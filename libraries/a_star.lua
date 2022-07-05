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
    uint8_t = 8,
    uint16_t = 16,
    uint32_T = 32
}

-- function to allow EXACT memory assignment
local function exact_bytes(number_of_values)
    return(detect_architecture() * number_of_values)
end

-- this is a test, move it into tests when it's in it's own repo, this only works on 64 bit
assert(detect_architecture() * 10 == 64 * 10, "detect_architecture EXTREME error")



-- 256MB - this should be WAY MORE than enough
local memory = love.data.newByteData(exact_bytes(10))
-- local pointer = ffi.cast()
-- local test_array = ffi.cast(268435456)