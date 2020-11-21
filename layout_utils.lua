local Platform = require("platform")

local Layout_Utils = {}

-- align provided table of objects left to right, so that their centers are on the same height
-- accepts both blocks and strings

function Layout_Utils.horizontal_center( root_x, root_y, objects, min_height )
    
    local sizes = {}
    local width, height = 0, min_height or 0

    -- size gathering pass
    for _, v in ipairs(objects) do
        -- if object has offset struct, it's a block
        -- otherwise a text struct
        local w, h = 0, 0
        if v.offset then
            w, h = v:get_size()     
        else
            w, h = Platform:get_text_size( v.text )
        end
        width = width + w
        height = math.max(h, height)
        table.insert( sizes, {w, h} )   
    end

    local offset_x = root_x

    --placement pass
    for i, v in ipairs(objects) do

        local size = sizes[i]
        local offset_y = root_y + (height - size[2]) / 2

        if v.offset then
            v:set_offset(offset_x, offset_y)
        else
            v.x = offset_x
            v.y = offset_y
        end
        offset_x = offset_x + size[1]
    end

    return width, height
end


return Layout_Utils