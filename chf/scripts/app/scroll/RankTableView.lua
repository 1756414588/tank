
-- 排行榜

-- MYS 获取排行榜等级颜色
local function getRankColor(rank)
	if rank == 1 then return COLOR[5]
	elseif rank == 2 then return COLOR[12]
	elseif rank == 3 then return COLOR[4]
	elseif rank <= 10 then return cc.c3b(249, 242, 164)
	else return cc.c3b(255, 255, 255)
	end
end

local RankTableView = class("RankTableView", TableView)

function RankTableView:ctor(size, rankType)
	RankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 80)

	self.m_rankType = rankType
	local outindex = self.m_rankType
	if not UserMO.queryFuncOpen(UFP_NEW_PLAYER_POWER) then
		outindex = self.m_rankType == 15 and 14 or self.m_rankType
	end		
	self.m_ranks = RankMO.getRanksByType(outindex)
	if not self.m_ranks then self.m_ranks = {} end
end

function RankTableView:numberOfCells()
	if #self.m_ranks < RANK_PAGE_NUM or #self.m_ranks >= 100 then
		return #self.m_ranks
	else
		return #self.m_ranks + 1
	end
end

function RankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RankTableView:createCellAtIndex(cell, index)
	RankTableView.super.createCellAtIndex(self, cell, index)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width-24, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2 + 5, 5)

	if index == #self.m_ranks + 1 then -- 最后一个按钮
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_normal.png")
		normal:setPreferredSize(cc.size(420, 100))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_selected.png")
		selected:setPreferredSize(cc.size(420, 100))
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onNextCallback))
		btn:setLabel(CommonText[577])
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		return cell
	end

	-- 排行
	local rankView = ArenaBO.createRank(index):addTo(cell)
	if self.m_rankType == 15 then
		rankView:setPosition(100, self.m_cellSize.height / 2)
	else
		rankView:setPosition(65, self.m_cellSize.height / 2)
	end

	local rankData = self.m_ranks[index]

	local name = nil
	if self.m_rankType == 14 then -- 军衔等级
		name = ui.newTTFLabel({text = rankData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 230, y = 52, color = getRankColor(index), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		name:setAnchorPoint(cc.p(0.5, 0.5))
	elseif self.m_rankType == 15 then -- 总实力
		name = ui.newTTFLabel({text = rankData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = 52, color = getRankColor(index), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		name:setAnchorPoint(cc.p(0.5, 0.5))
	else
		name = ui.newTTFLabel({text = rankData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 158 - 40, y = 52, color = getRankColor(index), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		name:setAnchorPoint(cc.p(0, 0.5))
	end
	cell.name = rankData.name

	-- -- 军团
	-- local label = ui.newTTFLabel({text = CommonText[452][1] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = name:getPositionX(), y = name:getPositionY() - 28, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- label:setAnchorPoint(cc.p(0, 0.5))
	
	if self.m_rankType == 8 then  -- 进度
		local value = ui.newTTFLabel({text = (rankData.lv % 100), font = G_FONT, size = FONT_SIZE_SMALL, x = 312, y = name:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	elseif self.m_rankType == 9 then -- 编制称号
		local staffingName = ""
		if rankData.lv == 0 then  -- 无
			staffingName = CommonText[108]
		else
			local staff = StaffMO.queryStaffById(rankData.lv)
			staffingName = staff.name
		end
		local value = ui.newTTFLabel({text = staffingName, font = G_FONT, size = FONT_SIZE_SMALL, x = 312, y = name:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	elseif self.m_rankType == 14 then -- 军衔等级
	elseif self.m_rankType == 15 then -- 总实力
		if UserMO.queryFuncOpen(UFP_NEW_PLAYER_POWER) then
			local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(rankData.value,nil,nil,true), font = "fnt/num_2.fnt"}):addTo(cell)
			value:setPosition(405, name:getPositionY())
		else
			local value = ui.newTTFLabel({text = "-", font = G_FONT, size = FONT_SIZE_SMALL,
			x = 405, y = name:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		end
	else
		-- 等级
		local value = ui.newTTFLabel({text = rankData.lv, font = G_FONT, size = FONT_SIZE_SMALL, x = 312, y = name:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end

	if self.m_rankType == 1 or self.m_rankType == 7 or self.m_rankType == 12 then -- 战斗力
		local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(rankData.value), font = "fnt/num_2.fnt"}):addTo(cell)
		value:setPosition(412, name:getPositionY())
	elseif self.m_rankType == 2 or self.m_rankType == 3 then
		local value = ui.newTTFLabel({text = rankData.value, font = G_FONT, size = FONT_SIZE_SMALL, x = 412, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	elseif self.m_rankType == 8 then -- 极限副本
		local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(rankData.value), font = "fnt/num_2.fnt"}):addTo(cell)
		value:setPosition(412, name:getPositionY())
	elseif self.m_rankType == 9 or self.m_rankType == 13 then -- 编制等级
		local value = ui.newTTFLabel({text = rankData.value, font = G_FONT, size = FONT_SIZE_SMALL, x = 412, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	elseif self.m_rankType == 10 or self.m_rankType == 11 then
		-- local t = self.m_rankType == 10 and ATTRIBUTE_INDEX_FRIGHTEN or ATTRIBUTE_INDEX_FORTITUDE
		local value = ui.newTTFLabel({text = "+" .. string.format("%.2f",rankData.value/1000), font = G_FONT, size = FONT_SIZE_SMALL, x = 412, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	elseif self.m_rankType == 14 then -- 军衔等级
		local valueName = rankData.value == 0 and CommonText[509] or MilitaryRankMO.queryById(rankData.value).name
		local value = ui.newTTFLabel({text = valueName, font = G_FONT, size = FONT_SIZE_SMALL, x = 412, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	elseif self.m_rankType == 15 then -- 总实力
		--dump(rankData)
		local  valueName = ""
		if UserMO.queryFuncOpen(UFP_NEW_PLAYER_POWER) then
			valueName = rankData.lv == 0 and CommonText[509] or MilitaryRankMO.queryById(rankData.lv).name
		else
			valueName = rankData.value == 0 and CommonText[509] or MilitaryRankMO.queryById(rankData.value).name
		end			
		local value = ui.newTTFLabel({text = valueName, font = G_FONT, size = FONT_SIZE_SMALL, x = 522, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	else
		-- local attrData = EquipBO.getEquipAttrData(rankData.value, rankData.lv)
		local attrData = EquipBO.getEquipAttrData(rankData.value, rankData.lv, rankData.value2)
		local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = 412, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end

	return cell
end

function RankTableView:cellTouched(cell, index)
	if not cell.name or cell.name == "" then return end

	if cell.name == UserMO.nickName_ then return end

	if self.m_rankType == 8 then return end

	local function doneCallback(man)
		Loading.getInstance():unshow()

		if man.lordId == UserMO.lordId_ then return end
		-- dump(man)

		local player = {icon = man.icon, nick = man.nick, level = man.level, lordId = man.lordId, rank = man.ranks,
	        fight = man.fight, sex = man.sex, party = man.partyName, pros = man.pros, prosMax = man.prosMax}
		require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_FRIEND, player):push()
	end
	Loading.getInstance():show()
	SocialityBO.asynSearchPlayer(doneCallback, cell.name)
end

function RankTableView:onNextCallback(tag, sender)
	local outindex = self.m_rankType
	if not UserMO.queryFuncOpen(UFP_NEW_PLAYER_POWER) then
		outindex = self.m_rankType == 15 and 14 or self.m_rankType
	end		
	local function showData()
		Loading.getInstance():unshow()

		local oldHeight = self:getContainer():getContentSize().height

		self.m_ranks = RankMO.getRanksByType(outindex)
		if not self.m_ranks then self.m_ranks = {} end

		self:reloadData()

		local delta = self:getContainer():getContentSize().height - oldHeight
		self:setContentOffset(cc.p(0, -delta))
	end

	local page = math.ceil(#self.m_ranks / RANK_PAGE_NUM)

	Loading.getInstance():show()
	RankBO.asynGetRank(showData, outindex, page + 1)
end

return RankTableView
