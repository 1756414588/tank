

------------------------------------------------------------------------------
-- 极限副本奖励预览
------------------------------------------------------------------------------

local ExtremeAwardTableView = class("ExtremeAwardTableView", TableView)

function ExtremeAwardTableView:ctor(size)
	ExtremeAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 188)

	self.m_exploreType = EXPLORE_TYPE_EXTREME
	self.m_sectionId = CombatMO.getExploreSectionIdByType(self.m_exploreType)
	self.m_combatIds = CombatMO.getCombatIdsBySectionId(self.m_sectionId)
end

function ExtremeAwardTableView:numberOfCells()
	return math.floor(#self.m_combatIds / 5)
end

function ExtremeAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ExtremeAwardTableView:createCellAtIndex(cell, index)
	ExtremeAwardTableView.super.createCellAtIndex(self, cell, index)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 10, self.m_cellSize.height - 8))
	bg:setCapInsets(cc.rect(130, 40, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local combatId = self.m_combatIds[index * 5]
	local combatDB = CombatMO.queryExploreById(combatId)

	-- 关卡名背景
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	titleBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 8)
	-- 第几关 名称
	local name = ui.newTTFLabel({text = CommonText[237][1] .. (index * 5) .. CommonText[237][2] .. " - " .. combatDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	local awards = CombatBO.parseShowDrop(combatDB)

	for idx = 1, #awards do
		local award = awards[idx]
		local itemView = UiUtil.createItemView(award.kind, award.id):addTo(cell)
		itemView:setPosition(20 + (idx - 0.5) * 105, 100)
		itemView:setScale(0.9)
		UiUtil.createItemDetailButton(itemView, cell, true)

		local resData = UserMO.getResourceData(award.kind, award.id)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	end

	return cell
end

------------------------------------------------------------------------------
-- 极限副本奖励预览
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ExtremeAwardDialog = class("ExtremeAwardDialog", Dialog)

function ExtremeAwardDialog:ctor()
	ExtremeAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
end

function ExtremeAwardDialog:onEnter()
	ExtremeAwardDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[269])

	self:showUI()
end

function ExtremeAwardDialog:showUI()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	self.m_upgradeTimeLabel = nil
	self.m_upgradeBar = nil

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	local view = ExtremeAwardTableView.new(cc.size(526, 740)):addTo(container)
	view:setPosition((container:getContentSize().width - view:getContentSize().width) / 2, 44)
	view:reloadData()
end

return ExtremeAwardDialog
