local Transform = require("transform")

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

function Block:iterator( collection )
    local i = 1
    local iter = function ()
        while i < #collection do
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

function Block:iterator_children()
    return self.iterator( self.children )
end


function Block:move(...)
    self.transform:move(...)
end


return Block