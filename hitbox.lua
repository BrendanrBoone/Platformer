local Hitbox = {}
Hitbox.__index = Hitbox

ActiveHitboxes = {}

function Hitbox.new(srcBody, xOff, yOff, width, height, damage)
    local instance = setmetatable({}, Hitbox)

    instance.srcBody = {} -- associated body "attached"
    instance.srcBody.body = srcBody
    instance.srcBody.x = srcBody:getX()
    instance.srcBody.y = srcBody:getY()

    instance.xOff = xOff -- offset from associated body
    instance.yOff = yOff
    instance.width = width
    instance.height = height

    instance.xPos = instance.assbod.x + instance.xOff -- hitbox x coordinate
    instance.yPos = instance.assbod.y + instance.yOff

    instance.damage = damage

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.xPos, instance.yPos, "kinematic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveHitboxes, instance)
end

function Hitbox:update(dt)

end

function Hitbox:syncAssociate()

end

function Hitbox:draw()

end

function Hitbox.updateAll(dt)
    for _, instance in ipairs(ActiveHitboxes) do
        instance:update(dt)
    end
end

return Hitbox