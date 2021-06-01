--
-- Author: gf
-- Date: 2015-09-24 18:13:59
--

local ConfirmDialog = require("app.dialog.ConfirmDialog")
local TaskLiveTableView = class("TaskLiveTableView", TableView)

function TaskLiveTableView:ctor(size)
	TaskLiveTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 150)
end

function TaskLiveTableView:onEnter()
	TaskLiveTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_TASK_UPDATE_EVENT, handler(self, self.updateListHandler))
	self.m_updateListHandler1 = Notify.register(LOCAL_TASK_FINISH_EVENT, handler(self, self.updateListHandler))
end

function TaskLiveTableView:numberOfCells()
	return #TaskMO.liveTaskList_
end

function TaskLiveTableView:cellSizeForIndex(index)
	
	return self.m_cellSize
end

function TaskLiveTableView:createCellAtIndex(cell, index)
	TaskLiveTableView.super.createCellAtIndex(self, cell, index)
		
	local task = TaskMO.liveTaskList_[index]
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


	local liveLab = ui.newTTFLabel({text = CommonText[685], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 65, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	liveLab:setAnchorPoint(cc.p(0, 0.5))

	local liveValue = ui.newTTFLabel({text = "+" .. taskInfo.live, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = liveLab:getPositionX() + liveLab:getContentSize().width, y = 65, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	liveValue:setAnchorPoint(cc.p(0, 0.5))


	local scheduleLab = ui.newTTFLabel({text = CommonText[676][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	scheduleLab:setAnchorPoint(cc.p(0, 0.5))


	local scheduleValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150 + scheduleLab:getContentSize().width, y = 35, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	scheduleValue:setAnchorPoint(cc.p(0, 0.5)) 
	if task.schedule >= taskInfo.schedule then
		scheduleValue:setString(CommonText[676][4])
	else
		scheduleValue:setString(task.schedule .. "/" .. taskInfo.schedule)
	end
	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local goBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onGoTask))
	goBtn:setLabel(CommonText[676][2])
	goBtn.taskInfo = taskInfo
	cell:addButton(goBtn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 20)
	

	return cell
end

function TaskLiveTableView:onGoTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	TaskBO.goToTaskDo(sender.taskInfo)
end


function TaskLiveTableView:onDetailTask(tag, sender)
	-- require("app.dialog.TaskDetailDialog").new(sender.task):push()
end




function TaskLiveTableView:cellTouched(cell, index)

end

function TaskLiveTableView:updateListHandler(event)
	TaskBO.sortFun(TaskMO.daylyTaskList_,TASK_TYPE_DAYLY)
	local offset = self:getContentOffset()
   	self:reloadData()
   	self:setContentOffset(offset)
end


function TaskLiveTableView:onExit()
	TaskLiveTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end

	if self.m_updateListHandler1 then
		Notify.unregister(self.m_updateListHandler1)
		self.m_updateListHandler1 = nil
	end
end



return TaskLiveTableView