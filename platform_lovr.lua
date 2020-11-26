local Platform = { font = lovr.graphics.newFont("FiraMono-Medium.ttf", 16), scale = 1000 }
lovr.graphics.setFont(Platform.font)

function Platform.draw_block( block )

    local r = block.r or 1
    local g = block.g or 1
    local b = block.b or 1

    local transform = block.transform
    local w = block.w
    local h = block.h

    Platform.draw_box( transform, w + block.m_w, h + block.m_h, 0.7 * r, 0.7 * g, 0.7 * b, 'line' )

    transform = transform:offset(block.m_w /2 + 2, block.m_h/2 + 2)
    -- Platform.draw_box( transform, w, h)

    -- transform = transform:offset(1,1)
    -- Platform.draw_box( transform, w - 2, h - 2, 0,0,0)

    -- transform = transform:offset(1,1)
    Platform.draw_box( transform, w - 4, h - 4, r,g,b)
end

function Platform.draw_box( transform, w, h, r, g, b, fill )
    r = r or 1
    g = g or 1
    b = b or 1

    local d = 5
    local scale = Platform.scale

    w = w / scale
    h = h / scale
    d = d / scale 
    fill = fill or 'fill'
    lovr.graphics.setColor(r, g , b)

    local m4 = lovr.math.mat4(transform:unpack()):translate(w/2, -h/2, -d/2)
    local x, y, z, sx, sy, sz, angle, ax, ay, az = m4:unpack(false)
    lovr.graphics.box(fill, x, y, z, w, h, d, angle, ax, ay, az)
end

function Platform:get_text_size( text )
    local scale = 10 --00
    local width, lines = self.font:getWidth(text, 0)
    return scale * width, self.font:getHeight() * lines * scale
end

function Platform.draw_text( transform, text, r, g, b) 
    r = r or 0
    g = g or 0
    b = b or 0

    local scale = 100 -- Platform.scale
    lovr.graphics.setColor(r, g , b)
    local m = lovr.math.mat4(transform.m4)
    m:translate(0,0,0.003)
    local x, y, z, sx, sy, sz, angle, ax, ay, az = m:unpack()
    lovr.graphics.print(text, x, y, z, 1/scale, angle, ax, ay, az, 0, 'left', 'top')
end

return Platform