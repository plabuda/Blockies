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

    local num = math.max(#self.lhs - 1, 0) + math.max(#self.rhs - 1, 0) + 1
    if self.is_local then
        num = num + 1
    end
    --todo filter out slots and don't put commas there
    while #self.texts ~= num do
        if #self.texts > num then
            table.remove( self.texts)
        else
            table.insert( self.texts, {text = '', x = 0, y = 0} )
        end
    end

    local objects = {}
    local counter = 1

    if self.is_local then
        self.texts[counter].text = 'local'
        table.insert( objects, self.texts[counter] )
        counter = counter + 1
    end

    if #self.lhs > 0 then
        for i = 1, #self.lhs - 1 do
            table.insert( objects, self.lhs[i])
            table.insert( objects, self.texts[counter])
            self.texts[counter].text = ','
            counter = counter + 1
        end
        table.insert( objects, self.lhs[#self.lhs] )
    end

    table.insert( objects, self.texts[counter])
    self.texts[counter].text = '='
    counter = counter + 1

    if #self.rhs > 0 then
        for i = 1, #self.rhs - 1 do
            table.insert( objects, self.rhs[i])
            table.insert( objects, self.texts[counter])
            self.texts[counter].text = ','
            counter = counter + 1
        end
        table.insert( objects, self.rhs[#self.rhs] )
    end

    local w, h = Layout_Utils.horizontal_center( 3,3, objects, 32 )

    self.w = w + 6
    self.h = h + 6
end

return Set_Block