local Enemy = {}
Enemy.__index = Enemy
local Player = require("player")

ActiveEnemys = {}

function Enemy.new(x, y)
    local instance = setmetatable({}, Enemy)

    instance.x = x
    instance.y = y
    instance.offsetY = -8 -- model is inside the ground a bit
    instance.r = 0        -- rotation

    instance.speed = 100
    instance.speedMod = 1
    instance.xVel = instance.speed
    instance.yVel = 100
    instance.gravity = 1500

    instance.rageCounter = 1
    instance.rageTrigger = 3

    instance.damage = 1
    instance.health = { current = 20, max = 20 }

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
    instance.physics.body:setMass(25)

    table.insert(ActiveEnemys, instance)
end

function Enemy.removeAll()
    for i, v in ipairs(ActiveEnemys) do
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
end

function Enemy:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Enemy:takeKnockback(xVel, yVel)

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
    if self.rageCounter > self.rageTrigger then
        self.state = "run"
        self.speedMod = 3
        self.rageCounter = 1
    else
        self.state = "walk"
        self.speedMod = 1
    end
end

function Enemy:flipDirection()
    self.xVel = -self.xVel
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
    self.physics.body:setLinearVelocity(self.xVel * self.speedMod, self.yVel)
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

function Enemy.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveEnemys) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamage(instance.damage)
            end

            instance:incrementRage()
            instance:flipDirection()
        end
    end
end

return Enemy
