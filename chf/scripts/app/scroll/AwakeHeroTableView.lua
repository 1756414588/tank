--
-- Author: Your Name
-- Date: 2017-03-21 21:08:45
--
--觉醒将领tableview

local AwakeHeroTableView = class("AwakeHeroTableView", TableView)

function AwakeHeroTableView:ctor(size,viewFor,kind)
	AwakeHeroTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 180)
	-- self.awakeHeros = HeroMO.awakeHeros_
	self.m_viewFor = viewFor
	self.kind = kind
	self.awakeHeros = {}
	for k,v in pairs(HeroMO.awakeHeros_) do
		local heroInfo = HeroMO.queryHero(v.heroId)
		v.listOrder = heroInfo.listOrder
		self.awakeHeros[#self.awakeHeros + 1] = v
	end

	--按新规则排序
	local mysort = function (a,b)
		return a.listOrder > b.listOrder
	end

	table.sort(self.awakeHeros , mysort)
end

function AwakeHeroTableView:onEnter(size,viewFor)
	AwakeHeroTableView.super.onEnter(self)
	self.m_updateHerosHandler = Notify.register(LOCAL_HERO_AWAKEHERO_EVENT, handler(self, self.onUpdateInfo))
end

function AwakeHeroTableView:numberOfCells()
	return #self.awakeHeros
end

function AwakeHeroTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function AwakeHeroTableView:createCellAtIndex(cell, index)
	AwakeHeroTableView.super.createCellAtIndex(self, cell, index)

	local hero = self.awakeHeros[index]
	local heroInfo = HeroMO.queryHero(hero.heroId)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png",400, self.m_cellSize.height / 2 - 10):addTo(cell)
	infoBg:setCapInsets(cc.rect(80, 60, 1, 1))
	infoBg:setPreferredSize(cc.size(426, 175))
	local itemPic
	if heroInfo.awakenHeroId == 0 then
		itemPic = UiUtil.createItemView(ITEM_KIND_AWAKE_HERO,hero.heroId):addTo(infoBg)
	else
		itemPic = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId):addTo(infoBg)
	end
	itemPic:setScale(0.8)
	itemPic:setPosition(20 - itemPic:getContentSize().width / 2,infoBg:getContentSize().height / 2 - 5)

	--已上阵图片
	local fightPic = display.newSprite(IMAGE_COMMON .. "hero_fight.png"):addTo(itemPic)
	fightPic:setPosition(itemPic:getContentSize().width / 2, itemPic:getContentSize().width - 50)
	fightPic:setVisible(ArmyBO.getHeroFightNum(hero.keyId, self.kind) >= 1)
	--拥有
	local countLab = ui.newTTFLabel({text = CommonText[507][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 46, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(infoBg)
	local countValue = ui.newTTFLabel({text = "1", font = G_FONT, size = FONT_SIZE_SMALL, x = 100, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[2]}):addTo(infoBg)
	--派出
	local useLab = ui.newTTFLabel({text = CommonText[507][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 246, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(infoBg)
	local useValue = ui.newTTFLabel({text = ArmyBO.getHeroFightNum(hero.keyId, self.kind), font = G_FONT, size = FONT_SIZE_SMALL, x = 300, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[2]}):addTo(infoBg)
	--技
	local skillIcon = display.newSprite(IMAGE_COMMON .. "icon_hero_skill.png", 60, 115):addTo(infoBg)
	--技能名
	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = skillIcon:getPositionX() + skillIcon:getContentSize().width, 
		y = skillIcon:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	skillName:setAnchorPoint(cc.p(0, 0.5))
	local heroSkill

	if hero.skillLv then
		skillName:setString(heroInfo.skillName)
	else
		skillName:setString(CommonText[509])
	end

	if heroInfo.tankCount > 0 then
		local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 45, y = 88, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab1:setAnchorPoint(cc.p(0, 0.5))
		local additionValue1 = ui.newTTFLabel({text = "+" .. heroInfo.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue1:setAnchorPoint(cc.p(0, 0.5))
	end

	local heroAttr = json.decode(heroInfo.attr)
	for index = 1,#heroAttr do
		local tanksAddition = heroAttr[index]
		local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])

		local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 45 + (index - 1) % 2 * 200, y = 68 - 20 * math.floor((index - 1) / 2), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab:setAnchorPoint(cc.p(0, 0.5))
		local additionValue = ui.newTTFLabel({text = attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue:setAnchorPoint(cc.p(0, 0.5))
	end

	return cell
end

function AwakeHeroTableView:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()
	local hero = self.awakeHeros[index]
	if self.m_viewFor == 1 then
		require("app.dialog.AwakeOperationDialog").new(hero):push()
	elseif self.m_viewFor == 2 then -- 武将上阵
		if ArmyBO.getHeroFightNum(hero.keyId, self.kind) >= 1 then
			Toast.show(CommonText[986])
		else
			Notify.notify(LOCAL_CHOSE_HERO_EVENT, {hero = hero,kind = 1})
		end
	end
end

function AwakeHeroTableView:onUpdateInfo()
	self.awakeHeros = {}
	for k,v in pairs(HeroMO.awakeHeros_) do
		local heroInfo = HeroMO.queryHero(v.heroId)
		v.listOrder = heroInfo.listOrder
		self.awakeHeros[#self.awakeHeros + 1] = v
	end
	-- self.awakeHeros = HeroMO.awakeHeros_

	--按新规则排序
	local mysort = function (a,b)
		return a.listOrder > b.listOrder
	end

	table.sort(self.awakeHeros , mysort)
	self:reloadData()
end

function AwakeHeroTableView:onExit()
	AwakeHeroTableView.super.onExit(self)
	if self.m_updateHerosHandler then
		Notify.unregister(self.m_updateHerosHandler)
		self.m_updateHerosHandler = nil
	end
end

return AwakeHeroTableView