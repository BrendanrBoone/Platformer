local NicoRobin = {}
NicoRobin.__index = NicoRobin

ActiveNicoRobins = {}
local Player = require("player")
local Anima = require("myTextAnima")

function NicoRobin.new(x, y)
    local instance = setmetatable({}, NicoRobin)

    instance.x = x
    instance.y = y

    instance.state = "idle"
    instance.idleTime = { current = 0, duration = 3}

    -- Animations
    instance.animation = { timer = 0, rate = 0.2 }
    instance.animation.idle = { total = 6, current = 1, img = NicoRobin.idleAnim }
    instance.animation.sittingDown = { total = 4, current = 1, img = NicoRobin.sittingDownAnim }
    instance.animation.reading = { total = 50, current = 1, img = NicoRobin.readingAnim }
    instance.animation.draw = instance.animation.idle.img[1]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed

    table.insert(ActiveNicoRobins, instance)
end

function NicoRobin.loadAssets()
    NicoRobin.idleAnim = {}
    for i = 1, 6 do
        NicoRobin.idleAnim[i] = love.graphics.newImage("assets/NicoRobin/idle/" .. i .. ".png")
    end

    NicoRobin.sittingDownAnim = {}
    for i = 1, 4 do
        NicoRobin.sittingDownAnim[i] = love.graphics.newImage("assets/NicoRobin/sittingDown/" .. i .. ".png")
    end

    NicoRobin.readingAnim = {}
    for i = 1, 50 do
        local current, stillFrame, lastFrame = i, 1, 4
        if current > lastFrame then
            current = stillFrame
        end
        NicoRobin.readingAnim[i] = love.graphics.newImage("assets/NicoRobin/reading/" .. current .. ".png")
    end

    NicoRobin.width = NicoRobin.idleAnim[1]:getWidth()
    NicoRobin.height = NicoRobin.idleAnim[1]:getHeight()
end

function NicoRobin.loadAnimaAnim()
    NicoRobin.speech = "Hey Franky"
    NicoRobin.SpeechTextAnimation = Anima:init()
    NicoRobin.SpeechTextAnimation:newTypingAnimation(NicoRobin.speech)
end

function NicoRobin.removeAll()
    for _, v in ipairs(ActiveNicoRobins) do
        v.physics.body:destroy()
    end

    ActiveNicoRobins = {}
end

function NicoRobin:setState(dt)
    if self.state == "idle" then
        self.idleTime.current = self.idleTime.current + dt
        if self.idleTime.current >= self.idleTime.duration then
            self.state = "sittingDown"
        end
    elseif self.state == "sittingDown"
    and self.animation.sittingDown.current >= self.animation.sittingDown.total then
        self.state = "reading"
    end
end

function NicoRobin:update(dt)
    self:setState(dt)
    self:animate(dt)
end

function NicoRobin:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

-- updates the image
function NicoRobin:setNewFrame()
    local anim = self.animation[self.state] -- not a copy. mirrors animation.[state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function NicoRobin:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function NicoRobin.updateAll(dt)
    for i, instance in ipairs(ActiveNicoRobins) do
        instance:update(dt)
    end
end

function NicoRobin.drawAll()
    for i, instance in ipairs(ActiveNicoRobins) do
        instance:draw()
    end
end

function NicoRobin.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveNicoRobins) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                return true
            end
        end
    end
end

return NicoRobin
