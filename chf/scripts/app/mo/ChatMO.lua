
local s_chat = require("app.data.s_chat")
local s_chat_lv = require("app.data.s_speak_lv")

local db_chat = nil
local db_chat_lv = nil

ChatMO = {}

CHAT_TYPE_WORLD = 1 -- 世界
CHAT_TYPE_PARTY = 2 -- 军团
CHAT_TYPE_CALLCENTER = 3 -- 客服
CHAT_TYPE_PRIVACY = 4 -- 私聊
CHAT_TYPE_TEAM = 5 -- 队伍聊天
CHAT_TYPE_CROSS = 6 -- 跨服聊天

CHAT_SHIELD_NUM = 50

CHAT_MAX_LENGTH = 40

CHAT_HORN_OPEN_LEVEL = 15 -- 聊天公告开启等级

CHAT_OPEN_LEVEL = 17


-- 按照类型分类聊天内容
ChatMO.chat_ = {}
ChatMO.man_ = {} -- 私聊搜索到的对方信息(对方在SearchOl搜索到的时候是可以确定在线的)
ChatMO.shield_ = {}  -- 屏蔽聊天列表
ChatMO.recent_ = {}  -- 最近联系人

ChatMO.showChat_ = true -- 如果为false，则点击聊天按钮进入聊天搜索
ChatMO.searchContent_ = ""  -- 搜索玩家名字显示的内容
ChatMO.curPrivacyLordId_ = 0 -- 当前私聊的对象的lordId

ChatMO.chatSynHandler_ = nil

ChatMO.bubbleType = {} -- 聊天皮肤列表

function ChatMO.init()
	db_chat = {}
	local records = DataBase.query(s_chat)
	for index = 1, #records do
		local data = records[index]
		db_chat[data.chatId] = data
	end

	db_chat_lv = {}
	local records = DataBase.query(s_chat_lv)
	for index = 1, #records do
		local data = records[index]
		db_chat_lv[data.id] = data
	end

	ChatMO.bubbleType = {}
	ChatMO.bubbleType[3001] = {right = {width = 76, height = 66, widthDex = 40, heightDex = 30, rect = cc.rect(34, 38, 1, 1), lbdex = cc.p(20,-15)},
								left = {width = 76, height = 66, widthDex = 40, heightDex = 30, rect = cc.rect(42, 38, 1, 1), lbdex = cc.p(20,-15)} } -- 默认 -- r_chatBg_bubble_1.png

	ChatMO.bubbleType[3002] = {right = {width = 171, height = 69, widthDex = 60, heightDex = 30, rect = cc.rect(75, 15, 1, 1), lbdex = cc.p(20,-15)}, 
								left = {width = 171, height = 69, widthDex = 60, heightDex = 30, rect = cc.rect(95, 15, 1, 1), lbdex = cc.p(40,-15)} } -- vip3

	ChatMO.bubbleType[3003] = {right = {width = 85, height = 69, widthDex = 40, heightDex = 30, rect = cc.rect(30, 15, 1, 1), lbdex = cc.p(20,-15)}, 
								left = {width = 85, height = 69, widthDex = 40, heightDex = 30, rect = cc.rect(30, 15, 1, 1), lbdex = cc.p(20,-15)} } -- vip6		

	ChatMO.bubbleType[3004] = {right = {width = 94, height = 75, widthDex = 50, heightDex = 35, rect = cc.rect(55, 15, 1, 1), lbdex = cc.p(30,-22)}, 
								left = {width = 94, height = 75, widthDex = 50, heightDex = 35, rect = cc.rect(30, 15, 1, 1), lbdex = cc.p(20,-22)} } -- vip12

	ChatMO.bubbleType[3005] = {right = {width = 157, height = 82, widthDex = 90, heightDex = 50, rect = cc.rect(65, 40, 1, 1), lbdex = cc.p(55,-40)},
								left = {width = 157, height = 82, widthDex = 95, heightDex = 50, rect = cc.rect(95, 5, 1, 1), lbdex = cc.p(40,-40)} } -- 万圣节

	ChatMO.bubbleType[3006] = {right = {width = 283, height = 83, widthDex = 50, heightDex = 50, rect = cc.rect(60, 40, 1, 1), lbdex = cc.p(35,-40)},
								left = {width = 283, height = 83, widthDex = 55, heightDex = 50, rect = cc.rect(130, 40, 1, 1), lbdex = cc.p(20,-40)} } -- 圣诞老人

	ChatMO.bubbleType[3007] = {right = {width = 288, height = 95, widthDex = 100, heightDex = 55, rect = cc.rect(130, 10, 1, 1), lbdex = cc.p(35,-40)},
								left = {width = 288, height = 95, widthDex = 100, heightDex = 55, rect = cc.rect(150, 10, 1, 1), lbdex = cc.p(65,-40)} } -- 星光灿烂 vip15
end

function ChatMO.queryChatById(id)
	return db_chat[id]
end

function ChatMO.getByType(type)
	local c = ChatMO.chat_[type]
	if not c then c = {} end
	return c
end

-- key:用于私聊时，判断自己和谁进行聊天的key值，值为聊天对方的名称
-- isread:此聊天记录是否已读
function ChatMO.addChat(type, name, portrait, vip, msg, time, id, param, report, style, tankData, sysId, heroId, isGm, isGuider, staffing, key, isread, jobId, medalData, militaryRank, bubble, teamId, uid, crossPlayInfo, roleId)
	time = time or ManagerTimer:getTime()

	if not ChatMO.chat_[type] then ChatMO.chat_[type] = {} end

	chat = {time = time, channel = type, name = name, portrait = portrait, vip = vip, msg = msg, id = id, param = param, report = report, style = style, tankData = tankData, sysId = sysId, heroId = heroId, isGm = isGm, isGuider = isGuider, staffing = staffing, isread = isread, jobId = jobId, medalData = medalData, roleId = roleId}
	if militaryRank then
		chat.militaryRank = militaryRank
	end
	if bubble then
		chat.bubble = bubble
	end

	if teamId and teamId ~= 0 then
		chat.teamId = teamId
	end

	if uid and uid > 0 then
		chat.uid = uid
	end
	
	if crossPlayInfo then
		chat.crossPlayInfo = crossPlayInfo
	end
	
	if roleId then
		chat.roleId = roleId
	end

	if type == CHAT_TYPE_PRIVACY then
		key = key or name
		
		if not ChatMO.chat_[type][key] then ChatMO.chat_[type][key] = {} end

		if #ChatMO.chat_[type][key] >= 50 then  -- 删除之前多的聊天记录
			local removeNum = #ChatMO.chat_[type][key] - 50 + 1
			for index = 1, removeNum do
				table.remove(ChatMO.chat_[type][key], 1)
			end
		end
		ChatMO.chat_[type][key][#ChatMO.chat_[type][key] + 1] = chat
	else
		if #ChatMO.chat_[type] >= 50 then  -- 删除之前多的聊天记录
			local removeNum = #ChatMO.chat_[type] - 50 + 1
			for index = 1, removeNum do
				table.remove(ChatMO.chat_[type], 1)
			end
		end
		ChatMO.chat_[type][#ChatMO.chat_[type] + 1] = chat
	end
	return chat
end

function ChatMO.addMan(man)
	ChatMO.man_[man.lordId] = man
end

function ChatMO.getChatManName(lordId)
	if not ChatMO.man_[lordId] then return "" end
	return ChatMO.man_[lordId].nick
end

function ChatMO.getChatManIdByName(name)
	for lordId, man in pairs(ChatMO.man_) do
		if man.nick == name then
			return lordId
		end
	end
	return 0
end

function ChatMO.getManById(lordId)
	return ChatMO.man_[lordId]
end

function ChatMO.delPrivaChat(name)
	local chats = ChatMO.getByType(CHAT_TYPE_PRIVACY)
	chats[name] = nil
	
end

function ChatMO.getChatOpenLv()
	local data = db_chat_lv
	local openLv = 0
	local openDay = UserMO.openServerDay
	for index=1,#data do
		local record = data[index]
		if openDay >= record.beginTime and openDay <= record.endTime then
			return record.lv
		end
	end

	return openLv
end