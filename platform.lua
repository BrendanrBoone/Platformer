local Platform = {}
Platform.__index = Platform

ActivePlatforms = {}

local Camera = require("camera")
local Player = require("player")

local levelScale = 100

function Platform.new(x, y, width, height)
    local instance = setmetatable({}, Platform)

    -- instance.img = love.graphics.newImage("assets/"..imgName..".png")
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

    instance.physics.fixture:setUserData("platform")

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
    -- love.graphics.draw(self.img, self.x, self.posY)
    love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function Platform.drawAll()
    for _, instance in ipairs(ActivePlatforms) do
        instance:draw()
    end
end

function Platform.beginContact(a, b, collision)
    -- Check if one of the fixtures involved in the collision is the platform's fixture
    for _, instance in ipairs(ActivePlatforms) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            print("instance")
            -- Only proceed if the player is not already grounded
            if Player.grounded == true then
                return
            end
            
            -- Get the normal of the collision
            local __, ny = collision:getNormal()
            
            -- Check if the colliding object is the player
            if a == Player.physics.fixture or b == Player.physics.fixture then
                print("hit")
                -- If the collision normal indicates a collision from above
                if ny > 0 then
                    -- Allow the player to land on the platform
                    Player:land(collision)
                else
                    -- If the player collides from below, reset vertical velocity
                    Player.yVel = 0
                end
            end
        end
    end
end

return Platform
