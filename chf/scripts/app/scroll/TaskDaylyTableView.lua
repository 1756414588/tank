--
-- Author: gf
-- Date: 2015-09-24 11:26:06
--
local ConfirmDialog = require("app.dialog.ConfirmDialog")
local TaskDaylyTableView = class("TaskDaylyTableView", TableView)

function TaskDaylyTableView:ctor(size)
	TaskDaylyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 150)
end

function TaskDaylyTableView:onEnter()
	TaskDaylyTableView.super.onEnter(self)
	self.acceptTaskStatus = false
   	self.getAwardTaskStatus = false
	self.m_updateListHandler = Notify.register(LOCAL_TASK_UPDATE_EVENT, handler(self, self.updateListHandler))
	self.m_updateListHandler1 = Notify.register(LOCAL_TASK_FINISH_EVENT, handler(self, self.updateListHandler))
end

function TaskDaylyTableView:numberOfCells()
	return #TaskMO.daylyTaskList_
end

function TaskDaylyTableView:cellSizeForIndex(index)
	
	return self.m_cellSize
end

function TaskDaylyTableView:createCellAtIndex(cell, index)
	TaskDaylyTableView.super.createCellAtIndex(self, cell, index)
		
	local task = TaskMO.daylyTaskList_[index]
	local taskInfo = TaskMO.queryTask(task.taskId)
	local taskBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(cell,-1)
	taskBg:setPreferredSize(cc.size(610, 140))
	taskBg:setCapInsets(cc.rect(80, 60, 1, 1))
	taskBg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local taskIcon = UiUtil.createItemView(ITEM_KIND_TASK, task.taskId)
	taskBg:addChild(taskIcon)
	taskIcon:setPosition(80,70)

	local taskName = ui.newTTFLabel({text = taskInfo.taskName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 115, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	taskName:setAnchorPoint(cc.p(0, 0.5))

	for index=1,taskInfo.taskStar do
		local starPic = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(taskBg)
		starPic:setScale(0.5)
		starPic:setPosition(160 + (index - 1) * 25,70)
	end

	local scheduleLab = ui.newTTFLabel({text = CommonText[676][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	scheduleLab:setAnchorPoint(cc.p(0, 0.5))
	scheduleLab:setVisible(task.accept == 1)

	local scheduleValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150 + scheduleLab:getContentSize().width, y = 35, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	scheduleValue:setAnchorPoint(cc.p(0, 0.5)) 
	if task.schedule >= taskInfo.schedule then
		scheduleValue:setString(CommonText[676][4])
	else
		scheduleValue:setString(task.schedule .. "/" .. taskInfo.schedule)
	end
	scheduleValue:setVisible(task.accept == 1)

	--详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDetailTask))
	detailBtn.task = task
	cell:addButton(detailBtn, self.m_cellSize.width - 230, taskBg:getPositionY() - 20)

	local normal,selected,goBtn
	if TaskBO.canGetDaylyTask() then
		normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		goBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onAcceptTask))
		goBtn:setLabel(CommonText[676][5])
		goBtn.task = task
	else
		if task.accept == 1 then
			if task.status == 0 then
				normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
				selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
				goBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onCoinGetTask))
				goBtn:setLabel(CommonText[676][6])
				goBtn.taskId = task.taskId
				goBtn.awardType = TASK_GET_AWARD_TYPE_GOLD
			else
				normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
				selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
				goBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.getAwardTask))
				goBtn:setLabel(CommonText[676][3])
				goBtn.taskId = task.taskId
				goBtn.awardType = TASK_GET_AWARD_TYPE_NOMAL
			end
		end
	end	
	if goBtn then
		cell:addButton(goBtn, self.m_cellSize.width - 100, taskBg:getPositionY() - 20)
	end
	

	return cell
end


function TaskDaylyTableView:onDetailTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.TaskDetailDialog").new(sender.task):push()
end

function TaskDaylyTableView:getAwardTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:getAwardTaskConfirm(sender.taskId,sender.awardType)
end

function TaskDaylyTableView:getAwardTaskConfirm(taskId,awardType)
	if self.getAwardTaskStatus == true then return end
	self.getAwardTaskStatus = true
	Loading.getInstance():show()
	TaskBO.asynTaskAward(function()
		Loading.getInstance():unshow()
		ManagerSound.playSound("task_done")
		end,TASK_TYPE_DAYLY,taskId,awardType)
end


function TaskDaylyTableView:onAcceptTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	--判断每日任务次数是否足够
	if TaskMO.taskDayiy.dayiy == TASK_DAYLY_COUNT then
		Toast.show(CommonText[680])
		return
	end
	if self.acceptTaskStatus == true then return end
	self.acceptTaskStatus = true
	Loading.getInstance():show()
	TaskBO.asynAcceptTask(function()
		
		Loading.getInstance():unshow()
		end,sender.task)
end

function TaskDaylyTableView:onCoinGetTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	function doCoinGet()
		--判断金币
		if UserMO.coin_ < TASK_DAYLY_QUICK_FINISH_COIN then
			require("app.dialog.CoinTipDialog").new():push()
		else
			self:getAwardTaskConfirm(sender.taskId,sender.awardType)
		end
	end
	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(CommonText[678], function()
			doCoinGet()
		end):push()
	else
		doCoinGet()
	end
end


function TaskDaylyTableView:cellTouched(cell, index)

end

function TaskDaylyTableView:updateListHandler(event)
	TaskBO.sortFun(TaskMO.daylyTaskList_,TASK_TYPE_DAYLY)
	local offset = self:getContentOffset()
   	self:reloadData()
   	self:setContentOffset(offset)
   	self.acceptTaskStatus = false
   	self.getAwardTaskStatus = false
end


function TaskDaylyTableView:onExit()
	TaskDaylyTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end

	if self.m_updateListHandler1 then
		Notify.unregister(self.m_updateListHandler1)
		self.m_updateListHandler1 = nil
	end
end



return TaskDaylyTableView