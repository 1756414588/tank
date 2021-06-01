--
-- Author: gf
-- Date: 2015-09-18 16:08:05
--

local PartyCombatSectionTableView = class("PartyCombatSectionTableView", TableView)

function PartyCombatSectionTableView:ctor(size)
	PartyCombatSectionTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 204)
end

function PartyCombatSectionTableView:onEnter()
	PartyCombatSectionTableView.super.onEnter(self)
end

function PartyCombatSectionTableView:numberOfCells()
	return #PartyCombatMO.CombatSection
end

function PartyCombatSectionTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyCombatSectionTableView:createCellAtIndex(cell, index)
	PartyCombatSectionTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell)
	bg:setPreferredSize(cc.size(594, 194))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	

	local sectionInfo = PartyCombatMO.CombatSection[index]
	-- local sectionDB = PartyCombatBO.getSectionById(sectionInfo.sectionId)
	local sectionIndex = math.floor(sectionInfo.sectionId / 100)
	local combatNum = PartyCombatMO.queryCombatBySectionNum(index)

	local sectionDB = PartyCombatBO.getSectionDB(index)
	local killedNum = sectionDB[1]
	local awardNum = sectionDB[2]
	local sectionOpen
	if index == 1 then
		sectionOpen = true
	else
		if PartyCombatBO.getSectionDB(index - 1)[1] == 5 then
			sectionOpen = true
		else
			sectionOpen = false
		end
	end
	local sprite = nil
	if sectionOpen then
		sprite = display.newSprite(IMAGE_COMMON .. "combat/section_" .. sectionIndex .. ".jpg")
	else
		sprite = display.newSprite(IMAGE_COMMON .. "combat/section_" .. sectionIndex .. "_close.jpg")
	end

	local btn = CellTouchButton.new(sprite, nil, nil, nil, handler(self, self.onChoseSectionCallback))
	-- btn.sectionDB = sectionDB
	btn.sectionInfo = sectionInfo
	btn.sectionOpen = sectionOpen
	cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = sectionInfo.combatName, font = G_FONT, size = FONT_SIZE_BIG, x = 80, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	name:setAnchorPoint(cc.p(0, 0.5))

	local combatLiveLab = ui.newTTFLabel({text = CommonText[655][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 80 + 155, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	combatLiveLab:setAnchorPoint(cc.p(0, 0.5))

	--未击杀据点
	gdump(sectionIndex,"sectionIndexsectionIndex")
	
	local aliveNum = combatNum - killedNum

	local combatLiveValue = ui.newTTFLabel({text = aliveNum, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = combatLiveLab:getPositionX() + combatLiveLab:getContentSize().width, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	combatLiveValue:setAnchorPoint(cc.p(0, 0.5))
	if aliveNum > 0 then
		combatLiveValue:setColor(COLOR[2])
	else
		combatLiveValue:setColor(COLOR[6])
	end


	local combatMaxValue = ui.newTTFLabel({text = "/" .. combatNum, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = combatLiveValue:getPositionX() + combatLiveValue:getContentSize().width, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	combatMaxValue:setAnchorPoint(cc.p(0, 0.5))

	local awardLab = ui.newTTFLabel({text = CommonText[655][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 80 + 155 + 190, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	awardLab:setAnchorPoint(cc.p(0, 0.5))

	local awardValue = ui.newTTFLabel({text = awardNum, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = awardLab:getPositionX() + awardLab:getContentSize().width, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	awardValue:setAnchorPoint(cc.p(0, 0.5))
	if awardNum > 0 then
		awardValue:setColor(COLOR[2])
	else
		awardValue:setColor(COLOR[6])
	end

	local awardMaxValue = ui.newTTFLabel({text = "/" .. combatNum, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = awardValue:getPositionX() + awardValue:getContentSize().width, y = btn:getContentSize().height - 42, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	awardMaxValue:setAnchorPoint(cc.p(0, 0.5))

	--箱子
	armature_add("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_add("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")
	local boxNode = display.newNode():addTo(btn)
	boxNode:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2 - 30)

	local lightEffect = CCArmature:create("ui_box_light")
    lightEffect:getAnimation():playWithIndex(0)
    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
    -- lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
    boxNode:addChild(lightEffect)
	--未领取
	local boxSprite = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_close.png")
	-- boxSprite:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
	boxNode:addChild(boxSprite)

	local starEffect = CCArmature:create("ui_box_star")
    starEffect:getAnimation():playWithIndex(0)
    starEffect:connectMovementEventSignal(function(movementType, movementID) end)
    starEffect:setPosition(boxSprite:getContentSize().width / 2, boxSprite:getContentSize().height / 2)
    boxSprite:addChild(starEffect)

    boxNode:setScale(0.6)
    boxNode:setVisible(awardNum > 0)



	for index = 1, 5 do
		local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(btn)
		starBg:setScale(0.5)
		starBg:setPosition(400 + (index - 1) * 35, 38)

		if index < sectionIndex + 1 then
			local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
			star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
		end
	end

	return cell
end

function PartyCombatSectionTableView:onChoseSectionCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.sectionOpen == false then return end
	require("app.view.PartyCombatLevelView").new(sender.sectionInfo):push()
end

function PartyCombatSectionTableView:onExit()
	PartyCombatSectionTableView.super.onExit(self)
	armature_remove("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_remove("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")
end

return PartyCombatSectionTableView
