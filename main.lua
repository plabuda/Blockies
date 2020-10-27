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
                local collection = retval.collections[j]
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
                local collection = retval.collections[j]
                for k=1,#collection do
                    collection[k].draw(x2, y2)
                end
            end
        end

    end

    return retval
end

local function red_block()
    local measure_callback = function ( retval )
        local child = retval.children[1].payload
        local w, h = child.getSize()
        retval.x = 200
        retval.h = child.y + h       
        retval.y = 50
        retval.w = child.x + w
    end

    local draw_callback = function ( retval, x, y )
        love.graphics.setColor(0.5,0,0)
        love.graphics.rectangle('line', x + retval.x , y + retval.y , retval.w + retval.m_w, retval.h + retval.m_h)
        love.graphics.setColor(0.7,0,0)
        love.graphics.rectangle('fill', x + retval.x + retval.m_w / 2, y + retval.y + retval.m_h / 2, retval.w, retval.h)
    end

    return box.new( measure_callback, draw_callback )
end

local function yellow_block()
    local measure_callback = function ( retval )
        retval.w = 50
        retval.h = 50       
        retval.x = 150
        retval.y = 250
        retval.m_w = retval.m_w * -1
        retval.m_h = retval.m_w
    end

    local draw_callback = function ( retval, x, y )
        love.graphics.setColor(0.5,0.5,0)
        love.graphics.rectangle('line', x + retval.x, y + retval.y, retval.w + retval.m_w, retval.h + retval.m_h)
        love.graphics.setColor(0.7,0.7,0)
        love.graphics.rectangle('fill', x + retval.x + retval.m_w / 2, y + retval.y + retval.m_h / 2, retval.w, retval.h)
    end

    return box.new( measure_callback, draw_callback )
end

local red = red_block()
local yell = yellow_block()

red.children = { new_child(yell) }


function  love.draw ( ... )
    red.draw(50, 50)
end

function love.keypressed ()
    red.measure()
end
