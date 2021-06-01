--
-- Author: gf
-- Date: 2016-05-12 17:50:28
--


local Dialog = require("app.dialog.Dialog")
local ActivityM1A2AwardDialog = class("ActivityM1A2AwardDialog", Dialog)

function ActivityM1A2AwardDialog:ctor(lotteryType)
	ActivityM1A2AwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.m_lotteryType = lotteryType
end

function ActivityM1A2AwardDialog:onEnter()
	ActivityM1A2AwardDialog.super.onEnter(self)
	
	self:setTitle(CommonText[938][self.m_lotteryType])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	--概率获得
	local title = ui.newTTFLabel({text = CommonText[940], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = btm:getContentSize().height - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	title:setAnchorPoint(cc.p(0, 0.5))


	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 90))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 75 - tableBg:getContentSize().height / 2)


	local ActivityM1A2AwardTableView = require("app.scroll.ActivityM1A2AwardTableView")
	local view = ActivityM1A2AwardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),self.m_lotteryType):addTo(tableBg)
	view:setPosition(0, 10)
	view:reloadData()
end

return ActivityM1A2AwardDialog
