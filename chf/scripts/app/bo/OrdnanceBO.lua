--
-- Author: Xiaohang
-- Date: 2016-05-12 10:35:03
--
OrdnanceBO = {}

--更新科技信息
function OrdnanceBO.update(data)
	OrdnanceBO.science_ = {}
	if not data then return end
	local data = PbProtocol.decodeArray(data["militaryScience"])
	for i=1,#data do
		local t = data[i]
		OrdnanceBO.science_[t.militaryScienceId] = t
	end
end

function OrdnanceBO.queryScienceById(id)
	return OrdnanceBO.science_[id]
end

--可装配的该类科技
function OrdnanceBO.getAdaptTypeScience(tankId)
	local mo = OrdnanceMO.queryTankById(tankId)
	local id = mo.productScienceId
	local list = {}
	for k,v in pairs(OrdnanceBO.science_) do
		local to = OrdnanceMO.queryScienceById(v.militaryScienceId)
		local scope = json.decode(to.scope)
		for m,n in ipairs(scope) do
			if n[1] == tankId and id ~= v.militaryScienceId and to.attrId ~= 28 then
				table.insert(list,v)
				break
			end
		end
	end
	return list
end

--已装配的科技
function OrdnanceBO.getScienceOnTank(tankId)
	local list = {}
	for k,v in pairs(OrdnanceBO.science_) do
		if v.fitTankId == tankId and v.level > 0 then
			list[v.militaryScienceId] = v
		end
	end
	return list
end

function OrdnanceBO.updateGrid(data)
	if not data then return end
	local data = PbProtocol.decodeArray(data["militaryScienceGrid"])
	OrdnanceBO.grid_ = {}
	for i=1,#data do
		local t = data[i]
		if not OrdnanceBO.grid_[t.tankId] then
			OrdnanceBO.grid_[t.tankId] = {}
		end
		OrdnanceBO.grid_[t.tankId][t.pos] = t
	end
end

function OrdnanceBO.getEquipNum(tankId)
	local data = OrdnanceBO.grid_[tankId]
	if not data then return 0 end
	local count = 0
	for k,v in pairs(data) do
		if v.militaryScienceId > 0 then
			count = count + 1
		end
	end
	return count
end

function OrdnanceBO.getGridInfo(tankId,pos)
	if OrdnanceBO.grid_[tankId] then
		return OrdnanceBO.grid_[tankId][pos]
	end
end

function OrdnanceBO.updateProp(callback)
	SocketWrapper.wrapSend(function(name,data)
			if not data then return end
			local data = PbProtocol.decodeArray(data["militaryMaterial"])
			OrdnanceBO.prop = data
			OrdnanceBO.prop_ = {}
			for i=1,#data do
				local t = data[i]
				OrdnanceBO.prop_[t.id] = t
			end
			if callback then callback() end
		end, NetRequest.new("GetMilitaryMaterial"))
end

function OrdnanceBO.getProp()
	return OrdnanceBO.prop
end

function OrdnanceBO.queryPropById(id)
	if OrdnanceBO.prop_ then
		return OrdnanceBO.prop_[id]
	end
end

function OrdnanceBO.addProp(data)
	if not OrdnanceBO.prop_ then
		OrdnanceBO.prop_ = {}
	end
	OrdnanceBO.prop_[data.id] = data
	if OrdnanceBO.prop then
		table.insert(OrdnanceBO.prop, data)
	end
end

function OrdnanceBO.UpMilitaryScience(doneCallback,id)
	local function getResult(name,data)
		OrdnanceBO.science_[data.militaryScienceId].level = data.level
		UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("UpMilitaryScience",{militaryScienceId = id}))
end

function OrdnanceBO.ResetMilitaryScience(doneCallback, type_)
	-- body
	local function getResult(name,data)
		Loading.getInstance():unshow()

		local militarySciences = PbProtocol.decodeArray(data.militaryScience)
		for i = 1, #militarySciences do
			local militaryScience = militarySciences[i]
			OrdnanceBO.science_[militaryScience.militaryScienceId].level = militaryScience.level
		end

		local msGrid = PbProtocol.decodeArray(data.militaryScienceGrid)
		for i=1,#msGrid do
			local t = msGrid[i]
			if not OrdnanceBO.grid_[t.tankId] then
				OrdnanceBO.grid_[t.tankId] = {}
			end
			OrdnanceBO.grid_[t.tankId][t.pos] = t
		end

		local awards = PbProtocol.decodeArray(data.award)
		local statsAward = CombatBO.addAwards(awards)

		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		UiUtil.showAwards(statsAward)

		Notify.notify(LOCAL_MILITARY_SCIENCE_UPDATE, {type=type_})
		if doneCallback then doneCallback() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("ResetMilitaryScience",{type=type_}))
end

function OrdnanceBO.getResetMilitaryScienceCost( type_ )
	-- body
	local allData = OrdnanceMO.getList()
	local data = allData[type_]
	table.sort(data.list,function(a,b)
			return a.tankId < b.tankId
		end)

	local goldCost = 0
	local itemCounts = {}

	for i = 1, #data.list do
		local d = data.list[i]
		local list = OrdnanceMO.getTankAllScience(d.tankId)
		print("d.tankId!!!", d.tankId)
		for j = 1, #list do
			local techId = list[j].id
			if OrdnanceBO.science_[techId] then
				local techLv = OrdnanceBO.science_[techId].level
				if techLv > 0 then
					for lv = 1, techLv do
						local scienceDB = OrdnanceMO.queryScienceById(techId, lv)
						local materials = json.decode(scienceDB['materials'])

						for i = 1, #materials do
							local mat = materials[i]
							local matId = mat[2]
							local matCount = mat[3]
							local itemType = mat[1]
							if itemType == 23 then
								if itemCounts[matId] == nil then
									itemCounts[matId] = matCount
								else
									itemCounts[matId] = itemCounts[matId] + matCount
								end
							end
						end
					end
				end
			end
		end
	end

	for matId, matCount in pairs(itemCounts) do
		local matDB = OrdnanceMO.queryMaterialById(matId)
		if matDB then
			goldCost = goldCost + math.ceil(matDB.valueRatio * matCount * 0.001)
		end
	end

	return goldCost
end

function OrdnanceBO.AdaptScience(doneCallback,sid,tankId,pos)
	local function getResult(name,data)
		local grid = PbProtocol.decodeRecord(data.militaryScienceGrid)
		OrdnanceBO.grid_[grid.tankId][grid.pos] =grid
		for k,v in pairs(PbProtocol.decodeArray(data.militaryScience)) do
			OrdnanceBO.science_[v.militaryScienceId] = v
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("FitMilitaryScience",{militaryScienceId = sid,tankId=tankId,pos=pos}))
end

function OrdnanceBO.MilitaryRefitTank(doneCallback,tankId,count)
	local function getResult(name,data)
		local temp = UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		for k,v in pairs(temp) do
			if v.count > 0 then
				UiUtil.showAwards({awards = {v}})
				break
			end
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("MilitaryRefitTank",{tankId=tankId,count=count}))
end

--解锁
function OrdnanceBO.UnLockMilitaryGrid(doneCallback,tankId)
	local function getResult(name,data)
		local grid = PbProtocol.decodeRecord(data.militaryScienceGrid)
		OrdnanceBO.grid_[grid.tankId][grid.pos] =grid
		UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("UnLockMilitaryGrid",{tankId=tankId}))
end

function OrdnanceBO.getAttrOnTank(tankId,attrData)
	local list = OrdnanceBO.getScienceOnTank(tankId)
	local tankDB = TankMO.queryTankById(tankId)
	local attr = {}
	for m,n in pairs(list) do
		local mo = OrdnanceMO.queryScienceById(n.militaryScienceId,n.level)
		local re = json.decode(mo.effect)
		for k,v in ipairs(re) do
			local value = n.level == 0 and 0 or v[2]
			if not attr[v[1]] then
				attr[v[1]] = value
			else
				attr[v[1]] = attr[v[1]] + value
			end
		end
	end
	if attrData then
		local temp = {}
		for k,v in pairs(attr) do
			local ao = AttributeBO.getAttributeData(k,v)
			temp[ao.index] = ao
			if ao.index == ATTRIBUTE_INDEX_ATTACK then
				temp[ao.index].value = temp[ao.index].value/tankDB.attack
			elseif ao.index == ATTRIBUTE_INDEX_HP then
				temp[ao.index].value = temp[ao.index].value/tankDB.hp
			end
		end
		return temp
	end
	--属性转化成百分比
	for k, v in pairs(attr) do
		attr[k] = AttributeBO.getAttributeData(k,v).value
		if k == ATTRIBUTE_INDEX_ATTACK then
			attr[k] = v/tankDB.attack
		elseif k == ATTRIBUTE_INDEX_HP then
			attr[k] = v/tankDB.hp
		end
	end
	return attr
end

--获取坦克生产改造减少时间
function OrdnanceBO.getProduceReduce(tankId)
	local list = OrdnanceBO.getScienceOnTank(tankId)
	for k,v in pairs(list) do
		local mo = OrdnanceMO.queryScienceById(v.militaryScienceId,v.level)
		local re = json.decode(mo.effect)
		for k,v in ipairs(re) do
			if v[1] == 26 then
				return v[3] or 0
			end
		end
	end
	return 0
end

--获取坦克研发进度
function OrdnanceBO.getProgress(tankId)
	local list = OrdnanceMO.getTankScience(tankId,true)
	local count = 0
	for k,v in pairs(list) do
		local data = OrdnanceBO.queryScienceById(v)
		count = count + data.level
	end
	return count
end