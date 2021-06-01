
-- 战车

local Fighter = require("app.fight.entity.Fighter")

local Chariot = class("Chariot", Fighter)

function Chariot:ctor(battleFor, pos, tankId, tankCount, hp)
	Chariot.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
end

function Chariot:onFireEffect(targetPos)
	local config = TankConfig.getConfigBy(self.tankId_)
	local tankAttack = TankMO.queryTankAttackById(self.tankId_)

	for index = 1, #self.weaponViews_ do
		local weapon = self.weaponViews_[index]

		-- armature_add(IMAGE_ANIMATION .. "battle/" .. tankAttack.fireName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. tankAttack.fireName .. ".plist", IMAGE_ANIMATION .. "battle/" .. tankAttack.fireName .. ".xml")
		local armName = self:addArmature(tankAttack,Fighter.fireName)

		local pos = cc.p(weapon:getContentSize().width * config.gun[index].a[1], weapon:getContentSize().height)

		local playTimes = 1

		local fire = armature_create(armName, pos.x, pos.y,
			function (movementType, movementID, armature)
				if movementType == MovementEventType.LOOP_COMPLETE then
					playTimes = playTimes + 1
					if playTimes == 5 then
						armature:removeSelf()
					end
				end
			end)
	    fire:getAnimation():playWithIndex(0)
    	fire:addTo(weapon)  -- 效果在炮口上
    end
end

-- firstCallback:第一个到达的回调
-- arriveCallback:每次到达的回调
function Chariot:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local offset = {{30, 60}, {15, 35}, {-60, 20}, {20, -5}, {-30, 15}}  -- 第一、三是没有打中坦克的

	local config = TankConfig.getConfigBy(self.tankId_)

	local tankAttack = TankMO.queryTankAttackById(self.tankId_)
	local recoil = json.decode(tankAttack.recoil)

	self:fireBegin()

	self.ammoCounts = recoil[1]

	self.fireAmmoIndex_ = 0

	local function fire()
		self.fireAmmoIndex_ = self.fireAmmoIndex_ + 1

		local fireIndex = self.fireAmmoIndex_

		for index = 1, #self.weaponViews_ do
			local weapon = self.weaponViews_[index]

			-- armature_add(IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".plist", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".xml")
			local armName = self:addArmature(tankAttack,Fighter.ammoName)

			local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width * config.gun[index].a[1], weapon:getContentSize().height + 60))
			local pos = self:getParent():convertToNodeSpace(pos)

			local ammo = armature_create(armName, 0, 0, function () end)
			ammo:setPosition(pos.x, pos.y)
			ammo:getAnimation():playWithIndex(0)
			ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)
			if self.battleFor_ == BATTLE_FOR_DEFEND then
				ammo:setRotation(180 - weapon:getRotation())
			else
				ammo:setRotation(weapon:getRotation())
			end

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

			ammo.fireIndex = fireIndex
			ammo.targetPos = targetPos  -- ammo打到的对方的阵型位置，值为1-6
			ammo.roundIndex = self.roundIndex_
			ammo.actionIndex = self.actionIndex_
			ammo.rivalPos = pos  -- 物理坐标位置
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

return Chariot
