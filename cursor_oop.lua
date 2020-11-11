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
                -- if picked object from workspace, pluck it from the workspace list
                table.remove( self.workspace.blocks, i )
            else
                -- if picked a child object, trigger parent to measure itself
                candidate:measure() 
            end
            break
        end
    end

    if self.held_block then
        self.held_block.transform:align_with( self.collider.transform )
        local offset = self.collider.transform:offset_to(self.held_block.transform) -- transform needs to be able to calculate offset between two
        self.held_block:set_offset(offset.x, offset.y)
        self.held_block:move(self.collider.transform:unpack())
    end
end

function Cursor:drop()
    if self.held_block then
        if self.collided_slot then
        else
            self.workspace:add_block(self.held_block)
            
            -- calculate block's transform in "absolute" space, with offsets 0,0
            local transform = self.collider.transform:offset(self.held_block.offset.x, self.held_block.offset.y)
            -- clear offsets and move to the calculated position
            self.held_block:set_offset(0,0)
            self.held_block:move(transform:unpack())

            -- stop holding object
            self.held_block = nil
        end
    end
end

return Cursor