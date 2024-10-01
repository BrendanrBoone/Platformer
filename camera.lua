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
    if not self.shaking then
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
    end
end

--@size: string == "large", "medium", "small", "extraSmall"
-- defaults to extraSmall if unknown size
function Camera:shake(size)
    self.shaking = true
    
    self.xVel = 0
    self.yVel = 1
    self.shakingTimer = 2

    if size == "large" then
        self.yVel = 3
        self.xVel = 2
    elseif size == "medium" then
        self.yVel = 2
        self.xVel = 1
    elseif size == "small" then
        self.yVel = 2
    end
end

return Camera
