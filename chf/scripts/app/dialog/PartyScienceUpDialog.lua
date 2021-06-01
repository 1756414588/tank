--
-- Author: gf
-- Date: 2015-09-14 17:43:07
-- 军团科技捐献
local ConfirmDialog = require("app.dialog.ConfirmDialog")
local Dialog = require("app.dialog.Dialog")
local PartyScienceUpDialog = class("PartyScienceUpDialog", Dialog)

function PartyScienceUpDialog:ctor(science)
	PartyScienceUpDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 860)})
	self.science = science
end

function PartyScienceUpDialog:onEnter()
	PartyScienceUpDialog.super.onEnter(self)
	
	self:setTitle(CommonText[595][2])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(self:getBg():getContentSize().width - 20, 850))
	self.btm = btm
	-- gdump(science,"PartyScienceUpDialog:ctor .. science")

	local scienceLvData =  PartyMO.queryScienceLevel(self.science.scienceId, self.science.scienceLv + 1)
	local scienceInfo = ScienceMO.queryScience(self.science.scienceId)
	self.scienceInfo = scienceInfo
	local itemView = UiUtil.createItemView(ITEM_KIND_SCIENCE, self.science.scienceId):addTo(btm)
	itemView:setPosition(110, btm:getContentSize().height - 110)

	local name = ui.newTTFLabel({text = scienceInfo.refineName .. ":LV." .. self.science.scienceLv, font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 180, y = btm:getContentSize().height - 70, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	name:setAnchorPoint(cc.p(0, 0.5))
	self.scienceName = name

	local desc = ui.newTTFLabel({text = scienceInfo.desc, font = G_FONT, size = FONT_SIZE_SMALL, 
		 color = COLOR[1], align = ui.TEXT_ALIGN_LEFT,
		dimensions = cc.size(280, 0)}):addTo(btm)
	desc:setPosition(180,btm:getContentSize().height - 90)
	desc:setAnchorPoint(cc.p(0, 1))
	

	--升级进度
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(btm)
	bar:setPosition(185 + bar:getContentSize().width / 2, btm:getContentSize().height - 155)
	-- bar.label = ui.newTTFLabel({text = self.science.schedule .. "/" .. scienceLvData.schedule, font = G_FONT, size = FONT_SIZE_SMALL, x = bar:getContentSize().width/2, y = bar:getContentSize().height/2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
	bar:setLabel(self.science.schedule .. "/" .. scienceLvData.schedule)
	bar:setPercent(self.science.schedule / scienceLvData.schedule)
	self.bar = bar

	local infoBg2 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_60.png"):addTo(self:getBg())
	infoBg2:setPreferredSize(cc.size(self:getBg():getContentSize().width - 50, 540))
	infoBg2:setCapInsets(cc.rect(80, 60, 1, 1))
	infoBg2:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height + 70 - infoBg2:getContentSize().height)
	self.infoBg2 = infoBg2

	self:showDonateUI()

	--一键捐献
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onDonateAllCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():width() - btn:width() / 2 - 20,self.infoBg2:y() - self.infoBg2:height() / 2 - btn:height() / 2)
	btn:setLabel(CommonText[1152])
end

function PartyScienceUpDialog:onDonateAllCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local resTab = CommonText[1153]
	local text = ""
	local canDonate = 0
	local costList = {}
	for index=1,PARTY_CONTRIBUTE_TYPE_STONE do
		local partyContribute = PartyMO.queryPartyContribute(index,PartyMO.scienceData_.donateData[index])

		local own = UserMO.getResource(ITEM_KIND_RESOURCE,index)
		if PartyMO.scienceData_.donateData[index] == PartyMO.queryPartyContributeMaxCount(index) or own < partyContribute.price then
			canDonate = canDonate + 1
		else
			local cost = (UiUtil.strNumSimplify(partyContribute.price))
			text = text .. resTab[index]..cost .. "、"
			costList[#costList + 1] = index
		end
	end
	local desc = CommonText[1155][1]..text..CommonText[1155][2]

	if canDonate < 5 then
		require("app.dialog.TipsAnyThingDialog").new(desc,function ()
			PartyBO.asynDonateAllScience(function (addSchedule,data)
				if addSchedule then
					Toast.show(string.format(CommonText[598][1],data.build,self.scienceInfo.refineName,data.build))
				else
					Toast.show(string.format(CommonText[598][2],data.build))
				end
				
				self:updateScienceInfo()
				self:showDonateUI()
			end,self.science,costList)
		end):push()
	else
		Toast.show(CommonText[1154])
	end
end

function PartyScienceUpDialog:showDonateUI()
	if self.node then
		self.infoBg2:removeChild(self.node, true)
	end

	local node = display.newNode():addTo(self.infoBg2)
	self.node = node
	local posX = {45, 120, 230, 340, 430}
	local posY = {375,295,215,135,455,55}
	-- gdump(PartyMO.scienceData_.donateData,"PartyMO.scienceData_.donateData")
	for index=1,#CommonText[597] do
		local labTit = ui.newTTFLabel({text = CommonText[597][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = self.infoBg2:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		labTit:setAnchorPoint(cc.p(0, 0.5))
		for type = 1,PARTY_CONTRIBUTE_TYPE_COIN do
			local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(node)
		   	line:setPreferredSize(cc.size(480, line:getContentSize().height))
		   	line:setPosition(self.infoBg2:getContentSize().width / 2, labTit:getPositionY() - 18 - (type - 1) * 80)

			--贡献配置
			local partyContribute = PartyMO.queryPartyContribute(type,PartyMO.scienceData_.donateData[type])
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
				if PartyMO.scienceData_.donateData[type] == PartyMO.queryPartyContributeMaxCount(type) then
					value:setString("-")
				else
					--判断是否有活动
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
				if PartyMO.scienceData_.donateData[type] == PartyMO.queryPartyContributeMaxCount(type) then
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
			elseif index == 4 then -- 建设度
				local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = labTit:getPositionX(), y = posY[type], color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				value:setAnchorPoint(cc.p(0, 0.5))
				if PartyMO.scienceData_.donateData[type] == PartyMO.queryPartyContributeMaxCount(type) then
					value:setString("-")
				else
					--火力全开活动是否开启
					if ActivityBO.isValid(ACTIVITY_ID_PARTY_DONATE) then
						value:setString("+" .. math.ceil(partyContribute.build * ACTIVITY_ID_PARTY_DONATE_RATE))
					else
						value:setString("+" .. partyContribute.build)
					end
				end
			elseif index == 5 then --贡献按钮
				--按钮
				local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
				local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
				local donateBtn = MenuButton.new(normal, selected, disabled, handler(self,self.donateHandler)):addTo(node)
				donateBtn:setPosition(labTit:getPositionX() + 20, posY[type])
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
				-- donateBtn:setEnabled(partyContribute and PartyMO.scienceData_.donateData[type] < PartyMO.queryPartyContributeMaxCount(type)
				-- 	and needCoin <= count and self.science.scienceLv < PartyMO.queryScienceMaxLevel(self.science.scienceId))

				donateBtn:setEnabled(partyContribute and needCoin <= count and PartyBO.scienceCanDonate(self.science,type))

			end
		end
	end
end

function PartyScienceUpDialog:donateHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.donateStatus == true then return end
	self.donateStatus = true

	function doDonate()
		Loading.getInstance():show()
		PartyBO.asynDonateScience(function(addSchedule)
			self.donateStatus = false
			Loading.getInstance():unshow()
			if addSchedule then
				Toast.show(string.format(CommonText[598][1],sender.build,self.scienceInfo.refineName,sender.build))
			else
				Toast.show(string.format(CommonText[598][2],sender.build))
			end
			
			self:updateScienceInfo()
			self:showDonateUI()
			end,self.science,sender.type,sender.build)
	end

	--判断是金币贡献
	if sender.type == PARTY_CONTRIBUTE_TYPE_COIN then
		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
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

function PartyScienceUpDialog:updateScienceInfo()
	local scienceInfo = ScienceMO.queryScience(self.science.scienceId)
	local scienceLvData =  PartyMO.queryScienceLevel(self.science.scienceId, self.science.scienceLv + 1)
	self.scienceName:setString(scienceInfo.refineName .. ":LV." .. self.science.scienceLv)
	if scienceLvData then
		self.bar:setPercent(self.science.schedule / scienceLvData.schedule)
		self.bar:setLabel(self.science.schedule .. "/" .. scienceLvData.schedule)
	else
		self.bar:setPercent(0)
		self.bar:setLabel("-")
	end
end

function PartyScienceUpDialog:onExit()
	PartyScienceUpDialog.super.onExit(self)
end


return PartyScienceUpDialog