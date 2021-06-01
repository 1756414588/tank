
--------------------------------------------------------------------
-- 授勋tableview
--------------------------------------------------------------------
local MedalTableView = class("MedalTableView", TableView)

function MedalTableView:ctor(size)
	MedalTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

end

function MedalTableView:numberOfCells()
	return 4
end

function MedalTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MedalTableView:createCellAtIndex(cell, index)
	MedalTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_MEDAL, index):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local fameData = UserMO.getResourceData(ITEM_KIND_FAME)

	-- X星授勋
	local title = ui.newTTFLabel({text = CommonText[239][index] .. "(" .. FAME_MEDAL_TAKE[index][1] .. fameData.name .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

	if FAME_MEDAL_TAKE[index][2] == 1 then  -- 宝石
		local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
		-- 花费宝石
		local label = ui.newTTFLabel({text = CommonText[117] .. resData.name .. ":" .. FAME_MEDAL_TAKE[index][3], font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 89, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	else
		local resData = UserMO.getResourceData(ITEM_KIND_COIN)
		-- 花费金币
		local label = ui.newTTFLabel({text = CommonText[117] .. resData.name .. ":" .. FAME_MEDAL_TAKE[index][3], font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 89, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local medalBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onMedalCallback))
	medalBtn:setLabel(CommonText[115])
	medalBtn.index = index
	cell:addButton(medalBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)

	if not UserMO.canBuyFame_ then  -- 不能授勋
		medalBtn:setEnabled(false)
	end

	return cell
end

function MedalTableView:onMedalCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = sender.index

	local function doneBuyFame(up, delta)
		Loading.getInstance():unshow()
		self:reloadData()
		if delta > 0 then
			UiUtil.showAwards({awards = {{kind = ITEM_KIND_FAME, count = delta}}})
		end
	end

	local function gotoBuyFame()
		Loading.getInstance():show()
		UserBO.asynBuyFame(doneBuyFame, index)
	end

	if FAME_MEDAL_TAKE[index][2] == 1 then  -- 宝石
		if UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE) < FAME_MEDAL_TAKE[index][3] then
			local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
			Toast.show(resData.name .. CommonText[223])
			return
		end
		gotoBuyFame()
	else
		local function coinBuyFame()
			if UserMO.getResource(ITEM_KIND_COIN) < FAME_MEDAL_TAKE[index][3] then  -- 金币不足
				require("app.dialog.CoinTipDialog").new():push()
				return
			end
			gotoBuyFame()
		end
		
		if UserMO.consumeConfirm then
			local resData = UserMO.getResourceData(ITEM_KIND_COIN)
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[472], FAME_MEDAL_TAKE[index][3], resData.name), function() coinBuyFame() end):push()
		else
			coinBuyFame()
		end
	end

end

--------------------------------------------------------------------
-- 授勋view
--------------------------------------------------------------------
local MedalView = class("MedalView", UiNode)

function MedalView:ctor(viewFor)
	MedalView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)

end

function MedalView:onEnter()
	MedalView.super.onEnter(self)

	-- 授勋
	self:setTitle(CommonText[115])

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - line:getContentSize().height / 2 - 4)

	local resData = UserMO.getResourceData(ITEM_KIND_FAME)

	-- 每天可授勋
	local desc = ui.newTTFLabel({text = string.format(CommonText[116] .. resData.name2, 1), font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 120, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	local view = MedalTableView.new(cc.size(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, self:getBg():getContentSize().height - 150 - view:getContentSize().height)
	view:reloadData()
end

return MedalView
