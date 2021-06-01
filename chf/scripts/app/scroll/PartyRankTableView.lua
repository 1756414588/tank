--
-- Author: gf
-- Date: 2015-11-24 11:01:58
--

local PartyRankTableView = class("PartyRankTableView", TableView)

function PartyRankTableView:ctor(size)
	PartyRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 110)
end

function PartyRankTableView:onEnter()
	PartyRankTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_RANK_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyRankTableView:numberOfCells()
	if #PartyMO.partyRankList_ > 0 and #PartyMO.partyRankList_ % 20 == 0 then
		return #PartyMO.partyRankList_ + 1
	else
		return #PartyMO.partyRankList_
	end
end

function PartyRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyRankTableView:createCellAtIndex(cell, index)
	PartyRankTableView.super.createCellAtIndex(self, cell, index)

	if #PartyMO.partyRankList_ > 0 and #PartyMO.partyRankList_ % 20 and index == #PartyMO.partyRankList_ + 1 then
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_normal.png")
		normal:setPreferredSize(cc.size(600, 100))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_selected.png")
		selected:setPreferredSize(cc.size(600, 100))
		local getNextButton = MenuButton.new(normal, selected, disabled, handler(self,self.getNextHandler)):addTo(cell)
		getNextButton:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		getNextButton.page = (index - 1) / 20
		getNextButton:setLabel(CommonText[577])
	else
		local party = PartyMO.partyRankList_[index]
		
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 105))

		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		
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
	end

	
	return cell
end

function PartyRankTableView:getNextHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynGetPartyLvRank(function()
		Loading.getInstance():unshow()
		end, sender.page)
end

-- function PartyRankTableView:openDetail(party)
-- 	ManagerSound.playNormalButtonSound()
-- 	Loading.getInstance():show()
-- 	PartyBO.asynGetParty(function(data)
-- 		Loading.getInstance():unshow()
-- 		require("app.dialog.PartyDetailDialog").new(data):push()
-- 		end, party.partyId)
-- end


-- function PartyRankTableView:cellTouched(cell, index)
--     gprint(index,"PartyRankTableView:cellTouched..index")
-- 	local party = PartyMO.partyRankList_[index]
-- 	self:openDetail(party)
-- end

function PartyRankTableView:updateListHandler(event)
	-- gdump(event,"eventeventeventevent")
	-- local offset = self:getContentOffset()
	self:reloadData()
	if event.obj and event.obj.page > 0 then
		self:setContentOffset(cc.p(0,-event.obj.count * 110))
	end
end



function PartyRankTableView:onExit()
	PartyRankTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end



return PartyRankTableView