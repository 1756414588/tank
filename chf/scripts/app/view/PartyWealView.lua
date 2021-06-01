--
-- Author: gf
-- Date: 2015-09-15 12:29:24
-- 福利院

--------------------------------------------------------------------
-- 军团活跃任务tableview
--------------------------------------------------------------------

local PartyLivelyTableView = class("PartyLivelyTableView", TableView)

function PartyLivelyTableView:ctor(size)
	PartyLivelyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

function PartyLivelyTableView:numberOfCells()
	return #PartyMO.liveTaskList
end

function PartyLivelyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyLivelyTableView:createCellAtIndex(cell, index)
	PartyLivelyTableView.super.createCellAtIndex(self, cell, index)

	local partyLivelyData = PartyMO.liveTaskList[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(580, 150))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_PARTY_LIVELY_TASK,partyLivelyData.taskId):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = partyLivelyData.taskName, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 123, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))
	
	local liveLab = ui.newTTFLabel({text = CommonText[610][1] .. partyLivelyData.live, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 70, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	liveLab:setAnchorPoint(cc.p(0, 0.5))

	local liveCount = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 40, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	liveCount:setAnchorPoint(cc.p(0, 0.5))
	local liveCountValue = partyLivelyData.schedue
	if liveCountValue > partyLivelyData.count then
		liveCountValue = partyLivelyData.count
	end
	liveCount:setString(CommonText[610][2] .. liveCountValue .. "/" .. partyLivelyData.count)

	return cell
end

function PartyLivelyTableView:onUpgradeUpdate()
	self:reloadData()
end

function PartyLivelyTableView:onExit()
	PartyLivelyTableView.super.onExit(self)

end

--------------------------------------------------------------------
-- 军团活跃任务tableview
--------------------------------------------------------------------


local PartyWealView = class("PartyWealView", UiNode)

function PartyWealView:ctor(buildingId)
	PartyWealView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function PartyWealView:onEnter()
	PartyWealView.super.onEnter(self)

	self:setTitle(CommonText[604])

	local function createDelegate(container, index)
		if index == 1 then  -- 日常福利
			self:showDayWealView(container)
		elseif index == 2 then -- 战事福利
			if not PartyBattleMO.isOpen then return end
			Loading.getInstance():show()
			PartyBattleBO.asynGetPartyAmyProps(function()
					Loading.getInstance():unshow()
					self:showCombatWealView(container)
				end)
		elseif index == 4 then --军团任命
			-- if GameConfig.areaId > 5 then
			-- 	Toast.show(CommonText[64])
			-- 	return
			-- end
			self:showAppoint(container)
		else --军团活跃
			self:showLiveLyView(container)
		end
	end

	local function clickDelegate(container, index)

	end

	local pages = {CommonText[601][1],CommonText[601][2],CommonText[601][3],CommonText[601][4]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

end

function PartyWealView:showAppoint(container)
	container:removeAllChildren()
	require("app.view.PartyAppoint").new(container:width(), container:height()):addTo(container)
end

function PartyWealView:showDayWealView(container)
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 40, 165))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 10 - infoBg:getContentSize().height / 2)
	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_WEAL,PartyMO.partyData_.wealLv)
	for index=1,#CommonText[602] do
		local labTit = ui.newTTFLabel({text = CommonText[602][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 20, y = infoBg:getContentSize().height - 25 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		labTit:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then --福利院等级
			value:setString(PartyMO.partyData_.wealLv)
			self.buildLvLab_ = value
		elseif index == 2 then --升级需求
			if PartyMO.partyData_.wealLv == PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_WEAL) then --等级已达上限
				value:setString(CommonText[575][1])
				value:setColor(COLOR[2])
			else
				value:setString(partyBuildLv.needExp)
				if PartyMO.partyData_.build >= partyBuildLv.needExp then --建设度大于升级需求
					value:setColor(COLOR[2])
				else
					value:setColor(COLOR[6])
				end
			end
			self.buildUpNeedLab_ = value
		elseif index == 3 then --总建设度
			value:setString(PartyMO.partyData_.build)
			self.buildValueLab_ = value
		elseif index == 4 then --个人贡献
			value:setString(PartyMO.myDonate_)
			self.myDonateLab_ = value
		end
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local levelUpBtn = MenuButton.new(normal, selected, disabled, handler(self,self.levelUpHandler)):addTo(infoBg)
	levelUpBtn:setPosition(infoBg:getContentSize().width - levelUpBtn:getContentSize().width / 2 - 10,infoBg:getContentSize().height - levelUpBtn:getContentSize().height / 2 - 10)
	levelUpBtn:setLabel(CommonText[582][1])
	levelUpBtn:setEnabled(PartyMO.partyData_.wealLv < PartyMO.partyData_.partyLv and PartyMO.partyData_.wealLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_WEAL) and PartyMO.partyData_.build >= partyBuildLv.needExp)
	if PartyMO.partyData_.wealLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_WEAL) then
		levelUpBtn.needExp = partyBuildLv.needExp
	end
	levelUpBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)

	--当前福利背景
	local infoBg1 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	infoBg1:setPreferredSize(cc.size(container:getContentSize().width - 40, 340))
	infoBg1:setPosition(container:getContentSize().width / 2, container:getContentSize().height - infoBg1:getContentSize().height - 30)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		infoBg1:getContentSize().width / 2, infoBg1:getContentSize().height):addTo(infoBg1)

	local wealTit = ui.newTTFLabel({text = CommonText[603][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, 
		color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	local needDonateLab = ui.newTTFLabel({text = CommonText[603][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = infoBg1:getContentSize().height - 60, 
		color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
	needDonateLab:setAnchorPoint(cc.p(0, 0.5))
	local needDonateValue = ui.newTTFLabel({text = PartyMO.getDayWealNeed, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = needDonateLab:getPositionX() + needDonateLab:getContentSize().width, y = needDonateLab:getPositionY(), 
		color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
	needDonateValue:setAnchorPoint(cc.p(0, 0.5))

	--根据福利院等级取得福利
	local wealAwards = json.decode(PartyMO.queryPartyWeal(PartyMO.partyData_.wealLv).wealList) 
	-- gdump(wealAwards,"当前等级每日福利")
	for index=1,#wealAwards do
		local itemView = UiUtil.createItemView(wealAwards[index][1], wealAwards[index][2], {count = wealAwards[index][3]})
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 140,infoBg1:getContentSize().height - 150)
		infoBg1:addChild(itemView)
		UiUtil.createItemDetailButton(itemView)
		local propDB = UserMO.getResourceData(wealAwards[index][1], wealAwards[index][2])
		local name = ui.newTTFLabel({text = propDB.name .. " * " .. wealAwards[index][3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 70, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local wealAllBtn = MenuButton.new(normal, selected, nil, handler(self,self.wealAllHandler)):addTo(container)
	wealAllBtn:setPosition(container:getContentSize().width / 2 - 150,infoBg1:getPositionY() - infoBg1:getContentSize().height / 2 - 70)
	wealAllBtn:setLabel(CommonText[603][3])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local getWealBtn = MenuButton.new(normal, selected, disabled, handler(self,self.getWealHandler)):addTo(container)
	getWealBtn:setPosition(container:getContentSize().width / 2 + 150,infoBg1:getPositionY() - infoBg1:getContentSize().height / 2 - 70)
	getWealBtn:setLabel(CommonText[603][4])
	getWealBtn:setEnabled(PartyMO.myDonate_ >= PartyMO.getDayWealNeed and PartyMO.wealData_.everWeal == 0)
	self.getWealBtn = getWealBtn

end

function PartyWealView:levelUpHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.levelUpStatus == true then return end
	self.levelUpStatus = true

	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_WEAL,PartyMO.partyData_.wealLv)
	
	Loading.getInstance():show()
	PartyBO.asynUpPartyBuilding(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[585])
		self:updateWealInfo()
		self.levelUpStatus = false
		end,PARTY_BUILD_ID_WEAL,partyBuildLv.needExp)
end

function PartyWealView:showCombatWealView(container)
	--军团活跃
	local lab = ui.newTTFLabel({text = CommonText[817], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = container:getContentSize().height - 40, 
		color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	lab:setAnchorPoint(cc.p(0, 0.5))

	-- local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	-- tableBg:setPreferredSize(cc.size(container:getContentSize().width - 40, container:getContentSize().height - 80))
	-- tableBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tableBg:getContentSize().height / 2 - 80)

	

	local PartyBWealTableView = require("app.scroll.PartyBWealTableView")
	local view = PartyBWealTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 70)):addTo(container)
	view:setPosition(0, 10)
	view:reloadData()

end

function PartyWealView:showLiveLyView(container)
	local logo = display.newSprite(IMAGE_COMMON .. "party_logo.png", 80, container:getContentSize().height - 50):addTo(container)
	local partyLiveLyData = PartyMO.getLivelyDataByExp(PartyMO.wealData_.live)

	--军团活跃
	local livelyLab = ui.newTTFLabel({text = CommonText[606][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = logo:getPositionY() + 20, 
		color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	livelyLab:setAnchorPoint(cc.p(0, 0.5))
	local livelyValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = livelyLab:getPositionX() + livelyLab:getContentSize().width, y = livelyLab:getPositionY(), 
		color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	livelyValue:setAnchorPoint(cc.p(0, 0.5))

	--升级进度
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(340, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(340 + 4, 26)}):addTo(container)
	bar:setPosition(150 + bar:getContentSize().width / 2, livelyLab:getPositionY() - 35)

	local livelyLv --活跃等级
	if partyLiveLyData then
		livelyLv = partyLiveLyData.livelyLv
		--计算当前经验
		local exp,needExp
		if partyLiveLyData.livelyLv == 1 then
			exp = PartyMO.wealData_.live
			needExp = partyLiveLyData.livelyExp
		else
			exp = PartyMO.wealData_.live - PartyMO.queryPartyLively(partyLiveLyData.livelyLv - 1).livelyExp
			needExp = partyLiveLyData.livelyExp - PartyMO.queryPartyLively(partyLiveLyData.livelyLv - 1).livelyExp
		end
		bar:setLabel(exp .. "/" .. needExp)
		bar:setPercent(exp / needExp)
	else --已满级
		livelyLv = PartyMO.queryPartyMaxLively()
		
		bar:setLabel("MAX")
		bar:setPercent(0)
	end
	livelyValue:setString("LV." .. livelyLv)

	--活跃规则按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local ruleBtn = MenuButton.new(normal, selected, nil, handler(self,self.ruleHandler)):addTo(container)
	ruleBtn:setPosition(container:getContentSize().width  - 70,logo:getPositionY() - 10)
	
	local infoBg1 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	infoBg1:setPreferredSize(cc.size(container:getContentSize().width - 40, container:getContentSize().height - 100))
	infoBg1:setPosition(container:getContentSize().width / 2, container:getContentSize().height - infoBg1:getContentSize().height / 2 - 100)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		infoBg1:getContentSize().width / 2, infoBg1:getContentSize().height):addTo(infoBg1)

	local wealTit = ui.newTTFLabel({text = string.format(CommonText[606][2],livelyLv) , font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, 
		color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	local info = PartyMO.queryPartyLively(livelyLv)
	local wealDesc1 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,
		color = COLOR[11], align = ui.TEXT_ALIGN_LEFT}):addTo(infoBg1)
	wealDesc1:setAnchorPoint(cc.p(0.5, 0.5))

	local wealDesc2 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		color = COLOR[11], align = ui.TEXT_ALIGN_LEFT,dimensions = cc.size(420, 60)}):addTo(infoBg1)
	wealDesc2:setAnchorPoint(cc.p(0.5, 0.5))

	if info.resource == 0 and info.science == 1 then --无福利
		wealDesc1:setString(CommonText[608][1])
	else
		if info.resource > 0 then
			wealDesc1:setString(string.format(CommonText[608][2],info.resource / 10) .. "%")
		end
		if info.science > 1 then
			wealDesc2:setString(string.format(CommonText[608][3],info.science))
		end
	end
	wealDesc1:setPosition(10 + wealDesc1:getContentSize().width / 2,infoBg1:getContentSize().height - 50)
	wealDesc2:setPosition(10 + wealDesc2:getContentSize().width / 2,wealDesc1:getPositionY() - wealDesc1:getContentSize().height - 10)

	--活跃榜按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local rankBtn = MenuButton.new(normal, selected, nil, handler(self,self.rankHandler)):addTo(infoBg1)
	rankBtn:setPosition(infoBg1:getContentSize().width  - 80,infoBg1:getContentSize().height - 60)
	rankBtn:setLabel(CommonText[607][1])

	--今日可领取
	local canGetLab = ui.newTTFLabel({text = CommonText[606][3], font = G_FONT, 
		size = FONT_SIZE_SMALL, x = 10, y = infoBg1:getContentSize().height - 125, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
	canGetLab:setAnchorPoint(cc.p(0, 0.5))
	for index = RESOURCE_ID_IRON,RESOURCE_ID_STONE do
		local icon = UiUtil.createItemView(ITEM_KIND_RESOURCE, index)
		icon:setScale(0.3)
		infoBg1:addChild(icon)
		icon:setPosition(10 + icon:getContentSize().width * 0.3 / 2 + (index - 1) * 110,canGetLab:getPositionY() - 45)
		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = icon:getPositionX() + icon:getContentSize().width * 0.3 / 2 + 5, y = icon:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == RESOURCE_ID_IRON then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.resource.iron))
		elseif index == RESOURCE_ID_OIL then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.resource.oil))
		elseif index == RESOURCE_ID_COPPER then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.resource.copper))
		elseif index == RESOURCE_ID_SILICON then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.resource.silicon))
		elseif index == RESOURCE_ID_STONE then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.resource.stone))
		end
	end

	--今日已领取
	local hasGetLab = ui.newTTFLabel({text = CommonText[606][4], font = G_FONT, 
		size = FONT_SIZE_SMALL, x = 10, y = infoBg1:getContentSize().height - 215, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
	hasGetLab:setAnchorPoint(cc.p(0, 0.5))

	for index = RESOURCE_ID_IRON,RESOURCE_ID_STONE do
		local icon = UiUtil.createItemView(ITEM_KIND_RESOURCE, index)
		icon:setScale(0.3)
		infoBg1:addChild(icon)
		icon:setPosition(10 + icon:getContentSize().width * 0.3 / 2 + (index - 1) * 110,hasGetLab:getPositionY() - 45)
		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = icon:getPositionX() + icon:getContentSize().width * 0.3 / 2 + 5, y = icon:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == RESOURCE_ID_IRON then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.getResource.iron))
		elseif index == RESOURCE_ID_OIL then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.getResource.oil))
		elseif index == RESOURCE_ID_COPPER then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.getResource.copper))
		elseif index == RESOURCE_ID_SILICON then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.getResource.silicon))
		elseif index == RESOURCE_ID_STONE then
			value:setString(UiUtil.strNumSimplify(PartyMO.wealData_.getResource.stone))
		end
	end

	--领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local getBtn = MenuButton.new(normal, selected, nil, handler(self,self.getRewardHandler)):addTo(infoBg1)
	getBtn:setPosition(infoBg1:getContentSize().width  - 80,infoBg1:getContentSize().height - 215)
	getBtn:setLabel(CommonText[607][3])
	local awardRes = PartyMO.wealData_.resource.iron + 
						PartyMO.wealData_.resource.stone +
						PartyMO.wealData_.resource.silicon +
						PartyMO.wealData_.resource.copper +
						PartyMO.wealData_.resource.oil
	-- gdump(awardRes,"awardResawardRes====")
	getBtn:setVisible(awardRes > 0)

	--采集按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local gatherBtn = MenuButton.new(normal, selected, nil, handler(self,self.gatherBtnHandler)):addTo(infoBg1)
	gatherBtn:setPosition(infoBg1:getContentSize().width  - 80,infoBg1:getContentSize().height - 215)
	gatherBtn:setLabel(CommonText[607][2])
	gatherBtn:setVisible(awardRes == 0)

	--活跃任务列表
	local view = PartyLivelyTableView.new(cc.size(infoBg1:getContentSize().width, infoBg1:getContentSize().height - 290)):addTo(infoBg1)
	view:setPosition(0, 0)
	view:reloadData()
end

function PartyWealView:getWealHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynWealDayParty(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[605])
		self:updateWealInfo()
		end,PARTY_WEAL_GET_TYPE_DAY)
end

function PartyWealView:ruleHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyWealRuleDialog").new():push()
end

function PartyWealView:rankHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynGetPartyLiveRank(function(list)
		Loading.getInstance():unshow()
		require("app.dialog.PartyLiveRankDialog").new(list):push()
		end)
end

function PartyWealView:wealAllHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyDayWealDialog").new():push()
end

function PartyWealView:getRewardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	PartyBO.asynWealDayParty(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[605])
		self:updateWealInfo()
		end,PARTY_WEAL_GET_TYPE_LIVE)
end

function PartyWealView:gatherBtnHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function()
		UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
	end)
end

function PartyWealView:updateWealInfo()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	-- local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_HALL,PartyMO.partyData_.wealLv)
	-- --等级
	-- self.buildLvLab_:setString(PartyMO.partyData_.wealLv)
	-- --升级需求
	-- if PartyMO.partyData_.wealLv == PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_WEAL) then --等级已达上限
	-- 	self.buildUpNeedLab_:setString(CommonText[575][1])
	-- 	self.buildUpNeedLab_:setColor(COLOR[2])
	-- else
	-- 	self.buildUpNeedLab_:setString(partyBuildLv.needExp)
	-- 	if PartyMO.partyData_.build >= partyBuildLv.needExp then --建设度大于升级需求
	-- 		self.buildUpNeedLab_:setColor(COLOR[2])
	-- 	else
	-- 		self.buildUpNeedLab_:setColor(COLOR[6])
	-- 	end
	-- end
	-- --建设度
	-- self.buildValueLab_:setString(PartyMO.partyData_.build)
	-- --个人贡献
	-- self.myDonateLab_:setString(PartyMO.myDonate_)
end

function PartyWealView:onExit()
	PartyWealView.super.onExit(self)
	PartyBO.clearAllParty()
end





return PartyWealView