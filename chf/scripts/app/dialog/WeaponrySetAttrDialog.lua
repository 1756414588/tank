--
-- Author: Gss
-- Date: 2018-10-12 17:33:56
--
-- WeaponrySetAttrDialog 军备批量设置洗练属性方案界面

local Dialog = require("app.dialog.Dialog")
local WeaponrySetAttrDialog = class("WeaponrySetAttrDialog", Dialog)

function WeaponrySetAttrDialog:ctor(sender)
	WeaponrySetAttrDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_19.png", UI_ENTER_NONE,{scale9Size = cc.size(190, 180),alpha = 0})
	self.sender = sender
end

function WeaponrySetAttrDialog:onEnter()
	WeaponrySetAttrDialog.super.onEnter(self)
	self:setOutOfBgClose(true)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_19.png")
	self:getBg():setPosition(self.sender:getPositionX(),self.sender:getPositionY() + 90 + bg:getContentSize().height / 2 + 10)

	--属性一
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local setBtn = MenuButton.new(normal, selected, nil, handler(self,self.onSetCallback)):addTo(self:getBg())
	setBtn:setLabel(CommonText[1626][1])
	setBtn:setPosition(self:getBg():getContentSize().width / 2,110)
	setBtn.tag = 0

	--属性二
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local setBtn2 = MenuButton.new(normal, selected, nil, handler(self, self.onSetCallback)):addTo(self:getBg())
	setBtn2:setLabel(CommonText[1626][2])
	setBtn2:setPosition(self:getBg():getContentSize().width / 2,50)
	setBtn2.tag = 1
end

function WeaponrySetAttrDialog:onSetCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local myParam = {}
	myParam.type = sender.tag
	myParam.operationType = WEAPONRY_SECOND_SETTYPE_ALL

	WeaponryBO.setWeaponryAttribute(function ()
		Toast.show(CommonText[382][1])
		self:pop()
	end, myParam)
end

function WeaponrySetAttrDialog:onExit()
	WeaponrySetAttrDialog.super.onExit(self)
end

return WeaponrySetAttrDialog