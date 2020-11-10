local Workspace = require("workspace_oop")
local Block = require("block_oop")
local w = Workspace:new()
local c = w:get_cursor()

w:add_block(Block:new(32,32,256,96))

local r = Block:new(64,64,64,64)
r:set_color(0.6,0.2,0.2)

local g = Block:new(64,64,64,264)
g:set_color(0.2,0.6,0.2)
g.offset = {x = 32, y = 32}

local b = Block:new(64,64,64,164)
b:set_color(0.2,0.2,0.6)
b.offset = {x = -32, y = 32}

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