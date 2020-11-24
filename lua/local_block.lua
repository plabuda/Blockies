local Block = require("../block")
local Platform = require("../platform")
local Layout_Utils = require("layout_utils")

local Local_Block = Block:new_raw()

function Local_Block:new( items, ...)
    local result = { items = (items or {}) }
    Local_Block:init(result, 200, 50, ... ) -- call base initializer
    result = Local_Block:new_raw(result)  -- attach methods to __index

    result.texts = { {text = 'local', x = 0, y = 0} }

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.4,0.6,0.3)
    result.collections = {
        {payload = result.items}
    }
    result:measure()
    return result
end

function Local_Block:measure_callback()

    local num = math.max(#self.items - 1, 0) + 1

    --todo filter out slots and don't put commas there
    while #self.texts ~= num do
        if #self.texts > num then
            table.remove( self.texts)
        else
            table.insert( self.texts, {text = '', x = 0, y = 0} )
        end
    end

    local objects = { self.texts[1] }
    local counter = 2

    if #self.items > 0 then
        for i = 1, #self.items - 1 do
            table.insert( objects, self.items[i])
            table.insert( objects, self.texts[counter])
            self.texts[counter].text = ','
            counter = counter + 1
        end
        table.insert( objects, self.items[#self.items] )
    end

    local w, h = Layout_Utils.horizontal_center( 3,3, objects, 32 )

    self.w = w + 6
    self.h = h + 6
end

return Local_Block