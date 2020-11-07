MARGIN_DEFAULT = 10
WIDTH_DEFAULT = 32
HEIGHT_DEFAULT = 32

local blockie = require("blockie")
local workspace = require("workspace")

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

local hor = horizontal_block()
hor.blocks.payload = {random_block(), random_block(), random_block(), random_block() }
hor.blocks2.payload = {}

workspace.blocks  = {horizontal_block(), random_block(), random_block(), hor, random_block(), horizontal_block()}
--blocks = {random_block(),random_block(),random_block(),random_block(),random_block(),random_block(),random_block()}

for i=1,#workspace.blocks do
    workspace.blocks[i].measure()
    workspace.blocks[i].move(love.math.random( ) * 250 ,love.math.random( ) * 250)
end

function  love.draw ( ... )
    workspace.draw()
end

function love.mousemoved( x, y, dx, dy, istouch )
   workspace.cursor_move(x,y)
end

function love.mousepressed( x, y, button, istouch, presses )
    workspace.cursor_grab()
end

function love.mousereleased( x, y, button )
    workspace.cursor_release()
end
