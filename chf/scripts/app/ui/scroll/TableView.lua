
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

TABLE_SLIDER_POS_CEIL = 1  -- SCROLL_DIRECTION_VERTICAL方向在slider在左，SCROLL_DIRECTION_HORIZONTAL方向slider在上
TABLE_SLIDER_POS_FLOOR = 2 -- SCROLL_DIRECTION_VERTICAL方向在slider在右，SCROLL_DIRECTION_HORIZONTAL方向slider在下

---------------------------------------------------------------------------------
-- TableView的滑动条
---------------------------------------------------------------------------------
local TableViewSlider = class("TableViewSlider", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function TableViewSlider:ctor(direction, images, param)
	direction = direction or display.TOP_TO_BOTTOM
	param = param or {}
	param.length = param.length or 0

	self.direction_ = direction
	self.length_ = param.length
	self.maxLen_ = param.length / 2
	self.minLen_ = 30

	self:setCascadeOpacityEnabled(true)

	if direction == display.TOP_TO_BOTTOM then -- 纵向
		local bg = display.newScale9Sprite(images.bg):addTo(self)
		bg:setPreferredSize(cc.size(bg:getContentSize().width, param.length))
		bg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

		self.bar_ = display.newScale9Sprite(images.bar):addTo(self)
		self.bar_:setPreferredSize(cc.size(self.bar_:getContentSize().width, self.maxLen_))
		self.bar_:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(bg:getContentSize())
	else
	end
end

-- percent: 滚动条的百分比，取值范围为[-1, 2]
function TableViewSlider:slide(percent)
	percent = percent or 0
	percent = math.max(-1, math.min(2, percent))

	if self.direction_ == display.TOP_TO_BOTTOM then   -- 纵向

		if percent < 0 then
			local scale = 1 + percent
			local newH = self.bar_:getContentSize().height * scale
			newH = math.max(newH, self.minLen_)
			scale = newH / self.bar_:getContentSize().height
			percent = scale - 1

			self.bar_:setScaleY(scale)
			local pos = (self.length_ - self.bar_:getContentSize().height) * (1 - percent) + self.bar_:getContentSize().height * scale / 2
			self.bar_:setPositionY(pos)
		elseif percent > 1 then
			local scale = 2 - percent
			local newH = self.bar_:getContentSize().height * scale
			newH = math.max(newH, self.minLen_)
			scale = newH / self.bar_:getContentSize().height
			percent = scale - 2

			-- print("TableViewSlider percent:", percent)
			self.bar_:setScaleY(scale)
			self.bar_:setPositionY(self.bar_:getContentSize().height * scale / 2) -- 下对齐
		else
			-- local pos = self.length_ - self.bar_:getContentSize().height / 2 - (self.length_ - self.bar_:getContentSize().height) * percent
			local pos = (self.length_ - self.bar_:getContentSize().height) * (1 - percent) + self.bar_:getContentSize().height / 2
			-- print("TableViewSlider percent:", percent, "pos:", pos)
			self.bar_:setPositionY(pos)
		end

	elseif self.direction_ == display.LEFT_TO_RIGHT then  -- 横向
	-- 	local movable = (1 - self.m_percent) * self.m_barBgLength

	-- 	local delta = movable * limitPercent

	-- 	local scale = 1
	-- 	if percent < 0 then
	-- 		scale = 1 + percent
	-- 		self.m_bar:setScaleX(scale)
	-- 		self.m_bar:setPositionX(delta + self.m_bar:getContentSize().width * scale / 2)
	-- 	elseif percent > 1 then
	-- 		scale = 2 - percent
	-- 		self.m_bar:setScaleX(scale)
	-- 		self.m_bar:setPositionX(self.m_barBgLength - self.m_bar:getContentSize().width * scale / 2) -- 右对齐
	-- 	else
	-- 		self.m_bar:setPositionX(delta + self.m_bar:getContentSize().width / 2)
	-- 	end
	end
end

---------------------------------------------------------------------------------
-- TableView
---------------------------------------------------------------------------------
local TableView = class("TableView", ScrollView)

function TableView:ctor(size, direction, params)
    TableView.super.ctor(self, size, direction)

	-- 保存每个cell的button
	self.m_cellButtons = {}
	self.m_isShow = false
end

function TableView:onEnter()
	TableView.super.onEnter(self)
end

function TableView:onTouchBegan(event)

	local result = TableView.super.onTouchBegan(self, event)

	if not result then
		return result
	end
	
    local rect = self:getViewRect()
    local point = cc.p(self.m_touches[1].x, self.m_touches[1].y)
    if cc.rectContainsPoint(rect, point) then
		self:sliderAppear()
    end

    self.m_touchedButton = nil

	if self.m_touchedCell then
		local btns = self.m_cellButtons[self.m_touchedCellIndex]
		-- if btns and #btns == 2 then
		-- 	print("CellInex:", self.m_touchedCellIndex)
		-- end
		if btns and #btns > 0 then
			local point = event.points[self.m_touches[1].id]
			local button = self:checkButtons_(btns, point.x, point.y)
			if button then
				self.m_touchedButton = button
				self.m_touchedButton:onCellTouch(event)
			else
				self.m_touchedButton = nil
			end
		end
	end
	
    return result
end

function TableView:onTouchMoved(event)

    local oldCellIndex = self.m_touchedCellIndex
    local oldTouchedCell = self.m_touchedCell

	TableView.super.onTouchMoved(self, event)

	if self:isTouchMoved() then
        if self.m_deaccelerateHanlder ~= nil then
            scheduler.unscheduleGlobal(self.m_deaccelerateHanlder)
            self.m_deaccelerateHanlder = nil
        end

        if oldTouchedCell and self.m_touchedButton and #self.m_touches > 0 then
        	local point = event.points[self.m_touches[1].id]
        	if self.m_touchedButton.onCellTouch then
	        	self.m_touchedButton:onCellTouch({name = "cancelled", x = point.x, y = point.y})
	        end
        	self.m_touchedButton = nil
        end
    end

    if not self.m_touchedCell and oldCellIndex ~= 0 then  -- cell已经被释放了
    	self.m_touchedButton = nil
    end
end

function TableView:onTouchEnded(event)
	local moved = self:isTouchMoved()

	local capture = false

	if self.m_touchedCell and self.m_touchedButton then
		local btns = self.m_cellButtons[self.m_touchedCellIndex]
		if btns and #btns > 0 and #self.m_touches > 0 then
			local point = event.points[self.m_touches[1].id]
			local button = self:checkButtons_(btns, point.x, point.y)
			if button == self.m_touchedButton then
				self.m_touchedButton:onCellTouch({name = "ended", x = point.x, y =point.y})
				capture = true -- 事件被处理了
			end
		end
	end

	if capture then
		self.m_touchMoved = true
	end

	TableView.super.onTouchEnded(self, event)

	if moved then
		if self.m_scrollDistance.x == 0 and self.m_scrollDistance.y == 0 then return end

		-- gprint("TableView: self.m_scrollDistance:", self.m_scrollDistance.x, self.m_scrollDistance.y)
        -- self.m_relocatedDistance = {x = self.m_scrollDistance.x, y = self.m_scrollDistance.y}
        if self.m_deaccelerateHanlder ~= nil then
            scheduler.unscheduleGlobal(self.m_deaccelerateHanlder)
            self.m_deaccelerateHanlder = nil
        end
		self.m_deaccelerateHanlder = scheduler.scheduleUpdateGlobal(handler(self, self.deaccelerateScrolling))
	end
end

local SCROLL_DEACCEL_RATE = 0.93
local SCROLL_DEACCEL_DIST = 1

function TableView:deaccelerateScrolling(dt)
	local maxInset = self:maxContainerOffset()
	local minInset = self:minContainerOffset()

	-- if self.m_bounceable then
	if true then  -- 松手后惯性向前继续滑动一段时间
		local size = self:getViewSize()
		maxInset = cc.PointAdd(maxInset, cc.PointMult(cc.p(size.width, size.height), 0.2))
		minInset = cc.PointSub(minInset, cc.PointMult(cc.p(size.width, size.height), 0.2))
	end

	self.m_scrollDistance = cc.PointMult(self.m_scrollDistance, SCROLL_DEACCEL_RATE)

	-- if self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
	-- 	self.m_scrollDistance.x = self.m_scrollDistance.x * SCROLL_DEACCEL_RATE
	-- else
	-- 	self.m_scrollDistance.y = self.m_scrollDistance.y * SCROLL_DEACCEL_RATE
	-- end

	-- gprint("xxx", self.m_scrollDistance.x, self.m_scrollDistance.y)

	local newOffset = cc.PointAdd(cc.p(self:getContainer():getPositionX(), self:getContainer():getPositionY()), self.m_scrollDistance)

	if not self.m_bounceable then  -- 控制是否能划出边界
		newOffset.x = math.max(minInset.x, math.min(maxInset.x, newOffset.x))
		newOffset.y = math.max(minInset.y, math.min(maxInset.y, newOffset.y))
	end

	self:setContentOffset(newOffset)

	if (math.abs(self.m_scrollDistance.x) <= SCROLL_DEACCEL_DIST and math.abs(self.m_scrollDistance.y) <= SCROLL_DEACCEL_DIST)
		or newOffset.x >= maxInset.x or newOffset.x <= minInset.x or newOffset.y >= maxInset.y or newOffset.y <= minInset.y then
        scheduler.unscheduleGlobal(self.m_deaccelerateHanlder)
        self.m_deaccelerateHanlder = nil
        self:relocateContainer(true)
	end
end

function TableView:relocateContainer(animated)
	local maxInset = self:maxContainerOffset()
	local minInset = self:minContainerOffset()

	local oldPoint = cc.p(self:getContainer():getPositionX(), self:getContainer():getPositionY())
	local newX = oldPoint.x
	local newY = oldPoint.y

	if self:getDirection() == SCROLL_DIRECTION_BOTH or self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
		-- 必须是先max，再min，以规避min比max的值要大的情况
		newX = math.min(math.max(minInset.x, newX), maxInset.x)
	end

	if self:getDirection() == SCROLL_DIRECTION_BOTH or self:getDirection() == SCROLL_DIRECTION_VERTICAL then
		newY = math.max(minInset.y, math.min(newY, maxInset.y))
	end

	if newX ~= oldPoint.x or newY ~= oldPoint.y then
		self:setContentOffset(cc.p(newX, newY), animated)
	end
end

function TableView:scrollViewDidScroll()
	TableView.super.scrollViewDidScroll(self)

	self:scrollSlider()
end

function TableView:setContentOffsetInDuration(offset)
	self:getContainer():stopAllActions()
	self:getContainer():runAction(transition.sequence({cc.MoveTo:create(0.15, offset), cc.CallFunc:create(handler(self, self.stopdAnimatedScroll))}))

    if self.m_performedAnimatedScrollHandler ~= nil then
        scheduler.unscheduleGlobal(self.m_performedAnimatedScrollHandler)
        self.m_performedAnimatedScrollHandler = nil
    end
    self.m_performedAnimatedScrollHandler = scheduler.scheduleUpdateGlobal(handler(self, self.performedAnimatedScroll))
end

function TableView:performedAnimatedScroll(dt)
	if not self.scrollViewDidScroll then
		return
	end
	self:scrollViewDidScroll()
	
    -- if self.didScrollDelegate ~= nil then
    --     self.didScrollDelegate(self)
    -- end 
    -- if self.class and self.class.scrollSlider then
    --     self:scrollSlider()
    -- end
end

function TableView:stopdAnimatedScroll()
    if self.m_performedAnimatedScrollHandler ~= nil then
        scheduler.unscheduleGlobal(self.m_performedAnimatedScrollHandler)
        self.m_performedAnimatedScrollHandler = nil
    end

    -- if self.didScrollDelegate ~= nil then
    --     self.didScrollDelegate(self)
    -- end 
    -- if self.class and self.class.scrollSlider then
    --     self:scrollSlider()
    -- end
    -- self:unshowSlider()

    -- self:unshowShade(ListView.SHADE_LEFT)
    -- self:unshowShade(ListView.SHADE_RIGHT)
    -- self:unshowShade(ListView.SHADE_TOP)
    -- self:unshowShade(ListView.SHADE_BOTTOM)
end

function TableView:onExit()
	TableView.super.onExit(self)
	self:clearSchedulerHandler()
end

function TableView:clearSchedulerHandler()
    if self.m_deaccelerateHanlder ~= nil then
        scheduler.unscheduleGlobal(self.m_deaccelerateHanlder)
        self.m_deaccelerateHanlder = nil
    end

    if self.m_performedAnimatedScrollHandler ~= nil then
        scheduler.unscheduleGlobal(self.m_performedAnimatedScrollHandler)
        self.m_performedAnimatedScrollHandler = nil
    end
end

---------------------------------------------------------------------------------

function TableView:createCellAtIndex(cell, index)
	cell.addButton = function (cellSelf, cellButton, x, y, params)
		local cellIndex = cell._CELL_INDEX_

		x = x or 0
		y = y or 0
		params = params or {}
		params.order = params.order or 1

		cellButton:addTo(cell, params.order)
		cellButton:setPosition(x, y)
		cellButton._PARENT_CELL_INDEX_ = cellIndex
		cellButton._SCROLL_VIEW_ = self

		if not self.m_cellButtons[cellIndex] then self.m_cellButtons[cellIndex] = {} end
		table.insert(self.m_cellButtons[cellIndex], cellButton)
	end
end

function TableView:_moveCellOutOfSight(cell)
	local cellIndex = cell._CELL_INDEX_
	TableView.super._moveCellOutOfSight(self, cell)

	if self.m_cellButtons[cellIndex] then
		self.m_cellButtons[cellIndex] = {}
	end
end

-- function TableView:addButton(cell, cellButton, x ,y, params)
-- 	if not cell then return end

-- 	local cellIndex = cell._CELL_INDEX_

-- 	params = params or {}
-- 	params.order = params.order or 1

-- 	cellButton:addTo(cell, params.order)
-- 	cellButton:setPosition(x, y)
-- 	cellButton._PARENT_CELL_INDEX_ = cellIndex
-- 	cellButton._SCROLL_VIEW_ = self

-- 	if not self.m_cellButtons[cellIndex] then self.m_cellButtons[cellIndex] = {} end
-- 	table.insert(self.m_cellButtons[cellIndex], cellButton)
-- end

-- 需要在cell的按钮数组中删除cell buttons
function TableView:_removeCellButton(cellButton)
	local cellIndex = cellButton._PARENT_CELL_INDEX_
	-- self.m_cellButtons[cellIndex] = {}

	-- print("????_removeCellButton", cellIndex)
	local findIndex = 0

	local btns = self.m_cellButtons[cellIndex]
	for index = 1, #btns do
		if btns[index] == cellButton then
			findIndex = index
			break
		end
	end

	if findIndex > 0 then
		-- print("xxxxxxxxxxxxxxxx !!!!!!!!!找到了要删除", "cell:", cellButton._PARENT_CELL_INDEX_)
		table.remove(btns, findIndex)
	end
end

function TableView:checkButtons_(btns, x, y)
	for index = 1, #btns do
		local button = btns[index]
		if button and button:containPosition(x, y) then
			return button
		end
	end
	return nil
end

---------------------------------------------------------------------------------

-- slider在TableView的显示范围内出现，外部不需要设置位置等信息，但在排版时，需要注意给slider留出显示的空间
--增加param参数。可更换slider图片
--param.isShow参数判断是否永久显示sliderbar
function TableView:showSlider(needShow, sliderPos,param)
	if param and param.isShow then
		self.m_isShow  = param.isShow
	end
	if needShow then
		sliderPos = sliderPos or TABLE_SLIDER_POS_FLOOR

		if self.m_direction == SCROLL_DIRECTION_VERTICAL then
			param = param or {bar = "image/common/scroll_head_1.png", bg = "image/common/scroll_bg_1.png"}
			self.m_slider = TableViewSlider.new(display.TOP_TO_BOTTOM, param, {length = self:getContentSize().height - 40}):addTo(self, 2)
		elseif self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
			-- self.m_slider = TableViewSlider.new(display.LEFT_TO_RIGHT, {bar = "image/common/scroll_head_1.png", bg = "image/common/scroll_bg_1.png"}, {length = self:getContentSize().width - 10})
		end

		if self.m_slider then
			if sliderPos == TABLE_SLIDER_POS_CEIL then
				if self.m_direction == SCROLL_DIRECTION_VERTICAL then  -- 左边
					self.m_slider:setPosition(10, self:getContentSize().height / 2)
				else  -- 上边
					self.m_slider:setPosition(self:getContentSize().width / 2, self:getContentSize().height - 10)
				end
			else
				if self.m_direction == SCROLL_DIRECTION_VERTICAL then  -- 右边
					self.m_slider:setPosition(self:getContentSize().width - 10, self:getContentSize().height / 2)
				else  -- 下边
					self.m_slider:setPosition(self:getContentSize().width / 2, 10)
				end
			end
		end

		-- 创建时显示下，就消失
		self.m_slider:setOpacity(0)
		self:runAction(transition.sequence({cc.DelayTime:create(0.05),
			cc.CallFunc:create(function() self:sliderAppear() end)}))
	else
		if self.m_slider then
			self.m_slider:removeSelf()
			self.m_slider = nil
		end
	end
end

-- 如果TableView的内容
function TableView:needShowSlider()
	if self:getContainer():getContentSize().width <= self:getViewSize().width
		and self:getContainer():getContentSize().height <= self:getViewSize().height then
		return false
	else
		return true
	end
end

function TableView:scrollSlider()
	-- gprint("TableView:scrollSlider")

	if not self.m_slider then return end
	if not self:needShowSlider() then return end

	local offset = self:getContentOffset()
	local delta = cc.p(self:getContainer():getContentSize().width - self:getViewSize().width,
		self:getContainer():getContentSize().height - self:getViewSize().height)

	local percent = 0

	if self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
		if math.abs(delta.x) < 0.1 then percent = 1
		else percent = -offset.x / delta.x end

	elseif self.m_direction == SCROLL_DIRECTION_VERTICAL then
		if math.abs(delta.y) < 0.1 then percent = 1
		else percent = 1 + offset.y / delta.y end
		-- print("percent:", percent, "delta:", delta.y)
	end

	self.m_slider:slide(percent)

	self:sliderAppear()
end

-- 内部接口，不对外
-- slider在创建和touch事件时出现
function TableView:sliderAppear()
	if not self.m_slider then return end
	if not self:needShowSlider() then return end

	self.m_slider:setOpacity(255)
	self.m_slider:stopAllActions()
	if self.m_isShow then
		self.m_slider:runAction(transition.sequence({
				cc.DelayTime:create(0.3),
				cc.CallFunc:create(function() self.m_sliderOut = true end),
				cc.CallFunc:create(function() self.m_sliderOut = false end)}))
	else
		self.m_slider:runAction(transition.sequence({
				cc.DelayTime:create(0.3),
				cc.CallFunc:create(function() self.m_sliderOut = true end),
				cc.FadeOut:create(0.28),
				cc.CallFunc:create(function() self.m_sliderOut = false end)}))
	end
end

---------------------------------------------------------------------------------

function TableView:showShade(needShow)
	if needShow then
		local ceilShade = display.newScale9Sprite("image/common/info_bg_shade.png"):addTo(self)
		local floorShade = display.newScale9Sprite("image/common/info_bg_shade.png"):addTo(self)
		if self:getDirection() == SCROLL_DIRECTION_VERTICAL then
			ceilShade:setPreferredSize(cc.size(ceilShade:getContentSize().width, self:getViewSize().width))
			ceilShade:setRotation(270)
			ceilShade:setPosition(self:getViewSize().width / 2, self:getViewSize().height - ceilShade:getContentSize().width / 2)

			floorShade:setPreferredSize(cc.size(floorShade:getContentSize().width, self:getViewSize().width))
			floorShade:setRotation(90)
			floorShade:setPosition(self:getViewSize().width / 2, floorShade:getContentSize().width / 2)
		elseif self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
			ceilShade:setPreferredSize(cc.size(ceilShade:getContentSize().width, self:getViewSize().height))
			ceilShade:setRotation(180)
			ceilShade:setPosition(ceilShade:getContentSize().width / 2, self:getViewSize().height / 2)

			floorShade:setPreferredSize(cc.size(floorShade:getContentSize().width, self:getViewSize().height))
			floorShade:setPosition(self:getViewSize().width - floorShade:getContentSize().width / 2, self:getViewSize().height / 2)
		end
	end
end

---------------------------------------------------------------------------------

function TableView:cellAppearRecursively(direction)
	if self:getDirection() ~= SCROLL_DIRECTION_VERTICAL then
		return
	end

	direction = direction or display.LEFT_TO_RIGHT

	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if cell then
			if direction == display.LEFT_TO_RIGHT then
				cell:setPosition(display.width, cell:getPositionY())

				cell:runAction(transition.sequence({cc.DelayTime:create(index * 0.06), cc.MoveTo:create(0.3, cc.p(0, cell:getPositionY()))}))
				-- cell:runAction(transition.sequence({cc.DelayTime:create(index * 0.05), cc.EaseBackOut:create(cc.MoveTo:create(0.3, cc.p(0, cell:getPositionY())))}))
			end
		end
	end
end

return TableView
