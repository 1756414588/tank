--
-- Author: heyunlong
-- Date: 2018-09-18 15:49:50
-- 世界矿场展示
require("app.text.DetailText")

local Dialog = require("app.dialog.Dialog")
local WorldMineFieldDialog = class("WorldMineFieldDialog", Dialog)

function WorldMineFieldDialog:ctor()
	WorldMineFieldDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 480)})
	self.m_hndStaffingUpdate = nil
	self.m_labelMineLevel = nil
	self.m_labelMineExp = nil
	-- self.m_labelLevelExp = nil
	self.m_levelBar = nil
	self.m_labelContrib = nil
	self.m_labelEffectLevel = nil
	self.m_labelMineSpdUp = nil
end

function WorldMineFieldDialog:onEnter()
	WorldMineFieldDialog.super.onEnter(self)

	self:setTitle(CommonText[2400])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 450))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, function ()
		self:pop()
	end):addTo(self:getBg())
	rechargeBtn:setPosition(self:getBg():getContentSize().width / 2,25)
	rechargeBtn:setLabel(CommonText[2401])

	-- 显示矿点等级 矿点经验 升级经验
	local firstRowX = 90
	local firstRowY = self:getBg():getContentSize().height - 90

	local worldMineLevel = WorldMO.worldMineLevel
	local maxLevel = WorldMO.queryWorldMineMaxLevel()
	local labelTMineLevel = ui.newTTFLabel({text = CommonText[2402] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = firstRowX, y = firstRowY, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	local labelMineLevel = UiUtil.label(worldMineLevel, nil ,COLOR[2]):rightTo(labelTMineLevel, 10)

	self.m_labelMineLevel = labelMineLevel

	local labelTMineExp = ui.newTTFLabel({text = CommonText[2403] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = firstRowX, y = firstRowY - 35, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	local labelMineExp = UiUtil.label(UiUtil.strNumSimplify(WorldMO.worldMineExp), nil ,COLOR[2]):rightTo(labelTMineExp, 10)

	self.m_labelMineExp = labelMineExp

	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.worldMineDetail):push()
	end
	local btnDetail = UiUtil.button("btn_detail_normal.png","btn_detail_selected.png",nil, gotoDetail):rightTo(labelMineLevel, 280)
	btnDetail:setScale(0.8)
	btnDetail:setPositionY(btnDetail:getPositionY() - 10)

	local thirdRowY = firstRowY - 70
	local labelTContrib = ui.newTTFLabel({text = CommonText[2406] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = firstRowX, y = thirdRowY, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	local labelContrib = UiUtil.label(UiUtil.strNumSimplify(UserMO.worldMineExpConribDay), nil ,COLOR[2]):rightTo(labelTContrib, 10)

	self.m_labelContrib = labelContrib

	local fourthRowY = firstRowY - 105
	local levelExp = 0
	if worldMineLevel + 1 > maxLevel then
		levelExp = WorldMO.queryWorldMineExpByLevel(maxLevel)
	else
		levelExp = WorldMO.queryWorldMineExpByLevel(worldMineLevel + 1)
	end

	local lebelTLevelProgress = ui.newTTFLabel({text = CommonText[2405] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = firstRowX, y = fourthRowY, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(240, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(240 + 4, 26)}):addTo(self:getBg())
	bar:setPosition(lebelTLevelProgress:getPositionX() + lebelTLevelProgress:getContentSize().width + bar:getContentSize().width / 2 - 10, fourthRowY)
	local lastLevelExp = WorldMO.queryWorldMineExpByLevel(worldMineLevel)
	local curLevelExp = WorldMO.worldMineExp - lastLevelExp
	local curLevelNeedExp = levelExp - lastLevelExp
	bar:setPercent(curLevelExp / curLevelNeedExp)
	if curLevelNeedExp ~= 0 then
		bar:setLabel(string.format("%d/%d", curLevelExp, curLevelNeedExp))
	else
		bar:setLabel(string.format("%d/-", curLevelExp))
	end

	self.m_levelBar = bar

	-- 属性背景框
	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	attrBg:setPreferredSize(cc.size(480, 190))
	attrBg:setPosition(275, fourthRowY - 120)

	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(firstRowX - 50, fourthRowY - 60)

	local labelTCurEffect = ui.newTTFLabel({text = CommonText[2407], font = G_FONT, size = FONT_SIZE_SMALL, x = firstRowX + 40, y = fourthRowY - 60, color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	local mineLevelUp = worldMineLevel * 2
	local speedUp = WorldMO.queryWorldMineSpeedUpByDayExp(UserMO.worldMineExpConribDay)
	local decline = WorldMO.queryWorldMineDeclineByLevel(worldMineLevel)
	local mineLevelUpStr = DetailText.formatDetailText(DetailText.worldMineStr, mineLevelUp, speedUp, decline * 100)
	local labelEffectLevel = RichLabel.new(mineLevelUpStr[1], cc.size(0, 0)):addTo(self:getBg())
	labelEffectLevel:setPosition(firstRowX - 40, fourthRowY - 90)
	labelEffectLevel:setAnchorPoint(0, 0.5)

	self.m_labelEffectLevel = labelEffectLevel

	local labelMineSpdUp = RichLabel.new(mineLevelUpStr[2], cc.size(0, 0)):addTo(self:getBg())
	labelMineSpdUp:setPosition(firstRowX - 40, fourthRowY - 120)
	labelMineSpdUp:setAnchorPoint(0, 0.5)

	self.m_labelMineSpdUp = labelMineSpdUp

	local labelMineExpDecay = RichLabel.new(mineLevelUpStr[3], cc.size(0, 0)):addTo(self:getBg())
	labelMineExpDecay:setPosition(firstRowX - 40, fourthRowY - 150)
	labelMineExpDecay:setAnchorPoint(0, 0.5)

	self.m_labelMineExpDecay = labelMineExpDecay

	self.m_hndStaffingUpdate = Notify.register(LOCAL_WORLD_STAFFING, handler(self, self.onStaffingUpdate))
end

function WorldMineFieldDialog:onExit()
	if self.m_hndStaffingUpdate then
		Notify.unregister(self.m_hndStaffingUpdate)
		self.m_hndStaffingUpdate = nil
	end
	WorldMineFieldDialog.super.onExit(self)
end

function WorldMineFieldDialog:onStaffingUpdate()
	-- body
	if self.m_labelMineLevel then
		local worldMineLevel = WorldMO.worldMineLevel
		local maxLevel = WorldMO.queryWorldMineMaxLevel()
		self.m_labelMineLevel:setString(string.format("%d", worldMineLevel))
		self.m_labelMineExp:setString(UiUtil.strNumSimplify(WorldMO.worldMineExp))

		local levelExp = 0
		if worldMineLevel + 1 > maxLevel then
			levelExp = WorldMO.queryWorldMineExpByLevel(maxLevel)
		else
			levelExp = WorldMO.queryWorldMineExpByLevel(worldMineLevel + 1)
		end

		-- self.m_labelLevelExp:setString(UiUtil.strNumSimplify(levelExp))

		local lastLevelExp = WorldMO.queryWorldMineExpByLevel(worldMineLevel)
		local curLevelExp = WorldMO.worldMineExp - lastLevelExp
		local curLevelNeedExp = levelExp - lastLevelExp
		self.m_levelBar:setPercent(curLevelExp / curLevelNeedExp)
		self.m_levelBar:setLabel(string.format("%d/%d", curLevelExp, curLevelNeedExp))

		self.m_labelContrib:setString(UiUtil.strNumSimplify(UserMO.worldMineExpConribDay))

		local mineLevelUp = worldMineLevel * 2
		local speedUp = WorldMO.queryWorldMineSpeedUpByDayExp(UserMO.worldMineExpConribDay)
		local decline = WorldMO.queryWorldMineDeclineByLevel(worldMineLevel)
		local mineLevelUpStr = DetailText.formatDetailText(DetailText.worldMineStr, mineLevelUp, speedUp, decline * 100)

		self.m_labelEffectLevel:setStringData(mineLevelUpStr[1])
		self.m_labelMineSpdUp:setStringData(mineLevelUpStr[2])
		self.m_labelMineExpDecay:setStringData(mineLevelUpStr[3])
	end
end

return WorldMineFieldDialog 
