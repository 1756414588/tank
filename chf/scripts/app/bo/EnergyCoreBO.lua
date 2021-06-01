--
-- Author: Gss
-- Date: 2019-04-09 11:33:33
--
-- 能源核心

EnergyCoreBO = {}

function EnergyCoreBO.update(data)
	if not data then return end
	
	local record = PbProtocol.decodeRecord(data.coreInfo)
	EnergyCoreMO.energyCoreData_.lv = record.v1 or 1
	EnergyCoreMO.energyCoreData_.section = record.v2 or 1
	EnergyCoreMO.energyCoreData_.exp = record.v3 or 0
	EnergyCoreMO.energyCoreData_.redExp = data.redExp or 0

	if table.isexist(data, "state") then
		EnergyCoreMO.energyCoreData_.state = data.state --最大等级边界
	end
	EnergyCoreBO.initPosAttr()
end

--熔炼
-- isEquip用来做判断，是否是消耗装备或者装卡
function EnergyCoreBO.meltingEngergyCore(doneCallback,param,isEquip)
	local param = param
	local function getResult(name, data)
		Loading.getInstance():unshow()

		if isEquip then
			for index = 1, #param do -- 删除被吞掉的装备
				EquipMO.removeEquipByKeyId(param[index].v2)
			end
		end

		if table.isexist(data, "atom") and #data.atom > 0 then
			UserMO.updateResources(PbProtocol.decodeArray(data.atom))
		end

		if table.isexist(data, "state") then
			EnergyCoreMO.energyCoreData_.state = data.state
		end

		local record = PbProtocol.decodeRecord(data.coreInfo)
		EnergyCoreMO.energyCoreData_.lv = record.v1 or 1
		EnergyCoreMO.energyCoreData_.section = record.v2 or 0
		EnergyCoreMO.energyCoreData_.exp = record.v3 or 0
		EnergyCoreMO.energyCoreData_.redExp = data.redExp or 0
		
		EnergyCoreBO.initPosAttr()
			
		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("SmeltCoreEquip",{equip = param}))
end

--初始化6个位置的属性
function EnergyCoreBO.initPosAttr()
	EnergyCoreBO.energyCorePosAttrs = EnergyCoreMO.getEnergyCoreAttrByPos()
end