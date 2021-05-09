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
local b = {}

local test_src2 = [[local x, y, z = 'hello', 'lovr', 'people!' ; x = (y .. 'test') ; z = 10 * 15^2 ; return z, y, x ]]
local test_src = [[function test(y, t, v) local x = y + y; print(t .. v); end]]

local test = "This is a test of a line, and looking for a character in this line"

local src = Parser:parse(test_src) 

function get_text_size( text )
    local width, text = self.font:getWrap( text, math.huge)
    return width, self.font:getHeight() * #text
end

function draw_text( x, y , text, r, g, b)    
    love.graphics.setColor(r or 0, g or 0 , b or 0)
    love.graphics.print( text, x, y)
end

function tree_select(tree, character)
    if tree~= nil then
        print('Testing character ' 
        .. tostring(character) 
        .. ' in range from ' .. tostring(tree.first) 
        .. ' to ' .. tostring(tree.last)
        .. ' with ' .. tostring(#tree.leaves) .. ' child nodes')
        if #tree.leaves > 0 then
            candidate = 1
            while tree.leaves[candidate] ~= nil do
                node = tree.leaves[candidate]
                print('Trying node ' .. tostring(candidate)
                 .. ' from ' .. tostring(node.first)
                 .. ' to ' .. tostring(node.last))                 
            
                if node.first <= character then
                    if node.last >= character then
                        print('Selecting child node ' .. tostring(candidate))
                        return tree_select(node, character)
                    end
                else
                    break
                end
                candidate = candidate + 1
            end
             print('No matching child nodes, returning self ' 
            .. tostring(tree.first) .. ' to ' .. tostring(tree.last))
            return tree
        else
            print('No child nodes, returning self ' 
            .. tostring(tree.first) .. ' to ' .. tostring(tree.last))
            return tree
        end
    else
        return nil
    end
    
end

if lovr then
    local m4 = lovr.math.mat4(lovr.math.vec3(-0.4, 1.5, -1.2))
for i, v in ipairs(src) do
    v:move(m4)
    w:add_block(v)
    m4:translate(0.2,-0.2,0)
end

local x, y, z = 0, 0, 0
local was_pressed = false
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

   -- w:add_block(b)
    
   -- wc, hc = c.collider:get_size()
   -- wb, hb = b:get_size()

end

function lovr.update()
    local hands = lovr.headset.getHands()

    if lovr.headset.isDown(hands[1], 'trigger') then
        local m4 = mat4(lovr.headset.getPose(hands[1])):translate(0,0,-0.2)
     --   b:move(m4)
    end

   -- if lovr.headset.isDown(hands[2], 'trigger') then
        local m4 = mat4(lovr.headset.getPose(hands[2])):translate(0,0,-0.2)
        c:move(m4)

    if lovr.headset.isDown(hands[2], 'trigger') and not was_pressed then
        was_pressed = true
        c:pick()
    elseif not lovr.headset.isDown(hands[2], 'trigger') and was_pressed then
        was_pressed = false
        c:drop()
    end    
end


function lovr.draw()


    lovr.graphics.setColor(1,1,1)
    for hand, model in pairs(models) do
        if lovr.headset.isTracked(hand) then
            local handPose = mat4(lovr.headset.getPose(hand))
            local success = lovr.headset.animate(hand, model)
            model:draw(handPose)
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
  --  lovr.graphics.sphere(xx, yy, zz, .01 ) 
    
   -- lovr.graphics.print('X: ' .. x .. '\nY: ' .. y .. '\nZ: ' .. z , 0, 1.7, -3, .5)
end

else

love.graphics.setBackgroundColor( 0xdc / 255, 0xd0 / 255, 0xb7 / 255)

for i, v in ipairs(src) do
    w:add_block(v)
end

local k = 5
local k_first = 1
local k_last = 1

function find_character(text, offset, first, last )
    first = first or 0
    last = last or text:len() + 1
    print('Finding offset ' .. tostring(offset) .. ' in range ' .. tostring(first) .. ' ' .. tostring(last))

    if last <= first + 1 then
        return last
    else
        local mid = math.floor( (first + last) / 2)
        print('Mid is ' .. tostring(mid) )
        local w = get_character_highlight( text, mid )
        print('Width is ' .. tostring(w) )
        if w < offset then
            return find_character(text, offset, mid, last)
        else
            return find_character(text, offset, first, mid)
        end
    end
end

function get_character_highlight( text, character )
    local sub = string.gsub(string.sub(text, 1, character), ' ', '_')
    local width, height = Platform:get_text_size( sub  )
    return width, height
end

function get_line_highlight( text, first, last )
    local x, h = get_character_highlight(text, first - 1)
    local width, height = get_character_highlight(text, last)
    return x, width - x, height
end

function love.draw()
    local x, w, h = get_line_highlight(test_src, k_first , k_last)
    love.graphics.setColor( 0xc9 / 255, 0xb8 / 255, 0x92 / 255);
    
    love.graphics.rectangle('fill', 32 + x, 32, w, h)
    draw_text(32, 32, test_src, 0x00 / 255, 0x6b / 255, 0x86 / 255);
    love.graphics.print( tostring(dist), 0,0)
    draw_cursor()
end

local xxx = 0

function HSV(h, s, v)
    if s <= 0 then return v,v,v end
    h, s, v = h/256*6, s/255, v/255
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255
end


b_x = 0
b_y = 0
e_x = 0
e_y = 0
clicked = false
dist = 0
threshold = 40

function draw_cursor()
    local index = math.ceil( dist / threshold )
    love.graphics.setLineWidth( 5 )
    local dx = e_x - b_x
    local dy = e_y - b_y

    local r, g, b = HSV(index * 40 % 255, 128, 228)
    love.graphics.setColor(r/255,g/255,b/255)
    love.graphics.line(b_x, b_y, e_x, e_y)

    local dist2 = (index - 1 ) * threshold
    while dist2 > 0 do
        index = index - 1
        r, g, b = HSV(index * 40 % 255, 128, 228)
        love.graphics.setColor(r/255,g/255,b/255)
        love.graphics.line(b_x, b_y, 
        b_x + (dx * dist2) / dist,
        b_y + (dy * dist2 / dist))
        dist2 = dist2 - threshold
    end
end

function love.mousemoved( x, y, dx, dy, istouch )
    if clicked then
        e_x = x
        e_y = y
    end
    dx = e_x - b_x
    dy = e_y - b_y
    dist = math.sqrt( dx * dx + dy * dy )
    xxx = x
    c:move(x - 8, y - 8)

    local r, g, b = HSV(x % 255, 255, 255)
    --love.graphics.setBackgroundColor(r/255,g/255,b/255)

end

function love.mousepressed(x, y )
    clicked = true
    b_x = x
    b_y = y
    e_x = x
    e_y = y
    k = find_character(test, xxx - 32)
    local node = tree_select(src, k)
    if node ~= nil then
        k_first = node.first
        k_last = node.last
    end
    c:pick()
end

function love.mousereleased(x, y)
    clicked = false
    b_x = x
    b_y = y
    e_x = x
    e_y = y
    c:drop()
end

end