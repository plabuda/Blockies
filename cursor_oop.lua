local Block = require("block_oop")

local Cursor = {}


function Cursor:new()
        
    local result = -- actual init
    {
       collider = Block:new(16,16,0,0)
    }

    setmetatable(result, {__index = self } )
    return result
end

function Cursor:move( ... )
    self.collider:move(...)
end


return Cursor