--
-- Author: gf
-- Date: 2015-09-12 12:00:25
-- 军团祭坛

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local PartyAltarView = class("PartyAltarView", UiNode)

function PartyAltarView:ctor()
	PartyAltarView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function PartyAltarView:onEnter()
	PartyAltarView.super.onEnter(self)
	
	self:setTitle(CommonText[581][7])

	self.m_partyBossHandler = Notify.register(LOCAL_PARTY_BOSS_UPDATE, handler(self, self.onpartyBossUpdate))

	local container = self:getBg()
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_76.jpg"):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, self:getBg():getContentSize().height - 100 - bg:getContentSize().height / 2)
	--遮住底部的
	local mask = display.newScale9Sprite(IMAGE_COMMON .. "boss_mask.png"):addTo(bg)
	mask:setPreferredSize(cc.size(bg:width(), mask:height()))
	mask:setPosition(bg:width() / 2, mask:height() / 2)

	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_ALTAR,PartyMO.partyData_.altarLv)

	for index=1,#CommonText[951] do
		local labTit = ui.newTTFLabel({text = CommonText[951][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = bg:getContentSize().height - 55 - (index - 1) * 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		labTit:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then --祭坛等级
			value:setString(PartyMO.partyData_.altarLv)
			self.buildLvLab_ = value
		elseif index == 2 then --升级需求
			if PartyMO.partyData_.altarLv == PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_ALTAR) then --等级已达上限
				value:setString(CommonText[575][1])
				value:setColor(COLOR[2])
			else
				value:setString(partyBuildLv.needExp)
				if PartyMO.partyData_.build >= partyBuildLv.needExp then --建设度大于升级需求
					value:setColor(COLOR[2])
				else
					value:setColor(COLOR[6])
				end
			end
			self.buildUpNeedLab_ = value
		elseif index == 3 then --总建设度
			value:setString(PartyMO.partyData_.build)
			self.buildValueLab_ = value
		elseif index == 4 then --军团等级
			value:setString(PartyMO.partyData_.partyLv)
			self.buildLevelLab_ = value
		end
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local levelUpBtn = MenuButton.new(normal, selected, disabled, handler(self,self.levelUpHandler)):addTo(bg)
	levelUpBtn:setPosition(bg:getContentSize().width - levelUpBtn:getContentSize().width / 2 - 25,bg:getContentSize().height - levelUpBtn:getContentSize().height / 2 - 40)
	levelUpBtn:setLabel(CommonText[582][1])

	levelUpBtn:setEnabled(PartyMO.partyData_.altarLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_ALTAR) and 
		PartyMO.partyData_.build >= partyBuildLv.needExp)

	-- if PartyMO.partyData_.altarLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_ALTAR) then
	-- 	levelUpBtn.needExp = partyBuildLv.needExp
	-- end
	
	levelUpBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)
	self.levelUpBtn = levelUpBtn

	local function checkFightDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.PartyAltarBossView").new(3):push()
	end
	--按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_seek_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_seek_selected.png")
	local checkFight = MenuButton.new(normal, selected, nil, checkFightDetail):addTo(bg)
	checkFight:setPosition(bg:getContentSize().width - checkFight:getContentSize().width / 2 - 20, checkFight:getContentSize().height / 2 + 70)
	-- checkFight:setLabel(CommonText[582][2])
	
	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.altarbuild):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoDetail):addTo(bg)
	btn:setPosition(70, 110)

	local boss = display.newSprite(IMAGE_COMMON .. "icon_tank_altar_boss.png"):addTo(bg)
	boss:setPosition(bg:getContentSize().width / 2, 200)
	self.m_bossSprite = boss

	--星级
	local lv = PartyBO.getAltarBossLevel()
	local altarboss = PartyMO.queryPartyAltarBoss(lv)
	local starBg = display.newScale9Sprite(IMAGE_COMMON .. "boss_star_bg.png"):addTo(container)
	starBg:setPreferredSize(cc.size(starBg:width(), 130))
	starBg:setPosition(container:width() / 2, bg:y() - bg:height() / 2 - starBg:height() / 2 + 58)
	self.m_bossLv = lv

	local starLv = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)
	self.m_starLv = starLv
	local starLv = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)
	local nexlv = starLv + 1
	local maxStar = PartyMO.getPartyBossMaxStarInfo().star
	if nexlv >= maxStar then
		nexlv = maxStar
	end
	local nexStar = PartyMO.getStarInfoByStar(nexlv)
	local starInfo = PartyMO.getStarInfoByStar(self.m_starLv)
	local star = UiUtil.label(CommonText[2601][1]):addTo(starBg)
	star:setAnchorPoint(cc.p(0,0.5))
	star:setPosition(30,starBg:height() - 25)
	local starValue = UiUtil.label(altarboss.bossName):rightTo(star)
	self.m_starValue = starValue
	local lv = UiUtil.label(CommonText[2601][2]):alignTo(star, -30, 1)
	local lvValue = UiUtil.label(self.m_starLv):rightTo(lv)
	self.m_lvValue = lvValue
	local starExp = UiUtil.label(CommonText[2601][3]):alignTo(lv, -45, 1)
	local starBar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(starBg:width() - 280, 35), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(starBg:width() - 280 + 4, 20)}):rightTo(starExp)
	starBar:setPercent(PartyMO.partyData_.altarexp / nexStar.exp)
	starBar:setLabel(PartyMO.partyData_.altarexp.."/"..nexStar.exp)
	if PartyMO.partyData_.altarexp >= nexStar.exp then
		starBar:setLabel("Max")
	end
	self.m_starBar = starBar
	--详情
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png") 
	local detailBtn = MenuButton.new(normal, selected, nil,handler(self, self.gotoBossDetail)):rightTo(starBar,10)
	detailBtn:setScale(0.65)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local disable = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
	local donateBtn = MenuButton.new(normal, selected, disable, function ()
		if PartyMO.partyData_.altarLv < 5 then
			Toast.show(CommonText[2608])
			return
		end
		PartyBO.asynGetPartyBoss(function ()
			require("app.view.PartyBossUpView").new():push()
		end)
	end):rightTo(detailBtn,-20)
	donateBtn:setScale(0.7)
	self.m_donateBtn = donateBtn

	--奖励预览
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local goBtn = MenuButton.new(normal, selected, nil, function ()
		if PartyMO.partyData_.altarLv < 5 then
			Toast.show(CommonText[2608])
			return
		end
		if self.m_starLv == 0 then
			Toast.show(CommonText[2605])
			return
		end
		require("app.dialog.PartyBossStarAwardDialog").new(self.m_bossLv,self.m_starLv):push()
	end):addTo(starBg)
	goBtn:setPosition(starBg:width() - goBtn:width() / 2, starBg:height() - goBtn:height() / 2)
	goBtn:setLabel(CommonText[2602])

	--奖励
	local bg1 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(container)
	bg1:setCapInsets(cc.rect(130, 40, 1, 1))
	bg1:setPreferredSize(cc.size(container:width() - 20, 160))
	bg1:setPosition(bg:getPositionX(), starBg:y() - starBg:height() / 2 - bg1:height() / 2 - 20)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg1)
	titleBg:setPosition(bg1:width() / 2, bg1:height())
	local labTit = ui.newTTFLabel({text = CommonText[953][4], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg):center()
	-- labTit:setPosition(bg1:getContentSize().width/2,bg1:getContentSize().height - labTit:getContentSize().height/2 - 5)

	-- 召唤
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onSummonCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width / 2, btn:height() / 2 + 10)
	btn:setLabel(CommonText[953][3])
	self.m_challengeButton = btn

	local state = PartyMO.altarBoss_.state

	if state == PARTY_ALTAR_BOSS_STATE_READY or state == PARTY_ALTAR_BOSS_STATE_FIGHTING then

	else

	end

	self.m_timerHandler = ManagerTimer.addTickListener(handler(self, self.onTick))

	local lefttime = 0
	-- 冷却倒计时	
	local label = ui.newTTFLabel({text = CommonText[10021], font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2 - 5, y = btn:getPositionY() + btn:getContentSize().height/2 + 10, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(1,0.5))
	self.m_cdTitle = label
	local value = ui.newTTFLabel({text = UiUtil.strBuildTime(lefttime), font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2+5, y = btn:getPositionY() + btn:getContentSize().height/2 + 10, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0,0.5))
	self.m_cdLabel = value

	local containerNode = display.newNode():addTo(bg1)
	containerNode:setContentSize(bg1:getContentSize())
	containerNode:center()
	self.m_contentNode = containerNode

	self:updateAltarInfo()

	self:onTick()
end

function PartyAltarView:gotoBossDetail(tag, sender)
	ManagerSound.playNormalButtonSound()
	local starInfo = PartyMO.getStarInfoByStar(self.m_starLv)
	local firstStarInfo = PartyMO.getStarInfoByStar(0)
	local text = {}
	table.insert(text,{{content = CommonText[2601][2]..self.m_starLv}})
	table.insert(text,{{content = string.format(CommonText[2606], (starInfo.amount - firstStarInfo.amount) / firstStarInfo.amount * 100) .."%"}})
	table.insert(text,{{content = string.format(CommonText[2607], starInfo.cost)}})
	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	DetailTextDialog.new(text):push()
end

--更新军团祭坛信息 等级 升级需求 建设度
function PartyAltarView:updateAltarInfo()
	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_ALTAR, PartyMO.partyData_.altarLv)
	--等级
	self.buildLvLab_:setString(PartyMO.partyData_.altarLv)
	--升级需求
	if PartyMO.partyData_.altarLv == PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_ALTAR) then --等级已达上限
		self.buildUpNeedLab_:setString(CommonText[575][1])
		self.buildUpNeedLab_:setColor(COLOR[2])
	else
		self.buildUpNeedLab_:setString(partyBuildLv.needExp)
		if PartyMO.partyData_.build >= partyBuildLv.needExp then --建设度大于升级需求
			self.buildUpNeedLab_:setColor(COLOR[2])
		else
			self.buildUpNeedLab_:setColor(COLOR[6])
		end
	end
	--建设度
	self.buildValueLab_:setString(PartyMO.partyData_.build)
	local canUp = PartyMO.partyData_.altarLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_ALTAR) and PartyMO.partyData_.build >= partyBuildLv.needExp
	self.levelUpBtn:setEnabled(canUp)

	self.m_contentNode:removeAllChildren()

	local gap = 110
	local lv = PartyBO.getAltarBossLevel()
	local altarboss = PartyMO.queryPartyAltarBoss(lv)
	local awards = json.decode(altarboss.partAward)
	local counts = #awards
	local startX = self.m_contentNode:getContentSize().width/2 - (counts+1)/2 * gap
	for i=1,counts do
		local award = awards[i]
		local kind = award[1]
		local propId = award[2]
		local count = award[3]
		local itemView = UiUtil.createItemView(kind, propId, {count = count}):addTo(self.m_contentNode)
		UiUtil.createItemDetailButton(itemView)
		itemView:setPositionX(startX + i * gap - self.m_contentNode:getContentSize().width/2)
	end
end

function PartyAltarView:onSummonCallback( tag, sender )
	ManagerSound.playNormalButtonSound()

	local function goToSummon()
		if PartyMO.myJob < PARTY_JOB_OFFICAIL then
			Toast.show(CommonText[952][7])
			return
		end

		if not self.m_canCall then
			Toast.show(CommonText[952][3])
			return
		end

		local lv = PartyMO.partyData_.altarLv--PartyBO.getAltarBossLevel()
		local altarboss = PartyMO.queryPartyAltarBoss(lv)---PartyMO.partyData_.altarLv
		local starLv = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)
		local starCost = PartyMO.getStarInfoByStar(starLv).cost
		local callBossCost = altarboss.callBossCost + starCost

		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[952][9], callBossCost), function()
			if PartyMO.partyData_.build < callBossCost then --建设度大于 召唤需求
				Toast.show(string.format(CommonText[952][4],callBossCost))
				return
			end

			Loading.getInstance():show()
			PartyBO.DoCallAltarBoss(function ()
				Loading.getInstance():unshow()
				self:updateAltarInfo()
				Toast.show(CommonText[955])
			end, callBossCost)
		end):push()
	end

	local function gotoFight()
		if not self.m_canCall then
			Toast.show(CommonText[952][5])
			return			
		end
		require("app.view.PartyAltarBossView").new():push()
	end

	local state = PartyMO.altarBoss_.state
	if state == PARTY_ALTAR_BOSS_STATE_READY or state == PARTY_ALTAR_BOSS_STATE_FIGHTING then
		gotoFight()
	else
		goToSummon()
	end
end

function PartyAltarView:levelUpHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	if PartyBO.canFight() then
		Toast.show(CommonText[952][8])
		return 
	end

	if PartyMO.partyData_.altarLv >= math.floor(PartyMO.partyData_.partyLv/5) then
		Toast.show(CommonText[952][1])
		return
	end

	if self.levelUpStatus == true then return end
	self.levelUpStatus = true

	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_ALTAR, PartyMO.partyData_.altarLv)

	Loading.getInstance():show()
	PartyBO.asynUpPartyBuilding(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[585])
		self:updateAltarInfo()
		self.levelUpStatus = false
		end,PARTY_BUILD_ID_ALTAR, partyBuildLv.needExp)
end


function PartyAltarView:onTick( dt )
	if PartyMO.altarBossDirty_ then 
		return
	end

	local state = PartyMO.altarBoss_.state
	local lefttime = PartyMO.altarBoss_.cdTime
		
	local hasChange = self.m_lastState ~= state
	self.m_lastState = state

	lefttime = math.floor(lefttime)
	if lefttime < 0 then
		lefttime = 0
	end

	self.m_cdLabel:setString(UiUtil.strBuildTime(lefttime))

	self.m_canCall = false
	if state ~= PARTY_ALTAR_BOSS_STATE_READY and state ~= PARTY_ALTAR_BOSS_STATE_FIGHTING then
		
		if hasChange then
			self.m_donateBtn:setEnabled(true)
			local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
			self.m_challengeButton:setNormalSprite(normal)
			self.m_challengeButton:setSelectedSprite(selected)	
			self.m_challengeButton:setLabel(CommonText[953][3])

			-- self.m_cdTitle:setString(CommonText[10021])
			self.m_cdTitle:setString(CommonText[956][1])
			self.m_cdTitle:setColor(COLOR[6])
			self.m_cdLabel:setColor(COLOR[6])
		end

		if lefttime <= 0 then
			self.m_canCall = true
		end

		if lefttime == 0 then
			self:doTickCall()
		end		
	elseif state == PARTY_ALTAR_BOSS_STATE_READY or state == PARTY_ALTAR_BOSS_STATE_FIGHTING then
		if hasChange then
			self.m_donateBtn:setEnabled(false)
			local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")			
			self.m_challengeButton:setNormalSprite(normal)
			self.m_challengeButton:setSelectedSprite(selected)			
			self.m_challengeButton:setLabel(CommonText[34])

			-- self.m_cdTitle:setString(CommonText[10017][2])
			if state == PARTY_ALTAR_BOSS_STATE_READY then
				self.m_cdTitle:setString(CommonText[956][2])
			else
				self.m_cdTitle:setString(CommonText[956][3])
			end

			self.m_cdTitle:setColor(COLOR[2])
			self.m_cdLabel:setColor(COLOR[2])
		end

		self.m_canCall = true	
	end
end

function PartyAltarView:onExit()
	PartyAltarView.super.onExit(self)

	ManagerTimer.removeTickListener(self.m_timerHandler)
	self.m_timerHandler = nil

	if self.m_partyBossHandler then
		Notify.unregister(self.m_partyBossHandler)
		self.m_partyBossHandler = nil
	end
end

local TickGap = 10
local tick = 0
function PartyAltarView:doTickCall()
	tick = tick + 1
	if tick > TickGap then
		tick = 0
		PartyBO.asynGetPartyAltarBossData()
	end
end

function PartyAltarView:onpartyBossUpdate(event)
	self.m_starLv = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)

	local starLv = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)
	local nexlv = starLv + 1
	local maxStar = PartyMO.getPartyBossMaxStarInfo().star
	if nexlv >= maxStar then
		nexlv = maxStar
	end
	local nexStar = PartyMO.getStarInfoByStar(nexlv)
	self.m_starBar:setPercent(PartyMO.partyData_.altarexp / nexStar.exp)
	self.m_starBar:setLabel(PartyMO.partyData_.altarexp.."/"..nexStar.exp)
	if PartyMO.partyData_.altarexp >= nexStar.exp then
		self.m_starBar:setLabel("Max")
	end
	self.m_lvValue:setString(self.m_starLv)

	local lv = PartyBO.getAltarBossLevel()
	self.m_bossLv = lv
	local altarboss = PartyMO.queryPartyAltarBoss(lv)
	self.m_starValue:setString(altarboss.bossName)
end

return PartyAltarView