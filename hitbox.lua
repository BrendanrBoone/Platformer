-- bug when moving between levels, If I were to do this again. I'd make a wholeHitbox object with hitboxes in it
local Hitbox = {}
Hitbox.__index = Hitbox

LiveHitboxes = {}

TargetsInRange = {} -- ex: {{'hitbox3': target1, target2, target3}, {'hitbox4': target1, target2, target3}}
HitboxTypeHit = {}

function Hitbox.new(srcFixture, type, targets, xOff, yOff, width, height, damage, xVel, yVel)
    local instance = setmetatable({}, Hitbox)

    instance.src = {}
    instance.src.fixture = srcFixture

    instance.type = type
    TargetsInRange[instance.type] = {}

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

    table.insert(LiveHitboxes, instance)
end

function Hitbox.loadAllTargets(targets)
    for _, hitbox in ipairs(LiveHitboxes) do
        hitbox.targets = targets
    end
end

function Hitbox:update(dt)
    self:syncAssociate()
    self:syncHit()
end

-- attaches hitbox to associated body
function Hitbox:syncAssociate()
    self:syncCoordinate()
    self.physics.body:setPosition(self.x, self.y)
end

function Hitbox:syncCoordinate()
    local body = self.src.fixture:getBody()
    self.x = body:getX() + self.xOff
    self.y = body:getY() + self.yOff
end

function Hitbox:syncHit()
    if self.active then
        if not self.isInTable(HitboxTypeHit, self.type) then
            table.insert(HitboxTypeHit, self.type)
            for i, target in ipairs(TargetsInRange[self.type]) do
                print("target was hit")
                self:hitTarget(target)
            end
        end
    else
        if self.isInTable(HitboxTypeHit, self.type) then
            for i, t in ipairs(HitboxTypeHit) do
                if t == self.type then
                    table.remove(HitboxTypeHit, i)
                end
            end
        end
    end
end

-- applies damage and knockback
function Hitbox:hitTarget(target)
    target:takeDamage(self.damage)
    target:takeKnockback(self.xVel, self.yVel)
end

-- helper function
function Hitbox.isInTable(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

function Hitbox:withinRange(target)
    if not self.isInTable(TargetsInRange[self.type], target) then
        table.insert(TargetsInRange[self.type], target)
        print("target in range")
    end
end

-- check if every hitbox with same type is in range: self.hit
function Hitbox:outsideRange(target)
    local allOutofRange = true
    for _, instance in ipairs(LiveHitboxes) do
        if instance.type == self.type and instance.hit then
            allOutofRange = false
            break
        end
    end

    if allOutofRange then
        for i, t in ipairs(TargetsInRange[self.type]) do
            if t == target then
                table.remove(TargetsInRange[self.type], i)
                print("target out of range")
            end
        end
    end
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
    for _, instance in ipairs(LiveHitboxes) do
        instance:update(dt)
    end
end

function Hitbox.drawAll()
    for _, instance in ipairs(LiveHitboxes) do
        instance:draw()
    end
end

function Hitbox.beginContact(a, b, collision)
    for _, instance in ipairs(LiveHitboxes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            for _, target in ipairs(instance.targets) do
                if a == target.physics.fixture or b == target.physics.fixture then
                    instance.hit = true
                    instance:withinRange(target)
                end
            end
        end
    end
end

function Hitbox.endContact(a, b, collision)
    for _, instance in ipairs(LiveHitboxes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            for _, target in ipairs(instance.targets) do
                if a == target.physics.fixture or b == target.physics.fixture then
                    instance.hit = false
                    instance:outsideRange(target)
                end
            end
        end
    end
end

return Hitbox
