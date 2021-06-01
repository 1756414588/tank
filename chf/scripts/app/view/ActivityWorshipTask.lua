--
-- yansong
-- data:
-- 任务列表

local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,task,tasknum)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 120)
	self.task = task
	self.tasknum = tasknum
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)

	local data = self.tasklist[index]

	-- 背景
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 10 , 110))
	bg:setAnchorPoint(0.5,0.5)
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	-- 图标
	local pic = display.newSprite("image/item/" .. tostring(data.asset) ..".jpg"):addTo(bg)
	pic:setAnchorPoint(0.5,0.5)
	pic:setPosition( pic:getContentSize().width - 20 ,bg:getContentSize().height / 2)
	pic:setScale(0.88)

	local picbg = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(pic)
	picbg:setAnchorPoint(0.5,0.5)
	picbg:setPosition( pic:getContentSize().width / 2 ,pic:getContentSize().height / 2)
	--picbg:setScale(0.95)
	--

	-- 标题
	local title = ui.newTTFLabel({text = data.taskName, font = G_FONT, color = COLOR[12], size = FONT_SIZE_SMALL, x = 42,
	 y = bg:getContentSize().height / 2}):addTo(bg)
	title:setAnchorPoint(0,0.5)
	title:setPosition(pic:getPositionX() + pic:getContentSize().width / 2 + 20, self.m_cellSize.height * 0.68)

	-- 提示
	local tip = ui.newTTFLabel({text = CommonText[20209], font = G_FONT, color = COLOR[12], size = FONT_SIZE_TINY, x = 42,
	 y = bg:getContentSize().height / 2}):addTo(bg)
	tip:setAnchorPoint(0,0.5)
	tip:setPosition(title:getPositionX() , title:getPositionY() - title:getContentSize().height - 5 )

	--
	local prolab = ui.newTTFLabel({text = data.pro, font = G_FONT, color = COLOR[12], size = FONT_SIZE_SMALL, x = 42,
	 y = bg:getContentSize().height / 2}):addTo(bg)
	prolab:setAnchorPoint(0,0.5)
	prolab:setPosition(pic:getPositionX() + pic:getContentSize().width / 2 + 20, self.m_cellSize.height * 0.2)


	local text = "" 
		if data.enabled then 
			text = CommonText[20211][2] 
		else 
			text = CommonText[20211][1] 
		end 
	-- 前往 按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local taskbtn = CellMenuButton.new(normal, selected, disabled,handler(self, self.onNextCallback))
	taskbtn:setLabel(text)
	taskbtn:setEnabled(not data.enabled)
	taskbtn.index = index
	cell:addButton(taskbtn , self.m_cellSize.width - 100 , self.m_cellSize.height / 2 - 13)

	return cell
end

function ContentTableView:onNextCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = sender.index
	local taskInfo = self.tasklist[index].task
	TaskBO.goToTaskDo(taskInfo)
end

function ContentTableView:numberOfCells()
	if #self.tasklist < RANK_PAGE_NUM or #self.tasklist >= 100 then
		return #self.tasklist
	else
		return #self.tasklist + 1
	end
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI()
	self.tasklist = {}

	gdump(self.task,"=========== task")
	gdump(self.tasknum,"========== 许愿任务已完成部分")
	local taskstr = tostring(self.task.task)
	local dec = json.decode(taskstr)

	for index=1,#dec do
		local data = {}
		local rs = dec[index]
		local cond = rs[1]
		local taskL = TaskMO.queryTaskByCond(cond)
		local taskout = nil
		for k,v in pairs(taskL) do
			if taskout == nil then
				if v.type == 3 then
					taskout = v
					break
				end
			end
		end
		local times = rs[2]
		data.taskName = self:resubNumber(taskout.taskName,times)
		data.asset = taskout.asset
		local hasdone = self.tasknum[index]
		local pro = CommonText[20210] .. hasdone .."/" .. tostring(times)
		data.pro = pro
		data.enabled = times == hasdone
		data.task = taskout
		self.tasklist[#self.tasklist + 1] = data
	end
	self:reloadData()
end

function ContentTableView:resubNumber(str,re)
	local st = nil
	local et = nil
	local ot
	repeat
		ot = string.find(str,'[%w]',et)
		if ot ~= nil then
			et = ot + 1
		end
		if st == nil and ot ~= nil then
			st = ot
		end
	until(ot == nil)
	if et ~= nil and st ~= nil then
		local restr = string.sub(str,st,et - 1)
		return string.gsub(str, restr, re)
	else
		return str
	end
end

------------------------------------------------------------------------------
-- 许愿任务view
------------------------------------------------------------------------------

local ActivityWorshipTask = class("ActivityWorshipTask",function ()
	return display.newNode()
end)

-- 宽 高 任务列表 已完成的列表（任务下标 ：完成数量）
function ActivityWorshipTask:ctor(width,height,task,tasknum)
	self:size(width,height)
	self.task = task
	self.tasknum = tasknum
	self:showInfo()
end

function ActivityWorshipTask:showInfo()
	
	local lines = display.newSprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(self)
	lines:setAnchorPoint(0.5,1)
	lines:setPosition( self:width() / 2, self:height())
	lines:setScaleX(2)

	lines = display.newSprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(self)
	lines:setAnchorPoint(0.5,0)
	lines:setPosition( self:width() / 2, 0)
	lines:setScaleX(2)

	local view = ContentTableView.new(cc.size(self:width(), self:height()),self.task,self.tasknum):addTo(self)--:pos(30,10)
	view:updateUI()

end

return ActivityWorshipTask