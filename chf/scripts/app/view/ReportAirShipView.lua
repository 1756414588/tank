--
-- Author: gf
-- Date: 2015-09-19 13:52:41
-- 飞艇战报


local ReportAirShipView = class("ReportAirShipView", UiNode)

function ReportAirShipView:ctor(mail,readStatus)
	ReportAirShipView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_mail = mail
	self.readStatus = readStatus

	-- gdump(self.m_mail, "ReportAirShipView:ctor",9)
end

function ReportAirShipView:onEnter()
	ReportAirShipView.super.onEnter(self)
	
	self:setTitle(CommonText[548][3])

	self:setUI()
end

function ReportAirShipView:onExit()
	ReportAirShipView.super.onExit(self)
end

function ReportAirShipView:setUI()
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(600, self:getBg():getContentSize().height - 220))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 100 - infoBg:getContentSize().height / 2)

	local report_db_

	local reportType
	
	if self.m_mail.report.atkAirship then
		report_db_ = self.m_mail.report.atkAirship
		reportType = DEFENCE_TYPE_ATTACK_AIRSHIP		
	elseif self.m_mail.report.defAirship then
		report_db_ = self.m_mail.report.defAirship
		reportType = DEFENCE_TYPE_DEFENCE_AIRSHIP
	end

	report_db_ = MailBO.parseRptAtkAirShip(report_db_)
	report_db_.reportType = reportType
	report_db_.time = self.m_mail.report.time

	self.m_mail.report_db_ = report_db_

	local ReportAirShipTableView = require_ex("app.scroll.ReportAirShipTableView")
	local view = ReportAirShipTableView.new(cc.size(infoBg:getContentSize().width, infoBg:getContentSize().height - 20),self.m_mail,self.readStatus):addTo(infoBg)
	view:setPosition(0, 0)
	view:reloadData()

	--按钮
	if not self.readStatus then
		--删除
		local normal = display.newSprite(IMAGE_COMMON .. "btn_store_del_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_store_del_selected.png")
		local delBtn = MenuButton.new(normal, selected, nil, handler(self,self.delHandler)):addTo(self:getBg())
		delBtn:setPosition(self:getBg():getContentSize().width / 2 - 250,80)
		delBtn.mail = self.m_mail

		--分享
		local normal = display.newSprite(IMAGE_COMMON .. "btn_share_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_share_selected.png")
		local shareBtn = MenuButton.new(normal, selected, nil, handler(self,self.shareHandler)):addTo(self:getBg())
		shareBtn:setPosition(self:getBg():getContentSize().width / 2 - 125,80)

		--写信
		local normal = display.newSprite(IMAGE_COMMON .. "btn_sendMail_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_sendMail_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_sendMail_disabled.png")
		local mailBtn = MenuButton.new(normal, selected, disabled, handler(self,self.mailHandler)):addTo(self:getBg())
		mailBtn:setPosition(self:getBg():getContentSize().width / 2,80)
		mailBtn:setEnabled(false)

		--攻打
		local normal = display.newSprite(IMAGE_COMMON .. "btn_lock_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_lock_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_lock_disabled.png")
		local lockBtn = MenuButton.new(normal, selected, disabled, handler(self,self.lockHandler)):addTo(self:getBg())
		lockBtn:setPosition(self:getBg():getContentSize().width / 2 + 125,80)

		lockBtn:setEnabled(false)
	end

	--回放
	local normal = display.newSprite(IMAGE_COMMON .. "btn_replay_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_replay_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_replay_disabled.png")
	local replayBtn = MenuButton.new(normal, selected, disabled, handler(self,self.replayHandler)):addTo(self:getBg())
	replayBtn:setPosition(self:getBg():getContentSize().width / 2 + 250,80)
	replayBtn.record = report_db_.record
	replayBtn.result = report_db_.result
	replayBtn.reportType = reportType
	replayBtn:setEnabled(report_db_.record)
end


function ReportAirShipView:mailHandler(tag, sender)
	local sendName = ""
	local defencer = self.m_mail.report_db_.defencer
	local attacker = self.m_mail.report_db_.attacker

	if self.m_mail.report_db_.reportType == DEFENCE_TYPE_ATTACK_MAN then
		sendName = defencer.name
	elseif self.m_mail.report_db_.reportType == DEFENCE_TYPE_DEFENCE_MAN then
		sendName = attacker.name
	elseif self.m_mail.report_db_.reportType == DEFENCE_TYPE_DEFENCE_MINE then
		sendName = attacker.name
	end
	require("app.dialog.MailSendDialog").new(sendName,MAIL_SEND_TYPE_NORMAL):push()
end

function ReportAirShipView:shareHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ShareDialog").new(SHARE_TYPE_MAIL, self.m_mail, sender):push()
end

-- 攻打按钮
function ReportAirShipView:lockHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
end

function ReportAirShipView:replayHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local record = sender.record
	local reportType = sender.reportType
	local result = sender.result

	if result then
		CombatMO.curBattleStar_ = 3
	else
		CombatMO.curBattleStar_ = 0
	end

	CombatMO.curBattleNeedShowBalance_ = false
	CombatMO.curBattleCombatUpdate_ = 0
	CombatMO.curBattleAward_ = nil
	CombatMO.curBattleStatistics_ = {}

	CombatMO.curChoseBattleType_ = COMBAT_TYPE_REPLAY
	CombatMO.curChoseBtttleId_ = 0

	-- 飞艇战目前在回放中设置序列
	local defFormat = nil
	-- BattleMO.attackers_ = nil
	-- if table.isexist(self.m_mail.report_db_, "attackers") then
	-- 	BattleMO.attackers_ = clone(self.m_mail.report_db_.attackers)
	-- end

	-- BattleMO.defencers_ = nil
	-- if table.isexist(self.m_mail.report_db_, "defencers") then
	-- 	BattleMO.defencers_ = clone(self.m_mail.report_db_.defencers)
	-- end

	
	BattleMO.airshipId_ = nil
	if table.isexist(self.m_mail.report_db_, "airshipId") then
		BattleMO.airshipId_ = self.m_mail.report_db_.airshipId
		local ab = AirshipMO.queryShipById(BattleMO.airshipId_)
		defFormat = TankMO.getEmptyFormation(0)
		--防守方2号位，现在是写死的
		local armys = json.decode(ab.army)
		defFormat[5].tankId = armys[1]
		defFormat[5].count = armys[2]
	end
	-- 解析战斗的数据
	local combatData = CombatBO.parseCombatRecord(record,nil,defFormat)

	if not combatData.atkFormat or not combatData.defFormat then
		sender:setEnabled(false)
		return
	end

	local recordLord = self.m_mail.report_db_.recordLord
	-- dump(recordLord, "2222222recordLord222222")
	-- dump(self.m_mail.report_db_.attackers, "1111111111111111")
	-- dump(self.m_mail.report_db_.defencers, "2222222222222222")
	-- dump(self.m_mail.report_db_, "dddddddddddddddddddd",)

	BattleMO.attackers_ = {}
	-- table.insert(BattleMO.attackers_, {commander = combatData.atkFormat.commander})

	BattleMO.defencers_ = {}
	-- table.insert(BattleMO.defencers_, {commander = combatData.defFormat.commander})

	-- if BattleMO.record_ then
	-- 	for i,v in ipairs(BattleMO.record_) do
	-- 		if v.atkFormat then
	-- 			table.insert(BattleMO.attackers_, {commander = v.atkFormat.commander})
	-- 		end

	-- 		if v.defFormat then
	-- 			table.insert(BattleMO.defencers_, {commander = v.defFormat.commander})			
	-- 		end
	-- 	end
	-- end

	local atkQue = {}
	local defQue = {}
	for i,v in ipairs(recordLord) do
		if v.v1 > 0 then
			if #atkQue <= 0 or atkQue[#atkQue].lordId ~= v.v1 then
				atkQue[#atkQue+1] = {lordId = v.v1, idx = i}
			end
		end

		if v.v2 > 0 then
			if #defQue <= 0 or defQue[#defQue].lordId ~= v.v2 then
				defQue[#defQue+1] = {lordId = v.v2, idx = i}
			end
		end		
	end

	for i,v in ipairs(atkQue) do
		BattleMO.attackers_[i] = {}
		BattleMO.attackers_[i].lordId = v.lordId
		for _,person in ipairs(self.m_mail.report_db_.attackers or {}) do
			if v.lordId == person.lordId then
				BattleMO.attackers_[i].name = person.name
				if table.isexist(person,"firstValue") then
					BattleMO.attackers_[i].firstValue = person.firstValue
				end
				break
			end
		end
		if i == 1 then
			BattleMO.attackers_[i].commander = combatData.atkFormat.commander
		elseif BattleMO.record_ and BattleMO.record_[v.idx-1] then
			BattleMO.attackers_[i].commander = BattleMO.record_[v.idx-1].atkFormat.commander
		end		
	end

	for i,v in ipairs(defQue) do
		BattleMO.defencers_[i] = {}
		BattleMO.defencers_[i].lordId = v.lordId
		for _,person in ipairs(self.m_mail.report_db_.defencers or {}) do
			if v.lordId == person.lordId then
				BattleMO.defencers_[i].name = person.name
				if table.isexist(person,"firstValue") then
					BattleMO.defencers_[i].firstValue = person.firstValue
				end
				break
			end
		end	
		if i == 1 then
			BattleMO.defencers_[i].commander = combatData.defFormat.commander
		elseif BattleMO.record_ and BattleMO.record_[v.idx-1] then
			BattleMO.defencers_[i].commander = BattleMO.record_[v.idx-1].defFormat.commander
		end			
	end

	-- for i,v in ipairs(recordLord) do
	-- 	if v.v1 > 0 then
	-- 		BattleMO.attackers_[i] = {}
	-- 		for _,person in ipairs(self.m_mail.report_db_.attackers or {}) do
	-- 			if v.v1 == person.lordId then
	-- 				BattleMO.attackers_[i].name = person.name
	-- 				break
	-- 			end
	-- 		end
	-- 		if i == 1 then
	-- 			BattleMO.attackers_[i].commander = combatData.atkFormat.commander
	-- 		elseif BattleMO.record_ and BattleMO.record_[i-1] then
	-- 			BattleMO.attackers_[i].commander = BattleMO.record_[i-1].atkFormat.commander
	-- 		end
	-- 	end

	-- 	if v.v2 > 0 then
	-- 		BattleMO.defencers_[i] = {}
	-- 		for _,person in ipairs(self.m_mail.report_db_.defencers or {}) do
	-- 			if v.v2 == person.lordId then
	-- 				BattleMO.defencers_[i].name = person.name
	-- 				break
	-- 			end
	-- 		end	
	-- 		if i == 1 then
	-- 			BattleMO.defencers_[i].commander = combatData.defFormat.commander
	-- 		elseif BattleMO.record_ and BattleMO.record_[i-1] then
	-- 			BattleMO.defencers_[i].commander = BattleMO.record_[i-1].defFormat.commander
	-- 		end					
	-- 	end	
	-- end

	-- -- 设置先手
	CombatMO.curBattleOffensive_ = combatData.offsensive

	CombatMO.curBattleAtkFormat_ = combatData.atkFormat
	CombatMO.curBattleDefFormat_ = combatData.defFormat
	CombatMO.curBattleFightData_ = combatData

	BattleMO.reset()
	BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
	BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
	BattleMO.setFightData(CombatMO.curBattleFightData_)
	BattleMO.setBothInfo(self.m_mail.report_db_.attacker,self.m_mail.report_db_.defencer)

	local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)

	require("app.view.BattleView").new():push()
end

function ReportAirShipView:delHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	MailBO.asynDelMail(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[551][2])
		self:pop()
	end,sender.mail)
end

return ReportAirShipView
