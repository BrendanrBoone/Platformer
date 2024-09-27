local Hitbox = {}
Hitbox.__index = Hitbox

ActiveHitboxes = {}

function Hitbox.new(srcFixture, targets, xOff, yOff, width, height, damage, xVel, yVel)
    local instance = setmetatable({}, Hitbox)

    instance.srcFixture = {}
    instance.srcFixture.body = srcFixture:getBody()
    instance.srcFixture.x = instance.srcFixture.body:getX()
    instance.srcFixture.y = instance.srcFixture.body:getY()

    -- table consisting of types objects that the hitbox can interact with. Needs to consist of fixtures
    instance.targets = targets

    instance.xOff = xOff -- offset from associated body
    instance.yOff = yOff
    instance.width = width
    instance.height = height

    instance:syncAssociate()

    instance.xVel = xVel
    instance.yVel = yVel
    instance.damage = damage
    instance.active = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.xPos, instance.yPos, "kinematic")
    instance.physics.shape = love.physics.newCircleShape(instance.height/2)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveHitboxes, instance)
end

function Hitbox:update(dt)
    self:syncAssociate()
end

-- attaches hitbox to associated body
function Hitbox:syncAssociate()
    self.x = self.srcFixture.x + self.xOff
    self.y = self.srcFixture.y + self.yOff
end

-- applies damage and knockback
function Hitbox:hit(enemy)
    enemy:takeDamage(self.damage)
    enemy:takeKnockback(self.xVel, self.yVel)
end

function Hitbox:draw()
    print("x: "..self.x.." y: "..self.y)
    love.graphics.circle("fill", self.x, self.y, self.height/2)
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
        if instance.active and (a == instance.physics.fixture or b == instance.physics.fixture) then
            if (a ~= Player.physics.fixture or b ~= Player.physics.fixture) then
                for _, target in ipairs(instance.targets) do
                    if a == target.physics.fixture or b == target.physics.fixture then
                        print("collision: "..collision)
                    end
                end
            end
        end
    end
end

return Hitbox
