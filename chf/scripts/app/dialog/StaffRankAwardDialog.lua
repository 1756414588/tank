
STAFF_RANK_AWARD_PERSON = 1
STAFF_RANK_AWARD_PARTY = 2

--------------------------------------------------------------------
-- 编制排行奖励一览TableView
--------------------------------------------------------------------

local StaffRankAwardTableView = class("StaffRankAwardTableView", TableView)

function StaffRankAwardTableView:ctor(size, staffType)
	StaffRankAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 200)

	if staffType == STAFF_RANK_AWARD_PERSON then
		self.list = PartyBattleMO.getRankAward(4)
	elseif staffType == STAFF_RANK_AWARD_PARTY then
		self.list = PartyBattleMO.getRankAward(5)
	end
end

function StaffRankAwardTableView:numberOfCells()
	return #self.list
end

function StaffRankAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function StaffRankAwardTableView:createCellAtIndex(cell, index)
	StaffRankAwardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]

	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self.m_cellSize.height - 30)

	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = bg:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	info:setAnchorPoint(cc.p(0,0.5))

	info:setString(string.format(CommonText[257],data.rank))

	local awardList = data.awards
	for index=1,#awardList do
		local award = awardList[index]
		local itemView = UiUtil.createItemView(award[1], award[2])
		if self.type == 2 and data.rank == 1 then
			itemView:setPosition(160 + itemView:getContentSize().width / 2 + (index - 1) * 130,bg:getPositionY() - 80)
		else
			itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 130,bg:getPositionY() - 80)
		end
		itemView:setScale(0.8)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)		

		local propDB = UserMO.getResourceData(award[1], award[2])
		local name = ui.newTTFLabel({text = propDB.name2 .. " * " .. award[3], font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end

	return cell
end

-- function StaffRankAwardTableView:onExit()
-- 	StaffRankAwardTableView.super.onExit(self)
-- end

--------------------------------------------------------------------
-- 编制排行榜View
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local StaffRankAwardDialog = class("StaffRankAwardDialog", Dialog)

function StaffRankAwardDialog:ctor(staffType)
	StaffRankAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
	self.m_staffType = staffType
end

function StaffRankAwardDialog:onEnter()
	StaffRankAwardDialog.super.onEnter(self)
	
	self:setTitle(CommonText[609])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = StaffRankAwardTableView.new(cc.size(btm:getContentSize().width - 30, btm:getContentSize().height - 20 - 120), self.m_staffType):addTo(btm)
	view:setPosition(15, 120)
	view:reloadData()

	-- 当前排名
	local label = ui.newTTFLabel({text = CommonText[440] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 135, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if self.m_staffType == STAFF_RANK_AWARD_PERSON then
		if StaffMO.rankPerson_ > 0 then
			value:setString(StaffMO.rankPerson_)
		else
			value:setString(CommonText[768])  -- 未上榜
		end
	elseif self.m_staffType == STAFF_RANK_AWARD_PARTY then
		if StaffMO.rankParty_ > 0 then
			value:setString(StaffMO.rankParty_)
		else
			value:setString(CommonText[768])  -- 未上榜
		end
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onAwardCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 80)
	self.m_awardBtn = btn
	self:checkState()
end

function StaffRankAwardDialog:checkState()
	local key = self.m_staffType == STAFF_RANK_AWARD_PERSON and "rankPersonReceive_" or "rankPartyReceive_"
	self.m_awardBtn:setEnabled(false)
	self.m_awardBtn:setLabel(CommonText[672][1])
	if StaffMO[key] == 1 then
		self.m_awardBtn:setEnabled(true)
	elseif StaffMO[key] == 2 then
		self.m_awardBtn:setLabel(CommonText[672][2])
	end
end

function StaffRankAwardDialog:onAwardCallback(tag, sender)
	local function doneCallback(statsAward)
		Loading.getInstance():unshow()
		UiUtil.showAwards(statsAward)
		self:checkState()
	end

	if self.m_staffType == STAFF_RANK_AWARD_PERSON then
		Loading.getInstance():show()
		StaffBO.asynScoreAward(doneCallback)
	elseif self.m_staffType == STAFF_RANK_AWARD_PARTY then
		Loading.getInstance():show()
		StaffBO.asynPartyScoreAward(doneCallback)
	end
end

return StaffRankAwardDialog
