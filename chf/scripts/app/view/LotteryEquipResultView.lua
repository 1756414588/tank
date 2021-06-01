--
-- Author: gf
-- Date: 2015-09-08 17:16:44
--
local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local LotteryEquipResultView = class("LotteryEquipResultView", UiNode)

function LotteryEquipResultView:ctor(m_view_type,doLotteryResult,closeCb)
	LotteryEquipResultView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	-- self:hasCloseButton(false)
	self.closeCb = closeCb
	self.doLotteryResult = doLotteryResult
	self.m_view_type = m_view_type
end

function LotteryEquipResultView:onEnter()
	LotteryEquipResultView.super.onEnter(self)

	self:setTitle(CommonText[555][1])

	local bg1 = display.newSprite(IMAGE_COMMON .. "info_bg_30.jpg"):addTo(self:getBg())
	bg1:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - bg1:getContentSize().height + 210)
	self.bg1 = bg1

	local bg2 = display.newSprite(IMAGE_COMMON .. "info_bg_33.jpg"):addTo(self:getBg())
	bg2:setPosition(bg1:getPositionX() , bg1:getPositionY() - bg1:getContentSize().height / 2 - bg2:getContentSize().height / 2)

	local bg3 = display.newSprite(IMAGE_COMMON .. "info_bg_34.png"):addTo(self.bg1)
	bg3:setPosition(self.bg1:getContentSize().width / 2, self.bg1:getContentSize().height / 2 + 275)

	local bg4 = display.newSprite(IMAGE_COMMON .. "info_bg_35.png"):addTo(bg3)
	bg4:setPosition(bg3:getContentSize().width / 2, bg3:getContentSize().height / 2 - 62)
	self.bg4 = bg4

	local goldLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = self:getBg():getContentSize().width / 2 - 200, 
		y = 120}):addTo(self:getBg())
	self.goldLab = goldLab

	local coinIcon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", 
		self:getBg():getContentSize().width / 2 + 170,120):addTo(self:getBg())
	self.coinIcon = coinIcon

	local needGoldLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = self:getBg():getContentSize().width / 2 + 190, 
		y = 120}):addTo(self:getBg())
	needGoldLab:setAnchorPoint(cc.p(0,0.5))
	self.needGoldLab = needGoldLab

	local coin9Icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", 
		self:getBg():getContentSize().width / 2 - 30,120):addTo(self:getBg())
	self.coin9Icon = coin9Icon

	local needGold9Lab = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11]}):addTo(self:getBg())
	needGold9Lab:setPosition(coin9Icon:getPositionX() + coin9Icon:getContentSize().width / 2,120)
	needGold9Lab:setAnchorPoint(cc.p(0,0.5))
	self.needGold9Lab = needGold9Lab
	
	if self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE then
		local cueLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[1],
			x = self:getBg():getContentSize().width - 20, 
			y = 160}):addTo(self:getBg())
		cueLab:setAnchorPoint(cc.p(1,0.5))
		self.cueLab = cueLab
	end
	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local quitBtn = MenuButton.new(normal, selected, nil, handler(self,self.quit)):addTo(self:getBg())
	quitBtn:setPosition(self:getBg():getContentSize().width / 2 - 200,60)
	quitBtn:setLabel(CommonText[144])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local lottery9Btn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(self:getBg())
	lottery9Btn:setPosition(self:getBg():getContentSize().width / 2 ,60)
	lottery9Btn:setLabel(CommonText[556][3])
	lottery9Btn:setVisible(self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE)
	lottery9Btn.type = LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE_9
	self.lottery9Btn = lottery9Btn

	local discountPic9 = display.newSprite(IMAGE_COMMON .. "discount_7.png"):addTo(lottery9Btn)
	discountPic9:setPosition(lottery9Btn:getContentSize().width - 39,lottery9Btn:getContentSize().height - 37)
	self.discountPic9 = discountPic9

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local lottery1Btn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(self:getBg())
	lottery1Btn:setPosition(self:getBg():getContentSize().width / 2 + 200,60)
	lottery1Btn:setLabel(CommonText[556][2])
	lottery1Btn.type = 5 + self.m_view_type
	self.lottery1Btn = lottery1Btn

	local discountPic = display.newSprite(IMAGE_COMMON .. "discount_8.png"):addTo(lottery1Btn)
	discountPic:setPosition(lottery1Btn:getContentSize().width - 39,lottery1Btn:getContentSize().height - 37)
	self.discountPic = discountPic

	self:updateView()
	self:showAwards(self.doLotteryResult.award)
end


function LotteryEquipResultView:lotteryHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- gprint(sender.type,"抽奖类别")

	--抽装折扣活动是否开启
	local isActivityTime = ActivityBO.isValid(ACTIVITY_ID_LOTTERY_EQUIP)

	--判断金币
	local cost = 0
	if sender.type == LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE_9 then
		if isActivityTime then
			cost = LotteryMO.LOTTERY_EQUIP_NEED[3] * 9 * LOTTERY_TYPE_EQUIP_PURPLE9_DISCOUNT
		else
			cost = LotteryMO.LOTTERY_EQUIP_NEED[3]*9
		end
	else
		local lotteryData = LotteryMO.getLotteryDataByType(self.m_view_type)
		if lotteryData.freetimes == 0 then
			if isActivityTime and self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE then
				cost = LotteryMO.LOTTERY_EQUIP_NEED[self.m_view_type] * LOTTERY_TYPE_EQUIP_PURPLE_DISCOUNT
			else
				cost = LotteryMO.LOTTERY_EQUIP_NEED[self.m_view_type]
			end
		end
	end
	if cost > UserMO.getResource(ITEM_KIND_COIN) then
		require("app.dialog.CoinTipDialog").new():push()
		return
	end

	if cost > 0 and UserMO.consumeConfirm then
		CoinConfirmDialog.new(string.format(CommonText[704],cost), function()
				self:confirmLottery(sender.type)
			end):push()
	else
		self:confirmLottery(sender.type)
	end
end

function LotteryEquipResultView:confirmLottery(type)
	--判断装备仓库是否已满
	local equips = EquipMO.getFreeEquipsAtPos()
	local remailCount = UserMO.equipWarhouse_ - #equips
	local needCount
	if type == LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE_9 then
		needCount = 9
	else
		needCount = 1
	end
	if needCount > remailCount then
		Toast.show(CommonText[711])
		return
	end
	
	Loading.getInstance():show()
	LotteryBO.doLotteryEquip(function(doLotteryResult)
		Loading.getInstance():unshow()
		self:showAwards(doLotteryResult.award)
		self:updateView()
		end,type,self.m_view_type)
end

function LotteryEquipResultView:updateView()
	--抽装折扣活动是否开启
	local isActivityTime = ActivityBO.isValid(ACTIVITY_ID_LOTTERY_EQUIP)

	local lotteryData = LotteryMO.getLotteryDataByType(self.m_view_type)
	self.goldLab:setString(CommonText[557][1] .. UserMO.getResource(ITEM_KIND_COIN))
	self.coinIcon:setVisible(lotteryData.freetimes == 0)
	if lotteryData.freetimes > 0 then
		self.needGoldLab:setVisible(false)
		self.needGoldLab:setString(CommonText[557][2] .. lotteryData.freetimes)
		self.lottery1Btn:setLabel(CommonText[556][4])
	else
		self.needGoldLab:setVisible(true)
		if isActivityTime and self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE then
			self.needGoldLab:setString(LotteryMO.LOTTERY_EQUIP_NEED[self.m_view_type] * LOTTERY_TYPE_EQUIP_PURPLE_DISCOUNT)
		else
			self.needGoldLab:setString(LotteryMO.LOTTERY_EQUIP_NEED[self.m_view_type])
		end
		self.lottery1Btn:setLabel(CommonText[556][2])
	end
	self.coin9Icon:setVisible(self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE)

	if isActivityTime then
		self.needGold9Lab:setString(LotteryMO.LOTTERY_EQUIP_NEED[LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE] * 9 * LOTTERY_TYPE_EQUIP_PURPLE9_DISCOUNT)
	else
		self.needGold9Lab:setString(LotteryMO.LOTTERY_EQUIP_NEED[LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE] * 9)
	end
	self.needGold9Lab:setVisible(self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE)

	self.lottery9Btn:setVisible(self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE)
	self.lottery1Btn.type = 5 + self.m_view_type

	if self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE then
		self.cueLab:setString(string.format(CommonText[707],lotteryData.purple))
	end

	self.discountPic:setVisible(isActivityTime and self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE)
	self.discountPic9:setVisible(isActivityTime)
end

function LotteryEquipResultView:showAwards(awards)
	if self.node then 
		self:getBg():removeChild(self.node,true)
	end
	local node = display.newNode():addTo(self:getBg())
	self.node = node
	if awards and #awards > 0 then
		if #awards == 1 then
			local itemBg = display.newSprite(IMAGE_COMMON .. "lottery_result_bg.png", 
				self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2 + 110)
			local itemView = UiUtil.createItemView(awards[1].type, awards[1].id, {equipLv = 1})
			itemView:setPosition(itemBg:getContentSize().width / 2,itemBg:getContentSize().height / 2 - 45)
			itemBg:addChild(itemView)
			UiUtil.createItemDetailButton(itemView)
			local itemName = ui.newTTFLabel({text = UserMO.getResourceData(awards[1].type, awards[1].id).name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[1],
			x = itemBg:getContentSize().width / 2, 
			y = 195}):addTo(itemBg)

			node:addChild(itemBg)
		else
			local middleX = self:getBg():getContentSize().width / 2
			local middleY = self:getBg():getContentSize().height / 2
			local pos = {
				{middleX - 180,middleY + 235},
				{middleX,middleY + 235},
				{middleX + 180,middleY + 235},
				{middleX - 180,middleY + 5},
				{middleX,middleY + 5},
				{middleX + 180,middleY + 5},
				{middleX - 180,middleY - 225},
				{middleX,middleY - 225},
				{middleX + 180,middleY - 225}
			}
			for index=1,#awards do
				local itemBg1 = display.newSprite(IMAGE_COMMON .. "lottery_result_bg1.png", 
				pos[index][1],pos[index][2] + 110)
				local itemBg = display.newSprite(IMAGE_COMMON .. "lottery_result_bg.png", 
				pos[index][1],pos[index][2])
				itemBg:setScale(0.75)
				local itemView = UiUtil.createItemView(awards[index].type, awards[index].id, {equipLv = 1})
				itemView:setPosition(pos[index][1],pos[index][2] - 30)
				UiUtil.createItemDetailButton(itemView)
				local itemName = ui.newTTFLabel({text = UserMO.getResourceData(awards[index].type, awards[index].id).name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
				color = COLOR[1],
				x = pos[index][1], 
				y = pos[index][2] + 40})

				node:addChild(itemBg1)
				node:addChild(itemBg)
				node:addChild(itemView)
				node:addChild(itemName)
			end
		end
	end
end

function LotteryEquipResultView:quit()
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function LotteryEquipResultView:onExit()
	if self.closeCb then
		self.closeCb()
	end
end


return LotteryEquipResultView