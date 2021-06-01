
--------------------------------------------------------------------
-- 用于道具生产的所需资源的tableview
--------------------------------------------------------------------

local PropResTableView = class("PropResTableView", TableView)

function PropResTableView:ctor(size, propId)
	PropResTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	-- -- self.m_tanks = TankMO.getFightTanks()
	-- self.m_tanks = tanks
	-- gdump(self.m_tanks, "PropResTableView ctor")

	self.m_propId = propId
	self.m_cellSize = cc.size(size.width, 80)
	
	self.m_cellNum = 0
	self.m_contents = {}

	local prop = PropMO.queryPropById(propId)

	if prop.stoneCost > 0 then
		self.m_cellNum = self.m_cellNum + 1
		self.m_contents[self.m_cellNum] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_STONE, need = prop.stoneCost}
	end

	if prop.skillBook > 0 then
		self.m_cellNum = self.m_cellNum + 1
		self.m_contents[self.m_cellNum] = {kind = ITEM_KIND_PROP, id = PROP_ID_SKILL_BOOK, need = prop.skillBook}
	end

	if prop.heroChip > 0 then
		self.m_cellNum = self.m_cellNum + 1
		self.m_contents[self.m_cellNum] = {kind = ITEM_KIND_PROP, id = PROP_ID_HERO_CHIP, need = prop.heroChip}
	end

	-- ex
	if prop.buildCost then
		local _buildCosts =  json.decode(prop.buildCost)
		for index = 1, #_buildCosts do
			local cost = _buildCosts[index]
			local kind = cost[1]
			local id = cost[2]
			local need = cost[3]
			self.m_cellNum = self.m_cellNum + 1
			self.m_contents[self.m_cellNum] = {kind = kind, id = id, need = need}
		end
	end


	self.m_curProductNum = 0
end

function PropResTableView:numberOfCells()
	return self.m_cellNum
end

function PropResTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PropResTableView:createCellAtIndex(cell, index)
	local contentData = self.m_contents[index]

	local view = UiUtil.createItemView(contentData.kind, contentData.id):addTo(cell)
	view:setScale(0.65)
	view:setPosition(68, self.m_cellSize.height / 2)

	-- 类别
	local strname = ""
	if contentData.kind == ITEM_KIND_PROP then
		strname = PropMO.getPropName(contentData.id)
	else
		strname = UserMO.getResourceData(contentData.kind, contentData.id).name2
	end

	-- 类别
	local name = ui.newTTFLabel({text = strname, font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setColor(COLOR[11])
	cell.nameLabel = name

	-- 需求
	local labelN = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 263, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	cell.needLabel = labelN

	-- 当前拥有
	local labelC = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt", x = 385, y = self.m_cellSize.height / 2}):addTo(cell)
	labelC:setAnchorPoint(cc.p(0, 0.5))
	cell.haslabel = labelC

	local gou = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 360, self.m_cellSize.height / 2):addTo(cell)
	cell.gouView = gou

	local cha = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 360, self.m_cellSize.height / 2):addTo(cell)
	cell.chaView = cha

	if index ~= 1 then -- 两行之间的横线
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
		line:setPreferredSize(cc.size(464, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 + 40)
	end

	self:updateCell(cell, index)

	return cell
end

function PropResTableView:updateCell(cell, cellIndex)
	local productProp = PropMO.queryPropById(self.m_propId)

	local contentData = self.m_contents[cellIndex]

	local count = UserMO.getResource(contentData.kind, contentData.id)
	local need = contentData.need * self.m_curProductNum

	cell.needLabel:setString(UiUtil.strNumSimplify(need))
	cell.haslabel:setString(UiUtil.strNumSimplify(count))

	if need <= count then -- 足够
		cell.gouView:setVisible(true)
		cell.chaView:setVisible(false)
		cell.nameLabel:setColor(COLOR[11])
		cell.needLabel:setColor(COLOR[11])
	else -- 不足够
		cell.gouView:setVisible(false)
		cell.chaView:setVisible(true)
		cell.nameLabel:setColor(COLOR[6])
		cell.needLabel:setColor(COLOR[6])
	end
end

function PropResTableView:setCurProductNum(num)
	self.m_curProductNum = num

	for index = 1, self.m_cellNum do
		local cell = self:cellAtIndex(index)
		if cell then
			self:updateCell(cell, index)
		end
	end
end

--------------------------------------------------------------------
-- 物资生产弹出框
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local PropProductDialog = class("PropProductDialog", Dialog)

function PropProductDialog:ctor(propId, productCallback)
	PropProductDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_LEFT_TO_RIGHT, {scale9Size = cc.size(588, 860)})

	self.m_propId = propId
	self.m_productCallback = productCallback
end

function PropProductDialog:onEnter()
	PropProductDialog.super.onEnter(self)
	
	local propDB = PropMO.queryPropById(self.m_propId)
	self.m_prop = propDB

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[204]) -- 物资生产

	local labelColor = COLOR[11]
	local greenLabelColor = COLOR[2]

	--
	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, propDB.propId):addTo(self:getBg())
	itemView:setPosition(110, self:getBg():getContentSize().height - 130)

	-- 名称
	local name = ui.newTTFLabel({text = PropMO.getPropName(self.m_propId), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self:getBg():getContentSize().height - 95, color = COLOR[propDB.color], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 当前数量
	local label = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_PROP, propDB.propId), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))

	local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", label:getPositionX(), label:getPositionY() - 30):addTo(self:getBg())
	clock:setAnchorPoint(cc.p(0, 0.5))
	local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(propDB.buildTime), font = "fnt/num_2.fnt"}):addTo(self:getBg())
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())

	local desc = propDB.desc or ""
	local label = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 60, y = self:getBg():getContentSize().height - 210, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local resBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_19.png"):addTo(self:getBg())
	resBg:setPreferredSize(cc.size(526, 336))
	resBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 + 30)

	local view = PropResTableView.new(cc.size(resBg:getContentSize().width, 278), self.m_propId):addTo(resBg)
	view:setPosition(0, 12)
	view:reloadData()
	self.m_resTablView = view

	-- 类别
	local title = ui.newTTFLabel({text = CommonText[61], font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = resBg:getContentSize().height - 26, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 需求
	local title = ui.newTTFLabel({text = CommonText[62], font = G_FONT, size = FONT_SIZE_SMALL, x = 260, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 当前拥有
	local title = ui.newTTFLabel({text = CommonText[63], font = G_FONT, size = FONT_SIZE_SMALL, x = resBg:getContentSize().width - 100, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	-- 数量
	local desc = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = 160, y = 230, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, color = labelColor}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))
	local num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, x = desc:getPositionX() +  desc:getContentSize().width + 5, y = desc:getPositionY(), color = greenLabelColor}):addTo(self:getBg())
	num:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = num

	-- 生产需要时间
	local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 320, num:getPositionY()):addTo(self:getBg())
	clock:setAnchorPoint(cc.p(0, 0.5))
	local time = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(self:getBg())
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
	self.m_timeLabel = time

	self:showSlider()

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(btm)
    reduceBtn:setPosition(50, 150 - 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(btm)
    addBtn:setPosition(btm:getContentSize().width - 50, reduceBtn:getPositionY())

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local okBtn = MenuButton.new(normal, selected, nil, handler(self, self.onOkCallback)):addTo(self:getBg())
	okBtn:setPosition(self:getBg():getContentSize().width / 2, 26)
	okBtn:setLabel(CommonText[1])
end

function PropProductDialog:showSlider()
	local barHeight = 40
	local barWidth = 286
	if self.m_numSlider then
		self.m_numSlider:removeSelf()
		self.m_numSlider = nil
	end

	self.m_minNum = 1
	self.m_maxNum = PropBO.canProductMaxNum(self.m_propId)
	if self.m_maxNum == 0 then self.m_maxNum = 1 end
	if self.m_maxNum == 0 then self.m_minNum = 0 end
	if self.m_maxNum >= 100 then self.m_maxNum = 100 end
	
	self.m_settingNum = 1

	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 150)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(364, 64), {x = barWidth / 2, y = barHeight / 2 - 4})
end

function PropProductDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function PropProductDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function PropProductDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	-- gprint("PropProductDialog value:", value)
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	self.m_timeLabel:setString(UiUtil.strBuildTime(self.m_prop.buildTime * self.m_settingNum))
	self.m_resTablView:setCurProductNum(self.m_settingNum)
end

function PropProductDialog:onOkCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if PropBO.canProductMaxNum(self.m_propId) <= 0 then -- 资源不足，无法生产
		Toast.show(CommonText[205])
		return
	end

	if self.m_productCallback then
		self.m_productCallback(self.m_propId, self.m_settingNum)
	end

	self:pop()
end

return PropProductDialog
