--
-- Author: xiaoxing
-- Date: 2016-12-21 18:53:31
--

local Dialog = require("app.dialog.Dialog")
local MedalDialog = class("MedalDialog", Dialog)

function MedalDialog:ctor(keyId)
	MedalDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 440)})
	self.keyId = keyId
end

function MedalDialog:onEnter()
	MedalDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[20163][2]) -- 查看勋章

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 200))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 65 - infoBg:getContentSize().height / 2)
	local data = MedalBO.medals[self.keyId]
	self.data = data
	local id = data.medalId
	local md = MedalMO.queryById(id)
	local itemView = UiUtil.createItemView(ITEM_KIND_MEDAL_ICON,id,{data = data}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height / 2 + 8)
	UiUtil.createItemDetailButton(itemView)
	--锁定/解锁按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local lockBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onLockCallback)):addTo(infoBg)
	lockBtn:setPosition(infoBg:getContentSize().width - 80,infoBg:getContentSize().height - 125 )
	self.m_lockBtn = lockBtn

	--锁定状态icon
	local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
	lockIcon:setScale(0.5)
	lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
	lockIcon:setVisible(self.data.locked)
	self.m_lockIcon = lockIcon

	UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.shareCallback), CommonText[20175][1])
		:alignTo(lockBtn, 60, 1)

	if self.data.locked then
		lockBtn:setLabel(CommonText[902][2]) 
	else
		lockBtn:setLabel(CommonText[902][1])
	end

	local attrs = MedalBO.getPartAttrData(self.keyId,nil)
	--强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_medal_strength.png"):addTo(self:getBg())
		:align(display.LEFT_CENTER, 60, 355)
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrs.strengthValue), font = "fnt/num_2.fnt"}):rightTo(strengthLabel, 10)

	local t = UiUtil.label(md.medalName,nil,COLOR[md.quality])
		:addTo(self:getBg()):align(display.LEFT_CENTER, 180, 325)
	t = UiUtil.label(CommonText[20164][1]):alignTo(t, -25, 1)
	UiUtil.label(md.position,nil,COLOR[2]):rightTo(t)

	t = UiUtil.label(CommonText[20164][2]):alignTo(t, -25, 1)
	UiUtil.label(data and data.upLv or 0,nil,COLOR[2]):rightTo(t)	

	t = UiUtil.label(CommonText[20164][3]):alignTo(t, -25, 1)
	UiUtil.label(data and data.refitLv or 0,nil,COLOR[2]):rightTo(t)

	local att = attrs[md.attr1]
	t = UiUtil.label(att.name .."："):alignTo(t, -25, 1)
	UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
	if md.attr2 > 0 then
		att = attrs[md.attr2]
		t = UiUtil.label(att.name.."："):alignTo(t, -25, 1)
		UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
	end
	-- local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 38, color = COLOR[equipDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- name:setAnchorPoint(cc.p(0, 0.5))

	-- local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level)

	-- local label = ui.newTTFLabel({text = attrData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- value:setAnchorPoint(cc.p(0, 0.5))

	-- local attrB = AttributeBO.getAttributeData(attrData.id, equipDB.b)

	-- -- 每级增加部队
	-- local desc = ui.newTTFLabel({text = string.format(CommonText[128], attrB.strValue, attrData.name), font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- desc:setAnchorPoint(cc.p(0, 0.5))

	-- 温养
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.warmBtn), CommonText[20165][1])
		:addTo(self:getBg()):pos(110,140)
	local btn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self, self.polishBtn), CommonText[20165][2])
		:alignTo(t, self:getBg():width() - t:x()*2)
	btn:setEnabled(md.refit ~= 0)
	t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self, self.resolveBtn), CommonText[515][2])
		:alignTo(t, -65, 1)
	t.md = md
	self.m_exchangeBtn = t
	if self.data.pos == 1 or self.data.locked then
		t:setEnabled(false)
	end
	t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.unloadBtn), CommonText[137])
		:alignTo(t, self:getBg():width() - t:x()*2)
	if self.data.pos == 1 then
		t:setLabel(CommonText[172])
	end
	--勋章精炼
	if UserMO.queryFuncOpen(UFP_MEDAL_REFINE) then
		local refineBtn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.refineBtn), CommonText[1739])
			:addTo(self:getBg()):pos(self:getBg():width() / 2,140)
		refineBtn:setVisible(md and md.transform ~= -1)
	end
end

function MedalDialog:warmBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function()
		require("app.view.MedalStrengthView").new(1,self.data.keyId):push()
	end)
end

function MedalDialog:polishBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function()
		require("app.view.MedalStrengthView").new(2,self.data.keyId):push()
	end)
end

function MedalDialog:refineBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function()
		require("app.view.MedalStrengthView").new(3,self.data.keyId):push()
	end)
end


function MedalDialog:resolveBtn(tag, sender)
	ManagerSound.playNormalButtonSound()

	local data = self.data
	local md = sender.md
	local function goBatch()
		self:pop(function()
			local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
			PartExplodeDialog.new({data.keyId},nil,"medal"):push()
		end)
	end

	if md.quality >= 5 then
		require("app.dialog.TipsAnyThingDialog").new(CommonText[1810][3],function ()
			goBatch()
		end):push()
	else
		goBatch()
	end

	-- self:pop(function()
	-- 	local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
	-- 	PartExplodeDialog.new({self.data.keyId},nil,"medal"):push()
	-- end)
end

function MedalDialog:unloadBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	MedalBO.OnMedal(self.data.keyId,self.data.pos,function()
		self:pop()
	end)
end

function MedalDialog:onLockCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneLock(locked)
		local statusStr = ""
		if locked then
			statusStr = CommonText[902][1]
			self.m_lockBtn:setLabel(CommonText[902][2]) 
		else
			statusStr = CommonText[902][2]
			self.m_lockBtn:setLabel(CommonText[902][1])
		end
		Toast.show(string.format(CommonText[20175][2],statusStr))
		self.m_lockIcon:setVisible(locked)

		if self.data.pos == 1 then
			self.m_exchangeBtn:setEnabled(false)
		else
			if locked then
				self.m_exchangeBtn:setEnabled(false)
			else
				self.m_exchangeBtn:setEnabled(true)
			end
		end
	end
	MedalBO.lockMedal(doneLock, self.data)
end

function MedalDialog:shareCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	local item = {}
	item.medalId = self.data.medalId
	item.upLv = self.data.upLv
	item.refitLv = self.data.refitLv
	local dialog = require("app.dialog.ShareDialog").new(SHARE_TYPE_MEDAL,item,sender):push()
	dialog:getBg():setPosition(display.cx + 150, display.cy + 150)
end

return MedalDialog