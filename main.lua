local Workspace = require("workspace_oop")
local Block = require("block_oop")
local w = Workspace:new()
local c = w:get_cursor()

w:add_block(Block:new(64,64,64,64))
w:add_block(Block:new(32,32,256,96))

function love.draw()

    w:print(w.blocks)
    w:draw()

end

function love.mousemoved( x, y, dx, dy, istouch )
    c:move(x, y)
end