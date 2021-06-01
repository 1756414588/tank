--
-- Author: xiaoxing
-- Date: 2016-12-14 10:21:53
--
local HeroPicTableView = class("HeroPicTableView", TableView)

function HeroPicTableView:ctor(size,data)
	HeroPicTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 260)
	self.heros = data
end

function HeroPicTableView:numberOfCells()
	return #self.heros
end

function HeroPicTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HeroPicTableView:createCellAtIndex(cell, index)
	HeroPicTableView.super.createCellAtIndex(self, cell, index)
	local hero = self.heros[index]
	local infoBg = UiUtil.sprite9("info_bg_82.png", 60,50,14,13,self.m_cellSize.width-20,self.m_cellSize.height):addTo(cell):pos(self.m_cellSize.width/2,self.m_cellSize.height/2)

	local itemPic = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId):addTo(infoBg)
	itemPic:setScale(0.65)
	itemPic:setPosition(100,infoBg:getContentSize().height - 95)

	-- local skillIcon = display.newSprite(IMAGE_COMMON .. "icon_hero_skill.png", 60, 95):addTo(infoBg)

	-- local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 	x = skillIcon:getPositionX() + skillIcon:getContentSize().width, 
	-- 	y = skillIcon:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	-- skillName:setAnchorPoint(cc.p(0, 0.5))
	-- local heroSkill

	-- if hero.skillId > 0 then
	-- 	skillName:setString(hero.skillName)
	-- else
	-- 	skillName:setString(CommonText[509])
	-- end

	-- if hero.tankCount > 0 then
	-- 	local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 45, y = 68, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	-- 	additionLab1:setAnchorPoint(cc.p(0, 0.5))
	-- 	local additionValue1 = ui.newTTFLabel({text = "+" .. hero.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
	-- 	additionValue1:setAnchorPoint(cc.p(0, 0.5))
	-- end
	
	local additionTit = ui.newTTFLabel({text = CommonText[513][1], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 220, y = self.m_cellSize.height - 40, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	additionTit:setAnchorPoint(cc.p(0, 0.5))

	if hero.tankCount > 0 then
		local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 220, y = additionTit:y() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab1:setAnchorPoint(cc.p(0, 0.5))
		local additionValue1 = ui.newTTFLabel({text = "+" .. hero.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue1:setAnchorPoint(cc.p(0, 0.5))
	end

	local heroAttr = json.decode(hero.attr)
	for index = 1,#heroAttr do
		local tanksAddition = heroAttr[index]
		local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])

		local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 220 + (index - 1) % 2 * 180, y = additionTit:y() - 60 - 30 * math.floor((index - 1) / 2), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab:setAnchorPoint(cc.p(0, 0.5))
		local additionValue = ui.newTTFLabel({text = attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue:setAnchorPoint(cc.p(0, 0.5))
	end

	additionTit = ui.newTTFLabel({text = CommonText[513][2], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 40, y = 73, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	additionTit:setAnchorPoint(cc.p(0, 0.5))

	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM}):rightTo(additionTit, 5)
	if hero.skillId > 0 then
		skillName:setString(hero.skillName)
	else
		skillName:setString(CommonText[509])
	end
	if hero.skillId > 0 then
		UiUtil.label(hero.skillDesc,nil,nil,cc.size(440,0),ui.TEXT_ALIGN_LEFT)
			:addTo(infoBg):align(display.LEFT_TOP, 40, 55)
	end
	return cell
end

---------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local HeroListDialog = class("HeroListDialog", Dialog)

function HeroListDialog:ctor(data)
	HeroListDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 780)})
	self.data = data
end

function HeroListDialog:onEnter()
	HeroListDialog.super.onEnter(self)
	self:setTitle(CommonText[506])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 750))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = HeroPicTableView.new(cc.size(550, self:getBg():height()-102),self.data)
		:addTo(self:getBg()):pos(17,34)
	view:reloadData()
end

return HeroListDialog