local Platform = { font = love.graphics.newFont("FiraMono-Medium.ttf", 16) }
love.graphics.setFont(Platform.font)

function Platform.draw_block( block )

    local r = block.r or 1
    local g = block.g or 1
    local b = block.b or 1

    local transform = block.transform
    local w = block.w
    local h = block.h

    --Platform.draw_box( transform, w + block.m_w, h + block.m_h, 0.7 * r, 0.7 * g, 0.7 * b, 'line' )

    transform = transform:offset(block.m_w /2, block.m_h/2)
    Platform.draw_box( transform, w, h)

    transform = transform:offset(1,1)
    Platform.draw_box( transform, w - 2, h - 2, 0,0,0)

    transform = transform:offset(1,1)
    Platform.draw_box( transform, w - 4, h - 4, r,g,b)
end

function Platform.draw_box( transform, w, h, r, g, b, fill )
    r = r or 1
    g = g or 1
    b = b or 1

    fill = fill or 'fill'
    love.graphics.setColor(r, g , b)
    love.graphics.rectangle(fill, transform.x, transform.y, w, h)
end

function Platform:get_text_size( text )
    local width, text = self.font:getWrap( text, math.huge)
    return width, self.font:getHeight() * #text
end

function Platform.draw_text( transform, text, r, g, b)    
    love.graphics.setColor(r or 0, g or 0 , b or 0)
    love.graphics.print( text, transform.x, transform.y)
end

return Platform