local Enemy = {}
Enemy.__index = Enemy
local Player = require("player")
local Hitbox = require("hitbox")

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

    instance.speed = 100
    instance.speedMod = 1
    instance.xVel = instance.speed
    instance.yVel = 0
    instance.gravity = 1500

    instance.rageCounter = 1
    instance.rageTrigger = 3

    instance.damage = 1
    instance.health = { current = 20, max = 20 }

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
    self:syncPhysics()
    self:animate(dt)
    self:applyGravity(dt)
    self:normalStateCheck()
end

function Enemy:normalStateCheck()
    if self.xVel == 0 and self.yVel == 0 then
        self.xVel = self.speed
    end
end

function Enemy:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Enemy:takeKnockback(xVel, yVel)
    self.xVel = xVel
    self.yVel = yVel
end

function Enemy:takeDamage(amount)
    if self.health.current - amount > 0 then
        self.health.current = self.health.current - amount
    else
        self.health.current = 0
        self:die()
    end
    print("Enemy health: " .. self.health.current)
end

function Enemy:die()
    self:remove()
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
    love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2,
        self.height / 2)
end

function Enemy.updateAll(dt)
    for i, instance in ipairs(ActiveEnemys) do
        instance:update(dt)
    end
end

function Enemy.drawAll()
    for i, instance in ipairs(ActiveEnemys) do
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
                Player:takeDamage(instance.damage)
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
            end
        end
    end
end

return Enemy
