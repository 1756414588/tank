--
-- Author: gf
-- Date: 2015-09-12 12:00:25
-- 军团大厅

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local PartyHallView = class("PartyHallView", UiNode)

function PartyHallView:ctor()
	PartyHallView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function PartyHallView:onEnter()
	PartyHallView.super.onEnter(self)
	
	self:setTitle(CommonText[565][2])

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, 165))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 110 - infoBg:getContentSize().height / 2)
	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_HALL,PartyMO.partyData_.partyLv)

	gdump(partyBuildLv,"PartyHallViewPartyHallView")
	for index=1,#CommonText[578] do
		local labTit = ui.newTTFLabel({text = CommonText[578][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 20, y = infoBg:getContentSize().height - 25 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		labTit:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then --军团名
			value:setString(PartyMO.partyData_.partyName)
		elseif index == 2 then --等级
			value:setString(PartyMO.partyData_.partyLv)
			self.buildLvLab_ = value
		elseif index == 3 then --升级需求
			if PartyMO.partyData_.partyLv == PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_HALL) then --等级已达上限
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
		elseif index == 4 then --总建设度
			value:setString(PartyMO.partyData_.build)
			self.buildValueLab_ = value
		end
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local levelUpBtn = MenuButton.new(normal, selected, disabled, handler(self,self.levelUpHandler)):addTo(infoBg)
	levelUpBtn:setPosition(infoBg:getContentSize().width - levelUpBtn:getContentSize().width / 2 - 10,infoBg:getContentSize().height - levelUpBtn:getContentSize().height / 2 - 10)
	levelUpBtn:setLabel(CommonText[582][1])
	levelUpBtn:setEnabled(PartyMO.partyData_.partyLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_HALL) and PartyMO.partyData_.build >= partyBuildLv.needExp)
	-- if PartyMO.partyData_.partyLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_HALL) then
	-- 	levelUpBtn.needExp = partyBuildLv.needExp
	-- end
	
	levelUpBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)
	self.levelUpBtn = levelUpBtn
	

	--捐献图片
	local infoBg1 = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(self:getBg())
	infoBg1:setPosition(infoBg1:getContentSize().width / 2 + 20,infoBg:getPositionY() - infoBg:getContentSize().height / 2 - 30)

	local donateTit = ui.newTTFLabel({text = CommonText[583], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 50, y = infoBg1:getContentSize().height / 2, 
		color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg1)
	donateTit:setAnchorPoint(cc.p(0, 0.5))

	local infoBg2 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(self:getBg())
	infoBg2:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, 540))
	infoBg2:setCapInsets(cc.rect(80, 60, 1, 1))
	infoBg2:setPosition(self:getBg():getContentSize().width / 2, infoBg1:getPositionY() - 30 - infoBg2:getContentSize().height / 2)
	self.infoBg2 = infoBg2
	self:showDonateUI()

	--一键捐献
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onDonateAllCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():width() - btn:width() / 2 - 20,self.infoBg2:y() - self.infoBg2:height() / 2 - btn:height() / 2)
	btn:setLabel(CommonText[1152])
end

function PartyHallView:onDonateAllCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local resTab = CommonText[1153]
	local text = ""
	local canDonate = 0
	local costList = {}
	for index=1,PARTY_CONTRIBUTE_TYPE_STONE do
		local partyContribute = PartyMO.queryPartyContribute(index,PartyMO.hallData_[index])

		local own = UserMO.getResource(ITEM_KIND_RESOURCE,index)
		if PartyMO.hallData_[index] == PartyMO.queryPartyContributeMaxCount(index) or own < partyContribute.price or partyContribute == nil then
			canDonate = canDonate + 1
		else
			costList[#costList + 1] = index
			local cost = (UiUtil.strNumSimplify(partyContribute.price))
			text = text .. resTab[index]..cost .. "、"
		end
	end
	local desc = CommonText[1155][1] .. text .. CommonText[1155][2]

	if canDonate < 5 then
		require("app.dialog.TipsAnyThingDialog").new(desc,function ()
			PartyBO.asynDonateAllParty(function (data)
				if table.isexist(data, "isBuild") then
					Toast.show(string.format(CommonText[584][1],data.build,data.build))
				else
					Toast.show(string.format(CommonText[584][2],data.build))
				end

				self:updateHallInfo()
				self:showDonateUI()
			end,costList)
		end):push()
	else
		Toast.show(CommonText[1154])
	end
end

function PartyHallView:showDonateUI()
	if self.node then
		self.infoBg2:removeChild(self.node, true)
	end

	local node = display.newNode():addTo(self.infoBg2)
	self.node = node
	local posX = {45, 120, 230, 340, 430, 520}
	-- local posY = {455,375,295,215,135,55}
	local posY = {375,295,215,135,455,55}
	-- gdump(PartyMO.hallData_,"PartyMO.hallData_")
	for index=1,#CommonText[580] do
		local labTit = ui.newTTFLabel({text = CommonText[580][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = self.infoBg2:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		labTit:setAnchorPoint(cc.p(0, 0.5))
		for type = 1,PARTY_CONTRIBUTE_TYPE_COIN do
			--贡献配置
			local partyContribute = PartyMO.queryPartyContribute(type,PartyMO.hallData_[type])
			local count
			if type == PARTY_CONTRIBUTE_TYPE_COIN then
				count = UserMO.getResource(ITEM_KIND_COIN)
			else
				count = UserMO.getResource(ITEM_KIND_RESOURCE,type)
			end
			if index == 1 then --类别ICON
				local view 
				if type == PARTY_CONTRIBUTE_TYPE_COIN then
					view = UiUtil.createItemView(ITEM_KIND_COIN):addTo(node)
				else
					view = UiUtil.createItemView(ITEM_KIND_RESOURCE,type):addTo(node)
				end
				view:setScale(0.65)
				view:setPosition(labTit:getPositionX() + 20, posY[type])
			elseif index == 2 then --捐献需求
				local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = labTit:getPositionX(), y = posY[type], color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				value:setAnchorPoint(cc.p(0, 0.5))
				if PartyMO.hallData_[type] == PartyMO.queryPartyContributeMaxCount(type) then
					value:setString("-")
				else
					--判断是否有金币返还活动
					if type == PARTY_CONTRIBUTE_TYPE_COIN and ActivityBO.isValid(ACTIVITY_ID_RTURN_DONATE) then
						value:setString(UiUtil.strNumSimplify(partyContribute.price * ACTIVITY_PARTY_DONATE_COIN_RATE))
					else
						value:setString(UiUtil.strNumSimplify(partyContribute.price))
					end
				end
			elseif index == 3 then --当前拥有
				local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = labTit:getPositionX(), y = posY[type], color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				value:setAnchorPoint(cc.p(0, 0.5))
				value:setString(UiUtil.strNumSimplify(count))
				if PartyMO.hallData_[type] == PartyMO.queryPartyContributeMaxCount(type) then
					local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", value:getPositionX() - 25, value:getPositionY()):addTo(node)
					tag:setScale(0.5)
					value:setColor(COLOR[11])
				else
					if partyContribute.price <= count then -- 足够
						local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", value:getPositionX() - 25, value:getPositionY()):addTo(node)
						tag:setScale(0.5)
						value:setColor(COLOR[11])
					else -- 不足够
						local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", value:getPositionX() - 25, value:getPositionY()):addTo(node)
						tag:setScale(0.5)
						value:setColor(COLOR[6])
					end
				end
			elseif index == 4 or index == 5 then -- 建设度 贡献
				local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = labTit:getPositionX(), y = posY[type], color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				value:setAnchorPoint(cc.p(0, 0.5))
				if PartyMO.hallData_[type] == PartyMO.queryPartyContributeMaxCount(type) then
					value:setString("-")
				else
					--火力全开活动是否开启
					if ActivityBO.isValid(ACTIVITY_ID_PARTY_DONATE) then
						value:setString("+" .. math.ceil(partyContribute.build * ACTIVITY_ID_PARTY_DONATE_RATE))
					else
						value:setString("+" .. partyContribute.build)
					end
				end
			elseif index == 6 then --贡献按钮
				--按钮
				local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
				local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
				local donateBtn = MenuButton.new(normal, selected, disabled, handler(self,self.donateHandler)):addTo(node)
				donateBtn:setPosition(labTit:getPositionX(), posY[type])
				donateBtn.type = type

				local needCoin
				if partyContribute then
					--火力全开活动是否开启
					if ActivityBO.isValid(ACTIVITY_ID_PARTY_DONATE) then
						donateBtn.build = math.ceil(partyContribute.build * ACTIVITY_ID_PARTY_DONATE_RATE)
					else
						donateBtn.build = partyContribute.build
					end
					--判断是否有活动
					if type == PARTY_CONTRIBUTE_TYPE_COIN and ActivityBO.isValid(ACTIVITY_ID_RTURN_DONATE) then
						needCoin = partyContribute.price * ACTIVITY_PARTY_DONATE_COIN_RATE
					else
						needCoin = partyContribute.price
					end
					donateBtn.needCoin = needCoin
				end
				donateBtn:setEnabled(PartyMO.hallData_[type] < PartyMO.queryPartyContributeMaxCount(type)
					and partyContribute and needCoin <= count)
			end
		end
	end
end

--更新军团大厅信息 等级 升级需求 建设度
function PartyHallView:updateHallInfo()
	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_HALL,PartyMO.partyData_.partyLv)
	--等级
	self.buildLvLab_:setString(PartyMO.partyData_.partyLv)
	--升级需求
	if PartyMO.partyData_.partyLv == PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_HALL) then --等级已达上限
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
	self.levelUpBtn:setEnabled(PartyMO.partyData_.partyLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_HALL) and PartyMO.partyData_.build >= partyBuildLv.needExp)
end

function PartyHallView:donateHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.donateStatus == true then return end
	self.donateStatus = true

	function doDonate()
		Loading.getInstance():show()
		PartyBO.asynDonateParty(function(isBuild)
			self.donateStatus = false
			Loading.getInstance():unshow()
			if isBuild then
				Toast.show(string.format(CommonText[584][1],sender.build,sender.build))
			else
				Toast.show(string.format(CommonText[584][2],sender.build))
			end
			
			self:updateHallInfo()
			self:showDonateUI()
			end,sender.type,sender.build)
	end
	--判断是金币贡献
	if sender.type == PARTY_CONTRIBUTE_TYPE_COIN then
		if UserMO.consumeConfirm then
			CoinConfirmDialog.new(string.format(CommonText[720],sender.needCoin), function()
					doDonate()
				end,function() self.donateStatus = false end):push()
		else
			doDonate()
		end
	else
		doDonate()
	end
end


function PartyHallView:levelUpHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.levelUpStatus == true then return end
	self.levelUpStatus = true

	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_HALL,PartyMO.partyData_.partyLv)

	Loading.getInstance():show()
	PartyBO.asynUpPartyBuilding(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[585])
		self:updateHallInfo()
		self.levelUpStatus = false
		end,PARTY_BUILD_ID_HALL, partyBuildLv.needExp)
end

function PartyHallView:onExit()
	PartyHallView.super.onExit(self)
end



return PartyHallView