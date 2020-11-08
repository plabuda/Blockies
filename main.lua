local Workspace = require("workspace_oop")
local Block = require("block_oop")
local w = Workspace:new()
local c = w:get_cursor()
local b = Block:new(64,64,64,64)
b:set_color(0.6,0.5,0.3)
w:add_block(Block:new(32,32,256,96))
w:add_block(b)

function love.draw()

    w:draw()

end

function love.mousemoved( x, y, dx, dy, istouch )
    c:move(x - 8, y - 8)
end