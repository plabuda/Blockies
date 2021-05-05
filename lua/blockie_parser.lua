local Block = require("block")

local Expression_Block = require("lua.expression_block")
local Operator_Block = require("lua.operator_block")
local Number_Block = require("lua.number_block")
local String_Block = require("lua.string_block")
local Local_Block = require("lua.local_block")
local Return_Block = require("lua.return_block")
local Set_Block = require("lua.set_block")
local Id_Block = require("lua.id_block")

local Parser = {
    compiler = require("lua.compiler").new(),
    print = require("lua.pprint")
}

function Parser:is_unary( opname )
    return opname == 'not'
        or opname == 'len'
        or opname == 'unm'
end

function Parser:parse_Paren( token )
    local expr = {}
    if token[1].tag == 'Op' then
        self:parse_Op(token[1], expr)
    else
        table.insert( expr, self:parse_token(token[1]) )
    end

    return Expression_Block:new(expr, true, 64, 64)

end

function Parser:parse_Op( token, expr )

    local opname = token[1]

    -- special case of unary minus negating a number
    if opname == 'unm' and token[2].tag == 'Number' then
        local number = self:parse_Number( token[2], true )
        if expr then
            table.insert( expr, number )
        else
            return number
        end
    end

    -- if we're passed a table, we insert to it
    -- but if not, we'll return as Expression, and pass it as table to children
    local is_root = false
    if not expr then
        expr = {}
        is_root = true
    end


    if self:is_unary(opname) then
        table.insert( expr, Operator_Block:new(opname, 64, 64) )
        -- unary operators have only one side
        if token[2].tag == 'Op' then
            self:parse_Op(token[2], expr)
        else
            table.insert( expr, self:parse_token(token[2]) )
        end
    else        
        -- expand left-hand operand, or just add it
        if token[2].tag == 'Op' then
            self:parse_Op(token[2], expr)
        else
            table.insert( expr, self:parse_token(token[2]) )
        end
        -- add itself
        table.insert( expr, Operator_Block:new(opname, 64, 64) )
        -- do the same for right-hand
        if token[3].tag == 'Op' then
            self:parse_Op(token[3], expr)
        else
            table.insert( expr, self:parse_token(token[3]) )
        end
    end

    if is_root then
        return Expression_Block:new(expr, false, 64,64)
    end
end

function Parser:parse_Default( token )
    return Block:new(64,64,64,64)
end

function Parser:parse_String( token )
    return String_Block:new(token[1], 64,64)
end

function Parser:parse_Number( token, is_negative )
    return Number_Block:new(token[1], is_negative, 64,64)
end

function Parser:build_set(token, is_local)
    local lhs = {}
    for i, v in ipairs(token[1]) do
        table.insert( lhs, self:parse_token(v) )
    end

    local rhs = {} 

    for i, v in ipairs(token[2]) do
        table.insert( rhs, self:parse_token(v) )
    end

    return Set_Block:new(lhs,rhs,is_local,64,64)
end

function Parser:parse_Return( token )
    local items = {}
    for i, v in ipairs(token) do
        table.insert( items, self:parse_token(v) )
    end
    return Return_Block:new(items, 64, 64)  
end

function Parser:parse_Local( token )

    -- Local can be local set of ID's OR a local Set
    if type(token[2]) == 'table' and #token[2] > 0 then
        return self:build_set(token, true)
    else
        local items = {}
        for i, v in ipairs(token[1]) do
            table.insert( items, self:parse_token(v) )
        end
        return Local_Block:new(items, 64, 64)
    end
end

function Parser:parse_Set(token)
    return self:build_set(token, false)
end

function Parser:parse_Id(token)
    return Id_Block:new(token[1], 64,64)
end

function Parser:parse( src ) --parse the given string using metalua parser 
    local ast = self:to_ast( src )
    local results = self:print_info(ast, 0)
    -- for index, token in pairs(ast) do
    --     if index ~= 'lineinfo' then
    --         --table.insert(results, self:parse_token(token))
    --         self:print_info(token,0)
    --     end
    -- end

    return results
end

function Parser:print_info( token, depth )
    local result = {}

    local off = string.rep("  ",depth)
    local res = off .. tostring(token.lineinfo.first) .. tostring(token.lineinfo.last)
    result.first = token.lineinfo.first.column
    result.last = token.lineinfo.last.column
    result.leaves = {}
    print(res)
    for i, v in ipairs(token) do
        if type(v) == 'table' then
            table.insert( result.leaves, self:print_info(v, depth + 1))
        end
    end
    return result
end

function Parser:parse_token( token )
    -- local method = self['parse_'.. tostring(token.tag)]
    -- if token.tag and method then
    --     return method(self, token)
    -- else
    --     return self:parse_Default(token)
    -- end
    return nil
end

function Parser:to_ast( src )
    local result = self.compiler:src_to_ast(src)
    print(self.print.tostring(result))
    return result
end

return Parser