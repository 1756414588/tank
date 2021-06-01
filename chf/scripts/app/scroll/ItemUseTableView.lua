
------------------------------------------------------------------------------
-- 物品使用TableView
------------------------------------------------------------------------------

local ItemUseTableView = class("ItemUseTableView", TableView)

-- kind是ITEM_KIND_ACCEL,是表示加速队列特殊处理
function ItemUseTableView:ctor(size, kind, id, param)
	ItemUseTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	self.m_kind = kind
	self.m_id = id
	self.m_param = param or {}

	self.m_propIds = PropBO.getCanUsePopIds(kind, id)
	-- gdump(self.m_propIds, "[ItemUseTableView] prop")
	-- gdump(self.m_param, "[ItemUseTableView] param")
end

function ItemUseTableView:onExit()
	gprint("ItemUseTableView:onExit ... ")
	ItemUseTableView.super.onExit(self)
end

function ItemUseTableView:numberOfCells()
	return #self.m_propIds
end

function ItemUseTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ItemUseTableView:createCellAtIndex(cell, index)
	ItemUseTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local propId = self.m_propIds[index]
	local count = UserMO.getResource(ITEM_KIND_PROP, propId)
	local propDB = PropMO.queryPropById(propId)

	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, propId):addTo(cell)
	itemView:setPosition(80, self.m_cellSize.height / 2)

	-- 名称
	local name = ui.newTTFLabel({text = PropMO.getPropName(propId), font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 114, color = COLOR[propDB.color]}):addTo(cell)

	local desc = ui.newTTFLabel({text = propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(200, 80)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	if count > 0 then
		-- 数量
		local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 25, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		-- 
		local countLabel = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		countLabel:setAnchorPoint(cc.p(0, 0.5))

		-- 使用按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onUseCallback))
		btn:setLabel(CommonText[86])
		btn.propId = propId
		cell:addButton(btn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 22)

		if self.m_param.disabled then
			btn:setEnabled(false)
		end
	else
		if propDB.canBuy == 1 then
			-- 金币价格
			local itemView = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(cell)
			itemView:setAnchorPoint(cc.p(0, 0.5))
			itemView:setPosition(self.m_cellSize.width - 120 - 25, 114)

			local countLabel = ui.newTTFLabel({text = propDB.price, font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX() + itemView:getContentSize().width + 5, y = itemView:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			countLabel:setAnchorPoint(cc.p(0, 0.5))

			-- 购买使用
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
			local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBuyUseCallback))
			btn:setLabel(CommonText[87])
			btn.propId = propId
			cell:addButton(btn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 22)

			if self.m_param.disabled then
				btn:setEnabled(false)
			end
		end
		
	end

	return cell
end

function ItemUseTableView:onUseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local propId = sender.propId
	if UserMO.getResource(ITEM_KIND_PROP, propId) <= 0 then  -- 购买使用
		return
	end

	if self.m_isUseProp then return end

	self.m_isUseProp = true

	self:useProp(propId)
end

function ItemUseTableView:onBuyUseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_isUseProp then return end

	local propId = sender.propId
	local propDB = PropMO.queryPropById(propId)

	local resData = UserMO.getResourceData(ITEM_KIND_COIN)

	local function doneBuyProp()
		scheduler.performWithDelayGlobal(function()
				self:useProp(propId)  -- 购买成功，直接使用
			end, 0.01)
	end

	local function gotoBuyProp()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < propDB.price then -- 金币不足
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		self.m_isUseProp = true

		Loading.getInstance():show()
		PropBO.asynBuyProp(doneBuyProp, propId, 1)
	end

	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[20133], propDB.price, resData.name), function() gotoBuyProp() end):push()
	else
		gotoBuyProp()
	end
end

function ItemUseTableView:useProp(propId)
	if self.m_kind == ITEM_KIND_ACCEL then
		if self.m_id == ACCEL_ID_BUILD then
			self:onSpeedBuild(propId)
		elseif self.m_id == ACCEL_ID_TANK then
			self:onSpeedTank(propId)
		elseif self.m_id == ALLEL_ID_SCIENCE then
			self:onSpeedScience(propId)
		end
	else
		local function doneUse(awards)
			Loading.getInstance():unshow()
			local offset = self:getContentOffset()
			self:reloadData()
			self:setContentOffset(offset)
			
			local resData = UserMO.getResourceData(ITEM_KIND_PROP, propId)
			Toast.show(CommonText[84] .. resData.name)
			if awards then
				UiUtil.showAwards(awards)
			end
			self.m_isUseProp = false
		end

		if propId == PROP_ID_FREE_WAR_72 or propId == PROP_ID_FREE_WAR_24 or propId == PROP_ID_FREE_WAR_8 then  -- 是免战
			local attack = false
			local armies = ArmyMO.getArmiesByState(ARMY_STATE_MARCH)
			for index = 1, #armies do
				local army = armies[index]
				-- local pos = WorldMO.decodePosition(army.target)
				-- local mine = WorldBO.getMineAt(pos)
				-- if not mine then
				if army.type == ARMY_TARGET_TYPE_PLAYER then  -- 有人被攻击了
					attack = true
					break
				end
			end

			if attack then -- 不能使用保护罩
				self.m_isUseProp = false
				self:reloadData()
				Loading.getInstance():unshow()
				Toast.show(CommonText[10006])
				return
			end

			Loading.getInstance():show()
			PropBO.asynUseProp(doneUse, propId, 1)
		else
			local propDB = PropMO.queryPropById(propId)
			if propDB.batchUse == 1 then  -- 可以批量使用
				local PropUseDialog = require("app.dialog.PropUseDialog")
				PropUseDialog.new(propId, doneUse):push()
				self.m_isUseProp = false
			else
				Loading.getInstance():show()
				PropBO.asynUseProp(doneUse, propId, 1)
			end
		end
	end
end

function ItemUseTableView:onDoneSpeed()
	Loading.getInstance():unshow()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)

	self.m_isUseProp = false
end

function ItemUseTableView:onSpeedBuild(propId)
	if self.m_param.wildPos and self.m_param.wildPos > 0 then  -- 城外
		if BuildMO.getWildBuildStatus(self.m_param.wildPos) ~= BUILD_STATUS_UPGRADE then
			return
		end
	else
		if BuildMO.getBuildStatus(self.m_param.buildingId) ~= BUILD_STATUS_UPGRADE then  -- 升级已经结束了
			return
		end
	end

	local schedulerId = 0
	if self.m_param.wildPos and self.m_param.wildPos > 0 then
		schedulerId = BuildMO.millPos_[self.m_param.wildPos].upgradeId
	else
		schedulerId = BuildMO.buildData_[self.m_param.buildingId].upgradeId
	end

	local count = 0
	local propDB = PropMO.queryPropById(propId)
	if propDB.batchUse == 1 then  -- 可以批量使用
		local PropUseDialog = require("app.dialog.AccelUseDialog")
		self.m_isUseProp = false
		PropUseDialog.new(propId, function (num)
			if num then count = num end
			if self.m_param then
				Loading.getInstance():show()
				BuildBO.asynSpeedUpgrade(handler(self, self.onDoneSpeed), self.m_param.buildingId, 2, propId, self.m_param.wildPos, count)
			else
				Toast.show(CommonText[1837][1])
			end
		end,schedulerId):push()
	end
end

function ItemUseTableView:onSpeedTank(propId)
	-- Loading.getInstance():show()
	-- if self.m_param.isRefit then
	-- 	TankBO.asynSpeedRefit(handler(self, self.onDoneSpeed), self.m_param.schedulerId, 2, propId)
	-- else
	-- 	TankBO.asynSpeedProduct(handler(self, self.onDoneSpeed), self.m_param.buildingId, self.m_param.schedulerId, 2, propId)
	-- end

	local function doSpeed(count)
		Loading.getInstance():show()
		if self.m_param.isRefit then
			TankBO.asynSpeedRefit(handler(self, self.onDoneSpeed), self.m_param.schedulerId, 2, propId,count)
		else
			TankBO.asynSpeedProduct(handler(self, self.onDoneSpeed), self.m_param.buildingId, self.m_param.schedulerId, 2, propId,count)
		end
	end

	local count = 0
	local propDB = PropMO.queryPropById(propId)
	if propDB.batchUse == 1 then  -- 可以批量使用
		local PropUseDialog = require("app.dialog.AccelUseDialog")
		self.m_isUseProp = false
		PropUseDialog.new(propId, function (num)
			if num then count = num end
			if self.m_param then
				doSpeed(count)
			else
				Toast.show(CommonText[1837][2])
			end
		end,self.m_param.schedulerId):push()
	end
end

function ItemUseTableView:onSpeedScience(propId)
	-- Loading.getInstance():show()
	-- ScienceBO.asynSpeedProduct(handler(self, self.onDoneSpeed), self.m_param.buildingId, self.m_param.schedulerId, 2, propId)

	local count = 0
	local propDB = PropMO.queryPropById(propId)
	if propDB.batchUse == 1 then  -- 可以批量使用
		local PropUseDialog = require("app.dialog.AccelUseDialog")
		self.m_isUseProp = false
		PropUseDialog.new(propId, function (num)
			if num then count = num end
			if self.m_param then
				Loading.getInstance():show()
				ScienceBO.asynSpeedProduct(handler(self, self.onDoneSpeed), self.m_param.buildingId, self.m_param.schedulerId, 2, propId, count)
			else
				Toast.show(CommonText[1837][2])
			end
		end,self.m_param.schedulerId):push()
	end
end

return ItemUseTableView
