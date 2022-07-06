require("map/map")

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

local test_map = {
    {0,1,1},
    {0,1,0},
    {1,0,0}
}

local debug_map = map:new(16, 4, 4, test_map)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 16)
end

function love.update()
    -- love.event.quit()
end

function love.draw()
    for x = 0,debug_map.size_x do
        for y = 0,debug_map.size_y do
            local value = debug_map:get_2d(x,y)
            if value > 0 then
                love.graphics.rectangle("fill",x * 20,y * 20, 16,16)
            end
        end
    end
end