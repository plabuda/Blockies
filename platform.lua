if love then
    return require("platform_love")
elseif lovr then
    return require("platform_lovr")
else
    return nil
end    
