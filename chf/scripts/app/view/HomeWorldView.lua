
local HomeWorldView = class("HomeWorldView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function HomeWorldView:ctor()
	self:setContentSize(cc.size(display.width, display.height))
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_runTick=nil
end

function HomeWorldView:onEnter()
	if WorldMO.clearMapData_ then  -- 需要清除之前没有被清除的地图数据
		WorldMO.clearMapData_ = false

		WorldMO.mapData_ = {}
		WorldMO.partyMine_ = {}
		WorldMO.mine_ = {}
		WorldMO.areaIndex_ = {}
		WorldMO.warFree_ = {}
		Notify.notify(LOCAL_CLEAR_MAP_EVENT)
	end

	self.m_xValue = 0
	self.m_yValue = 0

	local TileMapInfo = require("app.world.TileMapInfo")
	local mapInfo = TileMapInfo.new()
	mapInfo:setMapSize(WORLD_SIZE_WIDTH, WORLD_SIZE_HEIGHT)  -- 只能是偶数
	mapInfo:setTileSize(WORLD_TILE_WIDTH, WORLD_TILE_HEIGHT)

	local TileMap = require("app.world.TileMap")
	local view = TileMap.new(cc.size(display.width, display.height - 100 - 30), mapInfo):addTo(self)
	view:setPosition((self:getContentSize().width - view:getContentSize().width) / 2, 102 * GAME_X_SCALE_FACTOR)
	view:setHomePosition(cc.p(WorldMO.pos_.x, WorldMO.pos_.y))
	self.m_tileMap = view

	Notify.notify(LOCAL_TANK_LINE)

	self.mapSize_ = mapInfo:getMapSize()
	self.tileSize_ = mapInfo:getTileSize()

	self.m_xValue = WorldMO.currentPos_.x
	self.m_yValue = WorldMO.currentPos_.y

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(self, 2)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(0, self:getContentSize().height - 150 * GAME_X_SCALE_FACTOR - 40)

	-- 世界等级
	local label = ui.newTTFLabel({text = CommonText[10044][1] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(bg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = StaffMO.worldLv_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 坐标
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_70.png"):addTo(self, 2)
	bg:setPosition(self:getContentSize().width / 2 + 10, 180 * GAME_X_SCALE_FACTOR)

	local function onXCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local function showXValue(numValue)
			self.m_xValue = numValue
			self.m_xLabel:setString(self.m_xValue)
		end

		local KeyBoardDialog = require("app.dialog.KeyBoardDialog")
		local dialog = KeyBoardDialog.new(showXValue):push()
		dialog:getBg():setPosition(280, 210 * GAME_X_SCALE_FACTOR + dialog:getBg():getContentSize().height / 2)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_tip_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_tip_selected.png")
	local btn = MenuButton.new(normal, selected, nil, onXCallback):addTo(bg)
	btn:setPosition(15, bg:getContentSize().height / 2)

	local label = ui.newTTFLabel({text = CommonText[305], font = G_FONT, size = FONT_SIZE_SMALL, x = 80, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- X:
	local label = ui.newTTFLabel({text = "X:", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_16_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_16_selected.png")
	local xBtn = MenuButton.new(normal, selected, nil, onXCallback):addTo(bg)
	xBtn:setPosition(label:getPositionX() + 85, bg:getContentSize().height / 2)

	local label = ui.newTTFLabel({text = WorldMO.currentPos_.x, font = G_FONT, size = FONT_SIZE_SMALL, x = xBtn:getContentSize().width / 2, y = xBtn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(xBtn)
	self.m_xLabel = label

	-- Y:
	local label = ui.newTTFLabel({text = "Y:", font = G_FONT, size = FONT_SIZE_SMALL, x = xBtn:getPositionX() + 110, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local function onYCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local function showValue(numValue)
			self.m_yValue = numValue
			self.m_yLabel:setString(self.m_yValue)
		end

		local KeyBoardDialog = require("app.dialog.KeyBoardDialog")
		local dialog = KeyBoardDialog.new(showValue):push()
		dialog:getBg():setPosition(440, 210 * GAME_X_SCALE_FACTOR + dialog:getBg():getContentSize().height / 2)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_16_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_16_selected.png")
	local yBtn = MenuButton.new(normal, selected, nil, onYCallback):addTo(bg)
	yBtn:setPosition(label:getPositionX() + 85, bg:getContentSize().height / 2)

	local label = ui.newTTFLabel({text = WorldMO.currentPos_.y, font = G_FONT, size = FONT_SIZE_SMALL, x = yBtn:getContentSize().width / 2, y = yBtn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(yBtn)
	self.m_yLabel = label

	local function onLocationCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local x = math.max(0, math.min(self.mapSize_.width - 1, self.m_xValue))
		local y = math.max(0, math.min(self.mapSize_.height - 1, self.m_yValue))
		-- self:locate(x, y)
		self.m_tileMap:locate(x, y)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_go_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_go_selected.png")
	local locationBtn = MenuButton.new(normal, selected, nil, onLocationCallback):addTo(bg, 10)
	locationBtn:setPosition(bg:getContentSize().width - 30, bg:getContentSize().height / 2)

	local function gotoSocial(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.SocialityView").new(SOCIALITY_FOR_STORE):push()
	end

	-- 社交
	local normal = display.newSprite(IMAGE_COMMON .. "btn_favorite_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_favorite_selected.png")
	local socialBtn = MenuButton.new(normal, selected, nil, gotoSocial):addTo(self, 2)
	socialBtn:setPosition(display.width - 50, 370)

	--小地图按钮
	local btn = ScaleButton.new(display.newSprite(IMAGE_COMMON.."dituanniu.png"), function()
			ManagerSound.playNormalButtonSound()
			AirshipBO.getAirship(function()
				if UiDirector.getTopUi():getUiName() == "HomeView" then
					require("app.dialog.Minimap").new():push()
				end
			end)
		end):alignTo(socialBtn, 100, 1)
	btn:setVisible(UserMO.queryFuncOpen(UFP_AIRSHIP))
	local function gotoSearch(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.dialog.WorldNearbyDialog").new(WorldMO.currentPos_.x, WorldMO.currentPos_.y):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_seek_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_seek_selected.png")
	local socialBtn = MenuButton.new(normal, selected, nil, gotoSearch):addTo(self, 2)
	socialBtn:setPosition(display.width -50, 250)

	-- 安全区提示
	if RoyaleSurviveMO.isActOpen() then
		local royaleNode = display.newNode()
		royaleNode:addTo(self)
		self.m_royaleDisplay = royaleNode

		-- 显示当前安全区的范围
		local originH = display.height - 125
		local originW = display.width - 235

		local xbegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.x
		local xend = RoyaleSurviveMO.safeAreaRightUpCorner.x

		local ybegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.y
		local yend = RoyaleSurviveMO.safeAreaRightUpCorner.y

		local curPhaseStr = string.format("圈数/总圈数:(%d/%d)", RoyaleSurviveMO.curPhase, RoyaleSurviveMO.totalPhase)
		local labelPhase = ui.newTTFLabel({text=curPhaseStr,size=20,color=COLOR[1]}):addTo(self.m_royaleDisplay, 2)
		labelPhase:setPosition(originW, originH)
		labelPhase:setAnchorPoint(0, 0.5)
		self.m_phaseLabel = labelPhase

		local t = UiUtil.label("开始缩圈："):addTo(self.m_royaleDisplay, 2)
		t:setAnchorPoint(0, 0.5)
		t:setPosition(originW, originH - labelPhase:height())
		self.m_circleLabel = t

		local left = UiUtil.label("00d:00h:00m:00s", nil, COLOR[6]):rightTo(t)
		self.m_circleTimeCounterLabel = left
		left:performWithDelay(handler(self, self.poisonCircleTick), 1, 1)
		self:poisonCircleTick()

		local safeStr = string.format("X:(%d~%d), Y:(%d~%d)", xbegin, xend, ybegin, yend)
		local label1 = ui.newTTFLabel({text=safeStr,size=20,color=COLOR[23]}):addTo(self.m_royaleDisplay, 2)
		label1:setPosition(originW, originH - label1:height() * 3)
		label1:setAnchorPoint(0, 0.5)
		self.m_safeLabel = label1

		local lebel_tile = ui.newTTFLabel({text="当前安全区",size=20,color=COLOR[23]}):addTo(self.m_royaleDisplay, 2)
		lebel_tile:setPosition(originW, originH - label1:height() * 2)
		lebel_tile:setAnchorPoint(0, 0.5)
		self.m_safeTitleLabel = lebel_tile

		local xbegin1 = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.x
		local xend1 = RoyaleSurviveMO.nextSafeAreaRightUpCorner.x

		local ybegin1 = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.y
		local yend1 = RoyaleSurviveMO.nextSafeAreaRightUpCorner.y

		local nextSafeStr = string.format("X:(%d~%d), Y:(%d~%d)", xbegin1, xend1, ybegin1, yend1)
		local label2 = ui.newTTFLabel({text=nextSafeStr,size=20,color=COLOR[99]}):addTo(self.m_royaleDisplay, 2)
		label2:setPosition(originW, originH - label1:height()*5)
		label2:setAnchorPoint(0, 0.5)
		self.m_nextSafeLabel = label2
		print("RoyaleSurviveMO.shrinkAllOver!!", RoyaleSurviveMO.shrinkAllOver)
		label2:setVisible(not RoyaleSurviveMO.shrinkAllOver)

		local lebel_tile1 = ui.newTTFLabel({text="下一安全区",size=20,color=COLOR[99]}):addTo(self.m_royaleDisplay, 2)
		lebel_tile1:setPosition(originW, originH - label1:height()*4)
		lebel_tile1:setAnchorPoint(0, 0.5)
		self.m_nextSafeTitleLabel = lebel_tile1
		lebel_tile1:setVisible(not RoyaleSurviveMO.shrinkAllOver)

		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(self.m_royaleDisplay, 1)
		bg:setPreferredSize(cc.size(230, label1:height() * 6 + 10))
		bg:setAnchorPoint(cc.p(0, 0.5))
		bg:setPosition(originW - 5, originH - label1:height() * 3 + 10)
		bg:setOpacity(125)

		if RoyaleSurviveMO.curPhase > 0 then
			function rsCallback()
				require("app.view.RoyaleBuffShowDialog").new():push()
			end

			local normal = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_selected.png")
			local hsBtn = MenuButton.new(normal, selected, nil, rsCallback):addTo(self)
			hsBtn:setPosition(120, self:getContentSize().height - 220 + 20 - 40)

			local normal1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal_debuff.png")
			local selected1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_selected_debuff.png")
			local hsBtn1 = MenuButton.new(normal1, selected1, nil, rsCallback):addTo(self)
			hsBtn1:setPosition(120, self:getContentSize().height - 220 + 20 - 40)

			local myPos = WorldMO.pos_
			local temp = RoyaleSurviveMO.IsInSafeArea(myPos)
			hsBtn:setVisible(temp)
			hsBtn1:setVisible(not temp)

			self.m_hsBtnBuff = hsBtn
			self.m_hsBtnDebuff = hsBtn1
		end
	end

	local function gotoPlayRegulations(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.dialog.WorldRegulationsDialog").new():push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_52_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_52_normal.png")
	local socialBtn = MenuButton.new(normal, selected, nil, gotoPlayRegulations):addTo(self, 2)
	socialBtn:setPosition(socialBtn:getContentSize().width/2, self:getContentSize().height - 220 + 20 - 40)
	-- socialBtn:setLabel("玩法\n说明",{color=COLOR[6],size=FONT_SIZE_SMALL})
	socialBtn:setScale(0.8)
	socialBtn:setVisible(UserMO.level_ <= 30)

	-- 世界矿点按钮

	local function queryWorldMine()
		-- body
		WorldBO.getWorldStaffing(function (data)
			-- body
			require_ex("app.dialog.WorldMineFieldDialog").new():push()
		end)
	end

	local normal1 = display.newSprite(IMAGE_COMMON .. "btn_world_mine.png")
	local selected1 = display.newSprite(IMAGE_COMMON .. "btn_world_mine.png")
	local hsBtn1 = MenuButton.new(normal1, selected1, nil, queryWorldMine):addTo(self)
	hsBtn1:setPosition(socialBtn:getContentSize().width/2, self:getContentSize().height - 220 + 20 - 40 - socialBtn:height())
	if UserMO.level_ > 30 then
		hsBtn1:setPosition(socialBtn:getContentSize().width/2, socialBtn:y())
	end
	hsBtn1:setScale(0.8)

	self.homeEnterSchedulerHandler_ = scheduler.performWithDelayGlobal(function()
			self.homeEnterSchedulerHandler_ = nil
			if UiDirector.getTopUiName() == "HomeView" then
				ManagerSound.playSound("chapter_chose")
				Toast.show(CommonText[359][3])
			end
		end, 0.1)

	self.labelTime=ui.newTTFLabel({text="",font = "Arial",size = 20,color = cc.c3b(255, 0, 0)}):addTo(self,2)
	self.labelTime:setAnchorPoint(0,0)
	self.labelTime:setPosition(socialBtn:getContentSize().width+1, self:getContentSize().height - 220 + 20 - 50)
	self.labelTime:setVisible(false)
	PictureValidateBO.getScoutInfo(function ()
		Mtime=ManagerTimer.getTime()
		local s=UserMO.prohibitedTime-Mtime
		if  s>0 then   --被禁止时间的显示
			self:showTick(s)
		end
	end)

	self.m_hndSafeAreaUpdate = Notify.register(LOCAL_UPDATE_SAFE_AREA, handler(self, self.onSafeAreaUpdate))
	self.m_hndNextSafeAreaUpdate = Notify.register(LOCAL_NEXT_SAFE_AREA, handler(self, self.onNextSafeAreaUpdate))
	self.m_royaleCloseHandler = Notify.register(LOCAL_ROYALE_SURVIVE_CLOSE, handler(self, self.onRoyaleClose))
	self.m_safeAreaShrinkOverHandler = Notify.register(LOCAL_SAFE_AREA_SHRINK_OVER, handler(self, self.onSafeAreaShrinkOver))
end

function HomeWorldView:showTick(time)
	local s=time
	self.labelTime:setVisible(true)
	self.labelTime:setString(string.format("侦察冷却:"..UiUtil.strBuildTime(s, "hms")))
	if not self.m_runTick then
		self.m_runTick=ManagerTimer.addTickListener(function (dt)
			s=s-dt
			if s<=0 then
				self.labelTime:setVisible(false)
				ManagerTimer.removeTickListener(self.m_runTick)
				self.m_runTick=nil
			else
				self.labelTime:setString(string.format("侦察冷却倒计时:"..UiUtil.strBuildTime(s, "hms")))
			end
		end)
	end
end

function HomeWorldView:onLocate(x, y, feedback)
	if self.m_tileMap then
		self.m_tileMap:locate(x, y, feedback)
	end
end

function HomeWorldView:onExit()
	if self.homeEnterSchedulerHandler_ then
		scheduler.unscheduleGlobal(self.homeEnterSchedulerHandler_)
		self.homeEnterSchedulerHandler_ = nil
	end
	if self.m_runTick then
		ManagerTimer.removeTickListener(self.m_runTick)
		self.m_runTick=nil
	end

	if self.m_hndSafeAreaUpdate then
		Notify.unregister(self.m_hndSafeAreaUpdate)
		self.m_hndSafeAreaUpdate = nil
	end

	if self.m_hndNextSafeAreaUpdate then
		Notify.unregister(self.m_hndNextSafeAreaUpdate)
		self.m_hndNextSafeAreaUpdate = nil
	end

	if self.m_royaleCloseHandler then
		Notify.unregister(self.m_royaleCloseHandler)
		self.m_royaleCloseHandler = nil
	end

	if self.m_safeAreaShrinkOverHandler then
		Notify.unregister(self.m_safeAreaShrinkOverHandler)
		self.m_safeAreaShrinkOverHandler = nil
	end
end

function HomeWorldView:onSafeAreaUpdate(event)
	-- bod
	if self.m_safeLabel then
		if RoyaleSurviveMO.safeAreaLeftBottomCorner and RoyaleSurviveMO.safeAreaRightUpCorner then
			local xbegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.x
			local xend = RoyaleSurviveMO.safeAreaRightUpCorner.x

			local ybegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.y
			local yend = RoyaleSurviveMO.safeAreaRightUpCorner.y

			local safeStr = string.format("X:(%d~%d), Y:(%d~%d)", xbegin, xend, ybegin, yend)
			self.m_safeLabel:setString(safeStr)
		end
	else
		if RoyaleSurviveMO.isActOpen() then
			local royaleNode = display.newNode()
			royaleNode:addTo(self)
			self.m_royaleDisplay = royaleNode

			-- 显示当前安全区的范围
			local originH = display.height - 125
			local originW = display.width - 235

			local curPhaseStr = string.format("圈数/总圈数:(%d/%d)", RoyaleSurviveMO.curPhase, RoyaleSurviveMO.totalPhase)
			local labelPhase = ui.newTTFLabel({text=curPhaseStr,size=20,color=COLOR[1]}):addTo(self.m_royaleDisplay, 2)
			labelPhase:setPosition(originW, originH)
			labelPhase:setAnchorPoint(0, 0.5)
			self.m_phaseLabel = labelPhase

			if RoyaleSurviveMO.shrinkAllOver == false then
				local t = UiUtil.label("开始缩圈："):addTo(self.m_royaleDisplay, 2)
				t:setAnchorPoint(0, 0.5)
				t:setPosition(originW, originH - labelPhase:height())
				self.m_circleLabel = t

				local left = UiUtil.label("00d:00h:00m:00s", nil, COLOR[6]):rightTo(t)
				self.m_circleTimeCounterLabel = left
				left:performWithDelay(handler(self, self.poisonCircleTick), 1, 1)
				self:poisonCircleTick()
			end

			if RoyaleSurviveMO.safeAreaLeftBottomCorner and RoyaleSurviveMO.safeAreaRightUpCorner then
				local xbegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.x
				local xend = RoyaleSurviveMO.safeAreaRightUpCorner.x

				local ybegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.y
				local yend = RoyaleSurviveMO.safeAreaRightUpCorner.y

				local safeStr = string.format("X:(%d~%d), Y:(%d~%d)", xbegin, xend, ybegin, yend)
				local label1 = ui.newTTFLabel({text=safeStr,size=20,color=COLOR[23]}):addTo(self.m_royaleDisplay, 2)
				label1:setPosition(originW, originH - label1:height() * 3)
				label1:setAnchorPoint(0, 0.5)
				self.m_safeLabel = label1

				local lebel_tile = ui.newTTFLabel({text="当前安全区",size=20,color=COLOR[23]}):addTo(self.m_royaleDisplay, 2)
				lebel_tile:setPosition(originW, originH - label1:height() * 2)
				lebel_tile:setAnchorPoint(0, 0.5)
				self.m_safeTitleLabel = lebel_tile

				local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(self.m_royaleDisplay, 1)
				bg:setPreferredSize(cc.size(230, label1:height() * 6 + 10))
				bg:setAnchorPoint(cc.p(0, 0.5))
				bg:setPosition(originW - 5, originH - label1:height() * 3 + 10)
				bg:setOpacity(125)
			end

			if RoyaleSurviveMO.nextSafeAreaLeftBottomCorner and RoyaleSurviveMO.nextSafeAreaRightUpCorner then
				local xbegin1 = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.x
				local xend1 = RoyaleSurviveMO.nextSafeAreaRightUpCorner.x

				local ybegin1 = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.y
				local yend1 = RoyaleSurviveMO.nextSafeAreaRightUpCorner.y

				local nextSafeStr = string.format("X:(%d~%d), Y:(%d~%d)", xbegin1, xend1, ybegin1, yend1)
				local label2 = ui.newTTFLabel({text=nextSafeStr,size=20,color=COLOR[99]}):addTo(self.m_royaleDisplay, 2)
				label2:setPosition(originW, originH - label2:height()*5)
				label2:setAnchorPoint(0, 0.5)
				self.m_nextSafeLabel = label2
				label2:setVisible(not RoyaleSurviveMO.shrinkAllOver)

				local lebel_tile1 = ui.newTTFLabel({text="下一安全区",size=20,color=COLOR[99]}):addTo(self.m_royaleDisplay, 2)
				lebel_tile1:setPosition(originW, originH - label2:height()*4)
				lebel_tile1:setAnchorPoint(0, 0.5)
				self.m_nextSafeTitleLabel = lebel_tile1
				lebel_tile1:setVisible(not RoyaleSurviveMO.shrinkAllOver)
			end
		end
	end

	if self.m_hsBtnDebuff and self.m_hsBtnBuff then
		if RoyaleSurviveMO.isActOpen() and RoyaleSurviveMO.curPhase > 0 then
			local myPos = WorldMO.pos_
			local temp = RoyaleSurviveMO.IsInSafeArea(myPos)
			self.m_hsBtnBuff:setVisible(temp)
			self.m_hsBtnDebuff:setVisible(not temp)
		else
			self.m_hsBtnBuff:setVisible(false)
			self.m_hsBtnDebuff:setVisible(false)
		end
	else
		if RoyaleSurviveMO.isActOpen() and RoyaleSurviveMO.curPhase > 0 then
			function rsCallback()
				require("app.view.RoyaleBuffShowDialog").new():push()
			end

			local normal = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_selected.png")
			local hsBtn = MenuButton.new(normal, selected, nil, rsCallback):addTo(self)
			hsBtn:setPosition(120, self:getContentSize().height - 220 + 20 - 40)

			local normal1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal_debuff.png")
			local selected1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_selected_debuff.png")
			local hsBtn1 = MenuButton.new(normal1, selected1, nil, rsCallback):addTo(self)
			hsBtn1:setPosition(120, self:getContentSize().height - 220 + 20 - 40)

			local myPos = WorldMO.pos_
			local temp = RoyaleSurviveMO.IsInSafeArea(myPos)
			hsBtn:setVisible(temp)
			hsBtn1:setVisible(not temp)

			self.m_hsBtnBuff = hsBtn
			self.m_hsBtnDebuff = hsBtn1
		end
	end
end

function HomeWorldView:onNextSafeAreaUpdate(event)
	-- body
	if self.m_nextSafeLabel then
		local xbegin1 = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.x
		local xend1 = RoyaleSurviveMO.nextSafeAreaRightUpCorner.x

		local ybegin1 = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.y
		local yend1 = RoyaleSurviveMO.nextSafeAreaRightUpCorner.y

		local nextSafeStr = string.format("X:(%d~%d), Y:(%d~%d)", xbegin1, xend1, ybegin1, yend1)
		self.m_nextSafeLabel:setString(nextSafeStr)

		local curPhaseStr = string.format("圈数/总圈数:(%d/%d)", RoyaleSurviveMO.curPhase, RoyaleSurviveMO.totalPhase)
		self.m_phaseLabel:setString(curPhaseStr)
	else
		if RoyaleSurviveMO.nextSafeAreaLeftBottomCorner and RoyaleSurviveMO.nextSafeAreaRightUpCorner and self.m_royaleDisplay then
			local originH = display.height - 125
			local originW = display.width - 235

			local xbegin1 = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.x
			local xend1 = RoyaleSurviveMO.nextSafeAreaRightUpCorner.x

			local ybegin1 = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.y
			local yend1 = RoyaleSurviveMO.nextSafeAreaRightUpCorner.y

			local nextSafeStr = string.format("X:(%d~%d), Y:(%d~%d)", xbegin1, xend1, ybegin1, yend1)
			local label2 = ui.newTTFLabel({text=nextSafeStr,size=20,color=COLOR[99]}):addTo(self.m_royaleDisplay, 2)
			label2:setPosition(originW, originH - label2:height()*5)
			label2:setAnchorPoint(0, 0.5)
			self.m_nextSafeLabel = label2
			label2:setVisible(not RoyaleSurviveMO.shrinkAllOver)

			local lebel_tile1 = ui.newTTFLabel({text="下一安全区",size=20,color=COLOR[99]}):addTo(self.m_royaleDisplay, 2)
			lebel_tile1:setPosition(originW, originH - label2:height()*4)
			lebel_tile1:setAnchorPoint(0, 0.5)
			self.m_nextSafeTitleLabel = lebel_tile1
			lebel_tile1:setVisible(not RoyaleSurviveMO.shrinkAllOver)
		end
	end


	if self.m_circleTimeCounterLabel and self.m_circleLabel then
	else
		if RoyaleSurviveMO.shrinkAllOver == false and self.m_royaleDisplay then
			-- 显示当前安全区的范围
			local originH = display.height - 125
			local originW = display.width - 235

			local t = UiUtil.label("开始缩圈："):addTo(self.m_royaleDisplay, 2)
			t:setAnchorPoint(0, 0.5)
			t:setPosition(originW, originH - t:height())
			self.m_circleLabel = t

			local left = UiUtil.label("00d:00h:00m:00s", nil, COLOR[6]):rightTo(t)
			self.m_circleTimeCounterLabel = left
			left:performWithDelay(handler(self, self.poisonCircleTick), 1, 1)
			self:poisonCircleTick()
		end
	end
end


function HomeWorldView:onRoyaleClose(event)
	-- body
	if self.m_royaleDisplay then
		self.m_royaleDisplay:removeAllChildren()
	end
end


function HomeWorldView:onSafeAreaShrinkOver(event)
	-- body
	print("self.m_nextSafeLabel!!", self.m_nextSafeLabel)
	print("self.m_nextSafeTitleLabel!!", self.m_nextSafeTitleLabel)
	if self.m_nextSafeLabel and self.m_nextSafeTitleLabel then
		self.m_nextSafeLabel:setVisible(not RoyaleSurviveMO.shrinkAllOver)
		self.m_nextSafeTitleLabel:setVisible(not RoyaleSurviveMO.shrinkAllOver)
	end
end


function HomeWorldView:poisonCircleTick()
	-- body

	local now_t = ManagerTimer.getTime()
	local start_t = RoyaleSurviveMO.shrinkStartTime
	local end_t = RoyaleSurviveMO.shrinkEndTime

	local str
	local remain = 0
	if now_t < start_t then
		str = "开始缩圈："
		remain = start_t - now_t
		self.m_circleTimeCounterLabel:setColor(COLOR[1])
	elseif now_t >= start_t and now_t < end_t then
		str = "缩圈结束："
		remain = end_t - now_t
		self.m_circleTimeCounterLabel:setColor(COLOR[6])
	end

	if str then
		remain = math.floor(remain)
		self.m_circleLabel:setString(str)
		local h = math.floor(remain / 3600)
		local m = math.floor((remain - h * 3600) / 60)
		local s = remain - h * 3600 - m * 60

		self.m_circleTimeCounterLabel:setString(string.format("%02dh:%02dm:%02ds",h,m,s))
		self.m_circleTimeCounterLabel:setVisible(true)
		self.m_circleLabel:setVisible(true)
	else
		self.m_circleLabel:setVisible(false)
		self.m_circleTimeCounterLabel:setVisible(false)
	end
end


return HomeWorldView
