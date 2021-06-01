
-- 选中关卡，进行挑战或挂机弹出框

local Dialog = require("app.dialog.Dialog")
local TeammateInfoDialog = class("TeammateInfoDialog", Dialog)

function TeammateInfoDialog:ctor(fight, form, nick, commander)
	TeammateInfoDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 500)})
	self.m_fight = fight
	self.m_formation = form
	self.m_nick = nick
	self.m_commander = commander
end

function TeammateInfoDialog:onEnter()
	TeammateInfoDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY(500 / btm:getContentSize().height)

	self:setTitle("部队阵型")

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(self:getBg())
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(144, self:getBg():getContentSize().height - 100)

	local title = ui.newTTFLabel({text = self.m_nick, font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)

	local itemView = UiUtil.createItemView(ITEM_KIND_HERO, self.m_commander):addTo(self:getBg())
	itemView:setScale(0.6)
	itemView:setPosition(104, self:getBg():getContentSize().height - 130)
	-- UiUtil.createItemDetailButton(itemView, nil, nil, function() end)

	-- 战斗力
	if self.m_kind ~= COMBAT_TYPE_PARTY_COMBAT then
		local fightBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self:getBg())
		fightBg:setPreferredSize(cc.size(184, fightBg:getContentSize().height))
		fightBg:setPosition(274, self:getBg():getContentSize().height - 150)

		-- 战斗力
		local fight = display.newSprite(IMAGE_COMMON .. "label_fight.png"):addTo(fightBg)
		fight:setAnchorPoint(cc.p(0, 0.5))
		fight:setPosition(14, fightBg:getContentSize().height / 2)

		self.m_formation.commander = self.m_commander
		-- local fightValueData = TankBO.analyseFormation(self.m_formation)
		local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(self.m_fight), font = "fnt/num_2.fnt"}):addTo(fightBg)
		value:setPosition(fight:getPositionX() + fight:getContentSize().width + 5, fight:getPositionY())
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 阵型背景框
	local formatBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	formatBg:setPreferredSize(cc.size(506, 274))
	formatBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 336)

	-- 后排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_18.png", 30, 68):addTo(formatBg)

	-- 前排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_17.png", 30, 202):addTo(formatBg)

	-- 关卡中的敌军阵型
	local ArmyFormationView = require("app.view.ArmyFormationView")
	local view = ArmyFormationView.new(FORMATION_FOR_TANK, self.m_formation, nil, {showAdd = false, reverse = false}):addTo(self:getBg())
	view:setEnabled(false)
	view:setScale(0.8)
	view:setPosition(self:getBg():getContentSize().width / 2 + 24, 25)
end

return TeammateInfoDialog 
