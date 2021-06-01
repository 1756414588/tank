
-- 制作车间制作TableView

local WorkshopProductTableView = class("WorkshopProductTableView", TableView)

function WorkshopProductTableView:ctor(size)
	WorkshopProductTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

function WorkshopProductTableView:onEnter()
	WorkshopProductTableView.super.onEnter(self)
	
	self.m_props = PropMO.queryCanBuildProps()
	self.m_productHandler = Notify.register(LOCAL_PROP_DONE_EVENT, handler(self, self.onProductUpdate))
end

function WorkshopProductTableView:onExit()
	WorkshopProductTableView.super.onExit(self)
	
	if self.m_productHandler then
		Notify.unregister(self.m_productHandler)
		self.m_productHandler = nil
	end
end

function WorkshopProductTableView:numberOfCells()
	return #self.m_props
end

function WorkshopProductTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function WorkshopProductTableView:createCellAtIndex(cell, index)
	WorkshopProductTableView.super.createCellAtIndex(self, cell, index)

	local propDB = self.m_props[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	--
	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, propDB.propId):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	-- 名称
	local name = ui.newTTFLabel({text = PropMO.getPropName(propDB.propId), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[propDB.color]}):addTo(cell)

	-- 当前数量
	local label = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_PROP, propDB.propId), font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))

	local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, label:getPositionY() - 30):addTo(cell)
	clock:setAnchorPoint(cc.p(0, 0.5))
	local time = ui.newBMFontLabel({text =  UiUtil.strBuildTime(propDB.buildTime), font = "fnt/num_2.fnt"}):addTo(cell)
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())

	-- 建造
	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
	local buildBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenProp))
	buildBtn.prop = propDB
	cell:addButton(buildBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)

	return cell
end

function WorkshopProductTableView:onChosenProp(tag, sender)
	ManagerSound.playNormalButtonSound()
	local prop = sender.prop

	local function productCallback(propId, propNum)
		self:dispatchEvent({name = "PRODUCT_PROP_EVENT", propId = propId, count = propNum})
	end

	require("app.dialog.PropProductDialog").new(prop.propId, productCallback):push()
end

function WorkshopProductTableView:onProductUpdate(event)
	self.m_props = PropMO.queryCanBuildProps()
	
	self:reloadData()
end

return WorkshopProductTableView
