
--
-- 可左右，或者上下滑动进行翻页，保持页对齐的控件
-- 注: 每个cell的大小必须和view的窗口大小一致

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
-- local PageSlider = import("app.component.page.PageSlider")


---------------------------------------------------------------------------------
-- PageView显示滑动到某一页的指示条
---------------------------------------------------------------------------------
local PageViewSlider = class("PageViewSlider", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function PageViewSlider:ctor(direction, images, param)
    direction = direction or display.TOP_TO_BOTTOM
    param = param or {}
    param.pageNum = param.pageNum or 1

    self.direction_ = direction
    self.pageNum_ = param.pageNum
    self.selected_ = {}

    self:setCascadeOpacityEnabled(true)

    if direction == display.TOP_TO_BOTTOM then -- 纵向
        -- local bg = display.newScale9Sprite(images.bg):addTo(self)
        -- bg:setPreferredSize(cc.size(bg:getContentSize().width, param.length))
        -- bg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

        -- self.bar_ = display.newScale9Sprite(images.bar):addTo(self)
        -- self.bar_:setPreferredSize(cc.size(self.bar_:getContentSize().width, self.maxLen_))
        -- self.bar_:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

        -- self:setAnchorPoint(cc.p(0.5, 0.5))
        -- self:setContentSize(bg:getContentSize())
    elseif direction == display.LEFT_TO_RIGHT then
        local startX = -(self.pageNum_ - 1) * 30 / 2

        for index = 1, self.pageNum_ do
            local bg = display.newSprite(images.bg):addTo(self)
            bg:setPosition(startX + (index - 1) * 30, 0)

            local selected = display.newSprite(images.selected):addTo(self, 2)
            selected:setPosition(bg:getPositionX(), bg:getPositionY())
            selected:setVisible(false)

            self.selected_[index] = selected
        end
    end

    self:setCurrentIndex(1)
end

function PageViewSlider:setCurrentIndex(pageIndex, animated)
    for index = 1, self.pageNum_ do
        self.selected_[index]:stopAllActions()

        if index ~= pageIndex then
            self.selected_[index]:setVisible(false)
        else
            self.selected_[index]:setVisible(true)
            if animated then
                self.selected_[index]:setOpacity(0)
                self.selected_[index]:runAction(cc.FadeIn:create(0.15))
            else
                self.selected_[index]:setOpacity(255)
            end
        end
    end
end

---------------------------------------------------------------------------------
-- PageView
---------------------------------------------------------------------------------
local PageView = class("PageView", ScrollView)

-- params包含PageView的参数，其中：
-- indicator: true时表示显示页码指示, indicatorX, indicatorY
-- pageBtn: true是显示左右翻页按钮, pageBtnParent:放置pageBtn的父控件, pageBtnLeftX, pageBtnLeftY, pageBtnRightX, pageBtnRightY, pageBtnZOrder
function PageView:ctor(size, direction, params)
    PageView.super.ctor(self, size, direction)
    
    -- self.pageMargin = pageMargin
    -- self.dragThreshold = 40
    -- self.bouncThreshold = 50
    -- self.defaultAnimateTime = 0.4
    -- self.defaultAnimateEasing = "backOut"

    -- self.direction = direction
    -- self.touchRect = rect
    -- self.offsetX = 0
    -- self.offsetY = 0
    -- self.cells = {}
    self.m_currentIndex = 1
    
    -- self.container = display.newNode():addTo(self)
    -- nodeTouchEventProtocol(self.container, function(event, x, y)
    --     return self:onTouch(event, x, y)
    -- end)

    -- 保存每个cell的button
    self.m_cellButtons = {}

    params = params or {}

    self.m_params_ = params
    -- if params.indicator then
    --     self:showPageIndicator()
    -- end

    -- if self.m_params_.pageBtn then
    --     self:showPageButton()
    -- end

    ---------------------------------------------------------------------------
    -- local bg = display.newScale9Sprite(IMAGE_COMMON .. "a.png"):addTo(self)
    -- bg:setPreferredSize(cc.size(size.width, size.height))
    -- bg:setPosition(size.width / 2, size.height / 2)
    ---------------------------------------------------------------------------
end

function PageView:getCurrentIndex()
    return self.m_currentIndex
end

function PageView:setCurrentIndex(index, animated)
    self:scrollToCell(index, animated)
end

function PageView:onTouchBegan(event)
    local result = PageView.super.onTouchBegan(self, event)

    if self.m_touchedCell then
        local btns = self.m_cellButtons[self.m_touchedCellIndex]
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

function PageView:onTouchMoved(event, x, y)
    local oldCellIndex = self.m_touchedCellIndex
    local oldTouchedCell = self.m_touchedCell

    PageView.super.onTouchMoved(self, event)

    if self:isTouchMoved() then
        if oldTouchedCell and self.m_touchedButton then
            local point = event.points[self.m_touches[1].id]
            self.m_touchedButton:onCellTouch({name = "cancelled", x = point.x, y = point.y})
            self.m_touchedButton = nil
        end
    end

    if not self.m_touchedCell and oldCellIndex ~= 0 then  -- cell已经被释放了
        self.m_touchedButton = nil
    end
end

function PageView:onTouchEnded(event)
    local moved = self:isTouchMoved()

    if self.m_touchedCell and self.m_touchedButton then
        local btns = self.m_cellButtons[self.m_touchedCellIndex]
        if btns and #btns > 0 then
            local point = event.points[self.m_touches[1].id]
            local button = self:checkButtons_(btns, point.x, point.y)
            if button == self.m_touchedButton then
                self.m_touchedButton:onCellTouch({name = "ended", x = point.x, y =point.y})
            end
        end
    end

    PageView.super.onTouchEnded(self, event)

    self:pageAlign()
end

function PageView:pageAlign()
    local cellCount = self:numberOfCells()
    local offset = cc.PointMult(self:getContentOffset(), -1)
    local cellSize = self:cellSizeForIndex(self.m_currentIndex)
    local indexOffset = self:_offsetFromIndex(self.m_currentIndex + 1)

    local alignIndex = 0

    if self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
        if offset.x + cellSize.width > indexOffset.x then -- 往左边滑动
            -- print("PageView offset:" .. offset.x, "width:" .. cellSize.width, "index:".. indexOffset.x)
            local index = 1
            while index <= cellCount do
                local size = self:cellSizeForIndex(index)
                local pageMargin = size.width / 5
                local indexOffset = self:_offsetFromIndex(index)
                 
                if offset.x < indexOffset.x + pageMargin  then
                    alignIndex = index
                    break
                end
           
                index = index + 1
            end

            if alignIndex == 0 then alignIndex = cellCount end
        else  -- 往右边滑动
            -- print("往右边滑动" .. "offset:" .. offset.x, "width:" .. cellSize.width, "index:".. indexOffset.x)

            local index = self:numberOfCells()

            while index >= 1 do
                local size = self:cellSizeForIndex(index)
                local pageMargin = size.width / 5
                local indexOffset = self:_offsetFromIndex(index + 1)
                 
                if offset.x > (indexOffset.x - size.width - pageMargin) then
                    alignIndex = index
                    break
                end
                index = index - 1
            end
        end
    end

    alignIndex = math.min(alignIndex, cellCount)

    self:scrollToCell(alignIndex, true)
end

function PageView:scrollToCell(index, animated)
    local cellCount = self:numberOfCells()
    if cellCount <= 0 then
        self.m_currentIndex = 0
        return
    end

    index = math.max(index, 1)
    index = math.min(index, cellCount)

    self.m_currentIndex = index

    -- local offset = 0
    -- for i = 1, index - 1 do
    --     local cellSize = self:cellSizeForIndex(i)

    --     if self:getDirection() == SCROLL_DIRECTION_HORIZONTAL then
    --         offset = offset - size.width
    --     else
    --         offset = offset + size.height
    --     end
    -- end

    local offset = cc.PointMult(self:_offsetFromIndex(self.m_currentIndex), -1)

    self:setContentOffset(offset, animated)

    self:dispatchEvent({name = "PAGE_SCROLL_TO", index = index})

    -- if self.m_params_.indicator then
    --     self:updatePageIndicator()
    -- end

    -- if self.m_params_.pageBtn then
    --     self:updatePageButton()
    -- end

    self:scrollSlider()
    -- if self.m_slider then
    --     self.m_slider:slide(self.m_currentIndex)
    -- end
end

function PageView:setContentOffsetInDuration(offset)
    local function stopdAnimatedScroll()
        if self.m_scrollHandler then
            scheduler.unscheduleGlobal(self.m_scrollHandler)
            self.m_scrollHandler = nil
        end
    end

    local container = self:getContainer()
    container:stopAllActions()
    container:runAction(transition.sequence({cc.MoveTo:create(0.4, offset),
        cc.CallFunc:create(stopdAnimatedScroll)}))

    if self.m_scrollHandler then
        scheduler.unscheduleGlobal(self.m_scrollHandler)
        self.m_scrollHandler = nil
    end
    self.m_scrollHandler = scheduler.scheduleUpdateGlobal(handler(self, self.onAnimatedScroll))
end

function PageView:onAnimatedScroll(dt)
    self:scrollViewDidScroll()
end

function PageView:onExit()
    PageView.super.onExit(self)
    
    if self.m_scrollHandler then
        scheduler.unscheduleGlobal(self.m_scrollHandler)
        self.m_scrollHandler = nil
    end
end

-- function PageView:onTouchCancelled(event, x, y)
--     self.drag = nil
-- end

-- function PageView:onTouch(event, x, y)
--     if self.currentIndex < 1 then return end
--     if event.name == "began" then
--       --  if not self.touchRect:containsPoint(CCPoint(x, y)) then return false end
--         return self:onTouchBegan(event, x, y)
--     elseif event.name == "moved" then
--         self:onTouchMoved(event, x, y)
--     elseif event.name == "ended" then
--         self:onTouchEnded(event, x, y)
--     else -- cancelled
--         self:onTouchCancelled(event, x, y)
--     end
-- end

---- private methods

-- function PageView:reorderAllCells()
--     local count = #self.cells
--     local x, y = 0, 0
--     local maxWidth, maxHeight = 0, 0
--     for i = 1, count do
--         local cell = self.cells[i]
--         cell:setPosition(x, y)
--         if self.direction == PageView.DIRECTION_HORIZONTAL then
--             local width = cell:getContentSize().width
--             if width > maxWidth then maxWidth = width end
--             x = x + width
--         else
--             local height = cell:getContentSize().height
--             if height > maxHeight then maxHeight = height end
--             y = y - height
--         end
--     end

--     if count > 0 then
--         if self.currentIndex < 1 then
--             self.currentIndex = 1
--         elseif self.currentIndex > count then
--             self.currentIndex = count
--         end
--     else
--         self.currentIndex = 0
--     end

--     local size
--     if self.direction == ScrollPage.DIRECTION_HORIZONTAL then
--         size = CCSize(x, maxHeight)
--     else
--         size = CCSize(maxWidth, math.abs(y))
--     end
--     self.container:setContentSize(size)
-- end

-- function ScrollPage:setContentOffset(offset, animated, time, easing)
--     local ox, oy = self.offsetX, self.offsetY
--     local x, y = ox, oy
--     if self.direction == ScrollPage.DIRECTION_HORIZONTAL then
--         self.offsetX = offset
--         x = offset

--         local maxX = self.bouncThreshold
--         local minX = -self.container:getContentSize().width - self.bouncThreshold + self.touchRect.size.width
--         if x > maxX then
--             x = maxX
--         elseif x < minX then
--             x = minX
--         end
--     else
--         self.offsetY = offset
--         y = offset

--         local maxY = self.container:getContentSize().height + self.bouncThreshold - self.touchRect.size.height
--         local minY = -self.bouncThreshold
--         if y > maxY then
--             y = maxY
--         elseif y < minY then
--             y = minY
--         end
--     end

--     if animated then
--         transition.stopTarget(self.container)
--         transition.moveTo(self.container, {
--             x = x,
--             y = y,
--             time = time or self.defaultAnimateTime,
--             easing = easing or self.defaultAnimateEasing,
--         })
--     else
--         self.container:setPosition(x, y)
--     end
-- end

-- function ScrollPage:onExit()
--     self:removeAllEventListeners()
-- end

-- function ScrollPage:createSlider(x, y)
--     local sliderDirection

--     if self.direction == ScrollPage.DIRECTION_VERTICAL then
--         sliderDirection = display.TOP_TO_BOTTOM
--     else
--         sliderDirection = display.LEFT_TO_RIGHT
--     end

--     -- if sliderDirection == display.TOP_TO_BOTTOM then
--         self.m_slider = PageSlider.new(sliderDirection, {bg = "image/common/scroll_page_bg.png", bar = "image/common/scroll_page_bar.png"}, self:getTotalCellNum())
--     -- else
--     --     self.m_slider = PageSlider.new(sliderDirection, {bg = "image/common/scroll_bar_bg_h.png", bar = "image/common/scroll_bar_h.png"}, {scale9 = true, length = totalLength})
--     -- end

--     if x and y then
--        self.m_slider:setPosition(x, y)
--     end

--     self.m_slider:slide(self:getCurrentIndex())

--     return self.m_slider
-- end

function PageView:createCellAtIndex(cell, index)
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

-- function PageView:addButton(cell, cellButton, x ,y, params)
--     if cell then
--         params = params or {}
--         local order = params.order or 1

--         local cellIndex = cell._CELL_INDEX_

--         cellButton:addTo(cell, order)
--         cellButton:setPosition(x, y)
--         cellButton._PARENT_CELL_INDEX_ = cellIndex
--         cellButton._SCROLL_VIEW_ = self

--         if not self.m_cellButtons[cellIndex] then self.m_cellButtons[cellIndex] = {} end
--         table.insert(self.m_cellButtons[cellIndex], cellButton)
--     end
-- end

-- 需要在cell的按钮数组中删除cell buttons
function PageView:_removeCellButton(cellButton)
    local cellIndex = cellButton._PARENT_CELL_INDEX_
    -- self.m_cellButtons[cellIndex] = {}

    local findIndex = 0

    local btns = self.m_cellButtons[cellIndex]
    for index = 1, #btns do
        if btns[index] == cellButton then
            findIndex = index
            break
        end
    end

    if findIndex > 0 then
        -- print("xxxxxxxxxxxxxxxx !!!!!!!!!找到了要删除")
        table.remove(btns, findIndex)
    end
end

function PageView:checkButtons_(btns, x, y)
    for index = 1, #btns do
        local button = btns[index]
        if button:isVisible() and button:containPosition(x, y) then
            return button
        end
    end
    return nil
end
--------------------------------------------------------------------------------

function PageView:showSlider(needShow)
    if needShow then

        if self.m_direction == SCROLL_DIRECTION_VERTICAL then
        elseif self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
            self.m_slider = PageViewSlider.new(display.LEFT_TO_RIGHT, {selected = "image/common/scroll_head_2.png", bg = "image/common/scroll_bg_2.png"}, {pageNum = self:numberOfCells()}):addTo(self, 2)
        end

        if self.m_slider then
            if self.m_direction == SCROLL_DIRECTION_VERTICAL then  -- 右边
                self.m_slider:setPosition(self:getContentSize().width - 10, self:getContentSize().height / 2)
            else  -- 下边
                self.m_slider:setPosition(self:getViewSize().width / 2, 10)
            end
        end

        self.m_slider:setCurrentIndex(1)
    else
        if self.m_slider then
            self.m_slider:removeSelf()
            self.m_slider = nil
        end
    end
end

function PageView:scrollSlider()
    if not self.m_slider then return end

    self.m_slider:setCurrentIndex(self.m_currentIndex, true)
end

--------------------------------------------------------------------------------

-- -- 显示页码指示 格式：1/2
-- function PageView:showPageIndicator()
--     if self.m_params_.indicator then
--         local pageIndicatorBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(self)

--         local x = self.m_params_.indicatorX or self:getViewSize().width / 2
--         local y = self.m_params_.indicatorY or pageIndicatorBg:getContentSize().height / 2
--         pageIndicatorBg:setPosition(x, y)

--         -- 页码指示器
--         self.m_pageIndicator = display.newTTFLabel({"", font = FONTS, size = FONTS_SIZE_TINY, x = pageIndicatorBg:getContentSize().width / 2, y = pageIndicatorBg:getContentSize().height / 2, color = cc.c3b(124, 57, 4)}):addTo(pageIndicatorBg)
--         self.m_pageIndicator.bg = pageIndicatorBg

--         self:updatePageIndicator()
--     end
-- end

-- function PageView:updatePageIndicator()
--     if self.m_params_.indicator and self.m_pageIndicator then
--         self.m_pageIndicator:setString(string.format("%d/%d", self:getCurrentIndex(), self:numberOfCells()))
--     end
-- end

--------------------------------------------------------------------------------

-- -- 显示左右翻页按钮
-- function PageView:showPageButton()
--     if self.m_params_.pageBtn and self.m_params_.pageBtnParent then
--         self.m_pageButton = {}

--         local function clickLeftPage(tag, sender)
--             local index = self.m_currentIndex - 1
--             self:setCurrentIndex(index, true)
--         end

--         local order = self.m_params_.pageBtnZOrder or 2
--         local normal = display.newSprite(IMAGE_COMMON .. "btn_7_normal.png")
--         local selected = display.newSprite(IMAGE_COMMON .. "btn_7_selected.png")
--         local leftBtn = MenuButton.new(normal, selected, nil, clickLeftPage):addTo(self.m_params_.pageBtnParent, 2)
--         leftBtn:setPosition(self.m_params_.pageBtnLeftX, self.m_params_.pageBtnLeftY)

--         leftBtn:runAction(cc.RepeatForever:create(cc.Sequence:create({cc.MoveBy:create(1, cc.p(-15, 0)),
--             cc.MoveBy:create(2, cc.p(30, 0)), cc.MoveBy:create(1, cc.p(-15, 0))})))

--         self.m_pageButton.left = leftBtn

--         local function clickRightPage(tag, sender)
--             local index = self.m_currentIndex + 1
--             self:setCurrentIndex(index, true)
--         end

--         local order = self.m_params_.pageBtnZOrder or 2
--         local normal = display.newSprite(IMAGE_COMMON .. "btn_7_normal.png")
--         normal:setScaleX(-1)
--         local selected = display.newSprite(IMAGE_COMMON .. "btn_7_selected.png")
--         selected:setScaleX(-1)
--         local rightBtn = MenuButton.new(normal, selected, nil, clickRightPage):addTo(self.m_params_.pageBtnParent, 2)
--         rightBtn:setPosition(self.m_params_.pageBtnRightX, self.m_params_.pageBtnRightY)

--         rightBtn:runAction(cc.RepeatForever:create(cc.Sequence:create({cc.MoveBy:create(1, cc.p(15, 0)),
--             cc.MoveBy:create(2, cc.p(-30, 0)), cc.MoveBy:create(1, cc.p(15, 0))})))

--         self.m_pageButton.right = rightBtn

--         self:updatePageButton()
--     end
-- end

-- function PageView:updatePageButton()
--     if not self.m_params_.pageBtn or not self.m_pageButton then return end

--     local cellCount = self:numberOfCells()

--     if cellCount <= 1 then
--         self.m_pageButton.left:setVisible(false)
--         self.m_pageButton.right:setVisible(false)
--         return
--     end

--     self.m_pageButton.left:setVisible(true)
--     self.m_pageButton.right:setVisible(true)

--     if self.m_currentIndex <= 1 then  -- 首页
--         self.m_pageButton.left:setVisible(false)
--     elseif self.m_currentIndex == cellCount then
--         self.m_pageButton.right:setVisible(false)
--     end
-- end

--------------------------------------------------------------------------------

return PageView
