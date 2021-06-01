

------------------------------------------------------------------------------
-- 世界BOSS伤害奖励预览
------------------------------------------------------------------------------

local BossAwardTableView = class("BossAwardTableView", TableView)

function BossAwardTableView:ctor(size)
	BossAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 200)

	self.list = PartyBattleMO.getRankAward(3)

	gdump(self.list, "BossAwardTableView:ctor")

	-- self.m_exploreType = EXPLORE_TYPE_EXTREME
	-- self.m_sectionId = CombatMO.getExploreSectionIdByType(self.m_exploreType)
	-- self.m_combatIds = CombatMO.getCombatIdsBySectionId(self.m_sectionId)
end

function BossAwardTableView:numberOfCells()
	return #self.list
end

function BossAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function BossAwardTableView:createCellAtIndex(cell, index)
	BossAwardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]

	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self.m_cellSize.height - 30)

	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = bg:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	info:setAnchorPoint(cc.p(0,0.5))

	info:setString(string.format(CommonText[257],data.rank))


	local awardList = data.awards
	-- gdump(dayWeal,"当前等级每日福利")
	for index=1,#awardList do
		local award = awardList[index]
		--军团奖励第一名增加BUFF图标

		-- if self.type == 2 and data.rank == 1 then
		-- 	local itemView = UiUtil.createItemView(ITEM_KIND_EFFECT, EFFECT_ID_PB_RESOURCE)
		-- 	itemView:setPosition(50 + itemView:getContentSize().width / 2,bg:getPositionY() - 80)
		-- 	itemView:setScale(0.8)
		-- 	cell:addChild(itemView)
		-- 	UiUtil.createItemDetailButton(itemView, cell, true)	
		-- 	local name = ui.newTTFLabel({text = CommonText[821][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		-- 		x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
		-- end

		local itemView = UiUtil.createItemView(award[1], award[2])
		if self.type == 2 and data.rank == 1 then
			itemView:setPosition(160 + itemView:getContentSize().width / 2 + (index - 1) * 110,bg:getPositionY() - 80)
		else
			itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 110,bg:getPositionY() - 80)
		end
		itemView:setScale(0.8)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)		

		local propDB = UserMO.getResourceData(award[1], award[2])
		local name = ui.newTTFLabel({text = propDB.name2 .. " * " .. award[3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end

	return cell
end

------------------------------------------------------------------------------
-- 世界BOSS奖励预览
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local BossAwardDialog = class("BossAwardDialog", Dialog)

function BossAwardDialog:ctor()
	BossAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
end

function BossAwardDialog:onEnter()
	BossAwardDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[269])

	self:showUI()
end

function BossAwardDialog:showUI()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	self.m_upgradeTimeLabel = nil
	self.m_upgradeBar = nil

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	local view = BossAwardTableView.new(cc.size(526, 728)):addTo(container)
	view:setPosition((container:getContentSize().width - view:getContentSize().width) / 2, 64)
	view:reloadData()

	local desc = ui.newTTFLabel({text = CommonText[10013], font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2, y = 50, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
end

return BossAwardDialog
