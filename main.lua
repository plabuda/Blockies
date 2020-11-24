local Transform = require("transform")
local Platform = require("platform")

if lovr then
    local t = Transform:new(lovr.math.newMat4())
function lovr.load()
    models = {
        left = lovr.headset.newModel('hand/left', { animated = true }),
        right = lovr.headset.newModel('hand/right', { animated = true })
    }


    end

function lovr.update()
    local hands = lovr.headset.getHands()
    local down = lovr.headset.isDown(hands[2], 'grip')

    if down then
        local m4 = mat4(lovr.headset.getPose(hands[2])):mul(mat4(0,0,0.3, math.pi, 0, 1, 0))
        t:move(m4)
    end
end


function lovr.draw()
    for hand, model in pairs(models) do
        if lovr.headset.isTracked(hand) then
            local handPose = mat4(lovr.headset.getPose(hand))
            local success = lovr.headset.animate(hand, model)
            lovr.graphics.print(tostring(success), 0, 1.7, -3, .5)
            local turnPose = mat4(0,0,0.15, math.pi, 0, 1, 0) -- looks good enough
            model:draw(handPose)--handPose:mul(turnPose))
        end
    end

    local text = "This is a test ->\n->\n->"
    local w, h = Platform:get_text_size( text )

    Platform.draw_box( t, w * 0.1, h * 0.1, 0.3,0.3,0.8)
    local tt = Transform:new(lovr.math.mat4(t:unpack()):translate(0,0,0.03))
    Platform.draw_text(tt, text , 0.6,0.6,0)

    local x, y, z = t:unpack():unpack(false)
    lovr.graphics.sphere(x, y, z, .01 ) 
end

-- function lovr.draw()
--     for _, hand in ipairs({ 'left', 'right' }) do
--       for _, joint in ipairs(lovr.headset.getSkeleton(hand) or {}) do
--         lovr.graphics.points(unpack(joint, 1, 3))
--       end
--     end
--   end


else

local Workspace = require("workspace")
local Slot = require("slot")
local Block = require("block")
local HBlock = require("blocks/horizontal_block")
local VBlock = require("blocks/vertical_block")

local Parser = require("lua.blockie_parser")

local w = Workspace:new()
local c = w:get_cursor()
local t = Transform:new(0,0)

local test_src = [[local x = not - 4]] -- b = 10 c,d = 12, 13 local e = 14, 26]]


--[[local k,i,j = {}, 2, 3
function k:test(a, b, c, ...)
    return a
end

local z = k.aaa[10].test(0,0,0,0,0,0,0)]]

local print = require("lua.pprint")

local src = Parser:parse(test_src) 

for i, v in ipairs(src) do
    w:add_block(v)
end
-- ''--print.tostring(ast)
-- for i, v in pairs(ast) do
--     src = src .. tostring(i) .. ' = ' .. tostring(v) .. '\n'
-- end


-- local hb = HBlock:new("Hello \n world", 0,0)
-- local vb = VBlock:new("Hello\nvertical\nworld.", 200, 200)

-- table.insert( hb.expressions, Block:new(16,64,10,10) )
-- table.insert( hb.expressions, Block:new(48,64,10,10) )
-- table.insert( hb.expressions, Block:new(64,64,10,10) )

-- hb:measure()
-- w:add_block(hb)
-- w:add_block(vb)

-- local r = Block:new(264,264,64,64)
-- r:set_color(0.6,0.2,0.2)

-- local g = Block:new(164,164,64,264)
-- g:set_color(0.2,0.6,0.2)
-- g.offset = {x = 32, y = 32}

-- local b = Block:new(64,64,64,164)
-- b:set_color(0.2,0.2,0.6)
-- b.offset = {x = 32, y = 32}

-- r.children = { { payload = g } }
-- g.children = { { payload = b } }

-- w:add_block(r)  

-- r:move( 64, 64 )

function love.draw()

    w:draw()
    --Platform.draw_text(t, src, 1,0,0)

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