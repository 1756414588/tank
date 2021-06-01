--
-- 红色方案(共产主义活动)
-- 
--


----------------------------------------------------------
--						公共方法与变量					--
----------------------------------------------------------

local LOCAL_REDPLAN_MAPCOLOR = 5 		-- 色块层
local LOCAL_REDPLAN_MAPWORLD = 10 		-- 地图层
local LOCAL_REDPLAN_BSCENERY = 15 		-- 蒙板层
local LOCAL_REDPLAN_AREANODE = 20 		-- 区域层
local LOCAL_REDPLAN_LIGHT 	 = 25 		-- 高亮层

local LOCAL_UI				= 50

local LOCAL_ARROW			= 100

local LOCAL_TIP_LABEL		= 150

-- node 节点
-- formpoint 出发点
-- topoint 目的地
-- isforward 是否正方向
local function arrowRoundShow(node, formpoint, topoint, isforward, isAction, actionCallback)
	local isforward = isforward or false -- 是否正方向
	local isAction = isAction or true
	local _xwidth = topoint.x - formpoint.x -- 两点宽度间距
	local _yheight = topoint.y - formpoint.y -- 两点高度间距
	local arrowicon = "arrow_ra.png"
	local va = Vec(1, 0)
	local _rt = 1
	local _at = 1
	local _atob = 1
	-- 是否正方向
	if isforward then
		arrowicon = "arrow_re.png"
		va = nil
		va = Vec(-1, 0)
		_rt = -1
	end
	if _yheight > 0 then
		_atob = -1
	elseif _yheight < 0 then
		_atob = 1
	else
		if _xwidth > 0 then
			_atob = 1
		elseif _xwidth < 0 then
			_atob = -1
		else
			return
		end
	end
	-- 是否播放动画
	if not isAction then _at = -1 end

	-- 创建箭头
	local arrowItem = display.newSprite(IMAGE_COMMON .. "redplan/" .. arrowicon):addTo(node , LOCAL_ARROW)

	-- 相关变量
	local height = arrowItem:height() - 20 -- 图片高度 (-25 真是高度)
	local ftCenterPoint = cc.p(formpoint.x + _xwidth * 0.5, formpoint.y + _yheight * 0.5) -- 中心点
	local ftDistance = math.sqrt(math.pow(_xwidth, 2) + math.pow(_yheight, 2)) -- 两点绝对间距
	local itemDistance = height * 2 -- 图片真实间距(包含旋转)
	local itemscale = ftDistance / itemDistance -- 自然缩放
	local vb = Vec(_xwidth, _yheight)
	local _ra = (va * vb) / (va.modulus() * vb.modulus())
	local rotation = math.deg(math.acos( _ra )) -- 旋转角度

	-- 设置箭头
	arrowItem:setAnchorPoint(cc.p(0.5, 0))
	arrowItem:setScale(itemscale)
	arrowItem:setPosition(ftCenterPoint.x, ftCenterPoint.y )
	-- arrowItem:drawBoundingBox()
	arrowItem:setRotation(_atob * rotation * _rt - 20 * _rt * _at)

	-- 播放动画
	if isAction then
		local spwArray = cc.Array:create()
		spwArray:addObject(CCRotateBy:create(0.55, 40 * _rt))
		spwArray:addObject(CCFadeIn:create(0.55))
		arrowItem:runAction(transition.sequence({cc.Spawn:create(spwArray), cc.CallFunc:create(function ()
			if actionCallback then actionCallback() end
		end)}) )
	end
	
end

--判断当前区域块ID
local function getCurrentChapter(chapter)
	-- local _chapter = chapter + 1
	-- local areainof = ActivityCenterMO.getRedPlanArea(_chapter)
	-- if areainof then
	-- 	return _chapter
	-- end
	if chapter == 0 then
		return 1
	end

	return chapter
end










----------------------------------------------------------
--						地区					--
----------------------------------------------------------
local AreaNode = class("AreaNode", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function AreaNode:ctor(info, localInfo, activityAwardId, stateCallback)
	self.m_info = info
	self.m_localInfo = localInfo
	self.m_activityAwardId = activityAwardId
	self.m_stateCallback = stateCallback
end

function AreaNode:onEnter()
	self.startPoint = nil
	self.endPoint = nil
	self.ischange = false
	self.m_item = nil

	-- --body
	local item = display.newSprite(IMAGE_COMMON .. "redplan/map_" .. self.m_info.areaId .. "_1.png"):addTo(self)
	item:setPosition(self.m_localInfo.ccp.x, self.m_localInfo.ccp.y)
	-- self.m_item = item

	local arealName = display.newSprite(IMAGE_COMMON .. "redplan/map_name_" .. self.m_info.areaId ..".png"):addTo(self,999)
	arealName:setPosition(self.m_localInfo.nameccp.x, self.m_localInfo.nameccp.y)

	local sp = json.decode(self.m_info.startPoint)
	if table.getn(sp) > 0 then
		self.startPoint = cc.p(sp[1], sp[2])
	end
	local ep = json.decode(self.m_info.endPoint)
	if table.getn(ep) > 0 then
		self.endPoint = cc.p(ep[1], ep[2])
	end
	
end

function AreaNode:setSandData(data)
	if not data then return end
	if self.m_item then
		self.m_item:removeSelf()-- 是否移除处理需要和策划商定
	end
	local state = data
	local curState = 1
	--body
	-- self.m_info.areaId 自己的区域ID
	-- if self.m_item then
	-- 	self.m_item:removeSelf()
	-- 	self.m_item = nil
	-- end
	if state > 1 then
		local nextState = ActivityCenterMO.redPlanMapInfo_.areaInfo[self.m_info.areaId + 1]
		if state >= 3 then
			if self.m_info.areaId == ActivityCenterMO.redPlanMapInfo_.nowAreaId and ActivityCenterMO.redPlanMapInfo_.isfirst == 0 then
				curState = 3
			else
				curState = 4
			end
		else
			if nextState == 1 then
				curState = 2
			end
		end

		-- -- 正在打
		-- if state == 2 then
		-- 	-- 判断 下家 状态是否为1 ,== 1 curState = 2,否则 = 3
		-- 	local nextState = ActivityCenterMO.redPlanMapInfo_.areaInfo[self.m_info.areaId + 1]
		-- 	if nextState then
		-- 		if nextState == 1 then
		-- 			curState = 2
		-- 		else
		-- 			curState = 3
		-- 		end
		-- 	end
		-- elseif state >= 3 then
		-- 	if self.m_info.areaId == ActivityCenterMO.redPlanMapInfo_.nowAreaId and ActivityCenterMO.redPlanMapInfo_.isfirst == 0 then
		-- 		curState = 3
		-- 	else
		-- 		curState = 4
		-- 	end
		-- end

		local item = display.newSprite(IMAGE_COMMON .. "redplan/map_" .. self.m_info.areaId .. "_"..curState..".png"):addTo(self)
		item:setPosition(self.m_localInfo.ccp.x, self.m_localInfo.ccp.y)
		self.m_item = item
	end
end

function AreaNode:changeState(state)
	self.ischange = state
end

function AreaNode:checkColor(color)
	if self.ischange then
		return false
	end
	if color.b == self.m_localInfo.colorType then
		return true
	end
	return false
end

function AreaNode:DoSomeTh()
	-- dump(ActivityCenterMO.redPlanMapInfo_.areaInfo,"touch DOsome")
	--
	local function resultCallback(data)
		require("app.view.RedplanBattleView").new(self.m_activityAwardId, self.m_info.areaId, data):push()
	end
	ActivityCenterBO.GetRedPlanAreaInfo(resultCallback, self.m_info.areaId)
end

-- 取消
function AreaNode:CancelHState()
	
end

-- 播放变色动画
function AreaNode:showChangeAct(callback)
	-- if self.m_item then
	-- 	self.m_item:removeSelf()-- 是否移除处理需要和策划商定
	-- end
	-- self.ischange = true
	-- local toItem = display.newSprite(IMAGE_COMMON .. "redplan/map_" .. self.m_info.areaId .. "_4.png"):addTo(self)
	-- toItem:setPosition(self.m_localInfo.ccp.x, self.m_localInfo.ccp.y )
	-- toItem:setScale(0)
	-- toItem:runAction(cc.ScaleTo:create(0.3,1))
	local barIcon = display.newSprite(IMAGE_COMMON .. "redplan/map_" .. self.m_info.areaId .. "_4.png")
	local bar = CCProgressTimer:create(barIcon):addTo(self)
	bar:setPosition(self.m_localInfo.ccp.x, self.m_localInfo.ccp.y)
	bar:setType(1)
	bar:setBarChangeRate(cc.p(1,0))
	bar:setMidpoint(cc.p(0,0))
	bar:setPercentage(0)
	bar:runAction(transition.sequence({CCProgressTo:create(2, 100), cc.CallFunc:create(function() 
		if callback then callback() end
		if self.m_stateCallback then self.m_stateCallback(false) end
		end)}))
end








----------------------------------------------------------
--						世界地图地区					--
----------------------------------------------------------
local AreaWorldView = class("AwardProgressView", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function AreaWorldView:ctor(size, activityAwardId)
	self:setContentSize(size)
	self.m_activityAwardId = activityAwardId
end

function AreaWorldView:onEnter()

	nodeTouchEventProtocol(self, function(event)
        return self:onTouch(event)
    end, cc.TOUCH_MODE_ALL_AT_ONCE, nil, true)

    local heightDex = 87

    -- ccp 地图块的位置
    --nameccp 图块名字的位置
    --layer 层级
	self.localAreaInfos = {
		[1] = {ccp = cc.p(433, 471 + heightDex), colorType = 115, layer = 3, nameccp = cc.p(430, 475 + heightDex)},
		[2] = {ccp = cc.p(190, 540 + heightDex), colorType = 25, layer = 6, nameccp = cc.p(180, 560 + heightDex)},
		[3] = {ccp = cc.p(110, 682 + heightDex), colorType = 55, layer = 5, nameccp = cc.p(100, 670 + heightDex)},
		[4] = {ccp = cc.p(261, 604 + heightDex), colorType = 85, layer = 4, nameccp = cc.p(280, 650 + heightDex)},
		[5] = {ccp = cc.p(458, 614 + heightDex), colorType = 145, layer = 2, nameccp = cc.p(435, 575 + heightDex)},
		[6] = {ccp = cc.p(510 + 1, 595 + heightDex), colorType = 185, layer = 3, nameccp = cc.p(580, 580 + heightDex)}
	}

	self.m_couldTouch = true
	self.m_touchState = false

    self.m_areasInfo = ActivityCenterMO.getRedPlanArea()

    self.m_AreaNodes = {}
    self.m_CourseAreaID = nil

	-- 色盘
	local image = CCImage:new()
	image:initWithImageFile(IMAGE_COMMON .. "redplan/colormap.png")
	local texture = CCTextureCache:sharedTextureCache():addUIImage(image,nil)
	texture:retain()
	texture:autorelease()
	local colorWorldMap = display.newSprite()
    colorWorldMap:setTexture(texture)
    colorWorldMap:setPosition(self:width() * 0.5, self:height() * 0.5)
    colorWorldMap:addTo(self, LOCAL_REDPLAN_MAPCOLOR)
    colorWorldMap:setVisible(false)
    self.m_colormap = colorWorldMap
    self.m_MapImage = image
    self.m_MapTexture = texture

    self.m_widthDex = (self:width() - colorWorldMap:width() ) * 0.5
	self.m_colorMapHeight = colorWorldMap:height()


    self:Init()
    -- self:doLoad() -- 拉取网络信息

    self.m_frameTime = 0
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()

    -- 提示文字
    local tipLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = cc.c3b(255, 255, 255)}):addTo(self, LOCAL_TIP_LABEL)
    tipLabel:setAnchorPoint(cc.p(0,0.5))
    tipLabel:setPosition(40, self:height() - 155)
    tipLabel.opacity = 255
    tipLabel.time = 256
    tipLabel.str = ""
    tipLabel.posX = 40
    tipLabel.posY = self:height() - 155
    local function UpdateTipLabel(_self)
    	_self.time = _self.time + 4
    	if _self.time > 100000000 then _self.time = 256 end
    	if _self.time < 256 then
    		_self:setString(_self.str)
    		_self:setOpacity(_self.opacity - _self.time)
    		_self:setPosition(_self.posX, _self.posY + _self.time * 0.25)
    		if _self.opacity - _self.time < 10 then
    			_self:setOpacity(0)
    			_self:setString("")
    			_self.time = 256
    		end
    	end
    end
    local function PutTipLabel(_self, str)
    	if _self.time < 1000 then return end
    	_self.time = 0
    	_self.str = str
    	_self:setPosition(_self.posX, _self.posY)
    end
    self.m_tipLabel = tipLabel
    self.m_tipLabel.updateFunc = UpdateTipLabel
    self.m_tipLabel.putFunc = PutTipLabel
end

function AreaWorldView:onEnterFrame(dt)
	self.m_frameTime = self.m_frameTime + 1
	if self.m_frameTime > 1000000 then self.m_frameTime = 0 end

	self.m_tipLabel:updateFunc()
end

-- function AreaWorldView:doLoad()
-- 	ActivityCenterBO.getRedPlanInfo(handler(self,self.loadInfo))
-- end

function AreaWorldView:loadInfo()
	local spys = ActivityCenterMO.redPlanMapInfo_.areaInfo

	for k , v in pairs(spys) do
		self.m_AreaNodes[k]:setSandData(v)
	end
end

function AreaWorldView:Init()
	for k , v in pairs(self.m_areasInfo) do
		local areasInfo = v
		local localInfo = self.localAreaInfos[areasInfo.areaId]
		local areaNode = AreaNode.new(areasInfo, localInfo, self.m_activityAwardId, handler(self, self.changeAllState)):addTo(self,LOCAL_REDPLAN_AREANODE + localInfo.layer )
		self.m_AreaNodes[areasInfo.areaId] = areaNode
	end
end

function AreaWorldView:changeAllState(state)
	for k, v in pairs(self.m_AreaNodes) do
		v:changeState(state)
	end
end

function AreaWorldView:setCurrentAreaState(areaId, state)
	local areanode = self.m_AreaNodes[areaId]
	if areanode then
		areanode:setSandData(state)
	end
end

--播放某块区域变色动画
-- index
function AreaWorldView:playArealChangeAct(index, callback)
	self:changeAllState(true)
	self.m_AreaNodes[index]:showChangeAct(callback)
end

function AreaWorldView:onTouch(event)
	if not self.m_couldTouch then return false end

	if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    end
end

function AreaWorldView:onTouchBegan(event)
	local touchevent = event.points["0"]
	local x = touchevent.x 
	local y = touchevent.y - (display.height - self.m_colorMapHeight) * 0.5
	local _x = x - self.m_widthDex
	local _y = self.m_colorMapHeight - y
	self.m_BeganPoint = cc.p(x, y)
	if self.m_MapImage then
		local color = self.m_MapImage:getColor4B(_x,_y)
		for k, v in pairs(self.m_AreaNodes) do
			if not self.m_CourseAreaID then
				if v:checkColor(color) then
					self.m_touchState = true
					return true
				end
			else
				-- 教程引导
				-- print("onTouchBegan - self.m_CourseAreaID " .. self.m_CourseAreaID .. " "..k)
				if v:checkColor(color) then
					if k == self.m_CourseAreaID then
						self.m_touchState = true
						return true
					else
						self.m_tipLabel:putFunc("请先完成区域"..k .. "引导")
					end
				end
			end
		end
	end
	return false
end

function AreaWorldView:onTouchMoved(event)
	local point = event.points["0"]
	local _point = cc.p(point.x, point.y - (display.height - self.m_colorMapHeight) * 0.5)
	if self.m_BeganPoint then
		if _point.x > self.m_BeganPoint.x + 2 or 
			_point.x < self.m_BeganPoint.x - 2 or 
			_point.y > self.m_BeganPoint.y + 2 or
			_point.y < self.m_BeganPoint.y - 2 then
			self.m_touchState = false
		end
	end
end

function AreaWorldView:onTouchEnded(event)
	self.m_BeganPoint = nil
	if not self.m_touchState then return end
	local touchevent = event.points["0"]
	local x = touchevent.x 
	local y = touchevent.y - (display.height - self.m_colorMapHeight) * 0.5
	local _x = x - self.m_widthDex
	local _y = self.m_colorMapHeight - y

	if self.m_MapImage then
		local color = self.m_MapImage:getColor4B(_x,_y)
		local isClean = false
		for k, v in pairs(self.m_AreaNodes) do
			if v:checkColor(color) then
				-- do something 切换界面
				-- 打开相关的二级界面
				local currentChapter = getCurrentChapter(ActivityCenterMO.redPlanMapInfo_.nowAreaId)
				if not self.m_CourseAreaID then
					local isENTER = true
					for i = 1 , #ActivityCenterMO.redPlanMapInfo_.areaInfo do
						local s_ = ActivityCenterMO.redPlanMapInfo_.areaInfo[i]
						if s_ == 2 then
							if i == k then
								isENTER = true 
								break
							else
								isENTER = false
							end
						else
							if currentChapter == k then
								isENTER = true
								break
							end
							isENTER = false
						end
					end
					if isENTER then
						-- print("not self.m_CourseAreaID  ====== " .. ActivityCenterMO.redPlanMapInfo_.nowAreaId)
						v:DoSomeTh()
					else
						if ActivityCenterMO.redPlanMapInfo_.nowAreaId == 0 then
							v:DoSomeTh()
						else
							self.m_tipLabel:putFunc("请先完成正在进行的区域")
						end
						-- self.m_tipLabel:putFunc("请先完成正在进行的区域")
					end
				elseif self.m_CourseAreaID and (currentChapter and currentChapter == k) then
					-- print("self.m_CourseAreaID  -- " .. ActivityCenterMO.redPlanMapInfo_.nowAreaId)
					v:DoSomeTh()
				end
				-- v:DoSomeTh()
				isClean = true
			else
				v:CancelHState()
			end
		end

		if isClean then
			-- print("~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^",tostring(self.m_CourseAreaID))
			if self.m_CourseAreaID then self.m_CourseAreaID = nil end
		end
	end
end

function AreaWorldView:setCourseAreadId(areaid)
	self.m_CourseAreaID = areaid
end

function AreaWorldView:onExit()
	if self.m_colormap then
		self.m_colormap:removeSelf()
	end
	
	if self.m_MapImage then
		self.m_MapImage:delete()
	end

	if self.m_MapTexture then
		self.m_MapTexture:release()
	end
end


















----------------------------------------------------------
--							红色方案					--
----------------------------------------------------------
local ActivityCommunismView = class("ActivityCommunismView",function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function ActivityCommunismView:ctor(activity)
	self.m_activity = activity
	dump(self.m_activity)
	self:setContentSize(display.width,display.height)
	nodeTouchEventProtocol(self, function() end, nil, nil, true)
end

function ActivityCommunismView:onEnter()

	armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
	armature_add(IMAGE_ANIMATION .. "effect/redplan_lang.pvr.ccz", IMAGE_ANIMATION .. "effect/redplan_lang.plist", IMAGE_ANIMATION .. "effect/redplan_lang.xml")
	------------------------------- head -------------------------------
	local titleNode = display.newNode():addTo(self, LOCAL_UI)
	titleNode:setPosition(0,0)

	-- bg_ui_head
	local headBg = display.newSprite(IMAGE_COMMON .. "bg_ui_head.png"):addTo(titleNode)
	headBg:setAnchorPoint(cc.p(0.5,1))
	headBg:setPosition(display.cx,display.height)
	local function hidHead()
		headBg:setPosition(display.cx,display.height + headBg:height())
	end
	local function actionHead()
		headBg:runAction(CCMoveTo:create(0.9, cc.p(display.cx,display.height)))
	end
	self.m_headBg = headBg
	self.m_headBg.hideFunc = hidHead
	self.m_headBg.actionFunc = actionHead
	self.m_headBg.hideFunc()

	local normal = display.newSprite(IMAGE_COMMON .. "btn_return_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_return_selected.png")
	local closeBtn = MenuButton.new(normal, selected, nil, handler(self, self.closeBtnCallback)):addTo(headBg)
	closeBtn:setPosition(headBg:getContentSize().width / 2 - 270, headBg:getContentSize().height - 56)

	local title = ui.newTTFLabel({text = CommonText[5029][1], font = G_FONT, size = FONT_SIZE_BIG, align = ui.TEXT_ALIGN_CENTER,
					x = headBg:getContentSize().width / 2, y = headBg:getContentSize().height - 54}):addTo(headBg, 5)



	------------------------------- main ui -------------------------------
	--背景图
	local map = display.newSprite(IMAGE_COMMON .. "redplan/map_bg.jpg"):addTo(self):center()
	self.m_map = map
	self.m_map:setScale(1.2)

	--商店
	local normal = display.newSprite(IMAGE_COMMON .. "redplan/redplan_shop.png")
	local shopBtn = ScaleButton.new(normal, handler(self, self.showShop)):addTo(map,10)
	shopBtn:setPosition(170, 260)

	--水浪动画
	local lang = armature_create("redplan_lang"):addTo(map,9)
	lang:setPosition(170, 260)
	lang:getAnimation():playWithIndex(0)

	--商店吆喝
	local sellBG = display.newSprite(IMAGE_COMMON .. "redplan/shop_talk.png"):addTo(map,10)
	sellBG:setScale(1.3)
	sellBG:setPosition(200,330)
	--是否可点击进入商店
	-- sellBG:setTouchEnabled(true)
	-- sellBG:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
	-- 	if event.name == "began" then
	-- 		return true
	-- 	elseif event.name == "ended" then
	-- 	self:showShop()
	-- 	end
	-- end)

	local sellLab = UiUtil.label(CommonText[5033],12):addTo(sellBG)
	sellLab:setPosition(sellBG:width() / 2, sellBG:height() / 2 + 10)

	local function detailTextCallback()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.redplanHelper):push()
	end
	-- detail描述
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, detailTextCallback):addTo(map,10)
	detailBtn:setPosition(map:width() - detailBtn:width() * 0.5, display.height - (display.height * 0.5 - map:height() * 0.5 ) - 150)

	--地图块
	local size = cc.size(self:width() , self:height())
	local AreaWorld = AreaWorldView.new(size, self.m_activity.awardId):addTo(map, 2)
	AreaWorld:setAnchorPoint(cc.p(0.5,0.5))
	AreaWorld:setPosition(self:width() * 0.5, self:height() * 0.5)
	self.m_AreaWorld = AreaWorld

	--锯齿城墙
	local wall = display.newSprite(IMAGE_COMMON .. "redplan/wall.png"):addTo(map,3)
	wall:setPosition(430,600)
	wall:setVisible(false)
	self.m_wall = wall

	self:showWall()

	self.m_loadingLayer = self:loadingLayer()
	self.m_time = 5

	self:sendSocket()

	self.m_timeScheduler = scheduler.scheduleGlobal(handler(self, self.onUpdateTime), 1)
end

function ActivityCommunismView:onUpdateTime(ft)
	if ActivityCenterMO.getRedPlanFuelLimit().recoverLimit and ActivityCenterMO.redPlanFuelInfo.fuel then
		if ActivityCenterMO.redPlanFuelInfo.fuel < ActivityCenterMO.getRedPlanFuelLimit().recoverLimit then
			ActivityCenterMO.redPlanFuelInfo.fuelTime = ActivityCenterMO.redPlanFuelInfo.fuelTime - 1
			if ActivityCenterMO.redPlanFuelInfo.fuelTime < 0 then
				ActivityCenterMO.redPlanFuelInfo.fuel = ActivityCenterMO.redPlanFuelInfo.fuel + 1
				ActivityCenterMO.redPlanFuelInfo.fuelTime = ActivityCenterMO.getRedPlanFuelLimit().recoverSpan
			end
		end
	end
	self.m_time = self.m_time - 1
	if self.m_time <= 1 and self.m_time > 0 then
		self.m_time = 5
		UiDirector.pop()
		Toast.show("活动未开启或已结束")
	end
end

function ActivityCommunismView:sendSocket(toarea)
	--拉取信息，信息返回后进行下一步
	if self.m_arrowNode then
		self.m_arrowNode:removeSelf()
		self.m_arrowNode = nil
	end

	ActivityCenterBO.getRedPlanInfo(function (data)
		-- local isfirst = false
		-- local currentIndex = getCurrentChapter(data.nowAreaId)
		-- local function enterMap()
		-- 	--如果是第一次进入活动
			-- if data.isfirst == 1 then
			-- 	isfirst = true
			-- 	require("app.view.PlotTalkView").new(currentIndex,"redplan/redplan_bg.jpg",isfirst):addTo( self, LOCAL_UI + 1)
			-- end
		-- end
		-- enterMap()
		self:showWall()
		self.m_time = 0

		if self.m_loadingLayer and self.m_loadingLayer.openFunc then
			self.m_loadingLayer.openFunc(handler(self, self.openAction))
		end
		-- self.m_AreaWorld:loadInfo()
		if not self:istakeCourse(toarea) then
			self:curseCallback()
		end
	end)
end

function ActivityCommunismView:openAction()
	-- body
	if self.m_headBg.actionFunc then
		self.m_headBg.actionFunc()
	end
	if self.m_map then
		self.m_map:runAction(CCScaleTo:create(0.5,1))
	end
end

function ActivityCommunismView:curseCallback()
	self.m_AreaWorld:loadInfo()
end

function ActivityCommunismView:istakeCourse(toarea)
	local areaStateInfo = ActivityCenterMO.redPlanMapInfo_.areaInfo

	--判断当前打的是第几关
	for index =1,#areaStateInfo do
		if areaStateInfo[index] == 2 then
			return false
		else
			if areaStateInfo[index - 1] and areaStateInfo[index + 1] then
				if areaStateInfo[index + 1] == 1 and areaStateInfo[index - 1] > 2 and areaStateInfo[index] == 1 then
					ActivityCenterMO.redPlanMapInfo_.nowAreaId = index
					break
				end
			elseif areaStateInfo[index - 1] and areaStateInfo[index - 1] > 2 and areaStateInfo[index] == 1 and (not areaStateInfo[index + 1]) then
				ActivityCenterMO.redPlanMapInfo_.nowAreaId = index
			-- elseif areaStateInfo[index - 1] and (not areaStateInfo[index + 1]) and areaStateInfo[index - 1] > 3 then
			-- 	ActivityCenterMO.redPlanMapInfo_.nowAreaId = index
			end
		end
	end

	local nowAreaId = toarea or ActivityCenterMO.redPlanMapInfo_.nowAreaId
	if nowAreaId == 0 and ActivityCenterMO.redPlanMapInfo_.isfirst == 1 then
		require("app.view.PlotTalkView").new(1,"redplan/redplan_bg.jpg",true):addTo( self, LOCAL_UI + 1)
		return true
	end


	for index = 1 , #areaStateInfo do
		local area = areaStateInfo[index]
		if index == nowAreaId and area == 1 then
			self:playArealExchange(nowAreaId - 1, true,function ()
				require("app.view.PlotTalkView").new(nowAreaId,nil,false):addTo( self, LOCAL_UI + 1)
			end)
			return true --需要走引导
		elseif area >= 3 and index ~= (nowAreaId - 1) then
			self.m_AreaWorld:setCurrentAreaState(index, area)
		end
	end

	return false
end

--传入两个点pointa, pointb
--isforward 为true是正方向
-- areaid 引导的当前区域ID
function ActivityCommunismView:showArrowAct(areaid, pointa, pointb,isforward)
	local begain, ended = pointa, pointb
	local arrowNode = display.newNode():addTo(self.m_map,5)
	arrowNode:setPosition(0,0)
	self.m_arrowNode = arrowNode

	arrowRoundShow(arrowNode, begain, ended, isforward)

	--播放手的动画
	self:performWithDelay(function ()
		self:handShow(arrowNode,ended)
	end, 1)
	self.m_AreaWorld:setCourseAreadId(areaid)
end

--播放区域块变色动画
--changeIndex 变化的区域块
function ActivityCommunismView:playArealExchange(changeIndex, iscall,callback)
	iscall = iscall or false
	local function doCallabck()
		if callback then
			callback()
		end
		if iscall then
			self:curseCallback()
		end
	end
	self.m_AreaWorld:playArealChangeAct(changeIndex, doCallabck)
end

--显示锯齿城墙，且进行下一步对话
function ActivityCommunismView:showWall()
	--如果第一关已经打了。且倒数第二关没打通关，则显示城墙
	if ActivityCenterMO.redPlanMapInfo_.areaInfo and ActivityCenterMO.redPlanMapInfo_.areaInfo[1] >= 3 and ActivityCenterMO.redPlanMapInfo_.areaInfo[#ActivityCenterMO.redPlanMapInfo_.areaInfo - 1] < 3 then
		self.m_wall:setVisible(true)
		self.m_wall:runAction(cc.FadeIn:create(1))
		return
	end

	self.m_wall:setVisible(false)
end

function ActivityCommunismView:handShow(node, point)
	local light = armature_create("ryxz_dianji",point.x,point.y):addTo(node,LOCAL_ARROW + 1)
	light:getAnimation():playWithIndex(0)
end

function ActivityCommunismView:showShop()
	require("app.scroll.RedplanShopTableView").new():push()
end


-- 开门动画
function ActivityCommunismView:loadingLayer()
	local dex = 0--93
	local node = display.newNode():addTo(self,9999)
	node:setPosition(0,0)
	node:setTouchEnabled(true)
	node:setTouchSwallowEnabled(true) --防止点击到下一层

	local white = display.newColorLayer(ccc4(255, 255, 255, 255)):addTo(node,5)
	white:setContentSize(cc.size(display.width, display.height - dex))
	white:setPosition(0, 0)

	local leftNode = display.newNode():addTo(node,10)
	leftNode:setPosition(0,0)

	local black = display.newColorLayer(ccc4(0, 0, 0, 255)):addTo(leftNode)
	black:setContentSize(cc.size(display.width * 0.5, display.height - dex))
	black:setPosition(0, 0)

	local lld = display.newSprite(IMAGE_COMMON .. "redplan/show1.png"):addTo(leftNode,2)
	lld:setAnchorPoint(cc.p(1,0.5))
	lld:setPosition(display.width * 0.5, display.height * 0.5 + 120)

	-- local lui = ui.newTTFLabel({text = CommonText[5034][1], font = G_FONT, size = 100, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 0, 0)}):addTo(leftNode, 3)
	-- lui:setAnchorPoint(cc.p(1,0.5))
	-- lui:setPosition(display.width * 0.5, display.height * 0.5 - 200)
    


	local rightNode = display.newNode():addTo(node,10)
	rightNode:setPosition(display.width,0)

	local black1 = display.newColorLayer(ccc4(0, 0, 0, 255)):addTo(rightNode)
	black1:setContentSize(cc.size(display.width * 0.5, display.height - dex))
	black1:setPosition(-display.width * 0.5, 0)

	local rld = display.newSprite(IMAGE_COMMON .. "redplan/show2.png"):addTo(rightNode,2)
	rld:setAnchorPoint(cc.p(0,0.5))
	rld:setPosition(-display.width * 0.5, display.height * 0.5 + 120)

	-- local rui = ui.newTTFLabel({text = CommonText[5034][2], font = G_FONT, size = 100, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 0, 0)}):addTo(rightNode, 3)
	-- rui:setAnchorPoint(cc.p(0,0.5))
	-- rui:setPosition(-display.width * 0.5, display.height * 0.5 - 200)

	local function doclear()
		node:removeSelf()
		node = nil
	end
	
	local function openthedoor(callback)
		leftNode:runAction(CCOrbitCamera:create(1, 1, 0, 0, 90, 0, 0))
		rightNode:runAction(CCOrbitCamera:create(1, 1, 0, 0, -90, 0, 0))
		white:runAction(transition.sequence({cc.DelayTime:create(0.4),CCFadeOut:create(0.8),cc.CallFunc:create(function ()
			doclear()
			-- if callback then callback() end
		end)}))
		node:runAction(transition.sequence({cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
			if callback then callback() end
		end)}))
	end
	node.openFunc = openthedoor

	return node
end

function ActivityCommunismView:closeBtnCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local name = UiDirector.getTopUiName()
	if name == self:getUiName() then
		return UiDirector.pop(popCallback)
	else
		gprint("[UiNode] pop Error! name:", name)
	end
end

function ActivityCommunismView:refreshUIttt(toarea)
	-- if name == "RedplanBattleView" then
	-- 	-- local nowAreaid = ActivityCenterMO.redPlanMapInfo_.nowAreaId
	-- 	-- dump(ActivityCenterMO.redPlanMapInfo_,"======= refreshUI")
	-- 	-- local nextAreaState = ActivityCenterMO.redPlanMapInfo_.areaInfo[nowAreaid + 1]
	-- 	-- if nextAreaState and nextAreaState == 2 then
	-- 		self:sendSocket()
	-- 	-- end
	-- end
	-- print("[ActivityCommunismView]   refreshUIttt === to " .. tostring(toarea) )
	self:sendSocket(toarea)
end
--------------- protected mothed ----------------------
function ActivityCommunismView:getUiName()
	return self.__cname
end

function ActivityCommunismView:onExit()

	if self.m_timeScheduler then
		scheduler.unscheduleGlobal(self.m_timeScheduler)
		self.m_timeScheduler = nil
	end

	ActivityCenterMO.redPlanFuelInfo.fuel = nil

	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/redplan_lang.pvr.ccz", IMAGE_ANIMATION .. "effect/redplan_lang.plist", IMAGE_ANIMATION .. "effect/redplan_lang.xml")

end

return ActivityCommunismView