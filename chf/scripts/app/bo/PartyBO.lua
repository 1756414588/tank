--
-- Author: gf
-- Date: 2015-09-11 11:17:41
--

PartyBO = {}


-- 军团中所有的建筑排放的位置
HomePartyMapConfig = {
{id=PARTY_BUILD_ID_HALL, asset="gang", x=610, y=805, sx=-10, sy=0, ss=0.8, order=100},
{id=PARTY_BUILD_ID_SCIENCE, asset="party_science", x=640, y=612, sx=-0, sy=0, ss=0.5, order=88},
{id=PARTY_BUILD_ID_WEAL, asset="party_weal", x=590, y=240, sx=-10, sy=0, ss=0.6, order=103},
{id=PARTY_BUILD_ID_INTELLIGENCE, asset="party_intelligence", x=295, y=787, sx=-10, sy=0, ss=0.8, order=114},
{id=PARTY_BUILD_ID_SHOP, asset="party_shop", x=745, y=324, sx=-20, sy=0, order=91},
{id=PARTY_BUILD_ID_TAOC, asset="party_taoc", x=214, y=446, sx=-20, sy=0, order=101},
{id=PARTY_BUILD_ID_ALTAR, asset="party_altar", x=90, y=670, sx=-20, sy=0, order=102}
}


--被踢出军团推送处理
function PartyBO.parseSynPartyOut(name, data)
	PartyMO.clearMyParty()
	UserBO.triggerFightCheck()

	if #ArmyMO.getArmiesByState(ARMY_STATE_GARRISON) > 0 or #ArmyMO.getArmiesByState(ARMY_STATE_WAITTING) > 0 then -- 玩家自己在军团中有驻军
		ArmyBO.asynGetArmy()
	end

	Notify.notify(LOCAL_MYPARTY_UPDATE_EVENT)

	local homeView = UiDirector.getUiByName("HomeView")
	if homeView.m_curShowIndex == MAIN_SHOW_PARTY then
		Toast.show(CommonText[699])
		UiDirector.popMakeUiTop("HomeView")
		homeView:showChosenIndex(MAIN_SHOW_BASE)
	end	
end

--军团审核推送处理
function PartyBO.parseSynPartyAccept(name, data)
	gdump(data,"PartyBO.parseSynPartyAccept")
	--同意
	if data.accept == 1 then
		PartyMO.partyData_.partyId = data.partyId
		PartyMO.applyList = {}
		PartyBO.asynGetParty(function()
				PartyBO.asynGetPartyMember(nil,1)
				PartyBO.asynGetPartyScience()
				PartyBO.updatePartyTip()
				Notify.notify(LOCAL_MYPARTY_UPDATE_EVENT)
			end, 0)
	else
		--拒绝
		for index=1,#PartyMO.applyList do
			local id = PartyMO.applyList[index]
			if id == data.partyId then
				table.remove(PartyMO.applyList,index)
				break
			end
		end
	end
	Notify.notify(LOCAL_PARTY_LIST_UPDATE_EVENT)
end

function PartyBO.parseSynApply(name, data)
	if data.applyCount then
		PartyMO.partyApplyList_num = data.applyCount
		Notify.notify(LOCAL_PARTY_APPLY_UPDATE_EVENT)		
	end
end


function PartyBO.update(data)
	-- HeroMO.heros_ = HeroMO.queryHeroToInfo(data)
	gdump(data,"PartyBO.update..data")
	
	if data and table.isexist(data, "party") then
		PartyMO.partyData_ = PbProtocol.decodeRecord(data["party"])
		if table.isexist(data, "donate") then
			PartyMO.myDonate_ = data.donate
		end
		if table.isexist(data, "job") then
			PartyMO.myJob = data.job
		end
		if table.isexist(data, "enterTime") then
			PartyMO.enterTime_ = data.enterTime
		end
	else
		PartyMO.partyData_.partyId = 0
	end
end

function PartyBO.asynGetParty(doneCallback, partyId)
	local function parseResult(name, data)
		gdump(data,"[PartyBO.asynGetParty]..data")

		local partyData
		if table.isexist(data, "party") then
			partyData = PbProtocol.decodeRecord(data["party"])
			if partyId == 0 then
				PartyMO.partyData_ = partyData
				if table.isexist(data, "donate") then
					PartyMO.myDonate_ = data.donate
				end
				if table.isexist(data, "job") then
					PartyMO.myJob = data.job
				end
				if table.isexist(data, "enterTime") then
					PartyMO.enterTime_ = data.enterTime
				end				
			end
		else
			if partyId == 0 then
				-- PartyMO.clearMyParty()
				UserBO.triggerFightCheck()
			else
				Toast.show(CommonText[614])
			end
		end
		if doneCallback then doneCallback(partyData) end
		
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetParty", {partyId = partyId}))
end

function PartyBO.updateApply(data)
	if data and table.isexist(data, "partyId") then
		PartyMO.applyList = data.partyId
		-- dump(PartyMO.applyList,"PartyMO.applyListPartyMO.applyList")
	end
end

function PartyBO.asynApplyList(doneCallback)
	local function parseResult(name, data)
		PartyBO.updateApply(data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ApplyList"))
end

--创建军团资源是否足够
function PartyBO.canCreatParty(applyType)
	if applyType == 1 then
		if UserMO.getResource(ITEM_KIND_COIN) < CREAT_PARTY_NEED_COIN then
			return false
		end
	else
		if UserMO.getResource(ITEM_KIND_RESOURCE,RESOURCE_ID_STONE) < CREAT_PARTY_NEED_STONE then
			return false
		end
		if UserMO.getResource(ITEM_KIND_RESOURCE,RESOURCE_ID_IRON) < CREAT_PARTY_NEED_IRON then
			return false
		end
		if UserMO.getResource(ITEM_KIND_RESOURCE,RESOURCE_ID_OIL) < CREAT_PARTY_NEED_OIL then
			return false
		end
		if UserMO.getResource(ITEM_KIND_RESOURCE,RESOURCE_ID_COPPER) < CREAT_PARTY_NEED_COPPER then
			return false
		end
		if UserMO.getResource(ITEM_KIND_RESOURCE,RESOURCE_ID_SILICON) < CREAT_PARTY_NEED_SILICON then
			return false
		end
	end
	return true
end


function PartyBO.asynCreatParty(doneCallback, partyName, type, applyType)

	local function parseResult(name, data)
		PartyBO.update(data)

		--TK统计
		TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[29],TKGAME_USERES_TYPE_UPDATE)
		TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[29],TKGAME_USERES_TYPE_UPDATE)
		TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[29],TKGAME_USERES_TYPE_UPDATE)
		TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[29],TKGAME_USERES_TYPE_UPDATE)
		TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[29],TKGAME_USERES_TYPE_UPDATE)
		TKGameBO.onUseCoinTk(data.gold,TKText[29],TKGAME_USERES_TYPE_UPDATE)

		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		UserMO.updateResource(ITEM_KIND_RESOURCE, data.stone, RESOURCE_ID_STONE)
		UserMO.updateResource(ITEM_KIND_RESOURCE, data.iron, RESOURCE_ID_IRON)
		UserMO.updateResource(ITEM_KIND_RESOURCE, data.silicon, RESOURCE_ID_SILICON)
		UserMO.updateResource(ITEM_KIND_RESOURCE, data.copper, RESOURCE_ID_COPPER)
		UserMO.updateResource(ITEM_KIND_RESOURCE, data.oil, RESOURCE_ID_OIL)

		PartyBO.updatePartyTip()
		Notify.notify(LOCAL_MYPARTY_UPDATE_EVENT)
		
		if doneCallback then doneCallback() end
		-- 埋点
		Statistics.postPoint(STATIS_POINT_PART_C)
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("CreateParty", {partyName = partyName,type = type,applyType = applyType}))
end


function PartyBO.asynGetPartyRank(doneCallback, page, type)
	if page == 0 then
		PartyBO.clearAllParty()
	end
	local function parseResult(name, data)
		if table.isexist(data, "party") then
			PartyMO.myPartyRank = PbProtocol.decodeRecord(data["party"])
		else
			PartyMO.myPartyRank = nil
		end
		local list =PbProtocol.decodeArray(data["partyRank"])
		for index = 1,#list do
			table.insert(PartyMO.allPartyList_,list[index])
		end
		-- gdump(PartyMO.allPartyList_,"PartyBO.asynGetPartyRank..PartyMO.allPartyList_")
		Notify.notify(LOCAL_PARTY_LIST_UPDATE_EVENT,{page = page,count = #list})
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyRank", {page = page,type = type}))
end

function PartyBO.asynGetPartyLvRank(doneCallback, page)

	if page == 0 then
		PartyMO.partyRankList_ = {}
	end
	local function parseResult(name, data)
		if table.isexist(data, "party") then
			PartyMO.myPartyRank = PbProtocol.decodeRecord(data["party"])
		else
			PartyMO.myPartyRank = nil
		end
		local list =PbProtocol.decodeArray(data["partyLvRank"])
		for index = 1,#list do
			table.insert(PartyMO.partyRankList_,list[index])
		end

		Notify.notify(LOCAL_PARTY_RANK_UPDATE_EVENT,{page = page,count = #list})
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyLvRank", {page = page}))
end


function PartyBO.asynSeachParty(doneCallback, partyName)
	--测试
	-- local party = {
	-- 	rank = 4,
	-- 	partyId = 4,
	-- 	partyName = "公会名称21212",
	-- 	partyLv = 1,
	-- 	member = 50,
	-- 	fight = 1000
	-- }
	-- if doneCallback then doneCallback(party) end



	local function parseResult(name, data)
		
		if doneCallback then doneCallback(PbProtocol.decodeRecord(data["partyRank"])) end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("SeachParty", {partyName = partyName}))
end

-- function PartyBO.asynGetPartyBuilding(doneCallback)
-- 	local function parseResult(name, data)
-- 		local list = PbProtocol.decodeArray(data["partyBuilding"])
-- 		for index=1,#list do
-- 			local buildData = list[index]
-- 			PartyMO.buildData_[buildData.buildId] = buildData
-- 		end
-- 		gdump(PartyMO.buildData_,"PartyBO.asynGetPartyBuilding..PartyMO.buildData_")
-- 		if doneCallback then doneCallback() end
-- 	end

-- 	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyBuilding"))
-- end

function PartyBO.asynGetPartyHall(doneCallback)
	local function parseResult(name, data)
		local partyDonate = PbProtocol.decodeRecord(data["partyDonate"])

		PartyMO.hallData_[PARTY_CONTRIBUTE_TYPE_IRON] = partyDonate.iron
		PartyMO.hallData_[PARTY_CONTRIBUTE_TYPE_OIL] = partyDonate.oil
		PartyMO.hallData_[PARTY_CONTRIBUTE_TYPE_COPPER] = partyDonate.copper
		PartyMO.hallData_[PARTY_CONTRIBUTE_TYPE_SILICON] = partyDonate.silicon
		PartyMO.hallData_[PARTY_CONTRIBUTE_TYPE_STONE] = partyDonate.stone
		PartyMO.hallData_[PARTY_CONTRIBUTE_TYPE_COIN] = partyDonate.gold

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyHall"))
end

function PartyBO.asynDonateParty(doneCallback,resouceId,build)
	local function parseResult(name, data)
		--贡献次数增加
		PartyMO.hallData_[resouceId] = PartyMO.hallData_[resouceId] + 1
		--建设度增加
		--增加判断是否增加总建设度
		local isBuild
		if table.isexist(data, "isBuild") and data.isBuild == true then 
			isBuild = data.isBuild
			PartyMO.partyData_.build = PartyMO.partyData_.build + build
		end
		

		ActivityBO.trigger(ACTIVITY_ID_PARTY_RECURIT, {type = "hall", id = resouceId})  -- 军团大厅捐献一次

		local res = {}
		--资源更新
		if table.isexist(data, "oil") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "iron") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "copper") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end
		if table.isexist(data, "stone") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
		end
		if table.isexist(data, "gold") then 
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold} 
		end
		UserMO.updateResources(res)

		--个人贡献增加
		PartyMO.myDonate_ = PartyMO.myDonate_ + build
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_PARTY_DONOR,type = 1})
		if doneCallback then doneCallback(isBuild) end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("DonateParty",{resouceId = resouceId}))
end

function PartyBO.asynUpPartyBuilding(doneCallback,buildingId,needExp)
	local function parseResult(name, data)
		if buildingId == PARTY_BUILD_ID_HALL then
			PartyMO.partyData_.partyLv = PartyMO.partyData_.partyLv + 1

			ActivityBO.trigger(ACTIVITY_ID_PARTY_LEVEL) -- 活动处理
		elseif buildingId == PARTY_BUILD_ID_SCIENCE then
			PartyMO.partyData_.scienceLv = PartyMO.partyData_.scienceLv + 1
		elseif buildingId == PARTY_BUILD_ID_WEAL then
			PartyMO.partyData_.wealLv = PartyMO.partyData_.wealLv + 1
		elseif buildingId == PARTY_BUILD_ID_ALTAR then
			PartyMO.partyData_.altarLv = PartyMO.partyData_.altarLv + 1
		end
		--建设度减少
		PartyMO.partyData_.build = PartyMO.partyData_.build - needExp
		--建筑等级更新
		-- Notify.notify(LOCAL_PARTY_BUILD_EVENT)
		Notify.notify(LOCAL_PARTY_BUILD_SCIENCE_EVENT)
		
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpPartyBuilding",{buildingId = buildingId}))
end

function PartyBO.updateShopData(data)
	
	PartyMO.shopData_nomal_ = {}      	--普通
	PartyMO.shopData_treasure_ = {}		--珍品
	for index=1,#data do
		local shopProp = data[index]
		if PartyMO.queryPartyProp(shopProp.keyId).treasure == PARTY_SHOP_TYPE_NORMAL then
			PartyMO.shopData_nomal_[#PartyMO.shopData_nomal_ + 1] = shopProp
		else
			PartyMO.shopData_treasure_[#PartyMO.shopData_treasure_ + 1] = shopProp
		end
	end
	--排序
	local sortFun = function(a,b)
		return a.keyId < b.keyId
	end
	table.sort(PartyMO.shopData_nomal_,sortFun)
end

function PartyBO.asynGetPartyShop(doneCallback)
	--测试数据
	-- data = {
	-- 	{keyId = 1,count = 0},
	-- 	{keyId = 2,count = 0},
	-- 	{keyId = 3,count = 0},
	-- 	{keyId = 4,count = 0},
	-- 	{keyId = 5,count = 0},
	-- 	{keyId = 6,count = 0},
	-- 	{keyId = 7,count = 0},
	-- 	{keyId = 8,count = 0},
	-- 	{keyId = 9,count = 0},
	-- 	{keyId = 10,count = 0},
	-- 	{keyId = 32,count = 0},
	-- 	{keyId = 33,count = 0},
	-- 	{keyId = 34,count = 0}
	-- }
	-- PartyMO.myDonate_ = 160
	-- PartyBO.updateShopData(data)
	-- if doneCallback then doneCallback() end
	-- do return end

	--正式
	local function parseResult(name, data)
		local data = PbProtocol.decodeArray(data["partyProp"])
		gdump(data,"PartyBO.asynGetPartyShop .. data")
		PartyBO.updateShopData(data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyShop"))
end

function PartyBO.asynBuyPartyShop(doneCallback,shopData,need)
	--测试
	-- --减少贡献
	-- PartyMO.myDonate_ = PartyMO.myDonate_ - need
	-- --更新兑换次数
	-- shopData.count = shopData.count + 1
	-- Notify.notify(LOCAL_PARTYSHOP_UPDATE_EVENT)
	-- Notify.notify(LOCAL_PARTY_MYDONATE_UPDATE_EVENT)
	
	-- if doneCallback then doneCallback() end
	-- do return end

	--正式
	local function parseResult(name, data)
		--减少贡献
		PartyMO.myDonate_ = PartyMO.myDonate_ - need
		--更新兑换次数
		shopData.count = shopData.count + 1
		--加入背包
		if table.isexist(data, "award") then
			local award = PbProtocol.decodeArray(data["award"])
			--加入背包
			local ret = CombatBO.addAwards(award)
			UiUtil.showAwards(ret)
		end

		Notify.notify(LOCAL_PARTYSHOP_UPDATE_EVENT)
		Notify.notify(LOCAL_PARTY_MYDONATE_UPDATE_EVENT)

		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_PARTY_SHOP,type = 1})

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyPartyShop",{keyId = shopData.keyId}))
end

function PartyBO.asynGetPartyScience(doneCallback)
	--正式
	local function parseResult(name, data)
		-- gdump(data,"PartyBO.asynGetPartyScience..data")
		PartyBO.updateData(data)

		if doneCallback then doneCallback() end
	end

	PartyMO.dirtyPartyScienceData_ = true

	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyScience"))
end

function PartyBO.updateData(data)
	PartyMO.scienceData_.scienceData = ScienceMO.party_sciences_

	local scienceDbs
	if table.isexist(data, "science") then
		scienceDbs = PbProtocol.decodeArray(data["science"])
		for i = 1,#PartyMO.scienceData_.scienceData do
			local science = PartyMO.scienceData_.scienceData[i]
			for j = 1,#scienceDbs do
				local scienceDb = scienceDbs[j]
				if science.scienceId == scienceDb.scienceId then
					science.scienceLv = scienceDb.scienceLv
					science.schedule = scienceDb.schedule
				end
			end
		end
	end

	if table.isexist(data, "partyDonate") then 
		local partyDonate = PbProtocol.decodeRecord(data["partyDonate"])
		PartyMO.scienceData_.donateData = {}
		PartyMO.scienceData_.donateData[PARTY_CONTRIBUTE_TYPE_IRON] = partyDonate.iron
		PartyMO.scienceData_.donateData[PARTY_CONTRIBUTE_TYPE_OIL] = partyDonate.oil
		PartyMO.scienceData_.donateData[PARTY_CONTRIBUTE_TYPE_COPPER] = partyDonate.copper
		PartyMO.scienceData_.donateData[PARTY_CONTRIBUTE_TYPE_SILICON] = partyDonate.silicon
		PartyMO.scienceData_.donateData[PARTY_CONTRIBUTE_TYPE_STONE] = partyDonate.stone
		PartyMO.scienceData_.donateData[PARTY_CONTRIBUTE_TYPE_COIN] = partyDonate.gold
	end

	--获取军团信息
	local function doneCallback()
		gprint("军团科技等级：",PartyMO.partyData_.scienceLv)

		if not PartyMO.partyData_.scienceLv then
			return
		end

		local sortFun = function(a,b)
			--解锁等级
			local lockLv1 = a.scienceId % 100 - 1
			local lockLv2 = b.scienceId % 100 - 1
			if PartyMO.partyData_.scienceLv >= lockLv1 and PartyMO.partyData_.scienceLv >= lockLv2 then
				return a.rank < b.rank
			else
				return a.scienceId < b.scienceId
			end
		end

		table.sort(PartyMO.scienceData_.scienceData,sortFun)
		gdump(PartyMO.scienceData_.scienceData,"PartyBO.asynGetPartyScience..PartyMO.scienceData_.scienceData")
	end

	partyId = 0 
	if UserMO.level_ >= BuildMO.getOpenLevel(BUILD_ID_PARTY) then
		PartyBO.asynGetParty(doneCallback,partyId)
	end

	PartyMO.dirtyPartyScienceData_ = false

	UserBO.triggerFightCheck()
end

function PartyBO.asynDonateScience(doneCallback,science,resouceId,build)
	--正式
	local function parseResult(name, data)
		gdump(data,"PartyBO.asynDonateScience")
		--科技贡献次数增加
		PartyMO.scienceData_.donateData[resouceId] = PartyMO.scienceData_.donateData[resouceId] + 1

		--科技进度和等级更新
		local newScience = PbProtocol.decodeRecord(data["science"])
		-- gdump(newScience,"newSciencenewScience===============================================")

		local addSchedule --科技进度是否变化
		if science.schedule == newScience.schedule and science.scienceLv == newScience.scienceLv then
			addSchedule = nil
		else
			addSchedule = true
		end

		science.schedule = newScience.schedule

		local oldLv = science.scienceLv
		science.scienceLv = newScience.scienceLv
		if oldLv ~= science.scienceLv then
			UserBO.triggerFightCheck()
		end

		--我的军团贡献增加
		PartyMO.myDonate_ = PartyMO.myDonate_ + build

		--资源更新

		local res = {}
		if table.isexist(data, "oil") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "iron") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "copper") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end
		if table.isexist(data, "stone") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
		end
		if table.isexist(data, "gold") then 
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold} 
		end
		UserMO.updateResources(res)

		ActivityBO.trigger(ACTIVITY_ID_PARTY_RECURIT, {type = "science", id = resouceId})  -- 科技大厅捐献一次

		Notify.notify(LOCAL_PARTY_SCIENCE_DONE_EVENT)
		Notify.notify(LOCAL_PARTY_MYDONATE_UPDATE_EVENT)

		if doneCallback then doneCallback(addSchedule) end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("DonateScience",{scienceId = science.scienceId, resouceId = resouceId}))
end


function PartyBO.asynGetPartyWeal(doneCallback)

	local function parseResult(name, data)
		PartyMO.wealData_ ={}
		PartyMO.wealData_.everWeal = data["everWeal"]
		PartyMO.wealData_.live = data["live"]
		PartyMO.wealData_.resource = PbProtocol.decodeRecord(data["resource"])
		PartyMO.wealData_.getResource = PbProtocol.decodeRecord(data["getResource"])

		
		if table.isexist(data, "liveTask") then
			local liveTaskList = PbProtocol.decodeArray(data["liveTask"])
			for i=1,#PartyMO.liveTaskList do
				local task = PartyMO.liveTaskList[i]
				for j=1,#liveTaskList do
					local taskDB = liveTaskList[j]
					if task.taskId == taskDB.taskId then
						task.schedue = taskDB.count
					end
				end
			end
		end

		gdump(PartyMO.wealData_,"PartyBO.asynGetPartyWeal .. PartyMO.wealData_")
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyWeal"))
end



function PartyBO.asynWealDayParty(doneCallback,type)

	local function parseResult(name, data)
		if type == PARTY_WEAL_GET_TYPE_DAY then
			PartyMO.wealData_.everWeal = 1
			local awards = PbProtocol.decodeArray(data["award"])
			--加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
			PartyMO.myDonate_ = PartyMO.myDonate_ - PartyMO.getDayWealNeed
		else
			--更新资源
			local res = {}
			if table.isexist(data, "oil") then 
				--TK统计
				TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[30],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
			end
			if table.isexist(data, "iron") then 
				--TK统计
				TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[30],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
			end
			if table.isexist(data, "copper") then 
				--TK统计
				TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[30],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
			end
			if table.isexist(data, "silicon") then 
				--TK统计
				TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[30],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
			end
			if table.isexist(data, "stone") then 
				--TK统计
				TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[30],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
			end
			UserMO.updateResources(res)

			PartyMO.wealData_.getResource.iron = PartyMO.wealData_.getResource.iron + PartyMO.wealData_.resource.iron
			PartyMO.wealData_.getResource.oil = PartyMO.wealData_.getResource.oil + PartyMO.wealData_.resource.oil
			PartyMO.wealData_.getResource.copper = PartyMO.wealData_.getResource.copper + PartyMO.wealData_.resource.copper
			PartyMO.wealData_.getResource.silicon = PartyMO.wealData_.getResource.silicon + PartyMO.wealData_.resource.silicon
			PartyMO.wealData_.getResource.stone = PartyMO.wealData_.getResource.stone + PartyMO.wealData_.resource.stone

			PartyMO.wealData_.resource.iron = 0
			PartyMO.wealData_.resource.oil = 0
			PartyMO.wealData_.resource.copper = 0
			PartyMO.wealData_.resource.silicon = 0
			PartyMO.wealData_.resource.stone = 0
		end
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WealDayParty",{type = type}))

end


function PartyBO.asynPartyApply(doneCallback,party)

	local function parseResult(name, data)
		if party.applyType == PARTY_JOIN_TYPE_1 then
			--直接加入
			Toast.show(CommonText[612])
			PartyMO.partyData_ = party
			UiDirector.popMakeUiTop("HomeView")
			PartyBO.updatePartyTip()
			Notify.notify(LOCAL_MYPARTY_UPDATE_EVENT)
			PartyBO.asynGetPartyScience()
			PartyBO.asynGetPartyMember(nil,1)
		else
			--申请列表添加
			PartyMO.applyList[#PartyMO.applyList + 1] = party.partyId
			Toast.show(CommonText[613])
			Notify.notify(LOCAL_PARTY_LIST_UPDATE_EVENT)
		end
		if doneCallback then doneCallback(party.applyType) end
		-- 埋点
		Statistics.postPoint(STATIS_POINT_PART_J)
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("PartyApply",{partyId = party.partyId}))

end

function PartyBO.asynCannlyApply(doneCallback,party)

	local function parseResult(name, data)
		--申请列表删除
		for index=1,#PartyMO.applyList do
			local id = PartyMO.applyList[index]
			if party.partyId == id then
				table.remove(PartyMO.applyList,index)
				break
			end
		end
		Toast.show(CommonText[616])
		Notify.notify(LOCAL_PARTY_LIST_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("CannlyApply",{partyId = party.partyId}))

end

function PartyBO.asynGetPartyTrend(doneCallback, page, type)
	if page == 0 then
		if type == PARTY_TREND_TYPE_1 then
			PartyMO.trends_1 = {}
		else
			PartyMO.trends_2 = {}
		end
	end
	local function parseResult(name, data)
		local trendList = {}
		if table.isexist(data, "trend") then
			trendList = PbProtocol.decodeArray(data["trend"])
		end
		for index = 1,#trendList do
			local trend = trendList[index]
			trend.trendParam = PbProtocol.decodeArray(trend["trendParam"])
			local trendParams = trend.trendParam

			-- local rank = tonumber(trendParams[1].content)
			--百团混战奖励处理
			-- if trend.trendId == 14 and rank and rank > 0 and rank < 11 then
			-- 	local awards = PartyBattleMO.getAwardsByRank(2,rank)
			-- 	gdump(awards,"rank awards===")
			-- 	local str
			-- 	if rank == 1 then
			-- 		str = CommonText[821][1] .. "、"
			-- 	else
			-- 		str = ""
			-- 	end
			-- 	for index=1,#awards do
			-- 		local prop = awards[index]
			-- 		str = str .. UserMO.getResourceData(prop[1], prop[2]).name .. "*" .. prop[3]
			-- 		if index < #awards then
			-- 			str = str .. "、"
			-- 		end
			-- 	end
			-- 	trendParams[2] = {content = str}
			-- end

			for j = 1,#trendParams do
				if table.isexist(trendParams[j], "man") then
					trendParams[j].man = PbProtocol.decodeRecord(trendParams[j]["man"])
				end
				--资源数量处理
				if trend.trendId == 13 and j == 4 then
					trendParams[j].content = UiUtil.strNumSimplify(tonumber(trendParams[j].content))
				elseif trend.trendId >= 24 and trend.trendId <= 32 then
					if (trend.trendId >= 24 and trend.trendId <= 27 and j == 2)
					 or (trend.trendId >= 28 and trend.trendId <= 30 and j == 3)
					 or (trend.trendId >= 31 and trend.trendId <= 32 and j == 1) then
						local airshipId = tonumber(trendParams[j].content)
						trendParams[j].content = AirshipMO.queryShipById(airshipId).name
					end

					if trend.trendId == 30 and j == 2 then
						if trendParams[j].content == nil or trendParams[j].content == "" then
							trendParams[j].content = CommonText[1034]
						end
					end
				end
			end
			table.insert(PartyMO["trends_" .. type],trend)
		end

		--排序
		function sortFun(a,b)
			return a.trendTime > b.trendTime
		end
		table.sort(PartyMO.trends_1,sortFun)
		table.sort(PartyMO.trends_2,sortFun)

		gdump(PartyMO.trends_1,"PartyBO.asynGetPartyTrend..PartyMO.trends_1")
		gdump(PartyMO.trends_2,"PartyBO.asynGetPartyTrend..PartyMO.trends_2")
		Notify.notify(LOCAL_PARTY_TREND_UPDATE_EVENT,{page = page,count = #trendList})
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyTrend", {page = page,type = type}))
end

function PartyBO.asynQuitParty(doneCallback)
	local function parseResult(name, data)
		Toast.show(CommonText[624])
		PartyMO.clearMyParty()
		UserBO.triggerFightCheck()
		ActivityCenterMO.ActivityBrotherList = {} -- 飞艇BUFF活动 清空列表

		if #ArmyMO.getArmiesByState(ARMY_STATE_GARRISON) > 0 or #ArmyMO.getArmiesByState(ARMY_STATE_WAITTING) > 0 then -- 玩家自己在军团中有驻军
			ArmyBO.asynGetArmy()
		end

		UiDirector.popMakeUiTop("HomeView")
		local homeView = UiDirector.getUiByName("HomeView")
		if homeView then homeView:showChosenIndex(MAIN_SHOW_BASE) end

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("QuitParty"))

end

function PartyBO.asynPartyJobCount(doneCallback)
	local function parseResult(name, data)
		PartyMO.partyJobCount = data
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PartyJobCount"))
end

function PartyBO.asynSetPartyJob(doneCallback,jobName1,jobName2,jobName3,jobName4)
	local function parseResult(name, data)
		PartyMO.partyData_.jobName1 = jobName1
		PartyMO.partyData_.jobName2 = jobName2
		PartyMO.partyData_.jobName3 = jobName3
		PartyMO.partyData_.jobName4 = jobName4
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SetPartyJob",{jobName1 = jobName1,jobName2 = jobName2,jobName3 = jobName3,jobName4 = jobName4}))
end

function PartyBO.asynPartyApplyEdit(doneCallback,applyType,applyLv,fight,slogan)
	local function parseResult(name, data)
		Toast.show(CommonText[633])
		PartyMO.partyData_.applyType = applyType
		PartyMO.partyData_.applyLv = tonumber(applyLv)
		PartyMO.partyData_.applyFight = tonumber(fight)
		PartyMO.partyData_.slogan = slogan
		Notify.notify(LOCAL_PARTY_OPTION_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PartyApplyEdit",{applyType = applyType,applyLv = applyLv,fight = fight,slogan = slogan}))
end

function PartyBO.asynPartyApplyList(doneCallback)
	local function parseResult(name, data)
		local list = PbProtocol.decodeArray(data["partyApply"])
		PartyMO.partyApplyList = list
		PartyMO.partyApplyList_num = #PartyMO.partyApplyList
		Notify.notify(LOCAL_PARTY_APPLY_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PartyApplyList"))
end

function PartyBO.asynGetPartyMember(doneCallback,type)
	--测试
	-- local list = {
	-- 	{rank = 1,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 2,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 3,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 4,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 5,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 6,lordId = 1, icon = 1,job = 99, nick = "张三qq", level = 10, fight = 100,donate = 100, weekDonate = 2000},
	-- 	{rank = 7,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 8,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 9,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 10,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 11,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000},
	-- 	{rank = 12,lordId = 1, icon = 1,job = 99, nick = "张三", level = 10, fight = 100,donate = 100, weekDonate = 1000}
	-- }
	-- PartyMO.partyData_.partyMember = list
	-- if doneCallback then doneCallback(type) end
	-- do return end

	local function parseResult(name, data)
		local list = PbProtocol.decodeArray(data["partyMember"])
		gdump(list,"PartyBO.asynGetPartyMember..partyMember")
		--排序(战力)
		local sortFun = function(a,b)
			if a.militaryRank == b.militaryRank then
				if a.fight == b.fight then
					return a.lordId < b.lordId
				else
					return a.fight > b.fight
				end
			else
				return a.militaryRank > b.militaryRank
			end
		end

		--排序(贡献)
		local sortFun1 = function(a,b)
			if a.weekDonate == b.weekDonate then
				return a.lordId < b.lordId
			else
				return a.weekDonate > b.weekDonate
			end
		end

		if type == 1 then
			table.sort(list,sortFun)
		else
			table.sort(list,sortFun1)
		end
		
		--增加排名
		for index=1,#list do
			list[index].rank = index
		end
		
		PartyMO.partyData_.partyMember = list
		PartyMO.partyData_.member = #PartyMO.partyData_.partyMember

		if doneCallback then doneCallback(type) end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyMember"))
end

function PartyBO.asynGetPartyLiveRank(doneCallback)
	local function parseResult(name, data)
		local list = PbProtocol.decodeArray(data["partyLive"])
		--排序
		local sortFun = function(a,b)
			return a.live > b.live
		end

		table.sort(list,sortFun)
		
		--增加排名
		for index=1,#list do
			list[index].rank = index
		end
		if doneCallback then doneCallback(list) end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyLiveRank"))
end



function PartyBO.asynPartyApplyJudge(doneCallback,lordId,judge)
	local function parseResult(name, data)
		if judge == 3 then
			PartyMO.partyApplyList = {}
		else
			for index=1,#PartyMO.partyApplyList do
				if PartyMO.partyApplyList[index].lordId == lordId then
					table.remove(PartyMO.partyApplyList,index)
					break
				end
			end
		end
		PartyMO.partyApplyList_num = #PartyMO.partyApplyList
		Notify.notify(LOCAL_PARTY_APPLY_UPDATE_EVENT)

		if judge == 1 then
			PartyMO.partyData_.member = PartyMO.partyData_.member + 1
			Notify.notify(LOCAL_PARTY_MEMBER_UPDATE_EVENT)
		end
		if doneCallback then doneCallback() end
	end
	local param = {}
	if lordId then
		param.lordId = lordId
	end
	param.judge = judge
	
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PartyApplyJudge",param))
end

function PartyBO.asynUpMemberJob(doneCallback,member)
	
	local function parseResult(name, data)
		PartyMO.myJob = data.job
		member.job = data.job
		Notify.notify(LOCAL_PARTY_MEMBER_UPDATE_EVENT)
		Toast.show(string.format(CommonText[648],PartyBO.getJobNameById(member.job)))
		if doneCallback then doneCallback() end
	end
	local param = {}
	if PartyMO.myJob < PARTY_JOB_OFFICAIL then
		param.job = PARTY_JOB_OFFICAIL
	else
		param.job = PARTY_JOB_MASTER
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpMemberJob",param))
end

function PartyBO.asynCleanMember(doneCallback,member)
	
	local function parseResult(name, data)
		for index=1,#PartyMO.partyData_.partyMember do
			if PartyMO.partyData_.partyMember[index].lordId == member.lordId then
				table.remove(PartyMO.partyData_.partyMember,index)
				break
			end
		end
		PartyMO.partyData_.member = #PartyMO.partyData_.partyMember
		Notify.notify(LOCAL_PARTY_MEMBER_UPDATE_EVENT)
		Toast.show(CommonText[649])

		if doneCallback then doneCallback() end
	end
	local param = {lordId = member.lordId}
	
	SocketWrapper.wrapSend(parseResult, NetRequest.new("CleanMember",param))
end


function PartyBO.asynConcedeJob(doneCallback,member)
	local function parseResult(name, data)
		member.job = PARTY_JOB_MASTER
		for index=1,#PartyMO.partyData_.partyMember do
			if PartyMO.partyData_.partyMember[index].lordId == UserMO.lordId_ then
				PartyMO.partyData_.partyMember[index].job = PARTY_JOB_MEMBER
				break
			end
		end
		PartyMO.myJob = PARTY_JOB_MEMBER
		Notify.notify(LOCAL_PARTY_MEMBER_UPDATE_EVENT)
		Toast.show(CommonText[649])
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ConcedeJob",{lordId = member.lordId}))
end

function PartyBO.asynSetMemberJob(doneCallback,member,job)
	local function parseResult(name, data)
		member.job = data.job
		Notify.notify(LOCAL_PARTY_MEMBER_UPDATE_EVENT)
		Toast.show(CommonText[649])
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SetMemberJob",{lordId = member.lordId,job = job}))
end


function PartyBO.asynSloganParty(doneCallback,type,slogan)
	local function parseResult(name, data)
		PartyMO.partyData_.innerSlogan = slogan
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SloganParty",{type = type,slogan = slogan}))
end

function PartyBO.asynPartyRecruit(doneCallback)
	local function parseResult(name, data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PartyRecruit"))
end

function PartyBO.asynDoPartyTipAward(doneCallback)
	local function parseResult(name, data)
		local awards = PbProtocol.decodeArray(data["award"])
			--加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
			
		UserMO.partyTipAward_ = 2

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoPartyTipAward"))
end

function PartyBO.updateAltarBossData( data )
	PartyMO.altarBoss_ = {}

	PartyMO.altarBoss_.cdTime = data.nextStateTime - ManagerTimer.getTime()
	PartyMO.altarBoss_.rank = data.hurtRank
	PartyMO.altarBoss_.autoFight = data.autoFight
	PartyMO.altarBoss_.bless1 = data.bless1
	PartyMO.altarBoss_.bless2 = data.bless2
	PartyMO.altarBoss_.bless3 = data.bless3
	PartyMO.altarBoss_.hurt = data.hurt
	PartyMO.altarBoss_.which = data.which
	PartyMO.altarBoss_.bossHp = data.bossHp
	PartyMO.altarBoss_.bossLv = data.bossLv
	PartyMO.altarBoss_.fightCdTime = data.fightCdTime - ManagerTimer.getTime()

	if PartyMO.altarBoss_.cdTime < 0 then
		PartyMO.altarBoss_.cdTime = 0
	end

	if PartyMO.altarBoss_.fightCdTime < 0 then
		PartyMO.altarBoss_.fightCdTime = 0
	end

	PartyMO.altarBoss_.state = data.state
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
	dump(data, "=====PartyBO.updateAltarBossData======data")
	-- dump(PartyMO.altarBoss_, "=====PartyBO.updateAltarBossData======PartyMO.altarBoss_")
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")	

	if not PartyBO.tickHandler_ then
		PartyBO.tickHandler_ = ManagerTimer.addTickListener(PartyBO.onTick)
	end	

	PartyMO.altarBossDirty_ = false
end

----获取军团BOSS 当前状态数据
function PartyBO.asynGetPartyAltarBossData( doneCallback )
	local function parseResult( name, data )
		PartyBO.updateAltarBossData(data)
		if doneCallback then doneCallback() end
	end
	PartyMO.altarBossDirty_ = true
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetAltarBossData"))
end

function PartyBO.onTick( dt )
	if PartyMO.altarBossDirty_ then return end

	local canRequire = false
	local state = PartyMO.altarBoss_.state
	----刷定时器
	if PartyMO.altarBoss_.cdTime and PartyMO.altarBoss_.cdTime > 0 then
		PartyMO.altarBoss_.cdTime = PartyMO.altarBoss_.cdTime - dt

		if PartyMO.altarBoss_.cdTime < 0 then
			PartyMO.altarBoss_.cdTime = 0
			if state ~= PARTY_ALTAR_BOSS_STATE_CLOSE then
				canRequire = true
			end
		end
	end	

	----刷定时器
	if PartyMO.altarBoss_.fightCdTime and PartyMO.altarBoss_.fightCdTime > 0 then
		PartyMO.altarBoss_.fightCdTime = PartyMO.altarBoss_.fightCdTime - dt

		if PartyMO.altarBoss_.fightCdTime < 0 then
			PartyMO.altarBoss_.fightCdTime = 0
			canRequire = true
		end
	end	

	if canRequire then
		PartyBO.asynGetPartyAltarBossData()
	end
end

----召唤军团BOSS
function PartyBO.DoCallAltarBoss( doneCallback, needExp )
	local function parseResult( name, data )
		PartyMO.altarBoss_.which = data.which
		PartyMO.altarBoss_.bossHp = data.bossHp
		PartyMO.altarBoss_.state = data.state
		PartyMO.altarBoss_.bossLv = data.bossLv

		PartyMO.altarBoss_.cdTime = data.nextStateTime - ManagerTimer.getTime()

		if PartyMO.altarBoss_.cdTime < 0 then
			PartyMO.altarBoss_.cdTime = 0
		end

		---重新召唤 清零
		PartyMO.altarBoss_.rank = 0
		PartyMO.altarBoss_.hurt = 0


		--建设度减少
		PartyMO.partyData_.build = PartyMO.partyData_.build - needExp
		--建筑等级更新
		PartyMO.altarBossDirty_ = false
		
		Notify.notify(LOCAL_PARTY_BUILD_EVENT)
		-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
		-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
		-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
		-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
		dump(data, "=====PartyBO.DoCallAltarBoss======PartyMO.altarBoss_")
		-- dump(PartyMO.altarBoss_, "=====PartyBO.DoCallAltarBoss======PartyMO.altarBoss_")
		-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
		-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
		-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
		-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")		
		if doneCallback then doneCallback() end
	end
	PartyMO.altarBossDirty_ = true
	SocketWrapper.wrapSend(parseResult, NetRequest.new("CallAltarBoss"))	
end

---能挑战
function PartyBO.canFight()
	return (PartyMO.altarBoss_.state == PARTY_ALTAR_BOSS_STATE_READY or PartyMO.altarBoss_.state == PARTY_ALTAR_BOSS_STATE_FIGHTING ) and PartyMO.altarBoss_.cdTime > 0
end


---能召唤
function PartyBO.canSummon( ... )
	-- body
end

---设置 自动战斗
function PartyBO.asynSetBossAutoFight(doneCallback, isAutoFight)
	local function parseResult( name, data )
		if isAutoFight then
			PartyMO.altarBoss_.autoFight = 1
		else
			PartyMO.altarBoss_.autoFight = 0
		end

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SetAltarBossAutoFight",{autoFight=isAutoFight}))	
end


-- 根据当前的祝福等级blessLv，获得祝福到下一级需要花费的金币数量
local config = {20, 40, 80, 120, 160, 240, 320, 400, 600, 1000}
function PartyBO.getBlessPrice(blessLv)
	return config[blessLv + 1]
end

----购买祝福
function PartyBO.asynBlessBossFight(doneCallback,index)
	local function parseBlessBossFight(name, data)
		dump(data, "=======PartyBO.asynBlessBossFight=======")
		PartyMO.altarBoss_['bless' .. index] = PartyMO.altarBoss_['bless' .. index] + 1
		if doneCallback then doneCallback(data.gold) end
	end
	SocketWrapper.wrapSend(parseBlessBossFight, NetRequest.new("BlessAltarBossFight", {index = index}))
end

----清除挑战CD
function PartyBO.asynBuyBossCd(doneCallback, leftSecond)
	local function parseBuyBossCd(name, data)
		-- PartyMO.altarBoss_.cdTime = 0.99  -- 清除CD时间
		PartyMO.altarBoss_.fightCdTime = 0  -- 清除CD时间
		dump(data, "=====PartyBO.asynBuyBossCd========")
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		-- if leftSecond > ACTIVITY_BOSS_COLD_CD then leftSecond = ACTIVITY_BOSS_COLD_CD end

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseBuyBossCd, NetRequest.new("BuyAltarBossCd"))
end

function PartyBO.asynBossHurtAward(doneCallback)
	local function parseBossHurtAward(name, data)

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)

		PartyMO.altarBoss_.canReceive = false

		if doneCallback then doneCallback(statsAward) end
	end
	SocketWrapper.wrapSend(parseBossHurtAward, NetRequest.new("AltarBossHurtAward"))
end

function PartyBO.getBossStatus()
	return PartyMO.altarBoss_.state, PartyMO.altarBoss_.cdTime
end

function PartyBO.asynGetBossHurtRank(doneCallback)
	local function parseGetBossHurtRank(name, data)
		PartyMO.altarBoss_.hurt = data.hurt
		PartyMO.altarBoss_.rank = data.rank
		PartyMO.altarBoss_.canReceive = data.canGet -- true可以领取; false不可领取

		local rankData = PbProtocol.decodeArray(data.hurtRank)
		-- dump(rankData, "===========PartyBO.asynGetBossHurtRank========rankData")
		-- dump(data, "===========PartyBO.asynGetBossHurtRank========data")
		if doneCallback then doneCallback(rankData) end
	end
	SocketWrapper.wrapSend(parseGetBossHurtRank, NetRequest.new("GetAltarBossHurtRank"))
end

function PartyBO.asynFightBoss(doneCallback)
	local hurt = PartyMO.altarBoss_.hurt
	local function parseFightBoss(name, data)
		-- dump(data, "======PartyBO.asynFightBoss======")
		---: -1失败 1.胜利 2.冷却中
		if data.result == 2 then
			PartyMO.altarBoss_.fightCdTime = data.cdTime - ManagerTimer.getTime()
			-- Toast.show("WARNING: CD TIME")
			if doneCallback then doneCallback(false) end
			return
		end

		if data.result == 1 then  -- BOSS
			PartyMO.altarBoss_.state = PARTY_ALTAR_BOSS_STATE_DIE			
			CombatMO.curBattleStar_ = 3
			PartyMO.altarBoss_.cdTime = data.cdTime - ManagerTimer.getTime()
			if PartyMO.altarBoss_.cdTime < 0 then
				PartyMO.altarBoss_.cdTime = 0
			end			
		elseif data.result == -1 then
			CombatMO.curBattleStar_ = 0
		end

		ActivityCenterMO.bossBalance_.hurtDelta = data.hurt - hurt  -- 此次伤害总值
		ActivityCenterMO.beforeBattleWhich_ = PartyMO.altarBoss_.which -- 保存战斗之前的血条状态信息，用于显示战斗前的BOSS

		PartyMO.altarBoss_.hurt = data.hurt
		PartyMO.altarBoss_.rank = data.rank
		PartyMO.altarBoss_.which = data.which
		PartyMO.altarBoss_.bossHp = data.bossHp
		-- PartyMO.altarBoss_.cdTime = data.coldTime - ManagerTimer.getTime() + 0.99
		PartyMO.altarBoss_.fightCdTime = data.cdTime - ManagerTimer.getTime()


		if PartyMO.altarBoss_.fightCdTime < 0 then
			PartyMO.altarBoss_.fightCdTime = 0
		end

		CombatMO.curBattleAward_ = nil  ---军团BOSS 奖励不显示

		local formation = TankMO.getFormationByType(FORMATION_FOR_ALTAR_BOSS)
		local defFormat = TankMO.getEmptyFormation(TANK_ALTAR_BOSS_CONFIG_ID)
		-- defFormat[TANK_BOSS_POSITION_INDEX].tankId = TANK_ALTAR_BOSS_CONFIG_ID
		defFormat[TANK_BOSS_POSITION_INDEX].count = 1

		-- 解析战斗的数据
		local combatData = CombatBO.parseCombatRecord(data["record"], formation, defFormat)

		CombatMO.curChoseBattleType_ = COMBAT_TYPE_BOSS
		-- 设置先手
		CombatMO.curBattleOffensive_ = combatData.offsensive
		CombatMO.curBattleAtkFormat_ = combatData.atkFormat
		CombatMO.curBattleDefFormat_ = combatData.defFormat
		CombatMO.curBattleFightData_ = combatData
		BattleMO.reset()
		BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
		BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
		BattleMO.setFightData(CombatMO.curBattleFightData_)

		if doneCallback then doneCallback(true) end
	end
	SocketWrapper.wrapSend(parseFightBoss, NetRequest.new("FightAltarBoss"))
end

function PartyBO.getJobNameById(id)
	local jobName = ""
	if id == PARTY_JOB_MEMBER then
		jobName = jobName .. CommonText[639][3]
	elseif id == PARTY_JOB_OFFICAIL then
		jobName = jobName .. CommonText[639][2]
	elseif id == PARTY_JOB_MASTER then
		jobName = jobName .. CommonText[639][1]
	elseif id == PARTY_JOB_CUSTOM_1 then
		jobName = jobName .. PartyMO.partyData_.jobName1
	elseif id == PARTY_JOB_CUSTOM_2 then
		jobName = jobName .. PartyMO.partyData_.jobName2
	elseif id == PARTY_JOB_CUSTOM_3 then
		jobName = jobName .. PartyMO.partyData_.jobName3
	elseif id == PARTY_JOB_CUSTOM_4 then
		jobName = jobName .. PartyMO.partyData_.jobName4
	end
	return jobName
end


function PartyBO.clearAllParty()
	PartyMO.allPartyList_ = {}
end



function PartyBO.getMyParty()
	if PartyMO.partyData_ and PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
		return PartyMO.partyData_
	else 
		return nil
	end
end

function PartyBO.getMyPartyName()
	local party = PartyBO.getMyParty()
	if not party then
		return nil
	else
		return party.partyName
	end
end

function PartyBO.getScienceById(scienceId)
	if PartyMO.scienceData_.scienceData and #PartyMO.scienceData_.scienceData > 0 then
		for index=1,#PartyMO.scienceData_.scienceData do
			local science = PartyMO.scienceData_.scienceData[index]
			if science.scienceId == scienceId then
				return science
			end
		end
	end
	return nil
end


function PartyBO.getPartyJobByMemberNick(nick)
	-- gdump(PartyMO.partyData_, "aaaaaaaaaaaaaaaaa")
	-- gdump(PartyMO.partyData_.partyMember, "???????????????")
	if not table.isexist(PartyMO.partyData_, "partyMember") then return "" end
	
	for index=1,#PartyMO.partyData_.partyMember do
		local member = PartyMO.partyData_.partyMember[index]
		if member.nick == nick then
			return PartyBO.getJobNameById(member.job)
		end
	end
	return ""
end

function PartyBO.scienceCanDonate(science,type)
	if PartyMO.scienceData_.donateData[type] >= PartyMO.queryPartyContributeMaxCount(type) then return false end
	if science.scienceLv >= PartyMO.queryScienceMaxLevel(science.scienceId) then return false end

	local scienceLvData =  PartyMO.queryScienceLevel(science.scienceId, science.scienceLv + 1)

	if science.scienceLv > PartyMO.partyData_.scienceLv then return false end

	if science.scienceLv == PartyMO.partyData_.scienceLv and science.schedule == scienceLvData.schedule then
		return false
	end
	return true
end

function PartyBO.jobAppointed(chat)
	gdump(chat,"PartyBO.jobAppointed")
	if chat.param and chat.param[1] == UserMO.nickName_ then
		if chat.sysId == 127 then
			PartyMO.myJob = PARTY_JOB_MASTER
		elseif chat.sysId == 128 then
			PartyMO.myJob = PARTY_JOB_OFFICAIL
		elseif chat.sysId == 129 and chat.param[2] then
			PartyMO.myJob = tonumber(chat.param[2])
		end

	end
end

function PartyBO.updatePartyTip()
	if UserMO.partyTipAward_ and UserMO.partyTipAward_ == 0 then
		UserMO.partyTipAward_ = 1
	end
end

function PartyBO.isPartyBuildOpen( buildingId )
	if buildingId == PARTY_BUILD_ID_ALTAR then
		return PartyMO.partyData_.partyLv >= 20
	end

	return true
end

function PartyBO.isPartyBuildShowLevel( buildingId )
	local ret = false
	if buildingId == PARTY_BUILD_ID_HALL then
		ret = true
	elseif buildingId == PARTY_BUILD_ID_SCIENCE then
		ret = true
	elseif buildingId == PARTY_BUILD_ID_WEAL then
		ret = true
	elseif buildingId == PARTY_BUILD_ID_ALTAR then
		ret = true
	end
	return ret
end


----入团是否满足7天
function PartyBO.isAchieve7day()
	local ret = false

	if PartyMO.enterTime_ > 0 then
		local now = ManagerTimer.getDate()
		now = now.year * 10000 + now.month * 100 + now.day
		ret = PartyMO.enterTime_ + 6 <= now
	end
	return ret
end


function PartyBO.getAltarBossHpPercent()
	local bossStar = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)
	local starInfo = PartyMO.getStarInfoByStar(bossStar)

	local totol = ACTIVITY_BOSS_TOTAL_LIFE * starInfo.amount-- - PartyMO.altarBoss_.which
	local left = (ACTIVITY_BOSS_TOTAL_LIFE - 1 - PartyMO.altarBoss_.which)*starInfo.amount + PartyMO.altarBoss_.bossHp

	if left > totol then
		left = totol
	end
	return left/totol
end

function PartyBO.getAltarBossLevel()
	if PartyMO.altarBoss_.state == PARTY_ALTAR_BOSS_STATE_DIE then
		if PartyMO.altarBoss_.bossLv < PartyMO.queryPartyAltarBossMaxLevel()then
			return PartyMO.altarBoss_.bossLv + 1
		end

		return PartyMO.queryPartyAltarBossMaxLevel()
	elseif PartyMO.altarBoss_.state == PARTY_ALTAR_BOSS_STATE_OVER then
		local lv = PartyMO.altarBoss_.bossLv - 1
		if lv <= 1 then
			lv = 1
		end

		return lv
	end

	if PartyMO.altarBoss_.state == PARTY_ALTAR_BOSS_STATE_CLOSE and PartyMO.altarBoss_.bossLv == 0 then 
		return 1
	end

	return PartyMO.altarBoss_.bossLv
end

--军团大厅一键捐献
function PartyBO.asynDonateAllParty(doneCallback,resouceList)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		--贡献次数增加
		for resouceId=1,#resouceList do
			PartyMO.hallData_[resouceList[resouceId]] = PartyMO.hallData_[resouceList[resouceId]] + 1
			ActivityBO.trigger(ACTIVITY_ID_PARTY_RECURIT, {type = "hall", id = resouceId})  -- 军团大厅捐献一次
		end

		if table.isexist(data, "isBuild") then 
			PartyMO.partyData_.build = PartyMO.partyData_.build + data.build
		end

		local res = {}
		--资源更新
		if table.isexist(data, "oil") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "iron") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "copper") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end
		if table.isexist(data, "stone") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
		end
		if table.isexist(data, "gold") then 
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[28],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold} 
		end
		UserMO.updateResources(res)

		--个人贡献增加
		PartyMO.myDonate_ = PartyMO.myDonate_ + data.build
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_PARTY_DONOR,type = 1})
		if doneCallback then doneCallback(data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DonateAllPartyRes"))
end

--军团科技一键捐献
function PartyBO.asynDonateAllScience(doneCallback,science,resouceList)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		-- dump(data,"PartyBO.asynDonateScience")
		--科技贡献次数增加
		for resouceId=1,#resouceList do
			PartyMO.scienceData_.donateData[resouceList[resouceId]] = PartyMO.scienceData_.donateData[resouceList[resouceId]] + 1
			ActivityBO.trigger(ACTIVITY_ID_PARTY_RECURIT, {type = "science", id = resouceId})  -- 科技大厅捐献一次
		end

		--科技进度和等级更新
		local newScience = PbProtocol.decodeRecord(data["science"])

		local addSchedule --科技进度是否变化
		if science.schedule == newScience.schedule and science.scienceLv == newScience.scienceLv then
			addSchedule = nil
		else
			addSchedule = true
		end

		science.schedule = newScience.schedule

		local oldLv = science.scienceLv
		science.scienceLv = newScience.scienceLv
		if oldLv ~= science.scienceLv then
			UserBO.triggerFightCheck()
		end

		--我的军团贡献增加
		PartyMO.myDonate_ = PartyMO.myDonate_ + data.build

		--资源更新
		local res = {}
		if table.isexist(data, "oil") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "iron") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "copper") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end
		if table.isexist(data, "stone") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
		end
		if table.isexist(data, "gold") then 
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold} 
		end
		UserMO.updateResources(res)

		Notify.notify(LOCAL_PARTY_SCIENCE_DONE_EVENT)
		Notify.notify(LOCAL_PARTY_MYDONATE_UPDATE_EVENT)

		if doneCallback then doneCallback(addSchedule, data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DonateAllPartyScience",{scienceId = science.scienceId}))
end

function PartyBO.asynGetPartyBoss(doneCallback)
	for index=1,RESOURCE_ID_STONE do
		PartyMO.partyBossData_[index] = 0 --默认为0
	end
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		
		local info = PbProtocol.decodeArray(data["contributeCount"])
		for idx=1,#PartyMO.partyBossData_ do
			if info then
				for k,v in pairs(info) do
					if v.v1 == idx then
						PartyMO.partyBossData_[idx] = v.v2
					end
				end
			end
		end

		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFeedAltarBoss"))
end

function PartyBO.asynDonatePartyBoss(doneCallback,resouceList)
	local function parseResult(name, data)
		Loading.getInstance():unshow()

		local info = PbProtocol.decodeArray(data["contributeCount"])
		for idx=1,#PartyMO.partyBossData_ do
			if info then
				for k,v in pairs(info) do
					if v.v1 == idx then
						PartyMO.partyBossData_[idx] = v.v2
					end
				end
			end
		end

		--个人军团贡献增加
		if table.isexist(data, "contribute") then 
			PartyMO.myDonate_ = PartyMO.myDonate_ + data.contribute
		end

		--军团BOSS星级经验
		if table.isexist(data, "exp") then
			PartyMO.partyData_.altarexp = data.exp
		end

		--资源更新
		local res = {}
		if table.isexist(data, "oil") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "iron") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "copper") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end
		if table.isexist(data, "stone") then 
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[30],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
		end
		UserMO.updateResources(res)
		Notify.notify(LOCAL_PARTY_BOSS_UPDATE)
		if doneCallback then doneCallback(data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFeedAltarContriBute",{type = resouceList}))
end

function PartyBO.SynPartyBossInfo(name, data)
	PartyMO.partyData_.altarexp = data.exp
	Notify.notify(LOCAL_PARTY_BOSS_UPDATE)
end