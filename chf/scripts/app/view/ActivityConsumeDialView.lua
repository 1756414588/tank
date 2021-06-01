--
-- Author: gf
-- Date: 2016-01-27 15:40:01
-- 消费转盘


--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local ActivityConsumeDialRankTableView = class("ActivityConsumeDialRankTableView", TableView)

function ActivityConsumeDialRankTableView:ctor(size,activityId)
	ActivityConsumeDialRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 80)
	self.activityId = activityId
end

function ActivityConsumeDialRankTableView:onEnter()
	ActivityConsumeDialRankTableView.super.onEnter(self)
	self.rank = ActivityCenterMO.activityContents_[self.activityId].actFortuneRank.actPlayerRank
end

function ActivityConsumeDialRankTableView:numberOfCells()
	return #self.rank
end

function ActivityConsumeDialRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityConsumeDialRankTableView:createCellAtIndex(cell, index)
	ActivityConsumeDialRankTableView.super.createCellAtIndex(self, cell, index)

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



function ActivityConsumeDialRankTableView:onExit()
	ActivityConsumeDialRankTableView.super.onExit(self)
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

FORTUNE_STATUS_NORMAL = 0 	--未抽
FORTUNE_STATUS_LOTTERY = 1 	--正在抽
FORTUNE_STATUS_RESULT = 2 	--奖励显示
FORTUNE_STATUS_DONE = 3 	--奖励显示完成

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")

local itemPos = {
		{x = 70, y = 545},{x = 190, y = 545},{x = 310, y = 545},{x = 430, y = 545},{x = 550, y = 545},
		{x = 550, y = 435},{x = 550, y = 325},{x = 550, y = 215},{x = 550, y = 105},
		{x = 430, y = 105},{x = 310, y = 105},{x = 190, y = 105},{x = 70, y = 105},
		{x = 70, y = 215},{x = 70, y = 325},{x = 70, y = 435}
	}

local ActivityConsumeDialView = class("ActivityConsumeDialView", UiNode)

function ActivityConsumeDialView:ctor(activity)
	ActivityConsumeDialView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityConsumeDialView:onEnter()
	ActivityConsumeDialView.super.onEnter(self)

	
	self:setTitle(self.m_activity.name)
	
	self:hasCoinButton(true)
	armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")

	local function createDelegate(container, index)
		self.m_timeLab = nil
		Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				if index == 1 then  
					self:showFortune(container)
				elseif index == 2 then 
					self:showFortuneRank(container)
				end
		end, self.m_activity.activityId,index)
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[765][1],CommonText[765][2]}


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
end


function ActivityConsumeDialView:showFortune(container)

	self.lotteryStatus = FORTUNE_STATUS_NORMAL
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, container:getContentSize().height - 30)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.m_timeLab = timeLab

	--背景图
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_Fortune.jpg'):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, timeLab:getPositionY() - 30 - bg:getContentSize().height / 2 - 20)
	self.m_rebateBg = bg

	local actFortune_ = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).actFortune 
	self.actFortune_ = actFortune_

	local scoreLab = ui.newTTFLabel({text = CommonText[764][1], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = timeLab:getPositionY() - 30}):addTo(container)
	scoreLab:setAnchorPoint(cc.p(0, 0.5))

	local scoreValue = ui.newTTFLabel({text = " ", font = G_FONT, color = COLOR[2],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = scoreLab:getPositionX() + scoreLab:getContentSize().width, y = scoreLab:getPositionY()}):addTo(container)
	scoreValue:setAnchorPoint(cc.p(0, 0.5))
	scoreValue:setString(actFortune_.score)
	self.scoreValue_ = scoreValue

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			local content = DetailText.activityConsumeDial
			DetailTextDialog.new(content):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 70, container:getContentSize().height - 50)

	self:showLotteryUI()

	--拥有次数
	local countLab = ui.newTTFLabel({text = CommonText[861][1], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = timeLab:getPositionY() - 630}):addTo(container)
	countLab:setAnchorPoint(cc.p(0, 0.5))

	local countValue = ui.newTTFLabel({text = " ", font = G_FONT, color = COLOR[2],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = countLab:getPositionX() + countLab:getContentSize().width, y = countLab:getPositionY()}):addTo(container)
	countValue:setAnchorPoint(cc.p(0, 0.5))
	countValue:setString(actFortune_.count)
	self.countValue_ = countValue

	local countInfo = ui.newTTFLabel({text = CommonText[861][2], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = countValue:getPositionX() + countValue:getContentSize().width + 10, y = countLab:getPositionY()}):addTo(container)
	countInfo:setAnchorPoint(cc.p(0, 0.5))


	--按钮
	--探索按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local lottery1Btn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(container)
	lottery1Btn:setPosition(container:getContentSize().width / 2 - 150, 30)
	if actFortune_.free > 0 then
		lottery1Btn:setLabel(CommonText[862][1])
	else
		lottery1Btn:setLabel(CommonText[862][2])
	end
	lottery1Btn.fortune = actFortune_.fortune[1]
	lottery1Btn.type = 1
	self.lottery1Btn = lottery1Btn

	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local lottery10Btn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(container)
	lottery10Btn:setPosition(container:getContentSize().width / 2 + 150, 30)
	lottery10Btn:setLabel(CommonText[862][3])
	lottery10Btn.fortune = actFortune_.fortune[2]
	lottery10Btn.type = 10
	
end

function ActivityConsumeDialView:showLotteryUI()
	local bg = self.m_rebateBg	
	local displayAwards = json.decode(ActivityCenterMO.getFortuneById(self.m_activity.activityId).displayList)
	gdump(displayAwards,"displayAwards")
	for index=1,#displayAwards do
		local award = displayAwards[index]
		local itemView = UiUtil.createItemView(award[1], award[2], {count = award[3]})
		itemView:setPosition(itemPos[index].x, itemPos[index].y)
		bg:addChild(itemView)
		UiUtil.createItemDetailButton(itemView)
	end

	local boxEffect = CCArmature:create("ui_item_light_orange")
    boxEffect:getAnimation():playWithIndex(0)
    boxEffect:connectMovementEventSignal(function(movementType, movementID) end)
    boxEffect:setScale(0.85)
    boxEffect:setPosition(itemPos[1].x, itemPos[1].y)
    boxEffect:setVisible(false)
    self.boxEffect = boxEffect
    bg:addChild(boxEffect)
end

function ActivityConsumeDialView:showFortuneRank(container)
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
	if myRank == CommonText[768] then
		rankValue:setColor(COLOR[6])
	else
		rankValue:setColor(COLOR[2])
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


	local view = ActivityConsumeDialRankTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.m_activity.activityId):addTo(tableBg)
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
	
	if actFortuneRank_.open == true and myRankData then
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

function ActivityConsumeDialView:awardInfoHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityFortuneAwardDialog").new(self.m_activity.activityId):push()
end

function ActivityConsumeDialView:awardGetHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	Loading.getInstance():show()
	ActivityCenterBO.asynGetRankAward(function()
			Loading.getInstance():unshow()
			self.awardGetBtn:setLabel(CommonText[777][3])
			self.awardGetBtn:setEnabled(false)
		end,self.m_activity.activityId,sender.rankType,sender.actFortuneRank)
end

function ActivityConsumeDialView:lotteryHandler(tag, sender)
	-- if self.lotteryStatus ~= FORTUNE_STATUS_NORMAL then return end
	ManagerSound.playNormalButtonSound()
	local cost
	--单抽且有免费次数
	if sender.type == 1 and self.actFortune_.free > 0 then
		cost = 0
	else
		cost = sender.type
	end
	gdump(cost,"lotteryHandler .. cost")
	function doLottery()
		if cost > self.actFortune_.count then
			Toast.show(CommonText[863])
			return
		end
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActConsumeDial(function(score,awards,type)
			Loading.getInstance():unshow()
			local actFortune_ = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).actFortune 
			--单抽
			if type == 1 then
				if actFortune_.free > 0 then
					self.lottery1Btn:setLabel(CommonText[862][1])
				else
					self.lottery1Btn:setLabel(CommonText[862][2])
				end
			end
			self.countValue_:setString(actFortune_.count)
			self.scoreValue_:setString(score)
			self:showLotteryEffect(awards)
			end, self.m_activity.activityId,sender.fortune,sender.type)
	end
	doLottery()
end

function ActivityConsumeDialView:showLotteryEffect(awards)
	if not awards or #awards == 0 then return end
	if self.bgMask then self:removeChild(self.bgMask, true) end
	--黑色遮罩
	local rect = CCRectMake(0, 0, GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT)
	local bgMask = CCSprite:create("image/common/bg_ui.jpg", rect)
	bgMask:setCascadeBoundingBox(rect)
	bgMask:setColor(ccc3(0, 0, 0))
	bgMask:setOpacity(0)
	bgMask:setPosition(GAME_SIZE_WIDTH / 2, GAME_SIZE_HEIGHT / 2)
	self:addChild(bgMask,99)
	self.bgMask = bgMask

	nodeTouchEventProtocol(bgMask, function(event)  
					if self.lotteryStatus == FORTUNE_STATUS_LOTTERY then
						self:showAllResult()
					elseif self.lotteryStatus == FORTUNE_STATUS_DONE then
						self:removeChild(self.bgMask, true)
						self.lotteryStatus = FORTUNE_STATUS_NORMAL
						if self.awards and #self.awards > 0 then
							 --加入背包
							local ret = CombatBO.addAwards(self.awards)
							UiUtil.showAwards(ret, true)
						end
					end               
                end, nil, true, true)

	self.lotteryStatus = FORTUNE_STATUS_LOTTERY
	self.resultNode = display.newNode():addTo(self.m_rebateBg)

	self.awards = awards
	local effectTime,randomNum
	randomNum = {}
	if #awards == 1 then
		effectTime = 0.05
	else
		effectTime = 0.01
	end
	for index=1,#awards do
		-- gprint("seed",tostring(socket.gettime() * 10000 + index * 10000):reverse():sub(1, 10))
		math.randomseed(tostring(socket.gettime() * 10000 + index * 12345):reverse():sub(5, 10))
		randomNum[#randomNum + 1] =  math.random(2,#itemPos)
	end
	
	local rcount = #awards
	if rcount > 0 then
		self.boxEffect:setVisible(true)
		local i = 1
		local j = 2
		local randomIdx = randomNum[i]

		if not self.effectScheduler_ then
			self.effectScheduler_ = scheduler.scheduleGlobal(function()
				if self.lotteryStatus == FORTUNE_STATUS_LOTTERY then
					if j < #itemPos + 1 then
						-- gprint(j)
						self.boxEffect:setPosition(itemPos[j].x,itemPos[j].y - 4)
						--奖励移动
						if randomIdx == j then
							self:showResult(i,j)
						end
						j = j + 1
					else
						self.boxEffect:setPosition(itemPos[1].x,itemPos[1].y - 4)
						i = i + 1
						if (i - 1) < rcount then
							j = 2
							randomIdx = randomNum[i]
							-- gprint(randomIdx,"randomIdx")
						else
							-- self.boxEffect:setVisible(false)
							scheduler.unscheduleGlobal(self.effectScheduler_)
							self.effectScheduler_ = nil
							self:showAllResult()
						end
					end
				else
					self.boxEffect:setPosition(itemPos[1].x,itemPos[1].y - 4)
					scheduler.unscheduleGlobal(self.effectScheduler_)
					self.effectScheduler_ = nil
				end
				
			end, effectTime)
		end
	end
end


function ActivityConsumeDialView:showResult(awardIdx,posIdx)
	
	local award = self.awards[awardIdx]
	local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
	itemView:setPosition(itemPos[posIdx].x, itemPos[posIdx].y)
	self.resultNode:addChild(itemView)
	--移动
	itemView:runAction(transition.sequence({cc.MoveTo:create(0.2, cc.p(self.m_rebateBg:getContentSize().width / 2, self.m_rebateBg:getContentSize().height / 2)),
			cc.CallFunc:create(function()				
			end)}))
end

function ActivityConsumeDialView:showAllResult()
	self.lotteryStatus = FORTUNE_STATUS_RESULT
	self.boxEffect:setVisible(false)
	self.bgMask:setOpacity(200)
	if self.resultNode then
		self.m_rebateBg:removeChild(self.resultNode, true)
		self.resultNode = nil
	end

	local poss = {}
	if #self.awards == 1 then
		poss = {
			{x=display.cx, y=display.cy}
		}
	else
		poss = {
			{x=display.cx - 180, y=display.cy + 110},
			{x=display.cx - 60, y=display.cy + 110},
			{x=display.cx + 60, y=display.cy + 110},
			{x=display.cx + 180, y=display.cy + 110},
			{x=display.cx - 180, y=display.cy - 10},
			{x=display.cx - 60, y=display.cy - 10},
			{x=display.cx + 60, y=display.cy - 10},
			{x=display.cx + 180, y=display.cy - 10},
			{x=display.cx - 60, y=display.cy - 130},
			{x=display.cx + 60, y=display.cy - 130}
		}
	end
	for index=1,#self.awards do
		local award = self.awards[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setPosition(self.bgMask:getContentSize().width / 2, self.bgMask:getContentSize().height / 2)
		self.bgMask:addChild(itemView)
		UiUtil.createItemDetailButton(itemView)

		--播放展开动画
		itemView:runAction(transition.sequence({cc.MoveTo:create(0.2, cc.p(poss[index].x, poss[index].y)),
			cc.CallFunc:create(function()	
				if index == #self.awards then
					self.lotteryStatus = FORTUNE_STATUS_DONE
				end			
			end)}))
	end
end

function ActivityConsumeDialView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

function ActivityConsumeDialView:onExit()
	ActivityConsumeDialView.super.onExit(self)
	armature_remove("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
	if self.effectScheduler_ then
		scheduler.unscheduleGlobal(self.effectScheduler_)
		self.effectScheduler_ = nil
	end
end





return ActivityConsumeDialView
