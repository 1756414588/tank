--
-- Author: gf
-- Date: 2015-09-08 11:55:51
-- 抽装备


local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local LotteryEquipView = class("LotteryEquipView", UiNode)

local movieTime = 0.3
local movieTimeInterval = 0.01

function LotteryEquipView:ctor(uiEnter,openColor)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	LotteryEquipView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
	self.openColor = openColor
end

function LotteryEquipView:onEnter()
	LotteryEquipView.super.onEnter(self)

	self:setTitle(CommonText[555][1])
	self:hasCoinButton(true)
	Loading.getInstance():show()
	LotteryBO.getLotteryEquip(function()
		Loading.getInstance():unshow()
		self:setUI()
		end)
	
	self.m_equipHandler = Notify.register(LOCAL_UPDATE_EQUIP_LOTTERY_EVENT, handler(self, self.updateView))
end

function LotteryEquipView:setUI()
	local bg1 = display.newSprite(IMAGE_COMMON .. "info_bg_30.jpg"):addTo(self:getBg())
	bg1:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - bg1:getContentSize().height + 210)
	self.bg1 = bg1

	local bg2 = display.newSprite(IMAGE_COMMON .. "info_bg_33.jpg"):addTo(self:getBg())
	bg2:setPosition(bg1:getPositionX() , bg1:getPositionY() - bg1:getContentSize().height / 2 - bg2:getContentSize().height / 2)
	UiUtil.label(CommonText[20196]):addTo(bg2):align(display.LEFT_CENTER, 24, 60)
	--动画
	armature_add("animation/effect/ui_lottery_equip.pvr.ccz", "animation/effect/ui_lottery_equip.plist", "animation/effect/ui_lottery_equip_1.xml")
	armature_add("animation/effect/ui_lottery_equip.pvr.ccz", "animation/effect/ui_lottery_equip.plist", "animation/effect/ui_lottery_equip_2.xml")
	armature_add("animation/effect/ui_lottery_equip.pvr.ccz", "animation/effect/ui_lottery_equip.plist", "animation/effect/ui_lottery_equip_3.xml")
	armature_add("animation/effect/ui_lottery_equip.pvr.ccz", "animation/effect/ui_lottery_equip.plist", "animation/effect/ui_lottery_equip_arrow.xml")

	if self.openColor then
		if self.openColor == LotteryMO.LOTTERY_EQUIP_VIEW_GREEN then
			self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_BLUE,LotteryMO.LOTTERY_EQUIP_VIEW_GREEN,LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE}
		elseif self.openColor == LotteryMO.LOTTERY_EQUIP_VIEW_BLUE then
			self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE,LotteryMO.LOTTERY_EQUIP_VIEW_BLUE,LotteryMO.LOTTERY_EQUIP_VIEW_GREEN}
		elseif self.openColor == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE then
			self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_GREEN,LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE,LotteryMO.LOTTERY_EQUIP_VIEW_BLUE}
		end
	else
		--根据免费次数判断默认进来的颜色
		local greenFreeTimes = LotteryMO.getLotteryDataByType(LotteryMO.LOTTERY_EQUIP_VIEW_GREEN).freetimes
		local blueFreeTimes = LotteryMO.getLotteryDataByType(LotteryMO.LOTTERY_EQUIP_VIEW_BLUE).freetimes
		local purpleFreeTimes = LotteryMO.getLotteryDataByType(LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE).freetimes
		if greenFreeTimes > 0 then
			self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_BLUE,LotteryMO.LOTTERY_EQUIP_VIEW_GREEN,LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE}
		elseif blueFreeTimes > 0 then
			self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE,LotteryMO.LOTTERY_EQUIP_VIEW_BLUE,LotteryMO.LOTTERY_EQUIP_VIEW_GREEN}
		elseif purpleFreeTimes > 0 then
			self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_GREEN,LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE,LotteryMO.LOTTERY_EQUIP_VIEW_BLUE}
		else
			self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_BLUE,LotteryMO.LOTTERY_EQUIP_VIEW_GREEN,LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE}
		end
	end
	

    self.selectHero = 2
	self.m_view_type = self.equipData[self.selectHero]

 	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
    normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	selected:setScale(-1)
	local leftBtn = MenuButton.new(normal, selected, nil, handler(self,self.turnHandler)):addTo(bg1)
	leftBtn:setPosition(bg1:getContentSize().width / 2 - 220,bg1:getContentSize().height / 2 - 250)
    leftBtn.type = "next"

    local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local rightBtn = MenuButton.new(normal, selected, nil, handler(self,self.turnHandler)):addTo(bg1)
	rightBtn:setPosition(bg1:getContentSize().width / 2 + 220,bg1:getContentSize().height / 2 - 250)
	rightBtn.type = "pre"


	--概率公示
	if UserMO.queryFuncOpen(UFP_CHANCE_EQUIP) then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.chanceEquip):push()
		end):addTo(bg1)
		chanceBtn:setPosition(bg1:getContentSize().width / 2 + 220,bg1:getContentSize().height / 2 - 180)
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local equipBtn = MenuButton.new(normal, selected, nil, handler(self,self.equipHandler)):addTo(self:getBg())
	equipBtn:setPosition(self:getBg():getContentSize().width / 2 - 200,60)
	equipBtn:setLabel(CommonText[556][1])

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

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

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
	

	local listUI = display.newNode():addTo(self:getBg())
	listUI:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - 400)

    self.posList = {{x = -180,y = 70},{x = 0,y = -70},{x = 180,y = 70}}

    function movedCallback(tag,sender,x,y)

    	if x < self.touchPosX then
    		self:turnHandler(nil,{type = "next"})
    	elseif x > self.touchPosX then
    		self:turnHandler(nil,{type = "pre"})
    	end
    end

    function beganCallback(tag,sender,x,y)
    	self.touchPosX = x
    end
    for i = 1, #self.equipData do
    	local normal = display.newSprite(IMAGE_COMMON .. "lottery_equip_bg" .. self.equipData[i] .. ".png")
    	
    	local equipView = TouchButton.new(normal, beganCallback, movedCallback, nil, nil)
    	equipView:setPosition(self.posList[i].x, self.posList[i].y)

    	
    	local dicePic = display.newSprite(IMAGE_COMMON .. "lottery_equip_icon" .. self.equipData[i] .. ".png"):addTo(equipView)
    	dicePic:setPosition(equipView:getContentSize().width / 2, equipView:getContentSize().height / 2 + 50)

    	local label = ui.newTTFLabel({text = CommonText[558], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1],
		x = equipView:getContentSize().width / 2, 
		y = 160}):addTo(equipView)

		if self.equipData[i] == LotteryMO.LOTTERY_EQUIP_VIEW_GREEN then
			local icon = display.newSprite(IMAGE_COMMON .. "lottery_equip_white.png",
				equipView:getContentSize().width / 2 - 50,
				115):addTo(equipView)
			local icon1 = display.newSprite(IMAGE_COMMON .. "lottery_equip_green.png",
				equipView:getContentSize().width / 2 + 50,
				115):addTo(equipView)
		elseif self.equipData[i] == LotteryMO.LOTTERY_EQUIP_VIEW_BLUE then
			local icon = display.newSprite(IMAGE_COMMON .. "lottery_equip_green.png",
				equipView:getContentSize().width / 2 - 60,
				115):addTo(equipView)
			local icon1 = display.newSprite(IMAGE_COMMON .. "lottery_equip_blue.png",
				equipView:getContentSize().width / 2,
				115):addTo(equipView)
			local icon2 = display.newSprite(IMAGE_COMMON .. "lottery_equip_purple.png",
				equipView:getContentSize().width / 2 + 60,
				115):addTo(equipView)
		elseif self.equipData[i] == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE then
			local icon = display.newSprite(IMAGE_COMMON .. "lottery_equip_blue.png",
				equipView:getContentSize().width / 2 - 50,
				115):addTo(equipView)
			local icon1 = display.newSprite(IMAGE_COMMON .. "lottery_equip_purple.png",
				equipView:getContentSize().width / 2 + 50,
				115):addTo(equipView)
		end

		local infoLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1],
		x = equipView:getContentSize().width / 2, 
		y = 60}):addTo(equipView)
		equipView.infoLab = infoLab
		local lotteryData = LotteryMO.getLotteryDataByType(self.equipData[i])
		if lotteryData.freetimes > 0 then
			infoLab:setString(CommonText[557][2] .. lotteryData.freetimes)
		end

		if self.equipData[i] == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE then
			local cueLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
				color = COLOR[1],
				x = equipView:getContentSize().width / 2, 
				y = 0}):addTo(equipView)

			if table.isexist(lotteryData, "isFirst") and lotteryData.isFirst == 0 then
				cueLab:setString(CommonText[748])
			else
				cueLab:setString(string.format(CommonText[707],lotteryData.purple))
			end
			self.cueLab = cueLab
		end

		local armaturetEffect = CCArmature:create("ui_lottery_equip_" .. self.equipData[i])
        armaturetEffect:setPosition(equipView:getContentSize().width / 2,equipView:getContentSize().height / 2)
        armaturetEffect:getAnimation():playWithIndex(0)
        armaturetEffect:connectMovementEventSignal(function(movementType, movementID) end)
        equipView:addChild(armaturetEffect)

        self["equipView"..i] = equipView
        listUI:addChild(self["equipView"..i])
    end

   	self:selectHeroHandle()

   	local bg3 = display.newSprite(IMAGE_COMMON .. "info_bg_34.png"):addTo(self.bg1)
	bg3:setPosition(self.bg1:getContentSize().width / 2, self.bg1:getContentSize().height / 2 + 275)

	local bg4 = display.newSprite(IMAGE_COMMON .. "info_bg_35.png"):addTo(bg3)
	bg4:setPosition(bg3:getContentSize().width / 2, bg3:getContentSize().height / 2 - 62)
	self.bg4 = bg4

	local armaturetEffect = CCArmature:create("ui_lottery_equip_arrow")
    armaturetEffect:setPosition(bg3:getContentSize().width / 2,bg3:getContentSize().height / 2 - 30)
    armaturetEffect:getAnimation():playWithIndex(0)
    armaturetEffect:connectMovementEventSignal(function(movementType, movementID) end)
    bg3:addChild(armaturetEffect)
end

function LotteryEquipView:selectHeroHandle()
	self.m_view_type = self.equipData[self.selectHero]
    for i = 1, #self.equipData do
        if self.equipData[i] == self.m_view_type then
            self["equipView"..i]:setScale(1)
            self["equipView"..i]:setZOrder(10)
        	self["equipView"..i]:setOpacity(255)
        else
            self["equipView"..i]:setScale(0.8)
            self["equipView"..i]:setZOrder(9)
            self["equipView"..i]:setOpacity(150)
        end
    end
    self:updateView()
end

function LotteryEquipView:turnHandler(tag, sender)
	if self.playState == true then return end 
	ManagerSound.playNormalButtonSound()
	-- gprint(sender.type)
	local type = sender.type
	if self.playState == true then return end 
	if type == "next" then
        self.selectHero = self.selectHero + 1 
        if self.selectHero == 4 then
            self.selectHero = 1
        end
    else
        self.selectHero = self.selectHero - 1
        if self.selectHero == 0 then
            self.selectHero = 3
        end
    end
    self.nextHero = self.selectHero + 1
    if self.nextHero == 4 then
        self.nextHero = 1
    end
    self.preHero = self.selectHero - 1
    if self.preHero == 0 then
        self.preHero = 3
    end
    
    self:playMovie(type)

end

function LotteryEquipView:playMovie(type)
    self.showTime = movieTime
    self.playState = true
    local step = movieTime / movieTimeInterval
    local selectHeroX = self.posList[2].x - self["equipView"..self.selectHero]:getPositionX()
    local selectHeroY = self.posList[2].y - self["equipView"..self.selectHero]:getPositionY()

    local nextHeroX = self.posList[3].x - self["equipView"..self.nextHero]:getPositionX()
    local nextHeroY = self.posList[3].y - self["equipView"..self.nextHero]:getPositionY()
    local preHeroX = self.posList[1].x - self["equipView"..self.preHero]:getPositionX()
    local preHeroY = self.posList[1].y - self["equipView"..self.preHero]:getPositionY()

    local nextHeroScal
    local preHeroScal

    if type == "next" then
        nextHeroScal = nil
        preHeroScal = 0.8 - self["equipView"..self.preHero]:getScale()
        self["equipView"..self.selectHero]:setZOrder(10)
        self["equipView"..self.nextHero]:setZOrder(8)
        self["equipView"..self.preHero]:setZOrder(9)
    else
        nextHeroScal = 0.8 - self["equipView"..self.nextHero]:getScale()
        preHeroScal = nil
        self["equipView"..self.selectHero]:setZOrder(10)
        self["equipView"..self.nextHero]:setZOrder(9)
        self["equipView"..self.preHero]:setZOrder(8)
    end
    local function timeSet()
        if self.showTime > 0 then
            self.showTime = self.showTime - movieTimeInterval
            self["equipView"..self.selectHero]:setScale(0.2 / step + self["equipView"..self.selectHero]:getScale())
            self["equipView"..self.selectHero]:setPosition(
                selectHeroX / step + self["equipView"..self.selectHero]:getPositionX(),
                selectHeroY / step + self["equipView"..self.selectHero]:getPositionY()
                )

            self["equipView"..self.nextHero]:setPosition(
                nextHeroX / step + self["equipView"..self.nextHero]:getPositionX(),
                nextHeroY / step + self["equipView"..self.nextHero]:getPositionY()
                )
            self["equipView"..self.preHero]:setPosition(
                preHeroX / step + self["equipView"..self.preHero]:getPositionX(),
                preHeroY / step + self["equipView"..self.preHero]:getPositionY()
                )
            if nextHeroScal then 
                self["equipView"..self.nextHero]:setScale(nextHeroScal / step + self["equipView"..self.nextHero]:getScale())
            end
            if preHeroScal then 
                self["equipView"..self.preHero]:setScale(preHeroScal / step + self["equipView"..self.preHero]:getScale())
            end
        else 
            self["equipView"..self.selectHero]:setScale(1)
            self["equipView"..self.selectHero]:setPosition(
                self.posList[2].x,
                self.posList[2].y
                )

            self["equipView"..self.nextHero]:setPosition(
                self.posList[3].x,
                self.posList[3].y
                )
            self["equipView"..self.preHero]:setPosition(
                self.posList[1].x,
                self.posList[1].y
                )
            if type == "next" then 
                self["equipView"..self.preHero]:setScale(0.8)
            else
                self["equipView"..self.nextHero]:setScale(0.8)
            end
            self.playState = false
            self.showTime = 0
            self:stopAllActions()
            self:selectHeroHandle()
        end
    end
    local oneSec = transition.sequence({
                                        CCCallFunc:create(timeSet),
                                        CCDelayTime:create(movieTimeInterval)
                                       })
    self:runAction(CCRepeatForever:create(oneSec))
end

function LotteryEquipView:updateView()
	--抽装折扣活动是否开启
	local isActivityTime = ActivityBO.isValid(ACTIVITY_ID_LOTTERY_EQUIP)

	self.m_view_type = self.equipData[self.selectHero]
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
		if table.isexist(lotteryData, "isFirst") and lotteryData.isFirst  == 0 then
			self.cueLab:setString(CommonText[748])
		else
			self.cueLab:setString(string.format(CommonText[707],lotteryData.purple))
		end
	end

	self.discountPic:setVisible(isActivityTime and self.m_view_type == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE)
	self.discountPic9:setVisible(isActivityTime)
end

function LotteryEquipView:lotteryHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.playState == true then return end 
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

function LotteryEquipView:confirmLottery(type)
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
		self:showLotteryResult(doLotteryResult)
		self:updateView()
		end,type,self.m_view_type)
end

function LotteryEquipView:equipHandler()
	ManagerSound.playNormalButtonSound()
	require("app.view.EquipView").new(UI_ENTER_FADE_IN_GATE):push()
end

function LotteryEquipView:update(dt)
	for i = 1, #self.equipData do
		local lotteryData = LotteryMO.getLotteryDataByType(self.equipData[i])
		if lotteryData.freetimes and lotteryData.freetimes == 0 then
			if lotteryData.cd > 0 then
				self["equipView"..i].infoLab:setString(string.format(CommonText[557][3],UiUtil.strBuildTime(lotteryData.cd)))
			end
		else
			self["equipView"..i].infoLab:setString(CommonText[557][2] .. lotteryData.freetimes)
		end		
	end
	
end

function LotteryEquipView:showLotteryResult(doLotteryResult)
	require("app.view.LotteryEquipResultView").new(self.m_view_type,doLotteryResult,handler(self,self.updateView)):push()
end


function LotteryEquipView:showButtons()


end

function LotteryEquipView:onExit()
	LotteryEquipView.super.onExit(self)
	armature_remove("animation/effect/ui_lottery_equip.pvr.ccz", "animation/effect/ui_lottery_equip.plist", "animation/effect/ui_lottery_equip_1.xml")
	armature_remove("animation/effect/ui_lottery_equip.pvr.ccz", "animation/effect/ui_lottery_equip.plist", "animation/effect/ui_lottery_equip_2.xml")
	armature_remove("animation/effect/ui_lottery_equip.pvr.ccz", "animation/effect/ui_lottery_equip.plist", "animation/effect/ui_lottery_equip_3.xml")
	armature_remove("animation/effect/ui_lottery_equip.pvr.ccz", "animation/effect/ui_lottery_equip.plist", "animation/effect/ui_lottery_equip_arrow.xml")
	if self.m_equipHandler then
		Notify.unregister(self.m_equipHandler)
		self.m_equipHandler = nil
	end
end




return LotteryEquipView