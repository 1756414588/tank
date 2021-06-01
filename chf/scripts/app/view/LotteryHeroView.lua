--
-- Author: gf
-- Date: 2015-09-02 17:05:37
--

-------------------------------------------------------------------
-- 将领招募view
--------------------------------------------------------------------
local ConfirmDialog = require("app.dialog.ConfirmDialog")
local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local LotteryHeroView = class("LotteryHeroView", UiNode)

function LotteryHeroView:ctor()
	LotteryHeroView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	
end

function LotteryHeroView:onEnter()
	LotteryHeroView.super.onEnter(self)

	self:setTitle(CommonText[521])
	self:hasCoinButton(true)
	self.m_updateLotteryHandler = Notify.register(LOCAL_UPDATE_HERO_LOTTERY_EVENT, handler(self, self.updateLotteryNeed))

	self:updatePage()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function LotteryHeroView:updatePage(type)
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)

	local pages = {CommonText[520][1],CommonText[520][2]}
	

	local function createYesBtnCallback(index)
		local button = nil

		local startPosX = 0
		local posXDelta = 0
		local sprite = display.newScale9Sprite(IMAGE_COMMON .. "btn_4_normal.png")
		sprite:setPreferredSize(cc.size(320, sprite:getContentSize().height))
		startPosX = sprite:getContentSize().width / 2
		posXDelta = 320
		local posY = size.height + 22
		local posX = startPosX + (index - 1) * posXDelta

		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_4_selected.png")
		normal:setPreferredSize(cc.size(320, normal:getContentSize().height))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_4_selected.png")
		selected:setPreferredSize(cc.size(320, selected:getContentSize().height))
		button = MenuButton.new(normal, selected, nil, nil)
		button:setPosition(posX, posY - 4)
		button:setLabel(pages[index])
		local icon
		if index == 1 then
			icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", button:getContentSize().width / 2 - 70,button:getContentSize().height / 2):addTo(button)
		else
			icon = display.newSprite(IMAGE_COMMON .. "icon_gem.png", button:getContentSize().width / 2 - 70,button:getContentSize().height / 2):addTo(button)
			icon:setScale(0.5)
		end
		
		-- local starPic
		-- if index > 1 then
		-- 	starPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. (index - 1) .. ".png", button:getContentSize().width / 2 - 20,button:getContentSize().height / 2):addTo(button)
		-- end
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil

		local startPosX = 0
		local posXDelta = 0
		local sprite = display.newScale9Sprite(IMAGE_COMMON .. "btn_4_normal.png")
		sprite:setPreferredSize(cc.size(320, sprite:getContentSize().height))
		startPosX = sprite:getContentSize().width / 2
		posXDelta = 320
		local posY = size.height + 22
		local posX = startPosX + (index - 1) * posXDelta

		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_4_normal.png")
		normal:setPreferredSize(cc.size(320, normal:getContentSize().height))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_4_normal.png")
		selected:setPreferredSize(cc.size(320, selected:getContentSize().height))
		button = MenuButton.new(normal, selected, nil, nil)
		button:setPosition(posX, posY)
		button:setLabel(pages[index], {color = COLOR[11]})

		local icon
		if index == 1 then
			icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", button:getContentSize().width / 2 - 70,button:getContentSize().height / 2):addTo(button)
		else
			icon = display.newSprite(IMAGE_COMMON .. "icon_gem.png", button:getContentSize().width / 2 - 70,button:getContentSize().height / 2):addTo(button)
			icon:setScale(0.5)
		end

		return button
	end

	local function createDelegate(container, index)
		local view = nil

		view = self:creatInfoUi(container,index):addTo(container)

		if view then
			view:setPosition(0, 0)
			-- view:reloadData()
		end

		local lottery1Btn,lottery5Btn,need1,need5
		--招兵买将活动是否开启
		local isActivityTime = ActivityBO.isValid(ACTIVITY_ID_HERO_RECRUIT)
		if index == 1 then 
			local needValue1 = HeroBO.getLotteryNeed(HeroMO.HERO_LOTTERY_TYPE_GOLD_1)
			local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
			lottery1Btn = MenuButton.new(normal, selected, nil, handler(self,self.doLottery)):addTo(container)
			lottery1Btn:setPosition(container:getContentSize().width / 2 - 180,50)
			lottery1Btn:setLabel(CommonText[522][1],{size = FONT_SIZE_SMALL - 2, y = lottery1Btn:getContentSize().height / 2 + 13})
			lottery1Btn.type = HeroMO.HERO_LOTTERY_TYPE_GOLD_1
			lottery1Btn.need = needValue1

			local icon1 = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lottery1Btn:getContentSize().width / 2 - 30,lottery1Btn:getContentSize().height / 2 - 10):addTo(lottery1Btn)
			need1 = ui.newBMFontLabel({text = UiUtil.strNumSimplify(needValue1), font = "fnt/num_1.fnt"}):addTo(lottery1Btn)
			need1:setAnchorPoint(cc.p(0, 0.5))
			need1:setPosition(icon1:getPositionX() + icon1:getContentSize().width / 2 + 5,icon1:getPositionY())

			local discountPic1 = display.newSprite(IMAGE_COMMON .. "discount_8.png"):addTo(lottery1Btn)
			discountPic1:setPosition(lottery1Btn:getContentSize().width - 39,lottery1Btn:getContentSize().height - 37)
			discountPic1:setVisible(isActivityTime)

			local needValue5 = HeroBO.getLotteryNeed(HeroMO.HERO_LOTTERY_TYPE_GOLD_5)
			local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
			lottery5Btn = MenuButton.new(normal, selected, nil, handler(self,self.doLottery)):addTo(container)
			lottery5Btn:setPosition(container:getContentSize().width / 2 + 180,50)
			lottery5Btn:setLabel(CommonText[522][2],{size = FONT_SIZE_SMALL - 2,y = lottery1Btn:getContentSize().height / 2 + 13})
			lottery5Btn.type = HeroMO.HERO_LOTTERY_TYPE_GOLD_5
			lottery5Btn.need = needValue5

			local icon5 = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lottery5Btn:getContentSize().width / 2 - 30,lottery5Btn:getContentSize().height / 2 - 10):addTo(lottery5Btn)
			need5 = ui.newBMFontLabel({text = UiUtil.strNumSimplify(needValue5), font = "fnt/num_1.fnt"}):addTo(lottery5Btn)
			need5:setAnchorPoint(cc.p(0, 0.5))
			need5:setPosition(icon5:getPositionX() + icon5:getContentSize().width / 2 + 5,icon5:getPositionY())

			local discountPic5 = display.newSprite(IMAGE_COMMON .. "discount_7.png"):addTo(lottery5Btn)
			discountPic5:setPosition(lottery5Btn:getContentSize().width - 39,lottery5Btn:getContentSize().height - 37)
			discountPic5:setVisible(isActivityTime)
		else
			local needValue1 = HeroBO.getLotteryNeed(HeroMO.HERO_LOTTERY_TYPE_RES_1)
			local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
			lottery1Btn = MenuButton.new(normal, selected, nil, handler(self,self.doLottery)):addTo(container)
			lottery1Btn:setPosition(container:getContentSize().width / 2 - 180,50)
			lottery1Btn:setLabel(CommonText[522][1],{size = FONT_SIZE_SMALL - 2, y = lottery1Btn:getContentSize().height / 2 + 13})
			lottery1Btn.type = HeroMO.HERO_LOTTERY_TYPE_RES_1
			lottery1Btn.need = needValue1

			local icon1 = display.newSprite(IMAGE_COMMON .. "icon_gem.png", lottery1Btn:getContentSize().width / 2 - 30,lottery1Btn:getContentSize().height / 2 - 10):addTo(lottery1Btn)
			icon1:setScale(0.5)
			need1 = ui.newBMFontLabel({text = UiUtil.strNumSimplify(needValue1), font = "fnt/num_1.fnt"}):addTo(lottery1Btn)
			need1:setAnchorPoint(cc.p(0, 0.5))
			need1:setPosition(icon1:getPositionX() + icon1:getContentSize().width * 0.5 / 2 + 5,icon1:getPositionY())

			local discountPic1 = display.newSprite(IMAGE_COMMON .. "discount_6.png"):addTo(lottery1Btn)
			discountPic1:setPosition(lottery1Btn:getContentSize().width - 39,lottery1Btn:getContentSize().height - 37)
			discountPic1:setVisible(isActivityTime)

			local needValue5 = HeroBO.getLotteryNeed(HeroMO.HERO_LOTTERY_TYPE_RES_5)
			local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
			lottery5Btn = MenuButton.new(normal, selected, nil, handler(self,self.doLottery)):addTo(container)
			lottery5Btn:setPosition(container:getContentSize().width / 2 + 180,50)
			lottery5Btn:setLabel(CommonText[522][2],{size = FONT_SIZE_SMALL - 2,y = lottery1Btn:getContentSize().height / 2 + 13})
			lottery5Btn.type = HeroMO.HERO_LOTTERY_TYPE_RES_5
			lottery5Btn.need = needValue5

			local icon5 = display.newSprite(IMAGE_COMMON .. "icon_gem.png", lottery5Btn:getContentSize().width / 2 - 30,lottery5Btn:getContentSize().height / 2 - 10):addTo(lottery5Btn)
			icon5:setScale(0.5)
			need5 = ui.newBMFontLabel({text = UiUtil.strNumSimplify(needValue5), font = "fnt/num_1.fnt"}):addTo(lottery5Btn)
			need5:setAnchorPoint(cc.p(0, 0.5))
			need5:setPosition(icon5:getPositionX() + icon5:getContentSize().width / 2 * 0.5 + 5,icon5:getPositionY())

			local discountPic5 = display.newSprite(IMAGE_COMMON .. "discount_5.png"):addTo(lottery5Btn)
			discountPic5:setPosition(lottery5Btn:getContentSize().width - 39,lottery5Btn:getContentSize().height - 37)
			discountPic5:setVisible(isActivityTime)
		end
		self.lottery1Btn = lottery1Btn
		self.lottery5Btn = lottery5Btn
		self.need1_label_ = need1
		self.need5_label_ = need5

	end

	local function clickDelegate(container, index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView


end

function LotteryHeroView:creatInfoUi(container,type)
	local uiContainer = display.newNode()

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(uiContainer)
	infoBg:setPreferredSize(cc.size(590, 680))
	infoBg:setPosition(container:getContentSize().width / 2, 320 + container:getContentSize().height - infoBg:getContentSize().height)

	local infoPic = display.newSprite(IMAGE_COMMON .. "info_bg_12.png", 140, 640):addTo(infoBg)
	local infoTit = ui.newTTFLabel({text = CommonText[523], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, 
		y = infoPic:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(infoPic)
	infoTit:setAnchorPoint(cc.p(0, 0.5))

	--概率公示
	if UserMO.queryFuncOpen(UFP_CHANCE_HERO) then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.chanceHero):push()
		end):addTo(container,999)
		chanceBtn:setPosition(container:width() - 100,container:height() - 60)
	end

	local infoContent1 = ui.newTTFLabel({text = string.format(CommonText[524],UserMO.getResourceData(ITEM_KIND_RESOURCE,RESOURCE_ID_STONE).name), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, 
		y = 600, align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(530, 0), color = COLOR[11]}):addTo(infoBg)
	-- infoContent1:setAnchorPoint(cc.p(0, 0.5))
	local infoContent2 = ui.newTTFLabel({text = CommonText[525], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, 
		y = infoContent1:y() - infoContent1:height()/2 - 15, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	infoContent2:setAnchorPoint(cc.p(0, 0.5))
	local infoContent3 = ui.newTTFLabel({text = CommonText[526], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, 
		y = infoContent2:y() - infoContent2:height()/2 - 15, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	infoContent3:setAnchorPoint(cc.p(0, 0.5))
	local infoContent4 = ui.newTTFLabel({text = CommonText[527], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 260, 
		y = infoContent3:y(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
	infoContent4:setAnchorPoint(cc.p(0, 0.5))

	local heroPicBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_position_normal.png"):addTo(infoBg)
	heroPicBg:setPreferredSize(cc.size(526, 507))
	heroPicBg:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height / 2 - 90)
	local heroPic
	if type == 1 then
		heroPic = display.newSprite(IMAGE_COMMON .. "lottery_coin_bg.jpg", heroPicBg:getContentSize().width / 2, heroPicBg:getContentSize().height / 2):addTo(heroPicBg)
	else
		heroPic = display.newSprite(IMAGE_COMMON .. "lottery_gem_bg.jpg", heroPicBg:getContentSize().width / 2, heroPicBg:getContentSize().height / 2):addTo(heroPicBg)
	end
	local typeBg = display.newSprite(IMAGE_COMMON .. "lottery_type_bg.png", heroPicBg:getContentSize().width / 2, heroPicBg:getContentSize().height / 2 - 170):addTo(heroPicBg)
	typeBg:setScale(0.78)

	local typePic
	if type == 1 then
		typePic = display.newSprite(IMAGE_COMMON .. "lottery_coin.png", 156, 123):addTo(typeBg)
	else
		typePic = display.newSprite(IMAGE_COMMON .. "lottery_gem.png", 156, 123):addTo(typeBg)
	end
	return uiContainer
end

function LotteryHeroView:doLottery(tag, sender)
	ManagerSound.playNormalButtonSound()
	gdump(sender.type,"[LotteryHeroView:doLottery..]")
	function lotteryHandler()
		Loading.getInstance():show()
		HeroBO.asynDoLottery(function(type,heros)
			Loading.getInstance():unshow()
			self:showLotteryResult(type,heros)
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

function LotteryHeroView:updateLotteryNeed()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

function LotteryHeroView:showLotteryResult(type, heros)
	require("app.dialog.LotteryResultDialog").new(type,heros):push()
end

function LotteryHeroView:onExit()
	-- gprint("LotteryHeroView onExit() ........................")
	LotteryHeroView.super.onExit(self)
	if self.m_updateLotteryHandler then
		Notify.unregister(self.m_updateLotteryHandler)
		self.m_updateLotteryHandler = nil
	end
end


return LotteryHeroView