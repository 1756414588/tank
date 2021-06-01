----能晶

EnergySparBO = {}


function EnergySparBO.update( data )
	EnergySparMO.energySpar_ = {}
	if not data then return end

	local props = PbProtocol.decodeArray(data["prop"])

	for index = 1, #props do
		local prop = props[index]
		
		for index = 1, #props do  -- 
			local prop = props[index]
			EnergySparMO.energySpar_[prop.propId] = {stoneId=prop.propId, count = prop.count}
		end		
	end	
end

-----获取镶嵌列表
function EnergySparBO.getEnergyStoneInlay(doneCallback)
	local function parseUpgrade(name, data)
		EnergySparBO.updateInlayData(data)
		if doneCallback then doneCallback() end
	end

	EnergySparMO.dirtyEnergyData_ = true
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetEnergyStoneInlay"))
end

function EnergySparBO.updateInlayData( data )
	for pos = 1, FIGHT_FORMATION_POS_NUM do
		EnergySparMO.inlayData_[pos] = {}
		for hole = 1, ENERGYSPAR_HOLE_NUM do
			EnergySparMO.inlayData_[pos][hole] = 0
		end
	end

	if data then
		local inlays = PbProtocol.decodeArray(data["inlay"])
		for index = 1, #inlays do
			local inlay = inlays[index]
			EnergySparMO.inlayData_[inlay.pos][inlay.hole] = inlay.stoneId
		end
	end

	EnergySparMO.dirtyEnergyData_ = false
end

-----合成
function EnergySparBO.doEnergyStoneCombine(doneCallback, stoneId, count, times, batch)
	if not batch then
		batch = false
	end

	local function parseUpgrade(name, data)
		local successNum = data.successNum
		local sparDB = EnergySparMO.queryEnergySparById(stoneId)
		local newStoneId = sparDB.synthesizing

		---合成获得 能晶
		UserMO.addResource(ITEM_KIND_ENERGY_SPAR, successNum, newStoneId)

		---合成扣除 能晶
		UserMO.reduceResource(ITEM_KIND_ENERGY_SPAR, count * successNum + (times - successNum), stoneId)

		

		Notify.notify(LOCAL_ENERGYSPAR_EVENT)

		if doneCallback then doneCallback(newStoneId, successNum,  (times - successNum)) end
	end

	local params = {
		stoneId = stoneId,
		count = count,
		batch = batch,
	}
	
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("CombineEnergyStone", params))
end

-----镶嵌
function EnergySparBO.doEnergyStoneInlay(doneCallback, pos, hole, stoneId)
	local function parseUpgrade(name, data)
		if stoneId > 0 then
			----镶嵌
			EnergySparMO.inlayData_[pos][hole] = stoneId
			UserMO.reduceResource(ITEM_KIND_ENERGY_SPAR, 1, stoneId)
		else
			----拆卸
			local unInlayStoneId = EnergySparMO.inlayData_[pos][hole]
			if unInlayStoneId > 0 then
				EnergySparMO.inlayData_[pos][hole] = 0
				UserMO.addResource(ITEM_KIND_ENERGY_SPAR, 1, unInlayStoneId)
			end
		end

		EnergySparMO.dirtyEnergyData_ = false

		UserBO.triggerFightCheck()

		Notify.notify(LOCAL_ENERGYSPAR_EVENT)

		if doneCallback then doneCallback() end
	end
	---如果是镶嵌，传入要镶嵌上去的能晶id，如果是卸下，该值为-1
	local params = {
		pos = pos,
		hole = hole,
		stoneId	= stoneId,
	}

	EnergySparMO.dirtyEnergyData_ = true

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("OnEnergyStone", params))
end

function EnergySparBO.getFormationEnergyAttrData( formatIndex )
	-- local attrValue = {[ATTRIBUTE_INDEX_HP] = {value=0}, 
	-- [ATTRIBUTE_INDEX_ATTACK] = {value=0}, 
	-- [ATTRIBUTE_INDEX_HIT] = {value=0}, 
	-- [ATTRIBUTE_INDEX_DODGE] = {value=0}, 
	-- [ATTRIBUTE_INDEX_CRIT] = {value=0}, 
	-- [ATTRIBUTE_INDEX_CRIT_DEF] = {value=0}}
	local attrValue = {}
	
	local attrs = {}
	local levelCounts = {}
	for index = 1, ENERGYSPAR_HOLE_NUM do
		local stoneId = EnergySparMO.getEnergySparByPos( formatIndex, index )
		if stoneId and stoneId > 0 then
			local sparDB = EnergySparMO.queryEnergySparById(stoneId)
			if not levelCounts[sparDB.level] then
				levelCounts[sparDB.level] = 0
			end

			levelCounts[sparDB.level] = levelCounts[sparDB.level] + 1

			if not attrs[sparDB.attrId] then
				attrs[sparDB.attrId] = 0
			end

			attrs[sparDB.attrId] = attrs[sparDB.attrId] +  sparDB.attrValue
		end
	end

	local hideAttrs = EnergySparMO.getHideAttributes()
	for i,attr in ipairs(hideAttrs) do
		local rule = json.decode(attr.rule)
		local count = 0
		for lv,cn in pairs(levelCounts) do
			if lv >= rule[2] then
				count = count + cn
			end
		end

		if count >= rule[1] then
			local effects = json.decode(attr.effect)
			for i,effect in ipairs(effects) do
				if not attrs[effect[1]] then
					attrs[effect[1]] = 0
				end				
				attrs[effect[1]] = attrs[effect[1]] +  effect[2]
			end
		end
	end	

	for k,v in pairs(attrs) do
		local attrData = AttributeBO.getAttributeData(k, v)
		attrValue[attrData.index] = attrData
	end

	return attrValue	
end

-----一键镶嵌
function EnergySparBO.allInlay(pos,unpos,arry,doneCallback)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		----拆卸
		for k,v in pairs(unpos) do
			EnergySparMO.inlayData_[pos][k] = 0
			UserMO.addResource(ITEM_KIND_ENERGY_SPAR, 1, v)
		end
		for k,v in ipairs(arry) do
			EnergySparMO.inlayData_[pos][v.v1] = v.v2
			UserMO.reduceResource(ITEM_KIND_ENERGY_SPAR, 1, v.v2)
		end
		UserBO.triggerFightCheck()
		Notify.notify(LOCAL_ENERGYSPAR_EVENT)
		doneCallback()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("AllEnergyStone",{pos=pos,holeAndStoneId=arry}))
end