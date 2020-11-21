local Block = require("../block")
local Platform = require("../platform")
local Layout_Utils = require("layout_utils")

local Set_Block = Block:new_raw()

function Set_Block:new( lhs, rhs, is_local, ...)
    local result = { lhs = lhs or {}, rhs = rhs or {}, is_local = is_local }
    Set_Block:init(result, 200, 50, ... ) -- call base initializer
    result = Set_Block:new_raw(result)  -- attach methods to __index

    result.texts = { {text = '=', x = 0, y = 0}, {text = ',', x = 0, y = 0}   }

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.6,0.4,0.3)
    result.collections = {
        {payload = result.lhs },
        {payload = result.rhs}
    }
    result:measure()
    return result
end

function Set_Block:measure_callback()


    local objects = {self.texts[1]}
    for _, v in ipairs(self.collections[1].payload) do table.insert( objects, v ) end
    table.insert( objects, self.texts[2])
    for _, v in ipairs(self.collections[2].payload) do table.insert( objects, v ) end

    local w, h = Layout_Utils.horizontal_center( 2,2, objects, 32 )

    self.w = w + 4
    self.h = h + 4
end

return Set_Block