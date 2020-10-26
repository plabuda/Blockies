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
    }

    retval.measure = function () 
        measure_callback ( retval )
        return retval.w + retval.m_w, retval.h + retval.m_h
    end

    retval.draw = function ()
        draw_callback ( retval )
    end

    return retval
end

local function red_block()
    local measure_callback = function ( retval )
        retval.w = 200
        retval.h = 50       
        retval.x = 50
        retval.y = 150
    end

    local draw_callback = function ( retval )
        love.graphics.setColor(0.5,0,0)
        love.graphics.rectangle('line', retval.x, retval.y, retval.w + retval.m_w, retval.h + retval.m_h)
        love.graphics.setColor(0.7,0,0)
        love.graphics.rectangle('fill', retval.x + retval.m_w / 2, retval.y + retval.m_h / 2, retval.w, retval.h)

    end

    return box.new( measure_callback, draw_callback )
end

local red = red_block()


function  love.draw ( ... )
    red.draw()
end

function love.keypressed ()
    red.measure()
end