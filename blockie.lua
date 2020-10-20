local blockieFactory = {}

blockieFactory.renderBlockie = function( blockie )
    love.graphics.push('all')
    love.graphics.setColor( blockie.r, blockie.g, blockie.b )
    love.graphics.translate(blockie.x,blockie.y)
    love.graphics.rectangle('fill', 0,0, blockie.width, blockie.height)
    love.graphics.pop()
end

blockieFactory.new = function( r, g, b )
    local result = {}
    result.r = r
    result.g = g
    result.b = b
    result.width = 100
    result.height = 50
    result.x = 100
    result.y = 100
    result.draw = function() blockieFactory.renderBlockie(result) end
    return result
end

return blockieFactory