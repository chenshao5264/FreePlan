--
-- Author: Chen
-- Date: 2017-08-30 14:04:26
-- Brief: http 工具集
--  
-- HttpUtils.httpPost("http://127.0.0.1:9000", "login", {account = "chenshao", password = "1q2w3e"})

local HttpUtils = {}

--[[
local function mosaicUrl(baseUrl, api, params)
    local url = baseUrl .. "/" ..api .."?"
    if type(params) == 'table' then
        local paramIndex = 1
        for k, v in pairs(params) do
            url = url .. k .. '=' .. v
            if paramIndex < table.nums(params) then
                url = url .. '&'
            end
            paramIndex = paramIndex + 1
        end
    end

    return url
end
--]]

-- /**
--  * http get请求 http://localhost:8080/login?account=chenshao&password=1q2w3e
--  * @param url http://localhost:8080
--  * @param api login
--  * @param params {account = chenshao, password = 1q2w3e}
--  * @param callback http回复
--  */
function HttpUtils.httpGet(url, api, params, callback)
    url = mosaicUrl(url, api, params)
    local xhr = cc.XMLHttpRequest:new()
    xhr:open('GET', url)
    xhr:registerScriptHandler(function()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            printLog('HttpUtils GET', 'response: %s', xhr.response)
            if callback then
                callback(xhr.response)
            end
        else
            printLog('HttpUtils GET', 'readyState: %s, status: %s', xhr.readyState, xhr.status)
        end
    end )
    xhr:send()
    printLog('HttpUtils', 'http get url: %s', url)
end

-- /**
--  * http pos请求 http://localhost:8080/login?account=chenshao&password=1q2w3e
--  * @param url http://localhost:8080
--  * @param api login
--  * @param params {account = chenshao, password = 1q2w3e}
--  * @param callback http回复
--  */
function HttpUtils.httpPost(url, api, params, callback)
    url = mosaicUrl(url, api, params)
    local xhr = cc.XMLHttpRequest:new()
    xhr:open('POST', url)
    xhr:registerScriptHandler( function()
       if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            printLog('HttpUtils POST', 'response: %s', xhr.response)
            if callback then
                callback(xhr.response)
            end
        else
            printLog('HttpUtils POST', 'readyState: %s, status: %s', xhr.readyState, xhr.status)
        end
    end)
    xhr:send()
    printLog('HttpUtils', 'http post url: %s', url)
end

function HttpUtils.upload(url)
    local xhr = cc.XMLHttpRequest:new()
    xhr:open('POST', url)
    xhr:setRequestHeader("Content-Type", "text/plain")
    xhr:registerScriptHandler( function()
       if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            printLog('HttpUtils POST', 'response: %s', xhr.response)
            if callback then
                callback(xhr.response)
            end
        else
            printLog('HttpUtils POST', 'readyState: %s, status: %s', xhr.readyState, xhr.status)
        end
    end)
    xhr:send()
end

return HttpUtils