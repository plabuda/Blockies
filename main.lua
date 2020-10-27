MARGIN_DEFAULT = 10
WIDTH_DEFAULT = 32
HEIGHT_DEFAULT = 32


box = {}

local function new_collection ( payload )
    return {payload = payload}
end

local function new_child ( payload )
    return {payload = payload}
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
    local h = 20 + love.math.random( ) * 10

    local measure_callback = function ( retval )
        retval.h = h
        retval.w = w
    end

    local draw_callback = function ( retval, x, y )
        love.graphics.setColor(r * 0.5, g * 0.5, b * 0.5)
        love.graphics.rectangle('line', x + retval.x , y + retval.y , retval.w + retval.m_w, retval.h + retval.m_h)
        love.graphics.setColor(r * 0.7, g * 0.7, b * 0.7)
        love.graphics.rectangle('fill', x + retval.x + retval.m_w / 2, y + retval.y + retval.m_h / 2, retval.w, retval.h)
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
            
        retval.h = max_h + MARGIN_DEFAULT  
        retval.w = offset -- + MARGIN_DEFAULT
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

local hor = horizontal_block()
hor.blocks.payload = {random_block(), random_block(), random_block(), random_block(), random_block() }


function  love.draw ( ... )
    hor.draw(50,50)
end

function love.keypressed ()
    hor.measure()
end
