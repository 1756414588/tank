--
-- Author: gf
-- Date: 2015-09-07 14:36:08
--
local s_mail = require("app.data.s_mail")

local db_mail_

MailMO = {}

--邮件数量上限
MailMO.mailMax = 50

--邮件收藏数量上限
MailMO.mailCollectMax = 10

--邮件类别
MAIL_TYPE_PLAYER = 1 	--玩家
MAIL_TYPE_SEND = 2 		--已发送
MAIL_TYPE_REPORT = 3 	--报告
MAIL_TYPE_STSTEM = 4 	--系统
MAIL_TYPE_PERSON_JJC = 5 	--个人竞技场
MAIL_TYPE_ALL_JJC = 6 	--全服竞技场
MAIL_TYPE_REPORT_AS = 11 --飞艇战斗报告

-----邮件战报 防御类型
DEFENCE_TYPE_ATTACK_MAN = 1 --进攻人
DEFENCE_TYPE_DEFENCE_MAN = 2 --防守人
DEFENCE_TYPE_ATTACK_MINE = 3 --进攻矿
DEFENCE_TYPE_DEFENCE_MINE = 4 --防守矿
DEFENCE_TYPE_ATTACK_AIRSHIP = 5 --飞艇争夺
DEFENCE_TYPE_DEFENCE_AIRSHIP = 6 --飞艇争夺

--邮件状态
MailMO.MAIL_STATE_NEW = 1 --未读
MailMO.MAIL_STATE_READ = 2 --已读
MailMO.MAIL_STATE_NEW_AWARD = 3 --有附件 未读
MailMO.MAIL_STATE_READ_AWARD = 4  --有附件 已读
MailMO.MAIL_STATE_READ_AWARD_GET = 5  --附件已领 已读

--邮件发送类型
MAIL_SEND_TYPE_NORMAL = 0 --普通邮件
MAIL_SEND_TYPE_PARTY = 1  --军团长群发

--邮件收藏状态
MAIL_COLLECT_TYPE_NORMAL = 0 --未收藏
MAIL_COLLECT_TYPE_COLLECTED = 1  --已收藏

--邮件删除状态区分
MAIL_DELETE_TYPE_ALL = 1      --所有
MAIL_DELETE_TYPE_READED = 2   --已读
MAIL_DELETE_TYPE_SYSTEM = 3   --系统
MAIL_DELETE_TYPE_NULL = 4     --空白

--我的邮件
MailMO.myMails_ = {
	
}

--我的竞技场个人战报
MailMO.myJJCPersonReprot_ = {

}
--我的竞技场全服战报
MailMO.myJJCAllReprot_ = {

}

MailMO.synMailHandler_ = nil

--本地缓存已发送邮件
local sendMail_storge_file = "sendMail"

function MailMO.getMySendMailsCache()
    --读取本地文件
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. sendMail_storge_file .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
    local mails = nil
    if io.exists(path) then
        mails = json.decode(io.readfile(path))
    end
    return mails
end

function MailMO.saveMySendMailsCache(doneCallback,mails)
	--排序
	local sortFun = function(a,b)
		return a.time > b.time
	end
	table.sort(mails,sortFun)

	local saveMails = {}
	--只存储20封
	for index=1,#mails do
		if index <= 20 then
			saveMails[#saveMails + 1] = mails[index]
		else
			break
		end
	end
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. sendMail_storge_file .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
    io.writefile(path, json.encode(saveMails), "w+b")
    
    if doneCallback then doneCallback() end
end

function MailMO.init()
	--我的邮件
	MailMO.myMails_ = {}
	--我的竞技场个人战报
	MailMO.myJJCPersonReprot_ = {}
	--我的竞技场全服战报
	MailMO.myJJCAllReprot_ = {}
	db_mail_ = {}

	local records = DataBase.query(s_mail)
	for index = 1, #records do
		local mail = records[index]
		db_mail_[mail.moldId] = mail
	end
end

function MailMO.queryMail(moldId)
	return db_mail_[moldId]
end

function MailMO.queryMyMails_(type)
	local list = {}
	for index=1,#MailMO.myMails_ do
		local mail = MailMO.myMails_[index]
		if (mail.type == type) or (type == MAIL_TYPE_REPORT and mail.type == MAIL_TYPE_REPORT_AS) then
			list[#list + 1] = mail
		end
	end

	--读取状态排序
	local sortFun = function(a,b)
		local ad,bd = 0,0
		if a.state <= 2 then ad = ad + 2 end
		if b.state <= 2 then bd = bd + 2 end
		if a.isCollections == b.isCollections then --优先判断是否收藏的
			if (a.state + ad) == (b.state +bd)  then
				return a.time > b.time
			else
				return (a.state + ad) < (b.state + bd) 
			end
		else
			return a.isCollections > b.isCollections
		end

		-- if (a.state + ad) == (b.state +bd)  then
		-- 	return a.time > b.time
		-- else
		-- 	return (a.state + ad) < (b.state + bd) 
		-- end
	end

	--时间排序
	local sortFunTime = function(a,b)
		return a.time > b.time
	end
	if UserMO.queryFuncOpen(UFP_MAIL_SYNC) then
		table.sort(list,sortFun)
	else
		table.sort(list,sortFunTime)
	end

	return list
end

function MailMO.queryMailByKeyId(keyId)
	local myMail
	for index=1,#MailMO.myMails_ do
		local mail = MailMO.myMails_[index]
		if mail.keyId == keyId then
			myMail = mail
		end
	end

	return myMail
end

--计算得出所有已收藏的邮件的数量
function MailMO.queryTotalCollectMails()
	local totalMails = 0
	for index=1,#MailMO.myMails_ do
		local mail = MailMO.myMails_[index]
		if mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
			totalMails = totalMails + 1
		end
	end

	return totalMails
end