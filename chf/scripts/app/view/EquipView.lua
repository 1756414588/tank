
-- 部队装备view

local EquipConfig = {
{wire = {p = cc.p(-124, 112), a = cc.p(0, 1)}, pos = EQUIP_POS_ATK, index = ATTRIBUTE_INDEX_ATTACK}, -- 攻击
{wire = {p = cc.p(-124, -10), a = cc.p(0, 0)}, pos = EQUIP_POS_HIT, index = ATTRIBUTE_INDEX_HIT}, -- 命中
{wire = {p = cc.p(-124, -112), a = cc.p(0, 0)}, pos = EQUIP_POS_CRIT, index = ATTRIBUTE_INDEX_CRIT}, -- 暴击
{wire = {p = cc.p(124, 112), a = cc.p(1, 1)}, pos = EQUIP_POS_HP, index = ATTRIBUTE_INDEX_HP}, -- 生命
{wire = {p = cc.p(124, 10), a = cc.p(1, 1)}, pos = EQUIP_POS_DODGE, index = ATTRIBUTE_INDEX_DODGE}, -- 闪避
{wire = {p = cc.p(124, -112), a = cc.p(1, 0)}, pos = EQUIP_POS_CRIT_DEF, index = ATTRIBUTE_INDEX_CRIT_DEF}, -- 抗暴
}

local EquipView = class("EquipView", UiNode)

function EquipView:ctor(enterStyle)
	enterStyle = enterStyle or UI_ENTER_NONE

	EquipView.super.ctor(self, "image/common/bg_ui.jpg", enterStyle)
end

function EquipView:onEnter()
	EquipView.super.onEnter(self)

	-- 部队装备
	self:setTitle(CommonText[125])

	self.m_equipHandler = Notify.register(LOCAL_EQUIP_EVENT, handler(self, self.onEquipUpdate))

	-- 背景框
	local equipBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	equipBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 12 - 30, 520))
	equipBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 102 - equipBg:getContentSize().height / 2)

	local node = display.newNode():addTo(equipBg)
	node:setContentSize(equipBg:getContentSize())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	self.m_equipNode = node

	-- 阵型背景框
	local formatBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	formatBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 12 - 50, 296))
	formatBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 628 - formatBg:getContentSize().height / 2)

	self:showFormation(formatBg)
end

function EquipView:onExit()
	EquipView.super.onExit(self)
	
	if self.m_equipHandler then
		Notify.unregister(self.m_equipHandler)
		self.m_equipHandler = nil
	end
	self.m_warehouseButton = nil
end

-- animation: 是否动画显示装备。如果是进入ui则为true，动画显示，如果是更新ui，则为false
function EquipView:showEquip(formatPosition, animation)
	self.m_equipNode:stopAllActions()
	self.m_equipNode:removeAllChildren()

	local function gotoDetail(tag, sender)
		-- require("app.dialog.DetailEquipSuitDialog").new(formatPosition):push()
		require("app.dialog.DetailTextDialog").new(EquipMO.getShowSuit(formatPosition)):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, gotoDetail):addTo(self.m_equipNode)
	detailBtn:setPosition(64, 150)

	local function gotoLottery(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:pop(function()
				if UserMO.level_ >= UserMO.querySystemId(80) then
					UiDirector.push(require("app.view.EnergyCoreView").new(BUILD_ID_ENERGYCORE))
				else
					UiDirector.push(require("app.view.LotteryEquipView").new())
				end
			end)
	end

	-- 抽装备
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local lotteryBtn = MenuButton.new(normal, selected, nil, gotoLottery):addTo(self.m_equipNode)
	lotteryBtn:setPosition(180, 150)
	lotteryBtn:setLabel(CommonText[555][1])
	if UserMO.level_ >= UserMO.querySystemId(80) then
		lotteryBtn:setLabel(CommonText[8000])
	end

	local function gotoWarehouse(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.EquipWarehouseView").new():push()
	end

	-- 装备仓库
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoWarehouse):addTo(self.m_equipNode)
	btn:setPosition(340, 150)
	btn:setLabel(CommonText[130])
	self.m_warehouseButton = btn

	local function allEquipCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:doAllEquip(sender.formatPosition)
	end

	-- 一键装备
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, allEquipCallback):addTo(self.m_equipNode)
	btn:setPosition(500, 150)
	btn:setLabel(CommonText[91] .. CommonText[7])
	btn.formatPosition = formatPosition

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(self.m_equipNode)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(self.m_equipNode:getContentSize().width / 2, 106)

	local attrValue = EquipBO.getFormationEquipAttrData(formatPosition)
	-- gdump(attrValue, "EquipView:showEquip")

	local function gotoEquip(itemView)
		ManagerSound.playNormalButtonSound()
		local config = EquipConfig[itemView.index]

		self:doGoToEquip(formatPosition, config.pos)
	end

	-- 装备的各个属性
	for index = 1, 6 do
		local seq = {1, 2, 3, 4, 5, 6}
		local config = EquipConfig[seq[index]]
		local attrData = attrValue[config.index]

		local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = attrData.attrName}):addTo(self.m_equipNode)
		if index <= 3 then
			itemView:setPosition(50 + (index - 1) * 190, 78)
		else
			itemView:setPosition(50 + (index - 4) * 190, 35)
		end

		local name = ui.newTTFLabel({text = attrData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX() + 30, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
		name:setAnchorPoint(cc.p(0, 0.5))
		name:setColor(COLOR[11])

		local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
		value:setAnchorPoint(cc.p(0, 0.5))
		if EquipBO.hasEquipAtPos(formatPosition, config.pos) then
			name:setColor(cc.c3b(235, 218, 134))
			value:setColor(cc.c3b(235, 218, 134))
		else  -- 没有装备
			value:setColor(COLOR[11])
		end
	end

	local tankTag = display.newSprite(IMAGE_COMMON .. "icon_equip_tank_capture.png"):addTo(self.m_equipNode)
	tankTag:setPosition(self.m_equipNode:getContentSize().width / 2, 360)


	local function gotoEnergySpar()
		ManagerSound.playNormalButtonSound()
		if EnergySparMO.getOpenLv(UserMO.level_) then
			require("app.view.EnergySparView").new(ENERGYSPAR_VIEW_INSET, self.m_chosenPosition):push()
		else
			Toast.show(string.format(CommonText[290], ENERGYSPAR_OPEN_LEVEL, CommonText[941][1]))
		end
	end 
	---能晶系统
	local normal = display.newSprite(IMAGE_COMMON .. "btn_energy.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_energy.png")
	local btn = MenuButton.new(normal, selected, nil, gotoEnergySpar):addTo(self.m_equipNode)
	btn:setPosition(280, 365)
	self.guideBtn = btn
	
	armature_add(IMAGE_ANIMATION .. "effect/xingpian_output.pvr.ccz", IMAGE_ANIMATION .. "effect/xingpian_output.plist", IMAGE_ANIMATION .. "effect/xingpian_output.xml")
	local armature = armature_create("xingpian_output")
	armature:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
	armature:getAnimation():playWithIndex(0)
	armature:addTo(btn)


	local function showPositionEquip(index, animation)
		local config = EquipConfig[index]
		local attrData = attrValue[config.index]

		local label = ui.newTTFLabel({text = attrData.name, font = G_FONT, size = FONT_SIZE_SMALL}):addTo(tankTag)
		if index <= 3 then
			label:setAnchorPoint(cc.p(1, 0.5))
			label:setPosition(tankTag:getContentSize().width / 2 - 126, tankTag:getContentSize().height / 2 + 103 - (index - 1) * 103)
		else
			label:setAnchorPoint(cc.p(0, 0.5))
			label:setPosition(tankTag:getContentSize().width / 2 + 126, tankTag:getContentSize().height / 2 + 103 - (index - 4) * 103)
		end
		if EquipBO.hasEquipAtPos(formatPosition, config.pos) then
		else  -- 没有装备
			label:setColor(COLOR[11])
		end

		local itemView = nil
		if EquipBO.hasEquipAtPos(formatPosition, config.pos) then
			local equip = EquipBO.getEquipAtPos(formatPosition, config.pos)
			itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv})
		else
			itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, 0, {pos = config.pos})

			local equips = EquipMO.getFreeEquipsAtPos(config.pos)
			if #equips > 0 then
				UiUtil.showTip(itemView, #equips)
			end
		end
		itemView:addTo(tankTag)
		itemView.index = index
		itemView:setScale(0.9)
		if index <= 3 then
			itemView:setPosition(label:getPositionX() - 100, label:getPositionY())
		else
			itemView:setPosition(label:getPositionX() + 100, label:getPositionY())
		end
		UiUtil.createItemDetailButton(itemView, nil, nil, gotoEquip)

		local wireSprite = display.newSprite(IMAGE_COMMON .. "equip/equip_w_" .. 1 .. "_" .. index .. ".png"):addTo(tankTag)
		wireSprite:setPosition(tankTag:getContentSize().width / 2 + config.wire.p.x, tankTag:getContentSize().height / 2 + config.wire.p.y)
		wireSprite:setAnchorPoint(config.wire.a)

		if animation then
			itemView:setScale(0.6)
			itemView:runAction(cc.ScaleTo:create(0.15, 0.9))

			label:setOpacity(0)
			label:runAction(transition.sequence{cc.DelayTime:create(0.18), cc.FadeIn:create(0.18)})

			wireSprite:setOpacity(0)
			wireSprite:runAction(transition.sequence{cc.DelayTime:create(0.18), cc.FadeIn:create(0.18)})
		end
	end
	
	if animation then
		local seq = {3, 2, 1, 4, 5, 6}
		local deltaTime = 0.14
		self.m_equipNode:runAction(transition.sequence({
			cc.DelayTime:create(deltaTime), cc.CallFunc:create(function() showPositionEquip(seq[1], animation) end),
			cc.DelayTime:create(deltaTime), cc.CallFunc:create(function() showPositionEquip(seq[2], animation) end),
			cc.DelayTime:create(deltaTime), cc.CallFunc:create(function() showPositionEquip(seq[3], animation) end),
			cc.DelayTime:create(deltaTime), cc.CallFunc:create(function() showPositionEquip(seq[4], animation) end),
			cc.DelayTime:create(deltaTime), cc.CallFunc:create(function() showPositionEquip(seq[5], animation) end),
			cc.DelayTime:create(deltaTime), cc.CallFunc:create(function() showPositionEquip(seq[6], animation) end)}))
	else
		for index = 1, 6 do
			showPositionEquip(index, animation)
		end
	end

	-- 已装备
	self.m_equipNumLabel:setString(CommonText[126] .. EquipBO.getTotalEquipNum() .. "/36")

	-- 显示红点提示
	local equips = EquipMO.getFreeEquipsAtPos()
	-- 可以装备的
	local canEquips = EquipMO.getFreeCanEquips()

	-- 闲置装备
	local label = ui.newTTFLabel({text = CommonText[479][1] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 280, y = 215, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = #canEquips, font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 件
	local label = ui.newTTFLabel({text = CommonText[237][5], font = G_FONT, size = FONT_SIZE_TINY, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 升级材料
	local label = ui.newTTFLabel({text = CommonText[479][2] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 280, y = 190, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = (#equips - #canEquips), font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 件
	local label = ui.newTTFLabel({text = CommonText[237][5], font = G_FONT, size = FONT_SIZE_TINY, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- self:showEquipSuite()

	if #equips > 0 then
		UiUtil.showTip(self.m_warehouseButton, #equips)
	else
		UiUtil.unshowTip(self.m_warehouseButton)
	end
end

function EquipView:showFormation(formatBg)
	-- local formation = TankMO.getFormationByType(FORMATION_FOR_FIGHT)
	local formation = {1, 2, 3, 4, 5, 6}

	local function chosenFormation(event)
		if self.m_chosenPosition ~= event.position then
			self.m_chosenPosition = event.position
			-- gprint("EquipView:showFormation 触摸到了位置:", self.m_chosenPosition)
			self:showEquip(self.m_chosenPosition, true)
			self:showFormationMaxAttrChosen()
		end
	end

	local function exchangeFormation(event)
		Loading.getInstance():show()

		local from = event.from
		local to = event.to

		local function doneCallback()  -- 交换两个位置的装备
			Loading.getInstance():unshow()
			self.m_chosenPosition = event.to
			gprint("EquipView: showFormation:", self.m_chosenPosition)
			self:showEquip(self.m_chosenPosition)
			
			local tmp = self.m_formatEquipLabel[from]
			self.m_formatEquipLabel[from] = self.m_formatEquipLabel[to]
			self.m_formatEquipLabel[to] = tmp

			self:showFormationMaxAttr()
		end

		-- gprint("从：", from, "到：", to)
		EquipBO.asynEquip(doneCallback, 0, from, to)
	end

	-- 已装备
	local equipLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = formatBg:getContentSize().width / 2, y = formatBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(formatBg)
	self.m_equipNumLabel = equipLabel

	self.m_chosenPosition = 0

	-- 前排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_17.png", 24, 198):addTo(formatBg)

	-- 后排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_18.png", 24, 68):addTo(formatBg)

	local ArmyFormationView = require("app.view.ArmyFormationView")
	local view = ArmyFormationView.new(FORMATION_FOR_EQUIP, formation, TankBO.getMyFormationLockData()):addTo(formatBg, 10)
	view:addEventListener("FORMATION_BEGAN_EVENT", chosenFormation)
	view:addEventListener("EXCHANGE_FORMATION_EVENT", exchangeFormation)  -- 阵型有交换位置事件
	view:setScale(0.78)
	view:updateOffset(cc.p(54, 4))
	view:setPosition(formatBg:getContentSize().width / 2, 5)
	local firstPos = 0
	for index = 1, FIGHT_FORMATION_POS_NUM do
		if not TankBO.isFormationLockAtPosition(index) then
			firstPos = index
			break
		end
	end
	self.m_formatEquipLabel = {}
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local node = view:getNodeAtPosition(index)
		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = node:getContentSize().width / 2, y = 35, align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		self.m_formatEquipLabel[index] = label
	end

	view:onBeganPosition(firstPos)  -- 初始选择第一个开启的位置

	self:showFormationMaxAttr()
end

function EquipView:showFormationMaxAttr()
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local label = self.m_formatEquipLabel[index]

		if TankBO.isFormationLockAtPosition(index) then
			label:setString("")
		else
			local maxIndex = 0
			local maxValue = 0

			local attrValue = EquipBO.getFormationEquipAttrData(index)
			for index, attr in pairs(attrValue) do
				if attr.value > maxValue then
					maxValue = attr.value
					maxIndex = index
				end
			end

			if maxIndex > 0 then
				label:setString(CommonText[237][8] .. attrValue[maxIndex].name)
			else
				label:setString("")
			end
		end
	end
	self:showFormationMaxAttrChosen()
end

function EquipView:showFormationMaxAttrChosen()
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local label = self.m_formatEquipLabel[index]
		if index == self.m_chosenPosition then
			label:setColor(cc.c3b(255, 138, 18))
		else
			label:setColor(COLOR[11])
		end
	end
end

function EquipView:showEquipSuite()
	-- 蓝色装备数量
	local blueNum = EquipBO.getQualityEquipNumAtFormatIndex(self.m_chosenPosition, 3)
	local purpleNum = EquipBO.getQualityEquipNumAtFormatIndex(self.m_chosenPosition, 4)

	-- 蓝色套装
	local blueSuit = ui.newTTFLabel({text = CommonText[414][1], font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = 510, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	blueSuit:setAnchorPoint(cc.p(0, 0.5))

	-- 全部属性加成
	local desc = ui.newTTFLabel({text = ":" .. CommonText[413][3] .. EQUIP_BLUE_SUIT_ADD .. "%(" .. blueNum .. "/6)", font = G_FONT, size = FONT_SIZE_TINY, x = blueSuit:getPositionX() + blueSuit:getContentSize().width, y = blueSuit:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	desc:setAnchorPoint(cc.p(0, 0.5))

	if blueNum >= 6 then  -- 激活
	else
		desc:setColor(cc.c3b(138, 138, 138))
	end

	-- 紫色套装
	local purplesuit = ui.newTTFLabel({text = CommonText[414][2], font = G_FONT, size = FONT_SIZE_TINY, x = blueSuit:getPositionX(), y = blueSuit:getPositionY() - 22, color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	purplesuit:setAnchorPoint(cc.p(0, 0.5))

	-- 全部属性加成
	local desc = ui.newTTFLabel({text = ":" .. CommonText[413][3] .. EQUIP_PURPLE_SUIT_ADD .. "%(" .. purpleNum .. "/6)", font = G_FONT, size = FONT_SIZE_TINY, x = purplesuit:getPositionX() + purplesuit:getContentSize().width, y = purplesuit:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_equipNode)
	desc:setAnchorPoint(cc.p(0, 0.5))

	if purpleNum >= 6 then  -- 激活
	else
		desc:setColor(cc.c3b(138, 138, 138))
	end
end

function EquipView:onEquipUpdate(event)
	self:showEquip(self.m_chosenPosition)
	self:showFormationMaxAttr()
end

function EquipView:doAllEquip(formatPosition, callback)
	formatPosition = formatPosition or self.m_chosenPosition

	local update, on, off = EquipBO.checkAllEquip(formatPosition)
	if update then
		local function doneAllEquip()
			Loading.getInstance():unshow()
			self:showEquip(self.m_chosenPosition)
			if callback then callback() end
		end

		Loading.getInstance():show()
		EquipBO.asynAllEquip(doneAllEquip, formatPosition, on, off)
	else
		if callback then callback() end
	end
end

function EquipView:doGoToEquip(formatPosition, equipPos)
	formatPosition = formatPosition or self.m_chosenPosition

	if EquipBO.hasEquipAtPos(formatPosition, equipPos) then  -- 有装备
		require("app.dialog.EquipDialog").new(formatPosition, equipPos):push()
	else
		require("app.view.EquipExchangeView").new(formatPosition, equipPos):push()
	end
end

function EquipView:doCommand(command, callback)
	if not command then return end

	if command == "equipOneKey" then
		self:doAllEquip(nil, callback)
	elseif command == "equipUpgrade" then
		self:doGoToEquip(nil, EQUIP_POS_ATK)
		if callback then callback() end
	end
end

return EquipView
