local Block = require("../block")
local Platform = require("../platform")

local Set_Block = Block:new_raw()

function Set_Block:new( lhs, rhs, is_local, ...)
    local result = { lhs = lhs or {}, rhs = rhs or {}, is_local = is_local }
    Set_Block:init(result, 200, 50, ... ) -- call base initializer
    result = Set_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.6,0.4,0.3)
    result.collections = {
        {payload = result.lhs },
        {payload = result.rhs}
    }
    return result
end

return Set_Block