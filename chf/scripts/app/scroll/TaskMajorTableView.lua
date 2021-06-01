--
-- Author: gf
-- Date: 2015-09-23 10:20:34
--


local TaskMajorTableView = class("TaskMajorTableView", TableView)


function TaskMajorTableView:ctor(size)
	TaskMajorTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
end

function TaskMajorTableView:onEnter()
	TaskMajorTableView.super.onEnter(self)
	self.taskAcceptStatus = false
	self.m_updateListHandler = Notify.register(LOCAL_TASK_UPDATE_EVENT, handler(self, self.updateListHandler))
	self.m_updateListHandler1 = Notify.register(LOCAL_TASK_FINISH_EVENT, handler(self, self.updateListHandler))
	TaskBO.sortFun(TaskMO.majorTaskList_,TASK_TYPE_MAJOR)
	self:updateFinashTaskList()
end

function TaskMajorTableView:updateFinashTaskList()
	self.AllList = {}
	local _finashList = {}
	for _lindex = 1 , 3 do
		local out = {}
		local _list = TaskBO.getTaskByChildType(_lindex)
		for _iindex = 1 , #_list do
			local task = _list[_iindex]
			if task.status == 0 then
				out[#out + 1] = task
			else
				_finashList[#_finashList + 1] = task
			end
		end
		self.AllList[#self.AllList + 1] = out
	end

	if #_finashList > 0 then
		table.insert(self.AllList, 1, _finashList)
	end
end

function TaskMajorTableView:numberOfCells()
	return #self.AllList
end

function TaskMajorTableView:cellSizeForIndex(index)
	local _dexHeight = 60
	if self:numberOfCells() == 4 and index == 1 then _dexHeight = 30 end
	local taskList = self.AllList[index]
	local height = #taskList * 160 + _dexHeight

	self.m_cellSize = cc.size(self:getViewSize().width, height)

	return self.m_cellSize
end

function TaskMajorTableView:createCellAtIndex(cell, index)
	TaskMajorTableView.super.createCellAtIndex(self, cell, index)
	local size = self:cellSizeForIndex(index)
	local count = self:numberOfCells()
	local taskList = self.AllList[index]

	local _heightDex = 30
	local _heightSizeDex = 30
	local _index = index
	if count == 4 then
		if index == 1 then
			_heightDex = 15
			_heightSizeDex = 0
		else
			_index = index - 1
		end
	end

	local bg
	if  #taskList > 0 then
		bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(610, size.height - _heightSizeDex))
		bg:setPosition(size.width / 2, size.height / 2 - _heightSizeDex)
	end

	if not (count == 4 and index == 1) then
		local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(cell)
		titBg:setPosition(size.width / 2,size.height - 40)
		local titLab = ui.newTTFLabel({text = CommonText[675][_index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = titBg:getContentSize().width/2, y = titBg:getContentSize().height/2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)
	end

	if  #taskList > 0 then
		for index=1,#taskList do
			local task = taskList[index]
			local taskInfo = TaskMO.queryTask(task.taskId)
			local taskBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(bg)
			taskBg:setPreferredSize(cc.size(610, 140))
			taskBg:setCapInsets(cc.rect(80, 60, 1, 1))
			taskBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - taskBg:getContentSize().height / 2 - 20 - (index - 1) * (taskBg:getContentSize().height + 20))

			local taskIcon = UiUtil.createItemView(ITEM_KIND_TASK, task.taskId)
			taskBg:addChild(taskIcon)
			taskIcon:setPosition(80,70)

			local taskName = ui.newTTFLabel({text = taskInfo.taskName, font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 150, y = 115, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
			taskName:setAnchorPoint(cc.p(0, 0.5))

			local scheduleLab = ui.newTTFLabel({text = CommonText[676][1], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 150, y = 70, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
			scheduleLab:setAnchorPoint(cc.p(0, 0.5))

			local scheduleValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 150, y = 40, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
			scheduleValue:setAnchorPoint(cc.p(0, 0.5)) 
			if task.schedule >= taskInfo.schedule then
				scheduleValue:setString(CommonText[676][4])
			else
				scheduleValue:setString(task.schedule .. "/" .. taskInfo.schedule)
			end

			--详情按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
			local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDetailTask))
			detailBtn.task = task
			cell:addButton(detailBtn, size.width - 230, taskBg:getPositionY() - _heightDex)

			local normal,selected,goBtn
			if task.status == 0 then
				--前往
				normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
				selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
				goBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onGoTask))
				goBtn:setLabel(CommonText[676][2])
				goBtn.taskInfo = taskInfo
			else
				--领取奖励
				normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
				selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
				goBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.getAwardTask))
				goBtn:setLabel(CommonText[676][3])
				goBtn.taskId = task.taskId
			end
			cell:addButton(goBtn, size.width - 100, taskBg:getPositionY() - _heightDex)
		end
	end
	return cell
end

function TaskMajorTableView:onDetailTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.TaskDetailDialog").new(sender.task):push()
end

function TaskMajorTableView:onGoTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	TaskBO.goToTaskDo(sender.taskInfo)
end

function TaskMajorTableView:getAwardTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.taskAcceptStatus == true then return end
	self.taskAcceptStatus = true
	Loading.getInstance():show()
	TaskBO.asynTaskAward(function()
		Loading.getInstance():unshow()
		ManagerSound.playSound("task_done")
		end,TASK_TYPE_MAJOR,sender.taskId,TASK_GET_AWARD_TYPE_NOMAL)
end


function TaskMajorTableView:cellTouched(cell, index)

end

function TaskMajorTableView:updateListHandler(event)
	TaskBO.sortFun(TaskMO.majorTaskList_,TASK_TYPE_MAJOR)
	self:updateFinashTaskList()
	-- local offset = self:getContentOffset()
   	self:reloadData()
   	-- self:setContentOffset(offset)
   	self.taskAcceptStatus = false
end


function TaskMajorTableView:onExit()
	TaskMajorTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end

	if self.m_updateListHandler1 then
		Notify.unregister(self.m_updateListHandler1)
		self.m_updateListHandler1 = nil
	end
end



return TaskMajorTableView