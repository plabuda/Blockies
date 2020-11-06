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

local function vertical_block()
    local measure_callback = function ( retval )
        local offset = 0
        local max_w = 50
        for i=1,#retval.blocks.payload do 
            local block = retval.blocks.payload[i]
            block.x = MARGIN_DEFAULT / 2
            block.y = offset -- + MARGIN_DEFAULT /2
            local w, h = block.getSize()
            max_w = math.max( max_w, w )
            offset = offset + h
        end --named component
            
        retval.w = max_w + MARGIN_DEFAULT  
        retval.h = offset -- + MARGIN_DEFAULT
    end

    local draw_callback = function ( retval )
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle('line', x + retval.x , y + retval.y , retval.w + retval.m_w, retval.h + retval.m_h)
        love.graphics.setColor(0.35,0.35,0.35)
        love.graphics.rectangle('fill', x + retval.x + retval.m_w / 2, y + retval.y + retval.m_h / 2, retval.w, retval.h)
    end
    
    local result = blockie.new( measure_callback, draw_callback)
    local collection = new_collection(nil)
    result.blocks = collection
    result.collections = {collection}
    result.children = {new_child(nil)}

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




local hor = horizontal_block()
hor.blocks.payload = {random_block(), random_block(), random_block(), random_block() }
hor.blocks2.payload = {}

local blocks = {horizontal_block(), random_block(), random_block(), hor, random_block(), horizontal_block()}
--blocks = {random_block(),random_block(),random_block(),random_block(),random_block(),random_block(),random_block()}

local cursor = simple_block(16,16,0.6,0.6,0)
cursor.measure()

local mx = 0
local my = 0

local collided_slot = nil



local held_item = nil -- simple_block(60,60,1,1,1)

function move_cursor()
    -- draw cursor to update hitboxes
    cursor.move(mx - (cursor.w + cursor.m_w) /2, my - (cursor.h + cursor.m_h) /2 )
    if held_item then
        held_item.move(mx - (cursor.w + cursor.m_w) /2, my - (cursor.h + cursor.m_h) /2 )
    end

    local keep_old = collided_slot ~= nil and blockie.collide(cursor, collided_slot)
    if not keep_old then -- look for new collision

        -- notify collided slot about not colliding anymore here
        if collided_slot ~= nil then collided_slot.candidate = nil end

        for i=1, #blocks do
            collided_slot = blocks[i].collide(cursor)
            if collided_slot ~= nil then
                collided_slot.candidate = held_item
                return
                -- notify new slot about coliding here
            end
        end
        
    end   

end

for i=1,#blocks do
    blocks[i].measure()
    blocks[i].move(love.math.random( ) * 250 ,love.math.random( ) * 250)
end


function  love.draw ( ... )

    move_cursor()   
    for i=1,#blocks do
        blocks[i].draw()
    end    
    if held_item then held_item.draw() end
    cursor.draw()


    -- if collided_slot ~= nil then
    --     love.graphics.print( "Boxes overlap -> True " .. tostring(collided_slot.x_a) .. " | " .. tostring(collided_slot.y_a), 200, 400 )
    --     else
    --         love.graphics.print( "Boxes overlap -> False", 200, 400 )
    --     end  

end

local has_slots = true

-- function love.keypressed()
--     if has_slots == true then
--         hor.clear_slots()
--         has_slots = false
--     else
--         hor.add_slots( "none type" )
--         has_slots = true
--     end

--     hor.measure()
--     hor.move(hor.x_a, hor.y_a)
-- end

function love.mousemoved( x, y, dx, dy, istouch )
    mx = x
    my = y
end

function love.mousepressed( x, y, button, istouch, presses )

    if held_item == nil then
        local result = nil

        for i=1,#blocks do
            result = blocks[i].pick(cursor)
            if result ~= nil then                
                if result == blocks[i] then
                    table.remove( blocks, i )
                end
                break
            end
        end

        if result ~= nil then
            held_item = result
            held_item.x = held_item.x_a - cursor.x_a
            held_item.y = held_item.y_a - cursor.y_a

            for j=1,#blocks do
                blocks[j].add_slots( "none type" )
                blocks[j].measure()
                blocks[j].move(blocks[j].x_a, blocks[j].y_a)
            end
        end
    end
end

function love.mousereleased( x, y, button )
    if held_item ~= nil then
        held_item.x = 0
        held_item.y = 0

        if collided_slot then 
            collided_slot.drop_callback(held_item)
        else
            table.insert( blocks, held_item )
        end
        held_item = nil        
    end

    for j=1,#blocks do
        blocks[j].clear_slots()
        blocks[j].measure()
        blocks[j].move(blocks[j].x_a, blocks[j].y_a)
    end


end
