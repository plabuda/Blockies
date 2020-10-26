MARGIN_DEFAULT = 10
WIDTH_DEFAULT = 32
HEIGHT_DEFAULT = 32


box = {}


box.new = function( measure_callback, draw_callback )
    local retval =
    {
        w = WIDTH_DEFAULT,
        h = HEIGHT_DEFAULT,
        m_w = MARGIN_DEFAULT,
        m_h = MARGIN_DEFAULT,
        x = 0,
        y = 0,
        child = nil
    }

    retval.getSize = function ()        
        return retval.w + retval.m_w, retval.h + retval.m_h
    end

    retval.measure = function () 
        if ( retval.child ) then
            retval.child.measure()
        end
        measure_callback ( retval )
    end

    retval.draw = function ( x, y )
        draw_callback ( retval, x, y )
        if ( retval.child ) then
            retval.child.draw( retval.x + retval.m_w /2 + x , retval.y + retval.m_h /2 + y)
        end
    end

    return retval
end

local function red_block()
    local measure_callback = function ( retval )
        local w, h = retval.child.getSize()
        retval.x = 200
        retval.h = retval.child.y + h       
        retval.y = 50
        retval.w = retval.child.x + w
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
red.child = yell


function  love.draw ( ... )
    red.draw(50, 50)
end

function love.keypressed ()
    red.measure()
end
