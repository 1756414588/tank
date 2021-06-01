--
-- Author: wz
-- Date: 2015-09-08 11:55:51
-- 军备换装


local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local WeaponryChangeView = class("WeaponryChangeView", UiNode)

local movieTime = 0.3
local movieTimeInterval = 0.01

function WeaponryChangeView:ctor(uiEnter,openColor)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	--WeaponryChangeView.super.ctor(self, "image/common/info_bg_84.png", uiEnter)
	self.openColor = openColor or 1
end

function WeaponryChangeView:onEnter()
	--WeaponryChangeView.super.onEnter(self)

	self:setUI()
	
end

function WeaponryChangeView:setUI()
	local bg = display.newNode()
	bg:setContentSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
	bg:setAnchorPoint(cc.p(0.5, 0.5))

	local bg1 = display.newSprite(IMAGE_COMMON .. "info_bg_30.jpg"):addTo(bg)
	bg1:setPosition(bg:getContentSize().width / 2,bg:getContentSize().height - bg1:getContentSize().height + 210)
	self.bg1 = bg1

	local bg2 = display.newSprite(IMAGE_COMMON .. "info_bg_33.jpg"):addTo(bg)
	bg2:setPosition(bg1:getPositionX() , bg1:getPositionY() - bg1:getContentSize().height / 2 - bg2:getContentSize().height / 2)
	UiUtil.label(CommonText[20196]):addTo(bg2):align(display.LEFT_CENTER, 24, 60)

	if self.openColor == LotteryMO.LOTTERY_EQUIP_VIEW_GREEN then
		self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_BLUE,LotteryMO.LOTTERY_EQUIP_VIEW_GREEN,LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE}
	elseif self.openColor == LotteryMO.LOTTERY_EQUIP_VIEW_BLUE then
		self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE,LotteryMO.LOTTERY_EQUIP_VIEW_BLUE,LotteryMO.LOTTERY_EQUIP_VIEW_GREEN}
	elseif self.openColor == LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE then
		self.equipData = {LotteryMO.LOTTERY_EQUIP_VIEW_GREEN,LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE,LotteryMO.LOTTERY_EQUIP_VIEW_BLUE}
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

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local equipBtn = MenuButton.new(normal, selected, nil, handler(self,self.equipHandler)):addTo(bg)
	equipBtn:setPosition(bg:getContentSize().width / 2 - 200,60)
	equipBtn:setLabel(CommonText[556][1])



	-- self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	-- self:scheduleUpdate()

	local goldLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = bg:getContentSize().width / 2 - 200, 
		y = 120}):addTo(bg)
	self.goldLab = goldLab

	local coinIcon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", 
		bg:getContentSize().width / 2 + 170,120):addTo(bg)
	self.coinIcon = coinIcon

	local needGoldLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = bg:getContentSize().width / 2 + 190, 
		y = 120}):addTo(bg)
	needGoldLab:setAnchorPoint(cc.p(0,0.5))
	self.needGoldLab = needGoldLab

	local coin9Icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", 
		bg:getContentSize().width / 2 - 30,120):addTo(bg)
	self.coin9Icon = coin9Icon

	local needGold9Lab = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11]}):addTo(bg)
	needGold9Lab:setPosition(coin9Icon:getPositionX() + coin9Icon:getContentSize().width / 2,120)
	needGold9Lab:setAnchorPoint(cc.p(0,0.5))
	self.needGold9Lab = needGold9Lab
	

	local listUI = display.newNode():addTo(bg)
	listUI:setPosition(bg:getContentSize().width / 2,bg:getContentSize().height - 400)

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

		-- local armaturetEffect = CCArmature:create("ui_lottery_equip_" .. self.equipData[i])
  --       armaturetEffect:setPosition(equipView:getContentSize().width / 2,equipView:getContentSize().height / 2)
  --       armaturetEffect:getAnimation():playWithIndex(0)
  --       armaturetEffect:connectMovementEventSignal(function(movementType, movementID) end)
  --       equipView:addChild(armaturetEffect)

        self["equipView"..i] = equipView
        listUI:addChild(self["equipView"..i])
    end

   	self:selectHeroHandle()

   	local bg3 = display.newSprite(IMAGE_COMMON .. "info_bg_34.png"):addTo(self.bg1)
	bg3:setPosition(self.bg1:getContentSize().width / 2, self.bg1:getContentSize().height / 2 + 275)

	local bg4 = display.newSprite(IMAGE_COMMON .. "info_bg_35.png"):addTo(bg3)
	bg4:setPosition(bg3:getContentSize().width / 2, bg3:getContentSize().height / 2 - 62)
	self.bg4 = bg4

end

function WeaponryChangeView:selectHeroHandle()
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

function WeaponryChangeView:turnHandler(tag, sender)
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

function WeaponryChangeView:playMovie(type)
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

function WeaponryChangeView:updateView()
end

function WeaponryChangeView:update(dt)
	
end


function WeaponryChangeView:onExit()

end




return WeaponryChangeView