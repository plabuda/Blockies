local Block = require("block")
local Set_Block = require("lua.set_block")
local Id_Block = require("lua.id_block")

local Parser = {
    compiler = require("lua.compiler").new(),
    print = require("lua.pprint")
}

function Parser:parse_Default( token )
    return Block:new(64,64,64,64)
end

function Parser:parse_Set(token)
    local lhs = {}
    for i, v in ipairs(token[1]) do
        table.insert( lhs, self:parse_token(v) )
    end

    local rhs = {} 

    for i, v in ipairs(token[2]) do
        table.insert( rhs, self:parse_token(v) )
    end

    return Set_Block:new(lhs,rhs,nil,64,64)
end

function Parser:parse_Id(token)
    return Id_Block:new('aaa', 64,64)
end

function Parser:parse( src ) --parse the given string using metalua parser 
    local ast = self:to_ast( src )
    local results = {}
    for index, token in pairs(ast) do
        table.insert(results, self:parse_token(token))
    end

    return results
end

function Parser:parse_token( token )
    local method = self['parse_'.. tostring(token.tag)]
    if token.tag and method then
        return method(self, token)
    else
        return self:parse_Default(token)
    end
end

function Parser:to_ast( src )
    local result = self.compiler:src_to_ast(src)
    print(self.print.tostring(result))
    return result
end

return Parser