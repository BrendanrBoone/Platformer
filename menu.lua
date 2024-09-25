local Menu = {}

function Menu.load()
    
end

function Menu:update(dt)

end

function Menu:draw()

end

function Menu.Escape(key)
    if key == "escape" then
        love.event.quit()
    end
end

return Menu