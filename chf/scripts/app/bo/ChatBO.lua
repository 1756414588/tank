
ChatBO = {}

-- 如果chatType是CHAT_TYPE_PRIVACY私聊时，param必须有参数nick，表示和谁私聊的所有聊天已读
function ChatBO.readChat(chatType, param)
	local typeChats = ChatMO.getByType(chatType)

	local function set(chats)
		if not chats then return end
		
		for key, chat in pairs(chats) do
			chat.isread = true
		end
	end

	if chatType == CHAT_TYPE_PRIVACY then
		local chats = typeChats[param.nick]
		set(chats)
	else
		set(typeChats)
	end
	
	Notify.notify(LOCAL_READ_CHAT_EVENT)
end

function ChatBO.getUnreadChatNum()
	local num = 0
	for index = 1, CHAT_TYPE_CROSS do
		local typeChats = ChatMO.getByType(index)

		if index ~= CHAT_TYPE_PRIVACY then
			for chatIndex = 1, #typeChats do
				if not typeChats[chatIndex].isread then
					num = num + 1
				end
			end
		elseif index == CHAT_TYPE_PRIVACY then
			for name, chats in pairs(typeChats) do
				for key, chat in pairs(chats) do
					if not chat.isread then
						num = num + 1
					end
				end
			end
		end
	end
	return num
end

-- 如果chatType是私聊，则需要chatName判断是和谁的未读聊天，如果chatName为nil，则表示是所有的私聊
function ChatBO.getTypeUnreadChatNum(chatType, chatName)
	local num = 0

	local typeChats = ChatMO.getByType(chatType)
	if chatType == CHAT_TYPE_PRIVACY then
		if chatName then
			local chats = typeChats[chatName]
			if chats and #chats > 0 then
				for key, chat in pairs(chats) do
					if not chat.isread then
						num = num + 1
					end
				end
			end
		else  -- 所有的私聊
			for name, chats in pairs(typeChats) do
				for key, chat in pairs(chats) do
					if not chat.isread then
						num = num + 1
					end
				end
			end
		end
	else
		for chatIndex = 1, #typeChats do
			if not typeChats[chatIndex].isread then
				num = num + 1
			end
		end
	end
	return num
end

function ChatBO.update(data)
	gdump(data, "[ChatBO] update")

	ChatMO.chat_ = {}
	ChatMO.man_ = {}
	ChatMO.shield_ = {}

	ChatBO.readShieldList()

	if not data then return end

	local chats = PbProtocol.decodeArray(data["chat"])
	for index = 1, #chats do
		local chat = chats[index]
		local id = nil
		if table.isexist(chat, "id") then id = chat["id"] end

		local param = nil
		if table.isexist(chat, "param") then param = chat["param"] end

		local report = nil
		if table.isexist(chat, "report") then report = chat["report"] end

		local style = 0
		if table.isexist(chat, "style") then style = chat["style"] end

		local tankData = nil
		if table.isexist(chat, "tankData") then tankData = PbProtocol.decodeRecord(chat["tankData"]) end -- 坦克分享
		
		local medalData = nil
		if table.isexist(chat, "medalData") then medalData = PbProtocol.decodeRecord(chat["medalData"]) end -- 勋章分享

		local sysId = nil
		if table.isexist(chat, "sysId") then sysId = chat["sysId"] end -- 系统消息

		local heroId = 0
		if table.isexist(chat, "heroId") then heroId = chat["heroId"] end -- 将领分享

		local isGm = false
		if table.isexist(chat, "isGm") then isGm = chat["isGm"] end  -- 是否是GM账号

		local isGuider = false
		if table.isexist(chat, "isGuider") then isGuider = chat["isGuider"] end  -- 是否是新手指导员

		local staffing = 0
		if table.isexist(chat, "staffing") then staffing = chat["staffing"] end -- 编制

		local fortressJobId = 0
		if table.isexist(chat, "fortressJobId") then fortressJobId = chat["fortressJobId"] end -- 要塞任命

		local militaryRank = nil
		if table.isexist(chat, "militaryRank") then militaryRank = chat["militaryRank"] end -- 军衔

		local bubble = 0
		if table.isexist(chat, "bubble") then bubble = chat["bubble"] end -- 聊天框

		local teamId = 0
		if table.isexist(chat, "teamId") then teamId = chat["teamId"] end

		local uid = 0
		if table.isexist(chat, "uid") then uid = chat["uid"] end

		local roleId = 0
		if table.isexist(chat, "roleId") then roleId = chat["roleId"] end
		-- gdump(roleId,  "SERVER CHAT ChatBO.roleId == ")

		local crossPlayInfo = {}
		if table.isexist(chat, "crossPlayInfo") then 
			crossPlayInfo = PbProtocol.decodeRecord(chat["crossPlayInfo"]) 
			-- gdump(crossPlayInfo)
			-- gprint("1111111111111")
		end

		local shield = ChatBO.getShield(chat.roleId)

		if shield then -- 是屏蔽的
		else
			ChatMO.addChat(chat.channel, chat.name, chat.portrait, chat.vip, chat.msg, chat.time, id, param, report, style, tankData, sysId, heroId, isGm, isGuider, staffing, nil, false, fortressJobId, medalData, militaryRank, bubble, teamId, uid, crossPlayInfo, roleId)
		end
	end
end

-- 服务端系统指令
function ChatBO.isMsgOk(msg)
	if string.find(msg, "add ") ~= nil
		or string.find(msg, "set ") ~= nil
		or string.find(msg, "clear ") ~= nil
		or string.find(msg, "build ") ~= nil
		or string.find(msg, "mail ") ~= nil
		or string.find(msg, "system ") ~= nil
		or string.find(msg, "platMail ") ~= nil
		or string.find(msg, "kick ") ~= nil
		or string.find(msg, "silence ") ~= nil
		or string.find(msg, "ganVip ") ~= nil
		or string.find(msg, "clearPlayer ") ~= nil
		or string.find(msg, "clearAllPlayer ") ~= nil
		or string.find(msg, "ganTopup ") ~= nil
		or string.find(msg, "remove ") ~= nil
		or string.find(msg, "removePlayer ") ~= nil
		or string.find(msg, "removeAllPlayer ") ~= nil
		or string.find(msg, "setParty ") ~= nil
		or string.find(msg, "setPlayer ") ~= nil
		or string.find(msg, "gmRemoveAllPlayer ") ~= nil
		or string.find(msg, "airship ") ~= nil 
		or string.find(msg, "relevance ") ~= nil then
		return false
	else
		return true
	end
end

-- 客户端系统指令
function ChatBO.isGMOK(msg)
	if string.find(msg, "system #client info") ~= nil then
		return true
	end
	return false
end

-- 将chat的内容，转换为RichLabel可以显示的内容
function ChatBO.formatChat(chat)
	local stringDatas = {}
	if table.isexist(chat, "tankData") then  -- 坦克分享
		local tankData = chat.tankData
		local tankDB = TankMO.queryTankById(tankData.tankId)
		stringDatas[1] = {["content"] = tankDB.name, color = COLOR[tankDB.grade], click = function()
				require("app.dialog.DetailTankDialog").new(tankData.tankId, false, tankData):push()  -- 坦克详情
			end}
	elseif table.isexist(chat, "medalData") then  -- 勋章分享
		local medalData = chat.medalData
		local md = MedalMO.queryById(medalData.medalId)
		stringDatas[1] = {["content"] = md.medalName, color = COLOR[md.quality], click = function()
				require("app.dialog.DetailItemDialog").new(ITEM_KIND_MEDAL_ICON, medalData.medalId, {data = medalData}):push() 
			end}
	elseif table.isexist(chat, "id") and chat.id > 0 then -- 报告分享
		-- gprint("ChatBO.formatChat:id====", chat.id)
		-- gdump(chat, "????")
		local function gotoMail(state, report)
			Loading.getInstance():unshow()

			if state ~= 1 then
				Toast.show(CommonText[410])  -- 已删除
				return
			end

			local mail = {report = report, moldId = chat.id}

			local mailInfo = MailMO.queryMail(chat.id)
			if mailInfo.type == MAIL_TYPE_PERSON_JJC or mailInfo.type == MAIL_TYPE_ALL_JJC then ---竞技场
				require("app.view.ReportArenaView").new(mail, true):push()
			elseif mailInfo.type == MAIL_TYPE_REPORT then --- 战报
				if mail.report.scoutHome or mail.report.scoutMine or mail.report.scoutRebel then
					--侦查
					require("app.view.ReportScoutView").new(mail, true):push()
				else
					--攻打、防守
					require("app.view.ReportAttackView").new(mail, true):push()
				end
			elseif mailInfo.type == MAIL_TYPE_REPORT_AS then ---飞艇战报
				require("app.view.ReportAirShipView").new(mail, true):push()
			end
		end

		local mail = MailMO.queryMail(chat.id)

		local title = MailBO.parseShareTitle(mail.moldId, chat.param, chat.name)
		stringDatas[1] = {["content"] = title, color = COLOR[3], click = function() Loading.getInstance():show(); ChatBO.asynGetReport(gotoMail, chat.name, chat.report) end}
	elseif table.isexist(chat, "sysId") and chat.sysId > 0 then -- 系统报告 军团招募消息
		gprint("ChatBO.formatChat:sysId====", chat.sysId)
		local chatDB = ChatMO.queryChatById(chat.sysId)

		local function gotoChat(chatId,kind,id,act)
			--处理宝箱开物品
			if kind and id then
				if kind == ITEM_KIND_HERO then
					local heroId = id
					local heroDB = HeroMO.queryHero(heroId)
					require("app.dialog.HeroDetailDialog").new(heroDB,2):push()
				elseif kind == ITEM_KIND_TANK then
					local tankDB = TankMO.queryTankById(id)
					require("app.dialog.DetailTankDialog").new(id, false, tankDB):push()  -- 坦克详情
				elseif kind == ITEM_KIND_EQUIP then
					local eKid = string.split(act, ":")
					local t = require("app.dialog.DetailItemDialog").new(kind, id, {equipLv = tonumber(eKid[2]), star = tonumber(eKid[3])}):push()
				else
					local t = require("app.dialog.DetailItemDialog").new(kind, id):push()
					if t.ownLabel then t.ownLabel:hide() end
				end
				return
			end
			if (chatId >= 101 and chatId <= 104) or chatId == 125 then -- 军团招募
				gdump(chat,"chat DB")
				--判断玩家等级是否开启军团
				if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_PARTY) then
					local build = BuildMO.queryBuildById(BUILD_ID_PARTY)
					Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_PARTY), build.name))
					return
				end
				Loading.getInstance():show()
				PartyBO.asynSeachParty(function(party)
						Loading.getInstance():unshow()
						if party then
							Loading.getInstance():show()
							PartyBO.asynGetParty(function(data)
								Loading.getInstance():unshow()
								require("app.dialog.PartyDetailDialog").new(data):push()
								end, party.partyId)
						end 
					end,chat.param[1])
			elseif chatId == 105 or chatId == 108 or chatId == 193 then -- 竞技场
				--判断玩家等级是否开启军团
				if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_ARENA) then
					local build = BuildMO.queryBuildById(BUILD_ID_ARENA)
					Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_ARENA), build.name))
					return
				end
				require("app.view.ArenaView").new():push()
			elseif chatId == 107 then
				require("app.view.LotteryEquipView").new(UI_ENTER_NONE):push()
			elseif chatId == 111 then -- 限时副本
				local sectionId = CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_LIMIT)
				if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_LIMIT) then  -- 等级不足
					local exploreSection = CombatMO.querySectionById(sectionId)
					Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(EXPLORE_TYPE_LIMIT), exploreSection.name))
					return
				end

				if CombatBO.isLimitExploreTimeOpen() then
					local CombatLevelView = require("app.view.CombatLevelView")
					CombatLevelView.new(COMBAT_TYPE_EXPLORE, sectionId):push()
					return
				end

				local sectionDB = CombatMO.querySectionById(sectionId)
				Toast.show(sectionDB.name .. CommonText[411]) -- 未开启
			elseif chatId == 113 then  -- 组装
				local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_MECHA)
				if activity then
					local function show()
						Loading.getInstance():unshow()
						UiDirector.push(require("app.view.ActivityMechaView").new(activity))
					end

					local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_MECHA)
					if activityContent then
						show()
					else
						Loading.getInstance():show()
						ActivityCenterBO.asynGetActivityContent(show, ACTIVITY_ID_MECHA)
					end
				else
					Toast.show(CommonText[10026])
				end
			elseif chatId == 116 or chatId == 123 then  -- 探宝
				UiDirector.push(require("app.view.LotteryTreasureView").new())
			elseif chatId == 117 then   -- 招募将领
				if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then
					local build = BuildMO.queryBuildById(BUILD_ID_SCHOOL)
					Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_SCHOOL), build.name))
					return
				end
				require("app.view.LotteryHeroView").new():push()
			elseif chatId == 118 then  -- 武将进阶
				if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then
					local build = BuildMO.queryBuildById(BUILD_ID_SCHOOL)
					Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_SCHOOL), build.name))
					return
				end
				require("app.view.HeroImproveView").new():push()
			elseif chatId == 119 then -- 武将升级
				local buildingId = BUILD_ID_SCHOOL
				if UserMO.level_ < BuildMO.getOpenLevel(buildingId) then
					local build = BuildMO.queryBuildById(buildingId)
					Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(buildingId), build.name))
					return
				end
				require("app.view.NewSchoolView").new(buildingId):push()
			elseif chatId == 120 then --幸运转盘
				local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_FORTUNE)
				if not activity then
					Toast.show(CommonText[10026])
					return
				end
				UiDirector.push(require("app.view.ActivityFortuneView").new(activity))
			elseif chatId == 121 then
				local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_PROFOTO)
				if not activity then
					Toast.show(CommonText[10026])
					return
				end
				UiDirector.push(require("app.view.ActivityProfotoView").new(activity))
			elseif chatId == 131 then --领取军团试练箱子
				Loading.getInstance():show()
				PartyCombatBO.asynGetPartyCombat(function()
					Loading.getInstance():unshow()
					require("app.view.PartyCombatView").new():push()
					local sectionInfo = PartyCombatMO.getCombatSectionById(tonumber(chat.param[2]))
					if sectionInfo then
						require("app.view.PartyCombatLevelView").new(sectionInfo):push()
					end
					
					end)
			elseif chatId == 135 or chatId == 136 or chatId == 137 or chatId == 138 then -- 世界BOSS
				if not ActivityCenterMO.isBossOpen_ then
					Toast.show(CommonText[10026])
					return
				end

				if UserMO.level_ < ACTIVITY_BOSS_OPEN_LEVEL then
					Toast.show(string.format(CommonText[290], ACTIVITY_BOSS_OPEN_LEVEL, CommonText[10008]))
					return
				end

				local ActivityBossView = require("app.view.ActivityBossView")
				ActivityBossView.new():push()
			elseif chatId == 140 or chatId == 141 or chatId == 143 or chatId == 220 then --百团混战
				--判断等级
				if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_PARTY) then
					local build = BuildMO.queryBuildById(BUILD_ID_PARTY)
					Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_PARTY), build.name))
					return
				end

				--判断是否有军团
				if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
					UiDirector.pop()
					require("app.view.PartyBattleView").new():push()
				else
					--打开军团列表
					Loading.getInstance():show()
					PartyBO.asynGetPartyRank(function()
						Loading.getInstance():unshow()
						require("app.view.AllPartyView").new():push()
						end, 0, PartyMO.allPartyList_type_)
				end
			elseif chatId == 147 then
				require("app.view.VipView").new():push()
			elseif chatId == 154 then
				-- require("app.view.RechargeView").new():push()
				RechargeBO.openRechargeView()
			elseif chatId == 155 or chatId == 261 or chat.sysId == 262 or chat.sysId == 263 or chatId == 278 or chatId == 281 
				or chatId == 282 then
				if not act then return end
				act = tonumber(act)
				local t = ActivityCenterMO.activityIng(act)
				if t then
					if t.minLv and t.minLv > 0 and UserMO.level_ < t.minLv then
						Toast.show(string.format(CommonText[1125],t.minLv))
					elseif act == ACTIVITY_ID_GENERAL or act == ACTIVITY_ID_GENERAL1 then
						require("app.view.ActivityGeneralView").new(t):push()
					elseif act == ACTIVITY_ID_TANKRAFFLE then
						if not ActivityCenterMO.getActivityContentById(act) then
							ActivityCenterBO.asynGetActivityContent(function()
								require("app.view.ActivityRaffleView").new(t):push()
							end, act)
						else
							require("app.view.ActivityRaffleView").new(t):push()
						end
					elseif act == ACTIVITY_ID_TANK_CARNIVAL then
						if not ActivityCenterMO.getActivityContentById(act) then
							ActivityCenterBO.asynGetActivityContent(function()
								require("app.view.ActivityTankCarnival").new(t):push()
							end, act)
						else
							require("app.view.ActivityTankCarnival").new(t):push()
						end
					elseif act == ACTIVITY_ID_FLOWER then
						require("app.view.ActivityFlower").new(t):push()
					elseif act == ACTIVITY_ID_STOREHOUSE then
						require("app.view.ActivityStorehouse").new(t):push()
					elseif act == ACTIVITY_ID_FESTIVAL then
						require("app.view.ActivityFestival").new(t):push()
					elseif act == ACTIVITY_ID_CLEAR then
						require("app.view.ActivityPayClear").new(t):push()
					elseif act == ACTIVITY_ID_WORSHIP then
						require("app.view.ActivityWorship").new(t,2):push()
					elseif act == ACTIVITY_ID_CLEAR then
						require("app.view.ActivityPayClear").new(t):push()
					elseif act == ACTIVITY_ID_PAYTURNTABLE then
						require("app.view.ActivityPayTurntableView").new(t):push()
					elseif act == ACTIVITY_ID_REFINE_MASTER then
						require("app.view.ActivityRefineMasterView").new(t):push()
					elseif act == ACTIVITY_ID_MONOPOLY then
						require("app.view.ActivityMonopolyView").new(t):push()
					elseif act == ACTIVITY_ID_REDPACKET then
						require("app.view.ActivityRedPacketView").new(t):push()
					elseif act == ACTIVITY_ID_LUCKYROUND then
						require("app.view.ActivityLuckyRoundView").new(t):push()
					end
				else
					Toast.show(CommonText[10026])
				end
			elseif chatId == 156 or chatId == 157 then --挑战报告
				Loading.getInstance():show()
				local function goToReport(state, report)
					Loading.getInstance():unshow()

					if state ~= 1 then
						Toast.show(CommonText[410])  -- 已删除
						return
					end
					require("app.view.ReportAttackView").new({report = report}, true):push()
				end

				ChatBO.asynGetReport(goToReport, act[1], tonumber(act[2]))
			elseif chatId == 160 or chatId == 172 then --要塞战
				local HomeView = require("app.view.HomeView")
				local view = HomeView.new(MAIN_SHOW_FORTRESS):push()
			elseif chatId == 174 then
				-- require("app.view.PartyAltarBossView").new():push()
					--打开军团BOSS
					Loading.getInstance():show()
					PartyBO.asynGetPartyAltarBossData(function()
						Loading.getInstance():unshow()
						require("app.view.PartyAltarBossView").new():push()
						end)	
			elseif chatId == 178 or chatId == 179 or chatId == 181 or chatId == 182 then
				if StaffMO.worldLv_ < 1 then  -- 世界等级达到1级后
					Toast.show(CommonText[10054][2])
					return
				end
				require("app.view.ExerciseView").new():push()
			elseif chatId == 187 or chatId == 190 or chatId == 191 or chatId == 192 then
				local index = nil
				if chatId >= 190 then
					index = chatId - 189
				end
				require("app.view.RebelView").new(nil,nil,index):push()
			elseif chatId == 194 then
				if not CrossMO.isOpen_ then
					Toast.show(CommonText[30049])
					return
				end
				if UserMO.level_ < UserMO.querySystemId(45) then
					Toast.show(string.format(CommonText[1083], UserMO.querySystemId(45)))
					return
				end
				require("app.view.CrossEnter").new():push()
			elseif chatId == 195 then
				CrossMO.goToView(1,CrossBO.myGroup_)
			elseif chatId == 196 then
				CrossMO.goToView(2,CrossBO.myGroup_)
			elseif chatId == 197 then
				CrossMO.goToView(3,CrossBO.myGroup_)
			elseif chatId == 199 then
				if not CrossMO.isOpen_ then
					Toast.show(CommonText[30049])
					return
				end
				CrossBO.getServerList(function()
						if not CrossBO.state_ then
							CrossBO.getState(function()
									require("app.view.CrossShop").new():push()
								end)
						else
							require("app.view.CrossShop").new():push()	
						end
					end)
			elseif chatId == 211 then
				local t = require("app.dialog.DetailItemDialog").new(kind, id):push()
				if t.ownLabel then t.ownLabel:hide() end
			elseif chatId == 221 or chatId == 222 or chatId == 231 or chatId == 232 then
				if not CrossPartyMO.isOpen_ then
					Toast.show(CommonText[30049])
					return
				end
				require("app.view.CrossPartyEnter").new():push()
			elseif chatId == 223 then
				if not CrossPartyMO.isOpen_ then
					Toast.show(CommonText[30049])
					return
				end
				require("app.view.CrossPartyView").new(nil,3):push()
			elseif chatId == 229 then
				if not CrossPartyMO.isOpen_ then
					Toast.show(CommonText[30049])
					return
				end
				if not CrossPartyBO.state_ then
					CrossPartyBO.getState(function()
							require("app.view.CrossShop").new(ACTIVITY_CROSS_PARTY):push()
						end)
				else
					require("app.view.CrossShop").new(ACTIVITY_CROSS_PARTY):push()
				end
			elseif chatId == 215 then
				local t = ActivityCenterMO.activityIng(ACTIVITY_ID_NEWYEAR)
				if t then
					require("app.view.ActivityNewYearBoss").new(t):push()
				else
					Toast.show(CommonText[10026])
				end
			elseif chatId == 257 or chatId == 258 or chatId == 259 or chatId == 260 then
				local ab = AirshipMO.queryShipById(act)
				UiDirector.popMakeUiTop("HomeView")
				UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
				local pos = WorldMO.decodePosition(ab.pos)
				UiDirector.getTopUi():getCurContainer():onLocate(pos.x, pos.y)
			elseif chatId == 275 then
				if UserMO.queryFuncOpen(UFP_WARWEAPON) then
					if  UserMO.level_ >= UserMO.querySystemId(48) then
						require("app.view.WarWeaponView").new():push()
					else
						Toast.show(string.format(CommonText[20136],UserMO.querySystemId(48)))
					end
				else
					Toast.show(CommonText[758])
				end
			elseif chatId == 279 then
				RechargeBO.openRechargeView()
			elseif chatId == 280 then
				require("app.view.ActivityView").new(act):push()
			elseif chatId == 283 then
				HunterBO.joinTeam(act, function ()
					-- body
				end)
			elseif chatId == 290 then
				require("app.view.RoyaleSurvivalView").new(nil, 2):push()
			elseif chatId == 284 or chatId == 293 then
				UiDirector.popMakeUiTop("HomeView")
				UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
				local pos = WorldMO.decodePosition(act)
				UiDirector.getTopUi():getCurContainer():onLocate(pos.x, pos.y)
			end
		end

		-- gdump(chatDB,"chatDB===")
		if chatDB then
			local paramIndex = 1
			local contents = json.decode(chatDB.content)
			for index = 1, #contents do
				local content = contents[index]

				stringDatas[index] = {}
				local kind,id = nil,nil
				if content[1] == "" then -- 填写param
					if chatDB.chatId == 153 or chatDB.chatId == 155 or chatDB.chatId == 154 or chatDB.chatId == 261
					or chatDB.chatId == 262 or chatDB.chatId == 263 or chatDB.chatId == 264 or chatDB.chatId == 265
					or chatDB.chatId == 266 or chatDB.chatId == 267 or chatDB.chatId == 268 or chatDB.chatId == 269
					or chatDB.chatId == 270 or chatDB.chatId == 271 or chatDB.chatId == 272 or chatDB.chatId == 273 
					or chatDB.chatId == 278 or chatDB.chatId == 288 or chatDB.chatId == 291 or chatDB.chatId == 292 then --开宝箱解析需要解析参数或者活动
						local s = chat.param[paramIndex]
						if string.find(s, ":") then
							s = string.split(s, ":")
							kind,id = tonumber(s[1]), tonumber(s[2])
							local resData = UserMO.getResourceData(kind,id)
							stringDatas[index].content = resData.name2
							stringDatas[index].color = COLOR[resData.quality]
							stringDatas[index].underline = true
						else
							stringDatas[index] = {["content"] = s, color = cc.c3b(254, 248, 136), underline = true}
						end
					else
						stringDatas[index] = {["content"] = chat.param[paramIndex], color = cc.c3b(254, 248, 136), underline = true}
						if chatDB.chatId == 107 and paramIndex == 2 then
							stringDatas[index].color = COLOR[4]
						elseif chatDB.chatId == 113 and paramIndex == 2 then
							local tankId = json.decode(chat.param[paramIndex])
							local tankDB = TankMO.queryTankById(tankId)
							stringDatas[index].content = tankDB.name
							stringDatas[index].color = COLOR[tankDB.grade]
						elseif chatDB.chatId == 114 and paramIndex == 2 then
							local equipId = json.decode(chat.param[paramIndex])
							local resData = UserMO.getResourceData(ITEM_KIND_EQUIP, equipId)
							stringDatas[index].content = resData.name
							stringDatas[index].color = COLOR[resData.quality]
						elseif (chatDB.chatId == 117 or chatDB.chatId == 118 or chatDB.chatId == 255) and paramIndex == 2 then
							local heroId = json.decode(chat.param[2])
							local heroDB = HeroMO.queryHero(heroId)

							stringDatas[index].content = heroDB.heroName
							stringDatas[index].color = COLOR[heroDB.star]
						elseif chatDB.chatId == 119 then
							if paramIndex == 2 then  -- 武将名称
								local heroId = json.decode(chat.param[2])
								local heroDB = HeroMO.queryHero(heroId)

								stringDatas[index].content = heroDB.heroName
								stringDatas[index].color = COLOR[heroDB.star]
							elseif paramIndex == 3 then
								local heroId = json.decode(chat.param[2])
								local heroDB = HeroMO.queryHero(heroId)
								if heroDB.canup == 0 then
									stringDatas[index].content = " "
								else
									local nxtHeroDB = HeroMO.queryHero(heroDB.canup)
									stringDatas[index].content = nxtHeroDB.heroName -- CommonText.heroStar[nxtHeroDB.star]
									stringDatas[index].color = COLOR[nxtHeroDB.star]
								end
							end
						elseif (chatDB.chatId == 115 or chatDB.chatId == 122) and paramIndex == 2 then  -- 配件
							local partId = json.decode(chat.param[2])
							local resData = UserMO.getResourceData(ITEM_KIND_PART, partId)
							stringDatas[index].content = resData.name
							stringDatas[index].color = COLOR[resData.quality]
						elseif chatDB.chatId == 121 and paramIndex == 2 then -- 打开哈洛克的宝藏
							local itemKind = json.decode(chat.param[2])
							local itemId = json.decode(chat.param[3])
							local resData = UserMO.getResourceData(itemKind, itemId)
							
							stringDatas[index].content = resData.name
							stringDatas[index].color = COLOR[resData.quality]
						elseif chatDB.chatId == 129 and paramIndex == 2 then --军团职位被任命为自定义职位
							stringDatas[index].content = PartyBO.getJobNameById(tonumber(chat.param[2]))
						elseif chatDB.chatId == 131 and paramIndex == 2 then
							stringDatas[index].content = PartyCombatMO.queryCombat(tonumber(chat.param[2])).name
						elseif chatDB.chatId == 120 and paramIndex == 2 then
							local itemId = json.decode(chat.param[2])
							local resData = UserMO.getResourceData(ITEM_KIND_CHIP, itemId)
							stringDatas[index].content = resData.name
							stringDatas[index].color = COLOR[resData.quality]
						elseif chatDB.chatId == 146 then
							stringDatas[index].color = nil
							stringDatas[index].underline = nil
						elseif chatDB.chatId == 177 and paramIndex == 2 then  ---能晶合成
							local stoneId = json.decode(chat.param[2])
							local db = EnergySparMO.queryEnergySparById(stoneId)
							local resData = UserMO.getResourceData(ITEM_KIND_ENERGY_SPAR, stoneId)
							stringDatas[index].content = db.stoneName
							stringDatas[index].color = COLOR[resData.quality]	
							kind,id = ITEM_KIND_ENERGY_SPAR, stoneId
						elseif chatDB.chatId == 211 then --装备进阶
							if paramIndex > 1 then
								local eid = json.decode(chat.param[paramIndex])
								local resData = UserMO.getResourceData(ITEM_KIND_EQUIP, eid)
								stringDatas[index].content = resData.name2
								stringDatas[index].color = COLOR[resData.quality]
								kind,id = ITEM_KIND_EQUIP, eid
							end
						elseif chatDB.chatId == 201 or chatDB.chatId == 202 then
							if paramIndex == 2 then  -- 武将名称
								local medalId = json.decode(chat.param[2])
								local md = MedalMO.queryById(medalId)
								stringDatas[index].content = md.medalName
								stringDatas[index].color = COLOR[md.quality]
								kind,id = ITEM_KIND_MEDAL_ICON, medalId
							end
						elseif chatDB.chatId == 254 then  -- 配件进阶
							if paramIndex > 1 then
								local partId = json.decode(chat.param[paramIndex])
								local md = UserMO.getResourceData(ITEM_KIND_PART, partId)
								stringDatas[index].content = md.name
								stringDatas[index].color = COLOR[md.quality]
								kind,id = ITEM_KIND_PART , partId
							end
						elseif chatDB.chatId == 256 then --觉醒技能
							if paramIndex == 2 then 
								local sb = HeroMO.queryAwakeSkillInfo(json.decode(chat.param[2]),0)
								stringDatas[index].content = sb.name
							end
						elseif chatDB.chatId == 257 then --飞艇进攻
							if paramIndex == 3 then 
								local ab = AirshipMO.queryShipById(json.decode(chat.param[3]))
								stringDatas[index].content = ab.name
							end
						elseif chatDB.chatId == 283 then -- 赏金
							if paramIndex == 2 then
								stringDatas[index].content = chat.param[2]
							end
						elseif chatDB.chatId == 258 or chatDB.chatId == 259 or chatDB.chatId == 260 then
							if paramIndex == 1 then 
								local ab = AirshipMO.queryShipById(json.decode(chat.param[1]))
								stringDatas[index].content = ab.name
							end
						elseif chatDB.chatId == 274 then  --勋章精炼
							if paramIndex > 1 then
								local medalId = json.decode(chat.param[paramIndex])
								local md = UserMO.getResourceData(ITEM_KIND_MEDAL_ICON, medalId)
								stringDatas[index].content = md.name
								stringDatas[index].color = COLOR[md.quality]
								kind,id = ITEM_KIND_MEDAL_ICON , medalId
							end
						elseif chatDB.chatId == 275 then  --秘密武器
							if paramIndex == 1 then
								stringDatas[index].content = chat.param[paramIndex]
							end
							if paramIndex == 2 then
								local id = chat.param[paramIndex]
								local info = WarWeaponMO.queryWeaponById(tonumber(id))
								stringDatas[index].content = info.name
							end
						elseif chatDB.chatId == 1001 then  --红包
							if paramIndex == 1 then
								stringDatas[index].content = chat.param[paramIndex]
							end
							if paramIndex == 2 then
								if chat.param[paramIndex] == 1 then
									stringDatas[index].content = CommonText[354][1]
								else
									stringDatas[index].content = CommonText[354][2]
								end
								
							end
						elseif chatDB.chatId == 285 then  --装备升星
							if paramIndex > 1 then
								local eKid = string.split(chat.param[paramIndex], ":")--装备ID。等级。星级
								kind, id = ITEM_KIND_EQUIP, tonumber(eKid[1])

								local resData = UserMO.getResourceData(ITEM_KIND_EQUIP, tonumber(eKid[1]))
								stringDatas[index].content = resData.name2
								stringDatas[index].color = COLOR[resData.quality]
							end

						end
					end
					paramIndex = paramIndex + 1
				else
					stringDatas[index] = {["content"] = content[1]}
				end

				if content[2] > 0 then -- 是可点击的
					--活动读取id
					local act = nil
					if chat.sysId == 155 or chat.sysId == 261 or chat.sysId == 262 or chat.sysId == 263 then
						act = chat.param[paramIndex]
					elseif chat.sysId == 156 or chat.sysId == 157 then
						act = chat.param
					elseif chat.sysId == 257 then
						act = json.decode(chat.param[3])
					elseif chat.sysId == 258 then
						act = json.decode(chat.param[1])
					elseif chat.sysId == 278 then
						act = chat.param[3]
					elseif chat.sysId == 280 then
						act = ACTIVITY_ID_BIGWIG_LEADER
					elseif chat.sysId == 281 then
						act = ACTIVITY_ID_REDPACKET
					elseif chat.sysId == 282 then
						act = ACTIVITY_ID_LUCKYROUND
					elseif chat.sysId == 283 then
						act = chat.teamId
					elseif chat.sysId == 284 then
						act = chat.param[3]
					elseif chat.sysId == 293 then --叛军BOSS
						act = chat.param[1]
					elseif chat.sysId == 285 then
						act = chat.param[2]
					end
					stringDatas[index].click = function() gotoChat(chat.sysId,kind,id,act) end
					if not stringDatas[index].color then
						stringDatas[index].color = COLOR[3]
					end
				end
			end
		end
	elseif table.isexist(chat, "uid") then -- 红包
		stringDatas[1] = {["content"] = ""}
	elseif chat.heroId and chat.heroId > 0 then -- 将领分享
		local heroId = chat.heroId
		local heroDB = HeroMO.queryHero(heroId)
		stringDatas[1] = {["content"] = heroDB.heroName, color = COLOR[3], click = function()
				require("app.dialog.HeroDetailDialog").new(heroDB,2):push()
			end}
	else
		local msgs = ChatBO.parseCoordinate(chat.msg)
		for index = 1, #msgs do
			local mg = msgs[index]
			if mg.str then  -- 是信息
				stringDatas[#stringDatas + 1] = {["content"] = mg.str}
			elseif mg.pos then  -- 是坐标
				stringDatas[#stringDatas + 1] = {["content"] = mg.pos.x .. ":" .. mg.pos.y, color = COLOR[3], click = function()
						gprint("x:", mg.pos.x, "y:", mg.pos.y)
						UiDirector.clear()
						Notify.notify(LOCAL_LOCATION_EVENT, {x = mg.pos.x, y = mg.pos.y})
					end}
			end
		end
	end

	return stringDatas
end

function ChatBO.parseCoordinate(msg)
	local tab = {}
	
	-- for x, y in string.gmatch("a192,158b,#哈哈333.eeee,1.2-3,4,5", "(%d*),(%d*)") do
	for k, v in string.gmatch(msg, "(%d*)[：:](%d*)") do
		local x = tonumber(k)
		local y = tonumber(v)
		if (x and x >= 0 and x < WORLD_SIZE_WIDTH) and (y and y >= 0 and y < WORLD_SIZE_HEIGHT) then  -- 需要显示的坐标
			tab[#tab + 1] = cc.p(x, y)
		end
	end

    if #tab > 0 then
		local values = {}
        local posIndex = 1
        for index = 1, #tab do
            local pos = tab[index]

            local s, e = string.find(msg, pos.x .. ":" .. pos.y)
            if s == nil then
            	s, e = string.find(msg, pos.x .. "：" .. pos.y)
            end

            if s == nil then
            	return {{str = msg}}
            end

            local subStr = ""

            subStr = string.sub(msg, posIndex, s - 1)
            if subStr and subStr ~= "" then
                values[#values + 1] = {str = subStr}
            end

            subStr = string.sub(msg, s, e)
            if subStr and subStr ~= "" then
                values[#values + 1] = {pos = pos}
            end
            posIndex = e + 1

            if index == #tab then
                subStr = string.sub(msg, posIndex, string.len(msg))
                if subStr and subStr ~= "" then
                    values[#values + 1] = {str = subStr}
                end
            end
        end
    	return values
    else
    	return {{str = msg}}
    end
end

local shield_file = "shield_0021"

-- 读取屏蔽人列表
function ChatBO.readShieldList()
	ChatMO.shield_ = {}

	local name = shield_file .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId

	local data = readfile(name)
	gdump(data, "ChatBO.readShieldList")
	if data then
		ChatMO.shield_ = json.decode(data)
	end
end

function ChatBO.writeShieldList()
	local name = shield_file .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
	writefile(name, json.encode(ChatMO.shield_))
end

function ChatBO.isShieldFull()
	if #ChatMO.shield_ >= CHAT_SHIELD_NUM then return true
	else return false end
end

function ChatBO.addShield(lordId, nick, portrait, level)
	local shield = ChatBO.getShield(lordId)
	if shield then
		shield[2] = nick
		shield[3] = portrait
		shield[4] = level
	else
		local data = {lordId, nick, portrait, level}
		ChatMO.shield_[#ChatMO.shield_ + 1] = data
	end
	ChatBO.writeShieldList()
end

function ChatBO.deleteShield(lordId)
	local findIndex = 0
	for index = 1, #ChatMO.shield_ do
		local shield = ChatMO.shield_[index]
		if shield[1] == lordId then
			findIndex = index
			break
		end
	end

	if findIndex > 0 then
		table.remove(ChatMO.shield_, findIndex)
		ChatBO.writeShieldList()
	end
end

function ChatBO.isShield(lordId)
	for index = 1, #ChatMO.shield_ do
		local shield = ChatMO.shield_[index]
		if shield[1] == lordId then
			return true
		end
	end
	return false
end

function ChatBO.getShieldByName(name)
	for index = 1, #ChatMO.shield_ do
		local shield = ChatMO.shield_[index]
		if shield[2] == name then
			return shield
		end
	end
end

function ChatBO.getShield(lordId)
	for index = 1, #ChatMO.shield_ do
		local shield = ChatMO.shield_[index]
		if shield[1] == lordId then
			return shield
		end
	end
	return nil
end

function ChatBO.addRecent(lordId, nick, portrait, level)
	local shield = ChatBO.getRecent(nick)
	if shield then
		shield[2] = nick
		shield[3] = portrait
		shield[4] = level
	else
		local data = {lordId, nick, portrait, level}
		ChatMO.recent_[#ChatMO.recent_ + 1] = data
	end
	-- ChatBO.writeRecentList()
end

function ChatBO.getRecent(nick)
	for index = 1, #ChatMO.recent_ do
		local recnt = ChatMO.recent_[index]
		if recnt[2] == nick then
			return recnt
		end
	end
	return nil
end

function ChatBO.parseChatSync(name, data)
	local chat = PbProtocol.decodeRecord(data["chat"])
	gdump(chat, "SERVER CHAT ChatBO.parseChatSync")

	if chat.sysId == 261 then
		local s = string.split(chat.param[2], ":")
		local kind,id = s[1],s[2]
		local refineChat = {}
		refineChat.nick = chat.param[1]
		refineChat.type = kind
		refineChat.id = id
		if chat.param then
			if not ActivityCenterMO.refineMasterChat_ then
				ActivityCenterMO.refineMasterChat_ = {}
			end
			table.insert(ActivityCenterMO.refineMasterChat_,refineChat)
			Notify.notify(LOCAL_REFINE_MASTER)
		end
	end

	local id = nil
	if table.isexist(chat, "id") then id = chat["id"] end

	local param = nil
	if table.isexist(chat, "param") then param = chat["param"] end

	local report = nil
	if table.isexist(chat, "report") then report = chat["report"] end

	local style = 0
	if table.isexist(chat, "style") then style = chat["style"] end

	local tankData = nil
	if table.isexist(chat, "tankData") then tankData = PbProtocol.decodeRecord(chat["tankData"]) end -- 坦克分享

	local medalData = nil
	if table.isexist(chat, "medalData") then medalData = PbProtocol.decodeRecord(chat["medalData"]) end -- 勋章分享

	local sysId = 0
	if table.isexist(chat, "sysId") then sysId = chat["sysId"] end -- 系统消息

	local heroId = 0
	if table.isexist(chat, "heroId") then heroId = chat["heroId"] end -- 将领分享

	local isGm = false
	if table.isexist(chat, "isGm") then isGm = chat["isGm"] end  -- 是否是GM账号

	local isGuider = false
	if table.isexist(chat, "isGuider") then isGuider = chat["isGuider"] end  -- 是否是新手指导员

	local staffing = 0
	if table.isexist(chat, "staffing") then staffing = chat["staffing"] end -- 编制

	local fortressJobId = 0
	if table.isexist(chat, "fortressJobId") then fortressJobId = chat["fortressJobId"] end -- 要塞任命

	local militaryRank = nil
	if table.isexist(chat, "militaryRank") then militaryRank = chat["militaryRank"] end -- 军衔

	local bubble = 0
	if table.isexist(chat, "bubble") then bubble = chat["bubble"] end -- 聊天框

	local teamId = 0
	if table.isexist(chat, "teamId") then teamId = chat["teamId"] end

	local uid = 0
	if table.isexist(chat, "uid") then uid = chat["uid"] end

	local roleId = 0
	if table.isexist(chat, "roleId") then roleId = chat["roleId"] end
	-- gdump(roleId,  "SERVER CHAT ChatBO.roleId == ")

	local crossPlayInfo = {}
	if table.isexist(chat, "crossPlayInfo") then 
		crossPlayInfo = PbProtocol.decodeRecord(chat["crossPlayInfo"]) 
		-- gdump(crossPlayInfo,  "SERVER CHAT ChatBO.crossPlayInfo")
	end

	local shield = ChatBO.getShield(chat.roleId)

	if not shield and style > 0 then -- 使用喇叭
		UiUtil.showHorn(chat)
	end

	-- local shieldServerName = nil
	-- if table.isexist(data, "screenPlayerName") then
	-- 	shieldServerName = data["screenPlayerName"]
	-- end  -- 是否是新手指导员
	-- ChatMO.shieldServerName = shieldServerName

	if shield then -- 是屏蔽的
	else
		local c = ChatMO.addChat(chat.channel, chat.name, chat.portrait, chat.vip, chat.msg, chat.time, id, param, report, style, tankData, sysId, heroId, isGm, isGuider, staffing, chat.name, false, fortressJobId, medalData, militaryRank, bubble, teamId, uid, crossPlayInfo, roleId)
		
		if UiDirector.hasUiByName("HomeView") then
			Notify.notify(LOCAL_SERVER_CHAT_EVENT, {type = chat.channel, nick = chat.name, chat = c})
		end
	end

	--军团任命职位
	if sysId and sysId >= 127 and sysId <= 129 then
		PartyBO.jobAppointed(chat)
	end

	if chat.channel == CHAT_TYPE_PRIVACY then  -- 私聊
		local id = ChatMO.getChatManIdByName(chat.name)
		if id == 0 then
			ChatBO.asynSearchOl(nil, chat.name)
		end
	end

	-- if ChatMO.shieldServerName ~= nil then
	-- 	local data = clone(ChatMO.chat_[CHAT_TYPE_WORLD])
	-- 	local newData = {}
	-- 	for i=1,#data do
	-- 		if tostring(data[i].name) == tostring(ChatMO.shieldServerName) then		
	-- 		else
	-- 			newData[#newData + 1 ] = data[i]
	-- 		end
	-- 	end
	-- 	ChatMO.chat_[CHAT_TYPE_WORLD] = newData
	-- 	Notify.notify(LOCAL_SERVER_CHAT_EVENT, {type = chat.channel, nick = chat.name, chat = c})
	-- end
end

function ChatBO.asynDoChat(doneCallback, channel, target, shareType, msg)
	local function parseDoChat(name, data)
		gdump(data, "[ChatBO] do chat")
		if channel == CHAT_TYPE_PRIVACY then -- 私聊

			local name = ChatMO.getChatManName(target)  -- 我说话的对象

			ChatMO.addChat(channel, UserMO.nickName_, UserMO.portrait_, UserMO.vip_, msg, nil, nil, nil, nil, nil, nil, nil, nil, (UserMO.gm_ ~= 0), (UserMO.guider_ ~= 0), UserMO.staffing_, name, true, FortressMO.myJob(), nil, UserMO.militaryRank_, UserMO.bubble_)

			local man = ChatMO.getManById(target)
			if man and man.lordId ~= UserMO.lordId_ then   -- 添加最近聊天
				ChatBO.addRecent(man.lordId, man.nick, man.icon, man.level)
			end
		elseif channel == CHAT_TYPE_CALLCENTER then
			ChatMO.addChat(channel, UserMO.nickName_, UserMO.portrait_, UserMO.vip_, msg, nil, nil, nil, nil, nil, nil, nil, nil, (UserMO.gm_ ~= 0), (UserMO.guider_ ~= 0), UserMO.staffing_, nil, true, FortressMO.myJob(), nil, UserMO.militaryRank_, UserMO.bubble_)
		end

		if doneCallback then doneCallback() end
	end

	local msg = {msg}

	SocketWrapper.wrapSend(parseDoChat, NetRequest.new("DoChat", {channel = channel, target = target, shareType = shareType, msg = msg}))
end

function ChatBO.asynSearchOl(doneCallback, name)
	local function parseSearch(name, data)
		local man = nil
		if data["man"] then
			man = PbProtocol.decodeRecord(data["man"])
			gdump(man, "[ChatBO] SearchOl")

			ChatMO.addMan(man)
		end

		if doneCallback then doneCallback(man) end
	end
	SocketWrapper.wrapSend(parseSearch, NetRequest.new("SearchOl", {name = name}))
end

function ChatBO.asynShareReport(doneCallback, channel, reportKey, tankData, heroId, medalData)
	local function parseShareReport(name, data)
		gdump(data, "[ChatBO] ShareReport")
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseShareReport, NetRequest.new("ShareReport", {channel = channel, reportKey = reportKey, tankData = tankData, heroId = heroId,medalData = medalData}))
end

function ChatBO.asynGetReport(doneCallback, name, reportKey)
	local function parseGetReport(name, data)
		local report = PbProtocol.decodeRecord(data["report"])
		if report then
			report = MailBO.parseReport(report)
		end
		gdump(report, "ChatBO.asynGetReport")

		if doneCallback then doneCallback(data.state, report) end
	end
	SocketWrapper.wrapSend(parseGetReport, NetRequest.new("GetReport", {name = name, reportKey = reportKey}))
end


function ChatBO.asynTipGuy(doneCallback, lordId, chatMsg)
	local function parseGetReport(name, data)
		local result = data["result"]
		if result then
			Toast.show(CommonText[901])
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseGetReport, NetRequest.new("TipGuy", {lordId = lordId, chatMsg = chatMsg}))
end