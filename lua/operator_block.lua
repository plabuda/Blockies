local Block = require("../block")
local Platform = require("../platform")

local Operator_Block = Block:new_raw()

function Operator_Block:new( opname, ...)
    local result = {}
    Operator_Block:init(result, 20, 20, ... ) -- call base initializer
    result = Operator_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance

    -- parse opname to symbols here

    result:set_color(0.8,0.6,0.8)
    result.texts = { {text = opname , x = 2, y = 2 }}
    return result
end

function Operator_Block:measure_callback()
    local w, h = Platform:get_text_size(self.texts[1].text)
    self.w = w + 4
    self.h = h + 4
end

return Operator_Block