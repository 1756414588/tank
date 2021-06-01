
-- 选中关卡，进行挑战或挂机弹出框

local Dialog = require("app.dialog.Dialog")
local CombatFightDialog = class("CombatFightDialog", Dialog)

function CombatFightDialog:ctor(combatType, combatId)
	CombatFightDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})

	self.m_kind = combatType

	self.m_combatId = combatId

	gprint("[CombatFightDialog] combat type", combatType, "combatId:", combatId)
end

function CombatFightDialog:onEnter()
	CombatFightDialog.super.onEnter(self)

	CombatMO.curBattleNeedShowBalance_ = false
	CombatMO.curChoseBattleType_ = self.m_kind
	CombatMO.curChoseBtttleId_ = self.m_combatId
	CombatMO.curBattleCombatUpdate_ = 0

	local combatDB = nil
	if self.m_kind == COMBAT_TYPE_COMBAT then
		combatDB = CombatMO.queryCombatById(self.m_combatId)
	elseif self.m_kind == COMBAT_TYPE_EXPLORE then
		combatDB = CombatMO.queryExploreById(self.m_combatId)
	elseif self.m_kind == COMBAT_TYPE_PARTY_COMBAT then
		combatDB = PartyCombatBO.getCombatDbById(self.m_combatId)
	end
	gdump(combatDB, "[CombatFightDialog]")

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[32])

	-- 敌军阵型
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(self:getBg())
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(40, self:getBg():getContentSize().height - 80)

	local title = ui.newTTFLabel({text = combatDB.name, font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)

	local itemView = UiUtil.createItemView(ITEM_KIND_HERO, 0):addTo(self:getBg())
	itemView:setScale(0.48)
	itemView:setPosition(104, self:getBg():getContentSize().height - 148)
	UiUtil.createItemDetailButton(itemView, nil, nil, function() end)

	-- 战斗力
	if self.m_kind ~= COMBAT_TYPE_PARTY_COMBAT then
		local fightBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self:getBg())
		fightBg:setPreferredSize(cc.size(184, fightBg:getContentSize().height))
		fightBg:setPosition(274, self:getBg():getContentSize().height - 130)

		-- 战斗力
		local fight = display.newSprite(IMAGE_COMMON .. "label_fight.png"):addTo(fightBg)
		fight:setAnchorPoint(cc.p(0, 0.5))
		fight:setPosition(14, fightBg:getContentSize().height / 2)

		local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(combatDB.fight), font = "fnt/num_2.fnt"}):addTo(fightBg)
		value:setPosition(fight:getPositionX() + fight:getContentSize().width + 5, fight:getPositionY())
		value:setAnchorPoint(cc.p(0, 0.5))

	end
	-- 阵型背景框
	local formatBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	formatBg:setPreferredSize(cc.size(506, 274))
	formatBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 336)

	-- 后排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_18.png", 30, 202):addTo(formatBg)

	-- 前排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_17.png", 30, 68):addTo(formatBg)

	local formation

	if self.m_kind == COMBAT_TYPE_PARTY_COMBAT then
		formation = combatDB.form
	else
		formation = CombatBO.parseCombatFormation(combatDB)
	end
	
	-- 关卡中的敌军阵型
	local ArmyFormationView = require("app.view.ArmyFormationView")
	local view = ArmyFormationView.new(FORMATION_FOR_TANK, formation, nil, {showAdd = false, reverse = true}):addTo(self:getBg())
	view:setEnabled(false)
	view:setScale(0.8)
	view:setPosition(self:getBg():getContentSize().width / 2 + 24, 392)

	-- 省流量不看战斗
	local desc = ui.newTTFLabel({text = CommonText[39], font = G_FONT, size = FONT_SIZE_SMALL, x = 342, y = 360, color = COLOR[11]}):addTo(self:getBg())

	local function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		CombatMO.curSkipBattle_ = isChecked
	end

	local checkBox = CheckBox.new(nil, nil, onCheckedChanged):addTo(self:getBg())
	checkBox:setPosition(523, desc:getPositionY())
	checkBox:setChecked(CombatMO.curSkipBattle_)

	if self.m_kind == COMBAT_TYPE_PARTY_COMBAT then
		--团本
		-- 挑战奖励
		local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
		bg:setAnchorPoint(cc.p(0, 0.5))
		bg:setPosition(40, 360)

		local title = ui.newTTFLabel({text = CommonText[666][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

		for index=1,#CommonText[667] do
			local awardNormal = ui.newTTFLabel({text = CommonText[667][index], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			awardNormal:setAnchorPoint(cc.p(0, 0.5))
			awardNormal:setPosition(50, 320 - (index - 1) * 30)
		end

		-- 击杀奖励
		local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
		bg:setAnchorPoint(cc.p(0, 0.5))
		bg:setPosition(40, 210)

		local title = ui.newTTFLabel({text = CommonText[666][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
		
		-- gdump(combatDB,"击杀奖励数据")

		local killAward = json.decode(combatDB.lastAward)
		local lab = ui.newTTFLabel({text = UserMO.getResourceData(killAward[1][1]).name .. "+" .. killAward[1][3], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		lab:setAnchorPoint(cc.p(0, 0.5))
		lab:setPosition(50, 170)

		--箱子
		local box = json.decode(combatDB.box)
		local lab = ui.newTTFLabel({text = UserMO.getResourceData(box[1][1],box[1][2]).name .. "+" .. box[1][3], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		lab:setAnchorPoint(cc.p(0, 0.5))
		lab:setPosition(50, 140)

		--挑战不会损失部队
		local lab = ui.newTTFLabel({text = CommonText[669], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		lab:setAnchorPoint(cc.p(0, 0.5))
		lab:setPosition(50, 110)
	elseif self.m_kind == COMBAT_TYPE_COMBAT then
		-- 关卡收益
		local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
		bg:setAnchorPoint(cc.p(0, 0.5))
		bg:setPosition(40, 360)

		local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

		-- 经验
		local exp = ui.newTTFLabel({text = CommonText[37] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 48, y = 315, color = COLOR[11]}):addTo(self:getBg())
		local value = ui.newTTFLabel({text = "+" .. combatDB.exp, font = G_FONT, size = FONT_SIZE_SMALL, x = exp:getPositionX() + exp:getContentSize().width / 2 + 5, y = exp:getPositionY(), color = COLOR[2]}):addTo(self:getBg())

		-- 可能掉落
		local drop = ui.newTTFLabel({text = CommonText[38] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 48, y = 255, color = COLOR[11]}):addTo(self:getBg())
		local dropData = CombatBO.parseShowDrop(combatDB)
		-- 掉落
		local CombatDropTableView = require("app.scroll.CombatDropTableView")
		local view = CombatDropTableView.new(cc.size(350, 60), dropData):addTo(self:getBg())
		view:setPosition(drop:getPositionX() + drop:getContentSize().width / 2 + 10, drop:getPositionY() - view:getContentSize().height / 2)
		view:reloadData()

		-- 关卡评级
		local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
		bg:setAnchorPoint(cc.p(0, 0.5))
		bg:setPosition(40, 200)

		local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

		local combat = CombatMO.getCombatById(self.m_combatId)
		-- gdump(combat, "[CombatFightDialog] combat 222")
		for index = 1, 3 do
			local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
			starBg:setPosition(58 + (index - 0.5) * 64, 150)

			if combat and index <= combat.star then
				local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
				star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
			end
		end

		-- 获得三星评级可进行关卡扫荡
		local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())
		local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
	elseif self.m_kind == COMBAT_TYPE_EXPLORE then
		local combatDB = CombatMO.queryExploreById(self.m_combatId)
		
		local bg1 = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
		bg1:setAnchorPoint(cc.p(0, 0.5))
		bg1:setPosition(40, 360)

		local bg2 = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
		bg2:setAnchorPoint(cc.p(0, 0.5))
		bg2:setPosition(40, 200)

		if combatDB.type == EXPLORE_TYPE_EXTREME then  -- 极限副本
			-- 通关条件
			local title = ui.newTTFLabel({text = CommonText[273], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			local desc = ""

			-- 全面歼敌
			local label = ui.newTTFLabel({text = CommonText[277] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 48, y = 315, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			desc = combatDB.passDesc or ""

			local label = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			-- 通关奖励
			local bg2 = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
			bg2:setAnchorPoint(cc.p(0, 0.5))
			bg2:setPosition(40, 200)

			local title = ui.newTTFLabel({text = CommonText[274], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			-- 可能获得
			local label = ui.newTTFLabel({text = CommonText[278] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 48, y = 155, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			desc = combatDB.awardDesc or ""

			local label = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif combatDB.type == EXPLORE_TYPE_EQUIP then  -- 装备探险
			-- 关卡收益
			local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			-- 有几率获得装备升级材料
			local label =ui.newTTFLabel({text = CommonText[478][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getPositionY() - 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			local awards = json.decode(combatDB.passDesc)
			if awards then
				for index = 1, #awards do
					local award = awards[index]
					local resData = UserMO.getResourceData(ITEM_KIND_EQUIP, award[1])
					local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = label:getPositionY() - index * 22, color = COLOR[award[2]], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
					name:setAnchorPoint(cc.p(0, 0.5))
				end
			end

			-- 关卡评级
			local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			local combat = CombatMO.getExploreById(self.m_combatId)
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
				starBg:setPosition(58 + (index - 0.5) * 64, 150)

				if combat and index <= combat.star then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			-- 获得三星评级可进行关卡扫荡
			local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())
			local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
		elseif combatDB.type == EXPLORE_TYPE_PART then -- 配件探险
			-- 关卡收益
			local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			-- 有几率获得装备升级材料
			local label =ui.newTTFLabel({text = CommonText[478][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getPositionY() - 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			local awards = json.decode(combatDB.passDesc)
			if awards then
				for index = 1, #awards do
					local award = awards[index]
					local name = ui.newTTFLabel({text = award[1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = label:getPositionY() - index * 22, color = COLOR[award[2]], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
					name:setAnchorPoint(cc.p(0, 0.5))
				end
			end

			-- 关卡评级
			local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			local combat = CombatMO.getExploreById(self.m_combatId)
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
				starBg:setPosition(58 + (index - 0.5) * 64, 150)

				if combat and index <= combat.star then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			-- 获得三星评级可进行关卡扫荡
			local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())
			local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
		elseif combatDB.type == EXPLORE_TYPE_WAR then -- 军工探险
			-- 关卡收益
			local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			-- 有几率获得装备升级材料
			local label =ui.newTTFLabel({text = CommonText[478][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getPositionY() - 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			local awards = json.decode(combatDB.passDesc)
			if awards then
				for index = 1, #awards do
					local award = awards[index]
					local name = ui.newTTFLabel({text = award[1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = label:getPositionY() - index * 22, color = COLOR[award[2]], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
					name:setAnchorPoint(cc.p(0, 0.5))
				end
			end

			-- 关卡评级
			local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			local combat = CombatMO.getExploreById(self.m_combatId)
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
				starBg:setPosition(58 + (index - 0.5) * 64, 150)

				if combat and index <= combat.star then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			-- 获得三星评级可进行关卡扫荡
			local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())
			local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
		elseif combatDB.type == EXPLORE_TYPE_ENERGYSPAR then ---能晶探险
			-- 关卡收益
			local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			-- 有几率获得能晶
			local label =ui.newTTFLabel({text = CommonText[478][4], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getPositionY() - 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			local awards = json.decode(combatDB.passDesc)
			if awards then
				for index = 1, #awards do
					local award = awards[index]
					local name = ui.newTTFLabel({text = award[1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = label:getPositionY() - index * 22, color = COLOR[award[2]], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
					name:setAnchorPoint(cc.p(0, 0.5))
				end
			end

			-- 关卡评级
			local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			local combat = CombatMO.getExploreById(self.m_combatId)
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
				starBg:setPosition(58 + (index - 0.5) * 64, 150)

				if combat and index <= combat.star then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			-- 获得三星评级可进行关卡扫荡
			local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())			
			local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
		elseif combatDB.type == EXPLORE_TYPE_MEDAL then ---勋章探险
			-- 关卡收益
			local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			-- 有几率获得能晶
			local label =ui.newTTFLabel({text = CommonText[478][5], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getPositionY() - 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			local awards = json.decode(combatDB.passDesc)
			if awards then
				for index = 1, #awards do
					local award = awards[index]
					local name = ui.newTTFLabel({text = award[1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = label:getPositionY() - index * 22, color = COLOR[award[2]], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
					name:setAnchorPoint(cc.p(0, 0.5))
				end
			end

			-- 关卡评级
			local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			local combat = CombatMO.getExploreById(self.m_combatId)
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
				starBg:setPosition(58 + (index - 0.5) * 64, 150)

				if combat and index <= combat.star then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			-- 获得三星评级可进行关卡扫荡
			local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())			
			local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
		elseif combatDB.type == EXPLORE_TYPE_TACTIC then ---战术FB
			-- 关卡收益
			local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			local label =ui.newTTFLabel({text = CommonText[478][6], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getPositionY() - 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			local awards = json.decode(combatDB.passDesc)
			if awards then
				for index = 1, #awards do
					local award = awards[index]
					local name = ui.newTTFLabel({text = award[1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = label:getPositionY() - index * 22, color = COLOR[award[2]], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
					name:setAnchorPoint(cc.p(0, 0.5))
				end
			end

			-- 关卡评级
			local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			local combat = CombatMO.getExploreById(self.m_combatId)
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
				starBg:setPosition(58 + (index - 0.5) * 64, 150)

				if combat and index <= combat.star then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			-- 获得三星评级可进行关卡扫荡
			local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())			
			local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
		elseif combatDB.type == EXPLORE_TYPE_LIMIT then ---限时
			-- 关卡收益
			local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			local awards = json.decode(combatDB.passDesc)
			if awards then
				for index = 1, #awards do
					local award = awards[index]
					local name = ui.newTTFLabel({text = award[1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = title:getPositionY() - 20 - index * 22, color = COLOR[award[2]], align = ui.TEXT_ALIGN_CENTER}):addTo(bg1)
					name:setAnchorPoint(cc.p(0, 0.5))
				end
			end
			-- 关卡评级
			local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			local combat = CombatMO.getExploreById(self.m_combatId)
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
				starBg:setPosition(58 + (index - 0.5) * 64, 150)

				if combat and index <= combat.star then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			-- 获得三星评级可进行关卡扫荡
			local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())	
			local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
		else
			-- 关卡收益
			local title = ui.newTTFLabel({text = CommonText[56], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)

			-- 可能掉落
			local drop = ui.newTTFLabel({text = CommonText[38] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 48, y = 255, color = COLOR[11]}):addTo(self:getBg())
			local dropData = CombatBO.parseShowDrop(combatDB)
			-- 掉落
			local CombatDropTableView = require("app.scroll.CombatDropTableView")
			local view = CombatDropTableView.new(cc.size(350, 60), dropData):addTo(self:getBg())
			view:setPosition(drop:getPositionX() + drop:getContentSize().width / 2 + 10, drop:getPositionY() - view:getContentSize().height / 2)
			view:reloadData()

			-- 关卡评级
			local title = ui.newTTFLabel({text = CommonText[57], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg2:getContentSize().height / 2}):addTo(bg2)

			local combat = CombatMO.getExploreById(self.m_combatId)
			for index = 1, 3 do
				local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(self:getBg())
				starBg:setPosition(58 + (index - 0.5) * 64, 150)

				if combat and index <= combat.star then
					local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
					star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)
				end
			end

			-- 获得三星评级可进行关卡扫荡
			local desc = ui.newTTFLabel({text = CommonText[36], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 108, color = COLOR[11]}):addTo(self:getBg())
			local desc = ui.newTTFLabel({text = CommonText[1784], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 85, color = COLOR[11]}):addTo(self:getBg())
		end
	end

	-- 挑战按钮
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local challengeBtn = MenuButton.new(normal, selected, nil, handler(self, self.onChallengeCallback)):addTo(self:getBg())
	challengeBtn:setLabel(CommonText[34])
	challengeBtn:setPosition(self:getBg():getContentSize().width - 166, 26)

	
	if self.m_kind ~= COMBAT_TYPE_EXPLORE and self.m_kind ~= COMBAT_TYPE_PARTY_COMBAT or (self.m_kind == COMBAT_TYPE_EXPLORE and combatDB.type ~= EXPLORE_TYPE_EXTREME ) then -- 极限探险和军团副本无扫荡按钮
		-- 扫荡按钮
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local wipeBtn = MenuButton.new(normal, selected, nil, handler(self, self.onWipeCallback)):addTo(self:getBg())
		wipeBtn:setLabel(CommonText[35])
		wipeBtn:setPosition(166, 26)
	else
		challengeBtn:setPositionX(self:getBg():getContentSize().width / 2)
	end
end

function CombatFightDialog:onChallengeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_kind == COMBAT_TYPE_COMBAT then  -- 普通副本需要判断能量
		local power = UserMO.getResource(ITEM_KIND_POWER)
		if power < COMBAT_TAKE_POWER then -- 能量不足
			require("app.dialog.BuyPawerDialog").new():push()
			local resData = UserMO.getResourceData(ITEM_KIND_POWER)
			Toast.show(resData.name .. CommonText[223])
			

			-- local function doneBuyPower()
			-- 	Loading.getInstance():unshow()
			-- end

			-- local function gotoBuyPower()
			-- 	local coinCount = UserMO.getResource(ITEM_KIND_COIN)
			-- 	if coinCount < VipBO.getPowerBuyCoin() then
			-- 		require("app.dialog.CoinTipDialog").new():push()
			-- 		return
			-- 	end

			-- 	Loading.getInstance():show()
			-- 	UserBO.asynBuyPower(doneBuyPower)
			-- end

			-- local resData = UserMO.getResourceData(ITEM_KIND_POWER)

			-- if UserMO.powerBuy_ >= VipBO.getPowerBuyCount() then  -- vip等级不足，无法购买
			-- 	require("app.dialog.BuyPawerDialog").new():push()
			-- 	Toast.show(resData.name .. CommonText[223])  -- 能量不足
			-- 	return
			-- end
			-- if UserMO.consumeConfirm then
			-- 	local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			-- 	CoinConfirmDialog.new(string.format(CommonText[112], VipBO.getPowerBuyCoin(), POWER_BUY_NUM, resData.name), function() gotoBuyPower() end, nil):push()
			-- else
			-- 	gotoBuyPower()
			-- end
			return
		end
	end

	self:pop()

	local ArmyView = require("app.view.ArmyView")
	local view = ArmyView.new(ARMY_VIEW_FOR_FIGHT):push()
end

function CombatFightDialog:onWipeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not VipBO.canWipe() then  -- VIP不够
		Toast.show(CommonText[366][4])
		return
	end

	if self.m_kind == COMBAT_TYPE_COMBAT then  -- 普通副本需要判断能量
		local power = UserMO.getResource(ITEM_KIND_POWER)
		if power < COMBAT_TAKE_POWER then -- 能量不足

			require("app.dialog.BuyPawerDialog").new():push()
			local resData = UserMO.getResourceData(ITEM_KIND_POWER)
			Toast.show(resData.name .. CommonText[223])
			
			-- local function doneBuyPower()
			-- 	Loading.getInstance():unshow()
			-- end

			-- local function gotoBuyPower()
			-- 	local coinCount = UserMO.getResource(ITEM_KIND_COIN)
			-- 	if coinCount < VipBO.getPowerBuyCoin() then
			-- 		require("app.dialog.CoinTipDialog").new():push()
			-- 		return
			-- 	end

			-- 	Loading.getInstance():show()
			-- 	UserBO.asynBuyPower(doneBuyPower)
			-- end

			-- local resData = UserMO.getResourceData(ITEM_KIND_POWER)

			-- if UserMO.powerBuy_ >= VipBO.getPowerBuyCount() then  -- vip等级不足，无法购买
			-- 	Toast.show(resData.name .. CommonText[223])  -- 能量不足
			-- 	return
			-- end

			-- if UserMO.consumeConfirm then
			-- 	local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			-- 	CoinConfirmDialog.new(string.format(CommonText[112], VipBO.getPowerBuyCoin(), POWER_BUY_NUM, resData.name), function() gotoBuyPower() end, nil):push()
			-- else
			-- 	gotoBuyPower()
			-- end
			return
		end
	end

	if self.m_kind == COMBAT_TYPE_COMBAT then
		local combat = CombatMO.getCombatById(self.m_combatId)
		if combat and combat.star >= 3 then  -- 可以扫荡
			self:pop(function()
					local ArmyView = require("app.view.ArmyView")
					local view = ArmyView.new(ARMY_VIEW_FOR_WIPE):push()
				end)
		else
			Toast.show(CommonText[36])
		end
	elseif self.m_kind == COMBAT_TYPE_EXPLORE then
		local combat = CombatMO.getExploreById(self.m_combatId)
		if combat and combat.star >= 3 then -- 可以扫荡
			local combatDB = CombatMO.queryExploreById(self.m_combatId)
			
			if combatDB.type == EXPLORE_TYPE_EQUIP then
				local equips = EquipMO.getFreeEquipsAtPos()
				local remainCount = UserMO.equipWarhouse_ - #equips
				if remainCount <= 0 then
					Toast.show(CommonText[711])  -- 仓库已满
					return
				end
			end

			if CombatBO.getExploreChallengeLeftCount(combatDB.type) <= 0 then
				Toast.show(CommonText[301])
			else
				self:pop(function()
						local ArmyView = require("app.view.ArmyView")
						local view = ArmyView.new(ARMY_VIEW_FOR_WIPE):push()
					end)
			end
		else
			Toast.show(CommonText[36])
		end
	end
end

return CombatFightDialog