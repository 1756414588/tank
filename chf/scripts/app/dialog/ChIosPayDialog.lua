--
-- Author: gf
-- Date: 2015-09-21 16:31:31
-- 草花IOS支付弹出框

local Dialog = require("app.dialog.Dialog")
local ChIosPayDialog = class("ChIosPayDialog", Dialog)



function ChIosPayDialog:ctor(callBack)
	ChIosPayDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_19.png", UI_ENTER_NONE,{scale9Size = cc.size(250, 350),alpha = 0})

	self.callBack = callBack
end

function ChIosPayDialog:onEnter()
	ChIosPayDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_19.png")

	-- self:getBg():setPosition(,self.sender:getPositionY() + 90 / 2 + bg:getContentSize().height / 2 + 10)

	local titLab = ui.newTTFLabel({text = CommonText[1500][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = self:getBg():getContentSize().width / 2, y = 325, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	titLab:setAnchorPoint(cc.p(0.5, 0.5))

	--苹果官方
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local appleBtn = MenuButton.new(normal, selected, nil, handler(self,self.onPayCallback)):addTo(self:getBg())
	appleBtn:setLabel(CommonText[1500][4])
	appleBtn:setPosition(self:getBg():getContentSize().width / 2,260)
	appleBtn.type = 3

	--支付宝
	local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local aliBtn = MenuButton.new(normal, selected, nil, handler(self,self.onPayCallback)):addTo(self:getBg())
	aliBtn:setLabel(CommonText[1500][2])
	aliBtn:setPosition(self:getBg():getContentSize().width / 2,160)
	aliBtn.type = 1

	--微信
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local weixinBtn = MenuButton.new(normal, selected, nil, handler(self, self.onPayCallback)):addTo(self:getBg())
	weixinBtn:setLabel(CommonText[1500][3])
	weixinBtn:setPosition(self:getBg():getContentSize().width / 2,60)
	weixinBtn.type = 2

end

function ChIosPayDialog:onPayCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	gprint(sender.type,"sender.type====")
	self.callBack(sender.type)
	self:pop()
end



return ChIosPayDialog