--
-- Author: Chen
-- Date: 2017-08-25 09:44:00
-- Brief: 
--

local string_sub   = string.sub
local string_upper = string.upper
local string_lower = string.lower
local string_len   = string.len

local BaseModel = class("BaseModel")

BaseModel.schema = {

}

BaseModel.fields = {
    
}

local function func_name(k)
    local firstLetter = string_sub(k, 1, 1)
    local fcName
    if string_len(k) > 1 then
        fcName = string_upper(firstLetter) ..string_sub(k, 2, -1)
    else
        fcName = string_upper(firstLetter)
    end

    return fcName
end


function BaseModel:ctor(properties)
    self:_setProperties(properties)

    ---[[
    --// 禁止未声明的变量赋值
    local mt = getmetatable(self)
    mt.__newindex = function(table, key, value)
        logger.fatal("Assign value to nonexistent key. key = " ..key)
    end
    setmetatable(self, mt)
    --]]
end

--// typ 
--// number 数字
--// bool 布尔
--// string 字符串
--// table 表
--// ctable 常量表,不允许新建属性

function BaseModel:_setProperties(properties)

    properties = checktable(properties)

    for field, schema in pairs(self.schema) do
        local typ, val, sche = schema[1], schema[2], schema[3]
        local propname = "_" ..field

        if val ~= nil then
            if typ == "number" then
                val = tonumber(val) or 0
            elseif typ == "bool" then
                val = val or false
            elseif typ == "string" then
                if val then
                    val = tostring(val)
                else
                    val = ""
                end
            elseif typ == "table" or typ == "ctable" then

                val = checktable(val)

                --[[
                --// 目前止支持一层table,后续扩展
                for k, v in pairs(val) do
                    --// set
                    self["set" ..func_name(field) ..func_name(k)] = function(self, value)
                        val[k] = value
                    end

                    --// get
                    self["get" ..func_name(field) ..func_name(k)] = function(self)
                        return val[k]
                    end
                end
                --]]
            end
        else
            val = schema
        end

        self[propname] = val


        --// get
        self["get" ..func_name(field)] = function(self)
            return self[propname]
        end

        --// table 不创建set方法
        if type(self[propname]) ~= "table" then
            --// set
            self["set" ..func_name(field)] = function(self, value)
                self[propname] = value
            end
        else
            if typ == "ctable" then
                --// 禁止未声明的变量赋值
                local mt = getmetatable(self[propname]) or {}
                mt.__newindex = function(table, key, value)
                    logger.fatal("Assign value to nonexistent key. key = " ..key)
                end
                setmetatable(self[propname], mt)
                --[[
            elseif typ == "rtable" then
                local mt = getmetatable(self[propname]) or {}
                mt.__newindex = function(table, key, value)

                    if type(value) ~= "table" then
                        logger.fatal("key is must table. now is " ..type(value))
                        return
                    end

                    local nonkeys = {}
                    for k, v in pairs(value) do
                        if not sche[k] then
                            nonkeys[#nonkeys + 1] = k
                        end
                    end

                    logger.debug(nonkeys, "nonkeys")

                    if #nonkeys == 0 then
                        rawset(table, key, value)
                    else
                        logger.fatal(nonkeys, "key is nonexistent.")
                    end
                end
                setmetatable(self[propname], mt)
                --]]
            end
        end
    end

    return self
end

function BaseModel:setProperties(newProperties)
    if type(newProperties) ~= "table" then
        newProperties = {}
    end

    local schema = self.schema

    for field, value in pairs(newProperties) do
        if schema[field] then
            self["_" ..field] = value
        else
            printLog("ERROR", "%s not declaration", field)
        end
    end
end

function BaseModel:getPropertie(field)
    local schema = self.schema
    return self["_" ..field]
end

function BaseModel:getProperties(fields)
    local schema = self.schema
    local properties = {}

    if fields == nil then
        for field, schema in pairs(schema) do
            properties["_" ..field] = self["_" ..field]
        end
    elseif type(fields) == "table" then 
        for i, field in ipairs(fields) do
            if schema[field] then
                local typ = schema[field][1]
                local val = self["_" ..field]
                properties[field] = val
            else
                printLog("ERROR", "%s not declaration", field)
            end
        end
    end

    return properties
end

return BaseModel