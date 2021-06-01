--
-- Author: gf
-- Date: 2015-09-02 19:47:45
-- 抽将结果
local ConfirmDialog = require("app.dialog.ConfirmDialog")
local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local Dialog = require("app.dialog.Dialog")
local LotteryResultDialog = class("LotteryResultDialog", Dialog)

function LotteryResultDialog:ctor(type,heros)
	LotteryResultDialog.super.ctor(self, IMAGE_COMMON .. "lottery_result_bg.jpg", UI_ENTER_NONE)
	self.type = type
	self.heros = heros
end

function LotteryResultDialog:onEnter()
	LotteryResultDialog.super.onEnter(self)

	self:hasCloseButton(false)

	self:setTitle(CommonText[521])

	local infoTit = display.newSprite(IMAGE_COMMON .. "lottery_type_bg.png"):addTo(self:getBg())
	infoTit:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 +280)
	
	local typePic
	if self.type == 1 or self.type == 2 then
		typePic = display.newSprite(IMAGE_COMMON .. "lottery_gem.png", 156, 123):addTo(infoTit)
	else
		typePic = display.newSprite(IMAGE_COMMON .. "lottery_coin.png", 156, 123):addTo(infoTit)
	end
	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local quitBtn = MenuButton.new(normal, selected, nil, handler(self,self.quit)):addTo(self:getBg())
	quitBtn:setPosition(self:getBg():getContentSize().width / 2 - 180,self:getBg():getContentSize().height / 2 - 320)
	quitBtn:setLabel(CommonText[144])

	local reLotteryBtn,need
	-- if type == 1 then
	-- 	need = HeroMO.queryCost(2, HeroMO.resCount + 1).price
	-- elseif type == 2 then
	-- 	need = HeroBO.get5LotteryNeed(2)
	-- elseif type == 3 then
	-- 	need = HeroMO.queryCost(1, HeroMO.coinCount + 1).price
	-- else
	-- 	need = HeroBO.get5LotteryNeed(1)
	-- end
	need = HeroBO.getLotteryNeed(self.type)

	gdump(need,"HeroBO.getLotteryNeed(type)")


	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	reLotteryBtn = MenuButton.new(normal, selected, nil, handler(self,self.doLottery)):addTo(self:getBg())
	reLotteryBtn:setPosition(self:getBg():getContentSize().width / 2 + 180,self:getBg():getContentSize().height / 2 - 320)
	if self.type == 1 or self.type == 3 then
		reLotteryBtn:setLabel(CommonText[522][1],{size = FONT_SIZE_SMALL - 2, y = reLotteryBtn:getContentSize().height / 2 + 13})
	else
		reLotteryBtn:setLabel(CommonText[522][2],{size = FONT_SIZE_SMALL - 2, y = reLotteryBtn:getContentSize().height / 2 + 13})
	end

	reLotteryBtn.type = self.type
	reLotteryBtn.need = need
	self.reLotteryBtn = reLotteryBtn

	local icon,needLab
	if self.type == 1 or self.type == 2 then
		icon = display.newSprite(IMAGE_COMMON .. "icon_gem.png", reLotteryBtn:getContentSize().width / 2 - 30,reLotteryBtn:getContentSize().height / 2 - 10):addTo(reLotteryBtn)
		icon:setScale(0.5)
	else
		icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", reLotteryBtn:getContentSize().width / 2 - 30,reLotteryBtn:getContentSize().height / 2 - 10):addTo(reLotteryBtn)
	end
	
	needLab = ui.newBMFontLabel({text = UiUtil.strNumSimplify(need), font = "fnt/num_1.fnt"}):addTo(reLotteryBtn)
	needLab:setAnchorPoint(cc.p(0, 0.5))
	needLab:setPosition(icon:getPositionX() + icon:getContentSize().width / 2 + 5,icon:getPositionY())
	self.need_label_ = needLab

	--折扣图片
	--招兵买将活动是否开启
	local isActivityTime = ActivityBO.isValid(ACTIVITY_ID_HERO_RECRUIT)
	local discountPic
	if self.type == HeroMO.HERO_LOTTERY_TYPE_RES_1 then
		discountPic = display.newSprite(IMAGE_COMMON .. "discount_6.png"):addTo(reLotteryBtn)
	elseif self.type == HeroMO.HERO_LOTTERY_TYPE_RES_5 then
		discountPic = display.newSprite(IMAGE_COMMON .. "discount_5.png"):addTo(reLotteryBtn)
	elseif self.type == HeroMO.HERO_LOTTERY_TYPE_GOLD_1 then
		discountPic = display.newSprite(IMAGE_COMMON .. "discount_8.png"):addTo(reLotteryBtn)
	elseif self.type == HeroMO.HERO_LOTTERY_TYPE_GOLD_5 then
		discountPic = display.newSprite(IMAGE_COMMON .. "discount_7.png"):addTo(reLotteryBtn)
	end
	discountPic:setPosition(reLotteryBtn:getContentSize().width - 39,reLotteryBtn:getContentSize().height - 37)
	discountPic:setVisible(isActivityTime)

	self:showHeros(self.heros)
end

function LotteryResultDialog:doLottery(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.playEffect == true then return end

	function lotteryHandler()
		Loading.getInstance():show()
		HeroBO.asynDoLottery(function(type,heros)
			Loading.getInstance():unshow()
			self:showHeros(heros)
			--更新抽将消耗显示
			local need
			need = HeroBO.getLotteryNeed(type)
			
			self.need_label_:setString(UiUtil.strNumSimplify(need))
			self.reLotteryBtn.need = need

			end, sender.type)
	end

	--判断资源
	if sender.type == 1 or sender.type == 2 then
		if sender.need > UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE) then
			Toast.show(CommonText[528])
			return 
		else
			lotteryHandler()
		end
	elseif sender.type == 3 or sender.type == 4 then
		if sender.need > UserMO.getResource(ITEM_KIND_COIN) then
			require("app.dialog.CoinTipDialog").new():push()
			return 
		else
			if UserMO.consumeConfirm then
				CoinConfirmDialog.new(string.format(CommonText[721],sender.need), function()
					lotteryHandler()
					end):push()
			else
				lotteryHandler()
			end
		end
	end
end

function LotteryResultDialog:showHeros(heros)
	self.playEffect = true
	armature_add(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")


	if self.node then 
		self:getBg():removeChild(self.node,true)
	end
	local posEnd = {
		{x = 121, y = 300},
		{x = 320, y = 296},
		{x = 500, y = 292},
		{x = 193, y = 133},
		{x = 396, y = 118}
	}

	local posStart = {
		{x = 121, y = 400},
		{x = 320, y = 396},
		{x = 500, y = 392},
		{x = 193, y = 33},
		{x = 396, y = 18}
	}
	local node = display.newNode():addTo(self:getBg())
	self.node = node
	for index = 1,#heros do
		local bg
		local heroData = HeroMO.queryHero(heros[index].heroId)
		if index == 1 or index == 4 then
			bg = display.newSprite(IMAGE_COMMON .. "lottery_hero_bg1.png")
		else
			bg = display.newSprite(IMAGE_COMMON .. "lottery_hero_bg2.png")
		end
		bg:setScale(2)
		bg:setPosition(posStart[index].x,posStart[index].y)
		node:addChild(bg)

		local normal = UiUtil.createItemSprite(ITEM_KIND_HERO, heros[index].heroId)
		local selected = UiUtil.createItemSprite(ITEM_KIND_HERO, heros[index].heroId)
		local pic = MenuButton.new(normal, selected, nil, handler(self,self.heroDetail))
		pic.heroData = heroData
		-- local pic = UiUtil.createItemSprite(ITEM_KIND_HERO, heros[index].heroId)
		if index == 1 or index == 4 then
			pic:setPosition(bg:getContentSize().width / 2 + 20, bg:getContentSize().height / 2 + 10)
		else
			pic:setPosition(bg:getContentSize().width / 2 - 10, bg:getContentSize().height / 2 + 30)
		end
		bg:addChild(pic)
		
		local star = display.newSprite(IMAGE_COMMON .. "hero_star_" .. heroData.star .. ".png", pic:getContentSize().width / 2 * 0.8 - 60, pic:getContentSize().height * 0.8 + 20):addTo(pic)
		local nameBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(pic)
		nameBg:setPreferredSize(cc.size(120, 30))
		nameBg:setPosition(pic:getContentSize().width / 2, nameBg:getContentSize().height / 2)
		local name = ui.newTTFLabel({text = heroData.heroName, font = G_FONT, size = FONT_SIZE_SMALL, x = nameBg:getContentSize().width / 2, y = nameBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(nameBg)
		
		local spwArray = cc.Array:create()
		spwArray:addObject(cc.CallFuncN:create(function(sender)
					bg:setVisible(true)
				end))
		spwArray:addObject(cc.MoveTo:create(0.3, cc.p(posEnd[index].x,posEnd[index].y)))
		spwArray:addObject(cc.ScaleTo:create(0.3, 0.8))

		bg:setVisible(false)

		bg:runAction(
			transition.sequence({cc.DelayTime:create(0.2 * (index - 1)),cc.Spawn:create(spwArray),cc.CallFuncN:create(function(sender)
					local armature = armature_create("ui_flash", bg:getContentSize().width / 2, bg:getContentSize().height / 2, function (movementType, movementID, armature)
							if movementType == MovementEventType.COMPLETE then
								if index == #heros then
									self.playEffect = false
								end
								armature:removeSelf()
							end
					 end)
					armature:getAnimation():playWithIndex(0)
					armature:addTo(bg)
				end)}))

	end
end

function LotteryResultDialog:heroDetail(tag, sender)
	local heroData = sender.heroData
	require("app.dialog.HeroDetailDialog").new(heroData,2):push()
end

function LotteryResultDialog:quit()
	ManagerSound.playNormalButtonSound()
	if self.playEffect == true then return end
	self:pop()
end

function LotteryResultDialog:onExit()
	LotteryResultDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")
end


return LotteryResultDialog