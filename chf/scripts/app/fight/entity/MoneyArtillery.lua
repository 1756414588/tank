--
-- Author: Gss
-- Date: 2018-08-20 17:45:35
--
-- 四阶金币车火炮(竖排攻击)

local Fighter = require("app.fight.entity.Fighter")

local MoneyArtillery = class("MoneyArtillery", Fighter)

function MoneyArtillery:ctor(battleFor, pos, tankId, tankCount, hp)
	MoneyArtillery.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	armature_add(IMAGE_ANIMATION .. "tank/swsx_xuli.pvr.ccz", IMAGE_ANIMATION .. "tank/swsx_xuli.plist", IMAGE_ANIMATION .. "tank/swsx_xuli.xml")
	armature_add(IMAGE_ANIMATION .. "tank/swsx_zidan.pvr.ccz", IMAGE_ANIMATION .. "tank/swsx_zidan.plist", IMAGE_ANIMATION .. "tank/swsx_zidan.xml")
	self._formPos = nil	
	self._toPos = nil
end

-- 播放蓄力动画
function MoneyArtillery:onActionEnter()
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	if UserMO.queryFuncOpen(UFP_FRIGHTEN) and table.getn(round.action) == 0 then
			-- 解除震慑 消除震慑动画
		self:hideFrighten()
		BattleMO.fightRoundIndex_ = BattleMO.fightRoundIndex_ + 1
		BattleBO:startRound()
		return
	end

	local function nxtAction()
		local nxtIndex = self.actionIndex_ + 1
		if nxtIndex == #round.action + 1 then
			gprint("[Fighter] ACTION end. idx:", self.actionIndex_, "round idx:", self.roundIndex_)

			-- 当前回合round结束，炮管归位正前方
			for index = 1, #self.weaponViews_ do
				local weapon = self.weaponViews_[index]
				local rotation = weapon:getRotation()
				weapon:stopAllActions()
				weapon:runAction(cc.RotateTo:create(math.abs(rotation) * TankConfig.getRotationSpeed(self.tankId_)  * self.timeScale_, 0))
			end

			if self.roundEndCallback then self.roundEndCallback() end
		else
			local time = 0.2 -- 保证每个action在time的时间内完成
			self.actionSchedulerHandler_ = scheduler.performWithDelayGlobal(function() self.actionSchedulerHandler_ = nil; self.actionIndex_ = self.actionIndex_ + 1; self:onActionEnter() end, time)
		end
	end

	local function ActFun2()
		local action = round.action[self.actionIndex_]
		self:onActionWeaponMove(action, function() 
			if self.actionIndex_ == 1 then
				-- 蓄力
				local effect = armature_create("swsx_xuli", self.weaponViews_[1]:width() * 0.5,self.weaponViews_[1]:height() + 8, function (movementType, movementID, armature) 
						if movementType == MovementEventType.COMPLETE then
							armature:removeSelf()
							self:onFire(action, nxtAction) 
						end		
					end):addTo(self.weaponViews_[1],99)
				effect:setScale(1.3)
				effect:getAnimation():playWithIndex(0)
			else
				self:onFire(action, nxtAction) 
			end
		end)
	end
	ActFun2()
end

function MoneyArtillery:onFireEffect(targetPos)
end

function MoneyArtillery:onActionWeaponMove(action, doneCallback)
	if self.actionIndex_ == 1 then
		MoneyArtillery.super.onActionWeaponMove(self, action, doneCallback)
	else
		if doneCallback then doneCallback() end
	end
end

-- 后坐力效果
function MoneyArtillery:onFireRecoil(targetPos, doneCallback)
	MoneyArtillery.super.onFireRecoil(self, targetPos, doneCallback)
end

function MoneyArtillery:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	local tankAttack = TankMO.queryTankAttackById(self.tankId_)

	self:fireBegin()

	self.ammoCounts = #self.weaponViews_
	
	for index = 1, #self.weaponViews_ do
		local weapon = self.weaponViews_[index]

		local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2, weapon:getContentSize().height))
		local pos = self:getParent():convertToNodeSpace(pos)

		local ammo = armature_create("swsx_zidan", pos.x, pos.y, function (movementType, movementID, armature) 
				if movementType == MovementEventType.COMPLETE then
					armature:runAction(transition.sequence({cc.DelayTime:create(0.25*self.timeScale_), cc.CallFuncN:create(function(sender)
							sender:removeSelf()
							if firstCallback then firstCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
							if arriveCallback then arriveCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
							if endCallback then endCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end

							self.ammoCounts = self.ammoCounts - 1
							if self.ammoCounts <= 0 then
								self:fireOver()
							end
						end)}))
				end
			end)		
		local rival = self:getRival(targetPos)
		
		local toPos
		if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界BOSS
			local rivalWeapon = rival:getWeaponByIndex(targetPos)
			local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			toPos = rival:getParent():convertToNodeSpace(rivalWP)
		else
			toPos = cc.p(rival:getPositionX(), rival:getPositionY())
		end

		ammo.targetPos = targetPos  -- ammo打到的对方的阵型位置，值为1-6
		ammo.roundIndex = self.roundIndex_
		ammo.actionIndex = self.actionIndex_
		ammo.rivalPos = toPos  -- 打到对方的物理坐标位置

		ammo:getAnimation():playWithIndex(0)
		ammo:addTo(self:getParent(), Fighter.LAYER_BOMB)
		local dis = math.floor(self:GetDistance(toPos, pos))
		if dis > ammo:height() then
			ammo:setScaleY( dis / ammo:height() * 1.3)
		end
		local deltaX = toPos.x - pos.x
		local deltaY = toPos.y - pos.y
		local degree = math.deg(math.atan2(deltaX, deltaY))
		ammo:setRotation(degree)

		if tankAttack.fireSound and tankAttack.fireSound ~= "" then
			ManagerSound.playSound(tankAttack.fireSound)
		end
	end

	if self.ammoCounts <= 0 then
		self:fireOver()
	end	
end

return MoneyArtillery