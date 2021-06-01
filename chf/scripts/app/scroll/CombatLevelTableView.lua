
-- 展示所有小关卡的view

local CombatLevelTableView = class("CombatLevelTableView", TableView)

function CombatLevelTableView:ctor(size, combatType, sectionId)
	CombatLevelTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_bounceable = false

	local bg = nil
	if combatType == COMBAT_TYPE_EXPLORE then
		local exploreType = CombatMO.getExploreTypeBySectionId(sectionId)
		if exploreType == EXPLORE_TYPE_LIMIT then
			bg = display.newSprite("image/bg/bg_combat_3.jpg")
		else
			bg = display.newSprite("image/bg/bg_combat_1.jpg")
		end
	else
		bg = display.newSprite("image/bg/bg_combat_1.jpg")
	end

	self.m_cellSize = cc.size(size.width, bg:getContentSize().height)
	self.m_combatType = combatType
	self.m_sectionId = sectionId

	-- 关卡发生了更新的数据
	self.m_updateValue = nil
	self.m_updateCombatType = nil
	self.m_updateCombatId = nil
end

function CombatLevelTableView:reloadData(updateValue, updateCombatType, updateCombatId)
	self.m_canFightCombatId = CombatBO.getSectionCanFightMaxCombatId(self.m_combatType, self.m_sectionId)
	gprint("[CombatLevelTableView] value:", updateValue, "type:", self.m_combatType, "sectionId:", self.m_sectionId, "combatId:", updateCombatId, "maxFightCombatId:", self.m_canFightCombatId)

	self.m_updateValue = updateValue
	self.m_updateCombatType = updateCombatType
	self.m_updateCombatId = updateCombatId

	CombatLevelTableView.super.reloadData(self)
end

function CombatLevelTableView:numberOfCells()
	return 1
end

function CombatLevelTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function CombatLevelTableView:createCellAtIndex(cell, index)
	CombatLevelTableView.super.createCellAtIndex(self, cell, index)

	local bg = nil
	if self.m_combatType == COMBAT_TYPE_EXPLORE then
		local exploreType = CombatMO.getExploreTypeBySectionId(self.m_sectionId)
		if exploreType == EXPLORE_TYPE_LIMIT then
			bg = display.newSprite("image/bg/bg_combat_3.jpg")
		else
			bg = display.newSprite("image/bg/bg_combat_1.jpg")
		end
	else
		if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
			bg = display.newSprite("image/bg/bg_combat_1.jpg")
		else
			local sectionDB = CombatMO.querySectionById(self.m_sectionId)
			if sectionDB and sectionDB.bg and sectionDB.bg ~= "" then
				bg = display.newSprite("image/bg/" .. sectionDB.bg .. ".jpg")
			else
				bg = display.newSprite("image/bg/bg_combat_1.jpg")
			end
		end
	end

	if bg then
		bg:addTo(cell)
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	end

	local function createCombatBtn(assetData)
		local assetData = json.decode(assetData)
		local tankId = assetData[1][1]
		local buildId = assetData[1][2]
		local tankCount = assetData[1][3] or 0
		local isBuild = false

		if buildId and buildId > 0 then isBuild = true end

		local sprite = nil
		if isBuild then
			sprite = display.newSprite("image/build/build_" .. buildId .. ".png")
		else
			sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tankId)
			sprite:setScale(1)
		end

		local combatBtn = CellScaleButton.new(sprite, handler(self, self.onChoseCombatCallback))
		combatBtn:setAnchorPoint(cc.p(0.5, 0))
		combatBtn:setScale(0.9)

		if isBuild and tankId > 0 and tankCount > 0 then  -- 是建筑
			for index = 1, tankCount do -- 显示坦克
				local itemView = UiUtil.createItemSprite(ITEM_KIND_TANK, tankId):addTo(combatBtn, tankCount - index + 1)
				itemView:setScale(0.75)
				itemView:setPosition(combatBtn:getContentSize().width / 2 + 80 - (index - 1) * 40, combatBtn:getContentSize().height / 2 - 30 - (index - 1) * 10)
			end
		end
		return combatBtn, isBuild
	end

	local function createStar(nameBg, starNum)
		local stars = {}
		for index = 1, 3 do
			local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(nameBg)
			starBg:setPosition(nameBg:getContentSize().width / 2 + (index - 2) * 30 , -13)
			starBg:setScale(0.5)

			if index <= starNum then
				local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
				star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				star.index = index
				stars[index] = star
			end
		end
		return stars
	end

	local function createChose(combatBtn, isBuild)
		if isBuild then -- 是建筑
			armature_add("animation/effect/ui_combat_chose_build.pvr.ccz", "animation/effect/ui_combat_chose_build.plist", "animation/effect/ui_combat_chose_build.xml")
			local armature = armature_create("ui_combat_chose_build"):addTo(combatBtn, -1)
			armature:setPosition(combatBtn:getContentSize().width / 2, armature:getContentSize().height / 2)
			armature:setScale(1.1)
			armature:getAnimation():playWithIndex(0)
		else
			local chose = nil
			chose = display.newSprite(IMAGE_COMMON .. "chose_2.png"):addTo(combatBtn, -1)
			chose:setPosition(combatBtn:getContentSize().width / 2, combatBtn:getContentSize().height / 2)
			chose:setScale(0.6)
			chose:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(3, 0.8), cc.ScaleTo:create(3, 0.6)})))
		end

		local indicate = display.newSprite(IMAGE_COMMON .. "chose_4.png"):addTo(combatBtn, 2)
		indicate:setPosition(combatBtn:getContentSize().width / 2, combatBtn:getContentSize().height + 20)
		indicate:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(3, cc.p(0, 30)), cc.MoveBy:create(3, cc.p(0, -30))})))
	end

	local combatIds = CombatMO.getCombatIdsBySectionId(self.m_sectionId)
	if self.m_combatType == COMBAT_TYPE_COMBAT then  -- 普通副本
		for btnIndex = 1, #combatIds do
			local combatId = combatIds[btnIndex]
			local combatView = CombatMO.getCombatViewById(self.m_combatType, combatId)

			if combatView then
				local combatDB = CombatMO.queryCombatById(combatId)
				local combatBtn, isBuild = createCombatBtn(combatDB.assetData)
				combatBtn.combatId = combatId

				cell:addButton(combatBtn, combatView.offset[1], combatView.offset[2])

				local nameBg = display.newSprite(IMAGE_COMMON .. "info_bg_13.png"):addTo(cell)
				if isBuild then  -- 是建筑
					nameBg:setPosition(combatBtn:getPositionX(), combatBtn:getPositionY() - 18)
				else
					nameBg:setAnchorPoint(cc.p(0, 0.5))
					nameBg:setPosition(combatBtn:getPositionX() + 40, combatBtn:getPositionY() + 10)
				end

				local name = ui.newTTFLabel({text = combatDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = nameBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(nameBg)
				name:setAnchorPoint(cc.p(0, 0.5))

				if combatId <= CombatMO.currentCombatId_ then
				-- if combatId < self.m_canFightCombatId then -- 已经打过了
					local starNum = 0
					local combat = CombatMO.getCombatById(combatId)
					if combat then starNum = combat.star end
					combatBtn.stars = createStar(nameBg, starNum)
				elseif combatId == self.m_canFightCombatId then -- 正在打的进度
					createChose(combatBtn, isBuild)
				else  -- 还不能打
					combatBtn:setVisible(false)
					nameBg:setVisible(false)
				end

				self:showCombatUpdate(combatId, combatBtn)
			end
		end
	elseif self.m_combatType == COMBAT_TYPE_EXPLORE then  -- 探险副本
		for btnIndex = 1, #combatIds do
			local combatId = combatIds[btnIndex]
			local combatView = CombatMO.getCombatViewById(self.m_combatType, combatId)
			if combatView then
				local combatDB = CombatMO.queryExploreById(combatId)
				-- gdump(combatDB, "[CombatLevelTableView] createCombatBtn")

				local combatBtn, isBuild = createCombatBtn(combatDB.assetData)
				combatBtn.combatId = combatId
				cell:addButton(combatBtn, combatView.offset[1], combatView.offset[2])

				local nameBg = display.newSprite(IMAGE_COMMON .. "info_bg_13.png"):addTo(cell)
				if isBuild then  -- 是建筑
					nameBg:setPosition(combatBtn:getPositionX(), combatBtn:getPositionY() - 18)
				else
					nameBg:setAnchorPoint(cc.p(0, 0.5))
					nameBg:setPosition(combatBtn:getPositionX() + 40, combatBtn:getPositionY() + 10)
				end

				local name = ui.newTTFLabel({text = combatDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = nameBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(nameBg)
				name:setAnchorPoint(cc.p(0, 0.5))

				if combatId < self.m_canFightCombatId then -- 已经打过了
					local starNum = 0
					local combat = CombatMO.getExploreById(combatId)
					if combat then starNum = combat.star end
					combatBtn.stars = createStar(nameBg, starNum)
				elseif combatId == self.m_canFightCombatId then -- 正在打的进度
					local combat = CombatMO.getExploreById(combatId)
					if combat and combat.star > 0 then  -- 最后一关，并且已经打了
						combatBtn.stars = createStar(nameBg, combat.star)
					end
					createChose(combatBtn, isBuild)
				else
					combatBtn:setVisible(false)
					nameBg:setVisible(false)
				end

				self:showCombatUpdate(combatId, combatBtn)
			end
		end
	end

	return cell
end

function CombatLevelTableView:showCombatUpdate(combatId, combatBtn)
	if not combatBtn.stars then return end

	if not self.m_updateValue or (self.m_updateValue and self.m_updateValue <= 0)
		or not self.m_updateCombatType or (self.m_updateCombatType and self.m_updateCombatType ~= self.m_combatType)
		or not self.m_updateCombatId or (self.m_updateCombatId and self.m_updateCombatId ~= combatId) then return end

	if self.m_updateValue == 1 or self.m_updateValue == 2 or self.m_updateValue == 4 then
		armature_add(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")

		for index = 1, #combatBtn.stars do
			local star = combatBtn.stars[index]
			star:stopAllActions()
			star:setVisible(false)
			star:runAction(transition.sequence({
				cc.DelayTime:create(0.4 + index * 0.2),
				cc.CallFuncN:create(function(sender)
						if sender.index == 1 then sender:setPosition(sender:getPositionX() - 80, sender:getPositionY() + 70) end
						if sender.index == 2 then sender:setPosition(sender:getPositionX(), sender:getPositionY() + 70) end
						if sender.index == 3 then sender:setPosition(sender:getPositionX() + 80, sender:getPositionY() + 70) end
						sender:setVisible(true)
					end),
				cc.MoveTo:create(0.2, cc.p(star:getParent():getContentSize().width / 2, star:getParent():getContentSize().height / 2)),
				cc.CallFuncN:create(function(sender)
						ManagerSound.playSound("balance_star")

						local armature = armature_create("ui_flash", sender:getContentSize().width / 2, sender:getContentSize().height / 2, function (movementType, movementID, armature) end)
						armature:getAnimation():playWithIndex(0)
						armature:addTo(sender)
					end),
				}))
		end
	else
		gprint("CombatLevelTableView:showCombatUpdate Error!!!!:", self.m_updateValue)
	end
	self.m_updateValue = nil
	self.m_updateCombatType = nil
	self.m_updateCombatId = nil
end

function CombatLevelTableView:onChoseCombatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local combatId = sender.combatId

	CombatMO.curBattleNeedShowBalance_ = false
	CombatMO.curChoseBattleType_ = self.m_combatType
	CombatMO.curChoseBtttleId_ = combatId
	CombatMO.curBattleCombatUpdate_ = 0

	-- print("index:", sender.index)
	if self.m_combatType == COMBAT_TYPE_COMBAT then
		local combatDB = CombatMO.queryCombatById(combatId)
		if combatDB.sectionId == 101 then  -- 普通副本第一章没有打过，则跳过选阵型，直接打
			local combat = CombatMO.getCombatById(combatId)
			if not combat or combat.star <= 0 then
				NewerBO.doCombat(combatId)
				return
			end
		end
	end

	if self.m_combatType == COMBAT_TYPE_EXPLORE then
		local combatDB = CombatMO.queryExploreById(sender.combatId)
		if CombatBO.getExploreChallengeLeftCount(combatDB.type) <= 0 then  -- 没有挑战次数了
			local exploreType = CombatMO.getExploreTypeBySectionId(self.m_sectionId)
			if exploreType == EXPLORE_TYPE_LIMIT then -- 显示副本不可购买挑战次数
				Toast.show(CommonText[242])  -- 今日挑战次数已完成，请下次挑战
			else
				self:dispatchEvent({name = "BUY_COMBAT_EVENT"})
			end
			return
		end
	end

	local CombatFightDialog = require("app.dialog.CombatFightDialog")
	local dialog = CombatFightDialog.new(self.m_combatType, sender.combatId):push()
end

function CombatLevelTableView:onExit()
	CombatLevelTableView.super.onExit(self)
	armature_remove("animation/effect/ui_combat_chose_build.pvr.ccz", "animation/effect/ui_combat_chose_build.plist", "animation/effect/ui_combat_chose_build.xml")
	armature_remove("animation/effect/ui_flash.pvr.ccz", "animation/effect/ui_flash.plist", "animation/effect/ui_flash.xml")
end

return CombatLevelTableView
