local
math_floor, table_insert, table_sort, table_remove
=
math.floor, table.insert, table.sort, table.remove

local ffi = require("ffi")

print("\n")

print("loaded")

--[[
remember

c arrays start at 0

even though you can utilize 8 and 16 bits, they will be padded out to 32/64 in your ram

maps utilize unsigned integers, no negativity, badum tss

count base 0, a single shift is a row toggle right, an X overflow moves into next column

0,0|1,0|2,0|3,0|etc
0,1|1,1|2,1|3,1|etc
etc

]]--

-- function to simplify memory assignment
local function megabytes(input_value)
    return(1048576 * input_value)
end

-- this is a test, move it to tests when it's in it's own repo
assert(268435456 ==  megabytes(256), "SOMETHING HAS GONE WRONG WITH MEGABYTES CALCULATION!!")

-- simple helper tables
local data_converted = {
    [8]  = 1,
    [16] = 2,
    [32] = 4
}
local data_to_string = {
    [8]  = "uint8_t*",
    [16] = "uint16_t*",
    [32] = "uint32_t*"
}

-- function to allow EXACT memory assignment
local function values_to_bytes(data_type, number_of_values)
    assert(data_type == 8 or data_type == 16 or data_type == 32, "data_type must be a C unsigned whole number, up to 32 bits")
    return(data_converted[data_type] * number_of_values)
end

-- this is a test, move it into tests when it's in it's own repo
-- 10 values, 32 bit, 4 bytes in each memory cell
assert(10 * 4 == values_to_bytes(32, 10), "EXTREME error in detect_architecture")


-- map class
map = {}

-- creates individual signatures with identical maps
local id = 0

-- map constructor
function map:new(bits, size_x, size_y, optional_preset, optional_default_value)

    assert(bits == 8 or bits == 16 or bits == 32, "bits must be 8, 16, or 32 depending on your needs")

    assert(size_x, "size_x not defined")
    assert(size_y, "size_y not defined")

    assert(size_x > 1, "size_x must be greater than 1")
    assert(size_y > 1, "size_y must be greater than 1")

    local object = {}

    -- this makes it easier to work with in lua
    object.size_x = size_x - 1
    object.size_y = size_y - 1

    object.__internal_size_x = size_x
    object.__internal_size_y = size_y

    object.linear_size = size_x * size_y

    object.bits = bits

    object.memory = love.data.newByteData(values_to_bytes(bits, size_x * size_y))

    object.pointer = ffi.cast(data_to_string[bits], object.memory:getFFIPointer())

    object.walkable_ids = {}

    object.id = id

    id = id + 1

    setmetatable(object, self)

    self.__index = self

    -- set set defined map OR default value
    if optional_preset then
        -- take in first come first serve values
        local predefined_y_size = #optional_preset
        local predefined_x_size = #optional_preset[1]

        assert(predefined_y_size == object.__internal_size_y, "PREDEFINED MAP Y (left/right) IS NOT THE SAME SIZE AS DEFINITION!\nRecieved " .. tostring(predefined_y_size) .. " height instead of defined " .. tostring(object.size_y))
        assert(predefined_x_size == object.__internal_size_x, "PREDEFINED MAP X (up/down) IS NOT THE SAME SIZE AS DEFINITION!\nRecieved " .. tostring(predefined_x_size) .. " width instead of defined " .. tostring(object.size_x))

        -- reconfigure them to intake literal spacial definition as it appears in code
        for y = 1,predefined_y_size do
            for x = 1,predefined_x_size do
                local injecting_value = optional_preset[y][x]
                assert(injecting_value ~= nil, "predefined map is probably uneven, error at X: " .. tostring(x) .. " | Y: " .. tostring(y))
                object.pointer[object:convert_2d_to_1d(x - 1, y - 1)] = injecting_value
            end
        end
    elseif optional_default_value then
        for i = 0,object.linear_size do
            object.pointer[i] = optional_default_value
        end
    end

    return object
end

-- allows users to destroy the map
function map:close()
    self.memory:release()
    self = nil
end

-- allows users to define which nodes are walkable
function map:add_walkables(walkables_table)
    for _,value in ipairs(walkables_table) do
        if not self.walkable_ids[value] then
            self.walkable_ids[value] = true
        end
    end
end

-- map helper - base 0
-- 1d to 2d calcultion
function map:convert_1d_to_2d(i)
    return({math_floor(i % self.__internal_size_x), math_floor(i / self.__internal_size_x)})
end
-- 2d to 1d calculation
function map:convert_2d_to_1d(x,y)
    return math_floor((y * self.__internal_size_x) + x)
end

-- map integer overflow protection
function map:overflow_protection(new_value)
    assert(new_value > 0, "INTEGER UNDERFLOW DETECTED!")
    if self.bits == 8 then
        assert(new_value <= 255, "INTEGER OVERFLOW DETECTED!")
    elseif self.bits == 16 then
        assert(new_value <= 65535, "INTEGER OVERFLOW DETECTED!")
    elseif self.bits == 32 then
        assert(new_value <= 4294967295, "INTEGER OVERFLOW DETECTED!")
    end
end

-- getter 1D
function map:get_1d(i)
    assert(i >= 0 and i < self.linear_size, "MAP 1D GETTER MUST BE BETWEEN 0 AND " .. tostring(self.linear_size) .. "!")
    return self.pointer[i]
end

-- getter 2D
function map:get_2d(x,y)
    assert(x >= 0 and x < self.__internal_size_x, "trying to get map location out of bounds on X: " .. tostring(x))
    assert(y >= 0 and y < self.__internal_size_y, "trying to get map location out of bounds on Y: " .. tostring(y))
    return self.pointer[self:convert_2d_to_1d(x,y)]
end

-- setter 1D
function map:set_1d(i, new_value)
    assert(i >= 0 and i < self.linear_size, "MAP 1D GETTER MUST BE BETWEEN 0 AND " .. tostring(self.linear_size) .. "!")
    self:overflow_protection(new_value)
    self.pointer[i] = new_value
end

-- setter 2D
function map:set_2d(x, y, new_value)
    assert(x >= 0 and x < self.__internal_size_x, "trying to get map location out of bounds on X: " .. tostring(x))
    assert(y >= 0 and y < self.__internal_size_y, "trying to get map location out of bounds on Y: " .. tostring(y))
    self:overflow_protection(new_value)
    self.pointer[self:convert_2d_to_1d(x,y)] = new_value
end


------------------ begin path finding algorithm --------------------------------------------

-- https://github.com/wesleywerner/lua-star/blob/master/src/lua-star.lua MIT

-- I'm (jordan4ibanez) going to try to leave the comments alone, they explain it pretty well

--- Provides easy A* path finding.
-- @map lua-star

--- Clears all cached paths.
function map:clearCached()
    map.cache = nil
end

-- (Internal) Returns a unique key for the start and end points.
local function keyOf(start, goal)
    return string.format("%d,%d>%d,%d", start.x, start.y, goal.x, goal.y)
end

-- (Internal) Returns the cached path for start and end points.
local function getCached(start, goal)
    if map.cache then
        local key = keyOf(start, goal)
        return map.cache[key]
    end
end

-- (Internal) Saves a path to the cache.
local function saveCached(start, goal, path)
    map.cache = map.cache or { }
    local key = keyOf(start, goal)
    map.cache[key] = path
end

-- (Internal) Return the distance between two points.
-- This method doesn't bother getting the square root of s, it is faster
-- and it still works for our use.
local function distance(x1, y1, x2, y2)
  local x = x1 - x2
  local y = y1 - y2
  return(x * x + y * y)
end

-- (Internal) Clamp a value to a range.
local function clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

-- (Internal) Return the score of a node.
-- G is the cost from START to this node.
-- H is a heuristic cost, in this case the distance from this node to the goal.
-- Returns F, the sum of G and H.
local function calculateScore(previous, node, goal)

    local G = previous.score + 1
    local H = distance(node.x, node.y, goal.x, goal.y)
    return G + H, G, H

end

-- (Internal) Returns true if the given list contains the specified item.
local function listContains(list, item)
    for _, test in ipairs(list) do
        if test.x == item.x and test.y == item.y then
            return true
        end
    end
    return false
end

-- (Internal) Returns the item in the given list.
local function listItem(list, item)
    for _, test in ipairs(list) do
        if test.x == item.x and test.y == item.y then
            return test
        end
    end
end

local positions = {
    { x = 0, y = -1 },  -- top
    { x = -1, y = 0 },  -- left
    { x = 0, y = 1 },   -- bottom
    { x = 1, y = 0 },   -- right
}

local diagonalMovements = {
    { x = -1, y = -1 },   -- top left
    { x = 1, y = -1 },   -- top right
    { x = -1, y = 1 },   -- bot left
    { x = 1, y = 1 },   -- bot right
}

-- (Internal) Requests adjacent map values around the given node.
function map:getAdjacent(width, height, node, positionIsOpenFunc, includeDiagonals)

    local result = {}

    if includeDiagonals then
        for _, value in ipairs(diagonalMovements) do
            table_insert(positions, value)
        end
    end

    for _, point in ipairs(positions) do
        local px = clamp(node.x + point.x, 1, width)
        local py = clamp(node.y + point.y, 1, height)
        local value = self:is_walkable( px, py )
        if value then
            table_insert( result, { x = px, y = py  } )
        end
    end

    return result

end

-- a bolt on, internal handler to see if position is walkable
function map:is_walkable(x,y)
    return self.walkable_ids[self.pointer[self:convert_2d_to_1d(x,y)]] ~= nil
end

-- Returns the path from start to goal, or false if no path exists.
function map:find(width, height, start, goal, positionIsOpenFunc, useCache, excludeDiagonalMoving)

    if useCache then
        local cachedPath = getCached(start, goal)
        if cachedPath then
            return cachedPath
        end
    end

    local success = false
    local open = { }
    local closed = { }

    start.score = 0
    start.G = 0
    start.H = distance(start.x, start.y, goal.x, goal.y)
    start.parent = { x = 0, y = 0 }
    table_insert(open, start)

    while not success and #open > 0 do

        -- sort by score: high to low
        table_sort(open, function(a, b) return a.score > b.score end)

        local current = table_remove(open)

        table_insert(closed, current)

        success = listContains(closed, goal)

        if not success then

            local adjacentList = self:getAdjacent(width, height, current, positionIsOpenFunc, not excludeDiagonalMoving)

            for _, adjacent in ipairs(adjacentList) do

                if not listContains(closed, adjacent) then

                    if not listContains(open, adjacent) then

                        adjacent.score = calculateScore(current, adjacent, goal)
                        adjacent.parent = current
                        table_insert(open, adjacent)

                    end

                end

            end

        end

    end

    if not success then
        return false
    end

    -- traverse the parents from the last point to get the path
    local node = listItem(closed, closed[#closed])
    local path = { }

    while node do

        table_insert(path, 1, { x = node.x, y = node.y } )
        node = listItem(closed, node.parent)

    end

    saveCached(start, goal, path)

    -- reverse the closed list to get the solution
    return path

end