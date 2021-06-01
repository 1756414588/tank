--
-- Author: gf
-- Date: 2015-12-04 16:01:24
-- 极限单兵 排行奖励一览



local Dialog = require("app.dialog.Dialog")
local ActivityFortuneAwardDialog = class("ActivityFortuneAwardDialog", Dialog)

function ActivityFortuneAwardDialog:ctor(activityId)
	ActivityFortuneAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.activityId = activityId
end

function ActivityFortuneAwardDialog:onEnter()
	ActivityFortuneAwardDialog.super.onEnter(self)
	
	self:setTitle(CommonText[771])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 60))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 45 - tableBg:getContentSize().height / 2)


	local ActivityFortuneAwardTableView = require("app.scroll.ActivityFortuneAwardTableView")
	local view = ActivityFortuneAwardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),self.activityId):addTo(tableBg)
	view:setPosition(0, 10)
	view:reloadData()
end

return ActivityFortuneAwardDialog
