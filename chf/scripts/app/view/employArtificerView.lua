--
-- Author: wangzhen
-- Date: 2017-04-21 10:15:49
--

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local employArtificerView = class("employArtificerView", UiNode)

function employArtificerView:ctor(buildingId)
	employArtificerView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function employArtificerView:onEnter()
	employArtificerView.super.onEnter(self)

	self:setTitle(CommonText[1605][1])
	self:hasCoinButton(true)	
	--self.container = self:getBg()
	self:showLiveTask()

	self.m_updateDaylyTaskHandler = Notify.register(LOCAL_WEAPONRY_EMPLOY, handler(self, self.showLiveTask))
	self.m_tickTimer = ManagerTimer.addTickListener(handler(self, self.onTick))
end

function employArtificerView:onTick(dt)
	if self.cdTime then   --倒计时
		local left =  WeaponryBO.employEndtime - ManagerTimer.getTime()
		if left <= 0 then
			left = 0
		end
		--local timeLable = string.format("%02d:%02d:%02d",math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
		-- if math.floor(left / (3600*24)) >= 1 then
		-- 	timeLable = string.format("%02dd:%02dh:%02dm:%02ds",math.floor(left / (3600*24)) ,math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
		-- end
	    self.cdTime:setString(UiUtil.strBuildTime(left))
	end
end


function employArtificerView:showLiveTask()
	-- if self.container then
	-- 	self.container:removeAllChildren()
	-- 	self.container = nil
	-- end 
	container = self:getBg()
	self.container = container
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	bg:setPreferredSize(cc.size(614, 230))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - bg:getContentSize().height / 2 - 110)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		bg:getContentSize().width / 2, bg:getContentSize().height ):addTo(bg)

	local titLab = ui.newTTFLabel({text = CommonText[1605][4], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	local cueLab = ui.newTTFLabel({text = CommonText[1605][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = bg:getContentSize().height - 40, 50, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	cueLab:setAnchorPoint(cc.p(0, 0.5))

	local taskBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(bg,2)
	taskBg:setPreferredSize(cc.size(610, 140))
	taskBg:setCapInsets(cc.rect(80, 60, 1, 1))
	taskBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 20 )

	if WeaponryBO.currEmployId ~= 0 then
		local taskInfo = WeaponryMO.getEmployById(WeaponryBO.currEmployId) 
		local taskIcon = UiUtil.createItemView(ITEM_KIND_WEAPONRY_EMPLOY, taskInfo.id)
		taskBg:addChild(taskIcon)
		taskIcon:setPosition(80,70)
		local taskName = ui.newTTFLabel({text = taskInfo.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 150, y = 115, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
		taskName:setAnchorPoint(cc.p(0, 0.5))
		local liveLab = ui.newTTFLabel({text = CommonText[1607][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 65, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
		liveLab:setAnchorPoint(cc.p(0, 0.5))

		local liveValue = ui.newTTFLabel({text = (taskInfo.timeDown/3600) .. CommonText[159][3] , font = G_FONT, size = FONT_SIZE_SMALL, 
			x = liveLab:getPositionX() + liveLab:getContentSize().width, y = 65, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
		liveValue:setAnchorPoint(cc.p(0, 0.5))

		local scheduleLab = ui.newTTFLabel({text = CommonText[1609], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
		scheduleLab:setAnchorPoint(cc.p(0, 0.5))
		--倒计时
		local liveLab = ui.newTTFLabel({text = CommonText[853]  , font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 380, y = 115, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
		liveValue:setAnchorPoint(cc.p(0, 0.5))
		local cdTime = ui.newTTFLabel({text = UiUtil.strBuildTime(WeaponryBO.employEndtime - ManagerTimer.getTime()), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = liveLab:getPositionX() + liveLab:getContentSize().width + 20, y = 115, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
		liveValue:setAnchorPoint(cc.p(0, 0.5))

		self.cdTime = cdTime
	else
		-- local taskIcon = display.newSprite(IMAGE_COMMON .. "item_bg_0.png"):addTo(taskBg)
		-- taskIcon:setPosition(80,70)
		local taskName = ui.newTTFLabel({text = CommonText[1607][3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 248, y = 70, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
		taskName:setAnchorPoint(cc.p(0, 0.5))

		local scheduleLab = ui.newTTFLabel({text = CommonText[1609], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 90, y = 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
		scheduleLab:setAnchorPoint(cc.p(0, 0.5))
	end

	if self.tableView  then
		self.tableView:removeAllChildren()
		self.tableView = nil
	end

	local TaskLiveTableView = require("app.scroll.employTableView")
	local view = TaskLiveTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 360 - 4)):addTo(container)
	view:setPosition(0, 20)
	view:reloadData()
	self.tableView = view
end

function employArtificerView:onExit()
	employArtificerView.super.onExit(self)

	if self.m_tickTimer then
		ManagerTimer.removeTickListener(self.m_tickTimer)
		self.m_tickTimer = nil
	end	
	if self.m_updateDaylyTaskHandler then
		Notify.unregister(self.m_updateDaylyTaskHandler)
		self.m_updateDaylyTaskHandler = nil
	end
end


return employArtificerView