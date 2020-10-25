local boxFactory = require("box")

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

    blockieFactory.drawSlottie(blockie.left)
    blockieFactory.drawSlottie(blockie.right)

end

blockieFactory.drawSlottie = function ( slottie )
    love.graphics.push('all')
    love.graphics.setColor( 1,1,1,0.5 )
    love.graphics.translate(slottie.x, slottie.y)
    love.graphics.rectangle('fill', 0,0, slottie.w, slottie.h)
    love.graphics.pop()
end


blockieFactory.dropBlockie = function( blockie, target, mx, my)
    local result = true
    if blockie.child then
        result = blockie.child.drop(target, mx, my)
    else
        blockie.child = target
    end
    blockie.measure()
    blockie.place(blockie.x, blockie.y)
    return result
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
    blockie.left.x = blockie.x + 10
    blockie.left.y = blockie.y + 10
    blockie.right.x = blockie.x + 30
    blockie.right.y = blockie.y + 10
    if blockie.child then
        blockie.child.place( x + 7, y + 7)
    end
end

blockieFactory.new = function( r, g, b )
    local result = boxFactory.new( 100, 100, 100, 100 )
    result.r = r
    result.g = g
    result.b = b    
    result.left = boxFactory.new(0, 0, 10, 30)
    result.right = boxFactory.new(0,0,10,30)
    result.draw = function() blockieFactory.renderBlockie(result) end
    result.pick = function(mx, my) return blockieFactory.getBlockie(result, mx, my) end
    result.measure = function() blockieFactory.measure(result) end
    result.place = function( x, y ) blockieFactory.place( result, x, y) end
    result.drop = function( target, x, y) return blockieFactory.dropBlockie( result, target, x, y ) end
    result.measure()
    result.place( 100, 100 )
    result.child = nil
    return result
end

return blockieFactory