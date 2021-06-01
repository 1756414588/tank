--
-- Author: gf
-- Date: 2015-09-03 11:14:46
-- 将领进阶

local ConfirmDialog = require("app.dialog.ConfirmDialog")
local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local HeroImproveView = class("HeroImproveView", UiNode)

function HeroImproveView:ctor()
	HeroImproveView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)

end

function HeroImproveView:onEnter()
	HeroImproveView.super.onEnter(self)

	self:setTitle(CommonText[530])
	self:hasCoinButton(true)
	armature_add("animation/effect/ui_hero_upgrade.pvr.ccz", "animation/effect/ui_hero_upgrade.plist", "animation/effect/ui_hero_upgrade.xml")
	self:updatePage()

	

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function HeroImproveView:updatePage(type)
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)

	local pages = {"","","",""}
	

	local function createYesBtnCallback(index)
		local button = nil

		local startPosX = 0
		local posXDelta = 0
		local sprite = display.newSprite(IMAGE_COMMON .. "btn_14_normal.png")
		startPosX = sprite:getContentSize().width / 2
		posXDelta = 105
		local posY = size.height + 22
		local posX = startPosX + (index - 1) * posXDelta

		local normal = display.newSprite(IMAGE_COMMON .. "btn_14_selected.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_14_selected.png")
		button = MenuButton.new(normal, selected, nil, nil)
		button:setLabel(pages[index])
		button:setPosition(posX, posY - 4)
		-- button:setLabel(pages[index] .. "(" .. #HeroMO.queryHeroByStar(index) .. ")")
		-- button.m_label:setFontSize(FONT_SIZE_SMALL)
		-- button.m_label:setPosition(button:getContentSize().width / 2 + 20,button:getContentSize().height / 2)

		
		local starPic
		-- starPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. index .. ".png", button:getContentSize().width / 2 - 20,button:getContentSize().height / 2):addTo(button)
		starPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. index .. ".png", button:getContentSize().width / 2,button:getContentSize().height / 2):addTo(button)
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil

		local startPosX = 0
		local posXDelta = 0
		local sprite = display.newSprite(IMAGE_COMMON .. "btn_14_normal.png")
		startPosX = sprite:getContentSize().width / 2
		posXDelta = 105
		local posY = size.height + 22
		local posX = startPosX + (index - 1) * posXDelta

		local normal = display.newSprite(IMAGE_COMMON .. "btn_14_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_14_normal.png")
		button = MenuButton.new(normal, selected, nil, nil)
		button:setPosition(posX, posY)
		button:setLabel(pages[index], {color = COLOR[11]})
		local starPic
		starPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. index .. ".png",button:getContentSize().width / 2,button:getContentSize().height / 2):addTo(button)


		return button
	end

	local function createDelegate(container, index)
		-- local view = nil
		-- if self.view then 
		-- 	container:removeChild(self.view, true)
		-- end

		-- view = self:creatInfoUi(container,index):addTo(container)
		-- self.view = view
		-- gdump(view,"UI。。"..index)
		-- if view then
		-- 	view:setPosition(0, 0)
		-- end
	end

	local function clickDelegate(container, index)
		self:creatInfoUi(index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	self:creatInfoUi(1)

end

function HeroImproveView:creatInfoUi(type)
	if self.uiContainer then
		self:getBg():removeChild(self.uiContainer, true)
	end
	if not type then type = 1 end
	local uiContainer = display.newNode():addTo(self:getBg())
	self.uiContainer = uiContainer

	local infoBg = display.newSprite(IMAGE_COMMON .. "info_bg_30.jpg"):addTo(uiContainer)
	-- infoBg:setPreferredSize(cc.size(590, 680))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, 150 + self:getBg():getContentSize().height - infoBg:getContentSize().height)


	local bg = display.newSprite(IMAGE_COMMON .. "btn_position_normal.png", infoBg:getContentSize().width / 2, infoBg:getContentSize().height / 2):addTo(infoBg)
	self.middleBg = bg
	local randomBg = display.newSprite(IMAGE_COMMON .. "info_bg_31.png", bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 5):addTo(bg)
	randomBg:setScale(0.8)
	

	local starBg = display.newSprite(IMAGE_COMMON .. "hero_star_bg.png", bg:getContentSize().width / 2, bg:getContentSize().height):addTo(bg)
	local statPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. type + 1 .. ".png", 
		starBg:getContentSize().width / 2, starBg:getContentSize().height / 2):addTo(starBg)
	self.statPic = statPic


	local pos = {
		{x = 309, y = 508},
		{x = 512, y = 421},
		{x = 512, y = 183},
		{x = 309, y = 100},
		{x = 103, y = 183},
		{x = 103, y = 421}
	}
	self.addButtons = {}
	for index=1,#pos do
		-- local bg = display.newSprite(IMAGE_COMMON .. "btn_position_normal.png", pos[index].x, pos[index].y):addTo(infoBg)
		local normal = display.newSprite(IMAGE_COMMON .. "btn_position_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_position_normal.png")
		local addButton = MenuButton.new(normal, selected, nil, handler(self,self.clickAddButton)):addTo(infoBg)
		addButton:setPosition(pos[index].x, pos[index].y)
		local buttonPic = display.newSprite(IMAGE_COMMON .. "icon_plus.png",addButton:getContentSize().width / 2,addButton:getContentSize().height / 2):addTo(addButton)
		addButton.buttonPic = buttonPic
		addButton.pos = index
		addButton.star = type
		self.addButtons[index] = addButton
		HeroMO.improve_heros_s[index] = 0
	end

	
	local infoLabel = ui.newTTFLabel({text = CommonText[531][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = self:getBg():getContentSize().width / 2 - 290, 
		y = 100}):addTo(uiContainer)
	infoLabel:setAnchorPoint(cc.p(0,0.5))
	local statPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. type + 1 .. ".png", 
		infoLabel:getPositionX() + infoLabel:getContentSize().width + 30, infoLabel:getPositionY()):addTo(uiContainer)
	self.statPic1 = statPic
	local infoLabel1 = ui.newTTFLabel({text = CommonText[531][2], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = statPic:getPositionX() + statPic:getContentSize().width + 10, 
		y = 100}):addTo(uiContainer)
	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local autoSelectBtn = MenuButton.new(normal, selected, nil, handler(self,self.autoSelectHandler)):addTo(uiContainer)
	autoSelectBtn:setPosition(self:getBg():getContentSize().width / 2 - 220,252)
	autoSelectBtn:setLabel(CommonText[532][1])
	autoSelectBtn.type = type

	local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local improveBtn = MenuButton.new(normal, selected, nil, handler(self,self.improveHandler)):addTo(uiContainer)
	improveBtn:setPosition(self:getBg():getContentSize().width / 2 + 190,100)
	improveBtn:setLabel(CommonText[532][3],{y = improveBtn:getContentSize().height / 2 + 13})
	improveBtn.type = type
	improveBtn.need = HeroMO.improve_need_propCount[type]

	local icon = UiUtil.createItemView(ITEM_KIND_PROP,HeroMO.improve_need_propId):addTo(improveBtn)
	icon:setPosition(improveBtn:getContentSize().width / 2 - 30,improveBtn:getContentSize().height / 2 - 10)
	icon:setScale(0.3)
	local need = ui.newBMFontLabel({text = HeroMO.improve_need_propCount[type], font = "fnt/num_1.fnt"}):addTo(improveBtn)
	need:setAnchorPoint(cc.p(0, 0.5))
	need:setPosition(icon:getPositionX() + icon:getContentSize().width * 0.3 / 2 + 5,icon:getPositionY() - 5)

	local infoLabel2 = ui.newTTFLabel({text = CommonText[531][3] .. UserMO.getResource(ITEM_KIND_PROP, HeroMO.improve_need_propId), font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = 0, 
		y = 0}):addTo(uiContainer)
	infoLabel2:setAnchorPoint(cc.p(0,0.5))
	infoLabel2:setPosition(self:getBg():getContentSize().width - infoLabel2:getContentSize().width - 20, 160)
	self.infoLabel2 = infoLabel2

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local ruleBtn = MenuButton.new(normal, selected, nil, handler(self,self.ruleHandler)):addTo(infoBg)
	ruleBtn:setPosition(infoBg:getContentSize().width - 70,infoBg:getContentSize().height - 50)


	--一键进阶按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local multiImproveBtn = MenuButton.new(normal, selected, nil, handler(self,self.multiImproveHandler)):addTo(uiContainer)
	multiImproveBtn:setPosition(self:getBg():getContentSize().width / 2 + 190,252)
	multiImproveBtn:setLabel(CommonText[532][2])
	multiImproveBtn.type = type
	multiImproveBtn:setVisible(type < 3)
	
end

function HeroImproveView:autoSelectHandler(tag, sender)
	if self.playResultStatus == true then return end
	ManagerSound.playNormalButtonSound()

	for pos=1,#self.addButtons do
		HeroMO.improve_heros_s[pos] = 0
		self.addButtons[pos].buttonPic:removeAllChildren()
		self.addButtons[pos].heroPic = nil
	end

	local heros = HeroBO.getAutoSelectHeros(sender.type)
	if #heros > 0 then
		for i=1,#heros do
			self:updateAddButtons(sender.type,i,heros[i])
		end
	else
		Toast.show(CommonText[703])
	end 
end

function HeroImproveView:clickAddButton(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.playResultStatus == true then return end
	HeroMO.improve_heros_s[sender.pos] = 0
	self.addButtons[sender.pos].buttonPic:removeAllChildren()

	require("app.dialog.HeroImproveSelectDialog").new(sender.pos,sender.star,handler(self,self.updateAddButtons)):push()
end

function HeroImproveView:updateAddButtons(star,pos,hero)
	-- gdump(hero,"[HeroImproveView:updateAddButtons]..hero")
	-- local heroPic = UiUtil.createItemView(ITEM_KIND_HERO, hero.heroId)
	-- heroPic:setScale(0.8)
	-- heroPic:setPosition(22,22)
	-- self.addButtons[pos].buttonPic:addChild(heroPic)	

	local heroPic = UiUtil.createItemView(ITEM_KIND_HERO, hero.heroId)
	heroPic:setScale(0.8)
	heroPic:setPosition(22,22)
	self.addButtons[pos].buttonPic:addChild(heroPic)
	self.addButtons[pos].heroPic = heroPic
	HeroMO.improve_heros_s[pos] = hero
end

function HeroImproveView:improveHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.playResultStatus == true then return end

	function doImprove()
		Loading.getInstance():show()
		HeroBO.asynImprove(function(hero)
			Loading.getInstance():unshow()
			-- self:showImproveHero(hero)
			self:updateStoneCount()
			self:playEffect(hero)
			end, HeroMO.improve_heros_s,sender.need)
	end 
	--判断是否6个
	if HeroBO.canImproveHeros() == false then Toast.show(CommonText[535][1]) return end
	--判断进阶石
	local price = PropMO.queryPropById(HeroMO.improve_need_propId).price
	local stoneCount = UserMO.getResource(ITEM_KIND_PROP, HeroMO.improve_need_propId)
	local needBuy = sender.need - stoneCount
	local ok = true
	if needBuy > 100 then needBuy = 100 ok = false end
	local cost = needBuy * price

	if needBuy > 0 then
		if UserMO.consumeConfirm then
			CoinConfirmDialog.new(string.format(CommonText[535][2],cost,needBuy), function()
					--判断金币
					if cost > UserMO.getResource(ITEM_KIND_COIN) then
						require("app.dialog.CoinTipDialog").new():push()
						return
					end
					Loading.getInstance():show()
					PropBO.asynBuyProp(function()
						Loading.getInstance():unshow()
						self:updateStoneCount()
						if ok then
							doImprove()
						end
						end, HeroMO.improve_need_propId, needBuy)
					end):push()
		else
			--判断金币
			if cost > UserMO.getResource(ITEM_KIND_COIN) then
				require("app.dialog.CoinTipDialog").new():push()
				return
			end
			Loading.getInstance():show()
			PropBO.asynBuyProp(function()
				Loading.getInstance():unshow()
				self:updateStoneCount()
				if ok then
					doImprove()
				end
				end, HeroMO.improve_need_propId, needBuy)
		end

	else
		ConfirmDialog.new(string.format(CommonText[535][3],sender.need), function()
					doImprove()
					end):push()
	end

end

function HeroImproveView:updateStoneCount()
	self.infoLabel2:setString(CommonText[531][3] .. UserMO.getResource(ITEM_KIND_PROP, HeroMO.improve_need_propId))
end

function HeroImproveView:playEffect(hero)
	self.playResultStatus = true
	local posTo = {
		{x = 22, y = 22 - 200},
		{x = 22 - 200, y = 22 - 120},
		{x = 22 - 200, y = 22 + 120},
		{x = 22, y = 22 + 200},
		{x = 22 + 200, y = 22 + 120},
		{x = 22 + 200, y = 22 - 120}
	}
	for pos=1,#self.addButtons do
		local addButton = self.addButtons[pos]
		gprint(addButton.heroPic:getPositionX() .. " " .. addButton.heroPic:getPositionY(),"addButton.heroPic POS")
		addButton.heroPic:runAction(transition.sequence({cc.MoveTo:create(0.5, cc.p(posTo[pos].x, posTo[pos].y)), cc.CallFuncN:create(function()
                    if pos == #self.addButtons then
                    	self:showImproveHero(hero)
                    end
                end)}))
	end
end

function HeroImproveView:showImproveHero(hero)
	for pos=1,#self.addButtons do
		HeroMO.improve_heros_s[pos] = 0
		self.addButtons[pos].buttonPic:removeAllChildren()
	end
	local lightEffect = CCArmature:create("ui_hero_upgrade")
    lightEffect:setPosition(self.middleBg:getContentSize().width / 2, self.middleBg:getContentSize().height / 2)
    self.middleBg:addChild(lightEffect)
    lightEffect:getAnimation():playWithIndex(0)
    lightEffect:connectMovementEventSignal(function(movementType, movementID) 
    		if movementType == MovementEventType.COMPLETE then
    			self.middleBg:removeChild(lightEffect)
    			self.playResultStatus = false
    			local heros = {}
    			heros[#heros + 1] = hero
				require("app.dialog.HeroImproveResultDialog").new(heros):push()
    		end
    	end)
	

end

function HeroImproveView:ruleHandler()
	ManagerSound.playNormalButtonSound()
	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	DetailTextDialog.new(DetailText.heroImprove):push()
end


function HeroImproveView:multiImproveHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.playResultStatus == true then return end

	for pos=1,#self.addButtons do
		HeroMO.improve_heros_s[pos] = 0
		self.addButtons[pos].buttonPic:removeAllChildren()
		self.addButtons[pos].heroPic = nil
	end
	
	
	local star = sender.type

	local set = HeroBO.getMultiHeros(star)
	local heros = set.heros
	local count = set.count

	gdump(heros,count)

	--判断是否有将领
	if count < 6 then Toast.show(CommonText[897]) return end


	local need = HeroBO.getMultiHerosImproveNeed(star,heros)
	
	gprint(need,"need===")

	
	function doImprove()
		Loading.getInstance():show()
		HeroBO.asynMultiHeroImprove(function(heros)
			Loading.getInstance():unshow()
			require("app.dialog.HeroImproveResultDialog").new(heros):push()
			self:updateStoneCount()

			end, heros,need)
	end 

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[898],count,need), function()
		--判断进阶石
		local price = PropMO.queryPropById(HeroMO.improve_need_propId).price
		local stoneCount = UserMO.getResource(ITEM_KIND_PROP, HeroMO.improve_need_propId)
		local needBuy = need - stoneCount
		local ok = true
		if needBuy > 100 then needBuy = 100 ok = false end
		local cost = needBuy * price

		if needBuy > 0 then
			if UserMO.consumeConfirm then
				CoinConfirmDialog.new(string.format(CommonText[535][2],cost,needBuy), function()
						--判断金币
						if cost > UserMO.getResource(ITEM_KIND_COIN) then
							require("app.dialog.CoinTipDialog").new():push()
							return
						end
						Loading.getInstance():show()
						PropBO.asynBuyProp(function()
							Loading.getInstance():unshow()
							self:updateStoneCount()
							if ok then
								doImprove()
							end
							end, HeroMO.improve_need_propId, needBuy)
						end):push()
			else
				--判断金币
				if cost > UserMO.getResource(ITEM_KIND_COIN) then
					require("app.dialog.CoinTipDialog").new():push()
					return
				end
				Loading.getInstance():show()
				PropBO.asynBuyProp(function()
					Loading.getInstance():unshow()
					self:updateStoneCount()
					if ok then
						doImprove()
					end
					end, HeroMO.improve_need_propId, needBuy)
			end

		else
			doImprove()
		end
	end):push()

end

function HeroImproveView:onExit()
	HeroImproveView.super.onExit(self)
	armature_remove("animation/effect/ui_hero_upgrade.pvr.ccz", "animation/effect/ui_hero_upgrade.plist", "animation/effect/ui_hero_upgrade.xml")
	-- gprint("HeroImproveView onExit() ........................")

	-- if self.m_buildHandler then
	-- 	Notify.unregister(self.m_buildHandler)
	-- 	self.m_buildHandler = nil
	-- end
end




return HeroImproveView