--
-- Author: xiaoxing
-- Date: 2017-01-11 11:17:51
--
--------------------------------------------------------------------
--排名 tableview
--------------------------------------------------------------------

local HurtTableView = class("HurtTableView", TableView)

function HurtTableView:ctor(size, rankData)
	HurtTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 80)

	self.m_rankData = rankData
	-- self.m_rankData = {{rank = 1, name = "a", hurt = 1000}, {rank = 2, name = "b", hurt = 999}}
end

function HurtTableView:onEnter()
	HurtTableView.super.onEnter(self)
end

function HurtTableView:numberOfCells()
	return #self.m_rankData
end

function HurtTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HurtTableView:createCellAtIndex(cell, index)
	HurtTableView.super.createCellAtIndex(self, cell, index)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(450, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2 + 5, 5)

	local rankData = self.m_rankData[index]

	-- 排行
	local rankView = ArenaBO.createRank(index):addTo(cell)
	rankView:setPosition(85, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = rankData.nick, font = G_FONT, size = FONT_SIZE_SMALL, x = 280 - 40, y = 52, color = ArenaBO.getRankColor(rankData.rank), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))
	-- cell.name = rankData.name

	local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(rankData.rankValue), font = G_FONT, size = FONT_SIZE_SMALL, x = 475, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)

	return cell
end

--------------------------------------------------------------------
-- 世界BOSS
--------------------------------------------------------------------

local ActivityNewYearBoss = class("ActivityNewYearBoss", UiNode)

function ActivityNewYearBoss:ctor(activity)
	ActivityNewYearBoss.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity

	self.m_pageIndex = 1
end

function ActivityNewYearBoss:onEnter()
	ActivityNewYearBoss.super.onEnter(self)
	--春节年兽
	-- armature_add("animation/effect/chuijie_bianpao8.pvr.ccz", "animation/effect/chuijie_bianpao8.plist", "animation/effect/chuijie_bianpao8.xml")
	-- armature_add("animation/effect/chuijie_bianpao9.pvr.ccz", "animation/effect/chuijie_bianpao9.plist", "animation/effect/chuijie_bianpao9.xml")
	--五一搬砖
	armature_add("animation/effect/laodongjie_banzhuan8.pvr.ccz", "animation/effect/laodongjie_banzhuan8.plist", "animation/effect/laodongjie_banzhuan8.xml")
	armature_add("animation/effect/laodongjie_banzhuan9.pvr.ccz", "animation/effect/laodongjie_banzhuan9.plist", "animation/effect/laodongjie_banzhuan9.xml")
	self:hasCoinButton(true)
	self:setTitle(self.m_activity.name)
	self:showUI()
	self.m_bossHandler = Notify.register(LOCAL_BOSS_UPDATE_EVENT, handler(self, self.onBossUpdate))
end

function ActivityNewYearBoss:showUI()
	local function createDelegate(container, index)
		if index == 1 then  -- 挑战
			ActivityCenterBO.getActBoss(1,function()
					self:showChallenge(container)
				end)
		else 				--排行
			self:showRank(container,index)
		end
	end

	local function clickDelegate(container, index)
		-- if index == 1 then
		-- 	self:onTick(0)
		-- end
	end

	--  "挑战", "设置阵型", "伤害排名"
	local pages = {CommonText[34], CommonText[20187][1], CommonText[20187][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_pageIndex)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_tickCount = 0
	self.m_tickHandler = ManagerTimer.addTickListener(handler(self, self.onTick))

	self:onTick(0)
end

function ActivityNewYearBoss:onExit()
	ActivityNewYearBoss.super.onExit(self)
	--春节年兽
	-- armature_remove("animation/effect/chuijie_bianpao8.pvr.ccz", "animation/effect/chuijie_bianpao8.plist", "animation/effect/chuijie_bianpao8.xml")
	-- armature_remove("animation/effect/chuijie_bianpao9.pvr.ccz", "animation/effect/chuijie_bianpao9.plist", "animation/effect/chuijie_bianpao9.xml")
	--五一疯狂搬砖活动
	armature_remove("animation/effect/laodongjie_banzhuan8.pvr.ccz", "animation/effect/laodongjie_banzhuan8.plist", "animation/effect/laodongjie_banzhuan8.xml")
	armature_remove("animation/effect/laodongjie_banzhuan9.pvr.ccz", "animation/effect/laodongjie_banzhuan9.plist", "animation/effect/laodongjie_banzhuan9.xml")

	if self.m_tickHandler then
		ManagerTimer.removeTickListener(self.m_tickHandler)
		self.m_tickHandler = nil
	end

	if self.m_bossHandler then
		Notify.unregister(self.m_bossHandler)
		self.m_bossHandler = nil
	end
end

function ActivityNewYearBoss:onTick(dt)
	self:updataActivityState()
end

function ActivityNewYearBoss:showChallenge(container)
	local info = ActivityCenterBO.yearBoss_
	-- local bg = display.newSprite(IMAGE_COMMON .. "info_bg_77.jpg"):addTo(container) --年兽BOSS
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_78.jpg"):addTo(container) -- 五一疯狂搬砖
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - bg:getContentSize().height / 2 - 8)
	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.mayDayBoss):push()
	end
	--年兽灯笼
	-- local btn = UiUtil.button("lantern.png","lantern.png",nil,gotoDetail):addTo(bg):align(display.CENTER_TOP, bg:getContentSize().width - 53, bg:getContentSize().height - 48)
	-- local t = display.newSprite(IMAGE_COMMON.."tips.png"):addTo(btn):pos(btn:width()/2,60)
	-- t:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(1, 1.5),
	-- 	 cc.ScaleTo:create(1.2, 1)})))
	-- btn:rotation(10)
	-- btn:runAction(cc.RepeatForever:create(transition.sequence({cc.RotateTo:create(1.8, -20),
	-- 	 cc.RotateTo:create(1.8, 20)})))
	--五一疯狂搬砖
	local btn = UiUtil.button("btn_detail_normal.png","btn_detail_selected.png",nil,gotoDetail):addTo(bg):align(display.CENTER_TOP, bg:getContentSize().width - 53, bg:getContentSize().height - 48)

	--boss名称
	UiUtil.label(info.callLordName == "" and CommonText[20052] or info.callLordName..info.bossName,FONT_SIZE_TINY)
		:addTo(bg):pos(bg:width()/2,bg:height() - 15)
	display.newSprite(IMAGE_COMMON.."list_bg.png"):addTo(bg):align(display.LEFT_TOP, 12, bg:height()-42)
	local text = {CommonText[10011][1]..":",CommonText[20186][7],CommonText[20186][1],CommonText[20186][2],CommonText[20186][3]}
	
	for index = 1, 5 do
		local label = ui.newTTFLabel({text = text[index], font = G_FONT, size = FONT_SIZE_TINY, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		label:setAnchorPoint(cc.p(0, 0.5))
		label:setPosition(30, bg:getContentSize().height - 44 - (index - 0.5) * 32)
		if index == 1 then  -- 活动状态
			local value = ui.newTTFLabel({text = CommonText[20188][info.bossState], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
			self.m_stateLabel = value
		elseif index == 2 then
			local value = ui.newTTFLabel({text = "00m:00s", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
			self.m_leftLabel = value
		elseif index == 3 then  -- 我的福袋
			local value = ui.newTTFLabel({text = info.bagNum, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			-- local value = ui.newTTFLabel({text = ActivityCenterMO.yearBoss_.hurt, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
			self.ownLabel = value
		elseif index == 4 then  -- 我的召唤
			local value = ui.newTTFLabel({text = info.callTimes, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
		elseif index == 5 then  -- 召唤波次
			local value = ui.newTTFLabel({text = info.bossCallTimes, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	local icon = 1
	if info.callLordName ~= "" then icon = info.bossIcon end
	-- local boss = display.newSprite(IMAGE_COMMON .. "year_boss" .. icon..".png"):addTo(bg)   --年兽
	local boss = display.newSprite(IMAGE_COMMON .. "mayDay_boss" .. icon..".png"):addTo(bg)   --五一劳动BOSS
	boss:setPosition(bg:getContentSize().width / 2, 180)
	self.m_bossSprite = boss

	display.newSprite(IMAGE_COMMON.."probg.png"):addTo(bg):pos(bg:width()/2,10)
	local bar = CCProgressTimer:create(display.newSprite(IMAGE_COMMON.."pro_orange.png"))
	bar:setType(kCCProgressTimerTypeBar)
	bar:setMidpoint(ccp(0,0))
	bar:setBarChangeRate(ccp(1,0))
	bar:addTo(bg):pos(bg:width()/2,2)
	bar:setPercentage(100)
	self.proNum = UiUtil.label("100%", 16):addTo(bar):center()
	self.m_hpBar = bar

	-- 生命X
	local label = ui.newTTFLabel({text =CommonText[20186][4] .. ":", font = G_FONT, size = 18, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	label:setAnchorPoint(cc.p(1, 0.5))
	label:setPosition(bg:getContentSize().width / 2, -24)

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = 18, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_hpLabel = value

	bg = display.newSprite(IMAGE_COMMON.."balckbg.jpg"):addTo(container)
		:align(display.CENTER_TOP, container:width()/2, bg:y() - bg:height()/2 - 40)
	-- self.data = ActivityCenterMO.getActBossInfo()
	self.bg = bg
	local ids = {8,9}
	local checks = {}
	self.choose = display.newSprite(IMAGE_COMMON.."check1.png"):addTo(bg,10)
	local function setCheck(tag, btn)
		ManagerSound.playNormalButtonSound()
		self.index = tag
		self.choose:pos(btn:x()+25,btn:y()+5)
	end
	for k,v in ipairs(ids) do
		local tx,ty = 110 + (k-1)*320,bg:height()/2
		local t = UiUtil.createItemView(ITEM_KIND_CHAR,v):addTo(bg,0,1000+v):pos(tx,ty)
		t.fame_:hide()
		t.bg_:hide()
		display.newSprite(IMAGE_COMMON.."choose_bg.png"):addTo(t):center()
		UiUtil.createItemDetailButton(t)
		local own = info.props[v] or 0
		UiUtil.label("x"..own,nil,COLOR[own > 0 and 2 or 6]):addTo(bg,0,100+v):align(display.LEFT_CENTER, tx+72, ty-40)
		local btn = UiUtil.button("check0.jpg","check0.jpg",nil,setCheck)
			:rightTo(t, 20)
		btn:setTag(v)
		local c = self.index and self.index - 7 or 1
		if k == c then
			self.index = btn:getTag()
			self.choose:pos(btn:x()+25,btn:y()+5)
		end
	end

	-- 挑战
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onChallengeCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width / 2, 90)
	btn:setLabel(CommonText[20189])
	self.m_challengeButton = btn

	-- 冷却倒计时
	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2, y = 150, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	self.m_cdLabel = value

	self:onTick(0)
end

function ActivityNewYearBoss:onBossUpdate(event)
	if self.m_pageView and self.m_pageView:getPageIndex() == 1 then -- 挑战
		ActivityCenterBO.getActBoss(1,function()
				self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
			end)
	end
end

function ActivityNewYearBoss:onChallengeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local data = ActivityCenterMO.getActBossInfo()
	if UserMO.level_ < data.level then
		Toast.show(string.format(CommonText[20136],data.level))
		return
	end
	if ActivityCenterBO.yearBoss_.bossState == 0 then
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[20191],json.decode(data.callCost)[3]), function()
			ActivityCenterBO.callActBoss(function()
				Toast.show(CommonText[20192])
				ActivityCenterBO.getActBoss(1,function()
						self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
					end)
			end)
		end):push()
		return
	end
	local function gotoBuy()
		if ActivityCenterBO.yearBoss_.attackCd - ManagerTimer.getTime() <= 0 then return end
		ActivityCenterBO.buyActBossCd(function()
				ActivityCenterBO.yearBoss_.attackCd = ManagerTimer.getTime() - 1
				self.m_cdLabel:setString("")
				Toast.show(CommonText[10025]) -- 清除冷却时间成功
			end)
	end
	if ActivityCenterBO.yearBoss_.attackCd and ActivityCenterBO.yearBoss_.attackCd - ManagerTimer.getTime() > 0 then
		if UserMO.consumeConfirm then
			local resData = UserMO.getResourceData(ITEM_KIND_COIN)

			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[10022], math.ceil((ActivityCenterBO.yearBoss_.attackCd - ManagerTimer.getTime())/60)*data.cdClear, resData.name), function() gotoBuy() end):push()
		else
			gotoBuy()
		end
		return
	end

	local own = ActivityCenterBO.yearBoss_.props[self.index] or 0
	local prop = PropMO.queryActPropById(self.index)
	if own == 0 then
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[20190],prop.price,prop.name), function()
			ActivityCenterBO.attackActBoss(self.index - 7,true,function()
				self:showEffect()
			end)
		end):push()
	else
		ActivityCenterBO.attackActBoss(self.index - 7,false,function(useGold)
			self:updateOwn()
			self:showEffect()
		end)
	end
end

function ActivityNewYearBoss:updateOwn()
	-- ActivityCenterBO.yearBoss_.props[self.index] = ActivityCenterBO.yearBoss_.props[self.index] -1
	-- if ActivityCenterBO.yearBoss_.props[self.index] < 0 then
	-- 	ActivityCenterBO.yearBoss_.props[self.index] = 0
	-- end
	local label = self.bg:getChildByTag(self.index + 100)
	local own = ActivityCenterBO.yearBoss_.props[self.index]
	label:setString("x"..own)
	label:setColor(COLOR[own > 0 and 2 or 6])
end

function ActivityNewYearBoss:showEffect()
	self.ownLabel:setString(ActivityCenterBO.yearBoss_.bagNum)
	local tar = self.bg:getChildByTag(1000+self.index)
	-- local effect = armature_create("chuijie_bianpao"..self.index, tar:x(),tar:y(),   --春节年兽
	local effect = armature_create("laodongjie_banzhuan"..self.index, tar:x(),tar:y(),  --五一搬砖
		function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end)
	-- effect:setScaleX(-1)
    effect:getAnimation():playWithIndex(0)
	effect:addTo(self.bg,10)
end

-- 更新显示活动状态标签内容
function ActivityNewYearBoss:updataActivityState()
	if not self.m_pageView or tolua.isnull(self.m_stateLabel) then return end
	if self.m_pageView:getPageIndex() == 1 then -- 挑战
		local info = ActivityCenterBO.yearBoss_
		local status, cdTime = info.bossState,info.attackCd
		self.m_stateLabel:setString(CommonText[20188][status])
		self.m_challengeButton:setLabel(CommonText[953][3])
		self.m_cdLabel:setString("")
		self.m_leftLabel:setString("00m:00s")
		if status == -1 then -- 挑战
			-- gprint("status:", status, "cdTime:", cdTime)
			self.m_cdLabel:setString("")
			self.m_stateLabel:setColor(COLOR[11])
			self.m_hpLabel:setString("X0")
			self.m_hpBar:setPercentage(0)
			self.proNum:setString((string.format("%d", 0)) .. "%")
			self.m_challengeButton:setEnabled(false)
		elseif status == 0 then
			if cdTime - ManagerTimer.getTime() > 0 then
				self.m_cdLabel:setString(CommonText[10021] .. ":" .. UiUtil.strBuildTime(cdTime - ManagerTimer.getTime(), "ms"))
			end
			self.m_stateLabel:setColor(COLOR[2])
			self.m_hpLabel:setString("X0")
			self.m_hpBar:setPercentage(0)
			self.proNum:setString((string.format("%d", 0)) .. "%")
			self.m_challengeButton:setEnabled(true)
		elseif status == 1 then
			if cdTime - ManagerTimer.getTime() > 0 then
				self.m_cdLabel:setString(CommonText[10021] .. ":" .. UiUtil.strBuildTime(cdTime - ManagerTimer.getTime(), "ms"))
			end
			local data = ActivityCenterMO.getActBossInfo()
			self.m_stateLabel:setColor(COLOR[2])
			self.m_hpLabel:setString("X"..info.bossBagNum)
			self.m_hpBar:setPercentage(info.bossBagNum/data.bagNumber*100)
			self.proNum:setString((string.format("%d", info.bossBagNum/data.bagNumber*100)) .. "%")
			self.m_challengeButton:setEnabled(true)
			self.m_challengeButton:setLabel(CommonText[20189])
			local left = info.bossEndTime - ManagerTimer.getTime()
			if left <= 0 then
				left = 0
				ActivityCenterBO.getActBoss(1)
			end
			local time = ManagerTimer.time(left)
			self.m_leftLabel:setString(string.format("%02dm:%02ds", time.minute,time.second))
		end
		self.m_tickCount = self.m_tickCount + 1
		if self.m_tickCount % 5 == 0 then  -- 间隔5秒一次
			if status == 1 then
				ActivityCenterBO.getActBoss(1)
			end
		end
	end
end

function ActivityNewYearBoss:showRank(container,index)
	-- 我的伤害
	local label = ui.newTTFLabel({text = CommonText[20186][index - 1], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = 40, y = container:getContentSize().height - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))
	local t = UiUtil.label(CommonText[764][3],nil,COLOR[11]):alignTo(label, -30, 1)
	local data = ActivityCenterMO.getActBossInfo()
	local str = string.format(CommonText[20193], data.attackRank, CommonText[560][3])
	if index == 3 then
		str = string.format(CommonText[20193], data.callRank, CommonText[237][3])
	end
	UiUtil.label(str,nil,COLOR[11]):rightTo(t)

	local hurtLabel = ui.newTTFLabel({text = 0, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	hurtLabel:setAnchorPoint(cc.p(0, 0.5))

	-- 伤害排名
	local label = ui.newTTFLabel({text = CommonText[893][1], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = label:getPositionX() + 350, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local rankLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	rankLabel:setAnchorPoint(cc.p(0, 0.5))
	rankLabel:setString(CommonText[392]) -- 未上榜

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:getContentSize().width - 20 * 2, container:getContentSize().height - 80 - 90))
	bg:setCapInsets(cc.rect(80, 60, 1, 1))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 80 - bg:getContentSize().height / 2)

	-- 排名
	local label = ui.newTTFLabel({text = CommonText[396][1], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 85, y = bg:getContentSize().height - 25}):addTo(bg)
	-- 角色名
	local label = ui.newTTFLabel({text = CommonText[396][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 280, y = label:getPositionY()}):addTo(bg)
	-- 伤害
	local label = ui.newTTFLabel({text = CommonText[20186][index+3], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 475, y = label:getPositionY()}):addTo(bg)


	local function gotoAward(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.dialog.ActivityFortuneAwardDialog").new(ACTIVITY_ID_NEWYEAR):push()
	end

	local function gotoReceiveAward(tag, sender)
		Loading.getInstance():show()
		ActivityCenterBO.asynGetRankAward(function()
				Loading.getInstance():unshow()
				self.awardGetBtn:setLabel(CommonText[777][3])
				self.awardGetBtn:setEnabled(false)
			end,ACTIVITY_ID_NEWYEAR,sender.rankType)
	end

	local function show(data)
		hurtLabel:setString(data.score)

		local myRank = 100
		local rankType = 0
		local rankList = data.actPlayerRank
		if rankList and #rankList > 0 then
			for index=1,#rankList do
				local player = rankList[index]
				if player.lordId == UserMO.lordId_ then
					myRank = index
					rankType = player.rankType
				end
			end
		end

		if myRank == 100 then rankLabel:setString(CommonText[392]) -- 未上榜
		else rankLabel:setString(myRank) end

		local view = HurtTableView.new(cc.size(bg:getContentSize().width, bg:getContentSize().height - 16 - 50), rankList or {}):addTo(bg)
		view:setPosition(0, 16)
		view:reloadData()
		
		-- 奖励一览
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local btn = MenuButton.new(normal, selected, nil, gotoAward):addTo(container)
		btn:setPosition(120, 35)
		btn:setLabel(CommonText[771])
		ActivityCenterMO.activityContents_[ACTIVITY_ID_NEWYEAR] = {}
		ActivityCenterMO.activityContents_[ACTIVITY_ID_NEWYEAR].rankAward = data.rankAward
		local endRank = 0
		for k,v in ipairs(data.rankAward) do
			if v.rankEd > endRank then
				endRank = v.rankEd
			end
		end
		-- 领取奖励
		local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoReceiveAward):addTo(container)
		btn:setPosition(container:getContentSize().width - 120, 35)
		btn:setLabel(CommonText[255])
		awardButton = btn
		self.awardGetBtn = btn
		self.awardGetBtn.rankType = rankType

		if data.status == 1 then
			awardButton:setLabel(CommonText[672][2])
			awardButton:setEnabled(false)
		elseif data.status == -1 or myRank > endRank or not data.open then
			awardButton:setEnabled(false)
		end
	end

	ActivityCenterBO.getActBossRank(index - 2,show)
end

return ActivityNewYearBoss
