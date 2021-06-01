
local Dialog = require("app.dialog.Dialog")
local DetailRankDialog = class("DetailRankDialog", Dialog)

function DetailRankDialog:ctor()
	DetailRankDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 250)})
end

function DetailRankDialog:onEnter()
	DetailRankDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailRankDialog:showUI()
	local rankDB = UserMO.queryRankById(UserMO.getResource(ITEM_KIND_RANK))

	local resData = UserMO.getResourceData(ITEM_KIND_FAME)

	local label = ui.newTTFLabel({text = CommonText[73] .. ":" .. rankDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 每日可领取X声望
	local label = ui.newTTFLabel({text = CommonText[111] .. rankDB.fame .. resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.getResource(ITEM_KIND_RANK) >= UserMO.queryMaxRank() then -- 最高军衔
		return
	end

	local nxtRankDB = UserMO.queryRankById(UserMO.getResource(ITEM_KIND_RANK) + 1)

	-- 下级:xx
	local label = ui.newTTFLabel({text = CommonText[377] .. ":" .. nxtRankDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 每日可领取X声望
	local label = ui.newTTFLabel({text = CommonText[111] .. nxtRankDB.fame .. resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 升级需要:
	local label = ui.newTTFLabel({text = CommonText[378] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 指挥官X级
	local label = ui.newTTFLabel({text = CommonText[51] .. nxtRankDB.lordLv .. CommonText[237][4], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))
	if nxtRankDB.lordLv > UserMO.level_ then
		label:setColor(COLOR[5])
	end

	local stoneData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)

	-- 宝石
	local label = ui.newTTFLabel({text = stoneData.name .. nxtRankDB.stoneCost, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))
	if nxtRankDB.stoneCost > UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE) then
		label:setColor(COLOR[5])
	end
end

return DetailRankDialog