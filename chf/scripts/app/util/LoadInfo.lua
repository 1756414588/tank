--
-- Author: Xiaohang
-- Date: 2016-10-09 15:57:27
--
-- 登陆加载信息
local info_ = {
	{"GetBuilding",BuildBO.update},
	{"GetPartyScience",PartyBO.updateData},
	{"GetTank",TankBO.update},
	{"GetPendant",PendantBO.update},
	{"GetProp",PropBO.update},
	{"GetArmy",ArmyBO.update},
	{"GetInvasion",ArmyBO.updateInvasions},
	{"GetAid",ArmyBO.updateAids},
	{"GetScience",ScienceBO.update},
	{"GetRoleEnergyStone",EnergySparBO.update},
	{"GetEnergyStoneInlay",EnergySparBO.updateInlayData},
	{"GetForm",TankBO.updateForm},
	{"GetResource",UserBO.updateGetResource},
	{"GetEquip",EquipBO.update},
	{"GetPart",PartBO.update},
	{"GetChip",PartBO.updateChip},
	{"GetCombat",CombatBO.update},
	{"GetFriend",SocialityBO.updateFriend},
	{"GetBless",SocialityBO.updateBlesses},
	{"GetEffect",EffectBO.update},
	{"GetScout",UserMO.scout_,true},
	{"GetMyHeros",HeroBO.update},
	{"GetSkill",SkillBO.update},
	{"GetStore",SocialityBO.updateStore},
	{"GetChat",ChatBO.update},
	{"GetSign",SignBO.update},
	{"EveLogin",SignBO.updateEveryLogin},
	{"GetMajorTask",TaskBO.updateMajorTask},
	{"GetDayiyTask",TaskBO.updateDaylyTask},
	{"GetLiveTask",TaskBO.updateLiveTask},
	{"NewGetLiveTask",TaskBO.updateLiveTask},
	{"GetMailList",MailBO.updateMails},
	{"GetLotteryEquip",LotteryBO.updateLotteryEquip},
	{"GetLotteryExplore",LotteryBO.updateTreasureFreeTimes},
	{"GetStaffing",StaffBO.updateGetStaffing},
	{"GetSeniorMap",StaffBO.updateGetSeniorMap},
	{"GetArena",ArenaBO.update},
	{"GetActivityList",ActivityBO.update},
	{"GetActionCenter",ActivityCenterBO.update},
	{"GetActEDayPay",ActivityCenterBO.updateActEDayPay},
	{"GetMyFortressJob",FortressBO.fortressJob,true},
	{"GetPushState",UserBO.updatePushState,true},
	{"GetMedal",MedalBO.updateMedal},
	{"GetMedalChip",MedalBO.updateMedalChip},
	{"GetMedalBouns",MedalBO.updateMedalShow},
	{"GetMonthSign",ActivityBO.updateMonthSign},
	{"GetFightLabInfo",LaboratoryBO.updataFightLabInfo}, -- 作战实验室获取人员信息 科技信息 建筑信息
	{"GetFightLabItemInfo",LaboratoryBO.updateFightLabItemInfo}, -- 作战实验室获取物品信息 和 产出的资源信息
	{"GetFightLabGraduateInfo",LaboratoryBO.GetFightLabGraduateInfo},	-- 作战实验室 获取深度研究所信息
	{"GetActStroke",ActivityBO.UpdateActStroke},	-- 闪击行动
	{"GetTactics",TacticsBO.update},	        -- 战术
	{"EnergyCore",EnergyCoreBO.update},	        -- 能源核心
	{"GetCrossServerInfo",HunterBO.updateCrossInfo},	-- 跨服副本
	-- {"GetPlayerBackMessage",PlayerBackBO.update}, --拉取老玩家回归信息
	-- {"GetHeroPutInfo",StaffBO.updateStaffHeros}, --拉取文官入驻信息
}

--只能单次请求,这里面的请求数据量太大
local INFO_ONE = {
	{"GetMilitaryScience",OrdnanceBO.update},
	{"GetMilitaryScienceGrid",OrdnanceBO.updateGrid},
}

local time = 6 --发送次数

local LoadInfo = {}

function LoadInfo.getInfo(rhand)

	local do_info_ = clone(info_)


	--IOS审核阶段 尽量读取少量数据
	if GameConfig.enableCode == false then
		INFO_ONE = {
			
		}
		OrdnanceBO.update()
		OrdnanceBO.updateGrid()
	end
	
	-- 军备
	if UserMO.queryFuncOpen(UFP_WEAPONRY) then
		local fun = {"GetLordEquipInfo",WeaponryBO.updateMedal}
		table.insert(do_info_,fun)
	end

	-- 军衔
	if UserMO.queryFuncOpen(UFP_MILITARY) then
		local fun = {"GetMilitaryRank",MilitaryRankBO.updateLoad}
		table.insert(do_info_,fun)
	end

	LoadInfo.rhand = rhand
	LoadInfo.index = 1
	LoadInfo.index_one = 1
	local list = {}
	local num = math.floor(#do_info_/time)
	for k=1,num*time do
		local v = do_info_[k]
		local key = math.floor((k-1)/num)
		if not list[key+1] then list[key+1] = {} end
		table.insert(list[key+1], v)
	end
	--多余的从后开始往前加
	local index = #list
	for k=num*time+1,#do_info_ do
		table.insert(list[index], do_info_[k])
		index = index - 1
	end
	LoadInfo.list = list
	LoadInfo.repairs = {}
	LoadInfo.send()
end

function LoadInfo.send()
	local items = LoadInfo.list[LoadInfo.index]
	if items then
		local requests = {}
		for k,v in ipairs(items) do
			table.insert(requests,NetRequest.new(v[1]))
			if k == #items then
				SocketReceiver.register(v[1], function(name,data)
					for m,n in ipairs(items) do
						local temp = nil
						--最后一次不用dig，因为已经强制监听了
						if m == #items then
							temp = data 
						else
							temp = SocketReceiver.dig(n[1])
						end
						-- if (n[3] == true and temp) or n[3] == nil then
						-- 	if type(n[2]) == "function" then
						-- 		n[2](temp)
						-- 	else
						-- 		n[2] = temp
						-- 	end
						-- end
						table.insert(LoadInfo.repairs,{item = n,data=temp})
					end
					if display.getRunningScene().updatePer then
						display.getRunningScene():updatePer(92 + LoadInfo.index)
					end
					LoadInfo.index = LoadInfo.index + 1
					LoadInfo.send()
				end ,nil,nil,true)
			end
		end
		SocketWrapper.wrapSends(requests)
	else
		local item = INFO_ONE[LoadInfo.index_one]
		if item then
			SocketWrapper.wrapSend(function(name,data)
					if data then
						if type(item[2]) == "function" then
							item[2](data)
						else
							item[2] = data
						end
					end
					LoadInfo.index_one = LoadInfo.index_one + 1
					LoadInfo.send()
				end, NetRequest.new(item[1]))
		else
			if display.getRunningScene().updatePer then
				display.getRunningScene():updatePer(92 + LoadInfo.index)
			end
			LoadInfo.rhand()
		end
	end
end

return LoadInfo