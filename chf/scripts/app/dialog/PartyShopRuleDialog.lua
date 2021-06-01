--
-- Author: gf
-- Date: 2015-10-09 11:46:31
-- 军团商店规则


local Dialog = require("app.dialog.Dialog")
local PartyShopRuleDialog = class("PartyShopRuleDialog", Dialog)

function PartyShopRuleDialog:ctor()
	PartyShopRuleDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE,{scale9Size = cc.size(550, 260)})
end

function PartyShopRuleDialog:onEnter()
	PartyShopRuleDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)


	local title = ui.newTTFLabel({text = CommonText[593][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = self:getBg():getContentSize().height - 50, color = COLOR[12], 
		align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	title:setAnchorPoint(cc.p(0, 0.5))

	for index=2,3 do
		local desc = ui.newTTFLabel({text = CommonText[593][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = self:getBg():getContentSize().height - 75 - (index - 2) * 25, color = COLOR[1], 
			align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 0.5))
	end

	local title = ui.newTTFLabel({text = CommonText[593][4], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = self:getBg():getContentSize().height - 125, color = COLOR[12], 
		align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	title:setAnchorPoint(cc.p(0, 0.5))

	for index=5,7 do
		local desc = ui.newTTFLabel({text = CommonText[593][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = self:getBg():getContentSize().height - 75 - (index - 2) * 25, color = COLOR[1], 
			align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 0.5))

	end
end

return PartyShopRuleDialog