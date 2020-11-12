local Transform = require("transform")
local Platform = require("platform")
local Slot = nil

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

function Block:add_slots( type, parent )
    if Slot == nil then
        Slot = require("slot")
    end

    for _, child_slot in ipairs(self.children) do
        if child_slot.payload then
            child_slot.payload:add_slots(type, parent or self)            
        else
            child_slot.payload = Slot:new(parent or self, function (other) child_slot.payload = other end )
        end
    end

    for _, collection in ipairs(self.collections) do
        local min_value = nil
        if collection.payload then
            for _, child in ipairs(collection.payload) do
                if not child.is_slot then
                    child:add_slots(type, parent or self)
                    local w, h = child:get_size()
                    if collection.is_vertical == true then
                        min_value = math.max(min_value or 0, w)
                    else
                        min_value = math.max(min_value or 0, h)
                    end
                end
            end

            min_value = min_value or 32

            -- visual type of collection should dictate type of slot here
            for k = 0, #collection.payload do
                local callback = function (other) table.insert( collection.payload, k * 2 + 1, other ) end
                if collection.is_vertical == true then
                    table.insert( collection.payload, 2 * k + 1, Slot:vertical(parent or self, min_value, callback ))
                else                    
                    table.insert( collection.payload, 2 * k + 1, Slot:horizontal(parent or self, min_value, callback ))
                end
            end
        end
    end
    
    self:measure() 

end

function Block:clear_slots( type, skip_measure )
    for _, child_slot in ipairs(self.children) do
        if child_slot.payload then
            if child_slot.payload.is_slot == true then
                child_slot.payload = nil
            else
                child_slot.payload:clear_slots( type, true )
            end
        end
    end

    for collection in self:iterator_collections() do
        local k = 1
        while k <= #collection do
            if collection[k].is_slot then
                table.remove( collection , k)                        
            else
                collection[k]:clear_slots( type, true )
                k = k + 1
            end
        end
    end

    if not skip_measure then
        self:measure()
    end
  
end

function Block:measure()

    self:measure_raw()
    self:move(self.transform:unpack())

end

function Block:get_size()
    return self.w + self.m_w, self.h + self.m_h
end

function Block:measure_raw() -- measure without moving
    for child in self:iterator_children() do
        child:measure_raw()
    end

    for collection in self:iterator_collections() do
        for _, child in ipairs(collection) do
            child:measure_raw()
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

function Block:pick( other, skip_measure )
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

function Block:find_slot( other )
    if self:collide(other) then
        if self.is_slot == true then
            return self
        else
            local candidate = nil

            for child in self:iterator_children() do
                candidate = child:find_slot( other )
                if candidate ~= nil then
                    return candidate
                end
            end
        
            for collection in self:iterator_collections() do
                for _, child in ipairs(collection) do
                    candidate = child:find_slot( other )
                    if candidate ~= nil then
                        return candidate
                    end
                end
            end

        end
    else
        return nil
    end
end

function Block:set_offset(x, y)
    self.offset.x = x
    self.offset.y = y
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