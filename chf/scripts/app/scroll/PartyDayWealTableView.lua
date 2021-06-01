--
-- Author: gf
-- Date: 2015-09-15 19:14:44
-- 军团日常福利一览

local PartyDayWealTableView = class("PartyDayWealTableView", TableView)



function PartyDayWealTableView:ctor(size)
	PartyDayWealTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 200)

end

function PartyDayWealTableView:numberOfCells()
	return #PartyMO.dayWealList
end

function PartyDayWealTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyDayWealTableView:createCellAtIndex(cell, index)
	PartyDayWealTableView.super.createCellAtIndex(self, cell, index)

	local dayWeal = PartyMO.dayWealList[index]


	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(507, 195))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local wealAwards = json.decode(dayWeal.wealList) 
	-- gdump(dayWeal,"当前等级每日福利")
	for index=1,#wealAwards do
		local itemView = UiUtil.createItemView(wealAwards[index][1], wealAwards[index][2], {count = wealAwards[index][3]})
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 140,bg:getContentSize().height - 100)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView,cell,true)
		local propDB = UserMO.getResourceData(wealAwards[index][1], wealAwards[index][2])
		local name = ui.newTTFLabel({text = propDB.name .. " * " .. wealAwards[index][3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 70, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	end

	local info = ui.newTTFLabel({text = string.format(CommonText[611],dayWeal.wealLv,PartyMO.getDayWealNeed), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width / 2, y = bg:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	

	return cell
end




function PartyDayWealTableView:onExit()
	PartyDayWealTableView.super.onExit(self)

end



return PartyDayWealTableView