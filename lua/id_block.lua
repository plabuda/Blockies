local Block = require("../block")
local Platform = require("../platform")

local Id_Block = Block:new_raw()

function Id_Block:new( text, ...)
    local result = { text = text }
    Id_Block:init(result, 20, 20, ... ) -- call base initializer
    result = Id_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.3,0.3,0.8)
    return result
end

return Id_Block