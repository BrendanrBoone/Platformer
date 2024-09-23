local GUI = {}
local Player = require("player")

function GUI:load()
    self.coins = {}
    self.coins.img = love.graphics.newImage("assets/coin.png")
    self.coins.width = self.coins.img:getWidth()
    self.coins.height = self.coins.img:getHeight()
    self.coins.scale = 3
    self.coins.x = love.graphics.getWidth() - 200
    self.coins.y = 50

    self.hearts = {}
    self.hearts.img = love.graphics.newImage("assets/heart.png")
    self.hearts.width = self.hearts.img:getWidth()
    self.hearts.height = self.hearts.img:getHeight()
    self.hearts.x = 0
    self.hearts.y = 30
    self.hearts.scale = 3
    self.hearts.spacing = self.hearts.width * self.hearts.scale + 30

    self.volume = {}
    self.volume.img_soundOn = love.graphics.newImage("assets/ui/volumeIcon48x48.png")
    self.volume.img_soundOff = love.graphics.newImage("assets/ui/volumeIconMute48x48.png")
    self.volume.img = self.volume.img_soundOn
    self.volume.width = self.volume.img:getWidth()
    self.volume.height = self.volume.img:getHeight()
    self.volume.x = 30
    self.volume.y = love.graphics.getHeight() - self.volume.height - 20
    self.volume.scale = 1

    self.font = love.graphics.newFont("assets/bit.ttf", 36)
end

function GUI:update(dt)

end

function GUI:draw()
    GUI:displayCoins()
    GUI:displayCoinText()
    GUI:displayHearts()
    GUI:displayVolume()
end

function GUI:displayVolume()
    love.graphics.draw(self.volume.img, self.volume.x, self.volume.y, 0, self.volume.scale, self.volume.scale)
end

function GUI:displayHearts()
    for i = 1, Player.health.current do
        local x = self.hearts.x + self.hearts.spacing * i
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.draw(self.hearts.img, x + 2, self.hearts.y + 2, 0, self.hearts.scale, self.hearts.scale)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.hearts.img, x, self.hearts.y, 0, self.hearts.scale, self.hearts.scale)
    end
end

function GUI:displayCoins()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.draw(self.coins.img, self.coins.x + 2, self.coins.y + 2, 0, self.coins.scale, self.coins.scale)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.coins.img, self.coins.x, self.coins.y, 0, self.coins.scale, self.coins.scale)
end

function GUI:displayCoinText()
    love.graphics.setFont(self.font)
    local x = self.coins.x + self.coins.width * self.coins.scale
    local y = self.coins.y + self.coins.height / 2 * self.coins.scale - self.font:getHeight() / 2
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(" : " .. Player.coins, x + 2, y + 2) -- shadow
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(" : " .. Player.coins, x, y)
end

return GUI
