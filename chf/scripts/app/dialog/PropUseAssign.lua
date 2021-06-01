--
-- Author: xiaoxing
-- Date: 2017-01-18 14:02:48
--
-- 指定使用弹出框
local ContentTableView = class("ContentTableView", TableView)
local rhand = rhand
function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 138)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	UiUtil.sprite9("info_bg_26.png", 220, 80, 1, 1, 500, 138)
		:addTo(cell, -1):pos(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	local itemView = UiUtil.createItemView(data[1], data[2], {count = data[3]}):addTo(cell):pos(90, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(itemView,cell,true)

	local resData = UserMO.getResourceData(data[1], data[2])
	-- 名称
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 112, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = resData.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 70, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(230, 80)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	local btn = UiUtil.button("btn_7_unchecked.png", "btn_7_unchecked.png", nil, handler(self, self.onChosenCallback), nil, 1)
	btn.index = index
	btn.data = data
	cell:addButton(btn, self.m_cellSize.width - 75, self.m_cellSize.height / 2)
	cell.flag = display.newSprite(IMAGE_COMMON.."btn_7_checked.png"):addTo(btn):center()
	cell.flag:hide()
	if not self.m_chosenIndex then
		self.m_chosenIndex = index
		self.chooseData = data
		cell.flag:show()
	elseif self.m_chosenIndex == index then
		cell.flag:show()
	end
	return cell
end

function ContentTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.index == self.m_chosenIndex then
	else
		self.m_chosenIndex = sender.index
		self.chooseData = sender.data
		self:chosenIndex(sender.index)
	end
end

function ContentTableView:chosenIndex(menuIndex)
	for index = 1, #self.m_activityList do
		local cell = self:cellAtIndex(index)
		if cell then
			if index == self.m_chosenIndex then
				cell.flag:show()
			else
				cell.flag:hide()
			end
		end
	end
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
	self.m_activityList = data or {}
	self:reloadData()
end
--------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local PropUseAssign = class("PropUseAssign", Dialog)

function PropUseAssign:ctor(propId, useCallback)
	PropUseAssign.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 834)})

	self.m_propId = propId
	self.m_useCallback = useCallback
end

function PropUseAssign:onEnter()
	PropUseAssign.super.onEnter(self)

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.m_propId)
	self:setTitle(resData.name) -- 批量使用
	local propCount = UserMO.getResource(ITEM_KIND_PROP, self.m_propId)

	self.m_propDB = PropMO.queryPropById(self.m_propId)

	local bg = self:getBg()
	local item = UiUtil.sprite9("info_bg_26.png", 220, 80, 1, 1, 500, 138)
		:addTo(bg):pos(bg:width() / 2, bg:height() - 135)
	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, self.m_propId, {count = propCount}):addTo(item):pos(90, item:height()/2)
	-- 名称
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 112, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(item)
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = self.m_propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 70, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(item)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	UiUtil.label(CommonText[20194]):addTo(bg):alignTo(item, -85, 1)

	local view = ContentTableView.new(cc.size(500, bg:height()-430))
		:addTo(bg):pos(42,196)
	self.view = view
	--找出所有符合条件的科技类型 
	view:updateUI(json.decode(self.m_propDB.effectValue))
	local t = UiUtil.label(CommonText[914][2]):addTo(bg):align(display.LEFT_CENTER, 400, 85)
	self.m_numLabel = UiUtil.label(0,nil,COLOR[2]):rightTo(t)
 	local barHeight = 40
	local barWidth = 266

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    reduceBtn:setPosition(self:getBg():getContentSize().width / 2 - barWidth / 2 - 78, 140 + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(self:getBg():getContentSize().width / 2 + barWidth / 2 + 78, reduceBtn:getPositionY())

    self.m_maxNum = propCount
    self.m_minNum = 1
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM end
	self.m_settingNum = self.m_maxNum

	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 140)
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
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2, 85)
end

function PropUseAssign:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function PropUseAssign:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function PropUseAssign:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
end

function PropUseAssign:onOkCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_settingNum <= 0 then return end
    PropBO.usePropChoose(self.m_propId,self.m_settingNum,self.view.chooseData[2],self.view.chooseData[1],function()
    	-- local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.m_propId)
    	-- Toast.show(CommonText[84]..resData.name)
    	if self.m_useCallback then
    		self.m_useCallback()
    	end
    	self:pop()
    end)
end

return PropUseAssign
