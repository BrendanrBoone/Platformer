local BackgroundObject = {}
BackgroundObject.__index = BackgroundObject

ActiveBackgroundObjects = {}

local Player
local Camera = require("camera")

local levelScale = 100

function BackgroundObject.new(imgName, level, x, y, width, height)
    local instance = setmetatable({}, BackgroundObject)

    if not Player then
        Player = require("player")
    end

    instance.img = love.graphics.newImage("assets/"..imgName..".png")
    instance.level = level -- what level dictates the movement in background
    instance.posX = x
    instance.posY = y
    instance.width = width
    instance.height = height

    instance.bgoRange = instance.level * levelScale
    instance.bgoX = 0

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.posY, "kinematic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed

    table.insert(ActiveBackgroundObjects, instance)
end

function BackgroundObject:update(dt)
    self:syncAssociate()
end

function BackgroundObject.updateAll(dt)
    for _, instance in ipairs(ActiveBackgroundObjects) do
        instance:update(dt)
    end
end

-- move background object relative to where the player is on the map
function BackgroundObject:syncAssociate()
    self:syncCoordinate()
    self.physics.body:setPosition(self.x, self.posY)
end

function BackgroundObject:syncCoordinate()
    self.bgoX = Camera.x / MapWidth * self.bgoRange
    self.x = self.posX - self.bgoRange / 2 + self.bgoX
end

function BackgroundObject.removeAll()
    for _, v in ipairs(ActiveBackgroundObjects) do
        v.physics.body:destroy()
    end

    ActiveBackgroundObjects = {}
end

function BackgroundObject:draw()
    love.graphics.draw(self.img, self.x, self.posY)
    --love.graphics.rectangle("fill", self.x, self.posY, self.width, self.height)
end

function BackgroundObject.drawAll()
    for _, instance in ipairs(ActiveBackgroundObjects) do
        instance:draw()
    end
end

function BackgroundObject.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveBackgroundObjects) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                return true
            end
        end
    end
end

function BackgroundObject.endContact(a, b, collision)
    for i, instance in ipairs(ActiveBackgroundObjects) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                print("uncollided")
                return true
            end
        end
    end
end

return BackgroundObject
