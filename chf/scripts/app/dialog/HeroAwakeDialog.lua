--
-- Author: Your Name
-- Date: 2017-03-04 16:34:37
--

--将领觉醒任务TableView
local HeroAwakeTaskTableView = class("HeroAwakeTaskTableView", TableView)

function HeroAwakeTaskTableView:ctor(size,hero,viewFor,kind)
	HeroAwakeTaskTableView.super.ctor(self,size,SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 120)
	self.hero = hero
	self.kind = kind
	self.viewFor = viewFor
	self.canAwake = false
end

function HeroAwakeTaskTableView:onEnter(size,star,viewFor)
	HeroAwakeTaskTableView.super.onEnter(self)
end

function HeroAwakeTaskTableView:numberOfCells()
	local task = json.decode(self.hero.awakenCond)
	return #task
end

function HeroAwakeTaskTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HeroAwakeTaskTableView:createCellAtIndex(cell, index)
	HeroAwakeTaskTableView.super.createCellAtIndex(self, cell, index)
	local hero = self.hero
	local task = json.decode(hero.awakenCond)
	local info = HeroBO.getAwakeSkillInfo()
	local taskInfo = json.decode(hero.awakenCond)[index][index]  -- task[1]为将领的ID。 根据ID读表显示任务描述
	-- 任务头像
	local itemPic = UiUtil.createItemView(ITEM_KIND_HERO,taskInfo[1]):addTo(cell)
	itemPic:setScale(0.5)
	itemPic:setPosition(50,60)

	local goAwake = true
	for k, v in ipairs(task) do
		local hasFind = false
		for m,n in ipairs(v) do
			if info[n[1]] and info[n[1]][n[2]] and info[n[1]][n[2]] >= n[3] then --找到了满足了
				hasFind = true
				break
			end
		end
		if not hasFind then
			goAwake = false
			break
		end
	end
	self.canAwake = goAwake
	--任务描述
	local taskInfo = ui.newTTFLabel({text = hero.awakenTask, font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = itemPic:getPositionX() + 60, y = itemPic:getPositionY(), align = ui.TEXT_ALIGN_LEFT}):addTo(cell)
	local finish = ui.newTTFLabel({text = "("..CommonText[983][1]..")", font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = taskInfo:getPositionX() + taskInfo:getContentSize().width / 2, y = taskInfo:getPositionY(), align = ui.TEXT_ALIGN_LEFT}):addTo(cell)
	taskInfo:setColor(goAwake and COLOR[2] or COLOR[1])
	finish:setString(goAwake and "("..CommonText[983][2]..")" or "("..CommonText[983][1]..")")
	finish:setColor(goAwake and COLOR[2] or COLOR[1])

	return cell
end

function HeroAwakeTaskTableView:getCanAwake()
	return self.canAwake
end

function HeroAwakeTaskTableView:onExit()
	HeroAwakeTaskTableView.super.onExit(self)
end
---------------------------------------------------------------
---------------------------------------------------------------
--将领觉醒Dialog

local Dialog = require("app.dialog.Dialog")
local HeroAwakeDialog = class("HeroAwakeDialog", Dialog)

function HeroAwakeDialog:ctor(hero,type,kind)
	HeroAwakeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})

	self.hero = hero
	self.type = type
	self.kind = kind
end

function HeroAwakeDialog:onEnter()
	HeroAwakeDialog.super.onEnter(self)
	self:setTitle(CommonText[514][7])
	self.heroCan = false
	armature_add(IMAGE_ANIMATION .. "hero/youying.pvr.ccz", IMAGE_ANIMATION .. "hero/youying.plist", IMAGE_ANIMATION .. "hero/youying.xml")
	armature_add(IMAGE_ANIMATION .. "hero/diaoge.pvr.ccz", IMAGE_ANIMATION .. "hero/diaoge.plist", IMAGE_ANIMATION .. "hero/diaoge.xml")
	armature_add(IMAGE_ANIMATION .. "hero/anxing.pvr.ccz", IMAGE_ANIMATION .. "hero/anxing.plist", IMAGE_ANIMATION .. "hero/anxing.xml")
	armature_add(IMAGE_ANIMATION .. "hero/leidi.pvr.ccz", IMAGE_ANIMATION .. "hero/leidi.plist", IMAGE_ANIMATION .. "hero/leidi.xml")

	local hero = self.hero
	local islocked = HeroMO.IsLockById(hero.heroId)
	
	--bg
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(550, 780))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	--infoBg 2
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_awake_"..hero.map..".jpg"):addTo(self:getBg(), -1)
	infoBg:setPreferredSize(cc.size(515, 332))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - infoBg:getContentSize().height / 2 -70)

	-- 半身像
	local diePic = display.newSprite(IMAGE_COMMON .. "info_bg_awake_hui_"..hero.map..".png"):addTo(infoBg)
	diePic:setPosition(infoBg:getContentSize().width / 2 + 100,infoBg:getContentSize().height / 2 + 20)
	--将领名称
	local heroName = ui.newTTFLabel({text = hero.heroName, font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 110, y = infoBg:getContentSize().height - 40, align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	--line 
	local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(180, line:getContentSize().height))
	line:setAnchorPoint(cc.p(0,0.5))
	line:setPosition(20,heroName:getPositionY() - 20)
	--加成BG
	local additionBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_84.png"):addTo(infoBg)
	additionBg:setPreferredSize(cc.size(180, 230))
	additionBg:setPosition(additionBg:getContentSize().width / 2 + 20,line:getPositionY() - additionBg:getContentSize().height / 2 - 25)
	-- 将领加成label
	local additionTit = ui.newTTFLabel({text = CommonText[513][1], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 10, y = additionBg:getContentSize().height, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(additionBg)
	additionTit:setAnchorPoint(cc.p(0, 0.5))
	-- --带兵 + XX
	if hero.tankCount > 0 then
		local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL,
		 x = 10, y = additionTit:getPositionY() - additionTit:getContentSize().height / 2 - 15, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(additionBg)
		additionLab1:setAnchorPoint(cc.p(0, 0.5))
		local additionValue1 = ui.newTTFLabel({text = "+" .. hero.tankCount, font = G_FONT, size = FONT_SIZE_SMALL,
		 x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(additionBg)
		additionValue1:setAnchorPoint(cc.p(0, 0.5))
	end
	-- xx 加成 xx%
	local heroAttr = json.decode(hero.attr)
	for index = 1,#heroAttr do
		local tanksAddition = heroAttr[index]
		local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
		local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 10, y = additionBg:getContentSize().height - 25 - 35 * index, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(additionBg)
		additionLab:setAnchorPoint(cc.p(0, 0.5))
		local additionValue = ui.newTTFLabel({text = "+"..attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL,
		 x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(additionBg)
		additionValue:setAnchorPoint(cc.p(0, 0.5))
	end

	--技能图标 
	local heroSkillItem = display.newSprite("image/item/skillid_"..hero.skillId..".jpg"):addTo(contentNode)
	heroSkillItem:setPosition(heroSkillItem:getContentSize().width / 2 + 60, infoBg:getPositionY() - infoBg:getContentSize().height / 2 - 20 - heroSkillItem:getContentSize().height / 2)
	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(contentNode)
	fame:setPosition(heroSkillItem:getPosition())
	local skillDetail = nil
	heroSkillItem:setTouchEnabled(true)
	heroSkillItem:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			skillDetail = UiUtil.createSkillView(1, nil, {name = hero.skillName,desc = hero.skillDesc}):addTo(self:getBg(), -1)
			skillDetail:setPosition(heroSkillItem:getContentSize().width / 2,heroSkillItem:getPositionY() + heroSkillItem:getContentSize().height + 20)
			skillDetail:setAnchorPoint(cc.p(0,0.5))
			return true
		elseif event.name == "ended" then
			skillDetail:removeSelf()
		end
	end)

	--技能名称
	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = heroSkillItem:getContentSize().width / 2 + 60, y = heroSkillItem:getPositionY() - heroSkillItem:getContentSize().height /2 - 15, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg(), -1)
	if hero.skillId > 0 then
		skillName:setString(hero.skillName)
	else
		skillName:setString(CommonText[509])
	end

	--第一条分节线
	local lineB = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(self:getBg(), -1)
	lineB:setPreferredSize(cc.size(500, lineB:getContentSize().height))
	lineB:setPosition(self:getBg():getContentSize().width / 2, heroSkillItem:getPositionY() - heroSkillItem:getContentSize().height / 2 - 30)
	--任务BG
	local taskBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(self:getBg(), -1)
	taskBg:setAnchorPoint(cc.p(0,1))
	taskBg:setPosition(40, lineB:getPositionY() - 10)
	--觉醒任务label
	local taskLabel = ui.newTTFLabel({text = CommonText[975], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = taskBg:getContentSize().width / 2 - 20, y = taskBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	-- --将领觉醒任务TableView
	local taskTableView = HeroAwakeTaskTableView.new(cc.size(infoBg:getContentSize().width,infoBg:getContentSize().height - taskLabel:getPositionY() - 100),self.hero):addTo(self:getBg(), -1)
	taskTableView:setPosition(50,40)
	taskTableView:reloadData()
	self.heroCan = taskTableView:getCanAwake()

	--升级按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local taskBtn = MenuButton.new(normal, selected, disabled, handler(self,self.levelUpHandler)):addTo(self:getBg())
	taskBtn:setPosition(self:getBg():getContentSize().width / 2 - 210,60)
	taskBtn:setLabel(CommonText[514][1])
	taskBtn:setEnabled(hero.canup > 0 and hero.count > ArmyBO.getHeroFightNum(hero.heroId)) -- not islocked and
	--将领分解按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local heroLotteryBtn = MenuButton.new(normal, selected, disabled, handler(self, self.lotteryHandler)):addTo(self:getBg())
	heroLotteryBtn:setPosition(self:getBg():getContentSize().width / 2 - 70,60)
	heroLotteryBtn:setLabel(CommonText[514][2])
	heroLotteryBtn:setEnabled(not islocked and hero.count > ArmyBO.getHeroFightNum(hero.heroId))
	heroLotteryBtn:setEnabled(false)
	--将领觉醒完成任务按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local heroDecomposeBtn = MenuButton.new(normal, selected, disabled, handler(self,self.gotoAwakeHandler)):addTo(self:getBg())
	heroDecomposeBtn:setPosition(self:getBg():getContentSize().width / 2 + 70,60)
	heroDecomposeBtn:setLabel(CommonText[514][6])
	heroDecomposeBtn:setEnabled(self.heroCan)

	--将领分享按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local heroImproveBtn = MenuButton.new(normal, selected, nil, handler(self, self.shareHandler)):addTo(self:getBg())
	heroImproveBtn:setPosition(self:getBg():getContentSize().width / 2 + 210,60)
	heroImproveBtn:setLabel(CommonText[514][4])
	heroImproveBtn.heroId = hero.heroId

end

function HeroAwakeDialog:gotoAwakeHandler()
	ManagerSound.playNormalButtonSound()
	HeroBO.getAwakeHeroInfo(function (awakeHeros)
		HeroBO.updateMyHeros()
		self:pop()
		require("app.dialog.AwakeOperationDialog").new(awakeHeros):push()
	end,self.hero)
end

function HeroAwakeDialog:lotteryHandler()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.HeroDecomposeDialog").new(DECOMPOSE_TYPE_HERO,self.hero):push()
end

function HeroAwakeDialog:shareHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ShareDialog").new(SHARE_TYPE_HERO, sender.heroId,sender):push()
end

function HeroAwakeDialog:levelUpHandler()
	ManagerSound.playNormalButtonSound()
	self:pop()
	require("app.dialog.HeroLevelUpDialog").new(self.hero):push()
end

function HeroAwakeDialog:onExit()
	HeroAwakeDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "hero/youying.pvr.ccz", IMAGE_ANIMATION .. "hero/youying.plist", IMAGE_ANIMATION .. "hero/youying.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/diaoge.pvr.ccz", IMAGE_ANIMATION .. "hero/diaoge.plist", IMAGE_ANIMATION .. "hero/diaoge.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/anxing.pvr.ccz", IMAGE_ANIMATION .. "hero/anxing.plist", IMAGE_ANIMATION .. "hero/anxing.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/leidi.pvr.ccz", IMAGE_ANIMATION .. "hero/leidi.plist", IMAGE_ANIMATION .. "hero/leidi.xml")
end


return HeroAwakeDialog