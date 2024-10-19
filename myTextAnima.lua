local Anima = {}
Anima.__index = Anima

ActiveTextAnimas = {}

function Anima.new(trigger, text)
    local instance = setmetatable({}, Anima)

    instance.trigger = trigger -- love.physics.fixture

    instance.text = text
    instance.textLength = #text
    instance.currentlyAnimatedText = ""
    instance.animation = {
        timer = 0,
        rate = 0.1
    }
    instance.font = love.graphics.newFont("assets/bit.ttf", 10)

    instance.animating = false

    table.insert(ActiveTextAnimas, instance)
end

function Anima:newTypingAnimation(text)
    if text ~= self.text then
        self.text = text
        self.textLength = #text
        self.currentlyAnimatedText = ""
    end
end

function Anima:update(dt)
    if self.animating then
        self:animate(dt)
    end
end

function Anima.updateAll(dt)
    for _, instance in ipairs(ActiveTextAnimas) do
        instance:update(dt)
    end
end

function Anima:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Anima:setNewFrame()
    local len = #self.currentlyAnimatedText
    if len < self.textLength then
        self.currentlyAnimatedText = string.sub(self.text, 1, len + 1)
    else
        self.animating = false
    end
end

function Anima.removeAll()
    for _, instance in ipairs(ActiveTextAnimas) do
        instance.text = ""
    end
    ActiveTextAnimas = {}
end

function Anima:draw()
    local x, y = self.trigger:getBody():getPosition()
    local displayTextLength = self.font:getWidth(self.text)
    local robinHeight = 60 -- arbitrary
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.currentlyAnimatedText, x - displayTextLength / 2, y - robinHeight / 2)
end

function Anima.drawAll()
    for _, instance in ipairs(ActiveTextAnimas) do
        instance:draw()
    end
end

function Anima.animationStart(fixture)
    for _, instance in ipairs(ActiveTextAnimas) do
        if instance.trigger == fixture then
            instance.animating = true
        end
    end
end

function Anima.animationEnd(fixture)
    for _, instance in ipairs(ActiveTextAnimas) do
        if instance.trigger == fixture then
            instance.animating = false
            instance.currentlyAnimatedText = ""
        end
    end
end

return Anima
