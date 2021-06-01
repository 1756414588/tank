--
-- Author: Your Name
-- Date: 2017-06-19 10:02:18
--
-----------------------------------------------------------------------------------------------
local NewActiveAwardsTableView = class("NewActiveAwardsTableView", TableView)

function NewActiveAwardsTableView:ctor(size,data)
	NewActiveAwardsTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_cellSize = cc.size(90,self:getViewSize().height)
	self.m_data = data
end

function NewActiveAwardsTableView:onEnter()
	NewActiveAwardsTableView.super.onEnter(self)
	armature_add("animation/effect/clds_gaoji_tx.pvr.ccz", "animation/effect/clds_gaoji_tx.plist", "animation/effect/clds_gaoji_tx.xml")
end

function NewActiveAwardsTableView:onExit()
	NewActiveAwardsTableView.super.onExit(self)
end

function NewActiveAwardsTableView:numberOfCells()
	return #self.m_data
end

function NewActiveAwardsTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function NewActiveAwardsTableView:createCellAtIndex(cell, index)
	NewActiveAwardsTableView.super.createCellAtIndex(self, cell, index)
		local state = TaskMO.taskActiveStatus_[index]
		local boxBg = display.newSprite(IMAGE_COMMON.."new_active_boxbg.jpg"):addTo(cell)
		boxBg:setPosition(self.m_cellSize.width / 2,self.m_cellSize.height / 2)
		local liveNum = UiUtil.label(self.m_data[index].live,FONT_SIZE_TINY):addTo(boxBg):align(display.LEFT_CENTER,20,20)
		local box,box1
		if state == 0 then
			box = display.newSprite(IMAGE_COMMON.."new_active_normal"..self.m_data[index].map..".png")
			box1 = display.newSprite(IMAGE_COMMON.."new_active_normal"..self.m_data[index].map..".png")
		elseif state == 1 then
			box = display.newSprite(IMAGE_COMMON.."new_active_normal"..self.m_data[index].map..".png")
			box1 = display.newSprite(IMAGE_COMMON.."new_active_normal"..self.m_data[index].map..".png")
		else
			box = display.newSprite(IMAGE_COMMON.."new_active_open"..self.m_data[index].map..".png")
			box1 = display.newSprite(IMAGE_COMMON.."new_active_open"..self.m_data[index].map..".png")
		end
		box1:setScale(0.9)
		-- local boxBtn = ScaleButton.new(box, handler(self, self.getAwardHandler)):addTo(cell)
		local boxBtn = CellMenuButton.new(box, box1, nil, handler(self, self.getAwardHandler))
		cell:addButton(boxBtn)
		boxBtn.live = self.m_data[index].live
		boxBtn.state = state
		boxBtn:setPosition(boxBg:getPositionX(),boxBg:getPositionY() + 10)
		if state == 1 then
			local lightEffect = armature_create("clds_gaoji_tx", boxBtn:getContentSize().width / 2, boxBtn:getContentSize().height / 2)
	        lightEffect:getAnimation():playWithIndex(0)
	        lightEffect:setScale(0.4)
	        boxBtn:addChild(lightEffect, -1)
		end

	return cell
end

function NewActiveAwardsTableView:getAwardHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local state = sender.state
	local live = sender.live
	if state == 0 then
		require("app.dialog.TaskLiveAwardDialog").new():push()
	elseif state == 1 then
		TaskBO.asynNewTaskLiveAward(function ()
			local offset = self:getContentOffset()
			self:reloadData()
			self:setContentOffset(offset)
		end,live)
	else
		Toast.show(CommonText[747])
	end
end

function NewActiveAwardsTableView:onExit()
	NewActiveAwardsTableView.super.onExit(self)
	armature_remove("animation/effect/clds_gaoji_tx.pvr.ccz", "animation/effect/clds_gaoji_tx.plist", "animation/effect/clds_gaoji_tx.xml")
end
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--新活跃度玩法
local ActivityNewActiveView  =class("ActivityNewActiveView", UiNode)

function ActivityNewActiveView:ctor(pageIndex)
	ActivityNewActiveView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	
	self.pageIndex_ = pageIndex
	self.isStateChange = true
	if not self.pageIndex_ then self.pageIndex_ = 1 end
end

function ActivityNewActiveView:onEnter()
	ActivityNewActiveView.super.onEnter(self)
	self:setTitle(CommonText[100008])
	local function createDelegate(container, index)
		self.m_timeLab = nil
		if index == 1 then  
			self:showTask(container,index)
		elseif index == 2 then 
			self:showTask(container,index)
		elseif index == 3 then
			self:showTask(container,index)
		elseif index == 4 then
			self:showTask(container,index)
		end
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[100014][1],CommonText[100014][2],CommonText[100014][3],CommonText[100014][4]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.pageIndex_)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	if self.tick_ then
		self:stopAction(self.tick_)
		self.tick_ = nil
	end

	self.tick_ = self:schedule(handler(self, self.update), 1)
end

function ActivityNewActiveView:showTask(container,index)
	local task = TaskMO.getLiveTaskInfo()
	local taskInfo = TaskMO.getTypeByID(index)
	local page = {}
	if index == 1 then
		page = CommonText[100000]
	elseif index == 2 then
		page = CommonText[100001]
	elseif index == 3 then
		page = CommonText[100002]
	elseif index == 4 then
		page = CommonText[100003]
	end
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:width() - 10, 700))
	bg:setPosition(container:width()/2, container:height() - bg:height() / 2 - 20)

	local awardBg = UiUtil.sprite9("info_bg_82.png", 60,50,14,13,container:width() - 20,300):addTo(container)
	awardBg:setPosition(container:width() / 2,container:height() - awardBg:height() / 2 - 25)

	local awardList = TaskMO.getNewTaskLiveList()
	-- 奖励列表滚动区
	local view = NewActiveAwardsTableView.new(cc.size(awardBg:getContentSize().width - 100, 90),awardList):addTo(awardBg)
	view:setPosition(50,awardBg:height() - 120)
	view:reloadData()
	self.itemView = view

	--进度条
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_10.jpg", BAR_DIRECTION_HORIZONTAL, cc.size(480, 12), {bgName = IMAGE_COMMON .. "bar_bg_12.png", bgScale9Size = cc.size(480+ 4, 15)}):addTo(awardBg)
	bar:setPosition(60,160)
	bar:setAnchorPoint(cc.p(0,0.5))
	bar:setPercent(TaskMO.taskLive.live / awardList[#awardList].live)
	local liveness = UiUtil.label(TaskMO.taskLive.live.."/"..awardList[#awardList].live,FONT_SIZE_TINY,COLOR[1]):addTo(bar,99):center()
	self.endtime = UiUtil.label("",FONT_SIZE_TINY,COLOR[1]):addTo(awardBg,99):align(display.LEFT_CENTER,awardBg:width() / 2 - 20 ,bar:getPositionY() - 30)
	--当前活跃描述
	local tipBg = display.newSprite(IMAGE_COMMON.."new_active_tipbg.jpg"):addTo(awardBg)
	tipBg:setPosition(awardBg:width() / 2,bar:getPositionY() - tipBg:height() / 2 -20)
	--进度
	local clipping = cc.ClippingNode:create()
	clipping:setPosition(91 / 2 + 10,tipBg:height() / 2)
	local oilBar = ProgressBar.new(IMAGE_COMMON .. "bar_13.png", BAR_DIRECTION_CIRCLE)
	oilBar:setPercent(TaskMO.taskLive.live / awardList[#awardList].live)
	self.m_upgradeBar = oilBar
	local mask = display.newSprite(IMAGE_COMMON.."bar_bg_13.png")
	clipping:setInverted(false)
	clipping:setAlphaThreshold(0.0)
	clipping:setStencil(mask)
	clipping:addChild(oilBar)
	clipping:addTo(tipBg)

	local path = "animation/effect/huoyuedu_lizi.plist"
    local particleSys = cc.ParticleSystemQuad:create(path)

	local yOff = (oilBar:getPercent() - 0.5) * 91
	particleSys:setPosition(oilBar:getPositionX(),yOff + 5)
	particleSys:addTo(clipping)
	local active = display.newSprite(IMAGE_COMMON.."active_item.png"):addTo(tipBg)
	active:setPosition(active:width() / 2 + 20,tipBg:height() / 2)
	--当前任务进度描述
	local function getStage()
		for liveNum = 2,#awardList do
			if TaskMO.taskLive.live <= awardList[liveNum].live and TaskMO.taskLive.live > awardList[liveNum - 1].live then
				return liveNum - 1
			elseif TaskMO.taskLive.live >= awardList[#awardList].live then
				return 8
			end
		end
		return 1
	end
	local stage = getStage()
	local prodesc = UiUtil.label(string.format(CommonText[100007],stage,#awardList - stage),FONT_SIZE_TINY,COLOR[1],cc.size(300,0),ui.TEXT_ALIGN_LEFT):addTo(tipBg):align(display.LEFT_CENTER,130,tipBg:height() / 2)
	--任务线
	local line = display.newSprite(IMAGE_COMMON.."new_active_line.png"):addTo(awardBg)
	line:setPosition(awardBg:width() / 2,tipBg:getPositionY() - tipBg:height() + 30)
	--任务分枝
	for idx =1,#taskInfo do
		local taskBg = UiUtil.sprite9("info_bg_91.png", 60,50,14,13,(bg:width() - 10) / 4,360):addTo(bg)
		taskBg:setPosition(taskBg:width() / 2 + (idx - 1) *taskBg:width(),taskBg:height() / 2 + 20)
		local taskName = UiUtil.label(page[idx],FONT_SIZE_TINY,COLOR[1]):addTo(taskBg):align(display.LEFT_CENTER,25,taskBg:height()-45)
		local finish = UiUtil.label("",FONT_SIZE_TINY,COLOR[2]):rightTo(taskName)
		local progress = UiUtil.label("/"..#taskInfo[idx],FONT_SIZE_TINY,COLOR[1]):rightTo(finish,10)
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(taskBg)
		line:setPreferredSize(cc.size(taskBg:width() - 40, line:getContentSize().height))
		line:setPosition(taskBg:width() / 2,taskName:getPositionY() - 15)

		local normal = display.newSprite(IMAGE_COMMON .. "new_active_task"..index.."_"..idx.."_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "new_active_task"..index.."_"..idx.."_selected.png")
		local detailBtn = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound();
			 require("app.dialog.DetailTextDialog").new(DetailText.NewActiveInfo[index][idx]):push() 
			 end):addTo(taskBg)
		detailBtn:setPosition(taskBg:width() / 2,detailBtn:height() + 20)
		local finiNum = 0
		for i=1,#taskInfo[idx] do
			local taskId = taskInfo[idx][i].taskId
			local schedule = TaskMO.queryNewTask(taskId).schedule
			local mySchedele = TaskMO.getActiveById(taskId)
			local num = UiUtil.label(i,FONT_SIZE_TINY,COLOR[1]):addTo(taskBg):align(display.LEFT_CENTER,20,taskBg:height()-85 - (i - 1) * 30)
			local now = UiUtil.label(UiUtil.strNumSimplify(mySchedele),15,COLOR[6]):addTo(taskBg)
			now:setPosition(taskBg:width() / 2,taskBg:height()- 70 - (i - 1) * 30)
			local taskNum = UiUtil.label("/"..UiUtil.strNumSimplify(schedule),15,COLOR[1]):addTo(taskBg):rightTo(now)
			local indexBar = ProgressBar.new(IMAGE_COMMON .. "bar_12.png", BAR_DIRECTION_HORIZONTAL, cc.size(90, 5), {bgName = IMAGE_COMMON .. "bar_bg_12.png", bgScale9Size = cc.size(90 + 4, 6)}):addTo(taskBg):rightTo(num,5)
			indexBar:setPercent(mySchedele / schedule)
			if mySchedele >= schedule then
				finiNum = finiNum + 1
				if index == 4 then
					now:setString(UiUtil.strNumSimplify(mySchedele))
				else
					now:setString(UiUtil.strNumSimplify(schedule))
				end
				now:setColor(COLOR[2])
			end
		end
		finish:setString(finiNum)
		--前往
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local goBtn = MenuButton.new(normal, selected, nil, function ()
			TaskBO.goToTaskDo(taskInfo[idx][1])
		end):addTo(bg)
		goBtn:setPosition(taskBg:getPositionX(),goBtn:height() / 2)
		goBtn:setLabel(CommonText[20139])
	end

	--特殊写死，第四类任务只有三条数据，
	if index == 4 then
		local unuseBg = UiUtil.sprite9("info_bg_91.png", 60,50,14,13,(bg:width() - 10) / 4,360):addTo(bg)
		unuseBg:setPosition(unuseBg:width() / 2 + (4 - 1) *unuseBg:width(),unuseBg:height() / 2 + 20)

		local noImg = display.newSprite(IMAGE_COMMON .. "coming_soon.png"):addTo(unuseBg):pos(unuseBg:getContentSize().width/2, unuseBg:getContentSize().height/2)
		-- noImg:setScale(0.5)

		-- local lb = UiUtil.label(CommonText[20052], 20, COLOR[2]):addTo(unuseBg):pos(unuseBg:getContentSize().width/2, 100)
	end
	--结算desc
	local desc = UiUtil.label(CommonText[100006][1],FONT_SIZE_TINY,COLOR[1]):addTo(container):align(display.LEFT_CENTER,60,container:height() - bg:height() - 40)
	local descNex = UiUtil.label(CommonText[100006][2],FONT_SIZE_TINY,COLOR[1]):addTo(container):align(display.LEFT_CENTER,60,container:height() - bg:height() - 60)
	self:update()
end

--倒计时
function ActivityNewActiveView:update()
	local leftTime = TaskMO.taskActiveEndTime_ - ManagerTimer.getTime()
	if leftTime > 0 then
		self.isStateChange = true
		local t = ManagerTimer.getTime()
		local week = tonumber(os.date("%w",t))
		local h = tonumber(os.date("%H", t))
		if h >= 12 and h < 13 and week == 1 then
			self.endtime:setString(CommonText[100005])
		else
			self.endtime:setString(CommonText[100004] .. UiUtil.strActivityTime(leftTime))
		end
	else
		if self.isStateChange then
			TaskBO.asynNewGetLiveTask(function ()
				self:refreshUI()
			end)
		end
		self.isStateChange = false
	end
end

function ActivityNewActiveView:refreshUI()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

function ActivityNewActiveView:onExit()
	ActivityNewActiveView.super.onExit(self)

	Notify.notify(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT)
end

return ActivityNewActiveView