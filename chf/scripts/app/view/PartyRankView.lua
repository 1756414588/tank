--
-- Author: gf
-- Date: 2015-11-24 10:48:21
-- 军团排名

local PartyRankView = class("PartyRankView", UiNode)

function PartyRankView:ctor(buildingId)
	PartyRankView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function PartyRankView:onEnter()
	PartyRankView.super.onEnter(self)

	self:setTitle(CommonText[751])


	local height = 0
	if PartyMO.myPartyRank then
		self:showMyParty()
		height = 110
	end

	local PartyRankTableView = require("app.scroll.PartyRankTableView")

	local view = PartyRankTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height - 130 - height - 4)):addTo(self:getBg(),1)
	view:setPosition(0, 30)
	view:reloadData()
end

function PartyRankView:showMyParty()
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	bg:setPreferredSize(cc.size(607, 105))

	bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 100 - 55)
	
	local party = PartyMO.myPartyRank
	local rankTitle = ArenaBO.createRank(party.rank)
	rankTitle:setPosition(45, bg:getContentSize().height / 2)
	bg:addChild(rankTitle)
	
	local nameLab = ui.newTTFLabel({text = CommonText[567][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2 + 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	nameLab:setAnchorPoint(cc.p(0, 0.5))

	local nameValue = ui.newTTFLabel({text = party.partyName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = nameLab:getPositionX() + nameLab:getContentSize().width, y = bg:getContentSize().height / 2 + 30, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	nameValue:setAnchorPoint(cc.p(0, 0.5))


	local hallLevelLab = ui.newTTFLabel({text = CommonText[752][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	hallLevelLab:setAnchorPoint(cc.p(0, 0.5))

	local hallLevelValue = ui.newTTFLabel({text = party.partyLv, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = hallLevelLab:getPositionX() + hallLevelLab:getContentSize().width, y = hallLevelLab:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	hallLevelValue:setAnchorPoint(cc.p(0, 0.5))

	local scienceLevelLab = ui.newTTFLabel({text = CommonText[752][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = hallLevelValue:getPositionX() + hallLevelValue:getContentSize().width / 2 + 30, y = bg:getContentSize().height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	scienceLevelLab:setAnchorPoint(cc.p(0, 0.5))

	local scienceLevelValue = ui.newTTFLabel({text = party.scienceLv, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = scienceLevelLab:getPositionX() + scienceLevelLab:getContentSize().width, y = scienceLevelLab:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	scienceLevelValue:setAnchorPoint(cc.p(0, 0.5))

	local wealLevelLab = ui.newTTFLabel({text = CommonText[752][3], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2 - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	wealLevelLab:setAnchorPoint(cc.p(0, 0.5))

	local wealLevelValue = ui.newTTFLabel({text = party.wealLv, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = wealLevelLab:getPositionX() + wealLevelLab:getContentSize().width, y = wealLevelLab:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	wealLevelValue:setAnchorPoint(cc.p(0, 0.5))

	
	local buildLab = ui.newTTFLabel({text = CommonText[752][4], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 + 20, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	local buildValue = ui.newTTFLabel({text = party.build, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 - 20, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	-- nodeTouchEventProtocol(bg, function(event) self:showPartyDetail(party) end, nil, nil, true)
end

-- function PartyRankView:showPartyDetail(party)
-- 	Loading.getInstance():show()
-- 	PartyBO.asynGetParty(function(data)
-- 		Loading.getInstance():unshow()
-- 		require("app.dialog.PartyDetailDialog").new(data):push()
-- 		end, party.partyId)
-- end



function PartyRankView:onExit()
	PartyBO.clearAllParty()
end





return PartyRankView
