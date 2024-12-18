local Player = {}
local Sounds = require("sounds")
local Explosion = require("explosion")
local STI = require("sti")
local Hitbox = require("hitbox")
local Helper = require("helper")
local BackgroundObject = require("backgroundObject")
local Anima = require("myTextAnima")

PlayerContacts = {} -- fixtures

function Player:load()
    self.x = 100
    self.y = 100
    self.FrankyOffsetY = -5
    self.FrankyOffsetX = 3
    self.startX = self.x
    self.startY = self.y
    self.width = 30
    self.height = 50
    self.xVel = 0 -- + goes right
    self.yVel = 0 -- + goes down
    self.maxSpeed = 200
    self.acceleration = 4000 -- 200 / 4000 = 0.05 seconds to reach maxSpeed
    self.friction = 3500 -- 200 / 3500 = 0.0571 seconds to stop from maxSpeed
    self.gravity = 1500
    self.jumpAmount = -500
    self.superJumpAmount = -2500
    self.airJumpAmount = self.jumpAmount * 0.8
    self.totalAirJumps = 1
    self.airJumpsUsed = 0
    self.dash = {
        amount = 700,
        cost = 50,
        inputPressed = 0,
        inputRequirment = 2
    }
    self.dash.graceTime = 0
    self.dash.graceDuration = 0.3
    self.coins = 0
    self.health = {
        current = 15,
        max = 15
    }
    self.stamina = {
        current = 200,
        max = 200,
        rate = 0.1
    }

    self.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3 -- speed to untint
    }

    self.graceTime = 0
    self.graceDuration = 0.1 -- time to do a grounded jump after leaving the ground

    -- boolean check if action are active
    self.activeForwardAir = false
    self.activeForwardAttack = false
    self.activeRushAttack = false

    self.emoting = false
    self.attacking = false
    self.dashing = false
    self.talking = false
    self.alive = true
    self.invincibility = false
    self.grounded = false
    self.direction = "right"
    self.state = "idle"

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true) -- doesn't rotate
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setGravityScale(0) -- unaffected by world gravity

    Anima.new(self.physics.fixture, "interact (E)", "below", 0)

    self:loadAssets()
    self:loadHitboxes()
end

function Player:loadAssets()
    self.animation = {
        timer = 0,
        rate = 0.1
    }

    self.animation.run = {
        total = 8,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.run.total do
        self.animation.run.img[i] = love.graphics.newImage("assets/Franky/run/" .. i .. ".png")
    end

    self.animation.idle = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/Franky/idle/" .. i .. ".png")
    end

    self.animation.airRising = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airRising.total do
        self.animation.airRising.img[i] = love.graphics.newImage("assets/Franky/airRising/" .. i .. ".png")
    end

    self.animation.airFalling = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airFalling.total do
        self.animation.airFalling.img[i] = love.graphics.newImage("assets/Franky/airFalling/" .. i .. ".png")
    end

    self.animation.jump = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.jump.total do
        self.animation.jump.img[i] = love.graphics.newImage("assets/Franky/jump/" .. i .. ".png")
    end

    self.animation.dash = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.dash.total do
        self.animation.dash.img[i] = love.graphics.newImage("assets/Franky/dash/" .. i .. ".png")
    end

    self.animation.emote = {
        total = 56,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.emote.total do
        local current, stillFrame = i, 9 -- loop emote from 9
        if current > stillFrame then
            current = stillFrame
        end
        self.animation.emote.img[i] = love.graphics.newImage("assets/Franky/emote/" .. current .. ".png")
    end

    self.animation.forwardAir = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.forwardAir.total do
        self.animation.forwardAir.img[i] = love.graphics.newImage("assets/Franky/forwardAir/" .. i .. ".png")
    end

    self.animation.forwardAttack = {
        total = 9,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.forwardAttack.total do
        self.animation.forwardAttack.img[i] = love.graphics.newImage("assets/Franky/forwardAttack/" .. i .. ".png")
    end

    self.animation.rushAttack = {
        total = 5,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.rushAttack.total do
        self.animation.rushAttack.img[i] = love.graphics.newImage("assets/Franky/rushAttack/" .. i .. ".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Player:loadHitboxes()
    self.hitbox = {}
    self:loadForwardAirHitbox()
    self:loadForwardAttackHitbox()
    self:loadRushAttackHitbox()
end

function Player:loadRushAttackHitbox()
    self.hitbox.rushAttack = {}
    self.hitbox.rushAttack.map = STI("hitboxMap/rushAttack.lua", {"box2d"})
    self.hitbox.rushAttack.hitboxesLayer = self.hitbox.rushAttack.map.layers.hitboxes
    self.hitbox.rushAttack.mapWidth = self.hitbox.rushAttack.map.layers.ground.width * 16
    self.hitbox.rushAttack.mapHeight = self.hitbox.rushAttack.map.layers.ground.height * 16

    self.hitbox.rushAttack.damage = 10
    self.hitbox.rushAttack.shakeSize = "medium"

    self.hitbox.rushAttack.knockbackAtFrame = {{100, 0}, {100, 0}, {100, 0}, {500, -100}}

    self.hitbox.rushAttack.targets = ActiveEnemys

    self.hitbox.rushAttack.type = "rushAttack"
    local args = {
        animTotal = self.animation.rushAttack.total,
        hitboxType = self.hitbox.rushAttack.type,
        layerObjects = self.hitbox.rushAttack.hitboxesLayer.objects,
        hitboxMapWidth = self.hitbox.forwardAir.mapWidth,
        hitboxMapHeight = self.hitbox.rushAttack.mapHeight,
        playerImgWidth = self.animation.width,

        srcFixture = self.physics.fixture,
        targets = self.hitbox.rushAttack.targets,
        width = self.width,
        xOff = self.FrankyOffsetX,
        height = self.height,
        yOff = self.FrankyOffsetY,

        damage = self.hitbox.rushAttack.damage,
        knockbackAtFrame = self.hitbox.rushAttack.knockbackAtFrame,
        shakeSize = self.hitbox.rushAttack.shakeSize
    }
    Hitbox.generateHitboxes(args)
end

function Player:loadForwardAttackHitbox()
    self.hitbox.forwardAttack = {}
    self.hitbox.forwardAttack.map = STI("hitboxMap/forwardAttack.lua", {"box2d"})
    self.hitbox.forwardAttack.hitboxesLayer = self.hitbox.forwardAttack.map.layers.hitboxes
    self.hitbox.forwardAttack.mapWidth = self.hitbox.forwardAttack.map.layers.ground.width * 16
    self.hitbox.forwardAttack.mapHeight = self.hitbox.forwardAttack.map.layers.ground.height * 16

    self.hitbox.forwardAttack.damage = 10
    self.hitbox.forwardAttack.shakeSize = "large"

    self.hitbox.forwardAttack.xVel = 500
    self.hitbox.forwardAttack.yVel = -100

    self.hitbox.forwardAttack.targets = ActiveEnemys

    self.hitbox.forwardAttack.type = "forwardAttack"
    local args = {
        animTotal = self.animation.forwardAttack.total,
        hitboxType = self.hitbox.forwardAttack.type,
        layerObjects = self.hitbox.forwardAttack.hitboxesLayer.objects,
        hitboxMapWidth = self.hitbox.forwardAir.mapWidth,
        hitboxMapHeight = self.hitbox.forwardAttack.mapHeight,
        playerImgWidth = self.animation.width,

        srcFixture = self.physics.fixture,
        targets = self.hitbox.forwardAttack.targets,
        width = self.width,
        xOff = self.FrankyOffsetX,
        height = self.height,
        yOff = self.FrankyOffsetY,

        damage = self.hitbox.forwardAttack.damage,
        xVel = self.hitbox.forwardAttack.xVel,
        yVel = self.hitbox.forwardAttack.yVel,
        shakeSize = self.hitbox.forwardAttack.shakeSize
    }
    Hitbox.generateHitboxes(args)
end

function Player:loadForwardAirHitbox()
    self.hitbox.forwardAir = {}
    self.hitbox.forwardAir.map = STI("hitboxMap/forwardAir.lua", {"box2d"})
    self.hitbox.forwardAir.hitboxesLayer = self.hitbox.forwardAir.map.layers.hitboxes
    self.hitbox.forwardAir.mapWidth = self.hitbox.forwardAir.map.layers.ground.width * 16
    self.hitbox.forwardAir.mapHeight = self.hitbox.forwardAir.map.layers.ground.height * 16

    self.hitbox.forwardAir.damage = 5
    self.hitbox.forwardAir.shakeSize = "small"

    self.hitbox.forwardAir.xVel = 500
    self.hitbox.forwardAir.yVel = -100

    self.hitbox.forwardAir.targets = ActiveEnemys

    self.hitbox.forwardAir.type = "forwardAir"
    local args = {
        animTotal = self.animation.forwardAir.total,
        hitboxType = self.hitbox.forwardAir.type,
        layerObjects = self.hitbox.forwardAir.hitboxesLayer.objects,
        hitboxMapWidth = self.hitbox.forwardAir.mapWidth,
        hitboxMapHeight = self.hitbox.forwardAir.mapHeight,
        playerImgWidth = self.animation.width,

        srcFixture = self.physics.fixture,
        targets = self.hitbox.forwardAir.targets,
        width = self.width,
        xOff = self.FrankyOffsetX,
        height = self.height,
        yOff = self.FrankyOffsetY,

        damage = self.hitbox.forwardAir.damage,
        xVel = self.hitbox.forwardAir.xVel,
        yVel = self.hitbox.forwardAir.yVel,
        shakeSize = self.hitbox.forwardAir.shakeSize
    }
    Hitbox.generateHitboxes(args)
end

function Player:takeDamage(amount)
    if not self.invincibility then
        self:cancelActiveActions()
        self:resetAnimations()
        self:resetHitboxes()

        self:tintRed()
        Sounds.playSound(Sounds.sfx.playerHit)
        if self.health.current - amount > 0 then
            self.health.current = self.health.current - amount
        else
            self.health.current = 0
            self:die()
        end
        print("Player health: " .. self.health.current)
    end
end

function Player:respawn()
    if not self.alive then
        self:resetPosition()
        self.health.current = self.health.max
        self.alive = true
    end
end

function Player:resetPosition()
    self.physics.body:setPosition(self.startX, self.startY)
end

function Player:setPosition(x, y)
    self.physics.body:setPosition(x, y)
    self:cancelActiveActions()
end

function Player:tintRed()
    self.color.green = 0
    self.color.blue = 0
end

function Player:die()
    print("Player Died")
    self.alive = false
end

function Player:incrementCoins()
    Sounds.playSound(Sounds.sfx.playerGetCoin)
    self.coins = self.coins + 1
end

function Player:pickUpItem(item)
    if item == "staminaRefresh" then
        self:staminaRefresh()
    end
end

function Player:staminaRefresh()
    -- play a noise
    self.stamina.current = self.stamina.max
end

function Player:update(dt)
    -- print(self.x..", "..self.y)
    self:unTint(dt)
    self:respawn()
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:decreaseGraceTime(dt)
    self:syncPhysics() -- sets character position
    self:move(dt)
    self:applyGravity(dt)
end

function Player:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Player:setState()
    if self.dashing then
        self.state = "dash"
    elseif not self.grounded then
        if self.attacking then
            if self.activeForwardAir then
                self.state = "forwardAir"
            end
        else
            if self.yVel < 0 then
                self.state = "airRising"
            else
                self.state = "airFalling"
            end
        end
    else
        if self.attacking then
            if self.activeForwardAttack then
                self.state = "forwardAttack"
            elseif self.activeRushAttack then
                self.state = "rushAttack"
            end
        else
            if self.xVel == 0 then
                if self.emoting then
                    self.state = "emote"
                else
                    self.state = "idle"
                end
            else
                self.state = "run"
            end
        end
    end
end

function Player:setDirection()
    if not self.attacking then
        if self.xVel > 0 then
            self.direction = "right"
        elseif self.xVel < 0 then
            self.direction = "left"
        end
    end
end

function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

-- updates the image
function Player:setNewFrame()
    local anim = self.animation[self.state]
    self:animEffects(anim)
    self.animation.draw = anim.img[anim.current]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
end

function Player:animEffects(animation)
    self:emoteOwEffects(animation)
    self:forwardAirEffects(animation)
    self:forwardAttackEffects(animation)
    self:rushAttackEffects(animation)
    self:dashEffects(animation)
end

function Player:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Player:doingAction()
    if self.emoting or self.attacking or self.talking or self.dashing then
        return true
    end
    return false
end

function Player:move(dt)
    -- sprint
    if love.keyboard.isDown("lshift") and self.stamina.current > 0 and self.xVel ~= 0 then
        self.maxSpeed = 400
        -- self.stamina.current = math.max(self.stamina.current - self.stamina.rate * 2, 0)
    else
        self.maxSpeed = 200
        self.stamina.current = math.min(self.stamina.current + self.stamina.rate, self.stamina.max)
    end

    -- left and right movement
    if love.keyboard.isDown("d", "right") and not self:doingAction() then
        self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
    elseif love.keyboard.isDown("a", "left") and not self:doingAction() then
        self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
    else
        self:applyFriction(dt)
    end
end

function Player:applyFriction(dt)
    if self.grounded then
        if self.xVel > 0 then
            self.xVel = math.max(self.xVel - self.friction * dt, 0)
        elseif self.xVel < 0 then
            self.xVel = math.min(self.xVel + self.friction * dt, 0)
        end
    else -- MAYBE CHANGE THIS LATER
        if self.xVel > 0 then
            self.xVel = math.max(self.xVel - self.friction / 6 * dt, 0)
        elseif self.xVel < 0 then
            self.xVel = math.min(self.xVel + self.friction / 6 * dt, 0)
        end
    end
end

function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

-- called in Player:update()
function Player:decreaseGraceTime(dt)
    if not self.grounded then
        self.graceTime = self.graceTime - dt
    end
    if self.dash.inputPressed ~= 0 then
        self.dash.graceTime = self.dash.graceTime - dt
        if self.dash.graceTime <= 0 then
            self.dash.inputPressed = 0
            self.dash.graceTime = self.dash.graceDuration
        end
    end
end

-- called in main.keypressed()
function Player:dashForward(key)
    if not self:doingAction() and key == "lshift" and self.dash.cost <= self.stamina.current then
        self.dash.inputPressed = self.dash.inputPressed + 1
        if self.dash.inputPressed == self.dash.inputRequirment then
            self.dashing = true
            self.dash.graceTime = self.dash.graceDuration
            self.dash.inputPressed = 0
            local v
            if self.direction == "right" then
                v = self.dash.amount
            else
                v = -self.dash.amount
            end
            self.xVel = self.xVel + v
            self.stamina.current = self.stamina.current - self.dash.cost
        end
    end
end

function Player:dashEffects(anim)
    if self.dashing and math.abs(self.xVel) <= self.maxSpeed then
        self:cancelActiveActions()
    end
end

function Player:jump(key)
    if not self:doingAction() then
        if (key == "w" or key == "up" or key == "space") then
            if self.grounded or self.graceTime > 0 then
                self.yVel = self.jumpAmount
                Sounds.playSound(Sounds.sfx.playerJump)
            elseif self.airJumpsUsed < self.totalAirJumps then
                self.yVel = self.airJumpAmount
                self.grounded = false
                self.airJumpsUsed = self.airJumpsUsed + 1
                Sounds.playSound(Sounds.sfx.playerJump)
            end
        end
    end
end

function Player:fastFall(key)
    if not self.grounded then
        if (key == "s") then
            self.yVel = -self.jumpAmount
        end
    end
end

-- reset cancellable animations
function Player:resetAnimations()
    self.animation.forwardAir.current = 1
    self.animation.forwardAttack.current = 1
    self.animation.rushAttack.current = 1
    self.animation.emote.current = 1
end

function Player:resetHitboxes()
    for _, hitbox in ipairs(LiveHitboxes) do
        for _, v in ipairs(self.hitbox) do
            if hitbox.type:find(v.type) then
                hitbox.active = false
            end
        end
    end
end

function Player:rushAttack(key)
    if not self:doingAction() and self.grounded and self.xVel ~= 0 and key == "p" then
        self.attacking = true
        self.activeRushAttack = true
    end
end

function Player:rushAttackEffects(anim)
    if self.activeRushAttack then
        self.invincibility = true
        for _, hitbox in ipairs(LiveHitboxes) do
            if hitbox.type:find(self.hitbox.rushAttack.type) then
                if self.direction == "right" and hitbox.type == self.hitbox.rushAttack.type .. anim.current .. "Right" then
                    hitbox.active = true
                elseif self.direction == "left" and hitbox.type == self.hitbox.rushAttack.type .. anim.current .. "Left" then
                    hitbox.active = true
                else
                    hitbox.active = false
                end
            end
        end
        if anim.current == anim.total then
            self:cancelActiveActions()
        end
    end
end

function Player:forwardAttack(key)
    if not self:doingAction() and self.grounded and self.xVel == 0 and key == "p" then
        self.attacking = true
        self.activeForwardAttack = true
    end
end

-- this determines what frames are active
function Player:forwardAttackEffects(anim)
    if self.activeForwardAttack then
        for _, hitbox in ipairs(LiveHitboxes) do
            if hitbox.type:find(self.hitbox.forwardAttack.type) then
                if self.direction == "right" and hitbox.type == self.hitbox.forwardAttack.type .. anim.current ..
                    "Right" then
                    hitbox.active = true
                elseif self.direction == "left" and hitbox.type == self.hitbox.forwardAttack.type .. anim.current ..
                    "Left" then
                    hitbox.active = true
                else
                    hitbox.active = false
                end
            end
        end
        if anim.current == anim.total then
            self:cancelActiveActions()
        end
    end
end

function Player:forwardAir(key)
    if not self.grounded and not self:doingAction() and key == "p" and love.keyboard.isDown("a", "d", "left", "right") then
        self.attacking = true
        self.activeForwardAir = true
    end
end

function Player:forwardAirEffects(anim)
    if self.activeForwardAir then
        self.invincibility = true
        for _, hitbox in ipairs(LiveHitboxes) do
            if hitbox.type:find(self.hitbox.forwardAir.type) then
                if self.direction == "right" and hitbox.type == self.hitbox.forwardAir.type .. anim.current .. "Right" then
                    hitbox.active = true
                elseif self.direction == "left" and hitbox.type == self.hitbox.forwardAir.type .. anim.current .. "Left" then
                    hitbox.active = true
                else
                    hitbox.active = false
                end
            end
        end
        if anim.current == anim.total then
            self:cancelActiveActions()
        end
    end
end

function Player:cancelActiveActions()
    self.attacking = false
    self.activeForwardAir = false
    self.activeForwardAttack = false
    self.activeRushAttack = false
    self.emoting = false
    self.invincibility = false
    self.dashing = false
end

function Player:emote(key)
    if false and not self:doingAction() and key == "e" and self.grounded and self.xVel == 0 then
        Sounds.sfx.frankyEyeCatchTheme:setVolume(Sounds.sfx.maxSound)
        Sounds.playSound(Sounds.sfx.frankyEyeCatchTheme)
        self.emoting = true
    end
end

function Player:emoteOwEffects(anim)
    if anim.current < anim.total and self.emoting and self.animation.emote.current == 10 then
        Sounds.playSound(Sounds.sfx.playerHit)
        Explosion.new(self.x, self.y)
    elseif anim.current == anim.total and self.emoting then
        self.emoting = false
    end
end

function Player:superJump()
    self.yVel = self.superJumpAmount
    Sounds.playSound(Sounds.sfx.playerJump)
end

function Player:checkIfTargets(fixture1, fixture2)
    for _, v in ipairs(self.hitbox.forwardAttack.targets) do
        if v.physics.fixture == fixture1 or v.physics.fixture == fixture2 then
            return true
        end
    end
    return false
end

function Player:beginContact(a, b, collision)
    if self.grounded == true then
        return
    end
    if Helper.ignore(a, b, Hitbox) then
        return
    end
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

function Player:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
    self.airJumpsUsed = 0
    self.graceTime = self.graceDuration

    self:cancelActiveActions()

    self:resetAnimations()
    self:resetHitboxes()
end

function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Player:draw()
    local scaleX = 1
    if self.direction == "left" then
        scaleX = -1
    end
    local width = self.animation.width / 2
    local height = self.animation.height / 2
    love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y + self.FrankyOffsetY, 0, scaleX, 1, width, height)
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Player
