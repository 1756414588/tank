--
-- Author: gf
-- Date: 2016-04-08 16:27:55
-- 首充礼包

local Dialog = require("app.dialog.Dialog")
local FirstPayDialog = class("FirstPayDialog", Dialog)

function FirstPayDialog:ctor()
	FirstPayDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function FirstPayDialog:onEnter()
	FirstPayDialog.super.onEnter(self)

	self:setTitle(CommonText[456][2])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)


	local infoBg = display.newSprite(IMAGE_COMMON .. "info_bg_firstPay.jpg"):addTo(self:getBg())
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)
	

	--奖励内容
	local awardDB = json.decode(ActivityMO.queryActivityAwardsById(FIRST_RECHARGE_ACTIVITY_ID).awardList)

	local posParam = {
		{x = 140, y = 310, offsetY = 75, offsetY1 = 60},
		{x = 390, y = 310, offsetY = 75, offsetY1 = 60},
		{x = 140, y = 90, offsetY = 75, offsetY1 = 60},
		{x = 390, y = 90, offsetY = 75, offsetY1 = 60}
	}
	for index=1,#awardDB do
		local itemView = UiUtil.createItemView(awardDB[index][1], awardDB[index][2], {count = awardDB[index][3]})
		itemView:setPosition(posParam[index].x,posParam[index].y)
		itemView:setScale(0.9)
		infoBg:addChild(itemView)

		UiUtil.createItemDetailButton(itemView)

		local propDB = UserMO.getResourceData(awardDB[index][1], awardDB[index][2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 2, 
			x = itemView:getPositionX(), y = itemView:getPositionY() + posParam[index].offsetY, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		
		local info = ui.newTTFLabel({text = CommonText[895][index], font = G_FONT, size = FONT_SIZE_SMALL - 2, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - posParam[index].offsetY1, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onGoCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 10)
	btn:setLabel(CommonText[463])


	--开区三天，未充值，拇指广告渠道
	if ServiceBO.muzhiAdPlat() and UserMO.vip_ == 0 and MuzhiADMO.FirstGiftADDay >= 0 then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
		local adbtn = MenuButton.new(normal, selected, disabled, handler(self, self.onADCallback)):addTo(self:getBg())
		adbtn:setPosition(self:getBg():getContentSize().width / 2 + 120, 10)
		adbtn:setLabel(CommonText.MuzhiAD[3][1])

		btn:setPosition(self:getBg():getContentSize().width / 2 - 120, 10)
	end
	

end

function FirstPayDialog:onGoCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- require("app.view.RechargeView").new():push()
	RechargeBO.openRechargeView()
end

function FirstPayDialog:onADCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	MuzhiADBO.GetFirstGiftADStatus(function()
		Loading.getInstance():unshow()
		require("app.dialog.FirstGiftADDialg").new():push()
		end)
	
	
end

function FirstPayDialog:onExit()

end 


return FirstPayDialog