local Hitbox = {}
Hitbox.__index = Hitbox

ActiveHitboxes = {}

function Hitbox.new(x, y, width, height, damage)
    local instance = setmetatable({}, Hitbox)

    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height

    instance.damage = damage

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "kinematic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveHitboxes, instance)
end

function Hitbox:update(dt)

end

function Hitbox:draw()

end

function Hitbox.Escape(key)
    if key == "escape" then
        love.event.quit()
    end
end

return Hitbox