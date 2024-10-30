local NicoRobin = {}
NicoRobin.__index = NicoRobin

ActiveNicoRobins = {}
local Player = require("player")
local Anima = require("myTextAnima")

function NicoRobin.new(x, y)
    local instance = setmetatable({}, NicoRobin)

    instance.x = x
    instance.y = y

    instance.interactable = false
    instance.state = "idle"
    instance.idleTime = {
        current = 0,
        duration = 3
    }

    -- Animations
    instance.animation = {
        timer = 0,
        rate = 0.2
    }
    instance.animation.idle = {
        total = 6,
        current = 1,
        img = NicoRobin.idleAnim
    }
    instance.animation.sittingDown = {
        total = 4,
        current = 1,
        img = NicoRobin.sittingDownAnim
    }
    instance.animation.reading = {
        total = 50,
        current = 1,
        img = NicoRobin.readingAnim
    }
    instance.animation.draw = instance.animation.idle.img[1]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed

    Anima.new(instance.physics.fixture, "Hey Franky!", "above")

    instance:loadDialogue()

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

function NicoRobin:loadDialogue()
    self.dialogueIndex = 0
    self.dialogueGrace = {
        time = 2,
        duration = 2
    }
    self.dialogue = {{"Player", "SUUUUPPPERRRRRRR!"}, {"NicoRobin", "You seem excited. What are you doing?"},
                     {"Player", "Sunny's in need of some repairs. I need to go collect wood for some patch work."},
                     {"NicoRobin", "Oh! I wish you luck"}, {"Player", "OW!"}}
end

function NicoRobin.removeAll()
    for _, v in ipairs(ActiveNicoRobins) do
        v.physics.body:destroy()
        Anima.remove(v.physics.fixture)
    end

    ActiveNicoRobins = {}
end

function NicoRobin:setState(dt)
    if self.state == "idle" then
        self.idleTime.current = self.idleTime.current + dt
        if self.idleTime.current >= self.idleTime.duration then
            self.state = "sittingDown"
        end
    elseif self.state == "sittingDown" and self.animation.sittingDown.current >= self.animation.sittingDown.total then
        self.state = "reading"
    end
end

function NicoRobin:update(dt)
    self:setState(dt)
    self:animate(dt)
    self:runDialogue(dt)
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

function NicoRobin:runDialogue(dt)
    if Player.talking and self.interactable then
        if not Anima.currentlyAnimating() then
            if self.dialogueGrace.time == self.dialogueGrace.duration then
                local playerAnima = assert(Anima.findAnima(Player.physics.fixture))
                local originalPlayerAnimaText = playerAnima.text
                playerAnima:modifyAnimationRate(0.1)
    
                local robinAnima = assert(Anima.findAnima(self.physics.fixture))
                local originalRobinAnimaText = robinAnima.text
                self.dialogueIndex = self.dialogueIndex + 1
                if self.dialogueIndex <= #self.dialogue then
                    if self.dialogue[self.dialogueIndex][1] == "NicoRobin" then
                        robinAnima:newTypingAnimation(self.dialogue[self.dialogueIndex][2])
                    elseif self.dialogue[self.dialogueIndex][1] == "Player" then
                        playerAnima:newTypingAnimation(self.dialogue[self.dialogueIndex][2])
                    end
                    print(self.dialogue[self.dialogueIndex][2])
                end
                if self.dialogueIndex > #self.dialogue then
                    print("finished")
                    self.dialogueIndex = 1
                    Player.talking = false
                    playerAnima:modifyAnimationRate(0)
                    playerAnima:newTypingAnimation(originalPlayerAnimaText)
                    robinAnima:newTypingAnimation(originalRobinAnimaText)
                end
            end
            self.dialogueGrace.time = self.dialogueGrace.time - dt
            if self.dialogueGrace.time <= 0 then
                self.dialogueGrace.time = self.dialogueGrace.duration
            end
        end
    end
end

function NicoRobin.interact(key)
    if key == "e" then
        for _, instance in ipairs(ActiveNicoRobins) do
            if instance.interactable then
                Player.talking = true
                return true
            end
        end
    end
end

function NicoRobin.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveNicoRobins) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.interactable = true
                Anima.animationStart(instance.physics.fixture)
                Anima.animationStart(Player.physics.fixture)
                return true
            end
        end
    end
end

function NicoRobin.endContact(a, b, collision)
    for i, instance in ipairs(ActiveNicoRobins) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.interactable = false
                Anima.animationEnd(instance.physics.fixture)
                Anima.animationEnd(Player.physics.fixture)
                return true
            end
        end
    end
end

return NicoRobin
