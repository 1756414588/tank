--
-- Author: gf
-- Date: 2015-09-21 16:31:31
-- 分享弹出框

local Dialog = require("app.dialog.Dialog")
local ShareDialog = class("ShareDialog", Dialog)

SHARE_TYPE_MAIL = 1 -- 邮件分享
SHARE_TYPE_TANK = 2 -- 坦克分享
SHARE_TYPE_PARTY_TREND = 3 --军团情报分享
SHARE_TYPE_HERO = 4 --将领分享
SHARE_TYPE_MEDAL = 5 --勋章分享

function ShareDialog:ctor(shareType, data,sender)
	ShareDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_19.png", UI_ENTER_NONE,{scale9Size = cc.size(190, 180),alpha = 0})

	self.m_shareType = shareType
	self.m_data = data
	self.sender = sender
end

function ShareDialog:onEnter()
	ShareDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_19.png")

	if self.m_shareType == SHARE_TYPE_PARTY_TREND then
		self:getBg():setPosition(self.sender.x,self.sender.y)
	else
		self:getBg():setPosition(self.sender:getPositionX(),self.sender:getPositionY() + 90 / 2 + bg:getContentSize().height / 2 + 10)
	end

	local titLab = ui.newTTFLabel({text = CommonText[673][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = 155, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	titLab:setAnchorPoint(cc.p(0, 0.5))

	--军团频道
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local partyBtn = MenuButton.new(normal, selected, nil, handler(self,self.onPartyCallback)):addTo(self:getBg())
	partyBtn:setLabel(CommonText[673][2])
	partyBtn:setPosition(self:getBg():getContentSize().width / 2,110)

	--世界频道
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local partyBtn = MenuButton.new(normal, selected, nil, handler(self, self.onWorldCallback)):addTo(self:getBg())
	partyBtn:setLabel(CommonText[673][3])
	partyBtn:setPosition(self:getBg():getContentSize().width / 2,50)
end

function ShareDialog:onPartyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doneCallback()
		Loading.getInstance():unshow()
		Toast.show(CommonText[406]) -- 分享成功
	end

	Loading.getInstance():show()
	if self.m_shareType == SHARE_TYPE_MAIL then
		ChatBO.asynShareReport(doneCallback, 2, self.m_data.keyId)
	elseif self.m_shareType == SHARE_TYPE_TANK then
		ChatBO.asynShareReport(doneCallback, 2, nil, self.m_data)
	elseif self.m_shareType == SHARE_TYPE_PARTY_TREND then
		ChatBO.asynDoChat(doneCallback, CHAT_TYPE_PARTY, nil, nil, self.m_data)
	elseif self.m_shareType == SHARE_TYPE_HERO then
		ChatBO.asynShareReport(doneCallback, CHAT_TYPE_PARTY, nil, nil, self.m_data)
	elseif self.m_shareType == SHARE_TYPE_MEDAL then
		ChatBO.asynShareReport(doneCallback, CHAT_TYPE_PARTY, nil, nil, nil, self.m_data)
	end
end

-- 世界分享
function ShareDialog:onWorldCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	local function doneCallback()
		Loading.getInstance():unshow()
		Toast.show(CommonText[406])
	end
	
	Loading.getInstance():show()
	if self.m_shareType == SHARE_TYPE_MAIL then
		ChatBO.asynShareReport(doneCallback, 1, self.m_data.keyId)
	elseif self.m_shareType == SHARE_TYPE_TANK then
		ChatBO.asynShareReport(doneCallback, 1, nil, self.m_data)
	elseif self.m_shareType == SHARE_TYPE_PARTY_TREND then
		ChatBO.asynDoChat(doneCallback, CHAT_TYPE_WORLD, nil, nil, self.m_data)
	elseif self.m_shareType == SHARE_TYPE_HERO then
		ChatBO.asynShareReport(doneCallback, CHAT_TYPE_WORLD, nil, nil, self.m_data)
	elseif self.m_shareType == SHARE_TYPE_MEDAL then
		ChatBO.asynShareReport(doneCallback, CHAT_TYPE_WORLD, nil, nil, nil, self.m_data)	
	end
end

return ShareDialog