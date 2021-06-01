
-- 战争武器
-- 阵前buff系统

WarWeaponBO = {}

-- 
WarWeaponBO.weaponDataList = {}
WarWeaponBO.weaponPosSkillAttrs = {}

function WarWeaponBO.updata(data)
	-- repeated SecretWeapon  weapon = 1;       //秘密武器列表
	WarWeaponBO.weaponDataList = {}
 	local dataList = PbProtocol.decodeArray(data["weapon"])
 	for index = 1 , #dataList do
 		local weapon = {}
 		local _dbs = dataList[index]
 		weapon.id = _dbs.id
 		weapon.skills = PbProtocol.decodeArray(_dbs.bar)
 		WarWeaponBO.weaponDataList[#WarWeaponBO.weaponDataList + 1] = weapon
 	end

 	local function sort(a,b)
 		return a.id < b.id
 	end
 	table.sort(WarWeaponBO.weaponDataList,sort)

 	WarWeaponBO.checkInAllAttr()
end 

-- 获取秘密武器信息
function WarWeaponBO.GetSecretWeaponInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		WarWeaponBO.updata(data)
		if rhand then rhand() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetSecretWeaponInfo"))
end


-- 判断是否有技能
function WarWeaponBO.isHaveSkill()
	if #WarWeaponBO.weaponDataList > 0 then
		local skill = WarWeaponBO.weaponDataList[1].skills
		if skill and #skill > 0 then
			return true
		end
	end
	return false
end




-- 解锁秘密武器技能
function WarWeaponBO.UnlockWeaponBar(rhand,weaponId)
	-- required int32 weaponId = 1;            //秘密武器ID
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- optional SecretWeapon weapon = 1;       //注意解锁最后一条技能将会激活新的武器，此时需要重新请求5151协议
    	if table.isexist(data,"gold") then
    		UserMO.updateResource(ITEM_KIND_COIN, data.gold,0)
    	end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UnlockWeaponBar",{weaponId = weaponId}))
end





-- 秘密武器加/解锁定
function WarWeaponBO.LockedWeaponBar(rhand, weaponId, barIdx, lock)
	-- required int32 weaponId = 1;			//秘密武器ID
	-- required int32 barIdx	= 2;			//锁定的技能蓝位置, 下标从0开始
	-- required bool lock		= 3;			//true-锁定,false-解除锁定
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- optional SecretWeapon weapon = 1;

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("LockedWeaponBar",{weaponId = weaponId, barIdx = barIdx, lock = lock}))
end





-- 洗练秘密武器技能
function WarWeaponBO.StudyWeaponSkill(rhand, weaponId, weaponindex)
	-- required int32 weaponId	= 1;			//武器ID
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- optional Atom2 atom2 = 1;				//洗练道具剩余数量
  --   optional SecretWeapon weapon = 2;       //秘密武器信息
  		if table.isexist(data, "atom2") then
  			local propInfo = PbProtocol.decodeRecord(data["atom2"])
  			dump(propInfo,"StudyWeaponSkill      atom2")
  			UserMO.updateResource(propInfo.kind, propInfo.count, propInfo.id)
  		end

  		if table.isexist(data,"gold") then
    		UserMO.updateResource(ITEM_KIND_COIN, data.gold,0)
    	end

  		local _dbs = PbProtocol.decodeRecord(data["weapon"])
		local weapon = {}
		weapon.id = _dbs.id
		weapon.skills = PbProtocol.decodeArray(_dbs.bar)
		WarWeaponBO.weaponDataList[weaponindex] = weapon

		WarWeaponBO.checkInAllAttr()

		UserBO.triggerFightCheck()

		rhand(data)
		if ActivityMO.getActivityById(ACTIVITY_ID_SECRET_WEAPON) then --如果秘密行动开启了。
			function parseActivityContent(name, data)
				local activity = ActivityMO.getActivityById(ACTIVITY_ID_SECRET_WEAPON)
				if activity then
					if table.isexist(activity, "tips") then activity.tips = 0 end -- tips交给客户端维护
				end
				if not ActivityMO.activityContents_[ACTIVITY_ID_SECRET_WEAPON] then ActivityMO.activityContents_[ACTIVITY_ID_SECRET_WEAPON] = {} end
				ActivityMO.activityContents_[ACTIVITY_ID_SECRET_WEAPON].conditions = {}
				local contents = PbProtocol.decodeArray(data["cond"])
				local cnt = data.cnt
				ActivityMO.activityContents_[ACTIVITY_ID_SECRET_WEAPON].cnt = cnt

				for index = 1, #contents do
					local content = contents[index]

					local param = nil
					if table.isexist(content, "param") then param = content["param"] end

					local awards = PbProtocol.decodeArray(content["award"])
					for index = 1, #awards do
						awards[index].kind = awards[index].type
					end

					ActivityMO.activityContents_[ACTIVITY_ID_SECRET_WEAPON].conditions[index] = {keyId = content.keyId, cond = content.cond, status = content.status, param = param, award = awards}
					Notify.notify(LOCLA_ACTIVITY_EVENT)
				end
			end
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActScrtWpnStdCnt"))
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("StudyWeaponSkill",{weaponId = weaponId}))
end


-- 检查 秘密武器的战力属性
function WarWeaponBO.checkInAllAttr()
	WarWeaponBO.weaponPosSkillAttrs = {}
	for pos = 1 , 6 do
		local attrs = {}
		for index = 1 , #WarWeaponBO.weaponDataList do
			local weapon = WarWeaponBO.weaponDataList[index]
			for windex = 1 , #weapon.skills do
				local skill = weapon.skills[windex]
				local info = WarWeaponMO.queryWeaponSkillByPosID(pos,skill.sid)
				if info then
					local attr = json.decode(info.attr)
					local attrid = attr[1]
					local attrvalue = attr[2]
					local att = AttributeBO.getAttributeData(attrid, attrvalue)
					attrs[#attrs + 1] = att
				end
			end
		end
		WarWeaponBO.weaponPosSkillAttrs[pos] = attrs
	end
end


-- 获取军备的全部属性
function WarWeaponBO.getEquipAttr(pos)
	local attrs = {}
	if not (UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ >= UserMO.querySystemId(48)) then return attrs end
	attrs = WarWeaponBO.weaponPosSkillAttrs[pos] or {}
	return attrs 
end