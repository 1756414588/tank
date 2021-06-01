
-- 配件卸下、装配、强化、改造等操作弹出框

local Dialog = require("app.dialog.Dialog")
----------------------------------------------------
local ComponentShowChangeTableView = class("ComponentShowChangeTableView", TableView)
function ComponentShowChangeTableView:ctor(size,curData,ChangeCallback, DownCallback)
	ComponentShowChangeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 250)
	self.curData = curData
	self.ChangeCallback = ChangeCallback
	self.DownCallback = DownCallback
end
function ComponentShowChangeTableView:onEnter()
	ComponentShowChangeTableView.super.onEnter(self)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self, -1)
	bg:setPreferredSize(cc.size(self.m_viewSize.width , self.m_viewSize.height ))
	bg:setAnchorPoint(cc.p(0.5,0.5))
	bg:setPosition(self.m_viewSize.width / 2, self.m_viewSize.height / 2 )

	self.listData = PartBO.checkListUpPartsAtPos(self.curData)

	table.insert(self.listData,1,self.curData)

	self.curAttrData = PartBO.getPartAttrData(self.curData.partId, self.curData.upLevel, self.curData.refitLevel, self.curData.keyId, 1)

	self:reloadData()
end
function ComponentShowChangeTableView:numberOfCells()
	return #self.listData
end

function ComponentShowChangeTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ComponentShowChangeTableView:createCellAtIndex(cell, index)
	ComponentShowChangeTableView.super.createCellAtIndex(self, cell, index)

	local data = self.listData[index]

	local partDB = PartMO.queryPartById(data.partId)

	local attrData = PartBO.getPartAttrData(data.partId, data.upLevel, data.refitLevel, data.keyId, 1)

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(cell)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, self.m_cellSize.height - 20 - strengthLabel:getContentSize().height / 2)

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrData.strengthValue), font = "fnt/num_2.fnt"}):addTo(cell)
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	local itemView = UiUtil.createItemView(ITEM_KIND_PART, data.partId, {upLv = data.upLevel, refitLv = data.refitLevel, keyId = data.keyId}):addTo(cell)
	itemView:setPosition(70, self.m_cellSize.height - 55 - itemView:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView)

	local name = ui.newTTFLabel({text = partDB.partName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self.m_cellSize.height - 68, color = COLOR[partDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local startY = name:getPositionY() - 40

	local attrData1 = attrData.attr1

	local startLabel = nil

	-- xx加成
	local label1 = ui.newTTFLabel({text = attrData1.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = startY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = attrData1.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrData1.value > self.curAttrData.attr1.value then
		local stateui = display.newScale9Sprite(IMAGE_COMMON .. "mine_quality2.png"):addTo(cell)
		stateui:setPosition(value:x() + value:width() + 10, value:y())
		stateui:setScale(0.4)
		-- stateui:setRotation(180)
	end

	local attrData2 = attrData.attr2
	if attrData2 then -- 有第二属性
		-- xx加成
		local labelX = ui.newTTFLabel({text = attrData2.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		labelX:setAnchorPoint(cc.p(0, 0.5))
		startLabel = labelX

		local value = ui.newTTFLabel({text = attrData2.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = labelX:getPositionX() + labelX:getContentSize().width + 5, y = labelX:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))

		if self.curAttrData.attr2 and attrData2.value > self.curAttrData.attr2.value then
			local stateui = display.newScale9Sprite(IMAGE_COMMON .. "mine_quality2.png"):addTo(cell)
			stateui:setPosition(value:x() + value:width() + 10, value:y())
			stateui:setScale(0.4)
		end
	end

	local attrData3 = attrData.attr3
	if attrData3 then -- 有第三属性
		-- xx加成
		local labelX = ui.newTTFLabel({text = attrData3.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		labelX:setAnchorPoint(cc.p(0, 0.5))
		startLabel = labelX

		local value = ui.newTTFLabel({text = attrData3.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = labelX:getPositionX() + labelX:getContentSize().width + 5, y = labelX:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))

		if self.curAttrData.attr3 and attrData3.value > self.curAttrData.attr3.value then
			local stateui = display.newScale9Sprite(IMAGE_COMMON .. "mine_quality2.png"):addTo(cell)
			stateui:setPosition(value:x() + value:width() + 10, value:y())
			stateui:setScale(0.4)
		end
	end

	-- 适用兵种
	local label2 = ui.newTTFLabel({text = CommonText[177] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = startLabel:getPositionX(), y = startLabel:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label2:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = CommonText[162][partDB.type], font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX() + label2:getContentSize().width + 5, y = label2:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 改造等级
	local label3 = ui.newTTFLabel({text = CommonText[178] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX(), y = label2:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label3:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = data.refitLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 强化等级
	local label4 = ui.newTTFLabel({text = CommonText[179] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX(), y = label3:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label4:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = data.upLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label4:getPositionX() + label4:getContentSize().width + 5, y = label4:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	local function btncallback()
		if data.keyId == self.curData.keyId then
			if self.DownCallback then self.DownCallback() end
		else
			if self.ChangeCallback then self.ChangeCallback(data.keyId) end
		end
	end

	--stateBtn btn_19_normal
	local btnStr = "btn_9"
	if data.keyId == self.curData.keyId then btnStr = "btn_19" end
	local normal = display.newSprite(IMAGE_COMMON .. btnStr .. "_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. btnStr .. "_selected.png")
	local lockBtn = MenuButton.new(normal ,selected, nil, btncallback):addTo(cell)
	lockBtn:setPosition(self.m_cellSize.width - lockBtn:width() * 0.5 - 20,self.m_cellSize.height * 0.5 - 10)

	if data.keyId == self.curData.keyId then
		lockBtn:setLabel(CommonText[172])

		local equiped = ui.newTTFLabel({text = "(" .. CommonText[1053][1] .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = name:x() + name:width(), y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		equiped:setAnchorPoint(cc.p(0, 0.5))
	else
		lockBtn:setLabel(CommonText[1082][1])
	end
	
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_viewSize.width - 50, line:height()))
	line:setAnchorPoint(cc.p(0.5,0.5))
	line:setPosition(self.m_cellSize.width * 0.5, 0)

	return cell
end

function ComponentShowChangeTableView:doChange(tag,sender)
	-- body
	local keyId = sender.keyId
	if self.callback then self.callback(keyId) end
end



local ComponentShowChangeDialog = class("ComponentShowChangeDialog", Dialog)

-- list替换列表
function ComponentShowChangeDialog:ctor(curData,ChangeCallback,DownCallback)
	ComponentShowChangeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 560)})
	self.curData = curData
	self.ChangeCallback = ChangeCallback
	self.DownCallback = DownCallback
end

function ComponentShowChangeDialog:onEnter()
	ComponentShowChangeDialog.super.onEnter(self)
	self:setTitle(CommonText[1082][2]) -- 配件查看

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleX((self:getBg():getContentSize().width - 50) / btm:getContentSize().width )
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local view = ComponentShowChangeTableView.new(cc.size(self:getBg():getContentSize().width - 50 - 20, self:getBg():getContentSize().height - 70 - 30),
			 self.curData, handler(self,self.doChangePop), handler(self,self.doDownPop)):addTo(self:getBg(),2)
	view:setAnchorPoint(cc.p(0,0))
	view:setPosition(35,35)
end

function ComponentShowChangeDialog:doChangePop(keyId)
	self:pop()
	if self.ChangeCallback then self.ChangeCallback(keyId) end
end

function ComponentShowChangeDialog:doDownPop()
	self:pop()
	if self.DownCallback then self.DownCallback() end
end

----------------------------------------------------
local ComponentDialog = class("ComponentDialog", Dialog)

-- keyId:配件的keyId
function ComponentDialog:ctor(keyId)
	ComponentDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 760)})

	self.m_part = PartMO.getPartByKeyId(keyId)
end

function ComponentDialog:onEnter()
	ComponentDialog.super.onEnter(self)

	local partDB = PartMO.queryPartById(self.m_part.partId)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[170]) -- 配件查看

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 420))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)
	--分界线
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(506, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 225)

	local attrData = PartBO.getPartAttrData(self.m_part.partId, self.m_part.upLevel, self.m_part.refitLevel, self.m_part.keyId, 1)

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 20 - strengthLabel:getContentSize().height / 2)

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrData.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	local itemView = UiUtil.createItemView(ITEM_KIND_PART, self.m_part.partId, {upLv = self.m_part.upLevel, refitLv = self.m_part.refitLevel, keyId = self.m_part.keyId}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height - 55 - itemView:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView)

	--锁定状态icon
	local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
	lockIcon:setScale(0.5)
	lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
	lockIcon:setVisible(self.m_part.locked)
	self.m_lockIcon = lockIcon

	local name = ui.newTTFLabel({text = partDB.partName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 68, color = COLOR[partDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local startY = name:getPositionY() - 30

	if self.m_part.refitLevel > 0 then
		for index = 1, self.m_part.refitLevel do
			local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(infoBg)
			star:setPosition(name:getPositionX() + (index - 0.5) * 30, startY)
			star:setScale(0.55)
		end

		startY = name:getPositionY() - 60
	end

	local bottomBuffInitHeight = infoBg:height() - 240
	local attrData1 = attrData.attr1

	local startLabel = nil

	-- xx加成
	local label1 = ui.newTTFLabel({text = attrData1.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = startY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = attrData1.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local attrData2 = attrData.attr2
	if attrData2 then -- 有第二属性
		-- xx加成
		local labelX = ui.newTTFLabel({text = attrData2.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		labelX:setAnchorPoint(cc.p(0, 0.5))
		startLabel = labelX

		local value = ui.newTTFLabel({text = attrData2.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = labelX:getPositionX() + labelX:getContentSize().width + 5, y = labelX:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		line:setPositionY(line:getPositionY() - 25)
		bottomBuffInitHeight = bottomBuffInitHeight - 25
	end

	local attrData3 = attrData.attr3
	if attrData3 then -- 有第三属性
		-- xx加成
		local label3 = ui.newTTFLabel({text = attrData3.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label3:setAnchorPoint(cc.p(0, 0.5))
		startLabel = label3

		local value = ui.newTTFLabel({text = attrData3.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		line:setPositionY(line:getPositionY() - 25)
		bottomBuffInitHeight = bottomBuffInitHeight - 25
	end

	-- 适用兵种
	local label2 = ui.newTTFLabel({text = CommonText[177] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = startLabel:getPositionX(), y = startLabel:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label2:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = CommonText[162][partDB.type], font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX() + label2:getContentSize().width + 5, y = label2:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 改造等级
	local label3 = ui.newTTFLabel({text = CommonText[178] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX(), y = label2:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label3:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = self.m_part.refitLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 强化等级
	local label4 = ui.newTTFLabel({text = CommonText[179] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX(), y = label3:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label4:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = self.m_part.upLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label4:getPositionX() + label4:getContentSize().width + 5, y = label4:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local list = PartMO.getRefineAttr(self.m_part,1)
	local x, ey = 135, 30
	for k,v in ipairs(list) do
		local name = UiUtil.label(v.name,FONT_SIZE_SMALL):addTo(infoBg):align(display.LEFT_CENTER,x,bottomBuffInitHeight-(k-1)*ey)
		UiUtil.label(v.value[1],nil,COLOR[2]):alignTo(name,100)
	end

	--锁定/解锁按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local lockBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onLockCallback)):addTo(infoBg)
	lockBtn:setPosition(infoBg:getContentSize().width - 80,infoBg:getContentSize().height - 180 )
	self.m_lockBtn = lockBtn

	if self.m_part.locked then
		lockBtn:setLabel(CommonText[902][2]) 
	else
		lockBtn:setLabel(CommonText[902][1])
	end


	local isWear = PartBO.isPartWearByKeyId(self.m_part.keyId)

	-- 分解
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local exchangeBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onExplodeCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 - 170, 46 + normal:getContentSize().height + normal:getContentSize().height / 2)
	exchangeBtn:setLabel(CommonText[171])
	self.m_exchangeBtn = exchangeBtn
	if isWear or self.m_part.locked then
		exchangeBtn:setEnabled(false)
	end

	if isWear then
		local function funChange()
			ComponentShowChangeDialog.new(self.m_part, handler(self,self.DoChangeComponent), handler(self, self.onDemountCallback)):push()
		end

		-- 替换
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local changeBtn = MenuButton.new(normal ,selected, disabled, funChange):addTo(self:getBg())
		changeBtn:setPosition(self:getBg():getContentSize().width / 2 , 46 + normal:getContentSize().height + normal:getContentSize().height / 2)
		changeBtn:setLabel(CommonText[1082][1])
		-- changeBtn:setEnabled(#list > 0)
	else
		-- 装配
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local wearBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onWearCallback)):addTo(self:getBg())
		wearBtn:setPosition(self:getBg():getContentSize().width / 2 , 46 + normal:getContentSize().height + normal:getContentSize().height / 2)
		wearBtn:setLabel(CommonText[175])

		if PartMO.getOpenLv(PartMO.getPosByPartId(self.m_part.partId)) > UserMO.level_ then
			wearBtn:setEnabled(false)
		end
	end

	-- 强化
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local strengthBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onStrengthCallback)):addTo(self:getBg())
	strengthBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 46 + normal:getContentSize().height + normal:getContentSize().height / 2)
	strengthBtn:setLabel(CommonText[173])

	-- 改造
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local recreateBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onRefitCallback)):addTo(self:getBg())
	recreateBtn:setPosition(self:getBg():getContentSize().width / 2 - 170, 80)
	recreateBtn:setLabel(CommonText[174])

	--淬炼
	local qureQuality  = partDB.quality
	local normal = display.newSprite(IMAGE_COMMON.."btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON.."btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local cuilianBtn = MenuButton.new(normal,selected,disabled,handler(self, self.onCuilianCallback)):addTo(self:getBg())
	cuilianBtn:setPosition(self:getBg():getContentSize().width / 2 , 80)
	cuilianBtn:setLabel(CommonText[5000])
	if qureQuality < 2 then
		cuilianBtn:setEnabled(false)
	end

	--进阶
	local normal = display.newSprite(IMAGE_COMMON.."btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON.."btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local advanceBtn = MenuButton.new(normal,selected,disabled,handler(self, self.onAdvanceCallback)):addTo(self:getBg())
	advanceBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 80)
	advanceBtn:setLabel(CommonText[5001])
	advanceBtn:setEnabled(qureQuality > 2)
end

function ComponentDialog:onExplodeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local part = PartMO.queryPartById(self.m_part.partId)
	local partDB = self.m_part

	local function goBatch()
		self:pop(function()
				local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
				PartExplodeDialog.new({partDB.keyId}):push()
			end)
	end

	if part.quality >= 4 then
		require("app.dialog.TipsAnyThingDialog").new(CommonText[1810][1],function ()
			goBatch()
		end):push()
	else
		goBatch()
	end

	-- self:pop(function()
	-- 		local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
	-- 		PartExplodeDialog.new({self.m_part.keyId}):push()
	-- 	end)
end

function ComponentDialog:onWearCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doneOnPart()
		Loading.getInstance():unshow()
		self:pop()
	end

	Loading.getInstance():show()
	PartBO.asynOnPart(doneOnPart, self.m_part.keyId)
end

function ComponentDialog:onDemountCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doneOnPart()
		Loading.getInstance():unshow()

		-- 配件卸下成功
		Toast.show(CommonText[180])

		self:pop()
	end

	Loading.getInstance():show()
	PartBO.asynOnPart(doneOnPart, self.m_part.keyId)
end

function ComponentDialog:onStrengthCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self:pop(function()
			local ComponentStrengthView = require("app.view.ComponentStrengthView")
			ComponentStrengthView.new(COMPONENT_VIEW_FOR_UP, self.m_part.keyId):push()
		end)
end

function ComponentDialog:onRefitCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	self:pop(function()
			local ComponentStrengthView = require("app.view.ComponentStrengthView")
			ComponentStrengthView.new(COMPONENT_VIEW_FOR_REFIT, self.m_part.keyId):push()
		end)
end

function ComponentDialog:onCuilianCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if UserMO.level_ < PART_REFINE_LEVEL then
		Toast.show(string.format(CommonText[20136], PART_REFINE_LEVEL))
		return
	end
	if true then
		self:pop(function()
			local ComponentStrengthView = require("app.view.ComponentStrengthView")
			ComponentStrengthView.new(COMPONENT_VIEW_FOR_CUILIAN, self.m_part.keyId):push()
		end)
	else
		Toast.show(CommonText[967],1)
	end
	
end

function ComponentDialog:onAdvanceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if true then
		self:pop(function()
			local ComponentStrengthView = require("app.view.ComponentStrengthView")
			ComponentStrengthView.new(COMPONENT_VIEW_FOR_ADVANCE, self.m_part.keyId):push()
		end)
	else
		Toast.show(CommonText[967],1)
	end
	  
end


function ComponentDialog:onLockCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneLock(locked)
		Loading.getInstance():unshow()
		local statusStr = ""
		if locked then
			statusStr = CommonText[902][1]
			self.m_lockBtn:setLabel(CommonText[902][2]) 
		else
			statusStr = CommonText[902][2]
			self.m_lockBtn:setLabel(CommonText[902][1])
		end
		Toast.show(string.format(CommonText[903],statusStr))
		self.m_lockIcon:setVisible(locked)

		local isWear = PartBO.isPartWearByKeyId(self.m_part.keyId)
		if isWear then
			self.m_exchangeBtn:setEnabled(false)
		else
			if locked then
				self.m_exchangeBtn:setEnabled(false)
			else
				self.m_exchangeBtn:setEnabled(true)
			end
		end
	end

	Loading.getInstance():show()
	PartBO.asynLockPart(doneLock, self.m_part)
end

function ComponentDialog:DoChangeComponent(keyId)
	local function doneOnPart()
		Loading.getInstance():unshow()
		self:pop()
	end

	Loading.getInstance():show()
	PartBO.asynOnPart(doneOnPart, keyId)
end

return ComponentDialog