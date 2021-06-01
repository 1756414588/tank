--
-- Author: gf
-- Date: 2015-09-19 13:52:41
-- 攻打玩家和资源点报告

local ReportAttackView = class("ReportAttackView", UiNode)

function ReportAttackView:ctor(mail,readStatus)
	ReportAttackView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_mail = mail
	self.readStatus = readStatus
	self.m_selfAsk = false
	-- gdump(self.m_mail, "ReportAttackView:ctor")
end

function ReportAttackView:onEnter()
	ReportAttackView.super.onEnter(self)
	
	self:setTitle(CommonText[548][3])

	self:setUI()

	self.m_mapHandler = Notify.register(LOCAL_MAP_DATE_UPDATE_EVENT, handler(self, self.onMapUpdate))
end

function ReportAttackView:onExit()
	ReportAttackView.super.onExit(self)
	if self.m_mapHandler then
		Notify.unregister(self.m_mapHandler)
		self.m_mapHandler = nil
	end
end

function ReportAttackView:setUI()
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(600, self:getBg():getContentSize().height - 220))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 100 - infoBg:getContentSize().height / 2)

	local report_db_

	local reportType
	if self.m_mail.report.atkHome then
		report_db_ = self.m_mail.report.atkHome
		reportType = DEFENCE_TYPE_ATTACK_MAN
	elseif self.m_mail.report.atkMine then
		report_db_ = self.m_mail.report.atkMine
		reportType = DEFENCE_TYPE_ATTACK_MINE
	elseif self.m_mail.report.defHome then
		report_db_ = self.m_mail.report.defHome
		reportType = DEFENCE_TYPE_DEFENCE_MAN
	elseif self.m_mail.report.defMine then
		report_db_ = self.m_mail.report.defMine
		reportType = DEFENCE_TYPE_DEFENCE_MINE
	end

	report_db_ = MailBO.parseRptAtk(report_db_,reportType)
	report_db_.reportType = reportType
	report_db_.time = self.m_mail.report.time

	self.m_mail.report_db_ = report_db_

	local ReportAttackTableView = require("app.scroll.ReportAttackTableView")
	local view = ReportAttackTableView.new(cc.size(infoBg:getContentSize().width, infoBg:getContentSize().height - 20),self.m_mail,self.readStatus):addTo(infoBg)
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
		mailBtn:setEnabled(reportType ~= DEFENCE_TYPE_ATTACK_MINE)

		--攻打
		local normal = display.newSprite(IMAGE_COMMON .. "btn_lock_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_lock_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_lock_disabled.png")
		local lockBtn = MenuButton.new(normal, selected, disabled, handler(self,self.lockHandler)):addTo(self:getBg())
		lockBtn:setPosition(self:getBg():getContentSize().width / 2 + 125,80)

		if self.m_mail.moldId == 53 then -- 军事矿区
		elseif self.m_mail.moldId == 166 or self.m_mail.moldId == 167 then	-- 跨服军事矿区(胜利)
			lockBtn:setEnabled(false)
		elseif self.m_mail.moldId == 168 or self.m_mail.moldId == 169 then	-- 跨服军事矿区(失败)

		else
			if reportType == DEFENCE_TYPE_ATTACK_MINE then  -- 攻击矿资源，需要判断矿的状态
				local pos = WorldMO.decodePosition(self.m_mail.report_db_.defencer.pos)
				local status = WorldBO.getPositionStatus(cc.p(pos.x, pos.y))
				if status[ARMY_STATE_COLLECT] then
					lockBtn:setEnabled(false)
				else
					local partyMine = WorldMO.getPartyMineAt(pos.x, pos.y)
					if partyMine and PartyBO.getMyParty() then
						lockBtn:setEnabled(false)
					end
				end
			end
		end
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


function ReportAttackView:mailHandler(tag, sender)
	self.m_selfAsk = false
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

function ReportAttackView:shareHandler(tag, sender)
	self.m_selfAsk = false
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ShareDialog").new(SHARE_TYPE_MAIL, self.m_mail, sender):push()
end

-- 攻打按钮
function ReportAttackView:lockHandler(tag, sender)
	self.m_selfAsk = false
	ManagerSound.playNormalButtonSound()
	local pos = cc.p(0, 0)
	gdump(self.m_mail, "ReportAttackView:lockHandler")
	gdump(self.m_mail.report_db_,"self.m_mail.report_db_")

	if self.m_mail.moldId == 51 then -- 军事矿区，遭到攻击
		if not StaffBO.isMilitaryAreaOpen() then
			Toast.show(CommonText[10056][3])  -- 非活动期间，无法占领
			return
		end

		local pos = StaffMO.decodePosition(self.m_mail.report_db_.defencer.pos)

		local mapData = StaffMO.getMapDataAt(pos.x, pos.y)
		if mapData then -- 已经被占领了
			if mapData.my then  -- 是自己占领了
				Toast.show(CommonText[10063][5])
				return
			else
				local curTime = ManagerTimer.getTime()
				if curTime <= mapData.freeTime then  -- 处于保护时间内
					Toast.show(CommonText[10063][3])
					return
				end

				local ConfirmDialog = require("app.dialog.ConfirmDialog")
				ConfirmDialog.new(CommonText[10065], function()
						if StaffMO.plunderCount_ <= 0 then  -- 掠夺次数已经用完了
							Toast.show(CommonText[10063][1])
							return
						end

						if UiDirector.hasUiByName("HomeView1") then
							UiDirector.popMakeUiTop("HomeView1")
						else
							UiDirector.clear()
						end

					    StaffMO.curAttackPos_ = pos
			    		StaffMO.curAttackType_ = MILITARY_AREA_PLUNDER

						local ArmyView = require("app.view.ArmyView")
						local view = ArmyView.new(ARMY_VIEW_MILITARY_AREA, 1):push()
					end):push()
				return
			end
		else  -- 还没有被占领，可以攻击
			if UiDirector.hasUiByName("HomeView1") then
				UiDirector.popMakeUiTop("HomeView1")
			else
				UiDirector.clear()
			end

		    StaffMO.curAttackPos_ = pos
    		StaffMO.curAttackType_ = MILITARY_AREA_ATTACK

			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_MILITARY_AREA, 1):push()
		end
	elseif self.m_mail.moldId == 53 or self.m_mail.moldId == 51 or self.m_mail.moldId == 100 or self.m_mail.moldId == 101 then -- 军事矿区，进攻
		if not StaffBO.isMilitaryAreaOpen() then
			Toast.show(CommonText[10056][3])  -- 非活动期间，无法占领
			return
		end

		local pos = StaffMO.decodePosition(self.m_mail.report_db_.defencer.pos)

		local mapData = StaffMO.getMapDataAt(pos.x, pos.y)
		if mapData then -- 已经被占领了
			if mapData.my then  -- 是自己占领了
				Toast.show(CommonText[10063][5])
				return
			else
				local curTime = ManagerTimer.getTime()
				if curTime <= mapData.freeTime then  -- 处于保护时间内
					Toast.show(CommonText[10063][3])
					return
				end

				local ConfirmDialog = require("app.dialog.ConfirmDialog")
				ConfirmDialog.new(CommonText[10065], function()
						if StaffMO.plunderCount_ <= 0 then  -- 掠夺次数已经用完了
							Toast.show(CommonText[10063][1])
							return
						end

						if UiDirector.hasUiByName("HomeView1") then
							UiDirector.popMakeUiTop("HomeView1")
						else
							UiDirector.clear()
						end

					    StaffMO.curAttackPos_ = pos
			    		StaffMO.curAttackType_ = MILITARY_AREA_PLUNDER

						local ArmyView = require("app.view.ArmyView")
						local view = ArmyView.new(ARMY_VIEW_MILITARY_AREA, 1):push()
					end):push()
				return
			end
		else  -- 还没有被占领，可以攻击
			if UiDirector.hasUiByName("HomeView1") then
				UiDirector.popMakeUiTop("HomeView1")
			else
				UiDirector.clear()
			end

		    StaffMO.curAttackPos_ = pos
    		StaffMO.curAttackType_ = MILITARY_AREA_ATTACK

			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_MILITARY_AREA, 1):push()
		end
	elseif self.m_mail.moldId == 168 or self.m_mail.moldId == 169 then
		if not StaffBO.IsCrossServerMineAreaOpen() then
			Toast.show(CommonText[10056][3])  -- 非活动期间，无法占领
			return
		end

		local pos = StaffMO.decodeCrossPosition(self.m_mail.report_db_.defencer.pos)

		local mapData = StaffMO.getCrossMapDataAt(pos.x, pos.y)
		if mapData then -- 已经被占领了
			if mapData.my then  -- 是自己占领了
				Toast.show(CommonText[10063][5])
				return
			else
				local curTime = ManagerTimer.getTime()
				if curTime <= mapData.freeTime then  -- 处于保护时间内
					Toast.show(CommonText[10063][3])
					return
				end

				local ConfirmDialog = require("app.dialog.ConfirmDialog")
				ConfirmDialog.new(CommonText[10065], function()
						if StaffMO.plunderCount_ <= 0 then  -- 掠夺次数已经用完了
							Toast.show(CommonText[10063][1])
							return
						end

						if UiDirector.hasUiByName("HomeView3") then
							UiDirector.popMakeUiTop("HomeView3")
						else
							UiDirector.clear()
						end

					    StaffMO.curCrossAttackPos_ = pos
			    		StaffMO.curCrossAttackType_ = MILITARY_AREA_PLUNDER

						local ArmyView = require("app.view.ArmyView")
						local view = ArmyView.new(ARMY_VIEW_CORSS_MILITARY_AREA, 1):push()
					end):push()
				return
			end
		else  -- 还没有被占领，可以攻击
			if UiDirector.hasUiByName("HomeView3") then
				UiDirector.popMakeUiTop("HomeView3")
			else
				UiDirector.clear()
			end

		    StaffMO.curCrossAttackPos_ = pos
    		StaffMO.curCrossAttackType_ = MILITARY_AREA_ATTACK

			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_CORSS_MILITARY_AREA, 1):push()
		end
	else
		if self.m_mail.report_db_.reportType == DEFENCE_TYPE_ATTACK_MAN then
			WorldMO.curAttackPos_ = WorldMO.decodePosition(self.m_mail.report_db_.defencer.pos)
		elseif self.m_mail.report_db_.reportType == DEFENCE_TYPE_DEFENCE_MAN then
			WorldMO.curAttackPos_ = WorldMO.decodePosition(self.m_mail.report_db_.attacker.pos)
		elseif self.m_mail.report_db_.reportType == DEFENCE_TYPE_ATTACK_MINE then
			WorldMO.curAttackPos_ = WorldMO.decodePosition(self.m_mail.report_db_.defencer.pos)
		elseif self.m_mail.report_db_.reportType == DEFENCE_TYPE_DEFENCE_MINE then
			WorldMO.curAttackPos_ = WorldMO.decodePosition(self.m_mail.report_db_.attacker.pos)
		end

		local mine = WorldBO.getMineAt(WorldMO.curAttackPos_)
		if mine then  -- 是资源
			UiDirector.clear()
			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_FOR_WORLD):push()
		else
			local mapData = WorldMO.getMapDataAt(WorldMO.curAttackPos_.x, WorldMO.curAttackPos_.y)
			-- print("x:", WorldMO.curAttackPos_.x, "y:", WorldMO.curAttackPos_.y)
			-- dump(mapData, "XXXXXXXX")
			if mapData then -- 获得过玩家信息
				UiDirector.clear()
				local ArmyView = require("app.view.ArmyView")
				local view = ArmyView.new(ARMY_VIEW_FOR_WORLD):push()
			else  -- 没有地图数据，需要先请求
				Loading.getInstance():show()
				self.m_selfAsk = true
				WorldBO.asynGetMp({WorldMO.curAttackPos_},nil,1)
			end
		end
	end
end

function ReportAttackView:replayHandler(tag, sender)
	self.m_selfAsk = false
	ManagerSound.playNormalButtonSound()
	local record = sender.record
	local reportType = sender.reportType
	local result = sender.result
	if reportType == DEFENCE_TYPE_ATTACK_MAN or reportType == DEFENCE_TYPE_ATTACK_MINE then
		if result then  -- 胜利
			CombatMO.curBattleStar_ = 3
		else
			CombatMO.curBattleStar_ = 0
		end
	elseif reportType == DEFENCE_TYPE_DEFENCE_MAN or reportType == DEFENCE_TYPE_DEFENCE_MINE then
		if result then  -- 失败
			CombatMO.curBattleStar_ = 0
		else
			CombatMO.curBattleStar_ = 3
		end
	end


	gprint("CombatMO.curBattleStar_:", CombatMO.curBattleStar_, reportType, result)

	gdump(record, "ReportAttackView replayHandler")

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

function ReportAttackView:delHandler(tag,sender)
	self.m_selfAsk = false
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	MailBO.asynDelMail(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[551][2])
		self:pop()
		end,sender.mail)
end

function ReportAttackView:onMapUpdate(event)
	---当前界面 监听GETMAP 才有效
	if UiDirector.getTopUiName() == "ReportAttackView" and self.m_selfAsk then
		Loading.getInstance():unshow()
		UiDirector.clear()
		local ArmyView = require("app.view.ArmyView")
		local view = ArmyView.new(ARMY_VIEW_FOR_WORLD):push()
	end
end

return ReportAttackView
