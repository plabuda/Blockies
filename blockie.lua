local blockieFactory = {}

blockieFactory.renderBlockie = function( blockie )
    love.graphics.push('all')
    love.graphics.setColor( blockie.r, blockie.g, blockie.b )
    love.graphics.translate(blockie.x,blockie.y)
    love.graphics.rectangle('fill', 0,0, blockie.width, blockie.height)
    love.graphics.pop()
    if blockie.child then
        blockie.child.draw()
    end
end

blockieFactory.getBlockie = function( blockie , mx, my )
    local ret = blockie
    if blockie.child 
    and mx >= blockie.child.x and mx <= blockie.child.x + blockie.child.width
    and my >= blockie.child.y and my <= blockie.child.y + blockie.child.height then
        ret = blockie.child.pick(mx, my)
        if ret == blockie.child then            
        blockie.child = nil
        end
    end
    blockie.measure()
    return ret
end

blockieFactory.measure = function( blockie )
    if blockie.child then
        blockie.child.measure()
        blockie.width = blockie.child.width + 14
        blockie.height = blockie.child.height + 14
    else
        blockie.width = 50
        blockie.height = 50
    end
end

blockieFactory.place = function( blockie, x, y )
    blockie.x = x
    blockie.y = y
    if blockie.child then
        blockie.child.place( x + 7, y + 7)
    end
end

blockieFactory.new = function( r, g, b )
    local result = {}
    result.r = r
    result.g = g
    result.b = b    
    result.draw = function() blockieFactory.renderBlockie(result) end
    result.pick = function(mx, my) return blockieFactory.getBlockie(result, mx, my) end
    result.measure = function() blockieFactory.measure(result) end
    result.place = function( x, y ) blockieFactory.place( result, x, y) end
    result.measure()
    result.place( 100, 100 )
    result.child = nil
    return result
end

return blockieFactory