--
-- Author: gf
-- Date: 2015-12-04 16:02:58
-- 极限单兵 排行奖励一览


local ActivityFortuneAwardTableView = class("ActivityFortuneAwardTableView", TableView)

--不显示名字
local NoName = {
	[ACTIVITY_ID_FORTUNE] = 1,
}

function ActivityFortuneAwardTableView:ctor(size,activityId)
	ActivityFortuneAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.activityId = activityId
	self.m_cellSize = cc.size(self:getViewSize().width, 200)
	if activityId == ACTIVITY_ID_FORTUNE or activityId == ACTIVITY_ID_PARTDIAL or activityId == ACTIVITY_ID_CONSUMEDIAL 
	    or activityId == ACTIVITY_ID_ENERGYSPAR or activityId == ACTIVITY_ID_EQUIPDIAL or activityId == ACTIVITY_ID_TACTICSPAR then
		self.list = ActivityCenterMO.activityContents_[activityId].actFortuneRank.rankAward
	elseif activityId == ACTIVITY_ID_BEE or activityId == ACTIVITY_ID_BEE_NEW then
		self.list = ActivityCenterMO.activityContents_[activityId].actBeeRank.rankAward
	elseif activityId == ACTIVITY_ID_TANKDESTROY then
		self.list = ActivityCenterMO.activityContents_[activityId].actFortuneRank.rankAward
	elseif activityId == ACTIVITY_ID_GENERAL or activityId == ACTIVITY_ID_GENERAL1 then
		self.list = ActivityCenterMO.activityContents_[activityId].actFortuneRank.rankAward
	elseif activityId == ACTIVITY_ID_PARTY_DONATE then
		self.list = ActivityMO.getActivityContentById(activityId).rankAward
	elseif activityId == ACTIVITY_ID_STOREHOUSE or activityId == ACTIVITY_ID_NEWYEAR then
		self.list = ActivityCenterMO.activityContents_[activityId].rankAward
	else
		self.list = ActivityCenterMO.getRankDataById(activityId)
	end
end

function ActivityFortuneAwardTableView:numberOfCells()
	return #self.list
end

function ActivityFortuneAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityFortuneAwardTableView:createCellAtIndex(cell, index)
	ActivityFortuneAwardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]

	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(10, self.m_cellSize.height - 30)

	local awardList = nil
	if table.isexist(data, "awardList") then
		awardList = {}
		for k,v in ipairs(json.decode(data.awardList)) do
			table.insert(awardList, {type = v[1],id = v[2],count = v[3]})
		end
	else
		awardList = PbProtocol.decodeArray(data["award"]) or {}
	end
	-- gdump(dayWeal,"当前等级每日福利")
	for index=1,#awardList do
		local award = awardList[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setPosition(20 + itemView:getContentSize().width / 2 + (index - 1) * 120,bg:getPositionY() - 80)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)		
		if not NoName[self.activityId] then
			local propDB = UserMO.getResourceData(award.type, award.id)
			local name = ui.newTTFLabel({text = propDB.name2 .. (self.activityId == ACTIVITY_ID_ENERGYSPAR and "" or ("*" .. award.count)), font = G_FONT, size = 18, 
				x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
		end
	end

	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = bg:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	info:setAnchorPoint(cc.p(0,0.5))

	local rankValue
	if data.rank == data.rankEd then
		rankValue = data.rank
	else
		rankValue = data.rank .. "-" .. data.rankEd 
	end

	info:setString(string.format(CommonText[772],rankValue))

	return cell
end



function ActivityFortuneAwardTableView:onExit()
	ActivityFortuneAwardTableView.super.onExit(self)

end



return ActivityFortuneAwardTableView