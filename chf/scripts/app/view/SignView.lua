--
-- Author: gf
-- Date: 2015-09-21 12:20:45
-- 签到

local SignView = class("SignView", UiNode)

function SignView:ctor(buildingId)
	SignView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function SignView:onEnter()
	SignView.super.onEnter(self)

	self:setTitle(CommonText[670])
	local bg = display.newSprite(IMAGE_COMMON .. "imfo_bg_sign.jpg"):addTo(self:getBg())
	bg:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - bg:getContentSize().height / 2 - 100)

	local SignTableView = require("app.scroll.SignTableView")
	local view = SignTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height - 300)):addTo(self:getBg())
	view:setPosition(0, 30)
	view:reloadData()
	local initOffset = SignBO.getCanAwardIndex() * 200
	if initOffset > 0 then
		view:setContentOffset(cc.p(0, view:getContentOffset().y+initOffset))
	end
	
end

return SignView