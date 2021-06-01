--
-- Author: gf
-- Date: 2015-09-11 13:43:24
--


local PartyTableView = class("PartyTableView", TableView)

function PartyTableView:ctor(size)
	PartyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 110)
end

function PartyTableView:onEnter()
	PartyTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_LIST_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyTableView:numberOfCells()
	if #PartyMO.allPartyList_ > 0 and #PartyMO.allPartyList_ % 20 == 0 then
		return #PartyMO.allPartyList_ + 1
	else
		return #PartyMO.allPartyList_
	end
end

function PartyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyTableView:createCellAtIndex(cell, index)
	PartyTableView.super.createCellAtIndex(self, cell, index)

	if #PartyMO.allPartyList_ > 0 and #PartyMO.allPartyList_ % 20 and index == #PartyMO.allPartyList_ + 1 then
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_normal.png")
		normal:setPreferredSize(cc.size(600, 100))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_selected.png")
		selected:setPreferredSize(cc.size(600, 100))
		local getNextButton = MenuButton.new(normal, selected, disabled, handler(self,self.getNextHandler)):addTo(cell)
		getNextButton:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		getNextButton.page = (index - 1) / 20
		getNextButton:setLabel(CommonText[577])
	else
		local party = PartyMO.allPartyList_[index]
		
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 105))

		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		
		local rankTitle = ArenaBO.createRank(party.rank)
		rankTitle:setPosition(45, bg:getContentSize().height / 2)
		bg:addChild(rankTitle)
		
		local name = ui.newTTFLabel({text = CommonText[567][1] .. party.partyName, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 110, y = bg:getContentSize().height / 2 + 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		name:setAnchorPoint(cc.p(0, 0.5))

		local applyLab = ui.newTTFLabel({text = CommonText[615], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = name:getPositionX() + name:getContentSize().width, y = bg:getContentSize().height / 2 + 30, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		applyLab:setAnchorPoint(cc.p(0, 0.5))
		applyLab:setVisible(PartyMO.isInApply(party.partyId))

		local levelLab = ui.newTTFLabel({text = CommonText[567][2], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 110, y = bg:getContentSize().height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		levelLab:setAnchorPoint(cc.p(0, 0.5))

		local levelValue = ui.newTTFLabel({text = party.partyLv, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = levelLab:getPositionX() + levelLab:getContentSize().width, y = levelLab:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		levelValue:setAnchorPoint(cc.p(0, 0.5))

		local fightLab = ui.newTTFLabel({text = CommonText[567][4], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 110, y = bg:getContentSize().height / 2 - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		fightLab:setAnchorPoint(cc.p(0, 0.5))

		local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(party.fight), font = "fnt/num_2.fnt"}):addTo(bg)
		fightValue:setPosition(fightLab:getPositionX() + fightLab:getContentSize().width + fightValue:getContentSize().width / 2,fightLab:getPositionY())
		
		local numLab = ui.newTTFLabel({text = CommonText[567][3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 + 20, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		
		local numValue = ui.newTTFLabel({text = party.member .. "/" .. PartyMO.queryParty(party.partyLv).partyNum, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 - 20, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	end

	
	return cell
end

function PartyTableView:getNextHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynGetPartyRank(function()
		Loading.getInstance():unshow()
		end, sender.page,PartyMO.allPartyList_type_)
end

function PartyTableView:openDetail(party)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynGetParty(function(data)
		Loading.getInstance():unshow()
		require("app.dialog.PartyDetailDialog").new(data):push()
		end, party.partyId)
end


function PartyTableView:cellTouched(cell, index)
    gprint(index,"PartyTableView:cellTouched..index")
	local party = PartyMO.allPartyList_[index]
	self:openDetail(party)
end

function PartyTableView:updateListHandler(event)
	-- gdump(event,"eventeventeventevent")
	-- local offset = self:getContentOffset()
	self:reloadData()
	if event.obj and event.obj.page > 0 then
		self:setContentOffset(cc.p(0,-event.obj.count * 110))
	end
end



function PartyTableView:onExit()
	PartyTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end



return PartyTableView