local Platform = {}
Platform.__index = Platform

ActivePlatforms = {}

local Player
local Camera = require("camera")

local levelScale = 100

function Platform.new(x, y, width, height)
    local instance = setmetatable({}, Platform)

    if not Player then
        Player = require("player")
    end

    --instance.img = love.graphics.newImage("assets/"..imgName..".png")
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "kinematic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed

    instance.playerLanded = false

    table.insert(ActivePlatforms, instance)
end

function Platform:update(dt)
    
end

function Platform.updateAll(dt)
    for _, instance in ipairs(ActivePlatforms) do
        instance:update(dt)
    end
end

function Platform.removeAll()
    for _, v in ipairs(ActivePlatforms) do
        v.physics.body:destroy()
    end
    ActivePlatforms = {}
end

function Platform:draw()
    --love.graphics.draw(self.img, self.x, self.posY)
    love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function Platform.drawAll()
    for _, instance in ipairs(ActivePlatforms) do
        instance:draw()
    end
end

function Platform.beginContact(a, b, collision)
    for i, instance in ipairs(ActivePlatforms) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                if Player.y + Player.height < instance.y then
                    Player:land(collision)
                    --instance.playerLanded = true
                end
            end
        end
    end
end

function Platform.endContact(a, b, collision)
    for i, instance in ipairs(ActivePlatforms) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                
            end
        end
    end
end

return Platform
