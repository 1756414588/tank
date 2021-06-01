--
-- Author: gf
-- Date: 2015-09-03 17:00:33
--

SocialityBO = {}

function SocialityBO.parseSynBless(name, data)
	gdump(data,"SocialityBO.parseSynBless(name, data)")
	local bless = {}

	if not data then return end

	if #SocialityMO.myBless_ < 10 then
		bless.man = PbProtocol.decodeRecord(data["man"])
		bless.state = 0
		table.insert(SocialityMO.myBless_,bless)
		Notify.notify(LOCAL_BLESS_GET_EVENT)
	end
end

function SocialityBO.updateFriend(data)
	-- SocialityMO.myFriends_ = HeroMO.queryHeroToInfo(data)

	SocialityMO.myFriends_ = {}
	
	if not data then return end
	SocialityMO.myfriendGiveMax = data.giveCount
	--将领数据
	local friends = PbProtocol.decodeArray(data["friend"])
	for i=1,#friends do
		friends[i].man = PbProtocol.decodeRecord(friends[i]["man"])
	end
	gdump(friends,"SocialityBO.update .. friends:")
	SocialityMO.myFriends_ = friends

end

function SocialityBO.updateBlesses(data)
	SocialityMO.myBless_ = {}

	if not data then return end
	
	--祝福数据
	local blesses = PbProtocol.decodeArray(data["bless"])
	for i=1,#blesses do
		blesses[i].man = PbProtocol.decodeRecord(blesses[i]["man"])
		SocialityMO.myBless_[#SocialityMO.myBless_ + 1] = blesses[i]
	end
	Notify.notify(LOCAL_BLESS_GET_EVENT)
	gdump(SocialityMO.myBless_,"SocialityBO.updateBlesses .. myBless_:")
end

-- 获取收藏记录 登录时获取
function SocialityBO.updateStore(data)
	SocialityMO.myStore_ = {}
	local posList = {}
	local stores = PbProtocol.decodeArray(data["store"])
	for i=1,#stores do
		local store = stores[i]
		if table.isexist(store, "man") then
			store.man = PbProtocol.decodeRecord(store["man"])
		end
		if table.isexist(store, "mine") then
			store.mine = PbProtocol.decodeRecord(store["mine"])
		end
		store.index = i
		posList[store.pos] = true
		print("line  " .. store.pos)
		SocialityMO.myStore_[#SocialityMO.myStore_ + 1] = store
	end
	local myStore = SocialityMO.getMyStoreCache()
	if myStore then
		for i = #myStore , 1 , -1 do
			local store = myStore[i]
			if not posList[store.pos] then
				SocketWrapper.wrapSend(nil, NetRequest.new("RecordStore",{pos = store.pos,enemy = store.enemy,friend = store.friend,isMine = store.isMine,type = store.type}))
				store.index = #SocialityMO.myStore_ + 1
				print("addline " .. store.pos)
				SocialityMO.myStore_[#SocialityMO.myStore_ + 1] = store
			end
			print("remove " .. store.pos)
			table.remove(myStore,i)
		end
		SocialityMO.saveMyStoreCache(nil,{})
	end
	-- if myStore or true then
	-- 	return 
	-- 	-- SocialityMO.myStore_ = myStore
	-- else
	-- 	if not data then return end
	-- 	SocialityMO.myStore_ = {}

	-- 	local stores = PbProtocol.decodeArray(data["store"])
	-- 	for i=1,#stores do
	-- 		if table.isexist(stores[i], "man") then
	-- 			stores[i].man = PbProtocol.decodeRecord(stores[i]["man"])
	-- 		end
	-- 		if table.isexist(stores[i], "mine") then
	-- 			stores[i].mine = PbProtocol.decodeRecord(stores[i]["mine"])
	-- 		end
	-- 	end
	-- 	-- SocialityMO.myStore_ = stores
	-- 	-- gdump(stores,"SocialityBO.updateStore .. stores_:")
	-- 	-- SocialityMO.saveMyStoreCache(function()
	-- 	-- 	--批量删除数据库存储的收藏列表
	-- 	-- 	for index=1,#stores do
	-- 	-- 		local store = stores[index]
	-- 	-- 		if store.pos and store.pos > 0 then
	-- 	-- 			SocketWrapper.wrapSend(nil, NetRequest.new("DelStore",{pos = store.pos}))
	-- 	-- 		end
	-- 	-- 	end
	-- 	-- 	gdump(SocialityMO.myStore_,"SocialityBO.updateStore .. myStore_:")
	-- 	-- 	end,stores)
	-- end
	
end

function SocialityBO.getFriend(doneCallback)
	local function updateHero(name, data)
		SocialityBO.updateFriend(data)
		Notify.notify(LOCAL_FRIEND_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(updateHero, NetRequest.new("GetFriend"))
end


function SocialityBO.asynGetBless(doneCallback)
	local function parseUpgrade(name, data)
		SocialityBO.updateBlesses(data)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetBless"))
end

function SocialityBO.asynGiveBless(doneCallback,lordId)
	local function parseUpgrade(name, data)
		if data.exp > 0 then
			local awards = {{type = ITEM_KIND_EXP, count = data.exp}}
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)

			-- UserMO.addUpgradeResouce(ITEM_KIND_EXP, data.exp)
		end
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("BlessFriend",{friendId = lordId}))
end

function SocialityBO.asynAcceptBless(doneCallback,lordId)
	local function parseUpgrade(name, data)
		local _, award = UserMO.updateCycleResource(ITEM_KIND_POWER, data.energy, true)
		local temp = PbProtocol.decodeArray(data["award"])

		local tempAward = {}
		local showAward = {}
		for k,v in ipairs(temp) do
			table.insert(tempAward,{kind=v.type,id=v.id,count=v.count})
			table.insert(showAward,{kind=v.type,id=v.id,count=v.count})
		end
		UserMO.addResources(tempAward)
		if award then
			table.insert(showAward,{kind=award.kind,count=award.count})
		end
		UiUtil.showAwards({awards = showAward})
		-- Notify.notify(LOCAL_BLESS_ACCEPT_EVENT)
		if doneCallback then doneCallback() end

		SocialityBO.asynGetBless()
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("AcceptBless",{friendId = lordId}))
end

function SocialityBO.asynSearchPlayer(doneCallback,nick)
	local function parseUpgrade(name, data)
		
		local player = PbProtocol.decodeRecord(data["man"])
		player.nick = nick
		gdump(player,"SocialityView:searchHandler()..player")

		if doneCallback then doneCallback(player) end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("SeachPlayer",{nick = nick}))
end


function SocialityBO.asynAddFriend(doneCallback,friendId)
	local function parseUpgrade(name, data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("AddFriend",{friendId = friendId}))
end

function SocialityBO.asynDelFriend(doneCallback,friendId)
	local function parseUpgrade(name, data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DelFriend",{friendId = friendId}))
end

function SocialityBO.getCanBlessFriends()
	local can = false
	for index = 1,#SocialityMO.myFriends_ do
		if SocialityMO.myFriends_[index].bless == 0 then
			can = true
			break
		end
	end
	return can
end

function SocialityBO.isMyFriend(lordId)
	local is = false
	for index = 1,#SocialityMO.myFriends_ do
		if SocialityMO.myFriends_[index].man.lordId == lordId then
			is = true
			break
		end
	end 
	return is
end

--是不是彼此好友
function SocialityBO.isOtherFriend(lordId)
	local is = false
	for index = 1,#SocialityMO.myFriends_ do
		if SocialityMO.myFriends_[index].man.lordId == lordId then
			if SocialityMO.myFriends_[index].state == 1 then
				is = true
			end
			break
		end
	end 
	return is
end

function SocialityBO.asynGetStore(doneCallback)
	-- local function parseUpgrade(name, data)
	-- 	SocialityBO.updateStore(data)
	-- 	if doneCallback then doneCallback() end
	-- end
	-- local myStore = SocialityMO.getMyStoreCache()
	-- if myStore then
	-- 	SocialityMO.myStore_ = myStore
	-- 	if doneCallback then doneCallback() end
	-- else
	-- 	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetStore"))
	-- end
end

-- 保存收藏
function SocialityBO.asynRecordStore(doneCallback,pos,enemy,friend,isMine,type,mine,man)
	-- local function parseRecordStore(name, data)
	-- 	gdump(data, "[SocialityBO] asynRecordStore")
	-- 	if doneCallback then doneCallback() end
	-- end
	-- for index=1,500 do
	-- 	SocketWrapper.wrapSend(nil, NetRequest.new("RecordStore",{pos = pos,enemy = enemy,friend = friend,isMine = isMine,type = type}))
	-- end
	
	-- local store = {}
	-- store.isMine = isMine
	-- store.type = type
	-- store.mark = ""
	-- store.enemy = enemy
	-- store.friend = friend
	-- store.pos = pos
	-- store.man = man
	-- store.mine = mine

	-- --每次保存收藏坐标 都重新读取一下收藏文件
	-- local mystore = SocialityMO.getMyStoreCache()
	-- if mystore then
	-- 	SocialityMO.myStore_ = mystore
	-- end
	-- table.insert(SocialityMO.myStore_,1,store)

	-- SocialityMO.saveMyStoreCache(doneCallback,SocialityMO.myStore_)
	--
	local function parseUpgrade(name, data)
		local newStore = PbProtocol.decodeRecord(data["store"])
		if table.isexist(newStore, "man") then newStore.man = PbProtocol.decodeRecord(newStore["man"]) end
		if table.isexist(newStore, "mine") then newStore.mine = PbProtocol.decodeRecord(newStore["mine"]) end
		newStore.index = #SocialityMO.myStore_ + 1
		table.insert(SocialityMO.myStore_,newStore)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("RecordStore",{pos = pos,enemy = enemy,friend = friend,isMine = isMine,type = type}))
end

-- 删除收藏
function SocialityBO.asynDelStore(doneCallback,poses)
	-- local function parseUpgrade(name, data)
	-- 	--删除
	-- 	for index = 1,#SocialityMO.myStore_ do
	-- 		if SocialityMO.myStore_[index].pos == pos then
	-- 			table.remove(SocialityMO.myStore_,index)
	-- 			break
	-- 		end
	-- 	end
	-- 	Notify.notify(LOCAL_STORE_UPDATE_EVENT)
	-- 	if doneCallback then doneCallback() end
	-- end

	-- SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DelStore",{pos = pos}))


	--删除
	-- for j = 1,#poses do
	-- 	for index = 1,#SocialityMO.myStore_ do
	-- 		if SocialityMO.myStore_[index].pos == poses[j] then
	-- 			table.remove(SocialityMO.myStore_,index)
	-- 			break
	-- 		end
	-- 	end
	-- end
	

	-- Notify.notify(LOCAL_STORE_UPDATE_EVENT)
	-- SocialityMO.saveMyStoreCache(doneCallback,SocialityMO.myStore_)
	-- dump(poses)

	local function parseUpgrade(name, data)
		--删除
		for j = 1,#poses do
			for index = 1,#SocialityMO.myStore_ do
				if SocialityMO.myStore_[index].pos == poses[j] then
					table.remove(SocialityMO.myStore_,index)
					break
				end
			end
		end
		-- 重新定序
		for i = 1 ,#SocialityMO.myStore_ do
			SocialityMO.myStore_[i].index = i
		end
		Notify.notify(LOCAL_STORE_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DelStore",{pos = poses}))
end

-- 编辑并保存 收藏
function SocialityBO.asynMarkStore(doneCallback,store)
	-- local function parseUpgrade(name, data)

	-- 	if doneCallback then doneCallback() end
	-- end


	-- SocialityMO.saveMyStoreCache(doneCallback,SocialityMO.myStore_)
	local editStore = clone(store)
	editStore.index = nil
	local function parseUpgrade(name, data)
		SocialityMO.myStore_[store.index] = store
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("MarkStore",{store = editStore}))
end

function SocialityBO.getBlessCount()
	local count = 0
	for index=1,#SocialityMO.myBless_ do
		local bless = SocialityMO.myBless_[index]
		if bless.state == 0 then
			count = count + 1
		end
	end
	return count
end

--赠送好友道具
function SocialityBO.giveFriendGift(doneCallback,param, friendId)
	local function parseUpgrade(name, data)
		Loading.getInstance():unshow()

		if table.isexist(data,"atom2") then
			local propData = PbProtocol.decodeRecord(data["atom2"])
			UserMO.updateResource(propData.kind,propData.count,propData.id)
		end
		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("FriendGiveProp",{type = param[1], propId = param[2], count = param[3], friendId = friendId}))
end

--友好度推送
function SocialityBO.parseSynFriendGive(name, data)
	if not data then return end
	local friends = PbProtocol.decodeRecord(data["friend"])
	for index = 1,#SocialityMO.myFriends_ do
		if SocialityMO.myFriends_[index].man.lordId == friends.man.lordId then
			SocialityMO.myFriends_[index] = friends
		end
	end

	Notify.notify(LOCAL_FRIEND_UPDATE_EVENT)
end