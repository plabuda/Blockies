local Transform = { scale = 1000}

function Transform:new( ... )
    
    local arg = {...}
    
    local result = -- actual init
    { m4 = lovr.math.newMat4()  }
    if arg[1] then result.m4:set(arg[1]) end

    setmetatable(result, {__index = self } )
    return result
end

function Transform:move(m4) -- this signature is specific to the backend 
    self.m4:set(m4)
end

function Transform:offset( x, y )

    local z = 1
    local scale = self.scale
    local m = lovr.math.mat4(self.m4)
    m:translate(x / scale, -y / scale, z / scale)
    -- this signature is always x, y
    -- x grows to the "right", in the direction of width
    -- y grows "down", in the direction of height 
    

    -- TODO transform:unpack:translate for greater efficiency?

    return Transform:new(m)
end

function Transform:unpack() -- deconstruct to values that could be passed to new
    return self.m4
end

function Transform:collide(w, h, m_w, m_h, other, o_w, o_h, o_m_w, o_m_h)

    error (' not implemented ')
    -- this is arguably not pretty, but it has to be transform's responsibility to define collisions

    -- local b1 = {
    --     left = self.x + m_w / 2,
    --     right = self.x + w + m_w / 2,

    --     top =  self.y + m_h / 2,
    --     bottom = self.y + h + m_h / 2 
    -- }

    -- local b2 = {
    --     left = other.x + o_m_w / 2,
    --     right = other.x + o_w + o_m_w / 2,

    --     top =  other.y + o_m_h / 2,
    --     bottom = other.y + o_h + o_m_h / 2 
    -- }

    -- return b1.left < b2.right and
    -- b1.right > b2.left and
    -- b1.top < b2.bottom and
    -- b1.bottom > b2.top

end

function Transform:offset_to( other )
    error (' not implemented ')
    -- return {x = other.x - self.x, 
    --         y = other.y - self.y}
end

function Transform:align_with( other )
    error (' not implemented ') --self.angle, self.ax, self.ay, self.az = other.angle, other.ax, other.ay, other.az
    -- in 3D cases this would snap to plane, rotate, etc
end

return Transform