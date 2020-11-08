local Transform = require("transform")

local Block = {}

function Block:new( w, h, ... )
    local result = -- actual init
    {
       w = w,
       h = h,
       transform = Transform:new(...)
    }

    setmetatable(result, {__index = self } )
    return result
end

function Block:move(...)
    self.transform:move(...)
end


return Block