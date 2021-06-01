--
-- Author: gf
-- Date: 2015-09-07 14:35:55
--

MailBO = {}

function MailBO.parseSynMail(name, data)
	-- gprint("MailBO.parseSynMail 服务器推送")
	if not data then return end
	
	local mailShow = PbProtocol.decodeRecord(data["show"])
	gdump(mailShow, "MailBO.parseSynMail")
	--排序
	local sortFun = function(a,b)
		return a.time > b.time
	end

	if mailShow.moldId == 25 then
		-- 使用了矿侦查
		local posStr = mailShow.param[4]
		Notify.notify(LOCAL_USE_POS_SCOUT, {pos=posStr})
	elseif mailShow.moldId == 27 then
		local posStr = mailShow.param[2]
		Notify.notify(LOCAL_USE_POS_SCOUT, {pos=posStr})
	end

	if mailShow.type == MAIL_TYPE_PERSON_JJC then
		table.insert(MailMO.myJJCPersonReprot_, mailShow)
		table.sort(MailMO.myJJCPersonReprot_,sortFun)
		Notify.notify(LOCAL_JJC_REPORT_UPDATE_EVENT)
	elseif mailShow.type == MAIL_TYPE_ALL_JJC then
		table.insert(MailMO.myJJCAllReprot_, mailShow)
		table.sort(MailMO.myJJCAllReprot_,sortFun)
		Notify.notify(LOCAL_JJC_REPORT_UPDATE_EVENT)
	else
		table.insert(MailMO.myMails_, mailShow)
		table.sort(MailMO.myMails_,sortFun)
		Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
	end

	TaskBO.asynGetMajorTask()
end

function MailBO.updateMails(data,type)
	if not data then return end

	local mails = PbProtocol.decodeArray(data["mailShow"])
	--排序
	local sortFun = function(a,b)
		return a.time > b.time
	end
	table.sort(mails,sortFun)

	if type == MAIL_TYPE_PERSON_JJC then
		MailMO.myJJCPersonReprot_ = mails
	elseif type == MAIL_TYPE_ALL_JJC then
		MailMO.myJJCAllReprot_ = mails
		-- gdump(MailMO.myJJCAllReprot_,"MailMO.myJJCAllReprot_===")
	else
		local listMail = {}
		--判断是否有已发送的邮件
		local sendMailsCache = MailMO.getMySendMailsCache()
		if sendMailsCache then
			local filterMails = {} --过滤掉服务器的已发邮件
			for index=1,#mails do
				local mail = mails[index]
				if mail.type == MAIL_TYPE_SEND then
					--删除
					SocketWrapper.wrapSend(nil, NetRequest.new("DelMail",{keyId = mail.keyId}))
				else
					filterMails[#filterMails + 1] = mail
				end
			end
			--加入本地缓存的已发邮件
			for index=1,#sendMailsCache do
				filterMails[#filterMails + 1] = sendMailsCache[index]
			end
			listMail = filterMails
		else
			local sendMails = {}
			for index=#mails, 1 , -1 do
				local mail = mails[index]
				if mail.type == MAIL_TYPE_SEND then
					mail.contont = ""
					mail.toName = ""
					sendMails[#sendMails + 1] = mail
					--删除服务器端的已发邮件
					SocketWrapper.wrapSend(nil, NetRequest.new("DelMail",{keyId = mail.keyId}))
					table.remove(mails,index)
				end
			end
			--存储到本地缓存
			-- if #sendMails > 0 then
			-- 	MailMO.saveMySendMailsCache(nil,sendMails)
			-- end
			listMail = mails
		end
		table.sort(listMail,sortFun)
		MailMO.myMails_ = {}
		MailMO.myMails_ = listMail
	end
	gdump(MailMO.myMails_,"MailBO.updateMails(data)")
end

function MailBO.getMails(doneCallback,type)
	local function parseUpgrade(name, data)
		MailBO.updateMails(data,type)

		if doneCallback then doneCallback() end
	end
	local param
	if type then
		param = {type = type}
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetMailList",param))
end


function MailBO.asynGetMailById(doneCallback,keyId,type)
	local function parseUpgrade(name, data)
		local mailDB
		if table.isexist(data, "mail") then
			mailDB = MailBO.parseMail(PbProtocol.decodeRecord(data["mail"]))
			if table.isexist(data, "friendState") then
				mailDB.isOther = data.friendState
			end
			for index=1,#MailMO.myMails_ do
				local mail =  MailMO.myMails_[index]
				if mail.keyId == mailDB.keyId then
					mail.report = {}
					mail.award = {}
					mail.man = {}
					table.merge(mail,mailDB)
					break
				end
			end
		end

		-- gdump(mailDB,"mail content")
		Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
		if doneCallback then doneCallback(mailDB) end
	end
	local param = {}
	if keyId then
		param.keyId = keyId
	end
	if type then
		param.type = type
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetMailById",param))
end

function MailBO.asynGetJJCReportById(doneCallback,keyId,type)
	local function parseUpgrade(name, data)
		local mailDB
		if table.isexist(data, "mail") then
			mailDB = MailBO.parseMail(PbProtocol.decodeRecord(data["mail"]))
			local mails = {}
			if type == MAIL_TYPE_PERSON_JJC then
				mails = MailMO.myJJCPersonReprot_
			else
				mails = MailMO.myJJCAllReprot_
			end
			for index=1,#mails do
				local mail =  mails[index]
				if mail.keyId == mailDB.keyId then
					mail.report = {}
					mail.award = {}
					mail.man = {}
					table.merge(mail,mailDB)
					break
				end
			end
		end
		-- gdump(mailDB,"mail content")
		Notify.notify(LOCAL_JJC_REPORT_UPDATE_EVENT)
		if doneCallback then doneCallback(mailDB) end
	end
	local param = {}
	if keyId then
		param.keyId = keyId
	end
	if type then
		param.type = type
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetMailById",param))
end

function MailBO.mailHasGet(keyId)
	for index=1,#MailMO.myMails_ do
		local mail =  MailMO.myMails_[index]
		if mail.keyId == keyId and table.isexist(mail, "report") then
			return mail
		end
	end
	return nil
end


function MailBO.asynDelMail(doneCallback,delMail,type)
	local function parseUpgrade(name, data)
		--删除
		if delMail then
			for index = 1,#MailMO.myMails_ do
				if MailMO.myMails_[index].keyId == delMail.keyId then
					table.remove(MailMO.myMails_,index)
					break
				end
			end
		else
			local list = {}
			for index = 1,#MailMO.myMails_ do
				if MailMO.myMails_[index].type ~= type then
					if type ~= MAIL_TYPE_REPORT or MailMO.myMails_[index].type ~= MAIL_TYPE_REPORT_AS then
						list[#list + 1] = MailMO.myMails_[index]
					end
				end
			end
			MailMO.myMails_ = list
		end
		
		Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end

	if delMail then
		if delMail.type == MAIL_TYPE_SEND then
			for index = 1,#MailMO.myMails_ do
				local mail = MailMO.myMails_[index]
				if mail.type == MAIL_TYPE_SEND and mail.time == delMail.time then
					table.remove(MailMO.myMails_,index)
					break
				end
			end
			Notify.notify(LOCAL_MAIL_UPDATE_EVENT)

			local sendMailsCache = MailMO.getMySendMailsCache()
			gdump(sendMailsCache,"sendMailsCache==")
			for index=1,#sendMailsCache do
				local mail = sendMailsCache[index]
				if tostring(mail.time) == tostring(delMail.time) then
					table.remove(sendMailsCache,index)
					break
				end
			end
			
			MailMO.saveMySendMailsCache(doneCallback,sendMailsCache)
		else
			SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DelMail",{keyId = delMail.keyId}))
		end
	elseif type then
		if type == MAIL_TYPE_SEND then
			local list = {}
			for index = 1,#MailMO.myMails_ do
				if MailMO.myMails_[index].type ~= type then
					list[#list + 1] = MailMO.myMails_[index]
				end
			end
			MailMO.myMails_ = list
			Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
			MailMO.saveMySendMailsCache(doneCallback,{})
		else
			if type == MAIL_TYPE_REPORT then
				SocketWrapper.wrapSend(nil, NetRequest.new("DelMail",{keyId = 0,type = MAIL_TYPE_REPORT_AS}))
			end
			SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DelMail",{keyId = 0,type = type}))
		end
	end
	
end

function MailBO.asynDelJJCReport(doneCallback,keyId,type)
	local function parseUpgrade(name, data)
		if type == MAIL_TYPE_PERSON_JJC then
			--删除
			if keyId > 0 then
				for index = 1,#MailMO.myJJCPersonReprot_ do
					if MailMO.myJJCPersonReprot_[index].keyId == keyId then
						table.remove(MailMO.myJJCPersonReprot_,index)
						break
					end
				end
			else
				MailMO.myJJCPersonReprot_ = {}
			end
		else
			--删除
			if keyId > 0 then
				for index = 1,#MailMO.myJJCAllReprot_ do
					if MailMO.myJJCAllReprot_[index].keyId == keyId then
						table.remove(MailMO.myJJCAllReprot_,index)
						break
					end
				end
			else
				MailMO.myJJCAllReprot_ = {}
			end
		end

		gdump(MailMO.myJJCPersonReprot_,"MailMO.myJJCPersonReprot_")
		
		Notify.notify(LOCAL_JJC_REPORT_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	local param = {}
	if keyId > 0 then
		param.keyId = keyId
	else
		param.keyId = 0
	end
	if type then
		param.type = type
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DelMail",param))
end




function MailBO.asynSendMail(doneCallback,mail,type)
	local function parseUpgrade(name, data)
		--添加已发送邮件到本地缓存
		if type == MAIL_SEND_TYPE_NORMAL then
			local sendMails = MailMO.getMySendMailsCache()
			if not sendMails then sendMails = {} end
			local newSendMail = {
				contont = mail.contont,
				moldId = 0,
				param = {},
				sendName = mail.sendName,
				state = 2,
				time = ManagerTimer.getTime(),
				title = mail.title,
				toName = mail.toName,
				type = MAIL_TYPE_SEND
			}
			sendMails[#sendMails + 1] = newSendMail
			MailMO.myMails_[#MailMO.myMails_ + 1] = newSendMail
			MailMO.saveMySendMailsCache(doneCallback,sendMails)
			Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
		else
			if doneCallback then doneCallback() end
		end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("SendMail",{mail = mail,type = type}))
end

function MailBO.asynRewardMail(doneCallback,mail)
	local function parseUpgrade(name, data)
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)

			--TK统计 金币获得
			for index=1,#awards do
				local award = awards[index]
				if award.type == ITEM_KIND_COIN then
					TKGameBO.onReward(award.count, TKText[3])
				end
			end

			for index=1,#MailMO.myMails_ do
				local mailDB =  MailMO.myMails_[index]
				if mail.keyId == mailDB.keyId then
					--更改邮件状态
					mailDB.state = MailMO.MAIL_STATE_READ_AWARD_GET
					break
				end
			end
			mail.state = MailMO.MAIL_STATE_READ_AWARD_GET
		end
		if doneCallback then doneCallback(mail) end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("RewardMail",{keyId = mail.keyId}))
end




function MailBO.getNewMailCount(type)
	if type == MAIL_TYPE_SEND then return 0 end
	
	local mails
	if type then
		mails = MailMO.queryMyMails_(type)
	else
		mails = MailMO.myMails_
	end
	-- gdump(mails,"MailBO.getNewMailCount")
	local count = 0
	for index=1,#mails do
		local mail = mails[index]
		if mail.type ~= MAIL_TYPE_SEND
			and (mail.state == MailMO.MAIL_STATE_NEW 
			or mail.state == MailMO.MAIL_STATE_NEW_AWARD) then
			count = count + 1
		end
	end
	-- gdump(mails,"my all mails")
	return count
end

function MailBO.nicksIsYes(nicks)
	if not nicks or #nicks == 0 then
		Toast.show(CommonText[554][2])
		return false
	end
	local is = true
	for index=1,#nicks do
		local nick = string.gsub(nicks[index], " ", "")
		if nick == "" or nick == UserMO.nickName_ then
			is = false
			break
		end
	end
	return is
end

function MailBO.nickListToString(nicks)
	local nickString = ""
	if nicks then
		for index=1,#nicks do
			nickString = nickString .. nicks[index] .. ","
		end
	end
	
	nickString = string.sub(nickString,1,string.len(nickString) - 1)
	return nickString
end

-- 获得报告分享的标题
function MailBO.parseShareTitle(moldId, param, name)
	local mailInfo = MailMO.queryMail(moldId)
	if not mailInfo then return "" end

	if mailInfo.type == MAIL_TYPE_REPORT then --战报
		if moldId == 9 or moldId == 10 or moldId == 11 or moldId == 51 or moldId == 97 or moldId == 98 or moldId == 100  or moldId == 167 or moldId == 168 then
			return string.format(mailInfo.mtitle, param[1], param[2])
		elseif moldId == 18 or moldId == 19 or moldId == 52 or moldId == 53 or moldId == 99 or moldId == 101 or moldId == 166 or moldId == 169 or moldId == 170 then
			return string.format(mailInfo.mtitle, param[2], UserMO.getResourceData(ITEM_KIND_WORLD_RES, tonumber(param[1])).name2, param[2])
		elseif moldId == 71 or moldId == 72 or moldId == 102 then
			local rd = RebelMO.queryHeroById(tonumber(param[1]))
			local hd = HeroMO.queryHero(rd.associate)
			local title = string.format(mailInfo.mtitle, param[2], hd.heroName, param[2])
			if rd.teamType == 4 then
				if moldId == 71 then
					title = string.format(CommonText[1883], param[2], hd.heroName, param[2])
				else
					title = string.format(CommonText[1882], param[2], hd.heroName, param[2])
				end
			end

			return title
		elseif moldId == 125 or moldId == 126 or moldId == 129 then
			local rd = RebelMO.getTeamById(tonumber(param[1]))
			return string.format(mailInfo.mtitle, rd.name, param[2])
		else
			return mailInfo.mtitle
		end
	elseif mailInfo.type == MAIL_TYPE_PLAYER or mailInfo.type == MAIL_TYPE_STSTEM then --系统
		return mailInfo.mtitle
	elseif mailInfo.type == MAIL_TYPE_PERSON_JJC or mailInfo.type == MAIL_TYPE_ALL_JJC then ---竞技场
		local mtitle = mailInfo.mtitle
		if #param == 1 then
			return mailInfo.sname .. ":" .. string.format(mtitle, param[1])
		elseif #mail.param == 2 then
			return mailInfo.sname .. ":" .. string.format(mtitle, param[1], param[2])
		end
	elseif mailInfo.type == MAIL_TYPE_REPORT_AS then ---飞艇
		return mailInfo.mtitle
	end

	return "XX"
end

function MailBO.parseMailTitleAndCon(mail)
	if not mail.moldId or mail.moldId == 0 then return mail end
	local title,content
	local mailInfo = MailMO.queryMail(mail.moldId)
	if not mailInfo then return mail end
	if mailInfo.type == MAIL_TYPE_REPORT then --战报
		mail.sendName = mailInfo.sname
		if mail.moldId == 9 or mail.moldId == 10 or mail.moldId == 11 or mail.moldId == 51 or mail.moldId == 97 or mail.moldId == 98 or mail.moldId == 100  or mail.moldId == 167 or mail.moldId == 168 then
			local str = string.format(mailInfo.mtitle,mail.param[1],mail.param[2])
			mail.title = str
		elseif mail.moldId == 18 or mail.moldId == 19 or mail.moldId == 52 or mail.moldId == 53 or mail.moldId == 99 or mail.moldId == 101 or mail.moldId == 166 or mail.moldId == 169 or mail.moldId == 170 then
			mail.title = string.format(mailInfo.mtitle,mail.param[2],UserMO.getResourceData(ITEM_KIND_WORLD_RES, tonumber(mail.param[1])).name2,mail.param[2])
		elseif mail.moldId == 71 or mail.moldId == 72 or mail.moldId == 102 then
			local rd = RebelMO.queryHeroById(tonumber(mail.param[1]))
			local hd = HeroMO.queryHero(rd.associate)
			mail.title = string.format(mailInfo.mtitle, mail.param[2], hd.heroName, mail.param[2])
			if rd.teamType == 4 then
				if mail.moldId == 71 then
					mail.title = string.format(CommonText[1883], mail.param[2], hd.heroName, mail.param[2])
				else
					mail.title = string.format(CommonText[1882], mail.param[2], hd.heroName, mail.param[2])
				end
			end
		elseif mail.moldId == 125 or mail.moldId == 126 or mail.moldId == 129 then
			local rd = RebelMO.getTeamById(tonumber(mail.param[1]))
			mail.title = string.format(mailInfo.mtitle, rd.name, mail.param[2])
		else
			mail.title = mailInfo.mtitle
			local param = clone(mail.param)
			content = ""
			local contentList = string.split(mailInfo.mcontent, "|")  
			for index=1,#contentList do
				local str
				if contentList[index] == "%s" then
					str = table.remove(param,1)
				else
					str = contentList[index]
				end
				if str then
					content = content .. str
				end
			end
			mail.contont = content
		end
	elseif mailInfo.type == MAIL_TYPE_PLAYER or mailInfo.type == MAIL_TYPE_STSTEM then --系统
		mail.sendName = mailInfo.sname
		mail.title = mailInfo.mtitle
		local param = clone(mail.param)

		--发送坐标邮件特殊处理
		if mail.moldId == 25 then
			local pos = WorldMO.decodePosition(tonumber(param[4]))
			local posStr = "(" .. pos.x  .. "," .. pos.y ..  ")"
			param[4] = posStr

			local mineName = UserMO.getResourceData(ITEM_KIND_WORLD_RES, tonumber(param[3])).name2
			if mineName then
				param[3] = mineName
			end
		elseif mail.moldId == 27 then
			local pos = WorldMO.decodePosition(tonumber(param[2]))
			local posStr = "(" .. pos.x  .. "," .. pos.y ..  ")"
			param[2] = posStr
		elseif mail.moldId == 3 then
			param[1] = UserMO.getResourceData(ITEM_KIND_WORLD_RES, tonumber(param[1])).name2
		elseif mail.moldId == 20 or mail.moldId == 7 then
			local pos = WorldMO.decodePosition(tonumber(param[1]))
			local posStr = "(" .. pos.x  .. "," .. pos.y ..  ")"
			param[1] = posStr
		elseif mail.moldId == 44 or mail.moldId == 60 then
			if param[3] and param[3] ~= "" then
				local tanks,tankId,tankCount
				local list = string.split(param[3], "&")
				tanks = {}
				for index=1,#list do
					local d = list[index]
					if d ~= "" then
						local dd = string.split(d, "|")
						local data = {type = ITEM_KIND_TANK,id = tonumber(dd[1]) ,count = tonumber(dd[2])}
						tanks[#tanks + 1] = data
					end
				end
				tanks = TKGameBO.arrangeAwards(tanks)
				gdump(tanks,"mail tanks==")
				local str = ""
				for index=1,#tanks do
					local tank = tanks[index]
					if tank.id and tank.count and tank.kind then
						str = str .. UserMO.getResourceData(tank.kind, tank.id).name .. "*" .. tank.count
					end
					if index < #tanks then
						str = str .. "、"
					end
				end
				param[3] = str
			else
				param[3] = CommonText[509]
			end
		elseif mail.moldId == 152 or mail.moldId == 151 then -- 带军功
			if param[4] and param[4] ~= "" then
				local tanks,tankId,tankCount
				local list = string.split(param[4], "&")
				tanks = {}
				for index=1,#list do
					local d = list[index]
					if d ~= "" then
						local dd = string.split(d, "|")
						local data = {type = ITEM_KIND_TANK,id = tonumber(dd[1]) ,count = tonumber(dd[2])}
						tanks[#tanks + 1] = data
					end
				end
				tanks = TKGameBO.arrangeAwards(tanks)
				gdump(tanks,"mail tanks==")
				local str = ""
				for index=1,#tanks do
					local tank = tanks[index]
					if tank.id and tank.count and tank.kind then
						str = str .. UserMO.getResourceData(tank.kind, tank.id).name .. "*" .. tank.count
					end
					if index < #tanks then
						str = str .. "、"
					end
				end
				param[4] = str
			else
				param[4] = CommonText[509]
			end
		elseif mail.moldId == 49 or mail.moldId == 50 then
			mail.title = param[1]
			param[1] = param[2]
			param[2] = nil
		elseif mail.moldId == 131 then
			if GameConfig.environment == "chhjfc_gionee_client" then
				mail.title = "欢迎邮件"
				mailInfo.mtitle = "欢迎邮件"
				mailInfo.mcontent = "报告指挥官，非常感谢您及时来到前线战场，当前我军遭受到各方攻击，战况紧急，正在等您发号施令，突破重围！"
			end			
		elseif mail.moldId == 132 then
			local airshipId = tonumber(param[2])
			local ab = AirshipMO.queryShipById(airshipId)
			param[2] = ab.name			
		elseif mail.moldId == 139 then ---飞艇位置占用
			local pos = WorldMO.decodePosition(tonumber(param[1]))
			local posStr = pos.x  .. "," .. pos.y
			param[1] = posStr		
		elseif mail.moldId == 140 or mail.moldId == 133 then
			local airshipId = tonumber(param[1])
			local ab = AirshipMO.queryShipById(airshipId)
			param[1] = ab.name
		elseif mail.moldId == 157 then
			local str = ""
			local cd = ManagerTimer.time(param[1])
			if cd.day > 0 then str = str .. cd.day .. CommonText[159][4] end
			if cd.hour > 0 then str = str .. cd.hour .. CommonText[159][3] end
			if cd.minute > 0 then str = str .. cd.minute .. CommonText[159][5] end
			if cd.second > 0 then str = str .. cd.second .. CommonText[159][1] end
			param[1] = str
		end

		--充值丰收邮件内容特殊处理
		if mail.moldId == 40 then
			param[2] = UiUtil.strNumSimplify(tonumber(param[2]))
		end

		content = ""
		local contentList = string.split(mailInfo.mcontent, "|")  
		for index=1,#contentList do
			local str
			if contentList[index] == "%s" then
				str = table.remove(param,1)
				if mail.moldId == 73 then
					local eb = EffectMO.queryEffectById(tonumber(str))
					str= "["..eb.name.."]"					
				end
			else
				str = contentList[index]
			end
			if str then
				content = content .. str
			end
		end
		mail.contont = content
	elseif mailInfo.type == MAIL_TYPE_PERSON_JJC or mailInfo.type == MAIL_TYPE_ALL_JJC then ---竞技场
		-- gdump(mail,"mailmailmail")
		mail.sendName = mailInfo.sname
		local mtitle = mailInfo.mtitle
		if #mail.param == 1 then
			mail.title = string.format(mtitle,mail.param[1])
		elseif #mail.param == 2 then
			mail.title = string.format(mtitle,mail.param[1],mail.param[2])
		end
	elseif mailInfo.type == MAIL_TYPE_REPORT_AS then ----飞艇战报
		mail.sendName = mailInfo.sname
		mail.title = mailInfo.mtitle
		local param = clone(mail.param)

		if mail.moldId == 134 then
			local airshipId = tonumber(param[1])
			local ab = AirshipMO.queryShipById(airshipId)
			param[1] = ab.name			
		elseif mail.moldId == 135 or mail.moldId == 136 then 
			if param[1] == "" then
				param[1] = CommonText[1034]
			end

			local airshipId = tonumber(param[2])
			local ab = AirshipMO.queryShipById(airshipId)
			param[2] = ab.name				
		end

		content = ""
		local contentList = string.split(mailInfo.mcontent, "|")  
		for index=1,#contentList do
			local str
			if contentList[index] == "%s" then
				str = table.remove(param,1)
			else
				str = contentList[index]
			end
			if str then
				content = content .. str
			end
		end
		mail.contont = content		
	end
	return mail
end

function MailBO.parseGrab(grab)
	if grab then
		grab =PbProtocol.decodeRecord(grab)
	end
	
	-- if not grab then return {}, 0 end

	local ret = {}

	ret[#ret + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_STONE, count = 0}
	if grab and table.isexist(grab, "stone") then ret[#ret].count = grab.stone end
	
	ret[#ret + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_IRON, count = 0}
	if grab and table.isexist(grab, "iron") then ret[#ret].count = grab.iron end

	ret[#ret + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_OIL, count = 0}
	if grab and table.isexist(grab, "oil") then ret[#ret].count = grab.oil end

	ret[#ret + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_COPPER, count = 0}
	if grab and table.isexist(grab, "copper") then ret[#ret].count = grab.copper end

	ret[#ret + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_SILICON, count = 0}
	if grab and table.isexist(grab, "silicon") then ret[#ret].count = grab.silicon end


	local total = 0
	for index = 1, #ret do
		local res = ret[index]
		total = total + res.count
	end
	return ret, total
end

function MailBO.parseRptMan(rptMan)
	local ret = {}
	ret.pos = rptMan.pos
	ret.name = rptMan.name
	ret.vip = rptMan.vip
	ret.pros = rptMan.pros
	ret.prosMax = rptMan.prosMax
	ret.party = rptMan.party
	ret.hero = rptMan.hero
	ret.prosAdd = rptMan.prosAdd
	ret.tank = PbProtocol.decodeArray(rptMan["tank"])
	if table.isexist(rptMan, "mplt") then ret.mplt = rptMan.mplt end
	if table.isexist(rptMan, "firstValue") then ret.firstValue = rptMan.firstValue end
	if table.isexist(rptMan, "serverName") then ret.serverName = rptMan.serverName end
	return ret
end

function MailBO.parseRptMine(rptMine)
	local ret = {}
	ret.pos = rptMine.pos
	ret.mine = rptMine.mine
	ret.lv = rptMine.lv
	ret.name = rptMine.name
	ret.vip = rptMine.vip
	ret.party = rptMine.party
	ret.hero = rptMine.hero
	ret.tank = PbProtocol.decodeArray(rptMine["tank"])
	if table.isexist(rptMine, "mplt") then ret.mplt = rptMine.mplt end
	if table.isexist(rptMine, "firstValue") then ret.firstValue = rptMine.firstValue end
	if table.isexist(rptMine, "serverName") then ret.serverName = rptMine.serverName end
	return ret
end

function MailBO.parseRptAtk(atk,reportType)
	local ret = {}
	ret.result = atk.result
	ret.first = atk.first
	if table.isexist(atk, "honour") then
		ret.honour = atk.honour
	end
	if reportType ~= DEFENCE_TYPE_ATTACK_AIRSHIP and reportType ~= DEFENCE_TYPE_DEFENCEE_AIRSHIP then
		ret.attacker = MailBO.parseRptMan(PbProtocol.decodeRecord(atk["attacker"]))
		if table.isexist(atk, "friend") then
			ret.friend = atk.friend
		end
		if table.isexist(atk, "defencer") then
			if reportType == DEFENCE_TYPE_ATTACK_MINE or reportType == DEFENCE_TYPE_DEFENCE_MINE then
				ret.defencer = MailBO.parseRptMine(PbProtocol.decodeRecord(atk["defencer"])) 
			else
				ret.defencer = MailBO.parseRptMan(PbProtocol.decodeRecord(atk["defencer"]))
			end
		end
	else
		ret.attacker = {name = atk.attackerName}
		local ab = AirshipMO.queryShipById(atk.airshipId)
		ret.defencer = {name = atk.defencerName, pos = ab.pos}
		if atk.defencerName == "" then
			ret.defencer.name = AirshipMO.queryShipById(atk.airshipId).name
		end
		ret.attackers = PbProtocol.decodeArray(atk.attackers)
		ret.defencers = PbProtocol.decodeArray(atk.defencers)
		ret.airshipId = atk.airshipId
	end
	if table.isexist(atk, "grab") then
		ret.grab = atk.grab
	end
	if table.isexist(atk, "record") then
		ret.record = atk["record"]
	end
	if table.isexist(atk, "award") then
		ret.award = PbProtocol.decodeArray(atk["award"])
	end
	if table.isexist(atk, "winStaffingExp") then
		ret.winStaffingExp = atk.winStaffingExp
	end
	if table.isexist(atk, "failStaffingExp") then
		ret.failStaffingExp = atk.failStaffingExp
	end
	if table.isexist(atk, "staffingExpAdd") then
		ret.staffingExpAdd = atk.staffingExpAdd
	end
	if table.isexist(atk, "honourGoldWin") then
		ret.honourGoldWin = atk.honourGoldWin
	end
	if table.isexist(atk, "honourGoldFail") then
		ret.honourGoldFail = atk.honourGoldFail
	end
	if table.isexist(atk, "plunderGold") then
		ret.plunderGold = atk.plunderGold
	end
	if table.isexist(atk, "defPlunderGold") then
		ret.defPlunderGold = atk.defPlunderGold
	end
	if table.isexist(atk, "grabScore") then
		ret.grabScore = atk.grabScore
	end
	if table.isexist(atk, "demageScore") then
		ret.demageScore = atk.demageScore
	end

	--友好度
	if table.isexist(atk, "friendliness") then
		ret.friendliness = atk["friendliness"]
	end
	return ret
end

function MailBO.parseRptManAirshp( rptMans )
	local ret = {}
	local mans = PbProtocol.decodeArray(rptMans)
	for i,v in ipairs(mans) do
		local rpt = {}
		rpt.lordId = v.lordId	
		rpt.name = v.name	
		rpt.commander = v.commander	
		if table.isexist(v, "mplt") then
			rpt.mplt = v.mplt				
		end
		if table.isexist(v, "firstValue") then
			rpt.firstValue = v.firstValue				
		end
		rpt.tank = PbProtocol.decodeArray(v.tank)
		ret[i] = rpt
	end

	return ret
end

function MailBO.parseRptAtkAirShip(atk)
	local ret = {}
	ret.result = atk.result
	ret.first = atk.first
	if table.isexist(atk, "honour") then
		ret.honour = atk.honour
	end
	
	ret.attacker = {name = atk.attackerName}
	local ab = AirshipMO.queryShipById(atk.airshipId)
	ret.defencer = {name = atk.defencerName, pos = ab.pos}
	if atk.defencerName == "" then
		ret.defencer.name = AirshipMO.queryShipById(atk.airshipId).name
	end

	ret.attackers = MailBO.parseRptManAirshp(atk.attackers)
	ret.defencers = MailBO.parseRptManAirshp(atk.defencers)
	ret.recordLord = PbProtocol.decodeArray(atk.recordLord)

	ret.airshipId = atk.airshipId

	if table.isexist(atk, "grab") then
		ret.grab = atk.grab
	end
	if table.isexist(atk, "record") then
		ret.record = atk["record"]
	end
	if table.isexist(atk, "award") then
		ret.award = PbProtocol.decodeArray(atk["award"])
	end
	if table.isexist(atk, "winStaffingExp") then
		ret.winStaffingExp = atk.winStaffingExp
	end
	if table.isexist(atk, "failStaffingExp") then
		ret.failStaffingExp = atk.failStaffingExp
	end
	if table.isexist(atk, "staffingExpAdd") then
		ret.staffingExpAdd = atk.staffingExpAdd
	end
	if table.isexist(atk, "lostDurb") then
		ret.lostDurb = atk.lostDurb
	end	
	if table.isexist(atk, "remainDurb") then
		ret.remainDurb = atk.remainDurb
	end		
	return ret
end

function MailBO.parseRptAtkArena(atk)
	local ret = {}
	ret.result = atk.result
	ret.first = atk.first
	ret.attacker = MailBO.parseRptMan(PbProtocol.decodeRecord(atk["attacker"]))

	if table.isexist(atk, "defencer") then
		ret.defencer = MailBO.parseRptMan(PbProtocol.decodeRecord(atk["defencer"])) 
	end
	if table.isexist(atk, "record") then
		ret.record = atk["record"]
	end
	if table.isexist(atk, "award") then
		ret.award = PbProtocol.decodeArray(atk["award"])
	end
	return ret
end

function MailBO.parseMail(mail)
	local ret = {}
	ret.keyId = mail.keyId
	ret.type = mail.type
	ret.title = mail.title
	ret.sendName = mail.sendName
	ret.toName = mail.toName
	ret.state = mail.state
	ret.time = mail.time
	ret.param = mail.param
	ret.lv = mail.lv
	ret.vipLv = mail.vipLv
	ret.isCollections = mail.isCollections

	if table.isexist(mail, "contont") then ret.contont = mail.contont end
	if table.isexist(mail, "moldId") then ret.moldId = mail.moldId end

	if table.isexist(mail, "award") then ret.award = PbProtocol.decodeArray(mail["award"]) end


	if table.isexist(mail, "report") then
		-- local rp = {}
		local report = PbProtocol.decodeRecord(mail["report"])
		-- if table.isexist(report, "scoutHome") then rp.scoutHome = PbProtocol.decodeRecord(report["scoutHome"]) end
		-- if table.isexist(report, "scoutMine") then rp.scoutMine = PbProtocol.decodeRecord(report["scoutMine"]) end
		-- if table.isexist(report, "atkHome") then rp.atkHome = PbProtocol.decodeRecord(report["atkHome"]) end
		-- if table.isexist(report, "atkMine") then rp.atkMine = PbProtocol.decodeRecord(report["atkMine"]) end
		-- if table.isexist(report, "defHome") then rp.defHome = PbProtocol.decodeRecord(report["defHome"]) end
		-- if table.isexist(report, "defMine") then rp.defMine = PbProtocol.decodeRecord(report["defMine"]) end
		-- if table.isexist(report, "atkArena") then rp.atkArena = PbProtocol.decodeRecord(report["atkArena"]) end
		-- if table.isexist(report, "defArena") then rp.defArena = PbProtocol.decodeRecord(report["defArena"]) end
		-- if table.isexist(report, "globalArena") then rp.globalArena = PbProtocol.decodeRecord(report["globalArena"]) end

		-- ret.report = rp
		ret.report = MailBO.parseReport(report)
	end

	ret = MailBO.parseMailTitleAndCon(ret)
	return ret
end

function MailBO.parseReport(report)
	local rp = {}
	if table.isexist(report, "scoutHome") then rp.scoutHome = PbProtocol.decodeRecord(report["scoutHome"]) end
	if table.isexist(report, "scoutMine") then rp.scoutMine = PbProtocol.decodeRecord(report["scoutMine"]) end
	if table.isexist(report, "scoutRebel") then rp.scoutRebel = PbProtocol.decodeRecord(report["scoutRebel"]) end
	if table.isexist(report, "atkHome") then rp.atkHome = PbProtocol.decodeRecord(report["atkHome"]) end
	if table.isexist(report, "atkMine") then rp.atkMine = PbProtocol.decodeRecord(report["atkMine"]) end
	if table.isexist(report, "defHome") then rp.defHome = PbProtocol.decodeRecord(report["defHome"]) end
	if table.isexist(report, "defMine") then rp.defMine = PbProtocol.decodeRecord(report["defMine"]) end
	if table.isexist(report, "atkArena") then rp.atkArena = PbProtocol.decodeRecord(report["atkArena"]) end
	if table.isexist(report, "defArena") then rp.defArena = PbProtocol.decodeRecord(report["defArena"]) end
	if table.isexist(report, "globalArena") then rp.globalArena = PbProtocol.decodeRecord(report["globalArena"]) end
	if table.isexist(report, "atkAirship") then rp.atkAirship = PbProtocol.decodeRecord(report["atkAirship"]) end
	if table.isexist(report, "defAirship") then rp.defAirship = PbProtocol.decodeRecord(report["defAirship"]) end
	rp.time = report.time
	return rp
end

function MailBO.getNewReportCount(type)
	local mails
	if type == MAIL_TYPE_PERSON_JJC then
		mails = MailMO.myJJCPersonReprot_
	elseif type == MAIL_TYPE_ALL_JJC then
		mails = MailMO.myJJCAllReprot_
	end
	local count = 0
	for index=1,#mails do
		local mail = mails[index]
		if mail.state == MailMO.MAIL_STATE_NEW 
			or mail.state == MailMO.MAIL_STATE_NEW_AWARD then
			count = count + 1
		end
	end
	return count
end

function MailBO.getHasAwardsMail()
	for index=1,#MailMO.myMails_ do
		local mail = MailMO.myMails_[index]
		if mail.state == MailMO.MAIL_STATE_NEW_AWARD or mail.state == MailMO.MAIL_STATE_READ_AWARD then
			return true
		end
	end
	return false
end

--邮件一键领取
function MailBO.rewardMailAwards(rhand,type)
	local mtype = type
	local function parseUpgrade(name, data)
		Loading.getInstance():unshow()
			local awards = PbProtocol.decodeArray(data["award"])
			local statsAward = nil
			if awards then
				statsAward = CombatBO.addAwards(awards)
				UiUtil.showAwards(statsAward)
			end
			--TK统计 金币获得
			for index=1,#awards do
				local award = awards[index]
				if award.type == ITEM_KIND_COIN then
					TKGameBO.onReward(award.count, TKText[3])
				end
			end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("RewardAllMail",{type = mtype}))
end

--邮件到期推送接收
function MailBO.SyncMail(name,data)
	local awards = PbProtocol.decodeArray(data["award"])
	local statsAward = nil
	if awards then
		statsAward = CombatBO.addAwards(awards)
	end
	--TK统计 金币获得
	for index=1,#awards do
		local award = awards[index]
		if award.type == ITEM_KIND_COIN then
			TKGameBO.onReward(award.count, TKText[3])
		end
	end
	MailBO.getMails(function ()
		Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
	end)
end

--邮件收藏
function MailBO.CollectMial(keyId, kind, callBack)
	local function parseUpgrade(name, data)
		Loading.getInstance():unshow()
		if data.keyId > 0 then
			for index = 1,#MailMO.myMails_ do
				if MailMO.myMails_[index].keyId == data.keyId then
					MailMO.myMails_[index].isCollections = kind
					break
				end
			end
			Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
			if callBack then callBack(true) end
		else
			if callBack then callBack(false) end
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("CollectionsMail",{type = kind, keyId = keyId}))
end

--新删除邮件
-- kind 邮件类型，
-- delKind，删除类型
function MailBO.deleteMials(doneCallback, kind, delKind)
	local function parseUpgrade(name, data)
		Loading.getInstance():unshow()
		--删除
		local list = {}
		if kind ~= 4 then --如果不是系统邮件分页
			if delKind == MAIL_DELETE_TYPE_ALL then --如果是删除所有的邮件,收藏的不做删除
				if kind == MAIL_TYPE_REPORT then --如果是战报。特殊处理,包含飞艇和战报的
					for index = 1,#MailMO.myMails_ do
						local mail = MailMO.myMails_[index]
						if ((MailMO.myMails_[index].type == kind or MailMO.myMails_[index].type == MAIL_TYPE_REPORT_AS) and MailMO.myMails_[index].isCollections ~= MAIL_COLLECT_TYPE_NORMAL) or (MailMO.myMails_[index].type ~= kind and MailMO.myMails_[index].type ~= MAIL_TYPE_REPORT_AS) then
							list[#list + 1] = mail
						end
					end
				else
					for index = 1,#MailMO.myMails_ do
						local mail = MailMO.myMails_[index]
						if (MailMO.myMails_[index].type == kind and MailMO.myMails_[index].isCollections ~= MAIL_COLLECT_TYPE_NORMAL) or MailMO.myMails_[index].type ~= kind then
							list[#list + 1] = mail
						end
					end
				end
			elseif delKind == MAIL_DELETE_TYPE_READED then --如果是删除已读的邮件
				if kind == MAIL_TYPE_REPORT then
					for index = 1,#MailMO.myMails_ do
						local mail = MailMO.myMails_[index]
						if MailMO.myMails_[index].isCollections ~= MAIL_COLLECT_TYPE_NORMAL
						 or ((MailMO.myMails_[index].type == kind or MailMO.myMails_[index].type == MAIL_TYPE_REPORT_AS) and MailMO.myMails_[index].state ~= MailMO.MAIL_STATE_READ)
						 or (MailMO.myMails_[index].type ~= kind and MailMO.myMails_[index].type ~= MAIL_TYPE_REPORT_AS) then
							list[#list + 1] = mail
						end
					end
				else
					for index = 1,#MailMO.myMails_ do
						local mail = MailMO.myMails_[index]
						if (MailMO.myMails_[index].type == kind and MailMO.myMails_[index].state ~= MailMO.MAIL_STATE_READ) or MailMO.myMails_[index].type ~= kind or MailMO.myMails_[index].isCollections ~= MAIL_COLLECT_TYPE_NORMAL then
							list[#list + 1] = mail
						end
					end
				end
			elseif delKind == MAIL_DELETE_TYPE_SYSTEM then --如果是删除系统邮件
				for index = 1,#MailMO.myMails_ do
					local mail = MailMO.myMails_[index]

					if (MailMO.myMails_[index].type == kind and (MailMO.myMails_[index].sendName ~= "系统邮件" )) or MailMO.myMails_[index].type ~= kind then
						list[#list + 1] = mail
					end
				end
			end
		else --如果是系统邮件分页
			for index = 1,#MailMO.myMails_ do
				local mail = MailMO.myMails_[index]
				if (MailMO.myMails_[index].type == kind and (MailMO.myMails_[index].state == MailMO.MAIL_STATE_NEW_AWARD or MailMO.myMails_[index].state == MailMO.MAIL_STATE_READ_AWARD)) or MailMO.myMails_[index].type ~= kind then
					list[#list + 1] = mail
				end
			end
		end

		MailMO.myMails_ = list
		Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DelMail",{keyId = 0, type = kind, delType = delKind}))
end