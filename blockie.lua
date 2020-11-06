local blockie = {}

function blockie.collide( box1,  box2 )
    local b1 = {
        left = box1.x_a + box1.m_w / 2,
        right = box1.x_a + box1.w + box1.m_w / 2,

        top =  box1.y_a + box1.m_h / 2,
        bottom = box1.y_a + box1.h + box1.m_h / 2 
    }

    local b2 = {
        left = box2.x_a + box2.m_w / 2,
        right = box2.x_a + box2.w + box2.m_w / 2,

        top =  box2.y_a + box2.m_h / 2,
        bottom = box2.y_a + box2.h + box2.m_h / 2
    }

    return b1.left < b2.right and
    b1.right > b2.left and
    b1.top < b2.bottom and
    b1.bottom > b2.top
end
    
    
function blockie.draw( retval, r, g, b)
    love.graphics.setColor(r * 0.7, g * 0.7, b * 0.7)
    -- love.graphics.rectangle('line', retval.x_a , retval.y_a , retval.w + retval.m_w, retval.h + retval.m_h)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', retval.x_a + retval.m_w/2 , retval.y_a + retval.m_h / 2, retval.w, retval.h)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', retval.x_a + retval.m_w/2 + 1 , retval.y_a + retval.m_h / 2 + 1, retval.w - 2, retval.h - 2)

    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', retval.x_a + retval.m_w/2 + 2 , retval.y_a + retval.m_h / 2 + 2, retval.w - 4, retval.h - 4)
end
    

function blockie.new( measure_callback, draw_callback )
    local retval =
    {
        w = WIDTH_DEFAULT,
        h = HEIGHT_DEFAULT,
        m_w = MARGIN_DEFAULT,
        m_h = MARGIN_DEFAULT,
        x = 0,
        y = 0,
        x_a = 0, -- absolute transform, updated on move()
        y_a = 0,
        collections = {},
        children = {}
    }

    retval.clear_slots = function ()
        for i=1,#retval.children do
            if retval.children[i].payload then
                if retval.children[i].payload.is_slot == true then
                    retval.children[i].payload = nil
                else
                    retval.children[i].payload.clear_slots()
                end
            end
        end

        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local k = 1
                while k <= #retval.collections[j].payload do
                    if retval.collections[j].payload[k].is_slot then
                        table.remove( retval.collections[j].payload , k)                        
                    else
                        retval.collections[j].payload[k].clear_slots()
                        k = k + 1
                    end
                end
            end    
        end
    end

    retval.add_slots = function ( type )
        -- can there even be a nil collection? Maybe for else blocks in if? Still, in that case the block should control it, not slots
        for i=1,#retval.children do
            if retval.children[i].payload then
                    retval.children[i].payload.add_slots(type)              
            else                
                retval.children[i].payload = slot( function (other) retval.children[i].payload = other end ) -- replace with a proper slot type

            end
        end

        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload                
                local result = {slot( function (other) table.insert( retval.collections[j].payload, 1, other) end )}
                for k=1,#collection do
                    if collection[k].is_slot ~= true then
                        collection[k].add_slots(type)
                        table.insert( result, collection[k])
                        table.insert( result, slot( function (other) table.insert( retval.collections[j].payload, k * 2 + 1, other) end ) )
                    end
                end
                retval.collections[j].payload = result
            end    
        end
    end

    retval.collide = function ( other )        
        if blockie.collide(retval, other) then
            if retval.is_slot == true then
                return retval
            end
            -- it we aren't the slot, iterate over children
            -- iterate over and measure all singular children
            for i=1,#retval.children do
                if retval.children[i].payload then
                    local candidate = retval.children[i].payload.collide( other )
                    if candidate ~= nil then return candidate end
                end
            end

            -- iterate over and measure all collections
            for j=1,#retval.collections do
                if retval.collections[j].payload then
                    local collection = retval.collections[j].payload
                    for k=1,#collection do
                        local candidate = collection[k].collide( other )
                        if candidate ~= nil then return candidate end
                    end
                end
            end
        end
        return nil
    end

    retval.pick = function ( other )        -- TODO roll pick and collide together
        if retval.is_slot ~= true and blockie.collide(retval, other) then           

            for i=1,#retval.children do
                if retval.children[i].payload then
                    local candidate = retval.children[i].payload.pick( other )
                    if candidate ~= nil then
                        if candidate == retval.children[i].payload then -- if its a direct descendant, clear it from the slot
                            retval.children[i].payload = nil
                        end
                        return candidate 
                    end -- if found a candidate, return it
                end
            end

            -- iterate over and measure all collections
            for j=1,#retval.collections do
                if retval.collections[j].payload then
                    local collection = retval.collections[j].payload
                    for k=1,#collection do
                        local candidate = collection[k].pick( other )
                        if candidate ~= nil then
                            if candidate == collection[k] then -- if it's a direct descendant, remove it from collection
                                table.remove( collection, k ) 
                            end
                            return candidate 
                        end
                    end
                end
            end

            return retval
        else
            return nil
        end
    end

    retval.getSize = function ()        
        return retval.w + retval.m_w, retval.h + retval.m_h
    end

    retval.measure = function () 
        
        -- iterate over and measure all singular children
        for i=1,#retval.children do
            if retval.children[i].payload then
                retval.children[i].payload.measure()
            end
        end

        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                for k=1,#collection do
                    collection[k].measure()
                end
            end
        end

        measure_callback ( retval )
    end

    retval.draw = function ()

        draw_callback ( retval )
        
        for i=1,#retval.children do
            if retval.children[i].payload then
                retval.children[i].payload.draw()
            end
        end  
        
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                for k=1,#collection do
                    collection[k].draw()
                end
            end
        end

    end

    retval.move = function ( x, y )
        retval.x_a = x + retval.x -- calculate absolute position 
        retval.y_a = y + retval.y
        
        --draw_callback ( retval, x, y ) -- don't actually draw

        local x2 = retval.x_a + retval.m_w /2
        local y2 = retval.y_a + retval.m_h /2 

        -- iterate over and measure all singular children
        for i=1,#retval.children do
            if retval.children[i].payload then
                retval.children[i].payload.move(x2, y2)
            end
        end  
        
        -- iterate over and measure all collections
        for j=1,#retval.collections do
            if retval.collections[j].payload then
                local collection = retval.collections[j].payload
                for k=1,#collection do
                    collection[k].move(x2, y2)
                end
            end
        end

    end

    return retval
end

return blockie