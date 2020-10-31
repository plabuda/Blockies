MARGIN_DEFAULT = 10
WIDTH_DEFAULT = 32
HEIGHT_DEFAULT = 32


box = {}

font = love.graphics.newFont( "FiraMono-Medium.ttf", 16)
love.graphics.setFont(font)

local function new_collection ( payload )
    return {payload = payload}
end

local function new_child ( payload )
    return {payload = payload}
end

local function box_collide( box1,  box2 )
    local b1 = {
        left = box1.x_a + box1.m_w / 2,
        right = box1.x_a + box1.w + box1.m_w / 2,

        top =  box1.y_a + box1.m_h / 2,
        bottom = box1.y_a + box1.h + box1.m_h / 2 
    }

    local b2 = {
        left = box2.x_a + box2.m_w / 2,
        right = box2.x_a + box2.w + box2.m_w / 2,

        top =  box2.y_a + box2.m_h / 2,
        bottom = box2.y_a + box2.h + box2.m_h / 2
    }

    return b1.left < b2.right and
    b1.right > b2.left and
    b1.top < b2.bottom and
    b1.bottom > b2.top
end


local function draw_box( retval, r, g, b)
    love.graphics.setColor(r * 0.7, g * 0.7, b * 0.7)
    love.graphics.rectangle('line', retval.x_a , retval.y_a , retval.w + retval.m_w, retval.h + retval.m_h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', retval.x_a + retval.m_w/2 , retval.y_a + retval.m_h / 2, retval.w, retval.h)
end


box.new = function( measure_callback, draw_callback )
    local retval =
    {
        w = WIDTH_DEFAULT,
        h = HEIGHT_DEFAULT,
        m_w = MARGIN_DEFAULT,
        m_h = MARGIN_DEFAULT,
        x = 0,
        y = 0,
        x_a = 0, -- absolute transform, updated on move()
        y_a = 0,
        collections = {},
        children = {}
    }

    retval.clear_slots = function ()
        for i=1,#retval.children do
            if retval.children[i].payload then
                if retval.children[i].payload.is_slot == true then
                    retval.children[i].payload = nil
                else
                    retval.children[i].payload.clear_slots()
                end
            end
        end

        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                local k = 1
                while k <= #collection do
                    if collection[k].is_slot then
                        table.remove( collection , k)
                    else
                        collection[k].clear_slots()
                        k = k + 1
                    end
                end
            end    
        end
    end

    retval.add_slots = function ( type )
        -- can there even be a nil collection? Maybe for else blocks in if? Still, in that case the block should control it, not slots
        for i=1,#retval.children do
            if retval.children[i].payload then
                    retval.children[i].payload.add_slots(type)              
            else
                retval.children[i].payload = slot() -- replace with a proper slot type

            end
        end

        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                local result = {slot()}
                for k=1,#collection do
                    collection[k].add_slots(type)
                    table.insert( result, collection[k])
                    table.insert( result, slot() )
                end
                retval.collections[j].payload = result
            end    
        end
    end

    retval.collide = function ( other )        
        if box_collide(retval, other) then
            if retval.is_slot == true then
                return retval
            end
            -- it we aren't the slot, iterate over children
            -- iterate over and measure all singular children
            for i=1,#retval.children do
                if retval.children[i].payload then
                    local candidate = retval.children[i].payload.collide( other )
                    if candidate ~= nil then return candidate end
                end
            end

            -- iterate over and measure all collections
            for j=1,#retval.collections do
                if retval.collections[j].payload then
                    local collection = retval.collections[j].payload
                    for k=1,#collection do
                        local candidate = collection[k].collide( other )
                        if candidate ~= nil then return candidate end
                    end
                end
            end
        end
        return nil
    end

    retval.getSize = function ()        
        return retval.w + retval.m_w, retval.h + retval.m_h
    end

    retval.measure = function () 
        
        -- iterate over and measure all singular children
        for i=1,#retval.children do
            if retval.children[i].payload then
                retval.children[i].payload.measure()
            end
        end

        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                for k=1,#collection do
                    collection[k].measure()
                end
            end
        end

        measure_callback ( retval )
    end

    retval.draw = function ()

        draw_callback ( retval )
        
        for i=1,#retval.children do
            if retval.children[i].payload then
                retval.children[i].payload.draw()
            end
        end  
        
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                for k=1,#collection do
                    collection[k].draw()
                end
            end
        end

    end

    retval.move = function ( x, y )
        retval.x_a = x + retval.x -- calculate absolute position 
        retval.y_a = y + retval.y
        
        --draw_callback ( retval, x, y ) -- don't actually draw

        local x2 = retval.x_a + retval.m_w /2
        local y2 = retval.y_a + retval.m_h /2 

        -- iterate over and measure all singular children
        for i=1,#retval.children do
            if retval.children[i].payload then
                retval.children[i].payload.move(x2, y2)
            end
        end  
        
        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                for k=1,#collection do
                    collection[k].move(x2, y2)
                end
            end
        end

    end

    return retval
end

local function simple_block(w,h,r,g,b)
    local measure_callback = function ( retval )
        retval.w = w
        retval.h = h 
    end

    local draw_callback = function ( retval )
        draw_box(retval, r, g, b)
    end

    return box.new( measure_callback, draw_callback )
end

local function random_block()
    local r = love.math.random( )
    local g = love.math.random( )
    local b = love.math.random( )
    local w = 20 + love.math.random( ) * 180
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
        draw_box(retval, 0.6, 0.6, 0.6)
    end

    local result = box.new( measure_callback, draw_callback)
    local collection = new_collection(nil)
    local collection2 = new_collection(nil)
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
    
    local result = box.new( measure_callback, draw_callback)
    local collection = new_collection(nil)
    result.blocks = collection
    result.collections = {collection}
    result.children = {new_child(nil)}

    return result
end

function slot()
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
        draw_box(retval, 1, 1, 1)
    end

    local value = box.new(measure_callback, draw_callback)
    value.is_slot = true
    return value
end

local hor = horizontal_block()
local target = random_block()
hor.blocks.payload = {random_block(), slot(), random_block(), slot(), random_block(), slot(), target, slot(), random_block() }
hor.blocks2.payload = {}

local cursor = simple_block(80,40,0.6,0.6,0)
cursor.measure()

local mx = 0
local my = 0

local collided_slot = nil

function draw_cursor()
    -- draw cursor to update hitboxes
    cursor.move(mx - (cursor.w + cursor.m_w) /2, my - (cursor.h + cursor.m_h) /2 )
    cursor.draw()
    local keep_old = collided_slot ~= nil and box_collide(cursor, collided_slot)
    if not keep_old then -- look for new collision

        -- notify collided slot about not colliding anymore here
        if collided_slot ~= nil then collided_slot.candidate = nil end

        collided_slot = hor.collide(cursor)
        if collided_slot ~= nil then
            collided_slot.candidate = cursor
            -- notify new slot about coliding here
        end
        
    end   

end


function  love.draw ( ... )

    hor.measure()
    hor.move(50,50)

    hor.draw()
    draw_cursor()   


    if collided_slot ~= nil then
        love.graphics.print( "Boxes overlap -> True " .. tostring(collided_slot.x_a) .. " | " .. tostring(collided_slot.y_a), 200, 400 )
        else
            love.graphics.print( "Boxes overlap -> False", 200, 400 )
        end  

end

local has_slots = true

function love.keypressed()
    if has_slots == true then
        hor.clear_slots()
        has_slots = false
    else
        hor.add_slots( "none type" )
        has_slots = true
    end
end

function love.mousemoved( x, y, dx, dy, istouch )
    mx = x
    my = y
end
