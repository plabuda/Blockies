local Block = require("block_oop")

local Cursor = {}


function Cursor:new( workspace )
        
    local result = -- actual init
    {
       collider = Block:new(16,16,0,0),
       workspace = workspace,
       held_block = nil
    }

    setmetatable(result, {__index = self } )
    return result
end

function Cursor:move( ... )
    self.collider:move(...)
    if self.held_block then
        self.held_block:move(...)
    end
end

function Cursor:draw()
    if self.held_block then
        self.held_block:draw()
    end
    self.collider:draw()
end

function Cursor:pick()

    self.held_block = nil
    for i, candidate in ipairs(self.workspace.blocks) do 
        self.held_block = candidate:pick(self.collider)
        if self.held_block then
            if self.held_block == candidate then
                table.remove( self.workspace.blocks, i )
            end
            break
        end
    end

    if self.held_block then
        self.held_block.transform:align_with( self.collider.transform )
        self.held_block.offset = self.collider.transform:offset_to(self.held_block.transform) -- transform needs to be able to calculate offset between two
        self.held_block:move(self.collider.transform:unpack())
    end
end

function Cursor:drop()
    if self.collided_slot then
    else
        self.workspace:add_block(self.held_block)
        self.held_block = nil
    end
end

return Cursor