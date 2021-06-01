--
-- Author: Gss
-- Date: 2018-12-14 17:00:16
--
-- 战术查看界面  DetailTacticDialog

local Dialog = require("app.dialog.Dialog")
local DetailTacticDialog = class("DetailTacticDialog", Dialog)
	
function DetailTacticDialog:ctor(tactic, viewFor, choseIndex, formation, lastTactic,param,armySettingFor)
	DetailTacticDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 340)})
	self.m_tactics = tactic
	self.m_viewFor = viewFor
	self.m_formation = formation
	self.m_choseIndex = choseIndex
	self.m_lastTactic = lastTactic or nil
	self.m_param = param
	self.m_armySettingFor = armySettingFor
end

function DetailTacticDialog:onEnter()
	DetailTacticDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[4005]) -- 战术查看

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 150))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local tacticDB = TacticsMO.getTacticByKeyId(self.m_tactics.keyId)
	local itemView = UiUtil.createItemView(ITEM_KIND_TACTIC, tacticDB.tacticsId, {tacticLv = tacticDB.lv}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height / 2)
	-- UiUtil.createItemDetailButton(itemView)

	local tacticInfo = TacticsMO.queryTacticById(self.m_tactics.tacticsId)
	local name = ui.newTTFLabel({text = tacticInfo.tacticsName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 38, color = COLOR[tacticInfo.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local tacticAttr = TacticsMO.getTacticAttrByKeyId(self.m_tactics.keyId)

	for index = 1,#tacticAttr do
		local addition = tacticAttr[index]
		local attributeData = AttributeBO.getAttributeData(addition[1], addition[2])
		local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab:setAnchorPoint(cc.p(0,0))
		additionLab:setPosition(itemView:x() + itemView:width() / 2 + 20, infoBg:height() - (index - 1)*30 - 70)
		additionLab:setAnchorPoint(cc.p(0, 0.5))
		local additionValue = ui.newTTFLabel({text = attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):rightTo(additionLab)
	end

	local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
	lockIcon:setPosition(itemView:width() - 10, itemView:height() - 10)
	lockIcon:setScale(0.5)
	lockIcon:setVisible(self.m_tactics.bind == 1)
	self.m_lockIcon = lockIcon

	--锁定/解锁
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local lockBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onLockCallback)):addTo(infoBg)
	lockBtn:setPosition(infoBg:width() - 70, 35)
	lockBtn:setLabel(self.m_tactics.bind == 1 and CommonText[902][2] or CommonText[902][1])
	lockBtn:setScale(0.8)
	self.m_lockBtn = lockBtn

	-- 升级
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onUpgradeCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width - 120, exchangeBtn:height())
	exchangeBtn:setLabel(CommonText[79])

	-- 穿戴
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local wearBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onWearCallback)):addTo(self:getBg())
	wearBtn:setPosition(120, wearBtn:height())
	wearBtn:setLabel(CommonText[137])
	wearBtn:setVisible(self.m_viewFor == VIEW_FOR_WEAR)

	-- 卸下
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local wearBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onUnloadCallback)):addTo(self:getBg())
	wearBtn:setPosition(120, wearBtn:height())
	wearBtn:setLabel(CommonText[134])
	wearBtn:setVisible(self.m_viewFor == VIEW_FOR_EXC)

	-- 替换
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local wearBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onExcCallback)):addTo(self:getBg())
	wearBtn:setPosition(self:getBg():width() / 2, wearBtn:height())
	wearBtn:setLabel(CommonText[1082][1])
	wearBtn:setVisible(self.m_viewFor == VIEW_FOR_EXC)
end

function DetailTacticDialog:onWearCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local tacDB = TacticsMO.queryTacticById(self.m_tactics.tacticsId)
	local function canShow()
		local canWear = TacticsMO.canTacticWear(self.m_formation, tacDB.attrtype)
		if not canWear then
			Toast.show(CommonText[4017])
			self:pop()
			return false
		end
		return true
	end

	if self.m_lastTactic then -- 如果是替换
		if self.m_lastTactic.attrtype == tacDB.attrtype then
		else
			local iswear =  canShow()
			if not iswear then return end
		end
	else
		local iswear =  canShow()
		if not iswear then return end
	end

	Notify.notify(LOCAL_TACTICS_WEAR, {keyId = self.m_tactics.keyId,index = self.m_choseIndex, param = self.m_param})
end

function DetailTacticDialog:onUnloadCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Notify.notify(LOCAL_TACTICS_WEAR, {keyId = 0,index = self.m_choseIndex, param = self.m_param}) --  卸下。keyId 置为0
end

function DetailTacticDialog:onExcCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local tactic = TacticsMO.queryTacticById(self.m_tactics.tacticsId)
	self:pop()
	UiDirector.push(require("app.view.TacticsWareHouseView").new(VIEW_FOR_WEAR,self.m_choseIndex,self.m_formation, tactic,nil,self.m_armySettingFor))
end

function DetailTacticDialog:onUpgradeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
	require("app.view.TacticUpgradeView").new(self.m_tactics.keyId, self.m_formation):push()
end

function DetailTacticDialog:onLockCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneLock(locked)
		if locked == 0 then
			Toast.show(CommonText[4032][1])
			self.m_lockIcon:setVisible(false)
			sender:setLabel(CommonText[902][1])
		else
			Toast.show(CommonText[4032][2])
			self.m_lockIcon:setVisible(true)
			sender:setLabel(CommonText[902][2])
		end
	end
	TacticsBO.onTacticLock(doneLock, self.m_tactics.keyId)
end


return DetailTacticDialog