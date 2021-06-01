
require_ex("app.bo.LoginBO")

local LogoScene = class("LogoScene", function()
	return display.newScene("LogoScene")
	end)

function LogoScene:ctor()
end

function LogoScene:onEnter(...)
	LoginBO.initRunParam(function()
			self:showCpLogo()
		end)
end

function LogoScene:showCpLogo()
	-- local cpLogo
	-- if GameConfig.environment == "anfan_client" then
	-- 	cpLogo = display.newSprite("zLoginBg/logo_anfan.png", display.cx, display.cy):addTo(self)
	-- end
	-- if cpLogo then
	-- 	local actions = transition.sequence({CCFadeIn:create(0.7), CCDelayTime:create(1.5), CCFadeOut:create(0.7), CCCallFunc:create(function() 
	--         self:showBaili()
	--     end)})
	--     cpLogo:runAction(actions)
	-- else
	-- 	if GameConfig.environment == "chpub_client" or GameConfig.environment == "tencent_chpub" or GameConfig.environment == "zty_client" then
	-- 		self:playEnd()
	-- 	else
	-- 		self:showBaili()
	-- 	end
	-- end
	if GameConfig.environment == "chpub_client" or GameConfig.environment == "tencent_chpub" or GameConfig.environment == "zty_client" 
		or GameConfig.environment == "chYh_client" or GameConfig.environment == "chpub_hj4_client" then
		self:playEnd()
	else
		self:showBaili()
	end
end

function LogoScene:showBaili(...)
	local logoNode = display.newNode():addTo(self)
	logoNode:setCascadeOpacityEnabled(true)
	if GameConfig.environment == "tencent_muzhi" or GameConfig.environment == "tencent_muzhi_sjdz" 
		or GameConfig.environment == "tencent_muzhi_ly" or GameConfig.environment == "tencent_muzhi_hd" then
		local muzhiLogo = display.newSprite(IMAGE_COMMON .. "login/logo_muzhi.png", display.cx, display.cy):addTo(logoNode)
	elseif GameConfig.environment == "anfan_client" or GameConfig.environment == "anfanKoudai_client" or GameConfig.environment == "anfan_client_small" 
		or GameConfig.environment == "anfanaz_client" then
		local anfanLogo = display.newSprite(IMAGE_COMMON .. "login/logo_anfan.jpg", display.cx, display.cy):addTo(logoNode)
	elseif GameConfig.environment == "mzLzwz_appstore" or GameConfig.environment == "mztkjjylfc_appstore" then
		display.newSprite(IMAGE_COMMON .. "login/logo_muzhi.jpg", display.cx, display.cy):addTo(logoNode)
	else
		self:playEnd()
		return
	end

    local actions = transition.sequence({CCFadeIn:create(0.7), CCDelayTime:create(1.5), CCFadeOut:create(0.7), CCCallFunc:create(function() 
	        self:playEnd()
	    end)})
    logoNode:runAction(actions)
end

function LogoScene:onExit()
end

function LogoScene:playEnd()
    -- Enter.startNotice()
    LoginBO.initVersion()
    --草花IOS 血色坦克 调用IDFA
    local localVersion = LoginBO.getLocalApkVersion()
    if localVersion >= 269 and GameConfig.environment == "chxsjt_appstore" then
		LoginBO.asynDoIosIdfa()
	end

	
	if GameConfig.environment == "ch_appstore" then
		LoginBO.asynZhihuitui()
	end
    Enter.startUpdateApk()
end

return LogoScene