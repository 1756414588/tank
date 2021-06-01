--
-- Author: Gss
-- Date: 2018-05-17 21:00:38
--
--坦克转换

VIEW_FOR_LEFT = 1
VIEW_FOR_RIGHT = 2

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local PropTipDialog = class("PropTipDialog", Dialog)

function PropTipDialog:ctor(data, rhand)
	PropTipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 360)})

	self.m_data = data
	self.m_rhand = rhand
end

function PropTipDialog:onEnter()
	PropTipDialog.super.onEnter(self)
	local resData = UserMO.getResourceData(ITEM_KIND_CHAR, self.m_data.propId)
	-- 点击了确定或者取消按钮后就立即关闭弹出框
	self.m_isClickClose = true

	local content = display.newNode():addTo(self:getBg())
	content:setPosition(self:getBg():getContentSize().width / 2, 250)

	local coinData = UserMO.getResourceData(ITEM_KIND_COIN)

	local desc = ui.newTTFLabel({text = string.format(CommonText[5054], resData.name, self.m_data.count * resData.price, self.m_data.count, resData.name), font = G_FONT, size = FONT_SIZE_MEDIUM,
		dimensions = cc.size(470, 0), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(content)

	local function onCancelCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:pop()
	end

	-- 知道了
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	self.m_cancelBtn = MenuButton.new(normal, selected, disabled, onCancelCallback):addTo(self:getBg())  -- 取消
	self.m_cancelBtn:setLabel(CommonText[2])
	self.m_cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 130, 70)

	local function onOkCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		local count = UserMO.getResource(ITEM_KIND_COIN)
		local need = resData.price * self.m_data.count

		if need > count then -- 金币不足
			self:pop(function() require("app.dialog.CoinTipDialog").new():push() end)
			return
		end

		local function doneBuy()
			-- 成功购买
			Toast.show(CommonText[200])
			ManagerSound.playSound("shop_buy")
			self:pop()
		end

		ActivityCenterBO.buyActProp(self.m_data.propId,self.m_data.count,function (data)
			if self.m_rhand then self.m_rhand(data) end
			doneBuy()
		end)
	end

	-- 购买
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2 + 130, 70)
end


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
local TankExcCycleView = class("TankExcCycleView", function(size)
	if not size then size = cc.size(0, 0) end
	local rect = cc.rect(0, 0, size.width, size.height)

	local node = display.newClippingRegionNode(rect)
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function TankExcCycleView:ctor(size, data, viewFor, rhand)
	self.m_viewSize = size
	self.m_data = data
	self.m_viewFor = viewFor
	self.m_choseId = 2
	self.rhand = rhand
	self.node = {}
end

function TankExcCycleView:onEnter()
	local itemNumbs = #self.m_data

	local node2 = display.newNode():addTo(self)
	node2:setContentSize(self.m_viewSize.width, self.m_viewSize.height / 3 * itemNumbs)
	node2:setAnchorPoint(cc.p(0, 1))
	node2:setPosition(0,self.m_viewSize.height)
	self.node2 = node2
	self.node[#self.node + 1] = node2

	local node1 = display.newNode():addTo(self)
	node1:setContentSize(self.m_viewSize.width, self.m_viewSize.height / 3 * itemNumbs)
	node1:setAnchorPoint(cc.p(0, 1))
	node1:setPosition(0,node2:y() + node2:height())
	self.node1 = node1
	self.node[#self.node + 1] = node1

	local node3 = display.newNode():addTo(self)
	node3:setContentSize(self.m_viewSize.width, self.m_viewSize.height / 3 * itemNumbs)
	node3:setAnchorPoint(cc.p(0, 1))
	node3:setPosition(0,node2:y() - node2:height())
	self.node3 = node3
	self.node[#self.node + 1] = node3

	self:createUI()

	local touchNode = display.newNode():addTo(self,99)
	touchNode:setContentSize(self.m_viewSize.width, self.m_viewSize.height)
	touchNode:setPosition(0,0)
	nodeTouchEventProtocol(touchNode, function(event) return self:onTouch(event) end, nil, nil, false)
	self.touchNode = touchNode
end

function TankExcCycleView:createUI()
	for idx=1,3 do
		self.node[idx]:removeAllChildren()
		self.node[idx]:setContentSize(self.m_viewSize.width, self.m_viewSize.height / 3 * #self.m_data) --重新设置高度
		for index=1,#self.m_data do
			local cellData = self.m_data[index]
			local bg = display.newScale9Sprite(IMAGE_COMMON .. "tankExc_bg.png"):addTo(self.node[idx])
			local dis = self.node[idx]:height() / #self.m_data
			if self.m_viewFor == VIEW_FOR_RIGHT then
			end
			bg:setPosition(self.node[idx]:width() / 2, self.node[idx]:height() - (dis / 2 + (index - 1) * dis))
			local tank
			local count
			if self.m_viewFor == VIEW_FOR_LEFT then
				tank = UiUtil.createItemSprite(ITEM_KIND_TANK, cellData.tankId)
				count = UserMO.getResource(ITEM_KIND_TANK, cellData.tankId)
			else
				tank = UiUtil.createItemSprite(ITEM_KIND_TANK, cellData)
				count = UserMO.getResource(ITEM_KIND_TANK, cellData)
			end
			tank:addTo(bg):center()
			tank:setScale(0.9)

			--数量
			local num = UiUtil.label(count, 16):addTo(bg)
			num:setAnchorPoint(cc.p(1, 0.5))
			num:setPosition(bg:width() - 10, 20)

			nodeTouchEventProtocol(tank, function(event)
				if event.name == "began" then
					self.node_point = cc.p(event.x, event.y)
					tank:runAction(CCScaleTo:create(0.08, 0.85))

					local rect = self:getBoundingBox()
					local point = self:getParent():convertToNodeSpace(cc.p(event.x, event.y))
					if cc.rectContainsPoint(rect, point) then
						return true
					end
				    return false
				elseif event.name == "moved" then
				elseif event.name == "ended" then
					local dis = event.y - self.node_point.y
					if math.abs(dis) < 5 then
						if self.m_viewFor == VIEW_FOR_LEFT then
							require("app.dialog.DetailTankDialog").new(cellData.tankId):push()
						else
							require("app.dialog.DetailTankDialog").new(cellData):push()
						end
					end
					tank:setScale(0.95)
				end
			end, nil, nil, true)

		end
	end
end

function TankExcCycleView:onTouch(event)
    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    else
    	self:onTouchCancelled(event)
    end
end

function TankExcCycleView:onTouchBegan(event)
	self.m_touchPoint = cc.p(event.x, event.y)

	return true
end

function TankExcCycleView:onTouchMoved(event)
	-- local x = event.x - self.m_touchPoint.x
	-- local y = event.y - self.m_touchPoint.y


	-- local newPoint = cc.p(event.x, event.y)
	-- local moveDistance = cc.PointSub(newPoint, self.m_touchPoint)

	-- self.m_touchPoint = newPoint
	-- for aaa=1,3 do
	-- 	self.node[aaa]:setPosition(cc.p(0, self.node[aaa]:y() + y))
	-- end
end

function TankExcCycleView:onTouchCancelled(event)
	-- body
end

function TankExcCycleView:onTouchEnded(event)
	self.m_delaY = self.m_touchPoint.y - event.y

	local minY = 0
	if self.m_delaY == 0 then
		minY = 0
	elseif self.m_delaY < 0 then --向上滚动
		minY = self.node[1]:getContentSize().height / #self.m_data

		if self.node[3]:y() > 0 and self.node[3]:y() <= minY then
			self.node[2]:setPosition(0, self.node[3]:y() - self.node[3]:height())
		end

		if self.node[2]:y() > 0 and self.node[2]:y() <= minY then
			self.node[1]:setPosition(0, self.node[2]:y() - self.node[2]:height())
		end

		if self.node[1]:y() > 0 and self.node[1]:y() <= minY then
			self.node[3]:setPosition(0, self.node[1]:y() - self.node[1]:height())
		end
	elseif self.m_delaY > 0 then --向下滚动
		minY = -self.node[1]:getContentSize().height / #self.m_data

		if self.node[1]:y() > 0 and self.node[1]:y() <= math.abs(minY) then
			self.node[3]:setPosition(0, self.node[2]:y() + self.node[2]:height())
		end

		if self.node[2]:y() > 0 and self.node[2]:y() <= math.abs(minY) then
			self.node[1]:setPosition(0, self.node[3]:y() + self.node[3]:height())
		end

		if self.node[3]:y() > 0 and self.node[3]:y() <= math.abs(minY) then
			self.node[2]:setPosition(0, self.node[1]:y() + self.node[1]:height())
		end

	end

	if math.abs(self.m_delaY) > 30 then
		for idx=1,3 do
			self.node[idx]:runAction(cc.MoveBy:create(0.2, cc.p(0, minY)))
		end

		if self.m_delaY == 0 then
			self.m_choseId = self.m_choseId
		elseif self.m_delaY > 0 then
			self.m_choseId = self.m_choseId - 1
		elseif self.m_delaY < 0 then
			self.m_choseId = self.m_choseId + 1
		end

		if self.m_choseId <= 0 then
			self.m_choseId = #self.m_data
		elseif self.m_choseId > #self.m_data then
			self.m_choseId = 1
		end

		if self.rhand then self.rhand(self.m_choseId) end
	end
end

function TankExcCycleView:updateUI(data, viewFor)
	self.m_data = data
	self.m_viewFor = viewFor
	self:createUI()
end

function TankExcCycleView:onExit()
	-- body
end


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

local ActivityTankExcView = class("ActivityTankExcView", UiNode)

function ActivityTankExcView:ctor(activity,data)
	ActivityTankExcView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity

	self.m_data = ActivityCenterMO.getTankExcByAwardId(activity.awardId)
	self.m_useData = data or {}
	self.m_choseIndex = 2
	self.m_exchangeId = 2
	self.m_excCount = 0
end

function ActivityTankExcView:onEnter()
	ActivityTankExcView.super.onEnter(self)
	self:setTitle(self.m_activity.name)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
	self:showUI()
end

function ActivityTankExcView:showUI()
	--活动说明
	local tips = UiUtil.label(CommonText[5050], 24):addTo(self:getBg())
	tips:setAnchorPoint(cc.p(0, 1))
	tips:setPosition(25, self:getBg():getContentSize().height - 120)

	--活动时间
	local timeLab = UiUtil.label(CommonText[5051], 24):addTo(self:getBg())
	timeLab:setAnchorPoint(cc.p(0,1))
	timeLab:setPosition(tips:x(), tips:y() - 30)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = 24, color = COLOR[6]}):rightTo(timeLab)
	timeLab:setAnchorPoint(cc.p(0, 1))
	self.m_timeLab = timeLab

	--tips按钮
	local function helpCallback(tar, sender)
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.tankExchange):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal2.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
	local helpBtn = MenuButton.new(normal, selected, nil, helpCallback):addTo(self:getBg())
	helpBtn:setPosition(self:getBg():width() - helpBtn:width(), timeLab:y())
	
	--BG
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_29.jpg"):addTo(self:getBg())
	bg:setPosition(self:getBg():width() / 2, timeLab:y() - 40 - bg:height() / 2)
	self.bg = bg

	local down = display.newSprite(IMAGE_COMMON .. "down_arrow.png"):addTo(bg)
	down:setPosition(bg:width() / 2, bg:height() - down:height() / 2)

	--左边
	local function view1CallBack(id)
		self.m_choseIndex = id

		local tankId = self.m_data[self.m_choseIndex].tankId
		self:showExc(tankId)
		if self.m_view2 then
			local change = json.decode(self.m_data[self.m_choseIndex].convertType)
			local viewFor = VIEW_FOR_RIGHT
			self.m_view2:updateUI(change, viewFor)
		end
	end

	local view1 = TankExcCycleView.new(cc.size(bg:width() / 2 - 65,bg:height() - 70), self.m_data, VIEW_FOR_LEFT, view1CallBack):addTo(bg)
	view1:setPosition(20, 25)
	local selected1 = display.newSprite(IMAGE_COMMON .. "tankExc_chose.png"):addTo(view1)
	selected1:setPosition(view1:width() / 2, view1:height() / 2)

	self.m_view1 = view1


	--右边
	local function view2CallBack(id)
		self.m_exchangeId = id
	end

	local changeData = json.decode(self.m_data[self.m_choseIndex].convertType)

	--默认兑换ID
	local view2 = TankExcCycleView.new(cc.size(bg:width() / 2 - 65,bg:height() - 70), changeData, VIEW_FOR_RIGHT, view2CallBack):addTo(bg)
	view2:setPosition(bg:width() / 2 + 50, 25)
	local selected2 = display.newSprite(IMAGE_COMMON .. "tankExc_chose.png"):addTo(view2)
	selected2:setPosition(view2:width() / 2, view2:height() / 2)

	self.m_view2 = view2

	--箭头
	local arrow = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png"):addTo(bg)
	arrow:setPosition(bg:width() / 2, bg:height() / 2)
	-- arrow:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(-10, 0)), cc.MoveBy:create(2, cc.p(10, 0))})))

	--兑换
	self:showExc()

	--购买
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local buyBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardHandler)):addTo(self:getBg())
	buyBtn:setPosition(self:getBg():getContentSize().width / 4,80)
	buyBtn:setLabel(CommonText[5053][1])

	--转换
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local excBtn = MenuButton.new(normal, selected, nil, handler(self,self.onExcHandler)):addTo(self:getBg())
	excBtn:setPosition((self:getBg():getContentSize().width / 4) * 3,buyBtn:y())
	excBtn:setLabel(CommonText[5053][2])
end

function ActivityTankExcView:showExc()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	-- local tankInfo = ActivityCenterMO.getTankExcInfo(self.m_choseIndex)
	local tankInfo = self.m_data[self.m_choseIndex]
	--转换数量
	local numLab = UiUtil.label(CommonText[5052], 24):addTo(container)
	numLab:setAnchorPoint(cc.p(0,0.5))
	numLab:setPosition(40, self.bg:y() - self.bg:height() / 2 - 50)

	local ownTank = math.min(UserMO.getResource(ITEM_KIND_TANK, tankInfo.tankId), PROP_BUY_MAX_NUM)
	self.m_excCount = ownTank
	local num = UiUtil.label(ownTank, 24):rightTo(numLab)
	self.m_changeNum = num

	-- 减少按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
	local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):rightTo(num)
	reduceBtn:setScale(0.7)

    self.m_maxNum = ownTank
    self.m_minNum = 1
    if self.m_maxNum == 0 then self.m_minNum = 0 end
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM end
	self.m_settingNum = self.m_maxNum

	--消耗物品
	local cost = json.decode(tankInfo.convertPrice)[self.m_exchangeId]
	self.m_cost = cost
	local resData = UserMO.getResourceData(cost[1], cost[2])

	local name = UiUtil.label(resData.name.."：", 24):addTo(container)
	name:setAnchorPoint(cc.p(0,0.5))
	name:setPosition(numLab:x(), numLab:y() - 50)

	--消耗
	local consume = UiUtil.label(self.m_settingNum * cost[3], 24):rightTo(name)
	self.m_consume = consume

	--拥有
	local sprit = UiUtil.label("/", 24):rightTo(consume)

	local own = 0
	if self.m_useData then
		own = self.m_useData.count
	end

	local ownProp = UiUtil.label(own, 24):rightTo(sprit)
	self.ownProp = ownProp
	if own < self.m_settingNum * cost[3] then
		ownProp:setColor(COLOR[6])
	end

	--滑动条
	local barHeight = 45
	local barWidth = 250
	local slider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_19.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(container)
	slider:align(display.LEFT_BOTTOM, reduceBtn:x() + barWidth / 2 - 50, reduceBtn:y() - 20)
    slider:setSliderSize(barWidth, barHeight)
    slider:onSliderValueChanged(handler(self, self.onSlideCallback))
    slider:setSliderValue(self.m_settingNum)
    slider:setBg(IMAGE_COMMON .. "bar_bg_15.png", cc.size(250 + 40, 35), {x = barWidth / 2, y = barHeight / 2})
    self.m_numSlider = slider

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):rightTo(reduceBtn,250)
    addBtn:setScale(0.7)
end

function ActivityTankExcView:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
	-- self.priceLabel:setString(UiUtil.strNumSimplify(self:getPrice(self.m_settingNum)))
end

function ActivityTankExcView:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
	-- self.priceLabel:setString(UiUtil.strNumSimplify(self:getPrice(self.m_settingNum)))
end

function ActivityTankExcView:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_changeNum:setString(self.m_settingNum)
	if self.m_consume then
		self.m_consume:setString(self.m_settingNum * self.m_cost[3])
	end

	if self.ownProp then
		if self.m_useData.count < self.m_settingNum * self.m_cost[3] then
			self.ownProp:setColor(COLOR[6])
		else
			self.ownProp:setColor(COLOR[1])
		end
	end
end

function ActivityTankExcView:awardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not self.m_cost then return end

	require("app.dialog.BuyActPropDialog").new(self.m_cost[2],function (data)
		self.m_useData.count = data
		if self.ownProp then
			self.ownProp:setString(data)
			if self.m_useData.count < self.m_settingNum * self.m_cost[3] then
				self.ownProp:setColor(COLOR[6])
			else
				self.ownProp:setColor(COLOR[1])
			end
		end
	end):push()
end

function ActivityTankExcView:onExcHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not self.m_cost then return end
	if self.m_settingNum <= 0 then
		Toast.show(CommonText[5056])
		return
	end
	-- local tankInfo = ActivityCenterMO.getTankExcInfo(self.m_choseIndex)
	local tankInfo = self.m_data[self.m_choseIndex]

	local srcTankId = tankInfo.tankId
	local dstTankId = json.decode(tankInfo.convertType)[self.m_exchangeId]

	local need = self.m_settingNum * self.m_cost[3] --消耗多少活动道具
	local count = self.m_useData.count

	local function gotoExc()
		ActivityCenterBO.goTankExc(function (data)
			self.m_useData.count = self.m_useData.count - need
			Toast.show(CommonText[5055])
			--刷新
			self:showExc()

			local change = json.decode(self.m_data[self.m_choseIndex].convertType)

			self.m_view1:updateUI(self.m_data, VIEW_FOR_LEFT)
			self.m_view2:updateUI(change, VIEW_FOR_RIGHT)
		end, self.m_settingNum, srcTankId, dstTankId)
	end

	if need > count then
		local data = {}
		data.propId = self.m_cost[2]
		data.count = need - count
		PropTipDialog.new(data, function (data)
			self.m_useData.count = data
			gotoExc()
		end):push()
	else
		gotoExc()
	end
end

function ActivityTankExcView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

function ActivityTankExcView:onExit()
	ActivityTankExcView.super.onExit(self)
end


return ActivityTankExcView