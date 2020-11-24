local Block = require("../block")
local Platform = require("../platform")

local Number_Block = Block:new_raw()

function Number_Block:new( number, is_negative, ...)
    if is_negative == true then
        number = -number
    end
    local result = {num = number}
    Number_Block:init(result, 20, 20, ... ) -- call base initializer
    result = Number_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance

    result:set_color(0.6,0.3,0.8)
    result.texts = { {text = tostring(result.num), x = 2, y = 2 }}
    return result
end

function Number_Block:measure_callback()
    local w, h = Platform:get_text_size(self.texts[1].text)
    self.w = w + 4
    self.h = h + 4
end

return Number_Block