MARGIN_DEFAULT = 10
WIDTH_DEFAULT = 32
HEIGHT_DEFAULT = 32

local blockie = require("blockie")

font = love.graphics.newFont( "FiraMono-Medium.ttf", 16)
love.graphics.setFont(font)

local function new_collection ( payload )
    return {payload = payload}
end

local function new_child ( payload )
    return {payload = payload}
end

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

local function random_block()
    local r = love.math.random( )
    local g = love.math.random( )
    local b = love.math.random( )
    local w = 20 + love.math.random( ) * 80
        local h = 20 

    return simple_block(w, h, r, g, b)
end

local function horizontal_block()
    local measure_callback = function ( retval )
        local offset = 0
        local max_h = 50
        for i=1,#retval.blocks.payload do 
            local block = retval.blocks.payload[i]
            block.y = MARGIN_DEFAULT / 2
            block.x = offset -- + MARGIN_DEFAULT /2
            local w, h = block.getSize()
            max_h = math.max( max_h, h )
            offset = offset + w
        end --named component
        
        retval.w = offset -- + MARGIN_DEFAULT

        max_h = max_h + MARGIN_DEFAULT

        offset = 0
        local max_h2 = 50

        for i=1,#retval.blocks2.payload do 
            local block = retval.blocks2.payload[i]
            block.y = max_h + MARGIN_DEFAULT / 2
            block.x = offset -- + MARGIN_DEFAULT /2
            local w, h = block.getSize()
            max_h2 = math.max( max_h2, h )
            offset = offset + w
        end --named component
            
        retval.h = max_h + max_h2 + MARGIN_DEFAULT  
        retval.w = math.max(offset, retval.w)  -- + MARGIN_DEFAULT
    end

    local draw_callback = function ( retval )
        blockie.draw(retval, 0.6, 0.6, 0.6)
    end

    local result = blockie.new( measure_callback, draw_callback)
    local collection = new_collection({})
    local collection2 = new_collection({})
    result.blocks = collection
    result.blocks2 = collection2
    result.collections = {collection, collection2}
   -- result.children = {new_child(nil)}

    return result

end

function slot( drop_callback )
    local measure_callback = function (retval)
        if retval.candidate ~= nil then
            retval.w = retval.candidate.w
           -- retval.m_w = retval.candidate.m_w
            retval.h = retval.candidate.h
            --retval.m_h = retval.candidate.m_h
        else
            retval.w = 2 * MARGIN_DEFAULT
            retval.m_w = 0--//-2 * MARGIN_DEFAULT
            retval.h = HEIGHT_DEFAULT + MARGIN_DEFAULT * 1.5
            retval.m_h = 0-- -0.5 * MARGIN_DEFAULT
        end
    end

    local draw_callback = function ( retval )
        blockie.draw(retval, 1, 1, 1)
    end

    local value = blockie.new(measure_callback, draw_callback)
    value.is_slot = true
    value.drop_callback = drop_callback
    return value
end

local workspace = {}



local hor = horizontal_block()
hor.blocks.payload = {random_block(), random_block(), random_block(), random_block() }
hor.blocks2.payload = {}

workspace.blocks  = {horizontal_block(), random_block(), random_block(), hor, random_block(), horizontal_block()}
--blocks = {random_block(),random_block(),random_block(),random_block(),random_block(),random_block(),random_block()}

workspace.cursor = simple_block(16,16,0.6,0.6,0)
workspace.cursor.measure()

local mx = 0
local my = 0

local collided_slot = nil



local held_item = nil -- simple_block(60,60,1,1,1)

function cursor_move(x, y)
    mx = x
    my = y
    local cursor = workspace.cursor
    -- draw cursor to update hitboxes
    cursor.move(mx - (cursor.w + cursor.m_w) /2, my - (cursor.h + cursor.m_h) /2 )
    if held_item then
        held_item.move(mx - (cursor.w + cursor.m_w) /2, my - (cursor.h + cursor.m_h) /2 )
    end

    local keep_old = collided_slot ~= nil and blockie.collide(cursor, collided_slot)
    if not keep_old then -- look for new collision

        -- notify collided slot about not colliding anymore here
        if collided_slot ~= nil then collided_slot.candidate = nil end

        for i=1, #workspace.blocks do
            collided_slot = workspace.blocks[i].collide(cursor)
            if collided_slot ~= nil then
                collided_slot.candidate = held_item
                return
                -- notify new slot about coliding here
            end
        end
        
    end   

end

-- one time setup
for i=1,#workspace.blocks do
    workspace.blocks[i].measure()
    workspace.blocks[i].move(love.math.random( ) * 250 ,love.math.random( ) * 250)
end

local function workspace_draw()
    for i=1,#workspace.blocks do
        workspace.blocks[i].draw()
    end    
    if held_item then held_item.draw() end
    workspace.cursor.draw()

end

function  love.draw ( ... )
    workspace_draw()
end


function love.mousemoved( x, y, dx, dy, istouch )
    cursor_move(x,y)
end

function love.mousepressed( x, y, button, istouch, presses )

    if held_item == nil then
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
            held_item = result
            held_item.x = held_item.x_a - workspace.cursor.x_a
            held_item.y = held_item.y_a - workspace.cursor.y_a

            for j=1,#workspace.blocks do
                workspace.blocks[j].add_slots( "none type" )
                workspace.blocks[j].measure()
                workspace.blocks[j].move(workspace.blocks[j].x_a, workspace.blocks[j].y_a)
            end
        end
    end
end

local function cursor_release()
    if held_item ~= nil then
        held_item.x = 0
        held_item.y = 0

        if collided_slot then 
            collided_slot.drop_callback(held_item)
        else
            table.insert( workspace.blocks, held_item )
        end
        held_item = nil        
    end

    for j=1,#workspace.blocks do
        workspace.blocks[j].clear_slots()
        workspace.blocks[j].measure()
        workspace.blocks[j].move(workspace.blocks[j].x_a, workspace.blocks[j].y_a)
    end


end
function love.mousereleased( x, y, button )
    cursor_release()
end
