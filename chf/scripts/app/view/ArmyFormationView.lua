
FORMATION_FOR_TANK  = 1  -- 坦克阵型
FORMATION_FOR_EQUIP = 2  -- 坦克阵型的装备
FORMATION_FOR_EQUIP_ITEM = 3 -- 阵型的装备的某项(攻击、命中。。。)

--------------------------------------------------------------------
-- 部队阵型中的每个小节点位置
--------------------------------------------------------------------
local ArmyFormationNode = class("ArmyFormationNode", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function ArmyFormationNode:ctor(position, formationFor, formatData, lock, param)
	self.m_position = position
	self.m_formationFor = formationFor
	self.m_lock = lock
	self.m_param = param

	local normal = display.newSprite(IMAGE_COMMON .. "btn_position_normal.png"):addTo(self)
	normal:setPosition(normal:getContentSize().width / 2, normal:getContentSize().height / 2)
	normal:setVisible(true)

	local selected = display.newSprite(IMAGE_COMMON .. "chose_1.png"):addTo(self)
	selected:setPosition(selected:getContentSize().width / 2 + 4, selected:getContentSize().height / 2 + 8)
	selected:setVisible(false)   -- 初始不可见

	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(cc.size(normal:getContentSize().width, normal:getContentSize().height))
	self.normal_ = normal
	self.selected_ = selected

	if formationFor == FORMATION_FOR_TANK then
	elseif formationFor == FORMATION_FOR_EQUIP then
		self.chosen_ = display.newSprite(IMAGE_COMMON .. "icon_equip_tank_capture.png"):addTo(self)
		self.chosen_:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		self.chosen_:setScale(0.4)
		self.chosen_:setVisible(false)   -- 初始不可见

		self.unchosen_ = display.newSprite(IMAGE_COMMON .. "icon_equip_tank.png"):addTo(self)
		self.unchosen_:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 15)
		-- self.unchosen_:setScale(0.4)
		-- self.unchosen_:setVisible(false)   -- 初始不可见
	end

	self:update(formatData)
end

function ArmyFormationNode:update(formatData)
	if self.node_ then
		self.node_:removeSelf()
		self.node_ = nil
	end

	local node = display.newNode():addTo(self)
	node:setContentSize(cc.size(self:getContentSize().width, self:getContentSize().height))
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self.node_ = node

	if self.m_lock then
		local lock = display.newSprite(IMAGE_COMMON .. "icon_lock.png"):addTo(self.node_)
		lock:setPosition(self.node_:getContentSize().width / 2, self.node_:getContentSize().height / 2)

		self.selected_:setVisible(false)
		if self.unchosen_ then self.unchosen_:setVisible(false) end

		-- x级开启
		local level = TankBO.getFormationLockOpenLevel(self.m_position)
		local label = ui.newTTFLabel({text = level .. CommonText[237][4] .. CommonText[50], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self.node_)
		label:setPosition(self.node_:getContentSize().width / 2, 34)
	else
		if self.m_formationFor == FORMATION_FOR_TANK then
			if formatData and formatData.tankId > 0 then  -- 所在位置上有坦克
				local tankDB = TankMO.queryTankById(formatData.tankId)
				-- gprint("id:", formatData.tankId)
				-- dump(tankDB)

				local tankTag = UiUtil.createItemSprite(ITEM_KIND_TANK, tankDB.tankId):addTo(self.node_)
				tankTag:setAnchorPoint(cc.p(0.5, 0))
				tankTag:setPosition(self.node_:getContentSize().width / 2, 50)

				-- 名称
				local name = ui.newTTFLabel({text = tankDB.name, font = G_FONT, size = FONT_SIZE_TINY, x = self:getContentSize().width / 2, y = 34, align = ui.TEXT_ALIGN_CENTER, color = COLOR[tankDB.grade]}):addTo(self.node_)

				-- 数量
				local count = ui.newTTFLabel({text = formatData.count, font = G_FONT, size = FONT_SIZE_SMALL,
					x = self:getContentSize().width - 15, y = self:getContentSize().height - 30, align = ui.TEXT_ALIGN_RIGHT, color = COLOR[1]}):addTo(self.node_)
				count:setAnchorPoint(cc.p(1, 0.5))

				local am = display.newSprite(IMAGE_COMMON .. "icon_am_" .. tankDB.attackMode .. ".png", 35, self:getContentSize().height - 30):addTo(self.node_)
			else -- 位置上没有坦克
				if self.m_param.showAdd then
					local tag = display.newSprite(IMAGE_COMMON .. "icon_plus.png", self:getContentSize().width / 2, self:getContentSize().height / 2):addTo(self.node_)
					-- 添加坦克
					ui.newTTFLabel({text = CommonText[58], font = G_FONT, size = FONT_SIZE_TINY, x = self:getContentSize().width / 2, y = 34, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(self.node_)
				end
			end
		elseif self.m_formationFor == FORMATION_FOR_EQUIP then  -- 装备
		elseif self.m_formationFor == FORMATION_FOR_EQUIP_ITEM then -- 装备项
			local keyId = formatData
			if keyId > 0 then  -- 装上了装备
				local equip = EquipMO.getEquipByKeyId(keyId)
				local equipDB = EquipMO.queryEquipById(equip.equipId)

				local itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(self.node_)
				itemView:setPosition(self.node_:getContentSize().width / 2, self.node_:getContentSize().height / 2 + 2)
				itemView:setScale(1.24)
				self.node_.itemView = itemView

				local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_TINY, x = itemView:getContentSize().width / 2, y = -20, color = COLOR[equipDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
			end
		end
	end
end

function ArmyFormationNode:setNormal()
	if not self.m_lock then
		self.normal_:setVisible(true)
		self.selected_:setVisible(false)
	end
end

function ArmyFormationNode:setSelected()
	if not self.m_lock then
		self.normal_:setVisible(true)
		self.selected_:setVisible(true)
	end
end

function ArmyFormationNode:setChosen()
	if not self.m_lock then
		if self.chosen_ then self.chosen_:setVisible(true) end
		if self.unchosen_ then self.unchosen_:setVisible(false) end
	end
end

function ArmyFormationNode:setUnchosen()
	if not self.m_lock then
		if self.chosen_ then self.chosen_:setVisible(false) end
		if self.unchosen_ then self.unchosen_:setVisible(true) end
	end
end

function ArmyFormationNode:isLock()
	return self.m_lock
end

--------------------------------------------------------------------
-- 部队阵型view
-- 可以单手拖动以交换位置
--------------------------------------------------------------------
local ArmyFormationView = class("ArmyFormationView", Button)

-- local PositionConfig = {
-- {x = display.width / 2 - 172, y = 246},
-- {x = display.width / 2, y = 246},
-- {x = display.width / 2 + 172, y = 246},
-- {x = display.width / 2 - 172, y = 78},
-- {x = display.width / 2, y = 78},
-- {x = display.width / 2 + 172, y = 78}
-- }

function ArmyFormationView:ctor(formationFor, formation, lockData, param, tanks, kind)
	ArmyFormationView.super.ctor(self)
	self:setContentSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
	formation = formation or {}
	lockData = lockData or {}
	param = param or {}
	self.kind = kind
	if param.showAdd == nil then param.showAdd = true end  -- 没有坦克显示加号
	if param.reverse == nil then param.reverse = false end -- 是否逆转前后排

	-- local bg = display.newScale9Sprite(IMAGE_COMMON .. "a.png"):addTo(self)
	-- bg:setPreferredSize(cc.size(display.width, display.height))
	-- bg:setPosition(display.cx, display.cy)

	self.m_formationFor = formationFor
	self.m_lockData = lockData
	self.m_param = param

	-- 阵型中的节点是否可以拖拽
	self.m_dragEnabled = true

	self.m_chosePosition = 0

	-- 6个位置的view
	self.m_positionNodes = {}

	-- nodeTouchEventProtocol(self, handler(self, self.onTouch), nil, nil, false)
	self:setTouchSwallowEnabled(false)

	self:setAnchorPoint(cc.p(0.5, 0))  -- 以下边缘为锚点

	self.m_touchMoved = false
	self.m_touchPoint = cc.p(0, 0)

	self.m_offset = cc.p(14, 8)

	self:updateUI(formation)
end

function ArmyFormationView:getPositionAtIndex(index)
	local nodeWidth = 164
	local nodeHeight = 164

	if self.m_param.reverse then
		if index == 4 then return cc.p(self:getContentSize().width / 2 - nodeWidth - self.m_offset.x, 78 + nodeHeight + self.m_offset.y)
		elseif index == 5 then return cc.p(self:getContentSize().width / 2, 78 + nodeHeight + self.m_offset.y)
		elseif index == 6 then return cc.p(self:getContentSize().width / 2 + nodeWidth + self.m_offset.x, 78 + nodeHeight + self.m_offset.y)
		elseif index == 1 then return cc.p(self:getContentSize().width / 2 - nodeWidth - self.m_offset.x, 78)
		elseif index == 2 then return cc.p(self:getContentSize().width / 2, 78)
		elseif index == 3 then return cc.p(self:getContentSize().width / 2 + nodeWidth + self.m_offset.x, 78)
		end
	else
		if index == 1 then return cc.p(self:getContentSize().width / 2 - nodeWidth - self.m_offset.x, 78 + nodeHeight + self.m_offset.y)
		elseif index == 2 then return cc.p(self:getContentSize().width / 2, 78 + nodeHeight + self.m_offset.y)
		elseif index == 3 then return cc.p(self:getContentSize().width / 2 + nodeWidth + self.m_offset.x, 78 + nodeHeight + self.m_offset.y)
		elseif index == 4 then return cc.p(self:getContentSize().width / 2 - nodeWidth - self.m_offset.x, 78)
		elseif index == 5 then return cc.p(self:getContentSize().width / 2, 78)
		elseif index == 6 then return cc.p(self:getContentSize().width / 2 + nodeWidth + self.m_offset.x, 78)
		end
	end
end

function ArmyFormationView:getNodeAtPosition(position)
	return self.m_positionNodes[position]
end

function ArmyFormationView:updateUI(formation)
	self.m_formation = clone(formation)
	-- dump(self.m_formation, "ArmyFormationView 阵型")

	for index = 1, FIGHT_FORMATION_POS_NUM do
		if self.m_positionNodes[index] then
			self.m_positionNodes[index]:removeSelf()
			self.m_positionNodes[index] = nil
		end

		local node = ArmyFormationNode.new(index, self.m_formationFor, self.m_formation[index], self.m_lockData[index], self.m_param):addTo(self)
		local position = self:getPositionAtIndex(index)
		node:setPosition(position.x, position.y)

		self.m_positionNodes[index] = node
	end

	-- self:dispatchEvent({name = "UPDATE_FORMATION_EVENT"})
	self:updataFormationEvent()
end

function ArmyFormationView:updataFormationEvent()
	if self.kind then
		if self.kind == ARMY_SETTING_FOR_COMBAT or self.kind == ARMY_SETTING_FOR_WIPE then
			if not TankMO.formation_[FORMATION_FOR_COMBAT_TEMP] then TankMO.formation_[FORMATION_FOR_COMBAT_TEMP] = {} end
			if not TankMO.isEmptyFormation(self.m_formation) then
				TankMO.formation_[FORMATION_FOR_COMBAT_TEMP] = self.m_formation
			end
		elseif self.kind == ARMY_SETTING_FORTRESS_ATTACK then
			if not TankMO.isEmptyFormation(self.m_formation) then
				TankMO.formation_[FORMATION_FORTRESS_ATTACK] = self.m_formation
			end
		end
	end
	self:dispatchEvent({name = "UPDATE_FORMATION_EVENT"})
end

-- 更新阵型六个位置的位置偏移量，以控制节点直接的位置。(以第二排中间位置的中心点计算处理)
function ArmyFormationView:updateOffset(offset)
	self.m_offset = offset

	for index = 1, FIGHT_FORMATION_POS_NUM do
		local position = self:getPositionAtIndex(index)

		local node = self.m_positionNodes[index]
		node:setPosition(position.x, position.y)
	end
end

local function convertDistanceFromPointToInch(pointDis)
    local factor = ( CCEGLView:sharedOpenGLView():getScaleX() + CCEGLView:sharedOpenGLView():getScaleY() ) / 2
    return pointDis * factor / CCDevice:getDPI()
end

-- 查找curPosIndex的节点最近可互换位置的node，返回可互换位置node的索引
function ArmyFormationView:findNeighbouring(curPosIndex)
	local curViewNode = self.m_positionNodes[curPosIndex]

    for index = 1, FIGHT_FORMATION_POS_NUM do
    	if curPosIndex ~= index then
    		local viewNode = self.m_positionNodes[index]

    		local deltaX = curViewNode:getPositionX() - viewNode:getPositionX()
    		local deltaY = curViewNode:getPositionY() - viewNode:getPositionY()
    		local dis = math.sqrt(deltaX * deltaX + deltaY * deltaY)

    		if dis <= curViewNode:getContentSize().height / 2 then
    			return index
    		end
    	end
    end
    return 0
end

function ArmyFormationView:onTouchBegan(event)
	local captureIndex = 0
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local point = self:convertToNodeSpace(cc.p(event.x, event.y))

		local viewNode = self.m_positionNodes[index]
		-- if self.m_formationFor == FORMATION_FOR_TANK then  -- 如果是选择出阵tank阵型
		-- 	viewNode:setZOrder(1)
		-- 	viewNode:setNormal()
		-- end

		if captureIndex == 0 and cc.rectContainsPoint(viewNode:getBoundingBox(), point) then
			if viewNode:isLock() then
				local level = TankBO.getFormationLockOpenLevel(index)
				Toast.show(level .. CommonText[237][4] .. CommonText[50]) -- x级开启
			else
				captureIndex = index
				-- gprint("[ArmyFormationView] index:", index)

				-- viewNode:setZOrder(2)
				-- viewNode:setSelected()
			end
		end
	end

	self.m_touchMoved = false
	self.m_touchPoint = cc.p(event.x, event.y)
	self.m_touchIndex = captureIndex

	if captureIndex > 0 then
		-- if self.m_formationFor == FORMATION_FOR_EQUIP then  -- 装备只要began事件触摸到了，则算选中
			for index = 1, FIGHT_FORMATION_POS_NUM do
				local viewNode = self.m_positionNodes[index]
				viewNode:setZOrder(1)
				viewNode:setNormal()
				viewNode:setUnchosen()
			end

			self:onBeganPosition(captureIndex)
		-- end
		return true
	else
		return false
	end
end

function ArmyFormationView:onTouchMoved(event)
	if self.m_touchIndex == 0 then return end

	local newPoint = cc.p(event.x, event.y)
    local moveDistance = cc.PointSub(newPoint, self.m_touchPoint)

    if not self.m_touchMoved then
    	local dis = math.sqrt(moveDistance.x * moveDistance.x + moveDistance.y * moveDistance.y)
    	if math.abs(convertDistanceFromPointToInch(dis)) < 0.04375 then
    		return false
    	end
    end

    if not self.m_touchMoved then
    	moveDistance = cc.p(0, 0)
    end

    self.m_touchPoint = newPoint
    self.m_touchMoved = true

    if not self.m_dragEnabled then return end

    local curViewNode = self.m_positionNodes[self.m_touchIndex]

    local newPos = cc.p(curViewNode:getPositionX() + moveDistance.x, curViewNode:getPositionY() + moveDistance.y)
    curViewNode:setPosition(newPos.x, newPos.y)

    local find = self:findNeighbouring(self.m_touchIndex)

    for index = 1, FIGHT_FORMATION_POS_NUM do
    	if index ~= self.m_touchIndex then
	    	local viewNode = self.m_positionNodes[index]
	    	if find == index then
	    		viewNode:setSelected()
			else
				viewNode:setNormal()
			end
		end
	end
end

function ArmyFormationView:onTouchEnded(event)
	if self.m_touchIndex == 0 then return end

	if self.m_touchMoved and self.m_dragEnabled then
		local find = self:findNeighbouring(self.m_touchIndex)
		if find > 0 then  -- 两个node需要交换位置
			local findNode = self.m_positionNodes[find]
			if findNode:isLock() then
			else
				local from = self.m_touchIndex
				-- 交换数据
				local tmp = self.m_formation[self.m_touchIndex]
				self.m_formation[self.m_touchIndex] = self.m_formation[find]
				self.m_formation[find] = tmp

				-- 交换view
				local tmp = self.m_positionNodes[self.m_touchIndex]
				self.m_positionNodes[self.m_touchIndex] = self.m_positionNodes[find]
				self.m_positionNodes[find] = tmp

				self.m_touchIndex = find -- 更新当前索引的位置

				-- gprint("发送了")
				self:dispatchEvent({name = "EXCHANGE_FORMATION_EVENT", from = from, to = find})  -- 阵型有交换位置
				-- self:dispatchEvent({name = "UPDATE_FORMATION_EVENT"})
				self:updataFormationEvent()

				gdump(self.m_formation, "ArmyFormationView 新的阵型")
			end
		end

		for index = 1, FIGHT_FORMATION_POS_NUM do
			local viewNode = self.m_positionNodes[index]

			local position = self:getPositionAtIndex(index)

			if index ~= self.m_touchIndex then
				viewNode:runAction(transition.sequence({cc.EaseBackOut:create(cc.MoveTo:create(0.18, cc.p(position.x, position.y))), cc.CallFunc:create(function() viewNode:setZOrder(1) end)}))
			else
				viewNode:runAction(transition.sequence({cc.CallFunc:create(function() self:setEnabled(false) end),
					cc.MoveTo:create(0.18, cc.p(position.x, position.y)),
					cc.CallFunc:create(function()
							viewNode:setZOrder(1)
							self:setEnabled(true)
						end)}))
			end
		end
	else
		-- 判断当前选中的是否可以触发点击事件
		local point = self:convertToNodeSpace(cc.p(event.x, event.y))
		if self.m_touchIndex ~= 0 and cc.rectContainsPoint(self.m_positionNodes[self.m_touchIndex]:getBoundingBox(), point) then
			self:onPositionCallback(self.m_touchIndex)
		end
	end

	for index = 1, FIGHT_FORMATION_POS_NUM do
		local viewNode = self.m_positionNodes[index]
		if index ~= self.m_touchIndex then
			if not viewNode:isLock() then
				viewNode:setNormal()
			end
		else
			if not viewNode:isLock() then
				viewNode:setSelected()
			end
		end
	end

	self.m_touchIndex = 0
	self.m_touchPoint = cc.p(0, 0)
	self.m_touchMoved = false
end

function ArmyFormationView:onTouchCancelled(event)
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local viewNode = self.m_positionNodes[index]
		if index ~= self.m_touchIndex then
			viewNode:setNormal()
		else
			viewNode:setSelected()
		end
	end

	self.m_touchIndex = 0
	self.m_touchPoint = cc.p(0, 0)
	self.m_touchMoved = false
end

function ArmyFormationView:onTouch(event)
	if not self:isVisible() or not self:isEnabled() then return false end
	
    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    else -- cancelled
        self:onTouchCancelled(event)
    end
end

-- 某个位置被点击到了
function ArmyFormationView:onPositionCallback(position)
	ManagerSound.playNormalButtonSound()
	
	local formatData = self.m_formation[position]
	local viewNode = self.m_positionNodes[position]

	-- viewNode:setSelected()

	if self.m_formationFor == FORMATION_FOR_TANK then
		if formatData.tankId > 0 then  -- 点击的位置有坦克，则需要清除掉
			self.m_formation[position] = {tankId = 0, count = 0}
			viewNode:update(self.m_formation[position])

			-- self:dispatchEvent({name = "UPDATE_FORMATION_EVENT"})
			self:updataFormationEvent()
		else
			local function choseTank(data)
				if data.tankId > 0 and data.count > 0 then
					self.m_formation[position] = {tankId = data.tankId, count = data.count}
					viewNode:update(self.m_formation[position])

					-- self:dispatchEvent({name = "UPDATE_FORMATION_EVENT"})
					self:updataFormationEvent()
				else
					gdump(data, "[ArmyFormationView] choseTank Error")
				end
			end

			local ChoseArmyDialog = require("app.dialog.ChoseArmyDialog")
			local dialog = ChoseArmyDialog.new(self.m_formation, choseTank, self.kind):push()
		end
	elseif self.m_formationFor == FORMATION_FOR_EQUIP then
	elseif self.m_formationFor == FORMATION_FOR_EQUIP_ITEM then -- 某个装备
		self:dispatchEvent({name = "FORMATION_CHOSEN_EVENT", pos = position})
	end

end

function ArmyFormationView:onBeganPosition(position)
	local viewNode = self.m_positionNodes[position]

	viewNode:setZOrder(2)
	viewNode:setSelected()

	if self.m_formationFor == FORMATION_FOR_EQUIP then
		viewNode:setChosen()
	end

	gprint("ArmyFormationView:onBeganPosition:", position)
	self.m_chosePosition = position
	self:dispatchEvent({name = "FORMATION_BEGAN_EVENT", position = position})
end

-- 获得当前最新的阵型
function ArmyFormationView:getFormation()
	return self.m_formation
end

function ArmyFormationView:setDragEnabled(enabled)
	self.m_dragEnabled = enabled
end

function ArmyFormationView:getChosenPosition()
	return self.m_chosePosition
end

function ArmyFormationView:getFormationNode(position)
	return self.m_positionNodes[position]
end

return ArmyFormationView