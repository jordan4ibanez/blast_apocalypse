local ffi = require("ffi")
dofile("libraries/os_detector.lua")

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

-- simple helper table
local data_converted = {
    uint8_t = 1,
    uint16_t = 2,
    uint32_t = 4
}

-- function to allow EXACT memory assignment
local function values_to_bytes(data_type, number_of_values)
    assert(data_type == "uint8_t" or data_type == "uint16_t" or data_type == "uint32_t", "data_type must be a C unsigned whole number, up to 32 bits")
    return(data_converted[data_type] * number_of_values)
end

-- this is a test, move it into tests when it's in it's own rep
-- 10 values, 32 bit, 4 bytes in each memory cell
assert(10 * 4 == values_to_bytes("uint32_t", 10), "EXTREME error in detect_architecture")



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

local memory = love.data.newByteData(values_to_bytes("uint8_t", 2))
local pointer = ffi.cast("uint8_t*", memory:getFFIPointer())

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

