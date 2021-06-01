--
--
-- 储物间
-- MYS
--

local LaboratoryForStorageView = class("LaboratoryForStorageView",TableView)

function LaboratoryForStorageView:ctor(size)
	LaboratoryForStorageView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 150)
end

function LaboratoryForStorageView:onEnter()
	LaboratoryForStorageView.super.onEnter(self)
	self.m_list = {LABORATORY_ITEM1_ID, LABORATORY_ITEM2_ID, LABORATORY_ITEM3_ID, LABORATORY_ITEM4_ID}
	self:reloadData()
end

function LaboratoryForStorageView:numberOfCells()
	return #self.m_list
end

function LaboratoryForStorageView:cellSizeForIndex(index)
	return self.m_cellSize
end

function LaboratoryForStorageView:createCellAtIndex(cell, index)
	LaboratoryForStorageView.super.createCellAtIndex(self, cell, index)
	-- 
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPosition(self.m_cellSize.width * 0.5, self.m_cellSize.height * 0.5)

	local infoID = self.m_list[index]
	local info = LaboratoryMO.queryLaboratoryForItemById(infoID)

	local count = UserMO.getResource(ITEM_KIND_LABORATORY_RES, infoID)

	local item = UiUtil.createItemView(ITEM_KIND_LABORATORY_RES, infoID):addTo(bg)
	item:setScale(0.9)
	item:setPosition(45 + item:width() * 0.5, bg:height() * 0.5)
	UiUtil.createItemDetailButton(item)

	local name = ui.newTTFLabel({text = info.name .. "*" .. UiUtil.strNumSimplify(count) , font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(bg)
	name:setAnchorPoint(cc.p(0,0.5))
	name:setPosition( item:x() + item:width() * 0.5 + 20 , bg:height() - 27)

	local limitCount = 28
	local descCount , str = string.utf8len(info.description, limitCount)
	local desc = ui.newTTFLabel({text = info.description , font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = cc.c3b(255, 255, 255), dimensions = cc.size(370,60)}):addTo(bg)
	-- desc:setAnchorPoint(cc.p(0,0.5))
	-- desc:setPosition( item:x() + item:width() * 0.5 + 20 , bg:height() * 0.5 - 10)
	desc:setPosition( item:x() + item:width() * 0.5 + 20 + 185, bg:height() * 0.5 - 10)
	if descCount > limitCount then
		descStr = str  .. "..."
		desc:setString(descStr)
		local descTip = ui.newTTFLabel({text = CommonText[1777], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[12], align = ui.TEXT_ALIGN_RIGHT}):addTo(desc)
		descTip:setAnchorPoint(cc.p(1, 0))
		descTip:setPosition(desc:width() - 10,desc:height() * 0.5 - 22)
		desc.kind = ITEM_KIND_LABORATORY_RES
		desc.id = infoID
		-- desc.param = param
		UiUtil.createItemDetailButton(desc,cell,true)
	end

	return cell
end

function LaboratoryForStorageView:onExit()
	LaboratoryForStorageView.super.onExit(self)
end

return LaboratoryForStorageView