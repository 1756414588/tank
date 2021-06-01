--
-- 战斗坦克特效管理
-- MYS
--
require("app.fight.config.TankConfig")
local LAYER_BODY = 1
local LAYER_BODY1 = 3
local LAYER_BOMB1 = 2
local LAYER_BOMB = 5
local LAYER_EFFECT = 9 
local  WEAPON_ROTATE_TIME = 0.01 -- 武器旋转的

local TANK_INDEX = 0
local DEX_TANK = 4 * TANK_INDEX
local TANK_TYPE_1 = 1 + DEX_TANK
local TANK_TYPE_2 = 2 + DEX_TANK
local TANK_TYPE_3 = 3 + DEX_TANK
local TANK_TYPE_4 = 4 + DEX_TANK

local ammoName 	= "ammoName"
local hurtName 	= "hurtName"
local hurtName2 	= "hurtName2"
local fireName 	= "fireName"
local dieName 	= "dieName"
-- require("app.fight.EntityFactory")
local FighterScreenView = class("FighterScreenView", function (size)
	if not size then size = cc.size(0, 0) end
    local rect = cc.rect(0, 0, size.width, size.height)

    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function FighterScreenView:ctor(size)
	self.m_viewSize = size
	
end

function FighterScreenView:onEnter()
	local baseNode = display.newNode():addTo(self)
	baseNode:setPosition(0,0)
	self.baseNode = baseNode

	self.armatureList = {}

	-- self.testword = ui.newTTFLabel({text = "TestWord 测试文字", font = G_FONT, size = 22, x = self.m_viewSize.width * 0.5, y = self.m_viewSize.height * 0.5, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self)

end

function FighterScreenView:onExit()
	for k,v in pairs(self.armatureList) do
		armature_remove(IMAGE_ANIMATION .. "battle/" .. v .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/".. v .. ".plist", IMAGE_ANIMATION .. "battle/".. v .. ".xml")
	end
end

function FighterScreenView:addArmature(item, obj, name)
	local armName = name
	local effectid = item.effectid
	if effectid > 1 then
		armName = string.format("%s_%d",armName,(effectid - 1))
	end
	local outName = obj[armName]
	if not self.armatureList[outName] then 
		self.armatureList[outName] = outName 
		armature_add(IMAGE_ANIMATION .. "battle/" .. outName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. outName .. ".plist", IMAGE_ANIMATION .. "battle/" .. outName .. ".xml")
	end
	return outName 
end

function FighterScreenView:playShow(param)
	local tankType = param.key
	local effectid = param.value
	local showTank = json.decode(param.showTank)
	self.atkTankid = showTank[1]
	self.defTankid = showTank[2]

	-- if self.testword then
	-- 	self.testword:setString( "TestWord 测试文字 tank:" .. tankType .. " 效果id: " ..  effectid )
	-- end

	-- 基础节点
	if self.baseNode then
		self.baseNode:stopAllActions()
		self.baseNode:removeAllChildren()
	end

	self.tankView = nil

	self.curPlayerIndex = 1

	self.timeScale_ = 1

	self:modelFight(tankType, effectid)
	self:modelPlay()
end

function FighterScreenView:modelFight(type, effectid)

	self.tankView = {}
	-- 攻击方
	local function atkFight(index_)
		local config = TankConfig.getConfigBy(self.atkTankid)
		local atkView = display.newNode():addTo(self.baseNode)
		atkView:setAnchorPoint(cc.p(1,0.5))
		atkView:setPosition(self.m_viewSize.width * 0.25 * index_ , self.m_viewSize.height * 0.15)
		atkView.type = type
		atkView.tankId = self.atkTankid
		atkView.effectid = effectid
		atkView.weaponViews = {}
		atkView.battle = 1

		local body = display.newSprite("image/fight/" .. config.body .. ".png"):addTo(atkView)
		body:setPosition(config.offset[1], config.offset[2])
		atkView.bodyView_ = body

		local shade = display.newSprite("image/fight/" .. config.body .. "_sd" .. ".png"):addTo(body, -1)
		shade:setPosition(body:getContentSize().width / 2 + 5, body:getContentSize().height / 2 - 3)

		local gun = config.gun
		for index = 1, #gun do -- 创建炮管
			local v = display.newSprite("image/fight/" .. gun[index].b .. ".png"):addTo(body)
			v:setAnchorPoint(gun[index].a[1], gun[index].a[2])
			v:setPosition(body:getContentSize().width / 2 + gun[index].o[1], body:getContentSize().height / 2 + gun[index].o[2])
			atkView.weaponViews[index] = v

			local shade = display.newSprite("image/fight/" .. gun[index].b .. "_sd" .. ".png"):addTo(v, -1)
			shade:setPosition(v:getContentSize().width / 2 + 5, v:getContentSize().height / 2 - 3)
		end
		self.tankView[#self.tankView + 1] = atkView
	end

	-- 防守方
	local function defFight(index_)
		local config = TankConfig.getConfigBy(self.defTankid)
		local defView = display.newNode():addTo(self.baseNode)
		defView:setAnchorPoint(cc.p(1,0.5))
		defView:setRotation(180)
		defView:setPosition(self.m_viewSize.width * 0.25 * index_, self.m_viewSize.height * 0.85)
		defView.type = type
		defView.tankId = self.defTankid
		defView.weaponViews = {}
		defView.battle = 2

		local body = display.newSprite("image/fight/" .. config.body .. ".png"):addTo(defView)
		body:setPosition(config.offset[1], config.offset[2])
		defView.bodyView_ = body
		defView.effectid = 1

		local shade = display.newSprite("image/fight/" .. config.body .. "_sd" .. ".png"):addTo(body, -1)
		shade:setPosition(body:getContentSize().width / 2 + 5, body:getContentSize().height / 2 - 3)

		local gun = config.gun
		for index = 1, #gun do -- 创建炮管
			local v = display.newSprite("image/fight/" .. gun[index].b .. ".png"):addTo(body)
			v:setAnchorPoint(gun[index].a[1], gun[index].a[2])
			v:setPosition(body:getContentSize().width / 2 + gun[index].o[1], body:getContentSize().height / 2 + gun[index].o[2])
			defView.weaponViews[index] = v

			local shade = display.newSprite("image/fight/" .. gun[index].b .. "_sd" .. ".png"):addTo(v, -1)
			shade:setPosition(v:getContentSize().width / 2 + 5, v:getContentSize().height / 2 - 3)
		end
		self.tankView[#self.tankView + 1] = defView
	end
	
	for index = 1 , 3 do
		atkFight(index)
		defFight(index)
	end
end

function FighterScreenView:modelPlay()
	local curIndex = self.curPlayerIndex
	local itemview = self.tankView[curIndex]
	local type  = itemview.type
	local tankId = itemview.tankId
	local ourAware = curIndex%2 --主观意识
	local ownList = {} -- 自己人（相对）
	local enemyList = {} -- 敌人（相对）
	local attackItemIndex = {} --攻击目标队列
	local attackIndex = 0 --攻击目标
	local attackedIndex = 0
	for index = 1 ,#self.tankView do
		local aware = index % 2
		if aware == ourAware then
			ownList[#ownList + 1] = self.tankView[index]
			if curIndex == index then
				attackIndex = #ownList
			end
		else
			enemyList[#enemyList + 1] = self.tankView[index]
		end
	end
	
	-- 准备 统计目标
	local function ready()
		if type == TANK_TYPE_1 or type == TANK_TYPE_4  then
			-- 横排、全体 3个
			for index = 1 ,#enemyList do
				attackItemIndex[#attackItemIndex + 1] = index
			end
		elseif type == TANK_TYPE_2 or type == TANK_TYPE_3 then
			-- 单一、竖排 1个
			attackItemIndex[#attackItemIndex + 1] = attackIndex
		end
	end

	-- 后坐力效果
	local function onFireRecoil(returnCallback)
		if type == TANK_TYPE_4 then
			local step = #enemyList  -- 有几个对手要发射
			local stepTime = 0.08  -- 后退每步需要时间
			local stepDis = -5     -- 后退每步的距离
			local delay = 0      -- 后退一步后再等待时间
			local ret = 0.1   -- 后退结束后返回原地的时间
			for index = 1, #itemview.weaponViews do
				local weapon = itemview.weaponViews[index]
				local actions = {}
				for index = 1, step do
					actions[#actions + 1] = cc.MoveBy:create(stepTime*self.timeScale_, cc.p(stepDis, 0))
					if not isEqual(delay, 0) then
						actions[#actions + 1] = cc.DelayTime:create(delay)
					end
					actions[#actions + 1] = cc.MoveBy:create(ret, cc.p(-stepDis, 0))
				end
				if index == 1 then
					actions[#actions + 1] = cc.DelayTime:create(0.05)
					actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)
				end
				weapon:runAction(transition.sequence(actions))
			end
		else
			local tankAttack = TankMO.queryTankAttackById( tankId )
			local recoil = json.decode(tankAttack.recoil)
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
			actions[#actions + 1] = cc.DelayTime:create(0.05)
			actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)
			itemview.bodyView_:runAction(transition.sequence(actions))
		end
	end

	-- 当前状态下炮管指向对方toPos位置需要旋转的角度
	local function getWeaponRotation(toPosItem)
		local angle = 0
		local weapon = itemview.weaponViews[1]
		if weapon then
			angle = weapon:getRotation()
		end

		local toPos = cc.p(toPosItem:y() - itemview:y(), toPosItem:x() - itemview:x())
		local rodTo = math.deg(math.atan( toPos.y / toPos.x))
		return rodTo - angle
	end

	-- 炮管移动到指向对方
	local function onActionWeaponMove(target, callback)
		local rotation = 0
		if type == TANK_TYPE_4 then
			rotation = 90
		else
			rotation = getWeaponRotation(target)
		end
		if isEqual(rotation, 0) then
			if callback then callback() end
		else
			local delay = math.abs(rotation) * TankConfig.getRotationSpeed( tankId )*self.timeScale_
			for index = 1, #itemview.weaponViews do
				local weapon = itemview.weaponViews[index]
				weapon:stopAllActions()
				weapon:runAction(transition.sequence({cc.RotateBy:create(delay, rotation)}))
			end

			itemview.bodyView_:performWithDelay(function ()
				if callback then
					callback()
				end
			end, delay + 0.02)
		end
	end

	-- 回准炮管
	local function onBackWeapon()

		local function doNext()
			self.curPlayerIndex = self.curPlayerIndex + 1
			if self.curPlayerIndex > #self.tankView then
				self.curPlayerIndex = 1
			end
			
			self:modelPlay()
		end

		if type == TANK_TYPE_4 then
			-- 全体 3个
			for index = 1, #itemview.weaponViews do
				local weapon = itemview.weaponViews[index]
				local actions = {}
				actions[#actions + 1] = cc.RotateTo:create(math.abs(90) * TankConfig.getRotationSpeed( tankId )*self.timeScale_, 0)
				if index == 1 then
					actions[#actions + 1] = cc.CallFunc:create(function ()
							doNext()
						end)
					actions[#actions + 1] = cc.CallFunc:create(function () 
						itemview.recoveryAct_ = itemview.bodyView_:runAction(transition.sequence({cc.RotateTo:create(0.25*self.timeScale_, 0),cc.CallFunc:create(function ()
							itemview.recoveryAct_ = nil
						end)})) 
					end) -- 身体归位
				end
				weapon:runAction(transition.sequence(actions))
			end
		else
			for index = 1, #itemview.weaponViews do
				local weapon = itemview.weaponViews[index]
				local rotation = weapon:getRotation()
				weapon:stopAllActions()
				weapon:runAction(cc.RotateTo:create(math.abs(rotation) * TankConfig.getRotationSpeed( tankId )  * self.timeScale_, 0))
			end
			doNext()
		end
	end


	-- 受伤
	local function hurt(target,hurtIndex)
		if tolua.isnull(target) then return end

		local rivalTankAttack = TankMO.queryTankAttackById( tankId )
		if type == TANK_TYPE_1 then
			local armName = self:addArmature(itemview, rivalTankAttack, hurtName)

			local hurt = armature_create(armName, 0, 0,
			function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
				end
			end)
		    hurt:getAnimation():playWithIndex(0)
		    hurt:addTo(target)
			-- 横排 3个
		elseif type == TANK_TYPE_2 then
			if hurtIndex == 1 or hurtIndex == 3 then
				local armName = self:addArmature(itemview, rivalTankAttack, hurtName)
				
				local hurt = armature_create(armName, target:x(), target:y(),
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
				if itemview.battle == 2 then
					hurt:setRotation(180)
				end
			    hurt:getAnimation():playWithIndex(0)
				hurt:addTo(itemview:getParent(), LAYER_EFFECT)
			else
				local armName = self:addArmature(itemview, rivalTankAttack, hurtName2)
				local hurt = armature_create(armName, target:x(), target:y(),
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
				if itemview.battle == 2 then
					hurt:setRotation(180)
				end
			    hurt:getAnimation():playWithIndex(0)
				hurt:addTo(itemview:getParent(), LAYER_EFFECT)
			end
			-- 单一 1个
		elseif type == TANK_TYPE_3 then
			-- 竖排 1个
			local armName = self:addArmature(itemview, rivalTankAttack, hurtName)
			local hurt = armature_create(armName, 0, 0,
			function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
				end
			end)
			hurt:setRotation(180)
			hurt:getAnimation():playWithIndex(0)
			hurt:addTo(target)
		elseif type == TANK_TYPE_4 then
			-- 全体 3个
			local armName = self:addArmature(itemview, rivalTankAttack, hurtName)
			local hurt = armature_create(armName, target:x(), target:y(),
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
		    hurt:getAnimation():playWithIndex(0)
			hurt:addTo(itemview:getParent(), LAYER_EFFECT)
		end
	end

	-- 攻击特效
	local function onFireEffect(target)
		local config = TankConfig.getConfigBy( tankId )
		local tankAttack = TankMO.queryTankAttackById( tankId )
		if type == TANK_TYPE_1 or type == TANK_TYPE_3 then
			-- 横排 3个
			for index = 1, #itemview.weaponViews do
				local weapon = itemview.weaponViews[index]

				local armName = self:addArmature(itemview, tankAttack, fireName)

				local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2, weapon:getContentSize().height))
				local pos = itemview:convertToNodeSpace(pos)

				local fire = armature_create(armName, pos.x, pos.y,
					function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
							-- print("结束了")
							armature:removeSelf()
						end
					end)
				fire:setRotation(weapon:getRotation())
			    fire:getAnimation():playWithIndex(0)
		    	fire:addTo(itemview)
			end
		elseif type == TANK_TYPE_2 then
			-- 单一 1个
			for index = 1, #itemview.weaponViews do
				local weapon = itemview.weaponViews[index]

				local armName = self:addArmature(itemview, tankAttack, fireName)
				local pos = cc.p(weapon:getContentSize().width * config.gun[index].a[1], weapon:getContentSize().height)
				local playTimes = 1
				local fire = armature_create(armName, pos.x, pos.y,
					function (movementType, movementID, armature)
						if movementType == MovementEventType.LOOP_COMPLETE then
							playTimes = playTimes + 1
							if playTimes >= 5 then
								armature:removeSelf()
							end
						end
					end)
			    fire:getAnimation():playWithIndex(0)
		    	fire:addTo(weapon)
			end
		-- elseif type == TANK_TYPE_3 then
		-- 	-- 竖排 1个
		-- 	for index = 1, #itemview.weaponViews do
		-- 		local weapon = itemview.weaponViews[index]
		-- 		local armName = tankAttack.fireName
		-- 		if not self.armatureList[armName] then self.armatureList[armName] = armName end
		-- 		armature_add(IMAGE_ANIMATION .. "battle/" .. armName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. armName .. ".plist", IMAGE_ANIMATION .. "battle/" .. armName .. ".xml")
		-- 		local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2, weapon:getContentSize().height))
		-- 		local pos = itemview:convertToNodeSpace(pos)
		-- 		local fire = armature_create(tankAttack.fireName, pos.x, pos.y,
		-- 		function (movementType, movementID, armature)
		-- 			if movementType == MovementEventType.COMPLETE then
		-- 				-- print("结束了")
		-- 				armature:removeSelf()
		-- 			end
		-- 		end)
		-- 		fire:setRotation(weapon:getRotation())
		-- 		fire:getAnimation():playWithIndex(0)
		-- 		fire:addTo(itemview)
		-- 	end
		elseif type == TANK_TYPE_4 then
			-- 全体 3个
		end
	end

	-- 开火
	local function fire(target)
		local config = TankConfig.getConfigBy( tankId )
		local tankAttack = TankMO.queryTankAttackById( tankId )
		if type == TANK_TYPE_1 or type == TANK_TYPE_3 then
			-- 横排 3个
			for index = 1, #itemview.weaponViews do
				local weapon = itemview.weaponViews[index]

				local armName = self:addArmature(itemview, tankAttack, ammoName)

				local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2, weapon:getContentSize().height))
				local pos = itemview:getParent():convertToNodeSpace(pos)
				local ammo = armature_create(armName, pos.x, pos.y, function (movementType, movementID, armature) end)
				ammo:getAnimation():playWithIndex(0)
				ammo:addTo(itemview:getParent(), LAYER_BOMB)

				ammo:setRotation(weapon:getRotation())

				local pos = cc.p(target:x(), target:y()) 

				ammo:runAction(transition.sequence({cc.MoveTo:create(0.3*self.timeScale_, pos), cc.CallFuncN:create(function(sender)
					sender:removeSelf()
					hurt(target)
				end)}))
			end
		elseif type == TANK_TYPE_2 then
			-- 单一 1个
			local offset = {{15, 60}, {7.5, 35}, {-20, 20}, {10, -5}, {-15, 15}}  -- 第一、三是没有打中坦克的
			local recoil = json.decode(tankAttack.recoil)
			itemview.fireAmmoIndex_ = 0
			local function fire2()
				itemview.fireAmmoIndex_ = itemview.fireAmmoIndex_ + 1
				for index = 1, #itemview.weaponViews do
					local weapon = itemview.weaponViews[index]
					local armName = self:addArmature(itemview, tankAttack, ammoName)
					local pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width * config.gun[index].a[1], weapon:getContentSize().height + 60))
					local pos = itemview:getParent():convertToNodeSpace(pos)

					local ammo = armature_create(armName, 0, 0, function () end)
					ammo:setPosition(pos.x, pos.y)
					ammo:getAnimation():playWithIndex(0)
					ammo:addTo(itemview:getParent(), LAYER_BOMB)

					ammo:setRotation(weapon:getRotation())
					local pos = cc.p(target:getPositionX() + offset[itemview.fireAmmoIndex_][1], target:getPositionY() + offset[itemview.fireAmmoIndex_][2])
					ammo:runAction(transition.sequence({cc.MoveTo:create(0.3*self.timeScale_, pos), cc.CallFuncN:create(function(sender)
						sender:removeSelf()
						hurt(target)
					end)}))
				end
			end
			local actions = {}
			for index = 1, recoil[1] do
				actions[#actions + 1] = cc.CallFunc:create(function() fire2() end)
				actions[#actions + 1] = cc.DelayTime:create(0.2 * self.timeScale_)
			end
			itemview.bodyView_:runAction(transition.sequence(actions))
		elseif type == TANK_TYPE_4 then
			-- 全体 3个
			local armName = self:addArmature(itemview, tankAttack, ammoName)

			local m_curFireActionIndex = 1

			local function ammoUpdate(ammo)
				local armflameName = "bt_ammo_4_flame"
				armature_add(IMAGE_ANIMATION .. "battle/" .. armflameName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. armflameName .. ".plist", IMAGE_ANIMATION .. "battle/" .. armflameName .. ".xml")
	
				local flame = armature_create(armflameName, ammo:x(), ammo:y(), function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
								armature:removeSelf()
							end
					end)
				flame:getAnimation():playWithIndex(0)
				flame:addTo(itemview:getParent(), LAYER_BOMB)


				local lastPos = ammo.lastPos
				local deltaX = ammo:x() - lastPos.x
				local deltaY = ammo:y() - lastPos.y
				local degree = math.deg(math.atan2(deltaX, deltaY))
				ammo:setRotation(degree)
				flame:setRotation(degree)

				ammo.lastPos = cc.p(ammo:x(), ammo:y())
			end

			local function fireAmmo(index)
				local target = enemyList[m_curFireActionIndex]

				for index = 1, #itemview.weaponViews do
					local weapon = itemview.weaponViews[index]

					local ammo = armature_create(armName, 0, 0, function (movementType, movementID, armature) end)
					ammo:getAnimation():playWithIndex(0)
					ammo:addTo(itemview:getParent(), LAYER_BOMB)

					local pos = nil
					local rivalPos = cc.p(target:x(), target:y())
					if m_curFireActionIndex == 1 or m_curFireActionIndex == 3 then  -- 根据actionIndex使每次发射的炮弹错开位置
						pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2 - 20, weapon:getContentSize().height + 20))
						pos = itemview:getParent():convertToNodeSpace(pos)
						ammo:setPosition(pos.x, pos.y)
					else
						pos = weapon:convertToWorldSpace(cc.p(weapon:getContentSize().width / 2 + 20, weapon:getContentSize().height + 20))
						pos = itemview:getParent():convertToNodeSpace(pos)
						ammo:setPosition(pos.x, pos.y)
					end

					local config = ccBezierConfig()
					config.endPosition = rivalPos
					if itemview.battle == 1 then
						if attackIndex == 1 then
							config.controlPoint_1 = cc.p(pos.x - 150, pos.y + 180)
							config.controlPoint_2 = cc.p(rivalPos.x, rivalPos.y - 180)
						elseif attackIndex == 3 then
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
					
					ammo:runAction(transition.sequence({cc.EaseSineIn:create(cc.BezierTo:create(0.9*self.timeScale_, config)), cc.CallFuncN:create(function(sender)
						sender:removeSelf()
						hurt(target)
					end)}))
					ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())

					local node = display.newNode():addTo(ammo)
					nodeExportComponentMethod(node)
					node:setNodeEventEnabled(true)
					node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) ammoUpdate(ammo) end)
					node:scheduleUpdate()
				end
				m_curFireActionIndex = m_curFireActionIndex + 1
			end

			local ras = {}
			-- 要向几个对象同时发射
			for actionIndex = 1, #enemyList do
				ras[#ras + 1] = cc.CallFunc:create(function() fireAmmo(actionIndex) end)
				ras[#ras + 1] = cc.DelayTime:create(0.08 * 2*self.timeScale_)
			end
			itemview.bodyView_:runAction(transition.sequence(ras))
		end
	end

	-- 攻击
	local function atk(target)
		onFireRecoil(function()
			if type == TANK_TYPE_4 then
				onBackWeapon()
			else
				attackedIndex = attackedIndex + 1
				if attackedIndex >= #attackItemIndex then
					onBackWeapon()
				end
			end
		end)

		onFireEffect(target)
	
		fire(target)

		-- if type == 1 then
		-- 	-- 横排 3个
		-- elseif type == 2 then
		-- 	-- 单一 1个
		-- elseif type == 3 then
		-- 	-- 竖排 1个
		-- elseif type == 4 then
		-- 	-- 全体 3个
		-- end
	end

	-- 瞄准
	local function takeAim(target)
		onActionWeaponMove(target,function()
			atk(target)
		end)
	end

	-- 搜索
	local function search()
		if type == TANK_TYPE_1 or
			type == TANK_TYPE_2 or 
			type == TANK_TYPE_3 then
			-- 横排 3个
			for index = 1, #attackItemIndex do
				local searchIndex = attackItemIndex[index]
				local searchItem = enemyList[searchIndex]
				searchItem:runAction(transition.sequence({cc.DelayTime:create(1 * index - 1),cc.CallFuncN:create(function(sender)
					takeAim(sender)
				end)}))
			end
		elseif type == TANK_TYPE_4 then
			-- 全体 3个
			if itemview.recoveryAct_ then
				itemview.bodyView_:stopAction(itemview.recoveryAct_)
				itemview.recoveryAct_ = nil
			end
			itemview.bodyView_:runAction(transition.sequence({cc.RotateTo:create(0.25*self.timeScale_, -90), cc.CallFunc:create(function() 
				takeAim(nil)
			end)}))
		end
	end

	ready()
	search()
end












local FightEffectTableView = class("FightEffectTableView", TableView)

function FightEffectTableView:ctor(size,updataCallback,doload)
	FightEffectTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 172)
	self.updataCallback = updataCallback
	self.doload = doload
end

function FightEffectTableView:onEnter()
	FightEffectTableView.super.onEnter(self)
end

function FightEffectTableView:reLoadInfo(data)
	self.m_effectList = {}
	self.m_effectList = data
	self.curShow = self.curShow or 101
	self:reloadData()
	if self.m_offset then
		self:setContentOffset(self.m_offset)
	end
end

function FightEffectTableView:numberOfCells()
	return 4
end

function FightEffectTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function FightEffectTableView:createCellAtIndex(cell, index)
	FightEffectTableView.super.createCellAtIndex(self, cell, index)

	local eInfo = self.m_effectList[index]
	local showApply = false
	local used = 0
	local has = {}
	local unlock = {}
	local items = {}
	for k ,v in pairs(eInfo.unlock) do
		unlock[v] = true
	end

	local nameline = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(cell,2)
	nameline:setPreferredSize(cc.size(self.m_cellSize.width * 0.75 , nameline:height() ))
	nameline:setCapInsets(cc.rect(210, 22, 1, 1))
	nameline:setAnchorPoint(cc.p(0,1))
	nameline:setPosition(0 , self.m_cellSize.height )

	local title = ui.newTTFLabel({text = CommonText[162][index], font = G_FONT, size = 22, x = 100, y = nameline:height() * 0.5, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(nameline)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_108.png"):addTo(cell,1)
	bg:setAnchorPoint(cc.p(0.5,0))
	bg:setPosition(self.m_cellSize.width * 0.5 , 10 )

	local itemBg = display.newSprite(IMAGE_COMMON .. "info_bg_109.png"):addTo(bg)
	itemBg:setPosition(itemBg:width()*0.5 + 15, bg:height() * 0.5)

	local item = display.newSprite(IMAGE_COMMON .. "fighter/tank_" .. index .. ".png"):addTo(itemBg)
	item:setPosition(itemBg:width() * 0.5 , itemBg:height() * 0.5)

	local namebg = display.newSprite(IMAGE_COMMON .. "info_bg_110.png"):addTo(bg)
	namebg:setPosition(bg:width() * 0.5 ,bg:height() - namebg:height() * 0.75)

	local desc = ui.newTTFLabel({text = "", font = G_FONT, size = 22, x = 0, y = namebg:height() * 0.5, color = COLOR[1], align = ui.TEXT_ALIGN_LEFT}):addTo(namebg)
	desc:setAnchorPoint(cc.p(0,0.5))

	for vindex = 1, 3 do
		local icon = "a_e_0"
		local eData = FighterEffectMO.queryTypeForEid(eInfo.type, vindex)
		local unOpen = false
		if eData then
			icon = eData.icon
			if not unlock[vindex] and vindex ~= 1 then
				icon = icon .. "_n" 
				unOpen = true
			else
				has[eData.id] = true
			end
			items[eData.id] = vindex
		end

		local normal = display.newSprite(IMAGE_COMMON .. "fighter/" .. icon .. ".png")
	    local itembtn = ScaleButton.new(normal, handler(self,self.takeItemCallback)):addTo(bg)
	    itembtn:setPosition(bg:width() * 0.25 + vindex * normal:width() * 1.2, bg:height() * 0.5 - 17.5)
	    itembtn.value = vindex
	    itembtn.key = eInfo.type
	    itembtn.eData = eData
	    itembtn.desc = desc

	    if unOpen then
	    	local unactive = display.newSprite(IMAGE_COMMON .. "unactive.png"):addTo(itembtn)
	    	unactive:setScale(0.75)
	    	unactive:setPosition(itembtn:width() * 0.5 , itembtn:height() * 0.5)
	    end

	    if eInfo.useId == vindex then
	    	local using = display.newSprite(IMAGE_COMMON .. "using.png"):addTo(itembtn)
	    	using:setScale(0.75)
			using:setAnchorPoint(cc.p(0,1))
			using:setPosition(0,itembtn:height())
			if eData and desc:getString() == "" then desc:setString(eData.desc) end
			used = eData.id
	    end

	    if self.curShow and eData and self.curShow == eData.id then
	    	local show = display.newSprite(IMAGE_COMMON .. "show.png"):addTo(itembtn)
	    	show:setPosition(itembtn:width() * 0.5,itembtn:height() * 0.5)
	    	self:takeItemCallback(nil,itembtn)
	    	showApply = true
	    end
	end
	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_world.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_world.png")
	selected:setScale(0.85)
	local applyBtn = MenuButton.new(normal, selected, nil, handler(self,self.applyCallback)):addTo(bg)
	applyBtn:setPosition(bg:width() * 0.85, bg:height() * 0.5 - 17.5)
	applyBtn:setVisible(showApply)
	-- applyBtn:setLabel(CommonText[1119])
	applyBtn.used = used
	applyBtn.has = has
	applyBtn.type = eInfo.type
	applyBtn.items = items
	applyBtn.index = index

	local apply = display.newSprite(IMAGE_COMMON .. "apply.png"):addTo(applyBtn)
	apply:setPosition(applyBtn:width() * 0.5, applyBtn:height() * 0.5 + 2)

	return cell
end

function FightEffectTableView:takeItemCallback(tar,sender)
	ManagerSound.playNormalButtonSound()

	if not sender.eData then
		Toast.show(CommonText[1120])
		return
	end

	-- 关闭点击
	sender:setEnabled(false)
	-- 刷新文字
	sender.desc:setString(sender.eData.desc)

	local tid = sender.eData.id
	local tkey = sender.key
	local tvalue = sender.value
	local tshowTank = sender.eData.showTank
	local out = {key = tkey, value = tvalue, showTank = tshowTank}
	if self.updataCallback then self.updataCallback(out) end

	-- 刷新
	if self.curShow and tid ~= self.curShow then
		self.curShow = tid
		self.m_offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(self.m_offset)
	end
end

function FightEffectTableView:applyCallback(tar,sender)
	ManagerSound.playNormalButtonSound()
	local used = sender.used 
	local has = sender.has
	local type = sender.type
	local items = sender.items
	local index = sender.index
	if self.curShow == used then 
		Toast.show(CommonText[1122])
		return
	end

	if not has[self.curShow] then
		local i = items[self.curShow]
		local eData = FighterEffectMO.queryTypeForEid(type, i)
		local unLockLv = eData.unLockLv
		if unLockLv then
			Toast.show(string.format(CommonText[1121],CommonText[162][index],unLockLv))
		else
			Toast.show(CommonText[100012][1])
		end
		return
	end

	local function callback(data)
		if self.doload then self.doload() end
		Toast.show(CommonText[1119]..CommonText[1116][2])
	end

	FighterEffectBO.UseAttackEffect(callback, self.curShow)
end












local FightEffectMangaerView = class("FightEffectMangaerView", UiNode)

function FightEffectMangaerView:ctor(size)
	FightEffectMangaerView.super.ctor(self)
	self.ViewSize = size
end

function FightEffectMangaerView:onEnter()
	FightEffectMangaerView.super.onEnter(self)

	local showScreenBg = display.newSprite(IMAGE_COMMON .. "info_bg_111.png"):addTo(self:getBg(),1)
	showScreenBg:setAnchorPoint(cc.p(0.5,1))
	showScreenBg:setPosition(self.ViewSize.width * 0.5,self.ViewSize.height - 5 - 14)

	local showScreen = FighterScreenView.new(cc.size(showScreenBg:width() - 10, showScreenBg:height() - 10)):addTo(showScreenBg, 1)
	showScreen:setAnchorPoint(cc.p(0,0))
	showScreen:setPosition(5,5)
	self.m_showScreen = showScreen

	local showScreenTop = display.newSprite(IMAGE_COMMON .. "info_bg_112.png"):addTo(showScreenBg , 2)
	showScreenTop:setPosition(showScreenBg:width() * 0.5,showScreenBg:height() * 0.5 )


	local tankViewBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(self:getBg(),2)
	tankViewBg:setPreferredSize(cc.size(self.ViewSize.width - 30, self.ViewSize.height - 5 -5 - showScreenTop:height() ))
	tankViewBg:setAnchorPoint(cc.p(0.5,0))
	tankViewBg:setCapInsets(cc.rect(60, 60, 1, 1))
	tankViewBg:setPosition(self.ViewSize.width * 0.5,0)

	local tankNameBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(tankViewBg,1)
	tankNameBg:setPosition(tankViewBg:width() * 0.5, tankViewBg:height() - tankNameBg:height() * 0.5 - 3)

	ui.newTTFLabel({text = CommonText[1118], font = G_FONT, size = 22, x = tankNameBg:width() * 0.5, y = tankNameBg:height() * 0.5, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(tankNameBg)

	local view = FightEffectTableView.new(cc.size(tankViewBg:width() - 46, tankViewBg:height() - tankNameBg:height() - 30),handler(self,self.updateScreenData),handler(self,self.doLoad)):addTo(tankViewBg)
	view:setAnchorPoint(cc.p(0,0))
	view:setPosition(23,20)
	self.m_view = view

	self:doLoad()
end

function FightEffectMangaerView:doLoad()
	FighterEffectBO.GetAttackEffect(handler(self,self.loadData))
end

function FightEffectMangaerView:updateScreenData(param)
	if self.m_showScreen then
		self.m_showScreen:playShow(param)
	end
end

function FightEffectMangaerView:loadData(data)
	local effectData = PbProtocol.decodeArray(data["effect"])
	self.m_view:reLoadInfo(effectData)
end

function FightEffectMangaerView:onExit()
	FightEffectMangaerView.super.onExit(self)
	
end

return FightEffectMangaerView