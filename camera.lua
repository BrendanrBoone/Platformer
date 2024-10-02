local Camera = {
    x = 0,
    y = 0,
    scale = 2,

    shaking = false,
    shakingTimer = 0
}

--starts camera
function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:clear()
    love.graphics.pop()
end

--called in love.update(dt)
function Camera:setPosition(x, y)
    self.x = x - love.graphics.getWidth() / 2 / self.scale
    self.y = y - love.graphics.getHeight() / 2 / self.scale
    local RS = self.x + love.graphics.getWidth() / 2
    local BS = self.y + love.graphics.getHeight() / 2

    if self.x < 0 then
        self.x = 0
    elseif RS > MapWidth then
        self.x = MapWidth - love.graphics.getWidth() / 2
    end

    if self.y < 0 then
        self.y = 0
    elseif BS > MapHeight then
        self.y = MapHeight - love.graphics.getHeight() / 2
    end

    if self.shaking then
        local scale = 1
        if self.shakingTimer % 2 ~= 0 then
            scale = -1
        end
        self.y = self.y + self.maxY * scale
        self.x = self.x + self.maxX * scale
        self.shakingTimer = self.shakingTimer - 1
        if self.shakingTimer <= 0 then
            self.shaking = false
        end
        print("shook xvel:" .. self.xVel .. " yvel:" .. self.yVel .. " timer:" .. self.shakingTimer)
    end
end

--[[local shakeDirection = 1
        if self.shakingTimer % 2 == 0 then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxX)
            self.yVel = math.max(self.yVel - self.acceleration * dt, -self.maxY)
        else
            shakeDirection = -shakeDirection
            self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxX)
            self.yVel = math.min(self.yVel + self.acceleration * dt, self.maxY)
        end
        print("shook xvel:" .. self.xVel .. " yvel:" .. self.yVel .. " timer:" .. self.shakingTimer)
        self.x = x - love.graphics.getWidth() / 2 / self.scale + self.xVel * shakeDirection
        self.y = y - love.graphics.getHeight() / 2 / self.scale + self.yVel * -shakeDirection
        if self.xVel == self.maxX and self.yVel == -self.maxY then
            self.shakingTimer = self.shakingTimer - 1
        end
        if self.shakingTimer == 0 then
            self.shaking = false
        end]]

-- NEED TO ADD ACCELERATION
--@size: string == "large", "medium", "small", "extraSmall"
-- defaults to extraSmall if unknown size
function Camera:shake(size)
    self.shaking = true

    self.xVel = 0
    self.yVel = 0
    self.acceleration = 1
    self.maxX = 0
    self.maxY = 2
    self.shakingTimer = 2

    if size == "large" then
        self.maxX = 2
        self.maxY = 3
        self.shakingTimer = 6
    elseif size == "medium" then
        self.maxX = 1
        self.maxY = 2
        self.shakingTimer = 4
    elseif size == "small" then
        self.maxX = 0
        self.maxY = 2
    end
end

return Camera
