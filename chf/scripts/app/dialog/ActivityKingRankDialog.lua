--
-- Author: Gss
-- Date: 2018-12-07 11:19:55
--
-- 最强王者活动排行分榜界面  ActivityKingRankDialog

local ActivityKingRankTableView = class("ActivityKingRankTableView", TableView)

function ActivityKingRankTableView:ctor(size,data)
	ActivityKingRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 80)
	self.m_data = PbProtocol.decodeArray(data["kingRankInfo"])
end

function ActivityKingRankTableView:numberOfCells()
	return #self.m_data
end

function ActivityKingRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityKingRankTableView:createCellAtIndex(cell, index)
	ActivityKingRankTableView.super.createCellAtIndex(self, cell, index)
	local record = self.m_data[index]
	local rank = UiUtil.label(index):addTo(cell)
	rank:setPosition(75, self.m_cellSize.height / 2)

	local name = UiUtil.label(record.nick):addTo(cell)
	name:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local value = UiUtil.label(record.points,nil,COLOR[2]):addTo(cell)
	value:setPosition(self.m_cellSize.width - 65, self.m_cellSize.height / 2)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(cell, -1)
	line:setPreferredSize(cc.size(self.m_cellSize.width - 20, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, line:getContentSize().height)

	return cell
end

------------------------------------------------------------------------------
-- 奖励预览
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ActivityKingRankDialog = class("ActivityKingRankDialog", Dialog)

function ActivityKingRankDialog:ctor(rankData, rankKind, activity)
	ActivityKingRankDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 780)})
	self.m_rankData = rankData
	self.m_rankKind = rankKind
	self.m_activity = activity
end

function ActivityKingRankDialog:onEnter()
	ActivityKingRankDialog.super.onEnter(self)
	self:setTitle(CommonText[276])
	self:showUI()
end

function ActivityKingRankDialog:showUI()
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(self:getBg():width() - 40, self:getBg():height() - 20))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local myRank = UiUtil.label(CommonText[10067][4]):addTo(btm)
	if self.m_rankKind == 5 then
		myRank:setString(CommonText[3010][1])
	end
	myRank:setAnchorPoint(cc.p(0, 0.5))
	myRank:setPosition(30,btm:height() - 70)
	local value = UiUtil.label(self.m_rankData.myRank,nil,COLOR[2]):rightTo(myRank)

	local point = UiUtil.label(CommonText[764][1]):alignTo(myRank, -30, 1)
	local myPoint = UiUtil.label(self.m_rankData.myPoint,nil,COLOR[2]):rightTo(point)
	if self.m_rankKind == 5 then
		point:setString(CommonText[3010][2])
	end

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, btm:width()-20, btm:height()-240):addTo(btm)
	bg:setPosition(btm:width() / 2, bg:height() / 2 + 120)

	local name = UiUtil.label(CommonText[3007][1]):addTo(bg)
	name:setPosition(bg:width() / 2, bg:height() - 23)
	if self.m_rankKind == 5 then
		name:setString(CommonText[3007][4])
	end
	local rank = UiUtil.label(CommonText[3007][2]):leftTo(name, 140)
	local value = UiUtil.label(CommonText[3007][3]):rightTo(name, 140)

	local view = ActivityKingRankTableView.new(cc.size(bg:width() - 20, bg:height() - 60),self.m_rankData):addTo(bg)
	view:setPosition(0,10) 
	view:reloadData()

	--奖励一览
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.showAward)):addTo(btm):pos(btm:width() / 4, 70)
	btn:setLabel(CommonText[771])
	btn.index = index

	--领取奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local awardBtn = MenuButton.new(normal, selected, disabled, handler(self, self.rewardAward)):addTo(btm):pos(btm:width() / 4 * 3, 70)
	awardBtn:setLabel(CommonText[777][1])
	self.m_awardBtn = awardBtn
	if self.m_rankData.status == 1 then
		awardBtn:setEnabled(false)
		awardBtn:setLabel(CommonText[777][3])
	end
end

function ActivityKingRankDialog:showAward(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.KingRankAwardDialog").new(self.m_rankKind):push()
end

function ActivityKingRankDialog:rewardAward(tag, sender)
	ManagerSound.playNormalButtonSound()

	if self.m_rankKind == 4 or self.m_rankKind == 5 then
		if ManagerTimer.getTime() < self.m_activity.endTime or ManagerTimer.getTime() > self.m_activity.displayTime then
			Toast.show(CommonText[3008])
			return
		end
	else
		local stage = ActivityCenterMO.getActivityStage(self.m_activity)
		if self.m_rankKind >= stage and stage ~= 4 then
			Toast.show(CommonText[3008])
			return
		end
	end

	local maxNum = ActivityCenterMO.getMaxNumByKind(self.m_rankKind)
	if self.m_rankData.myRank > maxNum or self.m_rankData.myRank <= 0 then --如果大于榜数,或者没上榜
		Toast.show(CommonText[3011])
		return
	end

	if self.m_rankKind == 5 and (not PartyMO.partyData_ or not PartyMO.partyData_.partyName) then
		Toast.show(CommonText[3012])
		return
	end

	ActivityCenterBO.getActivityKingRankAwards(function (success)
		if success then
			self.m_awardBtn:setEnabled(false)
			self.m_awardBtn:setLabel(CommonText[777][3])
		end
	end,self.m_rankKind)
end

return ActivityKingRankDialog
