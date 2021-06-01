--
-- Author: gf
-- Date: 2015-09-25 10:09:55
--

local TaskLiveAwardTableView = class("TaskLiveAwardTableView", TableView)



function TaskLiveAwardTableView:ctor(size)
	TaskLiveAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 200)
	
	if UserMO.queryFuncOpen(UFP_NEW_ACTIVE) then
		self.m_list = TaskMO.getNewTaskLiveList()
	else
		self.m_list = TaskMO.getTaskLiveList()
	end
end

function TaskLiveAwardTableView:numberOfCells()
	return #self.m_list
end

function TaskLiveAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function TaskLiveAwardTableView:createCellAtIndex(cell, index)
	TaskLiveAwardTableView.super.createCellAtIndex(self, cell, index)

	local live = self.m_list[index]


	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(507, 195))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = string.format(CommonText[688],live.live), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 140, y = 170, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local liveAwards = json.decode(live.awardList) 

	for index=1,#liveAwards do
		local itemView = UiUtil.createItemView(liveAwards[index][1], liveAwards[index][2], {count = liveAwards[index][3]})
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 100,bg:getContentSize().height - 100)
		cell:addChild(itemView)
		itemView:setScale(0.8)
		UiUtil.createItemDetailButton(itemView,cell,true)
		local propDB = UserMO.getResourceData(liveAwards[index][1], liveAwards[index][2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_TINY - 2, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 70, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end

	return cell
end




function TaskLiveAwardTableView:onExit()
	TaskLiveAwardTableView.super.onExit(self)

end



return TaskLiveAwardTableView