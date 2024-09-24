local Explosion = {}
local Sounds = require("sounds")
local Player = require("player")

function Explosion:load()
    self.x = 100
    self.y = 0
    self.FrankyOffsetY = 5
    self.startX = self.x
    self.startY = self.y
    self.width = 30
    self.height = 50
    self.xVel = 0            -- + goes right
    self.yVel = 0            -- + goes down
    self.maxSpeed = 200
    self.acceleration = 4000 -- 200 / 4000 = 0.05 seconds to reach maxSpeed
    self.friction = 3500     -- 200 / 3500 = 0.0571 seconds to stop from maxSpeed
    self.gravity = 1500
    self.jumpAmount = -500
    self.superJumpAmount = -2500
    self.airJumpAmount = self.jumpAmount * 0.8
    self.totalAirJumps = 1
    self.airJumpsUsed = 0
    self.coins = 0
    self.health = { current = 3, max = 3 }

    self.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3 -- speed to untint
    }

    self.graceTime = 0
    self.graceDuration = 0.1 -- time to do a grounded jump after leaving the ground

    self.emoting = false
    self.alive = true
    self.grounded = false
    self.direction = "right"
    self.state = "idle"

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true) -- doesn't rotate
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setGravityScale(0) -- unaffected by world gravity
end

function Explosion:loadAssets()
    self.animation = { timer = 0, rate = 0.1 }

    self.animation.run = { total = 8, current = 1, img = {} }
    for i = 1, self.animation.run.total do
        self.animation.run.img[i] = love.graphics.newImage("assets/Franky/run/" .. i .. ".png")
    end

    self.animation.idle = { total = 4, current = 1, img = {} }
    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/Franky/idle/" .. i .. ".png")
    end

    self.animation.airRising = { total = 2, current = 1, img = {} }
    for i = 1, self.animation.airRising.total do
        self.animation.airRising.img[i] = love.graphics.newImage("assets/Franky/airRising/" .. i .. ".png")
    end

    self.animation.airFalling = { total = 2, current = 1, img = {} }
    for i = 1, self.animation.airFalling.total do
        self.animation.airFalling.img[i] = love.graphics.newImage("assets/Franky/airFalling/" .. i .. ".png")
    end

    self.animation.jump = { total = 2, current = 1, img = {} }
    for i = 1, self.animation.jump.total do
        self.animation.jump.img[i] = love.graphics.newImage("assets/Franky/jump/" .. i .. ".png")
    end

    self.animation.emote = { total = 16, current = 1, img = {} }
    for i = 1, self.animation.emote.total do
        self.animation.emote.img[i] = love.graphics.newImage("assets/Franky/emote/" .. i .. ".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Explosion:takeDamage(amount)
    self:tintRed()
    Sounds.playSound(Sounds.sfx.ExplosionHit)
    if self.health.current - amount > 0 then
        self.health.current = self.health.current - amount
    else
        self.health.current = 0
        self:die()
    end
    print("Explosion health: " .. self.health.current)
end

function Explosion:respawn()
    if not self.alive then
        self:resetPosition()
        self.health.current = self.health.max
        self.alive = true
    end
end

function Explosion:resetPosition()
    self.physics.body:setPosition(self.startX, self.startY)
end

function Explosion:setPosition(x, y)
    self.physics.body:setPosition(x, y)
end

function Explosion:tintRed()
    self.color.green = 0
    self.color.blue = 0
end

function Explosion:tintBlue()
    self.color.green = 0
    self.color.red = 0
end

function Explosion:die()
    print("Explosion Died")
    self.alive = false
end

function Explosion:incrementCoins()
    Sounds.playSound(Sounds.sfx.ExplosionGetCoin)
    self.coins = self.coins + 1
end

function Explosion:update(dt)
    self:unTint(dt)
    self:respawn()
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:decreaseGraceTime(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
end

function Explosion:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Explosion:setState()
    if not self.grounded then
        if self.yVel < 0 then
            self.state = "airRising"
        else
            self.state = "airFalling"
        end
    elseif self.xVel == 0 then
        if self.emoting then
            self.state = "emote"
        else
            self.state = "idle"
        end
    else
        self.state = "run"
    end
end

function Explosion:setDirection()
    if self.xVel > 0 then
        self.direction = "right"
    elseif self.xVel < 0 then
        self.direction = "left"
    end
end

function Explosion:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

-- updates the image
function Explosion:setNewFrame()
    local anim = self.animation[self.state] -- not a copy. mirrors animation.[state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        if self.emoting then
            self.emoting = false
        end
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Explosion:decreaseGraceTime(dt)
    if not self.grounded then
        self.graceTime = self.graceTime - dt
    end
end

function Explosion:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Explosion:move(dt)
    if not self.emoting then
        -- sprint
        if love.keyboard.isDown("lshift") then
            --self:tintBlue()
            self.maxSpeed = 400
        else
            self.maxSpeed = 200
        end

        -- left and right movement
        if love.keyboard.isDown("d", "right") then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
        elseif love.keyboard.isDown("a", "left") then
            self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
        else
            self:applyFriction(dt)
        end
    end
end

function Explosion:applyFriction(dt)
    if self.xVel > 0 then
        self.xVel = math.max(self.xVel - self.friction * dt, 0)
    elseif self.xVel < 0 then
        self.xVel = math.min(self.xVel + self.friction * dt, 0)
    end
end

function Explosion:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Explosion:beginContact(a, b, collision)
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

function Explosion:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
    self.airJumpsUsed = 0
    self.graceTime = self.graceDuration
end

function Explosion:jump(key)
    if not self.emoting then
        if (key == "w" or key == "up" or key == "space") then
            if self.grounded or self.graceTime > 0 then
                self.yVel = self.jumpAmount
                Sounds.playSound(Sounds.sfx.ExplosionJump)
            elseif self.airJumpsUsed < self.totalAirJumps then
                self.yVel = self.airJumpAmount
                self.grounded = false
                self.airJumpsUsed = self.airJumpsUsed + 1
                Sounds.playSound(Sounds.sfx.ExplosionJump)
            end
        end
    end
end

function Explosion:emote(key)
    if (key == "e" and self.grounded and self.xVel == 0) then
        self.emoting = true
    end
end

function Explosion:superJump()
    self.yVel = self.superJumpAmount
    Sounds.playSound(Sounds.sfx.ExplosionJump)
end

function Explosion:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Explosion:draw()
    local scaleX = 1
    if self.direction == "left" then scaleX = -1 end
    local width = self.animation.width / 2
    local height = self.animation.height / 2
    love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y - self.FrankyOffsetY, 0, scaleX, 1, width, height)
    love.graphics.setColor(1, 1, 1)
end

return Explosion