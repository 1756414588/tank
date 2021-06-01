--
-- Author: gf
-- Date: 2016-01-06 17:18:06
-- V6尊享



local Dialog = require("app.dialog.Dialog")
local VipServiceDialog = class("VipServiceDialog", Dialog)

function VipServiceDialog:ctor()
	VipServiceDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})

end

function VipServiceDialog:onEnter()
	VipServiceDialog.super.onEnter(self)
	self:setTitle(CommonText[846])
	self:showUI()
end

function VipServiceDialog:showUI()
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	local bar = display.newSprite(IMAGE_COMMON .. "bar_vip6_serv.jpg", btm:getContentSize().width / 2, btm:getContentSize().height - 190):addTo(btm)

	local name = ui.newTTFLabel({text = CommonText[847], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = btm:getContentSize().width / 2, y = bar:getPositionY() - 175, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	name:setAnchorPoint(cc.p(0.5, 0.5))

	local v6pic = display.newSprite(IMAGE_COMMON .. "/vip/vip_".. PERSONAL_SERVICE_VIP .. ".png", btm:getContentSize().width / 2, name:getPositionY() - 50):addTo(btm)

	for index=1,#CommonText[848] do
		local lab = ui.newTTFLabel({text = CommonText[848][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = btm:getContentSize().width / 2, y = v6pic:getPositionY() - 65 - (index - 1) * 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		lab:setAnchorPoint(cc.p(0.5, 0.5))
	end

	local lab = ui.newTTFLabel({text = "QQ:", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = btm:getContentSize().width / 2 - 80, y = v6pic:getPositionY() - 240, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	lab:setAnchorPoint(cc.p(0, 0.5))

	local qqLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = lab:getPositionX() + lab:getContentSize().width, y = lab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	qqLab:setAnchorPoint(cc.p(0, 0.5))

	--根据渠道判断QQ联系方式
	if GameConfig.environment == "anfan_client" then
		qqLab:setString()
	elseif GameConfig.environment == "chpub_client" then
		qqLab:setString()
	elseif GameConfig.environment == "zty_client" then
		qqLab:setString()
	else
		qqLab:setString("11111111")
	end

	local name = ui.newTTFLabel({text = CommonText[849], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = btm:getContentSize().width / 2, y = 50, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	name:setAnchorPoint(cc.p(0.5, 0.5))

end



return VipServiceDialog