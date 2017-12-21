--
-- Author: Your Name
-- Date: 2017-12-03 21:30:53
--
local M = {}


function M:startUpdate(packageName, cb)

    --local manifestPath = LOCAL_MANIFEST_PATH .."project_" ..packageName ..".manifest"
    local manifestPath = LOCAL_MANIFEST_PATH .."project.manifest"
    
    local storagePath = cc.FileUtils:getInstance():getWritablePath() ..UPDATE_STORAGE_PATH
    cclog.warn("<=== manifestPath = " ..manifestPath)
    cclog.warn("<=== storagePath = " ..storagePath)
    local amEx = cc.AssetsManagerEx:create(manifestPath, storagePath)
    amEx:retain()
    self.amEx = amEx

    local function onUpdateEvent(event)
        local eventCode = event:getEventCode()


        if eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE or 
            eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then

            cclog.debug("update eventCode = 0 ")
            --// 下载完成，或者不需要更新
            if cb then
                cb(0)
            end
         elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
            
            local percent = event:getPercentByFile()
            print("<===== percent = " ..percent)
            --// 正在下载
            if cb then
                cb(1, percent)
            end
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST or 
            eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
            eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST or 
            eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING or 
            eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED or 
            eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS then
            cclog.debug("update eventCode = 2")

            --// 发生错误
            if cb then
                cb(2, eventCode)
            end
        else
            cclog.debug("update eventCode = 3")
            --// 发生未知错误
            if cb then
                cb(3)
            end
        end
    end

    local listenerForUpdate = cc.EventListenerAssetsManagerEx:create(amEx, onUpdateEvent)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listenerForUpdate, 1)
    amEx:update()
end

function M:clear()
    -- body
    self.amEx:release()
end


return M