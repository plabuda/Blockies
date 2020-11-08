local Cursor = require("cursor_oop")
 
local Workspace = {}


function Workspace:new( platform )
    
    local result = -- actual init
    {
        blocks = {},
        cursor = Cursor:new(),
        platform = platform or require("platform") -- require platform stuff here
    }

    setmetatable(result, {__index = self } )
    return result
end

function Workspace:add_block( block )
    table.insert( self.blocks, block )
end

function Workspace:draw()
    for i = 1, #self.blocks do
        self.platform.draw_block( self.blocks[i] )
    end
        self.platform.draw_block( self.cursor.collider )
end

function Workspace:get_cursor()
    return self.cursor
end

function Workspace:print(object)
    self.platform.print(object)
end

return Workspace