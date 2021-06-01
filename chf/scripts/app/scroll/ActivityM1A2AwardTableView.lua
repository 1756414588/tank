--
-- Author: gf
-- Date: 2016-05-13 09:34:51
-- M1A2奖励


local ActivityM1A2AwardTableView = class("ActivityM1A2AwardTableView", TableView)



function ActivityM1A2AwardTableView:ctor(size,lotteryType)
	ActivityM1A2AwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 175)

	local act = ActivityCenterMO.getA1m2ById(lotteryType).awards
	self.list = json.decode(act)
end

function ActivityM1A2AwardTableView:numberOfCells()
	return #self.list
end

function ActivityM1A2AwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityM1A2AwardTableView:createCellAtIndex(cell, index)
	ActivityM1A2AwardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]

	-- local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	-- bg:setAnchorPoint(cc.p(0, 0.5))
	-- bg:setPosition(40, self.m_cellSize.height - 30)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(510, 170))
	bg:setCapInsets(cc.rect(80, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)


	-- gdump(dayWeal,"当前等级每日福利")
	local itemView = UiUtil.createItemView(data[1], data[2], {count = data[3]})
		itemView:setPosition(25 + itemView:getContentSize().width / 2,bg:getPositionY() - 15)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)

	local propDB = UserMO.getResourceData(data[1], data[2])
	local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 140, y = 143, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	name:setAnchorPoint(cc.p(0,0.5))

	local desc = propDB.desc or ""
	local desc = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 140, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(300, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	
	return cell
end


function ActivityM1A2AwardTableView:onExit()
	ActivityM1A2AwardTableView.super.onExit(self)
end



return ActivityM1A2AwardTableView