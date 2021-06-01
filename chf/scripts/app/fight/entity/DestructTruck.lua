
local Fighter = require("app.fight.entity.Fighter")

local DestructTruck = class("DestructTruck", Fighter)

-- local FIRE_HIT_ALL = false -- 不管场上有多少敌人，都是全部发射

function DestructTruck:ctor(battleFor, pos, tankId, tankCount, hp, bountyBossId)
	DestructTruck.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	self.view_ = display.newNode():addTo(self)

	armature_add(IMAGE_ANIMATION .. "truck/zbkc_baozha_output.pvr.ccz", IMAGE_ANIMATION .. "truck/zbkc_baozha_output.plist", IMAGE_ANIMATION .. "truck/zbkc_baozha_output.xml")

	local body = display.newSprite("image/fight/truck_body.png"):addTo(self.view_, Fighter.LAYER_BODY)
	self.bodyView_ = body
	self.isExploded = false
	self.explode_actions = nil
end

function DestructTruck:onFightEnter(callback,isReborn)
	if isReborn then
		self.isReborn_ = true
	else
		self.isReborn_ = false
	end

	local moveDis = BATTLE_TANK_SPEED * BATTLE_TANK_ENTER_TIME
	if self.battleFor_ == BATTLE_FOR_ATTACK then
		local config = FightAtkFormatConifg[self.pos_]
		if isReborn then
			self:setPosition(config.offset.x, config.offset.y)
		else
			self:setPosition(config.offset.x, config.offset.y - moveDis)
			self:move(BATTLE_TANK_ENTER_TIME, moveDis, callback)
		end
	else
		local config = FightDefFormatConifg[self.pos_]
		if isReborn then
			self:setPosition(config.offset.x, config.offset.y)
		else
			self:setPosition(config.offset.x, config.offset.y + moveDis)
			self:move(BATTLE_TANK_ENTER_TIME, -moveDis, callback)
		end
	end
end

function DestructTruck:onActionEnter()
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
		self:runAction(transition.sequence({cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
				if self.roundEndCallback then self.roundEndCallback() end
			end)}))
	end

	self.bodyView_:runAction(transition.sequence({cc.CallFunc:create(function() 
			self:onActionWeaponMove(nil, function() self:onFire(nil, function() roundEnd() end) end)
		end)}))
end

function DestructTruck:onFire(action, doneCallback)
	local targetPos = 0
	-- 后坐力效果
	self:onFireRecoil(targetPos, doneCallback)

	self:onFireEffect(targetPos)

	-- 发射炮弹
	self:onFireAmmo(targetPos,
		-- beHitPos: 被攻击者的阵型位置, 1-6
		-- roundIndex：ammo发射所在的round的索引
		-- actionIndex: ammo发射所在的action的索引
		-- hurtIndex: 在一次action中ammo的序列
		-- hurtPos: 倍攻击者被ammo击中受到伤害的位置
		function(beHitPos, roundIndex, actionIndex, hurtIndex, hurtPos)  -- 第一次受到伤害
			local rival = self:getRival(beHitPos)
			if rival then
				rival:onHurtFirst(self.pos_, roundIndex, actionIndex, hurtIndex, hurtPos)
			end
		end,
		function(beHitPos, roundIndex, actionIndex, hurtIndex, hurtPos)  -- 每次(包含第一次)受到伤害
			local rival = self:getRival(beHitPos)
			if rival then
				rival:onHurtTime(self.pos_, roundIndex, actionIndex, hurtIndex, hurtPos, self.fighterEffect)
			end
		end,
		function(beHitPos, roundIndex, actionIndex, hurtIndex, hurtPos)  -- 最后一次受到伤害
			local rival = self:getRival(beHitPos)
			if rival then
				rival:onHurtEnd(self.pos_, roundIndex, actionIndex, hurtIndex, hurtPos)
			end
		end)
end

function DestructTruck:onFireRecoil(targetPos, returnCallback)
	local actions = {}
	actions[#actions + 1] = cc.DelayTime:create(2.5)
	actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)
	self.bodyView_:runAction(transition.sequence(actions))
end

function DestructTruck:onFireEffect(targetPos)
end


function DestructTruck:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local tmpRoundIndex = self.roundIndex_
	local round = BattleMO.getRoundAtIndex(tmpRoundIndex)

	self:fireBegin()
	-- 播放攻击动画
	self.explode_actions = {}
	local targetPos = cc.p(0, 0)
	local targetCount = 0
	for i, v in ipairs(round.action) do
		table.insert(self.explode_actions, v)
		local targetTank = BattleMO.getTankByKey(v.target)
		local rival = self:getRival(targetTank.pos_)
		targetPos.x = targetPos.x + rival:getPositionX()
		targetPos.y = targetPos.y + rival:getPositionY()
		targetCount = targetCount + 1
	end
	targetPos.x = targetPos.x / targetCount
	targetPos.y = targetPos.y / targetCount

	-- 同时要跑一个移动动画
	local moveAct = cc.EaseSineIn:create(cc.MoveTo:create(1, targetPos))
	ManagerSound.playSound("bomb_charge")
	self:runAction(transition.sequence({moveAct, cc.CallFuncN:create(function(sender) 
			-- 在火箭的位置播放爆炸动画，动画结束后处理受击
			local pos = cc.p(sender:getPositionX(), sender:getPositionY())
			local boom = armature_create("zbkc_baozha_output", pos.x, pos.y, 
			function (movementType, movementID, armature) 
				if movementType == MovementEventType.COMPLETE then
					local actions = armature.actions
					local roundIndex = armature.roundIndex
					for i = 1, #actions do
						local target = actions[i].target
						print("DestructTruck:onFireAmmo target ==", target)
						local targetTank = BattleMO.getTankByKey(target)
						local rival = self:getRival(targetTank.pos_)
						local rivalPos = cc.p(rival:getPositionX(), rival:getPositionY())

						if firstCallback then firstCallback(targetTank.pos_, roundIndex, i, 1, rivalPos) end
						if arriveCallback then arriveCallback(targetTank.pos_, roundIndex, i, 1, rivalPos) end
						if endCallback then endCallback(targetTank.pos_, roundIndex, i, 1, rivalPos) end
					end
					armature:removeSelf()

					self:fireOver()
					self:onRemoveSelf(false, handler(self, self.sheckRevive))
				end
			end)

			boom.roundIndex = self.roundIndex_
			boom.actions = sender.explode_actions
			boom:getAnimation():play("start")
			boom:addTo(self:getParent(), Fighter.LAYER_BOMB)

			ManagerSound.playSound("bomb_boom")

			self:setVisible(false)
		end)}))
end

function DestructTruck:onDie(roundIndex, actionIndex)
	-- 死亡不做任何处理
end

function DestructTruck:onRemoveSelf(delay, callback)
	-- 再攻击后移除自己
	if delay == nil then
		delay = true
	end

	FightEffect.checkDie(self)

	self:hideFrighten()	-- 消除震慑特效
	if self.tankId_ ~= TANK_BOSS_CONFIG_ID and self.tankId_ ~= TANK_ALTAR_BOSS_CONFIG_ID then
		local tankAttack = TankMO.queryTankAttackById(self.tankId_)
		if tankAttack and tankAttack.dieSound and tankAttack.dieSound ~= "" then
			ManagerSound.playSound(tankAttack.dieSound)
		end
	end

	if delay then
		self:schedule(function ()
			BattleMO.setTankAtPos(self.battleFor_, self.pos_, nil)
			self:onOver()
			if callback then
				callback()
			end

			self:removeSelf()
		end, 1.0)
	else
		BattleMO.setTankAtPos(self.battleFor_, self.pos_, nil)
		self:onOver()
		if callback then
			callback()
		end

		self:removeSelf()
	end
end

function DestructTruck:sheckRevive()
	--检查是否有复活
	local allOver = true
	for index = 1, FIGHT_FORMATION_POS_NUM do
		if BattleMO.hasTankAtPos(self.battleFor_, index) then
			allOver = false
			break
		end
	end
	local list = {}
	if allOver then
		local info = BattleMO.fightData_.reborn[roundIndex]
		if info then
			armature_add(IMAGE_ANIMATION .. "effect/jineng_fadong.pvr.ccz", IMAGE_ANIMATION .. "effect/jineng_fadong.plist", IMAGE_ANIMATION .. "effect/jineng_fadong.xml")
			local reborns = {}
			for k,pos in ipairs(info.pos) do
				local formats,kind = BattleMO.atkFormat_,BATTLE_FOR_ATTACK
				if BattleMO.fightData_.offsensive == BATTLE_OFFENSIVE_DEFEND then
					formats,kind = BattleMO.defFormat_,BATTLE_FOR_DEFEND
				end
				if pos >= 7 then
					pos = pos - 6
					if BattleMO.fightData_.offsensive == BATTLE_OFFENSIVE_ATTACK then
						formats,kind = BattleMO.defFormat_,BATTLE_FOR_DEFEND
					else
						formats,kind = BattleMO.atkFormat_,BATTLE_FOR_ATTACK
					end
				end
				
				local format = {}
				local hp = 0

				if info.tankId[k] then
					format.tankId = info.tankId[k]
					format.count = info.count[k]
					hp = info.hp[k]
					-- hp = BattleMO.getHp(kind, pos)
				else
					format = formats[pos]
					hp = BattleMO.getHp(kind, pos)
				end

				local tank = BattleMO.setTankAtPos(kind, pos, EntityFactory.createTank(kind, pos, format.tankId, format.count, hp))
				tank:setTimeScale(1/BattleMO.getSpeed())
				tank:onFightEnter(nil,1)
				if self.timeScale_ == 1 then
					tank:setVisible(false)
				end
				reborns[#reborns+1] = {kind=kind,pos=pos}
			end

			self:showRebornItem(function(reborns)
				for i,v in ipairs(reborns) do
					local tank = BattleMO.getTankAtPos(v.kind, v.pos)
					if tank then
						tank:setVisible(true)
					end
				end
			end,reborns)
		end
	end
end

return DestructTruck 
