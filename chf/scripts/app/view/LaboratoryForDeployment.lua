--
--
-- 兵种调配所
-- MYS
--


-- 计算平均位置 以中心点为准
local function CalculateX( all, index, width, dexScaleOfWidth)
	-- body
	local c = all + 1
	local q = c / 2
	local sw = width * dexScaleOfWidth
	local w = q * sw
	return index * sw - w
end

local LaboratoryForDeployment = class("LaboratoryForDeployment",function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node 
end)

function LaboratoryForDeployment:ctor(size)
	self:setContentSize(size)
	self.m_touchNodeEventReged = false
end

function LaboratoryForDeployment:onEnter()

	armature_add(IMAGE_ANIMATION .. "effect/nengliangcao.pvr.ccz", IMAGE_ANIMATION .. "effect/nengliangcao.plist", IMAGE_ANIMATION .. "effect/nengliangcao.xml")
	
	-- CensusContent
	local censusNode = display.newSprite(IMAGE_COMMON .. "info_bg_128.png"):addTo(self, 3)
	censusNode:setAnchorPoint(cc.p(0.5,1))
	censusNode:setPosition(self:width() * 0.5,self:height() + 2)
	self.m_CensusNode = censusNode

	-- drawAction
	local rect = cc.rect(0,0,self:width() + 20 , self:height() + 35)
	local bgRect = display.newClippingRegionNode(rect):addTo(self, 1)
	bgRect:setAnchorPoint(cc.p(0.5,1))
	bgRect:setPosition(self:width() * 0.5,self:height() - 5)
	bgRect:drawBoundingBox()
	self.m_bg = bgRect

	-- 
	local enterBg = display.newSprite(IMAGE_COMMON .. "laboratory/deploymentBg2.png"):addTo(self, 5)
	enterBg:setAnchorPoint(cc.p(0.5, 1))
	enterBg:setPosition( self:width() * 0.5, self:height() - 5 )
	enterBg:setVisible(false)
	self.m_enterBg = enterBg

	-- 是否可点击动画
	self.m_touchAction = true

	-- 是否可点击穿过
	self.m_TouchCheck = true

	self.m_touchNodeEventReged = false

	-- 顶部总揽信息
	self:CensusContent()

	-- 按钮
	self:EnterContent(enterBg, cc.p(enterBg:width() * 0.5 - 5, enterBg:height() * 0.65), cc.p(10,5))

	-- 动画
	self:drawAction()

	self.labScienceListener = Notify.register("LOCAL_LABORATORY_SCIENCE_EVENT", handler(self, self.updateSciencePre))
end

function LaboratoryForDeployment:CensusContent()

	local function helpCallback(tar, sender)
		if not self.m_TouchCheck then return end
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.LaboratoryDeploymentHelper):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal2.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
	local helpBtn = MenuButton.new(normal, selected, nil, helpCallback):addTo(self.m_CensusNode, 5)
	helpBtn:setPosition(self.m_CensusNode:width() - helpBtn:width() * 0.5 - 15 , self.m_CensusNode:height() * 0.5 - helpBtn:height() * 0.5 + 10)


	local titlename = ui.newTTFLabel({text = CommonText[1773], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_CensusNode, 2)
	titlename:setPosition(self.m_CensusNode:width() * 0.5, self.m_CensusNode:height() - 30)

	local prelb = ui.newTTFLabel({text = CommonText[10015] .. "：", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_CensusNode, 2)
	prelb:setPosition( 75 + prelb:width() * 0.5, self.m_CensusNode:height() * 0.5 - 10 )
	
	-- percent
	local percentBg = display.newSprite(IMAGE_COMMON .. "bar_17_bg.jpg"):addTo(self.m_CensusNode, 4)
	percentBg:setPosition(self.m_CensusNode:width() / 2 + 10, prelb:y() )

	local percentSp = display.newSprite(IMAGE_COMMON .. "bar_17.jpg"):addTo(percentBg)
	percentSp:setAnchorPoint(cc.p(0,0.5))
	percentSp:setPosition(0,percentBg:height() * 0.5 )
	percentSp:setScaleX(0)
	self.m_percentSp = percentSp

	local percentPoint = display.newSprite(IMAGE_COMMON .. "img_point_2.png"):addTo(percentBg)
	percentPoint:setScale(0.75)
	percentPoint:setAnchorPoint(cc.p(0.5,0))
	percentPoint:setPosition(percentSp:width() * percentSp:getScaleX(), percentBg:height())
	self.m_percentPoint = percentPoint

	local touchNode = display.newNode():addTo(self.m_CensusNode, 10)
	touchNode:setContentSize(cc.size(self.m_CensusNode:width() * 0.75, self.m_CensusNode:height() * 0.5))
	touchNode:setAnchorPoint(cc.p(0.5,0.5))
	touchNode:setPosition(self.m_CensusNode:width() * 0.5, self.m_CensusNode:height() * 0.25 + 20)
	-- touchNode:drawBoundingBox()
	touchNode.progressID = 0 -- LaboratoryMO.progressID
	self.m_touchNode = touchNode

	local armature = armature_create("nengliangcao", percentBg:getContentSize().width / 2 + 5 , percentBg:getContentSize().height / 2 + 1):addTo(percentBg , 5)
	armature:setScaleX(percentBg:width() / armature:width() * 1.38)
	armature:setScaleY(1.1)
	self.m_percentSp.armature = armature
	self.m_percentSp.armatureIndex = -1
	self.m_percentSp.armature:getAnimation():playWithIndex(0)

	
	local startlb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(percentBg)
	startlb:setPosition( 0, - 20 )
	self.m_startlb = startlb

	local endlb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(percentBg)
	endlb:setPosition( percentBg:width() ,  - 20 )
	self.m_endlb = endlb

	local curlb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(percentBg)
	curlb:setPosition( percentSp:width() * percentSp:getScaleX(),  - 20 )
	self.m_curlb = curlb

	self:updateSciencePre()

	self:showAward()
end

function LaboratoryForDeployment:showAward()
	if not self.m_touchNode.awards then return end

	local function showAction()
		if self.m_showbg and not self.m_showbg.ismove then
			self.m_showbg.ismove = true
			self.m_showbg:setVisible(true)
			local spwArray = cc.Array:create()
			spwArray:addObject(cc.FadeIn:create(0.2) )
			spwArray:addObject(cc.MoveTo:create(0.2, cc.p(self:width() * 0.5,self:height() - 200)) )
			self.m_showbg:runAction(transition.sequence({cc.Spawn:create(spwArray),cc.CallFuncN:create(function()
				-- self.m_touchAction = false
				self.m_showbg.ismove = false
			end)}))
		end
	end

	if self.m_touchNodeEventReged == false then
		self.m_touchNode:setTouchEnabled(true)
		self.m_touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT,function (event)
			if event.name == "began" then
				if not self.m_TouchCheck then return end
				if not self:checkLoadAward() then return false end
				ManagerSound.playNormalButtonSound()
				self.m_touchAction = false
				showAction()
				return true
			elseif event.name == "ended" then
				self.m_touchAction = true 
				if self.m_showbg then
					self.m_showbg:setVisible(false)
					self.m_showbg:setPosition(self:width() * 0.5,self:height() - 120)
				end
			end
		end)
		self.m_touchNodeEventReged = true
	end

	if self.m_showbg then
		self.m_showbg:removeSelf()
		self.m_showbg = nil
	end

	local showbg = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_6.png"):addTo(self, 2)
	showbg:setPreferredSize(cc.size(290, 140))
	showbg:setPosition(self:width() * 0.5,self:height() - 120)
	showbg:setVisible(false)
	showbg:setCascadeOpacityEnabled(true)
	showbg:setOpacity(0)
	self.m_showbg = showbg

	local titleName = ui.newTTFLabel({text = CommonText[1774] .. CommonText[360][1], font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 0)}):addTo(showbg)
	titleName:setPosition(showbg:width() * 0.5 ,showbg:height() - 20)

	local all = #self.m_touchNode.awards
	for index = 1 , all do
		local award = self.m_touchNode.awards[index]
		local kind = award[1]
		local id = award[2]
		local count = award[3]
		local item = UiUtil.createItemView(kind, id):addTo(showbg)
		item:setScale(0.7)
		item:setPosition(showbg:width() * 0.5 + CalculateX(all, index, item:width() * item:getScale(), 1.3), showbg:height() * 0.5 )

		local iteminfo = UserMO.getResourceData(kind, id)
		local itemName = ui.newTTFLabel({text = iteminfo.name .. "*" .. UiUtil.strNumSimplify(count), font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(item)
		itemName:setPosition(item:width() * 0.5 , -20)

	end
end

function LaboratoryForDeployment:updateSciencePre()
	local _finallyCount = 0
	for _type = 1, 4 do
		local typeInfos = LaboratoryMO.queryLaboratoryForMilitarye(_type)
		-- local typeDatas = LaboratoryMO.militaryData[_type]
		for k , v in pairs(typeInfos) do
			local skillId = k
			local typeData = LaboratoryMO.militarySkillData[skillId] --typeDatas[skillId]
			local curLv = typeData.lv
			local criMaxLv = #v
			if curLv == criMaxLv then
				_finallyCount = _finallyCount + 1
			end
			-- _finallyCount = _finallyCount + curLv
		end
	end

	-- print("_finallyCount!!!", _finallyCount)
	self.m_touchNode.progressID = LaboratoryMO.progressID

	local progressInfo = LaboratoryMO.queryLaboratoryForProgress(LaboratoryMO.progressID)
	-- print("LaboratoryMO.progressID", LaboratoryMO.progressID)
	if progressInfo then
		local progress = json.decode(progressInfo.progress)
		local starts = progress[1]
		local ends = progress[2]

		if _finallyCount >= starts then -- 如果当前科技比开始段要大
			self.m_touchNode.starts = starts
			self.m_touchNode.ends = ends

			local awards = json.decode(progressInfo.award)
			self.m_touchNode.awards = awards
		else
			-- 如果当前科技比开始要小
			for i = LaboratoryMO.progressID, 1, -1 do
				local tmpProgInfo = LaboratoryMO.queryLaboratoryForProgress(i)
				local progress = json.decode(tmpProgInfo.progress)
				local starts = progress[1]
				local ends = progress[2]
				if _finallyCount >= starts and _finallyCount <= ends then
					self.m_touchNode.starts = starts
					self.m_touchNode.ends = ends
					self.m_touchNode.awards = json.decode(tmpProgInfo.award)
					break
				end
			end
		end
	else
		local progressMaxInfo = LaboratoryMO.queryLaboratoryForProgress(LaboratoryMO.progressID - 1)
		local progress = json.decode(progressMaxInfo.progress)
		local starts = progress[1]
		local ends = progress[2]


		if _finallyCount >= starts then -- 如果当前科技比开始段要大
			self.m_touchNode.starts = starts
			self.m_touchNode.ends = ends
			self.m_touchNode.awards = nil
		else
			-- 如果当前科技比开始断要小
			for i = 4, 1, -1 do
				local tmpProgInfo = LaboratoryMO.queryLaboratoryForProgress(i)
				local progress = json.decode(tmpProgInfo.progress)
				local starts = progress[1]
				local ends = progress[2]
				if _finallyCount >= starts and _finallyCount <= ends then
					self.m_touchNode.starts = starts
					self.m_touchNode.ends = ends
					self.m_touchNode.awards = nil
					break
				end
			end
		end

		if self.m_showbg then
			self.m_showbg:removeSelf()
			self.m_showbg = nil
		end
	end

	self.m_touchNode.finallyCount = _finallyCount
	self.m_touchNode.finallyCount = math.min(self.m_touchNode.finallyCount , self.m_touchNode.ends)

	local percent = 1

	self.m_startlb:setString(tostring(self.m_touchNode.starts) )
	self.m_endlb:setString(tostring(self.m_touchNode.ends) )
	local _curlbstr = ((self.m_touchNode.finallyCount == self.m_touchNode.ends) or (self.m_touchNode.finallyCount == self.m_touchNode.starts)) and "" or self.m_touchNode.finallyCount
	self.m_curlb:setString(tostring(_curlbstr))
	-- if self.m_touchNode.awards then
	percent = (self.m_touchNode.finallyCount - self.m_touchNode.starts) / (self.m_touchNode.ends - self.m_touchNode.starts)
	-- end

	percent = math.min(percent , 1)

	if self.m_percentSp.armature then
		local playindex = percent == 1 and 1 or 0
		if self.m_percentSp.armatureIndex ~= playindex then
			self.m_percentSp.armatureIndex = playindex
			self.m_percentSp.armature:getAnimation():playWithIndex(playindex)
		end
		if not self.m_touchNode.awards then
			self.m_percentSp.armature:removeSelf()
			self.m_percentSp.armature = nil
		end
	end
	
	self.m_percentSp:setScaleX(percent)
	self.m_percentPoint:setPosition(self.m_percentSp:width() * self.m_percentSp:getScaleX(), self.m_percentPoint:y())
	self.m_curlb:setPosition(self.m_percentSp:width() * self.m_percentSp:getScaleX(), self.m_curlb:y() )
end

function LaboratoryForDeployment:EnterContent(parent , ccp, ccpDex, scale, isTouch)
	isTouch = isTouch or false
	ccpDex = ccpDex or cc.p(0,0)
	scale = scale or 1

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_blue.png")
	local btn1 = TouchButton.new(normal, nil, nil, handler(self, self.openDeploymentCallback)):addTo(parent, 5)
	btn1:setAnchorPoint(cc.p(1,0))
	btn1:setScale(scale)
	btn1:setPosition(ccp.x - ccpDex.x, ccp.y + ccpDex.y)
	btn1.type = 1

	local tank1 = display.newSprite("image/tank/tank_103.png"):addTo(btn1)
	tank1:setScale(0.7)
	tank1:setPosition(btn1:width() * 0.5, btn1:height() - 50)

	local name1 = ui.newTTFLabel({text = CommonText[162][1] .. CommonText[1772], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btn1)
	name1:setPosition(btn1:width() * 0.5 , 30)



	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_blue.png")
	local btn2 = TouchButton.new(normal, nil, nil, handler(self, self.openDeploymentCallback)):addTo(parent, 5)
	btn2:setAnchorPoint(cc.p(0,0))
	btn2:setScale(scale)
	btn2:setPosition(ccp.x + ccpDex.x, ccp.y + ccpDex.y)
	btn2.type = 2

	local tank2 = display.newSprite("image/tank/tank_104.png"):addTo(btn2)
	tank2:setScale(0.7)
	tank2:setPosition(btn2:width() * 0.5, btn2:height() - 50)

	local name2 = ui.newTTFLabel({text = CommonText[162][2] .. CommonText[1772], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btn2)
	name2:setPosition(btn2:width() * 0.5 , 30)



	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_blue.png")
	local btn3 = TouchButton.new(normal, nil, nil, handler(self, self.openDeploymentCallback)):addTo(parent, 5)
	btn3:setAnchorPoint(cc.p(1,1))
	btn3:setScale(scale)
	btn3:setPosition(ccp.x - ccpDex.x, ccp.y - ccpDex.y)
	btn3.type = 3

	local tank3 = display.newSprite("image/tank/tank_105.png"):addTo(btn3)
	tank3:setScale(0.7)
	tank3:setPosition(btn3:width() * 0.5, btn3:height() - 50)

	local name3 = ui.newTTFLabel({text = CommonText[162][3] .. CommonText[1772], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btn3)
	name3:setPosition(btn3:width() * 0.5 , 30)



	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_blue.png")
	local btn4 = TouchButton.new(normal, nil, nil, handler(self, self.openDeploymentCallback)):addTo(parent, 5)
	btn4:setAnchorPoint(cc.p(0,1))
	btn4:setScale(scale)
	btn4:setPosition(ccp.x + ccpDex.x, ccp.y - ccpDex.y)
	btn4.type = 4

	local tank4 = display.newSprite("image/tank/tank_106.png"):addTo(btn4)
	tank4:setScale(0.7)
	tank4:setPosition(btn4:width() * 0.5, btn4:height() - 50)

	local name4 = ui.newTTFLabel({text = CommonText[162][4] .. CommonText[1772], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btn4)
	name4:setPosition(btn4:width() * 0.5 , 30)

	-- 可点击
	local function enableTouch()
		btn1:setEnabled(true)
		btn2:setEnabled(true)
		btn3:setEnabled(true)
		btn4:setEnabled(true)
		btn1:setTouchSwallowEnabled(true)
		btn2:setTouchSwallowEnabled(true)
		btn3:setTouchSwallowEnabled(true)
		btn4:setTouchSwallowEnabled(true)
	end

	-- 不可点击
	local function unEnableTouch()
		btn1:setEnabled(false)
		btn2:setEnabled(false)
		btn3:setEnabled(false)
		btn4:setEnabled(false)
		btn1:setTouchSwallowEnabled(false)
		btn2:setTouchSwallowEnabled(false)
		btn3:setTouchSwallowEnabled(false)
		btn4:setTouchSwallowEnabled(false)
	end

	if not isTouch then
		unEnableTouch()
	end

	parent.touchFun = enableTouch
	parent.untouchFun = unEnableTouch
end

function LaboratoryForDeployment:drawAction()
	-- self.m_DrawNode
	 local bg = display.newSprite(IMAGE_COMMON .. "laboratory/deploymentBg1.jpg"):addTo(self.m_bg, 0)
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	bg:setPosition(self.m_bg:width() * 0.5, self.m_bg:height()- bg:height() * 0.5)
	self.m_bg.bg = bg

	local machineBg = display.newSprite(IMAGE_COMMON .. "machine.png"):addTo(bg, 1)
	machineBg:setPosition(bg:width() * 0.5 , bg:height() * 0.5 - 50)

	self:EnterContent(machineBg, cc.p(machineBg:width() * 0.5 - 5, machineBg:height() * 0.7 + 5), cc.p(3,2), 0.3)


	-- 遮罩
	local blacksp = display.newColorLayer(ccc4(0, 0, 0, 255)):addTo(self, 3)
	blacksp:setContentSize(cc.size(self:width() + 20, self:height() + 35))
	blacksp:setPosition(-10,-35)
	blacksp:setOpacity(0)

	self.m_switchAction = true

	local function action2()
		blacksp:runAction(transition.sequence({cc.FadeIn:create(0.7),cc.CallFunc:create(function ()
			blacksp:setOpacity(0)
			blacksp:setZOrder(6)
			-- 
			self.m_enterBg:setVisible(true)
			self.m_enterBg.touchFun()
		end), cc.DelayTime:create(0.7), cc.CallFunc:create(function ()
			
			self.m_touchAction = true
		end)}))
	end

	local function action1()
		local spwArray = cc.Array:create()
		spwArray:addObject( CCEaseExponentialOut:create(cc.ScaleTo:create(1.5,2.5))  )
		spwArray:addObject( transition.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
			action2()
		end)}) )
		bg:runAction(cc.Spawn:create(spwArray))
	end

	local function reaction()
		self.m_enterBg.untouchFun()
		blacksp:runAction(transition.sequence({cc.FadeIn:create(0.3), cc.CallFunc:create(function()
			self.m_enterBg:setVisible(false)
			bg:setScale(1)

		end), cc.FadeOut:create(0.7), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
			blacksp:setOpacity(0)
			blacksp:setZOrder(3)

			self.m_touchAction = true
			self.m_TouchCheck = true
		end)}))
	end

	machineBg:setTouchEnabled(true)
	machineBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			if not self.m_touchAction then return end
			self.m_touchAction = false
			self.m_TouchCheck = false
			if self.m_switchAction then
				action1()
			else
				reaction()
			end
			self.m_switchAction = not self.m_switchAction
		end
	end)
end

function LaboratoryForDeployment:checkLoadAward()
	-- self.m_touchNode.starts = 0
	-- 		self.m_touchNode.ends = 0
	-- 		self.m_touchNode.awards = nil
	-- self.m_touchNode.finallyCount
	if self.m_touchNode.progressID > 4 then
		Toast.show("所有奖励已经领取完毕")
		return true
	end

	if self.m_touchNode.ends == 0 then return false end
	if self.m_touchNode.finallyCount == self.m_touchNode.ends then
		LaboratoryBO.GetFightLabGraduateReward(handler(self, self.getAwardCallback))
		return false
	end
	return true
end

function LaboratoryForDeployment:getAwardCallback()
	self:updateSciencePre()
	self:showAward()
end

function LaboratoryForDeployment:openDeploymentCallback(tar, sender)
	-- body
	local type = sender.type 
	local LaboratoryForScienceDeployment = require("app.view.LaboratoryForScienceDeployment")
	LaboratoryForScienceDeployment.new(type):push()

	self:reset()
end

function LaboratoryForDeployment:reset()
	self.m_TouchCheck = true
	self.m_touchAction = true
	self.m_switchAction = true
	if self.m_enterBg then
		self.m_enterBg:setVisible(false)
		self.m_enterBg.untouchFun()
	end
	self.m_bg.bg:stopAllActions()
	self.m_bg.bg:setScale(1)
end

function LaboratoryForDeployment:onExit()
	if self.labScienceListener then
		Notify.unregister(self.labScienceListener)
		self.labScienceListener = nil
	end

	armature_remove(IMAGE_ANIMATION .. "effect/nengliangcao.pvr.ccz", IMAGE_ANIMATION .. "effect/nengliangcao.plist", IMAGE_ANIMATION .. "effect/nengliangcao.xml")
end

return LaboratoryForDeployment