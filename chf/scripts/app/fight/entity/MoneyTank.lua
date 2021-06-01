--
-- Author: Gss
-- Date: 2018-08-20 17:46:16
--
-- 四阶金币车坦克(横排攻击)
local FRONT_ROW = 1
local BACK_ROW = 2
local WORLD_BOSS_ROW = 3

local Fighter = require("app.fight.entity.Fighter")

local MoneyTank = class("MoneyTank", Fighter)

function MoneyTank:ctor(battleFor, pos, tankId, tankCount, hp)
	MoneyTank.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	armature_add(IMAGE_ANIMATION .. "tank/gltk_dilie.pvr.ccz", IMAGE_ANIMATION .. "tank/gltk_dilie.plist", IMAGE_ANIMATION .. "tank/gltk_dilie.xml")
	armature_add(IMAGE_ANIMATION .. "tank/gltk_guangshu.pvr.ccz", IMAGE_ANIMATION .. "tank/gltk_guangshu.plist", IMAGE_ANIMATION .. "tank/gltk_guangshu.xml")
	armature_add(IMAGE_ANIMATION .. "tank/gltk_xuli.pvr.ccz", IMAGE_ANIMATION .. "tank/gltk_xuli.plist", IMAGE_ANIMATION .. "tank/gltk_xuli.xml")
end

function MoneyTank:onFireRecoil(targetPos, returnCallback)
	local tankDB = TankMO.queryTankById(self.tankId_)

	local tankAttack = TankMO.queryTankAttackById(self.tankId_)
	-- dump(tankAttack)
	local recoil = json.decode(tankAttack.recoil)
	-- dump(recoil)

	local step = recoil[1]  -- 后退步数
	local stepTime = recoil[2]  -- 后退每步需要时间
	local stepDis = recoil[3]     -- 后退每步的距离
	local delay = recoil[4]      -- 后退一步后再等待时间
	local ret = recoil[5]   -- 后退结束后返回原地的时间

	local actions = {}
	for index = 1, step do
		actions[#actions + 1] = cc.MoveBy:create(stepTime*self.timeScale_, cc.p(0, stepDis))
		if not isEqual(delay, 0) then
			actions[#actions + 1] = cc.DelayTime:create(delay*self.timeScale_)
		end
	end
	actions[#actions + 1] = cc.MoveBy:create(ret*self.timeScale_, cc.p(0, - step * stepDis))  -- 返回原位

	local delayTime = 1.5
	-- 这里要检查一下是不是发生了分裂被动技能, 如果发生了，这一回合要延迟结束
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

	actions[#actions + 1] = cc.DelayTime:create(delayTime * self.timeScale_)
	actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)
	self.bodyView_:runAction(transition.sequence(actions))
end

-- 发射时自身，以及炮管的效果
function MoneyTank:onFireEffect(targetPos)
end

function MoneyTank:onActionEnter()
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	if UserMO.queryFuncOpen(UFP_FRIGHTEN) and table.getn(round.action) == 0 then
			-- 解除震慑 消除震慑动画
		self:hideFrighten()
		-- if doneCallback then doneCallback() end
		BattleMO.fightRoundIndex_ = BattleMO.fightRoundIndex_ + 1
		BattleBO:startRound()
		return
	end

	local function ActFun2()
		local action = round.action[1]
		self:onFire(action,function ()
			if self.roundEndCallback then self.roundEndCallback() end
		end)
	end

	local function ActFun1()
		-- 蓄力
		local weapon = self.weaponViews_[1]
		local mypos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2 , weapon:getContentSize().height))
		mypos = self:getParent():convertToNodeSpace(mypos)
		local effect = armature_create("gltk_xuli", mypos.x, mypos.y, function (movementType, movementID, armature)
			-- body
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end):addTo(self:getParent(), Fighter.LAYER_BOMB+2)
		effect:getAnimation():playWithIndex(0)
	end

	local actall = cc.Array:create()
	actall:addObject(transition.sequence({cc.DelayTime:create(0.5),cc.CallFuncN:create(ActFun1)})) -- act1
	actall:addObject(transition.sequence({cc.DelayTime:create(1.5),cc.CallFuncN:create(ActFun2)}))
	self.bodyView_:runAction(cc.Spawn:create(actall))
end

function MoneyTank:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	self:fireBegin()

	-- 获取攻击的目标数量
	local targetCount = #round.action
	local allTargets = {}
	for i = 1, targetCount do
		local target = round.action[i].target
		local targetTank = BattleMO.getTankByKey(target)
		local pos
		if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then
			local rival = self:getRival(targetPos)
			local rivalWeapon = rival:getWeaponByIndex(targetPos)
			local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			pos = rival:getParent():convertToNodeSpace(rivalWP)
			table.insert(allTargets, {actionIndex=i, targetPos=targetPos, rivalPos=pos, roundIndex=self.roundIndex_})
		else
			pos = cc.p(targetTank:getPositionX(), targetTank:getPositionY())
			table.insert(allTargets, {actionIndex=i, targetPos=targetTank.pos_, rivalPos=pos, roundIndex=self.roundIndex_})
		end
	end

	local mypos = self.bodyView_:convertToWorldSpace(cc.p(self.bodyView_:getContentSize().width / 2 , self.bodyView_:getContentSize().height ))
	mypos = self:getParent():convertToNodeSpace(mypos)
	local function FireAction(fireIndex)
		local action = round.action[fireIndex]
		local ammo = armature_create("gltk_guangshu", 0, 0, function (movementType, movementID, armature) end)
		ammo:getAnimation():playWithIndex(0)
		local startPos = cc.p(mypos.x, mypos.y)
		if self.battleFor_ == BATTLE_FOR_ATTACK then
			startPos.y = startPos.y - 30
		elseif self.battleFor_ == BATTLE_FOR_DEFEND then
			startPos.y = startPos.y + 30
		end
		ammo:setPosition(startPos)
		ammo:addTo(self:getParent(), Fighter.LAYER_BOMB+1)

		local pos = cc.p(0,0)
		local _targetPos = nil
		-- 前判断攻击的是前排还是后排
		local rowTag = nil
		local endStartPos = nil
		local endFinishPos = nil
		if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
			local rival = self:getRival(targetPos)
			local rivalWeapon = rival:getWeaponByIndex(targetPos)
			local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			-- pos = rival:getParent():convertToNodeSpace(rivalWP)
			_targetPos = targetPos
			rowTag = WORLD_BOSS_ROW

			endStartPos = FightDefFormatConifg[4].offset
			endFinishPos = FightDefFormatConifg[6].offset

			pos.x = (endStartPos.x + endFinishPos.x) * 0.5
			pos.y = (endStartPos.y + endFinishPos.y) * 0.5
		else
			local targetTank = BattleMO.getTankByKey(action.target)
			local rival = self:getRival(targetTank.pos_)
			if action.target <= 6 then
				rowTag = FRONT_ROW
				_targetPos = 2
			else
				rowTag = BACK_ROW
				_targetPos = 5
			end

			local config
			if self.battleFor_ == BATTLE_FOR_ATTACK then
				config = FightDefFormatConifg[_targetPos]
				if rowTag == FRONT_ROW then
					endStartPos = FightDefFormatConifg[1].offset
					endFinishPos = FightDefFormatConifg[3].offset
				else
					endStartPos = FightDefFormatConifg[4].offset
					endFinishPos = FightDefFormatConifg[6].offset
				end
			else
				config = FightAtkFormatConifg[_targetPos]
				if rowTag == FRONT_ROW then
					endStartPos = FightAtkFormatConifg[1].offset
					endFinishPos = FightAtkFormatConifg[3].offset
				else
					endStartPos = FightAtkFormatConifg[4].offset
					endFinishPos = FightAtkFormatConifg[6].offset
				end
			end
			pos = cc.p(config.offset.x, config.offset.y)
		end

		local startVec = cc.p(endStartPos.x - mypos.x, endStartPos.y - mypos.y)
		local finishVec = cc.p(endFinishPos.x - mypos.x, endFinishPos.y - mypos.y)

		local startLen = math.sqrt(startVec.x * startVec.x + startVec.y * startVec.y)
		local finishLen = math.sqrt(finishVec.x * finishVec.x + finishVec.y * finishVec.y)

		local cosalpha = (startVec.x * finishVec.x + startVec.y * finishVec.y) / (startLen * finishLen)
		local r = math.deg(math.acos(cosalpha))
		if self.battleFor_ == BATTLE_FOR_DEFEND then
			r = -r
		end

		-- ammo.targetPos = _targetPos  -- ammo打到的对方的阵型位置，值为1-6
		ammo.roundIndex = self.roundIndex_
		ammo.actionIndex = fireIndex
		-- ammo.rivalPos = pos  -- 物理坐标位置

		-- 设置好初始的角度
		local normX = startVec.x / startLen
		-- local normY = startVec.y / startLen
		local bulletLen = 590
		-- pos.x = pos.x - bulletLen * normX
		-- pos.y = pos.y - bulletLen * normY
		local rOri = math.deg(math.acos(normX))
		rOri = 90 - rOri
		if self.battleFor_ == BATTLE_FOR_DEFEND then
			ammo:setRotation(180 - rOri)
		else
			ammo:setRotation(rOri)
		end

		local origScale = startLen / bulletLen
		ammo:setScale(origScale)

		local ruleScale = (endStartPos.y - mypos.y) / bulletLen

		ammo:runAction(transition.sequence({cc.RotateBy:create(0.66*self.timeScale_, r), cc.CallFuncN:create(function (sender)
			for i, v in ipairs(allTargets) do
				if firstCallback then 
					firstCallback(v.targetPos, v.roundIndex, v.actionIndex, 1, v.rivalPos)
				end
				if arriveCallback then
					arriveCallback(v.targetPos, v.roundIndex, v.actionIndex, 1, v.rivalPos) 
				end
				if endCallback then 
					endCallback(v.targetPos, v.roundIndex, v.actionIndex, 1, v.rivalPos) 
				end
			end

			sender:removeSelf()

			self:fireOver()
		end)}))


		local function ammoUpdate(ammo) -- 火箭弹的尾焰
			-- 更新ammo的scale
			local rot = ammo:getRotation()
			local rotAbs = math.abs(rot)
			local curScale = ruleScale / math.cos(math.rad(rotAbs))
			ammo:setScale(curScale)
		end

		local node = display.newNode():addTo(ammo)
		nodeExportComponentMethod(node)
		node:setNodeEventEnabled(true)
		node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) ammoUpdate(ammo) end)
		node:scheduleUpdate()

		local earthquake = armature_create("gltk_dilie", 0, 0, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end)
		earthquake:getAnimation():playWithIndex(0)
		earthquake:setPosition(pos.x, pos.y)
		earthquake:addTo(self:getParent(), Fighter.LAYER_BOMB)
	end

	FireAction(1)
end

return MoneyTank
