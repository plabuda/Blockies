local Block = require("../block")
local Platform = require("../platform")

local Id_Block = Block:new_raw()

function Id_Block:new( text, ...)
    local result = {}
    Id_Block:init(result, 20, 20, ... ) -- call base initializer
    result = Id_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.3,0.3,0.8)
    result.texts = { {text = text, x = 2, y = 2 }}
    return result
end

function Id_Block:measure_callback()
    local w, h = Platform:get_text_size(self.texts[1].text)
    self.w = w + 4
    self.h = h + 4
end

return Id_Block