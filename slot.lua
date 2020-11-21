local Block = require("block")

local Slot = Block:new_raw()

local def_size = 16


function Slot:new( parent, drop_callback ) -- user-facing constructor
    local result = {
        drop_callback = drop_callback,
        parent = parent }
    Slot:init(result, def_size, def_size) -- call base initializer
    result = Slot:new_raw(result)  -- attach methods to __index

    -- class-specific init can be done here, as long as there isn't multiple inheritance
    result:set_color(0.5,0.5,0.5)
    result.is_slot = true
    return result
end

-- function Slot:draw_callback()
-- end

function Slot:vertical(parent, width, drop_callback)
    local result = Slot:new( parent, drop_callback)
    result.is_vertical = true
    result.m_h = -def_size
    result.width = width - result.m_w
    result.w = result.width
    return result
end

function Slot:horizontal( parent, height, drop_callback )
    local result = Slot:new( parent, drop_callback)
    result.m_w = -def_size
    result.height = height - result.m_h
    result.h = result.height
    return result
end

function Slot:set_target( target )
    if target then
        local w, h = target:get_size()

        if self.is_vertical == true then
            self.h = h - self.m_h
        else
            self.w = w - self.m_w
        end
    end

    self.parent:measure()
end

function Slot:clear_target()
    if self.is_vertical == true then
        self.h = def_size
    else
        self.w = def_size
    end
    self.parent:measure()
end

return Slot