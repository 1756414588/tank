--
-- Author: gf
-- Date: 2015-09-11 18:40:40
--
local Dialog = require("app.dialog.Dialog")
local PartyDetailDialog = class("PartyDetailDialog", Dialog)

function PartyDetailDialog:ctor(party)
	PartyDetailDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})

	self.party = party
end

function PartyDetailDialog:onEnter()
	PartyDetailDialog.super.onEnter(self)
	
	self:setTitle(CommonText[565][1])
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	for index = 1,#CommonText[571] - 1 do
		local labTit = ui.newTTFLabel({text = CommonText[571][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 60, y = btm:getContentSize().height - 70 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		labTit:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then
			value:setString(self.party.partyName)
		elseif index == 2 then
			value:setString(self.party.legatusName)
		elseif index == 3 then
			value:setString(self.party.rank)
			value:setColor(COLOR[2])
		elseif index == 4 then
			value:setString(self.party.partyLv)
		elseif index == 5 then
			value:setString(self.party.member .. "/" .. PartyMO.queryParty(self.party.partyLv).partyNum)
		elseif index == 6 then
			value:setString(CommonText[570][self.party.applyType])
		elseif index == 7 then
			local applyNeedString = ""
			if self.party.applyLv == 0 and self.party.applyFight == 0 then
				applyNeedString = CommonText[575][1]
			elseif self.party.applyLv > 0 and self.party.applyFight > 0 then
				applyNeedString = string.format(CommonText[575][2], self.party.applyLv) .. "  " .. string.format(CommonText[575][3], UiUtil.strNumSimplify(self.party.applyFight))
			else
				if self.party.applyLv > 0 then
					applyNeedString = string.format(CommonText[575][2], self.party.applyLv)
				else
					applyNeedString = string.format(CommonText[575][3], UiUtil.strNumSimplify(self.party.applyFight))
				end
			end
			value:setString(applyNeedString)
			value:setColor(COLOR[2])
		end
	end

	local sloganBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	sloganBg:setPreferredSize(cc.size(500, 250))
	sloganBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - sloganBg:getContentSize().height - 300)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		sloganBg:getContentSize().width / 2, sloganBg:getContentSize().height):addTo(sloganBg)

	local sloganLab = ui.newTTFLabel({text = CommonText[571][8], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)


	local sloganValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 0, y = 0, color = COLOR[1], align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(sloganBg:getContentSize().width - 20, 150)}):addTo(sloganBg)
	sloganValue:setAnchorPoint(cc.p(0, 1))
	sloganValue:setString(self.party.slogan)
	sloganValue:setPosition(10,sloganBg:getContentSize().height - 30)

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local applyBtn = MenuButton.new(normal, selected, disabled, handler(self,self.applyHandler)):addTo(self:getBg())
	applyBtn:setPosition(self:getBg():getContentSize().width / 2,20)
	applyBtn:setLabel(CommonText[574][1])
	applyBtn.party = self.party
	applyBtn:setEnabled(UserMO.level_ >= self.party.applyLv and UserMO.fightValue_ >= self.party.applyFight and self.party.member < PartyMO.queryParty(self.party.partyLv).partyNum)
	self.applyBtn = applyBtn
	applyBtn:setVisible(PartyMO.isInApply(self.party.partyId) == false and not (PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local cancelApplyBtn = MenuButton.new(normal, selected, nil, handler(self,self.cancelApplyHandler)):addTo(self:getBg())
	cancelApplyBtn:setPosition(self:getBg():getContentSize().width / 2,20)
	cancelApplyBtn:setLabel(CommonText[574][2])
	cancelApplyBtn.party = self.party
	cancelApplyBtn:setVisible(PartyMO.isInApply(self.party.partyId) == true and not (PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0))
	self.cancelApplyBtn = cancelApplyBtn
end

function PartyDetailDialog:applyHandler(tag, sender)
	local party = sender.party
	Loading.getInstance():show()
	PartyBO.asynPartyApply(function(applyType)
		Loading.getInstance():unshow()
		if applyType == PARTY_JOIN_TYPE_2 then
			self:updateApply()
		end
		end,party)
end

function PartyDetailDialog:cancelApplyHandler(tag, sender)
	local party = sender.party
	Loading.getInstance():show()
	PartyBO.asynCannlyApply(function()
		Loading.getInstance():unshow()
		self:updateApply()
		end,party)
end

function PartyDetailDialog:updateApply()
	self.applyBtn:setVisible(PartyMO.isInApply(self.party.partyId) == false and not (PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0))
	self.applyBtn:setEnabled(UserMO.level_ >= self.party.applyLv and UserMO.fightValue_ >= self.party.applyFight)
	self.cancelApplyBtn:setVisible(PartyMO.isInApply(self.party.partyId) == true and not (PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0))
end

return PartyDetailDialog