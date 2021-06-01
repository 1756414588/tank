
-- 坦克、战车、火炮、火箭的父类

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local Fighter = class("Fighter", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)


Fighter.LAYER_BODY = 1

Fighter.LAYER_BODY1 = 3

Fighter.LAYER_BOMB1 = 2

Fighter.LAYER_BOMB = 5

Fighter.LAYER_EFFECT = 9 

Fighter.LAYER_EFFECT_WORD = 10

WEAPON_ROTATE_TIME = 0.01 -- 武器旋转的

Fighter.ammoName 	= "ammoName"
Fighter.hurtName 	= "hurtName"
Fighter.hurtName2 	= "hurtName2"
Fighter.fireName 	= "fireName"
Fighter.dieName 	= "dieName"

function Fighter:ctor(battleFor, pos, tankId, tankCount, hp)
	self:setCascadeOpacityEnabled(true)

	self.timeScale_ = 1

	self.battleFor_ = battleFor
	self.pos_ = pos
	self.tankId_ = tankId

	self.view_ = nil -- tank的各个view的载体
	self.bodyView_ = nil  -- 车身
	self.weaponViews_ = {}  -- 炮管 武器

	self.bulletScheduler_ = nil -- 炮弹到达对方的scheduler的handler

	self.totalHp_ = hp  -- 总的hp
	self.curHp_ = self.totalHp_ -- 当前hp
	self.count_ = tankCount

	self.roundIndex_ = 0
	self.actionIndex_ = 0
	self.roundEndCallback = nil

	self.isReborn_ = false ----是否是复活的
	self.frightenAniView = nil -- 是否中了震慑

	self.fireState_ = 0   ---攻击状态
	self.ammoCounts = 0
	gprint("[Fighter] create id:" .. tankId, " battleFor:" .. battleFor, "pos:" .. pos, "hp:" .. self.totalHp_)

	self.fighterEffect = 1 -- 战斗特效 默认值

	if UserMO.queryFuncOpen(UFP_FIGHTER) then
		self.fighterEffect = BattleMO.getFighterEffect(battleFor, pos)
	end
	
	------------------------------------------------------------
	-- if self.battleFor_ == BATTLE_FOR_ATTACK then
	-- 	local bg = display.newScale9Sprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(self, 100)
	-- else
	-- 	local bg = display.newScale9Sprite(IMAGE_COMMON .. "icon_arrow_down.png"):addTo(self, 100)
	-- end
	-- local cha = display.newSprite(IMAGE_COMMON .. "icon_cha.png"):addTo(self, 101)
	-- cha:setScale(0.3)
	--------------------------------------------------------------

	require("app.fight.config.TankConfig")
	local config = TankConfig.getConfigBy(self.tankId_)

	if EntityFactory.isAirsship(self.tankId_) then
		-- hp条
		self:showHp(0)		
	elseif EntityFactory.isBountyBoss(self.tankId_) then
		self:showHp(0)
	elseif not config then
		gprint("[Fighter] create no config ERROR!!! id:", tankId, "pos:", pos, "for:", battleFor)
		error("[Fighter] create no config")
	else
		self.view_ = display.newNode():addTo(self)

		local body = display.newSprite("image/fight/" .. config.body .. ".png"):addTo(self.view_)
		body:setPosition(config.offset[1], config.offset[2])
		self.bodyView_ = body

		local shade = display.newSprite("image/fight/" .. config.body .. "_sd" .. ".png"):addTo(body, -1)
		shade:setPosition(body:getContentSize().width / 2 + 5, body:getContentSize().height / 2 - 3)

		if self.battleFor_ == BATTLE_FOR_DEFEND then
			self.view_:setScaleY(-1)
		end

		local gun = config.gun
		for index = 1, #gun do -- 创建炮管
			local v = display.newSprite("image/fight/" .. gun[index].b .. ".png"):addTo(body)
			v:setAnchorPoint(gun[index].a[1], gun[index].a[2])
			v:setPosition(body:getContentSize().width / 2 + gun[index].o[1], body:getContentSize().height / 2 + gun[index].o[2])
			self.weaponViews_[index] = v

			local shade = display.newSprite("image/fight/" .. gun[index].b .. "_sd" .. ".png"):addTo(v, -1)
			shade:setPosition(v:getContentSize().width / 2 + 5, v:getContentSize().height / 2 - 3)

			--------------------------------------------------------------
			-- local bg = nil
			-- if self.battleFor_ == BATTLE_FOR_ATTACK then
			-- 	bg = display.newScale9Sprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(body, 100)
			-- else
			-- 	bg = display.newScale9Sprite(IMAGE_COMMON .. "icon_arrow_down.png"):addTo(body, 100)
			-- end
			-- bg:setPosition(v:getPositionX(), v:getPositionY())

			-- local value = ui.newTTFLabel({text = index, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(body, 1000)
			-- value:setPosition(bg:getPositionX(), bg:getPositionY())
			--------------------------------------------------------------
		end

		if self.tankId_ == TANK_BOSS_CONFIG_ID or self.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then
			for index = 1, ActivityCenterMO.beforeBattleWhich_ do
				self:onWeaponDie(index)
			end

			if #self.weaponViews_ >= 6 then
				self.weaponViews_[5]:setZOrder(2)
				self.weaponViews_[6]:setZOrder(2)
			end
			-- 	self.weaponViews_[index]:setVisible(false)
		else
			-- 数字背景
			local numBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_61.png"):addTo(self)

			-- 数量
			local label = ui.newTTFLabel({text = self.count_, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(numBg)
			self.countLabel_ = label

			numBg:setPreferredSize(cc.size(label:getContentSize().width + 20, numBg:getContentSize().height))

			label:setPosition(numBg:getContentSize().width / 2, numBg:getContentSize().height / 2)
			
			if self.battleFor_ == BATTLE_FOR_DEFEND then numBg:setPosition(-25, 30)
			else numBg:setPosition(-25, -30) end

			-- hp条
			self:showHp(0)
		end
	end
end

function Fighter:fireBegin()
	self.fireState_ = 1
end

function Fighter:fireOver()
	self.fireState_ = 0
end

function Fighter:isFireOver()
	return self.fireState_ == 0
end

function Fighter:setTimeScale( timeScale )
	self.timeScale_ = timeScale
end

function Fighter:move(time, distance, callback)
	self:stopAllActions()
	self:runAction(transition.sequence({cc.MoveBy:create(time*self.timeScale_, cc.p(0, distance)), cc.CallFunc:create(function() self.m_move_ = false; if callback then callback() end end)}))

	self.m_move_ = true

	local function showTread(dt)
		if not self.m_move_ then return end

		-- 车辙印
		armature_add(IMAGE_ANIMATION .. "battle/bt_tank_tread.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_tank_tread.plist", IMAGE_ANIMATION .. "battle/bt_tank_tread.xml")
		local tread = armature_create("bt_tank_tread", self:getPositionX(), self:getPositionY(), function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
			end)
		tread:getAnimation():playWithIndex(0)
		tread:addTo(self:getParent(), -1)
	end

	self:setNodeEventEnabled(true)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) showTread(ammo) end)
	self:scheduleUpdate()
end

-- 自身入场时炮管运动到正前方
function Fighter:onFightEnter(callback,isReborn)
	if isReborn then
		self.isReborn_ = true
	else
		self.isReborn_ = false
	end

	local moveDis = BATTLE_TANK_SPEED * BATTLE_TANK_ENTER_TIME
	if self.battleFor_ == BATTLE_FOR_ATTACK then
		local config = FightAtkFormatConifg[self.pos_]
		if isReborn then
			self:setPosition(config.offset.x, config.offset.y)
		else
			self:setPosition(config.offset.x, config.offset.y - moveDis)
			self:move(BATTLE_TANK_ENTER_TIME, moveDis, callback)
		end
	else
		local config = FightDefFormatConifg[self.pos_]
		if isReborn then
			self:setPosition(config.offset.x, config.offset.y)
		else
			self:setPosition(config.offset.x, config.offset.y + moveDis)
			self:move(BATTLE_TANK_ENTER_TIME, -moveDis, callback)
		end
	end

	if self.tankId_ == TANK_BOSS_CONFIG_ID or self.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then
	elseif EntityFactory.isBountyBoss(self.tankId_) then
	else
		if self.pos_ == 1 or self.pos_ == 2 or self.pos_ == 4 or self.pos_ == 5 then  -- 左路和中路
			for index = 1, #self.weaponViews_ do
				local weapon = self.weaponViews_[index]
				weapon:stopAllActions()
				weapon:setRotation(-90)
				weapon:runAction(cc.RotateTo:create(BATTLE_ENTER_TIME*self.timeScale_, 0))
			end
		elseif self.pos_ == 3 or self.pos_ == 6 then
			for index = 1, #self.weaponViews_ do
				local weapon = self.weaponViews_[index]
				weapon:stopAllActions()
				weapon:setRotation(90)
				weapon:runAction(cc.RotateTo:create(BATTLE_ENTER_TIME*self.timeScale_, 0))
			end
		end
	end
end

-- 开始某个回合roundIndex
function Fighter:onStartRound(roundIndex, doneCallback)
	if self.roundIndex_ ~= 0 then
		gprint("error!!! old round:", self.roundIndex_, "new:", roundIndex)
		-- error("Fighter:onStartRound")
	end

	self.roundIndex_ = roundIndex
	self.actionIndex_ = 1
	self.roundEndCallback = doneCallback  -- 此回调被调用表示当前回合结束，至于什么时候可以进入下一个回合有BattleBO根据表来确定

	for index = 1, #self.weaponViews_ do  -- 默认朝前
		local weapon = self.weaponViews_[index]
		weapon:stopAllActions()
		weapon:setRotation(0)
	end
	--检查特效
	FightEffect.showEffect(self.roundIndex_,function()
			FightEffect.checkRemoveSkill(self.roundIndex_,function()
				self:onActionEnter()
			end)
	end)
end

-- 开始当前的action，炮管移动指向对方，发射。
function Fighter:onActionEnter()
	local round = BattleMO.getRoundAtIndex(self.roundIndex_)

	if UserMO.queryFuncOpen(UFP_FRIGHTEN) and table.getn(round.action) == 0 then
		-- 解除震慑 消除震慑动画
		self:hideFrighten()
		-- if doneCallback then doneCallback() end
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

			-- self.roundIndex_ = 0
			-- self.actionIndex_ = 0

			if self.roundEndCallback then self.roundEndCallback() end
		else
			-- 当前action结束，开始下一个action
			local time = 0.2 -- 保证每个action在time的时间内完成
			self.actionSchedulerHandler_ = scheduler.performWithDelayGlobal(function() self.actionSchedulerHandler_ = nil; self.actionIndex_ = self.actionIndex_ + 1; self:onActionEnter() end, time)
		end
	end


	local action = round.action[self.actionIndex_]

	-- gprint("[Fighter] ACTION start. idx:" .. self.actionIndex_, "pos:" .. self.pos_, "btFor:" .. self.battleFor_,
	-- 	"target:" .. action.target, "crit:", action.crit, "dodge:", action.dodge, "impale:", action.impale)
	-- gdump(action.hurt, "[Fighter] enter actions hurt")
	self:onActionWeaponMove(action, function() self:onFire(action, nxtAction) end)
end

-- 在一个action开始时，炮管移动到指向对方
function Fighter:onActionWeaponMove(action, doneCallback)
	local rotation = 0
	if self.tankId_ == TANK_BOSS_CONFIG_ID or self.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then  -- 自身就是世界BOSS
		rotation = 0
	elseif EntityFactory.isBountyBoss(self.tankId_) then
		rotation = 0
	elseif self.tankId_ == 404 or self.tankId_ == 107 then
		rotation = 0
	else
		local tankDB = TankMO.queryTankById(self.tankId_)
		if tankDB.type == TANK_TYPE_ROCKET then
			rotation = 90
		else
			if self.battleFor_ == BATTLE_FOR_ATTACK and BattleMO.defSeveralForOne_ then  -- 防守方是世界BOSS
				local targetTank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, TANK_BOSS_POSITION_INDEX)
				local targetWeapon = targetTank:getWeaponByIndex(targetTank:getWeaponIndexByKey(action.target))
				local targetPos = targetWeapon:getParent():convertToWorldSpace(cc.p(targetWeapon:getPositionX(), targetWeapon:getPositionY()))

				local selfWeapon = self.weaponViews_[1]
				local selfPos = selfWeapon:getParent():convertToWorldSpace(cc.p(selfWeapon:getPositionX(), selfWeapon:getPositionY()))

				local deltaX = targetPos.x - selfPos.x
				local deltaY = targetPos.y - selfPos.y

				rotation = math.deg(math.atan2(deltaX, deltaY)) - selfWeapon:getRotation()
			else
				local targetTank = BattleMO.getTankByKey(action.target)

				if not targetTank then
					gdump(action, "Fighter:onActionEnter target is NULL!!!!")
					gprint("Fighter:onActionEnter", action.target, self.actionIndex_)
				end

				rotation = self:getWeaponRotation(targetTank.pos_)
			end
		end
	end

	gprint("[Fighter] ACTION start weapon move. idx:" .. self.actionIndex_, "pos:" .. self.pos_, "btFor:" .. self.battleFor_, "rotat:", rotation)

	if isEqual(rotation, 0) then
		if doneCallback then doneCallback() end
	else
		local delay = math.abs(rotation) * TankConfig.getRotationSpeed(self.tankId_)*self.timeScale_
		for index = 1, #self.weaponViews_ do
			local weapon = self.weaponViews_[index]
			weapon:stopAllActions()
			weapon:runAction(transition.sequence({cc.RotateBy:create(delay, rotation)}))
		end

		self.bodyView_:performWithDelay(function ()
			if doneCallback then
				doneCallback()
			end
		end, delay + 0.02)
	end
end

function Fighter:onFire(action, doneCallback)
	local targetPos = 0	

	if UserMO.queryFuncOpen(UFP_FRIGHTEN) then
		self:hideFrighten()
	end

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

-- 发射时自身的后坐力表现效果
-- returnCallback: 回到原位的回调
function Fighter:onFireRecoil(targetPos, returnCallback)
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

	local delayTime = 0.05
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

	actions[#actions + 1] = cc.DelayTime:create(delayTime*self.timeScale_)
	actions[#actions + 1] = cc.CallFunc:create(function() if returnCallback then returnCallback() end end)
	self.bodyView_:runAction(transition.sequence(actions))
end

-- 发射时自身，以及炮管的效果
function Fighter:onFireEffect(targetPos)
end

-- 发射炮弹
-- firstCallback:第一个到达的回调
-- arriveCallback: 到达对方时的回调
-- endCallback: 最后一个炮弹到达对方时的回调
function Fighter:onFireAmmo(targetPos, firstCallback, arriveCallback, endCallback)
end

-- atkPos: 攻击者的位置
function Fighter:onHurtFirst(atkPos, roundIndex, actionIndex, hurtIndex, hurtPos)
	local round = BattleMO.getRoundAtIndex(roundIndex)
	if not round then
		gprint("Fighter:onHurtFirst roundIndex", roundIndex)
	end
	local action = round.action[actionIndex]

	gprint("[Fighter] hurt first. idx:" .. actionIndex, "pos:" .. self.pos_, "btFor:" .. self.battleFor_,
		"target:" .. action.target, "crit:", action.crit, "dodge:", action.dodge, "impale:", action.impale)

	if action.impale then  -- 发生了穿刺
		gprint("[Fighter] impale  .. 发生了穿刺 .. " .. self.roundIndex_)
		self:hideSkill1()
		self:onImpale()
		if UserMO.queryFuncOpen(UFP_FRIGHTEN) then
			self:hideFrighten()
		end
	end
	if action.frighten then -- 发生了 震慑
		gprint("[Fighter] frighten  .. 发生了震慑 .. " .. self.roundIndex_ .. " " .. self.pos_)
		if UserMO.queryFuncOpen(UFP_FRIGHTEN) then
			self:showFrighten()
		end
	end

	if action.dodge then -- 发生了闪避
		gprint("[Fighter] dodge")
		--gprint("pos: " .. self.pos_ .. "  id: " .. actionIndex .. "  ----- 闪避 -----")
		local view = display.newSprite(IMAGE_COMMON .. "label_miss.png"):addTo(self:getParent(), Fighter.LAYER_EFFECT_WORD)
		view:setPosition(self:getPositionX(), self:getPositionY())
		view:runAction(transition.sequence({cc.EaseBackOut:create(cc.ScaleBy:create(0.2, 1.5)), cc.DelayTime:create(0.02), cc.MoveBy:create(0.06, cc.p(0, 20)), cc.FadeOut:create(0.05), cc.CallFuncN:create(function(sender)
				sender:removeSelf()
			end)}))
	else
		FightEffect.showHurtEffect(self)
	end
end

---移除烟雾弹
function Fighter:hideSkill1()
	gprint("@^^^^^移除烟雾弹^^^^")
	FightEffect.removeSkill1(self)
end

-- 每次受到的伤害
function Fighter:onHurtTime(atkPos, roundIndex, actionIndex, hurtIndex, hurtPos, atkfighterEffect)
	local function showHurt(hurtValue, crit, parent)
		-- local hurtLabel = ui.newTTFLabel({text = "-" .. action.hurt[hurtIndex], font = G_FONT, size = FONT_SIZE_HUGE, x = 0, y = 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self)
		local hurtLabel = ui.newBMFontLabel({text = hurtValue, font = "fnt/num_6.fnt", size = FONT_SIZE_HUGE, x = parent:getPositionX(), y = parent:getPositionY() + 30}):addTo(parent:getParent(), 100)
		if crit then  -- 发生了暴击
			hurtLabel:setFntFile("fnt/num_7.fnt")
		end
		hurtLabel:runAction(transition.sequence({cc.EaseBackOut:create(cc.ScaleBy:create(0.2, 1.5)), cc.DelayTime:create(0.02), cc.MoveBy:create(0.06, cc.p(0, 20)), cc.FadeOut:create(0.05), cc.CallFuncN:create(function(sender)
				sender:removeSelf()
			end)}))
	end

	-- 攻击者
	local rival = self:getRival(atkPos)
	local rivalDB = nil
	local rivalTankAttack = nil

	if rival.tankId_ == TANK_BOSS_CONFIG_ID or rival.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then
		local copyTankId = 30
		rivalDB = TankMO.queryTankById(copyTankId)
		rivalTankAttack = TankMO.queryTankAttackById(copyTankId)
	elseif EntityFactory.isAirsship(rival.tankId_) then
		local copyTankId = 30
		rivalDB = TankMO.queryTankById(copyTankId)
		rivalTankAttack = TankMO.queryTankAttackById(copyTankId)
		--变色
	else
		rivalDB = TankMO.queryTankById(rival.tankId_)
		rivalTankAttack = TankMO.queryTankAttackById(rival.tankId_)
	end
	gprint("onHurtTime: type:", rivalDB.type, "roundIndex:", roundIndex, "actionIndex:", actionIndex, "hurtIndex:", hurtIndex)

	if rivalDB.type == TANK_TYPE_TANK then -- 被坦克击中
		-- armature_add(IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".plist", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".xml")

		local round = BattleMO.getRoundAtIndex(roundIndex)
		local action = round.action[actionIndex]
		if action.hurt[hurtIndex] then  -- 有伤害
			showHurt(-action.hurt[hurtIndex], action.crit, self)

			self:showHp(action.hurt[hurtIndex])
		end

		local hurt = nil
		if rivalDB.special == 1 then
			armature_add(IMAGE_ANIMATION .. "tank/cineng_shot.pvr.ccz", IMAGE_ANIMATION .. "tank/cineng_shot.plist", IMAGE_ANIMATION .. "tank/cineng_shot.xml")
			hurt = armature_create("cineng_shot",  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()

						-- if self.tankId_ == TANK_BOSS_CONFIG_ID then
						-- 	self:onWeaponHurt(armature.roundIndex, armature.actionIndex, armature.hurtIndex)
						-- end
					end
				end)
		elseif rivalDB.special == 2 then
			armature_add(IMAGE_ANIMATION .. "tank/gltk_shouji.pvr.ccz", IMAGE_ANIMATION .. "tank/gltk_shouji.plist", IMAGE_ANIMATION .. "tank/gltk_shouji.xml")
			-- armature_add(IMAGE_ANIMATION .. "tank/cineng_shot.pvr.ccz", IMAGE_ANIMATION .. "tank/cineng_shot.plist", IMAGE_ANIMATION .. "tank/cineng_shot.xml")
			hurt = armature_create("gltk_shouji",  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
		else
			local armName = self:addArmature(rivalTankAttack, Fighter.hurtName, atkfighterEffect)
			hurt = armature_create(armName,  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()

						-- if self.tankId_ == TANK_BOSS_CONFIG_ID then
						-- 	self:onWeaponHurt(armature.roundIndex, armature.actionIndex, armature.hurtIndex)
						-- end
					end
				end)
		end
		
		if self.battleFor_ == BATTLE_FOR_ATTACK then
			hurt:setRotation(180)
		end
	    hurt:getAnimation():playWithIndex(0)
	    hurt.roundIndex = roundIndex
	    hurt.actionIndex = actionIndex
	    hurt.hurtIndex = hurtIndex

		-- if self.tankId_ == TANK_BOSS_CONFIG_ID then
		-- 	self:onWeaponHurt(roundIndex, actionIndex, hurtIndex)
		-- end

    	if self.tankId_ == TANK_BOSS_CONFIG_ID or self.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then  -- 世界BOSS
    		local weapon = self:getWeaponByIndex(self:getWeaponIndexByKey(action.target))
    		hurt:setPosition(weapon:getPositionX(), weapon:getPositionY())
    		hurt:addTo(self.bodyView_)
    	else
	    	hurt:addTo(self:getParent(), Fighter.LAYER_EFFECT)--self.view_)
    	end

    	if rivalTankAttack.hitSound and rivalTankAttack.hitSound ~= "" then
    		ManagerSound.playSound(rivalTankAttack.hitSound)
    	end
	elseif rivalDB.type == TANK_TYPE_CHARIOT then  -- 被战车击中
		local index = hurtIndex

		local round = BattleMO.getRoundAtIndex(roundIndex)
		local action = round.action[actionIndex]

		if index ~= 0 and action.hurt[index] and action.hurt[index] > 0 then  -- 有伤害
			local function totalHurt(hurts, hurtIdx)
				local h = 0
				for index = 1, #hurts do
					if index <= hurtIdx then
						h = h + hurts[index]
					end
				end
				return h
			end

			-- showHurt(-action.hurt[hurtIndex], action.crit, self)
			showHurt(-totalHurt(action.hurt, hurtIndex), action.crit, self)

			self:showHp(action.hurt[index])
		end

		if rivalDB.special == 1 then
			armature_add(IMAGE_ANIMATION .. "tank/cidian_shot.pvr.ccz", IMAGE_ANIMATION .. "tank/cidian_shot.plist", IMAGE_ANIMATION .. "tank/cidian_shot.xml")
			local hurt = armature_create("cidian_shot",  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()

						-- if self.tankId_ == TANK_BOSS_CONFIG_ID then
						-- 	self:onWeaponHurt(armature.roundIndex, armature.actionIndex, armature.hurtIndex)
						-- end
					end
				end)
			hurt:getAnimation():playWithIndex(0)
			hurt:addTo(self:getParent(), Fighter.LAYER_EFFECT)
			if self.battleFor_ == BATTLE_FOR_DEFEND then
				hurt:setScaleY(-1)
			end
		elseif rivalDB.special == 2 then
			armature_add(IMAGE_ANIMATION .. "tank/sdzy_shouji.pvr.ccz", IMAGE_ANIMATION .. "tank/sdzy_shouji.plist", IMAGE_ANIMATION .. "tank/sdzy_shouji.xml")
			local hurt = armature_create("sdzy_shouji",  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
			hurt:getAnimation():playWithIndex(0)
			hurt:addTo(self:getParent(), Fighter.LAYER_EFFECT)
			if self.battleFor_ == BATTLE_FOR_DEFEND then
				hurt:setScaleY(-1)
			end
		else
			if hurtIndex == 1 or hurtIndex == 3 then
				-- armature_add(IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".plist", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".xml")
				local armName = self:addArmature(rivalTankAttack, Fighter.hurtName, atkfighterEffect)
				-- 在地上的动画
				local hurt = armature_create(armName, hurtPos.x, hurtPos.y,
					function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
							armature:removeSelf()
						end
					end)
			    hurt:getAnimation():playWithIndex(0)
				hurt:addTo(self:getParent(), Fighter.LAYER_EFFECT)
				if self.battleFor_ == BATTLE_FOR_DEFEND then
					hurt:setScaleY(-1)
				end
			else
				-- armature_add(IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName2 .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName2 .. ".plist", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName2 .. ".xml")
				local armName = self:addArmature(rivalTankAttack, Fighter.hurtName2, atkfighterEffect)
				-- 自身被打中的动画
				local hurt = armature_create(armName, hurtPos.x, hurtPos.y,
					function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
							armature:removeSelf()
						end
					end)
			    hurt:getAnimation():playWithIndex(0)
				hurt:addTo(self:getParent(), Fighter.LAYER_EFFECT)
				if self.battleFor_ == BATTLE_FOR_DEFEND then
					hurt:setScaleY(-1)
				end
			end
		end

		-- if hurtIndex == #action.hurt then
		-- 	if self.tankId_ == TANK_BOSS_CONFIG_ID then
		-- 		self:onWeaponHurt(roundIndex, actionIndex, hurtIndex)
		-- 	end
		-- end

		local config = TankConfig.getConfigBy(self.tankId_)
		if EntityFactory.isBountyBoss(self.tankId_) or self.tankId_ == 404 then
		else
			if config then
				-- self.bodyView_:stopAllActions()
				self.bodyView_:runAction(transition.sequence({cc.MoveBy:create(0.05, cc.p(0, 2)), cc.MoveTo:create(0.05, cc.p(config.offset[1], config.offset[2]))}))
	    	end
	    end
    	if rivalTankAttack.hitSound and rivalTankAttack.hitSound ~= "" then
    		ManagerSound.playSound(rivalTankAttack.hitSound)
    	end
	elseif rivalDB.type == TANK_TYPE_ARTILLERY then  -- 被火炮击中
		local round = BattleMO.getRoundAtIndex(roundIndex)
		local action = round.action[actionIndex]
		if action.hurt[hurtIndex] then  -- 有伤害
			showHurt(-action.hurt[hurtIndex], action.crit, self)

			self:showHp(action.hurt[hurtIndex])
		end

		local hurt = nil
		if rivalDB.special == 1 then
			armature_add(IMAGE_ANIMATION .. "tank/bushizhe_shot.pvr.ccz", IMAGE_ANIMATION .. "tank/bushizhe_shot.plist", IMAGE_ANIMATION .. "tank/bushizhe_shot.xml")
			hurt = armature_create("bushizhe_shot",  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()

						-- if self.tankId_ == TANK_BOSS_CONFIG_ID then
						-- 	self:onWeaponHurt(armature.roundIndex, armature.actionIndex, armature.hurtIndex)
						-- end
					end
				end)
		elseif rivalDB.special == 2 then
			armature_add(IMAGE_ANIMATION .. "tank/swsx_shouji.pvr.ccz", IMAGE_ANIMATION .. "tank/swsx_shouji.plist", IMAGE_ANIMATION .. "tank/swsx_shouji.xml")
			hurt = armature_create("swsx_shouji",  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
		else
			-- armature_add(IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".plist", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".xml")
			local armName = self:addArmature(rivalTankAttack, Fighter.hurtName, atkfighterEffect)

			hurt = armature_create(armName, hurtPos.x, hurtPos.y,--0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
		end

		local rotation = TankConfig.getRotation(self.pos_, rival.pos_)
		if self.battleFor_ == BATTLE_FOR_DEFEND then
			hurt:setRotation(-rotation)
		else
			hurt:setRotation(rotation - 180)
		end
	    hurt:getAnimation():playWithIndex(0)
    	
    	if self.tankId_ == TANK_BOSS_CONFIG_ID or self.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then  -- 世界BOSS
    		local weapon = self:getWeaponByIndex(self:getWeaponIndexByKey(action.target))
    		hurt:setPosition(weapon:getPositionX(), weapon:getPositionY())
    		hurt:addTo(self.bodyView_)
    	else
	    	hurt:addTo(self:getParent(), Fighter.LAYER_EFFECT)--self.view_)  -- 放在tank上 改放入地面
    	end

		-- if self.tankId_ == TANK_BOSS_CONFIG_ID then
		-- 	self:onWeaponHurt(roundIndex, actionIndex, hurtIndex)
		-- end

		if rivalTankAttack.hitSound and rivalTankAttack.hitSound ~= "" then
    		ManagerSound.playSound(rivalTankAttack.hitSound)
    	end
	elseif rivalDB.type == TANK_TYPE_ROCKET then -- 被火箭击中
		local round = BattleMO.getRoundAtIndex(roundIndex)
		local action = round.action[actionIndex]
		if action.hurt[hurtIndex] then  -- 有伤害
			showHurt(-action.hurt[hurtIndex], action.crit, self)

			self:showHp(action.hurt[hurtIndex])
		end
		local hurt = nil
		if rivalDB.special == 1 then
			armature_add(IMAGE_ANIMATION .. "tank/zhunao_attack.pvr.ccz", IMAGE_ANIMATION .. "tank/zhunao_attack.plist", IMAGE_ANIMATION .. "tank/zhunao_attack.xml")
			hurt = armature_create("zhunao_attack",  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()

						-- if self.tankId_ == TANK_BOSS_CONFIG_ID then
						-- 	self:onWeaponHurt(armature.roundIndex, armature.actionIndex, armature.hurtIndex)
						-- end
					end
				end)
		elseif rivalDB.special == 2 then
			armature_add(IMAGE_ANIMATION .. "tank/wmhj_shouji2.pvr.ccz", IMAGE_ANIMATION .. "tank/wmhj_shouji2.plist", IMAGE_ANIMATION .. "tank/wmhj_shouji2.xml")
			hurt = armature_create("wmhj_shouji2",  hurtPos.x, hurtPos.y, --0, 0,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
		else
			-- armature_add(IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".plist", IMAGE_ANIMATION .. "battle/" .. rivalTankAttack.hurtName .. ".xml")
			local armName = self:addArmature(rivalTankAttack, Fighter.hurtName, atkfighterEffect)
			hurt = armature_create(armName, hurtPos.x, hurtPos.y,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
		end

	    hurt:getAnimation():playWithIndex(0)
		hurt:addTo(self:getParent(), Fighter.LAYER_EFFECT)
		if self.battleFor_ == BATTLE_FOR_DEFEND then
			hurt:setScaleY(-1)
		end

		-- if self.tankId_ == TANK_BOSS_CONFIG_ID then
		-- 	self:onWeaponHurt(roundIndex, actionIndex, hurtIndex)
		-- end
		
    	if rivalTankAttack.hitSound and rivalTankAttack.hitSound ~= "" then
    		ManagerSound.playSound(rivalTankAttack.hitSound)
    	end
	end
end

function Fighter:onHurtEnd(atkPos, roundIndex, actionIndex, hurtIndex, hurtPos)
	gprint("[Fighter] hurt end atk:" .. atkPos, "pos:" .. self.pos_, "round:" .. roundIndex, "action:" .. actionIndex, "hurt:" .. hurtIndex)
	local round = BattleMO.getRoundAtIndex(roundIndex)
	local action = round.action[actionIndex]
	if action.dodge then
	else -- 没有发生闪避
		if action.count <= 0 then -- 数量没有了
			gprint("[Fighter] hurt end die round:" .. roundIndex, "action:" .. actionIndex)
			self:onDie(roundIndex, actionIndex)
		else
			-- 更新显示自己的剩余数量
			local round = BattleMO.getRoundAtIndex(roundIndex)
			local action = round.action[actionIndex]
			self:showCount(action.count)
		end
	end
end

-- 自己被穿刺了，删除所有的炮管
function Fighter:onImpale()
	for index = 1, #self.weaponViews_ do
		self.weaponViews_[index]:removeSelf()
		self.weaponViews_[index] = nil
	end
	self.weaponViews_ = {}
end

----是否 是复活的tank
function Fighter:isReborn()
	return self.isReborn_
end

function Fighter:onRemoveSelf(delay, callback)
	if delay == nil then
		delay = true
	end
	-- Fighter.dieName 
	-- armature_add(IMAGE_ANIMATION .. "battle/bt_die.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_die.plist", IMAGE_ANIMATION .. "battle/bt_die.xml")
	local rivalTankAttack = TankMO.queryTankAttackById(self.tankId_)
	local armName = self:addArmature(rivalTankAttack, Fighter.dieName)
	-- armature_add(IMAGE_ANIMATION .. "battle/bt_crater.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_crater.plist", IMAGE_ANIMATION .. "battle/bt_crater.xml")
	FightEffect.checkDie(self)
	self:hideFrighten()	-- 消除震慑特效
	local pos = cc.p(self:getPositionX(), self:getPositionY())
	local die = armature_create(armName, pos.x, pos.y,
		function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end)
    die:getAnimation():playWithIndex(0)
	die:addTo(self:getParent(), Fighter.LAYER_EFFECT)

	-- -- 弹坑
	-- local crater = armature_create("bt_crater", pos.x, pos.y,
	-- 	function (movementType, movementID, armature)
	-- 		if movementType == MovementEventType.COMPLETE then
	-- 			-- armature:removeSelf()
	-- 		end
	-- 	end)
 --    crater:getAnimation():playWithIndex(0)
	-- crater:addTo(self:getParent(), -1)

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

function Fighter:onDie(roundIndex, actionIndex)
	----死亡移除
	self:onRemoveSelf(nil, function ()
		--检查是否有复活
		local allOver = true
		for index = 1, FIGHT_FORMATION_POS_NUM do
			if BattleMO.hasTankAtPos(self.battleFor_, index) then
				allOver = false
				break
			end
		end
		local list = {}
		if allOver then
			local info = BattleMO.fightData_.reborn[roundIndex]
			--gdump(info, "@^^^^^^reborn^^^^^", 9)
			if info then
				armature_add(IMAGE_ANIMATION .. "effect/jineng_fadong.pvr.ccz", IMAGE_ANIMATION .. "effect/jineng_fadong.plist", IMAGE_ANIMATION .. "effect/jineng_fadong.xml")
				-- local armture = armature_create("jineng_fadong", 540, bg:getContentSize().height - 20):addTo(bg, -1)
				local reborns = {}
				for k,pos in ipairs(info.pos) do
					local formats,kind = BattleMO.atkFormat_,BATTLE_FOR_ATTACK
					if BattleMO.fightData_.offsensive == BATTLE_OFFENSIVE_DEFEND then
						formats,kind = BattleMO.defFormat_,BATTLE_FOR_DEFEND
					end
					if pos >= 7 then
						pos = pos - 6
						if BattleMO.fightData_.offsensive == BATTLE_OFFENSIVE_ATTACK then
							formats,kind = BattleMO.defFormat_,BATTLE_FOR_DEFEND
						else
							formats,kind = BattleMO.atkFormat_,BATTLE_FOR_ATTACK
						end
					end
					
					local format = {}
					local hp = 0

					if info.tankId[k] then
						format.tankId = info.tankId[k]
						format.count = info.count[k]
						hp = info.hp[k]
						-- hp = BattleMO.getHp(kind, pos)
					else
						format = formats[pos]
						hp = BattleMO.getHp(kind, pos)
					end

					local tank = BattleMO.setTankAtPos(kind, pos, EntityFactory.createTank(kind, pos, format.tankId, format.count, hp))
					tank:setTimeScale(1/BattleMO.getSpeed())
					if info.awake[k] and info.awake[k] == 1 then --特殊处理。如果是
						armature_add(IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.pvr.ccz", IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.plist", IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.xml")
						local wu2 = armature_create("aogusite_jineng_chixu", tank:width()/2,tank:height()/2,
								function (movementType, movementID, armature)
									if movementType == MovementEventType.COMPLETE then
									end
								end)
						wu2:addTo(tank,-1)
						wu2:getAnimation():playWithIndex(0)
					end
					tank:onFightEnter(nil,1)
					if self.timeScale_ == 1 then
						tank:setVisible(false)
					end
					reborns[#reborns+1] = {kind=kind,pos=pos}
				end

				self:showRebornItem(function(reborns)
					for i,v in ipairs(reborns) do
						local tank = BattleMO.getTankAtPos(v.kind, v.pos)
						if tank then
							tank:setVisible(true)
						end
					end
				end,reborns)
			end
		end
	end)

end

function Fighter:showRebornItem(rhand, data)
	local p = UiDirector.getTopUi()
	armature_add(IMAGE_ANIMATION .. "effect/jineng_fadong.pvr.ccz", IMAGE_ANIMATION .. "effect/jineng_fadong.plist", IMAGE_ANIMATION .. "effect/jineng_fadong.xml")
	if self.battleFor_ == BATTLE_FOR_DEFEND then
		local id = BattleMO.defFormat_.commander
		local item = display.newSprite(IMAGE_COMMON.."info_64.png")
		local hero = HeroMO.queryHero(id)
		local itemView = UiUtil.createItemView(ITEM_KIND_HERO, id):addTo(item):pos(90,item:height()/2-10):scale(0.5)
		local t = UiUtil.label(hero.heroName,26,COLOR[hero.star]):addTo(item):align(display.LEFT_CENTER, 150, 86)
		t = UiUtil.label(CommonText[513][2],24,COLOR[12]):alignTo(t, -45, 1)
		UiUtil.label(hero.skillName,24):rightTo(t)
		item:addTo(p,99999):align(display.LEFT_BOTTOM, 0, display.height)
		item:runAction(transition.sequence({cc.MoveBy:create(0.3, cc.p(0,-280)), cc.CallFuncN:create(function(sender)
		            local armture = armature_create("jineng_fadong", display.cx, display.height - 280 + item:height()/2):addTo(p, 99998)
		            armture:getAnimation():playWithIndex(0)
		            armture:runAction(transition.sequence({cc.DelayTime:create(1.5),cc.CallFuncN:create(function()
		                    armture:removeSelf()
		                    item:runAction(transition.sequence({cc.MoveBy:create(0.2, cc.p(0,280)),cc.CallFuncN:create(function()
		                                item:removeSelf()
		                                rhand(data)
		                            end)}))
		                        end)}))
		        end)}))
	else
		local id = BattleMO.atkFormat_.commander
		local item = display.newSprite(IMAGE_COMMON.."info_63.png")
		local hero = HeroMO.queryHero(id)
		local itemView = UiUtil.createItemView(ITEM_KIND_HERO, id):addTo(item):pos(item:width()-90,item:height()/2-10):scale(0.5)
		local t = UiUtil.label(hero.heroName,26,COLOR[hero.star]):addTo(item):align(display.RIGHT_CENTER, item:width() - 150, 86)
		t = UiUtil.label(hero.skillName,24):alignTo(t, -45, 1)
		UiUtil.label(CommonText[513][2],24,COLOR[12]):leftTo(t)
		item:addTo(p,99999):align(display.RIGHT_TOP, display.width, 0)
		item:runAction(transition.sequence({cc.MoveBy:create(0.3, cc.p(0,280)), cc.CallFuncN:create(function(sender)
		           local armture = armature_create("jineng_fadong", display.cx, 280 - item:height()/2):addTo(p, 99998)
		           armture:getAnimation():playWithIndex(0)
		           armture:runAction(transition.sequence({cc.DelayTime:create(1.5),cc.CallFuncN:create(function()
		                   armture:removeSelf()
		                   item:runAction(transition.sequence({cc.MoveBy:create(0.2, cc.p(0,-280)),cc.CallFuncN:create(function()
		                               item:removeSelf()
		                               rhand(data)
		                           end)}))
		                       end)}))
		        end)}))
	end
end

function Fighter:onOver()
	if self.actionSchedulerHandler_ then
		scheduler.unscheduleGlobal(self.actionSchedulerHandler_)
		self.actionSchedulerHandler_ = nil
	end
end

-- 获得对方的位置上的tank
function Fighter:getRival(pos)
	gprint("Fighter:getRival", self.battleFor_, pos)
	if self.battleFor_ == BATTLE_FOR_ATTACK then
		if BattleMO.defSeveralForOne_ then -- 世界BOSS
			return BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, TANK_BOSS_POSITION_INDEX)
		else
			return BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, pos)
		end
	else
		return BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, pos)
	end
end

-- 当前状态下炮管指向对方toPos位置需要旋转的角度
function Fighter:getWeaponRotation(toPos)
	local angle = 0
	local weapon = self.weaponViews_[1]
	if weapon then
		angle = weapon:getRotation()
	end

	-- gprint("config:", TankConfig.getRotation(self.pos_, toPos),  "angle:", angle)
	return TankConfig.getRotation(self.pos_, toPos) - angle
end

-- 更新显示hp条
function Fighter:showHp(hurt)
	if self.hpBar_ then
		self.hpBar_:removeSelf()
		self.hpBar_ = nil
	end

	if self.tankId_ == TANK_BOSS_CONFIG_ID or self.tankId_ == TANK_ALTAR_BOSS_CONFIG_ID then return end
	self.curHp_ = self.curHp_ - hurt
	if self.curHp_ < 0 then
		self.curHp_ = 0
	end
	local percent = self.curHp_ / self.totalHp_

	local bar = nil
	if percent > 0.66 then
		bar = ProgressBar.new(IMAGE_COMMON .. "bar_6.png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "bar_bg_5.png"}):addTo(self,99)
	elseif percent > 0.33 then
		bar = ProgressBar.new(IMAGE_COMMON .. "bar_7.png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "bar_bg_5.png"}):addTo(self,99)
	else
		bar = ProgressBar.new(IMAGE_COMMON .. "bar_8.png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "bar_bg_5.png"}):addTo(self,99)
	end
	bar:setPercent(percent)

	if device.platform == "windows" then
		UiUtil.label(self.curHp_ .. "/" .. self.totalHp_):addTo(bar, 99):alignTo(bar,0,0)
	end

	if EntityFactory.isAirsship(self.tankId_) then
	else
		if self.battleFor_ == BATTLE_FOR_DEFEND then bar:setPosition(0, 70)
		else bar:setPosition(0, -70) end
	end
	
	local top = display.newSprite(IMAGE_COMMON .. "bar_bg_4.png"):addTo(bar, 10)
	top:setPosition(bar:getContentSize().width / 2, bar:getContentSize().height / 2)

	self.hpBar_ = bar
end

function Fighter:syncHp( curHp, count )
	self.curHp_ = curHp
	self:showHp(0)
	self:showCount(count)

	gprint("@^^^^^^^^恢复穿刺^^^^^^^^^^^")
	---恢复穿刺
	local config = TankConfig.getConfigBy(self.tankId_)

	if EntityFactory.isAirsship(self.tankId_) then
	elseif EntityFactory.isBountyBoss(self.tankId_) then
	elseif self.tankId_ == 404 then
	elseif not config then
	else
		local gun = config.gun
		local body = self.bodyView_
		for k,v in pairs(self.weaponViews_) do
			v:removeSelf()
		end
		self.weaponViews_ = {}
		for index = 1, #gun do -- 创建炮管
			local v = display.newSprite("image/fight/" .. gun[index].b .. ".png"):addTo(body)
			v:setAnchorPoint(gun[index].a[1], gun[index].a[2])
			v:setPosition(body:getContentSize().width / 2 + gun[index].o[1], body:getContentSize().height / 2 + gun[index].o[2])
			self.weaponViews_[index] = v

			local shade = display.newSprite("image/fight/" .. gun[index].b .. "_sd" .. ".png"):addTo(v, -1)
			shade:setPosition(v:getContentSize().width / 2 + 5, v:getContentSize().height / 2 - 3)
		end
	end	
end

-- 更新显示剩余数量count
function Fighter:showCount(count)
	if self.countLabel_ then self.countLabel_:setString(count) end
end

function Fighter:getWeaponByIndex(index)
	return self.weaponViews_[index]
end

-- 清楚所有动画
function Fighter:cleanAndstopAllActions()
	self:hideFrighten()
	self:stopAllActions()
end

-- 震慑点击buff
function Fighter:showFrighten()
	if not self.frightenAniView then
		armature_add(IMAGE_ANIMATION .. "battle/dianjibuff.pvr.ccz", IMAGE_ANIMATION .. "battle/dianjibuff.plist", IMAGE_ANIMATION .. "battle/dianjibuff.xml")
		local frighten = armature_create("dianjibuff", self:width() / 2, self:height() / 2, nil):addTo(self, 10)
		frighten:getAnimation():playWithIndex(0)
		self.frightenAniView = frighten
	end
end

-- 取消震慑电机buff
function Fighter:hideFrighten()
	if self.frightenAniView then
		self.frightenAniView:removeSelf()
		self.frightenAniView = nil
	end
end

-- 选择性 加载动画资源
function Fighter:addArmature(obj, name, fighterEffect)
	local armName = name
	local effectid = fighterEffect or self.fighterEffect
	if effectid > 1 then
		armName = string.format("%s_%d",armName,(effectid - 1))
	end
	local outName = obj[armName]
	armature_add(IMAGE_ANIMATION .. "battle/" .. outName .. ".pvr.ccz", IMAGE_ANIMATION .. "battle/" .. outName .. ".plist", IMAGE_ANIMATION .. "battle/" .. outName .. ".xml")
	return outName
end

function Fighter:GetDistance(from, to)
	local distance2 = cc.p(to.x - from.x, to.y - from.y)
	return math.sqrt(math.pow(distance2.x, 2) + math.pow(distance2.y, 2))
end

function Fighter:onFightBackstage(callback,isReborn)
	local moveDis = BATTLE_TANK_SPEED * BATTLE_TANK_ENTER_TIME
	if self.battleFor_ == BATTLE_FOR_ATTACK then
		local config = FightAtkFormatConifg[self.pos_]
		self:setPosition(config.offset.x, config.offset.y - moveDis)
	else
		local config = FightDefFormatConifg[self.pos_]
		self:setPosition(config.offset.x, config.offset.y + moveDis)
	end
end

return Fighter
