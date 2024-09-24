local Trampoline = { img = love.graphics.newImage("assets/trampoline.png") }
Trampoline.__index = Trampoline
Trampoline.width = Trampoline.img:getWidth()
Trampoline.height = Trampoline.img:getHeight()

ActiveTrampolines = {}
local Player = require("player")

function Trampoline.new(x, y)
    local instance = setmetatable({}, Trampoline)

    instance.x = x
    instance.y = y

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    table.insert(ActiveTrampolines, instance)
end

function Trampoline.removeAll()
    for _,v in ipairs(ActiveTrampolines) do
        v.physics.body:destroy()
    end

    ActiveTrampolines = {}
end

function Trampoline:update(dt)

end

function Trampoline:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

function Trampoline.updateAll(dt)
    for _, instance in ipairs(ActiveTrampolines) do
        instance:update(dt)
    end
end

function Trampoline.drawAll()
    for _, instance in ipairs(ActiveTrampolines) do
        instance:draw()
    end
end

function Trampoline.beginContact(a, b, collision)
    for _, instance in ipairs(ActiveTrampolines) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                if Player.y + Player.height/2*0.75 < instance.y then
                    Player:superJump()
                    return true
                end
            end
        end
    end
end

return Trampoline
