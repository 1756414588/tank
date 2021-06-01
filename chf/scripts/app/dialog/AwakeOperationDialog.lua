--
-- Author: Your Name
-- Date: 2017-03-06 13:50:10
--
--觉醒操作界面Dialog

local Dialog = require("app.dialog.Dialog")
local AwakeOperationDialog = class("AwakeOperationDialog", Dialog)

-- hero 觉醒将 数据
-- 是否预览 (预览模式下 不显示按钮和选项)
function AwakeOperationDialog:ctor(hero,preview)
	self.skillId = nil
	self.previewDexHeight = 0

	self.hero = hero
	self.preview = preview or false -- 预览
	if self.preview then self.previewDexHeight = 115 end
	AwakeOperationDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860 - self.previewDexHeight)})
end

function AwakeOperationDialog:onEnter()
	-- self.isDo = nil
	AwakeOperationDialog.super.onEnter(self)
	self:setTitle(CommonText[514][5])
	armature_add(IMAGE_ANIMATION .. "hero/fengxingzhe.pvr.ccz", IMAGE_ANIMATION .. "hero/fengxingzhe.plist", IMAGE_ANIMATION .. "hero/fengxingzhe.xml")
	armature_add(IMAGE_ANIMATION .. "hero/youying.pvr.ccz", IMAGE_ANIMATION .. "hero/youying.plist", IMAGE_ANIMATION .. "hero/youying.xml")
	armature_add(IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx2.pvr.ccz", IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx2.plist", IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx2.xml")
	armature_add(IMAGE_ANIMATION .. "hero/diaoge.pvr.ccz", IMAGE_ANIMATION .. "hero/diaoge.plist", IMAGE_ANIMATION .. "hero/diaoge.xml")
	armature_add(IMAGE_ANIMATION .. "hero/anxing.pvr.ccz", IMAGE_ANIMATION .. "hero/anxing.plist", IMAGE_ANIMATION .. "hero/anxing.xml")
	armature_add(IMAGE_ANIMATION .. "hero/leidi.pvr.ccz", IMAGE_ANIMATION .. "hero/leidi.plist", IMAGE_ANIMATION .. "hero/leidi.xml")
	-- armature_add(IMAGE_ANIMATION .. "hero/juexing_xiaojineng.pvr.ccz", IMAGE_ANIMATION .. "hero/juexing_xiaojineng.plist", IMAGE_ANIMATION .. "hero/juexing_xiaojineng.xml")
	armature_add(IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx1.pvr.ccz", IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx1.plist", IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx1.xml")
	armature_add(IMAGE_ANIMATION .. "hero/aogusite.pvr.ccz", IMAGE_ANIMATION .. "hero/aogusite.plist", IMAGE_ANIMATION .. "hero/aogusite.xml")

	local hero
	local state = HeroBO.getHeroStateById(self.hero.heroId)
	if state == 1 then
		hero = HeroMO.queryHero(self.hero.heroId)
	else
		local heroInfo = HeroMO.queryHero(self.hero.heroId)
		hero = HeroMO.queryHero(heroInfo.awakenHeroId)
	end


	local contentNode = self:getBg()
	--觉醒方式按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_awake_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_awake_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local taskBtn = MenuButton.new(normal, selected, disabled, handler(self, self.startAwakeHandler)):addTo(contentNode)
	taskBtn:setPosition(contentNode:getContentSize().width / 2 + 70,60)
	taskBtn:setLabel("")
	taskBtn:dispatchTouchEvent(false)
	taskBtn.hero = self.hero
	self.taskBtn = taskBtn

	--将领分解按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local heroLotteryBtn = MenuButton.new(normal, selected, disabled, handler(self, self.lotteryHandler)):addTo(contentNode)
	heroLotteryBtn:setPosition(contentNode:getContentSize().width / 2 - 70,60)
	heroLotteryBtn:setLabel(CommonText[514][2])
	heroLotteryBtn:setEnabled(false)
	--将领升级按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local heroDecomposeBtn = MenuButton.new(normal, selected, disabled, handler(self,self.levelUpHandler)):addTo(contentNode)
	heroDecomposeBtn:setPosition(contentNode:getContentSize().width / 2 - 210,60)
	heroDecomposeBtn:setLabel(CommonText[514][1])
	heroDecomposeBtn:setEnabled(hero.canup > 0 and ArmyBO.getHeroFightNum(self.hero.keyId) <= 0) -- not islocked and

	--将领分享按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	self.heroImproveBtn = MenuButton.new(normal, selected, nil, handler(self, self.shareHandler)):addTo(contentNode)
	self.heroImproveBtn:setPosition(contentNode:getContentSize().width / 2 + 210,60)
	self.heroImproveBtn:setLabel(CommonText[514][4])
	self.heroImproveBtn.hero = self.hero

	--选择觉醒方式
	self.checkBox = {}
	self.cost1 = json.decode(hero.cost1)
	self.cost2 = json.decode(hero.cost2)
	--药水
	local potion = UiUtil.createItemView(self.cost1[1],self.cost1[2]):addTo(contentNode)
	potion:setScale(0.5)
	potion:setPosition(100,124)
	-- 药水数量
	self.potionNum = ui.newTTFLabel({text = tostring(self.cost1[3]), font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = potion:getPositionX() + 30, y = potion:getPositionY(), align = ui.TEXT_ALIGN_LEFT}):addTo(contentNode)
	self.potionNum:setColor(UserMO.getResource(self.cost1[1],self.cost1[2]) >= self.cost1[3] and COLOR[1] or COLOR[6])

	local function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		if not isChecked then
			sender:setChecked(true)
			return 
		end

		for k,v in ipairs(self.checkBox) do
			if v:getTag() ~= sender:getTag() then
				v:setChecked(false)
			end
			self.taskBtn:setLabel(sender:getTag() == 1 and CommonText[978][1] or CommonText[978][2])
			self.taskBtn.tag = sender:getTag()
		end
		HeroMO.oldCheckIndex = sender:getTag()
	end
	--药水checkbox
	local checkBox1 = CheckBox.new(nil, nil, onCheckedChanged):addTo(contentNode,0,1)
	checkBox1:setPosition(self.potionNum:getPositionX() + self.potionNum:getContentSize().width / 2 + 30,self.potionNum:getPositionY())
	table.insert(self.checkBox, checkBox1)

	--金币
	local coin = UiUtil.createItemView(self.cost2[1],self.cost2[2]):addTo(contentNode)
	coin:setScale(0.5)
	coin:setPosition(contentNode:getContentSize().width / 2 + 60,potion:getPositionY())
	--金币数量
	self.coinNum = ui.newTTFLabel({text = tostring(self.cost2[3]), font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = coin:getPositionX() + 30, y = coin:getPositionY(), align = ui.TEXT_ALIGN_LEFT}):addTo(contentNode)
	self.coinNum:setColor(UserMO.getResource(ITEM_KIND_COIN) >= self.cost2[3] and COLOR[1] or COLOR[6])
	self.coinCost = tostring(self.cost2[3])
	--金币checkbox
	local checkBox2 = CheckBox.new(nil, nil, onCheckedChanged):addTo(contentNode,0,2)
	checkBox2:setPosition(self.coinNum:getPositionX() + self.coinNum:getContentSize().width / 2 + 30,self.coinNum:getPositionY())
	table.insert(self.checkBox, checkBox2)

	local index = HeroMO.oldCheckIndex or 1
	for k,v in ipairs(self.checkBox) do
		if v:getTag() == index then
			v:setChecked(true)
			onCheckedChanged(v,true)
		end
	end
	self:showUI()

	-- 预览
	if self.preview then
		-- taskBtn:setEnabled(false)
		-- heroLotteryBtn:setEnabled(false)
		-- heroDecomposeBtn:setEnabled(false)
		-- self.heroImproveBtn:setEnabled(false)
		taskBtn:setVisible(false)
		heroLotteryBtn:setVisible(false)
		heroDecomposeBtn:setVisible(false)
		self.heroImproveBtn:setVisible(false)
		potion:setVisible(false)
		self.potionNum:setVisible(false)
		checkBox1:setVisible(false)
		coin:setVisible(false)
		self.coinNum:setVisible(false)
		checkBox2:setVisible(false)
	end
end

function AwakeOperationDialog:startAwakeHandler(tag,sender)
	-- if self.isDo then return end
	ManagerSound.playNormalButtonSound()
	local count = UserMO.getResource(ITEM_KIND_COIN)
	local need = self.cost2[3]
	if self.taskBtn.tag == 2 and need > count then
		require("app.dialog.CoinTipDialog").new():push()
		return
	end

	local hero = self.hero
	local function goToAwake()
		-- self.isDo = true
		--播放动画
		local function playAnimation(heroId, skillId, skillLv)
			--背景层
			local touchLayer = display.newColorLayer(ccc4(0, 0, 0, 180)):addTo(self:getBg(),999)
			touchLayer:setContentSize(cc.size(display.width, display.height))
			touchLayer:setPosition(0, 0)

			touchLayer:setTouchEnabled(true)
			touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				return true
			end)			
			--数据信息
			local heroDB = HeroMO.queryHero(heroId)
			local awakeSkill = json.decode(heroDB.awakenSkillArr)

			for index =1,#awakeSkill do
				if skillId == awakeSkill[index] then
					local skillIcon = skillLv
					if index > 1 and skillIcon > 0 then
						skillIcon = 1
					end

					local awakeBtn = self.taskBtn
					--粒子效果
					local wPos = awakeBtn:convertToWorldSpace(cc.p(awakeBtn:getContentSize().width / 2,awakeBtn:getContentSize().height / 2))
					local lPos = touchLayer:convertToNodeSpace(wPos)
					local path = "animation/effect/miyaojuexing_tx1.plist"
					local rold = "animation/effect/jxcg.plist"
					local boom = cc.ParticleSystemQuad:create(rold)
					local skillIndex = index
					local function doEndShow()
						local skillIcon = self.awakeSkillIcons_[skillIndex]
						local wPos = skillIcon:convertToWorldSpace(cc.p(skillIcon:getContentSize().width / 2,skillIcon:getContentSize().height / 2))
						local lPos = touchLayer:convertToNodeSpace(wPos)
					    local particleSys = cc.ParticleSystemQuad:create(path)
					    particleSys:setPosition(cc.p(touchLayer:getContentSize().width / 2, touchLayer:getContentSize().height / 2))
					    particleSys:addTo(touchLayer)
					    particleSys:setScale(2)

					    local config = ccBezierConfig()
					    config.endPosition = lPos
					    config.controlPoint_1 = cc.p(wPos.x, wPos.y - 100)
					    config.controlPoint_2 = cc.p(lPos.x, lPos.y + 300)

					    particleSys:runAction(transition.sequence({cc.EaseSineIn:create(cc.BezierTo:create(0.9, config)), cc.CallFunc:create(function (sender)
					    	particleSys:removeSelf()
			    			local armature = armature_create("juexing_xiaojineng_tx2")
			    			armature:setPosition(lPos)
			    			armature:addTo(touchLayer,999)			
			    			armature:getAnimation():playWithIndex(0)
			    			armature:runAction(transition.sequence({cc.DelayTime:create(0),cc.CallFunc:create(function () 
			    					self:showUI()
			    				end),cc.CallFunc:create(function () 
			    					touchLayer:runAction(transition.sequence({cc.FadeOut:create(0.45),cc.DelayTime:create(1),cc.CallFunc:create(function() 
			    						touchLayer:removeSelf()
			    						-- self.isDo = nil
			    					end)}))
			    				end)}))
					    end)}))
					end

				    local particleSys = cc.ParticleSystemQuad:create(path)
				    particleSys:setPosition(lPos)
				    particleSys:setScale(1.5)
				    particleSys:addTo(touchLayer)

				    local toPos = cc.p(touchLayer:getContentSize().width / 2, touchLayer:getContentSize().height / 2)
				    local config = ccBezierConfig()
				    config.endPosition = toPos
				    config.controlPoint_1 = cc.p(wPos.x - 40, wPos.y + 80)
				    config.controlPoint_2 = cc.p(wPos.x, wPos.y + 120)
				    config.controlPoint_3 = cc.p(toPos.x, toPos.y - 50)

				    local moveT = cc.MoveTo:create(0.3, cc.p(touchLayer:getContentSize().width / 2, touchLayer:getContentSize().height / 2))
				   	particleSys:runAction(transition.sequence({cc.EaseSineIn:create(cc.BezierTo:create(0.9, config)), cc.CallFunc:create(function(sender) 
				   		particleSys:removeSelf()
		    			local armature = armature_create("juexing_xiaojineng_tx1", touchLayer:getContentSize().width / 2, touchLayer:getContentSize().height / 2,nil)
		    			armature:getAnimation():playWithIndex(0)
		    			armature:addTo(touchLayer,999)

	    				local awakeSkillItem = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "awake"..awakeSkill[index].."_"..skillIcon}):addTo(touchLayer)
	    				awakeSkillItem:setPosition(touchLayer:getContentSize().width / 2,touchLayer:getContentSize().height / 2)
	    				awakeSkillItem:setScale(0)
	    				awakeSkillItem:runAction(transition.sequence({cc.ScaleTo:create(0.5,1),cc.CallFunc:create(function ()
							boom:setPosition(awakeSkillItem:getPosition())
							boom:addTo(touchLayer)
	    				end),cc.DelayTime:create(1.2),cc.ScaleTo:create(0.3,0), cc.CallFunc:create(function(sender)
	    					awakeSkillItem:removeSelf()
	    					armature:removeSelf()
	    					boom:removeSelf()
	    					doEndShow()
	    					end)}))
				    	end)
				   	}))

				   	break
				end
			end
		end

		HeroBO.goAwake(function (data)
			if data.lvState == 0 then
				UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
				if data.failTimes % 30 == 0 then
					require("app.dialog.AwakeAnimationDialog").new(AWAKE_FALI_TYPE,self.hero):push()
					-- self.isDo = nil
				else
					Toast.show(CommonText[979])
					-- self.isDo = nil
				end
				self:showUI()
			elseif data.lvState > 0 then
				UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
				local awakeDB = HeroBO.getAwakeHeroByKeyId(data.keyId)
				local heroDB = HeroMO.queryHero(awakeDB.heroId)
				local oldHeroId = heroDB.awakenHeroId
				if oldHeroId == 0 then
					oldHeroId = awakeDB.heroId
				end
				local skill = PbProtocol.decodeArray(data.skill)
				local old = {}
				if table.isexist(awakeDB, "skillLv") then
					old = PbProtocol.decodeArray(awakeDB.skillLv)
				end
				local oldhas = {}
				for k,v in ipairs(old) do
					oldhas[v.v1] = v.v2
				end
				local find = nil
				for k,v in ipairs(skill) do
					if not oldhas[v.v1] then
						find = v
						break
					elseif oldhas[v.v1] < v.v2 then
						find = v
						break
					end
				end
				awakeDB.skillLv = data.skill
				awakeDB.skillLvPBInfo = HeroMO.PareSkill(data.skill)
				self.hero = awakeDB
				self.skillId = find.v1
				--使用最新数据
				playAnimation(oldHeroId, find.v1, find.v2)
			end 
		end,self.taskBtn.tag,hero)
	end


	if UserMO.consumeConfirm and self.taskBtn.tag == 2 then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[982], self.coinCost), function() goToAwake() end):push()
	else
		goToAwake()
	end

end

function AwakeOperationDialog:lotteryHandler()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.HeroDecomposeDialog").new(DECOMPOSE_TYPE_HERO,self.hero):push()
end

function AwakeOperationDialog:shareHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ShareDialog").new(SHARE_TYPE_HERO, sender.hero.heroId,sender):push()
end

function AwakeOperationDialog:showUI()

	if not self.m_contentNode then
		self.m_contentNode = display.newNode():addTo(self:getBg(),-1)
		self.m_contentNode:setContentSize(self:getBg():getContentSize())
	end

	self.m_contentNode:removeAllChildren()
	--道具不足标红
	self.potionNum:setColor(UserMO.getResource(self.cost1[1],self.cost1[2]) >= self.cost1[3] and COLOR[1] or COLOR[6])
	self.coinNum:setColor(UserMO.getResource(ITEM_KIND_COIN) >= self.cost2[3] and COLOR[1] or COLOR[6])
	local contentNode = self.m_contentNode

	local isAwake = false

	local heroDB = HeroMO.queryHero(self.hero.heroId)
	local hero
	if heroDB.awakenHeroId == 0 then
		hero = HeroMO.queryHero(self.hero.heroId)
	else
		local heroInfo = HeroMO.queryHero(self.hero.heroId)
		hero = HeroMO.queryHero(heroDB.awakenHeroId)
	end
	local awakeSkill = PbProtocol.decodeArray(self.hero.skillLv)
	local skillInfo = {}
	if awakeSkill then
		for k,v in ipairs (awakeSkill) do
			skillInfo[v.v1] = v.v2
		end
	end
	
	local status = HeroBO.getHeroStateById(self.hero.heroId)
	local awakeSkill = {}
	if status == 1 then
		awakeSkill = json.decode(hero.awakenSkillArr)
	else
		local heroInfo = HeroMO.queryHero(self.hero.heroId)
		local awakeInfo = HeroMO.queryHero(heroInfo.awakenHeroId)
		awakeSkill = json.decode(awakeInfo.awakenSkillArr)
	end
	--bg
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(contentNode, -1)
	btm:setPreferredSize(cc.size(550, 780 - self.previewDexHeight))
	btm:setPosition(contentNode:getContentSize().width / 2, contentNode:getContentSize().height / 2 - 6)
	--infoBg 2
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_awake_"..hero.map..".jpg"):addTo(contentNode, -1)
	infoBg:setPreferredSize(cc.size(515, 332))
	infoBg:setPosition(contentNode:getContentSize().width / 2, contentNode:getContentSize().height - infoBg:getContentSize().height / 2 -70)
	--detail描述
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.heroAwake):push()
		end):addTo(infoBg,999)
		detailBtn:setPosition(infoBg:getContentSize().width - 50, infoBg:height() - 50)
	--根据觉醒状态判断显示效果
	if skillInfo[awakeSkill[1]] and skillInfo[awakeSkill[1]] >= 4 then
		isAwake = true
		-- 头像动画
		local spyAdd = 20 
		if hero.map == "fengxingzhe" then
			spyAdd =  -10
		elseif hero.map == "leidi" or hero.map == "anxing" then
			spyAdd = 0
		elseif hero.map == "aogusite" then
			spyAdd =  -10
		end
		local itemAm = armature_create(hero.map,infoBg:getContentSize().width / 2 + 100,infoBg:getContentSize().height / 2 + spyAdd,nil):addTo(infoBg)
		itemAm:getAnimation():playWithIndex(0)
	else
		local spyAdd = 20 
		if hero.map == "fengxingzhe" then
			spyAdd =  -10
		end
		local diePic = display.newSprite(IMAGE_COMMON .. "info_bg_awake_hui_"..hero.map..".png"):addTo(infoBg)
		diePic:setPosition(infoBg:getContentSize().width / 2 + 100,infoBg:getContentSize().height / 2 + spyAdd)
	end

	if self.skillId and self.skillId == awakeSkill[1] and skillInfo[awakeSkill[1]] == 4 then
		HeroBO.updateMyHeros()
		self.heroImproveBtn.hero = hero
		require("app.dialog.AwakeAnimationDialog").new(AWAKE_SUCCESS_TYPE,hero):push()
	end
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

	--获得将领觉醒状态
	-- local heroState = HeroBO.getHeroStateById(self.hero.heroId)
	if skillInfo[awakeSkill[1]] and skillInfo[awakeSkill[1]] >= 4 then
		--带兵 + XX
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
	else
		local heroInfo = HeroMO.queryHero(self.hero.heroId)
		local awakeInfo = HeroMO.queryHero(heroInfo.awakenHeroId) or heroInfo
		--带兵 + XX
		if heroInfo.tankCount > 0 then
			local additionLab1 = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL,
			 x = 10, y = additionTit:getPositionY() - additionTit:getContentSize().height / 2 - 15, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(additionBg)
			additionLab1:setAnchorPoint(cc.p(0, 0.5))
			local additionValue1 = ui.newTTFLabel({text = "+" .. heroInfo.tankCount, font = G_FONT, size = FONT_SIZE_SMALL,
			 x = additionLab1:getPositionX() + additionLab1:getContentSize().width, y = additionLab1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(additionBg)
			additionValue1:setAnchorPoint(cc.p(0, 0.5))
			--觉醒后加成
			local awakeAdd = ui.newTTFLabel({text = "(+" .. awakeInfo.tankCount - heroInfo.tankCount..")", font = G_FONT, size = FONT_SIZE_SMALL,
			 x = additionValue1:getPositionX() + additionValue1:getContentSize().width, y = additionValue1:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(154,152,153)}):addTo(additionBg)
			awakeAdd:setAnchorPoint(cc.p(0, 0.5))
			awakeAdd:setVisible(awakeInfo.tankCount - heroInfo.tankCount ~= 0)
		end
		-- xx 加成 xx%
		local heroAttr = json.decode(heroInfo.attr)
		local awakeAttr = json.decode(awakeInfo.attr)
		for index = 1,#heroAttr do
			local tanksAddition = heroAttr[index]
			local attributeData = AttributeBO.getAttributeData(tanksAddition[1], tanksAddition[2])
			local additionLab = ui.newTTFLabel({text = attributeData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
						x = 10, y = additionBg:getContentSize().height - 25 - 35 * index, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(additionBg)
			additionLab:setAnchorPoint(cc.p(0, 0.5))
			local additionValue = ui.newTTFLabel({text = "+"..attributeData.strValue, font = G_FONT, size = FONT_SIZE_SMALL,
			 x = additionLab:getPositionX() + additionLab:getContentSize().width, y = additionLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(additionBg)
			additionValue:setAnchorPoint(cc.p(0, 0.5))
			--觉醒后的加成
			local awakeAdtion = awakeAttr[index]
			local awakeAttributeData = AttributeBO.getAttributeData(awakeAdtion[1], awakeAdtion[2] - tanksAddition[2])
			local awakeValue = ui.newTTFLabel({text = "(+"..awakeAttributeData.strValue..")", font = G_FONT, size = FONT_SIZE_SMALL,
			 x = additionValue:getPositionX() + additionValue:getContentSize().width, y = additionValue:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(154,152,153)}):addTo(additionBg)
			awakeValue:setAnchorPoint(cc.p(0, 0.5))
			awakeValue:setVisible(awakeAdtion[2] - tanksAddition[2] > 0)
		end
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
			local name = hero.skillName
			local desc = hero.skillDesc
			if not isAwake and heroDB.awakenHeroId ~= 0 then
				name = heroDB.skillName
				desc = heroDB.skillDesc
			end
			skillDetail = UiUtil.createSkillView(1, nil, {name = name,desc = desc}):addTo(contentNode, -1)
			skillDetail:setPosition(heroSkillItem:getContentSize().width / 2,heroSkillItem:getPositionY() + heroSkillItem:getContentSize().height + 20)
			skillDetail:setAnchorPoint(cc.p(0,0.5))
			return true
		elseif event.name == "ended" then
			skillDetail:removeSelf()
		end
	end)

	--技能名称
	local skillName = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = heroSkillItem:getContentSize().width / 2 + 60, y = heroSkillItem:getPositionY() - heroSkillItem:getContentSize().height /2 - 15, align = ui.TEXT_ALIGN_CENTER}):addTo(contentNode, -1)
	if hero.skillId > 0 then
		skillName:setString(hero.skillName)
	else
		skillName:setString(CommonText[509])
	end

	--第一条分节线
	local lineB = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(contentNode, -1)
	lineB:setPreferredSize(cc.size(500, lineB:getContentSize().height))
	lineB:setPosition(contentNode:getContentSize().width / 2, heroSkillItem:getPositionY() - heroSkillItem:getContentSize().height / 2 - 30)

	--所有技能都达到满级觉醒按钮变灰
	local canAwake = true

	for i=1,#awakeSkill do
		if not skillInfo[awakeSkill[i]] then
			skillInfo[awakeSkill[i]] = 0
		end
		local skillLv = skillInfo[awakeSkill[i]] --获取当前这个技能ID的等级
		local skillNum = HeroMO.queryAwakeSkillLevel(awakeSkill[i]) --获取当前技能ID等级最大值
		if skillLv < skillNum then
			canAwake = false
			break
		end		
	end

	if canAwake or ArmyBO.getHeroFightNum(self.hero.keyId) >= 1 then
		self.taskBtn:setEnabled(false)
	end
	
	self.awakeSkillIcons_ = {}
	local skillName = HeroMO.queryAwakeSkillInfo(awakeSkill[1],skillInfo[awakeSkill[1]])
	--觉醒技能icon
	local awakeSkillItem = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "awake"..awakeSkill[1].."_"..skillInfo[awakeSkill[1]]}):addTo(contentNode)
	awakeSkillItem:setPosition(heroSkillItem:getPositionX(), lineB:getPositionY() - awakeSkillItem:getContentSize().height / 2 - 20)
	awakeSkillItem:setScale(1)
	self.awakeSkillIcons_[#self.awakeSkillIcons_ + 1] = awakeSkillItem
	--如果觉醒ID为主动技能的ID播放动画
	-- if self.skillId and self.skillId == awakeSkill[1] then
	-- 	local shengjiAm = armature_create("juexingjineng_shengji"):addTo(awakeSkillItem)
	-- 	shengjiAm:setPosition(0,awakeSkillItem:getContentSize().height)
	-- 	shengjiAm:getAnimation():playWithIndex(skillInfo[awakeSkill[1]] -1)
	-- end
	-- if self.skillId and skillInfo[awakeSkill[1]] == 4 then
	-- 	require("app.dialog.AwakeAnimationDialog").new(AWAKE_SUCCESS_TYPE,hero):push()
	-- end

	awakeSkillItem:setTouchEnabled(true)
	awakeSkillItem:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			skillDetail = UiUtil.createSkillView(1, nil, {name = skillName.name,desc = skillName.desc}):addTo(contentNode)
			skillDetail:setPosition(awakeSkillItem:getContentSize().width / 2 ,awakeSkillItem:getPositionY() + awakeSkillItem:getContentSize().height + 20)
			skillDetail:setAnchorPoint(cc.p(0,0.5))
			return true
		elseif event.name == "ended" then
			skillDetail:removeSelf()
		end
	end)

	local awakeSkillName = ui.newTTFLabel({text = skillName.name, font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = awakeSkillItem:getPositionX(), y = awakeSkillItem:getPositionY() - awakeSkillItem:getContentSize().height / 2 - 15, align = ui.TEXT_ALIGN_CENTER}):addTo(contentNode)

	--觉醒被动技能 
	for index = 2,#awakeSkill do
		local awakeLv = 0
		if awakeSkill and skillInfo[awakeSkill[index]] then
			if skillInfo[awakeSkill[index]] > 0 then
				awakeLv = 1
			end
		end

		if not skillInfo[awakeSkill[index]] then
			skillInfo[awakeSkill[index]] = 0
		end
		local skillName = HeroMO.queryAwakeSkillInfo(awakeSkill[index],skillInfo[awakeSkill[index]])
	
		local passiveSkillItem = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "awake"..awakeSkill[index].."_"..awakeLv}):addTo(contentNode)
		passiveSkillItem:setScale(0.6)
		passiveSkillItem:setAnchorPoint(cc.p(0.5,0.5))
		passiveSkillItem:setPosition(awakeSkillItem:getPositionX() + awakeSkillItem:getContentSize().width / 2 - 30 + (index-1) *90,awakeSkillItem:getPositionY() - 15)
		--如果觉醒ID为被动技能的ID播放动画
		-- if self.skillId and self.skillId == awakeSkill[index] then
		-- 	local shengjiAm = armature_create("juexing_xiaojineng",awakeSkillItem:getPositionX() + awakeSkillItem:getContentSize().width / 2 - 30 + (index-1) *90,awakeSkillItem:getPositionY() - 15,nil):addTo(contentNode)
		-- 	shengjiAm:setScale(0.8)
		-- 	shengjiAm:getAnimation():playWithIndex(0)
		-- end
		--技能等级--如果技能达到满级。显示为Max
		local skillBg = nil
		local lvLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_RIGHT})
		lvLab:setString(skillInfo[awakeSkill[index]] or "")
		local skillMax = HeroMO.queryAwakeSkillLevel(awakeSkill[index])
		if skillInfo[awakeSkill[index]] >= skillMax then  
			lvLab:setString("Max")
		end
		if lvLab ~= "" then
			skillBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(passiveSkillItem)
			skillBg:setPreferredSize(cc.size(lvLab:getContentSize().width + 10, lvLab:getContentSize().height))
			skillBg:setPosition(passiveSkillItem:getContentSize().width - skillBg:getContentSize().width / 2 - 6, 14)
		end
		lvLab:addTo(skillBg)
		lvLab:setPosition(skillBg:getContentSize().width / 2,skillBg:getContentSize().height / 2)

		--被动技能名称
		local passiveSkillName = ui.newTTFLabel({text = skillName.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = passiveSkillItem:getPositionX(), y = passiveSkillItem:getPositionY() - awakeSkillItem:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(contentNode)

		passiveSkillItem:setTouchEnabled(true)
		passiveSkillItem:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				skillDetail = UiUtil.createSkillView(1, 2, {name = skillName.name,desc = skillName.desc}):addTo(contentNode)
				skillDetail:setPosition(awakeSkillItem:getPositionX() + awakeSkillItem:getContentSize().width / 2,awakeSkillItem:getPositionY() + 80)
				return true
			elseif event.name == "ended" then
				skillDetail:removeSelf()
			end
		end)
		self.awakeSkillIcons_[#self.awakeSkillIcons_ + 1] = passiveSkillItem
	end

	--第二条分节线
	local lineC = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(contentNode, -1)
	lineC:setPreferredSize(cc.size(500, lineC:getContentSize().height))
	lineC:setPosition(contentNode:getContentSize().width / 2, awakeSkillItem:getPositionY() - awakeSkillItem:getContentSize().height / 2 - 30)
end

function AwakeOperationDialog:levelUpHandler()
	ManagerSound.playNormalButtonSound()
	self:pop()
	require("app.dialog.HeroLevelUpDialog").new(self.hero,LEVEL_UP_AWAKE):push()
end

function AwakeOperationDialog:onExit()
	AwakeOperationDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "hero/fengxingzhe.pvr.ccz", IMAGE_ANIMATION .. "hero/fengxingzhe.plist", IMAGE_ANIMATION .. "hero/fengxingzhe.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/youying.pvr.ccz", IMAGE_ANIMATION .. "hero/youying.plist", IMAGE_ANIMATION .. "hero/youying.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx2.pvr.ccz", IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx2.plist", IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx2.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/diaoge.pvr.ccz", IMAGE_ANIMATION .. "hero/diaoge.plist", IMAGE_ANIMATION .. "hero/diaoge.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/anxing.pvr.ccz", IMAGE_ANIMATION .. "hero/anxing.plist", IMAGE_ANIMATION .. "hero/anxing.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/leidi.pvr.ccz", IMAGE_ANIMATION .. "hero/leidi.plist", IMAGE_ANIMATION .. "hero/leidi.xml")
	-- armature_remove(IMAGE_ANIMATION .. "hero/juexing_xiaojineng.pvr.ccz", IMAGE_ANIMATION .. "hero/juexing_xiaojineng.plist", IMAGE_ANIMATION .. "hero/juexing_xiaojineng.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx1.pvr.ccz", IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx1.plist", IMAGE_ANIMATION .. "hero/juexing_xiaojineng_tx1.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/aogusite.pvr.ccz", IMAGE_ANIMATION .. "hero/aogusite.plist", IMAGE_ANIMATION .. "hero/aogusite.xml")

end


return AwakeOperationDialog