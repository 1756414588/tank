

------------------------------------------------------------------------------
-- 世界BOSS祝福TableView
------------------------------------------------------------------------------

local BlessTableView = class("BlessTableView", TableView)

function BlessTableView:ctor(size)
	BlessTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

-- function BlessTableView:onExit()
-- 	gprint("BlessTableView:onExit ... ")
-- 	BlessTableView.super.onExit(self)
-- end

function BlessTableView:numberOfCells()
	return 3
end

function BlessTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function BlessTableView:createCellAtIndex(cell, index)
	BlessTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = nil
	if index == 1 then -- 穿刺
		itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "impale"}):addTo(cell)
		itemView:setScale(1)
	elseif index == 2 then -- 暴击
		itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "crit"}):addTo(cell)
		itemView:setScale(1)
	elseif index == 3 then -- 加伤
		itemView = UiUtil.createItemView(ITEM_KIND_EFFECT, EFFECT_ID_HURT_ADD):addTo(cell)
	end

	itemView:setPosition(80, self.m_cellSize.height / 2)

	local blessLv = PartyMO.altarBoss_["bless" .. index]
	-- 名称
	local name = ui.newTTFLabel({text = CommonText[10019][index] .. " LV." .. blessLv, font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 114, color = COLOR[1]}):addTo(cell)

	local desc = ui.newTTFLabel({text = CommonText[10020][index], font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(220, 80)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	-- if count > 0 then
	-- 	-- 数量
	-- 	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 25, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 	label:setAnchorPoint(cc.p(0, 0.5))

	-- 	-- 
	-- 	local countLabel = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 	countLabel:setAnchorPoint(cc.p(0, 0.5))

	-- 	-- 使用按钮
	-- 	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	-- 	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	-- 	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	-- 	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onUseCallback))
	-- 	btn:setLabel(CommonText[86])
	-- 	btn.propId = propId
	-- 	cell:addButton(btn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 22)

	-- 	if self.m_param.disabled then
	-- 		btn:setEnabled(false)
	-- 	end
	-- else

	if blessLv < ACTIVITY_BOSS_BLESS_MAX_LV then -- 还没有到达最高等级
		-- 金币价格
		local itemView = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(cell)
		itemView:setAnchorPoint(cc.p(0, 0.5))
		itemView:setPosition(self.m_cellSize.width - 70 - 40, 114)

		local countLabel = ui.newTTFLabel({text = PartyBO.getBlessPrice(blessLv), font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX() + itemView:getContentSize().width + 5, y = itemView:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		countLabel:setAnchorPoint(cc.p(0, 0.5))

		-- 
		local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onUseCallback))
		btn.index = index
		cell:addButton(btn, self.m_cellSize.width - 70, self.m_cellSize.height / 2 - 22)
	end

	return cell
end

function BlessTableView:onUseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = sender.index

	local blessLv = PartyMO.altarBoss_["bless" .. index]
	local take = PartyBO.getBlessPrice(blessLv)
	local count = UserMO.getResource(ITEM_KIND_COIN)

	local function doneCallback(gold)
		gold = gold or (count - take)
		UserMO.updateResource(ITEM_KIND_COIN, gold)
		self:reloadData()
		
		Loading.getInstance():unshow()
		Toast.show(CommonText[10028])  -- 祝福成功
	end

	local function gotoBuy()
		if count < take then  -- 金币不足
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		Loading.getInstance():show()
		PartyBO.asynBlessBossFight(doneCallback, index)
	end

	if UserMO.consumeConfirm then
		local resData = UserMO.getResourceData(ITEM_KIND_COIN)

		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[10029], take, resData.name), function() gotoBuy() end):push()
	else
		gotoBuy()
	end
end

------------------------------------------------------------------------------
-- 世界BOSS祝福弹出框
------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local AltarBossBlessDialog = class("AltarBossBlessDialog", Dialog)

function AltarBossBlessDialog:ctor()
	AltarBossBlessDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
end

function AltarBossBlessDialog:onEnter()
	AltarBossBlessDialog.super.onEnter(self)

	self:setTitle(CommonText[538][1])  -- 祝福

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = BlessTableView.new(cc.size(526, 728), self.m_kind, self.m_id):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 64)
	view:reloadData()

	local desc = ui.newTTFLabel({text = CommonText[10014], font = G_FONT, size = FONT_SIZE_SMALL, x = self:getBg():getContentSize().width / 2, y = 50, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
end

return AltarBossBlessDialog
