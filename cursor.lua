local Block = require("block")

local Cursor = {}


function Cursor:new( workspace )
        
    local result = -- actual init
    {
       collider = Block:new(8,8,0,0),
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

    local collider = self.collider
    if not (self.collided_slot and self.collided_slot:collide(collider)) then
        -- not colliding with previous slot, or no previous slot at all

        if self.collided_slot then            
            -- todo actual notify acquired here
            self.collided_slot:set_color(0.5,0.5,0.5)
            self.collided_slot:clear_target()
            self.collided_slot = nil
        end

        for _, block in ipairs(self.workspace.blocks) do
            self.collided_slot = block:find_slot(collider)
            if self.collided_slot and self.held_block then
                -- todo actual notify released here
                self.collided_slot:set_color(0.7,0.7,0.7)
                self.collided_slot:set_target(self.held_block)
                return
            end
        end
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
        self.collided_slot = nil
        self.held_block.transform:align_with( self.collider.transform )
        local offset = self.collider.transform:offset_to(self.held_block.transform) -- transform needs to be able to calculate offset between two
        self.held_block:set_offset(offset.x, offset.y)
        self.held_block:move(self.collider.transform:unpack())
        self.workspace:add_slots(self.held_block.type)
    end
end

function Cursor:drop()
    if self.held_block then
        local type = self.held_block.type
        if self.collided_slot and self.collided_slot.drop_callback then
            self.collided_slot.drop_callback(self.held_block)
            self.held_block:set_offset(0,0)
            self.workspace:clear_slots( self.held_block.type )
            self.held_block = nil
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

        self.workspace:clear_slots( type )
    end
end

return Cursor