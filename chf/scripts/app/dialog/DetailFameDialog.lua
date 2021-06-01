
local Dialog = require("app.dialog.Dialog")
local DetailFameDialog = class("DetailFameDialog", Dialog)

function DetailFameDialog:ctor()
	DetailFameDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 200)})
end

function DetailFameDialog:onEnter()
	DetailFameDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailFameDialog:showUI()
	local label = ui.newTTFLabel({text = CommonText[388][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 
	local label = ui.newTTFLabel({text = CommonText[388][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = CommonText[388][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 85, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	local label = ui.newTTFLabel({text = CommonText[388][4], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 110, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	local label = ui.newTTFLabel({text = CommonText[388][5], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 135, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))
end

return DetailFameDialog