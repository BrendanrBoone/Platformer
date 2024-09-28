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

    instance:syncCoordinate()

    instance.xVel = xVel
    instance.yVel = yVel
    instance.damage = damage
    instance.active = false
    instance.hit = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
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

function Hitbox:syncCoordinate()
    local body = self.src.fixture:getBody()
    self.x = body:getX() + self.xOff
    self.y = body:getY() + self.yOff
end

-- attaches hitbox to associated body
function Hitbox:syncAssociate()
    self:syncCoordinate()
    self.physics.body:setPosition(self.x, self.y)
end

-- applies damage and knockback
function Hitbox:hit(target)
    target:takeDamage(self.damage)
    target:takeKnockback(self.xVel, self.yVel)
end

function Hitbox:collisionFilter(target)
    print("hit")
    self.hit = true
end

function Hitbox:draw()
    if self.active then
        love.graphics.setColor(1, 0, 0)
    elseif self.hit then
        love.graphics.setColor(1, 1, 0)
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

-- push to hit target queue. filter out multiple hitboxes that hit the same object. hit when active is true
function Hitbox.beginContact(a, b, collision)
    for _, instance in ipairs(ActiveHitboxes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            for _, target in ipairs(instance.targets) do
                if a == target.physics.fixture or b == target.physics.fixture then
                    instance:collisionFilter(target)
                end
            end
        end
    end
end

function Hitbox.endContact(a, b, collision)
    for _, instance in ipairs(ActiveHitboxes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a ~= instance.src.fixture and b ~= instance.src.fixture then
                print("left hit")
                instance.hit = false
            end
        end
    end
end

--[[local hitbox, enemy
    if a:getUserData() and a:getUserData().__index == Hitbox then
        hitbox = a:getUserData()
        enemy = b:getUserData()
    elseif b:getUserData() and b:getUserData().__index == Hitbox then
        hitbox = b:getUserData()
        enemy = a:getUserData()
    else
        return
    end

    -- Check if the enemy is in the hitbox's target list
    for _, target in ipairs(hitbox.targets) do
        if target == enemy then
            -- Check if the hitbox is active
            if true then
                -- Check if the hitbox circle overlaps with the enemy rectangle
                local hitboxX, hitboxY = hitbox.physics.body:getPosition()
                local enemyX, enemyY = enemy.physics.body:getPosition()
                local enemyWidth, enemyHeight = enemy.physics.shape:getDimensions()
                local hitboxRadius = hitbox.physics.shape:getRadius()

                if math.abs(hitboxX - enemyX) < (enemyWidth / 2 + hitboxRadius) and
                   math.abs(hitboxY - enemyY) < (enemyHeight / 2 + hitboxRadius) then
                    -- The hitbox circle overlaps with the enemy rectangle, so apply damage and knockback
                    hitbox:collisionFilter(enemy)
                    return true
                end
            end
        end
    end]]

return Hitbox
