local Platform = {}

function Platform.print( object )
    love.graphics.print( tostring(object), 0, 0)
end

function Platform.draw_block( block )

    local r = block.r or 1
    local g = block.g or 1
    local b = block.b or 1

    local x = block.transform.x
    local y = block.transform.y

    love.graphics.setColor(r * 0.7, g * 0.7, b * 0.7)
    love.graphics.rectangle('line', x, y, block.w + block.m_w, block.h + block.m_h) -- outline
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', x + block.m_w/2 , y + block.m_h / 2, block.w, block.h)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', x + block.m_w/2 + 1 , y + block.m_h / 2 + 1, block.w - 2, block.h - 2)

    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', x + block.m_w/2 + 2 , y + block.m_h / 2 + 2, block.w - 4, block.h - 4)

end

return Platform