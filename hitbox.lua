local Hitbox = {}
Hitbox.__index = Hitbox

ActiveHitboxes = {}
local Enemy = require("enemy")

function Hitbox.new(srcBody, xOff, yOff, width, height, damage, knockbackX, knockbackY)
    local instance = setmetatable({}, Hitbox)

    instance.srcBody = {} -- associated body hitbox is attached to
    instance.srcBody.body = srcBody
    instance.srcBody.x = srcBody:getX()
    instance.srcBody.y = srcBody:getY()

    instance.xOff = xOff -- offset from associated body
    instance.yOff = yOff
    instance.width = width
    instance.height = height

    instance:syncAssociate()

    instance.knockbackX = knockbackX
    instance.knockbackY = knockbackY
    instance.damage = damage
    instance.active = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.xPos, instance.yPos, "kinematic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveHitboxes, instance)
end

function Hitbox:update(dt)
    self:syncAssociate()
end

-- attaches hitbox to associated body
function Hitbox:syncAssociate()
    self.x = self.srcBody.x + self.xOff
    self.y = self.srcBody.y + self.yOff
end

-- applies damage and knockback
function Hitbox:hit()

end

function Hitbox:draw()

end

function Hitbox.updateAll(dt)
    for _, instance in ipairs(ActiveHitboxes) do
        instance:update(dt)
    end
end

function Hitbox.beginContact(a, b, collision)
    for _, instance in ipairs(ActiveHitboxes) do
        if instance.active and (a == instance.physics.fixture or b == instance.physics.fixture) then
            
        end
    end

return Hitbox