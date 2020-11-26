local Transform = require("transform")
local Platform = require("platform")
local Block = require("block")
local Expression_Block = require("lua.expression_block")
local String_Block = require("lua.string_block")
local Number_Block = require("lua.number_block")
local Workspace = require("workspace")
local Slot = require("slot")
local HBlock = require("blocks/horizontal_block")
local VBlock = require("blocks/vertical_block")

local Parser = require("lua.blockie_parser")

local w = Workspace:new()
local c = w:get_cursor()
local b = Block:new(64,32)
b:measure()

local test_src = [[local x = 'hello' ]]
local src = Parser:parse(test_src) 

for i, v in ipairs(src) do
    w:add_block(v)
end

local x, y, z = 0, 0, 0


if lovr then
    local t = Transform:new(lovr.math.newMat4())

--   local b = String_Block:new("Test")
--    b:measure()
--    w:add_block(b)

 -- b = 10 c,d = 12, 13 local e = 14, 26]]

function lovr.load()
    models = {
        left = lovr.headset.newModel('hand/left', { animated = true }),
        right = lovr.headset.newModel('hand/right', { animated = true })
    }

    w:add_block(b)
    
    wc, hc = c.collider:get_size()
    wb, hb = b:get_size()

end

function lovr.update()
    local hands = lovr.headset.getHands()

    if lovr.headset.isDown(hands[1], 'trigger') then
        local m4 = mat4(lovr.headset.getPose(hands[1])):mul(mat4(0,0,0.2, math.pi, 0, 1, 0))
        b:move(m4)
    end

    if lovr.headset.isDown(hands[2], 'trigger') then
        local m4 = mat4(lovr.headset.getPose(hands[2])):mul(mat4(0,0,0.2, math.pi, 0, 1, 0))
        c:move(m4)
    end

    if b:collide(c.collider) then
        b:set_color(0.8,0.8,0.8)
    else
        b:set_color(0.3,0.3,0.3)
    end
    -- local m_inv = lovr.math.mat4(b.transform:unpack())
    -- m_inv:invert()
    -- local result = m_inv:mul(c.collider.transform:unpack())
    -- x, y, z = result:unpack(false)
    -- x = x * 500
    -- y = y * 500
    -- z = z * 500

    -- local r = (x >= 15 - wc and x <= wb - 15) and 1 or 0.5
    -- local g = (y <= (hc - 15) and y >= -(hb - 15)) and 1 or 0.5
    -- local bl =(z >= -5 and z <= 5) and 1 or 0.5

    --b:set_color(r,g,bl)
    

    
end


function lovr.draw()
    lovr.graphics.setColor(1,1,1)
    for hand, model in pairs(models) do
        if lovr.headset.isTracked(hand) then
            local handPose = mat4(lovr.headset.getPose(hand))
            local success = lovr.headset.animate(hand, model)
            local turnPose = mat4(0,0,0.15, math.pi, 0, 1, 0) -- looks good enough
            model:draw(handPose:mul(turnPose))
        end
    end
    
    w:draw()

    if false then
        local text = "This is a test ->\n->\n->"
        local w, h = Platform:get_text_size( text )

        Platform.draw_box( t, w, h, 0.3, 0.3, 0.3)
        local t_right = t:offset(w,0)
        Platform.draw_box( t_right, w, h, 1,0.3,0.3)
        local t_down = t:offset(0,h)    
        Platform.draw_box( t_down, w, h, 0.3,0.1,0.3)

        local tt = Transform:new(lovr.math.mat4(t:unpack()):translate(0,0,0.03))
        Platform.draw_text(tt, text , 0.6,0.6,0)
    end

    local xx, yy, zz = t:unpack():unpack(false)
    lovr.graphics.sphere(xx, yy, zz, .01 ) 
    
    lovr.graphics.print('X: ' .. x .. '\nY: ' .. y .. '\nZ: ' .. z , 0, 1.7, -3, .5)
end

else

function love.draw()
    w:draw()
end

function love.mousemoved( x, y, dx, dy, istouch )
    c:move(x - 8, y - 8)
end

function love.mousepressed()
    c:pick()
end

function love.mousereleased()
    c:drop()
end

end