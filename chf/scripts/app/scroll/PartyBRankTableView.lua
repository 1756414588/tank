--
-- Author: gf
-- Date: 2015-12-16 18:48:03
-- 百团混战 军团排行


local PartyBRankTableView = class("PartyBRankTableView", TableView)

function PartyBRankTableView:ctor(size)
	PartyBRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 70)
end

function PartyBRankTableView:onEnter()
	PartyBRankTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_RANK_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyBRankTableView:numberOfCells()
	if #PartyBattleMO.rankParty > 0 and #PartyBattleMO.rankParty % 20 == 0 then
		return #PartyBattleMO.rankParty + 1
	else
		return #PartyBattleMO.rankParty
	end
end

function PartyBRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyBRankTableView:createCellAtIndex(cell, index)
	PartyBRankTableView.super.createCellAtIndex(self, cell, index)

	if #PartyBattleMO.rankParty > 0 and #PartyBattleMO.rankParty % 20 and index == #PartyBattleMO.rankParty + 1 then
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_normal.png")
		normal:setPreferredSize(cc.size(self:getViewSize().width, 90))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_selected.png")
		selected:setPreferredSize(cc.size(self:getViewSize().width, 90))
		local getNextButton = MenuButton.new(normal, selected, disabled, handler(self,self.getNextHandler)):addTo(cell)
		getNextButton:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 5)
		getNextButton.page = (index - 1) / 20
		getNextButton:setLabel(CommonText[577])
	else
		local data = PartyBattleMO.rankParty[index]
		
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, 2))

		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
		
		local rankTitle = ArenaBO.createRank(data.rank)
		rankTitle:setPosition(40, 30)
		bg:addChild(rankTitle)
		
		local nameLab = ui.newTTFLabel({text = data.partyName, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 177, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		nameLab:setAnchorPoint(cc.p(0.5, 0.5))

		if data.rank == 1 then
			nameLab:setColor(COLOR[6])
		elseif data.rank == 2 then
			nameLab:setColor(COLOR[12])
		elseif data.rank == 3 then
			nameLab:setColor(COLOR[4])
		else
			nameLab:setColor(COLOR[11])
		end

		local numLab = ui.newTTFLabel({text = data.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 336, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		numLab:setAnchorPoint(cc.p(0.5, 0.5))

		local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(data.fight), font = "fnt/num_2.fnt"}):addTo(bg)
		fightValue:setPosition(485,30)
		
	end

	
	return cell
end

function PartyBRankTableView:getNextHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBattleBO.asynWarRank(function()
		Loading.getInstance():unshow()
		end,sender.page)
end


function PartyBRankTableView:updateListHandler(event)
	-- gdump(event,"eventeventeventevent")
	-- local offset = self:getContentOffset()
	self:reloadData()
	if event.obj and event.obj.page > 0 then
		self:setContentOffset(cc.p(0,-event.obj.count * 70))
	end
end



function PartyBRankTableView:onExit()
	PartyBRankTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end



return PartyBRankTableView
