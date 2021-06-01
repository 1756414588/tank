--
-- 新版战车 (单一攻击)
-- N: 磁电坦克 cidian 
-- MYS
--

local Fighter = require("app.fight.entity.Fighter")

local ChariotEx = class("ChariotEx", Fighter)

function ChariotEx:ctor(battleFor, pos, tankId, tankCount, hp)
	ChariotEx.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	armature_add(IMAGE_ANIMATION .. "tank/cidian_attack.pvr.ccz", IMAGE_ANIMATION .. "tank/cidian_attack.plist", IMAGE_ANIMATION .. "tank/cidian_attack.xml")
	armature_add(IMAGE_ANIMATION .. "tank/cidian_path.pvr.ccz", IMAGE_ANIMATION .. "tank/cidian_path.plist", IMAGE_ANIMATION .. "tank/cidian_path.xml")
	-- armature_add(IMAGE_ANIMATION .. "tank/cidian_shot.pvr.ccz", IMAGE_ANIMATION .. "tank/cidian_shot.plist", IMAGE_ANIMATION .. "tank/cidian_shot.xml")
end

function ChariotEx:onFireEffect(targetPos)
end

function ChariotEx:onFire(action, doneCallback)
	local targetPos = 0

	if self.tankId_ == TANK_BOSS_CONFIG_ID or self.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then
	else
		local tankDB = TankMO.queryTankById(self.tankId_)
		if tankDB.type == TANK_TYPE_ROCKET then
		else
			if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then  -- 防守方是世界BOSS
				local targetTank = self:getRival(TANK_BOSS_POSITION_INDEX)
				targetPos = targetTank:getWeaponIndexByKey(action.target)  -- BOSS炮管的位置
			else
				local targetTank = BattleMO.getTankByKey(action.target)
				if not targetTank then
					gdump(action, "Fighter:onActionEnter target is NULL!!!!")
					gprint("Fighter:onActionEnter", action.target, self.actionIndex_)
				end

				targetPos = targetTank.pos_
			end
		end
	end




	-- local targetTank = BattleMO.getTankByKey(action.target)
	-- targetPos = targetTank.pos_

	-- self:onFireEffect(targetPos)

	local function ChariotFirstCallback(beHitPos, roundIndex, actionIndex, hurtIndex, hurtPos, max)
		local rival = self:getRival(beHitPos)
		if hurtIndex == 1 then rival:onHurtFirst(self.pos_, roundIndex, actionIndex, hurtIndex, hurtPos) end
		rival:onHurtTime(self.pos_, roundIndex, actionIndex, hurtIndex, hurtPos)
		if hurtIndex == max then rival:onHurtEnd(self.pos_, roundIndex, actionIndex, hurtIndex, hurtPos) end
	end

	local function ChariotEndCallback()
		if doneCallback then doneCallback() end
	end

	self:onFireAmmo(targetPos,ChariotFirstCallback, nil, ChariotEndCallback)
end

function ChariotEx:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)

	self:fireBegin()

	local weapon = self.weaponViews_[1]

	-- 坐标
	local mypos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2 ,weapon:getContentSize().height ))
	mypos = self:getParent():convertToNodeSpace(mypos)
	
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)
	local action = round.action[self.actionIndex_]
	local hurts = action.hurt
	local hurtMax = math.max(#hurts , 1)

	local pos = cc.p(0,0)
	local _targetPos = nil

	if BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
		local rival = self:getRival(targetPos)
		local rivalWeapon = rival:getWeaponByIndex(targetPos)
		local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
		pos = rival:getParent():convertToNodeSpace(rivalWP)
		-- pos = cc.p(pos.x + offset[self.fireAmmoIndex_][1], pos.y + offset[self.fireAmmoIndex_][2])
		_targetPos = targetPos
	else
		local targetTank = BattleMO.getTankByKey(action.target)
		local rival = self:getRival(targetTank.pos_)
		pos = cc.p(rival:getPositionX(), rival:getPositionY())
		_targetPos = targetTank.pos_
	end


	local targetPos_ = _targetPos
	local roundIndex = self.roundIndex_
	local actionIndex = self.actionIndex_
	local rivalPos = pos

	-- 动画1
	local ammo2 = armature_create("cidian_path", 0, 0, function (movementType, movementID, armature)
		if movementType == MovementEventType.START then
			-- if firstCallback then firstCallback(targetPos_, roundIndex, actionIndex, 1, rivalPos) end
			self:fireOver()
		end
		if movementType == MovementEventType.COMPLETE then
			armature:removeSelf()
			if endCallback then endCallback() end
		end
	 end)
	ammo2:setPosition(mypos.x, mypos.y)
	ammo2:addTo(self:getParent(), Fighter.LAYER_EFFECT)
	local dis = math.floor(self:GetDistance(rivalPos, mypos))
	if dis > ammo2:height() then
		ammo2:setScaleY( dis / ammo2:height() * 1.3)
	end
	-- 旋转角度
	local deltaX = rivalPos.x - ammo2:getPositionX()
	local deltaY = rivalPos.y - ammo2:getPositionY()
	local degree = math.deg(math.atan2(deltaX, deltaY))
	ammo2:setRotation(degree)
	--
	ammo2:setVisible(false)

	
	-- 动画二
	local ammo = armature_create("cidian_attack", weapon:width() * 0.5, weapon:height() * 1.3)--:addTo(self:getParent(), 10)
	ammo:getAnimation():playWithIndex(0)
	ammo:addTo(weapon)
	-- if self.battleFor_ == BATTLE_FOR_DEFEND then
	-- 	local deltaX1 = rivalPos.x - ammo2:getPositionX()
	-- 	local deltaY1 = rivalPos.y - ammo2:getPositionY()
	-- 	local degree1 = math.deg(math.atan2(deltaX, deltaY))
	-- 	-- ammo:setRotation( -(degree1 + 180) )
	-- else
	-- 	local deltaX1 = rivalPos.x - ammo2:getPositionX()
	-- 	local deltaY1 = rivalPos.y - ammo2:getPositionY()
	-- 	local degree1 = math.deg(math.atan2(deltaX, deltaY))
	-- 	-- ammo:setRotation(degree1)
	-- end
	

	local function doEffect()
		ammo:getAnimation():playWithIndex(0)
	end
	local function doPath()
		ammo2:setVisible(true)
		ammo2:getAnimation():playWithIndex(0)

		local spwArray1 = cc.Array:create()
		for index = 1 , hurtMax do
			spwArray1:addObject(transition.sequence({cc.DelayTime:create((index - 1) * 0.1), cc.CallFunc:create(function ()
				if firstCallback then firstCallback(targetPos_, roundIndex, actionIndex, index, rivalPos, hurtMax) end
			end)}))
		end
		ammo2:runAction(cc.Spawn:create(spwArray1))
	end

	local actall = cc.Array:create()
	actall:addObject(transition.sequence({cc.CallFuncN:create(doEffect)})) -- act1
	actall:addObject(transition.sequence({cc.DelayTime:create(0.3),cc.CallFuncN:create(doPath)}))
	self.bodyView_:runAction(transition.sequence({cc.Spawn:create(actall)}))
	
end

return ChariotEx