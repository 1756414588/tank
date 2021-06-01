
local ArmList = {}

-- 选择性加载动画资源
local function addArmature(name)

	if not ArmList[name] then
		local armName = name
		armature_add(IMAGE_ANIMATION .. "effect/" .. armName .. ".pvr.ccz", IMAGE_ANIMATION .. "effect/" .. armName .. ".plist", IMAGE_ANIMATION .. "effect/" .. armName .. ".xml") -- 1
		ArmList[name] = true
	end
end

-- 计算平均位置 以中心点为准
local function CalculateX( all, index, width, dexScaleOfWidth)
	-- body
	local c = all + 1
	local q = c / 2
	local sw = width * dexScaleOfWidth
	local w = q * sw
	return index * sw - w
end


--------------------------------------------------------------
--							意外奖励						--
--------------------------------------------------------------
local AccidentReward = class("AccidentReward", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function AccidentReward:ctor(parent,activityID,inParam,okcallback)
	self.m_parentNode = parent
	self.m_activityID = activityID
	self.m_inParam = inParam
	self.m_okcallback = okcallback
end

function AccidentReward:onEnter()
	self.m_parentNode.m_AccidentReward = self

	self.isTouch = true

	local state = ActivityCenterMO.UseActLocalRecord(self.m_activityID, self.m_inParam)
	-- dump(state,"AccidentReward.state")
	-- state = {istate = 0, formx = 0, formy = 0, tox = 0, toy = 0}
	-- self.m_inParam
	-- istate = 0 -- 不处理
	-- istate = 1 -- 开始获得 飘
	-- istate = 2 -- 落地
	-- 状态 0 不处理
	if state.istate == 0 then
		self:removeSelf()
		return
	end
	-- self:addTo(self.m_parentNode, 999)

	self:setContentSize(display.width, display.height)

	nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, nil, nil, true)
	self:setTouchCaptureEnabled(true)
 	
	

	local parachuteNode = display.newNode():addTo(self, 1)
	parachuteNode:setPosition(0,0)

	-- local parachute = display.newSprite(IMAGE_COMMON .. "parachute.png"):addTo(parachuteNode)
	-- parachute:setAnchorPoint(cc.p(0.5,0.8))
	addArmature("sdbz_jangluosan")
	local parachute = armature_create("sdbz_jangluosan"):addTo(parachuteNode)
	parachute:setAnchorPoint(cc.p(0.5,0.8))
	self.m_parachute = parachute
    

	-- 状态 1 创建并动画
	if state.istate == 1 then
		parachute.index = 0
		parachute:getAnimation():playWithIndex(0)
		local formx = math.random( math.floor(parachute:width() * 0.55) , math.floor(self.m_parentNode:width() - parachute:width() * 0.55) )
		local tox = formx
		local formy = display.height + parachute:height()
		local toy = parachute:height() * 0.8

		

		parachute:setPosition(formx, formy)

		local dex = math.random(math.floor(parachute:width() * 0.75))
		local p = -1
		if formx >= display.cx then
			tox = formx - dex
		else
			tox = formx + dex
			p = 1
		end

		state.formx = formx
		state.tox = tox
		state.formy = formy
		state.toy = toy
		state.istate = 2

		ActivityCenterMO.UseActLocalRecord(self.m_activityID, state)

		local actall = cc.Array:create()
		actall:addObject(cc.EaseExponentialOut:create(cc.MoveTo:create(5,cc.p(tox,toy))))
		actall:addObject((transition.sequence({cc.RotateTo:create(1, -20 * p),
			cc.RotateTo:create(0.9, 2* p),
			cc.RotateTo:create(0.2, -1 * p),
			cc.RotateTo:create(0.1, 0)
			-- cc.EaseExponentialOut:create(cc.RotateTo:create(0.5, 0))
			})))

		parachute:runAction(transition.sequence({cc.Spawn:create(actall),cc.CallFunc:create(function ()
			if parachute.index < 2 then
				parachute:getAnimation():playWithIndex(1)
			end
		end)}) )
		return
	end

	-- 状态 2 落地
	if state.istate == 2 then
		parachute:getAnimation():playWithIndex(1)
		parachute:setPosition(state.tox, state.toy)
		return
	end

end

function AccidentReward:touchGift()
	print("领取 免费精力")
	self.isTouch = false

	local function callback(data)
		if self.m_okcallback then self.m_okcallback(data) end
		self:close()
	end
	
	self.m_parachute.index = 2
	self.m_parachute:getAnimation():playWithIndex(2)
	self.m_parachute:connectMovementEventSignal(function(movementType, movementID)
		if movementType == MovementEventType.COMPLETE then
			ActivityCenterBO.DrawFreeEnergy(self.m_okcallback)
			-- self:close()
		end
	end)
end

function AccidentReward:onTouch(event)
	local point = cc.p(event.x, event.y)
	if event.name == "began" then
		if cc.rectContainsPoint(self.m_parachute:getBoundingBox(), point) then
			self:setTouchSwallowEnabled(true)
			return true
		end
		self:setTouchSwallowEnabled(false)
		return true
	elseif event.name == "ended" then
		if self.m_parachute then
			if cc.rectContainsPoint(self.m_parachute:getBoundingBox(), point) and self.isTouch then
				self:touchGift()
				-- -- self:close()
				-- self:removeSelf()
			end
		end
	end
	return true
end

function AccidentReward:close()
	-- UiDirector.pop()
	self:removeSelf()
	self.m_parentNode.m_AccidentReward = nil
end

function AccidentReward:push()
	UiDirector.push(self)
	return self
end

function AccidentReward:getUiName()
	return self.__cname
end

































--------------------------------------------------------------
--							意念骰子						--
--------------------------------------------------------------
local SubjectivismView = class("SubjectivismView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function SubjectivismView:ctor(param,callback)
	self.m_param = param
	self.m_callback = callback
end

function SubjectivismView:onEnter()
	self.touchLayer = display.newColorLayer(ccc4(0, 0, 0, 128)):addTo(self, -1)
	self.touchLayer:setContentSize(cc.size(display.width, display.height))
	self.touchLayer:setPosition(0, 0)

	nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, nil, nil, true)
	self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)

    local sprite = display.newSprite(IMAGE_COMMON .. "monopoly/monopoly_dice_each.png"):addTo(self, 1)
    sprite:setPosition(self.m_param.x, self.m_param.y)
    sprite:setScale(self.m_param.scale)

    -- 意念骰子 lb
	local lb_subject_name = ui.newTTFLabel({text = CommonText[1126][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self,2)
	lb_subject_name:setScale(self.m_param.scale)
	lb_subject_name:setPosition(sprite:x() - 5, sprite:y() - 35 * self.m_param.scale)

	local count = UserMO.getResource(ITEM_KIND_PROP,542)
	local lb_subject_number = ui.newTTFLabel({text = "X" .. count, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(self,2)
	lb_subject_number:setScale(self.m_param.scale)
	lb_subject_number:setAnchorPoint(cc.p(0,0.5))
	lb_subject_number:setPosition(lb_subject_name:x() + lb_subject_name:width() * 0.5 * self.m_param.scale, lb_subject_name:y())

	local vector = display.newSprite(IMAGE_COMMON .. "vector.png"):addTo(self, 4)
	vector:setPosition(sprite:x(), sprite:y() + sprite:height() * 0.5 * self.m_param.scale + vector:height() * 0.5 + 10)

	local sbg = display.newSprite(IMAGE_COMMON .. "info_bg_120.png"):addTo(self, 3)
	sbg:setAnchorPoint(cc.p(0.5,0))
	sbg:setPosition(display.cx, vector:y() + vector:height() * 0.5 - 10)
	self.m_sbg = sbg

	for index = 1 , 6 do
		-- 
		local pointSprite = display.newSprite(IMAGE_COMMON .. "point_" .. index .. ".png")
		local pointEnergyBtn = ScaleButton.new(pointSprite, handler(self,self.pointCallback)):addTo(sbg, 1)
		pointEnergyBtn:setScale(0.75)
		pointEnergyBtn:setPosition(sbg:width() * 0.5 + CalculateX(6, index, pointEnergyBtn:width() * 0.75, 1.1) - 10, sbg:height() * 0.5 )
		pointEnergyBtn.index = index
	end
end

function SubjectivismView:pointCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local index = sender.index
	self:close()
	if self.m_callback then self.m_callback(index) end
end

function SubjectivismView:onTouch(event)
	if event.name == "ended" then

		if self.m_sbg then
			local point = cc.p(event.x, event.y)
			local rect = self.m_sbg:getBoundingBox()
			if not cc.rectContainsPoint(rect, point) then
				self:close()
			end
			return true
		end

		self:close()
	end
	return true
end

function SubjectivismView:close()
	UiDirector.pop()
end

function SubjectivismView:push()
	UiDirector.push(self)
	return self
end

function SubjectivismView:getUiName()
	return self.__cname
end



































--------------------------------------------------------------
--							事件管理						--
--------------------------------------------------------------
local EVENT_TYPE_NULL = 1 			-- 空事件
local EVENT_TYPE_START = 2 			-- 回到出发点事件
local EVENT_TYPE_AWARD = 3 			-- 奖励事件
local EVENT_TYPE_SHOP = 4 			-- 商店事件
local EVENT_TYPE_WORD = 5 			-- 对话事件

local MAX_BLOCK = 24

local EventManager = class("EventManager", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

-- activityID, eventID, actionPos, energy, rounds, buyID, awards, resCallback
function EventManager:ctor( param )
	self.m_activityID = param.activityID
	self.m_eventID = param.eventID
	self.m_actionPos = param.actionPos
	self.m_energy = param.energy
	self.m_rounds = param.rounds or 0
	self.m_buyID = param.buyID or 0
	self.m_awards = param.awards
	self.m_resCallback = param.resCallback
	self.m_closeCallback = param.closedCallback
	-- self.m_eventID = 401
end

function EventManager:onEnter()
	self:setContentSize(cc.size(display.width, display.height))
	self.isTouch = false

	local eventData = ActivityCenterMO.getMonopolyActEvents(self.m_activityID, self.m_eventID)

	self.touchLayer = display.newColorLayer(ccc4(0, 0, 0, 180)):addTo(self, -1)
	self.touchLayer:setContentSize(cc.size(display.width, display.height))
	self.touchLayer:setPosition(0, 0)
	self.touchLayer:setVisible(false)

	nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, nil, nil, true)
	self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)

    self.m_startNode = nil
    self.m_awardNode = nil
    self.m_buyNode = nil
    self.m_wordNode = nil
    self.m_RectNode = nil

    if not eventData then 
    	self.isTouch = true 
    	print("ERROR=========EventManager = self.m_eventID " .. self.m_eventID)
    end

    self:doEvent(eventData)
end

-- 事件处理
function EventManager:doEvent(eventData)
	local type = eventData.type
	-- type = 4 
	if type == EVENT_TYPE_NULL then -- 空事件
		print("空事件")
		self:close()

	elseif type == EVENT_TYPE_START then -- 回到出发点事件
		print("回到出发点事件")
		-- self.touchLayer:setVisible(true)

		self.m_startNode = display.newNode():addTo(self,2)
		self.m_startNode:setPosition(0,0)
		
		self:showStart()

	elseif type == EVENT_TYPE_AWARD then -- 奖励事件
		print("奖励事件")
		self.touchLayer:setVisible(true)

		self.m_awardNode = display.newNode():addTo(self,2)
		self.m_awardNode:setPosition(0,0)

		self.curAwardIndex = 0
		
		self:showMyAward()

	elseif type == EVENT_TYPE_SHOP then -- 商店事件
		print("商店事件")
		self.touchLayer:setVisible(true)
		-- self.m_buyID = 40101
		-- self.m_eventID = 401

		local buyData = ActivityCenterMO.getMonopolyActBuy(self.m_eventID, self.m_buyID)

		if not buyData then
			self:close()
			return
		end

		self.m_buyNode = display.newNode():addTo(self,2)
		self.m_buyNode:setPosition(0,0)
		self.m_buyNode.girlInfo = {}
		local girl = {x1 = 120, y1 = -70 , scale = 0.85}
		local girl1 = {x1 = 100, y1 = -50 , scale = 1}
		local girl2 = {x1 = 180, y1 = -40 , scale = 1}
		self.m_buyNode.girlInfo[#self.m_buyNode.girlInfo + 1] = girl
		self.m_buyNode.girlInfo[#self.m_buyNode.girlInfo + 1] = girl1
		self.m_buyNode.girlInfo[#self.m_buyNode.girlInfo + 1] = girl2

		local function doShop()
			self:showMyShop(buyData, eventData.content)
		end
		-- sdbz_shop 
		addArmature("sdbz_shop")
		local effect = armature_create("sdbz_shop", self.m_actionPos.x,self.m_actionPos.y, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
				doShop()
			end
		end):addTo(self.m_buyNode)
		effect:getAnimation():playWithIndex(0)	
		
	elseif type == EVENT_TYPE_WORD then -- 对话事件
		print("对话事件")
		-- self.touchLayer:setVisible(true)

		local wordDataList = ActivityCenterMO.getMonopolyActDlg(self.m_eventID )

		if not wordDataList then
			self:close()
			return
		end

		self.m_wordNode = display.newNode():addTo(self,2)
		self.m_wordNode:setPosition(0,0)
		self.m_wordNode.girlInfo = {}

		local girl = {dexx = 85, dexy = -100, toscale = 1, x2 = 120, y2 = -70 , scale = 0.85}
		local girl1 = {dexx = 85, dexy = -70, toscale = 1, x2 = 110, y2 = -50 , scale = 1}
		local girl2 = {dexx = 170, dexy = -50, toscale = 1.15, x2 = 170, y2 = -20 , scale = 1}
		self.m_wordNode.girlInfo[#self.m_wordNode.girlInfo + 1] = girl
		self.m_wordNode.girlInfo[#self.m_wordNode.girlInfo + 1] = girl1
		self.m_wordNode.girlInfo[#self.m_wordNode.girlInfo + 1] = girl2

		local function doWord()
			self:showTalkWord(wordDataList, eventData.content, eventData.title, eventData.sty)
		end

		-- sty 子类型事件 1 战斗 2 六芒星 3 问号 4 帐篷 5 金币事件
		if eventData.sty == 2 then
			addArmature("sdbz_mofazhen")
			local effect = armature_create("sdbz_mofazhen", self.m_actionPos.x,self.m_actionPos.y, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
					doWord()
				end
			end):addTo(self.m_wordNode)
			effect:getAnimation():playWithIndex(0)
		elseif eventData.sty == 3 then
			addArmature("sdbz_wenhao")
			local effect = armature_create("sdbz_wenhao", self.m_actionPos.x,self.m_actionPos.y, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
					doWord()
				end
			end):addTo(self.m_wordNode)
			effect:getAnimation():playWithIndex(0)
		else
			doWord()
		end

	else
		print("ERROR type:" .. tostring(type))
		self:close()
	end
end

-- 回到出发点事件
function EventManager:showStart()
	-- body
	-- self.m_startNode
	-- self.m_actionPos

	-- 蒙板
	self.touchLayer:setVisible(true)
	self.touchLayer:setOpacity(0)
	self.touchLayer:runAction(cc.FadeTo:create(0.3,180))
	

	addArmature("sdbz_start")
	local effect = armature_create("sdbz_start"):addTo(self.m_startNode,1)
	effect:setPosition(self.m_actionPos.x, self.m_actionPos.y)
	effect:getAnimation():playWithIndex(0)


	local function doOver()
		--
		addArmature("sdbz_yanhua")
		local effect2 = armature_create("sdbz_yanhua", display.cx,display.cy, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
				Notify.notify("LOCAL_ACTIVITY_MONOPOLY")
				Notify.notify("LOCAL_ACTIVITY_MONOPOLY_PRORESS_BOX", {round = self.m_rounds}) 
				self:close()
			end
		end):addTo(self.m_startNode,3)
		effect2:getAnimation():playWithIndex(0)
	end

	local actall = cc.Array:create()
	actall:addObject(cc.ScaleTo:create(0.3,2))
	actall:addObject(cc.MoveTo:create( 0.3,cc.p(display.cx , display.cy) ) )
	effect:runAction(transition.sequence({cc.Spawn:create(actall), cc.CallFuncN:create(function ()
		doOver()
	end)})  )
	
end

-- 展示奖励
function EventManager:showMyAward()
	self.curAwardIndex = self.curAwardIndex + 1

	if self.m_awardNode then
		self.m_awardNode:stopAllActions()
		self.m_awardNode:removeAllChildren()
	end

	if not self.m_awards then
		self:close()
		return
	end

	local award = self.m_awards[self.curAwardIndex]
	if award then
		
		-- 奖励
		local item = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(self.m_awardNode,2)
		item:setPosition(display.cx, display.cy)
		item:setScale(0.1)
		UiUtil.createItemDetailButton(item)

		local info = UserMO.getResourceData(award.kind, award.id)
		local name = ui.newTTFLabel({text = info.name , font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER,
			 color = COLOR[info.quality]}):addTo(item)
		name:setPosition(item:width() * 0.5, -20)

		-- addArmature("sdbz_jiangli_bgguang")
		armature_add(IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.plist", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.xml") -- 1
		
		local effect2 = armature_create("sdbz_jiangli_bgguang", display.cx,display.cy):addTo(self.m_awardNode,1)

		-- 
		-- addArmature("sdbz_hdgx")
		armature_add(IMAGE_ANIMATION .. "effect/sdbz_hdgx.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_hdgx.plist", IMAGE_ANIMATION .. "effect/sdbz_hdgx.xml") -- 1
		local effect = armature_create("sdbz_hdgx", display.cx,display.cy, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				effect2:getAnimation():playWithIndex(0)
				armature:removeSelf()
			end
		end):addTo(self.m_awardNode,3)
		effect:getAnimation():playWithIndex(0)

		-- 播放一个动画
		item:runAction(transition.sequence({cc.ScaleTo:create(0.2, 1),cc.CallFuncN:create(function ()
			self.isTouch = true
		end)}))
	else
		self:close()
	end
end

-- 打折商品
function EventManager:showMyShop(eventdata, content)
	content = content or CommonText[1130][1]
	-- 
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_117.png"):addTo(self.m_buyNode)
	bg:setPosition(display.cx, display.cy)
	bg:setScaleY(1.2)

	local snowtop = display.newScale9Sprite(IMAGE_COMMON .. "snowtop.png"):addTo(self.m_buyNode, 1)
	snowtop:setPreferredSize(cc.size(snowtop:width() * 0.85, snowtop:height()))
	snowtop:setAnchorPoint(cc.p(0.5,1))
	snowtop:setPosition(bg:x() + 25, bg:y() + bg:height() * 0.5 * bg:getScaleY() + 3 )

	local snowbottom = display.newSprite(IMAGE_COMMON .. "snowbottom.png"):addTo(self.m_buyNode, 1)
	snowbottom:setPosition(bg:x() - 10 ,bg:y() - bg:height() * 0.5 * bg:getScaleY())

	local girl = self.m_rounds and self.m_rounds >= 2 and 2 or self.m_rounds
	local girlinfo = self.m_buyNode.girlInfo[girl + 1]
	local girl = display.newSprite(IMAGE_COMMON .. "christmasgirl_".. girl .. ".png"):addTo(self.m_buyNode,3)
	girl:setScale(girlinfo.scale)
	girl:setAnchorPoint(cc.p(0.5,0))
	girl:setPosition(bg:x() - bg:width() * 0.5 + girlinfo.x1, bg:y() - bg:height() * bg:getScaleY() * 0.5 + girlinfo.y1 * girlinfo.scale)

	local contentlb = ui.newTTFLabel({text = content, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT,
			 color = COLOR[1], dimensions = cc.size(250,100)}):addTo(self.m_buyNode,2)
	contentlb:setPosition(bg:x() + 60 , bg:y() + bg:height() * bg:getScaleY() * 0.25 + 5)


	local awards = json.decode(eventdata.award)
	local award = awards[1]
	local kind = award[1]
	local id = award[2]
	local count = award[3]

	-- 奖励
	local item = UiUtil.createItemView(kind, id, {count = count}):addTo(self.m_buyNode, 2)
	item:setScale(0.8)
	item:setPosition(bg:x() - 30,bg:y() - bg:height() * bg:getScaleY() * 0.5 + item:height() * 0.5 * item:getScale() + 80)
	UiUtil.createItemDetailButton(item)

	-- 原价
	local label = ui.newTTFLabel({text = CommonText[460][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = 0, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_buyNode, 2)
	label:setAnchorPoint(cc.p(0, 0.5))
	label:setPosition(item:x() + item:width() * item:getScale() * 0.75, item:y() + item:height() * item:getScale() * 0.25)

	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_73.png"):addTo(self.m_buyNode, 3)
	tag:setPosition(label:getPositionX() + label:getContentSize().width + 10, label:getPositionY())

	local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(self.m_buyNode, 2)
	view:setScale(0.9)
	view:setPosition(label:getPositionX() + label:getContentSize().width + view:getBoundingBox().size.width / 2, label:getPositionY() - 2)

	local value = ui.newTTFLabel({text = eventdata.showGold, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = view:getPositionX() + view:getBoundingBox().size.width / 2, y = view:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_buyNode, 2)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 惊爆价
	local label = ui.newTTFLabel({text = CommonText[460][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(18, 255, 3), x = 0, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_buyNode, 2)
	label:setAnchorPoint(cc.p(0, 0.5))
	label:setPosition(item:x() + item:width() * item:getScale() * 0.75, item:y() - item:height() * item:getScale() * 0.25)

	local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(self.m_buyNode, 2)
	view:setScale(0.9)
	view:setPosition(label:getPositionX() + label:getContentSize().width + view:getBoundingBox().size.width / 2, label:getPositionY() - 2)

	local value = ui.newTTFLabel({text = eventdata.buyGold, font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(18, 255, 3), x = view:getPositionX() + view:getBoundingBox().size.width / 2, y = view:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_buyNode, 2)
	value:setAnchorPoint(cc.p(0, 0.5))


	local function resultCallback(data)
		UserMO.updateResource(ITEM_KIND_COIN,data.gold)					-- 金币
		local awards = PbProtocol.decodeArray(data["award"]) 			-- 奖励
		if awards then
			local statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		if self.m_resCallback then self.m_resCallback() end 			-- 刷新道具

		self:close()
	end

	local function buyCallback(tar,sender)
		ManagerSound.playNormalButtonSound()

		local function dobuy()
			ActivityCenterBO.BuyDiscountGoods(resultCallback, self.m_buyID)
		end

		local function ok2()
			-- require("app.view.RechargeView").new():push()
			RechargeBO.openRechargeView()
		end

		local function dobuy2()
			local count = UserMO.getResource(ITEM_KIND_COIN)
			if count >= eventdata.buyGold then
				dobuy()
			else
				local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
				TipsAnyThingDialog.new(CommonText[1094][2], ok2,CommonText[1094][1]):push()
			end
		end

		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[1130][2],eventdata.buyGold), function() dobuy2() end):push()
		else
			dobuy2()
		end
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local buyBtn = MenuButton.new(normal, selected, nil, buyCallback):addTo(self.m_buyNode, 4)
	buyBtn:setScale(0.8)
	buyBtn:setPosition(bg:x() + 60,bg:y() - bg:height() * bg:getScaleY() * 0.5 + buyBtn:height() * 0.5 + 10)
	buyBtn:setLabel(CommonText[119])

	local function closeCallback(tar,sender)
		ManagerSound.playNormalButtonSound()
		self:close()
	end
	local normal = display.newSprite(IMAGE_COMMON .. "mon_close.png")
	local closeBtn = ScaleButton.new(normal, closeCallback):addTo(self.m_buyNode, 4)
	closeBtn:setPosition(bg:x() + bg:width() * 0.5 - closeBtn:width() * 0.5,bg:y() + bg:height() * bg:getScaleY() * 0.5 - closeBtn:height() * 0.5)
end

-- 对话
function EventManager:showTalkWord(wordList, content, title, sty)
	local _wordDataList = {}
	for k,v in pairs(wordList) do
		_wordDataList[#_wordDataList + 1] = v
	end
	local function mysort(a,b)
		if a.costEnergy ~= b.costEnergy then
			return a.costEnergy > b.costEnergy
		else
			return a.id < b.id
		end
	end
	table.sort(_wordDataList, mysort)

	-- 蒙板
	self.touchLayer:setVisible(true)
	self.touchLayer:setOpacity(0)
	self.touchLayer:runAction(cc.FadeTo:create(0.3,180))

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_118.png"):addTo(self.m_wordNode, 1)
	bg:setPosition(display.cx + 45, display.cy + 50)
	bg:setCascadeOpacityEnabled(true)
	bg:setVisible(false)
	self.m_wordNode.bg = bg

	local actall = cc.Array:create()
	actall:addObject(cc.CallFunc:create(function () bg:setVisible(true)	end))
	actall:addObject(cc.FadeIn:create(0.5))
	actall:addObject(cc.MoveTo:create( 0.5,cc.p(display.cx + 45, display.cy) ) )
	bg:runAction(transition.sequence({cc.DelayTime:create(0.3), cc.Spawn:create(actall)})  )
	
	

	-- 女孩
	local girlindex = self.m_rounds and self.m_rounds >= 2 and 2 or self.m_rounds
	local girl = display.newSprite(IMAGE_COMMON .. "christmasgirl_".. girlindex .. ".png"):addTo(self.m_wordNode, 3)
	girl:setAnchorPoint(cc.p(0.5,0.5))
	girl:setPosition(self.m_actionPos.x, self.m_actionPos.y)
	girl:setScale(0.2)
	local girlinfo = self.m_wordNode.girlInfo[girlindex + 1]
	local actall = cc.Array:create()
	actall:addObject(cc.ScaleTo:create(0.4,girlinfo.toscale))
	actall:addObject(cc.MoveTo:create(0.4, cc.p(bg:x() - bg:width() * 0.5 + girlinfo.dexx, bg:y() - bg:height() * 0.5 + girl:height() * 0.5 + girlinfo.dexy)))
	girl:runAction(cc.Spawn:create(actall))
	self.m_wordNode.girl = girl


	-- 标题板
	local titlebg = display.newSprite(IMAGE_COMMON .. "info_bg_119.png"):addTo(bg, 2)
	titlebg:setAnchorPoint(cc.p(0,0))
	titlebg:setVisible(false)
	titlebg:setPosition(0 - 45,bg:height() - 40 + 50)

	local actall = cc.Array:create()
	actall:addObject(cc.CallFunc:create(function () titlebg:setVisible(true)	end))
	actall:addObject(cc.FadeIn:create(0.3))
	actall:addObject( cc.MoveTo:create( 0.3,cc.p(0 - 45, bg:height() - 40 ) ) )
	titlebg:runAction(transition.sequence({cc.DelayTime:create(0.3 + 0.5), cc.Spawn:create(actall)})  )

	local titlelb = ui.newTTFLabel({text = title, font = G_FONT, size = FONT_SIZE_BIG, color = COLOR[11], x = 0, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(titlebg)
	titlelb:setPosition(titlebg:width() * 0.5 + 30, titlebg:height() * 0.5 + 3)
	titlelb:setRotation(-6)

	-- 
	local contentlb = ui.newTTFLabel({text = content, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT,
			 color = COLOR[1], dimensions = cc.size(300,100)}):addTo(bg)
	contentlb:setPosition(bg:width() * 0.5 + 20 , bg:height() * 0.75 )


	-- 刷新 事件界面的精力 并且 通知外部
	local function finallyCallback(data)
		-- body
		local energy = data.energy 										-- 剩余精力
		self.m_energy = energy 											-- 刷新 事件界面的精力
		local out = { power = energy }
		if self.m_resCallback then self.m_resCallback(out) end 				-- 通知外部界面

		-- if table.isexist(data,"award") then
		-- 	local awards = PbProtocol.decodeArray(data["award"]) 		-- 奖励
		-- 	if awards then
		-- 		local statsAward = CombatBO.addAwards(awards)
		-- 		UiUtil.showAwards(statsAward)
		-- 	end
		-- end

		if table.isexist(data,"gold") then
			UserMO.updateResource(ITEM_KIND_COIN,data.gold)
		end
	end

	-- sty 子类型事件 1 战斗 2 六芒星 3 问号 4 帐篷 5 金币事件
	local function showEffect(call, awards)
		if not awards then
			call()
		elseif sty == 1 then

			self:hidWordMainBg()

			addArmature("sdbz_zhandouyan")
			local effect = armature_create("sdbz_zhandouyan", display.cx,display.cy, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
					call()
				end
			end):addTo(self.m_wordNode,10)
			effect:getAnimation():playWithIndex(0)
		elseif sty == 4 then

			self:hidWordMainBg()

			-- 帐篷
			addArmature("sdbz_zhangpeng")
			local effect = armature_create("sdbz_zhangpeng", display.cx,display.cy, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
					call()
				end
			end):addTo(self.m_wordNode,10)
			effect:getAnimation():playWithIndex(0)
		else
			call()
		end
	end

	local function choiceWordCallback(tar,sender)
		ManagerSound.playNormalButtonSound()
		local cost = sender.costEnergy
		local wordData = sender.wordData

		-- 无奖励事件
		if not wordData.fixAward and not wordData.rdAward then
			self:talkAbout(wordData)
			return
		end
		-- 需要消耗精力
		if self.m_energy >= cost then
			local function callback(data)

				local twoLAwards = nil
				if table.isexist(data,"award") then
					local awards = PbProtocol.decodeArray(data["award"]) 		-- 奖励
					if awards then
						CombatBO.addAwards(awards)
						-- UiUtil.showAwards(statsAward)
						twoLAwards = awards
					end

				end

				local function doEnd()
					self:talkAbout(wordData, twoLAwards)
					finallyCallback(data)
					self.isTouch = true
				end
				
				showEffect(doEnd, twoLAwards)
			end
			ActivityCenterBO.SelectDialog(callback, wordData.id)
		else
			local function no()
				self:close()
			end
			local function callback(data)
				Toast.show(CommonText[1127][2] .. data.energy)
				finallyCallback(data)
			end
			-- 精力不足
			local count = UserMO.getResource(ITEM_KIND_PROP,541)
			if count > 0 then
				-- 是否使用精力药水
				local function ok()
					ActivityCenterBO.BuyEnergy(callback,false)
				end
				
				local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
				TipsAnyThingDialog.new(CommonText[1127][3], ok,CommonText[86],no,CommonText[1131]):push()
			else
				-- 是否花费金币购买并使用 UserMO.consumeConfirm
				local baseinfo = ActivityCenterMO.getMonopolyActInfo(self.m_activityID)
				local function ok2()
					-- require("app.view.RechargeView").new():push()
					RechargeBO.openRechargeView()
				end
				local function ok()
					-- body
					local count = UserMO.getResource(ITEM_KIND_COIN)
					if count >= baseinfo.energyPrice then
						ActivityCenterBO.BuyEnergy(callback,true)
					else
						local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
						TipsAnyThingDialog.new(CommonText[1094][2], ok2,CommonText[1094][1],no,nil):push()
					end
				end
				
				local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
				TipsAnyThingDialog.new(string.format(CommonText[1127][4],baseinfo.energyPrice), ok,nil,no,nil):push()
			end
		end
	end

    self.m_wordNode.itembtnList = {}
	for index = 1 , #_wordDataList do
		local wordData = _wordDataList[index]

		local wordbg = display.newSprite(IMAGE_COMMON .. "title_infoBg.png")

		local keynum = display.newSprite(IMAGE_COMMON .. "num.png"):addTo(wordbg)
		keynum:setAnchorPoint(cc.p(0,0.5))
		keynum:setPosition(0, wordbg:height() * 0.5)

		local changelb = ui.newTTFLabel({text = wordData.text, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(wordbg)
		changelb:setAnchorPoint(cc.p(0,0.5))
		changelb:setPosition(keynum:x() + keynum:width() * 0.5 + 30, keynum:y())

		local width = keynum:width() + changelb:width()
		local height = math.max(keynum:height(), changelb:height())
		wordbg:setContentSize(cc.size(width,wordbg:height()))
		wordbg:setOpacity(0)
	    local itembtn = ScaleButton.new(wordbg, choiceWordCallback):addTo(bg)
	    itembtn:setAnchorPoint(cc.p(0,0.5))
	    itembtn:setPosition(bg:width() * 0.5 - 120, bg:height() * 0.5 + 30 - itembtn:height() * 1.5 * (index - 1) )
	    itembtn.costEnergy = wordData.costEnergy
	    itembtn.wordData = wordData

	    self.m_wordNode.itembtnList[#self.m_wordNode.itembtnList + 1] = itembtn
	end
end

-- 隐藏对话主界面
function EventManager:hidWordMainBg()
	self.m_wordNode.bg:setVisible(false)
	self.m_wordNode.girl:setVisible(false)

	for k, v in pairs(self.m_wordNode.itembtnList) do
		v:setEnabled(false)
	end
end

-- 二级对话
function EventManager:talkAbout(wordData, awards)
	local cost = wordData.costEnergy
	local conclusion = wordData.conclusion

	self:hidWordMainBg()

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_117.png"):addTo(self.m_wordNode, 10)
	bg:setPosition(display.cx, display.cy)
	self.m_wordNode.bg2 = bg
	self.m_RectNode = bg

	local snowtop = display.newScale9Sprite(IMAGE_COMMON .. "snowtop.png"):addTo(bg, 1)
	snowtop:setPreferredSize(cc.size(snowtop:width() * 0.85, snowtop:height()))
	snowtop:setAnchorPoint(cc.p(0.5,1))
	snowtop:setPosition(bg:width() * 0.5 + 25, bg:height() + 3 )

	local snowbottom = display.newSprite(IMAGE_COMMON .. "snowbottom.png"):addTo(bg, 1)
	snowbottom:setPosition(bg:width() * 0.5 - 10 , 0)

	local girlindex = self.m_rounds and self.m_rounds >= 2 and 2 or self.m_rounds
	local girlinfo = self.m_wordNode.girlInfo[girlindex + 1]
	local girl = display.newSprite(IMAGE_COMMON .. "christmasgirl_".. girlindex .. ".png"):addTo(bg,3)
	girl:setScale(girlinfo.scale)
	girl:setAnchorPoint(cc.p(0.5,0))
	girl:setPosition(girlinfo.x2, girlinfo.y2 * girlinfo.scale)

	-- 内容
	local contentlb = ui.newTTFLabel({text = conclusion, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT,
			 color = COLOR[1], dimensions = cc.size(250,100)}):addTo(bg,2)
	contentlb:setPosition(bg:width() * 0.5 + 60 , bg:height() * 0.5 + 15)

	if awards then -- cost > 0 then
		contentlb:setPosition(bg:width() * 0.5 + 60 , bg:height() * 0.75 + 5)


		-- dump(awards,"二级对话 显示奖励")
		-- local awards = json.decode(wordData.fixAward)
		-- if not awards and self.m_awards then awards = self.m_awards[1] end
		-- if not awards then return end
		local size = #awards
		for index = 1 , size do
			local award = awards[index]
			local kind = award.kind
			local id = award.id
			local count = award.count 

			-- 奖励
			local item = UiUtil.createItemView(kind, id, {count = count}):addTo(bg, 5)
			item:setScale(0.8)
			item:setPosition(bg:width() * 0.5 + 60 + CalculateX(size, index, item:width(), 1.1), item:height() * 0.5 * item:getScale() + 50)
			UiUtil.createItemDetailButton(item)

			-- addArmature("sdbz_jiangli_bgguang")
			armature_add(IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.plist", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.xml") -- 1

			local effect2 = armature_create("sdbz_jiangli_bgguang", item:x(),item:y()):addTo(bg,3)
			effect2:getAnimation():playWithIndex(0)

			local datainfo = UserMO.getResourceData(kind, id)

			local namelb = ui.newTTFLabelWithOutline({text = datainfo.name, font = G_FONT, size = 14, align = ui.TEXT_ALIGN_CENTER,
				 color = COLOR[datainfo.quality]}):addTo(bg,4)
			namelb:setPosition(item:x(), item:y() - item:height() * 0.5 * 0.85 - 10)

			-- local namelb = ui.newTTFLabel({text = datainfo.name, font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER,
			-- 	 color = COLOR[datainfo.quality]}):addTo(bg,4)
			-- namelb:setPosition(item:x(), item:y() - item:height() * 0.5 * 0.85 - 10)
		end
		
		-- self.isTouch = true
	else
		-- 点击 关闭
		self.isTouch = true
	end
end


function EventManager:onTouch(event)
	if event.name == "ended" then

		if self.m_awardNode then
			if self.isTouch then
				self.isTouch = false
				self:showMyAward()
			end
			return true
		end

		if self.m_RectNode then
			local point = cc.p(event.x, event.y)
			local rect = self.m_RectNode:getBoundingBox()
			if not cc.rectContainsPoint(rect, point) and self.isTouch then
				self:close()
			end
			return true
		end

		if self.isTouch then
			self:close()
		end
	end
	return true
end

function EventManager:close()
	if self.m_closeCallback then self.m_closeCallback()	end
	UiDirector.pop()
end

function EventManager:push()
	UiDirector.push(self)
	return self
end

function EventManager:getUiName()
	return self.__cname
end






































--------------------------------------------------------------
--							大富翁棋盘						--
--------------------------------------------------------------
local MonopolyView = class("MonopolyView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

-- activityId 应该为 awardid
function MonopolyView:ctor(size, activityId, progressCallback, stateKey)
	self.m_viewSize = size
	self.activityID = activityId
	self.m_progressCallback = progressCallback
	self.m_stateKey = stateKey
end

function MonopolyView:onEnter()

	self.m_ischeck = ActivityCenterMO.UseActivityLoaclRecordInfo(self.m_stateKey)

	-- 基本信息
	self.m_actMonopolyInfo = ActivityCenterMO.getMonopolyActInfo(self.activityID)

	nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, nil, nil, true)

	self.m_actResHandler = Notify.register("LOCAL_ACTIVITY_MONOPOLY_RES", handler(self, self.updateResource))

	self.isCouldTouch = true

	self.m_girlXdex = { 0 , 0 , 70}
	self.m_girlYdex = { 30 , -140 , -20}

	self.currentlyPos = 0
	self.nextPos = 0
	self.currentEnergy = 0
	self.currentFinnishRound = 0

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_115.png"):addTo(self)
	bg:setAnchorPoint(cc.p(0.5,0))
	bg:setPosition(self.m_viewSize.width * 0.5,0)
	bg:setScale(self.m_viewSize.width / bg:width())

	-- 底板块 节点
	local floorNode = display.newNode():addTo(self,3)
	self.m_floorNode = floorNode

	-- 内容块 节点
	local contentNode = display.newNode():addTo(self,5)
	self.m_contentNode = contentNode

	-- 人物块 节点
	local peopleNode = display.newNode():addTo(self,10)
	self.m_peopleNode = peopleNode

	-- 骰子 节点
	local diceNode = display.newNode():addTo(self,12)
	self.m_diceNode = diceNode

	local funcNode = display.newNode():addTo(self,14)
	self.m_funcNode = funcNode

	-- 绘制底板块 返回尺寸
	local floorBlockList , outSide , inSide = self:makeFloorBlock(self.m_viewSize.height, 0)
	self.m_floorBlockList = floorBlockList

	-- 雪
	self:makeSnow()

	-- 功能区域
	self:makeFunctionArea(inSide)

end

function MonopolyView:onExit()
	if self.m_actResHandler then
		Notify.unregister(self.m_actResHandler)
	end
end

function MonopolyView:onTouch(event)
	if event.name == "ended" then
		if self.m_energyDialog and self.m_energyDialog:isVisible() then
			self.m_energyDialog:setVisible(false)
		end
	end
	return true
end

-- 创建地块
-- 地图最高点
-- 地图最低点
function MonopolyView:makeFloorBlock(top, bottom)
	local ret = {}
	local Max = MAX_BLOCK						-- 地块数最大值	Max 最小为4
	local maxWidthCount = 6 					-- 单行最大值	maxWidthCount 最小为2
	local maxHeightCount = 8 					-- 单列最大值	maxHeightCount 最小为2
	Max = math.max(Max , 4)
	maxWidthCount = math.max(maxWidthCount , 2)
	maxHeightCount = math.max(maxHeightCount , 2)
	local wCount = 1 							-- 实际应用行
	local hCount = 1 							-- 实际应用列
	if (Max / maxWidthCount) < 2 then
		wCount = math.floor(Max / 2)
	else
		wCount = maxWidthCount
	end
	hCount = math.min(math.floor((Max - wCount * 2) / 2) + 2 , maxHeightCount)

	local _width = self.m_viewSize.width + 4
	local _height = top - bottom
	local _widthDex = math.floor(_width / wCount)
	local _heightDex = math.floor(_height / hCount)
	local Length = math.min(_widthDex,_heightDex)												-- 块 边长
	local wLenght = 106
	local hLenght = 111
	wLenght = Length
	hLenght = Length
	local topCenterPoint = cc.p(self.m_viewSize.width * 0.5, top)								-- 中心顶点
	local width = wLenght * wCount 																-- 矩形宽
	local height = hLenght * hCount 															-- 矩形高
	local outSideRect = cc.rect(topCenterPoint.x - width * 0.5, topCenterPoint.y - height, width, height)
	local inSideRect = cc.rect(outSideRect.x + Length, outSideRect.y + Length , outSideRect.width - Length * 2 + 2 , outSideRect.height - Length * 2 + 2)

	local lastCount = Max
	local indexWidth = 0 					-- 行索引
	local indexHeight = 0 					-- 列索引
	local all = math.floor(Max / 2) * 2 	-- 实际总数
	repeat 
		local point = cc.p(0,0)
		local index = 0 																		-- 索引
		if lastCount > wCount and indexWidth < wCount and indexHeight <= 0 then
			-- 顶层
			point.x = topCenterPoint.x - width * 0.5 + (indexWidth + 0.5) * wLenght
			point.y = topCenterPoint.y - (indexHeight + 0.5) * hLenght

			indexWidth = indexWidth + 1
			index = indexWidth
			if indexWidth >= wCount then
				indexHeight = indexHeight + 1
				indexWidth = 0
			end
		elseif lastCount <= wCount and indexWidth < wCount then
			-- 底层
			point.x = topCenterPoint.x - width * 0.5 + (indexWidth + 0.5) * wLenght
			point.y = topCenterPoint.y - (indexHeight + 0.5) * hLenght

			index = all - (hCount - 2) - indexWidth

			indexWidth = indexWidth + 1
			if indexWidth >= wCount then
				lastCount = 0
			end
		else
			-- 中层
			point.x = topCenterPoint.x + (indexWidth - 0.5) * width + wLenght * (0.5 - indexWidth)
			point.y = topCenterPoint.y - (indexHeight + 0.5) * hLenght
 
			index = all - ( indexHeight - 1 ) - indexWidth * (wCount + (hCount - 2 - indexHeight + 1) * 2 - 1)

			indexWidth = indexWidth + 1
			if indexWidth >= 2 then
				indexWidth = 0
				indexHeight = indexHeight + 1
			end
		end

		lastCount = lastCount - 1

		local sprite = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_114.png"):addTo(self.m_floorNode)
		sprite:setPreferredSize(cc.size(wLenght , hLenght ))
		sprite:setPosition(point.x, point.y)
		sprite.index = index

		local lb = ui.newTTFLabel({text = "(" .. index .. ")", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(sprite)
		lb:setAnchorPoint(cc.p(1,0))
		lb:setPosition(sprite:width(), 0)

		ret[#ret + 1] = sprite
	until lastCount <= 0


	local function mySort(a,b)
		return a.index < b.index
	end
	table.sort(ret, mySort)

	return ret, outSideRect, inSideRect
end

-- 雪
function MonopolyView:makeSnow()
	-- fuck
	-- 1
	local item = self.m_floorBlockList[5]
	local scale = item:width() / 106
	local snow1 = display.newSprite(IMAGE_COMMON .. "snow/snow1.png"):addTo(item)
	snow1:setAnchorPoint(cc.p(1,1))
	snow1:setPosition(item:width() * 0.5 ,item:height() + 15)
	snow1:setScale(scale)

	-- 2
	local item = self.m_floorBlockList[24]
	local scale = item:width() / 106
	local snow2 = display.newSprite(IMAGE_COMMON .. "snow/snow2.png"):addTo(item)
	snow2:setAnchorPoint(cc.p(0,0.5))
	snow2:setPosition( -5 ,item:height() )
	snow2:setScale(scale)

	-- 3 
	local item = self.m_floorBlockList[7]
	local scale = item:width() / 106
	local snow3 = display.newSprite(IMAGE_COMMON .. "snow/snow3.png"):addTo(item)
	snow3:setAnchorPoint(cc.p(1,0.5))
	snow3:setPosition(item:width() ,item:height() )
	snow3:setScale(scale)

	-- 4
	local item = self.m_floorBlockList[22]
	local scale = item:width() / 106
	local snow4 = display.newSprite(IMAGE_COMMON .. "snow/snow4.png"):addTo(item)
	snow4:setAnchorPoint(cc.p(0.5,1))
	snow4:setPosition(item:width() * 0.5 , item:height() + 3)
	snow4:setScale(scale)

	-- 5
	local item = self.m_floorBlockList[9]
	local scale = item:width() / 106
	local snow5 = display.newSprite(IMAGE_COMMON .. "snow/snow5.png"):addTo(item)
	snow5:setAnchorPoint(cc.p(0.5,1))
	snow5:setPosition(item:width() * 0.5,item:height() + 2)
	snow5:setScale(scale)

	-- 6
	local item = self.m_floorBlockList[19]
	local scale = item:width() / 106
	local snow6 = display.newSprite(IMAGE_COMMON .. "snow/snow6.png"):addTo(item)
	snow6:setAnchorPoint(cc.p(0,0))
	snow6:setPosition(-3, item:height()  - 10 )
	snow6:setScale(scale)

	-- 7
	local item = self.m_floorBlockList[12]
	local scale = item:width() / 106
	local snow7 = display.newSprite(IMAGE_COMMON .. "snow/snow7.png"):addTo(item)
	snow7:setAnchorPoint(cc.p(0,1))
	snow7:setPosition(-5 , item:height() + 5 )
	snow7:setScale(scale)

	-- 8 
	local item = self.m_floorBlockList[17]
	local scale = item:width() / 106
	local snow8 = display.newSprite(IMAGE_COMMON .. "snow/snow8.png"):addTo(item)
	snow8:setAnchorPoint(cc.p(1,1))
	snow8:setPosition(item:width() * 0.5 + 22, item:height() + 2 )
	snow8:setScale(scale)

	-- 9
	local item = self.m_floorBlockList[14]
	local scale = item:width() / 106
	local snow9 = display.newSprite(IMAGE_COMMON .. "snow/snow9.png"):addTo(item)
	snow9:setAnchorPoint(cc.p(1,1))
	snow9:setPosition(item:width() , item:height()  )
	snow9:setScale(scale)
end

-- 功能按钮
function MonopolyView:makeFunctionArea(inSide)
	local inSideNode = display.newClippingRegionNode(cc.rect(inSide.x, inSide.y, inSide.width, inSide.height)):addTo(self,2)

	-- 功能展示区 ---------------------------------------------------------
	local topArmatureArea = display.newSprite(IMAGE_COMMON .. "info_bg_115.png"):addTo(inSideNode,1)
	topArmatureArea:setAnchorPoint(cc.p(0.5,1))
	topArmatureArea:setPosition(inSide.x + inSide.width * 0.5,inSide.y + inSide.height)
	topArmatureArea:setScale(inSide.width / topArmatureArea:width())
	self.m_topArmatureArea = topArmatureArea

	-- 星星点点特效
	addArmature("sdbz_diandiandian")
	local effect = armature_create("sdbz_diandiandian", topArmatureArea:width() * 0.5,topArmatureArea:height() * 0.5):addTo(topArmatureArea, 1)
	effect:getAnimation():playWithIndex(0)

	-- self:reShowGirl(self.currentFinnishRound, 0)


	-- 功能按钮区 ---------------------------------------------------------
	local bottomButtonArea = display.newSprite(IMAGE_COMMON .. "info_bg_116.png"):addTo(inSideNode,2)
	bottomButtonArea:setAnchorPoint(cc.p(0.5,0))
	bottomButtonArea:setPosition(inSide.x + inSide.width * 0.5,inSide.y - 5)
	bottomButtonArea:setScale(inSide.width / bottomButtonArea:width())


	-- 购买使用精力区域
	local energyDialog = display.newSprite(IMAGE_COMMON .. "info_bg_121.png"):addTo(self.m_funcNode,1)
	energyDialog:setAnchorPoint(cc.p(0.5,0))
	energyDialog:setPosition(bottomButtonArea:x() ,inSide.y - 5 + bottomButtonArea:height() * bottomButtonArea:getScale() - 15)
	energyDialog:setVisible(false)
	self.m_energyDialog = energyDialog

	local lb1 = ui.newTTFLabel({text = string.format(CommonText[1127][5],self.m_actMonopolyInfo.addEnergy), font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER,
			 color = COLOR[1], dimensions = cc.size(energyDialog:width() * 0.9, 0)}):addTo(energyDialog)
	lb1:setAnchorPoint(cc.p(0.5,0.5))
	lb1:setPosition(energyDialog:width() * 0.5, energyDialog:height() - 40)

	local function buyOrUseEnergyCallback(tar, sender)
		ManagerSound.playNormalButtonSound()
		if self.isCouldTouch then return end
		self.isCouldTouch = true

		local isBuyState = sender.isBuy -- isBuyState true 购买 false 使用
		
		local function callback(data)
			Toast.show(CommonText[1127][2] .. data.energy)
			self.currentEnergy = data.energy
			self:updatePower()
			self:updateEnergy()
			UserMO.updateResource(ITEM_KIND_COIN,data.gold)
		end

		local function doServer()
			ActivityCenterBO.BuyEnergy(callback,sender.isBuy)
			energyDialog:setVisible(false)
			self:openTouch()
		end

		if isBuyState then
			-- 是否花费金币购买并使用
			local baseinfo = ActivityCenterMO.getMonopolyActInfo(self.activityID)
			local function no()
				self:openTouch()
			end

			local function ok2()
				-- require("app.view.RechargeView").new():push()
				RechargeBO.openRechargeView()
				self:openTouch()
			end

			local function ok()
				-- body
				local count = UserMO.getResource(ITEM_KIND_COIN)
				if count >= baseinfo.energyPrice then
					doServer()
				else
					local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
					TipsAnyThingDialog.new(CommonText[1094][2], ok2,CommonText[1094][1],no,nil):push()
				end
			end

			-- 二次消费确认
			if UserMO.consumeConfirm then
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText[1127][4],baseinfo.energyPrice), function() ok() end, function() no() end):push()
			else
				ok()
			end
		else
			doServer()
		end
	end

	local actSprite = display.newSprite(IMAGE_COMMON .. "btn_act_snow.png")
	local actEnergyBtn = ScaleButton.new(actSprite, buyOrUseEnergyCallback):addTo(energyDialog, 2)
	actEnergyBtn:setPosition(energyDialog:width() * 0.5, actEnergyBtn:height() * 0.5 + 35)
	actEnergyBtn.isBuy = true

	local energyBtnLb = ui.newTTFLabel({text = CommonText[119], font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(actEnergyBtn,2)
	energyBtnLb:setPosition(actEnergyBtn:width() * 0.5, actEnergyBtn:height() * 0.5)

	local coinsp = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(energyDialog, 1)
	coinsp:setAnchorPoint(cc.p(1,0.5))
	coinsp:setPosition(energyDialog:width() * 0.5, coinsp:height() * 0.5 + 35)

	local coinLabel = ui.newBMFontLabel({text = self.m_actMonopolyInfo.energyPrice, font = "fnt/num_1.fnt", x = self:getContentSize().width- 6, y = 25, align = ui.TEXT_ALIGN_CENTER}):addTo(energyDialog)
	coinLabel:setScale(0.8)
	coinLabel:setAnchorPoint(cc.p(0, 0.5))
	coinLabel:setPosition(energyDialog:width() * 0.5, coinsp:height() * 0.5 + 38)


	local function subjectCallback(tar, sender)
		ManagerSound.playNormalButtonSound()
		if self.isCouldTouch then return end

		energyDialog:setVisible(false)
		local count = UserMO.getResource(ITEM_KIND_PROP,542)
		print("意念骰子 剩余：" .. count)
		local function callback(index)
			self.isCouldTouch = true
			ActivityCenterBO.ThrowDice(handler(self,self.doPlayGame),index)
		end
		if count > 0 then
			local point = bottomButtonArea:convertToWorldSpace(cc.p(sender:x(), sender:y()))
			local param = {x = point.x, y = point.y, scale = bottomButtonArea:getScale()}
			SubjectivismView.new(param,callback):push()
		else
			Toast.show(CommonText[1126][2])
		end

	end

	-- 意念骰子
	local buttonSprite = display.newSprite(IMAGE_COMMON .. "monopoly/monopoly_dice_each.png")
	local subjectivismBtn = ScaleButton.new(buttonSprite, subjectCallback):addTo(bottomButtonArea, 1)
	subjectivismBtn:setPosition(bottomButtonArea:width() / 6 , bottomButtonArea:height() * 0.5 )
	subjectivismBtn:setScale(0.8)
	self.m_subjectivismBtn = subjectivismBtn

	-- 意念骰子 lb
	local lb_subject_name = ui.newTTFLabel({text = CommonText[1126][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bottomButtonArea,2)
	lb_subject_name:setPosition(subjectivismBtn:x() - 5, subjectivismBtn:y() - 35)

	-- 
	local lb_subject_number = ui.newTTFLabel({text = "X0", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(bottomButtonArea,2)
	lb_subject_number:setAnchorPoint(cc.p(0,0.5))
	lb_subject_number:setPosition(lb_subject_name:x() + lb_subject_name:width() * 0.5, lb_subject_name:y())
	self.m_subjectivismBtn.numberlb = lb_subject_number

	local function enegryCallback(tar, sender)
		ManagerSound.playNormalButtonSound()
		if self.isCouldTouch then return end

		if energyDialog:isVisible() then
			energyDialog:setVisible(false)
			return
		end

		local count = UserMO.getResource(ITEM_KIND_PROP,541)
		if count > 0 then
			-- 使用
			-- 按钮 
			actEnergyBtn.isBuy = false
			actEnergyBtn:setPosition(energyDialog:width() * 0.5, actEnergyBtn:height() * 0.5 + 35)

			-- 按钮 文字
			energyBtnLb:setString(CommonText[86])

			-- 文字
			lb1:setPosition(energyDialog:width() * 0.5, energyDialog:height() - 40)

			coinsp:setVisible(false)
			coinLabel:setVisible(false)
		else
			-- 购买 并且 使用
			-- 按钮 
			actEnergyBtn.isBuy = true
			actEnergyBtn:setPosition(energyDialog:width() * 0.5, energyDialog:height() * 0.5 + 15)

			-- 按钮 文字
			energyBtnLb:setString(CommonText[1128])

			-- 文字
			lb1:setPosition(energyDialog:width() * 0.5, energyDialog:height() - 20)

			coinsp:setVisible(true)
			coinLabel:setVisible(true)
		end
		energyDialog:setVisible(true)
	end

	-- 能量药水
	local buttonSprite = display.newSprite(IMAGE_COMMON .. "monopoly/monopoly_power.png")
	local enegryBtn = ScaleButton.new(buttonSprite, enegryCallback):addTo(bottomButtonArea, 1)
	enegryBtn:setPosition(bottomButtonArea:width() / 2 , bottomButtonArea:height() * 0.5 )
	enegryBtn:setScale(0.8)
	self.m_enegryBtn = enegryBtn

	-- 意念骰子 lb
	local lb_enegry_name = ui.newTTFLabel({text = CommonText[1127][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bottomButtonArea,2)
	lb_enegry_name:setPosition(enegryBtn:x() - 5, enegryBtn:y() - 35)

	-- 
	local lb_enegry_number = ui.newTTFLabel({text = "X0", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(bottomButtonArea,2)
	lb_enegry_number:setAnchorPoint(cc.p(0,0.5))
	lb_enegry_number:setPosition(lb_enegry_name:x() + lb_enegry_name:width() * 0.5, lb_enegry_name:y())
	self.m_enegryBtn.numberlb = lb_enegry_number

	local function pwoerCallback(tar, sender)
		ManagerSound.playNormalButtonSound()

		if not self.m_ischeck then
			local arrowPicItem = sender.arrowPic
			if arrowPicItem then
				arrowPicItem:removeSelf()
				sender.arrowPic = nil
				self.m_ischeck = ActivityCenterMO.UseActivityLoaclRecordInfo(self.m_stateKey,not self.m_ischeck)
			end
		end

		if UiDirector.hasUiByName("EventManager") then return end

		if self.isCouldTouch then return end
		self.isCouldTouch = true

		energyDialog:setVisible(false)

		if self.currentEnergy >= self.m_actMonopolyInfo.cost then
			ActivityCenterBO.ThrowDice(handler(self,self.doPlayGame),0)
		else
			Toast.show(CommonText[1127][6])
			self:openTouch()
		end
	end
	-- 骰子
	local buttonSprite = display.newSprite(IMAGE_COMMON .. "mon_dice.png")
	local pwoerBtn = ScaleButton.new(buttonSprite, pwoerCallback):addTo(bottomButtonArea, 1)
	pwoerBtn:setPosition(bottomButtonArea:width() * 5 / 6 - 15 , bottomButtonArea:height() * 0.5 + 10)
	pwoerBtn:setScale(0.9)
	self.m_pwoerBtn = pwoerBtn

	-- 骰子 精力 lb
	local lb_pwoer_name = ui.newTTFLabel({text = CommonText[1127][7], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bottomButtonArea,2)
	lb_pwoer_name:setPosition(pwoerBtn:x() - 5 , pwoerBtn:y() - 35 - 10)

	local lb_pwoer_number = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(bottomButtonArea,2)
	lb_pwoer_number:setAnchorPoint(cc.p(0,0.5))
	lb_pwoer_number:setPosition(lb_pwoer_name:x() + lb_pwoer_name:width() * 0.5, lb_pwoer_name:y())
	self.m_pwoerBtn.numberlb = lb_pwoer_number

	-- 引导
	if not self.m_ischeck then
		armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
		local arrowPic = armature_create("ryxz_dianji"):addTo(bottomButtonArea, 10)
        arrowPic:getAnimation():playWithIndex(0)
        arrowPic:setPosition(pwoerBtn:x() + 10, pwoerBtn:y() - 10)
        pwoerBtn.arrowPic = arrowPic
	end

end

-- 刷新剩余精力
function MonopolyView:updatePower(isAction, energy)
	isAction = isAction or false
	if energy then self.currentEnergy = energy end
	self.m_pwoerBtn.numberlb:setString(self.currentEnergy)

	if not isAction then
		local lb_add = ui.newTTFLabel({text = self.currentEnergy, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(self.m_pwoerBtn.numberlb)
		lb_add:setAnchorPoint(cc.p(0.5,0.5))
		lb_add:setPosition(self.m_pwoerBtn.numberlb:width() * 0.5, self.m_pwoerBtn.numberlb:height() * 0.5)
		lb_add:setScale(0.9)

		local actall = cc.Array:create()
			actall:addObject(cc.ScaleTo:create(0.3,1.8))
			actall:addObject(cc.FadeIn:create(0.3))

		lb_add:runAction(transition.sequence({cc.Spawn:create(actall),cc.CallFuncN:create(function (sender)
			sender:removeSelf()
		end)}))
	end
end

-- 刷新 能量药水
function MonopolyView:updateEnergy()
	local count = UserMO.getResource(ITEM_KIND_PROP,541)
	self.m_enegryBtn.numberlb:setString("X"..tostring(count))
end

-- 刷新 意念骰子
function MonopolyView:updateSubject()
	local count = UserMO.getResource(ITEM_KIND_PROP,542)
	self.m_subjectivismBtn.numberlb:setString("X"..tostring(count))
end

-- 异部更新界面显示数据
function MonopolyView:updateResource(param)
	-- if not param then return end

	-- 刷新剩余精力
	if param and table.isexist(param,"power") then
		self.currentEnergy = param.power
		self:updatePower()
	end

	-- 刷新 能量药水
	self:updateEnergy()

	-- 刷新 意念骰子
	self:updateSubject()
end

-- 女孩
function MonopolyView:reShowGirl(round, doIndex)
	local rounds =  round and (round < 2 and round or 2) or 0
	rounds = rounds + 1
	if not self.m_girlEffect or self.m_girlEffect.round ~= rounds then
		if self.m_girlEffect then
			self.m_girlEffect:stopAllActions()
			self.m_girlEffect:removeSelf()
			self.m_girlEffect = nil
		end
		addArmature("sdbz_meizhi".. rounds)
		local girlEffect = armature_create("sdbz_meizhi" .. rounds, self.m_topArmatureArea:width() * 0.5 + self.m_girlXdex[rounds],self.m_topArmatureArea:height() * 0.5 + self.m_girlYdex[rounds], function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:getAnimation():playWithIndex(0)
			end
			if movementType == MovementEventType.LOOP_COMPLETE then
				armature.loopCount = armature.loopCount + 1
				if armature.loopCount > 10 then
					armature.loopCount = 0
					armature:getAnimation():playWithIndex(1)
				end
			end
		end):addTo(self.m_topArmatureArea, 2)
		girlEffect:getAnimation():playWithIndex(doIndex)
		girlEffect.loopCount = 0
		girlEffect.round = rounds
		self.m_girlEffect = girlEffect
	else
		if self.m_girlEffect then
			self.m_girlEffect:getAnimation():playWithIndex(doIndex)
		end
	end
end

function MonopolyView:updateForData(data)
	-- body
	-- dump(data)
	self.Allevents = data["event"]							-- 格子里面事件列表,下标为格子ID[0,22)
	self.currentlyPos = data.pos + 1							-- 当前所在格子位置
	self.nextPos = self.currentlyPos
	self.currentEnergy = data.energy 						-- 剩余精力
	self.currentFinnishRound = data.finishRound 			-- 已经完成的轮数

	self:reShowGirl(self.currentFinnishRound, 0)

	self:makeContentBlock()

	-- 刷新数据
	self:updatePower(true)
	self:updateEnergy()
	self:updateSubject()

	self:openTouch()
end

-- 创建地块内容
function MonopolyView:makeContentBlock()
	if self.m_contentNode then
		self.m_contentNode:removeAllChildren()
	end 
	-- 根据数据 创建地块上的内容
	for index = 1, #self.Allevents do
		local eventId = self.Allevents[index]
		local eventInfo = ActivityCenterMO.getMonopolyActEvents(self.activityID, eventId)
		local icon = eventInfo.icon
		if icon then
			-- 确定地砖块
			local itemNode = self.m_floorBlockList[index]

			local eventUI = display.newSprite(IMAGE_COMMON .. "monopoly/".. icon ..".png"):addTo(self.m_contentNode)
			eventUI:setPosition(itemNode:x() , itemNode:y())
			eventUI:setScale(0.75)
		end
	end

	self:doMove()
end

-- 头像移动
function MonopolyView:doMove()
	local curPointIndex = self.currentlyPos
	local toPointIndex = self.nextPos
	local doPointIndex = math.min(toPointIndex, MAX_BLOCK + 1)
	local count = doPointIndex - curPointIndex

	if not self.m_people then

		self.armPlayerList = {0,0,0,0,0,
							  1,1,1,1,1,1,1,
							  2,2,2,2,2,
							  3,3,3,3,3,3,3}

		-- 0 上 1 右 2 下 3 左
 
		local item = self.m_floorBlockList[curPointIndex]

		addArmature("sdbz_xiaorenpaobu")
		local peopleNode = armature_create("sdbz_xiaorenpaobu", item:x(),item:y(), function (movementType, movementID, armature)
			if armature.showFloor then
				armature:showFloor(movementID)
			end
			if armature.call and movementType == MovementEventType.COMPLETE then
				armature:getAnimation():playWithIndex(1)
			end
		end):addTo(self.m_peopleNode)
		peopleNode:setScaleX(0.5)
		peopleNode:setScaleY(0.5)
		peopleNode:getAnimation():playWithIndex(1)
		peopleNode.call = false

		local function showFloor(body, movementName)
			if movementName == "zhengpao" or movementName == "cepao" or movementName == "beipao" then
				-- 初始化
				if not body.floor then
					local blackFloor = display.newSprite(IMAGE_COMMON .. "floor.png"):addTo(self.m_floorNode, 2)
					blackFloor:setScale( item:width() / blackFloor:width())
					blackFloor:setPosition(item:x(), item:y())
					body.floor = blackFloor
				end
				-- 赋值
				if body.startIndex and body.endIndex then
					if body.floor then
						for index = body.startIndex , body.endIndex do
							local curIndex = index <= MAX_BLOCK and index or 1
							local curitem = self.m_floorBlockList[curIndex]
							if curitem:boundingBox():containsPoint(cc.p(body:x(), body:y())) then
							body.floor:setPosition(curitem:x(), curitem:y())
							body.floor:setVisible(true)
							break
							end
						end
					end
				end
			elseif movementName == "zhenghuxi" then
				if body.floor and body.floor:isVisible() then
					body.startIndex = nil
					body.endIndex = nil
					body.floor:setVisible(false)
				end
			end
		end

		-- 人物 跑步
		local function peopleAction(body , index)
			body.call = false
			if index == 0 then
				body:setScaleX(1 * 0.5)
				body:getAnimation():playWithIndex(2)
			elseif index == 1 then
				body:setScaleX(1 * 0.5)
				body:getAnimation():playWithIndex(0)
			elseif index == 2 then
				body:setScaleX(-1 * 0.5)
				body:getAnimation():playWithIndex(2)
			elseif index == 3 then
				body:setScaleX(1 * 0.5)
				body:getAnimation():playWithIndex(4)
			end
 		end
 		-- 人物 站立
 		local function peopleStop(body)
 			if body.armIndex == 0 then
 				body:getAnimation():playWithIndex(3)
				body.call = true
			elseif body.armIndex == 1 then
				body:getAnimation():playWithIndex(1)
			elseif body.armIndex == 2 then
				body:getAnimation():playWithIndex(3)
				body.call = true
			elseif body.armIndex == 3 then
				body:getAnimation():playWithIndex(1)
 			end
 		end

		self.m_people = peopleNode
		self.m_people.peopleAction = peopleAction
 		self.m_people.peopleStop = peopleStop
 		self.m_people.showFloor = showFloor
		self.m_people.armIndex = self.armPlayerList[curPointIndex]


		if self.m_progressCallback then
			local out = {round = self.currentFinnishRound, cur = curPointIndex, time = 0}
			self.m_progressCallback(out)
		end
	end

	if not self.m_people or count == 0 then return end

	print("已完成" .. self.currentFinnishRound .. "圈，当前从 ".. self.currentlyPos.. "移动到".. doPointIndex)

	self.isCouldTouch = true

	local allTimes = 0
	local ret = {}
	count = 0
	self.cap = CCPointArray:create(6)

	local function putCreat()
		local actions = CCCardinalSplineTo:create(count * 0.5,self.cap , 1)
		ret[#ret + 1] = actions
		self.cap = nil
		allTimes = allTimes + count * 0.5
		count = 0
	end


	local lastPos = cc.p(0,0)
	local _indexForKey = curPointIndex 
	local cur_armkey = self.armPlayerList[_indexForKey]
	self.m_people:peopleAction(cur_armkey)
	self.m_people.startIndex = curPointIndex
	self.m_people.endIndex = doPointIndex

	for index = curPointIndex , doPointIndex do
		_indexForKey = index <= MAX_BLOCK and index or 1

		local armkey = self.armPlayerList[_indexForKey]
		local item = self.m_floorBlockList[_indexForKey]
		self.cap:add(cc.p(item:x(), item:y()))
		lastPos = cc.p(item:x(), item:y())
		count = count + 1

		if self.m_people.armIndex ~= armkey then
			putCreat()
			if index ~= doPointIndex then
				self.cap = CCPointArray:create(6)
				count = count + 1
				self.cap:add(cc.p(lastPos.x, lastPos.y))
			end

			self.m_people.armIndex = armkey
			local call = cc.CallFunc:create(function ()
				-- 播放动画
				self.m_people:peopleAction(armkey)
			end)
			ret[#ret + 1] = call
		end
	end

	if count ~= 0 and self.cap then
		putCreat()
	end


	-- 移动完成
	local function endCallback()
		self.m_people:peopleStop()

		self.currentlyPos = doPointIndex <= MAX_BLOCK and doPointIndex or 1
		self.nextPos = self.currentlyPos
		local dataEventId = self.Allevents[self.currentlyPos]
		local actionItem = self.m_floorBlockList[_indexForKey]
		local actionPos = cc.p(actionItem:x(), actionItem:y())
		-- activityID, eventID, actionPos, energy, rounds, buyID, awards, callback
		local param = { activityID = self.activityID,	 						-- 活动ID
						eventID = dataEventId,								-- 事件ID
						actionPos = actionPos,								-- 当前板块坐标
						energy = self.currentEnergy,						-- 剩余精力
						rounds = self.currentFinnishRound,					-- 已完成圈数
						buyID = self.buyId,									-- 购买ID
						awards = self.awards,								-- 奖励
						resCallback = handler(self,self.updateResource),	-- 完胜奖励刷新
						closedCallback = handler(self,self.openTouch) 		-- 关闭回调
					}

		EventManager.new(param):push()
		-- self.isCouldTouch = false 
	end
	ret[#ret + 1] = cc.CallFunc:create(function () endCallback() end)

	self.m_people:runAction(transition.sequence(ret))


	if self.m_progressCallback then
		local out = {round = self.currentFinnishRound, cur = _indexForKey, action = true, time = allTimes}
		self.m_progressCallback(out)
	end
end

function MonopolyView:openTouch()
	self.isCouldTouch = false
end

function MonopolyView:doPlayGame(data)
	-- dump(data,"掷骰子")
	if self.m_energyDialog and self.m_energyDialog:isVisible() then
		self.m_energyDialog:setVisible(false)
	end

	-- 同步意念骰子 数据
	if table.isexist(data, "atom2") then
		local prop = PbProtocol.decodeRecord(data["atom2"])
		UserMO.updateResource(prop.kind, prop.count, prop.id)
	end

	self.awards = nil
	local awards = PbProtocol.decodeArray(data["award"]) 			-- 奖励
	if awards then
		CombatBO.addAwards(awards)
		self.awards = awards
	end

	self.nextPos = data.pos + 1 									-- 位置

	local function donext()
		self:updateSubject()											--同步意念骰子 UI
		local energy = self.currentEnergy								-- 上一次精力
		self.buyId = table.isexist(data, "buyId") and data.buyId or 0 	-- 购买
		self.currentFinnishRound = data.finishRound 					-- 圈数
		self.currentEnergy = data.energy 								-- 精力
		self:updatePower(self.currentEnergy == energy)
		self:doMove()
	end
	dump(self.currentlyPos)
	local point = self.nextPos - self.currentlyPos
	point = math.min(point, 6)
	point = math.max(point, 1)
	print("掷骰子 点数 " .. point)

	if self.m_diceNode then
		self.m_diceNode:stopAllActions()
		self.m_diceNode:removeAllChildren()
	end

	
	addArmature("sdbz_shaizi")
	local effect = armature_create("sdbz_shaizi", display.cx,display.cy - 220, function (movementType, movementID, armature)
		if movementType == MovementEventType.COMPLETE then
			armature:getAnimation():playWithIndex(point)
			donext()
		end
	end):addTo(self.m_diceNode,1)
	effect:getAnimation():playWithIndex(0)
	effect.point = 0
	
	effect:runAction(transition.sequence({cc.DelayTime:create(0.7), cc.CallFunc:create(function ()
		self:reShowGirl(self.currentFinnishRound, 2)
	end)}))
end







































--------------------------------------------------------------
--							活动进度						--
--------------------------------------------------------------
local ActivityProgressBar = class("ActivityProgressBar", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function ActivityProgressBar:ctor(size,activityAwardID)
	self.viewSize = size
	self.activityAwardID = activityAwardID
end
function ActivityProgressBar:onEnter()

	self.m_actBOXHandler = Notify.register("LOCAL_ACTIVITY_MONOPOLY_PRORESS_BOX", handler(self, self.finishBox))

	local m_actMonopolyInfo = ActivityCenterMO.getMonopolyActInfo(self.activityAwardID)
	self.m_roundsInfo = {}
	-- 宝箱奖励信息
	local roundAwardInfo = json.decode(m_actMonopolyInfo.finishAward)
	local roundAward = {}							
	for index = 1 , #roundAwardInfo do
		local infoList = roundAwardInfo[index]
		local award = {}
		for i = 1 , #infoList do
			local raInfo = infoList[i]
			if raInfo[2] then
				award.list = raInfo
			else
				award.round = raInfo[1]
				self.m_roundsInfo[#self.m_roundsInfo + 1] = {roundLine = raInfo[1]}
			end
		end
		roundAward[#roundAward + 1] = award
	end
	
	-- 宝箱奖励描述
	local roundAwardDesc = m_actMonopolyInfo.desc
	local roundDesc = string.split(roundAwardDesc,";")
	
	self.m_boxlist = {}
	self.tookBoxList = {}
	self.m_openlist = {}

	


	local barBg = display.newSprite(IMAGE_COMMON .. "bar_14_bg.png"):addTo(self, 1)
	barBg:setAnchorPoint(cc.p(0.5,0.5))
	barBg:setPosition(self.viewSize.width * 0.5, self.viewSize.height * 0.5)

	local barIcon = display.newSprite(IMAGE_COMMON .. "bar_14_content.png")
	local bar = CCProgressTimer:create(barIcon):addTo(barBg)
	bar:setPosition(barBg:width() * 0.5 , barBg:height() * 0.5 + 1)
	bar:setType(1)
	bar:setBarChangeRate(cc.p(1,0))
	bar:setMidpoint(cc.p(0,0))
	bar:setPercentage(0)
	self.m_bar = bar
	self.m_barPercent = 0
	self.m_barStartX = bar:x() - bar:width() * 0.5
	self.m_barEndX = bar:x() + bar:width() * 0.5

	-- 头标
	-- local head_key = display.newSprite(IMAGE_COMMON .. "head_key.png"):addTo(barBg, 10)
	-- head_key:setAnchorPoint(cc.p(1,0.5))
	-- head_key:setPosition(self.m_barPercent * 0.01 * bar:width() + 5, bar:height() * 0.5 + 5)
	-- head_key:setOpacity(128)

	-- 头标
	addArmature("sdbz_xrtx")
	local head_key = armature_create("sdbz_xrtx", display.cx,display.cy):addTo(barBg,10)
	head_key:setPosition(self.m_barPercent * 0.01 * bar:width() + 2, bar:height() * 0.5 + 7)
	head_key:getAnimation():playWithIndex(0)

	self.m_bar.head_key = head_key


	for index = 1 ,#roundAward do
		local info = roundAward[index]
		local desc = roundDesc[index]
		local boxSprite = display.newSprite(IMAGE_COMMON .. "mon_box_".. index ..".png")
		local box = ScaleButton.new(boxSprite, handler(self,self.openBoxCallback)):addTo(self, 3)
		box:setPosition(self.viewSize.width * (index * 2 - 1) / 8 - 15 , 77)
		box.index = index
		box.round = info.round
		box.could = 0
		box.award = info.list
		box.desc = desc
		self.m_roundsInfo[index].posX = box:x() + 15
		self.m_boxlist[#self.m_boxlist + 1] = box

		local key_title = display.newSprite(IMAGE_COMMON .. "key_" .. index .. ".png"):addTo(self,4)
		key_title:setAnchorPoint(cc.p(0,1))
		key_title:setPosition(box:x() + 35, box:y() - 8)

		local strs = desc
		strs = string.split(strs,":")
		local title = ui.newTTFLabel({text = strs[1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(key_title)
		title:setAnchorPoint(cc.p(0,0.5))
		title:setPosition(5, key_title:height() * 0.5)

		-- 标线
		local key_sp = display.newSprite(IMAGE_COMMON .. "key.png"):addTo(bar,10)
		key_sp:setAnchorPoint(cc.p(0.5,0.5))
		key_sp:setPosition(box:x() + 15 - (self.viewSize.width - bar:width()) * 0.5 , self.viewSize.height * 0.5)
	end


	
end

function ActivityProgressBar:openBoxCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local index = sender.index
	local desc = sender.desc
	local award = sender.award
	local round = sender.round
	local couldState = sender.could
	if couldState == 0 then
		-- 查看
		local ShowDilog = require("app.dialog.ShowDilog")
		ShowDilog.new(award, desc,CommonText[1129]):push()
	elseif couldState == 1 then
		-- 领取

		local function drawFinishCallback(data)
			if table.isexist(data,"award") then
				local awards = PbProtocol.decodeArray(data["award"]) 		-- 奖励
				if awards then
					CombatBO.addAwards(awards)
					-- UiUtil.showAwards(statsAward)
					local AwardsDialog = require("app.dialog.AwardsDialog")
					AwardsDialog.new(awards):push()
				end
			end

			self.tookBoxList[round] = true
			sender.could = 2
			self:updateBoxData()
			Notify.notify("LOCAL_ACTIVITY_MONOPOLY_RES")
		end

		ActivityCenterBO.DrawFinishCountAward(drawFinishCallback,round)
	end
end

-- 设置宝箱已领取数据
function ActivityProgressBar:setOpenedBoxData(list)
	list = list or {}
	self.tookBoxList = {}
	for index = 1 ,#list do
		local key = list[index]
		self.tookBoxList[key] = true
	end
	self:updateBoxData()
end

-- 刷新宝箱状态
function ActivityProgressBar:updateBoxData()
	-- self.m_openlist = openlist or self.m_openlist
	 for index = 1 , #self.m_boxlist do
	 	local box = self.m_boxlist[index]
	 	local isOpen = self.m_openlist[index] or false
	 	local istake = self.tookBoxList[box.round] or false
	 	if box.et then
	 		box.et:removeSelf()
	 		box.et = nil
	 	end
	 	if box.eb then
	 		box.eb:removeSelf()
	 		box.eb = nil
	 	end
	 	if isOpen then
	 		if istake then
	 			-- 已经领取
	 			box:setTouchSprite(display.newSprite(IMAGE_COMMON .. "mon_box.png"))
	 			box:stopAllActions()
	 			box:setRotation(0)
	 			box:setEnabled(false)
	 			box.could = 2
	 		else
	 			-- 未领取
	 		-- 	box:run{
				-- 	"rep",
				-- 	{
				-- 		"seq",
				-- 		{"delay",math.random(1,1)},
				-- 		{"rotateTo",0,-10},
				-- 		{"rotateTo",0.1,10},
				-- 		{"rotateTo",0.1,-10},
				-- 		{"rotateTo",0.5,0,"ElasticOut"}
				-- 	}
				-- }
				addArmature("sdbz_baoxiang_shang")
				local effectTop = armature_create("sdbz_baoxiang_shang", box:width() * 0.5 ,box:height() * 0.5):addTo(box,1)
				effectTop:getAnimation():playWithIndex(0)
				box.et = effectTop

				addArmature("sdbz_baoxiang_xia")
				local effectBottom = armature_create("sdbz_baoxiang_xia", box:width() * 0.5 - 10 ,box:height() * 0.5 - 5):addTo(box,-1)
				effectBottom:getAnimation():playWithIndex(0)
				box.eb = effectBottom

				box.could = 1
	 		end
	 	end
	 end
end

-- 检查宝箱
function ActivityProgressBar:finishBox(event)
	local curFinishRound = event.obj.round

	local function showHeadEye()
		addArmature("sdbz_xrtx_aixing")
		local head_eye = armature_create("sdbz_xrtx_aixing"):addTo(self.m_bar.head_key,2)
		head_eye:setPosition(-26 , head_eye:height() * 0.5 - 2)
		head_eye:getAnimation():playWithIndex(0)
	end

	local function doFinishEffect2(node)
		addArmature("sdbz_tianhou_baozha")
		local effect2 = armature_create("sdbz_tianhou_baozha", 0 ,0, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
				self:updateBoxData()
			end
		end):addTo(node,9)
		effect2:setAnchorPoint(cc.p(0.5,0.5))
		effect2:setPosition(node:width() * 0.5 - 30, node:height() * 0.5 - 10)
		effect2:getAnimation():playWithIndex(0)
	end

	local function doFinishEffect1(node)
		addArmature("sdbz_tianhou")
		local effect1 = armature_create("sdbz_tianhou"):addTo(node,9)
		effect1:setAnchorPoint(cc.p(0.5,1))
		effect1:setPosition(node:width() * 0.5, node:height() * 0.5 - display.height)
		effect1:getAnimation():playWithIndex(0)
		effect1:runAction(transition.sequence({cc.MoveTo:create(0.5,cc.p(node:width() * 0.5, node:height() * 0.5 + 40)), cc.CallFuncN:create(function (sender)
			sender:removeSelf()
			doFinishEffect2(node)
			showHeadEye()
		end)}))
	end

	for index = 1 , #self.m_boxlist do
		local box = self.m_boxlist[index]
		if box.round == curFinishRound then
			doFinishEffect1(box)
			break
		end
	end
end

function ActivityProgressBar:updateProgress(param)
	local curRound = param.round
	local cur = param.cur
	local action = param.action or false
	local time = param.time
	local max = MAX_BLOCK

	local round = 0
	local catX = 0
	local nextRound = 10
	local nextCatX = self.m_barEndX
	
	local percent = 0

	local hasOpened = {}
	
	for index = 1 , #self.m_roundsInfo do
		local info = self.m_roundsInfo[index]
		if curRound >= info.roundLine then
			catX = info.posX 
			round = info.roundLine
			hasOpened[index] = true
		else
			nextCatX = info.posX
			nextRound = info.roundLine
			break
		end
	end

	if round >= nextRound then
		percent = 100
	else
		local perMax = (nextRound - round) * max
		local perCur = (curRound - round) * max + cur
		local per = perCur / perMax
		local dexWidth = (nextCatX - catX) * per
		local usedWidth = catX + dexWidth
		percent = (usedWidth - self.m_barStartX) / (self.m_barEndX - self.m_barStartX) * 100
		
		-- print("==========================")
		-- print("curRound " .. curRound .. "  cur " .. cur)
		-- print("round ", round)
		-- print("catX ", catX)
		-- print("nextRound ", nextRound)
		-- print("nextCatX ", nextCatX)
		-- print("perMax ", perMax)
		-- print("perCur ", perCur)
		-- print("per ", per)
		-- print("dexWidth ", dexWidth)
		-- print("usedWidth ", usedWidth)
		-- print("percent ", percent)
		-- print("==========================")
	end
	percent = math.min(percent, 100)

	self.m_barPercent = percent
	if action and percent < 100 then
		self.m_bar:runAction(cc.ProgressTo:create(time, percent))
		self.m_bar.head_key:runAction(transition.sequence({cc.MoveTo:create(time,cc.p( self.m_barPercent * 0.01 * self.m_bar:width() + 2, self.m_bar.head_key:y()))}))
	else
		self.m_bar:setPercentage(percent)
		self.m_bar.head_key:setPosition(self.m_barPercent * 0.01 * self.m_bar:width() + 2 , self.m_bar.head_key:y())
	end

	self.m_openlist = hasOpened
	-- self:updateBoxData(hasOpened)
end

function ActivityProgressBar:onExit()
	if self.m_actBOXHandler then
		Notify.unregister(self.m_actBOXHandler)
	end
end
































--------------------------------------------------------------
--							圣诞宝藏						--
--------------------------------------------------------------
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ActivityMonopolyView = class("ActivityMonopolyView", UiNode)

function ActivityMonopolyView:ctor(activity)
	-- ActivityMonopolyView.super.ctor(self, "image/common/bg_ui.jpg")
	ActivityMonopolyView.super.ctor(self,"",nil,{closeBtn = false})
	self.m_activity = activity
end

function ActivityMonopolyView:onEnter()
	ActivityMonopolyView.super.onEnter(self)

	ArmList = {}

	 -- {"sdbz_baoxiang_shang",
	 --    "sdbz_baoxiang_xia",
	 --    "sdbz_diandiandian",
	 --    "sdbz_hdgx",
	 --    "sdbz_jiangli_bgguang",
	 --    "sdbz_meizhi1",
	 --    "sdbz_meizhi2",
	 --    "sdbz_meizhi3",
	 --    "sdbz_shop",
	 --    "sdbz_shaizi",
	 --    "sdbz_start",
	 --    "sdbz_xiaorenpaobu",
	 --    "sdbz_xrtx",
	 --    "sdbz_xrtx_aixing",
	 --    "sdbz_yanhua",
	 --    "sdbz_zhandouyan",
	 --    "sdbz_tianhou",
	 --    "sdbz_tianhou_baozha",
		-- "sdbz_wenhao",
		-- "sdbz_zhangpeng"}
	
	-- self:setTitle(self.m_activity.name)
	-- self:hasCoinButton(true)

	local bg = display.newSprite("image/common/bg_ui.jpg"):addTo(self:getBg())
	bg:setScaleY(bg:getContentSize().height / bg:getContentSize().height)
	bg:setPosition(bg:getContentSize().width / 2, self:getBg():getContentSize().height / 2)

	local title = display.newSprite(IMAGE_COMMON .. "mon_title.png"):addTo(self:getBg(),97)
	title:setAnchorPoint(cc.p(0.5,1))
	title:setPosition(self:getBg():width() * 0.5, self:getBg():height())

	local namebg = display.newSprite(IMAGE_COMMON .. "info_bg_122.png"):addTo(self:getBg(),98)
	namebg:setAnchorPoint(cc.p(0.5,1))
	namebg:setPosition(self:getBg():width() * 0.5, self:getBg():height())

	local nameSP = display.newSprite(IMAGE_COMMON .. "monopoly_name.png"):addTo(namebg)
	nameSP:setPosition(namebg:width() * 0.5 , namebg:height() * 0.5+ 10)

	local normal = display.newSprite(IMAGE_COMMON .. "mon_back.png")
	local selected = display.newSprite(IMAGE_COMMON .. "mon_back.png")
	local closeBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReturnCallback)):addTo(self:getBg(), 99)
	closeBtn:setPosition(10 + closeBtn:width() * 0.5, self:getBg():height() - closeBtn:height() * 0.5)

	local function helpCallback(tar, sender)
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.ActMonopolyHelper):push()
	end
	local helSprite = display.newSprite(IMAGE_COMMON .. "btn_detail.png")
	helSprite:setTextureRect(cc.rect(-14,-4,40,40))
	local helpBtn = ScaleButton.new(helSprite, helpCallback):addTo(namebg, 1)
	helpBtn:setPosition(namebg:width() - helpBtn:width() * 0.5 - 8 , namebg:height() * 0.5 + helpBtn:height() * 0.5 + 4)
	-- helpBtn:drawBoundingBox()

	-- 背景
	local topBg = display.newSprite(IMAGE_COMMON .. "info_bg_113.png"):addTo(self:getBg(), 5)
	topBg:setPosition(self:getBg():width() * 0.5, self:getBg():height() - topBg:height() * 0.5)

	-- 时间bg
	local timeBg = display.newSprite(IMAGE_COMMON .. "time_bg.png"):addTo(self:getBg(), 99)
	timeBg:setPosition(self:getBg():width() - timeBg:width() * 0.5 - 2, self:getBg():height() - timeBg:height() * 0.5)

	-- 时间 cc.c3b(18, 255, 3)
	local lb_time_title = ui.newTTFLabel({text = "00:00:00", font = G_FONT, size = 14, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(timeBg)
	lb_time_title:setAnchorPoint(cc.p(0.5,0.5))
	lb_time_title:setPosition(timeBg:width() * 0.5 , timeBg:height() * 0.5 - 8)
	self.m_lb_time_title = lb_time_title

	-- 进度和奖励
	local barView = ActivityProgressBar.new(cc.size(self:getBg():width() , 24),self.m_activity.awardId):addTo(topBg, 10)
	barView:setAnchorPoint(cc.p(0,1))
	barView:setPosition(0, -5)
	self.m_barView = barView

	local top = topBg:y() - topBg:height() * 0.5 
	local bottom = 0

	local _key = self.m_activity.activityId -- .. "_" .. self.m_activity.awardId .. "_" .. self.m_activity.beginTime
	-- 转盘
	local mview = MonopolyView.new(cc.size(self:getBg():width(),top - bottom), self.m_activity.awardId, handler(barView,barView.updateProgress), _key):addTo(self:getBg())
	mview:setAnchorPoint(cc.p(0,0))
	mview:setPosition(0,bottom)
	self.m_view = mview

	self.timeEndTag = -1
	-- 刷新时间
	if not self.timeScheduler then
		self.timeScheduler = scheduler.scheduleGlobal(handler(self,self.update), 1)
	end

	self.m_actHandler = Notify.register("LOCAL_ACTIVITY_MONOPOLY", handler(self, self.reloadGame))
	self:reloadGame()
end

function ActivityMonopolyView:reloadGame()
	self.m_view.isCouldTouch = true
	ActivityCenterBO.GetMonopolyInfo(handler(self,self.reloadInfo))
end


function ActivityMonopolyView:reloadInfo(data)

	self.m_view:updateForData(data)

	local hasPrice = data["drawRound"]	-- 已经领取的宝箱列表
	-- dump(hasPrice,"GetMonopolyInfo.drawRound")
	self.m_barView:setOpenedBoxData(hasPrice)
	
	if table.isexist(data,"drawFreeEnergySec") then
		self:takeFreeGift(data.drawFreeEnergySec)
	end
	-- 
end

function ActivityMonopolyView:reFreeCallback(data)
	-- optional int32 drawFreeEnergySec = 1;       //最后领取免费精力事件:单位：秒
    -- optional int32 energy = 2;                  //当前剩余精力
    if table.isexist(data,"drawFreeEnergySec") then
		self:takeFreeGift(data.drawFreeEnergySec)
	end
	if table.isexist(data,"energy") then
		self.m_view:updatePower(false,data.energy)
	end
end

function ActivityMonopolyView:takeFreeGift(drawFreeEnergySec)
		local lasttake = drawFreeEnergySec
		
		local livetime = ManagerTimer.getTime() - self.m_activity.beginTime
		local half = 60 * 60 * 12
		local has = livetime % half
		local will = half - has 
		self.m_willtakeTime = will

		local lastFlush = ManagerTimer.getTime() - has
		-- local nextFlush = ManagerTimer.getTime() + will
		local last1 = os.date("*t", lastFlush)
		local last2 = os.date("*t", lasttake)
		print("上一次刷新时间点   " , lastFlush , " ", last1.month .. "月" , last1.day .. "日", last1.hour .. "时" , last1.min .. "分" )
		print("上一次领取时间     " , lasttake, " ", last2.month .. "月" , last2.day .. "日", last2.hour .. "时" , last2.min .. "分" )
		-- print("当前时间           " , ManagerTimer.getTime())
		-- print("下一次刷新时间     " , nextFlush)

		if lasttake < lastFlush then
			-- 还未领取奖励
			local state = ActivityCenterMO.UseActLocalRecord(self.m_activity.activityId)
			local out = clone(state)
			-- dump(state,"state")
			-- 第一次没有数据 or 有数据 和上次不一样
			if not state.last or state.last ~= lasttake then
				out.istate = 1
			elseif state.istate == 2 then
				out.istate = 2
			else
				-- 什么都做
				out.istate = 1
			end
			out.last = lasttake
			-- dump(out,"out")
			if self:getBg().m_AccidentReward then return end
			AccidentReward.new(self:getBg(), self.m_activity.activityId, out, handler(self,self.reFreeCallback)):addTo(self:getBg(),10)--:push()
		else
			-- print("已经领取过了")
		end
end

function ActivityMonopolyView:Time(time)
	local function Date(times)
		local data = {}
		data.second = times % 60
		data.minute = math.floor(times / 60) % 60
		data.hour = math.floor(times / 3600)
		return data
	end
	local timeData = Date(time)
	if timeData.hour > 0 then return string.format("%02d:%02d:%02d", timeData.hour, timeData.minute, timeData.second)
	else return string.format("%02d:%02d", timeData.minute, timeData.second)
	end
end

function ActivityMonopolyView:update(ft)
	if self.m_lb_time_title then
		local time = self.m_activity.endTime - ManagerTimer.getTime()
		if time >= 0 then 
			self.m_lb_time_title:setString(self:Time(time))
		else
			self.m_lb_time_title:setString(self:Time(0))
			self.timeEndTag = self.timeEndTag + 1
			if self.timeEndTag == 0 then
				self:reloadGame()
			end
		end
	end

	-- 半天领取倒计时
	if self.m_willtakeTime and self.m_willtakeTime >= 0 then
		if self.m_willtakeTime <= 0 then
			self:reloadGame()
		end
		self.m_willtakeTime = self.m_willtakeTime - 1
	end
end

function ActivityMonopolyView:onExit()
	ActivityMonopolyView.super.onExit(self)
	if self.m_actHandler then
		Notify.unregister(self.m_actHandler)
	end
	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
	end
	for index = 1, #ArmList do
		local armName = ArmList[index]
		armature_remove(IMAGE_ANIMATION .. "effect/" .. armName .. ".pvr.ccz", IMAGE_ANIMATION .. "effect/" .. armName .. ".plist", IMAGE_ANIMATION .. "effect/" .. armName .. ".xml") -- 1
	end
	armature_remove(IMAGE_ANIMATION .. "effect/sdbz_hdgx.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_hdgx.plist", IMAGE_ANIMATION .. "effect/sdbz_hdgx.xml") -- 1
	armature_remove(IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.plist", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.xml") -- 1
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
end


return ActivityMonopolyView