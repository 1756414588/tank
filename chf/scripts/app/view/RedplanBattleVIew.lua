--
-- Author: Gss
-- Date: 2018-03-22 16:49:11
--
--红色方案战场view

----------------------------------------------------------
--						奖励显示						--
----------------------------------------------------------
-- 奖励显示
local Dialog = require("app.dialog.Dialog")

local GiftShowDilog = class("GiftShowDilog", Dialog)

function GiftShowDilog:ctor(showdata,text)
	GiftShowDilog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 330)})
	self.Showdata = showdata
	self.text = text or ""
end

function GiftShowDilog:onEnter()
	GiftShowDilog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:hasCloseButton(true)
	self:setTitle(CommonText[1057][2])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(558, 300))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local lb_time_title = ui.newTTFLabel({text = self.text, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(self:getBg())
	lb_time_title:setPosition(self:getBg():getContentSize().width / 2 , self:getBg():getContentSize().height * 0.5 + 70)


	local centerX = self:getBg():getContentSize().width * 0.5
	local size = #self.Showdata

	for index = 1 , size do
		local _db = self.Showdata[index]
		local kind , id ,count = _db[1], _db[2], _db[3]

		-- 元素
		local item = UiUtil.createItemView(kind,id,{count = count}):addTo(self:getBg())
		item:setPosition(centerX + CalculateX(size, index,  item:getContentSize().width , 1.2) ,self:getBg():getContentSize().height * 0.5 - 10)
		UiUtil.createItemDetailButton(item)

		local namedata = UserMO.getResourceData(kind,id)
		local name = UiUtil.label(namedata.name2,FONT_SIZE_SMALL,COLOR[1]):addTo(self:getBg())
		name:setPosition(item:getPositionX() , item:getPositionY() - item:getContentSize().height * 0.5 - name:getContentSize().height * 0.5 - 10)

	end
end

function GiftShowDilog:onExit()
	GiftShowDilog.super.onExit(self)
end

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- node 节点
-- formpoint 出发点
-- topoint 目的地
-- isforward 是否正方向
local function arrowRoundShow(node, formpoint, topoint, isforward, isAction, actionCallback)
	local isforward = isforward and isforward == 0 and true or false -- 是否正方向
	local isAction = isAction or false
	local _xwidth = topoint.x - formpoint.x -- 两点宽度间距
	local _yheight = topoint.y - formpoint.y -- 两点高度间距
	local arrowicon = "arrow_ra2.png"
	local va = Vec(1, 0)
	local _rt = 1
	local _at = 1
	local _atob = 1
	-- 是否正方向
	if isforward then
		arrowicon = "arrow_re2.png"
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
	local arrowItem = display.newSprite(IMAGE_COMMON .. "redplan/" .. arrowicon):addTo(node, 5)

	local fromVec = Vec(formpoint.x, formpoint.y)
	local toVec = Vec(topoint.x, topoint.y)
	local targetVec = fromVec * (1- 0.3) + toVec * 0.3


	-- 相关变量
	local ftCenterPoint = cc.p(formpoint.x + _xwidth * 0.5, formpoint.y + _yheight * 0.5) -- 中心点
	local ftDistance = math.sqrt(math.pow(_xwidth, 2) + math.pow(_yheight, 2)) -- 两点绝对间距
	local itemDistance = arrowItem:width() -- 图片真实间距(包含旋转)
	local itemscale = ftDistance / itemDistance -- 自然缩放
	local vb = Vec(_xwidth, _yheight)
	local _ra = (va * vb) / (va.modulus() * vb.modulus())
	local rotation = math.deg(math.acos( _ra )) -- 旋转角度

	-- 设置箭头
	arrowItem:setAnchorPoint(cc.p(0.5, 0))
	arrowItem:setScale(itemscale)
	arrowItem:setPosition(targetVec.x, targetVec.y )
	-- arrowItem:drawBoundingBox()
	arrowItem:setRotation(_atob * rotation * _rt ) -- - 20 * _rt * _at)

	-- 播放动画
	if isAction then
		local spwArray = cc.Array:create()
		-- spwArray:addObject(CCRotateBy:create(0.55, 40 * _rt))
		spwArray:addObject(CCMoveTo:create(0.55, cc.p(ftCenterPoint.x, ftCenterPoint.y)))
		spwArray:addObject(CCFadeIn:create(0.55))
		arrowItem:runAction(transition.sequence({cc.Spawn:create(spwArray), cc.CallFunc:create(function ()
			if actionCallback then actionCallback() end
		end)}) )
	else
		arrowItem:setPosition(ftCenterPoint.x, ftCenterPoint.y )
	end
	
	return arrowItem
end

--------------------------------------------------------------
--							奖励							--
--------------------------------------------------------------
local Dialog = require("app.dialog.DialogEx")
local RedPlanAwardDialog = class("RedPlanAwardDialog", Dialog)

function RedPlanAwardDialog:ctor(dataInfo, callback, isOver)
	RedPlanAwardDialog.super.ctor(self)
	self.m_awarddata = dataInfo
	self.m_callback = callback
	self.m_isOver = isOver or false
end

function RedPlanAwardDialog:onEnter()
	RedPlanAwardDialog.super.onEnter(self)

	armature_add(IMAGE_ANIMATION .. "effect/jiangliban.pvr.ccz", IMAGE_ANIMATION .. "effect/jiangliban.plist", IMAGE_ANIMATION .. "effect/jiangliban.xml")

	local awardType = self.m_awarddata.awardType - 1
	local _awardType = awardType * 2

	local btm = armature_create("jiangliban", 0, 0 ,function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:getAnimation():playWithIndex(_awardType + 1)
			end
		end):addTo(self, 2)
	btm:setPosition(display.cx, display.cy + 180)
	btm:getAnimation():playWithIndex(_awardType)

	local node = display.newNode()
	self.m_viewbg = node


	local awards = self.m_awarddata.awards
	local awardCount = #awards
	for index = 1, awardCount do
		local award = awards[index]
		local type = award.type
		local id = award.id
		local count = award.count
		local item = UiUtil.createItemView(type, id, {count = count}):addTo(self, 4)
		item:setPosition(display.cx + CalculateX(awardCount, index, item:width(), 1.1) ,display.cy + 10 )
		UiUtil.createItemDetailButton(item)

		local dataInfo = UserMO.getResourceData(type, id)
		local name = ui.newTTFLabel({text = dataInfo.name, font = G_FONT, size = FONT_SIZE_SMALL, x = item:x(), y = display.cy - 70, align = ui.TEXT_ALIGN_CENTER, color = COLOR[dataInfo.quality]}):addTo(self, 4)
	end


	local normal = display.newSprite(IMAGE_COMMON .. "btn_ok.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_ok.png")
	local takeBtn = MenuButton.new(normal, selected, nil, handler(self, self.takeCallback)):addTo(self,10)
	takeBtn:setPosition(display.cx, display.cy - 160)
	takeBtn:setLabel(CommonText[870][2])
end

function RedPlanAwardDialog:takeCallback(tar, sender)
	self:close()
	if self.m_callback then self.m_callback(self.m_isOver) end
	if self.m_awarddata.statsAward then
		UiUtil.showAwards(self.m_awarddata.statsAward)
	end
end

function RedPlanAwardDialog:onExit()
	RedPlanAwardDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/jiangliban.pvr.ccz", IMAGE_ANIMATION .. "effect/jiangliban.plist", IMAGE_ANIMATION .. "effect/jiangliban.xml")
end





--修改文件名字区分大小写。
--------------------------------------------------------------
--							战场							--
--------------------------------------------------------------
local RedplanBattleView = class("RedplanBattleView", UiNode)

-- chapter 当前是第几战场
function RedplanBattleView:ctor(activityAwardId, chapter, data)
	RedplanBattleView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	self.m_activityAwardId = activityAwardId or 14701
	self.m_chapter = chapter or 1 
	-- self.m_data = data
	self.m_data = {}
	self.m_data.pointIds = table.isexist(data, "pointIds") and data.pointIds or {}
	self.m_data.areaInfo = table.isexist(data, "areaInfo") and data.areaInfo or {}
	self.m_data.rewardInfo = table.isexist(data, "rewardInfo") and data.rewardInfo or 0
	self.m_data.nowAreaId = table.isexist(data, "nowAreaId") and data.nowAreaId or 0
	self.m_data.isfirst = table.isexist(data, "isfirst") and data.isfirst or 0
	self.m_data.historyPoint = table.isexist(data, "historyPoint") and data.historyPoint or {}
	self.m_data.perfect = table.isexist(data, "perfect") and data.isfirst or 0
end

function RedplanBattleView:onEnter()
	RedplanBattleView.super.onEnter(self)
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")

	self.m_AreaInfo = ActivityCenterMO.getRedPlanArea(self.m_chapter)

	self:setTitle(self.m_AreaInfo.name)

	self.m_touchState = true
	self.m_touchStateLimitTime = 0

	self.nextpoint = nil

	self.m_drawColor = ccc4f(0.5, 0.5, 0.5, 1)
	self.m_drawSize = 1

	-- armature_add(IMAGE_ANIMATION .. "effect/red_qizi.pvr.ccz", IMAGE_ANIMATION .. "effect/red_qizi.plist", IMAGE_ANIMATION .. "effect/red_qizi.xml")
	armature_add(IMAGE_ANIMATION .. "effect/red_sulianzhanlin.pvr.ccz", IMAGE_ANIMATION .. "effect/red_sulianzhanlin.plist", IMAGE_ANIMATION .. "effect/red_sulianzhanlin.xml")


	local m_points = ActivityCenterMO.getRedPlanPoints(self.m_activityAwardId, self.m_chapter)
	self.m_points = m_points

	-- --删除第一条和最后一条关卡ID数据
	-- local cData = clone(self.m_data.historyPoint)
	-- for ids=1,#cData do
	-- 	if cData[ids] == m_points[1].pid or cData[ids] == m_points[#m_points].pid then
	-- 		table.remove(cData,ids)
	-- 	end
	-- end

	local map = display.newSprite(IMAGE_COMMON .. "redplan/redmap_" .. self.m_chapter .. ".jpg"):addTo(self:getBg()):center()
	self.m_map = map

	local starP = json.decode(self.m_AreaInfo.startPosition)
	local endP = json.decode(self.m_AreaInfo.endPosition)

	--起点和终点图片
	local start = display.newSprite(IMAGE_COMMON .. "redplan/start_point.png"):addTo(map, 2)
	start:setPosition(starP[1], starP[2])

	local ended = display.newSprite(IMAGE_COMMON .. "redplan/end_point.png"):addTo(map, 2)
	ended:setPosition(endP[1], endP[2])

	-- 虚线
	local draw = cc.DrawNode:create():addTo(map, 1)
	self.m_draw = draw

	local titltlabbg = display.newSprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(self:getBg(), 2)
	titltlabbg:setAnchorPoint(cc.p(0,0.5))
	titltlabbg:setPosition(0, display.height - 125)
	titltlabbg:setScaleY(2)

	local fuelsp = display.newSprite(IMAGE_COMMON .. "redplan/fuel.png"):addTo(self:getBg(), 2)
	fuelsp:setAnchorPoint(cc.p(0,0.5))
	fuelsp:setScale(0.75)
	fuelsp:setPosition(25 , display.height - 125)

	local function fuelUpdate(_self, fuel)
		local _fcolor = fuel > 0 and cc.c3b(255, 255, 255) or cc.c3b(255, 0, 0)
		_self:setColor(_fcolor)
		_self:setString(tostring(fuel))
		_self.maxui:setPosition(_self:x() + _self:width(), _self:y())
		_self.fuelBtn:setPosition(_self.maxui:x() + _self.maxui:width() + 10 , _self.maxui:y())
		_self.time:setPosition(_self.fuelBtn:x() + _self.fuelBtn:width() , _self.fuelBtn:y())
	end

	local fuelNum = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg(), 2)
	fuelNum:setAnchorPoint(cc.p(0,0.5))
	fuelNum:setPosition(fuelsp:x() + fuelsp:width() * 0.75 + 10, fuelsp:y())

	local fuelMax = ui.newTTFLabel({text = "/" .. ActivityCenterMO.getRedPlanFuelLimit().recoverLimit, font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg(), 2)
	fuelMax:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
	local fuelBtn = ScaleButton.new(normal, handler(self, self.onBuyFuelCallback)):addTo(self:getBg(), 2)
	fuelBtn:setScale(0.5)
	fuelBtn:setAnchorPoint(cc.p(0,0.5))

	local fueltime = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg(), 2)
	fueltime:setAnchorPoint(cc.p(0, 0.5))
	
	self.m_fuelNum = fuelNum
	self.m_fuelNum.maxui = fuelMax
	self.m_fuelNum.fuelBtn = fuelBtn
	self.m_fuelNum.time = fueltime
	self.m_fuelNum.upFunc = fuelUpdate
	self.m_fuelNum:upFunc(ActivityCenterMO.redPlanFuelInfo.fuel)

	-- 解析 点对点的方向数组
	local function praseArrowDirection(padStr)
		local pad = json.decode(padStr)
		local outList = {}
		for index = 1 , #pad do
			local pi = pad[index]
			local out = {}
			out.key = pi[1]
			out.value = pi[2]
			outList[out.key] = out
		end
		return outList
	end

	self.m_pointInfos = {}
	for index = 1 ,#m_points do
		local v = m_points[index]
		local point = {}
		local areaid = v.pid
		point.pid = areaid
		point.type = v.type
		point.prePoint = json.decode(v.prePoint) -- 后置点 走向谁
		point.pos = json.decode(v.position) 
		point.arrowDirection = praseArrowDirection(v.arrowDirection)
		point.asset = v.asset

		for idx =1,#self.m_data.historyPoint do
			if areaid == self.m_data.historyPoint[idx] then
				point.done = 1
				break
			else
				point.done = 0
			end
		end

		if point.type == 0 then
			-- 起始点
			local item = display.newSprite(IMAGE_COMMON .. "redplan/battle_0.png"):addTo(map, 2)
			item:setPosition(point.pos[1], point.pos[2])
			point.item = item

			-- 保护操作
			if not self.m_data.pointIds then self.m_data.pointIds = {} end
			if table.getn(self.m_data.pointIds) == 0 then
				self.m_data.pointIds[#self.m_data.pointIds + 1] = areaid
			end
		elseif point.type == 1 then
			-- 结束点
			local effect = armature_create("red_sulianzhanlin", point.pos[1], point.pos[2]):addTo(map, 2)
			effect:getAnimation():playWithIndex(0)
			point.item = effect
		else
			-- 处理状态


			local suffix = ".png"
			if point.done == 1 then
				suffix = "_done.png"
			end
			-- 过程点
			local item = display.newSprite(IMAGE_COMMON .. "redplan/battle_" .. point.type .. suffix):addTo(map, 2)
			item:setAnchorPoint(cc.p(0.5,0.1))
			item:setPosition(point.pos[1], point.pos[2])
			point.item = item

		end

		self.m_pointInfos[point.pid] = point
	end

	-- line
	for k, v in pairs(self.m_pointInfos) do
		local curPointInfo = v
		local formPoint = cc.p(curPointInfo.pos[1], curPointInfo.pos[2])
		for index = 1 , #curPointInfo.prePoint do
			local nextPointId = curPointInfo.prePoint[index]
			local nextPointInfo = self.m_pointInfos[nextPointId]
			local nextPoint = cc.p(nextPointInfo.pos[1], nextPointInfo.pos[2])
			self:dottedLine(formPoint, nextPoint)
		end
	end


	self.m_arrowList = {}
	local ruins = #self.m_data.pointIds
	local formCpp = nil
	local formId = nil
	local arrowDirs = nil
	local pointOver = true
	for index = 1 , ruins do
		local pointpid = self.m_data.pointIds[index]

		local point = self.m_pointInfos[pointpid]
		local toCpp = cc.p(point.pos[1], point.pos[2])
		if point.type == 1 then pointOver = false end
		if formCpp then
			local adStruct = arrowDirs[pointpid]
			local adValue = adStruct and adStruct.value or 1
			local arrowItem = arrowRoundShow(map, formCpp, toCpp, adValue)
			local out = {}
			out.item = arrowItem 			-- 箭头
			out.Pid = pointpid 				-- to 点ID
			out.prePid = formId 				-- from 点ID
			self.m_arrowList[out.Pid] = out

			-- -- 苏军
			-- if point.type == 2 or point.type == 3 then
			-- 	if point.item.effect then
			-- 		point.item.effect:getAnimation():playWithIndex(2)
			-- 	end
			-- end
		end
		arrowDirs = point.arrowDirection
		formCpp = toCpp
		formId = pointpid
	end

	local function btnAddlabel(node_)
		local fuelcostsp = display.newSprite(IMAGE_COMMON .. "redplan/fuel.png"):addTo(node_, 11)
		fuelcostsp:setPosition(node_:width() * 0.5 - 20, node_:height() + 5)
		fuelcostsp:setScale(0.6)

		local fuelcostui = ui.newTTFLabel({text = tostring(node_.cost), font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER}):addTo(node_, 11)
		fuelcostui:setPosition(fuelcostsp:x() + 30,fuelcostsp:y() - 5)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onPlayCallback)):addTo(self:getBg(), 10)
	btn:setPosition(self:getBg():width() * 0.5, btn:height() * 0.5)
	btn:setLabel(CommonText[5031])
	btn.x1 = self:getBg():width() * 0.5
	btn.x = self:getBg():width() * 0.3
	btn.y = btn:height() * 0.5
	btn.cost = self.m_AreaInfo.cost
	btn.isCould = pointOver
	self.m_palybtn = btn

	btnAddlabel(btn)

	if ActivityCenterMO.redPlanMapInfo_.isfirst == 1 and self.m_chapter == 1 then
		local hand = armature_create("ryxz_dianji"):addTo(btn):center()
		hand:getAnimation():playWithIndex(0)
		self.m_hand = hand
	end

	-- 扫荡
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local sweepbtn = MenuButton.new(normal, selected, nil, handler(self, self.onAllPlayCallback)):addTo(self:getBg(), 10)
	sweepbtn:setPosition(self:getBg():width() * 0.7, sweepbtn:height() * 0.5)
	sweepbtn:setLabel(CommonText[35])
	sweepbtn.isCould = pointOver
	sweepbtn.cost = self.m_AreaInfo.raidCost
	self.m_sweepbtn = sweepbtn

	btnAddlabel(sweepbtn)


	local function doAction(_self)
		_self.action = true
		_self:runAction(
			CCRepeatForever:create(
					transition.sequence({
						CCDelayTime:create(1.5),
						CCScaleTo:create(0.2,1.2),
						CCRotateTo:create(0,-10),
						CCRotateTo:create(0.1,10),
						CCRotateTo:create(0.1,-10),
						CCRotateTo:create(0.1,0),
						CCScaleTo:create(0.1,1),
						 })))
	end

	-- 宝箱 0不可以 1可以领取  2已经领取
	local iconState = 0
	local awardicon = "box4_0"
	if self.m_data.rewardInfo >= 2 then 
		awardicon = "box4_1"
		iconState = 1
	end
	local normal = display.newSprite(IMAGE_COMMON .. "redplan/"..awardicon ..".png")
	local awardbtn = ScaleButton.new(normal, handler(self, self.takeAwardCallback)):addTo(self:getBg(), 10)
	awardbtn:setPosition(self:getBg():width() - awardbtn:width() *0.9, display.height - 157)
	self.m_awardbtn = awardbtn
	self.m_awardbtn.iconState = iconState
	self.m_awardbtn.action = false
	self.m_awardbtn.actionFunc = doAction
	

	local function upProcess(_self, data)
		--删除第一条和最后一条关卡ID数据
		local cData = clone(data)
		for ids=1,#cData do
			if cData[ids] == m_points[1].pid or cData[ids] == m_points[#m_points].pid then
				table.remove(cData,ids)
			end
		end
		_self:setString(tostring(#cData))
	end

	--进度(-2是去除第一关和最后一关不算)
	local explore = UiUtil.label(CommonText[5041]):addTo(self:getBg(), 10):leftTo(awardbtn,35)
	local now = UiUtil.label(""):addTo(self:getBg(), 10):rightTo(explore)
	local total = UiUtil.label("/"..(#m_points - 2)):addTo(self:getBg(), 10):rightTo(now,10)
	self.now = now
	self.now.upStr = upProcess
	self.now:upStr(self.m_data.historyPoint)
	
	self:updateButtonState(self.m_data.rewardInfo)

	self.m_timeScheduler = scheduler.scheduleGlobal(handler(self, self.onUpdateTime), 1)
end

function RedplanBattleView:_lerp(_f, _t, ft)
	return _f * (1.0 - ft) + _t * ft
end

-- 虚线
function RedplanBattleView:dottedLine(form, to)
	local _form = Vec(form.x, form.y)
	local _to = Vec(to.x, to.y)
	local vecwidth = _to.x - _form.x
	local vecheight = _to.y - _form.y
	local ftDistance = math.sqrt(math.pow(vecwidth, 2) + math.pow(vecheight, 2))
	local count = math.floor( ftDistance / (self.m_drawSize * 20) )
	local _start = _form
	for index = 1 , count do
		local ft = (index / count)
		local _end = self:_lerp(_form, _to, ft)
		local _end_ = self:_lerp(_start, _end, 0.5)
		self.m_draw:drawSegment(_start.ccp(), _end_.ccp(), self.m_drawSize , self.m_drawColor)
		_start = _end
	end
end

function RedplanBattleView:updateButtonState(rewardState)
	if rewardState > 0 then
		if self.m_sweepbtn.isCould then
			self.m_sweepbtn:setVisible(true)
		else
			self.m_sweepbtn:setVisible(false)
		end

		if self.m_palybtn.isCould then
			self.m_palybtn:setVisible(true)
			self.m_palybtn:setPosition(self.m_palybtn.x,self.m_palybtn.y)
		else
			self.m_palybtn:setVisible(false)
		end

		if rewardState == 1 then
			-- 1可以领取
			if not self.m_awardbtn.action then
				self.m_awardbtn:actionFunc()
			end
		else
			-- 2已经领取
			if self.m_awardbtn.iconState == 0 then
				self.m_awardbtn:setTouchSprite(display.newSprite(IMAGE_COMMON .. "redplan/box4_1.png"))
				self.m_awardbtn.iconState = 1
			end
			self.m_awardbtn:setEnabled(false)
			self.m_awardbtn:stopAllActions()
			self.m_awardbtn.action = false
		end
		
	else
		self.m_sweepbtn:setVisible(false)

		if self.m_palybtn.isCould then
			self.m_palybtn:setPosition(self.m_palybtn.x1,self.m_palybtn.y)
			self.m_palybtn:setVisible(true)
		else
			self.m_palybtn:setVisible(false)
		end

		self.m_awardbtn:setEnabled(true)
		self.m_awardbtn:stopAllActions()
		self.m_awardbtn.action = false
	end
	self.m_awardbtn.state = rewardState
end

function RedplanBattleView:onUpdateTime(ft)
	if not self.m_touchState then
		self.m_touchStateLimitTime = self.m_touchStateLimitTime + 1
		if self.m_touchStateLimitTime >= 10 then
			self.m_touchStateLimitTime = 0
			self.m_touchState = true
		end
		return 
	end
	self.m_touchStateLimitTime = 0
end

function RedplanBattleView:takeAwardCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	if not self.m_touchState then return end
	local state = sender.state
	if state == 0 then
		-- Toast.show(CommonText[5032][1])
		local info = ActivityCenterMO.getRedPlanArea(self.m_chapter)
		local data = json.decode(info.areaAward)
		local text = string.format(CommonText[5037], info.name)
		GiftShowDilog.new(data,text):push()
		return
	end

	local function resultCallback(data)
		local state = data.rewardInfo
		self:updateButtonState(state)
	end

	ActivityCenterBO.GetRedPlanBox(resultCallback, self.m_chapter)
end

function RedplanBattleView:onBuyFuelCallback(tar, sender)
	if ActivityCenterMO.redPlanFuelInfo.fuel + ActivityCenterMO.getRedPlanFuelLimit().buyPoint > ActivityCenterMO.getRedPlanFuelLimit().buyLimit then
		Toast.show(CommonText[5032][2])
		return
	end

	local cost = ActivityCenterMO.getRedPlanFuelRole(ActivityCenterMO.redPlanFuelInfo.fuelBuyCount)
	local mygold = UserMO.getResource(ITEM_KIND_COIN)
	if cost > mygold then
		Toast.show(CommonText[679])
		return
	end

	local function resultCallback()
		Toast.show(CommonText[10064][2])
		if self.m_fuelNum then
			self.m_fuelNum:upFunc(ActivityCenterMO.redPlanFuelInfo.fuel)
		end
	end

	local function gotoBuy()
		ActivityCenterBO.RedPlanBuyFuel(resultCallback)
	end

	if UserMO.consumeConfirm then

		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[5035], cost, ActivityCenterMO.getRedPlanFuelLimit().buyPoint), function() gotoBuy() end):push()
	else
		gotoBuy()
	end	
end

-- 出击
function RedplanBattleView:onPlayCallback( tar, sender )
	ManagerSound.playNormalButtonSound()
	if self.m_hand then
		self.m_hand:removeSelf()
		self.m_hand = nil
	end
	-- if not self.m_touchState then return end
	self.m_awardbtn:setTouchEnabled(false) --箱子领奖按钮设置为不可点
	self.m_sweepbtn:setTouchEnabled(false) --扫荡按钮设置为不可点击
	self.m_palybtn :setTouchEnabled(false) --出击按钮设置不可点击
	if self.m_touchState == false then return end
	

	if ActivityCenterMO.redPlanFuelInfo.fuel < sender.cost then
		Toast.show(CommonText[5036])
		self.m_awardbtn:setTouchEnabled(true)
		self.m_sweepbtn:setTouchEnabled(true)
		self.m_palybtn :setTouchEnabled(true)
		return
	end
	self.m_touchState = false

	ActivityCenterBO.MoveRedPlan(handler(self,self.moveResult), self.m_chapter)
end

-- 扫荡
function RedplanBattleView:onAllPlayCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	if not self.m_touchState then return end

	if ActivityCenterMO.redPlanFuelInfo.fuel < sender.cost then
		Toast.show(CommonText[5036])
		self.m_awardbtn:setTouchEnabled(true)
		self.m_sweepbtn:setTouchEnabled(true)
		self.m_palybtn :setTouchEnabled(true)
		return
	end

	-- if #self.m_data.pointIds > 1 then
	-- 	Toast.show()
	-- 	return
	-- end

	local function resultCallback(data)
		if self.m_fuelNum then
			self.m_fuelNum:upFunc(ActivityCenterMO.redPlanFuelInfo.fuel)
		end
		RedPlanAwardDialog.new(data):push()
	end

	ActivityCenterBO.RefRedPlanArea(resultCallback, self.m_chapter)
end

function RedplanBattleView:moveResult(data)
	self.m_data.perfect = data.perfect
	self.m_data.historyPoint = data.historyPoint
	if self.m_fuelNum then
		self.m_fuelNum:upFunc(ActivityCenterMO.redPlanFuelInfo.fuel)
	end

	if self.now then
		self.now:upStr(data.historyPoint)
	end

	local nextPointId = data.nextPointId
	self.isfirst = data.isfirst
	self.m_data.pointIds[#self.m_data.pointIds + 1] = nextPointId

	local nextpoint = self.m_pointInfos[nextPointId]
	self.nextpoint = nextpoint
	local function takeAward(isOver)
		local _over = isOver or false
		-- 弹出奖励
		-- 弹出 奖励界面
		RedPlanAwardDialog.new(data,handler(self,self.close), _over):push()
		self.m_touchState = true
		self.m_awardbtn:setTouchEnabled(true) --领奖可点击
		self.m_sweepbtn:setTouchEnabled(true) --扫荡可点击
		self.m_palybtn :setTouchEnabled(true) --出击可点击 
		self:updateButtonState(data.rewardInfo)
	end
	
	local function arrowCallback()
		if nextpoint.type == 1 then
			-- 结束点
			nextpoint.item:connectMovementEventSignal(function (movementType, movementID)
				if movementType == MovementEventType.COMPLETE then
					takeAward(true)
				end
			end)
			nextpoint.item:getAnimation():playWithIndex(1)

			if self.m_palybtn then
				self.m_palybtn.isCould = false
				self.m_palybtn:setVisible(false)
				-- self.m_palybtn.fuelcostsp:setVisible(false)
				-- self.m_palybtn.fuelcostui:setVisible(false)
			end

			if self.m_sweepbtn then 
				self.m_sweepbtn.isCould = false
				self.m_sweepbtn:setVisible(false)
			end

			-- -- 通关发送请求更改区域状态
			-- local areaId = self.m_chapter + 1
			-- local areaInfo = ActivityCenterMO.getRedPlanArea(areaId)
			-- if areaInfo then
			-- 	ActivityCenterBO.GetRedPlanAreaInfo(function(data)
					
			-- 		dump(data)
			-- 	 end, areaId)
			-- end
		else
			-- @另做动作
			-- if nextpoint.item.effect then
			-- 	nextpoint.item.effect:connectMovementEventSignal(function (movementType, movementID)
			-- 		if movementType == MovementEventType.COMPLETE then
			-- 			nextpoint.item.effect:getAnimation():playWithIndex(2)
			-- 			takeAward()
			-- 		end
			-- 	end)
			-- 	nextpoint.item.effect:getAnimation():playWithIndex(1)
			-- end
			if (nextpoint.type == 2 or nextpoint.type == 3) and nextpoint.done == 0 then
				local function changeItem()
					local item = display.newSprite(IMAGE_COMMON .. "redplan/battle_" .. nextpoint.type .. "_done.png"):addTo(self.m_map, 2)
					item:setAnchorPoint(cc.p(0.5,0.1))
					item:setPosition(nextpoint.pos[1], nextpoint.pos[2] + 60)
					item:runAction(transition.sequence({cc.MoveTo:create(0.15,cc.p(nextpoint.pos[1], nextpoint.pos[2])), cc.CallFunc:create(function ()
						takeAward()
					end)}))
					nextpoint.item = item
					nextpoint.done = 1
				end
				nextpoint.item:runAction(transition.sequence({cc.FadeOut:create(0.6), cc.CallFuncN:create(function (sender)
					sender:removeSelf()
					changeItem()
				end)}))
			else
				takeAward()
			end
		end
	end
	
	local toCpp = cc.p(nextpoint.pos[1], nextpoint.pos[2])
	local formId = self.m_data.pointIds[#self.m_data.pointIds - 1]
	local formpoint = self.m_pointInfos[formId]
	local formCpp = cc.p(formpoint.pos[1], formpoint.pos[2])
	local formAdStruct = formpoint.arrowDirection[nextPointId]
	local advalue = formAdStruct and formAdStruct.value or 1
	local arrowItem = arrowRoundShow(self.m_map, formCpp, toCpp, advalue, true, arrowCallback)
	local out = {}
	out.item = arrowItem 			-- 箭头
	out.Pid = nextpoint 				-- to 点ID
	out.prePid = formId 				-- from 点ID
	self.m_arrowList[out.Pid] = out
end

function RedplanBattleView:updateUI()
	-- if self.m_fuelNum then
	-- 	self.m_fuelNum:upFunc(ActivityCenterMO.redPlanFuelInfo.fuel)
	-- end
end

function RedplanBattleView:close(state)
	if state then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onReturnCallback)):addTo(self:getBg(), 10)
		btn:setPosition(self:getBg():width() * 0.5, btn:height() * 0.5)
		btn:setLabel(CommonText[99])

		local done = display.newSprite(IMAGE_COMMON .. "done.png"):addTo(self:getBg(), 11)
		done:setPosition(self:getBg():width() * 0.5,180)
		done:setScale(4.5)
		done:runAction(CCEaseExponentialIn:create(cc.ScaleTo:create(0.55,1)))
	end

	--如果完美通关了
	if self.m_data.perfect == 1 then
		require("app.dialog.PerfectAdoptDialog").new():push()
	end

end

function RedplanBattleView:CloseAndCallback()
	if self.nextpoint then
		local view = UiDirector.getUiByName("ActivityCommunismView")
		if self.nextpoint.type == 1 then --结束 
			if view then
				if self.m_chapter == 6 and self.isfirst == 1 then
					if view.m_arrowNode then
						view.m_arrowNode:removeSelf()
						view.m_arrowNode = nil
					end
					ActivityCenterBO.getRedPlanInfo(function (data)
						view:playArealExchange(6,nil, function ()
							require("app.view.PlotTalkView").new(7,nil,false):addTo(view, 51)
						end)
					end)
					return
				end
				view:refreshUIttt(self.m_chapter + 1)
			end
		elseif self.nextpoint.type >= 1 then
			view:refreshUIttt(self.m_chapter + 1)
		end
	end
end

function RedplanBattleView:onReturnCallback(tag, sender)
	if not self.m_touchState then return end 
	RedplanBattleView.super.onReturnCallback(self, tag, sender)
end

function RedplanBattleView:onExit()
	RedplanBattleView.super.onExit(self)

	if self.m_timeScheduler then
		scheduler.unscheduleGlobal(self.m_timeScheduler)
		self.m_timeScheduler = nil
	end

	armature_remove(IMAGE_ANIMATION .. "effect/red_sulianzhanlin.pvr.ccz", IMAGE_ANIMATION .. "effect/red_sulianzhanlin.plist", IMAGE_ANIMATION .. "effect/red_sulianzhanlin.xml")
	-- armature_remove(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")

end

return RedplanBattleView