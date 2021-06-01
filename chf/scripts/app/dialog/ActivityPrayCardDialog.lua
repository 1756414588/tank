--
-- Author: gf
-- Date: 2016-05-04 11:45:30
-- 节日欢庆




local Dialog = require("app.dialog.Dialog")
local ActivityPrayCardDialog = class("ActivityPrayCardDialog", Dialog)

function ActivityPrayCardDialog:ctor(prayId)
	ActivityPrayCardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.prayId = prayId
end

function ActivityPrayCardDialog:onEnter()
	ActivityPrayCardDialog.super.onEnter(self)
	
	self:setTitle(CommonText[913])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 60))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 45 - tableBg:getContentSize().height / 2)


	local ActivityPrayCardTableView = require("app.scroll.ActivityPrayCardTableView")
	local view = ActivityPrayCardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),self.prayId):addTo(tableBg)
	view:setPosition(0, 10)
	view:reloadData()
end

return ActivityPrayCardDialog
