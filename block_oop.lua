local Transform = require("transform")
local Platform = require("platform")

local Block = {}

local MARGIN_DEFAULT = 10

function Block:new( w, h, ... ) -- user-facing constructor
    local result = {}
    Block:init(result, w, h, ...)
    return Block:new_raw(result)
end

function Block:init( object, w, h, ... ) -- actual initialization, declares necessary fields
    object.w = w
    object.h = h
    object.m_w = MARGIN_DEFAULT
    object.m_h = MARGIN_DEFAULT
    object.transform = Transform:new(...)
    object.offset = {x = 0, y = 0}

    object.children = {}
    object.collections = {}
end

function Block:new_raw(o) -- constructor for inheritance purposes
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function Block:set_color(r, g, b) -- should a color be block's inherent feature?
    self.r = r
    self.g = g
    self.b = b
end

-- region Iterators

function Block:iterator_payload( collection )
    local i = 1
    local iter = function ()
        while i <= #collection do
            if collection[i] and collection[i].payload then
                local value = collection[i].payload
                i = i + 1
                return value 
            else
                i = i + 1
            end
        end        
        return nil        
    end
    return iter
end

function Block:iterator_collections()
    return self:iterator_payload( self.collections )
end

function Block:iterator_children()
    return self:iterator_payload( self.children )
end

-- endregion

function Block:measure_callback()
    -- nothing here, to be overriden
end

function Block:measure()

    for child in self:iterator_children() do
        child:measure()
    end

    for collection in self:iterator_collections() do
        for _, child in ipairs(collection) do
            child:measure()
        end
    end
    
    self:measure_callback()

end

function Block:draw_callback()
    Platform.draw_block(self)
end

function Block:draw()

    self:draw_callback()

    for child in self:iterator_children() do
        child:draw()
    end

    for collection in self:iterator_collections() do
        for _, child in ipairs(collection) do
            child:draw()
        end
    end

end

function Block:collide( other )
    return self.transform:collide(self.w, self.h, self.m_w, self.m_h, 
                                  other.transform, other.w, other.h, other.m_w, other.m_h)
end

function Block:pick( other )
    if self.is_slot ~= true and self:collide( other ) then
        
        --look for a nested collision in children
        for _, child in ipairs(self.children) do
            if child.payload then
                local candidate = child.payload:pick( other ) 
                if candidate then -- child had a collision
                    if candidate == child.payload then -- a direct descendant - pop it from payload
                        child.payload = nil
                    end
                    return candidate
                end                
            end
        end

        for collection in self:iterator_collections() do
            for i, child in ipairs(collection) do
                local candidate = child:pick( other )
                if candidate then
                    if candidate == child then
                        table.remove( collection, i )
                    end
                    return candidate
                end
            end
        end
        
        return self -- no child block found, return self
    else
        return nil -- did not collide with this block
    end
end



function Block:move(...) -- accepts a full, unpacked transform as a "root"
    self.transform:move(...) -- move the block
    self.transform = self.transform:offset( self.offset.x, self.offset.y )

    local child_transform = self.transform:offset( self.m_w /2, self.m_h /2 )

    for child in self:iterator_children() do
        child:move( child_transform:unpack() )
    end

    for collection in self:iterator_collections() do
        for _, child in ipairs(collection) do
            child:move( child_transform:unpack() )
        end
    end



end


return Block