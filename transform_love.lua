local Transform = {}

function Transform:new( ... )
    
    local arg = {...}

    local result = -- actual init
    {
       x = arg[1],
       y = arg[2]
    }

    setmetatable(result, {__index = self } )
    return result
end

function Transform:move(x, y) -- this signature is specific to the backend 
    self.x = x
    self.y = y
end

return Transform