local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local ScrollView = class("ScrollView",function(size)
    if not size then size = cc.size(0, 0) end
    local rect = cc.rect(0, 0, size.width, size.height)

    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function ScrollView:ctor(size, direction)
    assert(direction == SCROLL_DIRECTION_VERTICAL or direction == SCROLL_DIRECTION_HORIZONTAL
        or direction == SCROLL_DIRECTION_BOTH,
           "ScrollView:ctor() - invalid direction")

    self.m_viewSize = size
    self.m_direction = direction
    -- self.m_offsetX = 0
    -- self.m_offsetY = 0
    -- self.m_cells = {}
    -- self.m_indices = {}
    self.m_cellsUsed = {}
    -- self.m_currentIndex = 0

    self.m_bounceable = true

    self.m_touchMoved = false
    self.m_dragging = false
    self.m_touches = {}

    self.m_canSlide = true -- 是否可以滑动,，如果不能滑动，则只能接受点击事件

    self.m_touchLength = 0
    self.m_zoomBounceable = true -- 当缩放到超过最大或者最小的范围时是否有缩回的效果
    self.m_multiTouchEnabled = false -- 多点触摸模式是否可用，默认是不可使用
    self.m_minScale = 1
    self.m_maxScale = 2

    self.m_container = display.newNode():addTo(self)
    nodeTouchEventProtocol(self.m_container, function(event)
        return self:onTouch(event)
    end, cc.TOUCH_MODE_ALL_AT_ONCE, nil, false)

    self:setCascadeOpacityEnabled(true)
    -- self:setAnchorPoint(cc.p(0.5, 0.5))
end

function ScrollView:onEnter()
end

function ScrollView:onExit()
    if self.m_zoomHanlder then
        scheduler.unscheduleGlobal(self.m_zoomHanlder)
        self.m_zoomHanlder = nil
    end
end

function ScrollView:reloadData()
    -- for key, cell in pairs(self.m_cells) do
    --     if cell then
    --         if cell:getParent() == self:getContainer() then
    --             self:getContainer():removeChild(cell, true)
    --         end
    --     end
    -- end
    -- self.m_cells = {}

    for key, cell in pairs(self.m_cellsUsed) do
        if cell then
            if cell:getParent() == self:getContainer() then
                self:getContainer():removeChild(cell, true)
            end
        end
    end

    self.m_cellsUsed = {}

    self:_updateCellPositions()
    self:_updateContentSize()

    -- local cellCount = self:numberOfCells()
    -- for index = 1, cellCount do
    -- 	local cell = self.m_cells[inidex]
    -- 	if not cell then
    -- 		cell = self:createCellAtIndex(index)
    -- 		self.m_cells[index] = cell

    -- 		local pos = self.m_cellsPositions[index]
    -- 		if self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
    --             cell:setPosition(pos, 0)
    --         else
	   --  		cell:setPosition(0, pos)
    -- 		end
    -- 		cell:setAnchorPoint(cc.p(0, 0))

    -- 		self:getContainer():addChild(cell)
    -- 	end
    -- end

    -- local cellCount = self:numberOfCells()
    -- for index = 1, cellCount do
    --     local cell = self.m_cellsUsed[inidex]
    --     if not cell then
    --         cell = self:createCellAtIndex(index)
    --         cell._CELL_INDEX_ = index
    --         self.m_cellsUsed[index] = cell
    --         -- self.m_indices[index] = cell._CELL_INDEX_

    --         local pos = self.m_cellsPositions[index]
    --         if self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
    --             cell:setPosition(pos, 0)
    --         else
    --             cell:setPosition(0, pos)
    --         end
    --         cell:setAnchorPoint(cc.p(0, 0))

    --         self:getContainer():addChild(cell)
    --     end
    -- end

    self.m_touchedCell = nil

    self:scrollViewDidScroll()
end

-- function ScrollView:getCurrentCell()
--     if self.m_currentIndex > 0 then
--         return self.m_cells[self.m_currentIndex]
--     else
--         return nil
--     end
-- end

-- function ScrollView:getTotalCellNum()
--     return #self.m_cells
-- end

-- function ScrollView:getCellAtIndex(index)
--     return self.m_cells[index]
-- end

-- function ScrollView:getCurrentIndex()
--     return self.m_currentIndex
-- end

-- function ScrollView:setCurrentIndex(index)
--     self:scrollToCell(index)
-- end

-- function ScrollView:addCell(cell)
--     self.m_container:addChild(cell)
--     self.m_cells[#self.m_cells + 1] = cell
--     self:reorderAllCells()
-- end

-- function ScrollView:insertCellAtIndex(cell, index)
--     self.m_container:addChild(cell)
--     table.insert(self.m_cells, index, cell)
--     self:reorderAllCells()
-- end

-- function ScrollView:removeCellAtIndex(index)
--     local cell = self.m_cells[index]
--     cell:removeSelf()
--     table.remove(self.m_cells, index)
--     self:reorderAllCells()
-- end

-- function ScrollView:removeAllCell()
--     self.m_container:removeAllChildrenWithCleanup(true)
--     self.m_cells = {}
--     self.m_currentIndex = 0
--     self:reorderAllCells()
-- end

function ScrollView:getContainer()
    return self.m_container
end

-- 更新设置view中每个cell的位置
function ScrollView:_updateCellPositions()
	local cellsCount = self:numberOfCells()
	self.m_cellsPositions = {}

	if cellsCount > 0 then
		local currentPos = 0
		for index = 1, cellsCount do
			self.m_cellsPositions[index] = currentPos

			local cellSize = self:cellSizeForIndex(index)
			if self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
				currentPos = cellSize.width + currentPos
			elseif self:getDirection() == SCROLL_DIRECTION_VERTICAL then
				currentPos = cellSize.height + currentPos
            else
                -- both的方式cell摆放的方式以横向为主
                currentPos = cellSize.width + currentPos
			end
		end
		-- 最后添加一个额外的值，可以获得最后一个cell的右边/底部位置
		self.m_cellsPositions[cellsCount + 1] = currentPos
	end
	-- gdump(self.m_cellsPositions, "ScrollView:_updateCellPositions")
end

-- 更新
function ScrollView:_updateContentSize()
	local cellsCount = self:numberOfCells()

	local size = cc.size(0, 0)
	if cellsCount > 0 then
		local maxPosition = self.m_cellsPositions[cellsCount + 1]

		if self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
			size = cc.size(maxPosition, self.m_viewSize.height)
		elseif self:getDirection() == SCROLL_DIRECTION_VERTICAL then
			size = cc.size(self.m_viewSize.width, maxPosition)
        else
            local height = self.m_viewSize.height
            for index = 1, cellsCount do -- 找到所有cell中最高的
                local size = self:cellSizeForIndex(index)
                height = math.max(height, size.height)
            end
            size = cc.size(maxPosition, height)
		end
	end

	self.m_container:setContentSize(size)

    -----------------------------------------------------------------------
    -- gdump(size, "ScrollView")
    if self.m_line then
        self.m_line:removeSelf()
    end

    if size.width ~= 0 and size.height ~= 0 then
        -- local line = display.newLine({{0, 0}, {size.width, size.height}})
        -- local line = display.newRect(size.width, size.height)
        
        -- local line = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png")
        -- line:setPreferredSize(cc.size(size.width - 10, size.height - 10))
        -- line:setPosition(size.width / 2, size.height / 2)
        -- line:setAnchorPoint(cc.p(0.5, 0.5))
        -- self.m_container:addChild(line)
        -- self.m_line = line
    end
    -----------------------------------------------------------------------

	if self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
		self:setContentOffset(cc.p(0, 0))
	elseif self:getDirection() == SCROLL_DIRECTION_VERTICAL then
        -- gprint("self:minContainerOffset().y:", self:minContainerOffset().y)
		self:setContentOffset(cc.p(0, self:minContainerOffset().y))
    else
        self:setContentOffset(cc.p(0, 0))
	end
end

function ScrollView:isTouchEnabled()
    return self.m_container:isTouchEnabled()
end

function ScrollView:setTouchEnabled(enabled)
    self.m_container:setTouchEnabled(enabled)
    if not enabled then
        self.m_touchMoved = false
        self.m_dragging = false
        self.m_touches = {}
    end
end

function ScrollView:getDirection()
	return self.m_direction
end

local function convertDistanceFromPointToInch(pointDis)
    -- local glView = cc.Director:getInstance():getOpenGLView()
    local factor = ( CCEGLView:sharedOpenGLView():getScaleX() + CCEGLView:sharedOpenGLView():getScaleY() ) / 2
    -- return pointDis * factor / cc.Device:getDPI()
    return pointDis * factor / CCDevice:getDPI()
end

function ScrollView:onTouch(event)
    -- event.name 是触摸事件的状态：began, moved, ended, cancelled, added（仅限多点触摸）, removed（仅限多点触摸）
    -- event.x, event.y 是触摸点当前位置
    -- event.prevX, event.prevY 是触摸点之前的位置

    -- if not self:isVisible() then return false end

    -- if event.name == "began" or event.name == "added" then
    -- elseif event.name == "moved" then
    -- elseif event.name == "removed" then
    -- elseif event.name == "ended" or event.name == "cancelled" then
    -- end

    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif  event.name == "added" then
        return self:onTouchAdded(event)
    elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    elseif event.name == "removed" then
        self:onTouchRemoved(event)
    else
        self:onTouchCancelled(event)
    end
end

-- point: id, x, y
function ScrollView:addTouchPoint(point)
    local find = nil
    for index = 1, #self.m_touches do
        local touch = self.m_touches[index]
        if touch.id == point.id then
            find = touch
            break
        end
    end

    if find then
        find.x = point.x
        find.y = point.y
        find.prevX = point.prevX
        find.prevY = point.prevY
    else
        self.m_touches[#self.m_touches + 1] = point
    end
end

function ScrollView:deleteTouchPoint(point)
    local findPos = nil
    for index = 1, #self.m_touches do
        local touch = self.m_touches[index]
        if touch.id == point.id then
            findPos = index
            break
        end
    end
    if findPos then
        table.remove(self.m_touches, findPos)
    end
end

function ScrollView:onTouchBegan(event)
    if not self:isVisible() then return false end

    if self.m_zoomHanlder then
        scheduler.unscheduleGlobal(self.m_zoomHanlder)
        self.m_zoomHanlder = nil
    end

    self.m_touches = {}

    -- gdump(self.m_touches, "[ScrollView] onTouchBegan before!!!!!!!!!!!!!!!!")

    for id, point in pairs(event.points) do
        self:addTouchPoint(point)
    end

    local touches = self.m_touches

    -- gdump(self.m_touches, "[ScrollView] onTouchBegan after!!!!!!!!!!!!!!!!")

    local rect = self:getViewRect()

    -- 滑动到可视范围外的不支持
    if not cc.rectContainsPoint(rect, cc.p(touches[1].x, touches[1].y)) then
        -- gprint("[ScrollView] onTouch began not container point!!!")
        -- self:deleteTouchPoint(point)
        self.m_touches = {}
        self.m_scrollDistance = cc.p(0, 0)
        self.m_touchLength = 0
        return false
    end

    if #touches == 1 then
        self.m_touchPoint = cc.p(touches[1].x, touches[1].y)
        self.m_touchMoved = false
        self.m_dragging = true  -- 开始滑动
        self.m_scrollDistance = cc.p(0, 0)
        self.m_touchLength = 0

        local point = self:getContainer():convertToNodeSpace(self.m_touchPoint)
        local index = self:_indexFromOffset(point)
        if index == GAME_INVALID_VALUE then
            self.m_touchedCell = nil
            self.m_touchedCellIndex = 0
        else
            self.m_touchedCell = self:cellAtIndex(index)
            self.m_touchedCellIndex = index
        end

        if self.m_touchedCell then
            self:cellHighlight(self.m_touchedCell, self.m_touchedCellIndex)
        end
    -- elseif #touches == 2 then
    --     self.m_touchLength = cc.PointDistance(cc.p(touches[1].x, touches[1].y), cc.p(touches[2].x, touches[2].y))
    --     self.m_dragging = false

    --     gprint("[ScrollView] onTouchBegan 2点触控 ", touches[1].x, touches[1].y, touches[2].x, touches[2].y)
    end
    return true
end

function ScrollView:onTouchAdded(event)
    if not self:isVisible() then return end
    -- gdump(event, "[ScrollView] onTouchAdded event")

    if self.m_zoomHanlder then
        scheduler.unscheduleGlobal(self.m_zoomHanlder)
        self.m_zoomHanlder = nil
    end

    -- print("self.m_multiTouchEnabled:", self.m_multiTouchEnabled)
    if not self.m_multiTouchEnabled then return end  -- 不支持多点

    for id, point in pairs(event.points) do
        self:addTouchPoint(point)
    end

    -- gdump(self.m_touches, "[ScrollView] onTouchAdded touches")

    -- 是多点触控
    self.m_touchedCell = nil
    self.m_touchedCellIndex = 0

    local touches = self.m_touches

    if #touches == 2 then
        self.m_touchLength = cc.PointDistance(cc.p(touches[1].x, touches[1].y), cc.p(touches[2].x, touches[2].y))
        self.m_dragging = false

        -- gprint("[ScrollView] onTouchAdded 2点触控 ", touches[1].x, touches[1].y, touches[2].x, touches[2].y, "len:", self.m_touchLength)
    elseif #touches > 2 or self.m_touchMoved or not cc.rectContainsPoint(rect, cc.p(touches[1].x, touches[1].y)) then
        -- 多于两指不支持
        -- 滑动到可视范围外的不支持
        -- gprint("[ScrollView] onTouch began not container point!!!")
        return false
    end
end

function ScrollView:onTouchMoved(event)
    if not self:isVisible() then return end

    if #self.m_touches == 1 and self.m_dragging then
        -- dump(event)
        local point = event.points[self.m_touches[1].id]
        local newPoint = cc.p(point.x, point.y)

        self.m_touches[1].x = point.x
        self.m_touches[1].y = point.y

        local moveDistance = cc.PointSub(newPoint, self.m_touchPoint)
        local dis = 0

        if self.m_direction == SCROLL_DIRECTION_VERTICAL then dis = moveDistance.y
        elseif self.m_direction == SCROLL_DIRECTION_HORIZONTAL then dis = moveDistance.x
        else dis = math.sqrt(moveDistance.x * moveDistance.x + moveDistance.y * moveDistance.y ) end

        if not self.m_touchMoved and math.abs(convertDistanceFromPointToInch(dis)) < 0.04375 then
            return
        end

        if not self.m_touchMoved then
            moveDistance = cc.p(0, 0)
        end

        self.m_touchPoint = newPoint
        self.m_touchMoved = true

        local rect = self:getViewRect()
        if cc.rectContainsPoint(rect, self.m_touchPoint) then
            if self.m_direction == SCROLL_DIRECTION_VERTICAL then
                moveDistance = cc.p(0, moveDistance.y)
            elseif self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
                moveDistance = cc.p(moveDistance.x, 0)
            end
            
            local newPos = cc.p(self:getContainer():getPositionX() + moveDistance.x, self:getContainer():getPositionY() + moveDistance.y)

            if self.m_bounceable then
                local minOffset = self:minContainerOffset()
                local maxOffset = self:maxContainerOffset()
                if self.m_direction == SCROLL_DIRECTION_VERTICAL then
                    if newPos.y < minOffset.y or newPos.y >= maxOffset.y then  -- 滑动超出container的显示正常范围
                        moveDistance = cc.PointMult(moveDistance, 0.33)
                    end
                elseif self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
                    if newPos.x < minOffset.x or newPos.x >= maxOffset.x then
                        moveDistance = cc.PointMult(moveDistance, 0.33)
                    end
                end

                newPos = cc.p(self:getContainer():getPositionX() + moveDistance.x, self:getContainer():getPositionY() + moveDistance.y)
            end

            self.m_scrollDistance = moveDistance

            self:setContentOffset(newPos)
        end

        if self.m_touchedCell and self:isTouchMoved() then
            self:cellUnhighlight(self.m_touchedCell, self.m_touchedCellIndex)

            self.m_touchedCell = nil
            self.m_touchedCellIndex = 0
        end
    elseif #self.m_touches == 2 and not self.m_dragging then
        -- gdump(event, "[ScrollView] onTouchMoved 2点滑动")
        local point1 = event.points[self.m_touches[1].id]
        local point2 = event.points[self.m_touches[2].id]
        if point1 and point2 then
            local len = cc.PointDistance(cc.p(point1.x, point1.y), cc.p(point2.x, point2.y))
            self:setZoomScale(self:getZoomScale() * len / self.m_touchLength)
            self.m_touchLength = len -- 更新长度
        end
    end
end

function ScrollView:onTouchRemoved(event)
    if not self:isVisible() then return end

    if not self.m_multiTouchEnabled then return end  -- 不支持多点

    -- gdump(event, "[ScrollView] onTouchRemoved")

    for id, point in pairs(event.points) do
        self:deleteTouchPoint(point)
    end

    if #self.m_touches == 1 then  -- 如果只剩单指，还是可以拖动的
        self.m_dragging = true
        self.m_touchPoint = cc.p(self.m_touches[1].x, self.m_touches[1].y)
    elseif #self.m_touches == 2 then
        self.m_touchLength = cc.PointDistance(cc.p(self.m_touches[1].x, self.m_touches[1].y), cc.p(self.m_touches[2].x, self.m_touches[2].y))
        self.m_dragging = false
    end
end

function ScrollView:onTouchEnded(event)
    if not self:isVisible() then return end

    if #self.m_touches == 1 and not self.m_touchMoved then
        if self.m_touchedCell then
            local point = event.points[self.m_touches[1].id]

            local point = self.m_touchedCell:convertToNodeSpace(cc.p(point.x, point.y))
            -- local rect = self:getBoundingBox()
            -- rect.width = self:getViewSize().width
            -- rect.height = self:getViewSize().height

            -- -- dump(rect, "ScrollView:onTouchEnded")
            -- print("width:", rect.width, "height:", rect.height, "x:", point.x, "y:", point.y)

            -- if cc.rectContainsPoint(rect, point) then
                self:cellUnhighlight(self.m_touchedCell, self.m_touchedCellIndex)
                self:cellTouched(self.m_touchedCell, self.m_touchedCellIndex)
                -- print("在里面")
            -- else
            --     print("不在")
            -- end
            self.m_touchedCell = nil
            self.m_touchedCellIndex = 0
        end

        self.m_touchMoved = false
   end

    for id, point in pairs(event.points) do
        self:deleteTouchPoint(point)
    end

    local zoomScale = self:getZoomScale()
    if zoomScale > self.m_maxScale then
        self:setZoomScale(self.m_maxScale, true)
    elseif zoomScale < self.m_minScale then
        self:setZoomScale(self.m_minScale, true)
    end
    -- if zoomScale > self.m_maxScale or zoomScale < self.m_minScale then
    --     if self.m_zoomHanlder ~= nil then
    --         scheduler.unscheduleGlobal(self.m_zoomHanlder)
    --         self.m_zoomHanlder = nil
    --     end
    --     self.m_zoomHanlder = scheduler.scheduleUpdateGlobal(handler(self, self.zoomScaling))
    -- end
end

function ScrollView:onTouchCancelled(event)
    if not self:isVisible() then return end

    if self.m_zoomHanlder then
        scheduler.unscheduleGlobal(self.m_zoomHanlder)
        self.m_zoomHanlder = nil
    end

    if #self.m_touches == 1 and self.m_touchMoved then
        self.m_touchMoved = false

        if self.m_touchedCell then
            self:cellUnhighlight(self.m_touchedCell, self.m_touchedCellIndex)

            self.m_touchedCell = nil
            self.m_touchedCellIndex = 0
        end
    end

    for id, point in pairs(event.points) do
        self:deleteTouchPoint(point)
    end

    local zoomScale = self:getZoomScale()
    if zoomScale > self.m_maxScale or zoomScale < self.m_minScale then
        if self.m_zoomHanlder ~= nil then
            scheduler.unscheduleGlobal(self.m_zoomHanlder)
            self.m_zoomHanlder = nil
        end
        self.m_zoomHanlder = scheduler.scheduleUpdateGlobal(handler(self, self.zoomScaling))
    end
end

function ScrollView:maxContainerOffset()
    return cc.p(0, 0)
end

function ScrollView:minContainerOffset()
    -- print("minContainerOffset:", self.m_viewSize.width - self:getContainer():getContentSize().width * self:getContainer():getScaleX())
    return cc.p(self.m_viewSize.width - self:getContainer():getContentSize().width * self:getContainer():getScaleX(),
        self.m_viewSize.height - self:getContainer():getContentSize().height * self:getContainer():getScaleY())
end

function ScrollView:setContentOffset(offset, animated)
    if not self.m_canSlide then return end
    
    if animated then
        self:setContentOffsetInDuration(offset)
        return
    end
    if not self.m_bounceable then  -- 是否有弹簧效果，可以划出范围外
        local minOffset = self:minContainerOffset()
        local maxOffset = self:maxContainerOffset()

        offset.x = math.max(minOffset.x, math.min(maxOffset.x, offset.x))
        offset.y = math.max(minOffset.y, math.min(maxOffset.y, offset.y))
        -- gprint("offset:", offset.x, "min:", minOffset.x, "max:", maxOffset.x)
    end

    self.m_container:setPosition(offset)

    self:scrollViewDidScroll()
end

function ScrollView:setContentOffsetInDuration(offset)
    error("ScrollView:setContentOffsetInDuration() - inherited class must override this method")
end

function ScrollView:getContentOffset()
    -- return self.m_container:getPosition()
    return cc.p(self.m_container:getPositionX(), self.m_container:getPositionY())
end

function ScrollView:cellAtIndex(index)
    for usedIndex = 1, #self.m_cellsUsed do
        local cell = self.m_cellsUsed[usedIndex]
        if cell._CELL_INDEX_ == index then
            return cell
        end
    end
    return nil
end

function ScrollView:isTouchMoved()
    return self.m_touchMoved
end

---------------------------- 需要覆写方法 -------------------------------------

-- 获得view中总共有多少个cell
function ScrollView:numberOfCells()
	error("ScrollView:numberOfCells() - inherited class must override this method")
end

-- 索引为index的cell的大小，index从1开启
function ScrollView:cellSizeForIndex(index)
	error("ScrollView:cellSizeForIndex() - inherited class must override this method")
end

-- cell:默认会创建一个空的node，node包含有_CELL_INDEX_的值。方法的返回的cellNode才是最终的cell
function ScrollView:createCellAtIndex(cell, index)
	error("ScrollView:createCellAtIndex() - inherited class must override this method")
end

-- 序列为index的cell将要被释放回收(也就是要删除cell)
function ScrollView:cellWillRecycle(cell, index)
    -- error("ScrollView:cellWillRecycle() - inherited class must override this method")
end

function ScrollView:cellHighlight(cell, index)
end

function ScrollView:cellUnhighlight(cell, index)
end

function ScrollView:cellTouched(cell, index)
end

-------------------------- private methods --------------------------------------

function ScrollView:getViewRect()
    local screenPos = self:convertToWorldSpace(cc.p(0, 0))

    local scaleX = self:getScaleX()
    local scaleY = self:getScaleY()

    local p = self:getParent()
    while p ~= nil do
        scaleX = scaleX * p:getScaleX()
        scaleY = scaleY * p:getScaleY()

        p = p:getParent()
    end

    if scaleX < 0 then
        screenPos.x = screenPos.x + self.m_viewSize.width * scaleX
        scaleX = -scaleX
    end

    if scaleY < 0 then
        screenPos.y = screenPos.y + self.m_viewSize.height * scaleY
        scaleY = -scaleY
    end

    -- print("width:", self:getContentSize().width, "height:", self:getContentSize().height)

    return cc.rect(screenPos.x, screenPos.y, self.m_viewSize.width * scaleX, self.m_viewSize.height * scaleY)
end

function ScrollView:scrollViewDidScroll()
    -- gprint("------------ scrollViewDidScroll -------------------------")
    local cellCount = self:numberOfCells()
    if cellCount <= 0 then return end

    local maxIndex = cellCount

    local offset = cc.PointMult(self:getContentOffset(), -1)
    if self.m_direction == SCROLL_DIRECTION_VERTICAL then
        offset.y = offset.y + self.m_viewSize.height / self:getContainer():getScaleY()
    end

    local startIndex = self:_indexFromOffset(cc.p(offset.x, offset.y))

    -- gprint("maxIndex:", maxIndex)

    -- gdump(offset, "scrollViewDidScroll startIndex offset")
    -- gprint("scrollViewDidScroll startIndex", startIndex)
    if startIndex == GAME_INVALID_VALUE then
        startIndex = cellCount
    end

    if self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
        -- 减1是因为位置是从0开始的
        offset.x = offset.x + self.m_viewSize.width / self:getContainer():getScaleX() - 1
    else
        offset.y = offset.y - self.m_viewSize.height / self:getContainer():getScaleY() + 1
    end

    local endIndex = self:_indexFromOffset(cc.p(offset.x, offset.y))
    -- gdump(offset, "endIndex offset")
    -- gprint("scrollViewDidScroll endIndex", endIndex)
    if endIndex == GAME_INVALID_VALUE then
        endIndex = cellCount
    end
    if endIndex == -1 then endIndex = cellCount end  -- 避免在container小于viewSize时，填不满整个view的情况

    if #self.m_cellsUsed > 0 then
        local cell = self.m_cellsUsed[1]
        local index = cell._CELL_INDEX_

        while index < startIndex do  -- 删除startIndex之前的cell
            -- gprint("start 处理前的cell的数量:", #self.m_cellsUsed)
            self:_moveCellOutOfSight(cell)
            -- gprint("start 需要删除cell:", index, "删除后的数量:", #self.m_cellsUsed)

            if #self.m_cellsUsed > 0 then
                cell = self.m_cellsUsed[1]
                index = cell._CELL_INDEX_
            else
                break
            end
        end
    end

    if #self.m_cellsUsed > 0 then
        local cell = self.m_cellsUsed[#self.m_cellsUsed]
        local index = cell._CELL_INDEX_

        while index <= maxIndex and index > endIndex do  -- 删除endIndex后面的cell
            -- gprint("end 处理前的cell的数量:", #self.m_cellsUsed)
            self:_moveCellOutOfSight(cell)
            -- gprint("end 需要删除cell:", index, "删除后的数量:", #self.m_cellsUsed)

            if #self.m_cellsUsed > 0 then
                cell = self.m_cellsUsed[#self.m_cellsUsed]
                index = cell._CELL_INDEX_
            else
                break
            end
        end
    end

    for index = startIndex, endIndex do  -- 创建可见的cell
        -- local hasCell = false
        -- for usedIndex = 1, #self.m_cellsUsed do
        --     local cell = self.m_cellsUsed[usedIndex]
        --     if cell._CELL_INDEX_ == index then
        --         hasCell = true
        --     end
        -- end
        local cell = self:cellAtIndex(index)

        if not cell then
            -- gprint("创建cell index:", index)
            self:updateCellAtIndex(index)
        end
    end
end

function ScrollView:updateCellAtIndex(index)
    if index == GAME_INVALID_VALUE then return end

    local cellCount = self:numberOfCells()
    if index <= 0 or index > cellCount then return end

    local cell = self:cellAtIndex(index)

    if cell then
        self:_moveCellOutOfSight(cell)
    end

    local node = display.newNode()
    node._CELL_INDEX_ = index
    node._SCROLL_VIEW_ = self
    
    cell = self:createCellAtIndex(node, index)
    self:_setIndexForCell(cell, index)
end

function ScrollView:_indexFromOffset(offset)
    local maxIndex = self:numberOfCells()

    if self:getDirection() == SCROLL_DIRECTION_VERTICAL then
        offset.y = self:getContainer():getContentSize().height - offset.y
    end

    local index = self:__indexFromOffset(offset)
    -- gdump(offset, "__indexFromOffset")
    -- gprint("index:", index)
    if index ~= -1 then
        index = math.max(1, index)
        if index > maxIndex then
            index = GAME_INVALID_VALUE
        end
    end
    return index
end

function ScrollView:__indexFromOffset(offset)
    local low = 1
    local high = self:numberOfCells()
    local search = 0
    if self.m_direction == SCROLL_DIRECTION_HORIZONTAL then search = offset.x
    elseif self.m_direction == SCROLL_DIRECTION_BOTH then search = offset.x
    else search = offset.y end

    while high >= low do
        local index = math.floor(low + (high - low) / 2)
        local cellStart = self.m_cellsPositions[index]
        local cellEnd = self.m_cellsPositions[index + 1]

        if not cellStart or not search or not cellEnd then
            gprint("ScrollView:__indexFromOffset cellStar:", cellStar, "search:", search, "cellEnd:", cellEnd)
            return -1
        end

        if search >= cellStart and search < cellEnd then
            return index
        elseif search < cellStart then
            high = index - 1
        else
            low = index + 1
        end
    end

    if low <= 1 then return 1 end
    -- gprint("offset.y:" .. offset.y, "search:".. search)
    return -1
end

-- 删除cell
function ScrollView:_moveCellOutOfSight(cell)
    local index = table.indexof(self.m_cellsUsed, cell)
    if index then
        -- gprint("成功需要删除 index:", index, " cellIndex:", cell._CELL_INDEX_)
        self:cellWillRecycle(cell, cell._CELL_INDEX_)

        table.remove(self.m_cellsUsed, index)
        -- table.remove(self.m_indices, index)
        if cell:getParent() == self:getContainer() then
            self:getContainer():removeChild(cell, true)
        end
    end
end

function ScrollView:_setIndexForCell(cell, index)
    cell:setAnchorPoint(cc.p(0, 0))
    cell:setPosition(self:_offsetFromIndex(index))
    cell._CELL_INDEX_ = index
    cell._SCROLL_VIEW_ = self

    self:getContainer():addChild(cell)

    if #self.m_cellsUsed <= 0 then
        table.insert(self.m_cellsUsed, cell)
    elseif index < self.m_cellsUsed[1]._CELL_INDEX_ then
        table.insert(self.m_cellsUsed, 1, cell)  -- 数组头插入
    else
        table.insert(self.m_cellsUsed, cell)
    end
end

function ScrollView:_offsetFromIndex(index)
    if self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
        return cc.p(self.m_cellsPositions[index], 0)
    else
        local offset = cc.p(0, self.m_cellsPositions[index])
        if self:getDirection() == SCROLL_DIRECTION_VERTICAL then
            local cellSize = self:cellSizeForIndex(index)
            offset.y = self:getContainer():getContentSize().height - offset.y - cellSize.height
        end
        return offset
    end
end

function ScrollView:zoomScaling(dt)
    local zoomScale = self:getZoomScale()
    -- gprint("zoomScale:", zoomScale)

    -- if zoomScale < self.m_minScale then
    --     zoomScale = zoomScale * 1.01
    -- elseif zoomScale > self.m_maxScale then
    --     zoomScale = zoomScale * 0.99
    -- end

    if math.abs(zoomScale - self.m_zoomScale) <= 0.001 then
        zoomScale = self.m_zoomScale
    else
        if zoomScale < self.m_zoomScale then
            zoomScale = math.min(zoomScale * 1.01, self.m_zoomScale)
        elseif zoomScale > self.m_zoomScale then
            zoomScale = math.max(zoomScale * 0.99, self.m_zoomScale)
        end
    end

    self:setZoomScale(zoomScale)

    if zoomScale == self.m_zoomScale then
    -- if zoomScale == self.m_maxScale or zoomScale == self.m_minScale then
        scheduler.unscheduleGlobal(self.m_zoomHanlder)
        self.m_zoomHanlder = nil
    end
end

function ScrollView:getZoomScale()
    return self.m_container:getScale()
end

function ScrollView:setZoomScale(s, animated)
    if animated then
        -- print("我去")
        -- self:getContainer():stopAllActions()
        -- self:getContainer():runAction(transition.sequence({cc.ScaleTo:create(0.4, s)}))

        -- print("ScrollView setZoomScale Error")
        if self.m_zoomHanlder ~= nil then
            scheduler.unscheduleGlobal(self.m_zoomHanlder)
            self.m_zoomHanlder = nil
        end
        self.m_zoomHanlder = scheduler.scheduleUpdateGlobal(handler(self, self.zoomScaling))
        self.m_zoomScale = s
    else
        -- gprint("setZoomScale scale:", s, "curS:", self.m_container:getScale())
        if self.m_container:getScale() ~= s then
            local center = nil
            if self.m_touchLength == 0 then
                center = cc.p(self.m_viewSize.width / 2, self.m_viewSize.height / 2)
                center = self:convertToWorldSpace(center)
            else
                center = self.m_touchPoint
            end

            local scale = 0
            if self.m_zoomBounceable then
                local minScale = self.m_minScale * 0.9
                local maxScale = self.m_maxScale * 1.2

                scale = math.max(minScale, math.min(maxScale, s))
            else
                scale = math.max(self.m_minScale, math.min(self.m_maxScale, s))
            end
            local oldCenter = self.m_container:convertToNodeSpace(center)
            self.m_container:setScale(scale)
            local newCenter = self.m_container:convertToWorldSpace(oldCenter)

            local offset = cc.PointSub(center, newCenter)
            self:setContentOffset(cc.PointAdd(cc.p(self.m_container:getPositionX(), self.m_container:getPositionY()), offset))
        end
    end
end

function ScrollView:getViewSize()
    return self.m_viewSize
end

function ScrollView:setMultiTouchEnabled(enabled)
    self.m_multiTouchEnabled = enabled
end

function ScrollView:setSlideEnabled(enabled)
    self.m_canSlide = enabled
end

return ScrollView