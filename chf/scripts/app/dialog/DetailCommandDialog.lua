
local Dialog = require("app.dialog.Dialog")
local DetailCommandDialog = class("DetailCommandDialog", Dialog)

function DetailCommandDialog:ctor()
	DetailCommandDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 230)})
end

function DetailCommandDialog:onEnter()
	DetailCommandDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailCommandDialog:showUI()
	local label = ui.newTTFLabel({text = CommonText[387][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 40, dimensions = cc.size(480, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0.5, 1))

	if UserMO.command_ >= UserMO.queryMaxCommand() then return end

	local nxtCommand = UserMO.queryCommandByLevel(UserMO.command_ + 1)

	-- 下一级
	local label = ui.newTTFLabel({text = CommonText[74] .. ":LV." .. (UserMO.command_ + 1) .. "(" .. CommonText[22] .. "+" .. nxtCommand.tankCount .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - 40, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 成功率
	local label = ui.newTTFLabel({text = CommonText[181] .. ":" .. (nxtCommand.prob / 10) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- if HeroMO.getHeroById(HERO_ID_COMMAND) then  -- 有统率官
	-- 	local hero = HeroMO.queryHero(HERO_ID_COMMAND)
	-- 	label = ui.newTTFLabel({text = " +" .. hero.skillValue .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(self:getBg())
	-- 	label:setAnchorPoint(cc.p(0, 0.5))
	-- end
	if HeroMO.isStaffHeroPutById(HERO_ID_COMMAND) then  -- 有统率官
		local hero = HeroMO.queryHero(HERO_ID_COMMAND)
		label = ui.newTTFLabel({text = " +" .. hero.skillValue .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))
	end

	if ActivityBO.isValid(ACTIVITY_ID_CARVINAL) then  -- 全名狂欢活动
		local activity = ActivityMO.getActivityById(ACTIVITY_ID_CARVINAL)

		local label = ui.newTTFLabel({text = "(" .. activity.name .. CommonText[449] .. (nxtCommand.prob / 100) .. "%" ..  ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))
	end
	

	-- 升级需要:
	local label = ui.newTTFLabel({text = CommonText[378] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 指挥官X级
	local label = ui.newTTFLabel({text = CommonText[51] .. nxtCommand.commandLv .. CommonText[237][4], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))
	if nxtCommand.commandLv > UserMO.level_ then
		label:setColor(COLOR[5])
	end

	-- 统率书
	local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_COMMAND_BOOK)

	-- 统率书
	local label = ui.newTTFLabel({text = resData.name .. nxtCommand.book .. CommonText[120], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))
	if nxtCommand.book > UserMO.getResource(ITEM_KIND_PROP, PROP_ID_COMMAND_BOOK) then
		label:setColor(COLOR[5])
	end

	-- 当前拥有
	local label = ui.newTTFLabel({text = "(" .. CommonText[63] .. ":" .. UserMO.getResource(ITEM_KIND_PROP, PROP_ID_COMMAND_BOOK) .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))
end

return DetailCommandDialog