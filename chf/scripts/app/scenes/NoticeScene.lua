
-- 公告Scene

local NoticeScene = class("NoticeScene", function()
    return display.newScene("NoticeScene")
end)


function NoticeScene:ctor()
    local bg = LoginBO.getLoadingBg()
    self:addChild(bg)
    self.bg = bg
end

function NoticeScene:onEnter()
    LoginBO.initVersion()
	LoginBO.asynGetServerList(handler(self, self.goToPlatform))
end

function NoticeScene:onExit()
end

function NoticeScene:goToPlatform()
    local serverBaseVer = string.split(LoginMO.baseVersion_, ".")
    local serverBaseVer1 = ""
    for i=1, #serverBaseVer do
        serverBaseVer1 = serverBaseVer1 .. serverBaseVer[i]
    end

    local localBaseVer = string.split(GameConfig.baseVersion, ".")
    local localBaseVer1 = ""
    for i = 1, #localBaseVer do
        localBaseVer1 = localBaseVer1 .. localBaseVer[i]
    end
    serverBaseVer1 = tonumber(serverBaseVer1)
    localBaseVer1 = tonumber(localBaseVer1)

    -- gdump(serverBaseVer1,localBaseVer1)
    gprint("NoticeScene:goToPlatform serverVer:", serverBaseVer1, "localVer:", localBaseVer1)

    if serverBaseVer1 > localBaseVer1 then  -- 需要下载新包进行更新
        --更新公告
        ServiceBO.showNotice(GameConfig.downRootURL .. GameConfig.environment .. "_noticeUpdate.html?t=" .. os.time())
        nodeTouchEventProtocol(self.m_bg, function(event)
                ServiceBO.showNotice(GameConfig.downRootURL .. GameConfig.environment .. "_noticeUpdate.html?t=" .. os.time())
            end, nil, true)
        do return end
    end

    --游戏公告
    ServiceBO.showNotice(GameConfig.downRootURL .. "notice.html?t=" .. os.time())

    self:runAction(transition.sequence({cc.DelayTime:create(0.6), cc.CallFunc:create(function()
            local starttxt = display.newSprite("image/common/label_click_screen_star.png", display.cx, 110)
            starttxt:addTo(self)

            nodeTouchEventProtocol(self.m_bg, handler(self, self.onTouch))
        end)}))
end

function NoticeScene:onTouch(event)
    -- if device.platform == "windows" and GLOBAL_UPDATE_ON == false then
    --     Enter.startLogin()
    -- else
        Enter.startUpdate()
    -- end
end

return NoticeScene
