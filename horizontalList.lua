local boxFactory = require("box")

local horizontalListFactory = {}

local function update ( list )

    list.slots = {}
    for i = 1,#(list.content) + 1 do
        local result = boxFactory.new(0,0,20,20)
        result.drop = function ( payload ) table.insert( list.content, i, payload) list.update() end
        table.insert( list.slots, result )
    end

end

local function measure ( list )

    
    local h = 64 --calculate this first
    local current = 10

    for i = 1, #(list.slots) do
        local slot = list.slots[i]
        slot.h = h
        slot.w = 10
        slot.x = list.x + current - 5
        slot.y = list.y + 10

        local content = list.content[i]
        if content ~= nil then
            content.x = list.x + current
            content.y = list.y + 10
            content.h = h
            current = current + content.w + 3
        end

    end

    list.w = current + 11
    list.h = h + 20

end

local function draw ( list )
        
    love.graphics.setColor( 0.2,0,0 )
    love.graphics.rectangle('fill', list.x, list.y, list.w, list.h)
    love.graphics.setColor( 0.2,0.2,0 )
    for i = 1, #(list.content) do
        local content = list.content[i]
        love.graphics.rectangle('fill', content.x,content.y, content.w, content.h)
    end
    love.graphics.setColor( 1,1,1, 0.5 )
    for i = 1, #(list.slots) do        
        local slot = list.slots[i]
        love.graphics.rectangle('fill', slot.x,slot.y, slot.w, slot.h)
    end
end





horizontalListFactory.new = function ( type, min_w, min_h )
    local result = boxFactory.new(50,50,50,50) 
    result.content = {} --{boxFactory.new(10,10,150,50) ,boxFactory.new(10,10,425,50) ,boxFactory.new(10,10,30,50) }
    result.slots = {}
    result.update = function () update ( result) end
    result.measure = function () measure ( result ) end
    result.draw = function () draw ( result ) end




    return result
end




return horizontalListFactory