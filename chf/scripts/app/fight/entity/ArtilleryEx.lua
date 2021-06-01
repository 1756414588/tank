--
-- 新版火炮 (竖排攻击)
-- N: 捕食者坦克 bushizhe
-- MYS
--

local Fighter = require("app.fight.entity.Fighter")

local ArtilleryEx = class("ArtilleryEx", Fighter)

function ArtilleryEx:ctor(battleFor, pos, tankId, tankCount, hp)
	ArtilleryEx.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	armature_add(IMAGE_ANIMATION .. "tank/bushizhe_path.pvr.ccz", IMAGE_ANIMATION .. "tank/bushizhe_path.plist", IMAGE_ANIMATION .. "tank/bushizhe_path.xml")
	armature_add(IMAGE_ANIMATION .. "tank/bushizhe_attack.pvr.ccz", IMAGE_ANIMATION .. "tank/bushizhe_attack.plist", IMAGE_ANIMATION .. "tank/bushizhe_attack.xml")
	-- armature_add(IMAGE_ANIMATION .. "tank/bushizhe_shot.pvr.ccz", IMAGE_ANIMATION .. "tank/bushizhe_shot.plist", IMAGE_ANIMATION .. "tank/bushizhe_shot.xml")
	self._formPos = nil	
	self._toPos = nil
end

function ArtilleryEx:onFireEffect(targetPos)
end

function ArtilleryEx:onActionWeaponMove(action, doneCallback)
	if self.actionIndex_ == 1 then
		ArtilleryEx.super.onActionWeaponMove(self, action, doneCallback)
	else
		if doneCallback then doneCallback() end
	end
end

-- 后坐力效果
function ArtilleryEx:onFireRecoil(targetPos, doneCallback)
	if self.actionIndex_ == 1 then 
		local function ActFun2()
			ArtilleryEx.super.onFireRecoil(self, targetPos, doneCallback)
		end
		self.bodyView_:runAction(transition.sequence({cc.DelayTime:create(0.5), cc.CallFuncN:create(ActFun2)}))
	else
		ArtilleryEx.super.onFireRecoil(self, targetPos, doneCallback)
	end
end

function ArtilleryEx:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	-- self:fireBegin()

	local _formPos , _toPos 
	local _pathFunc , _attackFunc
	local action
	local targetPosition

	local weapon = self.weaponViews_[1]

	local function AttackFunc(fpos, tpos, callback)
		local ammo = armature_create("bushizhe_attack", 0, 0, function (movementType, movementID, armature) 
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
					if callback then callback() end
				end
			end)
		ammo:getAnimation():playWithIndex(0)
		ammo:setPosition(weapon:width() * 0.5, weapon:height() + 5)
		ammo:addTo(weapon)
		--
		-- if self.battleFor_ == BATTLE_FOR_DEFEND then
		-- 	local deltaX = tpos.x - fpos.x
		-- 	local deltaY = tpos.y - fpos.y
		-- 	local degree = math.deg(math.atan2(deltaX, deltaY))
		-- 	ammo:setRotation( -(degree + 180) )
		-- else
		-- 	local deltaX = tpos.x - fpos.x
		-- 	local deltaY = tpos.y - fpos.y
		-- 	local degree = math.deg(math.atan2(deltaX, deltaY))
		-- 	ammo:setRotation(degree)
		-- end
	end

	local function PathFunc(fpos, tpos, callback)
		local ammo = armature_create("bushizhe_path", 0, 0, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
					if callback then callback() end
				end
			 end)
		ammo:getAnimation():playWithIndex(0)
		ammo:setPosition(fpos.x, fpos.y)
		ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)
		local dis = math.floor(self:GetDistance(tpos, fpos))
		if dis > ammo:height() then
			ammo:setScaleY( dis / ammo:height() * 1.3)
		end
		local deltaX = tpos.x - fpos.x
		local deltaY = tpos.y - fpos.y
		local degree = math.deg(math.atan2(deltaX, deltaY))
		ammo:setRotation(degree)
	end

	local function AmmoEnd()
		if action and targetPosition and self._toPos then
			if firstCallback then firstCallback(targetPosition, self.roundIndex_, self.actionIndex_, 1, self._toPos) end
			if arriveCallback then arriveCallback(targetPosition, self.roundIndex_, self.actionIndex_, 1, self._toPos) end
			if endCallback then endCallback(targetPosition, self.roundIndex_, self.actionIndex_, 1, self._toPos) end

			-- self:fireOver()
		end
	end

	if self.actionIndex_ == 1 then 
		-- form 
		local mypos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width * 0.5 + 5, weapon:getContentSize().height * 1.1))
		mypos = self:getParent():convertToNodeSpace(mypos)
		self._formPos = mypos

		-- to
		action = round.action[self.actionIndex_]

		if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
			local rival = self:getRival(targetPos)
			local rivalWeapon = rival:getWeaponByIndex(targetPos)
			local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			self._toPos = rival:getParent():convertToNodeSpace(rivalWP)
			targetPosition = targetPos
		else
			-- pos = cc.p(rival:getPositionX(), rival:getPositionY())
			local targetTank = BattleMO.getTankByKey(action.target)
			local rival = self:getRival(targetTank.pos_)
			local pos = cc.p(rival:getPositionX(), rival:getPositionY())
			self._toPos = pos
			targetPosition = targetTank.pos_
		end

		-- local targetTank = BattleMO.getTankByKey(action.target)
		-- local rival = self:getRival(targetTank.pos_)
		-- local pos = cc.p(rival:getPositionX(), rival:getPositionY())
		-- self._toPos = pos
		-- targetPosition = targetTank.pos_

		_attackFunc = AttackFunc
		_pathFunc = PathFunc
	else
		-- form 
		self._formPos = self._toPos

		-- to
		action = round.action[self.actionIndex_]

		if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
			local rival = self:getRival(targetPos)
			local rivalWeapon = rival:getWeaponByIndex(targetPos)
			local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			self._toPos = rival:getParent():convertToNodeSpace(rivalWP)
			targetPosition = targetPos
		else
			-- pos = cc.p(rival:getPositionX(), rival:getPositionY())
			local targetTank2 = BattleMO.getTankByKey(action.target)
			local rival2 = self:getRival(targetTank2.pos_)
			local pos2 = cc.p(rival2:getPositionX(), rival2:getPositionY())
			self._toPos = pos2
			targetPosition = targetTank2.pos_
		end


		-- local targetTank2 = BattleMO.getTankByKey(action.target)
		-- local rival2 = self:getRival(targetTank2.pos_)
		-- local pos2 = cc.p(rival2:getPositionX(), rival2:getPositionY())
		-- self._toPos = pos2
		-- targetPosition = targetTank2.pos_

		_attackFunc = nil
		_pathFunc = PathFunc
	end
	
	if _attackFunc then
		local function ActFun1()
			_attackFunc(self._formPos, self._toPos, nil)
		end

		local function ActFun2()
			if _pathFunc then _pathFunc(self._formPos, self._toPos, AmmoEnd) end
		end
		

		local actall = cc.Array:create()
		actall:addObject(transition.sequence({cc.CallFuncN:create(ActFun1)})) -- act1
		actall:addObject(transition.sequence({cc.DelayTime:create(0.5),cc.CallFuncN:create(ActFun2)}))
		self.bodyView_:runAction(cc.Spawn:create(actall))
	else
		local function ActFun2()
			if _pathFunc then _pathFunc(self._formPos, self._toPos, AmmoEnd) end
		end
		self.bodyView_:runAction(transition.sequence({cc.CallFuncN:create(ActFun2)})) -- cc.DelayTime:create(0.05),
	end
end

return ArtilleryEx