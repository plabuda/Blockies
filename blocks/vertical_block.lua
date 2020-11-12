local Block = require("../block")
local Platform = require("../platform")

local Vertical_Block = Block:new_raw() -- Vertical Block prototype inherits methods from Block prototype

function Vertical_Block:new( text, ... ) -- user-facing constructor
    local result = { expressions = {}, text = text }
    Vertical_Block:init(result, 100, 100, ... ) -- call base initializer
    result = Vertical_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.3,0.3,0.3)
    result.collections = { {payload = result.expressions, is_vertical = true } }
    return result
end

function Vertical_Block:draw_callback()
    Platform.draw_block(self)
    Platform.draw_text( self.transform:offset(self.m_h, self.m_w), self.text )
end

function Vertical_Block:measure_callback()
    
    local w, h = Platform:get_text_size( self.text )

    local offset_x = 0
    local offset_y = self.m_h + h
    
    local min_width = w + self.m_w /2

    for _, child in ipairs(self.expressions) do
        child:set_offset(offset_x, offset_y)
        local w, h = child:get_size() 
        offset_y = offset_y + h
        min_width = math.max(min_width, w)
    end

    self.h = math.max(offset_y + self.m_h /2, 32 + self.m_h)
    self.w = min_width
end

return Vertical_Block