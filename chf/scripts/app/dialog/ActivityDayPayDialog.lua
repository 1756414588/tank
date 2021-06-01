--
-- Author: gf
-- Date: 2015-12-29 16:47:46
-- 每日充值


local Dialog = require("app.dialog.Dialog")
local ActivityDayPayDialog = class("ActivityDayPayDialog", Dialog)

function ActivityDayPayDialog:ctor()
	ActivityDayPayDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 380)})
end

function ActivityDayPayDialog:onEnter()
	ActivityDayPayDialog.super.onEnter(self)

	self:setTitle(CommonText[838])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 350))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local awards = {
		{ITEM_KIND_PROP,ActivityCenterMO.dayPayData.goldBoxId,1},
		{ITEM_KIND_PROP,ActivityCenterMO.dayPayData.propBoxId,1}
	}

	for index = 1,#awards do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award[1], award[2]):addTo(self:getBg())
		itemView:setPosition(160 + (index - 1) % 2 * 220 ,250 - 120 * math.floor((index - 1) / 2))
		
		UiUtil.createItemDetailButton(itemView)
		local name = ui.newTTFLabel({text = UserMO.getResourceData(award[1], award[2]).name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, 
			y = -20, 
			align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[1]}):addTo(itemView)
			name:setAnchorPoint(cc.p(0.5, 0.5))
		-- local count = ui.newTTFLabel({text = "+" .. award[3], font = G_FONT, size = FONT_SIZE_SMALL, 
		-- 	x = name:getPositionX(), 
		-- 	y = name:getPositionY() - 30, 
		-- 	align = ui.TEXT_ALIGN_CENTER, 
		-- 	color = COLOR[1]}):addTo(self:getBg())
		-- count:setAnchorPoint(cc.p(0, 0.5))
	end

	local lab = ui.newTTFLabel({text = CommonText[839], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = self:getBg():getContentSize().width / 2, 
		y = 120, 
		align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[2]}):addTo(self:getBg())
	lab:setAnchorPoint(cc.p(0.5, 0.5))
	
	--今日已领取
	local gotLab = ui.newTTFLabel({text = CommonText[842], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = self:getBg():getContentSize().width / 2, 
		y = 80, 
		align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(self:getBg())
	gotLab:setAnchorPoint(cc.p(0.5, 0.5))
	self.gotLab = gotLab

	self:updateBtn()

	self.m_dayPayHandler = Notify.register(LOCAL_DAYPAY_UPDATE_EVENT, handler(self, self.updateBtn))

end

function ActivityDayPayDialog:updateBtn()
	if self.getBtn then self:getBg():removeChild(self.getBtn, true) end
	if self.rechargeBtn then self:getBg():removeChild(self.rechargeBtn, true) end

	if ActivityCenterMO.dayPayData.state == 0 then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
		local rechargeBtn = MenuButton.new(normal, selected, nil, handler(self,self.rechargeHandler)):addTo(self:getBg())
		rechargeBtn:setPosition(self:getBg():getContentSize().width / 2,25)
		rechargeBtn:setLabel(CommonText[10004])
		self.rechargeBtn = rechargeBtn
		self.gotLab:setVisible(false)
	elseif ActivityCenterMO.dayPayData.state == 1 then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
		local getBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardHandler)):addTo(self:getBg())
		getBtn:setPosition(self:getBg():getContentSize().width / 2,25)
		getBtn:setLabel(CommonText[694][2])
		self.getBtn = getBtn
		self.gotLab:setVisible(false)
	elseif ActivityCenterMO.dayPayData.state == 2 then
		self.gotLab:setVisible(true)
	end
end

function ActivityDayPayDialog:awardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynDoActEDayPay(function()
		Loading.getInstance():unshow()
		self:updateBtn()
		end)
end

function ActivityDayPayDialog:rechargeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- self:pop(function() require("app.view.RechargeView").new():push() end)
	self:pop(function() RechargeBO.openRechargeView() end)
end

function ActivityDayPayDialog:onExit()
	ActivityDayPayDialog.super.onExit(self)

	if self.m_dayPayHandler then
		Notify.unregister(self.m_dayPayHandler)
		self.m_dayPayHandler = nil
	end
end

return ActivityDayPayDialog