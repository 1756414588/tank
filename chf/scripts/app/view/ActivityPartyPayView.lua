--
-- Author: Gss
-- Date: 2018-11-20 17:10:55
--
--军团充值活动 ActivityPartyPayView

local ActivityPartyPayTableView = class("ActivityPartyPayTableView", TableView)

function ActivityPartyPayTableView:ctor(size,activity)
	ActivityPartyPayTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 220)
	self.m_activity = activity
	self.m_awards = ActivityCenterMO.getActivityContentById(activity.activityId)
end

function ActivityPartyPayTableView:onEnter()
	ActivityPartyPayTableView.super.onEnter(self)
end

function ActivityPartyPayTableView:numberOfCells()
	return #self.m_awards.activityCond
end

function ActivityPartyPayTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityPartyPayTableView:createCellAtIndex(cell, index)
	ActivityPartyPayTableView.super.createCellAtIndex(self, cell, index)
	local awards = self.m_awards.activityCond[index]

	local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width - 25, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)

	--title
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 30, self.m_cellSize.height - titleBg:getContentSize().height / 2 - 5)
	local title = ui.newTTFLabel({text = CommonText[1842], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setAnchorPoint(cc.p(0, 0.5))
	local valueStr = tostring(self.m_awards.totalGold)
	local value = UiUtil.label( valueStr ,nil,COLOR[6]):rightTo(titleBg,-40)
	value:setAnchorPoint(cc.p(0, 0.5))
	local limit = UiUtil.label("/"..awards.cond):addTo(cell)
	limit:setAnchorPoint(cc.p(0, 0.5))
	
	local finish = UiUtil.label(CommonText[1844][1],nil,COLOR[6]):addTo(cell)
	finish:setAnchorPoint(cc.p(0,0.5))
	if self.m_awards.totalGold >= awards.cond then
		value:setString(awards.cond)
		value:setColor(COLOR[2])

		finish:setString(CommonText[1844][2])
		finish:setColor(COLOR[2])
	end
	limit:setPosition(value:x() + value:width(), value:y())
	finish:setPosition(limit:x() + limit:width(), limit:y())

	local desc = UiUtil.label(CommonText[1843],nil, COLOR[11]):addTo(cell)
	desc:setAnchorPoint(cc.p(0,0.5))
	desc:setPosition(35,titleBg:y() - 40)

	local awardList = PbProtocol.decodeArray(awards["award"])
	for num=1,#awardList do
		local award = awardList[num]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count}):addTo(cell)
		itemView:setPosition(20 + itemView:getContentSize().width / 2 + (num - 1) * 100,self.m_cellSize.height / 2 - 30)
		itemView:setScale(0.8)
		UiUtil.createItemDetailButton(itemView, cell, true)

		local propDB = UserMO.getResourceData(award.type, award.id)
		local name = ui.newTTFLabel({text = propDB.name2 .. " * " .. award.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end

	-- 领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBtnCallback))
	btn:setEnabled(false)
	btn:setLabel(CommonText[777][2])
	if awards.status == 0 and awards.cond <= self.m_awards.totalGold then
		btn:setEnabled(true)
		btn:setLabel(CommonText[777][1])
	elseif awards.status == 1 then
		btn:setEnabled(false)
		btn:setLabel(CommonText[777][3])
	end
	btn.activityCond = awards
	btn.activityId = self.m_activity.activityId
	cell:addButton(btn, self.m_cellSize.width - 100, self.m_cellSize.height / 2)

  	return cell
end

function ActivityPartyPayTableView:onBtnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	ActivityCenterBO.asynReceiveAward(function ()
		self:updateUI()
	end, sender.activityId, sender.activityCond)
end

function ActivityPartyPayTableView:updateUI()
	self.m_awards = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
	if self.m_awards and self.m_awards.activityCond then
		self:reloadData()
	end
end

function ActivityPartyPayTableView:onExit()
	ActivityPartyPayTableView.super.onExit(self)
end

-------------------------------------------------------------------------------------------------------------------
--碎片兑换活动
-------------------------------------------------------------------------------------------------------------------
local ActivityPartyPayView = class("ActivityPartyPayView", UiNode)

function ActivityPartyPayView:ctor(activity)
	ActivityPartyPayView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
	self.m_data = ActivityCenterMO.getActivityContentById(activity.activityId)
end

function ActivityPartyPayView:onEnter()
	ActivityPartyPayView.super.onEnter(self)
	self:setTitle(self.m_activity.name)
	self:showUI()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function ActivityPartyPayView:showUI()
	local activityInfo = ActivityMO.queryActivityInfoById(self.m_activity.activityId)
	local topBg = display.newSprite(IMAGE_COMMON.."party_pay_bg.jpg"):addTo(self:getBg())
	topBg:setPosition(self:getBg():width() / 2, self:getBg():height() - topBg:height())

	--活动时间
	local activityTime = UiUtil.label(CommonText[727][1]..":"):addTo(topBg)
	activityTime:setAnchorPoint(cc.p(0, 0.5))
	activityTime:setPosition(50, topBg:height() - 30)

	-- local begainTime = self.m_activity.beginTime
	-- local endTime = self.m_activity.endTime
	-- local str1 = string.format("%02d/%02d/%02d",
	-- 		os.date("%Y",begainTime),os.date("%m",begainTime),os.date("%d",begainTime))
	-- local str2 = string.format("%02d/%02d/%02d",
	-- 		os.date("%Y",endTime),os.date("%m",endTime),os.date("%d",endTime))
	local time = UiUtil.label("",nil,COLOR[2]):rightTo(activityTime)
	self.m_time = time
	--活动描述
	local desc = UiUtil.label(CommonText[727][2]..":"):alignTo(activityTime, -35, 1)
	local label = UiUtil.label(activityInfo.activityRule,nil,nil,cc.size(425,0),ui.TEXT_ALIGN_LEFT):addTo(topBg)
	label:setAnchorPoint(cc.p(0,0.5))
	label:setPosition(desc:x() + desc:width(), desc:y())

	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.partyPay):push()
		end):addTo(topBg):scale(0.8)
	detailBtn:setPosition(topBg:width() - 90, topBg:height() - 45)
	--进度条
	local max = self.m_data.activityCond[#self.m_data.activityCond].cond
	self.m_max = max
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(520, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(520 + 4, 26)}):addTo(topBg)
	bar:setPosition(topBg:width() / 2, bar:height() * 2 + 6)
	bar:setPercent(self.m_data.totalGold / max)
	self.m_bar = bar
	for index=1,#self.m_data.activityCond do
		local scale = display.newSprite(IMAGE_COMMON.."scale_line.png"):addTo(bar)
		local proportion = self.m_data.activityCond[index].cond / max
		scale:setPosition(proportion * bar:width(), bar:height())

		-- local value = UiUtil.label(UiUtil.strNumSimplify(self.m_data.activityCond[index].cond)):alignTo(scale, 30, 1)
	end

	--奖励展示
	local awardBg = UiUtil.sprite9("info_bg_82.png", 60,50,14,13,self:getBg():width() - 40,self:getBg():height() - topBg:height() - 230):addTo(self:getBg())
	awardBg:setPosition(self:getBg():width() / 2,awardBg:height() / 2 + 120)

	--兑换列表
	local ActivityPartyPayTableView = ActivityPartyPayTableView.new(cc.size(awardBg:width(), awardBg:height() - 40), self.m_activity):addTo(awardBg)
	ActivityPartyPayTableView:setPosition(0,20)
	ActivityPartyPayTableView:reloadData()
	self.m_view = ActivityPartyPayTableView

	--前往充值
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local payBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onRewardHandler)):addTo(self:getBg())
	payBtn:setLabel(CommonText[757][2])
	payBtn:setPosition(self:getBg():getContentSize().width / 2 , 70)
	self.m_payBtn = payBtn
end

function ActivityPartyPayView:onRewardHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.RechargeView").new():push()
end

function ActivityPartyPayView:refreshUI(name)
	if name == "RechargeView" then
		ActivityCenterBO.asynGetActivityContent(function(data)
			self.m_data = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
			self.m_bar:setPercent(self.m_data.totalGold / self.m_max)
			self.m_view:updateUI()
			end,self.m_activity.activityId)
	end
end

function ActivityPartyPayView:update(dt)
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_time:setString(UiUtil.strActivityTime(leftTime))
	else
		self.m_time:setString(CommonText[852])
		self.m_payBtn:setEnabled(false)
	end
end

return ActivityPartyPayView