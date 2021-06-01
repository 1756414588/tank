--
-- Author: gf
-- Date: 2015-09-03 12:46:30
--

local HeroSelectTableView = class("HeroSelectTableView", TableView)

function HeroSelectTableView:ctor(size,star,callBack)
	HeroSelectTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 180)

	self.star = star
	self.heros = HeroBO.getImproveHeros(self.star)
	self.callBack = callBack
end

function HeroSelectTableView:numberOfCells()
	return #self.heros
end

function HeroSelectTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HeroSelectTableView:createCellAtIndex(cell, index)
	HeroSelectTableView.super.createCellAtIndex(self, cell, index)

	local buttons = {}
	cell.buttons = buttons

	local hero = self.heros[index]
	local itemView = display.newNode()
	
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png",400, self.m_cellSize.height / 2 - 10):addTo(cell)
	infoBg:setCapInsets(cc.rect(80, 60, 1, 1))
	infoBg:setPreferredSize(cc.size(426, 155))

	local itemPic = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId):addTo(infoBg)
	itemPic:setScale(0.8)
	itemPic:setPosition(0 - itemPic:getContentSize().width / 2 + 20,infoBg:getContentSize().height / 2 - 5)

	-- 头像锁
	local itemLock = display.newScale9Sprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemPic)
	itemLock:setPreferredSize(cc.size(56,70))
	itemLock:setScale(0.8)
	itemLock:setPosition(itemPic:getContentSize().width - 45, itemPic:getContentSize().height - 45)
	itemLock:setVisible(hero.locked)

	--已上阵图片
	local fightPic = display.newSprite(IMAGE_COMMON .. "hero_fight.png"):addTo(itemPic)
	fightPic:setPosition(itemPic:getContentSize().width / 2, itemPic:getContentSize().width - 50)
	fightPic:setVisible(hero.count == ArmyBO.getHeroFightNum(hero.heroId))

	local countLab = ui.newTTFLabel({text = CommonText[507][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 46, y = 128, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(infoBg)
	local countValue = ui.newTTFLabel({text = hero.count, font = G_FONT, size = FONT_SIZE_SMALL, x = 100, y = 128, align = ui.TEXT_ALIGN_LEFT, color = COLOR[2]}):addTo(infoBg)

	local useLab = ui.newTTFLabel({text = CommonText[507][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 246, y = 128, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(infoBg)
	local useValue = ui.newTTFLabel({text = ArmyBO.getHeroFightNum(hero.heroId), font = G_FONT, size = FONT_SIZE_SMALL, x = 300, y = 128, align = ui.TEXT_ALIGN_LEFT, color = COLOR[2]}):addTo(infoBg)

	local skillIcon = display.newSprite(IMAGE_COMMON .. "icon_hero_skill.png", 60, 95):addTo(infoBg)

	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = skillIcon:getPositionX() + skillIcon:getContentSize().width, 
		y = skillIcon:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	skillName:setAnchorPoint(cc.p(0, 0.5))
	local heroSkill
	if hero.skillId > 0 then
		skillName:setString(hero.skillName)
	else
		skillName:setString(CommonText[509])
	end

	if hero.tankCount > 0 then
		local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 45, y = 68, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab1:setAnchorPoint(cc.p(0, 0.5))
		local additionValue1 = ui.newTTFLabel({text = "+" .. hero.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue1:setAnchorPoint(cc.p(0, 0.5))
	end
	
	local heroAttr = json.decode(hero.attr)

	for index = 1,#heroAttr do
		local tanksAddition = heroAttr[index]
		local additionLab = ui.newTTFLabel({text = AttributeMO.queryAttributeById(tanksAddition[1]).desc .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 45 + (index - 1) % 2 * 200, y = 48 - 20 * math.floor((index - 1) / 2), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab:setAnchorPoint(cc.p(0, 0.5))
		local additionValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue:setAnchorPoint(cc.p(0, 0.5))
		if tanksAddition[1] % 2 == 0 then
			additionValue:setString("+" .. tanksAddition[2] / 100 .. "%")
		else
			additionValue:setString("+" .. tanksAddition[2])
		end
	end



	-- local btn = CellTouchButton.new(infoBg, nil, nil, nil, handler(self, self.onChosenCallback))
	-- btn.hero = hero
	-- buttons[index] = btn
	-- cell:addButton(btn, 400, self.m_cellSize.height / 2 - 10)


	return cell
end

function HeroSelectTableView:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()
	-- gdump(sender.hero,"[HeroTableView]..onChosenCallback")
	local hero = self.heros[index]

	if hero.count == ArmyBO.getHeroFightNum(hero.heroId) then
		Toast.show(CommonText[726])
		return
	end

	if hero.locked then
		Toast.show(CommonText[971])
		return
	end

	local paramHero = {}
	paramHero.keyId = hero.keyId
	paramHero.heroId = hero.heroId
	paramHero.count = 1
	if self.callBack then self.callBack(paramHero) end
end



-- function HeroSelectTableView:onChosenCallback(tag,sender)
-- 	ManagerSound.playNormalButtonSound()

-- 	if sender.hero.count == ArmyBO.getHeroFightNum(sender.hero.heroId) then
-- 		Toast.show(CommonText[726])
-- 		return
-- 	end

-- 	local hero = {}
-- 	hero.keyId = sender.hero.keyId
-- 	hero.heroId = sender.hero.heroId
-- 	hero.count = 1
-- 	if self.callBack then self.callBack(hero) end
-- end

function HeroSelectTableView:onUpdateHeros()
	self.heros = HeroBO.getImproveHeros(self.star)
	self:reloadData()
end

function HeroSelectTableView:onExit()
	HeroSelectTableView.super.onExit(self)

end

return HeroSelectTableView