
-- 装备套装详情弹出框

local Dialog = require("app.dialog.Dialog")
local DetailEquipSuitDialog = class("DetailEquipSuitDialog", Dialog)

function DetailEquipSuitDialog:ctor(formatPos)
	DetailEquipSuitDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 200)})
	self.m_formatPos = formatPos
	gprint("DetailEquipSuitDialog:formatPos", self.m_formatPos)
end

function DetailEquipSuitDialog:onEnter()
	DetailEquipSuitDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)
	
	self:showUI()
end

function DetailEquipSuitDialog:showUI()
	-- 当前激活套装效果
	local label = ui.newTTFLabel({text = CommonText[413][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 40, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 蓝色装备数量
	local blueNum = EquipBO.getQualityEquipNumAtFormatIndex(self.m_formatPos, 3)
	local purpleNum = EquipBO.getQualityEquipNumAtFormatIndex(self.m_formatPos, 4)

	if blueNum >= 6 then
		-- 蓝色套装
		local suit = ui.newTTFLabel({text = CommonText[414][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 20, y = label:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		suit:setAnchorPoint(cc.p(0, 0.5))

		-- 激活
		local desc = ui.newTTFLabel({text = CommonText[413][4], font = G_FONT, size = FONT_SIZE_SMALL, x = suit:getPositionX() + suit:getContentSize().width, y = suit:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 0.5))
	elseif purpleNum >= 6 then
		-- 紫色套装
		local suit = ui.newTTFLabel({text = CommonText[414][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 20, y = label:getPositionY() - 25, color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		suit:setAnchorPoint(cc.p(0, 0.5))

		-- 激活
		local desc = ui.newTTFLabel({text = CommonText[413][4], font = G_FONT, size = FONT_SIZE_SMALL, x = suit:getPositionX() + suit:getContentSize().width, y = suit:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 0.5))
	else
		-- 无
		local value = ui.newTTFLabel({text = CommonText[108], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 20, y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 套装列表
	local label = ui.newTTFLabel({text = CommonText[413][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - 50, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 6件
	local value = ui.newTTFLabel({text = 6 .. CommonText[237][5], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 20, y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 蓝色套装
	local suit = ui.newTTFLabel({text = CommonText[414][1], font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	suit:setAnchorPoint(cc.p(0, 0.5))

	-- 全部属性加成
	local desc = ui.newTTFLabel({text = ":" .. CommonText[413][3], font = G_FONT, size = FONT_SIZE_SMALL, x = suit:getPositionX() + suit:getContentSize().width, y = suit:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = EQUIP_BLUE_SUIT_ADD .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = "(", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = blueNum, font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = "/6)", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	-- 6件
	local value = ui.newTTFLabel({text = 6 .. CommonText[237][5], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 20, y = label:getPositionY() - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 紫色套装
	local suit = ui.newTTFLabel({text = CommonText[414][2], font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	suit:setAnchorPoint(cc.p(0, 0.5))

	-- 全部属性加成
	local desc = ui.newTTFLabel({text = ":" .. CommonText[413][3], font = G_FONT, size = FONT_SIZE_SMALL, x = suit:getPositionX() + suit:getContentSize().width, y = suit:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = EQUIP_PURPLE_SUIT_ADD .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = "(", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = purpleNum, font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = "/6)", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))
end

return DetailEquipSuitDialog
