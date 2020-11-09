local Transform = require("transform")
local Platform = require("platform")

local Block = {}

local MARGIN_DEFAULT = 10

function Block:new( w, h, ... )
    local result = -- actual init
    {
       w = w,
       h = h,
       m_w = MARGIN_DEFAULT,
       m_h = MARGIN_DEFAULT,
       transform = Transform:new(...),
       offset = {x = 0, y = 0},

       children = {},
       collections = {}
    }

    setmetatable(result, {__index = self } )
    return result
end

function Block:set_color(r, g, b)
    self.r = r
    self.g = g
    self.b = b
end

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

function Block:iterator_collections()
    return self:iterator_payload( self.collections )
end

function Block:iterator_children()
    return self:iterator_payload( self.children )
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