local Transform = { scale = 500}

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

    if x ~= 0 and y ~= 0 then
        local z = 1
        local scale = self.scale
        local m = lovr.math.mat4(self.m4)
        m:translate(x / scale, -y / scale, z / scale)
        return Transform:new(m)
    else
        return Transform:new(self.m4)
    end
end

function Transform:unpack() -- deconstruct to values that could be passed to new
    return self.m4
end

function Transform:collide(w, h, m_w, m_h, other, o_w, o_h, o_m_w, o_m_h)


    local wc = o_w + o_m_w
    local wb = w + m_w

    local hc = o_h + o_m_h
    local hb = h + m_h 

    local m_inv = lovr.math.mat4(self.m4)
    m_inv:invert()
    local result = m_inv:mul(other.m4)
    x, y, z = result:unpack(false)
    x = x * self.scale
    y = y * self.scale
    z = z * self.scale


    local r = (x >= 5 - wc and x <= wb - 5)
    local g = (y <= (hc - 5) and y >= -(hb - 5))
    local bl =(z >= -10 and z <= 10)

    return r and g and bl
    --error (' not implemented ')
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
    local m_inv = lovr.math.mat4(self.m4)
    m_inv:invert()
    local result = m_inv:mul(other.m4)
    x, y = result:unpack(false)
    x = x * self.scale
    y = y * self.scale
    
    return { x = x, y = -y} 
    -- error (' not implemented ')
    -- return {x = other.x - self.x, 
    --         y = other.y - self.y}
end

function Transform:align_with( other )

   -- error (' not implemented ') --self.angle, self.ax, self.ay, self.az = other.angle, other.ax, other.ay, other.az
    -- in 3D cases this would snap to plane, rotate, etc
end

return Transform