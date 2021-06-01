--
-- Author: gf
-- Date: 2015-09-03 12:37:50
--


local Dialog = require("app.dialog.Dialog")
local HeroImproveSelectDialog = class("HeroImproveSelectDialog", Dialog)

function HeroImproveSelectDialog:ctor(pos,star,closeCb)
	HeroImproveSelectDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(GAME_SIZE_WIDTH, display.height)})
	self.closeCb = closeCb
	self.pos = pos
	self.star = star
end

function HeroImproveSelectDialog:onEnter()
	HeroImproveSelectDialog.super.onEnter(self)

	self:setTitle(CommonText[534])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(display.width, display.height))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	
	local HeroSelectTableView = require("app.scroll.HeroSelectTableView")
	local view = HeroSelectTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height - 130), self.star, handler(self,self.selectCallBack)):addTo(self:getBg())
	view:setPosition(0,60)
	view:reloadData()
end

function HeroImproveSelectDialog:selectCallBack(hero)
	if self.closeCb then self.closeCb(self.star,self.pos,hero) end
	self:pop()
end

return HeroImproveSelectDialog