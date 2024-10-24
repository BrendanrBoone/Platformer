local Enemy = {}
Enemy.__index = Enemy
local Player = require("player")
local Hitbox = require("hitbox")
local Explosion = require("explosion")
local Helper = require("helper")

ActiveEnemys = {}

--[[
    known bugs:
    Excessive collision with stones confuse grounded state and floats in the air.
]]

function Enemy.new(x, y)
    local instance = setmetatable({}, Enemy)

    instance.x = x
    instance.y = y
    instance.offsetY = -8 -- model is inside the ground a bit
    instance.r = 0        -- rotation

    instance.speed = 100    -- NORMALLY 100
    instance.speedMod = 1
    instance.xVel = 0
    instance.yVel = 0
    instance.acceleration = 4000
    instance.friction = 3500
    instance.gravity = 1500

    instance.rageCounter = 1
    instance.rageTrigger = 3

    instance.damage = 1
    instance.hitCooldown = { time = 0, duration = 1 }
    instance.health = { current = 20, max = 20 }

    instance.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3 -- speed to untint
    }

    instance.moving = false
    instance.grounded = false
    instance.state = "walk"

    instance.animation = { timer = 0, rate = 0.1 }
    instance.animation.run = { total = 4, current = 1, img = Enemy.runAnim }
    instance.animation.walk = { total = 4, current = 1, img = Enemy.walkAnim }
    instance.animation.draw = instance.animation.walk.img[1]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.body:setFixedRotation(true)
    instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setGravityScale(0)

    table.insert(ActiveEnemys, instance)
end

function Enemy.removeAll()
    for _, v in ipairs(ActiveEnemys) do
        v.physics.body:destroy()
    end

    ActiveEnemys = {}
end

function Enemy:remove()
    for i, instance in ipairs(ActiveEnemys) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveEnemys, i)
        end
    end
end

function Enemy.loadAssets()
    Enemy.runAnim = {}
    for i = 1, 4 do
        Enemy.runAnim[i] = love.graphics.newImage("assets/enemy/run/" .. i .. ".png")
    end

    Enemy.walkAnim = {}
    for i = 1, 4 do
        Enemy.walkAnim[i] = love.graphics.newImage("assets/enemy/walk/" .. i .. ".png")
    end

    Enemy.width = Enemy.runAnim[1]:getWidth()
    Enemy.height = Enemy.runAnim[1]:getHeight()
end

function Enemy:update(dt)
    self:unTint(dt)
    self:syncPhysics()
    self:animate(dt)
    self:applyGravity(dt)
    self:move(dt)
    self:normalStateCheck()
    self:dealDamage(dt)
end

function Enemy:dealDamage(dt)
    if Helper.isInTable(PlayerContacts, self.physics.fixture) then
        if self.hitCooldown.time == 0 then
            Player:takeDamage(self.damage)
        end
        self.hitCooldown.time = self.hitCooldown.time + dt
        if self.hitCooldown.time >= self.hitCooldown.duration then
            self.hitCooldown.time = 0
        end
    else
        self.hitCooldown.time = 0
    end
end

function Enemy:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Enemy:normalStateCheck()
    if self.xVel == 0 and self.yVel == 0 then
        self.moving = true
    end
end

function Enemy:move(dt)
    if self.moving then
        if self.xVel >= 0 then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.speed)
        elseif self.xVel < 0 then
            self.xVel = math.max(self.xVel - self.acceleration * dt, -self.speed)
        end
    else
        self:applyFriction(dt)
    end
end

function Enemy:applyFriction(dt)
    if self.xVel > 0 then
        self.xVel = math.max(self.xVel - self.friction * dt, 0)
    elseif self.xVel < 0 then
        self.xVel = math.min(self.xVel + self.friction * dt, 0)
    end
end

function Enemy:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Enemy:takeKnockback(xVel, yVel)
    self.moving = false
    self.grounded = false
    self.xVel = xVel
    self.yVel = yVel
end

function Enemy:takeDamage(amount)
    self:tintRed()
    if self.health.current - amount > 0 then
        self.health.current = self.health.current - amount
    else
        self.health.current = 0
        self:die()
    end
    print("Enemy health: " .. self.health.current)
end

function Enemy:die()
    Hitbox.removeTargetFromRange(self)
    self:remove()
    Explosion.new(self.x, self.y)
end

function Enemy:tintRed()
    self.color.green = 0
    self.color.blue = 0
end

function Enemy:incrementRage()
    self.rageCounter = self.rageCounter + 1
    if self.grounded and self.rageCounter > self.rageTrigger then
        self.state = "run"
        self.speedMod = 3
        self.rageCounter = 1
    else
        self.state = "walk"
        self.speedMod = 1
    end
end

function Enemy:flipDirection()
    if self.xVel > 0 then
        self.xVel = -self.speed * self.speedMod
    else
        self.xVel = self.speed * self.speedMod
    end
end

function Enemy:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

-- updates the image
function Enemy:setNewFrame()
    local anim = self.animation[self.state] -- not a copy. mirrors animation.[state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Enemy:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Enemy:draw()
    local scaleX = 1
    if self.xVel < 0 then scaleX = -1 end
    love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2,
        self.height / 2)
    --[[love.graphics.rectangle("fill", self.x - (self.width * 0.4) / 2, self.y - (self.height * 0.75) / 2, self.width * 0.4,
        self.height * 0.75)]]
end

function Enemy.updateAll(dt)
    for _, instance in ipairs(ActiveEnemys) do
        instance:update(dt)
    end
end

function Enemy.drawAll()
    for _, instance in ipairs(ActiveEnemys) do
        instance:draw()
    end
end

function Enemy:checkGrounded(a, b, collision)
    if self.grounded == true then return end
    local __, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then
            self.yVel = 0
        end
    end
end

function Enemy:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
end

function Enemy.beginContact(a, b, collision)
    if (a:getUserData() and a:getUserData().__index == Hitbox)
        or (b:getUserData() and b:getUserData().__index == Hitbox) then
        return
    end
    for _, instance in ipairs(ActiveEnemys) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                table.insert(PlayerContacts, instance.physics.fixture)
            end

            instance:incrementRage()
            instance:flipDirection()
            instance:checkGrounded(a, b, collision)
        end
    end
end

function Enemy.endContact(a, b, collision)
    for _, instance in ipairs(ActiveEnemys) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if instance.currentGroundCollision == collision then
                instance.grounded = false
            elseif a == Player.physics.fixture or b == Player.physics.fixture then
                if Helper.isInTable(PlayerContacts, instance.physics.fixture) then
                    for i, f in ipairs(PlayerContacts) do
                        if f == instance.physics.fixture then
                            table.remove(PlayerContacts, i)
                        end
                    end
                end
            end
        end
    end
end

return Enemy
