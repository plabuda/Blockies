local Workspace = require("workspace_oop")
local Block = require("block_oop")
local w = Workspace:new()
local c = w:get_cursor()
local b = Block:new(64,64,64,64)
b:set_color(0.6,0.5,0.3)
w:add_block(Block:new(32,32,256,96))
w:add_block(b)

-- unit test for children / payload iterator
b.children = {
    { payload = nil},
    { payload = 'a'},    
    { payload = nil},    
    { payload = 'b'},    
    { payload = 'c'},    
    { payload = nil},    
    { payload = nil},
    { payload = 'd'},
    { payload = nil}
}

-- unit test for collections
b.collections = {
    { payload = nil},
    { payload = { 'a', 'b', 'c', 'e' }},
    { payload = nil},
    { payload = {'zz','hhh','kkkk'}},
    { payload = nil},
    { payload = nil},
    { payload = nil}
}

local text = ''

for i in b:iterator_children() do
    text = text .. ' ' .. i
end

local text2 = ''

for i in b:iterator_collections() do
    for _,j in ipairs(i) do
        text2 = text2 .. ' ' .. j
    end
end

function love.draw()

    love.graphics.print(text, 0,0)
    love.graphics.print(text2, 0,32)
    w:draw()

end

function love.mousemoved( x, y, dx, dy, istouch )
    c:move(x - 8, y - 8)
end