--
-- Author: gf
-- Date: 2016-04-08 11:56:00
-- 火力全开

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local ActivityPartyDonateTableView = class("ActivityPartyDonateTableView", TableView)

function ActivityPartyDonateTableView:ctor(size)
	ActivityPartyDonateTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 80)

end

function ActivityPartyDonateTableView:onEnter()
	ActivityPartyDonateTableView.super.onEnter(self)
	self.rank = ActivityMO.getActivityContentById(ACTIVITY_ID_PARTY_DONATE).actPartyRank
end

function ActivityPartyDonateTableView:numberOfCells()
	return #self.rank
end

function ActivityPartyDonateTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityPartyDonateTableView:createCellAtIndex(cell, index)
	ActivityPartyDonateTableView.super.createCellAtIndex(self, cell, index)

	local data = self.rank[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(550, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	
	local rankTitle = ArenaBO.createRank(index)
	rankTitle:setPosition(55, 40)
	bg:addChild(rankTitle)

	local name = ui.newTTFLabel({text = data.partyName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 145, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	name:setAnchorPoint(cc.p(0,0.5))
	
	if index == 1 then
		name:setColor(COLOR[6])
	elseif index == 2 then
		name:setColor(COLOR[12])
	elseif index == 3 then
		name:setColor(COLOR[4])
	else
		name:setColor(COLOR[11])
	end

	local fightValue = ui.newTTFLabel({text = UiUtil.strNumSimplify(data.fight), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 320, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	fightValue:setAnchorPoint(cc.p(0,0.5))

	local scoreValue = ui.newTTFLabel({text = data.rankValue, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 460, y = 40, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	scoreValue:setAnchorPoint(cc.p(0,0.5))
	return cell
end



function ActivityPartyDonateTableView:onExit()
	ActivityPartyDonateTableView.super.onExit(self)
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------




local ActivityPartyDonateView = class("ActivityPartyDonateView", UiNode)

function ActivityPartyDonateView:ctor(activity)
	ActivityPartyDonateView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityPartyDonateView:onEnter()
	ActivityPartyDonateView.super.onEnter(self)

	self:setTitle(CommonText[802][2])


	local infoBg = display.newSprite(IMAGE_COMMON .. "bar_gamble.jpg"):addTo(self:getBg())
	infoBg:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - infoBg:getContentSize().height)

	local infoLab = ui.newTTFLabel({text = CommonText[439][ACTIVITY_ID_PARTY_DONATE], font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = 30, dimensions = cc.size(450, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(infoBg)

	local time = ui.newTTFLabel({text = CommonText[393] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = 20, align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		time:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- local label = ui.newTTFLabel({text = os.date("%Y/%m/%d", activity.beginTime) .. " - " .. os.date("%Y/%m/%d(%H:%M)", activity.endTime), font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
	label:setAnchorPoint(cc.p(0, 0.5))
	label.activity = self.m_activity
	self.timerLabel_ = label


	self.m_tickTimer = ManagerTimer.addTickListener(handler(self, self.onTick))

	self:onTick(0)

	self:showRank()
end

function ActivityPartyDonateView:showRank()
	local activityContent = ActivityMO.getActivityContentById(self.m_activity.activityId)
	--当前排名
	local rankTit = ui.newTTFLabel({text = CommonText[893][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 70, y = self:getBg():getContentSize().height - 330, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	rankTit:setAnchorPoint(cc.p(0,0.5))
	local rankValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = rankTit:getPositionX() + rankTit:getContentSize().width, y = rankTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	rankValue:setAnchorPoint(cc.p(0,0.5))

	gdump(activityContent.party,"activityContent.party")
	local myPartyRank = ActivityBO.getMyPartyDonateRank()
	if myPartyRank > 0 then
		rankValue:setString(myPartyRank)
	else
		rankValue:setString(CommonText[392])
	end

	--战斗力
	local fightTit = ui.newTTFLabel({text = CommonText[893][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 270, y = self:getBg():getContentSize().height - 330, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	fightTit:setAnchorPoint(cc.p(0,0.5))
	local fightValue = ui.newTTFLabel({text = UiUtil.strNumSimplify(activityContent.party.fight), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = fightTit:getPositionX() + fightTit:getContentSize().width, y = fightTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	fightValue:setAnchorPoint(cc.p(0,0.5))
	--总贡献
	local donateTit = ui.newTTFLabel({text = CommonText[893][3], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 470, y = self:getBg():getContentSize().height - 330, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	donateTit:setAnchorPoint(cc.p(0,0.5))
	local donateValue = ui.newTTFLabel({text = UiUtil.strNumSimplify(activityContent.party.rankValue), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = donateTit:getPositionX() + donateTit:getContentSize().width, y = donateTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	donateValue:setAnchorPoint(cc.p(0,0.5))


	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(self:getBg())
	tableBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 30, self:getBg():getContentSize().height - 440))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setAnchorPoint(cc.p(0.5,1))
	tableBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 350)

	local posX = {65,170,350,490}
	for index=1,#CommonText[894] do
		local title = ui.newTTFLabel({text = CommonText[894][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		title:setAnchorPoint(cc.p(0, 0.5))
	end


	local view = ActivityPartyDonateTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70)):addTo(tableBg)
	view:setPosition(0, 25)
	view:reloadData()

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local awardInfoBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardInfoHandler)):addTo(self:getBg())
	awardInfoBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 50)
	awardInfoBtn:setLabel(CommonText[769][1])

	--领取奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local awardGetBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardGetHandler)):addTo(self:getBg())
	awardGetBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 50)
	self.awardGetBtn = awardGetBtn

	gdump(activityContent.party,"activityContent.party")
	if activityContent.open == true and ActivityBO.getMyPartyDonateRank() > 0 then
		if activityContent.status == 0 then
			awardGetBtn:setLabel(CommonText[777][1])
			awardGetBtn:setEnabled(true)
		else
			awardGetBtn:setLabel(CommonText[777][3])
			awardGetBtn:setEnabled(false)
		end
	else
		awardGetBtn:setLabel(CommonText[777][2])
		awardGetBtn:setEnabled(false)
	end
end

function ActivityPartyDonateView:awardInfoHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityFortuneAwardDialog").new(self.m_activity.activityId):push()
end

function ActivityPartyDonateView:awardGetHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	Loading.getInstance():show()
	ActivityBO.asynGetPartyRankAward(function()
			Loading.getInstance():unshow()
			self.awardGetBtn:setLabel(CommonText[777][3])
			self.awardGetBtn:setEnabled(false)
		end,self.m_activity.activityId)
end

function ActivityPartyDonateView:onTick(dt)
	if self.timerLabel_ and self.timerLabel_.activity then
		local activity = self.timerLabel_.activity
		local leftTime = activity.endTime - ManagerTimer.getTime()
		if leftTime <= 0 then leftTime = 0 end

		self.timerLabel_:setString(UiUtil.strActivityTime(leftTime))
	end
end


function ActivityPartyDonateView:onExit()
	ActivityPartyDonateView.super.onExit(self)
	if self.m_tickTimer then
		ManagerTimer.removeTickListener(self.m_tickTimer)
		self.m_tickTimer = nil
	end	
end





return ActivityPartyDonateView
