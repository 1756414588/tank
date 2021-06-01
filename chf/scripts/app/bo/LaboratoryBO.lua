--
--
--

LaboratoryBO = {}

-- 属性特效
function LaboratoryBO.getLaboratoryAttr(tankType)
	local _tankType = tankType or 0

	if LaboratoryMO.AttrType[_tankType] then
		return LaboratoryMO.AttrType[_tankType]
	end

	local attrAllDatas = {}
	local attDatas = LaboratoryMO.getLaboratoryForAttr(_tankType)
	if attDatas then table.merge(attrAllDatas, attDatas) end

	if _tankType ~= 0 then
		local commonDatas = LaboratoryMO.getLaboratoryForAttr(0)
		table.merge(attrAllDatas, commonDatas)
	end


	-- print("LaboratoryBO.getLaboratoryAttr +++++++++++++++++++++++++++++++++")
	local attrs = {}
	for k, v in pairs(attrAllDatas) do
		-- k = skillId
		-- v = lv[] list
 		local type = v.type
		local _data = LaboratoryMO.militarySkillData[k]
		if _data then 
			local lv = _data.lv
			local _attData = v[lv]
			if _attData then
				-- print("skillId!!", v[lv].skillId, lv, _attData.value, _attData.attrid)
				local attr = {}
				attr.id = _attData.attrid
				attr.value = _attData.value
				attr.type = _attData.type
				attrs[#attrs + 1] = attr
			end
		end
	end
	LaboratoryMO.AttrType[_tankType] = attrs
	-- print("LaboratoryBO.getLaboratoryAttr -------------------------------------")
	return attrs
end

-- LaboratoryMO.AttrType
-- 载重
function LaboratoryBO.getPayloadTypeAttr(tankType)
	if not UserMO.queryFuncOpen(UFP_LABORATORY) then return 0 end
	if LaboratoryMO.AttrTypePayload[tankType] then return LaboratoryMO.AttrTypePayload[tankType] end
	local attrs = LaboratoryBO.getLaboratoryAttr(tankType)
	local models = {[ATTRIBUTE_INDEX_PAYLOAD0] = 0, [ATTRIBUTE_INDEX_PAYLOAD1] = 0, [ATTRIBUTE_INDEX_PAYLOAD2] = 0, [ATTRIBUTE_INDEX_PAYLOAD3] = 0, [ATTRIBUTE_INDEX_PAYLOAD4] = 0}
	local attrValue = 0
	for index = 1 , #attrs do
		local attr = attrs[index]
		if models[attr.id] then
			models[attr.id] = models[attr.id] + attr.value
		end
	end
	for k , v in pairs(models) do
		attrValue = attrValue + v
	end
	LaboratoryMO.AttrTypePayload[tankType] = attrValue
	return attrValue
end


-- 生产属性
function LaboratoryBO.getProductTypeAttr(tankType)
	if not UserMO.queryFuncOpen(UFP_LABORATORY) then return 0 end
	if LaboratoryMO.AttrTypeProduct[tankType] then return LaboratoryMO.AttrTypeProduct[tankType] end
	local attrs = LaboratoryBO.getLaboratoryAttr(tankType)
	local models = {[ATTRIBUTE_INDEX_PRODUCT0] = 0, [ATTRIBUTE_INDEX_PRODUCT1] = 0, [ATTRIBUTE_INDEX_PRODUCT2] = 0, [ATTRIBUTE_INDEX_PRODUCT3] = 0, [ATTRIBUTE_INDEX_PRODUCT4] = 0}
	local attrValue = 0
	for index = 1 , #attrs do
		local attr = attrs[index]
		if models[attr.id] then
			models[attr.id] = models[attr.id] + attr.value
		end
	end
	for k , v in pairs(models) do
		attrValue = attrValue + v
	end
	LaboratoryMO.AttrTypeProduct[tankType] = attrValue
	return attrValue
end

-- 改造属性
function LaboratoryBO.getRefitTypeAttr(tankType)
	if not UserMO.queryFuncOpen(UFP_LABORATORY) then return 0 end
	if LaboratoryMO.AttrTypeRefit[tankType] then return LaboratoryMO.AttrTypeRefit[tankType] end
	local attrs = LaboratoryBO.getLaboratoryAttr(tankType)
	local models = {[ATTRIBUTE_INDEX_REFIT0] = 0, [ATTRIBUTE_INDEX_REFIT1] = 0, [ATTRIBUTE_INDEX_REFIT2] = 0, [ATTRIBUTE_INDEX_REFIT3] = 0, [ATTRIBUTE_INDEX_REFIT4] = 0}
	local attrValue = 0
	for index = 1 , #attrs do
		local attr = attrs[index]
		if models[attr.id] then
			models[attr.id] = models[attr.id] + attr.value
		end
	end
	for k , v in pairs(models) do
		attrValue = attrValue + v
	end
	LaboratoryMO.AttrTypeRefit[tankType] = attrValue
	return attrValue
end

-- 带兵量
function LaboratoryBO.getCommonTypeAttrSoldier()
	if not UserMO.queryFuncOpen(UFP_LABORATORY) then return 0 end
	local attrs = LaboratoryBO.getLaboratoryAttr(0)
	local attrValue = 0
	for index = 1 , #attrs do
		local attr = attrs[index]
		if ATTRIBUTE_INDEX_SOLDIER == attr.id then
			attrValue = attrValue + attr.value
		end
	end
	-- LaboratoryMO.AttrTypeCommonSoldier = attrValue
	return attrValue
end

-- 行军速度
function LaboratoryBO.getCommonTypeAttrSpeed()
	if not UserMO.queryFuncOpen(UFP_LABORATORY) then return 0 end
	local attrs = LaboratoryBO.getLaboratoryAttr(0)
	local attrValue = 0
	for index = 1 , #attrs do
		local attr = attrs[index]
		if ATTRIBUTE_INDEX_SPEED == attr.id then
			attrValue = attrValue + attr.value
		end
	end
	return attrValue
end

-- 通用属性
-- isAttr 是否显示为标准属性数据
function LaboratoryBO.getLaboratoryCommonAttr(tankType, isAttr)
	local _isAttr = isAttr or false
	if not UserMO.queryFuncOpen(UFP_LABORATORY) then return {} end
	local attrs = LaboratoryBO.getLaboratoryAttr(tankType)
	local out = {}
	for index = 1, #attrs do
		local attr = attrs[index]
		if attr.type == tankType then
			out[#out + 1] = attr
		end
	end
	-- gdump(out, "LaboratoryBO.getLaboratoryCommonAttr out==")
	if not _isAttr then
		return out
	else
		local outAttr = {}
		for index = 1, #out do
			local attr = out[index]
			if attr.id < 1000 then -- 1000 一下为正常通用属性
				local att = AttributeBO.getAttributeData(attr.id, attr.value)
				outAttr[#outAttr + 1] = att
			end
		end
		-- gdump(outAttr, "outAttr==")
		return outAttr
	end
end






-- 作战实验室获取人员信息 科技信息 建筑信息
function LaboratoryBO.updataFightLabInfo(data)
	-- 人员空闲人数
	LaboratoryMO.academeData.freeCount = data.freeCount 

	-- 各种类型分配人数
	LaboratoryMO.academeData.presonData = {}
	local _presonCount =  PbProtocol.decodeArray(data["presonCount"])
	for index = 1 , #_presonCount do
		local persion = _presonCount[index]
		local out = {}
		out.id = persion["v1"]
		out.count = persion["v2"]
		out.max = persion["v3"]
		LaboratoryMO.academeData.presonData[out.id] = out
	end
	-- dump(LaboratoryMO.academeData.presonData,"presonData == 各种类型分配人数")

	-- 科技id 科技等级
	LaboratoryMO.academeData.techData = {}
	local _techInfo =  PbProtocol.decodeArray(data["techInfo"])
	for index = 1 , #_techInfo do
		local tech = _techInfo[index]
		local out = {}
		out.id = tech["v1"]
		out.lv = tech["v2"]
		LaboratoryMO.academeData.techData[out.id] = out
	end
	-- dump(LaboratoryMO.academeData.techData,"techData == 科技id 科技等级")

	-- 建筑id state 是否激活 1激活
	LaboratoryMO.academeData.archData = {}
	local _archInfo =  PbProtocol.decodeArray(data["archInfo"])
	for index = 1, #_archInfo do
		local arch = _archInfo[index]
		LaboratoryMO.academeData.archData[ arch["v1"] ] = arch["v2"]
	end
	-- dump(LaboratoryMO.academeData.archData,"archData == 建筑id state 是否激活 1激活")
end

-- -- 作战实验室获取人员信息 科技信息 建筑信息
function LaboratoryBO.GetFightLabInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		LaboratoryBO.updataFightLabInfo(data)
		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFightLabInfo"))
end





-- 作战实验室获取物品信息 和 产出的资源信息
function LaboratoryBO.updateFightLabItemInfo(data)
	-- repeated TwoInt item=1;//key itemId,value count
   -- repeated ThreeInt resource=2;//resourceId state 1生产 time已经生产的时间 

		LaboratoryMO.dataList = {}
		local itemlist = PbProtocol.decodeArray(data["item"])
		for index = 1 , #itemlist do
			local item = itemlist[index]
			local out = {}
			out.id = item["v1"]
			out.count = item["v2"]
			LaboratoryMO.dataList[out.id] = out
		end
		-- dump(LaboratoryMO.dataList,"LaboratoryMO.dataList")
		
		LaboratoryMO.resProduct = {}
		local reslist = PbProtocol.decodeArray(data["resource"])
		for index = 1 , #reslist do
			local item = reslist[index]
			local out = {}
			out.id = item["v1"]
			out.state = item["v2"]
			out.time = item["v3"]
			LaboratoryMO.resProduct[out.id] = out
		end
		-- dump(LaboratoryMO.resProduct,"LaboratoryMO.resProduct")	
end


-- 作战实验室获取物品信息 和 产出的资源信息
function LaboratoryBO.GetFightLabItemInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
  		LaboratoryBO.updateFightLabItemInfo(data)

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFightLabItemInfo"))
end




-- 作战实验室设置人员信
function LaboratoryBO.SetFightLabPersonCount(rhand, presonCount)
	-- repeated TwoInt presonCount=1;//type count 各种类型分配人数
	local function parseResult(name,data)
		Loading.getInstance():unshow()
	-- 	required int32 freeCount = 1;//空闲人数
	-- repeated ThreeInt presonCount = 2;//ttype count maxcount 各种类型分配人数
	-- repeated ThreeInt resource=3;//resourceId state 1生产 time已经生产的时间 

		-- 空闲人数
		LaboratoryMO.academeData.freeCount = data.freeCount 

		-- 各种类型分配人数
		LaboratoryMO.academeData.presonData = {}
		local _presonCount =  PbProtocol.decodeArray(data["presonCount"])
		for index = 1 , #_presonCount do
			local persion = _presonCount[index]
			local out = {}
			out.id = persion["v1"]
			out.count = persion["v2"]
			out.max = persion["v3"]
			LaboratoryMO.academeData.presonData[out.id] = out
		end
		-- dump(LaboratoryMO.academeData.presonData,"presonData == 各种类型分配人数")

		-- 生产
		local reslist = PbProtocol.decodeArray(data["resource"])
		for index = 1 , #reslist do
			local item = reslist[index]
			local out = {}
			out.id = item["v1"]
			out.state = item["v2"]
			out.time = item["v3"]
			LaboratoryMO.resProduct[out.id] = out
		end
		-- dump(LaboratoryMO.resProduct,"LaboratoryMO.resProduct")	

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SetFightLabPersonCount",{presonCount = presonCount}))
end


-- 作战实验室 科技升级
function LaboratoryBO.UpFightLabTechUpLevel(rhand, techId)
	-- required int32 techId = 1;//科技id
	local function parseResult(name,data)
		Loading.getInstance():unshow()
	-- 	required int32 techId = 1;//科技id
	-- required int32 level = 2;//科技level
	-- required int32 freeCount = 3;//
	-- repeated ThreeInt itemInfo=4;//type itemId count  物品同步
		-- 同步科技
		local out = {}
		out.id = data.techId
		out.lv = data.level
		LaboratoryMO.academeData.techData[out.id] = out
		-- dump(LaboratoryMO.academeData.techData,"UpFightLabTechUpLevel techData")

		-- 同步空闲人数
		LaboratoryMO.academeData.freeCount = data.freeCount 

		-- 同步道具
		local itemlist =  PbProtocol.decodeArray(data["itemInfo"])
		local outs = {}
		for index = 1, #itemlist do
			local item = itemlist[index]
			local out = {}
			out.kind = item["v1"]
			out.id = item["v2"]
			out.count = item["v3"]
			outs[#outs + 1] = out
		end
		UserMO.updateResources(outs)

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpFightLabTechUpLevel",{techId = techId}))
end


-- 作战实验室 建筑激活
function LaboratoryBO.ActFightLabArchAct(rhand, ActId)
	-- required int32 ActId = 1;//建筑id
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- 刷新 人员 科技 建筑
		-- required TwoInt archInfo=1;//id state 建筑id state 是否激活 1激活
		-- optional TwoInt techInfo=2;//id level 科技id 科技等级
		-- repeated ThreeInt itemInfo=3;//type itemId count  物品同步
		-- repeated ThreeInt presonCount=4;//type count maxcount 各种类型分配人数
		-- repeated ThreeInt resource=5;//resourceId state 1生产 time已经生产的时间 

		-- 建筑
		local archInfo =  PbProtocol.decodeRecord(data["archInfo"])
		LaboratoryMO.academeData.archData[ archInfo["v1"] ] = archInfo["v2"]
		-- dump(LaboratoryMO.academeData.archData , "ActFightLabArchAct archData")

		-- 科技
		if table.isexist(data, "techInfo") then
			local techInfo =  PbProtocol.decodeRecord(data["techInfo"])
			local out ={}
			out.id = techInfo["v1"]
			out.lv = techInfo["v2"]
			LaboratoryMO.academeData.techData[ out.id ] = out
			-- dump(LaboratoryMO.academeData.techData,"       ActFightLabArchAct LaboratoryMO.academeData.techData       ")
		end

		-- 物品同步
		local itemlist =  PbProtocol.decodeArray(data["itemInfo"])
		local outs = {}
		for index = 1, #itemlist do
			local item = itemlist[index]
			local out = {}
			out.kind = item["v1"]
			out.id = item["v2"]
			out.count = item["v3"]
			outs[#outs + 1] = out
		end
		UserMO.updateResources(outs)

		-- 各种类型分配人数
		local _presonCount =  PbProtocol.decodeArray(data["presonCount"])
		for index = 1 , #_presonCount do
			local persion = _presonCount[index]
			local out = {}
			out.id = persion["v1"]
			out.count = persion["v2"]
			out.max = persion["v3"]
			LaboratoryMO.academeData.presonData[out.id] = out
		end
		-- dump(LaboratoryMO.academeData.presonData,"presonData == 各种类型分配人数")

		-- 生产
		local reslist = PbProtocol.decodeArray(data["resource"])
		for index = 1 , #reslist do
			local item = reslist[index]
			local out = {}
			out.id = item["v1"]
			out.state = item["v2"]
			out.time = item["v3"]
			LaboratoryMO.resProduct[out.id] = out
		end
		-- dump(LaboratoryMO.resProduct,"LaboratoryMO.resProduct")	

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ActFightLabArchAct", {ActId = ActId}))
end


-- 作战实验室 领取生产的资源
function LaboratoryBO.GetFightLabResource(rhand, resourceId)
	-- required int32 resourceId = 1;//资源id
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- repeated ThreeInt resource=1;//resourceId state 1生产 time已经生产的时间 
		-- repeated ThreeInt itemInfo=2;//type itemId count  物品同步

		-- 物品同步
		local itemlist =  PbProtocol.decodeArray(data["itemInfo"])
		local outs = {}
		local shows = {}
		for index = 1, #itemlist do
			local item = itemlist[index]
			local out = {}
			out.kind = item["v1"]
			out.id = item["v2"]
			out.count = item["v3"]
			outs[#outs + 1] = out
			if out.id == LABORATORY_ITEM1_ID or 
				out.id == LABORATORY_ITEM2_ID or 
				out.id == LABORATORY_ITEM3_ID or 
				out.id == LABORATORY_ITEM4_ID then
				local curCount = UserMO.getResource(out.kind, out.id)
				local changeCount = out.count - curCount
				local show = {}
				show.kind = out.kind
				show.id = out.id
				show.count = changeCount
				shows[#shows + 1] = show
			end
		end
		UserMO.updateResources(outs)

		-- 生产
		local reslist = PbProtocol.decodeArray(data["resource"])
		for index = 1 , #reslist do
			local item = reslist[index]
			local out = {}
			out.id = item["v1"]
			out.state = item["v2"]
			out.time = item["v3"]
			LaboratoryMO.resProduct[out.id] = out
		end
		-- dump(LaboratoryMO.resProduct,"LaboratoryMO.resProduct")	
	
		rhand(shows)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFightLabResource", {resourceId = resourceId}))
end


























-- 作战实验室 获取深度研究所信息
function LaboratoryBO.GetFightLabGraduateInfo(data)
	-- body
	-- repeated ThreeInt info	= 1;//type类型 skillId  level
	-- required int32 rewardId	= 2; //已经领取的奖励
	LaboratoryMO.progressID = data.rewardId + 1 -- 已经领取的奖励

	-- LaboratoryMO.militaryData = {}
	LaboratoryMO.militarySkillData = {}
	local infolist = PbProtocol.decodeArray(data["info"])
	for index = 1 , #infolist do
		local info = infolist[index]
		local out = {}
		out.type = info["v1"]
		out.skillId = info["v2"]
		out.lv = info["v3"]
		-- if not LaboratoryMO.militaryData[out.type] then
		-- 	LaboratoryMO.militaryData[out.type] = {}
		-- end
		-- LaboratoryMO.militaryData[out.type][out.skillId] = out
		LaboratoryMO.militarySkillData[out.skillId] = out

		LaboratoryMO.AttrType = {}
		LaboratoryMO.AttrTypeProduct = {}
		LaboratoryMO.AttrTypePayload = {}
		LaboratoryMO.AttrTypeRefit = {}
		-- LaboratoryMO.AttrTypeCommonSpeed = {}
		-- LaboratoryMO.AttrTypeCommonSoldier = {}
	end
	-- dump(LaboratoryMO.militaryData,"LaboratoryMO.militaryData")
end


-- 作战实验室 深度研究所 升级
function LaboratoryBO.UpFightLabGraduateUp(rhand, _type, _skillId)
	-- required int32 type = 1;//类型
	-- required int32 skillId = 2;//id
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- body
		-- required int32 type = 1;//类型
		-- required int32 skillId = 2;//id
		-- required int32 level = 3;//level
		-- repeated ThreeInt dearItemInfo	= 4;//消耗的物品信息
		local out = {}
		out.type = data.type
		out.skillId = data.skillId
		out.lv = data.level
		-- LaboratoryMO.militaryData[out.type][out.skillId] = out
		LaboratoryMO.militarySkillData[out.skillId] = out

		LaboratoryMO.AttrType = {}
		LaboratoryMO.AttrTypeProduct = {}
		LaboratoryMO.AttrTypePayload = {}
		LaboratoryMO.AttrTypeRefit = {}
		-- LaboratoryMO.AttrTypeCommonSpeed = {}
		-- LaboratoryMO.AttrTypeCommonSoldier = {}

		local ItemInfo = PbProtocol.decodeArray(data["dearItemInfo"])
		local updates = {}
		for index = 1 , #ItemInfo do
			local item = ItemInfo[index]
			local updataItem = {}
			updataItem.kind = item["v1"]
			updataItem.id = item["v2"]
			updataItem.count = item["v3"]
			updates[#updates + 1] = updataItem
		end
		UserMO.updateResources(updates)

		rhand(data)

		-- 刷新战斗力
		UserBO.triggerFightCheck()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpFightLabGraduateUp",{type = _type, skillId = _skillId}))
end

function LaboratoryBO.ResetFightLabGraduateUp(_type, rhand)
	-- body
	local function parseResult(name,data)
		Loading.getInstance():unshow()

		local infolist = PbProtocol.decodeArray(data["info"])
		for index = 1 , #infolist do
			local info = infolist[index]
			local out = {}
			out.type = info["v1"]
			out.skillId = info["v2"]
			out.lv = info["v3"]

			LaboratoryMO.militarySkillData[out.skillId] = out
		end

		LaboratoryMO.AttrType = {}
		LaboratoryMO.AttrTypeProduct = {}
		LaboratoryMO.AttrTypePayload = {}
		LaboratoryMO.AttrTypeRefit = {}

		local ItemInfo = PbProtocol.decodeArray(data["itemInfo"])
		local updates = {}
		for index = 1 , #ItemInfo do
			local item = ItemInfo[index]
			local updataItem = {}
			updataItem.kind = item["v1"]
			updataItem.id = item["v2"]
			updataItem.count = item["v3"]
			updates[#updates + 1] = updataItem
		end

		local temp = UserMO.updateResources(updates)
		local awards = {awards={}}
		for k, v in pairs(temp) do
			if v.count > 0 then
				table.insert(awards.awards, v)
			end
		end
		UiUtil.showAwards(awards)

		if table.isexist(data, 'gold') then
			-- 更新金币
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		end

		Notify.notify("LOCAL_LABORATORY_SCIENCE_EVENT")
		Notify.notify(LOCAL_RESET_ALL_EVENT_SCIENCE_DEPLOYMENT, {type=_type})

		rhand(data)

		-- 刷新战斗力
		UserBO.triggerFightCheck()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ResetFightLabGraduateUp",{type=_type, }))
end


function LaboratoryBO.getResetFightLabGraduateUpCost(_type)
	-- body
	local goldCost = 0
	local costByItemId = {}
	for k, v in pairs(LaboratoryMO.militarySkillData) do
		if v.type == _type and v.lv > 0 then
			local mili = LaboratoryMO.queryLaboratoryForMilitarye(v.type, v.skillId)
			-- 所有等级的消耗都要加起来
			for l = 1, v.lv do
				local cost = json.decode(mili[l].cost)
				for i = 1, #cost do
					local c = cost[i]
					local itemId = c[2]
					local itemCount = c[3]
					-- 
					if costByItemId[itemId] == nil then
						costByItemId[itemId] = itemCount
					else
						costByItemId[itemId] = costByItemId[itemId] + itemCount
					end
				end
			end
		end
	end

	for k1, v1 in pairs(costByItemId) do
		local laboItemDB = LaboratoryMO.queryLaboratoryForItemById(k1)
		goldCost = goldCost + math.ceil(v1 * laboItemDB.revertPrice * 0.000001)
	end
	return goldCost
end


-- 作战实验室 获取领取奖励信息
function LaboratoryBO.GetFightLabGraduateReward(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- body
		-- required int32 rewardId	= 1;
		-- repeated Award award = 2;
		LaboratoryMO.progressID = data.rewardId + 1

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)
		UiUtil.showAwards(statsAward)

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFightLabGraduateReward"))
end



--------------------------- 潜伏间谍 --------------------------

-- 获取潜伏间谍信息
function LaboratoryBO.GetFightLabSpyInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- body
		-- repeated SpyInfo spyinfo = 1;

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFightLabSpyInfo"))
end


-- 间谍地图激活
function LaboratoryBO.ActFightLabSpyArea(rhand, areaId)
	-- required int32 areaId =1;//区域id
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- body
		-- optional SpyInfo spyinfo = 1;
		-- optional int32 gold = 2;

		-- 更新金币
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ActFightLabSpyArea",{areaId = areaId}))
end


-- 间谍任务刷新
function LaboratoryBO.RefFightLabSpyTask(rhand, areaId)
	-- required int32 areaId =1;//区域id
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- body
		-- optional int32 taskId=1;//任务id 
		-- optional int32 gold = 2;

		-- 更新金币
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("RefFightLabSpyTask",{areaId = areaId}))
end


-- 间谍任务派遣
function LaboratoryBO.ActFightLabSpyTask(rhand, areaId, spyId)
	-- required int32 areaId =1;//区域id
	-- required int32 spyId =2;//间谍id
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- body
		-- optional SpyInfo spyinfo = 1;
		-- optional int32 gold = 2;

		-- 更新金币
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ActFightLabSpyTask",{areaId = areaId, spyId = spyId}))
end

-- 间谍任务领取奖励
function LaboratoryBO.GctFightLabSpyTaskReward(rhand, areaId)
	-- required int32 areaId =1;//区域id
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- body
		-- optional SpyInfo spyinfo = 1;
		-- repeated Award award = 2;
		-- required int32 awardLevel =3;//奖励等级 0成功 1大成功
		
		local out = {}
		local awards = PbProtocol.decodeArray(data["award"])
		out.awards = awards
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		out.ret = ret
		out.awardLevel = data.awardLevel
		-- UiUtil.showAwards(ret, true)

		rhand(out)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GctFightLabSpyTaskReward",{areaId = areaId}))
end

-- 一键领奖
function LaboratoryBO.getAllTaskReward(callBack)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		
		local out = {}
		local put = {}
		local spyAward = PbProtocol.decodeArray(data["taskAward"])
		for index=1,#spyAward do
			local award = spyAward[index]
			local awards = PbProtocol.decodeArray(award["award"])
			out[#out + 1] = awards
			put[#put + 1] = award
		end

		local rewards = {}
		for idx=1,#out do
			for num=1,#out[idx] do
				rewards[#rewards + 1] = out[idx][num]
			end
		end

		local ret = CombatBO.addAwards(rewards)
		UiUtil.showAwards(ret)

		if callBack then callBack(put) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetAllSpyTaskReward"))
end