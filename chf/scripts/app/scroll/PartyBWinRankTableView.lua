--
-- Author: gf
-- Date: 2015-12-16 16:31:23
-- 百团混战 连胜排行

local PartyBWinRankTableView = class("PartyBWinRankTableView", TableView)

function PartyBWinRankTableView:ctor(size)
	PartyBWinRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 70)
end

function PartyBWinRankTableView:onEnter()
	PartyBWinRankTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_RANK_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyBWinRankTableView:numberOfCells()
	return #PartyBattleMO.rankWin
end

function PartyBWinRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyBWinRankTableView:createCellAtIndex(cell, index)
	PartyBWinRankTableView.super.createCellAtIndex(self, cell, index)

	local data = PartyBattleMO.rankWin[index]
		
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	
	local rankTitle = ArenaBO.createRank(data.rank)
	rankTitle:setPosition(40, 30)
	bg:addChild(rankTitle)
	
	local nameLab = ui.newTTFLabel({text = data.name, font = G_FONT, size = FONT_SIZE_SMALL, 
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

	local numLab = ui.newTTFLabel({text = data.winCount, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 336, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	numLab:setAnchorPoint(cc.p(0.5, 0.5))

	local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(data.fight), font = "fnt/num_2.fnt"}):addTo(bg)
	fightValue:setPosition(485,30)

	return cell
end


function PartyBWinRankTableView:updateListHandler(event)
	self:reloadData()
end


function PartyBWinRankTableView:onExit()
	PartyBWinRankTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end



return PartyBWinRankTableView
