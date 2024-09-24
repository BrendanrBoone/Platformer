local Coin = {}
Coin.__index = Coin
local ActiveCoins = {}
local Player = require("player")

-- note: "." vs ":" -> ":" implies "self" like a referenced table, "." does not
function Coin.new(x, y)
    local instance = setmetatable({}, Coin)

    instance.x = x
    instance.y = y
    instance.img = love.graphics.newImage("assets/coin.png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.scaleX = 1
    instance.randomTimeOffset = math.random(0, 100)
    instance.toBeRemoved = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed

    table.insert(ActiveCoins, instance)
end

function Coin:remove()
    for i, instance in ipairs(ActiveCoins) do
        if instance == self then
            Player:incrementCoins()
            self.physics.body:destroy()
            table.remove(ActiveCoins, i)
        end
    end
end

function Coin.removeAll()
    for i,v in ipairs(ActiveCoins) do
        v.physics.body:destroy()
    end

    ActiveCoins = {}
end

function Coin:update(dt)
    self:spin()
    self:checkRemove()
end

function Coin:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

-- animation without using images
function Coin:spin()
    self.scaleX = math.sin(love.timer.getTime() * 2 + self.randomTimeOffset)
end

function Coin:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Coin.updateAll()
    for __, instance in ipairs(ActiveCoins) do
        instance:update()
    end
end

function Coin.drawAll()
    for __, instance in ipairs(ActiveCoins) do
        instance:draw()
    end
end
-- this might be wrong but I'm keeping it
--[[for i=1, #ActiveCoins do
        ActiveCoins[i]:draw()
    end]]

function Coin.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveCoins) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.toBeRemoved = true
                return true
            end
        end
    end
end

return Coin