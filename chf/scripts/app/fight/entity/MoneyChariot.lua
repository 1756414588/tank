--
-- Author: Gss
-- Date: 2018-08-20 17:46:02
--
-- 四阶金币车战车(单一攻击)

local Fighter = require("app.fight.entity.Fighter")

local MoneyChariot = class("MoneyChariot", Fighter)

function MoneyChariot:ctor(battleFor, pos, tankId, tankCount, hp)
	MoneyChariot.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	armature_add(IMAGE_ANIMATION .. "tank/sdzy_xuli.pvr.ccz", IMAGE_ANIMATION .. "tank/sdzy_xuli.plist", IMAGE_ANIMATION .. "tank/sdzy_xuli.xml")
	armature_add(IMAGE_ANIMATION .. "tank/sdzy_kaipao.pvr.ccz", IMAGE_ANIMATION .. "tank/sdzy_kaipao.plist", IMAGE_ANIMATION .. "tank/sdzy_kaipao.xml")
end

function MoneyChariot:onFireEffect(targetPos)
	local config = TankConfig.getConfigBy(self.tankId_)
	local tankAttack = TankMO.queryTankAttackById(self.tankId_)

	local recoil = json.decode(tankAttack.recoil)
	local ammoCounts = recoil[1] / 2

	local weapon = self.weaponViews_[1]
	local pos = cc.p(weapon:getContentSize().width * config.gun[1].a[1] - 25, weapon:getContentSize().height)
	local playTimes = 1
	local fire = armature_create("sdzy_kaipao", pos.x, pos.y,
		function (movementType, movementID, armature)
			if movementType == MovementEventType.LOOP_COMPLETE then
				playTimes = playTimes + 1
				if playTimes == ammoCounts then
					armature:removeSelf()
				end
			end
		end)
	fire:getAnimation():playWithIndex(0)
	fire:addTo(weapon)  -- 效果在炮口上


	local playTimes1 = 1
	local pos1 = cc.p(weapon:getContentSize().width * config.gun[1].a[1] + 25, weapon:getContentSize().height)
	local fire1 = armature_create("sdzy_kaipao", pos1.x, pos1.y,
		function (movementType, movementID, armature)
			if movementType == MovementEventType.LOOP_COMPLETE then
				playTimes1 = playTimes1 + 1
				if playTimes1 == ammoCounts then
					armature:removeSelf()
				end
			end
		end)
	-- fire1:getAnimation():playWithIndex(0)
	fire1:addTo(weapon)  -- 效果在炮口上
	fire1:setVisible(false)

	self:runAction(transition.sequence({cc.DelayTime:create(0.1 * self.timeScale_), cc.CallFuncN:create(function ()
		-- body
		fire1:setVisible(true)
		fire1:getAnimation():playWithIndex(0)
	end)}))
end

-- firstCallback:第一个到达的回调
-- arriveCallback:每次到达的回调
function MoneyChariot:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local offset = {{-30, 0}, {30, 0}, {-15, 0}, {15, 0}, {0, 0}, {0, 0}}  -- 第一、三是没有打中坦克的
	local config = TankConfig.getConfigBy(self.tankId_)

	local tankAttack = TankMO.queryTankAttackById(self.tankId_)
	local recoil = json.decode(tankAttack.recoil)

	self:fireBegin()

	self.ammoCounts = recoil[1]

	self.fireAmmoIndex_ = 0

	local function fire()
		self.fireAmmoIndex_ = self.fireAmmoIndex_ + 1

		local fireIndex = self.fireAmmoIndex_

		local weapon = self.weaponViews_[1]

		local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width * config.gun[1].a[1], weapon:getContentSize().height))
		local pos = self:getParent():convertToNodeSpace(pos)

		local ammo = display.newSprite(IMAGE_COMMON .. "sdzy_zidan_00000.png")
		local offsetx = -25
		if self.fireAmmoIndex_ % 2 == 0 then
			offsetx = 25
		end
		local startPos = cc.p(pos.x + offsetx, pos.y)
		ammo:setPosition(startPos)
		ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)
		ammo:setAnchorPoint(0.5, 0)

		local rival = self:getRival(targetPos)
		local pos = nil
		if self.battleFor_ == BATTLE_FOR_DEFEND then
			pos = cc.p(rival:getPositionX() + offset[self.fireAmmoIndex_][1], rival:getPositionY() - offset[self.fireAmmoIndex_][2])
		else
			if BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
				local rivalWeapon = rival:getWeaponByIndex(targetPos)
				local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
				pos = rival:getParent():convertToNodeSpace(rivalWP)
				pos = cc.p(pos.x + offset[self.fireAmmoIndex_][1], pos.y + offset[self.fireAmmoIndex_][2])
			else
				pos = cc.p(rival:getPositionX() + offset[self.fireAmmoIndex_][1], rival:getPositionY() + offset[self.fireAmmoIndex_][2])
			end
		end

		local deltaX = pos.x - startPos.x
		local deltaY = pos.y - startPos.y

		local vecLen = math.sqrt(deltaX * deltaX + deltaY * deltaY)
		local normX = deltaX / vecLen
		local normY = deltaY / vecLen
		local bulletLen = 150
		local origPos = cc.p(pos.x, pos.y)
		pos.x = pos.x - bulletLen * normX
		pos.y = pos.y - bulletLen * normY

		local r = math.deg(math.acos(normX))
		r = 90 - r
		if self.battleFor_ == BATTLE_FOR_DEFEND then
			ammo:setRotation(180 - r)
		else
			ammo:setRotation(r)
		end

		ammo.fireIndex = fireIndex
		ammo.targetPos = targetPos  -- ammo打到的对方的阵型位置，值为1-6
		ammo.roundIndex = self.roundIndex_
		ammo.actionIndex = self.actionIndex_
		ammo.rivalPos = origPos -- 物理坐标位置
		ammo.recoil = clone(recoil)
		ammo.firstCallback = firstCallback
		ammo.arriveCallback = arriveCallback
		ammo.endCallback = endCallback

		ammo:runAction(transition.sequence({cc.MoveTo:create(0.25*self.timeScale_, pos), cc.CallFuncN:create(function(sender)
				if sender.fireIndex == 1 and sender.firstCallback then sender.firstCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, sender.fireIndex, sender.rivalPos) end
				if sender.arriveCallback then sender.arriveCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, sender.fireIndex, sender.rivalPos) end
				if sender.fireIndex == sender.recoil[1] and sender.endCallback then sender.endCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, sender.fireIndex, sender.rivalPos) end

				sender:removeSelf()

				self.ammoCounts = self.ammoCounts - 1

				if self.ammoCounts <= 0 then
					self:fireOver()
				end
			end)}))

		if tankAttack.fireSound and tankAttack.fireSound ~= "" then
			ManagerSound.playSound(tankAttack.fireSound)
		end
	end


	local actions = {}
	for index = 1, recoil[1] do
		actions[#actions + 1] = cc.CallFunc:create(function() fire() end)
		actions[#actions + 1] = cc.DelayTime:create(0.2 * self.timeScale_)
	end
	actions[#actions + 1] = cc.CallFunc:create(function() 
		if self.ammoCounts <= 0 then
			self:fireOver()
		end
	end)
	self.bodyView_:runAction(transition.sequence(actions))
end

function MoneyChariot:onFire(action, doneCallback)
	-- 先播放蓄力动画，再onFireCore_
	local weapon = self.weaponViews_[1]
	local pos = cc.p(weapon:getContentSize().width * 0.5, weapon:getContentSize().height + 22)
	local fire = armature_create("sdzy_xuli", pos.x, pos.y,
		function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				self:onFireCore_(action, doneCallback)
				armature:removeSelf()
			end
		end)
	fire:getAnimation():playWithIndex(0)
	fire:addTo(weapon)  -- 效果在炮口上
end

function MoneyChariot:onFireCore_(action, doneCallback)
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

return MoneyChariot