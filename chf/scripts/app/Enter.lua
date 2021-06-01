cc.FileUtils:sharedFileUtils():purgeCachedEntries()

if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
	GAME_ORIGIANL_X = 0
	GAME_ORIGIANL_Y = 0
	GAME_SIZE_WIDTH = display.width
	GAME_SIZE_HEIGHT = display.height
else
    GAME_ORIGIANL_X = (display.width - 640) / 2
    GAME_ORIGIANL_Y = 0
    GAME_SIZE_WIDTH = 640
    GAME_SIZE_HEIGHT = display.height
end

print("GAME_ORIGIANL_X=", GAME_ORIGIANL_X)
print("GAME_ORIGIANL_Y=", GAME_ORIGIANL_Y)
print("GAME_SIZE_WIDTH=", GAME_SIZE_WIDTH)
print("GAME_SIZE_HEIGHT=", GAME_SIZE_HEIGHT)
-- print("CCEGLView:sharedOpenGLView():getScaleX()", CCEGLView:sharedOpenGLView():getScaleX())
-- print("CCEGLView:sharedOpenGLView():getScaleY()", CCEGLView:sharedOpenGLView():getScaleY())

GAME_X_SCALE_FACTOR = 1

if display.width > GAME_SIZE_WIDTH then
    GAME_X_SCALE_FACTOR = display.width / GAME_SIZE_WIDTH
end

print("GAME_X_SCALE_FACTOR=", GAME_X_SCALE_FACTOR)

scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
socket = require "socket.core"

require("app.GameConfig")

require_ex("app.ui.init")
require_ex("app.util.init")
require_ex("app.remote.init")
require_ex("app.controller.init")

require_ex("app.net.PbList")
require_ex("app.net.PbProtocol")
require("app.net.NetQueue")  -- -- 使用scheduler，不能使用require_ex加载
NetWrapper = require_ex("app.net.NetWrapper")
SocketWrapper = require("app.net.SocketWrapper")

require_ex("app.bo.ServiceBO")
require_ex("app.bo.LoginBO")

require_ex("app.bo.TKGameBO")
require_ex("app.text.TKText")
require_ex("app.text.InitText")

----------------------------------------------------
require_ex("app.text.ErrorText")
NetErrorDialog = require_ex("app.dialog.NetErrorDialog")
BusErrorDialog = require_ex("app.dialog.BusErrorDialog")
IosUpdateDialog = require_ex("app.dialog.IosUpdateDialog")
ChannelMaintainDialog = require_ex("app.dialog.ChannelMaintainDialog")
----------------------------------------------------
require("app.util.Statistics")
Statistics.Init()
----------------------------------------------------

Enter = {}

-- 游戏中资源的路径
IMAGE_COMMON = "image/common/"
IMAGE_HUNTER = "image/hunter"
IMAGE_ANIMATION = "animation/"

function Enter.startLogo()
    display.replaceScene(require_ex("app.scenes.LogoScene").new())
end

function Enter.startNotice()
    display.replaceScene(require_ex("app.scenes.NoticeScene").new(), nil, "fade", 0.6)
end

function Enter.startLogin(type)
    package.loaded["app.net.SocketWrapper"] = nil
    package.preload["app.net.SocketWrapper"] = nil
    SocketWrapper = require("app.net.SocketWrapper")
    display.replaceScene(require_ex("app.scenes.LoginScene").new(type))
end

function Enter.startActivate()
    display.replaceScene(require_ex("app.scenes.ActivateScene").new())
end

function Enter.startArea()
    display.replaceScene(require_ex("app.scenes.AreaScene").new())
end

function Enter.startRole()
    display.replaceScene(require_ex("app.scenes.RoleScene").new())
end

function Enter.startUpdate()
    
    -- LoginBO.enableCode(function(showCode)
    --         if showCode then
    --             display.replaceScene(require_ex("app.scenes.UpdateScene").new(), nil, "fade", 0.5)
    --         else
    --             Enter.startLogin()
    --         end
    --     end)
    display.replaceScene(require_ex("app.scenes.UpdateScene").new(), nil, "fade", 0.5)
end

function Enter.startLoading()
    display.replaceScene(require_ex("app.scenes.LoadingScene").new(), nil, "fade", 0.5)
end

function Enter.startMain()
	UiDirector.reset()
	display.replaceScene(require_ex("app.scenes.MainScene").new())
end

function Enter.startUpdateApk()
    --IOS审核阶段，不走更新
    LoginBO.enableCode(function(showCode)
            if showCode then
                display.replaceScene(require_ex("app.scenes.UpdateApkScene").new(), nil, "fade", 0.5)
            else
                Enter.startLogin()
            end
        end)
    -- display.replaceScene(require_ex("app.scenes.UpdateApkScene").new(), nil, "fade", 0.5)
end

--JAVA调用lua的两个方法，重新登录和注销
function returnLogin()
    if SocketWrapper.getInstance() then
        SocketWrapper.getInstance():disconnect(true)
    end
    Enter.startLogin()
end

function returnLogout(type)
    if SocketWrapper.getInstance() then
        SocketWrapper.getInstance():disconnect(true)
    end
    local logintype
    if type then
        logintype = tonumber(type)       
    end
    Enter.startLogin(logintype)
end

--新增JAVA调用lua的方法，传入sid调用sdklogin
function doSdkLoginCallback(sid)
    if SocketWrapper.getInstance() then
        SocketWrapper.getInstance():disconnect(true)
    end
    LoginBO.asynSdkLogin(sid)
end
