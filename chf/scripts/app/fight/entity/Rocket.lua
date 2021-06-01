
local Fighter = require("app.fight.entity.Fighter")

local Rocket = class("Rocket", Fighter)

-- local FIRE_HIT_ALL = false -- 不管场上有多少敌人，都是全部发射

function Rocket:ctor(battleFor, pos, tankId, tankCount, hp)
	Rocket.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
end

-- 火箭是面杀伤，在每个round中，所有的action一次处理完
function Rocket:onActionEnter()
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
		local waitRetuen = false -- 是否要等待自身归位

		-- 判断下一个回合是否还是自己
		local nxtRoundIndex = self.roundIndex_ + 1
		local nxtRound = BattleMO.getRoundAtIndex(nxtRoundIndex)
		if nxtRound and nxtRound.key == round.key then -- 如果还有下一个回合,下一个回合还是自己，直接进入下一回合
				self:runAction(transition.sequence({cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
						-- self.roundIndex_ = 0
						-- self.actionIndex_ = 0
						if self.roundEndCallback then self.roundEndCallback() end
					end)}))
		else  -- 否则炮管归位了才能结束当前回合
			for index = 1, #self.weaponViews_ do
				local actions = {}
				actions[#actions + 1] = cc.RotateTo:create(math.abs(90) * TankConfig.getRotationSpeed(self.tankId_)*self.timeScale_, 0)
				if index == 1 then
					actions[#actions + 1] = cc.CallFunc:create(function ()
							-- self.roundIndex_ = 0
							-- self.actionIndex_ = 0
							if self.roundEndCallback then self.roundEndCallback() end
						end)
					actions[#actions + 1] = cc.CallFunc:create(function () 
						self.recoveryAct_ = self.bodyView_:runAction(transition.sequence({cc.RotateTo:create(0.25*self.timeScale_, 0),cc.CallFunc:create(function ()
							self.recoveryAct_ = nil
						end)})) 
					end) -- 身体归位
				end
				self.weaponViews_[index]:runAction(transition.sequence(actions))
			end
		end
	end

	if self.recoveryAct_ then
		self.bodyView_:stopAction(self.recoveryAct_)
		self.recoveryAct_ = nil
	end
	-- 身体旋转90度
	self.bodyView_:runAction(transition.sequence({cc.RotateTo:create(0.25*self.timeScale_, -90), cc.CallFunc:create(function() 
			self:onActionWeaponMove(nil, function()
					self:onFire(nil, function() 
						roundEnd() 
					end)
				end)
		end)}))
end

function Rocket:onFireRecoil(targetPos, returnCallback)
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)
	local step = #round.action  -- 有几个对手要发射
	local stepTime = 0.08  -- 后退每步需要时间
	local stepDis = -5     -- 后退每步的距离
	local delay = 0      -- 后退一步后再等待时间
	local ret = 0.1   -- 后退结束后返回原地的时间

	local delayTime = 0.1
	local passiveSkillEffect = FightEffect.getPassiveSkillEffect(self.roundIndex_)
	gdump(passiveSkillEffect, "onFireRecoil passiveSkillEffect==")
	if passiveSkillEffect ~= nil then
		if #passiveSkillEffect == 0 then
		else
			for i = 1, #passiveSkillEffect do
				local ps = passiveSkillEffect[i]
				if ps.id == 2 then
					-- 每发生一次分裂，该回合多延迟1.5秒结束
					delayTime = delayTime + 2.5
				end
			end
		end
	else
	end

	for index = 1, #self.weaponViews_ do
		local actions = {}
		for index = 1, step do
			actions[#actions + 1] = cc.MoveBy:create(stepTime*self.timeScale_, cc.p(stepDis, 0))
			if not isEqual(delay, 0) then
				actions[#actions + 1] = cc.DelayTime:create(delay)
			end
			actions[#actions + 1] = cc.MoveBy:create(ret, cc.p(-stepDis, 0))
		end
		if index == 1 then
			actions[#actions + 1] = cc.DelayTime:create(delayTime)
			actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)
		end
		self.weaponViews_[index]:runAction(transition.sequence(actions))
	end
end

function Rocket:onFireEffect(targetPos)
end

function Rocket:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)
	-- gdump(round, "[Rocket] fire ammo")

	local tankDB = TankMO.queryTankById(self.tankId_)
	local tankAttack = TankMO.queryTankAttackById(self.tankId_)

	-- armature_add(IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".plist", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".xml")
	local armName = self:addArmature(tankAttack,Fighter.ammoName)

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
		-- gprint("@^^^^^^^fireAmmo^^^^^^",#self.weaponViews_ , index)
		for weaponIndex = 1, #self.weaponViews_ do
			local weapon = self.weaponViews_[weaponIndex]

			local targetTank = nil
			if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then  -- 防守方是世界BOSS
				targetTank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, TANK_BOSS_POSITION_INDEX)
			else
				targetTank = BattleMO.getTankByKey(action.target)
			end
			local rival = self:getRival(targetTank.pos_)

			local ammo = armature_create(armName, 0, 0, function (movementType, movementID, armature) end)
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

			-- local rivalPos = cc.p(rival:getPositionX(), rival:getPositionY())
			local rivalPos = nil
			if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
				local weaponIndex = targetTank:getWeaponIndexByKey(action.target)
				local rivalWeapon = rival:getWeaponByIndex(weaponIndex)
				local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
				rivalPos = rival:getParent():convertToNodeSpace(rivalWP)
			else
				rivalPos = cc.p(rival:getPositionX(), rival:getPositionY())
			end

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
			ammo.roundIndex = self.roundIndex_
			ammo.actionIndex = m_curFireActionIndex
			ammo.rivalPos = rivalPos  -- 打到对方的物理坐标位置
			ammo.firstCallback = firstCallback
			ammo.arriveCallback = arriveCallback
			ammo.endCallback = endCallback

			ammo:runAction(transition.sequence({cc.EaseSineIn:create(cc.BezierTo:create(0.9*self.timeScale_, config)), cc.CallFuncN:create(function(sender)
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

	-- 要向几个对象同时发射
	for actionIndex = 1, #round.action do
		ras[#ras + 1] = cc.CallFunc:create(function() fireAmmo(actionIndex) end)
		ras[#ras + 1] = cc.DelayTime:create(0.08 * 2*self.timeScale_)
	end

	ras[#ras + 1] = cc.CallFunc:create(function()
		if self.ammoCounts <= 0 then
			self:fireOver()
		end	
	end)


	self.bodyView_:runAction(transition.sequence(ras))
end

return Rocket
