--
-- Author: xiaoxing
-- Date: 2017-03-24 13:38:06
-- 技能特效处理
local SMOKE_SHOT  = 2 --烟雾弹出场时间

local FightEffect = {}
local SKILL1 = 1 --烟雾弹
local SKILL2 = 6 --盾
local SKILL3 = 11 -- 保护盾
local SKILL_ANXING = 18 -- 安兴的技能
local SKILL_UNYIELDING = 19 -- 奥古斯特不屈
local SKILL_DODGE = 20 -- 全体加闪避



function FightEffect.onEnter()
	armature_add(IMAGE_ANIMATION .. "battle/yanwudan_baozha.pvr.ccz", IMAGE_ANIMATION .. "battle/yanwudan_baozha.plist", IMAGE_ANIMATION .. "battle/yanwudan_baozha.xml")
	armature_add(IMAGE_ANIMATION .. "battle/yanwudan_biaojishang.pvr.ccz", IMAGE_ANIMATION .. "battle/yanwudan_biaojishang.plist", IMAGE_ANIMATION .. "battle/yanwudan_biaojishang.xml")
	armature_add(IMAGE_ANIMATION .. "battle/yanwudan_biaojixia.pvr.ccz", IMAGE_ANIMATION .. "battle/yanwudan_biaojixia.plist", IMAGE_ANIMATION .. "battle/yanwudan_biaojixia.xml")
	-- armature_add(IMAGE_ANIMATION .. "hero/beihou_gx.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_gx.plist", IMAGE_ANIMATION .. "hero/beihou_gx.xml")
	armature_add(IMAGE_ANIMATION .. "hero/jx_diban.pvr.ccz", IMAGE_ANIMATION .. "hero/jx_diban.plist", IMAGE_ANIMATION .. "hero/jx_diban.xml")
	armature_add(IMAGE_ANIMATION .. "hero/jx_shandian.pvr.ccz", IMAGE_ANIMATION .. "hero/jx_shandian.plist", IMAGE_ANIMATION .. "hero/jx_shandian.xml")

	armature_add(IMAGE_ANIMATION .. "battle/juexing_jineng.pvr.ccz", IMAGE_ANIMATION .. "battle/juexing_jineng.plist", IMAGE_ANIMATION .. "battle/juexing_jineng.xml")
	armature_add(IMAGE_ANIMATION .. "battle/juexing_gedang.pvr.ccz", IMAGE_ANIMATION .. "battle/juexing_gedang.plist", IMAGE_ANIMATION .. "battle/juexing_gedang.xml")

	armature_add(IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjineng.pvr.ccz", IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjineng.plist", IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjineng.xml")
	armature_add(IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjinengxunhuan.pvr.ccz", IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjinengxunhuan.plist", IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjinengxunhuan.xml")
	armature_add(IMAGE_ANIMATION .. "battle/anxing_juexingjineng.pvr.ccz", IMAGE_ANIMATION .. "battle/anxing_juexingjineng.plist", IMAGE_ANIMATION .. "battle/anxing_juexingjineng.xml")
	armature_add(IMAGE_ANIMATION .. "battle/anxing_juexingjinengxunhuan.pvr.ccz", IMAGE_ANIMATION .. "battle/anxing_juexingjinengxunhuan.plist", IMAGE_ANIMATION .. "battle/anxing_juexingjinengxunhuan.xml")
	armature_add(IMAGE_ANIMATION .. "battle/leidi_juexingjineng.pvr.ccz", IMAGE_ANIMATION .. "battle/leidi_juexingjineng.plist", IMAGE_ANIMATION .. "battle/leidi_juexingjineng.xml")
	armature_add(IMAGE_ANIMATION .. "battle/leidi_juexingjinengxunhuan.pvr.ccz", IMAGE_ANIMATION .. "battle/leidi_juexingjinengxunhuan.plist", IMAGE_ANIMATION .. "battle/leidi_juexingjinengxunhuan.xml")

	armature_add(IMAGE_ANIMATION .. "battle/aogusite_jineng.pvr.ccz", IMAGE_ANIMATION .. "battle/aogusite_jineng.plist", IMAGE_ANIMATION .. "battle/aogusite_jineng.xml")
	armature_add(IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.pvr.ccz", IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.plist", IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.xml")
end

function FightEffect.getRoundTime(roundIndex)
	local time = 0
	local add = BattleMO.fightData_.addSkillEffect[roundIndex]
	if add then
		local has = {}
		local order = {} --先手循序
		for k,v in ipairs(add) do
			local battleFor, pos= CombatMO.getBattlePosition(BattleMO.offensive_, v.key)
			--出手方
			if v.id == SKILL1 then
				battleFor = battleFor % 2 + 1
			end
			if not has[battleFor] then
				has[battleFor] = {}
				table.insert(order,battleFor)
			end
			table.insert(has[battleFor], v)
		end
		return has, order
	end
end


function FightEffect.getPassiveSkillEffect(roundIndex)
	-- body
	if BattleMO.fightData_.passiveSkillEffect ~= nil then
		local add = BattleMO.fightData_.passiveSkillEffect[roundIndex]
		return add
	else
		return nil
	end
end

--回合移除技能
function FightEffect.checkRemoveSkill(roundIndex,rhand)
	local round = BattleMO.getCurrentRound()
	local battleFor, pos= CombatMO.getBattlePosition(BattleMO.offensive_, round.key)
	local tank = BattleMO.getTankAtPos(battleFor, pos)
	if tank and tank.skillBuff_ then
		if tank.skillBuff_[SKILL1] and #round.action == 0 then --烟雾弹不出手
			local p = tank:getParent()
			local yanwu1 = tank.yanwu1
			local yanwu2 = tank.yanwu2
			local spwArray = cc.Array:create()
			spwArray:addObject(CCScaleTo:create(0.3, 1.4))
			spwArray:addObject(CCFadeOut:create(0.3))
			yanwu1:runAction(transition.sequence({cc.Spawn:create(spwArray),cc.CallFuncN:create(function()
					yanwu1:removeSelf()
				end)}))
			local spwArray = cc.Array:create()
			spwArray:addObject(CCScaleTo:create(0.8, 1.4))
			spwArray:addObject(CCFadeOut:create(0.8))
			yanwu2:runAction(transition.sequence({cc.Spawn:create(spwArray),cc.CallFuncN:create(function()
					yanwu2:removeSelf()
					tank.skillBuff_[SKILL1] = nil
					--跳过此回合
					BattleMO.fightRoundIndex_ = BattleMO.fightRoundIndex_ + 1
					BattleBO:startRound()					
				end)}))
		else
			rhand()
		end
	else
		rhand()
	end
end

--检查死亡tank
function FightEffect.checkDie(tank)
	if tank and tank.skillBuff_ then
		if tank.skillBuff_[SKILL1] then
			tank.yanwu1:removeSelf()
			tank.yanwu2:removeSelf()
			tank.skillBuff_[SKILL1] = nil
		end
		if tank.skillBuff_[SKILL3] then
			if tank.fxz_dun2 then
				tank.fxz_dun2:removeSelf()
				tank.fxz_dun2 = nil
			end
			tank.skillBuff_[SKILL3] = nil
		end

		if tank.skillBuff_[SKILL_DODGE] then
			if tank.fxz_dodge_add then
				tank.fxz_dodge_add:removeSelf()
				tank.fxz_dodge_add = nil
			end
			tank.skillBuff_[SKILL_DODGE] = nil
		end

		if tank.skillBuff_[SKILL_UNYIELDING] then
			if tank.fxz_unyielding then
				tank.fxz_unyielding:removeSelf()
				tank.fxz_unyielding = nil
			end
			tank.skillBuff_[SKILL_UNYIELDING] = nil
		end

		if tank.skillBuff_[SKILL_ANXING] then
			if tank.fxz_anxing then
				tank.fxz_anxing:removeSelf()
				tank.fxz_anxing = nil
			end
			tank.skillBuff_[SKILL_ANXING] = nil
		end
	end
end

--检查移除烟雾tank
function FightEffect.removeSkill1(tank, callback)
	if tank and tank.skillBuff_ and tank.skillBuff_[SKILL1] then
		local yanwu1 = tank.yanwu1
		local yanwu2 = tank.yanwu2
		local spwArray = cc.Array:create()
		spwArray:addObject(CCScaleTo:create(0.3, 1.4))
		spwArray:addObject(CCFadeOut:create(0.3))
		yanwu1:runAction(transition.sequence({cc.Spawn:create(spwArray),cc.CallFuncN:create(function()
				yanwu1:removeSelf()
			end)}))
		local spwArray = cc.Array:create()
		spwArray:addObject(CCScaleTo:create(0.8, 1.4))
		spwArray:addObject(CCFadeOut:create(0.8))
		yanwu2:runAction(transition.sequence({cc.Spawn:create(spwArray),cc.CallFuncN:create(function()
				yanwu2:removeSelf()		

				if callback then
					callback()
				end		
			end)}))
		tank.skillBuff_[SKILL1] = nil
	end
end

function FightEffect.showEffect(round,rhand)
	local info,order = FightEffect.getRoundTime(round)
	if not info then
		rhand()
		return
	end
	local index = 1
	local p = UiDirector.getTopUi()
	function show()
		if index > #order then
			rhand()
		else
			local bat = info[order[index]]
			if bat[1].id == SKILL1 then
				local startPos, y = cc.p(display.cx, 60),display.height - 150
				if order[index] == BATTLE_FOR_DEFEND then
					startPos, y = cc.p(display.cx, display.height - 60), 150
				end
				FightEffect.showSkillEnter(order[index],function()
						FightEffect.showSmoke(bat,p,startPos,y,function()
								index = index + 1
								show()
							end)
					end)
			elseif bat[1].id == SKILL2 then
				FightEffect.showSkillEnter(order[index],function()
						FightEffect.showShield(bat,p,function()
								index = index + 1
								show()
							end)
					end)
			elseif bat[1].id == SKILL3 then
				FightEffect.showSkillEnter(order[index],function()
						FightEffect.showDeepHurt(bat,p,function()
								index = index + 1
								show()
							end)
					end)
			elseif bat[1].id == (-SKILL3) then
				FightEffect.hideDeepHurt(bat,p,function ()
					index = index + 1
					show()
				end)
			elseif bat[1].id == SKILL_DODGE then
				FightEffect.showSkillEnter(order[index], function ()
					FightEffect.showDodgeAdd(bat,p,function()
						index = index + 1
						show()
					end)
				end)
			elseif bat[1].id == (-SKILL_DODGE) then
				FightEffect.hideDodgeAdd(bat,p,function()
					index = index + 1
					show()
				end)
			elseif bat[1].id == (SKILL_UNYIELDING) then
				FightEffect.showSkillEnter(order[index], function ()
					FightEffect.showUnyielding(bat,p,function()
						index = index + 1
						show()
					end)
				end)
			elseif bat[1].id == (-SKILL_UNYIELDING) then
				FightEffect.hideUnyielding(bat,p,function()
					index = index + 1
					show()
				end)
			elseif bat[1].id == (SKILL_ANXING) then
				FightEffect.showSkillEnter(order[index], function ()
					FightEffect.showAnxing(bat,p,function()
						index = index + 1
						show()
					end)
				end)
			elseif bat[1].id == (-SKILL_ANXING) then
				FightEffect.hideAnxing(bat,p,function()
					index = index + 1
					show()
				end)
			end
		end
	end
	show()
end

--显示入场
function FightEffect.showSkillEnter(battle,rhand)

	local p = UiDirector.getTopUi()
	local id = battle == BATTLE_FOR_ATTACK and BattleMO.atkFormat_.commander or BattleMO.defFormat_.commander
	local effectName = HeroMO.queryHero(id).map
	--底板
	local flame = armature_create("jx_diban", 320, 250, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
				rhand()
			end
		end)
	if battle == BATTLE_FOR_DEFEND then
		flame:setScaleX(-1)
		flame:y(display.height - flame:y())
	end
	flame:getAnimation():playWithIndex(0)
	flame:addTo(p)
	armature_add(IMAGE_ANIMATION .. "hero/" ..effectName ..".pvr.ccz", IMAGE_ANIMATION .. "hero/" ..effectName ..".plist", IMAGE_ANIMATION .. "hero/" ..effectName ..".xml")
	local heroNode = display.newNode():addTo(flame,10)
	--英雄
	local hero = armature_create(effectName, 0, 0, function (movementType, movementID, armature)
		end)
	hero:getAnimation():playWithIndex(0)
	hero:addTo(heroNode,10):align(display.CENTER_BOTTOM, 0, 0)
	heroNode:pos(-320 - hero:width()/2, -flame:height()/2)

	local map = effectName
	if map == "leidi" then
		map = "anxing"
	end
	heroNode:runAction(transition.sequence({cc.MoveTo:create(0.1, cc.p(-120,-flame:height()/2)),cc.CallFuncN:create(function(sender)
			local name = display.newSprite(IMAGE_COMMON.."skill_hero_"..effectName..".png"):addTo(heroNode):pos(200,60):scale(0.7)
			name:setOpacity(0)
			name:fadeIn(1)
			armature_add(IMAGE_ANIMATION .. "hero/beihou_"..map..".pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_"..map..".plist", IMAGE_ANIMATION .. "hero/beihou_"..map..".xml")
			--背后光
			local light = armature_create("beihou_"..map,320,flame:y() - 15,function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
			light:getAnimation():playWithIndex(0)
			light:addTo(heroNode,0):align(display.CENTER_BOTTOM, 0, 0)
			--光效
			armature_add(IMAGE_ANIMATION .. "hero/jx_shandian.pvr.ccz", IMAGE_ANIMATION .. "hero/jx_shandian.plist", IMAGE_ANIMATION .. "hero/jx_shandian.xml")
			local light = armature_create("jx_shandian",320,flame:y() - 15,function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
			light:getAnimation():playWithIndex(0)
			light:addTo(p,10)
			if battle == BATTLE_FOR_DEFEND then 
				name:setScaleX(-1) 
				light:setScaleX(-1) 
			end
		end),cc.DelayTime:create(1.4),cc.MoveBy:create(0.1, cc.p(-350,0)),cc.RemoveSelf:create()}))
end

--显示烟雾弹
function FightEffect.showSmoke(bat,p,startPos,endPos,rhand)

	local function ammoUpdate(ammo) -- 火箭弹的尾焰
		armature_add(IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.plist", IMAGE_ANIMATION .. "battle/bt_ammo_4_flame.xml")
		local flame = armature_create("bt_ammo_4_flame", ammo:getPositionX(), ammo:getPositionY(), function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
			end)
		flame:getAnimation():playWithIndex(0)
		flame:addTo(p):scale(2)

		local lastPos = ammo.lastPos
		local deltaX = ammo:getPositionX() - lastPos.x
		local deltaY = ammo:getPositionY() - lastPos.y
		local degree = math.deg(math.atan2(deltaX, deltaY))
		flame:setRotation(degree)
		ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())
	end
	local index = 1
	local function fire(order)
		local x = math.random(startPos.x-120,startPos.x+120)
		local y = math.random(startPos.y-60,startPos.y+60)
		local endx = math.random(x - 50,x + 50)
		local endy = math.random(endPos - 50,endPos +50)
		local config = ccBezierConfig()
		config.endPosition = cc.p(endx,endy)
		local ex = math.random(40,80) 
		local ey = math.random(60,100)
		if index % 2 == 0 then
			ex = ex*-1
		end
		config.controlPoint_1 = cc.p(x - ex, (endy+y)/2- ey)
		config.controlPoint_2 = cc.p(x - ex, (endy+y)/2 + ey)

		local ammo = display.newSprite(IMAGE_COMMON.."yanwudan.png"):addTo(p):pos(x,y)
		local ttt = 0.3
		ammo:rotateTo(ttt, math.random(360*4,360*7))
		ammo:runAction(transition.sequence({cc.BezierTo:create(ttt, config), cc.CallFuncN:create(function(sender)
			local die = armature_create("yanwudan_baozha", ammo:x(),ammo:y(),
					function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
							armature:removeSelf()
							if order >= 6 then
								rhand()
							end
						end
					end)
				die:getAnimation():playWithIndex(0)
				die:addTo(p)
				sender:removeSelf()
			end)}))
		--加上状态
		if order >= 6 then
			for k,v in ipairs(bat) do
				gdump(v, "bat v==")
				if v.state ~= 1 then
					local tank = BattleMO.getTankByKey(v.key)
					if not tank.skillBuff_ then
						tank.skillBuff_ = {}
					end
					tank.skillBuff_[v.id] = true
					local p = tank:getParent()
					local wu1 = armature_create("yanwudan_biaojishang", tank:width()/2,tank:height()/2,
							function (movementType, movementID, armature)
								if movementType == MovementEventType.COMPLETE then
									armature:removeSelf()
								end
							end)
					wu1:getAnimation():playWithIndex(0)
					wu1:addTo(tank,tank.bodyView_:getTag() + 1)
					wu1:setOpacity(0)
					wu1:runAction(CCFadeIn:create(0.8))
					tank.yanwu1 = wu1
					local wu2 = armature_create("yanwudan_biaojixia", tank:width()/2,tank:height()/2,
							function (movementType, movementID, armature)
								if movementType == MovementEventType.COMPLETE then
									armature:removeSelf()
								end
							end)
					wu2:getAnimation():playWithIndex(0)
					wu2:addTo(tank,tank.bodyView_:getTag() - 1)
					wu2:setOpacity(0)
					wu2:runAction(CCFadeIn:create(0.8))
					tank.yanwu2 = wu2
				end
			end
		end
		ammo.lastPos = cc.p(ammo:getPositionX(), ammo:getPositionY())
		local node = display.newNode():addTo(ammo)
		nodeExportComponentMethod(node)
		node:setNodeEventEnabled(true)
		node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) ammoUpdate(ammo) end)
		node:scheduleUpdate()
		if index < 6 then
			local delay = math.random(1,3)
			index = index + 1
			p:performWithDelay(function() fire(index) end, delay/10)
		end
	end
	fire(1)
end

function FightEffect.showShield(bat,p,rhand)
	 --加上状态
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if not tank.skillBuff_ then
			tank.skillBuff_ = {}
		end
		tank.skillBuff_[v.id] = true
		local wu1 = armature_create("juexing_jineng", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
						if k == #bat then
							rhand()
						end
					end
				end)
		wu1:getAnimation():playWithIndex(0)
		wu1:addTo(tank)
	end
end

function FightEffect.showDodgeAdd(bat,p,rhand)
	-- body
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if not tank.skillBuff_ then
			tank.skillBuff_ = {}
		end
		tank.skillBuff_[v.id] = true

		local wu2 = armature_create("leidi_juexingjinengxunhuan", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then

					end
				end)
		-- wu2:getAnimation():playWithIndex(0)
		wu2:addTo(tank)
		tank.fxz_dodge_add = wu2

		local wu1 = armature_create("leidi_juexingjineng", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
						wu2:getAnimation():playWithIndex(0)
						if k == #bat then
							rhand()
						end
					end
				end) 
		wu1:getAnimation():playWithIndex(0)
		wu1:addTo(tank)
	end
end

function FightEffect.showUnyielding(bat,p,rhand)
	-- body
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if not tank.skillBuff_ then
			tank.skillBuff_ = {}
		end
		tank.skillBuff_[v.id] = true

		local wu2 = armature_create("aogusite_jineng_chixu", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
					end
				end)
		-- wu2:getAnimation():playWithIndex(0)
		wu2:addTo(tank,-1)
		tank.fxz_unyielding = wu2

		local wu1 = armature_create("aogusite_jineng", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
						wu2:getAnimation():playWithIndex(0)
						if k == #bat then
							rhand()
						end
					end
				end) 
		wu1:getAnimation():playWithIndex(0)
		wu1:addTo(tank)
	end
end

function FightEffect.showAnxing(bat,p,rhand)
	-- body
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if not tank.skillBuff_ then
			tank.skillBuff_ = {}
		end
		tank.skillBuff_[v.id] = true

		local wu2 = armature_create("anxing_juexingjinengxunhuan", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
					end
				end)
		-- wu2:getAnimation():playWithIndex(0)
		wu2:addTo(tank)
		tank.fxz_anxing = wu2

		local wu1 = armature_create("anxing_juexingjineng", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
						wu2:getAnimation():playWithIndex(0)
						if k == #bat then
							rhand()
						end
					end
				end) 
		wu1:getAnimation():playWithIndex(0)
		wu1:addTo(tank)
	end
end

function FightEffect.hideDodgeAdd(bat, p, rhand)
	-- body
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if tank then
			if tank.fxz_dodge_add then
				tank.fxz_dodge_add:removeSelf()
				tank.fxz_dodge_add = nil
			end
			local id = v.id
			if v.id < 0 then
				id = -id
			end
			tank.skillBuff_[id] = nil
		end
	end
	rhand()
end


function FightEffect.hideUnyielding(bat, p, rhand)
	-- body
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if tank then
			if tank.fxz_unyielding then
				tank.fxz_unyielding:removeSelf()
				tank.fxz_unyielding = nil
			end
			local id = v.id
			if v.id < 0 then
				id = -id
			end
			tank.skillBuff_[id] = nil
		end
	end
	rhand()
end


function FightEffect.hideAnxing(bat, p, rhand)
	-- body
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if tank then
			if tank.fxz_anxing then
				tank.fxz_anxing:removeSelf()
				tank.fxz_anxing = nil
			end
			local id = v.id
			if v.id < 0 then
				id = -id
			end
			tank.skillBuff_[id] = nil
		end
	end
	rhand()
end


-- 风行者觉醒技能 show
function FightEffect.showDeepHurt(bat,p,rhand)
	--加上状态
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if not tank.skillBuff_ then
			tank.skillBuff_ = {}
		end
		tank.skillBuff_[v.id] = true
		local wu2 = armature_create("fengxingzhe_juexingjinengxunhuan", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then

					end
				end)
		-- wu2:getAnimation():playWithIndex(0)
		wu2:addTo(tank,-1)
		tank.fxz_dun2 = wu2

		local wu1 = armature_create("fengxingzhe_juexingjineng", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
						wu2:getAnimation():playWithIndex(0)
						if k == #bat then
							rhand()
						end
					end
				end) 
		wu1:getAnimation():playWithIndex(0)
		wu1:addTo(tank)
	end
end

-- 风行者觉醒技能 hide
function FightEffect.hideDeepHurt( bat,p,rhand )
	for k,v in ipairs(bat) do
		local tank = BattleMO.getTankByKey(v.key)
		if tank then
			if tank.fxz_dun2 then
				tank.fxz_dun2:removeSelf()
				tank.fxz_dun2 = nil
			end
			local id = v.id
			if v.id < 0 then
				id = -id
			end
			tank.skillBuff_[id] = nil
		end
	end
	rhand()
end

--显示打击特效
function FightEffect.showHurtEffect(tank)
	if tank.skillBuff_ and tank.skillBuff_[SKILL2] then --保护罩
		local gedang = armature_create("juexing_gedang", tank:width()/2,tank:height()/2,
				function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
				end)
		gedang:getAnimation():playWithIndex(0)
		gedang:addTo(tank,10)
		gedang:scale(1.2)
		if tank.battleFor_ == BATTLE_FOR_DEFEND then
			gedang:setScaleY(-1.2)
		end
		tank.skillBuff_[SKILL2] = nil
	end
end

function FightEffect.onExit()
	-- armature_remove(IMAGE_ANIMATION .. "hero/beihou_gx.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_gx.plist", IMAGE_ANIMATION .. "hero/beihou_gx.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/jx_diban.pvr.ccz", IMAGE_ANIMATION .. "hero/jx_diban.plist", IMAGE_ANIMATION .. "hero/jx_diban.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/jx_shandian.pvr.ccz", IMAGE_ANIMATION .. "hero/jx_shandian.plist", IMAGE_ANIMATION .. "hero/jx_shandian.xml")

	armature_remove(IMAGE_ANIMATION .. "battle/yanwudan_baozha.pvr.ccz", IMAGE_ANIMATION .. "battle/yanwudan_baozha.plist", IMAGE_ANIMATION .. "battle/yanwudan_baozha.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/yanwudan_biaojishang.pvr.ccz", IMAGE_ANIMATION .. "battle/yanwudan_biaojishang.plist", IMAGE_ANIMATION .. "battle/yanwudan_biaojishang.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/yanwudan_biaojixia.pvr.ccz", IMAGE_ANIMATION .. "battle/yanwudan_biaojixia.plist", IMAGE_ANIMATION .. "battle/yanwudan_biaojixia.xml")
	
	armature_remove(IMAGE_ANIMATION .. "battle/juexing_jineng.pvr.ccz", IMAGE_ANIMATION .. "battle/juexing_jineng.plist", IMAGE_ANIMATION .. "battle/juexing_jineng.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/juexing_gedang.pvr.ccz", IMAGE_ANIMATION .. "battle/juexing_gedang.plist", IMAGE_ANIMATION .. "battle/juexing_gedang.xml")

	armature_remove(IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjineng.pvr.ccz", IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjineng.plist", IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjineng.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjinengxunhuan.pvr.ccz", IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjinengxunhuan.plist", IMAGE_ANIMATION .. "battle/fengxingzhe_juexingjinengxunhuan.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/anxing_juexingjineng.pvr.ccz", IMAGE_ANIMATION .. "battle/anxing_juexingjineng.plist", IMAGE_ANIMATION .. "battle/anxing_juexingjineng.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/anxing_juexingjinengxunhuan.pvr.ccz", IMAGE_ANIMATION .. "battle/anxing_juexingjinengxunhuan.plist", IMAGE_ANIMATION .. "battle/anxing_juexingjinengxunhuan.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/leidi_juexingjineng.pvr.ccz", IMAGE_ANIMATION .. "battle/leidi_juexingjineng.plist", IMAGE_ANIMATION .. "battle/leidi_juexingjineng.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/leidi_juexingjinengxunhuan.pvr.ccz", IMAGE_ANIMATION .. "battle/leidi_juexingjinengxunhuan.plist", IMAGE_ANIMATION .. "battle/leidi_juexingjinengxunhuan.xml")

	armature_remove(IMAGE_ANIMATION .. "battle/aogusite_jineng.pvr.ccz", IMAGE_ANIMATION .. "battle/aogusite_jineng.plist", IMAGE_ANIMATION .. "battle/aogusite_jineng.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.pvr.ccz", IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.plist", IMAGE_ANIMATION .. "battle/aogusite_jineng_chixu.xml")
end

return FightEffect