

local Fighter = require("app.fight.entity.Fighter")

local Boss = class("Boss", Fighter)

function Boss:ctor(battleFor, pos, tankId, tankCount, hp)
	Boss.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
end

-- 火箭是面杀伤，在每个round中，所有的action一次处理完
function Boss:onActionEnter()
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	if UserMO.queryFuncOpen(UFP_FRIGHTEN) and table.getn(round.action) == 0 then
			-- 解除震慑 消除震慑动画
		self:hideFrighten()
		-- if doneCallback then doneCallback() end
		BattleMO.fightRoundIndex_ = BattleMO.fightRoundIndex_ + 1
		BattleBO:startRound()
		return
	end

	local function roundEnd()
		-- local waitRetuen = false -- 是否要等待自身归位

		-- -- 判断下一个回合是否还是自己
		-- local nxtRoundIndex = self.roundIndex_ + 1
		-- local nxtRound = BattleMO.getRoundAtIndex(nxtRoundIndex)
		-- if nxtRound and nxtRound.key == round.key then -- 如果还有下一个回合,下一个回合还是自己，直接进入下一回合
				self:runAction(transition.sequence({cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
						-- self.roundIndex_ = 0
						-- self.actionIndex_ = 0
						if self.roundEndCallback then self.roundEndCallback() end
					end)}))
		-- else  -- 否则炮管归位了才能结束当前回合
		-- 	for index = 1, #self.weaponViews_ do
		-- 		local actions = {}
		-- 		actions[#actions + 1] = cc.RotateTo:create(math.abs(90) * TankConfig.getRotationSpeed(self.tankId_), 0)
		-- 		if index == 1 then
		-- 			actions[#actions + 1] = cc.CallFunc:create(function ()
		-- 					self.roundIndex_ = 0
		-- 					self.actionIndex_ = 0
		-- 					if self.roundEndCallback then self.roundEndCallback() end
		-- 				end)
		-- 			actions[#actions + 1] = cc.CallFunc:create(function () self.bodyView_:runAction(cc.RotateTo:create(0.25, 0)) end) -- 身体归位
		-- 		end
		-- 		self.weaponViews_[index]:runAction(transition.sequence(actions))
		-- 	end
		-- end
	end

	self.bodyView_:runAction(transition.sequence({cc.CallFunc:create(function() 
			self:onActionWeaponMove(nil, function() self:onFire(nil, function() roundEnd() end) end)
		end)}))
end

function Boss:onFireRecoil(targetPos, returnCallback)
	armature_add(IMAGE_ANIMATION .. "battle/boss_fire_recoil.pvr.ccz", IMAGE_ANIMATION .. "battle/boss_fire_recoil.plist", IMAGE_ANIMATION .. "battle/boss_fire_recoil.xml")
	-- 后坐力效果
	local recoil = armature_create("boss_fire_recoil", self.bodyView_:getContentSize().width / 2, 10, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
				end
		end)
	recoil:getAnimation():playWithIndex(0)
	recoil:addTo(self.bodyView_, -1)

	local actions = {}
	actions[#actions + 1] = cc.MoveBy:create(0.16, cc.p(0, -20))
	actions[#actions + 1] = cc.DelayTime:create(0.02)
	actions[#actions + 1] = cc.MoveBy:create(0.16, cc.p(0, 20))  -- 返回原位
	actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)

	local weapon = self.weaponViews_[#self.weaponViews_]
	weapon:runAction(transition.sequence(actions))
end

function Boss:onFireEffect(targetPos)
end

function Boss:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local tmpRoundIndex = self.roundIndex_

	local round = BattleMO.getRoundAtIndex(tmpRoundIndex)
	-- gdump(round, "[Boss] fire ammo:" .. tmpRoundIndex)

	local copyTankId = 30 -- 世界BOSS发射的ammo效果参考tank的id
	local tankDB = TankMO.queryTankById(copyTankId)
	local tankAttack = TankMO.queryTankAttackById(copyTankId)

	armature_add(IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".plist", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".xml")

	self:fireBegin()

	local m_curFireActionIndex = 1

	self.ammoCounts = #round.action

	local function ammoUpdate(ammo) -- 火箭弹的尾焰
		armature_add(IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.plist", IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.xml")
		local flame = armature_create("bt_ammo_4_flame", ammo:getPositionX(), ammo:getPositionY(), function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
			end)
		flame:getAnimation():playWithIndex(0)
		flame:addTo(self:getParent(), Fighter.LAYER_BOMB)


		local lastPos = ammo.lastPos
		local deltaX = ammo:getPositionX() - lastPos.x
		local deltaY = ammo:getPositionY() - lastPos.y
		local degree = math.deg(math.atan2(deltaX, deltaY))
		ammo:setRotation(degree)
		flame:setRotation(degree)

		ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())
	end


	local function fireAmmo(index)
		local action = round.action[m_curFireActionIndex]

		-- for weaponIndex = 1, #self.weaponViews_ do
		for weaponIndex = 1, 1 do
			local weapon = nil
			if self.tankId_ == TANK_BOSS_CONFIG_ID or self.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then
				weapon = self.weaponViews_[#self.weaponViews_]
			else
				weapon = self.weaponViews_[weaponIndex]
			end

			local targetTank = nil
			-- if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then  -- 防守方是世界BOSS
			-- 	targetTank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, TANK_BOSS_POSITION_INDEX)
			-- else
				targetTank = BattleMO.getTankByKey(action.target)
			-- end
			local rival = self:getRival(targetTank.pos_)

			local ammo = armature_create(tankAttack.ammoName, 0, 0, function (movementType, movementID, armature) end)
			ammo:getAnimation():playWithIndex(0)
			ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)

			local pos = nil
			if m_curFireActionIndex == 1 or m_curFireActionIndex == 3 or m_curFireActionIndex == 5 then  -- 根据actionIndex使每次发射的炮弹错开位置
				pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2 - 20, weapon:getContentSize().height + 20))
				pos = self:getParent():convertToNodeSpace(pos)
				ammo:setPosition(pos.x, pos.y)
			else
				pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2 + 20, weapon:getContentSize().height + 20))
				pos = self:getParent():convertToNodeSpace(pos)
				ammo:setPosition(pos.x, pos.y)
			end

			local rivalPos = nil
			-- if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
			-- 	local weaponIndex = targetTank:getWeaponIndexByKey(action.target)
			-- 	local rivalWeapon = rival:getWeaponByIndex(weaponIndex)
			-- 	local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			-- 	rivalPos = rival:getParent():convertToNodeSpace(rivalWP)
			-- else
				rivalPos = cc.p(rival:getPositionX(), rival:getPositionY())
			-- end

			local config = ccBezierConfig()
			config.endPosition = rivalPos
			local delta = 0
			if self.battleFor_ == BATTLE_FOR_ATTACK then
				if self.pos_ == 1 or self.pos_ == 4 then
					config.controlPoint_1 = cc.p(pos.x - 150, pos.y + 180)
					config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y - 180)
				elseif self.pos_ == 3 or self.pos_ == 5 then
					config.controlPoint_1 = cc.p(pos.x - 150, pos.y + 180)
					config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y - 180)
				else
					config.controlPoint_1 = cc.p(pos.x + 150, pos.y + 180)
					config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y - 180)
				end
			else
				config.controlPoint_1 = cc.p(pos.x - 150, pos.y - 180)
				config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y + 180)
			end

			ammo.targetPos = targetTank.pos_  -- ammo打到的对方的阵型位置，值为1-6
			ammo.roundIndex = tmpRoundIndex
			ammo.actionIndex = m_curFireActionIndex
			ammo.rivalPos = rivalPos  -- 打到对方的物理坐标位置
			ammo.firstCallback = firstCallback
			ammo.arriveCallback = arriveCallback
			ammo.endCallback = endCallback

			ammo:runAction(transition.sequence({cc.EaseSineIn:create(cc.BezierTo:create(0.9 * self.timeScale_, config)), cc.CallFuncN:create(function(sender)
					if sender.firstCallback then sender.firstCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
					if sender.arriveCallback then sender.arriveCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
					if sender.endCallback then sender.endCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end

					sender:removeSelf()

					self.ammoCounts = self.ammoCounts - 1
					if self.ammoCounts <= 0 then
						self:fireOver()
					end					
				end)}))
			ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())

			local node = display.newNode():addTo(ammo)
			nodeExportComponentMethod(node)
			node:setNodeEventEnabled(true)
			node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) ammoUpdate(ammo) end)
			node:scheduleUpdate()

			if tankAttack.fireSound and tankAttack.fireSound ~= "" then
				ManagerSound.playSound(tankAttack.fireSound)
			end
		end
		m_curFireActionIndex = m_curFireActionIndex + 1
	end

	local ras = {}
	for actionIndex = 1, #round.action do  -- 要向几个对象同时发射
		ras[#ras + 1] = cc.CallFunc:create(function() fireAmmo(actionIndex) end)
		ras[#ras + 1] = cc.DelayTime:create(0.08 * 2 * self.timeScale_)
	end
	ras[#ras + 1] = cc.CallFunc:create(function()
		if self.ammoCounts <= 0 then
			self:fireOver()
		end	
	end)
	self.bodyView_:runAction(transition.sequence(ras))
end

function Boss:onDie(roundIndex, actionIndex)
	local round = BattleMO.getRoundAtIndex(roundIndex)
	local action = round.action[actionIndex]
	local weaponIndex = self:getWeaponIndexByKey(action.target)

	-- print("Boss:onDie: weaponIndex:", weaponIndex)

	self:onWeaponBroken(weaponIndex)
	self:onWeaponDie(weaponIndex)

	if weaponIndex == 7 then
		self:runAction(transition.sequence({cc.DelayTime:create(0.6), cc.CallFunc:create(function() Boss.super.onDie(self, roundIndex, actionIndex) end)}))
	end
end

-- function Boss:onWeaponHurt(roundIndex, actionIndex, hurtIndex)
-- 	local round = BattleMO.getRoundAtIndex(roundIndex)
-- 	local action = round.action[actionIndex]
-- 	gdump(action, "[Boss] onWeaponHurt tttttttttttt")

-- 	local weaponIndex = self:getWeaponIndexByKey(action.target)
-- 	local weapon = self.weaponViews_[weaponIndex]

-- 	if weaponIndex ~= 1 and weaponIndex ~= 7 then return end

-- 	if true then return end
-- end

function Boss:onWeaponBroken(weaponIndex)
	if weaponIndex == 0 then return end

	local indics = {}

	if weaponIndex <= 4 then
		indics[#indics + 1] = weaponIndex
	elseif weaponIndex == 5 then  -- 要同时爆两个
		indics[#indics + 1] = 5
		indics[#indics + 1] = 6
	elseif weaponIndex == 7 then
		indics[#indics + 1] = 7
	end

	if #self.weaponViews_ < weaponIndex then
		indics = { #self.weaponViews_}
	end
	
	for index = 1, #indics do
		local weaponIndex = indics[index]
		local weapon = self.weaponViews_[weaponIndex]

		local brokenName = ""
		if weaponIndex == #self.weaponViews_ then
			brokenName = "boss_gun_boken_big"
		else
			brokenName = "boss_gun_boken_small"
		end

		-- 爆炸效果
		armature_add(IMAGE_ANIMATION .. "battle/boss_gun_boken.pvr.ccz", IMAGE_ANIMATION .. "battle/boss_gun_boken.plist", IMAGE_ANIMATION .. "battle/" .. brokenName .. ".xml")
		local broken = armature_create(brokenName, weapon:getPositionX(), weapon:getPositionY(),
			function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
				end
			end)
		broken:getAnimation():playWithIndex(0)
		broken:addTo(weapon:getParent(), 3)
	end
end

function Boss:onWeaponDie(weaponIndex)
	if weaponIndex == 0 then return end

	local indics = {}

	if weaponIndex <= 4 then
		indics[#indics + 1] = weaponIndex
	elseif weaponIndex == 5 then  -- 要同时die两个
		indics[#indics + 1] = 5
		indics[#indics + 1] = 6
	elseif weaponIndex == 7 then
		indics[#indics + 1] = 7
	end

	if #self.weaponViews_ < weaponIndex then
		indics = { #self.weaponViews_}
	end

	for index = 1, #indics do
		local weaponIndex = indics[index]
		local weapon = self.weaponViews_[weaponIndex]

		local dieName = ""
		if weaponIndex == #self.weaponViews_ then
			dieName = "boss_gun_die_big"
		else
			dieName = "boss_gun_die_small"
		end

		weapon.die = true
		weapon:setVisible(false)

		-- 炮管消失后的黑烟效果
		armature_add(IMAGE_ANIMATION .. "battle/boss_gun_die.pvr.ccz", IMAGE_ANIMATION .. "battle/boss_gun_die.plist", IMAGE_ANIMATION .. "battle/" .. dieName .. ".xml")
		local die = armature_create(dieName, weapon:getPositionX(), weapon:getPositionY(),
			function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
		die:getAnimation():playWithIndex(0)
		die:addTo(weapon:getParent(), 2)
	end
end

function Boss:getWeaponWorldPosition(weaponIndex)
	local config = TankConfig.getConfigBy(self.tankId_)
	local offset = config.gun[weaponIndex]

	local weapon = self.weaponViews_[weaponIndex]

	local pos = weapon:convertToWorldSpace(cc.p(0, 0))
	-- local pos = cc.p(weapon:getPositionX(), weapon:getPositionY())
	local pos = self:getParent():convertToNodeSpace(pos)
	return pos
end

function Boss:getWeaponIndexByKey(key)
	local index = 1
	if key == 2 or key == 4 or key == 6 or key == 8 or key == 10 then
		index = key / 2
	elseif key == 12 then
		index = 7
	end

	if index > #self.weaponViews_ then
		index = #self.weaponViews_
	end

	return index
end

return Boss