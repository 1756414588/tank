--
-- Author: Gss
-- Date: 2018-03-21 14:52:07
--引导对话框

local PlotTalkView = class("PlotTalkView", UiNode)

-- index 为当前是第几区域块
-- root 背景图的路径
-- talkIndex 当前是第几步谈话
-- 第 index 块区域的第 talkIndex 次对话
-- isfirst是否是第一次进入活动
function PlotTalkView:ctor(index,root,isfirst,talkIndex)
	PlotTalkView.super.ctor(self, "",nil,{closeBtn = false})
	-- PlotTalkView.super.ctor(self,"",nil)
	self.m_isfirst = isfirst
	self.m_index = index
	self.m_root = root or nil
	self.m_talkIndex = talkIndex or 1
	self.m_talkMax = 0 --当前章节，最大有多次对话

	self._full_screen_ = false
end

function PlotTalkView:onEnter()
	PlotTalkView.super.onEnter(self)

	if self.m_isfirst then
		armature_add(IMAGE_ANIMATION .. "redplan/redplan_open.pvr.ccz", IMAGE_ANIMATION .. "redplan/redplan_open.plist", IMAGE_ANIMATION .. "redplan/redplan_open.xml")

		--黑色遮罩
		local rect = CCRectMake(0, 0, GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT)
		local bgMask = CCSprite:create("image/common/bg_ui.jpg", rect):addTo(self:getBg())
		bgMask:setCascadeBoundingBox(rect)
		bgMask:setPosition(GAME_SIZE_WIDTH / 2, GAME_SIZE_HEIGHT / 2)
		bgMask:setTouchEnabled(true)
		bgMask:setTouchSwallowEnabled(true) --防止点击到下一层

		local armature = armature_create("redplan_open", nil, nil, function(movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
				if bgMask then
					bgMask:removeSelf()
					bgMask = nil
				end
				self:initUI()
			end
		end):addTo(self:getBg()):pos(self:getBg():width() / 2, self:getBg():height() / 2)

		self:performWithDelay(function ()
			armature:getAnimation():playWithIndex(0)
		end, 0.8)
		-- armature:getAnimation():playWithIndex(0)
	else
		self:initUI()
		if self.m_index < 7 then
			ActivityCenterBO.GetRedPlanAreaInfo(function() end, self.m_index)
		end
		-- ActivityCenterBO.GetRedPlanAreaInfo(function() end, self.m_index )
	end

	self.m_ft = 0

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()

end

function PlotTalkView:onEnterFrame(dt)
	self.m_ft = self.m_ft + 1
end

function PlotTalkView:initUI()
	self.isTalking = false
	local talkDB = ActivityCenterMO.getTalkByChapter(self.m_index)
	self.m_talkMax = #talkDB
	if self.m_talkIndex > #talkDB then return end
	local db = talkDB[self.m_talkIndex]

	if self.container then
		self.container:removeAllChildren()
		self.container = nil
	end

	local container = display.newNode():addTo(self:getBg())
	self.container = container

	--BG
	local bg
	if self.m_root then
		bg = display.newSprite(IMAGE_COMMON .. self.m_root):addTo(container)
		self.container.bg = bg
	else
		bg = display.newNode():addTo(container)
		bg:setContentSize(cc.size(display.width, display.height))
	end
	bg:setPosition(self:getBg():width() / 2, self:getBg():height() / 2)

	local function dotoTalk()
		--对话框
		local talkBg = display.newSprite(IMAGE_COMMON .. "redplan/talk_bg.png"):addTo(container,99)
		talkBg:setPosition(self:getBg():width() / 2,talkBg:height() / 2 + 10)

		--头像
		local head = display.newSprite(IMAGE_COMMON .. "redplan/"..db.asset..".png"):addTo(container,9)
		head:setScale(0.6)
		if db.direct == 1 then
			head:setPosition(self:getBg():width() - head:width() / 4,talkBg:getPositionY() + head:height() * 0.35)
		else
			head:setPosition(head:width() / 4,talkBg:getPositionY() + head:height() * 0.35)
		end

		--对话框的箭头
		local arrow = display.newSprite(IMAGE_COMMON .. "redplan/down_arrow.png"):addTo(talkBg)
		arrow:setPosition(talkBg:width() - arrow:width() * 2, arrow:height())
		self.m_arrow = arrow
		self.m_arrow:setVisible(false)


		local talkStr = db.dialogue
		--判断如果是id 为12,15,21 时。格式化
		if db.id == 12 or db.id == 15 or db.id == 21 then
			talkStr = string.format(db.dialogue,UserMO.nickName_)
		end
		self.curContentText = talkStr

		local name = UiUtil.label(db.name..":",26):addTo(talkBg)
		name:setAnchorPoint(cc.p(0,1))
		name:setPosition(30,talkBg:height() - 10)

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(talkBg:width() - 60, 0)}):addTo(talkBg)
		label:setPosition(30,talkBg:height() - 70)
		label:setAnchorPoint(cc.p(0,1))
		self.curContentLabel = label

		self.curLabIndex = 1
		self.curTextLen = string.utf8len(self.curContentText)
		self:playLabelAnim()
	end

	--延迟S时间去创建对话
	self:performWithDelay(function ()     
		dotoTalk()
	end,0.5)

end

-- 播放文字逐渐显示的动画
function PlotTalkView:playLabelAnim()
	self:performWithDelay(function ()
		self.curLabIndex = self.curLabIndex + 1
		if self.curLabIndex > self.curTextLen then
			--do some
			self.isTalking = false
			self.m_arrow:setVisible(true)
		else
			self.isTalking = true
			self.curContentLabel:setString(string.utf8sub(self.curContentText, 1, self.curLabIndex))
			self:playLabelAnim()
		end
	end,0.05)
end

function PlotTalkView:setData(process)
	self.m_process = process
end

-- 在每个ui的最下层添加一个node来接受所有的touch事件，避免点击了下层ui
function PlotTalkView:addTouchReceiveNode()
	local touchNode = display.newNode():addTo(self, -1000)
	touchNode:setContentSize(cc.size(display.width, display.height))
	nodeTouchEventProtocol(touchNode, function(event)
			if event.name == "began" then
		        return self:onTouchBegan(event)
		    elseif event.name == "moved" then
		        self:onTouchMoved(event)
		    elseif event.name == "ended" then
		        self:onTouchEnded(event)
		    else -- cancelled
		        self:onTouchCancelled(event)
		    end
	 end, nil, true, true)
end

function PlotTalkView:onTouchBegan(event)

	return true
end

function PlotTalkView:onTouchMoved(event)

end

function PlotTalkView:onTouchEnded(event)
	local x = event.x
	local y = event.y

	local point = self:getParent():convertToNodeSpace(cc.p(x, y))
	
	local rect = self:getBoundingBox()

	if self.m_ft < 60 then
		return
	end

	self.m_ft = 0
	self:onNext()
end

function PlotTalkView:onTouchCancelled(event, x, y)
end

function PlotTalkView:onNext()
	local view = UiDirector.getUiByName("ActivityCommunismView")
	--如果正在打字，则显示全部内容
	if self.isTalking == true then
		self.curLabIndex = self.curTextLen
		self:playLabelAnim()
		self.curContentLabel:setString(self.curContentText)
		return
	end

	--如果当前是当前章节的最后一次剧情对话
	if self.m_talkIndex >= self.m_talkMax then
		if view then
			self:popSelf()
			if self.m_index == 7 then return end --如果是最后一关。没有箭头指引。直接return
			--播放箭头指向动画
			local begainPoint, endPoint, isforward = ActivityCenterMO:getArrowPoint(self.m_index)
			-- if self.m_index == 1 then --当前为第一关，只播放箭头。
				-- view:showArrowAct(self.m_index, begainPoint,endPoint,isforward)
			-- elseif self.m_index == 1 then --当前为最后一关，只播放区域块的变色
			-- 	view:playArealExchange(self.m_index - 1, true) --播放上次通过的关卡变色
			-- else --先播放变色，再播放箭头
				-- view:playArealExchange(self.m_index - 1, true) --播放上次通过的关卡变色
				view:showArrowAct(self.m_index, begainPoint,endPoint,isforward)
			-- end
		end
	end

	--如果当前是第一章的剧情对话
	if self.m_index == 1 and self.m_talkIndex == 2 then
		self:showOther()
		return
	end

	--如果当前是第二章
	if self.m_index == 2 and self.m_talkIndex == 2 then
		--第二章对话两次后地图出现锯齿城墙
		if view then
			self:popSelf()
			view:showWall(true)
			--此处为第二章的强引导。
			require("app.view.PlotTalkView").new(self.m_index,nil,nil,3):addTo(view, 50 + 1)
		end
	end

	self.m_talkIndex = self.m_talkIndex + 1
	self:initUI()
	
end

--显示谈话以外的剧情
function PlotTalkView:showOther()
	-- 遮罩
	local blacksp = display.newColorLayer(ccc4(0, 0, 0, 255)):addTo(self:getBg(), 3)
	blacksp:setContentSize(cc.size(self:getBg():width() + 20, self:getBg():height() + 35))
	blacksp:setPosition(-10,-35)
	blacksp:setOpacity(0)

	if self.m_index == 1 then
		local function action2()
			blacksp:runAction(transition.sequence({cc.FadeIn:create(0.7),cc.CallFunc:create(function ()
				blacksp:setOpacity(0)
				blacksp:setZOrder(6)
				self:popSelf()
				local view = UiDirector.getUiByName("ActivityCommunismView")
				if view then
					--此处为第一章的强引导。
					require("app.view.PlotTalkView").new(self.m_index,nil,nil,3):addTo(view, 50 + 1)
				end
			end)}))
		end

		local function action1()
			local spwArray = cc.Array:create()
			spwArray:addObject( CCEaseExponentialOut:create(cc.ScaleTo:create(1.5,2.5))  )
			spwArray:addObject( transition.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
				action2()
			end)}) )
			self.container.bg:runAction(cc.Spawn:create(spwArray))
			-- self:getBg():runAction(cc.Spawn:create(spwArray))
		end

		action1()

	end

end


function PlotTalkView:onExit()
	if self.m_isfirst then
		armature_remove(IMAGE_ANIMATION .. "redplan/redplan_open.pvr.ccz", IMAGE_ANIMATION .. "redplan/redplan_open.plist", IMAGE_ANIMATION .. "redplan/redplan_open.xml")
	end
end

function PlotTalkView:popSelf()
	self:removeSelf()
	print("PlotTalkView pop")
end


return PlotTalkView