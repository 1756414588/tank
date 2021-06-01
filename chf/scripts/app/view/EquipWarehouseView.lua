

-- 装备仓库view

local EquipWarehouseView = class("EquipWarehouseView", UiNode)

function EquipWarehouseView:ctor()
	EquipWarehouseView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function EquipWarehouseView:onEnter()
	EquipWarehouseView.super.onEnter(self)
	-- 装备仓库
	self:setTitle(CommonText[130])

	self.m_equipHandler = Notify.register(LOCAL_EQUIP_EVENT, handler(self, self.onEquipUpdate))

	self:showUI()
end

function EquipWarehouseView:onExit()
	EquipWarehouseView.super.onExit(self)
	
	if self.m_equipHandler then
		Notify.unregister(self.m_equipHandler)
		self.m_equipHandler = nil
	end
end

function EquipWarehouseView:onEquipUpdate(event)
	self:showUI()
end

function EquipWarehouseView:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 +  container:getContentSize().height / 2)
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container.status = 1 -- 显示装备
		self.m_container = container
	end

	local container = self.m_container

	container:removeAllChildren()

	-- local bg = display.newScale9Sprite(IMAGE_COMMON .. "a.png"):addTo(self.m_container)
	-- bg:setPreferredSize(cc.size(self.m_container:getContentSize().width, self.m_container:getContentSize().height))
	-- bg:setPosition(self.m_container:getContentSize().width / 2, self.m_container:getContentSize().height / 2)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	-- line:setScaleY(-1)
	line:setPosition(container:getContentSize().width / 2, 160)

	if container.status == 1 then  -- 显示列表
		local equips = EquipMO.getFreeEquipsAtPos()
		-- 容量
		local label = ui.newTTFLabel({text = CommonText[139] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 110, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_container)
		label:setAnchorPoint(cc.p(0, 0.5))

		local count = ui.newTTFLabel({text = #equips .. "/" .. UserMO.equipWarhouse_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2]}):addTo(self.m_container)
		self.m_capacityLabel = count

		local function doneExpand()
			Loading.getInstance():unshow()
			Toast.show(CommonText[407])  -- 容量增加
			self.m_capacityLabel:setString(#equips .. "/" .. UserMO.equipWarhouse_)
		end

		local function onExpandCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			if EquipBO.hasBuyCapacityNum() >= EQUIP_CAPACITY_MAX_TIME then  -- 扩容次数已用完
				Toast.show(CommonText[409])
				return
			end

			local takeCoin = EquipBO.buyCapacityTakCoin()
			-- 花费金币扩容
			require("app.dialog.ConfirmDialog").new(string.format(CommonText[140], takeCoin, EQUIP_CAPACITY_DELTA_NUM), function()
					if UserMO.getResource(ITEM_KIND_COIN) < takeCoin then
						local resDat = UserMO.getResourceData(ITEM_KIND_COIN)
						Toast.show(resDat.name .. CommonText[199])
						return
					end

					Loading.getInstance():show()
					EquipBO.asynUpCapacity(doneExpand)
				end):push()
		end

		-- 扩充
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local expandBtn = MenuButton.new(normal, selected, nil, onExpandCallback):addTo(self.m_container)
		expandBtn:setPosition(118, 50)
		expandBtn:setLabel(CommonText[136])

		-- -- 穿戴
		-- local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		-- local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		-- local wearBtn = MenuButton.new(normal, selected, nil, nil):addTo(self.m_container)
		-- wearBtn:setPosition(self.m_container:getContentSize().width - 278, 50)
		-- wearBtn:setLabel(CommonText[137])

		local function onSellCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			container.status = 2
			self:showUI()
		end

		-- 出售
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local sellBtn = MenuButton.new(normal, selected, nil, onSellCallback):addTo(self.m_container)
		sellBtn:setPosition(self.m_container:getContentSize().width - 90, 50)
		sellBtn:setLabel(CommonText[138])
	elseif container.status == 2 then  -- 出售
		-- 全选
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onAllCheckedChanged)):addTo(container)
		checkBox:setAnchorPoint(cc.p(0, 0.5))
		checkBox:setPosition(30, 50)

		local label = ui.newTTFLabel({text = CommonText[141], font = G_FONT, size = FONT_SIZE_SMALL, x = checkBox:getPositionX() + checkBox:getContentSize().width + 20, y = checkBox:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))

		-- 已选数量
		local chosenLabel = ui.newTTFLabel({text = CommonText[142], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 110, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		chosenLabel:setAnchorPoint(cc.p(0, 0.5))

		local num = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, x = chosenLabel:getPositionX() + chosenLabel:getContentSize().width + 10, y = chosenLabel:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		num:setAnchorPoint(cc.p(0, 0.5))
		container.numLabel_ = num

		-- 出售可获
		local label = ui.newTTFLabel({text = CommonText[143], font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = 110, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))

		local stoneView = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(container)
		stoneView:setPosition(label:getPositionX() + label:getContentSize().width + stoneView:getBoundingBox().size.width / 2, label:getPositionY())

		local stone = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, x = stoneView:getPositionX() + stoneView:getBoundingBox().size.width / 2, y = stoneView:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		stone:setAnchorPoint(cc.p(0, 0.5))
		container.stoneLabel_ = stone

		local function onExitCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			container.status = 1
			self:showUI()
		end

		-- 退出
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local exitBtn = MenuButton.new(normal, selected, nil, onExitCallback):addTo(container)
		exitBtn:setPosition(container:getContentSize().width - 250, 50)
		exitBtn:setLabel(CommonText[144])

		-- 确定出售
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local exitBtn = MenuButton.new(normal, selected, nil, handler(self, self.onSellCallback)):addTo(container)
		exitBtn:setPosition(container:getContentSize().width - 90, 50)
		exitBtn:setLabel(CommonText[145])
	end

	local function onCheckEquip(event)  -- 有装备被选中
		if self.m_container.status ~= 2 then return end

		self:onShowChecked()
	end

	local EquipWarehouseTableView = require("app.scroll.EquipWarehouseTableView")
	local view = EquipWarehouseTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 160), container.status):addTo(container)
	view:addEventListener("CHECK_EQUIP_EVENT", onCheckEquip)
	view:setPosition(0, 160)
	view:reloadData()
	container.equipTableView_ = view
end

function EquipWarehouseView:onAllCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	if self.m_container and self.m_container.equipTableView_ then
		self.m_container.equipTableView_:checkAll(isChecked)

		self:onShowChecked()
	end
end

-- 根据当前选中的状态，更新显示已选数量，和可出售获得
function EquipWarehouseView:onShowChecked()
	if self.m_container.status ~= 2 then return end

	local checkData = self.m_container.equipTableView_:getCheckedNumPrice()

	self.m_container.numLabel_:setString(checkData.num)
	self.m_container.stoneLabel_:setString(checkData.total)
end

function EquipWarehouseView:onSellCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local checkData = self.m_container.equipTableView_:getCheckedNumPrice()
	if checkData.num <= 0 then
		Toast.show(CommonText[146])  -- 选择装备出售
		return
	end

	Loading.getInstance():show()

	local function doneSellEquip(stasAwards)
		Loading.getInstance():unshow()
		UiUtil.showAwards(stasAwards)
	end

	local equips = self.m_container.equipTableView_:getCheckedEquips()
	EquipBO.asynSellEquip(doneSellEquip, equips)
end

return EquipWarehouseView