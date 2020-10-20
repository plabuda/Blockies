blockieFactory = require("blockie")

local x = 0
local y = 0

local rootBlockies = {}

table.insert(rootBlockies, blockieFactory.new(0.2,0.6,0.2))
table.insert(rootBlockies, blockieFactory.new(0.2,0.2,0.6))

rootBlockies[2].x = 20
rootBlockies[2].y = 150

current = nil
offset_x = 0
offset_y = 0


function love.draw( ... )

    for i, v in ipairs(rootBlockies) do
        v.draw()
    end
    if current ~= nil then
        current.draw()
    end
    love.graphics.circle('fill', x, y, 4)
end


function love.mousemoved(mx,my)
    x = mx
    y = my

    if current ~= nil then
        current.x = mx + offset_x
        current.y = my + offset_y
    end
end

function love.mousepressed(mx, my)    
    if current == nil then
        x = mx
        y = my

        for i = #rootBlockies, 1, -1 do
            local v = rootBlockies[i]
            if x >= v.x and x <= v.x + v.width
            and y >= v.y and y <= v.y + v.height then
                current = table.remove( rootBlockies, i)
                offset_x = current.x - mx
                offset_y = current.y - my
                return nil
            end
        end
    end
end

function love.mousereleased()
    if current ~= nil then
    table.insert( rootBlockies, current )
    current = nil
    end
end