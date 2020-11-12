local Workspace = require("workspace_oop")
local Slot = require("slot")
local Block = require("block_oop")
local HBlock = require("blocks/horizontal_block")
local w = Workspace:new()
local c = w:get_cursor()

local hb = HBlock:new(0,0)

table.insert( hb.expressions, Block:new(16,64,10,10) )
table.insert( hb.expressions, Block:new(48,64,10,10) )
table.insert( hb.expressions, Block:new(64,64,10,10) )

hb:measure()
w:add_block(hb)

local r = Block:new(264,264,64,64)
r:set_color(0.6,0.2,0.2)

local g = Block:new(164,164,64,264)
g:set_color(0.2,0.6,0.2)
g.offset = {x = 32, y = 32}

local b = Block:new(64,64,64,164)
b:set_color(0.2,0.2,0.6)
b.offset = {x = 32, y = 32}

r.children = { { payload = g } }
g.children = { { payload = b } }

w:add_block(r)  

r:move( 64, 64 )

function love.draw()

    w:draw()

end

function love.mousemoved( x, y, dx, dy, istouch )
    c:move(x - 8, y - 8)
    if c.collider:collide(g) then
        c.collider:set_color(0.6,0.2,0.2)
    else
        c.collider:set_color(1,1,1)
    end
end

function love.mousepressed()
    c:pick()
end

function love.mousereleased()
    c:drop()
end