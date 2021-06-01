
-- 装备升级view

local EquipUpgradeView = class("EquipUpgradeView", UiNode)

function EquipUpgradeView:ctor(keyId)
	EquipUpgradeView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)

	self.m_keyId = keyId -- 装备的keyId

	gprint("[EquipUpgradeView] keyId :", self.m_keyId)
end

function EquipUpgradeView:onEnter()
	EquipUpgradeView.super.onEnter(self)
	
	self:showUI()

	-- 装备升级
	self:setTitle(CommonText[7] .. CommonText[79])
end

function EquipUpgradeView:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 +  container:getContentSize().height / 2)
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container.status = 1 -- 显示装备
		self.m_container = container
	end

	self.m_container:removeAllChildren()
	local container = self.m_container

	container.expLabel_ = nil
	container.equipTableView_ = nil

	local equip = EquipMO.getEquipByKeyId(self.m_keyId)
	local equipDB = EquipMO.queryEquipById(equip.equipId)
	local maxLevel = EquipMO.queryMaxLevelByQuality(equipDB.quality)
	local max = equip.level >= maxLevel

	local nxtEquipLevel = EquipMO.queryEquipLevel(equipDB.quality, equip.level + 1)

	local title = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = container:getContentSize().width / 2, y = container:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	if equip.formatPos == 0 then
		title:setString(CommonText[210])  -- 仓库中的装备
	else
		title:setString(string.format(CommonText[127], equip.formatPos))
	end

	local itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(container)
	itemView:setPosition(95, container:getContentSize().height - 90)
	UiUtil.createItemDetailButton(itemView)

	local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_MEDIUM, x = 170, y = container:getContentSize().height - 60, color = COLOR[equipDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 本次提升:EXP
	local str = max and ErrorText.text528 or CommonText[209] .. ":EXP"
	local label = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, x = 360, y = container:getContentSize().height - 60, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = max and "" or "+0", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))
	container.expLabel_ = value

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(430, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(430 + 4, 26)}):addTo(container)
	bar:setPosition(170 + bar:getContentSize().width / 2, container:getContentSize().height - 96)
	bar:setPercent(max and 1 or (equip.exp / nxtEquipLevel.needExp))
	bar:setLabel(equip.exp .. "/" .. (max and "MAX" or nxtEquipLevel.needExp))

	-- 等级
	local lv = ui.newTTFLabel({text = "LV." .. equip.level, font = G_FONT, size = FONT_SIZE_SMALL, x = bar:getPositionX() + bar:getContentSize().width / 2 - 15, y = bar:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	lv:setAnchorPoint(cc.p(1, 0.5))

	local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_right.png"):addTo(container)
	arrow:setPosition(container:getContentSize().width / 2 + 70, container:getContentSize().height - 132)

	-- 当前等级装置的属性值
	-- local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level)
	local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level, equip.starLv)
	local label = ui.newTTFLabel({text = attrData.name .. "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = arrow:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 下一等级装置的属性值
	-- local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level + 1)
	local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level + 1, equip.starLv)
	local label = ui.newTTFLabel({text = max and "MAX" or (attrData.name .. "+" .. attrData.strValue), font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + 310, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(container:getContentSize().width / 2, container:getContentSize().height - (156 + line:getContentSize().height / 2))

	local equips = EquipMO.getCanUseUpgradeEqups(equip.keyId)
	if #equips <= 0 or max then
		local function gotoCombat(tag, sender)
			ManagerSound.playNormalButtonSound()
			self:pop(function() require("app.view.CombatLevelView").new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_EQUIP)):push() end)
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local btn = MenuButton.new(normal, selected, nil, gotoCombat):addTo(container)
		btn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 340)
		btn:setLabel(CommonText[480][2])  -- 前往关卡

		local function gotoLottery(tag, sender)
			ManagerSound.playNormalButtonSound()
			self:pop(function() require("app.view.LotteryEquipView").new():push() end)
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
		local btn = MenuButton.new(normal, selected, nil, gotoLottery):addTo(container)
		btn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 440)
		btn:setLabel(CommonText[480][3])  -- 抽装备
	else
		local function onCheckEquip(event)  -- 有装备被选中
			self:onShowChecked()
		end

		local EquipUpgradeTableView = require("app.scroll.EquipUpgradeTableView")
		local view = EquipUpgradeTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 160 - 160 - 4), equip.keyId):addTo(container)
		view:addEventListener("CHECK_EQUIP_EVENT", onCheckEquip)
		view:setPosition(0, 160)
		view:reloadData()
		container.equipTableView_ = view
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	-- line:setScaleY(-1)
	line:setPosition(container:getContentSize().width / 2, 160)

	-- 白色
	local checkBox1 = CheckBox.new(nil, nil, handler(self, self.onAllCheckedChanged)):addTo(container)
	checkBox1:setAnchorPoint(cc.p(0, 0.5))
	checkBox1:setPosition(30, 110)
	checkBox1.quality = 1

	local label = ui.newTTFLabel({text = CommonText.color[1][2], font = G_FONT, size = FONT_SIZE_SMALL, x = checkBox1:getPositionX() + checkBox1:getContentSize().width + 20, y = checkBox1:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 绿色
	local checkBox2 = CheckBox.new(nil, nil, handler(self, self.onAllCheckedChanged)):addTo(container)
	checkBox2:setAnchorPoint(cc.p(0, 0.5))
	checkBox2:setPosition(175, 110)
	checkBox2.quality = 2

	local label = ui.newTTFLabel({text = CommonText.color[2][2], font = G_FONT, size = FONT_SIZE_SMALL, x = checkBox2:getPositionX() + checkBox2:getContentSize().width + 20, y = checkBox2:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	--蓝色
	local checkBox3 = CheckBox.new(nil, nil, handler(self, self.onAllCheckedChanged)):addTo(container):rightTo(checkBox2,100)
	checkBox3.quality = 3

	local blue = UiUtil.label(CommonText.color[3][2],nil,COLOR[3]):rightTo(checkBox3,20)

	--紫色
	local checkBox4 = CheckBox.new(nil, nil, handler(self, self.onAllCheckedChanged)):addTo(container)
	checkBox4:setAnchorPoint(cc.p(0, 0.5))
	checkBox4:setPosition(checkBox1:x(),checkBox1:y() - 80)
	checkBox4.quality = 4
	local purple = UiUtil.label(CommonText.color[4][2],nil,COLOR[4]):rightTo(checkBox4,20)

	--橙色
	local checkBox5 = CheckBox.new(nil, nil, handler(self, self.onAllCheckedChanged)):addTo(container):rightTo(checkBox4,100)
	checkBox5.quality = 5
	local orange = UiUtil.label(CommonText.color[5][2],nil,COLOR[5]):rightTo(checkBox5,20)

	-- 全选
	local checkBox = CheckBox.new(nil, nil, handler(self, self.onAllCheckedChanged)):addTo(container):rightTo(checkBox5,100)
	-- checkBox:setAnchorPoint(cc.p(0, 0.5))
	-- checkBox:setPosition(300, 20)

	local label = ui.newTTFLabel({text = CommonText[141], color = COLOR[5],font = G_FONT, size = FONT_SIZE_SMALL, x = checkBox:getPositionX() + checkBox:getContentSize().width + 20, y = checkBox:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 升级
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local upgradeBtn = MenuButton.new(normal, selected, nil, handler(self, self.onUpgradeCallback)):addTo(container)
	upgradeBtn:setPosition(534, 70)
	upgradeBtn:setLabel(CommonText[79])
end

-- 根据当前选中的状态，更新显示增加经验值
function EquipUpgradeView:onShowChecked()
	local exp = 0
	if self.m_container.equipTableView_ then exp = self.m_container.equipTableView_:getCheckedExp() end

	self.m_container.expLabel_:setString("+" .. exp)
end

function EquipUpgradeView:onAllCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	if self.m_container and self.m_container.equipTableView_ then
		local quality = sender.quality
		self.m_container.equipTableView_:checkAll(quality, isChecked)

		self:onShowChecked()
	end
end

function EquipUpgradeView:onUpgradeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local equips = {}
	if self.m_container.equipTableView_ then equips = self.m_container.equipTableView_:getCheckedEquips() end
	if #equips <= 0 then -- 请选择装备
		Toast.show(CommonText[147])
		return
	end

	local addExp = 0
	if self.m_container.equipTableView_ then addExp = self.m_container.equipTableView_:getCheckedExp() end
	gprint("EquipUpgradeView:onUpgradeCallback addExp:", addExp)

	local equip = EquipMO.getEquipByKeyId(self.m_keyId)
	local equipDB = EquipMO.queryEquipById(equip.equipId)
	-- local maxLevel = EquipMO.queryMaxLevelByQuality(equipDB.quality)

	local newLevel, newExp = EquipMO.addExp(equipDB.quality, equip.level, equip.exp, addExp)
	print("EquipUpgradeView:onUpgradeCallback newLevel:", newLevel, "newExp:", newExp, "mylevel:", UserMO.level_)
	if newLevel > UserMO.level_ then
		Toast.show(CommonText[485][2])  -- 指挥官等级不足
		return
	end

	local function doneEquipUpgrade()
		Loading.getInstance():unshow()
		
		self:showUI()
	end

	Loading.getInstance():show()

	EquipBO.asynEquipUpgrade(doneEquipUpgrade, self.m_keyId, equips)
end

return EquipUpgradeView
