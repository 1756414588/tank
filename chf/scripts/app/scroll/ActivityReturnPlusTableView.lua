--
-- Author: Your Name
-- Date: 2017-06-14 20:41:29
--
--老玩家回归专属属性加成
local ActivityReturnPlusTableView = class("ActivityReturnPlusTableView", TableView)

function ActivityReturnPlusTableView:ctor(size,data)
	ActivityReturnPlusTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_data = data
	self.m_buff = PlayerBackMO.getBackBuffByTime(PlayerBackMO.backTime_)
end

function ActivityReturnPlusTableView:onEnter()
	ActivityReturnPlusTableView.super.onEnter(self)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
	self.isUpdat = false
end

function ActivityReturnPlusTableView:numberOfCells()
	return #self.m_buff
end

function ActivityReturnPlusTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityReturnPlusTableView:createCellAtIndex(cell, index)
	ActivityReturnPlusTableView.super.createCellAtIndex(self, cell, index)
	local state = self.m_data.buff[index]
	cell.state = state

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_EFFECT, self.m_buff[index].buffId):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local effectDB = self.m_buff[index]
	local leftTime = self.m_data.buffTime[index] - ManagerTimer.getTime()
	local totalTime = self.m_data.buffTime[index]

	local title = ui.newTTFLabel({text = effectDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png"):addTo(cell)
	normal:setPosition(self.m_cellSize.width - normal:width() / 2 - 20, self.m_cellSize.height / 2)
	local status = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL}):addTo(normal):center()
	status:setString(CommonText[100012][1])

	if state ~= 0 and leftTime > 0 then -- 有增益
		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
		bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 74)
		bar:setPercent(0)
		bar:setLabel(UiUtil.strBuildTime(leftTime))
		cell.bar = bar
		status:setString(CommonText[100012][2])
	end

	cell.leftTime = leftTime
	cell.totalTime = totalTime
	return cell
end

function ActivityReturnPlusTableView:onUseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ItemUseDialog").new(ITEM_KIND_EFFECT, sender.effectId):push()
end

function ActivityReturnPlusTableView:update(dt)
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if cell then
			if cell.state ~= 0 and cell.leftTime > 0 then
				local leftTime = cell.totalTime - ManagerTimer.getTime()
				if leftTime > 0 then
					cell.bar:setLabel(UiUtil.strBuildTime(leftTime))
				else
					self:upDateUI()
				end
			end
		end
	end
end

function ActivityReturnPlusTableView:upDateUI()
	if not self.isUpdat then
		self:reloadData()
	end
	self.isUpdat = true
end

function ActivityReturnPlusTableView:onExit()
	ActivityReturnPlusTableView.super.onExit(self)
end

return ActivityReturnPlusTableView