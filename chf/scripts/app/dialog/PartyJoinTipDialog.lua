--
-- Author: gf
-- Date: 2015-12-28 16:25:34
-- 军团奖励


local Dialog = require("app.dialog.Dialog")
local PartyJoinTipDialog = class("PartyJoinTipDialog", Dialog)

function PartyJoinTipDialog:ctor()
	PartyJoinTipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function PartyJoinTipDialog:onEnter()
	PartyJoinTipDialog.super.onEnter(self)

	self:setTitle(CommonText[105])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)


	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(480, 140))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)
	
	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, 56, {count = 5})
	itemView:setPosition(70,infoBg:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView,infoBg)
	infoBg:addChild(itemView)

	local lab = ui.newTTFLabel({text = CommonText[837], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 130, y = infoBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	lab:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	
	local awardBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardHandler)):addTo(infoBg)
	awardBtn:setPosition(400,infoBg:getContentSize().height / 2)
	awardBtn:setLabel(CommonText[672][1])
	awardBtn:setEnabled(UserMO.partyTipAward_ and UserMO.partyTipAward_ == 1)
	self.awardBtn = awardBtn


	local infoBg1 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg1:setPreferredSize(cc.size(480, 500))
	infoBg1:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 400 - infoBg:getContentSize().height / 2)

	for index=1,#CommonText[834] do
		local name = ui.newTTFLabel({text = CommonText[834][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 25, y = infoBg1:getContentSize().height - 30 - (index-1) * 100, color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
		name:setAnchorPoint(cc.p(0, 0.5))
		local content = ui.newTTFLabel({text = CommonText[835][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 25, y = infoBg1:getContentSize().height - 60 - (index-1) * 100, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
		content:setAnchorPoint(cc.p(0, 0.5))
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local creatBtn = MenuButton.new(normal, selected, nil, handler(self,self.goPartyHandler)):addTo(self:getBg())
	creatBtn:setPosition(self:getBg():getContentSize().width / 2 - 120,80)
	creatBtn:setLabel(CommonText[836][1])
	creatBtn:setTag(2)
	creatBtn:setVisible(not PartyMO.partyData_.partyId or PartyMO.partyData_.partyId == 0)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local joinBtn = MenuButton.new(normal, selected, nil, handler(self,self.goPartyHandler)):addTo(self:getBg())
	joinBtn:setPosition(self:getBg():getContentSize().width / 2 + 120,80)
	joinBtn:setLabel(CommonText[836][2])
	joinBtn:setTag(1)
	joinBtn:setVisible(not PartyMO.partyData_.partyId or PartyMO.partyData_.partyId == 0)


	self.m_partyTipHandler = Notify.register(LOCAL_MYPARTY_UPDATE_EVENT, handler(self, self.updateTip))
end

function PartyJoinTipDialog:goPartyHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynGetPartyRank(function()
		Loading.getInstance():unshow()
		require("app.view.AllPartyView").new(tag):push()
		end, 0, 1)
end

function PartyJoinTipDialog:awardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynDoPartyTipAward(function()
		Loading.getInstance():unshow()
		self:updateTip()
		end)
end

function PartyJoinTipDialog:updateTip()
	self.awardBtn:setEnabled(UserMO.partyTipAward_ and UserMO.partyTipAward_ == 1)
end


function PartyJoinTipDialog:onExit()
	if self.m_partyTipHandler then
		Notify.unregister(self.m_partyTipHandler)
		self.m_partyTipHandler = nil
	end
end 


return PartyJoinTipDialog