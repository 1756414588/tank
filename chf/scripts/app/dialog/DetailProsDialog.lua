
local Dialog = require("app.dialog.Dialog")
local DetailProsDialog = class("DetailProsDialog", Dialog)

function DetailProsDialog:ctor()
	DetailProsDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 720)})
end

function DetailProsDialog:onEnter()
	DetailProsDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailProsDialog:showUI()
	local pros = UserMO.queryProsperousByLevel(UserMO.prosperousLevel_)

	-- 当前等级
	local curLabel = ui.newTTFLabel({text = CommonText[379][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 50, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	curLabel:setAnchorPoint(cc.p(0, 0.5))

	local resData = UserMO.getResourceData(ITEM_KIND_PROSPEROUS)

	-- 繁荣X级 繁荣要求
	local label = ui.newTTFLabel({text = resData.name .. UserMO.prosperousLevel_ .. CommonText[237][4] .. "  " .. resData.name .. CommonText[48] .. "(" .. pros.prosExp .. ")",
		font = G_FONT, size = FONT_SIZE_SMALL, x = curLabel:getPositionX() + curLabel:getContentSize().width, y = curLabel:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))
	-- 带兵量
	local label = ui.newTTFLabel({text = CommonText[22], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "+" .. pros.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 编制经验获得
	local label = ui.newTTFLabel({text = CommonText[380] .. CommonText[381], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "+" .. pros.staffingAdd .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.prosperousLevel_ < UserMO.queryMaxProsperousLevel() then
		local nxtPros = UserMO.queryProsperousByLevel(UserMO.prosperousLevel_ + 1)
		-- 下一等级
		local nxtLabel = ui.newTTFLabel({text = CommonText[379][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = curLabel:getPositionX(), y = curLabel:getPositionY() - 90, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		nxtLabel:setAnchorPoint(cc.p(0, 0.5))

		-- 繁荣X级 繁荣要求
		local label = ui.newTTFLabel({text = resData.name .. (UserMO.prosperousLevel_ + 1) .. CommonText[237][4] .. "  " .. resData.name .. CommonText[48] .. "(",
			font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLabel:getPositionX() + nxtLabel:getContentSize().width, y = nxtLabel:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "+" .. nxtPros.prosExp, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = ")", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

		-- 带兵量
		local label = ui.newTTFLabel({text = CommonText[22], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "+" .. nxtPros.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))
		
		-- 编制经验获得
		local label = ui.newTTFLabel({text = CommonText[380] .. CommonText[381], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "+" .. nxtPros.staffingAdd .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 繁荣等级作用:增加带兵量（9级以上加成编制经验获得量）
	local label = ui.newTTFLabel({text = CommonText[386][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 220, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 1))

	-- 等级提升方法：升级建筑增加繁荣度.提升繁荣等级
	local label = ui.newTTFLabel({text = CommonText[386][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height -10, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 1))

	local label = ui.newTTFLabel({text = CommonText[386][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height -10, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 1))

	-- （1）攻击他人基地...
	local label = ui.newTTFLabel({text = CommonText[386][4], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	-- （2）繁荣度变低
	local label = ui.newTTFLabel({text = CommonText[386][5], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	-- （3）基地变为废墟
	local label = ui.newTTFLabel({text = CommonText[386][6], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	-- 当繁荣度低于繁荣上限时
	local label = ui.newTTFLabel({text = CommonText[386][7], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height - 10, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	local label = ui.newTTFLabel({text = CommonText[386][8], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	local label = ui.newTTFLabel({text = CommonText[386][9], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	local label = ui.newTTFLabel({text = CommonText[386][10], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - label:getContentSize().height, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))
end

return DetailProsDialog
