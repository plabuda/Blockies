
local blockie = require("blockie")

local function simple_block(w,h,r,g,b)
    local measure_callback = function ( retval )
        retval.w = w
        retval.h = h 
    end

    local draw_callback = function ( retval )
        blockie.draw(retval, r, g, b)
    end

    return blockie.new( measure_callback, draw_callback )
end

local workspace = {}
workspace.cursor = simple_block(16,16,0.6,0.6,0)
workspace.cursor.measure()

workspace.mx = 0
workspace.my = 0

workspace.collided_slot = nil
workspace.held_item = nil -- simple_block(60,60,1,1,1)

function workspace.cursor_move(x, y)
    workspace.mx = x
    workspace.my = y
    local cursor = workspace.cursor
    -- draw cursor to update hitboxes
    cursor.move(workspace.mx - (cursor.w + cursor.m_w) /2, workspace.my - (cursor.h + cursor.m_h) /2 )
    if workspace.held_item then
        workspace.held_item.move(workspace.mx - (cursor.w + cursor.m_w) /2, workspace.my - (cursor.h + cursor.m_h) /2 )
    end

    local keep_old = workspace.collided_slot  ~= nil and blockie.collide(cursor, workspace.collided_slot )
    if not keep_old then -- look for new collision

        -- notify collided slot about not colliding anymore here
        if workspace.collided_slot ~= nil then workspace.collided_slot.candidate = nil end

        for i=1, #workspace.blocks do
            workspace.collided_slot = workspace.blocks[i].collide(cursor)
            if workspace.collided_slot ~= nil then
                workspace.collided_slot.candidate = held_item
                return
                -- notify new slot about coliding here
            end
        end
        
    end   

end

function workspace.draw()
    for i=1,#workspace.blocks do
        workspace.blocks[i].draw()
    end    
    if workspace.held_item then workspace.held_item.draw() end
    workspace.cursor.draw()

end

function workspace.cursor_release()
    if workspace.held_item ~= nil then
        workspace.held_item.x = 0
        workspace.held_item.y = 0

        if workspace.collided_slot then 
            workspace.collided_slot.drop_callback(workspace.held_item)
        else
            table.insert( workspace.blocks, workspace.held_item )
        end
        workspace.held_item = nil        
    end

    for j=1,#workspace.blocks do
        workspace.blocks[j].clear_slots()
        workspace.blocks[j].measure()
        workspace.blocks[j].move(workspace.blocks[j].x_a, workspace.blocks[j].y_a)
    end


end

function workspace.cursor_grab()

    if workspace.held_item == nil then
        local result = nil

        for i=1,#workspace.blocks do
            result = workspace.blocks[i].pick(workspace.cursor)
            if result ~= nil then                
                if result == workspace.blocks[i] then
                    table.remove( workspace.blocks, i )
                end
                break
            end
        end

        if result ~= nil then
            workspace.held_item = result
            workspace.held_item.x = workspace.held_item.x_a - workspace.cursor.x_a
            workspace.held_item.y = workspace.held_item.y_a - workspace.cursor.y_a

            for j=1,#workspace.blocks do
                workspace.blocks[j].add_slots( "none type" )
                workspace.blocks[j].measure()
                workspace.blocks[j].move(workspace.blocks[j].x_a, workspace.blocks[j].y_a)
            end
        end
    end
end

return workspace