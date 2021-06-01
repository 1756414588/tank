--
-- Author: gf
-- Date: 2015-09-01 16:01:04
-- 

local HeroTableView = class("HeroTableView", TableView)

function HeroTableView:ctor(size,star,viewFor, kind)
	HeroTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 180)
	self.m_viewFor = viewFor
	self.star = star
	self.kind = kind

	if self.m_viewFor == 1 then
		if self.star == 1 then
			self.heros = HeroMO.heros_
		else
			self.heros = HeroMO.queryHeroByStar(star - 1)
		end
	else
		if self.star == 1 then
			self.heros = HeroMO.getShowHeroList(HeroMO.heros_)
		else
			self.heros = HeroMO.queryFightHeroByStar(star - 1)
		end
	end

	local herosTmp = {}
	for i, v in ipairs(self.heros) do
		local tmp = nil
		if v.endTime == nil then
			tmp = v
		else
			-- print("v.endTime", v.endTime)
			local curTime = ManagerTimer.getTime()
			if v.endTime > 0 and curTime < v.endTime then
				tmp = v
			elseif v.endTime <= 0 then
				tmp = v
			end
		end
		if tmp ~= nil then
			if self.kind == ARMY_SETTING_FOR_WORLD or self.m_viewFor == 1 then
				table.insert(herosTmp, tmp)
			else
				if tmp.heroId < 401 or tmp.heroId > 410 then
					table.insert(herosTmp, tmp)
				end
			end
		end
	end
	self.heros = herosTmp
end


function HeroTableView:onEnter(size,star,viewFor)
	HeroTableView.super.onEnter(self)
	armature_add(IMAGE_ANIMATION .. "hero/juexingtishi.pvr.ccz", IMAGE_ANIMATION .. "hero/juexingtishi.plist", IMAGE_ANIMATION .. "hero/juexingtishi.xml")
	self.m_updateHerosHandler = Notify.register(LOCAL_HERO_UPDATE_EVENT, handler(self, self.onUpdateHeros))
	
end

function HeroTableView:numberOfCells()
	return #self.heros
end

function HeroTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HeroTableView:createCellAtIndex(cell, index)
	HeroTableView.super.createCellAtIndex(self, cell, index)

	local buttons = {}
	cell.buttons = buttons

	local hero = self.heros[index]
	local itemView = display.newNode()
	
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png",400, self.m_cellSize.height / 2 - 10):addTo(cell)
	infoBg:setCapInsets(cc.rect(80, 60, 1, 1))
	infoBg:setPreferredSize(cc.size(426, 175))

	local itemPic = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId):addTo(infoBg)
	itemPic:setScale(0.8)
	itemPic:setPosition(20 - itemPic:getContentSize().width / 2,infoBg:getContentSize().height / 2 - 5)

	--觉醒将领高亮显示
	if hero.awakenHeroId > 0 then
		local lightAm = armature_create("juexingtishi"):addTo(infoBg,999)
		lightAm:setPosition(itemPic:getPosition())
		lightAm:setScale(1.4)
		lightAm:getAnimation():play("start_juexingtishi")
		lightAm:performWithDelay(function()
				lightAm:getAnimation():play("start_juexingtishi")
			end, 5, 1)
	end
	-- 锁定
	local itemLock = display.newScale9Sprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemPic)
	itemLock:setPreferredSize(cc.size(56,70))
	itemLock:setScale(0.8)
	itemLock:setPosition(itemPic:getContentSize().width - 45, itemPic:getContentSize().height - 45)
	itemLock:setVisible(hero.locked)

	--已上阵图片
	local fightPic = display.newSprite(IMAGE_COMMON .. "hero_fight.png"):addTo(itemPic)
	fightPic:setPosition(itemPic:getContentSize().width / 2, itemPic:getContentSize().width - 50)
	fightPic:setVisible(hero.count == ArmyBO.getHeroFightNum(hero.heroId, self.kind))


	local countLab = ui.newTTFLabel({text = CommonText[507][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 46, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(infoBg)
	local countValue = ui.newTTFLabel({text = hero.count, font = G_FONT, size = FONT_SIZE_SMALL, x = 100, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[2]}):addTo(infoBg)

	local useLab = ui.newTTFLabel({text = CommonText[507][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 246, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(infoBg)
	local useValue = ui.newTTFLabel({text = ArmyBO.getHeroFightNum(hero.heroId), font = G_FONT, size = FONT_SIZE_SMALL, x = 300, y = 148, align = ui.TEXT_ALIGN_LEFT, color = COLOR[2]}):addTo(infoBg)

	local skillIcon = display.newSprite(IMAGE_COMMON .. "icon_hero_skill.png", 60, 115):addTo(infoBg)

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
		local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 45, y = 88, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab1:setAnchorPoint(cc.p(0, 0.5))
		local additionValue1 = ui.newTTFLabel({text = "+" .. hero.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue1:setAnchorPoint(cc.p(0, 0.5))
	end
	
	local heroAttr = json.decode(hero.attr)
	local attrCount = #heroAttr

	for index = 1,#heroAttr do
		local tanksAddition = heroAttr[index]
		local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])

		local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 45 + (index - 1) % 2 * 200, y = 68 - 20 * math.floor((index - 1) / 2), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
		additionLab:setAnchorPoint(cc.p(0, 0.5))
		local additionValue = ui.newTTFLabel({text = attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		additionValue:setAnchorPoint(cc.p(0, 0.5))

		-- if tanksAddition[1] % 2 == 0 then
		-- 	additionValue:setString("+" .. tanksAddition[2] / 100 .. "%")
		-- else
		-- 	additionValue:setString("+" .. tanksAddition[2])
		-- end
	end

	-- local btn = CellTouchButton.new(infoBg, nil, nil, nil, handler(self, self.onChosenCallback))
	-- btn.hero = hero
	-- buttons[index] = btn
	-- cell:addButton(btn, 400, self.m_cellSize.height / 2 - 10)

	if hero.endTime and hero.endTime > 0 then
		local countdownLabel = UiUtil.label("剩余有效时间:"):addTo(infoBg)
		countdownLabel:setAnchorPoint(cc.p(0, 0.5))
		countdownLabel:setPosition(45, 68 - 20 * (math.floor(attrCount / 2) + 1))
		local countdownTimeLabel = UiUtil.label("00d:00h:00m:00s", nil, COLOR[6]):rightTo(countdownLabel)
		countdownTimeLabel:setAnchorPoint(cc.p(0, 0.5))
		countdownLabel:setVisible(false)
		countdownTimeLabel:setVisible(false)

		-- 如果有时间属性, 显示倒计哦时
		local curTime = ManagerTimer.getTime()
		local remains = hero.endTime - curTime
		if remains > 0 then
			countdownLabel:setVisible(true)
			countdownTimeLabel:setVisible(true)
			local function tick()
				-- body
				local now_t = ManagerTimer.getTime()
				local remains = hero.endTime - now_t
				remains = math.floor(remains)
				if remains > 0 then
					local d = math.floor(remains / 86400)
					local h = math.floor((remains - d * 86400) / 3600)
					local m = math.floor((remains - d * 86400 - h * 3600) / 60)
					local s = remains - d * 86400 - h * 3600 - m * 60

					countdownTimeLabel:setString(string.format("%02dd:%02dh:%02dm:%02ds",d,h,m,s))
				else
					countdownLabel:setString("已失效")
					countdownLabel:setColor(COLOR[6])
					countdownTimeLabel:setVisible(false)
				end
			end
			tick()
			cell:performWithDelay(tick, 1, 1)
		else
			countdownLabel:setVisible(true)
			countdownLabel:setColor(COLOR[6])
			countdownLabel:setString("已失效")
		end
	end

	if table.isexist(hero, 'cd') and hero.cd > 0 then
		local cooldownLabel = UiUtil.label("CD剩余时间:"):addTo(infoBg)
		cooldownLabel:setAnchorPoint(cc.p(0, 0.5))
		cooldownLabel:setPosition(45, 68 - 20 * (math.floor(attrCount / 2) + 2))
		local cooldownTimeLabel = UiUtil.label("00d:00h:00m:00s", nil, COLOR[6]):rightTo(cooldownLabel)
		cooldownTimeLabel:setAnchorPoint(cc.p(0, 0.5))
		cooldownLabel:setVisible(false)
		cooldownTimeLabel:setVisible(false)

		-- 如果有时间属性, 显示倒计哦时
		local curTime = ManagerTimer.getTime()
		local remains = hero.cd - curTime
		if remains > 0 then
			cooldownLabel:setVisible(true)
			cooldownTimeLabel:setVisible(true)
			local function tick1()
				-- body
				local now_t = ManagerTimer.getTime()
				local remains = hero.cd - now_t
				remains = math.floor(remains)
				if remains > 0 then
					local h = math.floor(remains / 3600)
					local m = math.floor((remains - h * 3600) / 60)
					local s = remains - h * 3600 - m * 60

					cooldownTimeLabel:setString(string.format("%02dh:%02dm:%02ds",h,m,s))
				else
					cooldownLabel:setVisible(false)
					cooldownTimeLabel:setVisible(false)
				end
			end
			tick1()
			cell:performWithDelay(tick1, 1, 1)
		end
	end

	return cell
end


function HeroTableView:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()
	-- gdump(sender.hero,"[HeroTableView]..onChosenCallback")
	local hero = self.heros[index]
	if self.m_viewFor == 1 then
		require("app.dialog.HeroDetailDialog").new(hero, 1, self.kind):push()
	elseif self.m_viewFor == 2 then -- 武将上阵
		require("app.dialog.HeroDetailDialog").new(hero, 3, self.kind):push()
	end
end


-- function HeroTableView:onChosenCallback(tag,sender)
-- 	ManagerSound.playNormalButtonSound()
-- 	-- gdump(sender.hero,"[HeroTableView]..onChosenCallback")
-- 	if self.m_viewFor == 1 then
-- 		require("app.dialog.HeroDetailDialog").new(sender.hero, 1):push()
-- 	elseif self.m_viewFor == 2 then -- 武将上阵
-- 		require("app.dialog.HeroDetailDialog").new(sender.hero, 3):push()
-- 	end
-- end

function HeroTableView:onUpdateHeros()
	if self.m_viewFor == 1 then
		if self.star == 1 then
			self.heros = HeroMO.heros_
		else
			self.heros = HeroMO.queryHeroByStar(self.star - 1)
		end
	else
		if self.star == 1 then
			self.heros = HeroMO.getShowHeroList(HeroMO.heros_)
		else
			self.heros = HeroMO.queryFightHeroByStar(self.star - 1)
		end
	end
	local herosTmp = {}
	for i, v in ipairs(self.heros) do
		local tmp = nil
		if v.endTime == nil then
			tmp = v
		else
			local curTime = ManagerTimer.getTime()
			if v.endTime > 0 and curTime < v.endTime then
				tmp = v
			elseif v.endTime <= 0 then
				tmp = v
			end
		end
		if tmp ~= nil then
			if self.kind == ARMY_SETTING_FOR_WORLD or self.m_viewFor == 1 then
				table.insert(herosTmp, tmp)
			else
				if tmp.heroId < 401 or tmp.heroId > 410 then
					table.insert(herosTmp, tmp)
				end
			end
		end
	end
	self.heros = herosTmp
	self:reloadData()
end

function HeroTableView:updateUI(index)
	self.star = index
	if self.m_viewFor == 1 then
		if self.star == 1 then
			self.heros = HeroMO.heros_
		else
			self.heros = HeroMO.queryHeroByStar(self.star - 1)
		end
	else
		if self.star == 1 then
			self.heros = HeroMO.getShowHeroList(HeroMO.heros_)
		else
			self.heros = HeroMO.queryFightHeroByStar(self.star - 1)
		end
	end
	local herosTmp = {}
	for i, v in ipairs(self.heros) do
		local tmp = nil
		if v.endTime == nil then
			tmp = v
		else
			local curTime = ManagerTimer.getTime()
			if v.endTime > 0 and curTime < v.endTime then
				tmp = v
			elseif v.endTime <= 0 then
				tmp = v
			end
		end
		if tmp ~= nil then
			if self.kind == ARMY_SETTING_FOR_WORLD or self.m_viewFor == 1 then
				table.insert(herosTmp, tmp)
			else
				if tmp.heroId < 401 or tmp.heroId > 410 then
					table.insert(herosTmp, tmp)
				end
			end
		end
	end
	self.heros = herosTmp
	self:reloadData()
end

function HeroTableView:onExit()
	HeroTableView.super.onExit(self)
	
	armature_remove(IMAGE_ANIMATION .. "hero/juexingtishi.pvr.ccz", IMAGE_ANIMATION .. "hero/juexingtishi.plist", IMAGE_ANIMATION .. "hero/juexingtishi.xml")

	if self.m_updateHerosHandler then
		Notify.unregister(self.m_updateHerosHandler)
		self.m_updateHerosHandler = nil
	end
end

return HeroTableView