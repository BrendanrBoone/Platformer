local Sunny = {}
Sunny.__index = Sunny

ActiveSunnys = {}

function Sunny.new(x, y)
    local instance = setmetatable({}, Sunny)

    instance.x = x
    instance.y = y

    Sunny.img = love.graphics.newImage("assets/thousandSunny.png")
    Sunny.width = Sunny.img:getWidth()
    Sunny.height = Sunny.img:getHeight()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed

    table.insert(ActiveSunnys, instance)
end

function Sunny.removeAll()
    for _, v in ipairs(ActiveSunnys) do
        v.physics.body:destroy()
    end

    ActiveSunnys = {}
end

function Sunny:setState(dt)

end

function Sunny:update(dt)
    self:setState(dt)
    self:float(dt)
end

function Sunny:float(dt)
    local Displacement = math.sin(love.timer.getTime() * 2) * 0.05
    print(Displacement)
    self.y = self.y + Displacement
end

function Sunny:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

function Sunny.updateAll(dt)
    for i, instance in ipairs(ActiveSunnys) do
        instance:update(dt)
    end
end

function Sunny.drawAll()
    for i, instance in ipairs(ActiveSunnys) do
        instance:draw()
    end
end

return Sunny
