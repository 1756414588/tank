--
-- MYS
-- ActivityLuckyRoundView
-- 幸运奖池
--
--
local Dialog = require("app.dialog.Dialog")
---------------------------------------------------------------------
--								
---------------------------------------------------------------------

local ActivityLuckyRoundRecordTableView = class("ActivityLuckyRoundRecordTableView", TableView)

function ActivityLuckyRoundRecordTableView:ctor(size, data)
	ActivityLuckyRoundRecordTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 47)
	self.m_data = data
end

function ActivityLuckyRoundRecordTableView:numberOfCells()
	return #self.m_data
end

function ActivityLuckyRoundRecordTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityLuckyRoundRecordTableView:createCellAtIndex(cell, index)
	ActivityLuckyRoundRecordTableView.super.createCellAtIndex(self, cell, index)
	local _data = self.m_data[index]

	local timeStr = os.date("%m-%d\n%H:%M:%S", math.floor(_data.time))
	local timelb = ui.newTTFLabel({text = timeStr, font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(200, 200, 200)}):addTo(cell)
	timelb:setPosition(80, self.m_cellSize.height * 0.5)

	local namelb = ui.newTTFLabel({text = _data.name, font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(200, 200, 200)}):addTo(cell)
	namelb:setPosition(230, self.m_cellSize.height * 0.5)

	local coinStrs = string.split(_data.goodInfo,"-")
	local coinStr = string.format(CommonText[1858],coinStrs[1],coinStrs[2])
	local coinb = ui.newTTFLabel({text = coinStr, font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(200, 200, 200)}):addTo(cell)
	coinb:setPosition(385, self.m_cellSize.height * 0.5)

	local line = display.newSprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(cell)
	line:setScaleX(3)
	line:setPosition(self.m_cellSize.width * 0.5, 0)

	return cell
end


local ActivityLuckyRoundRecordDialog = class("ActivityLuckyRoundRecordDialog",Dialog)
function ActivityLuckyRoundRecordDialog:ctor(data)
	ActivityLuckyRoundRecordDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(570, 850)})
	self.m_data = data
end

function ActivityLuckyRoundRecordDialog:onEnter()
	ActivityLuckyRoundRecordDialog.super.onEnter(self)
	self:setTitle(CommonText[1856])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, self:getBg():width()-60, self:getBg():height()-115):addTo(self:getBg(), 1)
	bg:setPosition(self:getBg():width() * 0.5, self:getBg():height() * 0.5 - 15)

	local timelb = ui.newTTFLabel({text = CommonText[619][1], font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(200, 200, 200)}):addTo(bg,3)
	timelb:setPosition(100, bg:height() - 25)

	local namelb = ui.newTTFLabel({text = CommonText[98], font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(200, 200, 200)}):addTo(bg,3)
	namelb:setPosition(245, bg:height() - 25)

	local coinb = ui.newTTFLabel({text = CommonText[1855], font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(200, 200, 200)}):addTo(bg,3)
	coinb:setPosition(400, bg:height() - 25)

	local size = cc.size(bg:width() - 40, bg:height() - 88)
	local view = ActivityLuckyRoundRecordTableView.new(size, self.m_data):addTo(bg, 3)
	view:setPosition(20, 38)
	view:reloadData()

	local titlelb = ui.newTTFLabel({text = CommonText[1857], font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(200, 200, 200)}):addTo(bg,3)
	titlelb:setPosition(bg:width() * 0.5, 22)
end

function ActivityLuckyRoundRecordDialog:onExit()
	ActivityLuckyRoundRecordDialog.super.onExit(self)
end









----------------------------------------------------------------------
--								
----------------------------------------------------------------------

local ActivityLuckyRoundAwardDialog = class("ActivityLuckyRoundAwardDialog", Dialog)

function ActivityLuckyRoundAwardDialog:ctor(data, endCallback, nextCallback)
	ActivityLuckyRoundAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(570, 650)})
	self.m_data = data
	self.m_endCallback = endCallback
	self.m_nextCallback = nextCallback
end

function ActivityLuckyRoundAwardDialog:onEnter()
	ActivityLuckyRoundAwardDialog.super.onEnter(self)
	self:setTitle(CommonText[1805])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:height())

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg(), 1)
	bg:setPreferredSize(cc.size(500, 450))
	bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 + 30)


	for index = 1, #self.m_data.awards do
		local awardInfo = self.m_data.awards[index]
		local kind = awardInfo.type
		local id = awardInfo.id
		local count = awardInfo.count

		local configInfoID = self.m_data.luckyId[index]
		local config = ActivityCenterMO.getLuckAwardDrawByID(configInfoID)
		local rewardGold = config and config.rewardGold or false

		local _indexX = index % 4
		local _n = _indexX ~= 0 and _indexX or 4

		local _indexY = math.floor((index - 1) / 4)
		
		local item = UiUtil.createItemView(kind, id, {count = count}):addTo(bg, 2)
		local _x = CalculateX(4, _n, item:width(), 1.2) + bg:width() * 0.5 -- all, index, width, dexScaleOfWidth
		local _y = bg:height() - item:height() * 1.4 * _indexY - 0.5 * item:height() - 15
		item:setPosition(_x, _y)
		UiUtil.createItemDetailButton(item)

		if rewardGold then
			local itemgoldbg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(item,1)
			itemgoldbg:setPreferredSize(cc.size(40, 22))
			itemgoldbg:setOpacity(180)
			itemgoldbg:setPosition(item:width() - 25, item:height() - 15)

			local itemgoldlb = ui.newTTFLabel({text = rewardGold .. "%", font = G_FONT, size = FONT_SIZE_TINY,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(255, 255, 0)}):addTo(item,1)
			itemgoldlb:setPosition(item:width() - 25, item:height() - 17)
		end

		local itemInfo = UserMO.getResourceData(kind, id)

		local nameCount = 5
		local descCount , str = string.utf8len(itemInfo.name, nameCount)
		local name = itemInfo.name
		if descCount > nameCount then
			name = str .. "..."
		end
		local name = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = COLOR[itemInfo.quality]}):addTo(bg,3)
		name:setPosition(_x, _y - item:height() * 0.5 - 20)
	end

	local lastnumlb =  ui.newTTFLabel({text = CommonText[275] ..":", font = G_FONT, size = FONT_SIZE_MEDIUM,align = ui.TEXT_ALIGN_LEFT,color = cc.c3b(175, 175, 175)}):addTo(self:getBg(),1)
	lastnumlb:setAnchorPoint(cc.p(0, 0.5))
	lastnumlb:setPosition(self:getBg():getContentSize().width / 2 - 80, 85)

	local numlb = ui.newTTFLabel({text = tostring(ActivityCenterMO.luckyroundInfo.luckyCount), font = G_FONT, size = FONT_SIZE_MEDIUM,align = ui.TEXT_ALIGN_LEFT,color = cc.c3b(212, 174, 20)}):addTo(self:getBg(),1)
	numlb:setAnchorPoint(cc.p(0, 0.5))
	numlb:setPosition(lastnumlb:x() + lastnumlb:width(), lastnumlb:y())

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local takeTenBtn = MenuButton.new(normal, selected, nil, handler(self,self.onNextCallback)):addTo(self:getBg(), 2)
	takeTenBtn:setPosition(self:getBg():width() - takeTenBtn:width() * 0.7,85)
	takeTenBtn:setLabel(CommonText[1806][3])
end

function ActivityLuckyRoundAwardDialog:onReturnCallback(tar, sender)
	ActivityLuckyRoundAwardDialog.super.onReturnCallback(self, tar, sender)
	if self.m_data.statsAward then
		UiUtil.showAwards(self.m_data.statsAward)
	end
	if self.m_endCallback then
		self.m_endCallback()
	end
end

function ActivityLuckyRoundAwardDialog:onNextCallback( tar, sender )
	self:onReturnCallback(tar, sender)
	if self.m_nextCallback then
		self.m_nextCallback()
	end
end

function ActivityLuckyRoundAwardDialog:onExit()
	ActivityLuckyRoundAwardDialog.super.onExit(self)
end










----------------------------------------------------------------------
--							 幸运奖池								--
----------------------------------------------------------------------

local ActivityLuckyRoundView = class("ActivityLuckyRoundView",UiNode)

function ActivityLuckyRoundView:ctor(activity)
	ActivityLuckyRoundView.super.ctor(self, "image/common/bg_ui.jpg")
	self.m_activity = activity
end

function ActivityLuckyRoundView:onEnter()
	ActivityLuckyRoundView.super.onEnter(self)
	self:setTitle(self.m_activity.name)

	armature_add(IMAGE_ANIMATION .. "effect/tk1_yaojiang.pvr.ccz", IMAGE_ANIMATION .. "effect/tk1_yaojiang.plist", IMAGE_ANIMATION .. "effect/tk1_yaojiang.xml")

	local activityConfig = ActivityCenterMO.getActivitySupportConfig(self.m_activity.activityId, self.m_activity.awardId)
	self.m_ActivityConfig = json.decode(activityConfig.data2)

	self.m_activityState = true

	self.m_touchState = true

	self.m_timeSecondHand = 0

	self.m_roundState = false 				-- 是否可转动
	self.m_roundSecondHand = 0 				-- 转动帧
	self.m_roundlimit = 0.5 				-- 选择间隔时间
	self.m_roundItemIndex = 0 				-- 选择ITEM索引
	self.m_roundRoundNumber = 0 			-- 圈数
	self.m_roundType = 0 					-- 转动类型 0 单次 1 十次
	self.m_roundTargetId = 0 				-- 停止目标ID
	self.m_roundTargetList = {}				-- 目标数组
	self.m_roundTargetIndex = 0 			-- 索引
	self.m_roundTargetRoundRecode = 0       -- 红包 十次 记录
	self.m_roundAwardBackData = nil 		-- 抽奖返回数据

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()

    self:Init()

    self.m_allGoldListener = SocketReceiver.register("ActLuckyPoolGoldChange", ActivityCenterBO.AysActLuckyPoolGoldChange, true)
    self.m_allGoldNotify = Notify.register("ACTIVITY_LUCKY_ROUND_ALL_GOLD", handler(self, self.handlerAllGold))
    self.m_romateUpdate = Notify.register("ACTIVITY_LUCKY_ROUND_ROMATE_UPDATE", handler(self, self.takeRomateData))

    self:takeRomateData()
end

-- 拉去活动消息
function ActivityLuckyRoundView:takeRomateData()
	ActivityCenterBO.GetActLuckyInfo(handler(self,self.handRomateData))
end

-- 拉去活动消息 回调
function ActivityLuckyRoundView:handRomateData(data)
	self.m_hasPayGold = data.rechargegold
	self:handlerAllGold()
	if self.m_takeAwardDesc then
		self.m_takeAwardDesc:updateFunc()
	end
end

-- 奖池推送
function ActivityLuckyRoundView:handlerAllGold()
	if self.m_awardAllGoldlb then
		self.m_awardAllGoldlb:setString(tostring(ActivityCenterMO.luckyroundInfo.poolgold))
	end
	if self.m_goldIcon then
		self.m_goldIcon:setVisible(true)
		self.m_goldIcon:setPosition(self.m_awardAllGoldlb:x() + self.m_awardAllGoldlb:width() + self.m_goldIcon:width() * 0.5, self.m_awardAllGoldlb:y())
	end
end

-- 帧刷新
function ActivityLuckyRoundView:onEnterFrame(dt)
	self.m_timeSecondHand = self.m_timeSecondHand + dt
	if self.m_timeSecondHand >= 1 then
		self.m_timeSecondHand = self.m_timeSecondHand - 1
		if self.m_timelb then
			local time = self.m_activity.endTime - ManagerTimer.getTime()
			if time >= 0 then
				self.m_timelb:setString(UiUtil.strBuildTime(time))
				self.m_activityState = true
			else
				self.m_timelb:setString(CommonText[1781])
				self.m_activityState = false
			end
			
		end
	end

	self:doRoundLogic(dt)
end

-- 转动逻辑
function ActivityLuckyRoundView:doRoundLogic(dt)
	-- 进入转动帧轨迹
	if not self.m_roundState then return end
	self.m_roundSecondHand = self.m_roundSecondHand + dt

	-- 选择轨迹
	if self.m_roundSecondHand < self.m_roundlimit then return end

	-- 选择ITEM索引
	self.m_roundSecondHand = self.m_roundSecondHand - self.m_roundlimit
	self.m_roundItemIndex = self.m_roundItemIndex + 1
	if self.m_roundItemIndex > 12 then
		self.m_roundItemIndex = 1
		self.m_roundRoundNumber = self.m_roundRoundNumber + 1
		if self.m_roundRoundNumber >= 2 and self.m_roundType == 0 then
			self.m_roundlimit = self.m_roundlimit * 2
		end
	end

	for index = 1, #self.m_posBgList do
		local item = self.m_posBgList[index]
		if self.m_roundItemIndex == index then
			item:showFunc(true)
			if self.m_roundType == 0 then -- 单次
				if self.m_roundlimit > 0.15 and self.m_roundTargetId and self.m_roundTargetId == item.lucyId then
					item:showValueFunc()
					self:doRoundDone(item)
				end
			else --if self.m_roundType == 1 then  -- 十次
				if self.m_roundRoundNumber > 2 and self.m_roundTargetId == item.lucyId and self.m_roundTargetRoundRecode ~= self.m_roundRoundNumber then
					self.m_roundTargetRoundRecode = self.m_roundRoundNumber
					item:showValueFunc()
					self:doRoundNext(item)
				end
			end
		else
			item:showFunc(false)
		end
	end
end

-- 单抽结果
function ActivityLuckyRoundView:doRoundDone(item)
	-- body
	if self.m_roundTargetIndex == #self.m_roundTargetList then
		self.m_roundState = false
	end

	local p = item:getParent():convertToWorldSpace(cc.p(item:x(), item:y()))

	local function showEnd()
		if self.m_roundAwardBackData.statsAward then
			UiUtil.showAwards(self.m_roundAwardBackData.statsAward)
		end
		self:hideAllItem()
		self.m_roundAwardBackData = nil
		self.m_touchState = true
	end

	local function showAward()
		local AwardsDialog = require("app.dialog.AwardsDialog")
		AwardsDialog.new(self.m_roundAwardBackData.awards,showEnd):push()
	end

	local newitem = item.makeItemFunc(self:getBg(), p.x, p.y, item.kind, item.id, item.count, item.rewardGold)
	newitem:runAction(transition.sequence({cc.MoveTo:create(0.4,cc.p(display.cx, display.cy)), cc.CallFuncN:create(function (sender)
		sender:removeSelf()
		showAward()
	end)}) )
end

-- 十次结果
function ActivityLuckyRoundView:doRoundNext(item)

	local function showNext()
		self:takeAwardCallback(nil,{count = 10})
	end

	local function showEnd()
		self:hideAllItem()
		self.m_touchState = true
	end

	local function showAward()
		ActivityLuckyRoundAwardDialog.new(self.m_roundAwardBackData, showEnd, showNext):push()
	end

	local Index = self.m_roundTargetIndex + 1
	self.m_roundTargetId = self.m_roundTargetList[Index]
	if self.m_roundTargetId then
		self.m_roundTargetIndex = Index
	end

	if Index > #self.m_roundTargetList then
		self.m_roundState = false
		showAward()
	end

	local p = item:getParent():convertToWorldSpace(cc.p(item:x(), item:y()))
	local top = self.m_takeTenBtn:getParent():convertToWorldSpace(cc.p(self.m_takeTenBtn:x(), self.m_takeTenBtn:y()))

	local newitem = item.makeItemFunc(self:getBg(), p.x, p.y, item.kind, item.id, item.count, item.rewardGold)
    local spwArray = cc.Array:create()
    spwArray:addObject(cc.MoveTo:create(0.4,cc.p(top.x, top.y)))
    spwArray:addObject(cc.ScaleTo:create(0.4,0.5))
	newitem:runAction(transition.sequence({cc.Spawn:create(spwArray), cc.CallFuncN:create(function (sender)
		sender:removeSelf()
	end)}))
end

-- 初始化界面
function ActivityLuckyRoundView:Init()

	self.m_paylimitOnce = self.m_ActivityConfig[2]
	self.m_hasPayGold = 0

	local timeTitleLb = ui.newTTFLabel({text = CommonText[853], font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_LEFT,color = cc.c3b(255, 255, 255)}):addTo(self:getBg(),1)
	timeTitleLb:setAnchorPoint(cc.p(0, 0.5))
	timeTitleLb:setPosition(30, self:getBg():height() - 120)

	local timelb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_LEFT,color = cc.c3b(0, 255, 0)}):addTo(self:getBg(),1)
	timelb:setAnchorPoint(cc.p(0, 0.5))
	timelb:setPosition(timeTitleLb:x() + timeTitleLb:width(), timeTitleLb:y())
	self.m_timelb = timelb

	--概率公示
	local chance = ActivityCenterMO.getProbabilityTextById(self.m_activity.activityId, self.m_activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(self:getBg())
		chanceBtn:setPosition(self:getBg():width() / 2 + 30, self:getBg():height() - 120)
		chanceBtn:setVisible(chance.open == 1)
	end

	local activityDesc = ui.newTTFLabel({text = CommonText[882][1], font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_LEFT,color = cc.c3b(255, 255, 255)}):addTo(self:getBg(),1)
	activityDesc:setAnchorPoint(cc.p(0, 0.5))
	activityDesc:setPosition(30, self:getBg():height() - 150)

	local activityDescValue = ui.newTTFLabel({text = string.format(CommonText[1809][1], self.m_paylimitOnce), font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_LEFT,color = cc.c3b(175, 175, 175)}):addTo(self:getBg(),1)
	activityDescValue:setAnchorPoint(cc.p(0, 0.5))
	activityDescValue:setPosition(activityDesc:x() + activityDesc:width(), activityDesc:y())

	local function onDetail()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		local tabStr = clone(DetailText.luckyRoundHelper)
		tabStr[3][1].content = string.format(tabStr[3][1].content, self.m_ActivityConfig[1])
		tabStr[7][1].content = string.format(tabStr[7][1].content, self.m_ActivityConfig[2])
		DetailTextDialog.new(tabStr):push()
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, onDetail):addTo(self:getBg(),2)
	detailBtn:setPosition(self:getBg():width() - 60, self:getBg():height() - 140)

	-- 
	local normal = display.newSprite(IMAGE_COMMON .. "recordbtn.png")
	local recordBtn = ScaleButton.new(normal, handler(self, self.openTheLuckyRecordCallback)):addTo(self:getBg())
	recordBtn:setPosition(detailBtn:x() - detailBtn:width() * 0.5 - recordBtn:width() * 0.6,detailBtn:y())

	local contentbg = display.newSprite(IMAGE_COMMON .. "info_bg_30.jpg"):addTo(self:getBg(),3)
	contentbg:setPosition(self:getBg():width() * 0.5, self:getBg():height() - 140 - contentbg:height() * 0.5 - 40)
	self.m_contentbg = contentbg

	local centerbg = display.newSprite(IMAGE_COMMON .. "info_bg_141.png"):addTo(contentbg,1)
	centerbg:setPosition(contentbg:width() * 0.5, contentbg:height() * 0.5)

	local awardlb = ui.newTTFLabel({text = CommonText[1808] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM,align = ui.TEXT_ALIGN_LEFT,color = cc.c3b(255, 255, 255)}):addTo(centerbg,1)
	awardlb:setAnchorPoint(cc.p(0, 0.5))
	awardlb:setPosition(10, 25)

	local awardAllGoldlb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM,align = ui.TEXT_ALIGN_LEFT,color = cc.c3b(255, 255, 0)}):addTo(centerbg,1)
	awardAllGoldlb:setAnchorPoint(cc.p(0, 0.5))
	awardAllGoldlb:setPosition(awardlb:x() + awardlb:width(), awardlb:y())
	self.m_awardAllGoldlb = awardAllGoldlb

	local goldIcon = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(centerbg,1)
	goldIcon:setVisible(false)
	self.m_goldIcon = goldIcon


	local dex = -4
	self.m_poss = {[1] = {pos = cc.p(77,535 + dex)},
					[2] = {pos = cc.p(230,535 + dex)},
					[3] = {pos = cc.p(383,535 + dex)},
					[4] = {pos = cc.p(536,535 + dex)},
					[5] = {pos = cc.p(536,382 + dex)},
					[6] = {pos = cc.p(536,229 + dex)},
					[7] = {pos = cc.p(536,76 + dex)},
					[8] = {pos = cc.p(383,76 + dex)},
					[9] = {pos = cc.p(230,76 + dex)},
					[10] = {pos = cc.p(77,76 + dex)},
					[11] = {pos = cc.p(77,229 + dex)},
					[12] = {pos = cc.p(77,382 + dex)},}

	self.m_posBgList = {}
	local awardDrawInfos = ActivityCenterMO.getLuckAwardDraw(self.m_activity.awardId)

	local function showArmature(self_,isshow, force)
		local _force = force or false
		if _force or not self_.isShow then
			self_.armature:setVisible(isshow)
		end
	end

	local function setShowValue(self_)
		self_.isShow = true
	end

	local function makeItem(self_, _x, _y, type, id, count, rewardGold, detail)
		-- 奖励item
		local item = UiUtil.createItemView(type,id,{count = count}):addTo(self_, 5)
		item:setPosition(_x, _y)
		if detail then
			UiUtil.createItemDetailButton(item)
		end

		if rewardGold then
			local itemgoldbg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(item,1)
			itemgoldbg:setPreferredSize(cc.size(40, 22))
			itemgoldbg:setOpacity(180)
			itemgoldbg:setPosition(item:width() - 25, item:height() - 15)

			local itemgoldlb = ui.newTTFLabel({text = rewardGold .. "%", font = G_FONT, size = FONT_SIZE_TINY,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(255, 255, 0)}):addTo(item,1)
			itemgoldlb:setPosition(item:width() - 25, item:height() - 17)
		end
		return item
	end

	for index = 1 , #self.m_poss do
		local bg = display.newSprite(IMAGE_COMMON .. "info_bg_142.png"):addTo(contentbg, 5)
		bg:setPosition(self.m_poss[index].pos)

		local rewardGold = nil
		local awardDrawInfo = awardDrawInfos[index]
		local awardInfo = {}
		if awardDrawInfo.reward then
			awardInfo = json.decode(awardDrawInfo.reward)
		else
			awardInfo = {[1] = ITEM_KIND_COIN,[2] = 0, [3] = 0}
			rewardGold = awardDrawInfo.rewardGold
		end

		-- 配置信息
		bg.lucyId = awardDrawInfo.lucyId
		bg.isShow = false
		bg.kind = awardInfo[1]
		bg.id = awardInfo[2]
		bg.count = awardInfo[3]
		bg.rewardGold = rewardGold

		bg.makeItemFunc = makeItem
		bg:makeItemFunc(bg:width() * 0.5, bg:height() * 0.5 + 5, bg.kind, bg.id, bg.count, bg.rewardGold, true)

		-- 选中动画
		local armature = armature_create("tk1_yaojiang", bg:width() / 2 , bg:height() / 2):addTo(bg)
		armature:getAnimation():playWithIndex(0)
		bg.armature = armature

		bg.showValueFunc = setShowValue
		bg.showFunc = showArmature
		bg:showFunc(false, true)

		self.m_posBgList[index] = bg
	end

	local function updateAwardDesc(self_)
		local nextNeedGold = self.m_paylimitOnce - (self.m_hasPayGold % self.m_paylimitOnce)
		local luckyCount = ActivityCenterMO.luckyroundInfo.luckyCount or 0
		self_:setString(string.format(CommonText[1809][2],luckyCount,nextNeedGold))
	end

	local takeAwardDesc = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(160, 160, 160)}):addTo(self:getBg(),1)
	takeAwardDesc:setPosition(self:getBg():width() * 0.5, contentbg:y() - contentbg:height() * 0.5 - 30)
	self.m_takeAwardDesc = takeAwardDesc
	self.m_takeAwardDesc.updateFunc = updateAwardDesc
	self.m_takeAwardDesc:updateFunc()

	-- 单抽
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local takeOnceBtn = MenuButton.new(normal, selected, nil, handler(self,self.takeAwardCallback)):addTo(self:getBg())
	takeOnceBtn:setPosition(self:getBg():width() * 0.3,70)
	takeOnceBtn:setLabel(CommonText[1806][1])
	takeOnceBtn.count = 1

	-- 单抽
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local takeTenBtn = MenuButton.new(normal, selected, nil, handler(self,self.takeAwardCallback)):addTo(self:getBg())
	takeTenBtn:setPosition(self:getBg():width() * 0.7,70)
	takeTenBtn:setLabel(CommonText[1806][2])
	takeTenBtn.count = 10
	self.m_takeTenBtn = takeTenBtn
end

-- 隐藏 选中动画
function ActivityLuckyRoundView:hideAllItem()
	for index = 1, #self.m_posBgList do
		self.m_posBgList[index]:showFunc(false, true)
	end
end

-- 抽奖按钮
function ActivityLuckyRoundView:takeAwardCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local toCount = sender.count

	if not self.m_activityState then
		Toast.show(CommonText[1781])
		return
	end

	if not self.m_touchState then return end

	self.m_touchState = false

	self:hideAllItem()

	if toCount > ActivityCenterMO.luckyroundInfo.luckyCount then
		-- Toast.show(CommonText[1807])
		local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
		TipsAnyThingDialog.new(CommonText[1807], function() 
					-- require("app.view.RechargeView").new():push()
					RechargeBO.openRechargeView()
				end,CommonText[1094][1]):push()
		self.m_touchState = true
		return
	end
	
	local function resultCallback(data)
		-- 抽奖次数更新
		if self.m_takeAwardDesc then
			self.m_takeAwardDesc:updateFunc()
		end

		-- 奖金池
		self:handlerAllGold()

		self.m_roundAwardBackData = data

		local function showNext()
			self:takeAwardCallback(nil,{count = 10})
		end

		local function showEnd()
			self:hideAllItem()
			self.m_touchState = true
		end

		local function showAward()
			ActivityLuckyRoundAwardDialog.new(self.m_roundAwardBackData, showEnd, showNext):push()
		end

		self.m_roundType = toCount > 1 and 1 or 0

		self.m_roundSecondHand = 0 				-- 转动帧
		self.m_roundlimit = 0.05 				-- 选择间隔时间
		self.m_roundItemIndex = 0 				-- 选择ITEM索引
		self.m_roundRoundNumber = 0 			-- 圈数
		-- self.m_roundType = 0 					-- 转动类型 0 单次 1 十次
		-- self.m_roundTargetId = 0 				-- 停止目标ID
		self.m_roundTargetList = {}				-- 目标数组
		-- self.m_roundTargetIndex = 0 			-- 索引

		self.m_roundTargetRoundRecode = 0       -- 十次 记录

		self.m_roundTargetList = self.m_roundAwardBackData.luckyId

		self.m_roundTargetIndex = 1
		self.m_roundTargetId = self.m_roundTargetList[self.m_roundTargetIndex]

		if self.m_roundType == 0 then
			self.m_roundState = true 				-- 是否可转动	
		else -- if self.m_roundType == 1 then 
			showAward()
		end
	end
	ActivityCenterBO.GetActLuckyReward(resultCallback, toCount)
end

function ActivityLuckyRoundView:openTheLuckyRecordCallback(tar, sender)
	ManagerSound.playNormalButtonSound()

	if not self.m_activityState then
		Toast.show(CommonText[1781])
		return
	end

	if not self.m_touchState then return end

	local function resultCallback(data)
		local outdata = PbProtocol.decodeArray(data["luckLog"])
		ActivityLuckyRoundRecordDialog.new(outdata):push()
	end
	ActivityCenterBO.GetActLuckyPoolLog(resultCallback)
end


function ActivityLuckyRoundView:onExit()
	ActivityLuckyRoundView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/tk1_yaojiang.pvr.ccz", IMAGE_ANIMATION .. "effect/tk1_yaojiang.plist", IMAGE_ANIMATION .. "effect/tk1_yaojiang.xml")

	if self.m_allGoldListener then
		SocketReceiver.unregister("ActLuckyPoolGoldChange")
		self.m_allGoldListener = nil
	end

	if self.m_allGoldNotify then
		Notify.unregister(self.m_allGoldNotify)
		self.m_allGoldNotify = nil
	end

	if self.m_romateUpdate then
		Notify.unregister(self.m_romateUpdate)
		self.m_romateUpdate = nil
	end
end

return ActivityLuckyRoundView