local ffi = require("ffi")

print("\n")

print("loaded")

-- remember c arrays start at 0

-- function to simplify memory assignment
local function megabytes(input_value)
    return(1048576 * input_value)
end

assert(268435456 ==  megabytes(256), "SOMETHING HAS GONE WRONG WITH MEGABYTES CALCULATION!!")


-- 256MB
-- local test_array = ffi.cast(268435456)