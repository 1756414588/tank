--
-- Author: gf
-- Date: 2016-01-14 14:38:44
-- 整包更新 Scene

IOS_FORCE_UPDATE_VERSION = 258  --IOS开启强更版本  258之前版本的IOS客户端没有强更支持


local UpdateApkScene = class("UpdateApkScene", function()
    return display.newScene("UpdateApkScene")
end)


function UpdateApkScene:ctor()
    local bg = LoginBO.getLoadingBg()
    self:addChild(bg)
    self.bg = bg
end

function UpdateApkScene:onEnter()
    --判断是否需要强更整包
    if LoginBO.needUpdateApk() then
        LoginBO.getApkUpdateData(function(apkURL)
                gprint("apkDownLoadURL=========:",apkURL)
                ServiceBO.updateApk(apkURL)
                self:initUI()
                if not self.refreshTimeScheduler_ then
                    self.refreshTimeScheduler_ = scheduler.scheduleGlobal(function()
                        ServiceBO.getProgress(function(progress)
                            gprint("downLoad progress:",progress)
                            if not progress then return end
                            local percent = tonumber(progress)
                            gprint("downLoad percent:",percent)
                            if percent < 100 then
                                self:updateUI(InitText[2]..tostring(percent) .. "%", percent / 100)
                            else
                                --下载完成
                                -- self:updateUI(InitText[20], 1)
                                scheduler.unscheduleGlobal(self.refreshTimeScheduler_)
                                self.refreshTimeScheduler_ = nil
                            end
                        end)
                    end, 1)  -- 每1秒钟执行一次
                end
            end)
    else
        if device.platform == "android" then
            self:asynGetUpdateInfo(function(data)
                    local updateList = data.list
                    local msg_ = InitText[24]
                    local stop = true
                    for index=1,#updateList do
                        local updateData = updateList[index]
                        if GameConfig.environment == updateData.plat then
                            if updateData.stop == "1" then
                                msg_ = updateData.info
                            else
                                stop = false
                            end
                            break
                        end
                    end
                    if stop then
                        NetErrorDialog.getInstance():show({msg = msg_, code = nil}, function() os.exit() end)
                    else
                        Enter.startUpdate()
                    end
                end
            )
        elseif device.platform == "ios" or device.platform == "mac" then
            local localVersion = LoginBO.getLocalApkVersion()
            self:asynGetIosUpdateInfo(function(data)
                    local updateList = data.list
                    local msg_ = ""
                    local url = ""
                    local stop = false
                    --更新方式 1 强更 2 提示
                    local updateType = 1
                    for index=1,#updateList do
                        local updateData = updateList[index]
                        if GameConfig.environment == updateData.plat then
                            if localVersion < updateData.version then
                                msg_ = updateData.info
                                url = updateData.url
                                stop = true
                                updateType = updateData.type
                            end
                            break
                        end
                    end
                    if stop then
                        --如果没有强更代码支持 直接弹出提示
                        if localVersion < IOS_FORCE_UPDATE_VERSION then
                            --弹出强更提示框
                            IosUpdateDialog.getInstance():show({msg = msg_, code = nil}, updateType, function() os.exit() end,  function() Enter.startUpdate() end)  
                            IosUpdateDialog.getInstance().m_okBtn:setLabel(LoginText[61])
                        else
                            --弹出强更提示框
                            IosUpdateDialog.getInstance():show({msg = msg_, code = nil}, updateType, function() ServiceBO.gotoURL(url) end,  function() Enter.startUpdate() end)  
                        end
                    else
                        Enter.startUpdate()
                    end
                end
            )
        else
            Enter.startUpdate()
        end
    end
end

--获得IOS强更信息
function UpdateApkScene:asynGetIosUpdateInfo(callBack)
    local function getVersionCallback(event)
        local wrapper = event.obj
        local content = wrapper:getData()
        gprint("content",content)
        local data = json.decode(content)
        if callBack then callBack(data) end
    end
    -- 正式 cdn.tank.hundredcent.com
    
    local wrapper = NetWrapper.new(getVersionCallback, nil, true, REQUEST_TYPE_GET, "http://cdn.tank.hundredcent.com/version/tank_update_info_ios.json", false)
    wrapper:sendRequest()
end


function UpdateApkScene:asynGetUpdateInfo(callBack)
    local function getVersionCallback(event)
        local wrapper = event.obj
        local content = wrapper:getData()
        gprint("content",content)
        local data = json.decode(content)
        if callBack then callBack(data) end
    end

    local wrapper = NetWrapper.new(getVersionCallback, nil, true, REQUEST_TYPE_GET, "http://cdn.tank.hundredcent.com/version/tank_update_info.json", false)
    wrapper:sendRequest()
end



function UpdateApkScene:initUI()
    self.updateView = display.newNode():addTo(self)

    local barBgName = ""

    if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
        barBgName = "image/screen/a_bg_7.png"
    else
        barBgName = "image/screen/b_bg_7.png"
        if HOME_SNOW_DEFAULT == 1 then
            barBgName = "image/screen/a_bg_7.png"
        end
    end

    local bar = ProgressBar.new(IMAGE_COMMON .. "login/bar_1.png", BAR_DIRECTION_HORIZONTAL, cc.size(296, 20), {bgName = barBgName}):addTo(self.updateView)
    bar:setPosition(display.cx, display.cy - 380)
    bar:setPercent(0)
    self.m_progressBar = bar

    local dot = display.newSprite("image/common/login/downEffect.png"):addTo(bar,100)
    dot:setPosition(0, 10)
    self.dot = dot

    self.m_msgLabel = ui.newTTFLabel({text = InitText[19], font = G_FONT, size = FONT_SIZE_SMALL, x = display.cx, y = display.cy - 420, align = ui.TEXT_ALIGN_CENTER}):addTo(self.updateView)
    self.m_msgLabel:setColor(ccc3(255,255,255))
end

function UpdateApkScene:updateUI(msg, percent, barVisible)
    if not barVisible then barVisible = true end
    gprint("bar msg",msg)
    gprint("bar percent",percent)
    self.m_msgLabel:setString(msg)
    self.m_progressBar:setPercent(percent)
    self.m_progressBar:setVisible(barVisible)

    local w = self.m_progressBar:getContentSize().width * percent
    self.dot:setPositionX(w)
end


-- function UpdateApkScene:onTick(dt)
	
-- end


function UpdateApkScene:onExit()
	if self.refreshTimeScheduler_ then
		scheduler.unscheduleGlobal(self.refreshTimeScheduler_)
		self.refreshTimeScheduler_ = nil
	end
end



return UpdateApkScene

