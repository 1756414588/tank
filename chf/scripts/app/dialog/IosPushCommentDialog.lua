--
-- Author: gf
-- Date: 2015-09-21 16:31:31
-- IOS push 评论弹出框

local Dialog = require("app.dialog.Dialog")
local IosPushCommentDialog = class("IosPushCommentDialog", Dialog)



function IosPushCommentDialog:ctor()
	IosPushCommentDialog.super.ctor(self, IMAGE_COMMON .. "push/push_bg.png", UI_ENTER_NONE,{scale9Size = cc.size(550, 465),alpha = 100})
end

function IosPushCommentDialog:onEnter()
	IosPushCommentDialog.super.onEnter(self)
	
	-- self:setOutOfBgClose(true)
	-- self:hasCloseButton(false)

	-- self:setTitle(CommonText[1501][5])

	-- self.m_returnButton:setVisible(false)

	-- local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	-- btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	-- btm:setScaleX((self:getBg():getContentSize().width - 40) / btm:getContentSize().width)
	-- btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)


	-- local sloganBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	-- sloganBg:setPreferredSize(cc.size(390, 350))
	-- sloganBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 10)

	-- self:getBg():setPosition(,self.sender:getPositionY() + 90 / 2 + bg:getContentSize().height / 2 + 10)

	local titLab = ui.newTTFLabel({text = CommonText[1501][1], font = G_FONT, size = 30, 
		x = self:getBg():getContentSize().width / 2, y = 360, color = cc.c3b(0, 0, 0), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	titLab:setAnchorPoint(cc.p(0.5, 0.5))

	--给个好评
	local normal = display.newSprite(IMAGE_COMMON .. "push/push_btn2_normal.jpg")
	local selected = display.newSprite(IMAGE_COMMON .. "push/push_btn2_selected.jpg")
	local goodBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCommentCallback)):addTo(self:getBg())
	goodBtn:setLabel(CommonText[1501][4])
	goodBtn:setPosition(self:getBg():getContentSize().width / 2,227)
	goodBtn.m_label:setColor(cc.c3b(14,106,231))
	goodBtn.m_label:setFontSize(30)
	goodBtn.type = 3

	--给个建议
	local normal = display.newSprite(IMAGE_COMMON .. "push/push_btn2_normal.jpg")
	local selected = display.newSprite(IMAGE_COMMON .. "push/push_btn2_selected.jpg")
	local sugBtn = MenuButton.new(normal, selected, nil, handler(self,self.onCommentCallback)):addTo(self:getBg())
	sugBtn:setLabel(CommonText[1501][3])
	sugBtn:setPosition(self:getBg():getContentSize().width / 2,135)
	sugBtn.m_label:setColor(cc.c3b(14,106,231))
	sugBtn.m_label:setFontSize(30)
	sugBtn.type = 2

	--残忍拒绝
	local normal = display.newSprite(IMAGE_COMMON .. "push/push_btn1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "push/push_btn1_selected.png")
	local noBtn = MenuButton.new(normal, selected, nil, handler(self,self.onCommentCallback)):addTo(self:getBg())
	noBtn:setLabel(CommonText[1501][2])
	noBtn:setPosition(self:getBg():getContentSize().width / 2,38)
	noBtn.m_label:setColor(cc.c3b(14,106,231))
	noBtn.m_label:setFontSize(30)
	noBtn.type = 1

	

	

end

function IosPushCommentDialog:onCommentCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	UserBO.asynPushComment(function()
		Loading.getInstance():unshow()
		self:pop()
		end,sender.type)
end



return IosPushCommentDialog