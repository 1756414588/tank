--
-- Author: xiaoxing
-- Date: 2017-04-19 17:47:39
--
local Dialog = require("app.dialog.Dialog")
local InfoDialog = class("InfoDialog", Dialog)

function InfoDialog:ctor(data)
	InfoDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 260)})
	self.data = data
end

function InfoDialog:onEnter()
	InfoDialog.super.onEnter(self)
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)
	local bg = self:getBg()
	local t = UiUtil.label(CommonText[995][1], 26, cc.c3b(237,254,174)):addTo(bg):pos(bg:width()/2, bg:height() - 62)
	t = UiUtil.label(CommonText[995][2] ..self.data.commanderCount, 22):alignTo(t, -45, 1)
	t = UiUtil.label(CommonText[995][3] ..self.data.tankCount, 22):alignTo(t, -30, 1)
	t = UiUtil.label(CommonText[995][5] ..UiUtil.strNumSimplify(self.data.fightCount), 22):alignTo(t, -30, 1)


end

--------------------------------------------------------------------------------
local AirshipInfo = class("AirshipInfo", UiNode)
ARMY_SETTING_AIRSHIP_DEFEND = 18
function AirshipInfo:ctor(pos)
	AirshipInfo.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	self.pos = pos

	self.validEndTime = 0  ---侦查有效时间
	self.remianFreeCnt = 0   ---今日免费创建攻打飞艇集结次数

	self.data_ = nil ---缓存数据

	local ab = AirshipMO.queryShip(self.pos) -- 飞艇信息

	if PartyBO.getMyParty() then ---只有拥有军团的时候 才会发送
		AirshipBO.asynGetAirshipPlayer(function (data)
			if table.isexist(data, "validEndTime") then
				self.validEndTime = data.validEndTime
			end

			if table.isexist(data, "remianFreeCnt") then
				self.remianFreeCnt = data.remianFreeCnt
			end
		end, ab.id)	
	end
end

function AirshipInfo:onEnter()
	AirshipInfo.super.onEnter(self)
	self:showUI_()


	self.r_airShipUpdateHandler_ = Notify.register(LOCAL_AIRSHIP_UPDATE_EVENT, function ()
		self:showUI_()
	end)
end

function AirshipInfo:onExit()
	AirshipInfo.super.onExit(self)

	if self.r_airShipUpdateHandler_ then
		Notify.unregister(self.r_airShipUpdateHandler_)
		self.r_airShipUpdateHandler_ = nil
	end
end

function AirshipInfo:showUI_()
	if not self.container_ then
		self.container_ = display.newNode():addTo(self:getBg())
		self.container_:setContentSize(self:getBg():getContentSize())
	end

	-- 部队
	local ab = AirshipMO.queryShip(self.pos) -- 飞艇信息
	local data = AirshipBO.ships_ and AirshipBO.ships_[ab.id] -- 飞艇军团信息
	if not data then return end
	local updateFlag = false
	if self.data_ then
		if self.data_.base and data.base then
			for k,v in pairs(data.base) do
				if v ~= self.data_.base[k] then
					updateFlag = true
					break
				end
			end
		end

		if not updateFlag then
			if self.data_.occupy and data.occupy then
				for k,v in pairs(data.occupy) do
					if v ~= self.data_.occupy[k] then
						updateFlag = true
						break
					end
				end				
			elseif not self.data_.occupy and not data.occupy then

			else
				updateFlag = true
			end
		end

		if not updateFlag then
			if self.data_.detail and data.detail then
				if self.data_.detail.durability ~= data.detail.durability then
					updateFlag = true
				end
			end
		end
	else
		updateFlag = true
	end

	if not updateFlag then
		return
	end

	self.data_ = clone(data)

	self.container_:removeAllChildren()
	local bg = self.container_
	gdump(ab,"ab--",1)
	gdump(data,"data--",9)
	self:setTitle(ab.name)
	self.id = ab.id
	self.data = data
	local armys = json.decode(ab.army)
	local tankId = armys[1]
	local count = armys[2]
	local tank = TankMO.queryTankById(tankId)
	
	local showSelf = false -- 是否归属自己
	local showPortrait = false -- 头像是否显示
	local hasOccupy = false ----是否被占领

	local posPoint = WorldMO.decodePosition(ab.pos)
	local wordpos = "["..posPoint.x ..","..posPoint.y.."]"	--位置
	local wordlv = tostring(ab.level)	--等级
	local wordatc = tank.fight * count -- 攻击力
	local numBar = 0
	local bottomTipText = CommonText[1007][6]
	local portraitId = 0 -- 任务头像ID

	local top = display.newSprite(IMAGE_COMMON.."ship/ship_bg.jpg"):addTo(bg):align(display.CENTER_TOP, bg:width()/2, bg:height() - 92)
	-- local ship = display.newSprite(IMAGE_COMMON.."ship/ship.png"):addTo(top):center()
	local isRuins = false

	if table.isexist(data.base, "ruins") then
		isRuins = data.base.ruins
	end

	local shipBg
	if isRuins then
		shipBg = display.newSprite(IMAGE_COMMON.."ship/ship_bg_2.jpg"):addTo(top):center()
	else
		shipBg = display.newSprite(IMAGE_COMMON.."ship/ship_bg_1.jpg"):addTo(top):center()
	end

	if data.occupy then
		portraitId = data.occupy.portrait or 0
		
		if PartyBO.getMyParty() and PartyMO.partyData_.partyId == data.occupy.partyId then
			-- 自己军团
			showSelf = true
			showPortrait = true
			numBar = data.detail.durability or 0
			local selectLab = UiUtil.label(CommonText[1000][3],FONT_SIZE_MEDIUM,cc.c3b(255, 255, 255)):addTo(top,10):pos(top:width()/2, top:height() - 40)
			selectLab:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0.5, 1.05),
				 cc.ScaleTo:create(0.5, 1)})))
			shipBg:setTouchEnabled(true)
			shipBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			    if event.name == "began" then
			        return true
			    elseif event.name == "ended" then
			    	if isRuins then
			    		Toast.show(CommonText[1038])
			    		return
			    	end
			        require("app.view.AirshipDefend").new(self.id):push()
			    end
			end)
		else
			-- 敌对军团
			showSelf = false
			showPortrait = true
		end

		hasOccupy = true
	else
		-- 中立
		showSelf = false
		showPortrait = false

		hasOccupy = false
	end

	-- 位置
	local contentbg = display.newSprite(IMAGE_COMMON.."ship/ship_word_bg.png"):addTo(top, 2)
	contentbg:setAnchorPoint(cc.p(0,0.5))
	contentbg:setPosition(10,60)
	local posTitle = ui.newTTFLabel({text = CommonText[1007][1], font = G_FONT, color=cc.c3b(226, 229, 144), size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT}):addTo(contentbg)
	posTitle:setAnchorPoint(cc.p(0,0.5))
	posTitle:setPosition(5,contentbg:getContentSize().height / 2)
	local posContent = ui.newTTFLabel({text = wordpos , font = G_FONT, color=COLOR[1], size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT}):addTo(contentbg)
	posContent:setAnchorPoint(cc.p(0,0.5))
	posContent:setPosition(posTitle:getPositionX() + posTitle:getContentSize().width ,contentbg:getContentSize().height / 2)

	-- 等级
	contentbg = display.newSprite(IMAGE_COMMON.."ship/ship_word_bg.png"):addTo(top, 2)
	contentbg:setAnchorPoint(cc.p(0,0.5))
	contentbg:setPosition(10,60 + 40)
	local lvTitle = ui.newTTFLabel({text = CommonText[1007][2], font = G_FONT, color=cc.c3b(226, 229, 144), size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT}):addTo(contentbg)
	lvTitle:setAnchorPoint(cc.p(0,0.5))
	lvTitle:setPosition(5,contentbg:getContentSize().height / 2)
	local lvContent = ui.newTTFLabel({text = wordlv , font = G_FONT, color=COLOR[1], size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT}):addTo(contentbg)
	lvContent:setAnchorPoint(cc.p(0,0.5))
	lvContent:setPosition(lvTitle:getPositionX() + lvTitle:getContentSize().width ,contentbg:getContentSize().height / 2)

	if not hasOccupy then
		-- 战斗力
		contentbg = display.newSprite(IMAGE_COMMON.."ship/ship_word_bg.png"):addTo(top, 2)
		contentbg:setAnchorPoint(cc.p(0,0.5))
		contentbg:setPosition(10,60 + 40 + 40)
		local atcTitle = ui.newTTFLabel({text = CommonText[1007][3] .. UiUtil.strNumSimplify(wordatc), font = G_FONT
			, color=cc.c3b(255, 50, 50), size = FONT_SIZE_SMALL + 4, align = ui.TEXT_ALIGN_LEFT}):addTo(contentbg)
		atcTitle:setAnchorPoint(cc.p(0,0.5))
		atcTitle:setPosition(5,contentbg:getContentSize().height / 2)
	end
	-- 耐久度（生命值）
	-- local showAward = ab.award
	local showAward = ab.showList ----读取 展现 数据（客户端使用）
	local factor = 1
	if showSelf then
		local durableBar = ProgressBar.new(IMAGE_COMMON .. "ship/durable.png",BAR_DIRECTION_HORIZONTAL,cc.size(top:getContentSize().width * 0.52, 9),{bgName = IMAGE_COMMON .. "ship/durablebg.png", bgScale9Size = cc.size(top:getContentSize().width * 0.52, 9)}):addTo(top)
		durableBar:setPosition(top:getContentSize().width * 0.5,9)

		durableBar:setPercent(numBar/10000)

		if isRuins then
			showAward = ab.repair --or "[[17,1,5000]]"
			factor = AirshipMO.queryRebuildFactor(StaffMO.worldLv_)
			bottomTipText = CommonText[1007][7]
		end

		-- if data.detail.produceTime < 0 then
			
		-- end

		local barNumber = UiUtil.label(CommonText[1007][4] .. string.format("%.2f", numBar/100) .. "%",14):addTo(top, 2)
		barNumber:setPosition(top:getContentSize().width * 0.5,9 )
		-- 耐久度提示
		local bartitle = UiUtil.label(CommonText[1007][5]):addTo(top, 2)
		bartitle:setPosition(top:getContentSize().width * 0.5,9 + bartitle:getContentSize().height)
		bartitle:setVisible(true)
	end

	-- 侦查按钮
	if not showSelf and data.occupy then
		local scoutbtn = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self, self.scout), CommonText[313][5])
		:addTo(top, 2):pos(540, 70)
		local scoutLab = UiUtil.label("00:00",FONT_SIZE_MEDIUM):addTo(scoutbtn)
		scoutLab:setPosition(scoutbtn:getContentSize().width * 0.5, scoutbtn:getContentSize().height)

		local function tick()
			local lefttime = self.validEndTime - ManagerTimer.getTime()
			if lefttime < 0 then
				lefttime = 0
			end

			if lefttime > 0 then
				scoutbtn:setLabel(CommonText[1032])				
			else
				scoutbtn:setLabel(CommonText[313][5])
			end
			
			scoutLab:setString(UiUtil.strBuildTime(lefttime))		
		end

		tick()

		scoutLab:schedule(tick, 1)
	end

	-- 征收记录
	if showSelf then
		UiUtil.button("btn_levy_normal.png", "btn_levy_selected.png", nil, handler(self, self.LevyRecordCallback)):addTo(top, 2):pos(570, 60)
	end

	if true then
		-- 提示
		local function tipshow()
			-- local DetailTextDialog = require("app.dialog.DetailTextDialog")
			-- DetailTextDialog.new(DetailText.AirshipInfo):push()	
			local DetailTextPageDialog = require("app.dialog.DetailTextPageDialog")
			DetailTextPageDialog.new(DetailText.AirshipInfo):push()	
		end
		local tipbtn = UiUtil.button("ship/tipnomal.png", "ship/tipselect.png", nil, tipshow):addTo(top, 2)
		tipbtn:setPosition(tipbtn:getContentSize().width * 0.65, top:getContentSize().height - tipbtn:getContentSize().height * 0.9)
	end

	--人物头像
	if showPortrait then
		local scale = 0.5
		local portrait = UiUtil.createItemView(ITEM_KIND_PORTRAIT, portraitId):addTo(top, 2)
		portrait:setScale(scale)
		portrait:setPosition(top:getContentSize().width - portrait:getContentSize().width * scale * 0.65 , top:getContentSize().height - portrait:getContentSize().height * scale * 0.7)

		local lordNameLabel = ui.newTTFLabel({text = data.occupy.lordName, font = G_FONT, size = FONT_SIZE_LIMIT,
			algin = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_CENTER}):addTo(top)
		-- playerNameLabel:setAnchorPoint(cc.p(0,0.5))
		lordNameLabel:setPosition(portrait:getPositionX() , portrait:getPositionY() - portrait:getBoundingBox().height/2 - 5)		
	end	


	-- 下半部分底板（资源底板）
	local bottombg = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_0.png"):addTo(bg)
	bottombg:setPreferredSize(cc.size(top:getContentSize().width * 0.9, 280))
	bottombg:setPosition(bg:width()/2,top:getPositionY() - top:getContentSize().height - 140 )
	local bottomtitlbg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(bottombg)
	bottomtitlbg:setPreferredSize(cc.size(bottombg:getContentSize().width, bottomtitlbg:getContentSize().height))
	bottomtitlbg:setScaleY(0.7)
	bottomtitlbg:setPosition(bottombg:getContentSize().width * 0.5 , bottombg:getContentSize().height - bottomtitlbg:getContentSize().height * 0.7 * 0.5)
	local bottomTip = UiUtil.label(bottomTipText,FONT_SIZE_TINY):addTo(bottombg)
	bottomTip:setPosition(bottombg:getContentSize().width * 0.5,bottombg:getContentSize().height - 18)

	-- 奖励
	local awards = json.decode(showAward)

	for index = 1 , #awards do
		if index > 6 then break end
		local award = awards[index]
 		local item = UiUtil.createItemView(award[1],award[2],{count = award[3] * factor}):addTo(bottombg)
 		UiUtil.createItemDetailButton(item)
		local x = ((index - 1) % 3 + 0.5) * (bottombg:getContentSize().width / 3)
		local y = 180 - math.floor((index - 1) / 3) * 120
		item:setPosition(x,y)
	end

	if showSelf then
		--图纸收取介绍
		local paperContentLable = ui.newTTFLabel({text = CommonText[1009][1], font = G_FONT, size = FONT_SIZE_LIMIT,algin = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_CENTER}):addTo(bottombg)
		-- paperContentLable:setAnchorPoint(cc.p(0,0.5))
		paperContentLable:setPosition(bottombg:getContentSize().width * 0.5 ,-35)
		-- paperContentLable = ui.newTTFLabel({text = CommonText[1009][2], font = G_FONT, size = FONT_SIZE_LIMIT,algin = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_CENTER}):addTo(bottombg)
		-- paperContentLable:setAnchorPoint(cc.p(0,0.5))
		-- paperContentLable:setPosition(15 ,-35)
	end
	
	if showSelf then
		-- 发送邮件
		local offFactor = 0.25
		if data.occupy.lordId and data.occupy.lordId ~= UserMO.lordId_ then
			local sendmsgbtn = UiUtil.button("btn_1_normal.png", "btn_1_selected.png", nil, handler(self, self.sendMsg), CommonText[1008][1])
				:addTo(bg):pos(bg:width()*0.25 ,70)
				offFactor = 0.5
		end

		if isRuins then
			--重建
			local rebuildbtn = UiUtil.button("btn_2_normal.png", "btn_2_selected.png", "btn_1_disabled.png", handler(self, self.reBuild), CommonText[1008][2])
				:addTo(bg):pos(bg:width()*(0.25 + offFactor) ,70)

			if numBar < 10000 then
				rebuildbtn:setEnabled(true)
			else
				rebuildbtn:setEnabled(false)
			end

			local ruinsLable = ui.newTTFLabel({text = CommonText[1112],color=COLOR[6], font = G_FONT, size = FONT_SIZE_LIMIT,algin = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_CENTER}):addTo(bottombg)
			-- ruinsLable:setAnchorPoint(cc.p(0,0.5))
			ruinsLable:setPosition(bottombg:getContentSize().width * 0.5 ,-15)			
		else

		end

		-- if data.detail.produceTime < 0 then
		-- 	rebuildbtn:setEnabled(true)
		-- else
		-- 	rebuildbtn:setEnabled(false)
		-- end

		-- if numBar < 100 then
		-- 	rebuildbtn:setEnabled(true)
		-- else
		-- 	rebuildbtn:setEnabled(false)
		-- end
	end
	
	-- 进攻按钮
	if not showSelf then
		local btn = UiUtil.button("btn_2_normal.png", "btn_2_selected.png", "btn_1_disabled.png", handler(self, self.attack),CommonText[996][1])
			:addTo(bg):pos(bg:width()*0.5 ,70)
		self.btn = btn
		self:checkState()
	end

	--保护倒计时
	-- if not showSelf and data and (data.base.safeEndTime == -1 or data.base.safeEndTime > 0) then
	if  data and (data.base.safeEndTime == -1 or data.base.safeEndTime > 0) then
		-- if showSelf then
		-- 	self.btn:setVisible(false)
		-- end
		----safeEndTime  -1表示没有打败所有低级飞艇,永久保护
		local safeEndTime = data.base.safeEndTime
		-- local leftLab = UiUtil.label(""):addTo(top):pos(top:width()/2, top:height() - 38)
		local leftLab = UiUtil.label(""):addTo(bg)
		if showSelf then
			leftLab:pos(bg:width()*0.5 ,bg:height()- 430)
		else
			leftLab:pos(bg:width()*0.5 ,130)
		end
		local function tick()
			local left = safeEndTime - ManagerTimer.getTime()
			if left <= 0 then
				if not showSelf then
					self.btn:setEnabled(true)
				end
				leftLab:removeSelf()
			end
			-- local time = ManagerTimer.time(left)
			-- local tl = string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
			leftLab:setString(CommonText[1005][1]..UiUtil.strBuildTime(left))
		end
		if not showSelf then
			self.btn:setEnabled(false)
		end
		if safeEndTime > 0 then
			leftLab:performWithDelay(tick, 1, 1)
			tick()
			print("==" .. safeEndTime)
		else
			print("--" .. safeEndTime)
			leftLab:setString(CommonText[1005][2])
		end
	end
end

function AirshipInfo:update()
	-- body
end

function AirshipInfo:checkState()
	local data = self.data.base
	dump(data, "@=========checkState==========")
	if data and table.isexist(data,"teamLeader") and data.teamLeader > 0 then
		self.btn.state = 1
		-- self.btn:setLabel(CommonText[1003][2])
		self.btn:setLabel(CommonText[1114])
	else
		self.btn.state = 0
		self.btn:setLabel(CommonText[996][1])
	end
	-- if self.data and self.data.aai and table.getn(self.data.aai) > 0 then
	-- 	self.btn.state = 1
	-- 	self.btn:setLabel(CommonText[1003][2])
	-- else
	-- 	self.btn.state = 0
	-- 	self.btn:setLabel(CommonText[996][1])
	-- end
end

-- 敌对 或 中立 可侦查
function AirshipInfo:scout()
	local ab = AirshipMO.queryShipById(self.id)
	local airshipId = self.id

	local lefttime = self.validEndTime - ManagerTimer.getTime()

	if lefttime > 0 then
		----有效时间，查看
		AirshipBO.scoutAirship(function(data)
			InfoDialog.new(data):push()
		end, airshipId)

		return
	end


	local scoutCost = json.decode(ab.spyCost)

	local costStr = ""

	for i,v in ipairs(scoutCost) do
		local resData = UserMO.getResourceData(v[1], v[2])
		costStr = costStr .. resData.name .. "*" .. v[3]
		if i < #scoutCost then
			costStr = costStr .. ","
		end
	end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")

	ConfirmDialog.new(string.format(CommonText[1036], costStr), function()
			for i,v in ipairs(scoutCost) do
				local resData = UserMO.getResourceData(v[1], v[2])
				local count = UserMO.getResource(v[1], v[2])
				if count < tonumber(v[3]) then
					Toast.show(resData.name .. CommonText[223])
					return
				end				
			end

			AirshipBO.scoutAirship(function(data)
				if table.isexist(data, "validEndTime") then
					self.validEndTime = data.validEndTime
				end
				InfoDialog.new(data):push()
			end, airshipId)
		end):push()
end

-- 攻击
function AirshipInfo:attack(tag, sender)
	ManagerSound.playNormalButtonSound()

	if not PartyBO.getMyParty() then
		Toast.show(CommonText[421][2])
		return
	end

	local party = PartyBO.getMyParty()

	local ab = AirshipMO.queryShipById(self.id)

	if ab and ab.partyLevel > party.partyLv then
		Toast.show(string.format(CommonText[1111], ab.partyLevel))	
		return
	end

	if sender.state == 0 then
		-----每个玩家只能创建一个战事
		if not AirshipBO.team_ then
			AirshipBO.getAirshipTeamList(function ()
				if not AirshipBO.team_ then
					require_ex("app.dialog.AttackAirShipDialog").new(self.id, self.remianFreeCnt):push()
					-- AirshipBO.createAirshipTeam(self.id,function()
					-- 		-- self:checkState()
					-- 		self:pop(function()
					-- 				require("app.view.ArmyView").new(ARMY_VIEW_AIRSHIP,4):push()
					-- 				Toast.show(CommonText[997][1])
					-- 			end)
					-- 	end)
				else
					Toast.show(CommonText[1037])
				end
			end, true)
		else
			Toast.show(CommonText[1037])
		end
	elseif sender.state == 1 then
		self:pop(function()
				require("app.view.ArmyView").new(nil ,4):push()
			end)
	end
end

-- 发送信息
function AirshipInfo:sendMsg(tag, sender)
	local occupyName
	if self.data.occupy then
		occupyName = self.data.occupy.lordName
	end
	require("app.dialog.MailSendDialog").new(occupyName, MAIL_SEND_TYPE_NORMAL):push()
end

-- 重建
function AirshipInfo:reBuild(tag, sender)
	print("!!!!!!!!!!!reBuild!!!!!!!")
-- UserMO.getResource
	local ab = AirshipMO.queryShip(self.pos) -- 飞艇信息

	local repairs = json.decode(ab.repair)
	local resEnough = true
	local factor = AirshipMO.queryRebuildFactor(StaffMO.worldLv_)
	for i,v in ipairs(repairs) do
		if v[3] * factor > UserMO.getResource(v[1],v[2]) then
			resEnough = false
			break
		end
	end

	if not resEnough then
		---资源不足
		Toast.show(CommonText[528])
		return
	end

	local airshipId = self.id
	AirshipBO.asynRebuildAirship(function ()
		-- body
		self:showUI_()
	end, airshipId)
end

-- 征收记录
function AirshipInfo:LevyRecordCallback(tag, sender)
	local ab = AirshipMO.queryShip(self.pos) -- 飞艇信息
	local LevyRecordDialog = require("app.dialog.LevyRecordDialog")
	LevyRecordDialog.new(ab.id):push()
end

-- 关闭
function AirshipInfo:CloseAndCallback()
	AirshipBO.needUpdate_ = true
	AirshipBO.getAirship()
end

return AirshipInfo