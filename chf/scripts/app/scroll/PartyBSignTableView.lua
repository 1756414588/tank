--
-- Author: gf
-- Date: 2015-12-16 14:00:57
--

local PartyBSignTableView = class("PartyBSignTableView", TableView)

function PartyBSignTableView:ctor(size)
	PartyBSignTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 60)
end

function PartyBSignTableView:onEnter()
	PartyBSignTableView.super.onEnter(self)
	self.m_list = PartyBattleMO.joinMember

	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_SIGN_UPDATE_EVENT, handler(self, self.updateListHandler))
	
end

function PartyBSignTableView:numberOfCells()
	return #self.m_list
end

function PartyBSignTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyBSignTableView:createCellAtIndex(cell, index)
	PartyBSignTableView.super.createCellAtIndex(self, cell, index)

	local data = self.m_list[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(550, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	
	local signTime = ui.newTTFLabel({text = os.date("%H:%M", data.time), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 60, y = 30, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	local name = ui.newTTFLabel({text = data.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 206, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	local level = ui.newTTFLabel({text = "LV." .. data.lv, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 346, y = 30, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(data.fight), font = "fnt/num_2.fnt"}):addTo(bg)
	fightValue:setPosition(485,30)

	return cell
end

function PartyBSignTableView:updateListHandler(event)
	-- gdump(event,"eventeventeventevent")
	-- local offset = self:getContentOffset()
	self:reloadData()
	-- self:setContentOffset(offset)
end

function PartyBSignTableView:onExit()
	PartyBSignTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

return PartyBSignTableView