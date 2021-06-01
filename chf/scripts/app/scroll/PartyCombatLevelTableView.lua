--
-- Author: gf
-- Date: 2015-09-18 18:52:56
--
local ConfirmDialog = require("app.dialog.ConfirmDialog")

local PartyCombatLevelTableView = class("PartyCombatLevelTableView", TableView)

function PartyCombatLevelTableView:ctor(size,  sectionId)
	PartyCombatLevelTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_bounceable = false
	local bg = display.newSprite("image/bg/bg_combat_2.jpg")
	self.m_cellSize = cc.size(size.width, bg:getContentSize().height)
	self.m_sectionId = sectionId
end

function PartyCombatLevelTableView:onEnter()
	PartyCombatLevelTableView.super.onEnter(self)
end

function PartyCombatLevelTableView:reloadData()
	PartyCombatLevelTableView.super.reloadData(self)
end

function PartyCombatLevelTableView:numberOfCells()
	return 1
end

function PartyCombatLevelTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyCombatLevelTableView:createCellAtIndex(cell, index)
	PartyCombatLevelTableView.super.createCellAtIndex(self, cell, index)
	armature_add("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_add("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")

	local bg = display.newSprite("image/bg/bg_combat_2.jpg"):addTo(cell)
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

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

	local combatList_ = PartyCombatBO.getCombatList(self.m_sectionId)
	-- gdump(combatList_,"combatList_combatList_")

	for index=1,#combatList_ do
		local combatDB = combatList_[index]
		
		local posX = PARTY_COMBAT_VIEW_[index][1]
		local posY = PARTY_COMBAT_VIEW_[index][2]
		--判断是否打完
		-- gdump(combatDB,"combatDBcombatDBcombatDB")
		if combatDB.schedule == 100 then --已打完
			if combatDB.status == 1 then 
				local lightEffect = CCArmature:create("ui_box_light")
		        lightEffect:getAnimation():playWithIndex(0)
		        lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
		        lightEffect:setPosition(posX, posY + 50)
		        cell:addChild(lightEffect)
				--未领取
				local sprite = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_close.png")
				local boxBtn = CellScaleButton.new(sprite, handler(self, self.onChoseBoxCallback))
				boxBtn:setAnchorPoint(cc.p(0.5, 0))
				boxBtn.combatDB = combatDB
				boxBtn.need = combatDB.contribute
				cell:addButton(boxBtn, posX, posY)

				local starEffect = CCArmature:create("ui_box_star")
		        starEffect:getAnimation():playWithIndex(0)
		        starEffect:connectMovementEventSignal(function(movementType, movementID) end)
		        starEffect:setPosition(boxBtn:getContentSize().width / 2, boxBtn:getContentSize().height / 2)
		        boxBtn:addChild(starEffect)
			else 
				--已领取
				local openBox = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_open.png", 
					posX, posY + 50):addTo(cell)
			end
		else
			local combatBtn, isBuild = createCombatBtn(combatDB.assetData)
			combatBtn.combatDB = combatDB
			cell:addButton(combatBtn, posX, posY)

			local nameBg = display.newSprite(IMAGE_COMMON .. "info_bg_13.png"):addTo(cell)
			if isBuild then  -- 是建筑
				nameBg:setPosition(combatBtn:getPositionX(), combatBtn:getPositionY() - 18)
			else
				nameBg:setAnchorPoint(cc.p(0, 0.5))
				nameBg:setPosition(combatBtn:getPositionX() + 40, combatBtn:getPositionY() + 10)
			end

			local name = ui.newTTFLabel({text = combatDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = nameBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(nameBg)
			name:setAnchorPoint(cc.p(0, 0.5))

			--进度条
			local bar = ProgressBar.new(IMAGE_COMMON .. "bar_3.png", BAR_DIRECTION_HORIZONTAL, cc.size(100, 10), {bgName = IMAGE_COMMON .. "bar_bg_1.png", bgScale9Size = cc.size(100 + 4, 16)}):addTo(cell,100)
			bar:setPosition(combatBtn:getPositionX(), combatBtn:getPositionY() + combatBtn:getContentSize().height / 2 + 50)
			bar:setPercent((100 - combatDB.schedule) / 100)
		end
	end
	
	return cell
end

function PartyCombatLevelTableView:onChoseCombatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- gdump(sender.combatDB,"combatDB")
	--判断挑战次数
	if PartyCombatMO.combatCount_ == 0 then
		Toast.show(CommonText[693])
		return
	end
	PartyCombatBO.asynPtcForm(function(combatDB)
			local CombatFightDialog = require("app.dialog.CombatFightDialog")
			local dialog = CombatFightDialog.new(COMBAT_TYPE_PARTY_COMBAT, sender.combatDB.combatId):push()
		end,sender.combatDB)
end

function PartyCombatLevelTableView:onChoseBoxCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	function doChoseBox()
		--判断贡献
		if PartyMO.myDonate_ < sender.need then
			Toast.show(CommonText[657])
			return
		end
		Loading.getInstance():show()
		PartyCombatBO.asynPartyctAward(function()
			Loading.getInstance():unshow()
			end,sender.combatDB,sender.need)
	end
	if sender.need > 0 then
		ConfirmDialog.new(string.format(CommonText[749],sender.need), function()
			doChoseBox()
		end):push()
	else
		doChoseBox()
	end
end

function PartyCombatLevelTableView:onExit()
	PartyCombatLevelTableView.super.onExit(self)
	armature_remove("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_remove("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")
end

return PartyCombatLevelTableView
