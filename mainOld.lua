-- blockieFactory = require("blockie")
-- local hl = require("horizontalList")

-- local x = 0
-- local y = 0


-- local b = blockieFactory.new(0.2,0.6,0.2)
-- local c = blockieFactory.new(0.2,0.2,0.6)
-- b.place(200,200)
-- local rootBlockies = {b, c}

-- b.place( 50, 50)
-- b.measure()

-- current = nil
-- offset_x = 0
-- offset_y = 0

-- local lll = hl.new(10,10,10)


-- function love.draw( ... )

--     lll.update()
--     lll.measure()
--     lll.draw()

--     -- for i, v in ipairs(rootBlockies) do
--     --     v.draw()
--     -- end
--     -- if current ~= nil then
--     --     current.draw()
--     -- end
--     -- love.graphics.circle('fill', x, y, 4)
-- end


-- function love.mousemoved(mx,my)
--     x = mx
--     y = my


--     if current ~= nil then
--         current.place( mx + offset_x, my + offset_y)
--     end
-- end

-- function love.mousepressed(mx, my)    
--     if current == nil then
--         x = mx
--         y = my

--         for i = #rootBlockies, 1, -1 do
--             local v = rootBlockies[i]
--             if x >= v.x and x <= v.x + v.width
--             and y >= v.y and y <= v.y + v.height then
--                 current = v.pick(mx, my)
--                 if current == v then
--                     table.remove( rootBlockies, i)
--                 end
--                 offset_x = current.x - mx
--                 offset_y = current.y - my
--                 return nil
--             end
--         end
--     end
-- end

-- function love.mousereleased()
--     local res = false
--     if current ~= nil then
--         for i = #rootBlockies, 1, -1 do
--             local v = rootBlockies[i]
--             if x >= v.x and x <= v.x + v.width
--             and y >= v.y and y <= v.y + v.height then
--                 res = v.drop(current, mx, my)
--                 break                
--             end
--         end
--         if not res then 
--             table.insert( rootBlockies, current )
--         end
--     current = nil
--     end
-- end


-- function test (   --funcOpen  
--     param, --func param
--     param2, -- func param
--     param3 ) -- close param
-- z -- value
-- = -- assign
-- 2 -- numeral
-- + -- add
-- 3 -- numeral
-- return -- ret 
-- z -- value
-- +   -- addition
-- 150 -- numeral

-- end -- func end