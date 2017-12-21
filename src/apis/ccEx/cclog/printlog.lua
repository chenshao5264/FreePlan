--
-- Author: Chen
-- Date: 2017-09-12 17:06:47
-- Brief: 
--

local old_print    = print

local LOG_DIR_ROOT = cc.FileUtils:getInstance():getWritablePath() .."logs/"
if IS_WRITE_TO_FILE then
if not cc.FileUtils:getInstance():isDirectoryExist(LOG_DIR_ROOT) then
    cc.FileUtils:getInstance():createDirectory(LOG_DIR_ROOT)
end
end


local HTML_COLOR = {"blue", "cyan", "green", "yellow", "red", "purple"}

local _thisFile
if IS_WRITE_TO_FILE then
    --local filename = LOG_DIR_ROOT ..os.date("%Y-%m-%d %H-%M-%S") .."-log.html"
    local filename = LOG_DIR_ROOT .."app-log.html"
    _thisFile = io.open(filename, "w+")
end

local function write2File(level, str)

    if _thisFile then
        local content = os.date("%Y-%m-%d %H:%M:%S") ..": " ..str ..'\n'
        content = string.format("<font color=%s>%s</font><br/>\n", HTML_COLOR[level], content)
        _thisFile:write(content)
        _thisFile:flush()
    end
end

local function checkArgType(arg)
    if type(arg) == "table" then
        local result = dump(arg, "table_table", 10, 10086)
        arg = table.concat(result, "\n")
    else
        arg = tostring(arg)
    end

    return arg
end

local function concat(...)
    local tb = {}
    for i=1, select('#', ...) do
        local arg = select(i, ...)  

        tb[#tb + 1] = checkArgType(arg)
    end
    return table.concat(tb, "\t")
end

local function checkArgType_(arg)
    if type(arg) == "table" then
        local result = dump(arg, "table_table", 10, 10086)
        arg = table.concat(result, "<br/>\n")
    else
        arg = tostring(arg)
    end

    return arg
end

local function concat_(...)
    local tb = {}
    for i=1, select('#', ...) do
        local arg = select(i, ...)  

        tb[#tb + 1] = checkArgType_(arg)
    end
    return table.concat(tb, "\t")
end

local color      = import(".color")
local colorPrint = color.colorPrint
local colors = {color.BLUE, color.CYAN, color.GREEN, color.YELLOW, color.RED, color.PURPLE}

local methods    = {"trace", "debug", "info", "warn", "error", "fatal"}
local levels = {ALL = 0}

logger = {}

cclog = {}

local funcs = {}
local nop = function() end

for i, name in ipairs(methods) do
    local level_name = string.upper(name)
    levels[level_name] = i
    local tag = '['..level_name..']'
    funcs[name] = function(...)
        local date = os.date("[%H:%M:%S] ")
        local pntRet = date .. concat(...) .. "\n"
        colorPrint(colors[i], tag, pntRet)

        pntRet = date .. concat_(...) .. "\n"
        write2File(i, pntRet)
    end
end

function logger.setLevel(lv)
    for i, funcname in ipairs(methods) do
        if i < lv then
            logger[funcname] = nop
            cclog[funcname] = nop
        else
            logger[funcname] = funcs[funcname]
            cclog[funcname] = funcs[funcname]
        end
    end
end