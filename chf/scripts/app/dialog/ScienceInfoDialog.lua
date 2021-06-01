--
-- Author: gf
-- Date: 2015-08-28 15:32:59
-- 科技详情弹出框

local Dialog = require("app.dialog.Dialog")
local ScienceInfoDialog = class("ScienceInfoDialog", Dialog)

function ScienceInfoDialog:ctor(data)
	ScienceInfoDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 716)})

	self.scienceData = data
end

function ScienceInfoDialog:onEnter(data)
	ScienceInfoDialog.super.onEnter(self)
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)
	self:showUI()
end

function ScienceInfoDialog:showUI()
	local valueColor = COLOR[3]

	local view = UiUtil.createItemView(ITEM_KIND_SCIENCE,self.scienceData.scienceId):addTo(self:getBg())
	view:setAnchorPoint(cc.p(0.5, 0))
	view:setPosition(112, self:getBg():getContentSize().height - 150)

	local scienceInfo = ScienceMO.queryScience(self.scienceData.scienceId)
	-- 名称
	local name = ui.newTTFLabel({text = scienceInfo.refineName .. "  LV." .. self.scienceData.scienceLv, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 190, y = self:getBg():getContentSize().height - 76, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local canUpGrade = ScienceBO.canUpGrade(self.scienceData.scienceId,self.scienceData.scienceLv + 1)
	if canUpGrade ~= 3 then
		local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 190, self:getBg():getContentSize().height - 126):addTo(self:getBg())
		clock:setAnchorPoint(cc.p(0, 0.5))

		local timeValue = FormulaBO.scienceUpTime(self.scienceData.scienceId, self.scienceData.scienceLv + 1)
		-- if ActivityBO.isValid(ACTIVITY_ID_SCIENCE_SPEED) then --如果有科技加速活动
		-- 	local activity = ActivityMO.getActivityById(ACTIVITY_ID_SCIENCE_SPEED)
		-- 	local refitInfo =  ScienceMO.getTechSellInfo(activity.awardId)
		-- 	local upIds = json.decode(refitInfo.techId)
		-- 	for index=1,#upIds do
		-- 		if upIds[index] == self.scienceData.scienceId then
		-- 			timeValue = timeValue - timeValue * (refitInfo.time / 100)
		-- 		end
		-- 	end
		-- end

		local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(math.ceil(timeValue)), font = "fnt/num_2.fnt"}):addTo(self:getBg())
		time:setAnchorPoint(cc.p(0, 0.5))
		time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
	end

	local desc = ui.newTTFLabel({text = scienceInfo.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 70, y = self:getBg():getContentSize().height - 172, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))

	
	local resBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_60.png"):addTo(self:getBg())
	resBg:setPreferredSize(cc.size(468, 490))
	resBg:setCapInsets(cc.rect(80, 60, 1, 1))
	resBg:setPosition(self:getBg():getContentSize().width / 2, resBg:getContentSize().height / 2 + 30)

	-- 类别
	local title = ui.newTTFLabel({text = CommonText[61], font = G_FONT, size = FONT_SIZE_SMALL, x = 140, y = resBg:getContentSize().height - 26, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 需求
	local title = ui.newTTFLabel({text = CommonText[62], font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 当前拥有
	local title = ui.newTTFLabel({text = CommonText[63], font = G_FONT, size = FONT_SIZE_SMALL, x = 370, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
		
	if canUpGrade ~= 3 then

		local needRes = ScienceBO.getScienceUpNeedRes(self.scienceData)
		-- gdump(needRes,"升级所需needRes")

		for i=1,#needRes do
			local posY = 390 - (i - 1) * 80
			local need = needRes[i]
			local view

			local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(resBg)
		   	line:setPreferredSize(cc.size(440, line:getContentSize().height))
		   	line:setPosition(resBg:getContentSize().width / 2, posY + 40)

			if need.kind == ITEM_KIND_BUILD then
				view = UiUtil.createItemView(ITEM_KIND_BUILD, need.type):addTo(resBg)
				view:setScale(0.65)
				view:setPosition(74, posY)
				-- 类别名称
				local commandBuild = BuildMO.queryBuildById(need.type)
				local name = ui.newTTFLabel({text = commandBuild.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

				-- 需求等级
				local level = ui.newTTFLabel({text = "LV." .. need.value, font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

				-- 当前等级
				local curLv = ui.newTTFLabel({text = "LV." .. BuildMO.getBuildLevel(need.type), font = G_FONT, size = FONT_SIZE_SMALL, x = 370, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
				curLv:setAnchorPoint(cc.p(0, 0.5))

				if need.value <= BuildMO.getBuildLevel(need.type) then -- 等级足够
					local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 330, posY):addTo(resBg)
				else
					local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 330, posY):addTo(resBg)
				end
			elseif need.kind == ITEM_KIND_FAME then
				local resData = UserMO.getResourceData(ITEM_KIND_FAME)
				
				view = UiUtil.createItemView(need.kind):addTo(resBg)
				view:setScale(0.65)
				view:setPosition(74, posY)
				local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = posY, align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

				-- 需求等级
				local level = ui.newTTFLabel({text = "LV." .. need.value, font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

				-- 当前等级
				local curLv = ui.newTTFLabel({text = "LV." .. UserMO.fameLevel_, font = G_FONT, size = FONT_SIZE_SMALL, x = 370, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
				curLv:setAnchorPoint(cc.p(0, 0.5))

				if need.value <= UserMO.fameLevel_ then -- 足够
					local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 330, posY):addTo(resBg)

					name:setColor(COLOR[11])
				else -- 不足够
					conditionEnough = false -- 条件不够

					local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 330, posY):addTo(resBg)

					name:setColor(COLOR[6])
				end
			else
				view = UiUtil.createItemView(need.kind, need.id):addTo(resBg)
				view:setScale(0.65)
				view:setPosition(74, posY)

				-- 类别
				local resData = UserMO.getResourceData(need.kind, need.id)
				local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = posY, align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
				
				
				local count = UserMO.getResource(need.kind, need.id)

				local finalNeed
				if ActivityBO.scienceIsDis(self.scienceData.scienceId) then
					finalNeed = need.value * ACTIVITY_ID_SCIENCE_DIS_RES_RATE
				else
					finalNeed = need.value
				end

				if ActivityBO.isValid(ACTIVITY_ID_SCIENCE_SPEED) then --如果有科技加速活动
					local activity = ActivityMO.getActivityById(ACTIVITY_ID_SCIENCE_SPEED)
					local refitInfo =  ScienceMO.getTechSellInfo(activity.awardId)
					local upIds = json.decode(refitInfo.techId)
					for index=1,#upIds do
						if upIds[index] == self.scienceData.scienceId then
							finalNeed = finalNeed - finalNeed * (refitInfo.resource / 100)
						end
					end
				end
				-- 需求
				local labelN = ui.newTTFLabel({text = UiUtil.strNumSimplify(finalNeed), font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = posY, align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

				-- 当前拥有
				local labelC = ui.newBMFontLabel({text = UiUtil.strNumSimplify(count), font = "fnt/num_1.fnt", x = 370, y = posY}):addTo(resBg)
				labelC:setAnchorPoint(cc.p(0, 0.5))

				if finalNeed <= count then -- 足够
					local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 330, posY):addTo(resBg)

					name:setColor(COLOR[11])
					labelN:setColor(COLOR[11])
				else -- 不足够
					conditionEnough = false -- 条件不够

					local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 330, posY):addTo(resBg)

					name:setColor(COLOR[6])
					labelN:setColor(COLOR[6])
				end
			end
		end

	else
		local desc = ui.newTTFLabel({text = CommonText[958][1], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2, y = 390, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	end
end

function ScienceInfoDialog:onExit()
	ScienceInfoDialog.super.onExit(self)
end

return ScienceInfoDialog
