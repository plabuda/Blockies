local Cursor = require("cursor_oop")
 
local Workspace = {}


function Workspace:new( platform )
    
    local result = -- actual init
    {
        blocks = {},
        platform = platform or require("platform") -- require platform stuff here
    }

    result.cursor = Cursor:new(result),

    setmetatable(result, {__index = self } )
    return result
end

function Workspace:add_block( block )
    table.insert( self.blocks, block )
end

function Workspace:draw()
    for i = 1, #self.blocks do
        self.blocks[i]:draw()
    end
        self.cursor:draw()
end

function Workspace:add_slots( type )
    for i = 1, #self.blocks do
        self.blocks[i]:add_slots( type )
    end
end

function Workspace:clear_slots( type )
    for i = 1, #self.blocks do
        self.blocks[i]:clear_slots( type )
    end
end

function Workspace:get_cursor()
    return self.cursor
end

function Workspace:print(object)
    self.platform.print(object)
end

return Workspace