local Menu = {}

-- Complete after finishing hitboxes

function Menu:load()
    self.exitButton = {}
    self.exitButton.img = love.graphics.newImage("assets/exitIcon.png")
    self.exitButton.width = self.exitButton.img:getWidth()
    self.exitButton.height = self.exitButton.img:getHeight()
    self.exitButton.x = love.graphics.getWidth() / 2 - self.exitButton.width / 2
    self.exitButton.y = love.graphics.getHeight() / 2
end

function Menu:update(dt)

end

function Menu:draw()

end

function Menu.quit()
    love.event.quit()
end

function Menu.Escape(key)
    if key == "escape" then
        if WorldPause then
            WorldPause = false
        else
            WorldPause = true
        end
    end
end

return Menu