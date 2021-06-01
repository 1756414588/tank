--
-- Author: Gss
-- Date: 2018-12-18 17:16:30
--
-- 战术材料界面  TacticMaterialsTableView

local TacticMaterialsTableView = class("TacticMaterialsTableView", TableView)

function TacticMaterialsTableView:ctor(size,key)
	TacticMaterialsTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_items = TacticsMO.queryTacticMaterialsById()

end

function TacticMaterialsTableView:numberOfCells()
	return #self.m_items
end

function TacticMaterialsTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function TacticMaterialsTableView:createCellAtIndex(cell, index)
	TacticMaterialsTableView.super.createCellAtIndex(self, cell, index)

	local kind = ITEM_KIND_TACTIC_MATERIAL
	local data = self.m_items[index]
	local id = data.id
	local resData = UserMO.getResourceData(kind, id)
	local count = UserMO.getResource(kind, id)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(kind, id):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	-- 名称
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[resData.quality]}):addTo(cell)

	local desc = ui.newTTFLabel({text = resData.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(410, 80)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 140, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newBMFontLabel({text = UiUtil.strNumSimplify(count), font = "fnt/num_2.fnt", x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))

	return cell
end

return TacticMaterialsTableView
