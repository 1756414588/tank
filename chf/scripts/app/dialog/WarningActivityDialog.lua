--
-- 活动警告
-- 
-- MYS
local Dialog = require("app.dialog.Dialog")
local WarningActivityDialog = class("WarningActivityDialog", Dialog)

function WarningActivityDialog:ctor()
	WarningActivityDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 270)})
end

function WarningActivityDialog:onEnter()
	WarningActivityDialog.super.onEnter(self)
	UiDirector.setLimitTopPoshNode(true,self:getUiName())

	local secret = display.newSprite(IMAGE_COMMON.."refine_secret_dialog.png"):addTo(self:getBg())
	secret:setPosition(secret:width() / 2,self:getBg():getContentSize().height / 2 + 22)

	local title = ui.newTTFLabel({text = CommonText[1056][1] .. ":", font = G_FONT,  color = COLOR[1], size = FONT_SIZE_MEDIUM, x = secret:x() + 170, 
		y = self:getBg():getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	local desc = ui.newTTFLabel({text = CommonText[1056][2],font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1],align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(280, 70)}):addTo(self:getBg())
	desc:setPosition(secret:x() + 110,title:y() - 50)
	desc:setAnchorPoint(cc.p(0,0.5))

	local Nomal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local Selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local btn = MenuButton.new(Nomal,Selected,nil,handler(self,self.ok)):addTo(self:getBg(),2)
	btn:setPosition((self:getBg():getContentSize().width + desc:x()) * 0.5 - 20, self:getBg():getContentSize().height * 0.5 - 50)
	btn:setLabel(CommonText[1056][3])

end

function WarningActivityDialog:ok(tag ,sender)
	ManagerSound.playNormalButtonSound()
	UiDirector.setLimitTopPoshNode(false)
	UiDirector.popMakeUiTop("HomeView")
end

return WarningActivityDialog