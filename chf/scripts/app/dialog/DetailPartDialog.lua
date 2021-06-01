

local Dialog = require("app.dialog.Dialog")
local DetailPartDialog = class("DetailPartDialog", Dialog)

function DetailPartDialog:ctor()
	DetailPartDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 200)})
end

function DetailPartDialog:onEnter()
	DetailPartDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailPartDialog:showUI()
	-- local label = ui.newTTFLabel({text = skillDB.name .. " LV." .. skillLv, font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- -- 每级增加所有部队
	-- local label = ui.newTTFLabel({text = CommonText[389][1] .. "1%" .. skillDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- -- 升级需要:
	-- local label = ui.newTTFLabel({text = CommonText[378] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- -- 指挥官X级
	-- local label = ui.newTTFLabel({text = CommonText[51] .. (skillLv + 1) .. CommonText[237][4], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	-- label:setAnchorPoint(cc.p(0, 0.5))
	-- if (skillLv + 1) > UserMO.level_ then
	-- 	label:setColor(COLOR[5])
	-- end

	-- local skillData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK)

	-- -- 
	-- local label = ui.newTTFLabel({text = skillData.name .. (skillLv + 1) .. CommonText[120], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	-- label:setAnchorPoint(cc.p(0, 0.5))
	-- if skillLv + 1 > UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK) then
	-- 	label:setColor(COLOR[5])
	-- end

	-- -- 可从日常任务获得
	-- local label = ui.newTTFLabel({text = "(" .. CommonText[389][2] .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	-- label:setAnchorPoint(cc.p(0, 0.5))
end

return DetailPartDialog