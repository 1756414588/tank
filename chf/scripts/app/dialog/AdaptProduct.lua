--
-- Author: Xiaohang
-- Date: 2016-05-03 16:43:41
--

--------------------------------------------------------------------
-- 坦克改装消耗资源TableView
--------------------------------------------------------------------

local itemKind = {RESOURCE_ID_IRON, RESOURCE_ID_OIL, RESOURCE_ID_COPPER, RESOURCE_ID_SILICON} -- 铁、石油、铜、硅

local ResTableView = class("ResTableView", TableView)

-- tankId: 需要进行改装的tank
function ResTableView:ctor(size, tankId)
	ResTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 80)
	self.m_refitTankDB = TankMO.queryTankById(tankId)

	self.m_assistItem = {}
	local mo = OrdnanceMO.queryTankById(tankId)
	for k,v in ipairs(json.decode(mo.militaryRefitConsume)) do
		if v[1] and v[1] > 0 then
			table.insert(self.m_assistItem,{kind=v[1],id=v[2],need=v[3]})
		end
	end
	self.m_assistItem[#self.m_assistItem + 1] = {kind = ITEM_KIND_TANK, id = mo.militaryRefitBaseTankId, need = 1}

	self.m_curProductNum = 0
end

function ResTableView:numberOfCells()
	return #self.m_assistItem
end

function ResTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ResTableView:createCellAtIndex(cell, index)
	ResTableView.super.createCellAtIndex(self, cell, index)

	local item = self.m_assistItem[index]
	local view = UiUtil.createItemView(item.kind, item.id):addTo(cell)
	view:setPosition(74, self.m_cellSize.height / 2)
	view:setScale(0.65)

	-- 类别
	local resData = UserMO.getResourceData(item.kind, item.id)
	local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 174, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setColor(COLOR[11])
	cell.nameLabel = name

	-- 需求
	local labelN = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 283, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	cell.needLabel = labelN

	-- 当前拥有
	local labelC = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt", x = 390, y = self.m_cellSize.height / 2}):addTo(cell)
	labelC:setAnchorPoint(cc.p(0, 0.5))
	cell.haslabel = labelC

	local gou = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 370, self.m_cellSize.height / 2):addTo(cell)
	cell.gouView = gou

	local cha = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 370, self.m_cellSize.height / 2):addTo(cell)
	cell.chaView = cha

	if index ~= 1 then -- 两行之间的横线
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
		line:setPreferredSize(cc.size(554, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 + 40)
	end

	self:updateCell(cell, index)

	local function onUseCallback(tag, sender)  -- 物品使用弹出框
		ManagerSound.playNormalButtonSound()
		local index = sender.index
		if self.m_assistItem[index].kind == ITEM_KIND_RESOURCE then
			require("app.dialog.ItemUseDialog").new(ITEM_KIND_RESOURCE, self.m_assistItem[index].id):push()
		elseif self.m_assistItem[index].kind == ITEM_KIND_PROP then
			UiDirector.pop(function() require("app.view.BagView").new(BAG_VIEW_FOR_SHOP):push() end)
		elseif self.m_assistItem[index].kind == ITEM_KIND_TANK then
			UiDirector.pop(function() require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_A, 2):push() end)
		end
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, onUseCallback)
	btn:setScale(0.9)
	btn.index = index
	cell:addButton(btn, 560, self.m_cellSize.height / 2)

	return cell
end

function ResTableView:updateCell(cell, cellIndex)
	local item = self.m_assistItem[cellIndex]

	local need = item.need
	need = need * self.m_curProductNum

	local count = UserMO.getResource(item.kind, item.id)
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

function ResTableView:setCurProductNum(num)
	self.m_curProductNum = num

	for index = 1, self:numberOfCells() do
		local cell = self:cellAtIndex(index)
		if cell then
			self:updateCell(cell, index)
		end
	end
end

------------------------------------------------------------------------------
-- 坦克改装view
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local AdaptProduct = class("AdaptProduct", Dialog)

-- tankId: 需要改装的tank
function AdaptProduct:ctor(data,rhand)
	AdaptProduct.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.data = data
	self.rhand = rhand
	self.m_tankId = self.data.tankId
end

function AdaptProduct:onEnter()
	AdaptProduct.super.onEnter(self)
	self:setTitle(CommonText[206])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	self:showUI()
end

function AdaptProduct:showUI()
	local container = self:getBg()
	local h = self:getBg():height()
	local tankDB = TankMO.queryTankById(self.data.tankId)
	self.m_tank = tankDB

	local title = UiUtil.label(tankDB.name, FONT_SIZE_SMALL, COLOR[tankDB.grade])
		:addTo(container):align(display.LEFT_CENTER, 200, h-110)
	-- 建筑样式
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tankDB.tankId):addTo(container)
		:pos(126, h - 126)

	-- 当前数量
	local label = ui.newTTFLabel({text = CommonText[95] .. ":" ..UserMO.getResource(ITEM_KIND_TANK, tankDB.tankId), font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = h-140, color = cc.c3b(140, 140, 140), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 详情
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); require("app.dialog.DetailTankDialog").new(tankDB.tankId):push() end):addTo(container)
	detailBtn:setPosition(500, h-126)

	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	attrBg:setPreferredSize(cc.size(self:getBg():width() - 80, 112))
	attrBg:setPosition(self:getBg():width() / 2, h - 182 - attrBg:getContentSize().height / 2)

	local valueColor = COLOR[3]
	local labelX = 90
	local labelX2 = 318

	-- 攻击
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "attack"}):addTo(attrBg)
	itemView:setPosition(labelX - 30, attrBg:getContentSize().height - 32)

	local label = ui.newTTFLabel({text = CommonText.attr[1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = tankDB.attack, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 生命
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "maxHp"}):addTo(attrBg)
	itemView:setPosition(labelX - 30, attrBg:getContentSize().height - 76)

	local label = ui.newTTFLabel({text = CommonText.attr[2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = tankDB.hp, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 攻击方式
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, tankDB.attackMode, {name = "atkMode"}):addTo(attrBg)
	itemView:setPosition(labelX2 - 30, attrBg:getContentSize().height - 32)

	local label = ui.newTTFLabel({text = CommonText.atkMode[tankDB.attackMode], font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = attrBg:getContentSize().height - 32, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 载重
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "payload"}):addTo(attrBg)
	itemView:setPosition(labelX2 - 30, attrBg:getContentSize().height - 76)

	local label = ui.newTTFLabel({text = CommonText.attr[3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = tankDB.payload, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local resBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(self:getBg())
	resBg:setPreferredSize(cc.size(508, 330))
	resBg:setCapInsets(cc.rect(80, 60, 1, 1))
	resBg:setPosition(self:getBg():width() / 2, attrBg:getPositionY() - attrBg:getContentSize().height / 2 - 5 - resBg:getContentSize().height / 2)
	self.m_resBg = resBg

	local view = ResTableView.new(cc.size(resBg:getContentSize().width, 272), self.m_tankId):addTo(resBg)
	view:setPosition(0, 12)
	view:reloadData()
	self.m_resTablView = view

	-- 类别
	local title = ui.newTTFLabel({text = CommonText[61], font = G_FONT, size = FONT_SIZE_SMALL, x = 175, y = resBg:getContentSize().height - 26, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 需求
	local title = ui.newTTFLabel({text = CommonText[62], font = G_FONT, size = FONT_SIZE_SMALL, x = 284, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 当前拥有
	local title = ui.newTTFLabel({text = CommonText[63], font = G_FONT, size = FONT_SIZE_SMALL, x = 400, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	local greenLabelColor = COLOR[2]

	-- 数量
	local desc = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 168, y = resBg:getPositionY() - resBg:getContentSize().height / 2 - 28, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	local num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() +  desc:getContentSize().width / 2, y = desc:getPositionY(), color = greenLabelColor}):addTo(self:getBg())
	num:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = num

	self.m_minNum = 1
	-- self.m_maxNum = self.data.count > TANK_REFIT_MAX_NUM  and TANK_REFIT_MAX_NUM  or self.data.count
	self.m_maxNum = self:getMaxRefitNum()
	self.m_settingNum = self.m_maxNum

	self:showSlider()

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    reduceBtn:setPosition(65, self.m_numSlider:getPositionY() + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(self:getBg():width() - 65, reduceBtn:getPositionY())

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local returnBtn = MenuButton.new(normal, selected, nil, handler(self, self.onProductCallback)):addTo(self:getBg())
	returnBtn:setPosition(self:getBg():width()/2, 25)
	returnBtn:setLabel(CommonText[1])
end

function AdaptProduct:showSlider()
	if self.m_numSlider then
		self.m_numSlider:removeSelf()
		self.m_numSlider = nil
	end

	local barHeight = 40
	local barWidth = 300

	gprint("self.m_settingNum:", self.m_settingNum)
	
	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg(), 2)
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getContentSize().width / 2 - barWidth / 2, self.m_resBg:getPositionY() - self.m_resBg:getContentSize().height / 2 - 105)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(barWidth + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})
end

function AdaptProduct:onResUpdate()
	local maxNum = TankBO.getMaxRefitNum(self.m_tankId)
	if maxNum == 0 then maxNum = 1 end -- 最少有一个
	-- if maxNum == self.m_maxNum then return end

	self.m_maxNum = maxNum
	if self.m_settingNum > self.m_maxNum then self.m_settingNum = self.m_maxNum end

	gprint("self.m_maxNum:", self.m_maxNum, "self.m_settingNum:", self.m_settingNum)
	self:showSlider()
end

function AdaptProduct:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function AdaptProduct:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function AdaptProduct:onSlideCallback(event)
	local value = event.value - event.value % 1
	-- -- gprint("AdaptProduct value:", value)
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	self.m_resTablView:setCurProductNum(self.m_settingNum)
end

function AdaptProduct:onProductCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	local data = sender.data
	OrdnanceBO.MilitaryRefitTank(function()
		Loading.getInstance():unshow()
		self.rhand()
		self:pop()
		UserBO.triggerFightCheck()
	end,self.m_tankId,self.m_settingNum)
end

function AdaptProduct:getMaxRefitNum()
	local tankId = self.m_tankId
	local tank = TankMO.queryTankById(tankId)

	if not tank then return 1 end

	local count = UserMO.getResource(ITEM_KIND_TANK, tankId)  -- 可以改装的数量
	if not count == 0 then return 1 end

	local mo = OrdnanceMO.queryTankById(tankId)
	local needData = json.decode(mo.militaryRefitConsume)
	needData[#needData + 1] = {ITEM_KIND_TANK, mo.militaryRefitBaseTankId, 1}
	local canRefit = {}
	for k,v in ipairs(needData) do
		canRefit[#canRefit + 1] = math.floor(UserMO.getResource(v[1], v[2]) / v[3])
	end

	--排序
	function sortFun(a,b)
		return a < b
	end
	table.sort(canRefit,sortFun)

	return math.min(canRefit[1] > 0 and canRefit[1] or 1, TANK_REFIT_MAX_NUM)
end

return AdaptProduct
