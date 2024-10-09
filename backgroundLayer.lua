local BackgroundLayer = {}
BackgroundLayer.__index = BackgroundLayer

ActiveBackgroundLayers = {}

function BackgroundLayer.new(img, srcFixture, layerN, xOff, yOff, width, height)
    local instance = setmetatable({}, BackgroundLayer)

    instance.img = img

    instance.src = {}
    instance.src.fixture = srcFixture

    instance.layerN = layerN

    instance.xOff = xOff -- offset from associated body
    instance.yOff = yOff
    instance.width = width
    instance.height = height

    instance:syncAssociate()

    table.insert(LiveBackgroundLayeres, instance)
end

function BackgroundLayer:update(dt)
    self:syncAssociate()
    self:syncHit()
end

-- attaches BackgroundLayer to associated body
function BackgroundLayer:syncAssociate()
    self:syncCoordinate()
    self.physics.body:setPosition(self.x, self.y)
end

function BackgroundLayer:syncCoordinate()
    local body = self.src.fixture:getBody()
    self.x = body:getX() + self.xOff
    self.y = body:getY() + self.yOff
end

-- helper function
function BackgroundLayer.isInTable(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

function BackgroundLayer:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, self.width / 2, self.height / 2)
end

function BackgroundLayer.updateAll(dt)
    for _, instance in ipairs(LiveBackgroundLayeres) do
        instance:update(dt)
    end
end

function BackgroundLayer.drawAll()
    for _, instance in ipairs(LiveBackgroundLayeres) do
        instance:draw()
    end
end

return BackgroundLayer
