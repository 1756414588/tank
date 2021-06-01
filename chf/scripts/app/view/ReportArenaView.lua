--
-- Author: gf
-- Date: 2015-10-14 15:57:31
-- JJC战报

JJC_REPORT_TYPE_ATTACK = 1 --进攻
JJC_REPORT_TYPE_DEFENCE = 2 --防守
JJC_REPORT_TYPE_GLOBAL = 3 --全服


local ReportArenaView = class("ReportArenaView", UiNode)

function ReportArenaView:ctor(mail,readStatus)
	ReportArenaView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_mail = mail
	self.readStatus = readStatus

	gdump(self.m_mail, "ReportArenaView:ctor")
end

function ReportArenaView:onEnter()
	ReportArenaView.super.onEnter(self)
	
	self:setTitle(CommonText[548][3])

	self:setUI()
end

function ReportArenaView:setUI()
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(600, 724))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 100 - infoBg:getContentSize().height / 2)

	local report_db_

	local reportType
	if self.m_mail.report.atkArena then
		report_db_ = self.m_mail.report.atkArena
		reportType = JJC_REPORT_TYPE_ATTACK
	elseif self.m_mail.report.defArena then
		report_db_ = self.m_mail.report.defArena
		reportType = JJC_REPORT_TYPE_DEFENCE
	elseif self.m_mail.report.globalArena then
		report_db_ = self.m_mail.report.globalArena
		reportType = JJC_REPORT_TYPE_GLOBAL
	end

	report_db_ = MailBO.parseRptAtkArena(report_db_)
	report_db_.reportType = reportType

	self.m_mail.report_db_ = report_db_

	local ReportArenaTableView = require("app.scroll.ReportArenaTableView")
	local view = ReportArenaTableView.new(cc.size(infoBg:getContentSize().width, infoBg:getContentSize().height - 20),self.m_mail):addTo(infoBg)
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
		delBtn:setVisible(reportType ~= JJC_REPORT_TYPE_GLOBAL)

		--分享
		local normal = display.newSprite(IMAGE_COMMON .. "btn_share_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_share_selected.png")
		local shareBtn = MenuButton.new(normal, selected, nil, handler(self,self.shareHandler)):addTo(self:getBg())
		shareBtn:setPosition(self:getBg():getContentSize().width / 2 - 125,80)
		shareBtn:setVisible(reportType ~= JJC_REPORT_TYPE_GLOBAL)
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


function ReportArenaView:shareHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ShareDialog").new(SHARE_TYPE_MAIL, self.m_mail,sender):push()
end

function ReportArenaView:replayHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local record = sender.record
	local reportType = sender.reportType
	local result = sender.result
	if reportType == JJC_REPORT_TYPE_ATTACK or reportType == JJC_REPORT_TYPE_GLOBAL then
		if result then  -- 胜利
			CombatMO.curBattleStar_ = 3
		else
			CombatMO.curBattleStar_ = 0
		end
	elseif reportType == JJC_REPORT_TYPE_DEFENCE then
		if result then  -- 失败
			CombatMO.curBattleStar_ = 0
		else
			CombatMO.curBattleStar_ = 3
		end
	end


	gprint("CombatMO.curBattleStar_:", CombatMO.curBattleStar_, reportType, result)

	gdump(record, "ReportArenaView replayHandler")

	CombatMO.curBattleNeedShowBalance_ = false
	CombatMO.curBattleCombatUpdate_ = 0
	CombatMO.curBattleAward_ = nil
	CombatMO.curBattleStatistics_ = {}

	CombatMO.curChoseBattleType_ = COMBAT_TYPE_REPLAY
	CombatMO.curChoseBtttleId_ = 0

	-- 解析战斗的数据
	local combatData = CombatBO.parseCombatRecord(record)

	if not combatData.atkFormat or not combatData.defFormat then
		sender:setEnabled(false)
		return
	end

	-- 设置先手
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

function ReportArenaView:delHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	MailBO.asynDelJJCReport(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[551][2])
		self:pop()
		end,sender.mail.keyId,sender.mail.type)
end



return ReportArenaView
