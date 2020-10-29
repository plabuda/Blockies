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

local function draw_box( retval, x, y, r, g, b)
    love.graphics.setColor(r * 0.7, g * 0.7, b * 0.7)
    love.graphics.rectangle('line', x + retval.x , y + retval.y , retval.w + retval.m_w, retval.h + retval.m_h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', x + retval.x + retval.m_w / 2, y + retval.y + retval.m_h / 2, retval.w, retval.h)
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

    retval.draw = function ( x, y )
        draw_callback ( retval, x, y )
        local x2 = retval.x + retval.m_w /2 + x
        local y2 = retval.y + retval.m_h /2 + y

        -- iterate over and measure all singular children
        for i=1,#retval.children do
            if retval.children[i].payload then
                retval.children[i].payload.draw(x2, y2)
            end
        end  
        
        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                for k=1,#collection do
                    collection[k].draw(x2, y2)
                end
            end
        end

    end

    return retval
end

local function random_block()
    local r = love.math.random( )
    local g = love.math.random( )
    local b = love.math.random( )
    local w = 20 + love.math.random( ) * 180
    local h = 20 + love.math.random( ) * 80

    local measure_callback = function ( retval )
        retval.w = w
    end

    local draw_callback = function ( retval, x, y )
        draw_box(retval, x, y, r, g, b)
    end

    return box.new( measure_callback, draw_callback )
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

    local draw_callback = function ( retval, x, y )
        draw_box(retval,x, y, 0.6, 0.6, 0.6)
    end

    local result = box.new( measure_callback, draw_callback)
    local collection = new_collection(nil)
    local collection2 = new_collection(nil)
    result.blocks = collection
    result.blocks2 = collection2
    result.collections = {collection, collection2}

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

    local draw_callback = function ( retval, x, y )
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle('line', x + retval.x , y + retval.y , retval.w + retval.m_w, retval.h + retval.m_h)
        love.graphics.setColor(0.35,0.35,0.35)
        love.graphics.rectangle('fill', x + retval.x + retval.m_w / 2, y + retval.y + retval.m_h / 2, retval.w, retval.h)
    end
    
    local result = box.new( measure_callback, draw_callback)
    local collection = new_collection(nil)
    result.blocks = collection
    result.collections = {collection}

    return result
end

local function slot()
    local measure_callback = function (retval)
        retval.w = 2 * MARGIN_DEFAULT
        retval.m_w = -2 * MARGIN_DEFAULT
        retval.h = HEIGHT_DEFAULT + MARGIN_DEFAULT * 1.5
        retval.m_h = -0.5 * MARGIN_DEFAULT
end

    local draw_callback = function ( retval, x, y )
        draw_box(retval, x, y, 1, 1, 1)
    end

    return box.new(measure_callback, draw_callback)
end

local hor = horizontal_block()
hor.blocks.payload = {random_block(), slot(), random_block(), slot(), random_block(), slot(), random_block(), slot(), random_block() }
hor.blocks2.payload = {random_block(), random_block(), random_block(), random_block(), random_block() }


function  love.draw ( ... )
    hor.draw(50,50)
    love.graphics.print( "Hello world -> --> ---> ", 200, 400 )
end

function love.keypressed ()
    hor.measure()
end
