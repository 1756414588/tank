
-- 装备详情、操作弹出框

local Dialog = require("app.dialog.Dialog")
local EquipDialog = class("EquipDialog", Dialog)

-- 阵型的某个位置formatPosition下的装备位置equipPos的弹出框
function EquipDialog:ctor(formatPosition, equipPos)

	local equip = EquipBO.getEquipAtPos(formatPosition, equipPos)
	local equipDB = EquipMO.queryEquipById(equip.equipId)

	if equipDB.quality < 4 then
		EquipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 340)})
	else
		EquipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 420)})
	end

	self.m_formatPosition = formatPosition
	self.m_equipPos = equipPos
end

function EquipDialog:onEnter()
	EquipDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[132]) -- 装备查看

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 150))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	if not EquipBO.hasEquipAtPos(self.m_formatPosition, self.m_equipPos) then -- 有装备
		gprint("[EquipDialog] no equip Error!!!!!", self.m_formatPosition, self.m_equipPos)
	end

	local equip = EquipBO.getEquipAtPos(self.m_formatPosition, self.m_equipPos)
	self.m_equip = equip
	local equipDB = EquipMO.queryEquipById(equip.equipId)

	local itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView)

	local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 38, color = COLOR[equipDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level)
	local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level, equip.starLv)

	local label = ui.newTTFLabel({text = attrData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local attrB = AttributeBO.getAttributeData(attrData.id, equipDB.b)

	-- 每级增加部队
	local desc = ui.newTTFLabel({text = string.format(CommonText[128], attrB.strValue, attrData.name), font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	desc:setAnchorPoint(cc.p(0, 0.5))

	local posY
	if equipDB.quality < 4 then
		posY = 75
	else
		posY = 150
	end
	-- 交换
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onExchangeCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 - 180, posY)
	exchangeBtn:setLabel(CommonText[133])

	-- 卸下
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local demountBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onDemountCallback)):addTo(self:getBg())
	demountBtn:setPosition(self:getBg():getContentSize().width / 2, posY)
	demountBtn:setLabel(CommonText[134])

	-- 升级
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onUpgradeCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 + 180, posY)
	exchangeBtn:setLabel(CommonText[79])

	-- 升级
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local advanceBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onAdvanceCallback)):addTo(self:getBg())
	advanceBtn:setPosition(self:getBg():getContentSize().width / 2 - 180, 80)
	advanceBtn:setLabel(CommonText[5001])
	advanceBtn:setEnabled(equipDB.transform > 0)
	advanceBtn:setVisible(equipDB.quality == 4)

	-- 升星
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local upStarBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onUpStarsCallback)):addTo(self:getBg())
	-- upStarBtn:setPosition(self:getBg():getContentSize().width / 2 + 180, 70)
	upStarBtn:setPosition(self:getBg():getContentSize().width / 2 - 180, 80)
	upStarBtn:setLabel(CommonText[5067])
	upStarBtn:setEnabled(equip.starLv < 5)
	upStarBtn:setVisible(equipDB.quality >= 5)
end

function EquipDialog:onExchangeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function() require("app.view.EquipExchangeView").new(self.m_formatPosition, self.m_equipPos):push() end)
end

function EquipDialog:onUpgradeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local keyId = self.m_equip.keyId
	self:pop(function() require("app.view.EquipUpgradeView").new(keyId):push() end)
end

function EquipDialog:onAdvanceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local keyId = self.m_equip.keyId
	self:pop(function() require("app.view.EquipAdvanceView").new(keyId):push() end)
end

function EquipDialog:onDemountCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()

	local function doneEquip()
		Loading.getInstance():unshow()
		Toast.show(CommonText[131]) -- 卸下成功
		self:pop()
	end

	-- 卸下装备
	EquipBO.asynEquip(doneEquip, self.m_equip.keyId, self.m_formatPosition, 0)
end

function EquipDialog:doCommand(command, callback)
	if not command then return end

	if command == "equipDialog_upgrade" then
		local keyId = self.m_equip.keyId
		self:pop(function() require("app.view.EquipUpgradeView").new(keyId):push() end)
		if callback then callback() end
	end
end

--升星
function EquipDialog:onUpStarsCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local keyId = self.m_equip.keyId
	self:pop(function() require("app.view.EquipUpStarView").new(keyId):push() end)
end

return EquipDialog