--
-- Author: gf
-- Date: 2015-12-02 10:22:52
-- 名将招募

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local ActivityGeneralTableView = class("ActivityGeneralTableView", TableView)

function ActivityGeneralTableView:ctor(size,activityId)
	ActivityGeneralTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 80)
	self.activityId = activityId
end

function ActivityGeneralTableView:onEnter()
	ActivityGeneralTableView.super.onEnter(self)
	self.rank = ActivityCenterMO.activityContents_[self.activityId].actFortuneRank.actPlayerRank
end

function ActivityGeneralTableView:numberOfCells()
	return #self.rank
end

function ActivityGeneralTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityGeneralTableView:createCellAtIndex(cell, index)
	ActivityGeneralTableView.super.createCellAtIndex(self, cell, index)

	local data = self.rank[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(550, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	
	local rankTitle = ArenaBO.createRank(index)
	rankTitle:setPosition(45, 40)
	bg:addChild(rankTitle)

	local name = ui.newTTFLabel({text = data.nick, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 192, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	if index == 1 then
		name:setColor(COLOR[6])
	elseif index == 2 then
		name:setColor(COLOR[12])
	elseif index == 3 then
		name:setColor(COLOR[4])
	else
		name:setColor(COLOR[11])
	end

	local scoreValue = ui.newTTFLabel({text = data.rankValue, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 470, y = 40, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	return cell
end



function ActivityGeneralTableView:onExit()
	ActivityGeneralTableView.super.onExit(self)
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")


local ActivityGeneralView = class("ActivityGeneralView", UiNode)

function ActivityGeneralView:ctor(activity)
	ActivityGeneralView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityGeneralView:onEnter()
	ActivityGeneralView.super.onEnter(self)


	self:setTitle(self.m_activity.name)
	
	self:hasCoinButton(true)

	local function createDelegate(container, index)
		self.m_timeLab = nil
		Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				if index == 1 then  
					self:showGeneral(container)
				elseif index == 2 then 
					self:showGeneralRank(container)
				end
		end, self.m_activity.activityId,index)
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[843][1],CommonText[843][2]}


	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.m_updateHandler = Notify.register(LOCAL_ACT_GENERAL_UPDATE_EVENT, handler(self, self.updateLuckyBar))
end


function ActivityGeneralView:showGeneral(container)
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'bar_general.jpg'):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 110)

	local title = ui.newTTFLabel({text = CommonText[727][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 37, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	title:setAnchorPoint(cc.p(0,0.5))

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER,
   	color = COLOR[2]}):addTo(bg)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(title:getPositionX() + title:getContentSize().width, title:getPositionY())
	self.m_timeLab = timeLab

	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data
	local generals = activityContent.general
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(self.m_activity.activityId == ACTIVITY_ID_GENERAL1 and DetailText.activityGeneral1 or DetailText.activityGeneral):push()
		end):addTo(bg)
	detailBtn:setPosition(container:getContentSize().width - 70, title:getPositionY())

	if self.m_activity.activityId == ACTIVITY_ID_GENERAL1 then
		UiUtil.button("btn_replay_normal.png","btn_replay_selected.png",nil,function()
			BattleMO.setTest()
		end):leftTo(detailBtn)
	end

	--背景图
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_29.jpg'):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 470)
	self.m_rebateBg = bg


	--左边将领
	local herobgL = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(bg)
	herobgL:setPreferredSize(cc.size(230, 315))
	herobgL:setCapInsets(cc.rect(80, 60, 1, 1))
	herobgL:setPosition(bg:getContentSize().width / 2 - 160, bg:getContentSize().height / 2 + 50)

	local heroName = ui.newTTFLabel({text = UserMO.getResourceData(ITEM_KIND_HERO, generals[1].heroId).name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = herobgL:getContentSize().width / 2, y = herobgL:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(herobgL)
	heroName:setAnchorPoint(cc.p(0.5, 0.5))
	local itemView = UiUtil.createItemView(ITEM_KIND_HERO, generals[1].heroId)
	itemView:setPosition(herobgL:getContentSize().width / 2,herobgL:getContentSize().height / 2 - 20)
	herobgL:addChild(itemView)

	nodeTouchEventProtocol(itemView, function(event) 
		if event.name == "ended" then
			local heroDB = HeroMO.queryHero(generals[1].heroId)
            require("app.dialog.HeroDetailDialog").new(heroDB,2):push()
		else
			return true
        end
	       
		end, nil, nil, true)


	--右边将领
	local herobgR = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(bg)
	herobgR:setPreferredSize(cc.size(230, 315))
	herobgR:setCapInsets(cc.rect(80, 60, 1, 1))
	herobgR:setPosition(bg:getContentSize().width / 2 + 160, bg:getContentSize().height / 2 + 50)

	local heroName = ui.newTTFLabel({text = CommonText[845], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = herobgR:getContentSize().width / 2, y = herobgR:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(herobgR)
	heroName:setAnchorPoint(cc.p(0.5, 0.5))

	local heroBg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png",herobgR:getContentSize().width / 2,herobgR:getContentSize().height / 2 - 20):addTo(herobgR)
	local heroView = display.newSprite(IMAGE_COMMON .. "info_bg_31.png", heroBg:getContentSize().width / 2, heroBg:getContentSize().height / 2):addTo(heroBg)
	local starBg = display.newSprite(IMAGE_COMMON .. "hero_star_bg.png", heroBg:getContentSize().width / 2, heroBg:getContentSize().height):addTo(heroBg)
	

	--幸运值
	local luckyTit = ui.newTTFLabel({text = CommonText[880][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width / 2, y = 110, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	luckyTit:setAnchorPoint(cc.p(0.5, 0.5))

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(520, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(520 + 4, 26)}):addTo(bg)
	bar:setPosition(bg:getContentSize().width / 2, 70)
	self.luckyBar = bar

	local maxBar = ProgressBar.new(IMAGE_COMMON .. "bar_5.png", BAR_DIRECTION_HORIZONTAL, cc.size(520, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(520 + 4, 26)}):addTo(bg)
	maxBar:setPosition(bg:getContentSize().width / 2, 70)
	maxBar:setPercent(1)
	self.maxBar = maxBar


	local luckyDesc = ui.newTTFLabel({text = string.format(CommonText[880][2],UserMO.getResourceData(ITEM_KIND_HERO, generals[1].heroId).name), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width / 2, y = 30, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	luckyDesc:setAnchorPoint(cc.p(0.5, 0.5))

	self:updateLuckyBar()


	--按钮
	--探索按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local lottery1Btn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(container)
	lottery1Btn:setPosition(container:getContentSize().width / 2 - 150, 30)
	lottery1Btn:setLabel(string.format(CommonText[844],generals[1].count),{size = FONT_SIZE_SMALL - 2, y = lottery1Btn:getContentSize().height / 2 + 13})
	lottery1Btn.general = generals[1]
	lottery1Btn.type = 1

	local icon1 = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lottery1Btn:getContentSize().width / 2 - 30,lottery1Btn:getContentSize().height / 2 - 13):addTo(lottery1Btn)
	local need1 = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt"}):addTo(lottery1Btn)
	need1:setAnchorPoint(cc.p(0, 0.5))
	need1:setPosition(icon1:getPositionX() + icon1:getContentSize().width / 2 + 5,icon1:getPositionY() + 2)
	need1:setString(generals[1].price)
	self.lottery1Btn = lottery1Btn

	

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local lottery10Btn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(container)
	lottery10Btn:setPosition(container:getContentSize().width / 2 + 150, 30)
	lottery10Btn:setLabel(string.format(CommonText[844],generals[2].count),{size = FONT_SIZE_SMALL - 2, y = lottery1Btn:getContentSize().height / 2 + 13})
	lottery10Btn.general = generals[2]
	lottery10Btn.type = 10
	local icon10 = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lottery10Btn:getContentSize().width / 2 - 30,lottery10Btn:getContentSize().height / 2 - 13):addTo(lottery10Btn)
	local need10 = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt"}):addTo(lottery10Btn)
	need10:setAnchorPoint(cc.p(0, 0.5))
	need10:setPosition(icon1:getPositionX() + icon1:getContentSize().width / 2 + 5,icon1:getPositionY() + 2)
	need10:setString(generals[2].price)

	self.lottery10Btn = lottery10Btn
	
end

function ActivityGeneralView:lotteryHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local cost = sender.general.price
	
	function doLottery()
		if cost > UserMO.getResource(ITEM_KIND_COIN) then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActGeneral(function(heros)
				Loading.getInstance():unshow()
				function closeCb()
					self.lottery1Btn:setVisible(true)
					self.lottery10Btn:setVisible(true)
				end
				require("app.dialog.ActGeneralResultDialog").new(sender.general,heros,closeCb,self.m_activity.activityId):push()
				self.lottery1Btn:setVisible(false)
				self.lottery10Btn:setVisible(false)
			end, sender.general, self.m_activity.activityId)
	end
	if UserMO.consumeConfirm and cost > 0 then
		CoinConfirmDialog.new(string.format(CommonText[721],cost), function()
				doLottery()
			end):push()
	else
		doLottery()
	end
end

function ActivityGeneralView:updateLuckyBar()
	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data
	local percent = activityContent.count / (activityContent.luck - 1)

	self.luckyBar:setPercent(percent)
	self.luckyBar:setVisible(percent < 1)
	self.maxBar:setVisible(percent == 1)
end

function ActivityGeneralView:showGeneralRank(container)
	local actFortuneRank_ = ActivityCenterMO.activityContents_[self.m_activity.activityId].actFortuneRank

	--我的积分
	local scoreLab = ui.newTTFLabel({text = CommonText[764][1], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = container:getContentSize().height - 30}):addTo(container)
	scoreLab:setAnchorPoint(cc.p(0, 0.5))

	local scoreValue = ui.newTTFLabel({text = " ", font = G_FONT, color = COLOR[2],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = scoreLab:getPositionX() + scoreLab:getContentSize().width, y = scoreLab:getPositionY()}):addTo(container)
	scoreValue:setAnchorPoint(cc.p(0, 0.5))
	scoreValue:setString(actFortuneRank_.score)
	self.scoreValue_ = scoreValue

	--当前排名
	local rankLab = ui.newTTFLabel({text = CommonText[764][2], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 350, y = container:getContentSize().height - 30}):addTo(container)
	rankLab:setAnchorPoint(cc.p(0, 0.5))

	local rankValue = ui.newTTFLabel({text = " ", font = G_FONT, color = COLOR[6],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = rankLab:getPositionX() + rankLab:getContentSize().width, y = scoreLab:getPositionY()}):addTo(container)
	rankValue:setAnchorPoint(cc.p(0, 0.5))
	local myRank = ActivityCenterBO.getMyFortuneRank(self.m_activity.activityId)
	rankValue:setString(myRank)
	local rank = nil
	if myRank == CommonText[768] then
		rankValue:setColor(COLOR[6])
	else
		rankValue:setColor(COLOR[2])
		rank = myRank
	end

	--活动结束时结算排名
	local infoLab = ui.newTTFLabel({text = CommonText[764][3], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = container:getContentSize().height - 60}):addTo(container)
	infoLab:setAnchorPoint(cc.p(0, 0.5))

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	tableBg:setPreferredSize(cc.size(container:getContentSize().width, container:getContentSize().height - 160))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - (container:getContentSize().height - 160) / 2 - 80)

	local posX = {65,200,490}
	for index=1,#CommonText[770] do
		local title = ui.newTTFLabel({text = CommonText[770][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		title:setAnchorPoint(cc.p(0, 0.5))
	end


	local view = ActivityGeneralTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.m_activity.activityId):addTo(tableBg)
	view:setPosition(0, 25)
	view:reloadData()

	--按钮
	--查看奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local awardInfoBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardInfoHandler)):addTo(container)
	awardInfoBtn:setPosition(container:getContentSize().width / 2 - 150, 30)
	awardInfoBtn:setLabel(CommonText[769][1])

	--领取奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local awardGetBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardGetHandler)):addTo(container)
	awardGetBtn:setPosition(container:getContentSize().width / 2 + 150, 30)
	self.awardGetBtn = awardGetBtn

	--我的排名数据
	local myRankData = ActivityCenterBO.getMyFortuneRankData(self.m_activity.activityId)
	if actFortuneRank_.open == true and myRankData and rank <= 10 then
		if actFortuneRank_.status == 0 then
			awardGetBtn:setLabel(CommonText[777][1])
			awardGetBtn:setEnabled(true)
			awardGetBtn.rankType = myRankData.rankType
			awardGetBtn.actFortuneRank = actFortuneRank_
		else
			awardGetBtn:setLabel(CommonText[777][3])
			awardGetBtn:setEnabled(false)
		end
	else
		awardGetBtn:setLabel(CommonText[777][2])
		awardGetBtn:setEnabled(false)
	end
end

function ActivityGeneralView:awardInfoHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityFortuneAwardDialog").new(self.m_activity.activityId):push()
end

function ActivityGeneralView:awardGetHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	
	Loading.getInstance():show()
	ActivityCenterBO.asynGetRankAward(function()
			Loading.getInstance():unshow()
			self.awardGetBtn:setLabel(CommonText[777][3])
			self.awardGetBtn:setEnabled(false)
		end,self.m_activity.activityId,sender.rankType,sender.actFortuneRank)
end



function ActivityGeneralView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

function ActivityGeneralView:refreshUI()
	local time = CCDirector:sharedDirector():getScheduler():getTimeScale()
	if time ~= 1 then
		CCDirector:sharedDirector():getScheduler():setTimeScale(1)
	end
end

function ActivityGeneralView:onExit()
	ActivityGeneralView.super.onExit(self)

	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
	
end

return ActivityGeneralView
