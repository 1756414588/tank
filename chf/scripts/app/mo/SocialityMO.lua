--
-- Author: gf
-- Date: 2015-09-03 17:00:23
--
-- local s_mine = require("app.data.s_mine")

local s_gift = require("app.data.s_friend_gift")
local db_gift_


SocialityMO = {}

STORE_TYPE_PLAYER   = 1 -- 收藏类型为玩家
STORE_TYPE_RESOURCE = 2 -- 收藏类型为资源点

--好友数量上限
SocialityMO.friendMax = 20

--祝福上限
SocialityMO.blessNumMax = 10

--我的好友
SocialityMO.myFriends_ = {}

--我的祝福
SocialityMO.myBless_ = {}

--我收藏的资源点
SocialityMO.myStore_ = {}

SocialityMO.myStoreMax = 200

SocialityMO.myfriendGiveMax = 0 --每月已经赠送次数

local myStore_storge_file = "myStore"

function SocialityMO.getMyStoreCache()
    --读取本地文件
    local path = nil
    if UserMO.oldLordId_ and UserMO.oldLordId_ == 0 then
    	path = CCFileUtils:sharedFileUtils():getCachePath() .. myStore_storge_file .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
    else
    	path = CCFileUtils:sharedFileUtils():getCachePath() .. myStore_storge_file .. "_" .. UserMO.oldLordId_ .. "_" .. GameConfig.areaId
    end
    local stores = nil
    if io.exists(path) then
        stores = json.decode(io.readfile(path))
    end
    return stores
end

function SocialityMO.saveMyStoreCache(doneCallback,stores)
	--只存储最近的200条数据
	local saveStores = {}
	for index=1,#stores do
		if index <= 200 then
			saveStores[#saveStores + 1] = stores[index]
		else
			break
		end
	end
	-- SocialityMO.myStore_ = saveStores
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. myStore_storge_file .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
    io.writefile(path, json.encode(saveStores), "w+b")
    if UserMO.oldLordId_ and UserMO.oldLordId_ ~= 0 then
		local path2 = CCFileUtils:sharedFileUtils():getCachePath() .. myStore_storge_file .. "_" .. UserMO.oldLordId_ .. "_" .. GameConfig.areaId
    	io.writefile(path2, json.encode(saveStores), "w+b")
    end
    if doneCallback then doneCallback() end
end


function SocialityMO.init()
	--我的好友
	SocialityMO.myFriends_ = {}

	--我的祝福
	SocialityMO.myBless_ = {}

	--我收藏的资源点
	SocialityMO.myStore_ = {}

	db_gift_ = {}

	local records = DataBase.query(s_gift)
	for index = 1, #records do
		local gift = records[index]
		db_gift_[gift.id] = gift
	end
end


function SocialityMO.queryMyStore_(type)
	gprint(type,"SocialityMO.queryMyStore_..index")

	if type == 1 then return SocialityMO.myStore_ end
	local list = {}
	for index=1,#SocialityMO.myStore_ do
		local store = SocialityMO.myStore_[index]
		if type == 2 then
			if store.isMine == 1 then
				list[#list + 1] = store
			end
		elseif type ==  3 then
			if store.enemy == 1 then
				list[#list + 1] = store
			end
		elseif type ==  4 then
			if store.friend == 1 then
				list[#list + 1] = store
			end
		end
	end

	gdump(list,"SocialityMO.queryMyStore_..list")
	return list
end

--判断俩好友之间的好友度是否已满
function SocialityMO.isFriendLessMax(lordId)
	local max = UserMO.querySystemId(70)
	local isFull = false

	for index = 1,#SocialityMO.myFriends_ do
		if SocialityMO.myFriends_[index].man.lordId == lordId then
			if SocialityMO.myFriends_[index].friendliness >= max then
				isFull = true
			end
			break
		end
	end 

	return isFull
end

--计算出友好度加成的资源掠夺量
function SocialityMO.getPlunderByFriendliness(friendliness)
	local record = UserMO.querySystemId(77)
	local data = json.decode(record)
	for index=1,#data do
		local param = data[index]
		if friendliness >= param[1] and friendliness <= param[2] then
			return param[3]
		end
	end
end

--根据好友度得出可赠送的道具
function SocialityMO.getGiftByFriendliness(friendliness)
	local data = db_gift_
	local info = {}
	for index=1,#data do
		local friend = json.decode(data[index].friend)
		if friendliness >= friend[1] and friendliness <= friend[2] then
			info = data[index].prop
		end
	end

	local record = json.decode(info)
	return record
end

--根据类型获得可赠送的道具
function SocialityMO.getGiftByKind(kind)
	local data = db_gift_
	local info = {}
	for index=1,#data do
		if data[index].type == kind then
			info[#info +1] = data[index]
		end
	end

	--排序
	local sortFun = function(a,b)
		if a.friend == b.friend then
			return a.id < b.id
		else
			return a.friend < b.friend
		end
	end
	
	table.sort(info,sortFun)
	return info
end