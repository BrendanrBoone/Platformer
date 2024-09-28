local Hitbox = {}
Hitbox.__index = Hitbox

ActiveHitboxes = {}

function Hitbox.new(srcFixture, type, targets, xOff, yOff, width, height, damage, xVel, yVel)
    local instance = setmetatable({}, Hitbox)

    instance.src = {}
    instance.src.fixture = srcFixture

    instance.type = type

    -- table consisting of types objects that the hitbox can interact with. Needs to consist of fixtures
    instance.targets = targets

    instance.xOff = xOff -- offset from associated body
    instance.yOff = yOff
    instance.width = width
    instance.height = height


    local body = instance.src.fixture:getBody()
    instance.x = body:getX() + instance.xOff
    instance.y = body:getY() + instance.yOff

    instance.xVel = xVel
    instance.yVel = yVel
    instance.damage = damage
    instance.active = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "kinematic")
    instance.physics.shape = love.physics.newCircleShape(instance.height / 2)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData(instance)

    instance:syncAssociate()

    table.insert(ActiveHitboxes, instance)
end

function Hitbox:update(dt)
    self:syncAssociate()
end

-- attaches hitbox to associated body
function Hitbox:syncAssociate()
    local body = self.src.fixture:getBody()
    self.x = body:getX() + self.xOff
    self.y = body:getY() + self.yOff
    self.physics.body:setPosition(self.x, self.y)
end

-- applies damage and knockback
function Hitbox:hit(target)
    target:takeDamage(self.damage)
    target:takeKnockback(self.xVel, self.yVel)
end

function Hitbox:draw()
    if self.active then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.circle("fill", self.x, self.y, self.height / 2)
end

function Hitbox.updateAll(dt)
    for _, instance in ipairs(ActiveHitboxes) do
        instance:update(dt)
    end
end

function Hitbox.drawAll()
    for _, instance in ipairs(ActiveHitboxes) do
        instance:draw()
    end
end

function Hitbox.beginContact(a, b, collision)
    for _, instance in ipairs(ActiveHitboxes) do
        if instance.active then
            for i, target in ipairs(instance.targets) do
                print("target "..i)
                if a == target.physics.fixture or b == target.physics.fixture then
                    print("collision "..collision)
                end
            end
        end
    end
end

--[[if (a ~= instance.src.fixture or b ~= instance.src.fixture) then
                print("HERE")
                for i, target in ipairs(instance.targets) do
                    print('target '..i)
                    if a == target.physics.fixture or b == target.physics.fixture then
                        print("collision: "..collision)
                    end
                end
            end]]

return Hitbox
