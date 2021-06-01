
-- 玩家头像tableview

local PortraitTableView = class("PortraitTableView", TableView)

function PortraitTableView:ctor(size,kind)
	PortraitTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	-- self.m_vipPendants = PendantMO.queryPendantsByType(PENDANT_TYPE_VIP)
	-- self.m_vipPendantRow = math.ceil(#self.m_vipPendants / 5)

	-- self.m_normalPendants = PendantMO.queryPendantsByType(PENDANT_TYPE_LEVEL)
	-- self.m_normalPendantRow = math.ceil(#self.m_normalPendants / 5)

	-- self.m_crossPendants = PendantMO.queryPendantsByType(PENDANT_TYPE_CROSS)
	-- self.m_crossPendantRow = math.ceil(#self.m_crossPendants / 5)
	self.kind = kind
	if kind == 1 then
		self.group = PendantMO.queryPortraits()
	elseif kind == 2 then
		self.group = PendantMO.queryPendants()
	end

	local height = 44
	height = height + (math.ceil(#self.group[1] / 5) + 0.5) * 110
	height = height + (math.ceil(#self.group[2] / 5) + 0.5) * 110
	height = height + (math.ceil(#self.group[3] / 5) + 0.5) * 110 
	-- height = height + 65
	-- height = height + (self.m_normalPortraitRow + 0.5) * 110
	-- height = height + (self.m_vipPortraitRow + 0.5) * 110
	-- height = height + (self.m_specialPortraitRow + 0.5) * 110
	-- height = height + 50

	self.m_cellSize = cc.size(size.width, height)
	-- self.m_cellSize = cc.size(size.width, 800 + 110 + 110 + 110 + 110)

	self.m_curProductNum = 0
end

function PortraitTableView:numberOfCells()
	return 1
end

function PortraitTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PortraitTableView:createCellAtIndex(cell, index)
	PortraitTableView.super.createCellAtIndex(self, cell, index)

	--------头像选择框
	local chose = display.newSprite(IMAGE_COMMON .. "chose_5.png"):addTo(cell, 10)
	self.m_portraitChoseSprite = chose
	self.m_portraitChoseSprite.id = 0
	if self.kind == 2 then
		self.m_portraitChoseSprite:hide()
	end

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(cell)
		:align(display.LEFT_CENTER,20,self.m_cellSize.height - 22)
	ui.newTTFLabel({text = CommonText[self.kind == 1 and 122 or 124], font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)
	-- 背景框
	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell)
	attrBg:setPreferredSize(cc.size(self.m_cellSize.width - 30, self.m_cellSize.height - titleBg:height()))
	attrBg:setPosition(self.m_cellSize.width / 2, (self.m_cellSize.height - titleBg:height())/2)

	local height = self.m_cellSize.height - 72
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
		:align(display.LEFT_CENTER,30,height)
	local title = ui.newTTFLabel({text = CommonText[self.kind == 1 and 123 or 20137], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	height = height - 78
	self:createItem(self.group[1],cell,height)

	height = height - math.floor((#self.group[1]-1)/5)*110 - 55
	height = height - bg:height()/2
	bg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
		:align(display.LEFT_CENTER,30,height)
	title = display.newSprite(IMAGE_COMMON .. "label_vip_5_use.png", 42, bg:getContentSize().height / 2):addTo(bg)
	title:setAnchorPoint(cc.p(0, 0.5))
	height = height - 78
	self:createItem(self.group[2],cell,height)

	height = height - math.floor((#self.group[2]-1)/5)*110 - 55
	height = height - bg:height()/2
	bg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
		:align(display.LEFT_CENTER,30,height)
	title = ui.newTTFLabel({text = CommonText[self.kind == 1 and 30047 or 30046], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	height = height - 78
	self:createItem(self.group[3],cell,height)
	return cell
end

function PortraitTableView:createItem(data,cell,height)
	for i,v in ipairs(data) do
		local itemView = nil
		if self.kind == 1 then
			itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, v.id):addTo(cell)
			itemView.id = v.id
		elseif self.kind == 2 then
			itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, 0, {pendant = v.pendantId}):addTo(cell)
			itemView.id = v.pendantId
		end
		itemView:setScale(0.55)
		itemView:setPosition(30 + (((i-1) % 5) + 0.5 ) * 114, height - math.floor((i-1)/5) * 110 )
		UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onPendantCallback))
		local value = self.kind == 1 and UserMO.portrait_ or UserMO.pendant_
		if itemView.id == value then
			self:onPendantCallback(itemView)
		end
	end
end

function PortraitTableView:getPortraitId()
	if self.kind == 2 then
		return UserMO.portrait_
	end
	return self.m_portraitChoseSprite.id
end

function PortraitTableView:onPendantCallback(sender)
	local id = sender.id
	self.m_portraitChoseSprite:setScale(0.65)
	self.m_portraitChoseSprite.id = id
	self.m_portraitChoseSprite:setPosition(sender:getPositionX(), sender:getPositionY())
	if self.kind == 2 then
		self.m_portraitChoseSprite:show()
	end
	self:choseChanged()
end

function PortraitTableView:getPendantId()
	if self.kind == 1 then
		return UserMO.pendant_
	end
	return self.m_portraitChoseSprite.id
end

function PortraitTableView:choseChanged()
	self:dispatchEvent({name = "CHOSEN_PORTRAIT_EVENT", portraitId = self:getPortraitId(), pendantId = self:getPendantId()})
end

return PortraitTableView
