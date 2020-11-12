local Block = require("block")

local Slot = Block:new_raw()

function Slot:new( drop_callback ) -- user-facing constructor
    local result = { drop_callback = drop_callback }
    Slot:init(result, 32, 32) -- call base initializer
    result = Slot:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.5,0.5,0.5)
    result.is_slot = true
    return result
end

return Slot