--
-- Author: gf
-- Date: 2015-12-14 10:30:53
--


local RaffleAwardTableView = class("RaffleAwardTableView", TableView)


function RaffleAwardTableView:ctor(size,activityId)
	RaffleAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.listData_ = ActivityCenterMO.getRaffleById(activityId)
end

function RaffleAwardTableView:onEnter()
	RaffleAwardTableView.super.onEnter(self)
end

function RaffleAwardTableView:numberOfCells()
	return #self.listData_
end

function RaffleAwardTableView:cellSizeForIndex(index)
	local tankList = json.decode(self.listData_[index].tankList)
	local height = #tankList * 90 + 60

	self.m_cellSize = cc.size(self:getViewSize().width, height)

	return self.m_cellSize
end

function RaffleAwardTableView:createCellAtIndex(cell, index)
	RaffleAwardTableView.super.createCellAtIndex(self, cell, index)
	local size = self:cellSizeForIndex(index)
	local tankList = json.decode(self.listData_[index].tankList)
	local tankCount = self.listData_[index].count
	local raffleList = {3,2,1}
	local bg
	if  #tankList > 0 then
		bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(size.width - 40, size.height - 10))
		bg:setCapInsets(cc.rect(130, 40, 1, 1))
		bg:setPosition(size.width / 2, size.height / 2 - 20)
	end

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(cell)
	titBg:setPosition(size.width / 2,size.height - 30)

	local titLab = ui.newTTFLabel({text = CommonText[789][index], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width/2, y = titBg:getContentSize().height/2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	local awardList = self.listData_[index]
	if #tankList > 0 then
		for i=1,#tankList do
			local tankId = tankList[i]
			local itemView = UiUtil.createItemView(ITEM_KIND_TANK, tankId, {count = tankCount})
			itemView:setScale(0.8)
			itemView:setPosition(bg:getContentSize().width - 40, bg:getContentSize().height - 90 / 2 - 40 - (i - 1) * (90))
			cell:addChild(itemView)
			UiUtil.createItemDetailButton(itemView,cell,true)
			for j=1,raffleList[index] do
				local lab = ui.newTTFLabel({text = "=", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = itemView:getPositionX() - 70 - (j - 1) * 125, y = itemView:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				lab:setAnchorPoint(cc.p(0.5, 0.5))
				if j == 1 then
					lab:setString("=")
				else
					lab:setString("+")
				end

				local pic = display.newSprite(IMAGE_COMMON .. "raffle_" .. i .. ".png", 
					lab:getPositionX() - 60, lab:getPositionY()):addTo(cell)
			end
		end
	end
	return cell
end





function RaffleAwardTableView:onExit()
	RaffleAwardTableView.super.onExit(self)
end



return RaffleAwardTableView