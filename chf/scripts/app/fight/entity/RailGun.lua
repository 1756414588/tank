

local Fighter = require("app.fight.entity.Fighter")

local RailGun = class("RailGun", Fighter)

function RailGun:ctor(battleFor, pos, tankId, tankCount, hp, bountyBossId)
	RailGun.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	self.view_ = display.newNode():addTo(self)

	armature_add(IMAGE_ANIMATION .. "railgun/lcp_xuli_output.pvr.ccz", IMAGE_ANIMATION .. "railgun/lcp_xuli_output.plist", IMAGE_ANIMATION .. "railgun/lcp_xuli_output.xml")
	armature_add(IMAGE_ANIMATION .. "railgun/lcp_output.pvr.ccz", IMAGE_ANIMATION .. "railgun/lcp_output.plist", IMAGE_ANIMATION .. "railgun/lcp_output.xml")
	armature_add(IMAGE_ANIMATION .. "railgun/lcp_gongji_output.pvr.ccz", IMAGE_ANIMATION .. "railgun/lcp_gongji_output.plist", IMAGE_ANIMATION .. "railgun/lcp_gongji_output.xml")

	local body = armature_create("lcp_output", 0, 260,
		function (movementType, movementID, armature)
		end)

	body:addTo(self.view_, Fighter.LAYER_BODY)

	local bubble = display.newSprite(IMAGE_COMMON .. "redplan/shop_talk.png"):addTo(self.view_, Fighter.LAYER_EFFECT)
	bubble:setPosition(20, -100)
	--bubble:setScale()
	local chargeNum = UiUtil.label("0..", 22, COLOR[6]):addTo(bubble)
	chargeNum:setPosition(bubble:getContentSize().width / 2, bubble:getContentSize().height / 2 + 5)
	bubble:setVisible(false)

	self.bodyView_ = body
	self.bubbleView_ = bubble
	self.m_chargeNum = chargeNum
end

function RailGun:onFightEnter(callback,isReborn)
	if isReborn then
		self.isReborn_ = true
	else
		self.isReborn_ = false
	end

	local function wrapMoveCallback()
		-- body
		self.bodyView_:getAnimation():play("start")
		ManagerSound.playSound("railgun_raise_gun")
		if callback then
			callback()
		end
	end


	local moveDis = BATTLE_TANK_SPEED * BATTLE_TANK_ENTER_TIME + 50
	if self.battleFor_ == BATTLE_FOR_ATTACK then
		local config = FightAtkFormatConifg[self.pos_]
		if isReborn then
			self:setPosition(config.offset.x, config.offset.y)
		else
			self:setPosition(config.offset.x, config.offset.y - moveDis)
			self:move(BATTLE_TANK_ENTER_TIME, moveDis, wrapMoveCallback)
		end
	else
		local config = FightDefFormatConifg[self.pos_]
		if isReborn then
			self:setPosition(config.offset.x, config.offset.y)
		else
			self:setPosition(config.offset.x, config.offset.y + moveDis)
			self:move(BATTLE_TANK_ENTER_TIME, -moveDis, wrapMoveCallback)
		end
	end
end


function RailGun:onFightBackstage(callback,isReborn)
	local moveDis = BATTLE_TANK_SPEED * BATTLE_TANK_ENTER_TIME + 50
	if self.battleFor_ == BATTLE_FOR_ATTACK then
		local config = FightAtkFormatConifg[self.pos_]
		self:setPosition(config.offset.x, config.offset.y - moveDis)
	else
		local config = FightDefFormatConifg[self.pos_]
		self:setPosition(config.offset.x, config.offset.y + moveDis)
	end
end

-- 火箭是面杀伤，在每个round中，所有的action一次处理完
function RailGun:onActionEnter()
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

function RailGun:onFire(action, doneCallback)
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

function RailGun:onFireRecoil(targetPos, returnCallback)
	local tmpRoundIndex = self.roundIndex_
	local round = BattleMO.getRoundAtIndex(tmpRoundIndex)
	local action = round.action[1]
	local force = action.force
	local forceCount = action.forceCount

	if force == true then
		-- 如果蓄力已满
		self.bubbleView_:setVisible(false)
	else
		local maxRound = HunterMO.getRailGunChargeRound()
		local remainRound = maxRound - forceCount + 1
		self.bubbleView_:setVisible(true)
		self.m_chargeNum:setString(string.format("%d..", remainRound))
	end

	-- 播放蓄力动画
	local pos = cc.p(self:getPositionX(), self:getPositionY())
	local charge = armature_create("lcp_xuli_output", pos.x, pos.y - 200,
	function (movementType, movementID, armature)
		if movementType == MovementEventType.COMPLETE then
			self.bubbleView_:setVisible(false)
			armature:removeSelf()
			gprint("onFireAmmo armature:removeSelf!!!!!!!!!")
		end
	end)

	if force == false then
		ManagerSound.playSound("railgun_charge")
	end

	charge:getAnimation():playWithIndex(0)
	charge:addTo(self:getParent(), Fighter.LAYER_EFFECT)

	local actions = {}
	actions[#actions + 1] = cc.DelayTime:create(1.0)
	actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)
	self.bodyView_:runAction(transition.sequence(actions))
end

function RailGun:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local tmpRoundIndex = self.roundIndex_
	local round = BattleMO.getRoundAtIndex(tmpRoundIndex)

	self:fireBegin()
	local action = round.action[1]
	if action.force == true then
		-- 播放攻击动画
		local pos = cc.p(self:getPositionX(), self:getPositionY())
		local ammo = armature_create("lcp_gongji_output", pos.x, pos.y - 200, 
			function (movementType, movementID, armature) 
				if movementType == MovementEventType.COMPLETE then
					local actions = armature.actions
					local roundIndex = armature.roundIndex
					for i = 1, #actions do
						local target = actions[i].target
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

		ManagerSound.playSound("railgun_shoot")

		ammo.actions = {}
		for i, v in ipairs(round.action) do
			table.insert(ammo.actions, v)
		end
		ammo.roundIndex = tmpRoundIndex
		ammo:getAnimation():playWithIndex(0)
		ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)
	else
		-- 直接开火结束
		self:fireOver()
	end
end

function RailGun:onRemoveSelf(delay, callback)
	if delay == nil then
		delay = true
	end

	FightEffect.checkDie(self)
	if self.tankId_ ~= TANK_BOSS_CONFIG_ID and self.tankId_ ~= TANK_ALTAR_BOSS_CONFIG_ID then
		local tankAttack = TankMO.queryTankAttackById(self.tankId_)
		if tankAttack and tankAttack.dieSound and tankAttack.dieSound ~= "" then
			ManagerSound.playSound(tankAttack.dieSound)
		end
	end

	self.bodyView_:getAnimation():play("start2")

	self:schedule(function ()
		BattleMO.setTankAtPos(self.battleFor_, self.pos_, nil)
		self:onOver()
		if callback then
			callback()
		end

		self:removeSelf()
	end, 1.0)
end

return RailGun
