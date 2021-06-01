
-- 战斗力发生变化的view

local FightChangeView = class("FightChangeView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

local instance_ = nil

local CHANGE_TYPE_BIT = 1  -- 数字从第到高，每位的增加
local CHANGE_TYPE_NUM = 2  -- 数字1个1个加

local oldFightParam_ = {}

function FightChangeView:ctor()
	self.m_oldValue = 0
	self.m_newValue = 0
	self.m_curValue = 0
	self.m_changeType = 0
	self.m_changeBitIndex = 0

	self.m_isStart = false
	self.m_fameIndex = 0
end

function FightChangeView:onEnter()
	-- self:setContentSize(cc.size(display.width, display.height))
	-- self:setAnchorPoint(cc.p(0.5, 0.5))

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function FightChangeView:onExit()
	gprint("FightChangeView:onExit")
	instance_ = nil
end

function FightChangeView:start(oldValue, newValue, fightParam)
	oldValue = math.floor(oldValue)
	newValue = math.floor(newValue)
	if oldValue == newValue then return end
	-- print("oldValue", oldValue, "newValue:", newValue)
	if self.m_oldValue == oldValue and self.m_newValue == newValue then return end -- 值没有发生变化，继续之前的流程

	self.m_isStart = true
	self.m_fameIndex = 0

	self.m_oldValue = oldValue
	self.m_newValue = newValue

	self.m_curValue = self.m_oldValue

	self:stopAllActions()

	ManagerSound.playSound("level_up")

	if not self.m_container then
		self.m_container = display.newNode():addTo(self)

		armature_add(IMAGE_ANIMATION .. "effect/ui_award_light.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_light.plist", IMAGE_ANIMATION .. "effect/ui_award_light.xml")
		local armature = armature_create("ui_award_light", 0, -20, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
				end
			end):addTo(self.m_container, -1)
		armature:getAnimation():playWithIndex(0)

		local view = display.newSprite(IMAGE_COMMON .. "info_bg_49.png"):addTo(self.m_container)
		-- view:setPosition(0, 0)
		view:runAction(transition.sequence({cc.MoveBy:create(2, cc.p(0, 50))}))
		self.m_container.bg_ = view

		local label = ui.newBMFontLabel({text = "", font = "fnt/num_3.fnt", x = view:getContentSize().width / 2, y = 25}):addTo(view)
		label:setAnchorPoint(cc.p(1, 0.5))
		self.m_container.newLabel_ = label

		local label = ui.newBMFontLabel({text = "", font = "fnt/num_4.fnt", x = view:getContentSize().width / 2, y = 25}):addTo(view)
		label:setAnchorPoint(cc.p(0, 0.5))
		self.m_container.deltaLabel_ = label
	end

	self.m_container.newLabel_:setString(self.m_curValue)

	local delta = newValue - oldValue
	if delta >= 0 then -- 战斗力增加
		self.m_container.deltaLabel_:setFntFile("fnt/num_4.fnt")
		self.m_container.deltaLabel_:setString("+" .. delta)
	else
		self.m_container.deltaLabel_:setFntFile("fnt/num_5.fnt")
		self.m_container.deltaLabel_:setString(delta)
	end

	if math.abs(delta) < 100 then
		self.m_changeType = CHANGE_TYPE_NUM
	else
		self.m_changeType = CHANGE_TYPE_BIT
		self.m_changeBitIndex = 1
	end

	if GAME_PRINT_ENABLE and fightParam then
		self:showDebug(fightParam)
	end
end

function FightChangeView:showDebug(fightParam)
	local node = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_37.png"):addTo(self)
	node:setPreferredSize(cc.size(530, 400))
	node:setPosition(60, -260)

	local startY = node:getContentSize().height - 20

	local label = ui.newTTFLabel({text = "旧阵型----------", font = G_FONT, size = FONT_SIZE_TINY, x = 10, y = startY, align = ui.TEXT_ALIGN_CENTER, color = COLOR[5]}):addTo(node)
	label:setAnchorPoint(cc.p(0, 0.5))

	local formatY = startY - 20

	-- oldFightParam_ = {}
	-- oldFightParam_.formation = TankMO.getEmptyFormation()
	-- oldFightParam_.formation.commander = 201
	-- oldFightParam_.formation[1].tankId = 1
	-- oldFightParam_.formation[1].count = 10
	-- oldFightParam_.analyse = TankBO.analyseFormation(oldFightParam_.formation)

	if oldFightParam_.formation then  -- 有旧阵型
		local formation = oldFightParam_.formation
		local label = ui.newTTFLabel({text="武将: ", font = G_FONT, size = FONT_SIZE_TINY, x = 10, y = formatY, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))

		if formation.commander and formation.commander > 0 then
			local heroDB = HeroMO.queryHero(formation.commander)
			local value = ui.newTTFLabel({text=heroDB.heroName,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
			value:setAnchorPoint(cc.p(0,0.5))
		else
			local value = ui.newTTFLabel({text="无",font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[5]}):addTo(node)
			value:setAnchorPoint(cc.p(0,0.5))
		end

		formatY = formatY - 30

		for index = 1, FIGHT_FORMATION_POS_NUM do
			local format = formation[index]
			if format.tankId > 0 and format.count > 0 then
				local tankDB = TankMO.queryTankById(format.tankId)
				local label = ui.newTTFLabel({text = index .. ": " .. tankDB.name .. " * " .. format.count, font = G_FONT, size = FONT_SIZE_TINY, x = 10, y = formatY, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				label:setAnchorPoint(cc.p(0, 0.5))
			else
				local label = ui.newTTFLabel({text = index .. ": 无", font = G_FONT, size = FONT_SIZE_TINY, x = 10, y = formatY, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				label:setAnchorPoint(cc.p(0, 0.5))
			end
			formatY = formatY - 20
		end
	end

	local fightY = startY - 180

	if oldFightParam_.analyse then
		local analyse = oldFightParam_.analyse

		local label = ui.newTTFLabel({text = "旧战力----------", font = G_FONT, size = FONT_SIZE_TINY, x = 10, y = fightY, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))

		fightY = fightY - 25

		-- 总的
		local label = ui.newTTFLabel({text="总战力:", font=G_FONT, size=FONT_SIZE_TINY,x=10,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.total,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25

		-- 基础
		local label = ui.newTTFLabel({text="基础战力:", font=G_FONT, size=FONT_SIZE_TINY,x=10,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.base,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25

		-- 配件
		local label = ui.newTTFLabel({text="配件战力:", font=G_FONT, size=FONT_SIZE_TINY,x=10,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.part,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25
		
		-- 技能
		local label = ui.newTTFLabel({text="技能战力:", font=G_FONT, size=FONT_SIZE_TINY,x=10,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.skill,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25
		
		-- 武将
		local label = ui.newTTFLabel({text="武将战力:", font=G_FONT, size=FONT_SIZE_TINY,x=10,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.hero,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25
		
		-- 装备
		local label = ui.newTTFLabel({text="装备战力:", font=G_FONT, size=FONT_SIZE_TINY,x=10,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.equip,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25
			
		-- 能晶
		local label = ui.newTTFLabel({text="能晶战力:", font=G_FONT, size=FONT_SIZE_TINY,x=10,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.energyspar,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))		
	end

	---------------------------------------------------------
	------------------    新的阵型数据  ---------------------
	---------------------------------------------------------

	local label = ui.newTTFLabel({text = "新阵型:", font = G_FONT, size = FONT_SIZE_TINY, x = 210, y = startY, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(node)
	label:setAnchorPoint(cc.p(0, 0.5))

	local formatY = startY - 20

	if fightParam.formation then  -- 有阵型
		local formation = fightParam.formation
		local label = ui.newTTFLabel({text="武将: ", font = G_FONT, size = FONT_SIZE_TINY, x = 210, y = formatY, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))

		if formation.commander and formation.commander > 0 then
			local heroDB = HeroMO.queryHero(formation.commander)
			local value = ui.newTTFLabel({text=heroDB.heroName,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
			value:setAnchorPoint(cc.p(0,0.5))
		else
			local value = ui.newTTFLabel({text="无",font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[5]}):addTo(node)
			value:setAnchorPoint(cc.p(0,0.5))
		end

		formatY = formatY - 30

		for index = 1, FIGHT_FORMATION_POS_NUM do
			local format = formation[index]
			if format.tankId > 0 and format.count > 0 then
				local tankDB = TankMO.queryTankById(format.tankId)
				local label = ui.newTTFLabel({text = index .. ": " .. tankDB.name .. " * " .. format.count, font = G_FONT, size = FONT_SIZE_TINY, x = 210, y = formatY, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				label:setAnchorPoint(cc.p(0, 0.5))
			else
				local label = ui.newTTFLabel({text = index .. ": 无", font = G_FONT, size = FONT_SIZE_TINY, x = 210, y = formatY, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				label:setAnchorPoint(cc.p(0, 0.5))
			end
			formatY = formatY - 20
		end
	end

	local fightY = startY - 180

	if fightParam.analyse then
		local analyse = fightParam.analyse

		local label = ui.newTTFLabel({text = "新战力----------", font = G_FONT, size = FONT_SIZE_TINY, x = 210, y = fightY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))

		fightY = fightY - 25

		-- 总的
		local label = ui.newTTFLabel({text="总战力:", font=G_FONT, size=FONT_SIZE_TINY,x=210,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.total,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25

		-- 基础
		local label = ui.newTTFLabel({text="基础战力:", font=G_FONT, size=FONT_SIZE_TINY,x=210,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.base,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25

		-- 配件
		local label = ui.newTTFLabel({text="配件战力:", font=G_FONT, size=FONT_SIZE_TINY,x=210,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.part,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25
		
		-- 技能
		local label = ui.newTTFLabel({text="技能战力:", font=G_FONT, size=FONT_SIZE_TINY,x=210,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.skill,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25
		
		-- 武将
		local label = ui.newTTFLabel({text="武将战力:", font=G_FONT, size=FONT_SIZE_TINY,x=210,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.hero,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25
		
		-- 装备
		local label = ui.newTTFLabel({text="装备战力:", font=G_FONT, size=FONT_SIZE_TINY,x=210,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.equip,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))

		fightY = fightY - 25
		-- 装备
		local label = ui.newTTFLabel({text="能晶战力:", font=G_FONT, size=FONT_SIZE_TINY,x=210,y=fightY, color=COLOR[11], align=ui.TEXT_ALIGN_CENTER}):addTo(node)
		label:setAnchorPoint(cc.p(0, 0.5))
		local value = ui.newTTFLabel({text=analyse.energyspar,font=G_FONT,size=FONT_SIZE_TINY,x=label:getPositionX()+label:getContentSize().width, y=label:getPositionY(),align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))		

	end

	---------------------------------------------------------
	------------------    战力数据变化  ---------------------
	---------------------------------------------------------

	local fightY = startY - 180

	if oldFightParam_.analyse and fightParam.analyse then
		fightY = fightY - 25

		local value = ui.newTTFLabel({text="",font=G_FONT,size=FONT_SIZE_TINY,x=420, y=fightY,align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))
		local delta = fightParam.analyse.total - oldFightParam_.analyse.total
		if delta >= 0 then
			value:setString("+" .. delta)
			value:setColor(COLOR[2])
		else
			value:setString(delta)
			value:setColor(COLOR[5])
		end

		fightY = fightY - 25
		
		local value = ui.newTTFLabel({text="",font=G_FONT,size=FONT_SIZE_TINY,x=420, y=fightY,align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))
		local delta = fightParam.analyse.base - oldFightParam_.analyse.base
		if delta >= 0 then
			value:setString("+" .. delta)
			value:setColor(COLOR[2])
		else
			value:setString(delta)
			value:setColor(COLOR[5])
		end

		fightY = fightY - 25
		
		local value = ui.newTTFLabel({text="",font=G_FONT,size=FONT_SIZE_TINY,x=420, y=fightY,align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))
		local delta = fightParam.analyse.part - oldFightParam_.analyse.part
		if delta >= 0 then
			value:setString("+" .. delta)
			value:setColor(COLOR[2])
		else
			value:setString(delta)
			value:setColor(COLOR[5])
		end

		fightY = fightY - 25
		
		local value = ui.newTTFLabel({text="",font=G_FONT,size=FONT_SIZE_TINY,x=420, y=fightY,align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))
		local delta = fightParam.analyse.skill - oldFightParam_.analyse.skill
		if delta >= 0 then
			value:setString("+" .. delta)
			value:setColor(COLOR[2])
		else
			value:setString(delta)
			value:setColor(COLOR[5])
		end

		fightY = fightY - 25
		
		local value = ui.newTTFLabel({text="",font=G_FONT,size=FONT_SIZE_TINY,x=420, y=fightY,align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))
		local delta = fightParam.analyse.hero - oldFightParam_.analyse.hero
		if delta >= 0 then
			value:setString("+" .. delta)
			value:setColor(COLOR[2])
		else
			value:setString(delta)
			value:setColor(COLOR[5])
		end
		
		fightY = fightY - 25
		
		local value = ui.newTTFLabel({text="",font=G_FONT,size=FONT_SIZE_TINY,x=420, y=fightY,align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))
		local delta = fightParam.analyse.equip - oldFightParam_.analyse.equip
		if delta >= 0 then
			value:setString("+" .. delta)
			value:setColor(COLOR[2])
		else
			value:setString(delta)
			value:setColor(COLOR[5])
		end

		fightY = fightY - 25
		
		local value = ui.newTTFLabel({text="",font=G_FONT,size=FONT_SIZE_TINY,x=420, y=fightY,align=ui.TEXT_ALIGN_CENTER,color=COLOR[2]}):addTo(node)
		value:setAnchorPoint(cc.p(0,0.5))
		local delta = fightParam.analyse.energyspar - oldFightParam_.analyse.energyspar
		if delta >= 0 then
			value:setString("+" .. delta)
			value:setColor(COLOR[2])
		else
			value:setString(delta)
			value:setColor(COLOR[5])
		end	
	end

	oldFightParam_ = fightParam
end

function FightChangeView:update(dt)
	if not self.m_isStart then return end
	if not self.m_container then return end

	if self.m_curValue == self.m_newValue then
		self.m_isStart = false
		self:runAction(transition.sequence({cc.DelayTime:create(0.5), cc.CallFunc:create(function()
				self:removeSelf()
			end)}))
		return
	end

	if self.m_changeType == CHANGE_TYPE_NUM then
		if self.m_curValue < self.m_newValue then
			self.m_curValue = self.m_curValue + 1
		else
			self.m_curValue = self.m_curValue - 1
		end
		self.m_container.newLabel_:setString(self.m_curValue)
	else
		if self.m_fameIndex == 1 then
			local seed = math.pow(10, self.m_changeBitIndex)
			self.m_curValue = math.floor(self.m_curValue / seed) * seed +  self.m_newValue % seed
			-- print("value:", self.m_curValue)

			self.m_changeBitIndex = self.m_changeBitIndex + 1
			self.m_container.newLabel_:setString(self.m_curValue)
			self.m_container.newLabel_:runAction(cc.Blink:create(0.15, 1))
		else
			self.m_fameIndex = self.m_fameIndex % 20
		end
	end

	self.m_fameIndex = self.m_fameIndex + 1
end

function FightChangeView.getInstance()
	if instance_ == nil then
		instance_ = FightChangeView.new()
		instance_:setPosition(display.cx - 100, display.cy + 100)
		instance_:addTo(display.getRunningScene(), 11)
	end
	return instance_
end

return FightChangeView