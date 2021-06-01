--
-- Author: gf
-- Date: 2015-12-14 10:28:54
--

local Dialog = require("app.dialog.Dialog")
local RaffleAwardDialog = class("RaffleAwardDialog", Dialog)

function RaffleAwardDialog:ctor(activityId)
	RaffleAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.activityId = activityId
end

function RaffleAwardDialog:onEnter()
	RaffleAwardDialog.super.onEnter(self)
	
	self:setTitle(CommonText[771])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local RaffleAwardTableView = require("app.scroll.RaffleAwardTableView")
	local view = RaffleAwardTableView.new(cc.size(btm:getContentSize().width, btm:getContentSize().height - 20),self.activityId):addTo(btm)
	view:setPosition(0, 10)
	view:reloadData()
end

return RaffleAwardDialog