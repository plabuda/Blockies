local boxFactory = {}

local function box_collide( box1,  box2 )
    return box1.x < box2.x + box2.width and
    box1.x + box1.width > box2.x and
    box1.y < box2.y + box2.height and
    box1.y + box1.height > box2.y
end

function boxFactory.new( x, y, w, h)
    local result = {x = x, y = y, w = w, h = h}
    result.collide = function ( box_other ) return box_collide( result, box_other ) end
    return result
end

return boxFactory