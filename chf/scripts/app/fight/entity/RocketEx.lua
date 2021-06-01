--
-- 新版火箭 (全军攻击)
-- N: (主脑坦克) zhunao 
-- MYS
--

local Fighter = require("app.fight.entity.Fighter")

local RocketEx = class("RocketEx", Fighter)

function RocketEx:ctor(battleFor, pos, tankId, tankCount, hp)
	RocketEx.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	armature_add(IMAGE_ANIMATION .. "tank/zhunao_all.pvr.ccz", IMAGE_ANIMATION .. "tank/zhunao_all.plist", IMAGE_ANIMATION .. "tank/zhunao_all.xml")
	armature_add(IMAGE_ANIMATION .. "tank/zhunao_path.pvr.ccz", IMAGE_ANIMATION .. "tank/zhunao_path.plist", IMAGE_ANIMATION .. "tank/zhunao_path.xml")
	armature_add(IMAGE_ANIMATION .. "tank/zhunao_shot.pvr.ccz", IMAGE_ANIMATION .. "tank/zhunao_shot.plist", IMAGE_ANIMATION .. "tank/zhunao_shot.xml")
	-- armature_add(IMAGE_ANIMATION .. "tank/zhunao_attack.pvr.ccz", IMAGE_ANIMATION .. "tank/zhunao_attack.plist", IMAGE_ANIMATION .. "tank/zhunao_attack.xml")
end

function RocketEx:onActionEnter()
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)


	if UserMO.queryFuncOpen(UFP_FRIGHTEN) and table.getn(round.action) == 0 then
			-- 解除震慑 消除震慑动画
		self:hideFrighten()
		-- if doneCallback then doneCallback() end
		BattleMO.fightRoundIndex_ = BattleMO.fightRoundIndex_ + 1
		BattleBO:startRound()
		return
	end

	self:onFire(nil, nil)
end

function RocketEx:onFireRecoil(targetPos, returnCallback)
end

function RocketEx:onFireEffect(targetPos)
	local effect = armature_create("zhunao_shot", self.bodyView_:width() * 0.5,self.bodyView_:height() * 0.5, function(movementType, movementID, armature) 
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end):addTo(self.bodyView_)
	effect:getAnimation():playWithIndex(0)
end

function RocketEx:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	self:fireBegin()

	-- 自己的位置
	local mypos = self.bodyView_:convertToWorldSpace(cc.p(self.bodyView_:getContentSize().width / 2 , self.bodyView_:getContentSize().height /2))
	mypos = self:getParent():convertToNodeSpace(mypos)

	-- 终点位置
	local _targetPos = nil
	if self.battleFor_ == BATTLE_FOR_DEFEND then
			_targetPos = cc.p(0, 0 - display.cy * 0.5)
		else
			_targetPos = cc.p(0, 0 + display.cy * 0.5)
		end

	local function doBlastAll()
		for actionIndex = 1, #round.action do
			local action = round.action[actionIndex]

			local targetTank = nil
			local pos = cc.p(0,0)
			if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then  -- 防守方是世界BOSS
				targetTank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, TANK_BOSS_POSITION_INDEX)
				local weaponIndex = targetTank:getWeaponIndexByKey(action.target)
				local rival = self:getRival(targetTank.pos_)
				local rivalWeapon = rival:getWeaponByIndex(weaponIndex)
				local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
				pos = rival:getParent():convertToNodeSpace(rivalWP)
			else
				targetTank = BattleMO.getTankByKey(action.target)
				local rival = self:getRival(targetTank.pos_)
				pos = cc.p(rival:getPositionX(), rival:getPositionY())
			end

			-- -- local targetTank = BattleMO.getTankByKey(action.target)
			-- local rival = self:getRival(targetTank.pos_)
			-- local pos = cc.p(rival:getPositionX(), rival:getPositionY())

			local targetPos_ = targetTank.pos_
			local roundIndex = self.roundIndex_
			local actionIndex = actionIndex
			local rivalPos = pos

			if firstCallback then firstCallback(targetPos_, roundIndex, actionIndex, 1, rivalPos) end
			if arriveCallback then arriveCallback(targetPos_, roundIndex, actionIndex, 1, rivalPos) end
			if endCallback then endCallback(targetPos_, roundIndex, actionIndex, 1, rivalPos) end
		end
	end

	local function doBlast()
		local ammo2 = armature_create("zhunao_all", _targetPos.x, _targetPos.y, function (movementType, movementID, armature) 
				if movementType == MovementEventType.COMPLETE then
					-- doBlastAll() 
					armature:removeSelf()
				end
			end):addTo(self:getParent(), Fighter.LAYER_EFFECT)
		ammo2:getAnimation():playWithIndex(0)
		self:fireOver()
	end

	-- 这里要检查一下是不是发生了分裂被动技能, 如果发生了，这一回合要延迟结束
	local delayTime = 1
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

	local function ActionEnd()
		if self.roundEndCallback then self.roundEndCallback() end
	end

	local function doFire(lastAmmo)
		lastAmmo:removeSelf()

		local actall = cc.Array:create()
		actall:addObject(transition.sequence({cc.CallFuncN:create(doBlast)})) -- act1
		actall:addObject(transition.sequence({cc.DelayTime:create(0.25),cc.CallFuncN:create(doBlastAll)}))
		self.bodyView_:runAction( transition.sequence({cc.Spawn:create(actall), cc.DelayTime:create(delayTime), cc.CallFuncN:create(ActionEnd)}) )
	end

	local ammo = armature_create("zhunao_path", 0, 0, function (movementType, movementID, armature) end)--:addTo(self:getParent(), 10)
	ammo:getAnimation():playWithIndex(0)
	ammo:setPosition(mypos.x, mypos.y)
	ammo:addTo(self:getParent(), Fighter.LAYER_EFFECT)
	local deltaX = _targetPos.x - ammo:getPositionX()
	local deltaY = _targetPos.y - ammo:getPositionY()
	local degree = math.deg(math.atan2(deltaX, deltaY))
	ammo:setRotation(degree)
	ammo:runAction(transition.sequence({cc.MoveTo:create(0.4*self.timeScale_, _targetPos),cc.CallFuncN:create(function(sender) doFire(sender) end)}))
end


return RocketEx