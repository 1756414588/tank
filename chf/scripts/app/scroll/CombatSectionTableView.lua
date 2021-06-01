
local CombatSectionTableView = class("CombatSectionTableView", TableView)

function CombatSectionTableView:ctor(size, viewFor)
	CombatSectionTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 204)
	-- self.m_canFightSectionId = CombatBO.getCanFightSectionId()
	-- self.m_combatType = combatType

	self.m_viewFor = viewFor

	self.m_updateValue = nil
	self.m_updateCombatType = nil
	self.m_updateCombatId = nil

	--探险关卡
	-- self.explorePass = {EXPLORE_TYPE_EXTREME,EXPLORE_TYPE_PART,EXPLORE_TYPE_EQUIP,EXPLORE_TYPE_MEDAL,EXPLORE_TYPE_WAR,EXPLORE_TYPE_ENERGYSPAR,EXPLORE_TYPE_TACTIC}
	self.explorePass = {EXPLORE_TYPE_PART,EXPLORE_TYPE_EQUIP,EXPLORE_TYPE_MEDAL,EXPLORE_TYPE_WAR,EXPLORE_TYPE_ENERGYSPAR,EXPLORE_TYPE_TACTIC}
	-- if GameConfig.areaId > 5 then
	-- 	table.remove(self.explorePass,#self.explorePass)
	-- 	return
	-- end
end

function CombatSectionTableView:onEnter()
	CombatSectionTableView.super.onEnter(self)
	self.m_exploreListener = Notify.register("WIPE_COMBAT_EXPLORE_HANDLER", handler(self,self.updatePowerListener))
end

function CombatSectionTableView:onExit()
	CombatSectionTableView.super.onExit(self)
	if self.m_exploreListener then
		Notify.unregister(self.m_exploreListener)
		self.m_exploreListener = nil
	end
	armature_remove("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_remove("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")
end

function CombatSectionTableView:updatePowerListener()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function CombatSectionTableView:reloadData(updateValue, updateCombatType, updateCombatId)
	self.m_updateValue = updateValue
	self.m_updateCombatType = updateCombatType
	self.m_updateCombatId = updateCombatId

	gprint("[CombatSectionTableView] value:", updateValue, "type:", updateCombatType, "combatId:", updateCombatId)

	CombatSectionTableView.super.reloadData(self)
end

function CombatSectionTableView:numberOfCells()
	if self.m_viewFor == SECTION_VIEW_FOR_COMBAT then
		if CombatMO.currentCombatId_ == 0 then
			return 1
		else
			local combatDB = CombatMO.queryCombatById(CombatMO.currentCombatId_)
			local nxtCombatDB = CombatMO.queryCombatById(combatDB.nxtCombatId)
			local size = 0

			if not nxtCombatDB then
				size = combatDB.sectionId % 100
			else
				if combatDB.sectionId < nxtCombatDB.sectionId then  -- 当前章的最后一关
					local nxtNxtSectionId = nxtCombatDB.sectionId + 1
					local nxtNxtSection = CombatMO.querySectionById(nxtNxtSectionId)
					if not nxtNxtSection then
						size = combatDB.sectionId % 100 + 1
					else
						size = combatDB.sectionId % 100 + 2
					end
				else
					size = combatDB.sectionId % 100 + 1
				end
			end

			if size > CombatMO.queryCombatSectionMax() then
				size = CombatMO.queryCombatSectionMax()
			end
			return size
		end
	elseif self.m_viewFor == SECTION_VIEW_FOR_EXPLORE then -- 装备、配件、极限
		return #self.explorePass
	elseif self.m_viewFor == SECTION_VIEW_FOR_LIMIT then
		return 1
	elseif self.m_viewFor == SECTION_VIEW_FOR_CHALLENGE then
		return HunterMO.getStageCount()
	end
end

function CombatSectionTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function CombatSectionTableView:createCellAtIndex(cell, index)
	CombatSectionTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell)
	bg:setPreferredSize(cc.size(594, 194))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local sectionId = 0
	if self.m_viewFor == SECTION_VIEW_FOR_COMBAT then
		sectionId = 100 + self:numberOfCells() - index + 1 -- 显示的章节id
	elseif self.m_viewFor == SECTION_VIEW_FOR_EXPLORE then -- 装备、配件、极限
		local exploreType = self.explorePass[index]
		sectionId = CombatMO.getExploreSectionIdByType(exploreType)
	elseif self.m_viewFor == SECTION_VIEW_FOR_LIMIT then
		-- sectionId = CombatMO.getExploreSectionIdByType(4)
		sectionId = CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_EXTREME)
	elseif self.m_viewFor == SECTION_VIEW_FOR_CHALLENGE then --如果是极限挑战，就从1000开始加
		sectionId = 100 + index
	end

	gprint("[CombatSectionTableView] create cell. sectionId:", sectionId, "index:", index, "size:", self:numberOfCells())

	if self.m_viewFor == SECTION_VIEW_FOR_COMBAT then  -- 征战
		local sectionDB = CombatMO.querySectionById(sectionId)
		local sectionOpen = CombatBO.isSectionCanFight(sectionId)  -- 章节是否开启

		local sprite = nil
		if sectionOpen then
			sprite = display.newSprite(IMAGE_COMMON .. "combat/" .. sectionDB.asset .. ".jpg")
		else
			sprite = display.newSprite(IMAGE_COMMON .. "combat/" .. sectionDB.asset .. "_close.jpg")
		end
		local btn = CellTouchButton.new(sprite, nil, nil, nil, handler(self, self.onChoseSectionCallback))
		btn.index = index
		btn.sectionId = sectionId
		btn.sectionOpen = sectionOpen
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		local name = ui.newTTFLabel({text = sectionDB.name, font = G_FONT, size = FONT_SIZE_BIG, x = 80, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		name:setAnchorPoint(cc.p(0, 0.5))

		if not sectionOpen then
			if sectionDB.rank > 0 then -- 军衔要求
				-- 军衔要求
				local rank = ui.newTTFLabel({text = CommonText[48] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width + 5, y = name:getPositionY(), color = COLOR[1]}):addTo(btn)

				local rankDB = UserMO.queryRankById(sectionDB.rank)
				local rankName = ui.newTTFLabel({text = rankDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = rank:getPositionX() + rank:getContentSize().width / 2, y = rank:getPositionY(), color = COLOR[2]}):addTo(btn)
			end

			local lastSectionDB = CombatMO.querySectionById(sectionId - 1)  -- 上一个章节信息
			if lastSectionDB then
				-- 通过
				local pas = ui.newTTFLabel({text = CommonText[49], font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 270, y = name:getPositionY(), color = COLOR[1]}):addTo(btn)
				-- 章节名称
				local chapter = ui.newTTFLabel({text = "[" .. lastSectionDB.name .. "]", font = G_FONT, size = FONT_SIZE_SMALL, x = pas:getPositionX() + pas:getContentSize().width / 2, y = pas:getPositionY(), color = COLOR[2]}):addTo(btn)
				-- 开启
				local pas = ui.newTTFLabel({text = CommonText[50], font = G_FONT, size = FONT_SIZE_SMALL, x = chapter:getPositionX() + chapter:getContentSize().width / 2, y = chapter:getPositionY(), color = COLOR[1]}):addTo(btn)
			end
		else
			local sectionBoxData = CombatBO.getSectionBoxData(COMBAT_TYPE_COMBAT, sectionId)
			local sectionStar = CombatMO.getSectionStar(sectionBoxData.starOwnNum, sectionBoxData.starTotal)  -- 章节根据获得的星数，评定章节的星级

			-- 显示星级
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(btn)
				starBg:setScale(0.5)
				starBg:setPosition(400 + (index - 1) * 35, 38)

				if index <= sectionStar then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			local star = ui.newTTFLabel({text = sectionBoxData.starOwnNum, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 500, y = 38, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(btn)
			star:setAnchorPoint(cc.p(0, 0.5))

			local total = ui.newTTFLabel({text = "/" .. sectionBoxData.starTotal, font = G_FONT, size = FONT_SIZE_MEDIUM, x = star:getPositionX() + star:getContentSize().width, y = star:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(btn)
			total:setAnchorPoint(cc.p(0, 0.5))

			if CombatBO.isSectionPass(COMBAT_TYPE_COMBAT, sectionId) then
				local tag = display.newSprite(IMAGE_COMMON .. "label_pass.png"):addTo(btn)
				tag:setPosition(btn:getContentSize().width - 72, btn:getContentSize().height / 2 + 63)
				btn.passTag = tag
			end

			for index = 1, #sectionBoxData.boxNeedStar do
				if not CombatBO.hasSectionBoxOpen(sectionId, index) and sectionBoxData.starOwnNum >= sectionBoxData.boxNeedStar[index] then -- 可以领取宝箱，而 没有领
					local sprite = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_close.png")
					local boxBtn = CellScaleButton.new(sprite, handler(self, self.onOpenBoxCallback))
					boxBtn:setEnabled(false)
					boxBtn:setScale(0.75)
					cell:addButton(boxBtn, 150, self.m_cellSize.height / 2 - 20)

					armature_add("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
					armature_add("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")

					local lightEffect = armature_create("ui_box_light", boxBtn:getContentSize().width / 2, boxBtn:getContentSize().height / 2)
			        lightEffect:getAnimation():playWithIndex(0)
			        boxBtn:addChild(lightEffect, -1)

					local starEffect = armature_create("ui_box_star", boxBtn:getContentSize().width / 2, boxBtn:getContentSize().height / 2)
			        starEffect:getAnimation():playWithIndex(0)
			        boxBtn:addChild(starEffect)

			        break  -- 只显示一个
				end
			end
		end

		self:showSectionUpdate(COMBAT_TYPE_COMBAT, sectionId, btn)
	elseif self.m_viewFor == SECTION_VIEW_FOR_CHALLENGE then --极限挑战
		local sectionDB = HunterMO.queryStageById(sectionId)
		-- local sectionOpen = true
		local openTimeStr = sectionDB.openTime
		local sectionOpen = HunterBO.isBountyOpen(openTimeStr)
		local sectionPicPath = IMAGE_COMMON .. "combat/" .. sectionDB.asset
		if sectionOpen == true then
			sectionPicPath = sectionPicPath .. ".jpg"
		else
			sectionPicPath = sectionPicPath .. "_close.jpg"
		end
		local sprite = display.newSprite(sectionPicPath)
		local btn = CellTouchButton.new(sprite, nil, nil, nil, handler(self, self.onChoseSectionCallback))
		btn.index = index
		btn.sectionId = sectionId
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		btn.sectionOpen = sectionOpen

		--关卡名字
		local name = ui.newTTFLabel({text = sectionDB.name, font = G_FONT, size = FONT_SIZE_BIG, x = 80, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		name:setAnchorPoint(cc.p(0, 0.5))

		--特殊敌人名字
		local armyName = ui.newTTFLabel({text = "特殊敌人："..sectionDB.bg, font = G_FONT, size = FONT_SIZE_SMALL, x = 450, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		name:setAnchorPoint(cc.p(0, 0.5))

		-- 副本可挑战次数
		local leftTime = HunterBO.getStageChanllCount(sectionId)
		local label = ui.newTTFLabel({text = "(", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width + 5, y = name:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		label:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = leftTime, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		label:setAnchorPoint(cc.p(0, 0.5))
		if leftTime >= sectionDB.count then label:setColor(COLOR[5]) end

		-- 可挑战总次数
		local label = ui.newTTFLabel({text = "/" .. sectionDB.count .. ")" .. CommonText[237][3], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		label:setAnchorPoint(cc.p(0, 0.5))

		--开放时间
		local openTimeStr = sectionDB.openTime
		local openTimeStd = HunterMO.getOpenTimeShow(openTimeStr)
		local label = ui.newTTFLabel({text = openTimeStd, font = G_FONT, size = FONT_SIZE_SMALL, x = 25, y = 25, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		label:setAnchorPoint(cc.p(0, 0))

		--可获得XXX
		-- local resData = UserMO.getResourceData(ITEM_KIND_HUANGBAO)
		local des_label = ui.newTTFLabel({text = string.format(CommonText[345][3], "珈蓝矿石"), font = G_FONT, size = FONT_SIZE_SMALL, x = 25, y = 25 + label:getContentSize().height, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		des_label:setAnchorPoint(cc.p(0, 0.5))

	else -- 探险
		local exploreSection = CombatMO.querySectionById(sectionId)

		local sprite = display.newSprite(IMAGE_COMMON .. "combat/" .. exploreSection.asset .. ".jpg")
		local btn = CellTouchButton.new(sprite, nil, nil, nil, handler(self, self.onChoseSectionCallback))
		btn.index = index
		btn.sectionId = sectionId
		btn.sectionOpen = sectionOpen
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		local name = ui.newTTFLabel({text = exploreSection.name, font = G_FONT, size = FONT_SIZE_BIG, x = 80, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		name:setAnchorPoint(cc.p(0, 0.5))

		local exploreType = CombatMO.getExploreTypeBySectionId(sectionId)

		if exploreType == EXPLORE_TYPE_EXTREME then  -- 极限探险
			local progressId = CombatMO.getCurrentExploreIdBySectionId(sectionId)
			local combatIds = CombatMO.getCombatIdsBySectionId(sectionId)
			local currentId = 0
			if progressId == 0 or progressId == 300 then -- 还没有挑战的
				currentId = combatIds[1]
			else
				local combatDB = CombatMO.queryExploreById(progressId)
				currentId = combatDB.nxtCombatId
				if currentId == 0 then  -- 挑战的是最后一关，重头开始
					currentId = combatIds[1]
				end
			end

			local function getIndex(combatId)
				for index = 1, #combatIds do if combatIds[index] == combatId then return index end end
				return 0
			end

			-- 当前进度：第x关
			local label = ui.newTTFLabel({text = CommonText[236] .. ":" .. CommonText[237][1], font = FONT_SIZE_MEDIUM, x = 400 - 16, y = 38, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))
			local progress = ui.newTTFLabel({text = getIndex(currentId), font = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			progress:setAnchorPoint(cc.p(0, 0.5))
			local label = ui.newTTFLabel({text = CommonText[237][2], font = FONT_SIZE_MEDIUM, x = progress:getPositionX() + progress:getContentSize().width, y = progress:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif exploreType == EXPLORE_TYPE_LIMIT then -- 限时
			-- 副本可挑战次数
			local leftTime = CombatBO.getExploreChallengeLeftCount(exploreType)
			local label = ui.newTTFLabel({text = "(", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width + 5, y = name:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))

			local label = ui.newTTFLabel({text = leftTime, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))
			if leftTime <= 0 then label:setColor(COLOR[5]) end

			-- 次
			local label = ui.newTTFLabel({text = "/" .. EXPLORE_FIGHT_TIME .. ")" .. CommonText[237][3], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))

			local resData = UserMO.getResourceData(ITEM_KIND_HUANGBAO)

			local des_label = ui.newTTFLabel({text = string.format(CommonText[345][3], resData.name), font = G_FONT, size = FONT_SIZE_SMALL, x = 25, y = btn:getContentSize().height / 2 - 40, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			des_label:setAnchorPoint(cc.p(0, 0.5))
			local label = ui.newTTFLabel({text = CommonText[345][4], font = G_FONT, size = FONT_SIZE_SMALL, x = 25, y = des_label:getPositionY() - 15, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))
		else -- 装备和配件
			-- 副本可挑战次数
			local leftTime = CombatBO.getExploreChallengeLeftCount(exploreType)
			local label = ui.newTTFLabel({text = "(", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width + 5, y = name:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))

			local label = ui.newTTFLabel({text = leftTime, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))
			if leftTime <= 0 then label:setColor(COLOR[5]) end

			-- 次
			local label = ui.newTTFLabel({text = "/" .. EXPLORE_FIGHT_TIME .. ")" .. CommonText[237][3], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
			label:setAnchorPoint(cc.p(0, 0.5))

			-- 描述
			local label = ui.newTTFLabel({text = CommonText[345][exploreType], font = G_FONT, size = FONT_SIZE_SMALL, x = btn:getContentSize().width - 20, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(btn)
			label:setAnchorPoint(cc.p(1, 0.5))
			if exploreType == EXPLORE_TYPE_TACTIC then
				label:setString(CommonText[4014])
			end

			local sectionBoxData = CombatBO.getSectionBoxData(COMBAT_TYPE_EXPLORE, sectionId)
			local sectionStar = CombatMO.getSectionStar(sectionBoxData.starOwnNum, sectionBoxData.starTotal)  -- 章节根据获得的星数，评定章节的星级
			
			-- 显示星级
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(btn)
				starBg:setScale(0.5)
				starBg:setPosition(400 + (index - 1) * 35, 38)

				if index <= sectionStar then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			local star = ui.newTTFLabel({text = sectionBoxData.starOwnNum, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 500, y = 38, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(btn)
			star:setAnchorPoint(cc.p(0, 0.5))

			local total = ui.newTTFLabel({text = "/" .. sectionBoxData.starTotal, font = G_FONT, size = FONT_SIZE_MEDIUM, x = star:getPositionX() + star:getContentSize().width, y = star:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(btn)
			total:setAnchorPoint(cc.p(0, 0.5))

			for index = 1, #sectionBoxData.boxNeedStar do
				if not CombatBO.hasSectionBoxOpen(sectionId, index) and sectionBoxData.starOwnNum >= sectionBoxData.boxNeedStar[index] then -- 可以领取宝箱，而没有领
					local sprite = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_close.png")
					local boxBtn = CellScaleButton.new(sprite, handler(self, self.onOpenBoxCallback))
					boxBtn:setEnabled(false)
					boxBtn:setScale(0.75)
					cell:addButton(boxBtn, 150, self.m_cellSize.height / 2 - 20)

					armature_add("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
					armature_add("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")

					local lightEffect = armature_create("ui_box_light", boxBtn:getContentSize().width / 2, boxBtn:getContentSize().height / 2)
			        lightEffect:getAnimation():playWithIndex(0)
			        boxBtn:addChild(lightEffect, -1)

					local starEffect = armature_create("ui_box_star", boxBtn:getContentSize().width / 2, boxBtn:getContentSize().height / 2)
			        starEffect:getAnimation():playWithIndex(0)
			        boxBtn:addChild(starEffect)

			        break  -- 只显示一个
				end
			end
		end
	end

	return cell
end

function CombatSectionTableView:showSectionUpdate(combatType, sectionId, sectionBtn)
	if not self.m_updateValue or (self.m_updateValue and self.m_updateValue <= 0)
		or not self.m_updateCombatType or self.m_updateCombatType ~= combatType
		or not self.m_updateCombatId then return end

	local sectionDB = CombatMO.queryCombatById(self.m_updateCombatId)
	if sectionDB.sectionId ~= sectionId then return end

	-- gprint("CombatSectionTableView ***:", self.m_updateValue, self.m_updateCombatType, self.m_updateCombatId)

	-- UiDirector.pop()

	-- -- if self.m_updateValue == 3 then
		armature_add(IMAGE_ANIMATION .. "effect/ui_section_pass.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_section_pass.plist", IMAGE_ANIMATION .. "effect/ui_section_pass.xml")
		if sectionBtn.passTag then
			sectionBtn.passTag:setVisible(false)
		end

		local armature = armature_create("ui_section_pass", sectionBtn:getContentSize().width - 130, sectionBtn:getContentSize().height / 2 - 10, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					local btn = armature.sectionBtn
					if btn.passTag then
						btn.passTag:setVisible(true)
					end
					armature:removeSelf()
				end
			end):addTo(sectionBtn)
		armature:getAnimation():playWithIndex(0)
		armature.sectionBtn = sectionBtn

	-- -- end

	self.m_updateValue = nil
	self.m_updateCombatType = nil
	self.m_updateCombatId = nil

end

function CombatSectionTableView:onChoseSectionCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_viewFor == SECTION_VIEW_FOR_COMBAT then -- 征战
		local sectionOpen = sender.sectionOpen
		local sectionId = sender.sectionId

		if not sectionOpen then return end  -- 章节不开放
		
		local sectionDB = CombatMO.querySectionById(sectionId)
		if sectionDB.rank > UserMO.getResource(ITEM_KIND_RANK) then  -- 军衔不足
			local rankDB = UserMO.queryRankById(sectionDB.rank)

			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(string.format(CommonText[493], rankDB.name), function()
					UiDirector.popMakeUiTop("HomeView")
					
					local IndicatorView = require("app.view.IndicatorView")
					local view = IndicatorView.new(HomeUpCommandConfig)
					display.getRunningScene():addChild(view, 999999999)

				end):push()
			return
		end

		ManagerSound.playSound("chapter_chose")
	
		local CombatLevelView = require("app.view.CombatLevelView")
		CombatLevelView.new(COMBAT_TYPE_COMBAT, sender.sectionId):push()
	elseif self.m_viewFor == SECTION_VIEW_FOR_EXPLORE or self.m_viewFor == SECTION_VIEW_FOR_LIMIT then -- 探险
		if self.m_viewFor == SECTION_VIEW_FOR_EXPLORE then
			local exploreType = CombatMO.getExploreTypeBySectionId(sender.sectionId)

			if UserMO.level_ < CombatMO.getExploreOpenLv(exploreType) then  -- 等级不足
				local exploreSection = CombatMO.querySectionById(sender.sectionId)
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(exploreType), exploreSection.name))
				return
			end

			if exploreType == EXPLORE_TYPE_EXTREME then
				ManagerSound.playSound("chapter_chose")

				local CombatLevelView = require("app.view.CombatExtremeView")
				CombatLevelView.new(COMBAT_TYPE_EXPLORE, sender.sectionId):push()
			else
				ManagerSound.playSound("chapter_chose")

				local CombatLevelView = require("app.view.CombatLevelView")
				CombatLevelView.new(COMBAT_TYPE_EXPLORE, sender.sectionId):push()
			end
		else
			ManagerSound.playSound("chapter_chose")

			local exploreType = CombatMO.getExploreTypeBySectionId(sender.sectionId)
			if UserMO.level_ < CombatMO.getExploreOpenLv(exploreType) then  -- 等级不足
				local exploreSection = CombatMO.querySectionById(sender.sectionId)
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(exploreType), exploreSection.name))
				return
			end

			-- if CombatBO.isLimitExploreTimeOpen() then
			if true then --永久开
				-- local CombatLevelView = require("app.view.CombatLevelView")
				-- CombatLevelView.new(COMBAT_TYPE_EXPLORE, sender.sectionId):push()

				ManagerSound.playSound("chapter_chose")
				local CombatLevelView = require("app.view.CombatExtremeView")
				CombatLevelView.new(COMBAT_TYPE_EXPLORE, sender.sectionId):push()
				return
			end

			local sectionDB = CombatMO.querySectionById(sender.sectionId)
			Toast.show(sectionDB.name .. CommonText[411]) -- 未开启
		end
	elseif self.m_viewFor == SECTION_VIEW_FOR_CHALLENGE then --极限挑战
		local sectionOpen = sender.sectionOpen --是否开放
		local sectionId = sender.sectionId

		local sectionDB = HunterMO.queryStageById(sectionId)
		local openTimeStr = sectionDB.openTime

		sectionOpen = HunterBO.isBountyOpen(openTimeStr)

		if UserMO.level_ < 70 then
			Toast.show("指挥官等级达到70级可参与")
			return
		end

		if not sectionOpen then
			Toast.show("当前副本暂未开启")
			return
		end

		local sectionDB = HunterMO.queryStageById(sectionId)
		-- 副本可挑战次数
		local leftTime = HunterBO.getStageChanllCount(sectionId)
		-- 今日已获得金币数
		local todayCoinGot = HunterBO.todayCoinGot

		local function goToCombatHunter()
			-- body
			ManagerSound.playSound("chapter_chose")
			require("app.view.CombatHunterView").new(sectionId, UI_ENTER_FADE_IN_GATE):push()
		end

		if HunterMO.combatConfirm then
			goToCombatHunter()
		else
			if todayCoinGot >= HunterMO.getBountyCoinGainedMax() then
				local HunterConfirmDialog = require("app.dialog.HunterConfirmDialog")
				HunterConfirmDialog.new("您今日获得的矿石数量已达上限，确定还要继续吗", function()
					goToCombatHunter()
				end):push()
			else
				if leftTime >= sectionDB.count then
					local tip = "您今日奖励次数已耗尽，收益将变更为原来的%d%%，确定还要继续吗"
					local offPercent = HunterMO.getBountyBenefitOffPercent()
					local HunterConfirmDialog = require("app.dialog.HunterConfirmDialog")
					HunterConfirmDialog.new(string.format(tip, offPercent), function()
						goToCombatHunter()
					end):push()
				else
					goToCombatHunter()
				end
			end
		end
	end
end

return CombatSectionTableView
