--
-- Author: gf
-- Date: 2015-09-02 15:29:53
--
LEVEL_UP_NORMAL = 0  -- kind 是普通将升级,为1是觉醒将
LEVEL_UP_AWAKE = 1

local Dialog = require("app.dialog.Dialog")
local HeroLevelUpDialog = class("HeroLevelUpDialog", Dialog)


function HeroLevelUpDialog:ctor(hero,kind)
	HeroLevelUpDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT)})
	self.hero = hero
	self.kind = kind
end

function HeroLevelUpDialog:onEnter()
	HeroLevelUpDialog.super.onEnter(self)

	self:setTitle(CommonText[514][1])
	local hero
	if self.kind == 1 then
		local awakeInfo = HeroBO.getAwakeHeroByKeyId(self.hero.keyId)
		hero = HeroMO.queryHero(awakeInfo.heroId)
	else
		hero = self.hero
	end

	self.m_LevelUpHandler = Notify.register(LOCAL_HERO_LEVELUP_EVENT, handler(self, self.decomposeDoneHandler))

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local heroBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_29.jpg"):addTo(self:getBg())
	heroBg:setPreferredSize(cc.size(GAME_SIZE_WIDTH - 40, heroBg:getContentSize().height))
	heroBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 310)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(GAME_SIZE_WIDTH - 80, 210))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 680)
	
	local leftBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(heroBg)
	leftBg:setPreferredSize(cc.size(220, 470))
	leftBg:setCapInsets(cc.rect(80, 60, 1, 1))
	leftBg:setPosition(heroBg:getContentSize().width / 2 - 158, heroBg:getContentSize().height / 2 + 10)

	local rightBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(heroBg)
	rightBg:setPreferredSize(cc.size(220, 470))
	rightBg:setCapInsets(cc.rect(80, 60, 1, 1))
	rightBg:setPosition(heroBg:getContentSize().width / 2 + 158, heroBg:getContentSize().height / 2 + 10)

	--将领信息
	local heroLeftData = hero
	local leftName = ui.newTTFLabel({text = heroLeftData.heroName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = leftBg:getContentSize().width / 2, 
		y = leftBg:getContentSize().height - 25, 
		align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(leftBg)
	leftName:setAnchorPoint(cc.p(0.5, 0.5))

	local leftHeroPic = UiUtil.createItemView(ITEM_KIND_HERO,heroLeftData.heroId):addTo(leftBg)
	leftHeroPic:setScale(0.8)
	leftHeroPic:setPosition(leftBg:getContentSize().width / 2,leftBg:getContentSize().height - 150)

	-- local leftHeroAddition = HeroMO.queryHeroAddition(heroLeftData.heroAdditionId)

	if heroLeftData.type == 2 then
		if heroLeftData.tankCount > 0 then
			local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 30, y = 215, 
				align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(leftBg)
			additionLab1:setAnchorPoint(cc.p(0, 0.5))
			local additionValue1 = ui.newTTFLabel({text = "+" .. heroLeftData.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(leftBg)
			additionValue1:setAnchorPoint(cc.p(0, 0.5))
		end
		local heroLeftAttr = json.decode(heroLeftData.attr)

		for index = 1,#heroLeftAttr do
			local tanksAddition = heroLeftAttr[index]
			local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
			local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 30, y = 195 - 32 * (index - 1), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(leftBg)
			additionLab:setAnchorPoint(cc.p(0, 0.5))
			local additionValue = ui.newTTFLabel({text = attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(leftBg)
			additionValue:setAnchorPoint(cc.p(0, 0.5))
		end
	end
	local skillIcon = display.newSprite(IMAGE_COMMON .. "icon_hero_skill.png", 50, 35):addTo(leftBg)

	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = skillIcon:getPositionX() + skillIcon:getContentSize().width / 2 + 5, 
		y = skillIcon:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(leftBg)
	skillName:setAnchorPoint(cc.p(0, 0.5))
	-- local heroSkill
	if heroLeftData.skillId > 0 then
		skillName:setString(heroLeftData.skillName)
	else
		skillName:setString(CommonText[509])
	end

	local arrowPic = display.newSprite(IMAGE_COMMON .. "icon_arrow_right.png", heroBg:getContentSize().width / 2, heroBg:getContentSize().height / 2):addTo(heroBg)

	local heroRightData = HeroMO.queryHero(hero.canup)
	local rightName = ui.newTTFLabel({text = heroRightData.heroName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = rightBg:getContentSize().width / 2, 
		y = rightBg:getContentSize().height - 25, 
		align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(rightBg)
	rightName:setAnchorPoint(cc.p(0.5, 0.5))

	local rightHeroPic = UiUtil.createItemView(ITEM_KIND_HERO,heroRightData.heroId):addTo(rightBg)
	rightHeroPic:setScale(0.8)
	rightHeroPic:setPosition(rightBg:getContentSize().width / 2,rightBg:getContentSize().height - 150)

	-- local rightHeroAddition = HeroMO.queryHeroAddition(heroRightData.heroAdditionId)

	if heroRightData.type == 2 then
		if heroRightData.tankCount > 0 then
			local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 30, y = 215, 
				align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(rightBg)
			additionLab1:setAnchorPoint(cc.p(0, 0.5))
			local additionValue1 = ui.newTTFLabel({text = "+" .. heroRightData.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(rightBg)
			additionValue1:setAnchorPoint(cc.p(0, 0.5))
		end
		local heroRightAttr = json.decode(heroRightData.attr)

		for index = 1,#heroRightAttr do
			local tanksAddition = heroRightAttr[index]
			local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
			local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 30, y = 195 - 32 * (index - 1), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(rightBg)
			additionLab:setAnchorPoint(cc.p(0, 0.5))
			local additionValue = ui.newTTFLabel({text = attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(rightBg)
			additionValue:setAnchorPoint(cc.p(0, 0.5))
		end
	end
	local skillIcon = display.newSprite(IMAGE_COMMON .. "icon_hero_skill.png", 50, 35):addTo(rightBg)

	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = skillIcon:getPositionX() + skillIcon:getContentSize().width / 2 + 5, 
		y = skillIcon:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(rightBg)
	skillName:setAnchorPoint(cc.p(0, 0.5))
	-- local heroSkill
	if heroRightData.skillId > 0 then
		skillName:setString(heroRightData.skillName)
	else
		skillName:setString(CommonText[509])
	end


	--强化所需材料
	local needPic = display.newSprite(IMAGE_COMMON .. "info_bg_12.png", 140, 170):addTo(infoBg)
	local needTit = ui.newTTFLabel({text = CommonText[519], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, 
		y = needPic:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(needPic)
	needTit:setAnchorPoint(cc.p(0, 0.5))

	local needProp = json.decode(hero.meta)
	-- gdump(needProp,"升级所需材料")
	local canLevelup = true
	for index = 1,#needProp do
		local itemView = UiUtil.createItemView(needProp[index][1], needProp[index][2])
		itemView:setPosition(80 + (index - 1) * 130,90)
		infoBg:addChild(itemView)
		UiUtil.createItemDetailButton(itemView)
		local needResLabel = ui.newTTFLabel({text = needProp[index][3] .. "/", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, 
			y = -20, 
			align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(itemView)
		needResLabel:setAnchorPoint(cc.p(1, 0.5))

		local myRes = UserMO.getResource(needProp[index][1], needProp[index][2])
		local myResLabel = ui.newTTFLabel({text = myRes, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, 
			y = needResLabel:getPositionY(), 
			align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(itemView)
		myResLabel:setAnchorPoint(cc.p(0, 0.5))
		if myRes < needProp[index][3] then
			myResLabel:setColor(COLOR[6])
			canLevelup = false
		else
			myResLabel:setColor(COLOR[2])
		end
	end
	
	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	cancelBtn = MenuButton.new(normal, selected, nil, handler(self,self.cancelHandler)):addTo(self:getBg())
	cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 150,100)
	cancelBtn:setLabel(CommonText[518][1])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	levelUpBtn = MenuButton.new(normal, selected, disabled, handler(self,self.levelUpHandler)):addTo(self:getBg())
	levelUpBtn:setPosition(self:getBg():getContentSize().width / 2 + 150,100)
	levelUpBtn:setLabel(CommonText[518][2])
	levelUpBtn:setEnabled(canLevelup)
	levelUpBtn.hero = hero
	levelUpBtn.needProp = needProp


end


function HeroLevelUpDialog:cancelHandler()
	self:pop()
end

function HeroLevelUpDialog:decomposeDoneHandler()
	self:pop()
end

function HeroLevelUpDialog:levelUpHandler(tag, sender)
	gdump(sender.hero,"sender.herosender.hero")
	Loading.getInstance():show()
	if self.kind == 1 then
		HeroBO.asynLevelUp(function()
			Loading.getInstance():unshow()
			end, -self.hero.keyId, sender.needProp)
	else
		HeroBO.asynLevelUp(function()
			Loading.getInstance():unshow()
			end, sender.hero.keyId, sender.needProp)
	end
end



function HeroLevelUpDialog:onExit()
	HeroLevelUpDialog.super.onExit(self)
	if self.m_LevelUpHandler then
		Notify.unregister(self.m_LevelUpHandler)
		self.m_LevelUpHandler = nil
	end
end


return HeroLevelUpDialog