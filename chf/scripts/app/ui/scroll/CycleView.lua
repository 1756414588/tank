local CycleView = class("CycleView",function(size)
    if not size then size = cc.size(0, 0) end
    local rect = cc.rect(0, 0, size.width, size.height)

    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function CycleView:ctor(size, direction)
    direction = direction or SCROLL_DIRECTION_VERTICAL

    self.m_direction = direction
    self.m_viewSize = size

    self.m_cellUsed = {}
    self.m_cellsPositions = {}
end

function CycleView:onEnter()
    self.m_container = display.newNode():addTo(self)
    nodeTouchEventProtocol(self.m_container, function(event) return self:onTouch(event) end, nil, nil, false)

    -- local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self, -1)
    -- bg:setPreferredSize(cc.size(self.m_viewSize.width, self.m_viewSize.height))
    -- bg:setAnchorPoint(cc.p(0.5, 0.5))
    -- bg:setPosition(self.m_viewSize.width / 2, self.m_viewSize.height / 2)

    self.m_container:setContentSize(self.m_viewSize)
    self.m_container:setPosition(0, 0)
end

function CycleView:setContentOffset(off)
    offset = cc.p(off.x, off.y)

    if self.m_direction == SCROLL_DIRECTION_VERTICAL then
        offset.x = 0 

        while offset.y < 0 do
            offset.y = offset.y + self.m_cellsPositions[#self.m_cellsPositions]
        end
        offset.y = offset.y % self.m_cellsPositions[#self.m_cellsPositions]

        if offset.y >= self.m_viewSize.height then
            offset.y = offset.y - self.m_cellsPositions[#self.m_cellsPositions]
        end

        -- gprint("CycleView:setContentOffset:", offset.x, offset.y, "!!!", self.m_cellsPositions[#self.m_cellsPositions])

        if offset.y <= 0 then -- 一段全部显示
            for index = 1, self:numberOfCells() do
                local cell = self:cellAtIndex(index)
                local size = self:cellSizeForIndex(index)
                cell:setPosition(offset.x, offset.y + size.height * self:numberOfCells() - size.height * index)
            end
        else -- 分为两部分显示
            local maxOffset = cc.p(offset.x, self.m_viewSize.height - offset.y)
            local maxIndex = self:_indexFromOffset(maxOffset)

            local endOffset = cc.p(offset.x, 1)
            local endIndex = self:_indexFromOffset(endOffset)

            -- gprint("maxIndex:", maxIndex, "endIndex:", endIndex)

            for index = maxIndex, endIndex do
                local cell = self:cellAtIndex(index)
                local size = self:cellSizeForIndex(index)
                cell:setPosition(offset.x, offset.y + size.height * self:numberOfCells() - size.height * index)
            end

            for index = 1, maxIndex - 1 do
                local cell = self:cellAtIndex(index)
                local size = self:cellSizeForIndex(index)
                cell:setPosition(offset.x, offset.y - size.height * index)
            end
        end
    elseif self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
        offset.y = 0

        while offset.x < 0 do
            offset.x = offset.x + self.m_cellsPositions[#self.m_cellsPositions]
        end

        offset.x = offset.x % self.m_cellsPositions[#self.m_cellsPositions]

        if offset.x >= self.m_viewSize.width then
            offset.x = offset.x - self.m_cellsPositions[#self.m_cellsPositions]
        end

        if offset.x <= 0 then -- 一段全部显示
            for index = 1, self:numberOfCells() do
                local cell = self:cellAtIndex(index)
                local size = self:cellSizeForIndex(index)
                cell:setPosition(offset.x + size.width * (index - 1), offset.y)
            end
        else
            -- local maxOffset = cc.p(offset.x, offset.y)
            -- local maxIndex = self:_indexFromOffset(maxOffset)

            local endOffset = cc.p(self.m_viewSize.width - offset.x, offset.y)
            local endIndex = self:_indexFromOffset(endOffset)

            -- gprint("maxIndex:", maxIndex, "endIndex:", endIndex, "endOffset:", endOffset.x)

            for index = 1, endIndex do
                local cell = self:cellAtIndex(index)
                local size = self:cellSizeForIndex(index)
                cell:setPosition(offset.x + size.width * (index - 1), offset.y)
            end

            for index = endIndex + 1, self:numberOfCells() do
                local cell = self:cellAtIndex(index)
                local size = self:cellSizeForIndex(index)
                cell:setPosition(offset.x + size.width * (index - 1) - size.width * self:numberOfCells(), offset.y)
            end
        end
    end
end

function CycleView:_indexFromOffset(offset)
    local off = cc.p(offset.x, offset.y)

    if self.m_direction == SCROLL_DIRECTION_VERTICAL then
        off.y = self.m_cellsPositions[#self.m_cellsPositions] - offset.y
    end

    return self:__indexFromOffset(off)
end

function CycleView:__indexFromOffset(offset)
    local low = 1
    local high = self:numberOfCells()
    local search = 0
    if self.m_direction == SCROLL_DIRECTION_HORIZONTAL then search = offset.x
    else search = offset.y end

    while high >= low do
        local index = math.floor(low + (high - low) / 2)
        local cellStart = self.m_cellsPositions[index]
        local cellEnd = self.m_cellsPositions[index + 1]

        if search >= cellStart and search < cellEnd then
            return index
        elseif search < cellStart then
            high = index - 1
        else
            low = index + 1
        end
    end

    if low <= 1 then return 1 end
    -- gprint("offset.x:" .. offset.x, "search:".. search)
    return -1
end

function CycleView:reloadData()
    for _, cell in pairs(self.m_cellUsed) do
        cell:removeSelf()
    end
    self.m_cellUsed = {}

    local cellsCount = self:numberOfCells()
    local currentPos = 0

    for index = 1, cellsCount do
        self.m_cellsPositions[index] = currentPos

        local node = display.newNode():addTo(self.m_container)
        node._CELL_INDEX_ = index

        local cell = self:createCellAtIndex(node, index)
        self.m_cellUsed[index] = cell

        local size = self:cellSizeForIndex(index)

        if self.m_direction == SCROLL_DIRECTION_VERTICAL then
            currentPos = size.height + currentPos
        else
            currentPos = size.width + currentPos
        end
    end
    self.m_cellsPositions[cellsCount + 1] = currentPos
    -- gdump(self.m_cellsPositions, "!!!!!!!!!")

    if self.m_direction == SCROLL_DIRECTION_VERTICAL then
        if self.m_cellsPositions[#self.m_cellsPositions] < self.m_viewSize.height then
            error("CycleView: 内容太少了 height is too small !!! VERTICAL")
        end
    else
        if self.m_cellsPositions[#self.m_cellsPositions] < self.m_viewSize.width then
            error("CycleView: 内容太少了 height is too small !!! HORIZONTAL")
        end
    end

    if self.m_direction == SCROLL_DIRECTION_VERTICAL then
        self:setContentOffset(cc.p(0, -(self.m_cellsPositions[#self.m_cellsPositions] - self.m_viewSize.height)))
    else
        self:setContentOffset(cc.p(0, 0))
    end
end

function CycleView:setTouchEnabled(enabled)
    self.m_container:setTouchEnabled(enabled)
    -- if not enabled then
    --     self.m_touchMoved = false
    --     self.m_dragging = false
    --     self.m_touches = {}
    -- end
end

function CycleView:onTouch(event)
    return true
end

function CycleView:cellAtIndex(index)
    return self.m_cellUsed[index]
end

function CycleView:getMaxContentOffset()
    if self.m_direction == SCROLL_DIRECTION_VERTICAL then
        return cc.p(0, self.m_cellsPositions[#self.m_cellsPositions])
    else
        return cc.p(self.m_cellsPositions[#self.m_cellsPositions], 0)
    end
end

function CycleView:cellSizeForIndex(index)
   error("ScrollView:cellSizeForIndex() - inherited class must override this method")
end

function CycleView:numberOfCells()
    error("ScrollView:numberOfCells() - inherited class must override this method")
end

function CycleView:createCellAtIndex(cell, index)
    error("ScrollView:createCellAtIndex() - inherited class must override this method")
end

return CycleView