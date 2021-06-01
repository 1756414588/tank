
MilitaryRankBO = {}


function MilitaryRankBO.updateLoad(data)
	UserMO.militaryRank_ = data.militaryRank --军衔等级
	UserMO.militaryExploit_ = data.militaryExploit --军功
end

-- 获取军衔信息
function MilitaryRankBO.getMilitaryData(rhand)
	local function parseUpgrade(name, data)
		Loading.getInstance():unshow()
		UserMO.militaryRank_ = data.militaryRank --军衔等级
		UserMO.militaryExploit_ = data.militaryExploit --军功
		if rhand then rhand(data) end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetMilitaryRank"))
end

-- 升级军衔
function MilitaryRankBO.upleveMilitary(rhand)
	local function parseUpgrade(name, data)
		Loading.getInstance():unshow()
		local update = { {kind = ITEM_KIND_MILITARY_EXPLOIT, id = 0, count = data.militaryExploit} }
		UserMO.updateResources(update)	-- 更新军功
		UserMO.militaryRank_ = data.militaryRank -- 更新军衔等级
		UserBO.triggerFightCheck() -- 刷新战斗力
		if rhand then rhand(data) end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("UpMilitaryRank"))
end

-- 附加属性计算
function MilitaryRankBO.getEquipAttr()
	local outAttr = {}
	if not UserMO.queryFuncOpen(UFP_MILITARY) then return outAttr end
	local mylv = UserMO.militaryRank_ -- 我的军衔等级
	local data = MilitaryRankMO.queryById(mylv)
	if data then
		local attrdata = json.decode(data.attrs)
		for index = 1 , #attrdata do
			local outdata = attrdata[index]
			local datamix = AttributeBO.getAttributeData(outdata[1],outdata[2])
			outAttr[#outAttr + 1] = datamix
		end
	end
	return outAttr
end
