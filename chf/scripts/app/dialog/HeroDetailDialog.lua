--
-- Author: gf
-- Date: 2015-09-02 12:06:13
--

local Dialog = require("app.dialog.Dialog")
local HeroDetailDialog = class("HeroDetailDialog", Dialog)

-- type:1武将属性;2武将图鉴;3武将上阵

-- 锁定 图片
local itemLock = nil
-- 锁定 按钮
local heroLockBtn = nil
-- 是否被加锁
local islocked
-- 将领升级
local heroPicBtn = nil
-- 将领分解 按钮
local heroLotteryBtn = nil


function HeroDetailDialog:ctor(hero,type,kind)
	HeroDetailDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 610)})

	self.hero = hero
	self.type = type
	self.kind = kind
end

function HeroDetailDialog:onEnter()
	HeroDetailDialog.super.onEnter(self)

	self:setTitle(CommonText[512])

	local hero = self.hero
	local type = self.type

	islocked = HeroMO.IsLockById(hero.heroId)

	self.m_detailHandler = Notify.register(LOCAL_HERO_DETAIL_EVENT, handler(self, self.detailcloseHandler))


	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(550, 530))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg(), -1)
	infoBg:setPreferredSize(cc.size(510, 416))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 +20)
	
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(470, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height / 2 - 5)

	-- 头像
	local itemPic = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId):addTo(infoBg)
	itemPic:setScale(0.8)
	itemPic:setPosition(100,300)

    -- 头像锁 在将领图鉴中不显示
	if type == 1 or type == 3 then
		itemLock = display.newScale9Sprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemPic)
		itemLock:setPreferredSize(cc.size(56,70))
		itemLock:setScale(0.8)
		itemLock:setPosition(itemPic:getContentSize().width - 45, itemPic:getContentSize().height - 45)
		itemLock:setVisible(islocked)
	end

	-- 将领加成
	local additionTit = ui.newTTFLabel({text = CommonText[513][1], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 190, y = 378, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	additionTit:setAnchorPoint(cc.p(0, 0.5))

	if hero.tankCount > 0 then
		local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 190, y = 338, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab1:setAnchorPoint(cc.p(0, 0.5))
		local additionValue1 = ui.newTTFLabel({text = "+" .. hero.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue1:setAnchorPoint(cc.p(0, 0.5))
	end

	local heroAttr = json.decode(hero.attr)

	for index = 1,#heroAttr do
		local tanksAddition = heroAttr[index]
		local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
		local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 190 + (index - 1) % 2 * 200, y = 300 - 40 * math.floor((index - 1) / 2), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab:setAnchorPoint(cc.p(0, 0.5))
		local additionValue = ui.newTTFLabel({text = attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue:setAnchorPoint(cc.p(0, 0.5))

	end

	if type == 1 then 
		-- 将领锁定
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		heroLockBtn = MenuButton.new(normal, selected, disabled, handler(self,self.doLock)):addTo(infoBg)
		heroLockBtn:setPosition(self:getBg():getContentSize().width - 155,378)
		if not islocked then heroLockBtn:setLabel(CommonText[902][1]) else heroLockBtn:setLabel(CommonText[902][2]) end
		heroLockBtn:setEnabled(true)
	end
	

	local skillTit = ui.newTTFLabel({text = CommonText[513][2], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 40, y = 170, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	skillTit:setAnchorPoint(cc.p(0, 0.5))
	if hero.skillId > 0 then
		local skillItem = display.newSprite("image/item/skillid_"..hero.skillId..".jpg"):addTo(infoBg)
		skillItem:setPosition(skillItem:getContentSize().width, skillItem:getContentSize().height)
		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(infoBg)
		fame:setPosition(skillItem:getPosition())
		local skillName = ui.newTTFLabel({text = hero.skillName, font = G_FONT, size = FONT_SIZE_MEDIUM, 
			x = skillItem:getPositionX(),y = skillItem:getPositionY() - skillItem:getContentSize().height / 2 - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(infoBg)
		local skillDetail = nil
		skillItem:setTouchEnabled(true)
		skillItem:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				skillDetail = UiUtil.createSkillView(1, nil, {name = hero.skillName,desc = hero.skillDesc}):addTo(infoBg)
				skillDetail:setPosition(skillItem:getContentSize().width / 2,skillItem:getPositionY() + skillItem:getContentSize().height + 20)
				skillDetail:setAnchorPoint(cc.p(0,0.5))
				return true
			elseif event.name == "ended" then
				skillDetail:removeSelf()
			end
		end)
	else
		local skillName = ui.newTTFLabel({text = CommonText[985], font = G_FONT, size = FONT_SIZE_MEDIUM, 
			x = 50,y = 130, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(infoBg)
		skillName:setAnchorPoint(cc.p(0, 0.5))
	end
	
	if type == 1 then
		--按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		heroPicBtn = MenuButton.new(normal, selected, disabled, handler(self,self.levelUpHandler)):addTo(self:getBg())
		heroPicBtn:setPosition(self:getBg():getContentSize().width / 2 - 210,20)
		heroPicBtn:setLabel(CommonText[514][1])
		heroPicBtn:setEnabled(hero.canup > 0 and hero.count > ArmyBO.getHeroFightNum(hero.heroId)) -- not islocked and
		--分解
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		heroLotteryBtn = MenuButton.new(normal, selected, disabled, handler(self,self.decomposeHandler)):addTo(self:getBg())
		heroLotteryBtn:setPosition(self:getBg():getContentSize().width / 2 - 70,20)
		heroLotteryBtn:setLabel(CommonText[514][2])

		local heroDB = HeroMO.queryHero(hero.heroId)
		heroLotteryBtn:setEnabled(not islocked and hero.count > ArmyBO.getHeroFightNum(hero.heroId) and heroDB and heroDB.resolveId ~= 0)

		-- 将领觉醒
		local normal = display.newSprite(IMAGE_COMMON .. "btn_awake_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_awake_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local awakeBtn = MenuButton.new(normal, selected, disabled, handler(self,self.heroAwake)):addTo(self:getBg())
		awakeBtn:setPosition(self:getBg():getContentSize().width / 2 + 70,20)
		awakeBtn:setLabel(CommonText[980])
		awakeBtn:setEnabled(hero.awakenHeroId > 0 and UserMO.level_  >= self.hero.commanderLv and hero.count > ArmyBO.getHeroFightNum(hero.heroId)) --如果满足等级和awakenHeroId字段

		--分享
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local heroImproveBtn = MenuButton.new(normal, selected, nil, handler(self,self.shareHandler)):addTo(self:getBg())
		heroImproveBtn:setPosition(self:getBg():getContentSize().width / 2 + 210,20)
		heroImproveBtn:setLabel(CommonText[514][4])
		heroImproveBtn.heroId = hero.heroId
	elseif type == 3 then
		-- 将领上阵
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local heroDecomposeBtn = MenuButton.new(normal, selected, disabled, handler(self,self.useHandler)):addTo(self:getBg())
		heroDecomposeBtn:setPosition(self:getBg():getContentSize().width / 2,20)
		heroDecomposeBtn:setLabel(CommonText[514][3])
		if hero.type == HERO_TYPE_CIVILIAN or hero.count <= ArmyBO.getHeroFightNum(hero.heroId,self.kind) then -- 文官和已经派遣的武将不能上阵
			heroDecomposeBtn:setEnabled(false)
		end
	end
end

function HeroDetailDialog:levelUpHandler()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.HeroLevelUpDialog").new(self.hero):push()
end

function HeroDetailDialog:decomposeHandler()
	ManagerSound.playNormalButtonSound()
	if UserMO.queryFuncOpen(UFP_STAFF_CONFIG) and HeroMO.isStaffHeroPutById(self.hero.heroId) then
		Toast.show(CommonText[100022])
		return
	end
	require("app.dialog.HeroDecomposeDialog").new(DECOMPOSE_TYPE_HERO,self.hero):push()
end

--如果有前提任务则做任务。否则直接到觉醒操作界面
function HeroDetailDialog:heroAwake()
	ManagerSound.playNormalButtonSound()
	if self.hero.awakenCond then
		self:pop()
		require("app.dialog.HeroAwakeDialog").new(self.hero):push()
		require("app.dialog.AwakeAnimationDialog").new(AWAKE_BEGIN_TYPE,self.hero):push()
	else
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[987], function()
			HeroBO.getAwakeHeroInfo(function (awakeHeros)
				self:pop()
				require("app.dialog.AwakeOperationDialog").new(awakeHeros):push()
				require("app.dialog.AwakeAnimationDialog").new(AWAKE_BEGIN_TYPE,self.hero):push()
			end,self.hero)
		end):push()
	end
end

function HeroDetailDialog:shareHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ShareDialog").new(SHARE_TYPE_HERO, sender.heroId,sender):push()
end

function HeroDetailDialog:detailcloseHandler()
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function HeroDetailDialog:useHandler()
	ManagerSound.playNormalButtonSound()
	-- gprint("武将id:", self.hero.heroId)

	Notify.notify(LOCAL_CHOSE_HERO_EVENT, {heroId = self.hero.heroId})
end

-- 锁定 / 解锁
function HeroDetailDialog:doLock()
	if not heroLockBtn then return end

	heroLockBtn:setEnabled(false)

	local function doneLock()
		Loading.getInstance():unshow()
		local locked = HeroMO.IsLockById(self.hero.heroId)
		islocked = locked

		if locked then 
			Toast.show(CommonText[970][1])	
			heroLockBtn:setLabel(CommonText[902][2])
		else 
			Toast.show(CommonText[970][2]) 
			heroLockBtn:setLabel(CommonText[902][1])
		end
		if itemLock then itemLock:setVisible(locked) end
		if heroPicBtn then heroPicBtn:setEnabled(self.hero.canup > 0 and self.hero.count > ArmyBO.getHeroFightNum(self.hero.heroId)) end
		if heroLotteryBtn then 
			local heroDB = HeroMO.queryHero(self.hero.heroId)
			heroLotteryBtn:setEnabled(not islocked and self.hero.count > ArmyBO.getHeroFightNum(self.hero.heroId) and heroDB and heroDB.resolveId ~= 0) 
		end
		heroLockBtn:setEnabled(true)
	end
	Loading.getInstance():show()
	local attemptLock = not islocked
	HeroBO.lockHero( doneLock, self.hero.heroId, attemptLock)
end

function HeroDetailDialog:onExit()
	HeroDetailDialog.super.onExit(self)
	if self.m_detailHandler then
		Notify.unregister(self.m_detailHandler)
		self.m_detailHandler = nil
	end
end


return HeroDetailDialog