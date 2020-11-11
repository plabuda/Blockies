local Block = require("../block_oop")
local Platform = require("../platform")

local Horizontal_Block = Block:new_raw() -- Horizontal Block prototype inherits methods from Block prototype

function Horizontal_Block:new( ... ) -- user-facing constructor
    local result = {}
    Horizontal_Block:init(result, 100, 100, ... ) -- call base initializer
    result = Horizontal_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.3,0.3,0.3)
    return result
end

function Horizontal_Block:draw_callback()
    Platform.draw_block(self)
    Platform.print(self.transform.x)
end

return Horizontal_Block