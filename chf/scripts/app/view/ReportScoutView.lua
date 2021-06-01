
local ReportScoutView = class("ReportScoutView", UiNode)

-- 侦查报告
function ReportScoutView:ctor(mail, readStatus)
	ReportScoutView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_mail = mail
	self.m_readStatus = readStatus
	self.m_selfAsk = false
	gdump(self.m_mail, "ReportScoutView:ctor")
end

function ReportScoutView:onEnter()
	ReportScoutView.super.onEnter(self)
	
	self:setTitle(CommonText[548][3])

	self.m_mapHandler = Notify.register(LOCAL_MAP_DATE_UPDATE_EVENT, handler(self, self.onMapUpdate))

	self:setUI()
end

function ReportScoutView:onExit()
	ReportScoutView.super.onExit(self)
	if self.m_mapHandler then
		Notify.unregister(self.m_mapHandler)
		self.m_mapHandler = nil
	end
end

function ReportScoutView:setUI()
	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 90 - 34))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(600, 724))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 10 - infoBg:getContentSize().height / 2)

	-- 目标信息
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(infoBg)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(15, infoBg:getContentSize().height - 35)

	local title = ui.newTTFLabel({text = CommonText[308], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	-- 侦察地点
	local label = ui.newTTFLabel({text = CommonText[349][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = infoBg:getContentSize().height - 78, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))
	if self.m_mail.report.scoutMine then  -- 资源
		local resData = UserMO.getResourceData(ITEM_KIND_WORLD_RES, self.m_mail.report.scoutMine.mine)
		value:setString("LV." .. self.m_mail.report.scoutMine.lv .. " " .. resData.name2)
	elseif self.m_mail.report.scoutHome then -- 玩家
		value:setString(self.m_mail.report.scoutHome.name .. " " .. "LV." .. self.m_mail.report.scoutHome.lv)
	elseif self.m_mail.report.scoutRebel then -- 叛军
		if self.m_mail.report.scoutRebel.heroPick == -2 then
			local hd = RebelMO.getTeamById(self.m_mail.report.scoutRebel.rebelId)
			value:setString("LV." .. self.m_mail.report.scoutRebel.lv .. " " .. hd.name)
		else
			local rd = RebelMO.queryHeroById(self.m_mail.report.scoutRebel.heroPick)
			local hd = HeroMO.queryHero(rd.associate)
			value:setString("LV." .. self.m_mail.report.scoutRebel.lv .. " " .. hd.heroName)
		end
	end

	-- 侦察时间
	local label = ui.newTTFLabel({text = CommonText[349][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	local value = ui.newTTFLabel({text = os.date("%m-%d %X",self.m_mail.time or self.m_mail.report.time), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 据点坐标
	local label = ui.newTTFLabel({text = CommonText[349][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if self.m_mail.moldId == 52 then -- 军事矿区
		-- if self.m_mail.report.scoutMine then  -- 资源
			local pos = StaffMO.decodePosition(self.m_mail.report.scoutMine.pos)
			value:setString("(" .. pos.x .. "," .. pos.y .. ")")
		-- elseif self.m_mail.report.scoutHome then -- 玩家
		-- 	local pos = StaffMO.decodePosition(self.m_mail.report.scoutHome.pos)
		-- 	value:setString("(" .. pos.x .. "," .. pos.y .. ")")
		-- end
	elseif self.m_mail.moldId == 170 then -- 跨服军事矿区
		local pos = StaffMO.decodeCrossPosition(self.m_mail.report.scoutMine.pos)
			value:setString("(" .. pos.x .. "," .. pos.y .. ")")
	else
		if self.m_mail.report.scoutMine then  -- 资源
			local pos = WorldMO.decodePosition(self.m_mail.report.scoutMine.pos)
			value:setString("(" .. pos.x .. "," .. pos.y .. ")")
		elseif self.m_mail.report.scoutHome then -- 玩家
			local pos = WorldMO.decodePosition(self.m_mail.report.scoutHome.pos)
			value:setString("(" .. pos.x .. "," .. pos.y .. ")")
		elseif self.m_mail.report.scoutRebel then -- 叛军
			local pos = WorldMO.decodePosition(self.m_mail.report.scoutRebel.pos)
			value:setString("(" .. pos.x .. "," .. pos.y .. ")")
		end
	end
	value:setVisible(not self.m_readStatus)

	-- 所属军团
	local label = ui.newTTFLabel({text = CommonText[349][4] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if self.m_mail.report.scoutMine then -- 资源
		if table.isexist(self.m_mail.report.scoutMine, "party") then value:setString(self.m_mail.report.scoutMine.party)
		else value:setString(CommonText[108]) end  -- 无
	elseif self.m_mail.report.scoutHome then -- 玩家
		if table.isexist(self.m_mail.report.scoutHome, "party") then value:setString(self.m_mail.report.scoutHome.party)
		else value:setString(CommonText[108]) end  -- 无
	else
		value:setString(CommonText[108])
	end

	-- 据点驻军
	local label = ui.newTTFLabel({text = CommonText[349][5] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if self.m_mail.report.scoutMine then -- 资源
		if table.isexist(self.m_mail.report.scoutMine, "friend") then value:setString(self.m_mail.report.scoutMine.friend)
		else value:setString(CommonText[108]) end  -- 无
	elseif self.m_mail.report.scoutHome then -- 玩家
		if table.isexist(self.m_mail.report.scoutHome, "friend") then value:setString(self.m_mail.report.scoutHome.friend)
		else value:setString(CommonText[108]) end  -- 无
	else
		value:setString(CommonText[108])
	end

	local mineType = 1
	if self.m_mail.moldId == 52 then -- 军事矿区
		if self.m_mail.report.scoutMine then -- 资源
	        local sprite = UiUtil.createItemSprite(ITEM_KIND_MILITARY_MINE, self.m_mail.report.scoutMine.mine):addTo(infoBg)
	        sprite:setAnchorPoint(cc.p(0.5, 0))
	        sprite:setPosition(infoBg:getContentSize().width - 80, infoBg:getContentSize().height - 140)
	    end
	    mineType = 2
	elseif self.m_mail.moldId == 170 then -- 跨服军事矿区
		if self.m_mail.report.scoutMine then -- 资源
	        local sprite = UiUtil.createItemSprite(ITEM_KIND_MILITARY_MINE, self.m_mail.report.scoutMine.mine):addTo(infoBg)
	        sprite:setAnchorPoint(cc.p(0.5, 0))
	        sprite:setPosition(infoBg:getContentSize().width - 80, infoBg:getContentSize().height - 140)
	    end
	    mineType = 3
	else
		if self.m_mail.report.scoutMine then -- 资源
	        local sprite = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, self.m_mail.report.scoutMine.mine, {level = self.m_mail.report.scoutMine.lv}):addTo(infoBg)
	        sprite:setAnchorPoint(cc.p(0.5, 0))
	        sprite:setPosition(infoBg:getContentSize().width - 80, infoBg:getContentSize().height - 160)
	    elseif self.m_mail.report.scoutRebel then -- 叛军
	    	local sprite = RebelMO.getImage(self.m_mail.report.scoutRebel.heroPick):addTo(infoBg):scale(0.6)
	    	sprite:setAnchorPoint(cc.p(0.5, 0))
	    	sprite:setPosition(infoBg:getContentSize().width - 80, infoBg:getContentSize().height - 160)
	    elseif self.m_mail.report.scoutHome then -- 玩家
	    	local level = WorldMO.getBuildLevelByProps(self.m_mail.report.scoutHome.pros, self.m_mail.report.scoutHome.prosMax)
	    	local build = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, WORLD_ID_BUILD, {level = level}):addTo(infoBg)
	        build:setAnchorPoint(cc.p(0.5, 0))
	        build:setScale(math.min(160 / build:getContentSize().width, 130 / build:getContentSize().height))
	        build:setPosition(infoBg:getContentSize().width - 80, infoBg:getContentSize().height - 160)

	        local node = UiUtil.showProsValue(self.m_mail.report.scoutHome.pros, self.m_mail.report.scoutHome.prosMax):addTo(infoBg)
	        node:setPosition(infoBg:getContentSize().width - 160 - node:getContentSize().width, infoBg:getContentSize().height - 78)
		end
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_go_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_go_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onLocationCallback)):addTo(infoBg)
	btn:setPosition(infoBg:getContentSize().width - 80, infoBg:getContentSize().height - 200)
	if self.m_readStatus then
		btn:setEnabled(false)
		btn:setVisible(false)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_uncollect_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_uncollect_selected.png")
	local collectBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCollectCallback)):leftTo(btn)
	if self.m_mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
		collectBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_collect_normal.png"))
		collectBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_collect_selected.png"))
	end
	if self.m_readStatus then
		collectBtn:setVisible(false)
	end
	collectBtn.keyId = self.m_mail.keyId

	-- 资源信息 
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(infoBg)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(15, infoBg:getContentSize().height - 255)

	local title = ui.newTTFLabel({text = self.m_mail.report.scoutRebel and CommonText[38] or CommonText[347], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	if self.m_mail.report.scoutMine then -- 资源
		-- local resData = UserMO.getResource(ITEM_KIND_WORLD_RES, self.m_mail.report.scoutMine.mine)

		-- 驻守后。。。
		local value = ui.newTTFLabel({text = CommonText[350][1] .. UiUtil.strNumSimplify(self.m_mail.report.scoutMine.product) .. CommonText[350][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(540, 60)}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 1))
		value:setPosition(20, infoBg:getContentSize().height - 280)
		local vH = value:height()

		-- 已经采集
		local label = ui.newTTFLabel({text = CommonText[350][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = infoBg:getContentSize().height - 365, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = self.m_mail.report.scoutMine.harvest, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = infoBg:getContentSize().height - 365, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		local scoutMine = self.m_mail.report.scoutMine
		local goldGained = 0

		if RoyaleSurviveMO.isActOpen() and self.m_mail.moldId ~= 52  and self.m_mail.moldId ~= 170 then
			local mineLv = scoutMine.lv
			local mineLvDB = WorldMO.queryMineLvByLv(mineLv, mineType)
			local scorePerH = mineLvDB.honourLiveScore
			-- local scorePerH = 30000

			local value = ui.newTTFLabel({text = CommonText[2107][1] .. UiUtil.strNumSimplify(scorePerH) .. CommonText[2107][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[25], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(540, 60)}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 1))
			value:setPosition(20, infoBg:getContentSize().height - 305)

			if table.isexist(scoutMine, "honourScore") then
				local honourScore = scoutMine.honourScore
				-- local honourScore = 100
				local label = ui.newTTFLabel({text = CommonText[2107][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 220, y = infoBg:getContentSize().height - 365, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
				label:setAnchorPoint(cc.p(0, 0.5))

				local value = ui.newTTFLabel({text = string.format("%d", honourScore), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = infoBg:getContentSize().height - 365, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
				value:setAnchorPoint(cc.p(0, 0.5))
			end

			if table.isexist(scoutMine, "honourGold") then
				goldGained = goldGained + scoutMine.honourGold
				local mineLv = scoutMine.lv
				local mineLvDB = WorldMO.queryMineLvByLv(mineLv, mineType)
				local goldPerH = mineLvDB.honourLiveGold
				local value = ui.newTTFLabel({text = CommonText[2108][1] .. UiUtil.strNumSimplify(goldPerH) .. CommonText[2108][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[25], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(540, 60)}):addTo(infoBg)
				value:setAnchorPoint(cc.p(0, 1))
				value:setPosition(20, infoBg:getContentSize().height - 330)
			end
		end

		if table.isexist(scoutMine, "newHeroGold") then
			goldGained = goldGained + scoutMine.newHeroGold
		end

		if goldGained > 0 then
			local label = ui.newTTFLabel({text = CommonText[2108][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 400, y = infoBg:getContentSize().height - 365, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label:setAnchorPoint(cc.p(0, 0.5))
			local value = ui.newTTFLabel({text = string.format("%d", goldGained), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = infoBg:getContentSize().height - 365, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end
	elseif self.m_mail.report.scoutRebel then
		local list = RebelMO.getDropList(self.m_mail.report.scoutRebel.rebelId,self.m_mail.report.scoutRebel.heroPick)
		local ReportRewardTableView = require("app.scroll.ReportRewardTableView")
		local view = ReportRewardTableView.new(cc.size(self:getBg():getContentSize().width - 90, 120), list):addTo(infoBg)
		view:setAnchorPoint(cc.p(0,0.5))
		view:setPosition(20 , bg:getPositionY() - bg:getContentSize().height * 0.5 - view:getContentSize().height * 0.5 + 7.5)
	elseif self.m_mail.report.scoutHome then -- 玩家
		-- 最多可掠夺
		local label = ui.newTTFLabel({text = CommonText[350][4] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = infoBg:getContentSize().height - 285, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local grab, total = MailBO.parseGrab(self.m_mail.report.scoutHome.grab)

		local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(total), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		local startPosX = 20
		for index = 1, #grab do
			local res = grab[index]
			local itemSprite = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, res.id):addTo(infoBg)
			itemSprite:setPosition(startPosX + itemSprite:getBoundingBox().size.width / 2, value:getPositionY() - 40)
			local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(res.count), font = G_FONT, size = FONT_SIZE_SMALL, x = itemSprite:getPositionX() + itemSprite:getBoundingBox().size.width / 2, y = itemSprite:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 0.5))
			startPosX = startPosX + 105

			-- if grab.stone then
			-- 	local itemSprite = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(infoBg)
			-- 	itemSprite:setPosition(startPosX + itemSprite:getBoundingBox().size.width / 2, value:getPositionY() - 40)
			-- 	local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(grab.stone), font = G_FONT, size = FONT_SIZE_SMALL, x = itemSprite:getPositionX() + itemSprite:getBoundingBox().size.width / 2, y = itemSprite:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			-- 	value:setAnchorPoint(cc.p(0, 0.5))
			-- 	startPosX = startPosX + 105
			-- end
			-- if grab.iron then
			-- 	local itemSprite = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_IRON):addTo(infoBg)
			-- 	itemSprite:setPosition(startPosX + itemSprite:getBoundingBox().size.width / 2, value:getPositionY() - 40)
			-- 	local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(grab.iron), font = G_FONT, size = FONT_SIZE_SMALL, x = itemSprite:getPositionX() + itemSprite:getBoundingBox().size.width / 2, y = itemSprite:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			-- 	value:setAnchorPoint(cc.p(0, 0.5))
			-- 	startPosX = startPosX + 105
			-- end
			-- if grab.silicon then
			-- 	local itemSprite = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_SIlICON):addTo(infoBg)
			-- 	itemSprite:setPosition(startPosX + itemSprite:getBoundingBox().size.width / 2, value:getPositionY() - 40)
			-- 	local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(grab.silicon), font = G_FONT, size = FONT_SIZE_SMALL, x = itemSprite:getPositionX() + itemSprite:getBoundingBox().size.width / 2, y = itemSprite:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			-- 	value:setAnchorPoint(cc.p(0, 0.5))
			-- 	startPosX = startPosX + 105
			-- end
			-- if grab.copper then
			-- 	local itemSprite = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_COPPER):addTo(infoBg)
			-- 	itemSprite:setPosition(startPosX + itemSprite:getBoundingBox().size.width / 2, value:getPositionY() - 40)
			-- 	local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(grab.copper), font = G_FONT, size = FONT_SIZE_SMALL, x = itemSprite:getPositionX() + itemSprite:getBoundingBox().size.width / 2, y = itemSprite:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			-- 	value:setAnchorPoint(cc.p(0, 0.5))
			-- 	startPosX = startPosX + 105
			-- end
			-- if grab.oil then
			-- 	local itemSprite = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_OIL):addTo(infoBg)
			-- 	itemSprite:setPosition(startPosX + itemSprite:getBoundingBox().size.width / 2, value:getPositionY() - 40)
			-- 	local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(grab.oil), font = G_FONT, size = FONT_SIZE_SMALL, x = itemSprite:getPositionX() + itemSprite:getBoundingBox().size.width / 2, y = itemSprite:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			-- 	value:setAnchorPoint(cc.p(0, 0.5))
			-- 	startPosX = startPosX + 105
			-- end
		end
	end

	-- 兵力信息
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(infoBg)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(15, infoBg:getContentSize().height - 410)

	local title = ui.newTTFLabel({text = CommonText[348], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	-- 后排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_18.png", 154, 222):addTo(infoBg)

	-- 前排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_17.png", 154, 88):addTo(infoBg)

	local formation = nil
	if self.m_mail.report.scoutMine then -- 资源
		local form = PbProtocol.decodeRecord(self.m_mail.report.scoutMine["form"])
		formation = CombatBO.parseServerFormation(form)
	elseif self.m_mail.report.scoutHome then -- 玩家
		local form = PbProtocol.decodeRecord(self.m_mail.report.scoutHome["form"])
		form = form or TankMO.getEmptyFormation()
		formation = CombatBO.parseServerFormation(form)
	elseif self.m_mail.report.scoutRebel then -- 叛军
		local form = PbProtocol.decodeRecord(self.m_mail.report.scoutRebel["form"])
		form = form or TankMO.getEmptyFormation()
		formation = CombatBO.parseServerFormation(form)
	end

	if formation.awakenHero then
		formation.commander = formation.awakenHero.heroId
	end
	local itemView = UiUtil.createItemView(ITEM_KIND_HERO, formation.commander):addTo(infoBg)
	itemView:setScale(0.5)
	itemView:setPosition(70, 145)

	local tactics = {}
	if table.isexist(formation, "tactics") then
		tactics = PbProtocol.decodeArray(formation["tactics"])
	end
	local isTacticSuit = TacticsMO.isFormationTacticSuit(tactics,true) -- 战术类型
	local quality, tankType = TacticsMO.isFormationArmsSuit(tactics, true)  --兵种类型

	if isTacticSuit then
		local effItem = display.newSprite("image/tactics/tactics_"..isTacticSuit..".png"):addTo(infoBg)
		effItem:setScale(0.7)
		effItem:setPosition(70, 70)

		if tankType then
			local tankItem = display.newSprite("image/tactics/tank_type_"..tankType..".png"):alignTo(effItem, -40, 1)
		end
	end

	local ArmyFormationView = require("app.view.ArmyFormationView")
	local view = ArmyFormationView.new(FORMATION_FOR_TANK, formation, nil, {showAdd = false, reverse = true}):addTo(infoBg)
	view:setEnabled(false)
	view:setScale(0.8)
	view:setPosition(infoBg:getContentSize().width / 2 + 85, 20)

	-- 删除
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_del_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_del_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_lock_disabled.png")
	local delBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onDeleteCallback)):addTo(container)
	delBtn:setPosition(80, 50)
	if self.m_readStatus then
		delBtn:setEnabled(false)
	end

	-- 分享
	local normal = display.newSprite(IMAGE_COMMON .. "btn_share_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_share_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_share_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onShareCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width - 80 - 2 * 120, 50)
	if self.m_readStatus then
		btn:setEnabled(false)
	end

	-- 写邮件
	local normal = display.newSprite(IMAGE_COMMON .. "btn_sendMail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_sendMail_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_sendMail_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onWriteCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width - 80 - 1 * 120, 50)
	if self.m_readStatus or self.m_mail.report.scoutMine or self.m_mail.report.scoutRebel then -- 资源
		btn:setEnabled(false)
	end

	-- 攻击
	local normal = display.newSprite(IMAGE_COMMON .. "btn_lock_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_lock_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_lock_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onAtkCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width - 80, 50)
	if self.m_readStatus then
		btn:setEnabled(false)
	else
		if self.m_mail.moldId == 52 or self.m_mail.moldId == 170 then -- 军事矿区 或 跨服军事矿区
		else
			if self.m_mail.report.scoutMine then  -- 资源
				local pos = WorldMO.decodePosition(self.m_mail.report.scoutMine.pos)
				local status = WorldBO.getPositionStatus(pos)
				if status[ARMY_STATE_COLLECT] then
					btn:setEnabled(false)
				else
					local partyMine = WorldMO.getPartyMineAt(pos.x, pos.y)
					if partyMine and PartyBO.getMyParty() then
						btn:setEnabled(false)
					end
				end
			end
		end
	end
end

function ReportScoutView:onCollectCallback(tag, sender)
	local keyId = sender.keyId
	local kind = self.m_mail.isCollections
	if self.m_mail.isCollections == MAIL_COLLECT_TYPE_NORMAL then
		kind = MAIL_COLLECT_TYPE_COLLECTED
	elseif self.m_mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
		kind = MAIL_COLLECT_TYPE_NORMAL
	end

	if kind == MAIL_COLLECT_TYPE_COLLECTED then
		local collectNum = MailMO.queryTotalCollectMails()
		if collectNum >= MailMO.mailCollectMax then
			Toast.show(CommonText[100031])
			return
		end
	end

	MailBO.CollectMial(keyId, kind, function (success)
		if success then
			self.m_mail.isCollections = kind
			if self.m_mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
				sender:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_collect_normal.png"))
				sender:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_collect_selected.png"))
			else
				sender:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_uncollect_normal.png"))
				sender:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_uncollect_selected.png"))
			end

			if self.m_mail.isCollections == MAIL_COLLECT_TYPE_NORMAL then
				Toast.show(CommonText[1634][2])
			elseif self.m_mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
				Toast.show(CommonText[1634][1])
			end
		end
	end)
end

function ReportScoutView:onLocationCallback(tag, sender)
	self.m_selfAsk = false
	ManagerSound.playNormalButtonSound()
	local pos = cc.p(0, 0)

	if self.m_mail.moldId == 52 then -- 军事矿区
		if self.m_mail.report.scoutMine then -- 资源
			pos = StaffMO.decodePosition(self.m_mail.report.scoutMine.pos)
		end

		UiDirector.clear()

		local HomeView = require("app.view.HomeView")
		local view = HomeView.new(MAIN_SHOW_MINE_AREA):push()
		view:getCurContainer():locate(pos.x, pos.y, true)

		-- Notify.notify(LOCAL_LOCATION_MILITARY_AREA_EVENT, {x = pos.x, y = pos.y})
	elseif self.m_mail.moldId == 170 then -- 跨服军事矿区
		if self.m_mail.report.scoutMine then -- 资源
			pos = StaffMO.decodeCrossPosition(self.m_mail.report.scoutMine.pos)
		end

		UiDirector.clear()

		local HomeView = require("app.view.HomeView")
		local view = HomeView.new(MAIN_SHOW_CROSSSERVER_MINE_AREA):push()
		view:getCurContainer():locate(pos.x, pos.y, true)
	else
		if self.m_mail.report.scoutMine then -- 资源
			pos = WorldMO.decodePosition(self.m_mail.report.scoutMine.pos)
		elseif self.m_mail.report.scoutRebel then -- 资源
			pos = WorldMO.decodePosition(self.m_mail.report.scoutRebel.pos)
		elseif self.m_mail.report.scoutHome then -- 玩家
			pos = WorldMO.decodePosition(self.m_mail.report.scoutHome.pos)
		end

		UiDirector.clear()

		Notify.notify(LOCAL_LOCATION_EVENT, {x = pos.x, y = pos.y})
	end
end

function ReportScoutView:onAtkCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_selfAsk = false
	if self.m_mail.moldId == 52 then -- 军事矿区
		if not StaffBO.isMilitaryAreaOpen() then
			Toast.show(CommonText[10056][3])  -- 非活动期间，无法占领
			return
		end

		local pos = StaffMO.decodePosition(self.m_mail.report.scoutMine.pos)

		local mapData = StaffMO.getMapDataAt(pos.x, pos.y)
		if mapData then -- 已经被占领了
			if mapData.my then  -- 是自己占领了
				Toast.show(CommonText[10063][5])
				return
			else
				local curTime = ManagerTimer.getTime()
				if curTime <= mapData.freeTime then  -- 处于保护时间内
					Toast.show(CommonText[10063][3])
					return
				end

				local ConfirmDialog = require("app.dialog.ConfirmDialog")
				ConfirmDialog.new(CommonText[10065], function()
						if StaffMO.plunderCount_ <= 0 then  -- 掠夺次数已经用完了
							Toast.show(CommonText[10063][1])
							return
						end

						if UiDirector.hasUiByName("HomeView1") then
							UiDirector.popMakeUiTop("HomeView1")
						else
							UiDirector.clear()
						end

					    StaffMO.curAttackPos_ = pos
			    		StaffMO.curAttackType_ = MILITARY_AREA_PLUNDER

						local ArmyView = require("app.view.ArmyView")
						local view = ArmyView.new(ARMY_VIEW_MILITARY_AREA, 1):push()
					end):push()
				return
			end
		else  -- 还没有被占领，可以攻击
			if UiDirector.hasUiByName("HomeView1") then
				UiDirector.popMakeUiTop("HomeView1")
			else
				UiDirector.clear()
			end

		    StaffMO.curAttackPos_ = pos
    		StaffMO.curAttackType_ = MILITARY_AREA_ATTACK

			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_MILITARY_AREA, 1):push()
		end
	elseif self.m_mail.moldId == 170 then -- 跨服军事矿区
		if not StaffBO.IsCrossServerMineAreaOpen() then
			Toast.show(CommonText[10056][3])  -- 非活动期间，无法占领
			return
		end

		local pos = StaffMO.decodeCrossPosition(self.m_mail.report.scoutMine.pos)

		local mapData = StaffMO.getCrossMapDataAt(pos.x, pos.y)
		if mapData then -- 已经被占领了
			if mapData.my then  -- 是自己占领了
				Toast.show(CommonText[10063][5])
				return
			else
				local curTime = ManagerTimer.getTime()
				if curTime <= mapData.freeTime then  -- 处于保护时间内
					Toast.show(CommonText[10063][3])
					return
				end

				local ConfirmDialog = require("app.dialog.ConfirmDialog")
				ConfirmDialog.new(CommonText[10065], function()
						if StaffMO.plunderCount_ <= 0 then  -- 掠夺次数已经用完了
							Toast.show(CommonText[10063][1])
							return
						end

						if UiDirector.hasUiByName("HomeView3") then
							UiDirector.popMakeUiTop("HomeView3")
						else
							UiDirector.clear()
						end

					    StaffMO.curCrossAttackPos_ = pos
			    		StaffMO.curCrossAttackType_ = MILITARY_AREA_PLUNDER

						local ArmyView = require("app.view.ArmyView")
						local view = ArmyView.new(ARMY_VIEW_CORSS_MILITARY_AREA, 1):push()
					end):push()
				return
			end
		else  -- 还没有被占领，可以攻击
			if UiDirector.hasUiByName("HomeView3") then
				UiDirector.popMakeUiTop("HomeView3")
			else
				UiDirector.clear()
			end

		    StaffMO.curCrossAttackPos_ = pos
    		StaffMO.curCrossAttackType_ = MILITARY_AREA_ATTACK

			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_CORSS_MILITARY_AREA, 1):push()
		end
	else
		local num = UserMO.getResource(ITEM_KIND_POWER)
		if num < 1 then  -- 能量不足
			require("app.dialog.BuyPawerDialog").new():push()
			local resData = UserMO.getResourceData(ITEM_KIND_POWER)
			Toast.show(resData.name .. CommonText[223])
			return
		end

		if self.m_mail.report.scoutMine then -- 资源
			WorldMO.curAttackPos_ = WorldMO.decodePosition(self.m_mail.report.scoutMine.pos)
		elseif self.m_mail.report.scoutRebel then -- 资源
			WorldMO.curAttackPos_ = WorldMO.decodePosition(self.m_mail.report.scoutRebel.pos)
		elseif self.m_mail.report.scoutHome then -- 玩家
			WorldMO.curAttackPos_ = WorldMO.decodePosition(self.m_mail.report.scoutHome.pos)
		end

		local mine = WorldBO.getMineAt(WorldMO.curAttackPos_)
		if mine then  -- 是资源
			UiDirector.clear()
			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_FOR_WORLD):push()
		else
			local mapData = WorldMO.getMapDataAt(WorldMO.curAttackPos_.x, WorldMO.curAttackPos_.y)
			-- print("x:", WorldMO.curAttackPos_.x, "y:", WorldMO.curAttackPos_.y)
			-- dump(mapData, "XXXXXXXX")
			if mapData then -- 获得过玩家信息
				UiDirector.clear()
				local ArmyView = require("app.view.ArmyView")
				local view = ArmyView.new(ARMY_VIEW_FOR_WORLD):push()
			else  -- 没有地图数据，需要先请求
				Loading.getInstance():show()
				self.m_selfAsk = true
				WorldBO.asynGetMp({WorldMO.curAttackPos_},nil,1)
			end
		end
	end
end

function ReportScoutView:onMapUpdate(event)
	if UiDirector.getTopUiName() == "ReportScoutView" and self.m_selfAsk then 
		Loading.getInstance():unshow()
		UiDirector.clear()
		local ArmyView = require("app.view.ArmyView")
		local view = ArmyView.new(ARMY_VIEW_FOR_WORLD):push()
	end
end

function ReportScoutView:onDeleteCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	MailBO.asynDelMail(function()
			Loading.getInstance():unshow()
			Toast.show(CommonText[551][2])
			self:pop()
		end, self.m_mail)
end

function ReportScoutView:onShareCallback(tag, sender)
	self.m_selfAsk = false
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ShareDialog").new(SHARE_TYPE_MAIL, self.m_mail, sender):push()
end

function ReportScoutView:onWriteCallback(tag, sender)
	self.m_selfAsk = false
	ManagerSound.playNormalButtonSound()
	require("app.dialog.MailSendDialog").new(self.m_mail.report.scoutHome.name, MAIL_SEND_TYPE_NORMAL):push()
end

return ReportScoutView
