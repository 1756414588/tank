
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

-- 战斗BO

BattleBO = {}

FightAtkFormatConifg = { -- 进攻方的基础配置
{offset = cc.p(-210, -220)},
{offset = cc.p(0, -220)},
{offset = cc.p(210, -220)},
{offset = cc.p(-210, -410)},
{offset = cc.p(0, -410)},
{offset = cc.p(210, -410)},
}

FightDefFormatConifg = { -- 防守方的基础配置
{offset = cc.p(-210, 220)},
{offset = cc.p(0, 220)},
{offset = cc.p(210, 220)},
{offset = cc.p(-210, 410)},
{offset = cc.p(0, 410)},
{offset = cc.p(210, 410)},
}

local enterSchedulerHandler_ = nil  -- 入场定时器
local roundSchedulerHandler_ = nil  -- 回合定时器


BattleMO.airshipId_ = nil --- 飞艇id
BattleMO.bountyBossId_ = nil
-- -- atkFormat: 进攻的阵型(下方的阵型)
-- -- defFormat: 防守的阵型(上方的阵型)
function BattleBO.createFormatEntity()
	require("app.fight.EntityFactory")

	gdump(BattleMO.atkFormat_, "[BattleBO] create format attacker")
	gdump(BattleMO.defFormat_, "[BattleBO] create format defender")

	-- 进攻方
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local format = BattleMO.atkFormat_[index]
		if format and format.tankId and format.tankId > 0 and format.count and format.count > 0 then
			-- local mapData = BattleMO.fightData_.keyMap[format.key]
			-- local hp = BattleMO.fightData_.hp[mapData.hpIndex]
			local hp = BattleMO.getHp(BATTLE_FOR_ATTACK, index)
			if hp > 0 then
				BattleMO.setTankAtPos(BATTLE_FOR_ATTACK, index, EntityFactory.createTank(BATTLE_FOR_ATTACK, index, format.tankId, format.count, hp))
			end
		end
	end

	-- 防守方
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local format = BattleMO.defFormat_[index]
		if format and format.tankId and format.tankId > 0 and format.count and format.count > 0 then
			-- local mapData = BattleMO.fightData_.keyMap[format.key]
			-- local hp = BattleMO.fightData_.hp[mapData.hpIndex]
			local hp = 0
			-- if format.tankId == TANK_BOSS_CONFIG_ID then  -- 世界BOSS
			-- 	hp = BattleMO.getHp(BATTLE_FOR_DEFEND, index)
			-- else
				hp = BattleMO.getHp(BATTLE_FOR_DEFEND, index)
			-- end
			if hp > 0 then
				BattleMO.setTankAtPos(BATTLE_FOR_DEFEND, index, EntityFactory.createTank(BATTLE_FOR_DEFEND, index, format.tankId, format.count, hp))
			end
		end
	end
end

-- enterDoneCallback: 所有tank入场结束后的回调
function BattleBO.tankEnter(camp)
	BattleMO.updateSpeed() ---更新速度

	if not camp or camp == BATTLE_FOR_ATTACK then
		for index = 1, FIGHT_FORMATION_POS_NUM do  -- 进攻方从下向上入场
			if BattleMO.hasTankAtPos(BATTLE_FOR_ATTACK, index) then
				local tank = BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, index)
				tank:onFightEnter()
			end
		end
	end

	local enterTime = BATTLE_ENTER_TIME

	local haveBoss = false
	-- 如果是赏金Boss战 判断防守方有没有赏金Boss
	if camp == nil or camp == BATTLE_FOR_DEFEND then
		for index = 1, FIGHT_FORMATION_POS_NUM do  --防守方从上向下入场
			if BattleMO.hasTankAtPos(BATTLE_FOR_DEFEND, index) then
				local tank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, index)
				print("tank.tankId_!!!", tank.tankId_)
				if EntityFactory.isBountyBoss(tank.tankId_) then
					haveBoss = true
					break
				end
			end
		end
	end

	local function defEnter()
		-- body
		if not camp or camp == BATTLE_FOR_DEFEND then
			for index = 1, FIGHT_FORMATION_POS_NUM do  --防守方从上向下入场
				if BattleMO.hasTankAtPos(BATTLE_FOR_DEFEND, index) then
					local tank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, index)
					tank:onFightEnter()
				end
			end
		end
	end

	if haveBoss == false then
		defEnter()
		-- 如果第一个回合就是火箭，则增加入场时间
		local firstRound = BattleMO.getRoundAtIndex(1)
		if not firstRound then --将领复活无数据
			Notify.notify(LOCAL_BATTLE_OVER_EVENT)
			return
		end

		local battleFor, pos = CombatMO.getBattlePosition(BattleMO.offensive_, firstRound.key)
		if battleFor == BATTLE_FOR_DEFEND and BattleMO.defSeveralForOne_ then -- 是世界BOSS
			enterTime = BATTLE_TANK_ENTER_TIME + 0.05
		else
			local fighter = BattleMO.getTankByKey(firstRound.key)
			local tankDB = TankMO.queryTankById(fighter.tankId_)
			if tankDB.type == TANK_TYPE_ROCKET then
				enterTime = BATTLE_TANK_ENTER_TIME + 0.01
			end
		end

		if enterSchedulerHandler_ then
			scheduler.unscheduleGlobal(enterSchedulerHandler_)
			enterSchedulerHandler_ = nil
		end
		enterSchedulerHandler_ = scheduler.performWithDelayGlobal(function()
				enterSchedulerHandler_ = nil
				gprint("[BattleBO] enter end. start to fight...")
				BattleBO:startFight()
			end, enterTime/BattleMO.getSpeed())
	else
		if not camp or camp == BATTLE_FOR_DEFEND then
			for index = 1, FIGHT_FORMATION_POS_NUM do  --防守方从上向下入场
				if BattleMO.hasTankAtPos(BATTLE_FOR_DEFEND, index) then
					local tank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, index)
					tank:onFightBackstage()
				end
			end
		end

		local function wrapCallback()
			defEnter()
			local firstRound = BattleMO.getRoundAtIndex(1)
			if not firstRound then --将领复活无数据
				Notify.notify(LOCAL_BATTLE_OVER_EVENT)
				return
			end

			enterTime = enterTime + 2

			if enterSchedulerHandler_ then
				scheduler.unscheduleGlobal(enterSchedulerHandler_)
				enterSchedulerHandler_ = nil
			end
			enterSchedulerHandler_ = scheduler.performWithDelayGlobal(function()
					enterSchedulerHandler_ = nil
					gprint("[BattleBO] enter end. start to fight...")
					BattleBO:startFight()
				end, enterTime/BattleMO.getSpeed())
		end

		local view = UiDirector.getUiByName("BattleView")
		if view then
			view:playWarning(wrapCallback)
		end
	end
end

function BattleBO:startFight()
	BattleMO.fightRoundIndex_ = 1

	self:startRound()
end

-- 开始当前回合
function BattleBO:startRound()
	local isOver = BattleMO.isOver()
	if isOver == true then
		gprint("[BattleBO] battle is OVER!!!")

		-- 胜利的一方向前进
		BattleBO.tankExit()
		
		Notify.notify(LOCAL_BATTLE_OVER_EVENT)
	elseif isOver == 1 then
		gprint("下一轮飞艇战斗开始========")
	elseif isOver == 2 then
		gprint("等待游戏结束判定======")
	else
		local round = BattleMO.getCurrentRound()
		gprint("[BattleBO] cur round is start!! round idx:", BattleMO.fightRoundIndex_, "key:", round.key)
		-- gdump(round, "[BattleBO] startRound 需要进行的round")

		local fighter = nil

		-- 当前round的发起者
		local battleFor, pos = CombatMO.getBattlePosition(BattleMO.offensive_, round.key)
		gprint("@^^^^^^^^^battleFor^^^^^^^^", battleFor, "pos", pos)
		gprint("startRound BattleMO.offensive_", BattleMO.offensive_, round.key)
		if battleFor == BATTLE_FOR_DEFEND and BattleMO.defSeveralForOne_ then -- 是世界BOSS
			fighter = BattleMO.getTankAtPos(battleFor, TANK_BOSS_POSITION_INDEX)
		else
			fighter = BattleMO.getTankByKey(round.key)
		end


		fighter:onStartRound(BattleMO.fightRoundIndex_, function()
				local time = self:getNxtRoundTime()

				gprint("[BattleBO] cur round is over!!! round idx: " .. BattleMO.fightRoundIndex_, "goto nxt round wait time:" .. time)

				local function gotoNxtRound()
					roundSchedulerHandler_ = nil
					BattleMO.fightRoundIndex_ = BattleMO.fightRoundIndex_ + 1
					self:startRound()
				end

				if time <= 0 then
					gotoNxtRound()
				else
					-- 走到下一个回合
					roundSchedulerHandler_ = scheduler.performWithDelayGlobal(function() gotoNxtRound() end, time/BattleMO.getSpeed())
				end
			end)
	end
end

-- 所有的坦克从原地一直向前走到屏幕外，用于战斗结束
function BattleBO.tankExit()
	gprint("[BattleBO] all tank start to exit...")

	-- 按照tank的速度走到屏幕的长度需要的时间
	local time = display.height / BATTLE_TANK_SPEED / BattleMO.getSpeed()

	if CombatMO.curBattleStar_ > 0 then
		for index = 1, FIGHT_FORMATION_POS_NUM do  -- 进攻方从下向上走
			-- gprint("index:", index)
			-- gdump(BattleMO.fightEntity_[BATTLE_FOR_ATTACK])
			if BattleMO.hasTankAtPos(BATTLE_FOR_ATTACK, index) then
				local tank = BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, index)
				tank:cleanAndstopAllActions()
				tank:runAction(cc.MoveBy:create(time, cc.p(0, display.height)))
			end
		end
	else
		for index = 1, FIGHT_FORMATION_POS_NUM do  --防守方从上向下入场
			if BattleMO.hasTankAtPos(BATTLE_FOR_DEFEND, index) then
				local tank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, index)
				tank:cleanAndstopAllActions()
				tank:runAction(cc.MoveBy:create(time, cc.p(0, -display.height)))
			end
		end
	end
end

-- 当前回合结束时，到下一轮回合开始时的时间间隔
function BattleBO.getNxtRoundTime()
	local round = BattleMO.getCurrentRound()

	local rebornTime = BattleMO.fightData_.reborn[BattleMO.fightRoundIndex_] and 5 or 0
	local nxtRound = BattleMO.getRoundAtIndex(BattleMO.fightRoundIndex_ + 1)

	local battleFor, pos = CombatMO.getBattlePosition(BattleMO.offensive_, round.key)
	if battleFor == BATTLE_FOR_DEFEND and BattleMO.defSeveralForOne_ then -- 是世界BOSS
		-- if nxtRound then return 0   -- 有下一轮
		-- else return 0.5 end
		return 0.8 + rebornTime 
	end

	local tank = BattleMO.getTankByKey(round.key)
	local tankDB = TankMO.queryTankById(tank.tankId_)
	if tank.tankId_ >= 401 and tank.tankId_ <= 404 then
		return 0.8 + rebornTime
	end

	local attackDB = TankMO.queryAttackByType(tankDB.type)
	if nxtRound then -- 有下一轮
		local battleFor, pos = CombatMO.getBattlePosition(BattleMO.offensive_, nxtRound.key)
		if battleFor == BATTLE_FOR_DEFEND and BattleMO.defSeveralForOne_ then -- 下一轮是世界BOSS
			return 0 + rebornTime
		end

		local nxtTank = BattleMO.getTankByKey(nxtRound.key)
		if not nxtTank then
			gprint("BattleBO.getNxtRoundTime Error!!!!")
			return 0 + rebornTime
		end
		local nxtTankDB = TankMO.queryTankById(nxtTank.tankId_)

		if nxtTank.tankId_ >= 401 and nxtTank.tankId_ <= 404 then
			return 0.8 + rebornTime
		end

		if tank.battleFor_ == nxtTank.battleFor_ then -- 是友方
			gprint("[BattleBO] cur round go to nxt round is FRIEND")
			local idx = {"tankTime", "zhancTime", "huopTime", "huojTime"}
			gdump(attackDB, "attackDB==")
			gdump(attackDB.type, "attackDB.type==")
			return attackDB[idx[nxtTankDB.type]] + rebornTime
		else -- 是对方
			gprint("[BattleBO] cur round go to nxt round is RIVAL")
			local idx = {"rivalTankTime", "rivalZhancTime", "rivalHuopTime", "rivalHuojTime"}
			return attackDB[idx[nxtTankDB.type]] + rebornTime
		end
		return 0 + rebornTime
	else  -- 没有下一轮，也就是战斗结束时，多少时间进入战斗结束
		gprint("[BattleBO] cur round has NO nxt ROUND")
		if EntityFactory.isAirsship(tank.tankId_) then
			return 1
		elseif EntityFactory.isBountyBoss(tank.tankId_) then
			return 1
		elseif tank.tankId_ == 404 then
			return 1
		else
			local idx = {"tankTime", "zhancTime", "huopTime", "huojTime"}
			return attackDB[idx[tankDB.type]]
		end
	end
end

function BattleBO.fightOver()
	gprint("[BattleBO] fightOver ...")
	-- 进攻方
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local fighter = BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, index)
		if fighter then
			fighter:onOver()
		end
	end

	-- 防守方
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local fighter = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, index)
		if fighter then
			fighter:onOver()
		end
	end

	BattleMO.airshipId_ = nil
	BattleMO.bountyBossId_ = nil

	BattleMO.offensive_ = nil
	BattleMO.atkFormat_ = nil
	BattleMO.defFormat_ = nil
	BattleMO.fightRoundIndex_ = 1
	BattleMO.fightData_ = nil
	BattleMO.fightEntity_ = {}
	
	if enterSchedulerHandler_ then
		scheduler.unscheduleGlobal(enterSchedulerHandler_)
		enterSchedulerHandler_ = nil
	end

	if roundSchedulerHandler_ then
		scheduler.unscheduleGlobal(roundSchedulerHandler_)
		roundSchedulerHandler_ = nil
	end
end
