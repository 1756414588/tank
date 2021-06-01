--
-- Author: Your Name
-- Date: 2017-07-07 11:26:19
--
--文官入驻操作界面

local Dialog = require("app.dialog.Dialog")
local ExchangeStaffHeroDialog = class("ExchangeStaffHeroDialog", Dialog)

function ExchangeStaffHeroDialog:ctor(rhand,param)
	ExchangeStaffHeroDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 400)})
	self.m_param = param
	self.rhand = rhand
	self.hero = HeroMO.queryHero(self.m_param.heroId)
end

function ExchangeStaffHeroDialog:onEnter()
	ExchangeStaffHeroDialog.super.onEnter(self)
	local hero = self.hero
	self:setTitle(CommonText[100023])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(550, 330))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg(), -1)
	infoBg:setPreferredSize(cc.size(510, 316))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 +20)
	
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(470, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height / 2 - 45)

	-- 头像
	local itemPic = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId):addTo(infoBg)
	itemPic:setScale(0.7)
	itemPic:setPosition(itemPic:width() / 2 +10,self:getBg():getContentSize().height - itemPic:height() - 10)

	local skillIcon = display.newSprite(IMAGE_COMMON .. "icon_hero_skill.png",itemPic:width(),infoBg:height() - 70):addTo(infoBg)
	local skillTit = ui.newTTFLabel({text = CommonText[513][2], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	skillTit:setAnchorPoint(cc.p(0, 0.5))
	skillTit:setPosition(itemPic:width() + 20,infoBg:height() - 70)

	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = skillTit:getPositionX(), y = skillTit:getPositionY() - 40, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(infoBg)
	skillName:setAnchorPoint(cc.p(0, 0.5))

	local skillDesc = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = line:getPositionY() - 40, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	skillDesc:setAnchorPoint(cc.p(0, 0.5))

	if hero.skillId > 0 then
		skillName:setString(hero.skillName)
		if not hero.desc then hero.desc = "" end
		skillDesc:setString(hero.skillDesc)
	else
		skillName:setString(CommonText[509])
	end

	-- 卸下
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	-- local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local heroDecomposeBtn = MenuButton.new(normal, selected, nil, handler(self,self.onChoseCallback)):addTo(self:getBg())
	heroDecomposeBtn:setPosition(self:getBg():getContentSize().width / 2 + 110,20)
	heroDecomposeBtn:setLabel(CommonText[134])

	-- 取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	-- local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local heroDecomposeBtn = MenuButton.new(normal, selected, nil, function ()
		ManagerSound.playNormalButtonSound()
		self:pop()
	end):addTo(self:getBg())
	heroDecomposeBtn:setPosition(self:getBg():getContentSize().width / 2 - 110,20)
	heroDecomposeBtn:setLabel(CommonText[553][1])
end

function ExchangeStaffHeroDialog:onChoseCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	local param = clone(self.m_param)
	param.heroId = 0
	HeroBO.setStaffHeros(function ()
		self.rhand()
		self:pop()
	end,param)
end

function ExchangeStaffHeroDialog:onExit()
	ExchangeStaffHeroDialog.super.onExit(self)
end

return ExchangeStaffHeroDialog