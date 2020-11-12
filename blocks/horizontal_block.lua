local Block = require("../block")
local Platform = require("../platform")

local Horizontal_Block = Block:new_raw() -- Horizontal Block prototype inherits methods from Block prototype

function Horizontal_Block:new( ... ) -- user-facing constructor
    local result = { expressions = {} }
    Horizontal_Block:init(result, 100, 100, ... ) -- call base initializer
    result = Horizontal_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.3,0.3,0.3)
    result.collections = { {payload = result.expressions } }
    return result
end

function Horizontal_Block:draw_callback()
    Platform.draw_block(self)
    Platform.print(self.transform.x)
end

function Horizontal_Block:measure_callback()
    local offset_x = self.m_w / 2
    local offset_y = self.m_h / 2
    local min_height = 32

    for _, child in ipairs(self.expressions) do
        child:set_offset(offset_x, offset_y)
        local w, h = child:get_size() 
        offset_x = offset_x + w
        min_height = math.max(min_height, h)
    end

    self.w = math.max(offset_x + self.m_w /2, 32 + self.m_w)
    self.h = min_height + self.m_h
end

return Horizontal_Block