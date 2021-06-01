
local Dialog = require("app.dialog.Dialog")
local DetailBuildDialog = class("DetailBuildDialog", Dialog)

require("app.text.DetailText")

function DetailBuildDialog:ctor(buildingId, wildPos)
	DetailBuildDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 550)})

	self.m_buildingId = buildingId
	self.m_wildPos = wildPos
end

function DetailBuildDialog:onEnter(data)
	DetailBuildDialog.super.onEnter(self)
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)
	self:showUI()
end

local itemKind = {RESOURCE_ID_IRON, RESOURCE_ID_OIL, RESOURCE_ID_COPPER} -- 铁、石油、铜

function DetailBuildDialog:showUI()
	if self.m_wildPos and self.m_wildPos > 0 then -- 城外的
		self.m_buildLv = BuildMO.getWildLevel(self.m_wildPos)
	else
		self.m_buildLv = BuildMO.getBuildLevel(self.m_buildingId)
	end

	local buildDB = BuildMO.queryBuildById(self.m_buildingId)
	local name = ui.newTTFLabel({text = buildDB.name .. " LV." .. self.m_buildLv, font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER,
		x = 40, y = self:getBg():getContentSize().height - 54}):addTo(self:getBg(), 4)
	name:setAnchorPoint(cc.p(0, 0.5))

	local maxLevel = BuildMO.queryBuildMaxLevel(self.m_buildingId)
	if self.m_buildLv < maxLevel then  -- 还可以升级
		local nxtBuildLevel = BuildMO.queryBuildLevel(self.m_buildingId, self.m_buildLv + 1, self.m_wildPos and self.m_wildPos > 0)
		self.m_nxtBuildLevel = nxtBuildLevel

		local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 300, name:getPositionY()):addTo(self:getBg())
		clock:setAnchorPoint(cc.p(0, 0.5))
		local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(FormulaBO.buildingUpTime(nxtBuildLevel.upTime, self.m_buildingId)), font = "fnt/num_2.fnt"}):addTo(self:getBg())
		time:setAnchorPoint(cc.p(0, 0.5))
		time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
	end

	local buildingId = self.m_buildingId

	if buildingId == BUILD_ID_COMMAND then -- 司令部
		local buildLevel = BuildMO.queryBuildLevel(buildingId, self.m_buildLv)

		-- 每小时可生产资源
		local label = ui.newTTFLabel({text = CommonText[331], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = buildLevel.stoneOut, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

		-- 提供每种资源容量
		local label = ui.newTTFLabel({text = CommonText[332], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = buildLevel.stoneMax, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))
	elseif buildingId == BUILD_ID_SCIENCE then  -- 科技馆
		-- 提高科技研发速度
		local label = ui.newTTFLabel({text = CommonText[333][3], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))
	elseif buildingId == BUILD_ID_WAREHOUSE_A or buildingId == BUILD_ID_WAREHOUSE_B then
		-- 提高所有资源容量，并保护这部分不被掠夺
		local label = ui.newTTFLabel({text = CommonText[335][1], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local buildLevel = BuildMO.queryBuildLevel(buildingId, self.m_buildLv)
		local value = ui.newTTFLabel({text = buildLevel.stoneMax, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

	elseif buildingId == BUILD_ID_CHARIOT_A or buildingId == BUILD_ID_CHARIOT_B then
		-- 作战单位生产速度
		local label = ui.newTTFLabel({text = CommonText[336][3], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

	elseif buildingId == BUILD_ID_REFIT then -- 改装工厂
		-- 改装速度
		local label = ui.newTTFLabel({text = CommonText[337][3], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

	elseif buildingId == BUILD_ID_COPPER or buildingId == BUILD_ID_IRON or buildingId == BUILD_ID_OIL
		or buildingId == BUILD_ID_STONE or buildingId == BUILD_ID_SILICON then -- 铜厂
		local data = {}
		if buildingId == BUILD_ID_COPPER then
			data.id = RESOURCE_ID_COPPER
			data.param1 = "copperMax"
			data.param2 = "copperOut"
		elseif buildingId == BUILD_ID_IRON then
			data.id = RESOURCE_ID_IRON
			data.param1 = "ironMax"
			data.param2 = "ironOut"
		elseif buildingId == BUILD_ID_OIL then
			data.id = RESOURCE_ID_OIL
			data.param1 = "oilMax"
			data.param2 = "oilOut"
		elseif buildingId == BUILD_ID_STONE then
			data.id = RESOURCE_ID_STONE
			data.param1 = "stoneMax"
			data.param2 = "stoneOut"
		elseif buildingId == BUILD_ID_SILICON then
			data.id = RESOURCE_ID_SILICON
			data.param1 = "siliconMax"
			data.param2 = "siliconOut"
		end

		local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, data.id)
		-- 每小时可生产
		local label = ui.newTTFLabel({text = CommonText[338][1] .. resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local buildLevel = BuildMO.queryBuildLevel(buildingId, self.m_buildLv)
		local value = ui.newTTFLabel({text = buildLevel[data.param2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

		-- 提供每种资源容量
		local label = ui.newTTFLabel({text = CommonText[338][2] .. resData.name2 .. CommonText[338][3], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = buildLevel[data.param1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.4))

	elseif buildingId == BUILD_ID_MATERIAL_WORKSHOP then
		-- 可生产材料
		local descTab = {CommonText[1718][1],CommonText[1718][2],CommonText[1718][3],CommonText[1718][4]}

		local label = ui.newTTFLabel({text = descTab[self.m_buildLv], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[self.m_buildLv + 1]}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		if buildDB.pros > 0 then
			local resData = UserMO.getResourceData(ITEM_KIND_PROSPEROUS)
			-- 每级xxx可增加
			local label = ui.newTTFLabel({text = string.format(CommonText[77], buildDB.name), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))
			-- xx点
			local value = ui.newTTFLabel({text = buildDB.pros .. CommonText[83], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[3]}):addTo(self:getBg())
			value:setAnchorPoint(cc.p(0, 0.5))
			-- 繁荣度
			local pros = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
			pros:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	if buildDB.pros > 0 and buildingId ~= BUILD_ID_MATERIAL_WORKSHOP then
		local buildFlourishStr = DetailText.formatDetailText(DetailText.buildflourishDetail, buildDB.pros, buildDB.pros2)
		local labelFlourish = RichLabel.new(buildFlourishStr[1], cc.size(0, 0)):addTo(self:getBg())
		labelFlourish:setPosition(name:getPositionX(), name:getPositionY() - 68)
	end

	if self.m_buildLv >= maxLevel then return end

	-- 升级资源信息
	local resBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_60.png"):addTo(self:getBg())
	resBg:setCapInsets(cc.rect(80, 60, 1, 1))
	if self.m_buildingId == BUILD_ID_COMMAND then -- 司令部
		resBg:setPreferredSize(cc.size(468, 312))
		resBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 170 - resBg:getContentSize().height / 2)
	else
		resBg:setPreferredSize(cc.size(468, 372))
		resBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 150 - resBg:getContentSize().height / 2)
	end

	-- 类别
	local title = ui.newTTFLabel({text = CommonText[61], font = G_FONT, size = FONT_SIZE_SMALL, x = 140, y = resBg:getContentSize().height - 26, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 需求
	local title = ui.newTTFLabel({text = CommonText[62], font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 当前拥有
	local title = ui.newTTFLabel({text = CommonText[63], font = G_FONT, size = FONT_SIZE_SMALL, x = 370, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	
	local start = 0

	if self.m_buildingId == BUILD_ID_COMMAND then start = 1 end

	for index = start, 3 do
		local posY = 12 + (3 - index + 0.5) * 80

		local view = nil
		if index == 0 then view = UiUtil.createItemView(ITEM_KIND_BUILD, BUILD_ID_COMMAND):addTo(resBg) -- 建造升级需要司令部
		else view = UiUtil.createItemView(ITEM_KIND_RESOURCE, itemKind[index]):addTo(resBg) end

		view:setScale(0.65)
		view:setPosition(74, posY)

		if index == 0 then -- 建造升级需要司令部
			-- 类别名称
			local commandBuild = BuildMO.queryBuildById(BUILD_ID_COMMAND)
			local name = ui.newTTFLabel({text = commandBuild.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 140, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

			-- 需求等级
			local level = ui.newTTFLabel({text = "LV." .. self.m_nxtBuildLevel.commandLv, font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

			-- 当前等级
			local curLv = ui.newTTFLabel({text = "LV." .. BuildMO.getBuildLevel(BUILD_ID_COMMAND), font = G_FONT, size = FONT_SIZE_SMALL, x = 360, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
			curLv:setAnchorPoint(cc.p(0, 0.5))

			if self.m_nxtBuildLevel.commandLv <= BuildMO.getBuildLevel(BUILD_ID_COMMAND) then -- 等级足够
				local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 330, posY):addTo(resBg)
			else
				local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 330, posY):addTo(resBg)
			end
		else
			-- 类别
			local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, itemKind[index])
			local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 140, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
			
			local need = 0
			local count = UserMO.getResource(ITEM_KIND_RESOURCE, itemKind[index])

			if index == 1 then need = self.m_nxtBuildLevel.ironCost -- 铁
			elseif index == 2 then need = self.m_nxtBuildLevel.oilCost
			elseif index == 3 then need = self.m_nxtBuildLevel.copperCost
			end

			if ActivityBO.isValid(ACTIVITY_ID_BUILD_SPEED) then --如果有建筑加速活动
				local activity = ActivityMO.getActivityById(ACTIVITY_ID_BUILD_SPEED)
				local refitInfo =  BuildMO.getBuildSellInfo(activity.awardId)
				local upIds = json.decode(refitInfo.buildingId)
				for index=1,#upIds do
					if upIds[index] == buildingId then
						need = math.floor(need - need * (refitInfo.resource / 100))
					end
				end
			end

			-- 需求
			local labelN = ui.newTTFLabel({text = UiUtil.strNumSimplify(need), font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

			-- 当前拥有
			local labelC = ui.newBMFontLabel({text = UiUtil.strNumSimplify(count), font = "fnt/num_1.fnt", x = 360, y = posY}):addTo(resBg)
			labelC:setAnchorPoint(cc.p(0, 0.5))
			labelC:setScale(0.9)

			if need <= count then -- 足够
				local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 330, posY):addTo(resBg)

				name:setColor(COLOR[11])
				labelN:setColor(COLOR[11])
			else -- 不足够
				local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 330, posY):addTo(resBg)

				name:setColor(COLOR[6])
				labelN:setColor(COLOR[6])
			end
		end

		if index ~= start then -- 两行之间的横线
			local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(resBg)
			line:setPreferredSize(cc.size(440, line:getContentSize().height))
			line:setPosition(resBg:getContentSize().width / 2, posY + 40)
		end
	end


	-- local needRes = ScienceBO.getScienceUpNeedRes(self.scienceData)
	-- -- gdump(needRes,"升级所需needRes")

	-- for i=1,#needRes do
	-- 	local posY = 390 - (i - 1) * 80
	-- 	local need = needRes[i]
	-- 	local view

	-- 	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(resBg)
	--    	line:setPreferredSize(cc.size(440, line:getContentSize().height))
	--    	line:setPosition(resBg:getContentSize().width / 2, posY + 40)

	-- 	if need.kind == ITEM_KIND_BUILD then
	-- 		view = UiUtil.createItemView(ITEM_KIND_BUILD, need.type):addTo(resBg)
	-- 		view:setScale(0.65)
	-- 		view:setPosition(74, posY)
	-- 		-- 类别名称
	-- 		local commandBuild = BuildMO.queryBuildById(need.type)
	-- 		local name = ui.newTTFLabel({text = commandBuild.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	-- 		-- 需求等级
	-- 		local level = ui.newTTFLabel({text = "LV." .. need.value, font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	-- 		-- 当前等级
	-- 		local curLv = ui.newTTFLabel({text = "LV." .. BuildMO.getBuildLevel(need.type), font = G_FONT, size = FONT_SIZE_SMALL, x = 370, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 		curLv:setAnchorPoint(cc.p(0, 0.5))

	-- 		if need.value <= BuildMO.getBuildLevel(need.type) then -- 等级足够
	-- 			local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 330, posY):addTo(resBg)
	-- 		else
	-- 			local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 330, posY):addTo(resBg)
	-- 		end
	-- 	elseif need.kind == ITEM_KIND_FAME then
	-- 		local resData = UserMO.getResourceData(ITEM_KIND_FAME)
			
	-- 		view = UiUtil.createItemView(need.kind):addTo(resBg)
	-- 		view:setScale(0.65)
	-- 		view:setPosition(74, posY)
	-- 		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = posY, align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	-- 		-- 需求等级
	-- 		local level = ui.newTTFLabel({text = "LV." .. need.value, font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	-- 		-- 当前等级
	-- 		local curLv = ui.newTTFLabel({text = "LV." .. UserMO.fameLevel_, font = G_FONT, size = FONT_SIZE_SMALL, x = 370, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 		curLv:setAnchorPoint(cc.p(0, 0.5))

	-- 		if need.value <= UserMO.fameLevel_ then -- 足够
	-- 			local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 330, posY):addTo(resBg)

	-- 			name:setColor(COLOR[11])
	-- 		else -- 不足够
	-- 			conditionEnough = false -- 条件不够

	-- 			local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 330, posY):addTo(resBg)

	-- 			name:setColor(COLOR[6])
	-- 		end
	-- 	else
	-- 		view = UiUtil.createItemView(need.kind, need.id):addTo(resBg)
	-- 		view:setScale(0.65)
	-- 		view:setPosition(74, posY)

	-- 		-- 类别
	-- 		local resData = UserMO.getResourceData(need.kind, need.id)
	-- 		local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = posY, align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
			
			
	-- 		local count = UserMO.getResource(need.kind, need.id)

	-- 		-- 需求
	-- 		local labelN = ui.newTTFLabel({text = UiUtil.strNumSimplify(need.value), font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = posY, align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	-- 		-- 当前拥有
	-- 		local labelC = ui.newBMFontLabel({text = UiUtil.strNumSimplify(count), font = "fnt/num_1.fnt", x = 370, y = posY}):addTo(resBg)
	-- 		labelC:setAnchorPoint(cc.p(0, 0.5))

	-- 		if need.value <= count then -- 足够
	-- 			local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 330, posY):addTo(resBg)

	-- 			name:setColor(COLOR[11])
	-- 			labelN:setColor(COLOR[11])
	-- 		else -- 不足够
	-- 			conditionEnough = false -- 条件不够

	-- 			local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 330, posY):addTo(resBg)

	-- 			name:setColor(COLOR[6])
	-- 			labelN:setColor(COLOR[6])
	-- 		end
	-- 	end
	-- end

end

return DetailBuildDialog
