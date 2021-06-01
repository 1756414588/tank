
-- 战斗view
--战斗特效处理
FightEffect = require_ex("app.fight.FightEffect")

local BattleView = class("BattleView", UiNode)

function BattleView:ctor(bgName)
	BattleView.super.ctor(self, "", UI_ENTER_NONE, {closeBtn = false})
	self.m_overHandler = Notify.register(LOCAL_BATTLE_OVER_EVENT, handler(self, self.onFightEnd))
	self.m_nextHandler = Notify.register(LOCAL_BATTLE_NEXT_EVENT, handler(self, self.onFightNext))
	bgName = bgName or "image/bg/bg_battle_1.jpg"
	self.m_bgName = bgName
end

function BattleView:onEnter()
	BattleView.super.onEnter(self)

	FightEffect.onEnter()

	self:hasCloseButton(false)

	self.fightBg_ = display.newSprite(self.m_bgName):addTo(self:getBg(), 2)
	self.fightBg_:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2)

	-- 跳过
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local skipButton = MenuButton.new(normal, selected, nil, handler(self, self.onSkipCallback)):addTo(self, 10)
	skipButton:setPosition(display.cx + 250, 30)
	skipButton:setLabel(CommonText[234])


	if BattleMO.airshipId_ then
		-- 加速
		local normal = display.newSprite(IMAGE_COMMON .. "btn_accel_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_accel_selected.png")
		local speedBtn = MenuButton.new(normal, selected, nil, function (tag,sender)
			local speed = BattleMO.getSpeed()
			if speed == 1 then
				speed = 2
			elseif speed == 2 then
				speed = 4
			elseif speed == 4 then
				speed = 1
			end
			BattleMO.setSpeed(speed)
			sender.tip:setString("X" .. speed)
		end):addTo(self, 10)
		speedBtn:setPosition(display.width - 50, 100)
		speedBtn:setScale(0.8)
		-- speedBtn:setLabel("X1")

		local tip = UiUtil.label("X1"):alignTo(speedBtn, 40, true)
		speedBtn.tip = tip
	end
	--攻守方信息
	if BattleMO.atkInfo_ and BattleMO.atkInfo_.name and BattleMO.atkInfo_.name ~= "" 
		and BattleMO.defInfo_ and BattleMO.defInfo_.name and BattleMO.defInfo_.name ~= "" then
		local l = UiUtil.label(BattleMO.atkInfo_.name .."("..CommonText[20016]..")",nil,cc.c3b(0xff,0xe4,0xe4))
		local bg = UiUtil.sprite9("attack_atk.png",25,12,110,1,l:width() > 120 and l:width()+40 or 160,43)
		l:addTo(bg):center()
		bg:addTo(self,2):pos(bg:width()/2,bg:height()/2)
		self.atkName = l
		-- 进攻方 先手具体值
		local f = UiUtil.label(CommonText[1073] ..":0"  ,nil,cc.c3b(0xff,0xe4,0xe4)):addTo(bg)
		f:setAnchorPoint(cc.p(0,0))
		f:setPosition(bg:width(),0)
		f:setVisible(false)
		if table.isexist(BattleMO.atkInfo_,"firstValue") then
			f:setString(CommonText[1073] ..":" .. BattleMO.atkInfo_.firstValue)
			f:setVisible(true)
		end
		self.atkFirst = f

		
		
		l = UiUtil.label(BattleMO.defInfo_.name .."("..CommonText[20017]..")",nil,cc.c3b(0xe7,0xf0,0xff))
		bg = UiUtil.sprite9("attack_def.png",25,12,110,1,l:width() > 120 and l:width()+40 or 160,41)
		l:addTo(bg):center()
		bg:addTo(self,2):pos(display.width - bg:width()/2,display.height - bg:height()/2)
		self.defName = l

		-- 防守方 先手具体值
		local f2 = UiUtil.label("0:" .. CommonText[1073],nil,cc.c3b(0xff,0xe4,0xe4)):addTo(bg)
		f2:setAnchorPoint(cc.p(1,1))
		f2:setPosition(0,bg:height())
		f2:setVisible(false)
		if table.isexist(BattleMO.defInfo_,"firstValue") then
			f2:setString(BattleMO.defInfo_.firstValue ..":" .. CommonText[1073])
			f2:setVisible(true)
		end
		self.defFirst = f2
	end
	--如果是飞艇，设置队列信息
	if BattleMO.record_ then
		local bg = self:getBg()
		local l = display.newSprite(IMAGE_COMMON.."bg_left.png"):addTo(bg,99):align(display.LEFT_CENTER, 0, bg:height()/2)
		UiUtil.label(CommonText[1002][1], 18, cc.c3b(0xff,0xe4,0xe4)):addTo(l):center()
		l = UiUtil.sprite9("panel_head.png", 30, 30, 1, 1, 115, 210):addTo(bg,99):align(display.LEFT_CENTER, l:x()+l:width(), l:y())
		self.atkNode = display.newNode():size(l:width(),l:height()):addTo(l)

		if BattleMO.bountyBossId_ ~= true then
			l = display.newSprite(IMAGE_COMMON.."bg_right.png"):addTo(bg,99):align(display.RIGHT_CENTER, bg:width(), bg:height()/2)
			UiUtil.label(CommonText[1002][2], 18, cc.c3b(0xe7,0xf0,0xff)):addTo(l):center()
			l = UiUtil.sprite9("panel_head.png", 30, 30, 1, 1, 115, 210):addTo(bg,99):align(display.RIGHT_CENTER, l:x()-l:width(), l:y())
			self.defNode = display.newNode():size(l:width(),l:height()):addTo(l)
		end
	end
	self:showRecord()
end

function BattleView:showRecord()
	if (not BattleMO.airshipId_ and BattleMO.bountyBossId_ ~= true) or not BattleMO.attackers_ or not BattleMO.defencers_ then return end

	self.atkNode:removeAllChildren()
	if self.defNode then
		self.defNode:removeAllChildren()
	end
	local s = 0.55

	for i=1,2 do
		local person = BattleMO.attackers_[i]
		if person then
			local icon = UiUtil.createItemView(ITEM_KIND_HERO, person.commander):addTo(self.atkNode):pos(self.atkNode:width()/2,150 - 110 *(i-1)):scale(s)
			-- UiUtil.label(person.name, 30):alignTo(icon, 100)
			if i == 1 and self.atkName then
				self.atkName:setString(person.name .."("..CommonText[20016]..")")
				if table.isexist(person,"firstValue") and self.atkFirst then
					self.atkFirst:setVisible(true)
					self.atkFirst:setString(CommonText[1073] ..":" .. person.firstValue)
				else
					if self.atkFirst then self.atkFirst:setVisible(false) end
				end
			end
		else
			break
		end
	end

	if BattleMO.bountyBossId_ ~= true then
		for i=1,2 do
			local person = BattleMO.defencers_[i]
			if person then
				local icon = UiUtil.createItemView(ITEM_KIND_HERO, person.commander):addTo(self.defNode):pos(self.defNode:width()/2,150 - 100 *(i-1)):scale(s)
				-- UiUtil.label(person.name, 30):alignTo(icon, -100)
				if i == 1 then
					self.defName:setString(person.name .."("..CommonText[20017]..")")
					if table.isexist(person,"firstValue") and self.defFirst then
						self.defFirst:setVisible(true)
						self.defFirst:setString(person.firstValue ..":" .. CommonText[1073])
					else
						if self.defFirst then self.defFirst:setVisible(false) end
					end
				end
			else
				break
			end
		end
	end
end

function BattleView:onSkipCallback()
	-- self:removeSelf()

	if NewerMO.tdBeginStateId == 50 then
		Statistics.postPoint(ST_P_34)
	end

	self:pop()

	if CombatMO.curChoseBattleType_ == COMBAT_TYPE_BOSS then -- 世界BOSS
		local BossBalanceDialog = require("app.dialog.BossBalanceDialog")
		BossBalanceDialog.new():push()
	else
		if CombatMO.curChoseBattleType_ ~= COMBAT_TYPE_REPLAY then
			local BattleBalanceView = require("app.view.BattleBalanceView")
			BattleBalanceView.new():push()
		end
	end
end

function BattleView:showAtkHero()
	if BattleMO.atkFormat_.commander and BattleMO.atkFormat_.commander > 0 then -- 进攻方有武将
		local hero = HeroMO.queryHero(BattleMO.atkFormat_.commander)

		local bg = display.newSprite(IMAGE_COMMON .. "info_bg_63.png"):addTo(self:getBg(), 10)
		bg:setPosition(-bg:getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 150)

		local itemView = UiUtil.createItemView(ITEM_KIND_HERO, BattleMO.atkFormat_.commander):addTo(bg)
		itemView:setScale(0.6)
		itemView:setPosition(itemView:getBoundingBox().size.width / 2, itemView:getBoundingBox().size.height / 2)

		if hero then
			-- 名称
			local name = ui.newTTFLabel({text = hero.heroName, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 82, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			name:setAnchorPoint(cc.p(0, 0.5))

			-- 等级
			local level = ui.newTTFLabel({text = "LV." .. hero.level, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):rightTo(name, 20)
			-- level:setAnchorPoint(cc.p(0, 0.5))

			if hero.tankCount > 0 then  -- 带兵
				local label = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 45, align = ui.TEXT_ALIGN_CENTER}):alignTo(level, 90)
				local count = ui.newTTFLabel({text = "+" .. hero.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
				count:setAnchorPoint(cc.p(0, 0.5))
			end

			local heroAttr = json.decode(hero.attr)
			for index = 1,#heroAttr do
				local tanksAddition = heroAttr[index]
				local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
				local x, y = 180 + math.floor((index-1)/2)*140,55 - (index-1)%2*30

				local label = ui.newTTFLabel({text = attributeData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = x, y = y, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
				label:setAnchorPoint(cc.p(0, 0.5))
				local value = ui.newTTFLabel({text = "+" .. attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
				value:setAnchorPoint(cc.p(0, 0.5))
			end
		end

		bg:runAction(transition.sequence({cc.MoveTo:create(0.3, cc.p(self:getBg():getContentSize().width / 2, bg:getPositionY())),
			cc.CallFuncN:create(function(sender)  -- 火焰动画
					armature_add(IMAGE_ANIMATION .. "battle/hero_enter_fire.pvr.ccz", IMAGE_ANIMATION .. "battle/hero_enter_fire.plist", IMAGE_ANIMATION .. "battle/hero_enter_fire.xml")
					local armture = armature_create("hero_enter_fire", 470, bg:getContentSize().height - 20):addTo(bg, -1)
					armture:setScaleX(-1)
					armture:getAnimation():playWithIndex(0)
				end),
			cc.DelayTime:create(1),
			cc.CallFuncN:create(function(sender) sender:removeSelf() end)}))
	end

	if table.isexist(BattleMO.atkFormat_, "tacticsKeyId") then
		--检测战术
		local canShow = true
		local format = clone(BattleMO.atkFormat_)
		local tactics = {}
		if table.isexist(BattleMO.atkFormat_, "tactics") then
			tactics = PbProtocol.decodeArray(BattleMO.atkFormat_["tactics"])
		else
			for index = 1,#format.tacticsKeyId do 
				if format.tacticsKeyId[index] > 0 then
					local tactic = TacticsMO.getTacticByKeyId(format.tacticsKeyId[index])
					if tactic then
						tactics[#tactics + 1] = {v1 = tactic.tacticsId, v2 = tactic.lv}
					end
				end
			end

			format.tacticsKeyId = TacticsMO.isTacticCanUse(format)
			local num = 0
			for index=1,#format.tacticsKeyId do
				if format.tacticsKeyId[index] > 0 then
					num = num + 1
				end
			end
			if num <= 0 then
				canShow = false
			end
		end
		
		local bg = display.newSprite("image/tactics/attr_atk_bg.png"):addTo(self:getBg(), 11)
		local isTacticSuit = TacticsMO.isFormationTacticSuit(tactics,true) -- 战术类型
		local quality, tankType = TacticsMO.isFormationArmsSuit(tactics, true)  --兵种类型

		if isTacticSuit then
			local effItem = display.newSprite("image/tactics/tactics_"..isTacticSuit..".png"):addTo(bg)
			effItem:setScale(0.7)
			effItem:setPosition(effItem:width() / 2 + 20, bg:height() / 2)

			if tankType then
				local tankItem = display.newSprite("image/tactics/tank_type_"..tankType..".png"):rightTo(effItem)
			end
		end
		local tacticAttr = TacticsMO.getFormationTacticAttr(tactics)

		local col = math.max(math.ceil(#tacticAttr / 3), 3)
		for index = 1,#tacticAttr do
			local tanksAddition = tacticAttr[index]
			local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
			local x, y
			if index <= col then
				x = 179 + (index-1)*140
			    y = bg:getContentSize().height - 20
			 else
			 	x = 179 + (index-col - 1)*140
			    y = bg:getContentSize().height - 50
			 end

			local label = ui.newTTFLabel({text = attributeData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = x, y = y, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setAnchorPoint(cc.p(0, 0.5))
			local value = ui.newTTFLabel({text = "+" .. attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end

		bg:setPosition(-bg:getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 232)
		bg:runAction(transition.sequence({cc.MoveTo:create(0.3, cc.p(self:getBg():getContentSize().width / 2, bg:getPositionY())),
			cc.DelayTime:create(1),
			cc.CallFuncN:create(function(sender) sender:removeSelf() end)}))
	end
end

function BattleView:showDefHero()
	if BattleMO.defFormat_.commander and BattleMO.defFormat_.commander > 0 then -- 防守方有武将
		local hero = HeroMO.queryHero(BattleMO.defFormat_.commander)

		local bg = display.newSprite(IMAGE_COMMON .. "info_bg_64.png"):addTo(self:getBg(), 10)
		bg:setPosition(self:getBg():getContentSize().width + bg:getContentSize().width / 2, self:getBg():getContentSize().height / 2 + 150)

		local itemView = UiUtil.createItemView(ITEM_KIND_HERO, BattleMO.defFormat_.commander):addTo(bg)
		itemView:setScale(0.6)
		itemView:setPosition(self:getBg():getContentSize().width - itemView:getBoundingBox().size.width / 2, itemView:getBoundingBox().size.height / 2)

		if hero then
			-- 名称
			local name = ui.newTTFLabel({text = hero.heroName, font = G_FONT, size = FONT_SIZE_SMALL, x = 80, y = 82, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			name:setAnchorPoint(cc.p(0, 0.5))

			-- 等级
			local level = ui.newTTFLabel({text = "LV." .. hero.level, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):rightTo(name, 20)
			-- level:setAnchorPoint(cc.p(0, 0.5))

			if hero.tankCount > 0 then  -- 带兵
				local label = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 80, y = 45, align = ui.TEXT_ALIGN_CENTER}):alignTo(level, 90)
				label:setAnchorPoint(cc.p(0, 0.5))

				local count = ui.newTTFLabel({text = "+" .. hero.tankCount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
				count:setAnchorPoint(cc.p(0, 0.5))
			end

			local heroAttr = json.decode(hero.attr)
			for index = 1,#heroAttr do
				local tanksAddition = heroAttr[index]
				local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
				local x, y = 122 + math.floor((index-1)/2)*130,55 - (index-1)%2*30

				local label = ui.newTTFLabel({text = attributeData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = x, y = y, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
				label:setAnchorPoint(cc.p(0, 0.5))
				local value = ui.newTTFLabel({text = "+" .. attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
				value:setAnchorPoint(cc.p(0, 0.5))
			end
		end

		bg:runAction(transition.sequence({cc.MoveTo:create(0.3, cc.p(self:getBg():getContentSize().width / 2, bg:getPositionY())),
			cc.CallFuncN:create(function(sender)  -- 火焰动画
					armature_add(IMAGE_ANIMATION .. "battle/hero_enter_fire.pvr.ccz", IMAGE_ANIMATION .. "battle/hero_enter_fire.plist", IMAGE_ANIMATION .. "battle/hero_enter_fire.xml")
					local armture = armature_create("hero_enter_fire", 170, 0):addTo(bg, -1)
					-- local armture = armature_create("hero_enter_fire", 100, bg:getContentSize().height - 20):addTo(bg, -1)
					armture:setScaleY(-1)
					armture:getAnimation():playWithIndex(0)
				end),
			cc.DelayTime:create(1),
			cc.CallFuncN:create(function(sender) sender:removeSelf() end)}))
	end

	if table.isexist(BattleMO.defFormat_, "tactics") then
		local tactics = PbProtocol.decodeArray(BattleMO.defFormat_["tactics"])

		local bg = display.newSprite("image/tactics/attr_def_bg.png"):addTo(self:getBg(), 11)
		bg:setPosition(self:getBg():getContentSize().width + bg:getContentSize().width / 2, self:getBg():getContentSize().height / 2 + 225)
		local isTacticSuit = TacticsMO.isFormationTacticSuit(tactics,true) -- 战术类型
		local quality, tankType = TacticsMO.isFormationArmsSuit(tactics, true)  --兵种类型

		if isTacticSuit then
			local effItem = display.newSprite("image/tactics/tactics_"..isTacticSuit..".png"):addTo(bg)
			effItem:setScale(0.7)
			effItem:setPosition(bg:width() -  effItem:width() / 2 - 20, bg:height() / 2)

			if tankType then
				local tankItem = display.newSprite("image/tactics/tank_type_"..tankType..".png"):leftTo(effItem)
			end
		end
		local tacticAttr = TacticsMO.getFormationTacticAttr(tactics)

		local col = math.max(math.ceil(#tacticAttr / 3), 3)
		for index = 1,#tacticAttr do
			local tanksAddition = tacticAttr[index]
			local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
			local x, y
			if index <= col then
				x = 121 + (index-1)*140
			    y = bg:getContentSize().height - 50
			 else
			 	x = 121 + (index-col - 1)*140
			    y = bg:getContentSize().height - 20
			 end

			local label = ui.newTTFLabel({text = attributeData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = x, y = y, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setAnchorPoint(cc.p(0, 0.5))
			local value = ui.newTTFLabel({text = "+" .. attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end

		bg:runAction(transition.sequence({cc.MoveTo:create(0.3, cc.p(self:getBg():getContentSize().width / 2, bg:getPositionY())),
			cc.DelayTime:create(1),
			cc.CallFuncN:create(function(sender) sender:removeSelf() end)}))
	end
end

function BattleView:showAtkWeapon()
	if UserMO.level_ < UserMO.querySystemId(48) then return end
	if not UserMO.queryFuncOpen(UFP_WARWEAPON) then return end
	local weaponID = BattleMO.getWarWeaponId(1)
	if weaponID > 0 then
		local tid = math.floor(weaponID/100)

		local weapon = display.newSprite(IMAGE_COMMON .. "weapon/battle_ws_" .. weaponID .. ".png"):addTo(self:getBg(), 10)
		weapon:setPosition(self:getBg():getContentSize().width *0.5, self:getBg():getContentSize().height * 0.2 )
		weapon:runAction(transition.sequence({ cc.ScaleTo:create(0.2,1)}))
		weapon:setScale(0.1)

		local weaponName = display.newSprite(IMAGE_COMMON .. "weapon/secret_name_" .. tid .. ".png"):addTo(weapon,1)
		weaponName:setPosition(weapon:width() * 0.5 , -weaponName:height() * 0.6 )

		armature_add(IMAGE_ANIMATION .. "effect/mmwq_zd_".. tid .. ".pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_zd_".. tid .. ".plist", IMAGE_ANIMATION .. "effect/mmwq_zd_".. tid .. ".xml")
		local animation = armature_create("mmwq_zd_" .. tid, weapon:width() * 0.5, weapon:height() * 0.5,function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					weapon:removeSelf()
				end
			end):addTo(weapon,2)
		animation:getAnimation():playWithIndex(0)
	end
end

function BattleView:showDefWeapon()
	if UserMO.level_ < UserMO.querySystemId(48) then return end
	if not UserMO.queryFuncOpen(UFP_WARWEAPON) then return end
	local weaponID = BattleMO.getWarWeaponId(2)
	if weaponID > 0 then
		local tid = math.floor(weaponID/100)

		local weapon = display.newSprite(IMAGE_COMMON .. "weapon/battle_ws_" .. weaponID .. ".png"):addTo(self:getBg(), 10)
		weapon:setPosition(self:getBg():getContentSize().width *0.5, self:getBg():getContentSize().height * 0.8 )
		weapon:runAction(transition.sequence({cc.ScaleTo:create(0.2,1)}))
		weapon:setScale(0.1)

		local weaponName = display.newSprite(IMAGE_COMMON .. "weapon/secret_name_" .. tid .. ".png"):addTo(weapon,1)
		weaponName:setPosition(weapon:width() * 0.5 , -weaponName:height() * 0.6 )

		armature_add(IMAGE_ANIMATION .. "effect/mmwq_zd_".. tid .. ".pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_zd_".. tid .. ".plist", IMAGE_ANIMATION .. "effect/mmwq_zd_".. tid .. ".xml")
		local animation = armature_create("mmwq_zd_" .. tid, weapon:width() * 0.5, weapon:height() * 0.5,function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					weapon:removeSelf()
				end
			end):addTo(weapon,2)
		animation:getAnimation():playWithIndex(0)
	end
end

function BattleView:onEnterEnd()
	BattleView.super.onEnterEnd(self)
	gprint("[BattleView] onEnterEnd ...")
	-- 承载所有的战斗Entity的Node
	self.fightNode_ = display.newNode():addTo(self:getBg(), 3)
	-- 战斗的显示向下移60px
	self.fightNode_:setPosition(self:getBg():getContentSize().width / 2, (self:getBg():getContentSize().height - 30) / 2)

	-- 创建战斗数据
	require("app.fight.EntityFactory")
	EntityFactory.init(self.fightNode_)

	if CombatMO.curChoseBattleType_ == COMBAT_TYPE_BOSS then
		BattleMO.defSeveralForOne_ = true
		-- BattleMO.defBossData_ = {}
		-- BattleMO.defBossData_.which = ActivityCenterMO.boss_.which
	else
		BattleMO.defSeveralForOne_ = false
	end

	BattleBO.createFormatEntity(BattleMO.atkFormat_, BattleMO.defFormat_)

	BattleMO.setSpeed(1)

	self:showAtkHero()
	self:showDefHero()
	self:showAtkWeapon()
	self:showDefWeapon()
	-- tanke入场
	BattleBO.tankEnter()
end

-- 战斗结束
function BattleView:onFightEnd()
	gprint("[BattleView] onFightEnd ...")
	self:runAction(transition.sequence({cc.DelayTime:create(2), cc.CallFunc:create(function()
			self:pop(function()
					if CombatMO.curChoseBattleType_ == COMBAT_TYPE_BOSS then -- 世界BOSS
						local BossBalanceDialog = require("app.dialog.BossBalanceDialog")
						BossBalanceDialog.new():push()
					else
						if CombatMO.curChoseBattleType_ ~= COMBAT_TYPE_REPLAY then
							local BattleBalanceView = require("app.view.BattleBalanceView")
							BattleBalanceView.new():push()
						end
					end
				end)
		end)}))
end

-- 继续战斗
function BattleView:onFightNext(event)
	self:showRecord()
	local camp = event.obj.camp
	if not camp or camp == BATTLE_FOR_ATTACK then
		self:showAtkHero()
		self:showAtkWeapon()
	end

	if not camp or camp == BATTLE_FOR_DEFEND then
		self:showDefHero()
		self:showDefWeapon()
	end
end

function BattleView:onExit()
	BattleView.super.onExit(self)
	
	gprint("[BattleView] onExit ...")

	BattleBO.fightOver()

	ManagerSound.stopMusic()
	
	if self.m_overHandler then
		Notify.unregister(self.m_overHandler)
		self.m_overHandler = nil
	end
	if self.m_nextHandler then
		Notify.unregister(self.m_nextHandler)
		self.m_nextHandler = nil
	end
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_zd_1.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_zd_1.plist", IMAGE_ANIMATION .. "effect/mmwq_zd_1.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_zd_0.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_zd_0.plist", IMAGE_ANIMATION .. "effect/mmwq_zd_0.xml")
		
	armature_remove(IMAGE_ANIMATION .. "battle/hero_enter_fire.pvr.ccz", IMAGE_ANIMATION .. "battle/hero_enter_fire.plist", IMAGE_ANIMATION .. "battle/hero_enter_fire.xml")
	armature_remove(IMAGE_ANIMATION .. "battle/boss_jg_output.pvr.ccz", IMAGE_ANIMATION .. "battle/boss_jg_output.plist", IMAGE_ANIMATION .. "battle/boss_jg_output.xml")
	FightEffect.onExit()
end

function BattleView:playWarning( callback )
	-- body
	ManagerSound.playSound("warning")

	armature_add(IMAGE_ANIMATION .. "battle/boss_jg_output.pvr.ccz", IMAGE_ANIMATION .. "battle/boss_jg_output.plist", IMAGE_ANIMATION .. "battle/boss_jg_output.xml")
	local pos = cc.p(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2)
	local animation = armature_create("boss_jg_output", pos.x, pos.y, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()

				if callback then
					callback()
				end
			end
		end):addTo(self:getBg(), 10)

	animation:getAnimation():playWithIndex(0)
end

return BattleView
