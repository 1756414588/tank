
local Fighter = require("app.fight.entity.Fighter")

local V3SubRocket = class("V3SubRocket", Fighter)

-- local FIRE_HIT_ALL = false -- 不管场上有多少敌人，都是全部发射

function V3SubRocket:ctor(battleFor, pos, tankId, tankCount, hp)
	V3SubRocket.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	self.view_ = display.newNode():addTo(self)

	armature_add(IMAGE_ANIMATION .. "v3sub/v3_xb_dd_output.pvr.ccz", IMAGE_ANIMATION .. "v3sub/v3_xb_dd_output.plist", IMAGE_ANIMATION .. "v3sub/v3_xb_dd_output.xml")
	armature_add(IMAGE_ANIMATION .. "v3sub/v3_xb_bz_output.pvr.ccz", IMAGE_ANIMATION .. "v3sub/v3_xb_bz_output.plist", IMAGE_ANIMATION .. "v3sub/v3_xb_bz_output.xml")
	armature_add(IMAGE_ANIMATION .. "v3sub/v3_xb_weiyan_output.pvr.ccz", IMAGE_ANIMATION .. "v3sub/v3_xb_weiyan_output.plist", IMAGE_ANIMATION .. "v3sub/v3_xb_weiyan_output.xml")

	local body = display.newSprite("image/fight/v3sub_body.png"):addTo(self.view_, Fighter.LAYER_BODY)
	body:setAnchorPoint(0.45, 0.5)
	self.bodyView_ = body

	local rocket = display.newSprite("image/fight/v3sub_rocket.png"):addTo(self.bodyView_)
	rocket:setPosition(33, 82)
	self.m_rocket = rocket
end

function V3SubRocket:onFightEnter(callback,isReborn)
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

function V3SubRocket:onActionEnter()
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

function V3SubRocket:onFire(action, doneCallback)
	local targetPos = 0
	-- 后坐力效果
	self:onFireRecoil(targetPos, doneCallback)

	self:onFireEffect(targetPos, function ()
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
	end)
end

function V3SubRocket:onFireRecoil(targetPos, returnCallback)
	local actions = {}
	actions[#actions + 1] = cc.DelayTime:create(2)
	actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)
	self.bodyView_:runAction(transition.sequence(actions))

	self.m_rocket:setVisible(false)
end

function V3SubRocket:onFireEffect(targetPos, doneCallback)
	-- 先用一个特效播放升起动画
	local pos = cc.p(self:getPositionX(), self:getPositionY())
	local ammo = armature_create("v3_xb_dd_output", pos.x - 10, pos.y - 10, 
		function (movementType, movementID, armature) 
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
				if doneCallback then
					doneCallback()
				end
			end
		end)

	ammo:getAnimation():play("start")
	ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)
end


function V3SubRocket:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local tmpRoundIndex = self.roundIndex_
	local round = BattleMO.getRoundAtIndex(tmpRoundIndex)

	self:fireBegin()
	-- 播放攻击动画
	local pos = cc.p(self:getPositionX(), self:getPositionY())
	local ammo = armature_create("v3_xb_dd_output", pos.x, pos.y + 50, 
		function (movementType, movementID, armature) 
			if movementType == MovementEventType.COMPLETE then
			end
		end)

	ManagerSound.playSound("v3_attack_xiaobing")

	ammo.actions = {}
	local targetPos = cc.p(0, 0)
	local targetCount = 0
	for i, v in ipairs(round.action) do
		table.insert(ammo.actions, v)
		local targetTank = BattleMO.getTankByKey(v.target)
		local rival = self:getRival(targetTank.pos_)
		targetPos.x = targetPos.x + rival:getPositionX()
		targetPos.y = targetPos.y + rival:getPositionY()
		targetCount = targetCount + 1
	end
	targetPos.x = targetPos.x / targetCount
	targetPos.y = targetPos.y / targetCount

	ammo.roundIndex = tmpRoundIndex
	-- 播放导弹发射动画
	ammo:getAnimation():play("start1")
	ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)

	-- 同时要跑一个移动动画
	local moveAct = cc.EaseSineIn:create(cc.MoveTo:create(0.5, targetPos))
	ammo:runAction(transition.sequence({moveAct, cc.CallFuncN:create(function(sender) 
			-- 在火箭的位置播放爆炸动画，动画结束后处理受击
			local pos = cc.p(sender:getPositionX(), sender:getPositionY())
			local boom = armature_create("v3_xb_bz_output", pos.x, pos.y, 
			function (movementType, movementID, armature) 
				if movementType == MovementEventType.COMPLETE then
					local actions = armature.actions
					local roundIndex = armature.roundIndex
					for i = 1, #actions do
						local target = actions[i].target
						print("V3SubRocket:onFireAmmo target ==", target)
						local targetTank = BattleMO.getTankByKey(target)
						local rival = self:getRival(targetTank.pos_)
						local rivalPos = cc.p(rival:getPositionX(), rival:getPositionY())

						if firstCallback then firstCallback(targetTank.pos_, roundIndex, i, 1, rivalPos) end
						if arriveCallback then arriveCallback(targetTank.pos_, roundIndex, i, 1, rivalPos) end
						if endCallback then endCallback(targetTank.pos_, roundIndex, i, 1, rivalPos) end
					end

					armature:removeSelf()

					self:fireOver()
				end
			end)

			boom.roundIndex = sender.roundIndex
			boom.actions = sender.actions
			boom:getAnimation():play("start")
			boom:addTo(self:getParent(), Fighter.LAYER_BOMB)

			sender:removeSelf()

			self.m_rocket:setVisible(true)
		end)}))

	local function ammoUpdate(ammo) -- 火箭弹的尾焰
		local flame = armature_create("v3_xb_weiyan_output", ammo:getPositionX(), ammo:getPositionY(), function (movementType, movementID, armature)
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

		-- ammo:setRotation(degree)
		flame:setRotation(degree)

		ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())
	end

	ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())
	local node = display.newNode():addTo(ammo)
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) ammoUpdate(ammo) end)
	node:scheduleUpdate()
end

function V3SubRocket:onRemoveSelf(delay, callback)
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

	self:setVisible(false)

	self:schedule(function ()
		BattleMO.setTankAtPos(self.battleFor_, self.pos_, nil)
		self:onOver()
		if callback then
			callback()
		end

		self:removeSelf()
	end, 1.0)
end

function V3SubRocket:onFightSplit()
	-- body
	if self.battleFor_ == BATTLE_FOR_ATTACK then
		local config = FightAtkFormatConifg[self.pos_]
		self:setPosition(config.offset.x, config.offset.y)
	else
		local config = FightDefFormatConifg[self.pos_]
		self:setPosition(config.offset.x, config.offset.y)
	end
end

return V3SubRocket 
