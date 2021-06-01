--
-- 新版坦克 (横排攻击)
-- N: 磁能坦克 cineng 
-- MYS
--

local Fighter = require("app.fight.entity.Fighter")

local TankEx = class("TankEx", Fighter)

function TankEx:ctor(battleFor, pos, tankId, tankCount, hp)
	TankEx.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	-- armature_add(IMAGE_ANIMATION .. "tank/cineng_shot.pvr.ccz", IMAGE_ANIMATION .. "tank/cineng_shot.plist", IMAGE_ANIMATION .. "tank/cineng_shot.xml")
	armature_add(IMAGE_ANIMATION .. "tank/cineng_path.pvr.ccz", IMAGE_ANIMATION .. "tank/cineng_path.plist", IMAGE_ANIMATION .. "tank/cineng_path.xml")
	armature_add(IMAGE_ANIMATION .. "tank/cineng_attack.pvr.ccz", IMAGE_ANIMATION .. "tank/cineng_attack.plist", IMAGE_ANIMATION .. "tank/cineng_attack.xml")
end

-- 发射时自身，以及炮管的效果
function TankEx:onFireEffect(targetPos)
end

-- 磁能坦克
-- 播放蓄力动画
function TankEx:onActionEnter()
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	if UserMO.queryFuncOpen(UFP_FRIGHTEN) and table.getn(round.action) == 0 then
			-- 解除震慑 消除震慑动画
		self:hideFrighten()
		-- if doneCallback then doneCallback() end
		BattleMO.fightRoundIndex_ = BattleMO.fightRoundIndex_ + 1
		BattleBO:startRound()
		return
	end

	
	local function ActFun1()
	-- 蓄力
	local effect = armature_create("cineng_attack", self.bodyView_:width() * 0.5,self.bodyView_:height() + 10 ):addTo(self.bodyView_)
	effect:getAnimation():playWithIndex(0)
	end
	local function ActFun2()
		local action = round.action[1]
		self:onFire(action,function ( )
			if self.roundEndCallback then self.roundEndCallback() end
		end)
	end

	local actall = cc.Array:create()
	actall:addObject(transition.sequence({cc.CallFuncN:create(ActFun1)})) -- act1
	actall:addObject(transition.sequence({cc.DelayTime:create(0.5),cc.CallFuncN:create(ActFun2)}))
	self.bodyView_:runAction(cc.Spawn:create(actall))
end

function TankEx:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	self:fireBegin()

	local runactionCount = #round.action

	local mypos = self.bodyView_:convertToWorldSpace(cc.p(self.bodyView_:getContentSize().width / 2 , self.bodyView_:getContentSize().height ))
	mypos = self:getParent():convertToNodeSpace(mypos)
	local function FireAction(fireIndex)

		local action = round.action[fireIndex]
		local ammo = armature_create("cineng_path", 0, 0, function (movementType, movementID, armature) end)
		ammo:getAnimation():playWithIndex(0)
		ammo:setPosition(mypos.x, mypos.y)
		ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)

		local pos = cc.p(0,0)
		local _targetPos = nil
		if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
			local rival = self:getRival(targetPos)
			local rivalWeapon = rival:getWeaponByIndex(targetPos)
			local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			pos = rival:getParent():convertToNodeSpace(rivalWP)
			_targetPos = targetPos
		else
			local targetTank = BattleMO.getTankByKey(action.target)
			local rival = self:getRival(targetTank.pos_)
			pos = cc.p(rival:getPositionX(), rival:getPositionY())
			_targetPos = targetTank.pos_
		end

		ammo.targetPos = _targetPos  -- ammo打到的对方的阵型位置，值为1-6
		ammo.roundIndex = self.roundIndex_
		ammo.actionIndex = fireIndex
		ammo.rivalPos = pos  -- 物理坐标位置
		ammo:runAction(transition.sequence({cc.MoveTo:create(0.3*self.timeScale_, pos), cc.CallFuncN:create(function (sender)
			if firstCallback then firstCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
			if arriveCallback then arriveCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
			if endCallback then endCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end

			sender:removeSelf()

			runactionCount = runactionCount - 1
			if runactionCount <= 0 then
				self:fireOver()
			end
		end)}))
	end

	local actionRun = {}
	for actionIndex = 1, #round.action do
		actionRun[#actionRun + 1] = cc.CallFunc:create(function() FireAction(actionIndex) end)
	end

	self.bodyView_:runAction(transition.sequence(actionRun))
end

return TankEx