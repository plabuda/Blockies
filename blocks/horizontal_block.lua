local Block = require("../block")
local Platform = require("../platform")

local Horizontal_Block = Block:new_raw() -- Horizontal Block prototype inherits methods from Block prototype

function Horizontal_Block:new( text, ... ) -- user-facing constructor
    local result = { expressions = {}, text = text }
    Horizontal_Block:init(result, 100, 100, ... ) -- call base initializer
    result = Horizontal_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.3,0.3,0.3)
    result.collections = { {payload = result.expressions } }
    return result
end

function Horizontal_Block:draw_callback()
    Platform.draw_block(self)
    Platform.draw_text( self.transform:offset(self.m_h, self.m_w), self.text )
end

function Horizontal_Block:measure_callback()
    
    local w, h = Platform:get_text_size( self.text )

    local offset_x = self.m_w + w
    local offset_y = 0
    
    local min_height = h + self.m_h /2

    for _, child in ipairs(self.expressions) do
        child:set_offset(offset_x, offset_y)
        local w, h = child:get_size() 
        offset_x = offset_x + w
        min_height = math.max(min_height, h)
    end

    self.w = math.max(offset_x + self.m_w /2, 32 + self.m_w)
    self.h = min_height
end

return Horizontal_Block