local Platform = {}

function Platform.print( object )
    love.graphics.print( tostring(object), 0, 0)
end

function Platform.draw_block( block )
    --love.graphics.print( tostring(block.transform.x), 0, 32)
    --love.graphics.print( tostring(block.transform.y), 0, 64)
    love.graphics.rectangle('fill', block.transform.x, block.transform.y, block.w, block.h)

end

return Platform