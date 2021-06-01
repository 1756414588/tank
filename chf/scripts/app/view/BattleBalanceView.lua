
-- 战斗结算view
-- 队伍中的每个小节点位置
local TroopNode = class("TroopNode", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function TroopNode:ctor(posIndex, troopData)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png"):addTo(self)
	normal:setPosition(normal:getContentSize().width / 2, normal:getContentSize().height / 2)
	normal:setVisible(true)

	local scale = 0.8
	if posIndex ~= 2 then
		scale = 0.7
	end
	normal:setScale(scale)

	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(cc.size(normal:getContentSize().width, normal:getContentSize().height))
	self.normal_ = normal

	self.posIndex = posIndex

	self:update(troopData)
end

function TroopNode:update(troopData)
	self.m_param = troopData

	if self.node_ then
		self.node_:removeSelf()
		self.node_ = nil
	end

	local node = display.newNode():addTo(self)
	node:setContentSize(cc.size(self:getContentSize().width, self:getContentSize().height))
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self.node_ = node

	local value = self.m_param.portrait
	local portrait = value % 100
	if portrait < 1 then
		portrait = 1
	elseif portrait > PendantMO.PORTRAIT_MAX_ID then
		portrait = PendantMO.PORTRAIT_MAX_ID
	end
	local head = UiUtil.createItemSprite(ITEM_KIND_PORTRAIT, portrait):addTo(node)
	head:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)

	local scale = 0.8
	if self.posIndex ~= 2 then
		scale = 0.7
	end
	head:setScale(scale)
end

--------------------------------------------------------------------------------------------------------------------------------------
local BattleBalanceView = class("BattleBalanceView", UiNode)

function BattleBalanceView:ctor()
	if CombatMO.curBattleStar_ > 0 then
		BattleBalanceView.super.ctor(self, "image/common/bg_battle_succ.jpg", nil, {closeBtn = false})
	else
		BattleBalanceView.super.ctor(self, "image/common/bg_battle_fail.jpg", nil, {closeBtn = false})
	end
end

function BattleBalanceView:onEnter()
	BattleBalanceView.super.onEnter(self)

	ManagerSound.stopMusic()
	
	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
	self:showBalance(container)
end

function BattleBalanceView:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/ui_balance_success.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_balance_success.plist", IMAGE_ANIMATION .. "effect/ui_balance_success.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ui_balance_fail.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_balance_fail.plist", IMAGE_ANIMATION .. "effect/ui_balance_fail.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")

	UiUtil.clearImageCache()
end

function BattleBalanceView:showBalance(container)
	self:showResult(container)

	if HunterMO.curTeamFightBossData_ == nil then
		self:showBattleInfo(container)
	else
		self:showBattleInfoHunter(container)
	end

	self:showAward(container)

	self:showButtons(container)
end

-- 显示战斗结果，胜利还是失败，如果胜利，并显示几星
function BattleBalanceView:showResult(container)
	if CombatMO.curBattleStar_ > 0 then  -- 战斗胜利
		ManagerSound.playSound("balance_succ")

		armature_add(IMAGE_ANIMATION .. "effect/ui_balance_success.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_balance_success.plist", IMAGE_ANIMATION .. "effect/ui_balance_success.xml")
		armature_add(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")

		local starBg = {}

		local function showStar()
			for index = 1, CombatMO.curBattleStar_ do
				local bg = starBg[index]
				local star = display.newSprite(IMAGE_COMMON .. "star_2.png"):addTo(bg)
				if index == 1 then star:setPosition(bg:getContentSize().width / 2 - 150, bg:getContentSize().height / 2 + 220)
				elseif index == 2 then star:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 220)
				elseif index == 3 then star:setPosition(bg:getContentSize().width / 2 + 150, bg:getContentSize().height / 2 + 220)
				end
				star:setVisible(false)
				star:runAction(transition.sequence({cc.DelayTime:create(0.22 * index),
					cc.CallFunc:create(function()
							star:setVisible(true)
							local armature = armature_create("ui_flash", bg:getContentSize().width / 2, bg:getContentSize().height / 2, function (movementType, movementID, armature) end)
							armature:getAnimation():playWithIndex(0)
							armature:addTo(bg)
						end),
					cc.MoveTo:create(0.15, cc.p(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 7)),
					cc.CallFunc:create(function() ManagerSound.playSound("balance_star") end)})) 
			end
		end

		local function showSucc(parent)  -- 显示胜利
			local spwArray = cc.Array:create()
			spwArray:addObject(cc.ScaleTo:create(0.12, 1))
			spwArray:addObject(cc.MoveBy:create(0.13, cc.p(0, -220)))

			local succ = display.newSprite(IMAGE_COMMON .. "label_succ.png"):addTo(parent, 2)
			succ:setPosition(parent:getContentSize().width / 2, parent:getContentSize().height / 2 + 220)
			succ:setScale(2.5)
			succ:runAction(transition.sequence({cc.Spawn:create(spwArray), cc.DelayTime:create(0.05), cc.CallFunc:create(function() showStar() end)}))

			local armature = armature_create("ui_balance_success", parent:getContentSize().width / 2, parent:getContentSize().height / 2, function (movementType, movementID, armature) end)
			armature:getAnimation():playWithIndex(0)
			armature:addTo(parent)
		end

		local tag = display.newSprite(IMAGE_COMMON .. "icon_bt_succ.png"):addTo(container)
		tag:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2 + 170)
		tag:runAction(transition.sequence({cc.EaseBackOut:create(cc.MoveBy:create(0.2, cc.p(0, 60))),
			cc.CallFunc:create(function() showSucc(tag) end)
			}))

		for index = 1, 3 do -- 星级的背景
			local bg = display.newSprite(IMAGE_COMMON .. "star_bg_2.png"):addTo(tag)
			bg:setPosition(tag:getContentSize().width / 2 + (index - 2) * 85, 70)
			starBg[index] = bg
		end

	else
		ManagerSound.playSound("balance_fail")

		armature_add(IMAGE_ANIMATION .. "effect/ui_balance_fail.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_balance_fail.plist", IMAGE_ANIMATION .. "effect/ui_balance_fail.xml")

		local tag = display.newSprite(IMAGE_COMMON .. "icon_bt_fail.png"):addTo(container)
		tag:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2 + 230 + 50)
		tag:runAction(cc.EaseBackOut:create(cc.MoveBy:create(0.2, cc.p(0, -50))))

		local fail = display.newSprite(IMAGE_COMMON .. "label_fail.png"):addTo(container)
		fail:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2 + 230 + 80)
		fail:runAction(cc.EaseBackOut:create(cc.MoveBy:create(0.35, cc.p(0, -80))))

		local armature = armature_create("ui_balance_fail", tag:getContentSize().width / 2, tag:getContentSize().height / 2, function (movementType, movementID, armature) end)
		armature:getAnimation():playWithIndex(0)
		armature:addTo(tag)
	end
end

-- 显示战斗的信息，双方坦克数量，损兵、暴击等等
function BattleBalanceView:showBattleInfo(container)
	local vs = display.newSprite(IMAGE_COMMON .. "label_vs_1.png"):addTo(container)
	vs:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2 + 140)
	vs:runAction(cc.EaseBackOut:create(cc.MoveBy:create(0.3, cc.p(0, -80))))

	-- 我方出阵坦克
	local my = display.newNode():addTo(container)
	my:setPosition(container:getContentSize().width / 2 - 450, container:getContentSize().height / 2 + 60)
	my:runAction(cc.MoveBy:create(0.3, cc.p(300, 0)))

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_29.png"):addTo(my)

	-- 我方出阵坦克
	local label = ui.newTTFLabel({text = CommonText[228], font = G_FONT, size = FONT_SIZE_SMALL, x = -20, y = 20, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(my)

	-- 敌方出战坦克
	local rival = display.newNode():addTo(container)
	rival:setPosition(container:getContentSize().width / 2 + 450, container:getContentSize().height / 2 + 60)
	rival:runAction(cc.MoveBy:create(0.3, cc.p(-300, 0)))

	local count = ui.newTTFLabel({text = CombatMO.curBattleStatistics_[BATTLE_FOR_ATTACK].tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = -20, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(my)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_29.png"):addTo(rival)
	bg:setFlipX(true)

	-- 敌方出阵坦克
	local label = ui.newTTFLabel({text = CommonText[229], font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = 20, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(rival)

	local count = ui.newTTFLabel({text = CombatMO.curBattleStatistics_[BATTLE_FOR_DEFEND].tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = -20, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(rival)

	local atkStatistics = CombatMO.curBattleStatistics_[BATTLE_FOR_ATTACK]

	local lost = string.format("%.0f", ((atkStatistics.tankCount - atkStatistics.leftTankCount) / atkStatistics.tankCount * 100)) .. "%"
	local crit = string.format("%.0f", atkStatistics.critCount / atkStatistics.actionCount * 100 ) .. "%"
	local dodge = string.format("%.0f", atkStatistics.dodgeCount / atkStatistics.actionCount * 100 ) .. "%"
	if atkStatistics.actionCount == 0 then
		print("一个错误=========================")
		crit = "0%" 
		dodge = "0%"
	end

	local labels = {CommonText[231], CommonText.attr[6], CommonText.attr[5]}
	local nums = {lost, crit, dodge}

	-- 损兵、暴击、闪避
	for index = 1, 3 do
		local bg = display.newSprite(IMAGE_COMMON .. "info_bg_30.png"):addTo(container)
		bg:setPosition(container:getContentSize().width + bg:getContentSize().width / 2, container:getContentSize().height / 2 - 25 - (index - 1) * 45)
		bg:runAction(transition.sequence({cc.DelayTime:create(0.15 + index * 0.15), cc.EaseBackOut:create(cc.MoveTo:create(0.25, cc.p(container:getContentSize().width / 2, bg:getPositionY())))}))

		local label = ui.newTTFLabel({text = labels[index] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = bg:getContentSize().height / 2, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = nums[index], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 20, y = label:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		label:setAnchorPoint(cc.p(0, 0.5))
	end
end

function BattleBalanceView:getPositionAtIndex(index)
	local y = -60
	if index ~= 2 then
		y = -70
	end
	return cc.p(-40 + 180 *(index - 1), y)
end

-- 显示战斗的信息，双方坦克数量，损兵、暴击等等
function BattleBalanceView:showBattleInfoHunter(container)
	local my = display.newNode():addTo(container)
	my:setPosition(container:getContentSize().width / 2 - 450, container:getContentSize().height / 2 + 60)
	my:runAction(cc.MoveBy:create(0.3, cc.p(300, 0)))

	local teamOrders = HunterBO.teamOrders
	local teamInfos = HunterBO.teamInfos
	local newShowOrders = {}
	local others = {1, 3}
	local tmpIndex = 1
	for i, v in ipairs(teamOrders) do
		if v == UserMO.lordId_ then
			newShowOrders[2] = v
		else
			newShowOrders[others[tmpIndex]] = v
			tmpIndex = tmpIndex + 1
		end
	end

	-- print("UserMO.lordId_!!!!", UserMO.lordId_)
	-- gdump(teamOrders, "BattleBalanceView:showBattleInfoHunter teamOrders==")
	-- gdump(newShowOrders, "BattleBalanceView:showBattleInfoHunter newShowOrders==")

	for index=1, 3 do
		local mateInfo = nil
		local roleId = newShowOrders[index]
		if roleId then
			mateInfo = teamInfos[roleId]
		end

		local node = TroopNode.new(index, mateInfo):addTo(my)
		local position = self:getPositionAtIndex(index)
		node:setPosition(position.x, position.y)

		nodeTouchEventProtocol(node, handler(self, self.onTouch), nil, nil, false)
		node:setTouchSwallowEnabled(false)

		if mateInfo ~= nil then
			--玩家名字
			local y = node:y() - node:height() / 2 + 10
			if index ~= 2 then
				y = y + 10
			end

			local nameBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(my)
			nameBg:setPosition(node:x(), y)

			local name = UiUtil.label("名字最多八个字母",18,COLOR[3]):addTo(my)
			name:setPosition(node:x(), y)
			local nickName = mateInfo.nick
			name:setString(nickName)

			if index == 2 then
				nameBg:setScale(1.2)
				name:setScale(1.2)
			end
		end
	end
end

-- 获得奖励，失败则显示提升坦克战力
function BattleBalanceView:showAward(container)
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	bg:setPosition(container:getContentSize().width, container:getContentSize().height / 2 - 180)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:runAction(transition.sequence({cc.DelayTime:create(0.6), cc.EaseBackOut:create(cc.MoveTo:create(0.6, cc.p(container:getContentSize().width / 2 - 240, bg:getPositionY())))}))

	if CombatMO.curBattleStar_ > 0 then  -- 战斗胜利
		-- 获得奖励
		local title = ui.newTTFLabel({text = CommonText[230], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

		if CombatMO.curBattleAward_ and #CombatMO.curBattleAward_.awards > 0 then -- 有战斗奖励
			gdump(CombatMO.curBattleAward_.awards, "BattleBalanceView show drop")
			local num = #CombatMO.curBattleAward_.awards
			local node = display.newNode():size(num*100 + (num-1)*30,130)
			for index = 1, #CombatMO.curBattleAward_.awards do
				local award = CombatMO.curBattleAward_.awards[index]
				local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(node)
				itemView:pos(80 + (index-1)*130,node:height()-itemView:height()/2)
				if award.kind == ITEM_KIND_TACTIC or award.kind == ITEM_KIND_TACTIC_PIECE then
					itemView:pos(80 + (index-1)*130,node:height()-itemView:height()/2 - 10)
				end
				local resData = UserMO.getResourceData(award.kind, award.id)
				local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):alignTo(itemView, -63, 1)
			end
			local scroll = CCScrollView:create()
			container:addChild(scroll)
			scroll:setPosition(ccp(container:width(),container:getContentSize().height / 2 - 330))
			scroll:setDirection(0)
			scroll:setViewSize(cc.size(556,node:height()))
			scroll:setContainer(node)
			scroll:runAction(transition.sequence({cc.DelayTime:create(0.8),cc.EaseBackOut:create(cc.MoveTo:create(0.6, cc.p(90, scroll:getPositionY())))}))
		end

		if HunterMO.curTeamFightBossData_ == nil then
			local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK)
			local tip = ui.newTTFLabel({text = CommonText[232] .. resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width, y = container:getContentSize().height / 2 - 360, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
			tip:setAnchorPoint(cc.p(0, 0.5))
			tip:runAction(transition.sequence({cc.DelayTime:create(0.8), cc.EaseBackOut:create(cc.MoveTo:create(0.7, cc.p(70, tip:getPositionY())))}))
		else
			local tip = ui.newTTFLabel({text = CommonText[415][2], font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width, y = container:getContentSize().height / 2 - 360, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
			tip:setAnchorPoint(cc.p(0, 0.5))
			tip:runAction(transition.sequence({cc.DelayTime:create(0.8), cc.EaseBackOut:create(cc.MoveTo:create(0.7, cc.p(70, tip:getPositionY())))}))
		end
	else
		-- 提升坦克战力吧
		local title = ui.newTTFLabel({text = CommonText[235], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
		local configs = {{name="t_tank_product", text=CommonText[482][1]}, {name="t_equip_upgrade", text=CommonText[482][2]}, {name="p_sc_accel", text=CommonText[482][3]}, {name="t_hero_upgrade", text=CommonText[482][4]}, {name="t_skill_upgrade", text=CommonText[482][5]}}
		for index = 1, 5 do
			local config = configs[index]

			local normal = display.newSprite("image/item/" .. config.name .. ".jpg")
			local selected = display.newSprite("image/item/" .. config.name .. ".jpg")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.onFailCallback)):addTo(container)
			btn:setPosition(container:getContentSize().width + btn:getContentSize().width / 2, container:getContentSize().height / 2 - 260)
			btn:setScale(0.9)
			btn.index = index
			btn:runAction(transition.sequence({cc.DelayTime:create(0.6 + index * 0.2), cc.EaseBackOut:create(cc.MoveTo:create(0.7, cc.p(50 + (index - 0.5) * 110, btn:getPositionY())))}))

			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(btn)
			fame:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)

			local name = ui.newTTFLabel({text = config.text, font = G_FONT, size = FONT_SIZE_SMALL, x = btn:getContentSize().width / 2, y = -20, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
		end

		local tip = ui.newTTFLabel({text = CommonText[483], font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width, y = container:getContentSize().height / 2 - 360, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(container)
		tip:setAnchorPoint(cc.p(0, 0.5))
		tip:runAction(transition.sequence({cc.DelayTime:create(0.8), cc.EaseBackOut:create(cc.MoveTo:create(0.7, cc.p(70, tip:getPositionY())))}))
	end
end

function BattleBalanceView:showButtons(container)
	-- 回放录像
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local palyBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onPlayCallback)):addTo(container)
	palyBtn:setPosition(container:getContentSize().width / 2 - 160, container:getContentSize().height / 2 - 610)
	palyBtn:setLabel(CommonText[226])
	palyBtn:runAction(transition.sequence{cc.DelayTime:create(1), cc.EaseBackOut:create(cc.MoveBy:create(0.25, cc.p(0, 150)))})
	if CombatMO.curSkipBattle_ then  -- 省流量不看战斗
		palyBtn:setEnabled(false)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local fightBtn = MenuButton.new(normal, selected, nil, handler(self, self.onFightCallback)):addTo(container)
	fightBtn:setPosition(container:getContentSize().width / 2 + 160, container:getContentSize().height / 2 - 610)
	fightBtn:runAction(transition.sequence{cc.DelayTime:create(1), cc.EaseBackOut:create(cc.MoveBy:create(0.25, cc.p(0, 150)))})
	if CombatMO.curChoseBattleType_ == COMBAT_TYPE_REPLAY or CombatMO.curChoseBattleType_ == COMBAT_TYPE_GUIDE or CombatMO.curChoseBattleType_ == COMBAT_TYPE_ARENA then  -- 只是回放
		fightBtn:setLabel(CommonText[144])  -- 退出
	else
		fightBtn:setLabel(CommonText[227])  -- 继续战斗
	end
end

function BattleBalanceView:onPlayCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if CombatMO.curSkipBattle_ then return end

	self:pop()

	if HunterMO.curTeamFightBossData_ == nil then
		local atk = BattleMO.atkInfo_
		local def = BattleMO.defInfo_
		BattleMO.reset()
		BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
		BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
		BattleMO.setFightData(CombatMO.curBattleFightData_)
		BattleMO.setBothInfo(atk,def)
		require("app.view.BattleView").new():push()
	else
		HunterBO.PlayTeamFightBoss(HunterBO.teamType, HunterMO.curTeamFightBossData_)
	end
end

-- 继续战斗
function BattleBalanceView:onFightCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	-- 退出时也清除组队信息
	HunterBO.clear()
	HunterMO.curTeamFightBossData_ = nil

	if NewerMO.tdBeginStateId == 50 then
		Statistics.postPoint(ST_P_35)
	end
	
	if CombatMO.curChoseBattleType_ == COMBAT_TYPE_REPLAY or CombatMO.curChoseBattleType_ == COMBAT_TYPE_GUIDE then  -- 只是回放
		self:pop()
		--引导触发
		NewerBO.showNewerGuide()
		return
	end

	gprint("BattleBalanceView:onFightCallback update:", CombatMO.curBattleCombatUpdate_, "type:", CombatMO.curChoseBattleType_, "id:", CombatMO.curChoseBtttleId_, "balance:", CombatMO.curBattleNeedShowBalance_)
	if CombatMO.curBattleCombatUpdate_ == 0 then
		self:pop()
	elseif CombatMO.curBattleCombatUpdate_ == 1 then -- 星级增加了
		self:pop()
	elseif CombatMO.curBattleCombatUpdate_ == 2 then -- 新的关卡开启了
		local isExtreme = false -- 判断是否是探险的极限副本
		if CombatMO.curChoseBattleType_ == COMBAT_TYPE_EXPLORE then
			local combatDB = CombatMO.queryExploreById(CombatMO.curChoseBtttleId_)
			if combatDB.type == EXPLORE_TYPE_EXTREME then
				isExtreme = true
			end
		end
		if isExtreme then
			UiDirector.popMakeUiTop("CombatExtremeView")
		else
			UiDirector.popMakeUiTop("CombatLevelView")
		end
	elseif CombatMO.curBattleCombatUpdate_ == 3 then -- 新的章节中的关卡开启了
		if UiDirector.hasUiByName("CombatSectionView") then
			UiDirector.popMakeUiTop("CombatSectionView")
		end
	elseif CombatMO.curBattleCombatUpdate_ == 4 then -- 开启了第二章节
		self:pop()
	elseif CombatMO.curBattleCombatUpdate_ == 5 then -- 从赏金中跳出来的
		self:pop()
		local view = require("app.view.CombatHunterView").new(HunterBO.lastSectionId, UI_ENTER_FADE_IN_GATE)
		view:push()
	end
	Notify.notify(LOCAL_COMBAT_UPDATE_EVENT)
	Notify.notify(LOCAL_PARTY_COMBAT_UPDATE_EVENT)
	UserBO.triggerFightCheck()

	if CombatMO.curChoseBattleType_ == COMBAT_TYPE_COMBAT and CombatMO.curBattleCombatUpdate_ > 0 then
		UserBO.triggerCombatStar()
	end

	--引导触发
	NewerBO.showNewerGuide()
end

function BattleBalanceView:onFailCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local index = sender.index
	if index == 1 then
		UiDirector.popMakeUiTop("HomeView")

		local work, position, schedulerId, buildingId = BuildBO.getChariotProductInfo()
		local id = buildingId
		if position == 1 then  -- 有一个开工了，则需要进入另外一个
			if buildingId == BUILD_ID_CHARIOT_A then id = BUILD_ID_CHARIOT_B else id = BUILD_ID_CHARIOT_A end
		end
		require("app.view.ChariotInfoView").new(id, CHARIOT_FOR_PRODUCT):push()
	elseif index == 2 then
		UiDirector.popMakeUiTop("HomeView")
		require("app.view.EquipView").new():push()
	elseif index == 3 then
		UiDirector.popMakeUiTop("HomeView")
		require("app.view.ScienceView").new(BUILD_ID_SCIENCE, SCIENCE_FOR_STUDY):push()
	elseif index == 4 then
		local buildingId = BUILD_ID_SCHOOL
		if UserMO.level_ < BuildMO.getOpenLevel(buildingId) then
			local build = BuildMO.queryBuildById(buildingId)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(buildingId), build.name))
			return
		end
		UiDirector.popMakeUiTop("HomeView")
		require("app.view.NewSchoolView").new(buildingId):push()
	elseif index == 5 then
		UiDirector.popMakeUiTop("HomeView")
		local PlayerView = require("app.view.PlayerView")
		PlayerView.new(nil, PLAYER_VIEW_SKILL):push()
	end
end

return BattleBalanceView