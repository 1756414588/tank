--
-- Author: gf
-- Date: 2015-09-15 19:32:10
-- 军团日常福利一览


local Dialog = require("app.dialog.Dialog")
local PartyDayWealDialog = class("PartyDayWealDialog", Dialog)

function PartyDayWealDialog:ctor()
	PartyDayWealDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function PartyDayWealDialog:onEnter()
	PartyDayWealDialog.super.onEnter(self)
	
	self:setTitle(CommonText[609])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local PartyDayWealTableView = require("app.scroll.PartyDayWealTableView")
	local view = PartyDayWealTableView.new(cc.size(btm:getContentSize().width, btm:getContentSize().height - 60)):addTo(btm)
	view:setPosition(0, 20)
	view:reloadData()
end

return PartyDayWealDialog
