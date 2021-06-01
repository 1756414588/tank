
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- ui.newTTFLabel({text = "Hello, World", size = 64, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(display.cx, display.cy)
    --     :addTo(self)
end

function MainScene:onEnter()
	local g_require = _G.require
	function require(modname)
		if GameConfig.debug and (string.find(modname,"app.dialog") == 1 or string.find(modname,"app.scroll") 
			or string.find(modname,"app.view")) then
			package.loaded[modname] = nil
			package.preload[modname] = nil
		end
		return g_require(modname)
	end
	PictureValidateBO.getScoutInfo(function ()
	end)
	-- 这里主动拉取一下活动是否结束的状态
	RoyaleSurviveBO.getHonourStatus()
	HeroBO.getHeroCd()
	HeroBO.getHeroEndTime()
	WorldBO.getWorldStaffing()
	require("app.view.HomeView").new():push()
	Pinging.GetInstance():Init()
	-- UiDirector.push()
	-- UiDirector.push(require("app.view.HomeView").new())
end

function MainScene:onExit()
	ManagerTimer.destroy()
	SchedulerSet.destroy()
	Pinging.GetInstance():Destory()
end

return MainScene
