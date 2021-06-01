
-- 火炮

local Fighter = require("app.fight.entity.Fighter")

local Artillery = class("Artillery", Fighter)

function Artillery:ctor(battleFor, pos, tankId, tankCount, hp)
	Artillery.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
end

function Artillery:onFireEffect()
	local tankAttack = TankMO.queryTankAttackById(self.tankId_)
	
	for index = 1, #self.weaponViews_ do
		local weapon = self.weaponViews_[index]

		-- armature_add(IMAGE_ANIMATION .. "battle/" .. tankAttack.fireName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. tankAttack.fireName .. ".plist", IMAGE_ANIMATION .. "battle/" .. tankAttack.fireName .. ".xml")
		local armName = self:addArmature(tankAttack,Fighter.fireName)

		local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2, weapon:getContentSize().height))
		local pos = self.view_:convertToNodeSpace(pos)

		local fire = armature_create(armName, pos.x, pos.y,
			function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					-- print("结束了")
					armature:removeSelf()
				end
			end)
		fire:setRotation(weapon:getRotation())
		fire:getAnimation():playWithIndex(0)
		fire:addTo(self.view_)
	end
end

-- 火炮发射炮弹
function Artillery:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local tankDB = TankMO.queryTankById(self.tankId_)
	local tankAttack = TankMO.queryTankAttackById(self.tankId_)

	
	self:fireBegin()

	self.ammoCounts = #self.weaponViews_
	
	for index = 1, #self.weaponViews_ do
		local weapon = self.weaponViews_[index]

		-- armature_add(IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".plist", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".xml")
		local armName = self:addArmature(tankAttack,Fighter.ammoName)

		local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2, weapon:getContentSize().height))
		local pos = self:getParent():convertToNodeSpace(pos)

		local ammo = armature_create(armName, pos.x, pos.y, function (movementType, movementID, armature) end)
		ammo:getAnimation():playWithIndex(0)
		ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)
		if self.battleFor_ == BATTLE_FOR_DEFEND then
			ammo:setRotation(180 - weapon:getRotation())
		else
			ammo:setRotation(weapon:getRotation())
		end

		local rival = self:getRival(targetPos)
		
		if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
			local rivalWeapon = rival:getWeaponByIndex(targetPos)
			local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			pos = rival:getParent():convertToNodeSpace(rivalWP)
		else
			pos = cc.p(rival:getPositionX(), rival:getPositionY())
		end

		ammo.targetPos = targetPos  -- ammo打到的对方的阵型位置，值为1-6
		ammo.roundIndex = self.roundIndex_
		ammo.actionIndex = self.actionIndex_
		ammo.rivalPos = pos  -- 打到对方的物理坐标位置
		ammo:runAction(transition.sequence({cc.MoveTo:create(0.25*self.timeScale_, pos), cc.CallFuncN:create(function(sender)
				if firstCallback then firstCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
				if arriveCallback then arriveCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
				if endCallback then endCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end

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

	if self.ammoCounts <= 0 then
		self:fireOver()
	end	
end

return Artillery
