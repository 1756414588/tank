
-- 配件工厂

require("app.text.DetailText")

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

------------------------------------------------------------------------------
-- 配件pageview
------------------------------------------------------------------------------

local ComponentPageView = class("ComponentPageView", function(size)
    if not size then size = cc.size(0, 0) end
    local rect = cc.rect(0, 0, size.width, size.height)

    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function ComponentPageView:ctor(size)
	self.m_viewSize = size
	self.m_viewNode = {}
	self.m_curPageIndex = 0

	self.selected_ = {}
end

function ComponentPageView:onEnter()
	local container = display.newNode():addTo(self)
	container:setContentSize(self.m_viewSize)
	-- container:setPosition(self.m_viewSize.width / 2, self.m_viewSize.height / 2)
	nodeTouchEventProtocol(container, function(event)
        	return self:onTouch(event)
        end)
	self.m_container = container

	local startX = self:getViewSize().width / 2 - (self:numberOfCells() - 1) * 30 / 2

    for index = 1, self:numberOfCells() do
        local bg = display.newSprite("image/common/scroll_bg_2.png"):addTo(self)
        bg:setPosition(startX + (index - 1) * 30, 10)

        local selected = display.newSprite("image/common/scroll_head_2.png"):addTo(self, 2)
        selected:setPosition(bg:getPositionX(), bg:getPositionY())
        selected:setVisible(false)

        self.selected_[index] = selected
    end
end

function ComponentPageView:numberOfCells()
	return 4
end

function ComponentPageView:cellSizeForIndex(index)
	return self:getViewSize()
end

function ComponentPageView:setCurrentIndex(pageIndex, animated)
	if self.m_moveAnimation then return end
	if self.m_curPageIndex == pageIndex then return end
	if pageIndex > self:numberOfCells() then pageIndex = pageIndex % self:numberOfCells() end
	if pageIndex == 0 then pageIndex = self:numberOfCells() end

	-- gprint("ComponentPageView:setCurrentIndex: pageIndex:", pageIndex)

	if not self.m_viewNode[pageIndex] then
		local node = display.newNode():addTo(self.m_container)
		local cell = self:createCellAtIndex(node, pageIndex)
		self.m_viewNode[pageIndex] = cell
	end

	local function setPage()
		for index = 1, self:numberOfCells() do
			if index ~= pageIndex then
				if self.m_viewNode[index] then  -- 删除掉没有使用的page
					self.m_viewNode[index]:removeSelf()
					self.m_viewNode[index] = nil
				end
			end
			
	        self.selected_[index]:stopAllActions()
            if index ~= pageIndex then
	            self.selected_[index]:setVisible(false)
	        else
	        	self.selected_[index]:setVisible(true)
	        	self.selected_[index]:setOpacity(255)
	        end
	    end

		self.m_curPageIndex = pageIndex
	end

	if animated then
		self.m_moveAnimation = true
		local moveX = 0
		if (pageIndex < self.m_curPageIndex and not (self.m_curPageIndex == self:numberOfCells() and pageIndex == 1)) or (self.m_curPageIndex == 1 and pageIndex == self:numberOfCells()) then
			self.m_viewNode[pageIndex]:setPosition(-self:getViewSize().width, 0)
			moveX = self:getViewSize().width
		else
			self.m_viewNode[pageIndex]:setPosition(self:getViewSize().width, 0)
			moveX = -self:getViewSize().width
		end

		-- gprint("pageIndex:", pageIndex, "curPage:", self.m_curPageIndex)

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

function ComponentPageView:getCurrentIndex()
	return self.m_curPageIndex
end

function ComponentPageView:getNodeAtIndex(index)
	return self.m_viewNode[index]
end

function ComponentPageView:createCellAtIndex(cell, index)
	local componentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell)
	componentBg:setPreferredSize(cc.size(self:getViewSize().width - 20, self:getViewSize().height - 40))
	componentBg:setPosition(self:getViewSize().width / 2, self:getViewSize().height - 15 - componentBg:getContentSize().height / 2)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(componentBg)
	titleBg:setPosition(componentBg:getContentSize().width / 2, componentBg:getContentSize().height - 10)

	local name = ui.newTTFLabel({text = CommonText[162][index], font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	local tank = display.newSprite(IMAGE_COMMON .. "icon_component_tank_" .. index .. ".png"):addTo(componentBg)
	tank:setAnchorPoint(cc.p(0.5, 0))
	tank:setPosition(componentBg:getContentSize().width / 2, componentBg:getContentSize().height - 370)

	local function gotoComponentTransfer()
		if UserMO.level_ < 60 then
			Toast.show("必须大于等于60级才能使用配件转换功能")
			return
		end

		if UserMO.vip_ < 5 then
			Toast.show("vip等级大于等于5级才能使用配件转换功能")
			return
		end

		local rightIndex = index + 1
		if rightIndex > 4 then rightIndex = rightIndex % 4 end
		require("app.view.ComponentTransferView").new(UI_ENTER_FADE_IN_GATE, index, rightIndex):push()
	end

	local btn = UiUtil.button("btn_com_transfer.png","btn_com_transfer.png",nil,gotoComponentTransfer):addTo(tank)
	btn:setPosition(tank:getContentSize().width - btn:getContentSize().width + 195, btn:getContentSize().height / 2 - 50)
	btn:setVisible(UserMO.level_ >= 60)

	local function gotoComponent(itemView)
		ManagerSound.playNormalButtonSound()

		local config = ComponentConfig[itemView.index]
		if PartBO.hasPartAtPos(index, config.pos) then  -- 有配件
			local part = PartBO.getPartAtPos(index, config.pos)
			require("app.dialog.ComponentDialog").new(part.keyId):push()
		else
			if PartMO.getOpenLv(config.pos) > UserMO.level_ then
				Toast.show(string.format(CommonText[168], PartMO.getOpenLv(config.pos)))
				return
			end

			if itemView.canWear then -- 有控件可穿戴
				local parts = itemView.canWearParts
				local part = parts[1]
				require("app.dialog.ComponentDialog").new(part.keyId):push()
			else
			end
		-- 	require("app.view.EquipExchangeView").new(formatPosition, config.pos):push()
		end
	end

	local function showPositionComponent(posIndex, animated)
		local config = ComponentConfig[posIndex]
		local itemView = nil
		local partQuality = 0
		if PartBO.hasPartAtPos(index, config.pos) then
			local part = PartBO.getPartAtPos(index, config.pos)
			local partDB = PartMO.queryPartById(part.partId)
			partQuality = partDB.quality
			itemView = UiUtil.createItemView(ITEM_KIND_PART, part.partId, {upLv = part.upLevel, refitLv = part.refitLevel, keyId = part.keyId})

			local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
			lockIcon:setScale(0.5)
			lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
			lockIcon:setVisible(part.locked)

			local _list , _state = PartBO.checkListUpPartsAtPos(part)
			if _state then
				local tipstate = display.newSprite(IMAGE_COMMON .. "icon_red_point.png"):addTo(itemView, 10)
				tipstate:setScale(0.75)
				tipstate:setPosition(itemView:width() - tipstate:width() * 0.5 ,itemView:height() - tipstate:height() * 0.5)
			end
		else -- 没有配件
			itemView = UiUtil.createItemView(ITEM_KIND_PART, 0, {pos = config.pos, openLv = PartMO.getOpenLv(config.pos)})

			local parts = PartBO.getCanWearPartsAtPos(index, config.pos)
			if PartMO.getOpenLv(config.pos) <= UserMO.level_ and #parts > 0 then -- 位置上有配件可以穿，并且可以穿
				UiUtil.showTip(itemView, #parts)

				table.sort(parts,PartBO.sortStrength)

				itemView.canWear = true
				itemView.canWearParts = parts
			end
		end
		itemView:addTo(componentBg)
		itemView.index = posIndex
		itemView:setScale(0.9)
		UiUtil.createItemDetailButton(itemView, nil, nil, gotoComponent)
		
		local topInitX = componentBg:getContentSize().width - 480
		local topY = componentBg:getContentSize().height - 90
		local topOffsetX = 105

		local bottomInitX = 60
		local bottomY = componentBg:getContentSize().height - 475
		local bottomOffsetX = 105

		if posIndex <= 5 then
			itemView:setPosition(topInitX + (posIndex - 1) * topOffsetX, topY)
		else
			itemView:setPosition(bottomInitX + (posIndex - 6) * bottomOffsetX, bottomY)
		end

		-- if posIndex == 1 then itemView:setPosition(topInitX, topY)
		-- elseif posIndex == 2 then itemView:setPosition(componentBg:getContentSize().width - 270, componentBg:getContentSize().height - 110)
		-- elseif posIndex == 3 then itemView:setPosition(componentBg:getContentSize().width - 170, componentBg:getContentSize().height - 110)
		-- elseif posIndex == 4 then itemView:setPosition(componentBg:getContentSize().width - 70, componentBg:getContentSize().height - 110)
		-- elseif posIndex == 5 then itemView:setPosition(70, componentBg:getContentSize().height - 110 - 346)
		-- elseif posIndex == 6 then itemView:setPosition(170, componentBg:getContentSize().height - 110 - 346)
		-- elseif posIndex == 7 then itemView:setPosition(270, componentBg:getContentSize().height - 110 - 346)
		-- elseif posIndex == 8 then itemView:setPosition(370, componentBg:getContentSize().height - 110 - 346)
		-- end

		local label = ui.newTTFLabel({text = CommonText.PartPos2Name[posIndex], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[partQuality + 1]}):addTo(componentBg)
		if posIndex <= 5 then
			label:setPosition(itemView:getPositionX(), itemView:getPositionY() - itemView:getContentSize().height / 2 - label:getContentSize().height / 2)
		else
			label:setPosition(itemView:getPositionX(), itemView:getPositionY() - itemView:getContentSize().height / 2 - label:getContentSize().height / 2)
		end

		if not cell.components then cell.components = {} end
		cell.components[config.pos] = itemView
	end

	for posIndex = 1, 10 do
		showPositionComponent(posIndex)
	end

	local attrValue = PartBO.getTankTypePartAttrData(index)
	-- gdump(attrValue, "[ComponentView] createCellAtIndex")

	local attrList = {{index = ATTRIBUTE_INDEX_ATTACK}, {index = ATTRIBUTE_INDEX_IMPALE}, {index = ATTRIBUTE_INDEX_HP}, {index = ATTRIBUTE_INDEX_DEFEND}}

	-- 配件的各个属性值
	for attrIndex = 1, #attrList do
		local attr = attrValue[attrList[attrIndex].index]

		local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = attr.attrName}):addTo(componentBg)
		if attrIndex <= 2 then
			itemView:setPosition(50 + (attrIndex - 1) * 240, 78)
		else
			itemView:setPosition(50 + (attrIndex - 3) * 240, 35)
		end

		local name = ui.newTTFLabel({text = attr.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(componentBg)
		-- local name = ui.newTTFLabel({text = attrList[attrIndex].text .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(componentBg)
		name:setAnchorPoint(cc.p(0, 0.5))
		name:setColor(COLOR[11])
		name:setPosition(itemView:getPositionX() + 30, itemView:getPositionY())

		local value = ui.newTTFLabel({text = "+" .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(componentBg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	-- local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDetailCallback))
	-- cell:addButton(detailBtn, 65, self:getViewSize().height - 70)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(componentBg)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(15, componentBg:getContentSize().height - 575)

	-- 增加属性
	local title = ui.newTTFLabel({text = CommonText[160], font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(componentBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(400, titleBg:getPositionY())

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrValue.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	return cell
end

function ComponentPageView:getViewSize()
	return self.m_viewSize
end

function ComponentPageView:onDetailCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	DetailTextDialog.new(DetailText.part):push()
end

function ComponentPageView:onTouch(event)
    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
    --     self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    -- elseif event.name == "removed" then
    --     self:onTouchRemoved(event)
    else
        self:onTouchCancelled(event)
    end
end

function ComponentPageView:onTouchBegan(event)
    if not self:isVisible() then return false end

    self.m_touchPoint = cc.p(event.x, event.y)
    return true
end


function ComponentPageView:onTouchEnded(event)
    if not self:isVisible() then return end
	-- gprint("ComponentPageView:onTouch, event:", event.name)
	if not self.m_touchPoint then return end

	local deltaX = event.x - self.m_touchPoint.x
	-- gprint("deltaX:", deltaX)

	if math.abs(deltaX) <= 18 then return end

	if deltaX < 0 then
		self:setCurrentIndex(self:getCurrentIndex() + 1, true)
	else
		self:setCurrentIndex(self:getCurrentIndex() - 1, true)
	end

end

function ComponentPageView:onTouchCancelled(event)
	self.m_touchPoint = nil
end
------------------------------------------------------------------------------
-- 配件 Tip--view
------------------------------------------------------------------------------
local TipClippingView = class("TipClippingView", function (size)
	if not size then size = cc.size(0, 0) end
    local rect = cc.rect(0, 0, size.width, size.height)

    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function TipClippingView:ctor(size)
	self.viewSize = size
end

function TipClippingView:onEnter()
	self.tips = {}
	self.tips[#self.tips + 1] = CommonText[494]
	self.tips[#self.tips + 1] = CommonText[1123]
	self.tips[#self.tips + 1] = CommonText[1124]
	self.curIndex = 1
	self.node = display.newNode():addTo(self)

	local label = ui.newTTFLabel({text= self.tips[self.curIndex], font = G_FONT, size = FONT_SIZE_TINY, x = self.viewSize.width * 0.5, y = self.viewSize.height * 0.5, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self.node)
	self.curlb = label

	self:showNext()
end

function TipClippingView:showNext()
	self.curIndex = self.curIndex + 1
	if self.curIndex > #self.tips then self.curIndex = 1 end
	local label = ui.newTTFLabel({text= self.tips[self.curIndex], font = G_FONT, size = FONT_SIZE_TINY, 
			x = self.viewSize.width * 0.5, y = self.curlb:y() - self.viewSize.height, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self.node)
	self.node:runAction(transition.sequence({cc.DelayTime:create(3.0), 
		cc.MoveBy:create(0.2,cc.p(0, self.viewSize.height)), 
		cc.CallFunc:create(function()
			if self.curlb then
				self.curlb:removeSelf()
				self.curlb = nil
			end
			self.curlb = label
			self:showNext()
		end)}))
end

------------------------------------------------------------------------------
-- 配件view
------------------------------------------------------------------------------
local ComponentView = class("ComponentView", UiNode)

function ComponentView:ctor(buildingId, enterStyle)
	enterStyle = enterStyle or UI_ENTER_NONE
	ComponentView.super.ctor(self, "image/common/bg_ui.jpg", enterStyle)
end

function ComponentView:onEnter()
	ComponentView.super.onEnter(self)
	armature_add(IMAGE_ANIMATION .. "effect/cuilian_xiaozhushou.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilian_xiaozhushou.plist", IMAGE_ANIMATION .. "effect/cuilian_xiaozhushou.xml")

	self:setTitle(CommonText[11])  -- 配件

	self.m_partHandler = Notify.register(LOCLA_PART_EVENT, handler(self, self.onPartUpdate))

	self:showUI()
end

function ComponentView:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/cuilian_xiaozhushou.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilian_xiaozhushou.plist", IMAGE_ANIMATION .. "effect/cuilian_xiaozhushou.xml")
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end
end

function ComponentView:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 + container:getContentSize().height / 2)
		self.m_container = container
	end

	local container = self.m_container
	self.m_container:removeAllChildren()

	--如果开启了淬炼大师活动。就显示小秘书
	local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_REFINE_MASTER)
	if activity and activity.open == false then
		local armature = armature_create("cuilian_xiaozhushou",container:getContentSize().width - 40,container:getContentSize().height - 160):addTo(container,999)
		armature:runAction(transition.sequence({cc.CallFunc:create(function()
			armature:getAnimation():playWithIndex(0)
		 	end),cc.DelayTime:create(1),
			cc.CallFunc:create(function()
				local normal = display.newSprite(IMAGE_COMMON .. "refine_secret.png")
				self.btn = ScaleButton.new(normal,function ()
					ManagerSound.playNormalButtonSound()
					self.btn:setVisible(false)
					require("app.dialog.DetailRefineMasterDialog").new(function (data)
						if data == 2 then
							self.btn:setVisible(true)
						else
							self.btn:setVisible(true)
							require("app.view.ActivityRefineMasterView").new(activity):push()
						end
					end):push()
				end):addTo(container,999):pos(container:getContentSize().width - 37,container:getContentSize().height - 159)
				armature:stopAllActions()
				armature:removeSelf()
			 end)}))
	end

	local view = ComponentPageView.new(cc.size(container:getContentSize().width - 10, 735)):addTo(container)
	view:setPosition(5, container:getContentSize().height - 735)
	view:setCurrentIndex(1)
	self.m_pageView = view

	self:showUnlock(view)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	selected:setScale(-1)
	local lastBtn = MenuButton.new(normal, selected, nil, handler(self, self.onLastCallback)):addTo(container)
	lastBtn:setPosition(50, container:getContentSize().height - 298)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, handler(self, self.onNextCallback)):addTo(container)
	nxtBtn:setPosition(container:getContentSize().width - 50, container:getContentSize().height - 298)

	-- 小提示:
	local tipView = TipClippingView.new(cc.size(container:width() * 0.9, 24 )):addTo(container)
	tipView:setAnchorPoint(cc.p(0.5,0.5))
	tipView:setPosition(container:width() * 0.5, 85)

	-- 配件探险
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local warehouseBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCombatCallback)):addTo(container)
	warehouseBtn:setLabel(CommonText[161])
	warehouseBtn:setPosition(110, 30)

	-- 仓库
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local warehouseBtn = MenuButton.new(normal, selected, nil, handler(self, self.onWarehouseCallback)):addTo(container)
	warehouseBtn:setLabel(CommonText[169])
	warehouseBtn:setPosition(container:getContentSize().width - 110, 30)
	self.m_warehouseBtn = warehouseBtn

	self:onUpdateTip()
end

function ComponentView:showUnlock(pageView)
	if PartMO.unlockPosition_ > 0 then
		gprint("ComponentView:showUnlock: ", PartMO.unlockPosition_)

		local viewNode = pageView:getNodeAtIndex(pageView:getCurrentIndex())
		local node = viewNode.components[PartMO.unlockPosition_]

		PartMO.unlockPosition_ = 0
		
		armature_add(IMAGE_ANIMATION .. "effect/ui_unlock_2.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_unlock_2.plist", IMAGE_ANIMATION .. "effect/ui_unlock_2.xml")
		local armature = armature_create("ui_unlock_2", node:getContentSize().width / 2, node:getContentSize().height / 2 + 2, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
				end
			 end)
		armature:setScale(1.12)
		armature:getAnimation():playWithIndex(0)
		armature:addTo(node, 10)
	end
end

function ComponentView:onLastCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local curPage = self.m_pageView:getCurrentIndex()
	self.m_pageView:setCurrentIndex(curPage - 1, true)
end

function ComponentView:onNextCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local curPage = self.m_pageView:getCurrentIndex()
	self.m_pageView:setCurrentIndex(curPage + 1, true)
end

function ComponentView:onCombatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if HunterBO.teamType == nil and HunterBO.teamId == nil then
		local CombatLevelView = require("app.view.CombatLevelView")
		CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_PART)):push()
	else
		Toast.show("组队中无法前往配件探险")
	end
end

function ComponentView:onWarehouseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.ComponentWarehouseView").new():push()
end

function ComponentView:onPartUpdate(event)
	local curPage = self.m_pageView:getCurrentIndex()
	self:showUI()
	self.m_pageView:setCurrentIndex(curPage)

	self:onUpdateTip()
end

function ComponentView:onUpdateTip()
	local parts = PartMO.getFreeParts()
	if #parts > 0 then
		UiUtil.showTip(self.m_warehouseBtn, #parts)
	else
		UiUtil.unshowTip(self.m_warehouseBtn)
	end
end

function ComponentView:getCurrGuideID()
	local index = 0
	for i=1,10 do
		local config = ComponentConfig[i]
		local itemView = nil
		if PartBO.hasPartAtPos(1, config.pos) then
			local part = PartBO.getPartAtPos(1, config.pos)
			local equipDB = EquipMO.queryEquipById(part.partId)
			if part ~= nil and  equipDB.quality ~= nil then
				if equipDB.quality >= 2 then
					index = i
				end
			end
			
		end
	end
	return index
end



return ComponentView
