--
-- Author: xiaoxing
-- Date: 2017-04-27 10:35:26
--
local Fighter = require("app.fight.entity.Fighter")

local Airsship = class("Airsship", Fighter)

function Airsship:ctor(battleFor, pos, tankId, tankCount, hp, airshpId)
	Airsship.super.ctor(self, battleFor, pos, tankId, tankCount, hp)
	self.view_ = display.newNode():addTo(self)
	armature_add(IMAGE_ANIMATION .. "ship/feiting_zhandou.pvr.ccz", IMAGE_ANIMATION .. "ship/feiting_zhandou.plist", IMAGE_ANIMATION .. "ship/feiting_zhandou.xml")
	armature_add(IMAGE_ANIMATION .. "ship/feiting_zhandou2.pvr.ccz", IMAGE_ANIMATION .. "ship/feiting_zhandou2.plist", IMAGE_ANIMATION .. "ship/feiting_zhandou2.xml")
	armature_add(IMAGE_ANIMATION .. "ship/ftzd_siwangbaozha.pvr.ccz", IMAGE_ANIMATION .. "ship/ftzd_siwangbaozha.plist", IMAGE_ANIMATION .. "ship/ftzd_siwangbaozha.xml")
	armature_add(IMAGE_ANIMATION .. "ship/ftzd_gongjifashe.pvr.ccz", IMAGE_ANIMATION .. "ship/ftzd_gongjifashe.plist", IMAGE_ANIMATION .. "ship/ftzd_gongjifashe.xml")
	armature_add(IMAGE_ANIMATION .. "ship/ftzd_yun.pvr.ccz", IMAGE_ANIMATION .. "ship/ftzd_yun.plist", IMAGE_ANIMATION .. "ship/ftzd_yun.xml")
	
	local airshpRes = "feiting_zhandou"
	local ab = AirshipMO.queryShipById(airshpId)
	if ab.id > 4 then
		airshpRes = "feiting_zhandou2"
	end

	local config = TankConfig.getConfigBy(self.tankId_)

	local offset = cc.p(0,0)
	if config then
		offset.x = config.offset[1]
		offset.y = config.offset[2]
	end
	local ship = armature_create(airshpRes, offset.x, offset.y)
	
	ship:getAnimation():playWithIndex(0)
	ship:addTo(self.view_,1)
	ship:setScaleY(-1)
	self.bodyView_ = ship

	----效果 云
	local yun = armature_create("ftzd_yun", 0, -300)
	yun:getAnimation():playWithIndex(0)
	yun:addTo(self, 1)

	--创建发射点
	local weapon = display.newNode():addTo(self.view_)
	table.insert(self.weaponViews_, weapon)
end

-- 火箭是面杀伤，在每个round中，所有的action一次处理完
function Airsship:onActionEnter()
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
		-- local waitRetuen = false -- 是否要等待自身归位

		-- -- 判断下一个回合是否还是自己
		-- local nxtRoundIndex = self.roundIndex_ + 1
		-- local nxtRound = BattleMO.getRoundAtIndex(nxtRoundIndex)
		-- if nxtRound and nxtRound.key == round.key then -- 如果还有下一个回合,下一个回合还是自己，直接进入下一回合
				self:runAction(transition.sequence({cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
						-- self.roundIndex_ = 0
						-- self.actionIndex_ = 0
						if self.roundEndCallback then self.roundEndCallback() end
					end)}))
		-- else  -- 否则炮管归位了才能结束当前回合
		-- 	for index = 1, #self.weaponViews_ do
		-- 		local actions = {}
		-- 		actions[#actions + 1] = cc.RotateTo:create(math.abs(90) * TankConfig.getRotationSpeed(self.tankId_), 0)
		-- 		if index == 1 then
		-- 			actions[#actions + 1] = cc.CallFunc:create(function ()
		-- 					self.roundIndex_ = 0
		-- 					self.actionIndex_ = 0
		-- 					if self.roundEndCallback then self.roundEndCallback() end
		-- 				end)
		-- 			actions[#actions + 1] = cc.CallFunc:create(function () self.bodyView_:runAction(cc.RotateTo:create(0.25, 0)) end) -- 身体归位
		-- 		end
		-- 		self.weaponViews_[index]:runAction(transition.sequence(actions))
		-- 	end
		-- end
	end

	self:onFire(nil, function() roundEnd() end)
end

function Airsship:onFireEffect(targetPos)
	local pos = cc.p(self:getPositionX(), self:getPositionY()- 100)
	local fireEffect = armature_create("ftzd_gongjifashe", pos.x, pos.y,
		function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end)
    fireEffect:getAnimation():playWithIndex(0)
	fireEffect:addTo(self:getParent(), -1)	
end

function Airsship:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
	local tmpRoundIndex = self.roundIndex_

	local round = BattleMO.getRoundAtIndex(tmpRoundIndex)
	-- gdump(round, "[Airsship] fire ammo:" .. tmpRoundIndex)

	local copyTankId = 30 -- 世界Airsship发射的ammo效果参考tank的id
	local tankDB = TankMO.queryTankById(copyTankId)
	local tankAttack = TankMO.queryTankAttackById(copyTankId)

	armature_add(IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".plist", IMAGE_ANIMATION .. "battle/" .. tankAttack.ammoName .. ".xml")

	local m_curFireActionIndex = 1

	self:fireBegin()
	self.ammoCounts = #round.action

	armature_add(IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.plist", IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.xml")

	local function ammoUpdate(ammo) -- 火箭弹的尾焰
		
		local flame = armature_create("bt_ammo_4_flame", ammo:getPositionX(), ammo:getPositionY(), function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
			end)
		flame:getAnimation():playWithIndex(0)
		flame:addTo(self:getParent(), Fighter.LAYER_BOMB1)


		local lastPos = ammo.lastPos
		local deltaX = ammo:getPositionX() - lastPos.x
		local deltaY = ammo:getPositionY() - lastPos.y
		local degree = math.deg(math.atan2(deltaX, deltaY))
		ammo:setRotation(degree)
		flame:setRotation(degree)

		ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())
	end

	local function fireAmmo(index)
		local action = round.action[m_curFireActionIndex]

		-- for weaponIndex = 1, #self.weaponViews_ do
		for weaponIndex = 1, 1 do
			local weapon = self.weaponViews_[weaponIndex]
			local targetTank = nil
			-- if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then  -- 防守方是世界Airsship
			-- 	targetTank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, TANK_Airsship_POSITION_INDEX)
			-- else
				targetTank = BattleMO.getTankByKey(action.target)
			-- end
			local rival = self:getRival(targetTank.pos_)

			local ammo = armature_create(tankAttack.ammoName, 0, 0, function (movementType, movementID, armature) end)
			ammo:getAnimation():playWithIndex(0)
			ammo:addTo(self:getParent(),Fighter.LAYER_BOMB1)

			local pos = nil
			if m_curFireActionIndex == 1 or m_curFireActionIndex == 3 or m_curFireActionIndex == 5 then  -- 根据actionIndex使每次发射的炮弹错开位置
				pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2 - 70, weapon:getContentSize().height - 120 + math.ceil(m_curFireActionIndex / 2) * 50))
				pos = self:getParent():convertToNodeSpace(pos)
				ammo:setPosition(pos.x, pos.y)
			else
				pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2 + 70, weapon:getContentSize().height - 120 + math.ceil(m_curFireActionIndex / 2) * 50))
				pos = self:getParent():convertToNodeSpace(pos)
				ammo:setPosition(pos.x, pos.y)
			end

			local rivalPos = nil
			-- if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then -- 攻击世界Airsship
			-- 	local weaponIndex = targetTank:getWeaponIndexByKey(action.target)
			-- 	local rivalWeapon = rival:getWeaponByIndex(weaponIndex)
			-- 	local rivalWP = rivalWeapon:getParent():convertToWorldSpace(cc.p(rivalWeapon:getPositionX(), rivalWeapon:getPositionY()))
			-- 	rivalPos = rival:getParent():convertToNodeSpace(rivalWP)
			-- else
				rivalPos = cc.p(rival:getPositionX(), rival:getPositionY())
			-- end

			local config = ccBezierConfig()
			config.endPosition = rivalPos
			local delta = 0
			if self.battleFor_ == BATTLE_FOR_ATTACK then
				if self.pos_ == 1 or self.pos_ == 4 then
					config.controlPoint_1 = cc.p(pos.x - 150, pos.y + 180)
					config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y - 180)
				elseif self.pos_ == 3 or self.pos_ == 5 then
					config.controlPoint_1 = cc.p(pos.x - 150, pos.y + 180)
					config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y - 180)
				else
					config.controlPoint_1 = cc.p(pos.x + 150, pos.y + 180)
					config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y - 180)
				end
			else
				config.controlPoint_1 = cc.p(pos.x - 150, pos.y - 180)
				config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y + 180)
			end

			ammo.targetPos = targetTank.pos_  -- ammo打到的对方的阵型位置，值为1-6
			ammo.roundIndex = tmpRoundIndex
			ammo.actionIndex = m_curFireActionIndex
			ammo.rivalPos = rivalPos  -- 打到对方的物理坐标位置
			ammo.firstCallback = firstCallback
			ammo.arriveCallback = arriveCallback
			ammo.endCallback = endCallback

			ammo:runAction(transition.sequence({cc.EaseSineIn:create(cc.BezierTo:create(0.9*self.timeScale_, config)), cc.CallFuncN:create(function(sender)
					if sender.firstCallback then sender.firstCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
					if sender.arriveCallback then sender.arriveCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
					if sender.endCallback then sender.endCallback(sender.targetPos, sender.roundIndex, sender.actionIndex, 1, sender.rivalPos) end
					sender:removeSelf()

					self.ammoCounts = self.ammoCounts - 1
					if self.ammoCounts <= 0 then
						self:fireOver()
					end
				end)}))
			ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())

			local node = display.newNode():addTo(ammo)
			nodeExportComponentMethod(node)
			node:setNodeEventEnabled(true)
			node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) ammoUpdate(ammo) end)
			node:scheduleUpdate()

			if tankAttack.fireSound and tankAttack.fireSound ~= "" then
				ManagerSound.playSound(tankAttack.fireSound)
			end
		end
		m_curFireActionIndex = m_curFireActionIndex + 1
	end


	local ras = {}
	for actionIndex = 1, #round.action do  -- 要向几个对象同时发射
		ras[#ras + 1] = cc.CallFunc:create(function() fireAmmo(actionIndex) end)
		ras[#ras + 1] = cc.DelayTime:create(0.08 * 2*self.timeScale_)
	end

	ras[#ras + 1] = cc.CallFunc:create(function()
		if self.ammoCounts <= 0 then
			self:fireOver()
		end	 
	end)
	self.bodyView_:runAction(transition.sequence(ras))
end

--特效
function Airsship:onFireRecoil(targetPos, returnCallback)
	if returnCallback then returnCallback() end
end

--特效
-- function Airsship:onDie(roundIndex, actionIndex)
-- end
function Airsship:onRemoveSelf(delay, callback)
	if delay == nil then
		delay = true
	end
	-- armature_add(IMAGE_ANIMATION .. "battle/bt_die.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_die.plist", IMAGE_ANIMATION .. "battle/bt_die.xml")
	-- armature_add(IMAGE_ANIMATION .. "battle/bt_crater.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_crater.plist", IMAGE_ANIMATION .. "battle/bt_crater.xml")
	FightEffect.checkDie(self)
	local pos = cc.p(self:getPositionX(), self:getPositionY())
	local die = armature_create("ftzd_siwangbaozha", pos.x, pos.y,
		function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end)
    die:getAnimation():playWithIndex(0)
	die:addTo(self:getParent(), Fighter.LAYER_EFFECT)

	if self.tankId_ ~= TANK_BOSS_CONFIG_ID and self.tankId_ ~= TANK_ALTAR_BOSS_CONFIG_ID then
		local tankAttack = TankMO.queryTankAttackById(self.tankId_)
		if tankAttack and tankAttack.dieSound and tankAttack.dieSound ~= "" then
			ManagerSound.playSound(tankAttack.dieSound)
		end
	end
	
	-- self:removeSelf()
	self:setVisible(false)

	if delay then
		self:schedule(function ()
			if self:isFireOver() then
				BattleMO.setTankAtPos(self.battleFor_, self.pos_, nil)
				self:onOver()
				if callback then
					callback()
				end				

				self:removeSelf()
			end
		end, 0.1)
	else
		BattleMO.setTankAtPos(self.battleFor_, self.pos_, nil)
		self:onOver()
		if callback then
			callback()
		end		

		self:removeSelf()
	end
end

--特效-------
function Airsship:onWeaponBroken(weaponIndex)

end

--特效---------
function Airsship:onWeaponDie(weaponIndex)
	if weaponIndex == 0 then return end
end

function Airsship:getWeaponIndexByKey(key)
	local index = 1
	if key == 2 or key == 4 or key == 6 or key == 8 or key == 10 then
		index = key / 2
	elseif key == 12 then
		index = 7
	end

	if index > #self.weaponViews_ then
		index = #self.weaponViews_
	end
	return index
end

return Airsship