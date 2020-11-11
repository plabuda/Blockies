local Block = require("block_oop")

local Slot = Block:new_raw()

function Slot:new( ... ) -- user-facing constructor
    local result = {}
    Slot:init(result, 100, 100, ... ) -- call base initializer
    result = Slot:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.5,0.5,0.5)
    result.is_slot = true
    return result
end

return Slot