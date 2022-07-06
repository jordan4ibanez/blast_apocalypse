require("map/map")

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

local debug_map = map:new(16, 20,20)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 16)
end

function love.update()
    -- love.event.quit()
end

function love.draw()
    for x = 0,debug_map.size_x do
        for y = 0,debug_map.size_y do
            love.graphics.rectangle("fill",10,10, x * 30,y * 30)
        end
    end
end