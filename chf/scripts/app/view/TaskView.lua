--
-- Author: gf
-- Date: 2015-09-23 10:15:49
--

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local TaskView = class("TaskView", UiNode)

function TaskView:ctor(viewFor)
	TaskView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_viewFor = viewFor or 1
end

function TaskView:onEnter()
	TaskView.super.onEnter(self)

	self.m_updateDaylyTaskHandler = Notify.register(LOCAL_DAYLY_TASK_UPDATE_EVENT, handler(self, self.reloadContainer))
	self.m_taskTipHandler = Notify.register(LOCAL_TASK_FINISH_EVENT, handler(self, self.updateTip))

	self:setTitle(CommonText[683])
	self:hasCoinButton(true)
	
	local function createDelegate(container, index)
		if index == 1 then  -- 主线
			self:showMajorTask(container)
		elseif index == 2 then -- 日常
			self:showDaylyTask(container)
		else --活跃
			self:showLiveTask(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local page
	if UserMO.queryFuncOpen(UFP_NEW_ACTIVE) then
		pages = {CommonText[674][1],CommonText[674][2]}
	else
		pages = {CommonText[674][1],CommonText[674][2],CommonText[674][3]}
	end
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self:updateTip()

	if UserMO.level_ <= 30 then
		self:showGirl(size)
	end
end

function TaskView:showGirl(size)

	local girl = display.newSprite(IMAGE_COMMON .. "refine_secret2.png"):addTo(self, 5)
	girl:setAnchorPoint(cc.p(1,0))
	girl:setPosition(GAME_SIZE_WIDTH, size.height + 34 - girl:height() * 0.5)
	girl:setRotation(90)

	local showbag = display.newScale9Sprite("image/skin/chat/r_chatBg_bubble_6.png"):addTo(self, 5)
	showbag:setPreferredSize(cc.size(showbag:width() + 50, showbag:height()))
	-- showbag:setCapInsets(cc.rect(80, 60, 1, 1))
	showbag:setScale(0)
	showbag:setAnchorPoint(1,0.5)
	showbag:setPosition(GAME_SIZE_WIDTH - girl:width() + 10, girl:y() + girl:height() * 0.5)

	local lb = ui.newTTFLabel({text = CommonText[1804], font = G_FONT, size = FONT_SIZE_TINY, 
		x = showbag:width()*0.5 + 5 , y = showbag:height() * 0.5 - 10, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(showbag)
	
	local function overAction()
		girl:removeSelf()
		showbag:removeSelf()
	end

	local function endAction()
		showbag:runAction(transition.sequence({cc.ScaleTo:create(0.2,1),cc.DelayTime:create(1), cc.CallFunc:create(overAction)}))
	end

	girl:runAction(transition.sequence({cc.DelayTime:create(0.5), CCRotateTo:create(0.3,0), cc.CallFunc:create(endAction)}))

end

function TaskView:updateTip()
	for index=1,TASK_TYPE_DAYLY do
		local finishTasks = TaskBO.getAllFinishTask(index)
		if finishTasks > 0 then
			UiUtil.showTip(self.m_pageView.m_yesButtons[index], finishTasks, 142, 50)
			UiUtil.showTip(self.m_pageView.m_noButtons[index], finishTasks, 135, 37)
		else
			UiUtil.unshowTip(self.m_pageView.m_yesButtons[index])
			UiUtil.unshowTip(self.m_pageView.m_noButtons[index])
		end
	end
end

function TaskView:showMajorTask(container)
	local TaskMajorTableView = require("app.scroll.TaskMajorTableView")
	local view = TaskMajorTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4)):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function TaskView:showDaylyTask(container)
	-- --测试
	-- TaskMO.daylyTaskList_ = {
	-- 	{taskId = 4001,schedule = 0, status = 0,accept = 1},
	-- 	{taskId = 4006,schedule = 0, status = 0,accept = 0},
	-- 	{taskId = 4011,schedule = 0, status = 0,accept = 0},
	-- 	{taskId = 4016,schedule = 0, status = 0,accept = 0},
	-- 	{taskId = 4025,schedule = 0, status = 0,accept = 0}
	-- }
	-- TaskMO.taskDayiy = {dayiy = 1,dayiyCount = 0}

	local TaskDaylyTableView = require("app.scroll.TaskDaylyTableView")
	local view = TaskDaylyTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 120 - 4)):addTo(container)
	view:setPosition(0, 120)
	view:reloadData()

	--剩余每日任务次数
	local countLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = container:getContentSize().width / 2 - 150, y = 90, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	if TaskMO.taskDayiy.dayiy then
		countLab:setString(string.format(CommonText[677][3],TaskMO.taskDayiy.dayiy,TASK_DAYLY_COUNT))
	end
	self.m_daylyCountLab = countLab

	--有几率刷出5星任务
	local refreshLab = ui.newTTFLabel({text = CommonText[677][4], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = container:getContentSize().width / 2 + 150, y = 90, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)

	--放弃按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local giveUpBtn = MenuButton.new(normal, selected, disabled, handler(self,self.giveUpHandler)):addTo(container)
	giveUpBtn:setLabel(CommonText[677][1])
	giveUpBtn:setEnabled(TaskBO.canGetDaylyTask() == false)
	giveUpBtn:setPosition(container:getContentSize().width / 2 - 150,30)
	self.m_giveUpBtn = giveUpBtn

	local normal,selected,disabled,refreshBtn,coinPic,coinValue
	if TaskMO.taskDayiy.dayiy < TASK_DAYLY_COUNT then
		--刷新
		normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
		selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
		disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
		refreshBtn = MenuButton.new(normal, selected, disabled, handler(self,self.reFreshHandler)):addTo(container)
		refreshBtn:setLabel(CommonText[677][2])
		refreshBtn:getLabel():setPosition(refreshBtn:getLabel():getPositionX() - 20,refreshBtn:getLabel():getPositionY())
		refreshBtn:setPosition(container:getContentSize().width / 2 + 150,30)

		coinPic = UiUtil.createItemSprite(ITEM_KIND_COIN)
		refreshBtn:addChild(coinPic)
		coinPic:setPosition(refreshBtn:getContentSize().width / 2 + 20,refreshBtn:getContentSize().height / 2)
		coinValue = ui.newTTFLabel({text = TASK_DAYLY_REFRESH_COIN, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = coinPic:getPositionX() + coinPic:getContentSize().width, y = coinPic:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(refreshBtn)
		coinValue:setAnchorPoint(cc.p(0, 0.5))
		refreshBtn:setEnabled(TaskBO.canGetDaylyTask())
	else
		--重置
		normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
		selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
		disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
		refreshBtn = MenuButton.new(normal, selected, disabled, handler(self,self.resetHandler)):addTo(container)
		refreshBtn:setLabel(CommonText[677][5])
		refreshBtn:getLabel():setPosition(refreshBtn:getLabel():getPositionX() - 20,refreshBtn:getLabel():getPositionY())
		refreshBtn:setPosition(container:getContentSize().width / 2 + 150,30)

		coinPic = UiUtil.createItemSprite(ITEM_KIND_COIN)
		refreshBtn:addChild(coinPic)
		coinPic:setPosition(refreshBtn:getContentSize().width / 2 + 20,refreshBtn:getContentSize().height / 2)
		coinValue = ui.newTTFLabel({text = TASK_DAYLY_RESET_COIN, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = coinPic:getPositionX() + coinPic:getContentSize().width, y = coinPic:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(refreshBtn)
		coinValue:setAnchorPoint(cc.p(0, 0.5))
		refreshBtn:setEnabled(TaskMO.taskDayiy.dayiyCount < VipMO.queryVip(UserMO.vip_).resetDaily)
	end
	self.m_refreshBtn = refreshBtn
	
end

function TaskView:showLiveTask(container)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:getContentSize().width - 40, 120))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - bg:getContentSize().height / 2 - 30)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		bg:getContentSize().width / 2, bg:getContentSize().height):addTo(bg)

	local titLab = ui.newTTFLabel({text = CommonText[686][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	local cueLab = ui.newTTFLabel({text = CommonText[686][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = 80, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	cueLab:setAnchorPoint(cc.p(0, 0.5))

	--进度条
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(bg)
	bar:setPosition(30 + bar:getContentSize().width / 2, 40)
	-- bar.label = ui.newTTFLabel({text = science.schedule .. "/" .. scienceLvData.schedule, font = G_FONT, size = FONT_SIZE_SMALL, x = bar:getContentSize().width/2, y = bar:getContentSize().height/2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
	local nextLive = TaskMO.queryNextTaskLive(TaskMO.taskLive.liveAward)
	if nextLive then
		bar:setLabel(TaskMO.taskLive.live .. "/" .. nextLive.live)
		bar:setPercent(TaskMO.taskLive.live / nextLive.live)
	else
		bar:setLabel("-")
		bar:setPercent(0)
	end
	
	--详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	detailBtn = MenuButton.new(normal, selected, nil, handler(self,self.detailLiveHandler)):addTo(bg)
	detailBtn:setPosition(bg:getContentSize().width - 200,50)

	--领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	getAwardBtn = MenuButton.new(normal, selected, disabled, handler(self,self.getLiveAwardHandler)):addTo(bg)
	getAwardBtn:setPosition(bg:getContentSize().width - 80,50)
	if nextLive then
		getAwardBtn:setEnabled(TaskMO.taskLive.live >= nextLive.live)
	else
		getAwardBtn:setEnabled(false)
	end
	
	
	if nextLive and TaskMO.taskLive.live >= nextLive.live then
		getAwardBtn:setLabel(CommonText[687][2])
	else
		getAwardBtn:setLabel(CommonText[687][1])
	end

	local TaskLiveTableView = require("app.scroll.TaskLiveTableView")
	local view = TaskLiveTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 160 - 4)):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function TaskView:getLiveAwardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	TaskBO.asynTaskLiveAward(function()
		Loading.getInstance():unshow()
		self:reloadContainer()
		end)
end

function TaskView:detailLiveHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.TaskLiveAwardDialog").new():push()
end

function TaskView:giveUpHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	TaskBO.asynAcceptNoTask(function()
		Loading.getInstance():unshow()
		end)
end

function TaskView:reFreshHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local coin = TASK_DAYLY_REFRESH_COIN

	function doRefresh()
		--判断金币
		if UserMO.coin_ < coin then
			require("app.dialog.CoinTipDialog").new():push()
		else
			Loading.getInstance():show()
			TaskBO.asynRefreshDayiyTask(function()
				Loading.getInstance():unshow()
				self:reloadContainer()
				end)
		end
	end
	if UserMO.consumeConfirm then
		CoinConfirmDialog.new(string.format(CommonText[681],coin), function()
			doRefresh()
		end):push()
	else
		doRefresh()
	end
end

function TaskView:resetHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local coin = TASK_DAYLY_RESET_COIN

	function doReset()
		--判断金币
		if UserMO.coin_ < coin then
			require("app.dialog.CoinTipDialog").new():push()
		else
			Loading.getInstance():show()
			TaskBO.asynTaskDaylyReset(function()
				Loading.getInstance():unshow()
				self:reloadContainer()
				end)
		end
	end
	if UserMO.consumeConfirm then
		CoinConfirmDialog.new(string.format(CommonText[682],coin), function()
				doReset()
			end):push()
	else
		doReset()
	end
end


function TaskView:reloadContainer()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	-- if self.m_pageView:getPageIndex() == 2 then
	-- 	-- self.m_daylyCountLab:setString(string.format(CommonText[677][3],TaskMO.taskDayiy.dayiy,TASK_DAYLY_COUNT))
	-- 	-- self.m_giveUpBtn:setEnabled(TaskBO.canGetDaylyTask() == false)
	-- 	-- if TaskMO.taskDayiy.dayiy < TASK_DAYLY_COUNT then
	-- 	-- 	self.m_refreshBtn:setEnabled(TaskBO.canGetDaylyTask())
	-- 	-- else
	-- 	-- 	self.m_refreshBtn:setEnabled(TaskMO.taskDayiy.dayiyCount < VipMO.queryVip(UserMO.vip_).resetDaily)
	-- 	-- end
	-- 	self.m_pageView:reloadContainer(2)
	-- end
end


function TaskView:onExit()
	TaskView.super.onExit(self)
	if self.m_updateDaylyTaskHandler then
		Notify.unregister(self.m_updateDaylyTaskHandler)
		self.m_updateDaylyTaskHandler = nil
	end
	if self.m_taskTipHandler then
		Notify.unregister(self.m_taskTipHandler)
		self.m_taskTipHandler = nil
	end
end

function TaskView:doCommand(command, callback)
	if command == "task_daily" then
		if self.m_pageView then self.m_pageView:setPageIndex(2) end
		if callback then callback() end
	end
end

return TaskView