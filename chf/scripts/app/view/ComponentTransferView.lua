------------------------------------------------------------------------------
-- 配件转换view
------------------------------------------------------------------------------

local ComponentConfig = {
{text = CommonText.attr[2], pos = PART_POS_HP},  -- 生命
{text = CommonText.attr[1], pos = PART_POS_ATTACK},  -- 攻击
{text = CommonText.attr[9], pos = PART_POS_DEFEND},  -- 防护
{text = CommonText.attr[8], pos = PART_POS_IMPALE},  -- 穿刺

{text = CommonText.attr[2] .. "\n" .. CommonText.attr[9], pos = PART_POS_HP_DEFEND}, -- 生命防护
{text = CommonText.attr[1] .. "\n" .. CommonText.attr[8], pos = PART_POS_ATTACK_IMPALE}, -- 攻击穿刺
{text = CommonText.attr[1] .. "\n" .. CommonText.attr[2], pos = PART_POS_ATTACK_HP}, -- 攻击生命
{text = CommonText.attr[8] .. "\n" .. CommonText.attr[9], pos = PART_POS_IMPALE_DEFEND}, -- 穿刺防护

{text = CommonText.attr[2] .. "\n" .. CommonText.attr[9] .. "\n" .. CommonText.attr[8], pos = PART_POS_HP_DEFEND_IMPALE}, -- 生命防护穿刺
{text = CommonText.attr[1] .. "\n" .. CommonText.attr[9] .. "\n" .. CommonText.attr[8], pos = PART_POS_ATTACK_DEFEND_IMPALE}, -- 攻击防护穿刺
}

local ComTransPageView = class("ComTransPageView", function(size)
	if not size then size = cc.size(0, 0) end
	local rect = cc.rect(0, 0, size.width, size.height)

	local node = display.newClippingRegionNode(rect)
	node:setNodeEventEnabled(true)
	nodeExportComponentMethod(node)
	return node
end)

function ComTransPageView:ctor(size, isShowCheckBox, parentView, name)
	self.m_viewSize = size
	self.m_viewNode = {}
	self.m_curPageIndex = 0
	self.m_partCheckState = {}
	self.m_isShowCheckBox = isShowCheckBox
	self.m_parentView = parentView
	self.m_name = name
	self.m_tempRivalPageIndex = nil

	self.selected_ = {}
end

function ComTransPageView:onEnter()
	local container = display.newNode():addTo(self)
	container:setContentSize(self.m_viewSize)

	nodeTouchEventProtocol(container, function(event)
		return self:onTouch(event)
	end)
	self.m_container = container
	-- 默认所有都是确认的
	self.m_partCheckState = {
	}
	for typeIndex = 1, 4 do
		self.m_partCheckState[typeIndex] = {}
		for posIndex = 1, 10 do
			self.m_partCheckState[typeIndex][posIndex] = false
		end
	end
	-- gdump(self.m_name, "ComTransPageView:onEnter self==")
	-- gdump(self.m_partCheckState, "ComTransPageView:onEnter==")
end

function ComTransPageView:numberOfCells()
	return 4
end

function ComTransPageView:cellSizeForIndex(index)
	return self:getViewSize()
end

function ComTransPageView:setCurrentIndex(pageIndex, animated, callback, rivalPageIndex)
	if self.m_moveAnimation then return end

	if rivalPageIndex ~= nil then
		self.m_tempRivalPageIndex = rivalPageIndex
	end

	local delta = pageIndex - self.m_curPageIndex
	-- if self.m_curPageIndex == pageIndex then return end
	if delta ~= 0 and self.m_curPageIndex ~= 0 then
		local pageTable = {1, 2, 3, 4}
		local rivalPageIndex = self:getRivalPageIndex()
		table.remove(pageTable, rivalPageIndex)
		local realCurPageIndex = self.m_curPageIndex
		for i, v in ipairs(pageTable) do
			if self.m_curPageIndex == v then
				realCurPageIndex = i
				break
			end
		end
		pageIndex = realCurPageIndex + delta
		local tempCount = self:numberOfCells() - 1
		if pageIndex > tempCount then pageIndex = pageIndex % tempCount end
		if pageIndex == 0 then pageIndex = tempCount end

		pageIndex = pageTable[pageIndex]
	elseif self.m_curPageIndex == 0 then
	end

	if self.m_viewNode[pageIndex] ~= nil then
		self.m_viewNode[pageIndex]:removeSelf()
		self.m_viewNode[pageIndex] = nil
	end

	local node = display.newNode():addTo(self.m_container)
	local cell = self:createCellAtIndex(node, pageIndex, rivalPageIndex)
	self.m_viewNode[pageIndex] = cell

	local function setPage()
		for index = 1, self:numberOfCells() do
			if index ~= pageIndex then
				if self.m_viewNode[index] then  -- 删除掉没有使用的page
					self.m_viewNode[index]:removeSelf()
					self.m_viewNode[index] = nil
				end
			end

			-- self.selected_[index]:stopAllActions()
			-- if index ~= pageIndex then
			-- 	self.selected_[index]:setVisible(false)
			-- else
			-- 	self.selected_[index]:setVisible(true)
			-- 	self.selected_[index]:setOpacity(255)
			-- end
		end

		if callback then
			callback()
		end
	end

	self.m_curPageIndex = pageIndex

	if animated then
		self.m_moveAnimation = true
		local moveX = 0
		if delta < 0 then
			self.m_viewNode[pageIndex]:setPosition(-self:getViewSize().width, 0)
			moveX = self:getViewSize().width
		else
			self.m_viewNode[pageIndex]:setPosition(self:getViewSize().width, 0)
			moveX = -self:getViewSize().width
		end

		self.m_container:runAction(transition.sequence({cc.MoveTo:create(0.6, cc.p(moveX, 0)), cc.CallFunc:create(function()
				self.m_container:setPosition(0, 0)
				self.m_viewNode[pageIndex]:setPosition(0, 0)

				self.m_moveAnimation = false
				setPage()
			end)}))
	else
		setPage()
	end
end

function ComTransPageView:getCurrentIndex()
	return self.m_curPageIndex
end

function ComTransPageView:getNodeAtIndex(index)
	return self.m_viewNode[index]
end

function ComTransPageView:getRivalPageIndex()
	-- body
	if self.m_isShowCheckBox then
		rivalPageView = self.m_parentView.m_rightPageView
	else
		rivalPageView = self.m_parentView.m_leftPageView
	end
	local rivalIndex = rivalPageView:getCurrentIndex()
	if rivalIndex == 0 then
		if self.m_tempRivalPageIndex ~= nil then
			rivalIndex = self.m_tempRivalPageIndex
		else
			rivalIndex = rivalPageView:numberOfCells()
		end
	end
	return rivalIndex
end

function ComTransPageView:createCellAtIndex(cell, index, rivalPageIndex)
	local headBg = display.newSprite(IMAGE_COMMON .. "com_show_head.png"):addTo(cell)
	local headSize = headBg:getContentSize()
	headBg:setPosition(self:getViewSize().width / 2, self:getViewSize().height - headSize.height / 2)

	local componentBg = display.newSprite(IMAGE_COMMON .. "com_show_bg.png"):addTo(cell)
	componentBg:setPosition(self:getViewSize().width / 2, self:getViewSize().height - headSize.height - componentBg:getContentSize().height / 2)

	local name = ui.newTTFLabel({text = CommonText[162][index], font = G_FONT, size = FONT_SIZE_SMALL, x = headSize.width / 2, y = headSize.height - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(headBg)

	local tank = display.newSprite(IMAGE_COMMON .. "icon_component_tank_" .. index .. ".png"):addTo(headBg)
	local tankSize = tank:getContentSize()
	tank:setAnchorPoint(cc.p(0.5, 0.5))
	tank:setPosition(headSize.width / 2, tankSize.height / 2 - 25)
	tank:setScale(0.4)

	local function gotoComponent(itemView)
		ManagerSound.playNormalButtonSound()

		local config = ComponentConfig[itemView.index]
		if PartBO.hasPartAtPos(index, config.pos) then  -- 有配件
			local part = PartBO.getPartAtPos(index, config.pos)
			require("app.dialog.ComponentShowDialog").new(part.keyId):push()
		end
	end

	local function showPositionComponent(posIndex, animated)
		local config = ComponentConfig[posIndex]
		local itemView = nil
		if PartBO.hasPartAtPos(index, config.pos) then
			local part = PartBO.getPartAtPos(index, config.pos)
			local partDB = PartMO.queryPartById(part.partId)

			itemView = UiUtil.createItemView(ITEM_KIND_PART, part.partId, {upLv = part.upLevel, refitLv = part.refitLevel, keyId = part.keyId})
			local itemSize = itemView:getContentSize()

			local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
			lockIcon:setScale(0.5)
			lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
			lockIcon:setVisible(part.locked)

			local canTransfer = true
			local errorStr = nil

			local rivalPageView = nil
			if self.m_isShowCheckBox then
				rivalPageView = self.m_parentView.m_rightPageView
			else
				rivalPageView = self.m_parentView.m_leftPageView
			end
			local rivalIndex = nil
			if rivalPageIndex == nil then
				rivalIndex = rivalPageView:getCurrentIndex()
				if rivalIndex == 0 then
					rivalIndex = rivalPageView:numberOfCells()
				end
			else
				rivalIndex = rivalPageIndex
			end

			-- print("self.m_isShowCheckBox", self.m_isShowCheckBox)
			-- print("rivalIndex!!!!", rivalIndex)

			if rivalIndex == index then
				canTransfer = false
				errorStr = "不同兵种间的配件才能互相转换"
			end

			if canTransfer then
				local rivalPart = PartBO.getPartAtPos(rivalIndex, config.pos)
				if rivalPart == nil then
					canTransfer = false
					errorStr = "同部位的橙紫配件之间才能互相转换"
				else
					local rivalPartDB = PartMO.queryPartById(rivalPart.partId)
					if partDB.quality <= 2 or rivalPartDB.quality <= 2 then
						canTransfer = false
						errorStr = "同部位的橙紫配件之间才能互相转换"
					else
						if rivalPart.locked or part.locked then
							canTransfer = false
							errorStr = "未锁定的配件才能进行转换"
						else
							if rivalPart.saved == false or part.saved == false then
								canTransfer = false
								errorStr = "淬炼未保存的配件不能进行转换"
							end
						end
					end
				end
			end

			if canTransfer == false then
				local mask = display.newSprite(IMAGE_COMMON .. "item_bg_1.png"):addTo(itemView, 10)
				mask:setPosition(itemSize.width / 2, itemSize.height / 2)
				mask:setOpacity(150)

				-- print("index posIndex!!!", index, posIndex)
				self.m_partCheckState[index][posIndex] = nil
			else
				if self.m_partCheckState[index][posIndex] == nil then
					self.m_partCheckState[index][posIndex] = self.m_parentView.m_checkBoxAllSelect:isChecked() 
				end
			end

			-- self.m_partCheckState[index][posIndex] = canTransfer

			if self.m_isShowCheckBox then
				local function onCheckedChanged(sender, isChecked)
					ManagerSound.playNormalButtonSound()

					if sender.canTransfer then
						self.m_partCheckState[sender.kind][sender.posIndex] = isChecked

						-- local allUnchecked = true
						-- local allChecked = true
						-- for i = 1, 8 do
						-- 	local checkState = self.m_partCheckState[sender.kind][i]
						-- 	if checkState == true then
						-- 		allUnchecked = false
						-- 	elseif checkState == false then
						-- 		allChecked = false
						-- 	end
						-- end
						-- if allUnchecked or allChecked then
						-- 	if allUnchecked then
						-- 		Notify.notify(LOCAL_COM_TRANSFER_CHECKED_CHANGE, {eventType="AllUnchecked", formType=curPageIndex})
						-- 	end
						-- else
						-- 	Notify.notify(LOCAL_COM_TRANSFER_CHECKED_CHANGE, {eventType="PartChecked", formType=curPageIndex})
						-- end
						self.m_parentView:updateTransGoldCost()
					else
						Toast.show(sender.errorStr)
						sender:setChecked(false)
					end
				end

				local uncheckedSprite = display.newSprite(IMAGE_COMMON .. "com_transfer_unchecked.png")
				local checkedSprite = display.newSprite(IMAGE_COMMON .. "com_transfer_checked.png")
				local checkBox = CheckBox.new(uncheckedSprite, checkedSprite, onCheckedChanged):addTo(itemView, 20)
				local checkBoxSize = checkBox:getContentSize()
				checkBox.kind = index
				checkBox.posIndex = posIndex
				checkBox.canTransfer = canTransfer
				checkBox.errorStr = errorStr
				if self.m_partCheckState[index][posIndex] == true then
					checkBox:setChecked(true)
				else
					checkBox:setChecked(false)
				end
				-- checkBox:setPosition(20, itemSize.height - 20)
				checkBox:setPosition(20, 20)
				checkBox:setTouchSwallowEnabled(true)
			end
		else -- 没有配件
			-- print("no com index posIndex!!!!", index, posIndex)
			self.m_partCheckState[index][posIndex] = nil
			itemView = UiUtil.createItemView(ITEM_KIND_PART, 0, {pos = config.pos, openLv = PartMO.getOpenLv(config.pos)})
		end
		itemView:addTo(componentBg)
		itemView.index = posIndex
		itemView:setScale(0.9)
		UiUtil.createItemDetailButton(itemView, nil, false, gotoComponent)

		local row = math.floor((posIndex + 1) / 2)
		local col = posIndex - (row - 1) * 2
		local itemSize = itemView:getContentSize()

		local posX = (col - 0.5)* itemSize.width + 10
		local posY = componentBg:getContentSize().height - 20 - (row - 0.5) * (itemSize.height + 1) * 0.9

		itemView:setPosition(posX, posY)

		if not cell.components then cell.components = {} end
		cell.components[config.pos] = itemView
	end

	for posIndex = 1, 10 do
		showPositionComponent(posIndex)
	end

	-- gdump(self.m_name, "createCellAtIndex self==")
	-- gdump(self.m_partCheckState, "createCellAtIndex self.m_partCheckState==")

	return cell
end

function ComTransPageView:getViewSize()
	return self.m_viewSize
end

function ComTransPageView:onTouch(event)
	if event.name == "began" then
		return self:onTouchBegan(event)
	elseif event.name == "moved" then
	elseif event.name == "ended" then
		self:onTouchEnded(event)
	else
		self:onTouchCancelled(event)
	end
end

function ComTransPageView:onTouchBegan(event)
	if not self:isVisible() then return false end

	self.m_touchPoint = cc.p(event.x, event.y)
	return true
end

function ComTransPageView:onTouchEnded(event)
	if not self:isVisible() then return end
	-- gprint("ComTransPageView:onTouch, event:", event.name)
	if not self.m_touchPoint then return end

	local deltaX = event.x - self.m_touchPoint.x
end

function ComTransPageView:onTouchCancelled(event)
	self.m_touchPoint = nil
end

function ComTransPageView:selectAll(isChecked)
	-- body
	local curPage = self:getCurrentIndex()
	-- gdump(self, "before ComTransPageView:selectAll self==")
	-- gdump(self.m_partCheckState, "before ComTransPageView:selectAll self.m_partCheckState==")
	for posIndex = 1, 10 do
		local checkState = self.m_partCheckState[curPage][posIndex]
		if isChecked then
			if checkState ~= nil and checkState == false then
				self.m_partCheckState[curPage][posIndex] = isChecked
			end
		else
			if checkState == true then
				self.m_partCheckState[curPage][posIndex] = isChecked
			end
		end
	end

	-- gdump(self.m_partCheckState, "ComTransPageView:selectAll self.m_partCheckState==")

	self:setCurrentIndex(curPage, false)
	self.m_parentView:updateTransGoldCost()

	-- local eventType = nil
	-- if isChecked then
	-- else
	-- 	eventType = 'AllUnchecked'
	-- 	Notify.notify(LOCAL_COM_TRANSFER_CHECKED_CHANGE, {eventType=eventType, formType=curPageIndex})
	-- end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local ComponentTransferView = class("ComponentTransferView", UiNode)

function ComponentTransferView:ctor(enterStyle, leftVehType, rightVehType)
	enterStyle = enterStyle or UI_ENTER_NONE
	ComponentTransferView.super.ctor(self, "image/common/bg_ui.jpg", enterStyle)
	self.m_leftVehType = leftVehType
	self.m_rightVehType = rightVehType
end

function ComponentTransferView:onEnter()
	ComponentTransferView.super.onEnter(self)
	self:setTitle("配件转换")  -- 配件
	self:showUI(self.m_leftVehType, self.m_rightVehType)

	self.m_partHandler = Notify.register(LOCLA_PART_EVENT, handler(self, self.onPartUpdate))
	-- self.m_checkBoxHandler = Notify.register(LOCAL_COM_TRANSFER_CHECKED_CHANGE, handler(self, self.onComTransferCheckedChange))
end

function ComponentTransferView:onExit()
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end
end

function ComponentTransferView:onPartUpdate(event)
	local leftPageIndex = event.obj.leftPageIndex
	local rightPageIndex = event.obj.rightPageIndex
	self:showUI(leftPageIndex, rightPageIndex)
end


function ComponentTransferView:onComTransferCheckedChange(event)
	-- body
	local eventType = event.obj.eventType
	-- if eventType == "AllChecked" then
	-- 	self.m_checkBoxAllSelect:setChecked(false)
	if eventType == "AllUnchecked" then
		self.m_checkBoxAllSelect:setChecked(false)
	elseif eventType == "PartChecked" then
		self.m_checkBoxAllSelect:setChecked(false)
	end
end

function ComponentTransferView:showUI(leftPageIndex, rightPageIndex)
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 + container:getContentSize().height / 2)
		self.m_container = container
	end

	local container = self.m_container
	self.m_container:removeAllChildren()

	local bg = display.newSprite(IMAGE_COMMON .. "com_transfer_bg.jpg"):addTo(container)
	local bgSize = bg:getContentSize()
	bg:setPosition(bgSize.width / 2, container:getContentSize().height - bgSize.height / 2 - 10)

	local pageViewSize = cc.size(300, 690)
	local view1 = ComTransPageView.new(pageViewSize, false, self, "rightview"):addTo(bg)
	view1:setPosition(bgSize.width - pageViewSize.width + 5, -30)
	self.m_rightPageView = view1

	local view = ComTransPageView.new(pageViewSize, true, self, "leftview"):addTo(bg)
	view:setPosition(-5, -30)
	self.m_leftPageView = view

	self.m_leftPageView:setCurrentIndex(leftPageIndex, nil, nil, rightPageIndex)
	self.m_rightPageView:setCurrentIndex(rightPageIndex)

	-- 中间的标志
	local mark = display.newSprite(IMAGE_COMMON .. "com_transfer_mark.png"):addTo(bg)
	mark:setPosition(bgSize.width / 2, bgSize.height / 2 - 72)

	-- 左边的左右箭头
	local normal = display.newSprite(IMAGE_COMMON .. "com_show_next.png")
	normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "com_show_next.png")
	selected:setScale(-1)
	local lastBtn = MenuButton.new(normal, selected, nil, handler(self, self.onLeftLastCallback)):addTo(bg)
	lastBtn:setPosition(lastBtn:getContentSize().width / 2 + 20, bgSize.height - lastBtn:getContentSize().height / 2 - 40)

	local normal = display.newSprite(IMAGE_COMMON .. "com_show_next.png")
	local selected = display.newSprite(IMAGE_COMMON .. "com_show_next.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, handler(self, self.onLeftNextCallback)):addTo(bg)
	nxtBtn:setPosition(lastBtn:getContentSize().width / 2 + 207, bgSize.height - lastBtn:getContentSize().height / 2 - 40)

	-- 右边的左右箭头
	local normal = display.newSprite(IMAGE_COMMON .. "com_show_next.png")
	normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "com_show_next.png")
	selected:setScale(-1)
	local lastBtn = MenuButton.new(normal, selected, nil, handler(self, self.onRightLastCallback)):addTo(bg)
	lastBtn:setPosition(bgSize.width - lastBtn:getContentSize().width / 2 - 207, bgSize.height - lastBtn:getContentSize().height / 2 - 40)

	local normal = display.newSprite(IMAGE_COMMON .. "com_show_next.png")
	local selected = display.newSprite(IMAGE_COMMON .. "com_show_next.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, handler(self, self.onRightNextCallback)):addTo(bg)
	nxtBtn:setPosition(bgSize.width - lastBtn:getContentSize().width / 2 - 20, bgSize.height - lastBtn:getContentSize().height / 2 - 40)

	-- 下面的提示
	local labelComTrans = UiUtil.label(CommonText[1900][1]):addTo(self.m_container)
	labelComTrans:setAnchorPoint(0, 0.5)
	labelComTrans:setPosition(10, 180)

	local labelComTransDetail = UiUtil.label(CommonText[1900][2], nil, COLOR[22], cc.size(460, 0)):addTo(self.m_container):rightTo(labelComTrans, 10)
	labelComTransDetail:setPositionY(labelComTrans:getPositionY() - 10)

	local labelTransConsume = UiUtil.label(CommonText[1901][1]):addTo(self.m_container)
	labelTransConsume:setAnchorPoint(0, 0.5)
	labelTransConsume:setPosition(10, 130)
	-- labelTransConsume:setPosition(10, 100)

	local labelTransConsumeDetail =  UiUtil.label(CommonText[1901][2], nil, COLOR[22]):addTo(self.m_container):rightTo(labelTransConsume, 10)

	local goldCost = self:getTransGoldCost()
	local goldNum = UiUtil.label(string.format("%d", goldCost)):addTo(self.m_container)
	goldNum:setPosition(self:getBg():width() / 2, 100)
	goldNum:setAnchorPoint(cc.p(0, 0.5))
	self.m_labelGoldNum = goldNum

	local goldIcon = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(self.m_container):leftTo(goldNum, 10)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local transBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onClickTransBtn)):addTo(self.m_container)
	transBtn:setPosition(self:getBg():width() / 2,50)
	transBtn:setLabel(CommonText[1902])

	local function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		self.m_leftPageView:selectAll(isChecked)
	end
	local checkBox = CheckBox.new(nil, nil, onCheckedChanged):addTo(self.m_container)
	checkBox:setPosition(70, 50)

	local labelAllSelect = UiUtil.label("全部选择"):addTo(self.m_container):rightTo(checkBox, 10)
	self.m_labelAllSelect = labelAllSelect
	self.m_checkBoxAllSelect = checkBox
end

function ComponentTransferView:onLeftLastCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function refreshRightPage()
		-- body
		self:refreshRightPage()
		self:updateTransGoldCost()
	end

	local curPage = self.m_leftPageView:getCurrentIndex()
	self.m_leftPageView:setCurrentIndex(curPage - 1, true, refreshRightPage)
end

function ComponentTransferView:onLeftNextCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function refreshRightPage()
		-- body
		self:refreshRightPage()
		self:updateTransGoldCost()
	end

	local curPage = self.m_leftPageView:getCurrentIndex()
	self.m_leftPageView:setCurrentIndex(curPage + 1, true, refreshRightPage)
end

function ComponentTransferView:onRightLastCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function refreshLeftPage()
		-- body
		self:refreshLeftPage()
		self:updateTransGoldCost()
	end

	local curPage = self.m_rightPageView:getCurrentIndex()
	self.m_rightPageView:setCurrentIndex(curPage - 1, true, refreshLeftPage)
end

function ComponentTransferView:onRightNextCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function refreshLeftPage()
		-- body
		self:refreshLeftPage()
		self:updateTransGoldCost()
	end

	local curPage = self.m_rightPageView:getCurrentIndex()
	self.m_rightPageView:setCurrentIndex(curPage + 1, true, refreshLeftPage)
end

function ComponentTransferView:onClickTransBtn(tag, sender)
	local leftPageView = self.m_leftPageView
	local partCheckState = leftPageView.m_partCheckState
	local leftTypeIndex = leftPageView:getCurrentIndex()
	local rightTypeIndex = self.m_rightPageView:getCurrentIndex()
	local keyIds = {}
	for posIndex = 1, 10 do
		if partCheckState[leftTypeIndex][posIndex] == true then
			local config = ComponentConfig[posIndex]
			local leftPart = PartBO.getPartAtPos(leftTypeIndex, config.pos)
			local rightPart = PartBO.getPartAtPos(rightTypeIndex, config.pos)
			table.insert(keyIds, {v1=leftPart.keyId, v2=rightPart.keyId})
		end
	end
	if #keyIds > 0 then
		local goldCost = 0
		for i, v in ipairs(keyIds) do
			local key1 = v.v1
			local key2 = v.v2
			local part1 = PartMO.getPartByKeyId(key1)
			local part2 = PartMO.getPartByKeyId(key2)
			local partDB1 = PartMO.queryPartById(part1.partId)
			local partDB2 = PartMO.queryPartById(part2.partId)
			if partDB1.quality == 3 and partDB2.quality == 3 then
				goldCost = goldCost + 500
			else
				goldCost = goldCost + 800
			end
		end
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		local confirmStr = {
			{content="是否花费"},
			{content=string.format("%d", goldCost), color=COLOR[6]},
			{content="金币进行配件转换"},
		}

		ConfirmDialog.new(confirmStr, function()
			PartBO.partConvert(leftTypeIndex, rightTypeIndex, keyIds, function ()
				-- body
				Toast.show("配件转换成功")
			end)
		end):push()
	else
		Toast.show("没有符合转换条件或未勾选任何可以转换的配件")
	end
end


function ComponentTransferView:refreshLeftPage()
	-- body
	local curPage = self.m_leftPageView:getCurrentIndex()
	-- gdump(self.m_leftPageView.m_partCheckState, "before refreshLeftPage==")
	-- print("refresh left page index", curPage)
	-- print("self.m_leftPageView name", self.m_leftPageView.m_name)
	self.m_leftPageView:setCurrentIndex(curPage, false)
end


function ComponentTransferView:refreshRightPage()
	-- body
	local curPage = self.m_rightPageView:getCurrentIndex()
	self.m_rightPageView:setCurrentIndex(curPage, false)
end


function ComponentTransferView:getTransGoldCost()
	-- body
	local leftPageView = self.m_leftPageView
	local partCheckState = leftPageView.m_partCheckState
	if partCheckState == nil then
		return 0
	end
	local leftTypeIndex = leftPageView:getCurrentIndex()
	local rightTypeIndex = self.m_rightPageView:getCurrentIndex()
	if leftTypeIndex == 0 or rightTypeIndex == 0 then
		return 0
	end
	local keyIds = {}
	for posIndex = 1, 10 do
		print()
		if partCheckState[leftTypeIndex][posIndex] == true then
			local config = ComponentConfig[posIndex]
			local leftPart = PartBO.getPartAtPos(leftTypeIndex, config.pos)
			local rightPart = PartBO.getPartAtPos(rightTypeIndex, config.pos)
			table.insert(keyIds, {v1=leftPart.keyId, v2=rightPart.keyId})
		end
	end
	local goldCost = 0
	if #keyIds > 0 then
		for i, v in ipairs(keyIds) do
			local key1 = v.v1
			local key2 = v.v2
			local part1 = PartMO.getPartByKeyId(key1)
			local part2 = PartMO.getPartByKeyId(key2)
			local partDB1 = PartMO.queryPartById(part1.partId)
			local partDB2 = PartMO.queryPartById(part2.partId)
			if partDB1.quality == 3 and partDB2.quality == 3 then
				goldCost = goldCost + 500
			else
				goldCost = goldCost + 800
			end
		end
	end
	return goldCost
end

function ComponentTransferView:updateTransGoldCost()
	-- body
	local goldCost = self:getTransGoldCost()
	if self.m_labelGoldNum then
		self.m_labelGoldNum:setString(string.format("%d", goldCost))
	end
end

return ComponentTransferView
