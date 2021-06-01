--
-- Author: Your Name
-- Date: 2017-06-01 11:50:29
--
--淬炼大师小秘书Dialog

local Dialog = require("app.dialog.Dialog")
local DetailRefineMasterDialog = class("DetailRefineMasterDialog", Dialog)

function DetailRefineMasterDialog:ctor(rhand)
	DetailRefineMasterDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 270)})
	self.rhand = rhand
end

function DetailRefineMasterDialog:onEnter()
	DetailRefineMasterDialog.super.onEnter(self)
	
	self:setOutOfBgClose(false)
	self:setInOfBgClose(false)

	self:showUI()
end

function DetailRefineMasterDialog:showUI()
	local secret = display.newSprite(IMAGE_COMMON.."refine_secret_dialog.png"):addTo(self:getBg())
	secret:setPosition(secret:width() / 2,self:getBg():getContentSize().height / 2 + 22)

	local title = ui.newTTFLabel({text = CommonText[1021][1], font = G_FONT, size = FONT_SIZE_SMALL, x = secret:x() + 160, y = self:getBg():getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	local desc = ui.newTTFLabel({text = CommonText[1021][2],font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1],align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(280, 70)}):addTo(self:getBg())
	desc:setPosition(secret:x() + 110,title:y() - 50)
	desc:setAnchorPoint(cc.p(0,0.5))
	--去寻宝
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local goBtn = MenuButton.new(normal, selected, nil, function ()
		self:pop()
		self.rhand(1)
	end):addTo(self:getBg())
	goBtn:setPosition(self:getBg():getContentSize().width / 2 - 20,goBtn:height() - 10)
	goBtn:setLabel(CommonText[1022])
	--关闭
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local closeBtn = MenuButton.new(normal, selected, nil, function ()
		self:pop()
		self.rhand(2)
	end):addTo(self:getBg()):rightTo(goBtn,20)
	closeBtn:setLabel(CommonText[1023])
end

return DetailRefineMasterDialog