
-- 积分兑换的物品

local ScoreTableView = class("ScoreTableView", TableView)

VIEW_FOR_FIGHT        = 1  -- 战斗
VIEW_FOR_RESOURCE     = 2  -- 资源
VIEW_FOR_GROWN        = 3  -- 成长

function ScoreTableView:ctor(size, viewFor)
	ScoreTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_viewFor = viewFor

	self.m_props = {}

	if self.m_viewFor == VIEW_FOR_FIGHT then
		self.m_props = PropBO.getArenaProps(self.m_viewFor)
	elseif self.m_viewFor == VIEW_FOR_RESOURCE then
		self.m_props = PropBO.getArenaProps(self.m_viewFor)
	elseif self.m_viewFor == VIEW_FOR_GROWN then
		self.m_props = PropBO.getArenaProps(self.m_viewFor)
	end

	-- gdump(self.m_props, "[ScoreTableView] ctor")
end

function ScoreTableView:numberOfCells()
	return #self.m_props
end

function ScoreTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ScoreTableView:createCellAtIndex(cell, index)
	ScoreTableView.super.createCellAtIndex(self, cell, index)

	local prop = self.m_props[index]
	local propDB = PropMO.queryPropById(prop.propId)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local bagView = nil
	-- if self.m_viewFor == VIEW_FOR_ALL_MINE then
	-- 	bagView = UiUtil.createItemView(ITEM_KIND_PROP, prop.propId, {count = UserMO.getResource(ITEM_KIND_PROP, prop.propId)}):addTo(cell)
	-- else
		bagView = UiUtil.createItemView(ITEM_KIND_PROP, prop.propId):addTo(cell)
	-- end
	bagView:setPosition(100, self.m_cellSize.height / 2)

	-- 名称
	local name = ui.newTTFLabel({text = PropMO.getPropName(prop.propId), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[propDB.color]}):addTo(cell)

	local desc = ui.newTTFLabel({text = propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	-- 兑换
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBtnCallback))
	btn:setLabel(CommonText[294])
	btn.propId = propDB.propId
	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
	if propDB.arenaScore > ArenaMO.arenaScore_ then
		btn:setEnabled(false)
	end

	-- 售价
	local label = ui.newTTFLabel({text = CommonText[198] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 55, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(cell)
	view:setPosition(label:getPositionX() + label:getContentSize().width + view:getContentSize().width / 2, label:getPositionY())
	view:setVisible(false)

	local price = ui.newBMFontLabel({text = UiUtil.strNumSimplify(propDB.arenaScore), font = "fnt/num_2.fnt", x = view:getPositionX() + view:getContentSize().width / 2, y = view:getPositionY()}):addTo(cell)
	price:setAnchorPoint(cc.p(0, 0.5))

	-- if self.m_viewFor == VIEW_FOR_ALL_MINE then -- 我的背包
	-- 	-- 数量
	-- 	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 25, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 	label:setAnchorPoint(cc.p(0, 0.5))

	-- 	-- 
	-- 	local count = ui.newTTFLabel({text = prop.count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 	count:setAnchorPoint(cc.p(0, 0.5))

	-- 	if propDB.canUse == 1 then -- 可以使用
	-- 		-- 使用按钮
	-- 	end
	-- else -- 商城
	-- 	-- 售价
	-- 	local label = ui.newTTFLabel({text = CommonText[198] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 55, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 	label:setAnchorPoint(cc.p(0, 0.5))

	-- 	local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(cell)
	-- 	view:setPosition(label:getPositionX() + label:getContentSize().width + view:getContentSize().width / 2, label:getPositionY())

	-- 	local price = ui.newBMFontLabel({text = UiUtil.strNumSimplify(propDB.price), font = "fnt/num_2.fnt", x = view:getPositionX() + view:getContentSize().width / 2, y = view:getPositionY()}):addTo(cell)
	-- 	price:setAnchorPoint(cc.p(0, 0.5))

	-- 	-- 购买按钮
	-- 	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	-- 	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	-- 	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onBtnCallback))
	-- 	btn.propId = propDB.propId
	-- 	btn:setLabel(CommonText[119])
	-- 	btn.itemView = bagView
	-- 	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
	-- end

	return cell
end

function ScoreTableView:onBtnCallback(tag, sender)
	local function doneCallback()
		Loading.getInstance():unshow()
		Toast.show(CommonText[295])
	end

	Loading.getInstance():show()
	ArenaBO.asynUseScore(doneCallback, sender.propId)

	-- local propId = sender.propId

	-- if self.m_viewFor == VIEW_FOR_ALL_MINE then  -- 使用
	-- 	local function doneUserProp()
	-- 		Toast.show("道具使用成功")

	-- 		local count = UserMO.getResource(ITEM_KIND_PROP, propId)
	-- 		if count <= 0 then  -- 使用完了
	-- 			self.m_props = PropMO.getAllProps()
	-- 			self:reloadData()
	-- 		else
	-- 			local label = sender.propLabel
	-- 			if label then
	-- 				label:setString(count)
	-- 			end
	-- 		end
	-- 	end

	-- 	PropBO.asynUseProp(doneUserProp, propId, 1)
	-- else
	-- 	local itemView = sender.itemView
	-- 	local worldPoint = itemView:getParent():convertToWorldSpace(cc.p(itemView:getPositionX(), itemView:getPositionY()))
	-- 	-- print("pos: x:", worldPoint.x, "y:", worldPoint.y)

	-- 	local BagBuyDialog = require("app.dialog.BagBuyDialog")
	-- 	local dialog = BagBuyDialog.new(worldPoint, propId)
	-- 	dialog:push()
	-- 	dialog:showUI()
	-- end
end

-- function ScoreTableView:cellTouched(cell, index)
-- 	gprint("ScoreTableView index:", index)
-- end

return ScoreTableView
