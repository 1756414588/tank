--
-- Author: Your Name
-- Date: 2017-07-04 14:20:50
--
--参谋选兵View
local StaffHeroTableview = class("StaffHeroTableview", TableView)

function StaffHeroTableview:ctor(size,rhand,param)
	StaffHeroTableview.super.ctor(self,size,SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 180)
	self.rhand = rhand
	self.param = param
	self.heros = HeroMO.getStaffHeros(self.param.partId)
end

function StaffHeroTableview:onEnter()
	StaffHeroTableview.super.onEnter(self)
	self.m_updateHerosHandler = Notify.register(LOCAL_HERO_UPDATE_EVENT, handler(self, self.onUpdateHeros))
end

function StaffHeroTableview:numberOfCells()
	return #self.heros
end

function StaffHeroTableview:cellSizeForIndex(index)
	return self.m_cellSize
end

function StaffHeroTableview:createCellAtIndex(cell, index)
	StaffHeroTableview.super.createCellAtIndex(self, cell, index)

	local hero = self.heros[index]
	local itemView = display.newNode()
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png",400, self.m_cellSize.height / 2 - 10):addTo(cell)
	infoBg:setCapInsets(cc.rect(80, 60, 1, 1))
	infoBg:setPreferredSize(cc.size(426, 175))

	local itemPic = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId):addTo(infoBg)
	itemPic:setScale(0.8)
	itemPic:setPosition(20 - itemPic:getContentSize().width / 2,infoBg:getContentSize().height / 2 - 5)

	local countLab = ui.newTTFLabel({text = CommonText[507][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 46, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(infoBg)
	local countValue = ui.newTTFLabel({text = hero.count, font = G_FONT, size = FONT_SIZE_SMALL, x = 100, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[2]}):addTo(infoBg)

	local useLab = ui.newTTFLabel({text = CommonText[507][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 246, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(infoBg)
	local useValue = ui.newTTFLabel({text = ArmyBO.getHeroFightNum(hero.heroId), font = G_FONT, size = FONT_SIZE_SMALL, x = 300, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[2]}):addTo(infoBg)
	local skillIcon = display.newSprite(IMAGE_COMMON .. "icon_hero_skill.png", 60, 115):addTo(infoBg)

	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = skillIcon:getPositionX() + skillIcon:getContentSize().width, 
		y = skillIcon:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	skillName:setAnchorPoint(cc.p(0, 0.5))

	local skillDesc = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = skillIcon:getPositionX(), y = skillName:getPositionY() - 40, align = ui.TEXT_ALIGN_LEFT, color = COLOR[11],dimensions = cc.size(320,0)}):addTo(infoBg)
	skillDesc:setAnchorPoint(cc.p(0, 0.5))

	if hero.skillId > 0 then
		skillName:setString(hero.skillName)
		if not hero.desc then hero.desc = "" end
		skillDesc:setString(hero.skillDesc)
	else
		skillName:setString(CommonText[509])
	end
	
	cell.heroId = hero.heroId
	return cell
end

function StaffHeroTableview:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()
	local heroId = cell.heroId
	if HeroBO.canHeroStaff(heroId) then
		local param = self.param
		param.heroId = heroId
		HeroBO.setStaffHeros(function ()
			--做数据返回刷新处理
			self.rhand()
		end,param)
	else
		Toast.show(CommonText[100024])
	end
end

function StaffHeroTableview:onUpdateHeros()
	self:reloadData()
end

function StaffHeroTableview:onExit()
	StaffHeroTableview.super.onExit(self)
	if self.m_updateHerosHandler then
		Notify.unregister(self.m_updateHerosHandler)
		self.m_updateHerosHandler = nil
	end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
local StaffHeroView = class("StaffHeroView", UiNode)

function StaffHeroView:ctor(rhand,param,max)
	StaffHeroView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	self.rhand = rhand
	self.param = param
	self.max = max
end

function StaffHeroView:onEnter()
	StaffHeroView.super.onEnter(self)
	-- 装备仓库
	self:setTitle(CommonText[100019])
	self:showUI()
end

function StaffHeroView:showUI()
	local hero = HeroMO.getStaffHeros(self.param.partId)
	if #hero <= 0 then
		local desc = UiUtil.label(CommonText[100020]):addTo(self:getBg()):pos(self:getBg():width() / 2,self:getBg():height() / 2)
		return
	end
	local view = StaffHeroTableview.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height - 160),function ()
		self.rhand(self.max)
		self:pop()
	end,self.param):addTo(self:getBg())
	self.view = view
	if view then
		view:setPosition(0, 70)
		view:reloadData()
	end
end

function StaffHeroView:onExit()
	StaffHeroView.super.onExit(self)
end

return StaffHeroView