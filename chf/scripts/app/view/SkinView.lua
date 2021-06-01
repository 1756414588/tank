
-- 计算定点位置
local function CalculateAllX( size, index, allwidth, dexScaleOfWidth)
	-- body
	local _width = allwidth / size
	return (index + 0.5) * _width
end

local Dialog = require("app.dialog.Dialog")
----------------------------------------------------------
--					道具批量使用弹出框					--
----------------------------------------------------------
local SkinUseDialog = class("SkinUseDialog", Dialog)

function SkinUseDialog:ctor(skinId, count, useCallback,ischange)
	SkinUseDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_skinId = skinId
	self.count = count
	self.m_useCallback = useCallback
	self.ischange = ischange or false
end


function SkinUseDialog:onEnter()
	SkinUseDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[429]) -- 批量使用

	self.m_propDB = PropMO.checkPropForSkin(self.m_skinId)


	local itemView = UiUtil.createItemView(ITEM_KIND_SKIN, self.m_skinId):addTo(self:getBg())
	itemView:setPosition(100, self:getBg():getContentSize().height - 130)

	-- 名称
	local name = ui.newTTFLabel({text = self.m_propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self:getBg():getContentSize().height - 90, color = COLOR[self.m_propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = self.m_propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self:getBg():getContentSize().height - 150, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self:getBg():getContentSize().width / 2, y = 160, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(1, 0.5))

	-- 
	local count = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = count

	local total = ui.newTTFLabel({text = "/" .. self.count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	total:setAnchorPoint(cc.p(0, 0.5))
	self.m_totalLabel = total

 	local barHeight = 40
	local barWidth = 266

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    reduceBtn:setPosition(self:getBg():getContentSize().width / 2 - barWidth / 2 - 78, 100 + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(self:getBg():getContentSize().width / 2 + barWidth / 2 + 78, reduceBtn:getPositionY())

    self.m_maxNum = self.count
    self.m_minNum = 1
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM end
	self.m_settingNum = self.m_minNum

	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 100)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(266 + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})

	-- 使用按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onOkCallback)):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2, 25)
	--只有一个道具，直接使用
	if self.count == 1 then
		self:hide()
		self:onOkCallback(nil,nil)	
	end
end

function SkinUseDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function SkinUseDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function SkinUseDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	self.m_totalLabel:setPosition(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width, self.m_numLabel:getPositionY())
end

function SkinUseDialog:onOkCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if self.m_settingNum <= 0 then return end

    local function doneUseProp(data)
    	if self.ischange then
    		Toast.show(CommonText[1062][4])
    	else
    		Toast.show(CommonText[1062][3])
    	end
    	
    	self:pop()
    end

    if self.m_useCallback then self.m_useCallback(self.m_settingNum, doneUseProp) end
end








----------------------------------------------------------
--					购买道具弹出框						--
----------------------------------------------------------

local SkinBuyDialog = class("SkinBuyDialog", Dialog)

function SkinBuyDialog:ctor(skinId, param)
	
	self.skinId = skinId
	self.param = param
	SkinBuyDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 450)})
end

function SkinBuyDialog:onEnter()
	SkinBuyDialog.super.onEnter(self)

	self:setOutOfBgClose(true)

	self.m_propDB = PropMO.checkPropForSkin(self.skinId)

	-- 名称
	local name = ui.newTTFLabel({text = self.m_propDB.name , font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 60, color = COLOR[self.m_propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = self.m_propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 100, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	-- 售价
	local label = ui.newTTFLabel({text = CommonText[198] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 280, y = self:getBg():getContentSize().height - 175, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(self:getBg())
	view:setPosition(label:getPositionX() + label:getContentSize().width + view:getContentSize().width / 2, label:getPositionY())

	local price = self:getPrice()
	local t = ui.newBMFontLabel({text = UiUtil.strNumSimplify(price), font = "fnt/num_2.fnt", x = view:getPositionX() + view:getContentSize().width / 2, y = view:getPositionY()}):addTo(self:getBg())
	t:setAnchorPoint(cc.p(0, 0.5))
	self.priceLabel = t

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(440, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 200)

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    reduceBtn:setPosition(64, 160 + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(self:getBg():getContentSize().width - 64, reduceBtn:getPositionY())

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2 - 50, y = 220, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 
	local count = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = count

	local count = UserMO.getResource(ITEM_KIND_COIN)

    self.m_maxNum = math.floor(count / price)
    if self.param and self.param.max then
    	self.m_maxNum = math.min(self.m_maxNum, self.param.max)
    end
    self.m_minNum = 1
    if self.m_maxNum == 0 then self.m_minNum = 0 end
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM end
	self.m_settingNum = self.m_minNum

	local barHeight = 40
	local barWidth = 266
	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 160)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(266 + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})

	-- 购买
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onBuyCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 80)
	btn:setLabel(CommonText[119])


	local kind,id = ITEM_KIND_SKIN, self.skinId

	local itemView = UiUtil.createItemView(kind,id):addTo(self:getBg(), 10)
	itemView:setPosition(84, self:getBg():getContentSize().height - 94)


	self:getBg():setCascadeOpacityEnabledRecursively(true)
	self:getBg():setOpacity(0)
	self:getBg():runAction(transition.sequence({cc.DelayTime:create(0.15), cc.FadeIn:create(0.1)}))
end

function SkinBuyDialog:getPrice(num)
	if self.param then
		num = num or 1
		if type(self.param.price) == "string" then
			local total = 0
			local sec = json.decode(self.param.price)
			for i=self.param.nowtime + 1,self.param.nowtime + num do
				local t = sec[1][2]
				for k,v in ipairs(sec) do
					if i > v[1] and i <= sec[k+1][1] then
						t = sec[k+1][2]
						break
					end
				end
				total = total + t
			end
			return total
		else
			if num and num == 0 then num = 1 end
			return self.param.price * num
		end
	else
		return self.m_propDB.price
	end
end

function SkinBuyDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function SkinBuyDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function SkinBuyDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	if self.param and self.param.nowtime then
		self.priceLabel:setString(self:getPrice(self.m_settingNum))
	end
end

function SkinBuyDialog:onBuyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local count = UserMO.getResource(ITEM_KIND_COIN)
	local need = 0
	if self.param and self.param.nowtime then
		need = self:getPrice(self.m_settingNum)
	else
		need = (self.param and self.param.price or self.m_propDB.price) * self.m_settingNum
	end
	if need > count or self.m_settingNum == 0 then -- 金币不足
		self:pop(function() require("app.dialog.CoinTipDialog").new():push() end)
		return
	end

	local function doneBuy()
		-- 成功购买
		Toast.show(CommonText[200])
		ManagerSound.playSound("shop_buy")
		self:pop()
	end

	if self.param then
		self.param.rhand(self.m_settingNum, doneBuy)
	end
end

function SkinBuyDialog:onExit()
	SkinBuyDialog.super.onExit(self)
end








----------------------------------------------------------
--						皮肤列表						--
----------------------------------------------------------
local SkinTableView = class("SkinTableView", TableView)

function SkinTableView:ctor(size, calls, skinUI, skinType)
	SkinTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.calls = calls
	self.skinUI = skinUI
	self.skinType = skinType or 1
end

function SkinTableView:onEnter()
	SkinTableView.super.onEnter(self)
end

function SkinTableView:setPos(x,y)
	self:setPosition(x,y)
	local realpoint = self:convertToWorldSpace(cc.p(self:getPositionX() , self:getPositionY()))
	self.MineRect = cc.rect(realpoint.x,realpoint.y,self:getViewSize().width,self:getViewSize().height)
end


function SkinTableView:makeDraw(indata)
	
	self.lastTouchSkinId = 0
	local pitem = nil 			-- 设置偏移对象
	local touchSkinId = 0 		-- 记录上次的ID
	local touchSkinData = nil   -- 根据ID获取上次的数据
	if self.touchPointList and self.touchPointList.touchSkinId ~= nil and self.touchPointList.touchSkinId ~= 0 then
		touchSkinId = self.touchPointList.touchSkinId
	end

	self.touchPointList = {}

	self.data = indata
	local outdata = {}
	for index = 1 ,#indata do
		local _data = indata[index]
		local skininfo = PropMO.checkPropForSkin(_data.skinId)
		-- _data.skinId = _data.skinId
		-- _data.status = _data.status
		-- _data.remaining = _data.remaining
		-- _data.count = _data.count
		_data.name = skininfo.name 							-- 皮肤名称
		_data.category = skininfo.category 					-- 类别（1为普通，2为特殊）
		_data.quality = skininfo.quality 					-- 品质
		_data.subtitle = skininfo.subtitle 					-- 副标题
		_data.label = skininfo.label 						-- 标签（1为普通，2为史诗，3为传奇，4为限定）
		_data.canbuy = skininfo.canbuy 						-- 是否可购买（0为不可以，1为可以）
		_data.cansee = skininfo.cansee 						-- 未拥有时，是否可见（0为不可以，1为可以）
		_data.effectivetime = skininfo.effectivetime 		-- 持续时间（单位：秒。0为永久）
		_data.desc = skininfo.desc 							-- 皮肤效果描述
		_data.icon = skininfo.icon 							-- 图标地址
		_data.propId = skininfo.item 						-- 道具ID （用于购买）
		_data.price = skininfo.price 						-- 价格
		_data.show = skininfo.show 							-- 显示图标
		_data.order = skininfo.order 						-- 排序
		_data.vip = skininfo.vip 							-- VIP
		_data.type = skininfo.type 							-- 类型 1皮肤 2铭牌 3气泡
		_data.dynamics = skininfo.dynamics					-- 动态类型 1是 0否

		if not outdata[_data.category] then
			outdata[_data.category] = {}
		end

		if _data.status > 0 or _data.cansee == 1 then
			outdata[_data.category][#outdata[_data.category] + 1] = _data
		end

		if touchSkinId == _data.skinId then
			touchSkinData = _data
		end
	end

	local _width = self:getViewSize().width
	self.node = display.newNode()

	-- touchpoint
	local touchpoint = display.newSprite(IMAGE_COMMON .. "img_point.png"):addTo(self.node,10)
	touchpoint:setVisible(false)

	local function showPoint( item )
		touchpoint:setVisible(true)
		touchpoint:setPosition(item:getPosition())
		touchpoint:setScale(0.1)
		touchpoint:runAction(CCScaleTo:create(0.1,1))
	end

	-- 点击消息
	local function itembgTouchListner(node,data)
		node:setTouchEnabled(true)
		node:setTouchCaptureEnabled(true)
		node:setTouchSwallowEnabled(false)
		node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				return true
			elseif event.name == "ended" then
				if cc.rectContainsPoint(self.MineRect, cc.p(event.x,event.y)) then
					if cc.rectContainsPoint(node:getCascadeBoundingBox(), cc.p(event.x,event.y)) then
						if self.lastTouchSkinId ~= data.skinId then
							self.lastTouchSkinId = data.skinId
							local item = self.touchPointList[data.skinId]
							self.touchPointList.touchSkinId = data.skinId
							showPoint(item)
							if self.calls then self.calls(self.skinUI,data) end
						end
					end
				end
			end
		end)
	end

	-- 绘制皮肤列表
	local function drawFun(tdata, node, topY)
		local function mySort(a,b)
			return a.order < b.order
		end
		table.sort(tdata,mySort)
		local thisY = topY
		for index = 1 , #tdata do
			local _data = tdata[index]

			local _index = (index - 1)
			local _index_x = _index % 4
			local _index_y = math.floor(_index / 4)

			local scaleNum = 0.78

			-- 背景
			local bg = display.newSprite(IMAGE_COMMON .. "btn_position_normal.png"):addTo(node)
			bg:setScale(scaleNum)
			bg:setAnchorPoint(cc.p(0.5,1))
			local _y = thisY - 5 - (bg:getContentSize().height * _index_y * 1.4 * scaleNum)
			bg:setPosition(CalculateAllX(4,_index_x,_width,0), _y )
			topY = bg:y() - bg:height() * 1.45 * scaleNum
		
			-- 元素
			local item = display.newSprite("image/item/" .. _data.icon .. ".jpg"):addTo(node)
			item:setPosition(bg:x(),bg:y() - bg:height() * 0.5 * scaleNum)

			-- label （1为普通，2为史诗，3为传奇，4为限定）
			if _data.label > 1 then
				local lvlabel = display.newSprite(IMAGE_COMMON .. "skin_lable_" .. _data.label .. ".png"):addTo(item)
				lvlabel:setAnchorPoint(cc.p(0.5,0))
				lvlabel:setPosition(item:width() * 0.5, -3)
			end

			-- 个数
			local count = _data.count or 0
			if count > 0 then
				local numberlb = ui.newTTFLabel({text = UiUtil.strNumSimplify(count), font = G_FONT, color = ccc3(255,255,255), size = FONT_SIZE_LIMIT,
			 		x = item:width() - 2, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(item)
				numberlb:setAnchorPoint(cc.p(1,0))
			end
			
			-- 拥有
			if _data.status > 2 then
				local havedone = display.newSprite(IMAGE_COMMON .. "havedone.png"):addTo(item)
				havedone:setAnchorPoint(cc.p(0,1))
				havedone:setPosition(0,item:height())
			elseif _data.status == 2 then
				local haveusing = display.newSprite(IMAGE_COMMON .. "using.png"):addTo(item)
				haveusing:setAnchorPoint(cc.p(0,1))
				haveusing:setPosition(0,item:height())
			end

			-- 价格区
			if _data.canbuy == 1 and UserMO.vip_ > _data.vip then
				local pricebg = display.newSprite(IMAGE_COMMON .. "skin_gold_bg.png"):addTo(node)
				pricebg:setAnchorPoint(cc.p(0.5,1))
				pricebg:setPosition(bg:x(), bg:y() - bg:height() * scaleNum)

				local price = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(pricebg)
				price:setPosition(pricebg:width() * 0.25 , pricebg:height() * 0.5)

				local getCoinLabel = ui.newTTFLabel({text = tostring(_data.price), font = G_FONT, color = ccc3(255,255,0), size = FONT_SIZE_SMALL,
			 		x = pricebg:width() * 0.60, y = pricebg:height() * 0.5, align = ui.TEXT_ALIGN_CENTER}):addTo(pricebg)
			else
				local price = ui.newTTFLabel({text = CommonText[1061][3], font = G_FONT, color = ccc3(255,0,0), size = FONT_SIZE_SMALL,
			 		x = bg:x() , y = bg:y() - bg:height() * scaleNum , align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				price:setAnchorPoint(cc.p(0.5,1))
			end

			self.touchPointList[_data.skinId] = item
			
			-- touch
			itembgTouchListner(item, _data)

			-- 默认使用
			if _data.status == 2 and touchSkinId == 0 then
				local item = self.touchPointList[_data.skinId]
				self.touchPointList.touchSkinId = _data.skinId
				pitem = item
				showPoint(item)
				if self.calls then self.calls(self.skinUI,_data) end
			end
		end
		
		return topY
	end

	-- local categoryType = {{type = 1 , typeName = CommonText[1060][1]}, {type = 2 , typeName = CommonText[1060][2]}}
	local categoryType = {}
	if self.skinType == 1 then -- 基地皮肤
		categoryType = {{type = 1 , typeName = CommonText[1060][1]}, {type = 2 , typeName = CommonText[1060][2]}}
	elseif self.skinType == 2 then -- 铭牌
		categoryType = {{type = 1 , typeName = CommonText[1060][1]}}
	else --if self.skinType == 2 then -- 气泡
		categoryType = {{type = 1 , typeName = CommonText[1060][3]}}
	end
	
	local nodeY = -5
	local thisY = 0
	
	for index = 1 , #categoryType do
		thisY = nodeY
		local tip = display.newSprite(IMAGE_COMMON .. "info_bg_96.png"):addTo(self.node)
		tip:setAnchorPoint(cc.p(0.5,0))
		thisY = thisY - tip:height()
		tip:setPosition(_width * 0.5,thisY)
		thisY = thisY - 10
		nodeY = thisY

		local tipName = ui.newTTFLabel({text = categoryType[index].typeName, font = G_FONT, color = ccc3(255,255,255), size = FONT_SIZE_SMALL,
			 x = 100, y = tip:height() * 0.5 , align = ui.TEXT_ALIGN_CENTER}):addTo(tip)

		-- 绘制列表
		nodeY = drawFun(outdata[categoryType[index].type], self.node, nodeY)

	end

	self.m_cellSize = cc.size(_width, -nodeY )
	self:reloadData()

	--
	local titem = nil
	if touchSkinId == 0 then -- pitem
		titem = pitem
	else
		titem = self.touchPointList[touchSkinId]
		if titem then showPoint(titem) end
		if self.calls and touchSkinData then self.calls(self.skinUI,touchSkinData) end
	end

	if titem then -- 设置偏移 self:getViewSize()
		local dex = 0
		local _dex = -titem:y() + titem:height() - self:getViewSize().height
		if _dex > 0 then dex = _dex end
		self:setContentOffset(cc.p( 0 ,nodeY + self:getViewSize().height + dex))
	end

end

function SkinTableView:numberOfCells()
	return 1
end

function SkinTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SkinTableView:createCellAtIndex(cell, index)
	SkinTableView.super.createCellAtIndex(self, cell, index)
	self.node:addTo(cell)
	self.node:setPosition(0,self.m_cellSize.height)
	return cell
end


function SkinTableView:onExit()
	SkinTableView.super.onExit(self)
end








----------------------------------------------------------
--						皮肤管理						--
----------------------------------------------------------
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local SkinView = class("SkinView", UiNode)

function SkinView:ctor(size,skinType)
	SkinView.super.ctor(self)
	self.ViewSize = size
	self.skinType = skinType or 1
end

function SkinView:onEnter()
	SkinView.super.onEnter(self)

	self.skinActionResList = {}

	self.descType = {CommonText[1062][2],CommonText[1079][1],CommonText[1079][2]}
	self.showbyRes = {"skin_world_bg.jpg","skin_world_bg.jpg","skin_world_bg3.jpg"}

	if self.skinType == 1 then -- 基地皮肤
		----
		-- 背景
		local tipbg = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(self:getBg())
		tipbg:setAnchorPoint(cc.p(0.5,1))
		tipbg:setPosition(self.ViewSize.width * 0.5, self.ViewSize.height - 5)

		local size = cc.size(self.ViewSize.width - 10 , self.ViewSize.height - tipbg:getContentSize().height)

		local pages = {CommonText[1059][2],CommonText[1059][3]}

		local function createYesBtnCallback(index)
			local button = nil
			if index == 1 then
				local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
				button = MenuButton.new(normal, selected, nil, nil)
				button:setAnchorPoint(cc.p(0.5,0.5))
				button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height * 0.5 )
			elseif index == 2 then
				local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
				normal:setScaleX(-1)
				local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
				selected:setScaleX(-1)
				button = MenuButton.new(normal, selected, nil, nil)
				button:setAnchorPoint(cc.p(0.5,0.5))
				button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5 )
			end
			button:setLabel(pages[index])
			return button
		end

		local function createNoBtnCallback(index)
			local button = nil
			if index == 1 then
				local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
				button = MenuButton.new(normal, selected, nil, nil)
				button:setAnchorPoint(cc.p(0.5,0.5))
				button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5)
			elseif index == 2 then
				local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
				normal:setScaleX(-1)
				local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
				selected:setScaleX(-1)
				button = MenuButton.new(normal, selected, nil, nil)
				button:setAnchorPoint(cc.p(0.5,0.5))
				button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5)
			end
			button:setLabel(pages[index], {color = COLOR[11]})

			return button
		end

		-- 背景
		local function createDelegate(container, index)
			if index == 1 then 		-- 基地外观
				self:createWithSkin(container)
			elseif index == 2 then 	-- 行军效果
				
			end
		end

		local function clickDelegate(container, index)
		end

		local function clickBaginDelegate( index )
			if index == 2 then
				Toast.show(CommonText[1722])
				return false
			end
			return true
		end

		local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = self.ViewSize.width *0.5, y = 0, createDelegate = createDelegate, clickDelegate = clickDelegate, 
			clickBaginDelegate = clickBaginDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback},hideDelete = true,containerLayerLevel = 3}):addTo(self, 2)
		pageView:setAnchorPoint(cc.p(0.5,0))
		pageView:setPageIndex(1)
		----
	else -- 2 身份铭牌 3聊天气泡
		local baseNode = display.newNode():addTo(self:getBg(),2)
		baseNode:setAnchorPoint(cc.p(0,0))
		baseNode:setContentSize(cc.size(self.ViewSize.width - 10, self.ViewSize.height - 5))
		baseNode:setPosition(5,0)

		self:createWithSkin(baseNode)
	end


	self.skinItemTimeLock = false

	-- 打开计时器
	if not self.m_tickTimer then
		self.m_tickTimer = scheduler.scheduleGlobal(handler(self,self.onTick), 1)
	end
end

function SkinView:onTick(ft)
	if self.skinItemTimeLock then
		-- 处理倒计时
		-- 永久道具不会进入 self.skinItemTimeList 列表
		for index = #self.skinItemTimeList , 1, -1 do
			local data = self.skinItemTimeList[index]
			data.remaining = data.remaining - 1
			if data.remaining <= 0 then
				data.remaining = 0
				table.remove(self.skinItemTimeList, index)
			end
			-- 时间LB
			if self.leaveTimelb then
				if self.leaveTimelb.skinId == data.skinId then
					local str = "dhms"
					if data.remaining < 86400 then
						str = "hms"
						self.leaveTimelb:setColor(cc.c3b(255,0,0))
					else
						str = "dhm"
						self.leaveTimelb:setColor(cc.c3b(255,255,255))
					end
					self.leaveTimelb:setString(UiUtil.strBuildTime(data.remaining,str))
					
				end
			end
		end
	end
end

function SkinView:createWithSkin(container)
		-- 这里处理时间信息
	self.skinItemTimeLock = false

	-- 时间lable
	if self.leaveTimelb then
		self.leaveTimelb:setString("")
		self.leaveTimelb = nil
	end

	container:removeAllChildren()

	local containerViewSize = container:getContentSize()

	-- 背景
	local showbg = display.newSprite(IMAGE_COMMON .. self.showbyRes[self.skinType]):addTo(container)
	showbg:setAnchorPoint(cc.p(0.5,1))
	showbg:setPosition(containerViewSize.width * 0.5, containerViewSize.height - 5) --

	local _bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_95.png"):addTo(showbg,-1)
	_bg:setAnchorPoint(cc.p(0.5,0.5))
	_bg:setPreferredSize(cc.size(showbg:width() + 10, showbg:height() + 10 ))
	_bg:setPosition(showbg:width() * 0.5 , showbg:height() * 0.5)

	local line2 = display.newSprite(IMAGE_COMMON .. "line2.png"):addTo(showbg)
	line2:setAnchorPoint(cc.p(0.5,1))
	line2:setPosition(showbg:width() * 0.5 - 5,0)

	-- 皮肤显示
	local item = nil
	-- local item = display.newSprite(IMAGE_COMMON .. "bar_13.png"):addTo(showbg)
	-- item:setAnchorPoint(cc.p(0.5,0.5))
	-- item:setPosition(showbg:width() * 0.5 , showbg:height() * 0.5)

	-- itemEx
	local itemEx = nil
	-- itemExlb
	local itemExLB = nil

	-- 名字背景
	local itemNamebg = display.newSprite(IMAGE_COMMON .. "skinnamedi.png"):addTo(showbg,1)
	itemNamebg:setAnchorPoint(cc.p(1,1))
	itemNamebg:setPosition(showbg:width() ,showbg:height())


	-- 名字
	local itemNamelb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = itemNamebg:width() * 0.5, y = itemNamebg:height() * 0.5, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(225, 225, 225)}):addTo(itemNamebg)

	-- 有效天数
	local itemMaxDaylb = display.newSprite(IMAGE_COMMON .. "sevenday.png"):addTo(itemNamebg)
	itemMaxDaylb:setPosition(itemNamebg:width() * 0.5 , itemNamebg:height() - 20)

	-- 皮肤描述bg
	local itemDescbg = display.newSprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(showbg,3)
	itemDescbg:setAnchorPoint(cc.p(0,0))
	itemDescbg:setScaleX(2.5)
	itemDescbg:setScaleY(1.5)
	itemDescbg:setPosition(1,1)
	
	-- 皮肤描述
	local itemDesclb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, x = 6, y = itemDescbg:y() + itemDescbg:height() * 0.5 + 6, 
		align = ui.TEXT_ALIGN_LEFT, color = cc.c3b(225, 225, 0),dimensions = cc.size(itemDescbg:width() * 3,itemDescbg:height()*1.5)}):addTo(showbg,4)
	itemDesclb:setAnchorPoint(cc.p(0,0.5))

	-- 多功能按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local funBtn = MenuButton.new(normal,selected,disabled,handler(self,self.btnFuncCallback)):addTo(showbg)
	funBtn:setAnchorPoint(1,0)
	funBtn:setPosition(showbg:width(), 0)
	funBtn:setEnabled(false)

	-- 剩余时间 bg
	local itemleavetimebg = display.newSprite(IMAGE_COMMON .. "info_bg_13.png"):addTo(showbg,3)
	itemleavetimebg:setAnchorPoint(cc.p(0,0))
	itemleavetimebg:setPosition(funBtn:x() - funBtn:width() , funBtn:y() + funBtn:height() - 10)
	itemleavetimebg:setVisible(false)

	-- 剩余时间
	local itemleavetimelb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = itemleavetimebg:x() + itemleavetimebg:width() * 0.25, y = funBtn:y() + funBtn:height() , align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(225, 225, 255)}):addTo(showbg,4)
	itemleavetimelb:setAnchorPoint(cc.p(0,0.5))

	local showSkin = {}
	showSkin.showbg = showbg 				-- 背景
	showSkin.item = item 					-- 皮肤
	showSkin.itemEx = itemEx				-- 主体附加
	showSkin.itemExLB = itemExLB 			-- 主体附加文字
	showSkin.itemNamelb = itemNamelb 		-- 名字
	showSkin.itemMaxDaylb = itemMaxDaylb 	-- 天数
	showSkin.itemDesclb = itemDesclb 		-- 描述
	showSkin.funBtn = funBtn 			    -- 按钮
	showSkin.itemleavetimelb = itemleavetimelb 	-- 剩余时间
	showSkin.itemleavetimebg = itemleavetimebg 	-- 剩余时间背景
	showSkin.itemNamebg = itemNamebg 			-- 名字背景


	-- 内容背景
	local skinListContentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_82.png"):addTo(self:getBg(),4)
	skinListContentBg:setAnchorPoint(cc.p(0.5,1))
	skinListContentBg:setPreferredSize(cc.size(containerViewSize.width - 30, showbg:y() - showbg:height() - 10 ))
	skinListContentBg:setPosition(containerViewSize.width * 0.5 ,showbg:y() - showbg:height() - 10 )

	-- 系统提示背景
	local sysbg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(skinListContentBg)
	sysbg:setAnchorPoint(cc.p(0.5, 1))
	sysbg:setPosition(skinListContentBg:width() * 0.5, skinListContentBg:height() - 7)
    
    -- 系统头像 文字 info_bg_28.png
    local titleNameTip = {CommonText[1062][1],CommonText[1078][1],CommonText[1078][2]}
	ui.newTTFLabel({text = titleNameTip[self.skinType], font = G_FONT, size = FONT_SIZE_TINY, x = sysbg:width() * 0.5, y = sysbg:height() * 0.5 + 2, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(225, 225, 225)}):addTo(sysbg)

 	-- 列表
	local skinlist = SkinTableView.new(cc.size(skinListContentBg:width() - 50 , skinListContentBg:height() - sysbg:height() - 7 - 25), handler(self,self.reflushTarget),showSkin,self.skinType):addTo(skinListContentBg)
	skinlist:setPos(25, 23)
	self.skinlist = skinlist

	PropBO.GetSkins(handler(self,self.LoadInfo),self.skinType)

end

function SkinView:LoadInfo( data )

	self.skinItemTimeList = {}

	-- 在列表里处理数据
	local outdata = {}

	local skindata = PbProtocol.decodeArray(data["skin"])

	-- dump(skindata)

	for index = 1 , #skindata do
		local out = {}
		local _data = skindata[index]
		out.skinId = _data.skinId
		out.status = _data.status
		out.remaining = _data.remaining
		out.count = _data.count --(临时test)
		outdata[#outdata + 1] = out 											-- 加入数据队列

		if (out.status == 2 or out.status == 3) and out.remaining > 0 then
			self.skinItemTimeList[#self.skinItemTimeList + 1] = out 			-- 加入倒计时队列
		end
	end

	self.skinlist:makeDraw(outdata)

	self.skinItemTimeLock = true
end

-- 刷新顶部数据
function SkinView:reflushTarget(uiInfo, data)
	-- showSkin.showbg = showbg 				-- 背景
	-- showSkin.item = item 					-- 皮肤
	-- showSkin.itemEx = itemEx				    -- 主体附加
	-- showSkin.itemExLB = itemExLB 			-- 主体附加文字
	-- showSkin.itemNamelb = itemNamelb 		-- 名字
	-- showSkin.itemMaxDaylb = itemMaxDaylb 	-- 天数
	-- showSkin.itemDesclb = itemDesclb 		-- 描述
	-- showSkin.funBtn = funBtn 			    -- 按钮
	-- showSkin.itemleavetimelb = itemleavetimelb 	-- 剩余时间
	-- showSkin.itemleavetimebg = itemleavetimebg 	-- 剩余时间背景
	-- showSkin.itemNamebg = itemNamebg 			-- 名字背景
	-------------------------
	-- _data.skinId = _data.skinId
		-- _data.status = _data.status
		-- _data.remaining = _data.remaining
		-- _data.count = _data.count
		-- _data.name = skininfo.name 							-- 皮肤名称
		-- _data.category = skininfo.category 					-- 类别（1为普通，2为特殊）
		-- _data.quality = skininfo.quality 					-- 品质
		-- _data.subtitle = skininfo.subtitle 					-- 副标题 
		-- _data.label = skininfo.label 						-- 标签（1为普通，2为史诗，3为传奇，4为限定）
		-- _data.canbuy = skininfo.canbuy 						-- 是否可购买（0为不可以，1为可以）
		-- _data.cansee = skininfo.cansee 						-- 未拥有时，是否可见（0为不可以，1为可以）
		-- _data.effectivetime = skininfo.effectivetime 		-- 持续时间（单位：秒。0为永久）
		-- _data.desc = skininfo.desc 							-- 皮肤效果描述
		-- _data.icon = skininfo.icon 							-- 图标地址
		-- _data.propId = skininfo.item 						-- 道具ID （用于购买）
		----------------------------

	-- 时间lable 预处理
	if self.leaveTimelb then
		self.leaveTimelb:setString("")
		self.leaveTimelb = nil
	end

	-- 名字 更新
	uiInfo.itemNamelb:setString(data.name)

	-- 描述 更新
	uiInfo.itemDesclb:setString(self.descType[self.skinType] .. "：" .. data.desc)

	-- 副标题 更新
	if uiInfo.itemMaxDaylb then
		uiInfo.itemNamebg:removeChild(uiInfo.itemMaxDaylb)
		uiInfo.itemMaxDaylb = nil
	end
	if data.subtitle == 1 then -- 1 7天 2永久
		local itemMaxDaylb = display.newSprite(IMAGE_COMMON .. "sevenday.png"):addTo(uiInfo.itemNamebg)
		itemMaxDaylb:setPosition(uiInfo.itemNamebg:width() * 0.5 , uiInfo.itemNamebg:height() - 20)
		uiInfo.itemMaxDaylb = itemMaxDaylb
	elseif data.subtitle == 2 then
		local itemMaxDaylb = display.newSprite(IMAGE_COMMON .. "forever.png"):addTo(uiInfo.itemNamebg)
		itemMaxDaylb:setPosition(uiInfo.itemNamebg:width() * 0.5 , uiInfo.itemNamebg:height() - 20)
		uiInfo.itemMaxDaylb = itemMaxDaylb
	end

	-- 倒计时 更新 status >= 2 2正在使用 | 3以被替换
	if data.status >= 2 then
		if data.remaining <= -1 then --and data.count == -1 then 	-- 永久
			uiInfo.itemleavetimelb:setString("")
			uiInfo.itemleavetimelb:setColor(ccc3(255,255,255))
			uiInfo.itemleavetimebg:setVisible(false)
		else 														-- 
			self.leaveTimelb = uiInfo.itemleavetimelb
			self.leaveTimelb.skinId = data.skinId
			uiInfo.itemleavetimebg:setVisible(true)
		end
	else
		uiInfo.itemleavetimelb:setString("")
		uiInfo.itemleavetimebg:setVisible(false)
	end

	-- 按钮状态 data.status： 0购买 1使用 2续购|不可购买 3已有/未使用
	if data.status == 0 then
		if data.canbuy == 1 then
			uiInfo.funBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
			uiInfo.funBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
			uiInfo.funBtn:setLabel(CommonText[1061][1])
			uiInfo.funBtn:setEnabled(true)
			uiInfo.funBtn:setVisible(true)
		else
			if data.vip == -1 then
				uiInfo.funBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
				uiInfo.funBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
				uiInfo.funBtn:setLabel(CommonText[1061][3])
				uiInfo.funBtn:setEnabled(false)
				uiInfo.funBtn:setVisible(true)
			else
				-- VIP需求
				uiInfo.funBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
				uiInfo.funBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
				uiInfo.funBtn:setLabel(CommonText[1061][2])
				uiInfo.funBtn:setEnabled(true)
				uiInfo.funBtn:setVisible(true)
			end
		end
	elseif data.status == 2 then
		if data.canbuy == 1 then
			if data.count >= 1 then
				-- 使用
				uiInfo.funBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_11_normal.png"))
				uiInfo.funBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_11_normal.png"))
				uiInfo.funBtn:setLabel(CommonText[1061][4])
				uiInfo.funBtn:setEnabled(true)
				uiInfo.funBtn:setVisible(true)
			else
				-- 续购
				uiInfo.funBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
				uiInfo.funBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
				uiInfo.funBtn:setLabel(CommonText[1061][5])
				uiInfo.funBtn:setEnabled(true)
				uiInfo.funBtn:setVisible(true)
			end
		else
			if data.vip == -1 then
				uiInfo.funBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
				uiInfo.funBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_63_normal.png"))
				uiInfo.funBtn:setLabel(CommonText[1061][3])
				uiInfo.funBtn:setEnabled(false)
				uiInfo.funBtn:setVisible(true)
			else
				uiInfo.funBtn:setVisible(false)
			end
		end
	elseif data.status == 3 then
		uiInfo.funBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_64_normal.png"))
		uiInfo.funBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_64_normal.png"))
		uiInfo.funBtn:setLabel(CommonText[1061][2])
		uiInfo.funBtn:setEnabled(true)
		uiInfo.funBtn:setVisible(true)
	else -- 1
		uiInfo.funBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_11_normal.png"))
		uiInfo.funBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_11_normal.png"))
		uiInfo.funBtn:setLabel(CommonText[1061][4])
		uiInfo.funBtn:setEnabled(true)
		uiInfo.funBtn:setVisible(true)
	end
	uiInfo.funBtn.status = data.status
	uiInfo.funBtn.skinId = data.skinId
	uiInfo.funBtn.propId = data.propId
	uiInfo.funBtn.price = data.price
	uiInfo.funBtn.count = data.count
	uiInfo.funBtn.remaining = data.remaining
	uiInfo.funBtn.vip = data.vip

	
	-----------------------------
	if self.skinType == 1 then -- 皮肤
		-- 更新皮肤
		if uiInfo.item then
			uiInfo.showbg:removeChild(uiInfo.item)
			uiInfo.item = nil
		end
		
		if data.dynamics == 1 then -- 动态皮肤
			if not self.skinActionResList[data.skinId] then
				self.skinActionResList[data.skinId] = "animation/skin/" .. data.show .. "_action"
			end
            armature_add(IMAGE_ANIMATION .. "skin/" .. data.show .. "_action.pvr.ccz", IMAGE_ANIMATION .. "skin/" .. data.show .. "_action.plist", IMAGE_ANIMATION .. "skin/" .. data.show .. "_action.xml")
            local armature = armature_create(data.show .. "_action")
            armature:getAnimation():playWithIndex(0)
            local node = display.newNode()
            node:setContentSize(cc.size(armature:width(), armature:height()))
            armature:setAnchorPoint(cc.p(0.5, 0))
            armature:setPosition(node:width() * 0.5, 0)
            node:setAnchorPoint(cc.p(0.5,0.5))
            node:setPosition(uiInfo.showbg:width() * 0.5 , uiInfo.showbg:height() * 0.5)
            node:setScale(0.75)
            node:addChild(armature)
            uiInfo.showbg:addChild(node,1)
            uiInfo.item = node
		else -- 静态皮肤
			local item = display.newSprite("image/skin/base/" .. data.show ..".png"):addTo(uiInfo.showbg,1)
			item:setAnchorPoint(cc.p(0.5,0.5))
			item:setPosition(uiInfo.showbg:width() * 0.5 , uiInfo.showbg:height() * 0.5)
			uiInfo.item = item
		end
	elseif self.skinType == 2 then -- 铭牌
		-- 基地
		if not uiInfo.item then
			local item = display.newSprite("image/skin/base/w_b_1.png"):addTo(uiInfo.showbg,1)
			item:setAnchorPoint(cc.p(0.5,0.5))
			item:setPosition(uiInfo.showbg:width() * 0.5 , uiInfo.showbg:height() * 0.5)
			uiInfo.item = item
		end

		-- 文字
		if not uiInfo.itemExLB then
			local itemExLB = ui.newTTFLabel({text = CommonText[1078][1], font = G_FONT, size = FONT_SIZE_LIMIT, x = 0, y = 0, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(uiInfo.item,3)
			itemExLB:setAnchorPoint(cc.p(0.5, 0.5))
			uiInfo.itemExLB = itemExLB
		end

		-- 名牌
		if uiInfo.itemEx then
			uiInfo.item:removeChild(uiInfo.itemEx)
			uiInfo.itemEx = nil
		end

		local width = 100 
		local height = 20
		if uiInfo.itemExLB then
			width = uiInfo.itemExLB:width() + 40
			height = uiInfo.itemExLB:height() + 10
		end
		local itemEx = display.newScale9Sprite("image/skin/board/nameplate_" .. data.show ..".png"):addTo(uiInfo.item,1)
		itemEx:setPreferredSize(cc.size(width, height))
		itemEx:setAnchorPoint(cc.p(0.5,1))
		itemEx:setPosition(uiInfo.item:width() * 0.5 , uiInfo.item:height())
		uiInfo.itemEx = itemEx

		if uiInfo.itemExLB and uiInfo.itemEx then
			uiInfo.itemExLB:setPosition(uiInfo.itemEx:x() , uiInfo.itemEx:y() - uiInfo.itemEx:height() * 0.5)
		end
	elseif self.skinType == 3 then -- 聊天气泡
		-- 文字
		if not uiInfo.itemExLB then
			local itemExLB = ui.newTTFLabel({text = CommonText[1078][2], font = G_FONT, size = FONT_SIZE_LIMIT, x = 0, y = 0, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(uiInfo.showbg,3)
			itemExLB:setAnchorPoint(cc.p(0.5, 0.5))
			uiInfo.itemExLB = itemExLB
		end

		-- 气泡
		if uiInfo.itemEx then
			uiInfo.showbg:removeChild(uiInfo.itemEx)
			uiInfo.itemEx = nil
		end

		local width = 200 
		local height = 40
		if uiInfo.itemExLB then
			width = uiInfo.itemExLB:width() * 2 + 150
			height = uiInfo.itemExLB:height() * 2 + 20
		end

		local types = ChatMO.bubbleType[data.skinId].right
		local itemEx = display.newScale9Sprite("image/skin/chat/r_chatBg_" .. data.show ..".png"):addTo(uiInfo.showbg,1)
		itemEx:setPreferredSize(cc.size(math.max(types.width,width), math.max(types.height,height)))
		itemEx:setCapInsets(types.rect)
		itemEx:setAnchorPoint(cc.p(0.5,0.25))
		itemEx:setPosition(uiInfo.showbg:width() * 0.5 , uiInfo.showbg:height() * 0.5)
		uiInfo.itemEx = itemEx

		if uiInfo.itemExLB and uiInfo.itemEx then
			uiInfo.itemExLB:setPosition(uiInfo.itemEx:x() , uiInfo.itemEx:y() + uiInfo.itemEx:height() * 0.25)
		end
	end
	

end

function SkinView:btnFuncCallback(tag, sender)
	local status = sender.status
	local count = sender.count
	local vip = sender.vip
	-- data.status： 0购买 1使用 2续购|不可购买 3使用
	if vip ~= -1 and UserMO.vip_ < vip then
		Toast.show(string.format(CommonText[1080], vip))
		return
	end

	local doFunc = handler(self,self.LoadInfo)

	if status == 1 or status == 3 or (status == 2 and count > 0) then
		-- 使用
		local ischange = false
		if status == 3 then
			count = 1
			ischange = true
		end
		if status == 1 and sender.remaining < 0 then
			count = 1
		end
		local function useFunc(number, doneUse)
			self.skinItemTimeLock = false
			local function useDo( data )
				doneUse()
				doFunc(data)
			end
			PropBO.UseSkin(useDo,sender.skinId,number,sender.propId,self.skinType)
		end
		SkinUseDialog.new(sender.skinId, count, useFunc, ischange):push()
		
	else		
		-- 购买
		local function buyFunc(number,doneBuy)
			self.skinItemTimeLock = false
			local function buyDo( data )
				doneBuy()
				doFunc(data)
			end
			PropBO.BuySkin(buyDo,sender.skinId,number,sender.propId,self.skinType)
		end
		SkinBuyDialog.new(sender.skinId, {price = sender.price, nowtime = 1, rhand = buyFunc}):push()
	end

end


function SkinView:onExit()
	SkinView.super.onExit(self)
	for k ,v in pairs(self.skinActionResList) do
		armature_remove(v .. ".pvr.ccz", v .. ".plist", v .. ".xml")
	end
	if self.m_tickTimer then
		scheduler.unscheduleGlobal(self.m_tickTimer)
		self.m_tickTimer = nil
	end
end


return SkinView