local Block = require("../block")
local Platform = require("../platform")

local String_Block = Block:new_raw()

function String_Block:new( text, ...)
    local result = {}
    String_Block:init(result, 20, 20, ... ) -- call base initializer
    result = String_Block:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance

    -- unescape the characters

    local parsed = string.gsub(text, '\\', '\\\\')
    parsed = string.gsub(parsed, '\a', '\\a')
    parsed = string.gsub(parsed, '\b', '\\b')
    parsed = string.gsub(parsed, '\f', '\\f')
    parsed = string.gsub(parsed, '\n', '\\n')
    parsed = string.gsub(parsed, '\r', '\\r')
    parsed = string.gsub(parsed, '\t', '\\t')
    parsed = string.gsub(parsed, '\v', '\\v')

    parsed = string.gsub(parsed, '\"', '\\"')
    parsed = string.gsub(parsed, '\'', '\\\'')

    result:set_color(0.8,0.3,0.8)
    result.texts = { {text = '"' .. parsed .. '"', x = 2, y = 2 }}
    return result
end

function String_Block:measure_callback()
    local w, h = Platform:get_text_size(self.texts[1].text)
    self.w = w + 4
    self.h = h + 4
end

return String_Block