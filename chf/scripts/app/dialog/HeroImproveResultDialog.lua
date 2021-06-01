--
-- Author: gf
-- Date: 2015-09-03 16:53:04
--

local Dialog = require("app.dialog.Dialog")
local HeroImproveResultDialog = class("HeroImproveResultDialog", Dialog)

function HeroImproveResultDialog:ctor(heros)
	HeroImproveResultDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 600)})
	self.heros = heros
end

function HeroImproveResultDialog:onEnter()
	HeroImproveResultDialog.super.onEnter(self)

	self:setTitle(CommonText[536])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local heros = self.heros

	-- heros = {
	-- 	{heroId = 201},
	-- 	{heroId = 202},
	-- 	{heroId = 203},
	-- 	{heroId = 204},
	-- 	{heroId = 205},
	-- 	{heroId = 206},
	-- 	{heroId = 207},
	-- 	{heroId = 208},
	-- 	{heroId = 209},
	-- 	{heroId = 210},
	-- 	{heroId = 211},
	-- 	{heroId = 212}
	-- }

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 480))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)
	
	local HeroImproveTableView = require("app.scroll.HeroImproveTableView")
	local view = HeroImproveTableView.new(cc.size(infoBg:getContentSize().width, infoBg:getContentSize().height - 20),heros):addTo(infoBg)
	view:setPosition(0, 0)
	view:reloadData()



	

end



return HeroImproveResultDialog
