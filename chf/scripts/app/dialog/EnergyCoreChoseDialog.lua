--
-- Author: Gss
-- Date: 2019-04-27 17:19:58
--
-- 能源核心熔炼选择界面

local EnergyCoreChoseTableView = class("EnergyCoreChoseTableView", TableView)

-- status: 1表示显示列表，2表示显示出售
function EnergyCoreChoseTableView:ctor(size,data)
	EnergyCoreChoseTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_data = data
end

function EnergyCoreChoseTableView:numberOfCells()
	return #self.m_data
end

function EnergyCoreChoseTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EnergyCoreChoseTableView:createCellAtIndex(cell, index)
	EnergyCoreChoseTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_data[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(data[1], data[2]):addTo(cell)
	itemView:setPosition(80, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(itemView, cell, true)
	cell.itemView = itemView
	local resData = UserMO.getResourceData(data[1],data[2])
	-- 名称
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[resData.quality]}):addTo(cell)
	
	--数量
	local value = UserMO.getResource(data[1],data[2])
	local own = UiUtil.label(CommonText[63]..":"):rightTo(itemView,40)
	local num = UiUtil.label(value,nil,COLOR[value >= data[3] and 1 or 5]):rightTo(own)

	--checkbox
	local checkBox = CellCheckBox.new(nil, nil, handler(self, self.onCheckedChanged))
	checkBox.cellIndex = index
	checkBox:setAnchorPoint(cc.p(0, 0.5))
	cell:addButton(checkBox, self.m_cellSize.width - 90, self.m_cellSize.height / 2 - 22)
	cell.checkBox = checkBox
	checkBox.data = data
	checkBox:setVisible(value >= data[3])

	return cell
end

function EnergyCoreChoseTableView:onCheckedChanged(sender, isChecked)
	local cellIndex = sender.cellIndex

	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if index == cellIndex then
			cell.checkBox:setChecked(true)
		else
			cell.checkBox:setChecked(false)
		end
	end

	self:dispatchEvent({name = "CHECK_EVENT_FOR_ENERGYCORE_CHOSE", data = sender.data})
end





---------------------------------------------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local EnergyCoreChoseDialog = class("EnergyCoreChoseDialog", Dialog)

function EnergyCoreChoseDialog:ctor(callBack,pos)
	EnergyCoreChoseDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 780)})
	self.m_callBack = callBack
	self.m_pos = pos
end

function EnergyCoreChoseDialog:onEnter()
	EnergyCoreChoseDialog.super.onEnter(self)
	self:setTitle(CommonText[8005])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setPreferredSize(cc.size(self:getBg():width() - 34,self:getBg():height() - 80))
	self.m_choseData = nil
	self:showUI()
end

function EnergyCoreChoseDialog:showUI()
	local data = EnergyCoreMO.getMeltingInfoByLoc(self.m_pos)
	--需求展示
	local needBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(self:getBg())
	needBg:setPreferredSize(cc.size(self:getBg():width() - 60, 140))
	needBg:setPosition(self:getBg():width() / 2, self:getBg():height() - 130)

	local info = json.decode(data.asset)
	local itemView = UiUtil.createItemView(info[1], info[2]):addTo(needBg)
	itemView:setPosition(80, needBg:height() / 2)
	local resData = UserMO.getResourceData(info[1],info[2])
	local name = ui.newTTFLabel({text = data.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[resData.quality]}):addTo(needBg)

	--拥有展示
	local tips = UiUtil.label(CommonText[8006]):alignTo(needBg, -100, 1)
	local tabBg = display.newScale9Sprite(IMAGE_COMMON .. "energycore_attrBg.png"):addTo(self:getBg())
	tabBg:setPreferredSize(cc.size(self:getBg():width() - 50, self:getBg():height() - 380))
	tabBg:setPosition(self:getBg():width() / 2, tips:y() - tabBg:height() / 2 - 20)
	--所有可选的，tableview
	local function onChoseCallback(event)  -- 有被选中
		self.m_choseData = event.data
	end

	local view = EnergyCoreChoseTableView.new(cc.size(self:getBg():width() - 60,self:getBg():height() - 420), json.decode(data.material)):addTo(self:getBg())
	view:addEventListener("CHECK_EVENT_FOR_ENERGYCORE_CHOSE", onChoseCallback)
	view:setPosition(30, 155)
	view:reloadData()
	self.m_choseTableView_ = view
	
	--确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local okBtn = MenuButton.new(normal, selected, nil, handler(self,self.doChose)):addTo(self:getBg())
	okBtn:setPosition(self:getBg():width() / 2,okBtn:height() - 10)
	okBtn:setLabel(CommonText[1])
end

function EnergyCoreChoseDialog:doChose(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not self.m_choseData then
		Toast.show(CommonText[8007])
		return
	end
	if self.m_callBack then
		self.m_callBack(self.m_choseData)
		self:pop()
	end
end

return EnergyCoreChoseDialog