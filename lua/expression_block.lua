local Block = require("../block")
local Platform = require("../platform")
local Layout_Utils = require("layout_utils")

local Expression_Block = Block:new_raw()

function Expression_Block:new( items, is_paren, ...)
    local result = { items = (items or {}) }
    Expression_Block:init(result, 200, 50, ... ) -- call base initializer
    result = Expression_Block:new_raw(result)  -- attach methods to __index

    if is_paren then
        result.texts = { {text = '(', x = 0, y = 0}, {text = ')', x = 0, y = 0} }
    else
        result.texts = {}
    end

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.4,0.4,0.4)
    result.collections = {
        {payload = result.items }
    }
    result:measure()
    return result
end

function Expression_Block:measure_callback()

    local objects = {}
    if is_paren then
        table.insert( objects, self.texts[1] )
    end

    for i = 1, #self.items  do
        table.insert( objects, self.items[i])
    end

    if is_paren then
        table.insert( objects, self.texts[2] )
    end   

    local w, h = 32, 32

    if #objects > 0 then
        w, h = Layout_Utils.horizontal_center( 3,3, objects, 32 )
    end

    self.w = w + 6
    self.h = h + 6
end

return Expression_Block