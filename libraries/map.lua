local
math_floor
=
math.floor

local ffi = require("ffi")
dofile("libraries/a_star.lua")

print("\n")

print("loaded")

--[[
remember

c arrays start at 0

even though you can utilize 8 and 16 bits, they will be padded out to 32/64 in your ram

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

-- this is a test, move it into tests when it's in it's own rep
-- 10 values, 32 bit, 4 bytes in each memory cell
assert(10 * 4 == values_to_bytes(32, 10), "EXTREME error in detect_architecture")


-- test system for now
--[[
dev visualization:

8 bit blank
row 1                  
[0][0][0][0][0][0][0][0]
row 2
[0][0][0][0][0][0][0][0]

test[0] = 3

row 1                  
[0][0][0][0][0][0][1][1]
row 2
[0][0][0][0][0][0][0][0]
]]


-- map class
map = {}
local id = 0

-- map constructor
function map:new(bits, size_x, size_y, optional_preset, optional_default_value)

    assert(bits == 8 or bits == 16 or bits == 32, "bits must be 8, 16, or 32 depending on your needs")

    local object = {}

    object.size_x = size_x

    object.size_y = size_y

    object.memory = love.data.newByteData(values_to_bytes(bits, size_x * size_y))

    object.pointer = ffi.cast(data_to_string[bits], object.memory:getFFIPointer())

    object.id = id

    id = id + 1

    setmetatable(object, self)

    self.__index = self

    return object
end

-- map helper - base 0
-- 1d to 2d calcultion
function map:convert_1d_to_2d(i)
    return({math_floor(i % self.size_x), math_floor(i / self.size_x)})
end
-- 2d to 1d calculation
function map:convert_2d_to_1d(x,y)
    return math_floor((y * self.size_x) + x)
end




local test_map = map:new(8, 10, 10)

print("map size: " .. tostring(test_map.memory:getSize()))

--[[
-- to find the exact bytes, multiply by 8
print("memory size (bytes) = " .. tostring(memory:getSize()))

pointer[0] = 1
print(pointer[0])

-- this overflows and wraps around
pointer[1] = 1234
print(pointer[1])

-- allows you to create security issue, this must be fixed in full api
-- todo: FIX THIS
-- pointer[20000000] = 5
-- print(pointer[20000000])
]]--