--
-- Author: gf
-- Date: 2015-12-17 13:50:25
-- 百团混战 战况列表


local PartyBProcessTableView = class("PartyBProcessTableView", TableView)

function PartyBProcessTableView:ctor(size)
	PartyBProcessTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 90)
end

function PartyBProcessTableView:onEnter()
	PartyBProcessTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_PROCESS_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyBProcessTableView:numberOfCells()
	return #self.m_list
end

function PartyBProcessTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyBProcessTableView:createCellAtIndex(cell, index)
	PartyBProcessTableView.super.createCellAtIndex(self, cell, index)

	local data = self.m_list[index]
		
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, 2))
	bg:setPosition(self.m_cellSize.width / 2, 0)
	
	local maskPic
	
	if self.processType == PARTY_BATTLE_PROCESS_TYPE_ALL then
		if UserMO.nickName_ == data.name1 or UserMO.nickName_ == data.name2 then
			maskPic = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_partyB2.png")
		elseif PartyMO.partyData_ and PartyMO.partyData_.partyName and (PartyMO.partyData_.partyName == data.partyName1 or PartyMO.partyData_.partyName == data.partyName2) then
			maskPic = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_partyB1.png")
		end
	elseif self.processType == PARTY_BATTLE_PROCESS_TYPE_PARTY then
		if UserMO.nickName_ == data.name1 or UserMO.nickName_ == data.name2 then
			maskPic = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_partyB2.png")
		end
	end

	if maskPic then
		cell:addChild(maskPic,0)
		maskPic:setPreferredSize(cc.size(self.m_cellSize.width - 40, 80))
		maskPic:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	end

 	local timeLab = ui.newTTFLabel({text = os.date("%H:%M", data.time), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 65, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	timeLab:setAnchorPoint(cc.p(0.5, 0.5))
	--是否有最终名次
	if data.rank and data.rank > 0 then
		if data.rank == 1 then
			--决出第一名
			local lab1 = ui.newTTFLabel({text = CommonText[810][1], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 110, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			lab1:setAnchorPoint(cc.p(0, 0.5))

			local lab2 = ui.newTTFLabel({text = data.partyName1, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = lab1:getPositionX() + lab1:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			lab2:setAnchorPoint(cc.p(0, 0.5))

			local lab3 = ui.newTTFLabel({text = CommonText[810][2], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = lab2:getPositionX() + lab2:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			lab3:setAnchorPoint(cc.p(0, 0.5))

		elseif data.rank > 1 then
			--被淘汰
			local defPartyLab = ui.newTTFLabel({text = data.partyName1, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 110, y = self.m_cellSize.height / 2, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defPartyLab:setAnchorPoint(cc.p(0, 0.5))

			local lab2 = ui.newTTFLabel({text = CommonText[811][1], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = defPartyLab:getPositionX() + defPartyLab:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			lab2:setAnchorPoint(cc.p(0, 0.5)) 

			local atkPartyLab = ui.newTTFLabel({text = data.name1, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = lab2:getPositionX() + lab2:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			atkPartyLab:setAnchorPoint(cc.p(0, 0.5))

			local lab3 = ui.newTTFLabel({text = string.format(CommonText[811][2],data.rank), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = atkPartyLab:getPositionX() + atkPartyLab:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			lab3:setAnchorPoint(cc.p(0, 0.5)) 
		end

		local rankTitle = ArenaBO.createRank(data.rank)
		rankTitle:setPosition(533, self.m_cellSize.height / 2)
		cell:addChild(rankTitle)
	else
		local atkPartyLab = ui.newTTFLabel({text = data.partyName1, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 200, y = self.m_cellSize.height / 2 + 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		atkPartyLab:setAnchorPoint(cc.p(0.5, 0.5))

		local atkManLab = ui.newTTFLabel({text = data.name1 .. "(" .. data.hp1 .. "%)", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 200, y = self.m_cellSize.height / 2 - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		atkManLab:setAnchorPoint(cc.p(0.5, 0.5))

		--VS
		local vsLab = ui.newTTFLabel({text = "VS", font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 285, y = self.m_cellSize.height / 2, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		vsLab:setAnchorPoint(cc.p(0.5, 0.5))

		local defPartyLab = ui.newTTFLabel({text = data.partyName2, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 373, y = self.m_cellSize.height / 2 + 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defPartyLab:setAnchorPoint(cc.p(0.5, 0.5))

		local defManLab = ui.newTTFLabel({text = data.name2 .. "(" .. data.hp2 .. "%)", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 373, y = self.m_cellSize.height / 2 - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defManLab:setAnchorPoint(cc.p(0.5, 0.5))

		local resultLab = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 533, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		resultLab:setAnchorPoint(cc.p(0.5, 0.5))
		if data.result == 0 then
			resultLab:setString(CommonText[809][1])
			resultLab:setColor(COLOR[6])
		elseif data.result > 0 then
			resultLab:setString(string.format(CommonText[809][2],data.result))
			resultLab:setColor(COLOR[12])
		end
	end
	return cell
end


function PartyBProcessTableView:updateListHandler(event)
	self:reloadData()	
end

function PartyBProcessTableView:reloadData(type)
	if type then 
		self.processType = type
	end
	if not self.processType then self.processType = PARTY_BATTLE_PROCESS_TYPE_ALL end
	self.m_list = PartyBattleBO.getProcessDataBytype(self.processType)
	PartyBProcessTableView.super.reloadData(self)

	--非推送更新列表 自动滑倒最下
	local offsetY = #self.m_list * 90 - self.m_viewSize.height
	if offsetY > 0 then
		self:setContentOffset(cc.p(0, self:getContentOffset().y+offsetY))
	end

	-- if type then
	-- 	local offsetY = #self.m_list * 90 - self.m_viewSize.height
	-- 	if offsetY > 0 then
	-- 		self:setContentOffset(cc.p(0, self:getContentOffset().y+offsetY))
	-- 	end
	-- else
	-- 	local offsetY = #self.m_list * 90 - self.m_viewSize.height
	-- 	if offsetY > 0 and self.lastOffset then
	-- 		self:setContentOffset(cc.p(0, #self.m_list * 90 - self.lastOffsetY))
	-- 	end
	-- end
end

function PartyBProcessTableView:onExit()
	PartyBProcessTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end



return PartyBProcessTableView
