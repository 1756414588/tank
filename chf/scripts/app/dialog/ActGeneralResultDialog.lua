--
-- Author: gf
-- Date: 2015-12-31 15:01:27
-- 名将招募

local ConfirmDialog = require("app.dialog.ConfirmDialog")
local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local Dialog = require("app.dialog.Dialog")
local ActGeneralResultDialog = class("ActGeneralResultDialog", Dialog)

function ActGeneralResultDialog:ctor(general,heros,closeCb,actId)
	ActGeneralResultDialog.super.ctor(self, IMAGE_COMMON .. "lottery_result_bg.jpg", UI_ENTER_NONE, {alpha = 0,y = display.cy + 50})
	self.heros = heros
	self.general = general
	self.closeCb = closeCb
	self.actId = actId
end

function ActGeneralResultDialog:onEnter()
	ActGeneralResultDialog.super.onEnter(self)

	self:hasCloseButton(false)

	self:setTitle(CommonText[521])

	local infoTit = display.newSprite(IMAGE_COMMON .. "lottery_type_bg.png"):addTo(self:getBg())
	infoTit:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 +280)
	
	local typePic = display.newSprite(IMAGE_COMMON .. "lottery_coin.png", 156, 123):addTo(infoTit)
	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local quitBtn = MenuButton.new(normal, selected, nil, handler(self,self.quit)):addTo(self:getBg())
	quitBtn:setPosition(self:getBg():getContentSize().width / 2 - 150,self:getBg():getContentSize().height / 2 - 465)
	quitBtn:setLabel(CommonText[144])

	local reLotteryBtn,need

	need = self.general.price

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	reLotteryBtn = MenuButton.new(normal, selected, nil, handler(self,self.doLottery)):addTo(self:getBg())
	reLotteryBtn:setPosition(self:getBg():getContentSize().width / 2 + 180,self:getBg():getContentSize().height / 2 - 465)
	reLotteryBtn:setLabel(string.format(CommonText[844],self.general.count),{size = FONT_SIZE_SMALL - 2, y = reLotteryBtn:getContentSize().height / 2 + 13})
	self.reLotteryBtn = reLotteryBtn

	local icon,needLab
	icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", reLotteryBtn:getContentSize().width / 2 - 30,reLotteryBtn:getContentSize().height / 2 - 10):addTo(reLotteryBtn)
	
	needLab = ui.newBMFontLabel({text = UiUtil.strNumSimplify(need), font = "fnt/num_1.fnt"}):addTo(reLotteryBtn)
	needLab:setAnchorPoint(cc.p(0, 0.5))
	needLab:setPosition(icon:getPositionX() + icon:getContentSize().width / 2 + 5,icon:getPositionY())
	self.need_label_ = needLab


	self:showHeros(self.heros)
end

function ActGeneralResultDialog:doLottery(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.playEffect == true then return end

	local cost = self.general.price
	
	function doLottery()
		if cost > UserMO.getResource(ITEM_KIND_COIN) then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActGeneral(function(heros)
			Loading.getInstance():unshow()
			self:showHeros(heros)
			end, self.general, self.actId)
	end
	if UserMO.consumeConfirm and cost > 0 then
		CoinConfirmDialog.new(string.format(CommonText[721],cost), function()
			doLottery()
			end):push()
	else
		doLottery()
	end
	
end

function ActGeneralResultDialog:showHeros(heros)
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

function ActGeneralResultDialog:heroDetail(tag, sender)
	local heroData = sender.heroData
	require("app.dialog.HeroDetailDialog").new(heroData,2):push()
end

function ActGeneralResultDialog:quit()
	ManagerSound.playNormalButtonSound()
	if self.playEffect == true then return end
	self:pop()
end

function ActGeneralResultDialog:onExit()
	ActGeneralResultDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")
	if self.closeCb then
		self.closeCb()
	end
end


return ActGeneralResultDialog