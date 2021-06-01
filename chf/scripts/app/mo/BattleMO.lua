
BattleMO = {}

local battleSpeed_ = 1 -- 战斗中的所有运动的速度倍数

BATTLE_TANK_ENTER_TIME = 2  -- tank入场需要消耗的时间，单位秒
BATTLE_TANK_SPEED = 80  -- 战斗tank移动的速度

BATTLE_ENTER_TIME = 1.6 -- 游戏入场的时间，(可以比tank的时间要短，这样就是tank在行进中就可以开始开炮了)

BATTLE_FOR_ATTACK = 1  -- 进攻方
BATTLE_FOR_DEFEND = 2

BATTLE_OFFENSIVE_ATTACK = 1 -- 攻击方先手
BATTLE_OFFENSIVE_DEFEND = 2 -- 防守方先手

BattleMO.offensive_ = nil  -- 战斗的先手

BattleMO.atkFormat_ = nil  -- 进攻方阵型数据，包含tank的id和数量
BattleMO.defFormat_ = nil

BattleMO.fightRoundIndex_ = 1 -- 战斗的回合索引

BattleMO.fightData_ = nil -- 战斗的数据
BattleMO.reborn_ = {} -- 复活的数据

BattleMO.fightEntity_ = {} -- 保存战斗双方的战斗的tank的实体

BattleMO.defSeveralForOne_ = false
-- BattleMO.defBossData_ = {}

function BattleMO.reset()
	BattleMO.offensive_ = nil

	BattleMO.atkFormat_ = {}
	BattleMO.defFormat_ = {}

	BattleMO.fightRoundIndex_ = 1

	BattleMO.fightData_ = nil

	BattleMO.defSeveralForOne_ = false
	BattleMO.atkInfo_ = nil
	BattleMO.defInfo_ = nil
	-- BattleMO.defBossData_ = {}
end

function BattleMO.setFormat(atkFormat, defFormat)
	BattleMO.atkFormat_ = atkFormat
	BattleMO.defFormat_ = defFormat
	if table.isexist(BattleMO.atkFormat_, "awakenHero") then
		BattleMO.atkFormat_.commander = BattleMO.atkFormat_.awakenHero.heroId
	end
	if table.isexist(BattleMO.defFormat_, "awakenHero") then
		BattleMO.defFormat_.commander = BattleMO.defFormat_.awakenHero.heroId
	end
end

function BattleMO.setFightData(fightData)
	BattleMO.fightData_ = fightData
end

--设置双方信息
function BattleMO.setBothInfo(atkInfo,defInfo)
	BattleMO.atkInfo_ = atkInfo
	BattleMO.defInfo_ = defInfo
end

function BattleMO.setOffensive(offensive)
	BattleMO.offensive_ = offensive
end

function BattleMO.setSpeed(speed)
	battleSpeed_ = speed

	BattleMO.updateSpeed()
end

function BattleMO.getSpeed()
	return battleSpeed_
end

function BattleMO.updateSpeed()
	if BattleMO.fightEntity_ then
		for battleFor,forms in pairs(BattleMO.fightEntity_) do
			for pos, tank in pairs(forms) do
				if tank then
					tank:setTimeScale(1/battleSpeed_)
				end
			end
		end
	end
end

-- 战斗中，指定方battleFor，在指定位置pos是否有tank攻击者
function BattleMO.hasTankAtPos(battleFor, pos)
	if not BattleMO.fightEntity_[battleFor] then
		gprint("[BattleMO] ERROR!!!! hasTankAtPos ==>> battleFor:", battleFor, "pos:", pos)
		return false
	end
	if BattleMO.fightEntity_[battleFor][pos] then return true
	else return false end
end

function BattleMO.setTankAtPos(battleFor, pos, tank)
	if not BattleMO.fightEntity_[battleFor] then BattleMO.fightEntity_[battleFor] = {} end
	BattleMO.fightEntity_[battleFor][pos] = tank
	return tank
end

function BattleMO.getTankAtPos(battleFor, pos)
	if not BattleMO.fightEntity_[battleFor] then return nil end
	return BattleMO.fightEntity_[battleFor][pos]
end

-- key: 编号1-12
function BattleMO.getTankByKey(key)
	-- gprint("BattleMO getTankByKey", BattleMO.offensive_, key)
	local battleFor, pos = CombatMO.getBattlePosition(BattleMO.offensive_, key)
	-- gprint("battleFor pos", battleFor, pos)
	return BattleMO.getTankAtPos(battleFor, pos)
end

-- 获得战斗某一方的所有还存在的战斗单元的位置信息
function BattleMO.getAllTankPos(battleFor)
	local ret = {}
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local fighter = BattleMO.getTankAtPos(battleFor, index)
		if fighter then  -- 有
			ret[#ret + 1] = index -- 保存位置
		end
	end
	return ret
end

-- -- key: 编号1-12
-- function BattleMO.getTankByKey(key)
-- 	local pos = math.floor((key + 1) / 2)

-- 	if BattleMO.offensive_ == BATTLE_OFFENSIVE_ATTACK then  -- 进攻方是先手
-- 		if key % 2 == 1 then -- 进攻方
-- 			return BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, pos)
-- 		else
-- 			return BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, pos)
-- 		end
-- 	else
-- 		if key % 2 == 1 then -- 防守方
-- 			return BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, pos)
-- 		else
-- 			return BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, pos)
-- 		end
-- 	end
-- end

function BattleMO.getHp(battleFor, pos)
	-- print("BattleMO.offensive_", BattleMO.offensive_)
	if BattleMO.offensive_ == BATTLE_OFFENSIVE_ATTACK then  -- 进攻方是先手
		if battleFor == BATTLE_FOR_ATTACK then
			return BattleMO.fightData_.hp[pos * 2 - 1]
		else
			return BattleMO.fightData_.hp[pos * 2]
		end
	else
		if battleFor == BATTLE_FOR_ATTACK then
			return BattleMO.fightData_.hp[pos * 2]
		else
			return BattleMO.fightData_.hp[pos * 2 - 1]
		end
	end
	-- local pos = math.floor((key + 1) / 2)

	-- if BattleMO.offensive_ == BATTLE_OFFENSIVE_ATTACK then  -- 进攻方是先手
	-- 	if key % 2 == 1 then -- 进攻方
	-- 		return BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, pos)
	-- 	else
	-- 		return BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, pos)
	-- 	end
	-- else
	-- 	if key % 2 == 1 then -- 防守方
	-- 		return BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, pos)
	-- 	else
	-- 		return BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, pos)
	-- 	end
	-- end
end

function BattleMO.isOver()
	--gprint("@^^^^^BattleMO.isOver^^^^^", BattleMO.fightRoundIndex_, #BattleMO.fightData_.round)
	if BattleMO.fightRoundIndex_ > #BattleMO.fightData_.round + 1 then
		error("[BattleMO] is over. index is Error!!!")
	elseif BattleMO.fightRoundIndex_ == #BattleMO.fightData_.round + 1 then
		--判断飞艇战事		
		if BattleMO.record_ and BattleMO.record_[1] then --还有战斗数据
			local record = clone(BattleMO.record_[1])
			table.remove(BattleMO.record_, 1)
			BattleMO.initNextRecord(record)
			return 1
		else
			local liveFor = 0
			for index = 1, FIGHT_FORMATION_POS_NUM do
				if BattleMO.hasTankAtPos(BATTLE_FOR_DEFEND, index) then
					liveFor = 1
					break
				end
			end

			if liveFor == 1 then
				for index = 1, FIGHT_FORMATION_POS_NUM do
					if BattleMO.hasTankAtPos(BATTLE_FOR_ATTACK, index) then
						liveFor = 2
						break
					end
				end

				if liveFor == 2 then
					BattleMO.checkTankState()
					return 2
				end
			end			
		end
		return true
	else
		return false
	end
end

function BattleMO.checkTankState()
	local node = display.newNode():addTo(UiDirector.getTopUi())

	local function hand()
		if BattleMO.fightEntity_ then
			for battleFor,fights in pairs(BattleMO.fightEntity_) do
				for pos,tank in pairs(fights) do
					if tank and not tank:isFireOver() then
						node:performWithDelay(hand, 3/battleSpeed_)
						return
					end
				end
			end
		end		
		
		node:removeSelf()

		local liveFor = 0
		for index = 1, FIGHT_FORMATION_POS_NUM do
			if BattleMO.hasTankAtPos(BATTLE_FOR_DEFEND, index) then
				liveFor = 1
				break
			end
		end

		if liveFor == 1 then
			for index = 1, FIGHT_FORMATION_POS_NUM do
				local liveTank = BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, index)
				if liveTank then
					liveTank:onRemoveSelf(false)
					liveFor = 2
				end
			end

			if liveFor == 2 then
				Toast.show(CommonText[1109])
			end
		end	

		BattleBO:startRound()
	end

	node:performWithDelay(hand, 2/battleSpeed_) --弹道延时时间
end

function BattleMO.initNextRecord(record)
	local node = display.newNode():addTo(UiDirector.getTopUi())
	local function hand()
		--检查哪方团灭
		local nxt = BATTLE_FOR_DEFEND
		local allDead = true
		for index = 1, FIGHT_FORMATION_POS_NUM do
			if BattleMO.hasTankAtPos(BATTLE_FOR_DEFEND, index) then
				nxt = 0
				allDead = false
				break
			end
		end
		if nxt == 0 then
			nxt = BATTLE_FOR_ATTACK
			for index = 1, FIGHT_FORMATION_POS_NUM do
				if BattleMO.hasTankAtPos(BATTLE_FOR_ATTACK, index) then
					nxt = 0
					allDead = false
					break
				end
			end
		else
			-- 这里还是要再检查一下是不是全灭了
			for index = 1, FIGHT_FORMATION_POS_NUM do
				if BattleMO.hasTankAtPos(BATTLE_FOR_ATTACK, index) then
					allDead = false
					break
				end
			end
		end
		if nxt == 0 then --继续检查，直到有一方全灭
			----达到回合上限,判定进攻方 失败,移除所有进攻玩家
			for index = 1, FIGHT_FORMATION_POS_NUM do
				local liveTank = BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, index)
				if liveTank  then
					liveTank:onRemoveSelf(false)
				end
			end	

			Toast.show(CommonText[1109])
			node:performWithDelay(hand, 2/battleSpeed_)
		else
			node:removeSelf()
			-- table.remove(BattleMO.attackers_, 1)
			-- table.remove(BattleMO.defencers_, 1)
			table.remove(nxt == BATTLE_FOR_ATTACK and BattleMO.attackers_ or BattleMO.defencers_, 1)
			---检测 存活方 是不是复活tank
			
			local live = nxt == BATTLE_FOR_ATTACK and BATTLE_FOR_DEFEND or BATTLE_FOR_ATTACK
			local liveReborn = false
			for index = 1, FIGHT_FORMATION_POS_NUM do
				local liveTank = BattleMO.getTankAtPos(live, index)
				if liveTank and liveTank:isReborn() then
					----移除复活tank
					liveTank:onRemoveSelf(false)
					liveReborn = true
				end
			end

			if liveReborn then
				table.remove(live == BATTLE_FOR_ATTACK and BattleMO.attackers_ or BattleMO.defencers_, 1)
			end
			
			-- 设置先手
			CombatMO.curBattleOffensive_ = record.offsensive

			CombatMO.curBattleAtkFormat_ = record.atkFormat
			CombatMO.curBattleDefFormat_ = record.defFormat
			CombatMO.curBattleFightData_ = record

			BattleMO.reset()
			BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
			BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
			BattleMO.setFightData(CombatMO.curBattleFightData_)

			gprint("@^^^^^^^^^^^^新生成战斗方阵^^^^^^^^^^^^")
			--新生成阵营
			for index = 1, FIGHT_FORMATION_POS_NUM do
				local atk = BattleMO.atkFormat_[index]
				if atk and atk.tankId and atk.tankId > 0 and atk.count and atk.count > 0 then
					local hp = BattleMO.getHp(BATTLE_FOR_ATTACK, index)
					if not BattleMO.hasTankAtPos(BATTLE_FOR_ATTACK, index) then
						if hp > 0 then
							BattleMO.setTankAtPos(BATTLE_FOR_ATTACK, index, EntityFactory.createTank(BATTLE_FOR_ATTACK, index, atk.tankId, atk.count, hp))
						end
					else
						local tank = BattleMO.getTankAtPos(BATTLE_FOR_ATTACK, index)
						tank:syncHp(hp, atk.count)
					end
				end

				local def = BattleMO.defFormat_[index]
				if def and def.tankId and def.tankId > 0 and def.count and def.count > 0 then
					local hp = BattleMO.getHp(BATTLE_FOR_DEFEND, index)
					if not BattleMO.hasTankAtPos(BATTLE_FOR_DEFEND, index) then
						if hp > 0 then
							BattleMO.setTankAtPos(BATTLE_FOR_DEFEND, index, EntityFactory.createTank(BATTLE_FOR_DEFEND, index, def.tankId, def.count, hp))
						end
					else
						local tank = BattleMO.getTankAtPos(BATTLE_FOR_DEFEND, index)
						tank:syncHp(hp, def.count)						
					end
				end
			end

			local campFlag = nxt
			if liveReborn then
				campFlag = nil
			end
			--初始化下一轮数据
			Notify.notify(LOCAL_BATTLE_NEXT_EVENT,{camp = campFlag})
			--入场
			if allDead == false then
				BattleBO.tankEnter(campFlag)
			else
				BattleBO.tankEnter()
			end
		end
	end
	node:performWithDelay(hand, 1.5/battleSpeed_) --弹道延时时间
end

function BattleMO.getRoundAtIndex(index)
	return BattleMO.fightData_.round[index]
end

function BattleMO.getCurrentRound()
	return BattleMO.fightData_.round[BattleMO.fightRoundIndex_]
end

-- 秘密武器
function BattleMO.getWarWeaponId(battleFor)
	if not BattleMO.fightData_.weapon then return -1 end
	if battleFor == 1 and BattleMO.fightData_.weapon then
		return BattleMO.fightData_.weapon.atkWeaponId or 0
	end
	if battleFor == 2 and BattleMO.fightData_.weapon then
		return BattleMO.fightData_.weapon.defWeaponId or 0
	end
end

-- 战斗特效
function BattleMO.getFighterEffect(battleFor, pos)
	if not BattleMO.fightData_.fighterEffect then return 1 end
	if battleFor == 1 and BattleMO.fightData_.fighterEffect.atkFighterEffect then
		local effectid = BattleMO.fightData_.fighterEffect.atkFighterEffect[pos]
		if (not effectid) or (effectid and effectid <= 1) then return 1 end
		return effectid
	end
	if battleFor == 2 and BattleMO.fightData_.fighterEffect.defFighterEffect then
		local effectid = BattleMO.fightData_.fighterEffect.defFighterEffect[pos]
		if (not effectid) or (effectid and effectid <= 1) then return 1 end
		return effectid
	end
	return 1
end

function BattleMO.setTest()
	local data = 
	{
		addSkillEffect = {},
		atkFormat = {
		    [1]= {
		        count  = 1161,
		        tankId = 24,
		    },
		    [2]= {
		        count  = 1161,
		        tankId = 24,
		    },
		    [3]= {
		        count  = 1161,
		        tankId = 24,
		    },
		    [4]= {
		        count  = 1161,
		        tankId = 24,
		    },
		    [5]= {
		        count  = 1161,
		        tankId = 24,
		    },
		    [6]= {
		        count  = 1161,
		        tankId = 24,
		    },
		    commander = 339,
		},
		defFormat = {
		    [1]= {
		        count  = 1171,
		        tankId = 24,
		    },
		    [2]= {
		        count  = 1171,
		        tankId = 24,
		    },
		    [3]= {
		        count  = 1171,
		        tankId = 24,
		    },
		    [4]= {
		        count  = 1171,
		        tankId = 24,
		    },
		    [5]= {
		        count  = 1171,
		        tankId = 24,
		    },
		    [6]= {
		        count  = 1171,
		        tankId = 24,
		    },
		    commander = 336,
		},
		hp = {
		    [1] = 15123465,
		    [2] = 16619715,
		    [3] = 15123465,
		    [4] = 16619715,
		    [5] = 15123465,
		    [6] = 13368915,
		    [7] = 15123465,
		    [8] = 13368915,
		    [9] = 12582395,
		    [10]= 13368915,
		    [11]= 15123465,
		    [12]= 13368915,
		},
		keyId      = 0,
		offsensive = 2,
		reborn = {
		    [15]= {
		    	tankId = {[1]=24,[2]=24},
		    	count = {[1]=1161,[2]=1161},
		    	hp = {[1]=15123465,[2]=15123465},
		    	pos={[1]=7,[2]=8},
		    	round=15,
		    },
		},
		round = {
		    [1]= {
		        action = {
		            [1]= {
		                count  = 656,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 7232079,
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 909,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3615072,
		                },
		                impale = false,
		                target = 4,
		            },
		            [3]= {
		                count  = 854,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3539741,
		                },
		                impale = false,
		                target = 6,
		            },
		            [4]= {
		                count  = 532,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 7248151,
		                },
		                impale = false,
		                target = 8,
		            },
		            [5]= {
		                count  = 533,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 7240710,
		                },
		                impale = false,
		                target = 10,
		            },
		            [6]= {
		                count  = 847,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3624186,
		                },
		                impale = false,
		                target = 12,
		            },
		        },
		        key    = 1,
		    },
		    [2]= {
		        action = {
		            [1]= {
		                count  = 1005,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2144651,
		                },
		                impale = false,
		                target = 1,
		            },
		            [2]= {
		                count  = 847,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 4195551,
		                },
		                impale = false,
		                target = 3,
		            },
		            [3]= {
		                count  = 844,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 4223322,
		                },
		                impale = false,
		                target = 5,
		            },
		            [4]= {
		                count  = 842,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 4254752,
		                },
		                impale = false,
		                target = 7,
		            },
		            [5]= {
		                count  = 969,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2175250,
		                },
		                impale = false,
		                target = 9,
		            },
		            [6]= {
		                count  = 1006,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2137398,
		                },
		                impale = false,
		                target = 11,
		            },
		        },
		        key    = 2,
		    },
		    [3]= {
		        action = {
		            [1]= {
		                count  = 0,
		                crit   = false,
		                dodge  = true,
		                hurt = {
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 727,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2606187,
		                },
		                impale = false,
		                target = 4,
		            },
		            [3]= {
		                count  = 630,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2578894,
		                },
		                impale = false,
		                target = 6,
		            },
		            [4]= {
		                count  = 304,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2621397,
		                },
		                impale = false,
		                target = 8,
		            },
		            [5]= {
		                count  = 305,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2622264,
		                },
		                impale = false,
		                target = 10,
		            },
		            [6]= {
		                count  = 625,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2550603,
		                },
		                impale = false,
		                target = 12,
		            },
		        },
		        key    = 3,
		    },
		    [4]= {
		        action = {
		            [1]= {
		                count  = 819,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2405464,
		                },
		                impale = false,
		                target = 1,
		            },
		            [2]= {
		                count  = 662,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2391063,
		                },
		                impale = false,
		                target = 3,
		            },
		            [3]= {
		                count  = 481,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 4696945,
		                },
		                impale = false,
		                target = 5,
		            },
		            [4]= {
		                count  = 477,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 4710348,
		                },
		                impale = false,
		                target = 7,
		            },
		            [5]= {
		                count  = 751,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 2343544,
		                },
		                impale = false,
		                target = 9,
		            },
		            [6]= {
		                count  = 635,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 4790822,
		                },
		                impale = false,
		                target = 11,
		            },
		        },
		        key    = 4,
		    },
		    [5]= {
		        action = {
		            [1]= {
		                count  = 553,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1472783,
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 623,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1492104,
		                },
		                impale = false,
		                target = 4,
		            },
		            [3]= {
		                count  = 500,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1493395,
		                },
		                impale = false,
		                target = 6,
		            },
		            [4]= {
		                count  = 177,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1471101,
		                },
		                impale = false,
		                target = 8,
		            },
		            [5]= {
		                count  = 175,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1497017,
		                },
		                impale = false,
		                target = 10,
		            },
		            [6]= {
		                count  = 496,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1490851,
		                },
		                impale = false,
		                target = 12,
		            },
		        },
		        key    = 5,
		    },
		    [6]= {
		        action = {
		            [1]= {
		                count  = 707,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1454483,
		                },
		                impale = false,
		                target = 1,
		            },
		            [2]= {
		                count  = 547,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1474564,
		                },
		                impale = false,
		                target = 3,
		            },
		            [3]= {
		                count  = 367,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1465602,
		                },
		                impale = false,
		                target = 5,
		            },
		            [4]= {
		                count  = 363,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1483064,
		                },
		                impale = false,
		                target = 7,
		            },
		            [5]= {
		                count  = 617,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1441040,
		                },
		                impale = false,
		                target = 9,
		            },
		            [6]= {
		                count  = 0,
		                crit   = false,
		                dodge  = true,
		                hurt = {
		                    [1]= 1432020,
		                },
		                impale = false,
		                target = 11,
		            },
		        },
		        key    = 6,
		    },
		    [7]= {
		        action = {
		            [1]= {
		                count  = 475,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1124488,
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 544,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1126399,
		                },
		                impale = false,
		                target = 4,
		            },
		            [3]= {
		                count  = 307,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 2228244,
		                },
		                impale = false,
		                target = 6,
		            },
		            [4]= {
		                count  = 79,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1120084,
		                },
		                impale = false,
		                target = 8,
		            },
		            [5]= {
		                count  = 0,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 2266300,
		                },
		                impale = false,
		                target = 10,
		            },
		            [6]= {
		                count  = 399,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1119655,
		                },
		                impale = false,
		                target = 12,
		            },
		        },
		        key    = 7,
		    },
		    [8]= {
		        action = {
		            [1]= {
		                count  = 688,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 234314,
		                },
		                impale = false,
		                target = 1,
		            },
		            [2]= {
		                count  = 530,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 226123,
		                },
		                impale = false,
		                target = 3,
		            },
		            [3]= {
		                count  = 350,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 226101,
		                },
		                impale = false,
		                target = 5,
		            },
		            [4]= {
		                count  = 344,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 233094,
		                },
		                impale = false,
		                target = 7,
		            },
		            [5]= {
		                count  = 595,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 234094,
		                },
		                impale = false,
		                target = 9,
		            },
		            [6]= {
		                count  = 617,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 226988,
		                },
		                impale = false,
		                target = 11,
		            },
		        },
		        key    = 8,
		    },
		    [9]= {
		        action = {
		            [1]= {
		                count  = 346,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1840600,
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 417,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1818792,
		                },
		                impale = false,
		                target = 4,
		            },
		            [3]= {
		                count  = 147,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1836432,
		                },
		                impale = false,
		                target = 6,
		            },
		            [4]= {
		                count  = 0,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 3602585,
		                },
		                impale = false,
		                target = 8,
		            },
		            [5]= {
		                count  = 238,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1848254,
		                },
		                impale = false,
		                target = 12,
		            },
		        },
		        key    = 9,
		    },
		    [10]= {
		        action = {
		            [1]= {
		                count  = 635,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 685416,
		                },
		                impale = false,
		                target = 1,
		            },
		            [2]= {
		                count  = 421,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 1403762,
		                },
		                impale = false,
		                target = 3,
		            },
		            [3]= {
		                count  = 297,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 688435,
		                },
		                impale = false,
		                target = 5,
		            },
		            [4]= {
		                count  = 291,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 693707,
		                },
		                impale = false,
		                target = 7,
		            },
		            [5]= {
		                count  = 530,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 699099,
		                },
		                impale = false,
		                target = 9,
		            },
		            [6]= {
		                count  = 563,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 703020,
		                },
		                impale = false,
		                target = 11,
		            },
		        },
		        key    = 12,
		    },
		    [11]= {
		        action = {
		            [1]= {
		                count  = 224,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1754335,
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 297,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1719285,
		                },
		                impale = false,
		                target = 4,
		            },
		            [3]= {
		                count  = 0,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1713243,
		                },
		                impale = false,
		                target = 6,
		            },
		            [4]= {
		                count  = 91,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1697224,
		                },
		                impale = false,
		                target = 12,
		            },
		        },
		        key    = 11,
		    },
		    [12]= {
		        action = {
		            [1]= {
		                count  = 86,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1972220,
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 22,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 3933613,
		                },
		                impale = false,
		                target = 4,
		            },
		            [3]= {
		                count  = 0,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1925032,
		                },
		                impale = false,
		                target = 12,
		            },
		        },
		        key    = 1,
		    },
		    [13]= {
		        action = {
		            [1]= {
		                count  = 589,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 596648,
		                },
		                impale = false,
		                target = 1,
		            },
		            [2]= {
		                count  = 398,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 295953,
		                },
		                impale = false,
		                target = 3,
		            },
		            [3]= {
		                count  = 273,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 302579,
		                },
		                impale = false,
		                target = 5,
		            },
		            [4]= {
		                count  = 267,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 303180,
		                },
		                impale = false,
		                target = 7,
		            },
		            [5]= {
		                count  = 503,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 294349,
		                },
		                impale = false,
		                target = 9,
		            },
		            [6]= {
		                count  = 540,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 298049,
		                },
		                impale = false,
		                target = 11,
		            },
		        },
		        key    = 2,
		    },
		    [14]= {
		        action = {
		            [1]= {
		                count  = 2,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1207502,
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 0,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 1232285,
		                },
		                impale = false,
		                target = 4,
		            },
		        },
		        key    = 3,
		    },
		    [15]= {
		        action = {
		            [1]= {
		                count  = 0,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 846347,
		                },
		                impale = false,
		                target = 2,
		            },
		        },
		        key    = 5,
		    },
		    [16]= {
		        action = {
		            [1]= {
		                count  = 300,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3737708,
		                },
		                impale = false,
		                target = 1,
		            },
		            [2]= {
		                count  = 109,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3734806,
		                },
		                impale = false,
		                target = 3,
		            },
		            [3]= {
		                count  = 0,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3822579,
		                },
		                impale = false,
		                target = 5,
		            },
		            [4]= {
		                count  = 0,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3709594,
		                },
		                impale = false,
		                target = 7,
		            },
		            [5]= {
		                count  = 157,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3708315,
		                },
		                impale = false,
		                target = 9,
		            },
		            [6]= {
		                count  = 0,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 7512274,
		                },
		                impale = false,
		                target = 11,
		            },
		        },
		        key    = 2,
		    },
		    [17]= {
		        action = {
		            [1]= {
		                count  = 1094,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 971152,
		                },
		                impale = false,
		                target = 2,
		            },
		            [2]= {
		                count  = 1093,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 980231,
		                },
		                impale = false,
		                target = 4,
		            },
		        },
		        key    = 1,
		    },
		    [18]= {
		        action = {
		            [1]= {
		                count  = 0,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 7143985,
		                },
		                impale = false,
		                target = 1,
		            },
		            [2]= {
		                count  = 0,
		                crit   = false,
		                dodge  = false,
		                hurt = {
		                    [1]= 3534561,
		                },
		                impale = false,
		                target = 3,
		            },
		            [3]= {
		                count  = 0,
		                crit   = true,
		                dodge  = false,
		                hurt = {
		                    [1]= 7003807,
		                },
		                impale = false,
		                target = 9,
		            },
		        },
		        key    = 4,
		    }
		}
	}
	CombatMO.curChoseBattleType_ = COMBAT_TYPE_REPLAY
	BattleMO.reset()
	BattleMO.setOffensive(2)  -- 设置先手
	BattleMO.setFormat(data.atkFormat, data.defFormat)
	BattleMO.setFightData(data)
	BattleMO.setBothInfo({name = "不死战神"},{name = "克敌先机"})
	CCDirector:sharedDirector():getScheduler():setTimeScale(1.5)
	require("app.view.BattleView").new("image/bg/bg_battle_2.jpg"):push()
end
