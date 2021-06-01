--
-- Author: gf
-- Date: 2015-12-23 16:37:22
-- 疯狂歼灭奖励



local Dialog = require("app.dialog.Dialog")
local ActivityDestoryRewardDialog = class("ActivityDestoryRewardDialog", Dialog)

function ActivityDestoryRewardDialog:ctor(data)
	ActivityDestoryRewardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 450)})

	
	self.activityCond = data
end

function ActivityDestoryRewardDialog:onEnter()
	ActivityDestoryRewardDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)
	self:showUI()
end

function ActivityDestoryRewardDialog:showUI()
	local tankIdx
	if self.activityCond.param == "0" then
		tankIdx = 5
	else
		tankIdx = tonumber(self.activityCond.param)
	end

	-- 名称
	local name = ui.newTTFLabel({text = string.format(CommonText[825][tankIdx],self.activityCond.cond), font = G_FONT, size = FONT_SIZE_MEDIUM - 2, 
		x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 80, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0.5, 0.5))

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(480, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 140)

	local awardTit = ui.newTTFLabel({text = CommonText[826], font = G_FONT, size = FONT_SIZE_MEDIUM - 2, 
		x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 180, color = cc.c3b(106, 255, 0), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0.5, 0.5))

	local awards = PbProtocol.decodeArray(self.activityCond["award"])
	gdump(awards,"awards==")

	for index=1,#awards do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setPosition(120 + (index - 1) * 140,self:getBg():getContentSize().height - 260)
		self:getBg():addChild(itemView)
		UiUtil.createItemDetailButton(itemView)
		local propDB = UserMO.getResourceData(award.type, award.id)
		local name = ui.newTTFLabel({text = propDB.name2 .. " * " .. award.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
		
	end
end



return ActivityDestoryRewardDialog