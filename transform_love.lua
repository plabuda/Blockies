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

function Transform:offset( x, y )
    -- this signature is always x, y
    -- x grows to the "right", in the direction of width
    -- y grows "down", in the direction of height 
    return Transform:new(x + self.x, y + self.y)
end

function Transform:unpack() -- deconstruct to values that could be passed to new
    return self.x, self.y
end

return Transform