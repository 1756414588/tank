
local TileLayer = require("app.world.TileLayer")
local PoisonLayer = require("app.world.PoisonLayer")

local TileMap = class("TileMap",function(size)
    if not size then size = cc.size(0, 0) end
    local rect = cc.rect(0, 0, size.width, size.height)

    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

-- 以当前view的正中心的坐标作为中心，下列偏移量的tile表示是可见范围内的
local WINDOW_OFFSET = {
{4, 1}, {4, 2}, {4, 3},
{3, 0}, {3, 1}, {3, 2}, {3, 3}, {3, 4},
{2, -1}, {2, 0}, {2, 1}, {2, 2}, {2, 3}, {2, 4},
{1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2}, {1, 3}, {1, 4},
{0, -3}, {0, -2}, {0, -1}, {0, 0}, {0, 1}, {0, 2}, {0, 3},
{-1, -4}, {-1, -3}, {-1, -2}, {-1, -1}, {-1, 0}, {-1, 1}, {-1, 2},
{-2, -4}, {-2, -3}, {-2, -2}, {-2, -1}, {-2, 0}, {-2, 1},
{-3, -4}, {-3, -3}, {-3, -2}, {-3, -1}, {-3, 0},
{-4, -1}, {-4, -2}, {-4, -3},
}

function TileMap:ctor(size, mapInfo)
    self:setContentSize(size)
    self.m_mapInfo = mapInfo
    self.m_tileUsed = {}
    self.m_homePos = cc.p(0, 0)
end

function TileMap:setHomePosition(pos)
    self.m_homePos = pos
end

function TileMap:onEnter()
    self:buildWithMapInfo(self.m_mapInfo)

    nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, cc.TOUCH_MODE_ALL_AT_ONCE, nil, false)

    self.m_mapHandler = Notify.register(LOCAL_GET_MAP_EVENT, handler(self, self.onMapGetUpdate))
    self.m_clearHandler = Notify.register(LOCAL_CLEAR_MAP_EVENT, handler(self, self.onClearUpdate))  -- 后台强制清除地图数据
    self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.onMapArmyUpdate))
    self.m_mapForceHandler = Notify.register(LOCAL_MAP_FORCE_EVENT, handler(self, self.onMapForceUpdate))
    self.m_levelHandler = Notify.register(LOCAL_LEVEL_EVENT, handler(self, self.onMapArmyUpdate))
    self.m_safeAreaHandler = Notify.register(LOCAL_UPDATE_SAFE_AREA, handler(self, self.onSafeAreaUpdate))
    self.m_royaleCloseHandler = Notify.register(LOCAL_ROYALE_SURVIVE_CLOSE, handler(self, self.onRoyaleClose))
end

function TileMap:onExit()
    if self.m_mapHandler then
        Notify.unregister(self.m_mapHandler)
        self.m_mapHandler = nil
    end
    if self.m_clearHandler then
        Notify.unregister(self.m_clearHandler)
        self.m_clearHandler = nil
    end
    if self.m_armyHandler then
        Notify.unregister(self.m_armyHandler)
        self.m_armyHandler = nil
    end
    if self.m_mapForceHandler then
        Notify.unregister(self.m_mapForceHandler)
        self.m_mapForceHandler = nil
    end
    if self.m_levelHandler then
        Notify.unregister(self.m_levelHandler)
        self.m_levelHandler = nil
    end
    if self.m_safeAreaHandler then
        Notify.unregister(self.m_safeAreaHandler)
        self.m_safeAreaHandler = nil
    end
    if self.m_royaleCloseHandler then
        Notify.unregister(self.m_royaleCloseHandler)
        self.m_royaleCloseHandler = nil
    end
end

function TileMap:buildWithMapInfo(mapInfo)
    self.layerContainer_ = nil
	self.mapSize_ = mapInfo:getMapSize()
	self.tileSize_ = mapInfo:getTileSize()

    local child = TileLayer.new(self):addTo(self, 1, 1)
    self.layerContainer_ = child

    self.poisonContainer_ = nil
    if RoyaleSurviveMO.isActOpen() then
        local poison = PoisonLayer.new(self):addTo(self, 2, 2)
        self.poisonContainer_ = poison
    end
end

-- 定位到某个坐标位子，是坐标位于可视范围内的中心
-- feedback: 定位到指定位置后，tile是否有动画反馈
function TileMap:locate(x, y, feedback)
    if x < 0 then x = 0 end
    if x > self.mapSize_.width - 1 then x = self.mapSize_.width - 1 end
    if y < 0 then y = 0 end
    if y > self.mapSize_.height - 1 then y = self.mapSize_.height - 1 end

    local pos = self.layerContainer_:getPositionAt(cc.p(x, y))
    local offset = cc.p(-pos.x + self:getContentSize().width / 2, -pos.y + self:getContentSize().height / 2 - self.tileSize_.height / 2)

    self:setContentOffset(offset)

    if feedback then
        local container = self.layerContainer_:getViewContainer(WorldMO.currentPos_)
        if container then
            container:stopAllActions()

            if container.choseView_ then
                container.choseView_:removeSelf()
                container.choseView_ = nil
            end

            cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")

            local view = nil
            if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
                view = display.newSprite("#tile_3.png"):addTo(container, -1)
            else
                view = display.newSprite("image/world/tile_3.png"):addTo(container, -1)
            end
            view:setAnchorPoint(cc.p(0.5, 0))
            view:setPosition(0, 0)
            container.choseView_ = view
            container:runAction(transition.sequence({cc.CallFuncN:create(function(sender) if sender.view_ then sender.view_:setColor(cc.c3b(125, 125, 125)) end end),
                cc.DelayTime:create(0.2),
                cc.CallFuncN:create(function(sender)
                        if sender.view_ then sender.view_:setColor(cc.c3b(255, 255, 255)) end
                        if sender.choseView_ then sender.choseView_:setVisible(false) end
                    end),
                cc.CallFuncN:create(function(sender) if sender.view_ then sender.view_:setColor(cc.c3b(125, 125, 125)) end;  sender.choseView_:setVisible(true) end),
                cc.DelayTime:create(0.1),
                cc.CallFuncN:create(function(sender)
                        if sender.view_ then sender.view_:setColor(cc.c3b(255, 255, 255)) end
                        if sender.choseView_ then sender.choseView_:removeSelf(); sender.choseView_ = nil end
                    end)
                }))
        end
    end
end

local function convertDistanceFromPointToInch(pointDis)
    -- local glView = cc.Director:getInstance():getOpenGLView()
    local factor = ( CCEGLView:sharedOpenGLView():getScaleX() + CCEGLView:sharedOpenGLView():getScaleY() ) / 2
    -- return pointDis * factor / cc.Device:getDPI()
    return pointDis * factor / CCDevice:getDPI()
end

function TileMap:getViewRect()
    self.m_viewSize = cc.size(self:getContentSize().width, self:getContentSize().height)

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

function TileMap:loadMap()
    if not self.m_tileUsed then return end

    self.layerContainer_:clearMineFreePos()

    for x, datas in pairs(self.m_tileUsed) do
        for y, tilePos in pairs(datas) do
            if x >= 0 and x < WORLD_SIZE_WIDTH and y >= 0 and y < WORLD_SIZE_HEIGHT then -- 地图范围内的
                local pos = cc.p(x, y)
                if not self.layerContainer_:hasLoadAt(pos) then
                    self.layerContainer_:loadTileAt(pos)
                else
                    if x == WorldMO.pos_.x and y == WorldMO.pos_.y then -- 玩家自己强制重新加载，这样如果免战或者有外观等则可以刷新
                        self.layerContainer_:reloadTileAt(pos)
                    else
                        if not self.layerContainer_:compareView(pos) then
                            self.layerContainer_:reloadTileAt(pos)
                        else
                        end
                    end
                end

                if self.poisonContainer_ then
                    if not self.poisonContainer_:hasLoadAt(pos) then
                        self.poisonContainer_:loadTileAt(pos)
                    else
                        if not self.poisonContainer_:compareView(pos) then
                            self.poisonContainer_:reloadTileAt(pos)
                        else
                        end
                    end
                end
            end
        end
    end
end

function TileMap:createPoison()
    -- body
    local x, y = self.layerContainer_:getPosition()
    self:setContentOffset(cc.p(x, y))
end

function TileMap:onMapGetUpdate(event)
    -- 获得信息后，延时一些时间再加载
    self:runAction(transition.sequence({cc.DelayTime:create(0.3), cc.CallFuncN:create(function()
            self:loadMap()
        end)}))
end

function TileMap:onSafeAreaUpdate(event)
    -- body
    if self.poisonContainer_ == nil then
        if RoyaleSurviveMO.isActOpen() then
            local poison = PoisonLayer.new(self):addTo(self, 2, 2)
            self.poisonContainer_ = poison
        end

        self:runAction(transition.sequence({cc.DelayTime:create(0.3), cc.CallFuncN:create(function()
            self:createPoison()
        end)}))
    else
        self:runAction(transition.sequence({cc.DelayTime:create(0.3), cc.CallFuncN:create(function()
            self:loadMap()
        end)}))
    end
end


function TileMap:onRoyaleClose(event)
    -- body
    self:runAction(transition.sequence({cc.DelayTime:create(0.3), cc.CallFuncN:create(function()
        self:loadMap()
    end)}))
end


function TileMap:onClearUpdate(event)
    self:loadMap()

    self:onRequestVisiualMapData()
end

function TileMap:onMapArmyUpdate(event)
    self:loadMap()
end

function TileMap:onMapForceUpdate(event)
    self:setHomePosition(cc.p(WorldMO.pos_.x, WorldMO.pos_.y))
    self:loadMap()
end

-- 请求可视范围内，还没有mapData数据的地图快的数据
function TileMap:onRequestVisiualMapData()
    local noMapDatas = {}
    for x, datas in pairs(self.m_tileUsed) do
        for y, tilePos in pairs(datas) do
            if x >= 0 and x < WORLD_SIZE_WIDTH and y >= 0 and y < WORLD_SIZE_HEIGHT then -- 地图范围内的
                local pos = cc.p(x, y)
                local mine = WorldBO.getMineAt(pos)
                if not mine then  -- 不是资源，则要提前判断是否有地图数据
                    local mapData = WorldMO.getMapDataAt(x, y)
                    if not mapData then  -- 目前还没有这些地图数据，需要请求
                        noMapDatas[#noMapDatas + 1] = pos
                    end
                end
            end

            if not self.layerContainer_:hasLoadAt(cc.p(x, y)) then
                self.layerContainer_:loadTileAt(cc.p(x, y))
            end

            if self.poisonContainer_ then
                if not self.poisonContainer_:hasLoadAt(cc.p(x, y)) then
                    self.poisonContainer_:loadTileAt(cc.p(x, y))
                end
            end
        end
    end
    
    WorldBO.asynGetMp(noMapDatas)
end

function TileMap:setContentOffset(offset)
    gdump("offset!!", setContentOffset)
    local newPos = offset
    local newCenterPos = cc.p(-newPos.x + self:getContentSize().width / 2, -newPos.y + self:getContentSize().height / 2)
    local newCenterTilePos = self.layerContainer_:getTilePositionAt(newCenterPos)

    -- print("pos:" .. newCenterTilePos.x, newCenterTilePos.y, "offset:" .. offset.x, offset.y)

    if newCenterTilePos.x < 0 or newCenterTilePos.x > 599
        or newCenterTilePos.y < 0 or newCenterTilePos.y > 599 then
        Toast.clear()
        Toast.show(CommonText[385])  -- 世界尽头
        return
    end

    self.layerContainer_:setPosition(offset)
    if self.poisonContainer_ then
        self.poisonContainer_:setPosition(offset)
    end

    WorldMO.setCurrentPosition(newCenterTilePos.x, newCenterTilePos.y)

    self:showIndicate()

    local centerPos = cc.p(-self.layerContainer_:getPositionX() + self:getContentSize().width / 2, -self.layerContainer_:getPositionY() + self:getContentSize().height / 2)
    local centerTilePos = self.layerContainer_:getTilePositionAt(centerPos)

    if not self.centerTilePos_ then
        self.centerTilePos_ = centerTilePos
    elseif self.centerTilePos_.x == centerTilePos.x and self.centerTilePos_.y == centerTilePos.y then
        -- gprint("是相同的")
        return
    end

    self.centerTilePos_ = centerTilePos

    local use = clone(self.m_tileUsed)
    self.m_tileUsed = {}

    for index = 1, #WINDOW_OFFSET do
        local tilePos = cc.p(centerTilePos.x + WINDOW_OFFSET[index][1], centerTilePos.y + WINDOW_OFFSET[index][2])

        if not self.layerContainer_:hasTileAt(tilePos) then
            self.layerContainer_:createTileAt(tilePos)
        end

        if self.poisonContainer_ then
            if not self.poisonContainer_:hasTileAt(tilePos) then
                self.poisonContainer_:createTileAt(tilePos)
            end
        end

        if use[tilePos.x] then use[tilePos.x][tilePos.y] = nil end

        if not self.m_tileUsed[tilePos.x] then self.m_tileUsed[tilePos.x] = {} end
        self.m_tileUsed[tilePos.x][tilePos.y] = tilePos
    end

    for x, datas in pairs(use) do  -- 将没有使用的tile清除
        for y, tilePos in pairs(datas) do
            self.layerContainer_:removeTileAt(cc.p(x, y))
            if self.poisonContainer_ then
                self.poisonContainer_:removeTileAt(cc.p(x, y))
            end
        end
    end

    use = nil

    for x, datas in pairs(self.m_tileUsed) do
        for y, tilePos in pairs(datas) do
            if not self.layerContainer_:hasLoadAt(cc.p(x, y)) then
                self.layerContainer_:loadTileAt(cc.p(x, y))
            end

            if self.poisonContainer_ then
                if not self.poisonContainer_:hasLoadAt(cc.p(x, y)) then
                    self.poisonContainer_:loadTileAt(cc.p(x, y))
                end
            end
        end
    end


    self:onRequestVisiualMapData()
    -- local noMapDatas = {}
    -- for x, datas in pairs(self.m_tileUsed) do
    --     for y, tilePos in pairs(datas) do
    --         if x >= 0 and x < WORLD_SIZE_WIDTH and y >= 0 and y < WORLD_SIZE_HEIGHT then -- 地图范围内的
    --             local pos = cc.p(x, y)
    --             local mine = WorldBO.getMineAt(pos)
    --             if not mine then  -- 不是资源，则要提前判断是否有地图数据
    --                 local mapData = WorldMO.getMapDataAt(x, y)
    --                 if not mapData then  -- 目前还没有这些地图数据，需要请求
    --                     noMapDatas[#noMapDatas + 1] = pos
    --                 end
    --             end
    --         end

    --         if not self.layerContainer_:hasLoadAt(cc.p(x, y)) then
    --             self.layerContainer_:loadTileAt(cc.p(x, y))
    --         end
    --     end
    -- end
    
    -- WorldBO.asynGetMp(noMapDatas)

    self:showCenter()
end

function TileMap:onTouch(event)
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
function TileMap:addTouchPoint(point)
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

function TileMap:deleteTouchPoint(point)
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

function TileMap:onTouchBegan(event)
    if not self:isVisible() then return false end

    -- if self.m_zoomHanlder then
    --     scheduler.unscheduleGlobal(self.m_zoomHanlder)
    --     self.m_zoomHanlder = nil
    -- end

    self.m_touchedTilePos = nil

    self.m_touches = {}

    -- gdump(self.m_touches, "[TileMap] onTouchBegan before")

    for id, point in pairs(event.points) do
        self:addTouchPoint(point)
    end

    local touches = self.m_touches

    -- gdump(self.m_touches, "[TileMap] onTouchBegan after")

    local rect = self:getViewRect()

    -- 滑动到可视范围外的不支持
    if not cc.rectContainsPoint(rect, cc.p(touches[1].x, touches[1].y)) then
        gprint("[TileMap] onTouch began not container point!!!")
        -- self:deleteTouchPoint(point)
        self.m_touches = {}
        return false
    end

    if #touches == 1 then
        self.m_touchPoint = cc.p(touches[1].x, touches[1].y)
        self.m_touchMoved = false
        self.m_dragging = true  -- 开始滑动
        self.m_scrollDistance = cc.p(0, 0)
        self.m_touchLength = 0

        local point = self.layerContainer_:convertToNodeSpace(self.m_touchPoint)
        local tilePos = self.layerContainer_:getTilePositionAt(point)
        -- gprint("tx:", tilePos.x, "ty:", tilePos.y, "x:", point.x, "y:", point.y)
        self.m_touchedTilePos = tilePos

        self:tileHighlight(self.m_touchedTilePos)

        -- local index = self:_indexFromOffset(point)
        -- if index == GAME_INVALID_VALUE then
        --     self.m_touchedCell = NULL
        --     self.m_touchedCellIndex = 0
        -- else
        --     self.m_touchedCell = self:cellAtIndex(index)
        --     self.m_touchedCellIndex = index
        -- end

        -- if self.m_touchedCell then
        --     self:cellHighlight(self.m_touchedCell, self.m_touchedCellIndex)
        -- end
    elseif #touches == 2 then
    --     self.m_touchLength = cc.PointDistance(cc.p(touches[1].x, touches[1].y), cc.p(touches[2].x, touches[2].y))
    --     self.m_dragging = false

    --     gprint("[TileMap] onTouchBegan 2点触控 ", touches[1].x, touches[1].y, touches[2].x, touches[2].y)
    end
    return true
end

function TileMap:onTouchAdded(event)
    if not self:isVisible() then return end
    -- gdump(event, "[TileMap] onTouchAdded event")

    -- if self.m_zoomHanlder then
    --     scheduler.unscheduleGlobal(self.m_zoomHanlder)
    --     self.m_zoomHanlder = nil
    -- end

    gprint("self.m_multiTouchEnabled:", self.m_multiTouchEnabled)
    if not self.m_multiTouchEnabled then return end  -- 不支持多点

    for id, point in pairs(event.points) do
        self:addTouchPoint(point)
    end

    -- gdump(self.m_touches, "[TileMap] onTouchAdded touches")

    -- 是多点触控
    self.m_touchedCell = nil
    self.m_touchedCellIndex = 0

    local touches = self.m_touches

    if #touches == 2 then
        self.m_touchLength = cc.PointDistance(cc.p(touches[1].x, touches[1].y), cc.p(touches[2].x, touches[2].y))
        self.m_dragging = false

        -- gprint("[TileMap] onTouchAdded 2点触控 ", touches[1].x, touches[1].y, touches[2].x, touches[2].y, "len:", self.m_touchLength)
    elseif #touches > 2 or self.m_touchMoved or not cc.rectContainsPoint(rect, cc.p(touches[1].x, touches[1].y)) then
        -- 多于两指不支持
        -- 滑动到可视范围外的不支持
        gprint("[TileMap] onTouch began not container point!!!")
        return false
    end
end

function TileMap:onTouchMoved(event)
    if not self:isVisible() then return end

    if #self.m_touches == 1 and self.m_dragging then
        -- dump(event)
        local point = event.points[self.m_touches[1].id]
        local newPoint = cc.p(point.x, point.y)

        self.m_touches[1].x = point.x
        self.m_touches[1].y = point.y

        local moveDistance = cc.PointSub(newPoint, self.m_touchPoint)
        local dis = math.sqrt(moveDistance.x * moveDistance.x + moveDistance.y * moveDistance.y )

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
            local newPos = cc.p(self.layerContainer_:getPositionX() + moveDistance.x, self.layerContainer_:getPositionY() + moveDistance.y)
            -- local newPos = cc.p(self:getContainer():getPositionX() + moveDistance.x, self:getContainer():getPositionY() + moveDistance.y)

            self.m_scrollDistance = moveDistance

    -- local newCenterPos = cc.p(-newPos.x + self:getContentSize().width / 2, -newPos.y + self:getContentSize().height / 2)
    -- local newCenterTilePos = self.layerContainer_:getTilePositionAt(newCenterPos)
    -- print("move:", newCenterTilePos.x, newCenterTilePos.y, self:getContentSize().width, self:getContentSize().height, newCenterPos.x, newCenterPos.y)

        -- local point = self.layerContainer_:convertToNodeSpace(self.m_touchPoint)
        -- local tilePos = self.layerContainer_:getTilePositionAt(point)

            self:setContentOffset(newPos)

            if self.centerView_ and not self.centerView_.show then
                self.centerView_:setVisible(true)
                self.centerView_.show = true
            end
        end

        if self.m_touchedTilePos then
            self:tileUnhighlight(self.m_touchedTilePos)
            self.m_touchedTilePos = nil
        end

        -- if self.m_touchedCell and self:isTouchMoved() then
        --     self:cellUnhighlight(self.m_touchedCell, self.m_touchedCellIndex)

        --     self.m_touchedCell = nil
        --     self.m_touchedCellIndex = 0
        -- end
    elseif #self.m_touches == 2 and not self.m_dragging then
        -- -- gdump(event, "[TileMap] onTouchMoved 2点滑动")
        -- local point1 = event.points[self.m_touches[1].id]
        -- local point2 = event.points[self.m_touches[2].id]
        -- local len = cc.PointDistance(cc.p(point1.x, point1.y), cc.p(point2.x, point2.y))
        -- self:setZoomScale(self:getZoomScale() * len / self.m_touchLength)
        -- self.m_touchLength = len -- 更新长度
    end
end

function TileMap:onTouchRemoved(event)
    if not self:isVisible() then return end

    if not self.m_multiTouchEnabled then return end  -- 不支持多点

    -- gdump(event, "[TileMap] onTouchRemoved")

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

function TileMap:onTouchEnded(event)
    if not self:isVisible() then return end

    if #self.m_touches == 1 and not self.m_touchMoved then
        if self.m_touchedTilePos then
            local point = event.points[self.m_touches[1].id]
            local point = self.layerContainer_:convertToNodeSpace(cc.p(point.x, point.y))
            local tilePos = self.layerContainer_:getTilePositionAt(point)
            if tilePos.x == self.m_touchedTilePos.x and tilePos.y == self.m_touchedTilePos.y then
                self:tileUnhighlight(self.m_touchedTilePos)
                self:tileTouched(self.m_touchedTilePos)
            end

            self.m_touchedTilePos = nil
        end
        -- if self.m_touchedCell then
            -- local point = event.points[self.m_touches[1].id]

        --     local point = self.m_touchedCell:convertToNodeSpace(cc.p(point.x, point.y))
        --     -- local rect = self:getBoundingBox()
        --     -- rect.width = self:getViewSize().width
        --     -- rect.height = self:getViewSize().height

        --     -- -- dump(rect, "TileMap:onTouchEnded")
        --     -- print("width:", rect.width, "height:", rect.height, "x:", point.x, "y:", point.y)

        --     -- if cc.rectContainsPoint(rect, point) then
        --         self:cellUnhighlight(self.m_touchedCell, self.m_touchedCellIndex)
        --         self:cellTouched(self.m_touchedCell, self.m_touchedCellIndex)
        --         -- print("在里面")
        --     -- else
        --     --     print("不在")
        --     -- end
        --     self.m_touchedCell = nil
        --     self.m_touchedCellIndex = 0
        -- end

        self.m_touchMoved = false
   end

    for id, point in pairs(event.points) do
        self:deleteTouchPoint(point)
    end

     if self.centerView_ and self.centerView_.show then
        self.centerView_:setVisible(false)
        self.centerView_.show = false
    end
    -- local zoomScale = self:getZoomScale()
    -- if zoomScale > self.m_maxScale then
    --     self:setZoomScale(self.m_maxScale, true)
    -- elseif zoomScale < self.m_minScale then
    --     self:setZoomScale(self.m_minScale, true)
    -- end
    -- if zoomScale > self.m_maxScale or zoomScale < self.m_minScale then
    --     if self.m_zoomHanlder ~= nil then
    --         scheduler.unscheduleGlobal(self.m_zoomHanlder)
    --         self.m_zoomHanlder = nil
    --     end
    --     self.m_zoomHanlder = scheduler.scheduleUpdateGlobal(handler(self, self.zoomScaling))
    -- end
end

function TileMap:onTouchCancelled(event)
    if not self:isVisible() then return end

    -- if self.m_zoomHanlder then
    --     scheduler.unscheduleGlobal(self.m_zoomHanlder)
    --     self.m_zoomHanlder = nil
    -- end

    if #self.m_touches == 1 and self.m_touchMoved then
        self.m_touchMoved = false

        -- if self.m_touchedCell then
        --     self:cellUnhighlight(self.m_touchedCell, self.m_touchedCellIndex)

        --     self.m_touchedCell = nil
        --     self.m_touchedCellIndex = 0
        -- end
    end

    for id, point in pairs(event.points) do
        self:deleteTouchPoint(point)
    end

    -- local zoomScale = self:getZoomScale()
    -- if zoomScale > self.m_maxScale or zoomScale < self.m_minScale then
    --     if self.m_zoomHanlder ~= nil then
    --         scheduler.unscheduleGlobal(self.m_zoomHanlder)
    --         self.m_zoomHanlder = nil
    --     end
    --     self.m_zoomHanlder = scheduler.scheduleUpdateGlobal(handler(self, self.zoomScaling))
    -- end
end

function TileMap:tileHighlight(tilePos)
    -- local x = tilePos.x % MINE_SIZE_WIDTH
    -- local y = tilePos.y % MINE_SIZE_HEIGHT
    -- local offset = math.floor(tilePos.x / MINE_SIZE_WIDTH) + math.floor(tilePos.y / MINE_SIZE_HEIGHT) * (WORLD_SIZE_WIDTH / MINE_SIZE_WIDTH)
    -- local minPos = (x + y * MINE_SIZE_WIDTH + MINE_OFFSET_SEED * offset) % 1600

    -- gprint("tx:", tilePos.x, "ty:", tilePos.y, "index", tileIndex, "mine:", minPos)
end

function TileMap:tileUnhighlight(tilePos)
    -- self.m_touchedTilePos
end

function TileMap:tileTouched(tilePos)
    ManagerSound.playNormalButtonSound()

    -- gprint("TileMap touch:", tilePos.x, tilePos.y)
    if tilePos.x < 0 or tilePos.x > self.mapSize_.width - 1
        or tilePos.y < 0 or tilePos.y > self.mapSize_.height - 1 then
        return
    end

    local function click()
        if FortressBO.isInScope(tilePos) then  -- 在要塞的范围内
            -- require("app.dialog.FortressDialog").new():push()
            local view = UiDirector.getTopUi()
            view:showChosenIndex(MAIN_SHOW_FORTRESS)
        elseif WorldMO.pos_.x == tilePos.x and WorldMO.pos_.y == tilePos.y then  -- 玩家自己
            local player = {icon = UserMO.portrait_, nick = UserMO.nickName_, level = UserMO.level_, lordId = UserMO.lordId_,
                fight = UserMO.fightValue_, pos = WorldMO.pos_, sex = UserMO.sex_, party = PartyBO.getMyPartyName(), pros = UserMO.getResource(ITEM_KIND_PROSPEROUS), prosMax = UserMO.maxProsperous_,ruins = UserMO.ruins}
            require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_WORLD_SELF, player):push()
        else
            local airsshipPos = AirshipMO.isInScope(tilePos)
            if airsshipPos then  -- 在飞艇范围内
                AirshipBO.getAirship(function()
                    local ab = AirshipMO.queryShip(airsshipPos) -- 飞艇信息
                    local airshipId = ab.id
                    local airshipData = AirshipBO.ships_ and AirshipBO.ships_[airshipId]
                    if airshipData and airshipData.base.safeEndTime >= 0 then
                        require("app.view.AirshipInfo").new(airsshipPos):push()
                        return
                    else
                        local openTime = json.decode(ab.openTime)
                        local unlockType = tonumber(openTime[1])
                        local strTip = CommonText[1051]

                        if unlockType == 1 then
                            strTip = string.format(CommonText[1102], openTime[2])
                        elseif unlockType == 2 then
                            local id = tonumber(openTime[2])
                            local preAb = AirshipMO.queryShipById(id)
                            strTip = string.format(CommonText[1103], preAb.name)
                        end 
                        Toast.show(strTip)
                        return
                    end
                    Notify.notify(LOCAL_GET_MAP_EVENT)
                end)
                return
            end
            local mine = WorldBO.getMineAt(tilePos)
            if mine then -- 是资源
                local WorldResDialog = require("app.dialog.WorldResDialog")
                WorldResDialog.new(tilePos.x, tilePos.y):push()
            else
                local mapData = WorldMO.getMapDataAt(tilePos.x, tilePos.y)
                if mapData then
                    --叛军
                    if table.isexist(mapData, "heroPick") then
                        local med = mapData.heroPick == -2 and RebelBO.checkActDead or RebelBO.checkDead
                        med(mapData.pos,function(dead)
                                if dead then
                                    Toast.show(CommonText[20127][mapData.heroPick == -2 and 2 or 1])
                                    WorldMO.mapData_[tilePos.x][tilePos.y] = nil
                                    self.layerContainer_:getViewContainer(tilePos):removeAllChildren()
                                    self.layerContainer_:getViewContainer(tilePos).view_ = nil
                                    self.layerContainer_:getViewContainer(tilePos).choseView_ = nil
                                else
                                    local WorldResDialog = require("app.dialog.WorldResDialog")
                                    WorldResDialog.new(tilePos.x, tilePos.y,mapData):push()
                                end
                            end)
                        return
                    end
                    -- 礼盒
                    if table.isexist(mapData, "rebelGift") then
                        local function rebelGiftResultCallback(data)
                            -- body
                            if data.leftCount == 0 then
                                Toast.show(CommonText[1852])
                                WorldMO.mapData_[tilePos.x][tilePos.y] = nil
                                self.layerContainer_:getViewContainer(tilePos):removeAllChildren()
                                self.layerContainer_:getViewContainer(tilePos).view_ = nil
                                self.layerContainer_:getViewContainer(tilePos).choseView_ = nil
                            elseif data.leftCount == -1 then
                                Toast.show(CommonText[1851])
                            elseif data.leftCount == -2 then
                                Toast.show(CommonText[1859])
                            elseif data.leftCount == -3 then
                                Toast.show(CommonText[1781])
                                WorldMO.mapData_[tilePos.x][tilePos.y] = nil
                                self.layerContainer_:getViewContainer(tilePos):removeAllChildren()
                                self.layerContainer_:getViewContainer(tilePos).view_ = nil
                                self.layerContainer_:getViewContainer(tilePos).choseView_ = nil
                            else
                                -- 刷新
                                WorldBO.asynGetMp({tilePos}, true)
                            end
                        end
                        RebelBO.GetRebelBoxAward(rebelGiftResultCallback,mapData.pos)
                        return
                    end
                    local function doneCallback(man)
                        Loading.getInstance():unshow()
                        if man then
                            gprint("mapData.pros", mapData.pros, "man.pros", man.pros)
                            mapData.pros = man.pros
                            mapData.prosMax = man.prosMax
                            mapData.lv = man.level

                            self:loadMap()

                            local player = {icon = man.icon, nick = mapData.name, level = man.level, lordId = man.lordId, rank = man.ranks, pos = cc.p(tilePos.x, tilePos.y),
                                fight = man.fight, sex = man.sex, party = man.partyName, pros = man.pros, prosMax = man.prosMax, free = mapData.free, ruins = mapData.ruins}
                            require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_WORLD_OTHER, player, {pos = cc.p(tilePos.x, tilePos.y)}):push()
                        end
                    end
                    Loading.getInstance():show()
                    -- 由于mapData中无法获得lordId，所以需要先调用SearchPlayer协议
                    SocialityBO.asynSearchPlayer(doneCallback, mapData.name)
                else
                    local function doneMoveHome()
                        Loading.getInstance():unshow()
                    end

                    local propCount = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_MOVE_HOME_SPECIFY)
                    if propCount > 0 then -- 有定点迁城道具
                        local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_MOVE_HOME_SPECIFY)
                        local ConfirmDialog = require("app.dialog.ConfirmDialog")
                        ConfirmDialog.new(string.format(CommonText[311][1], "", resData.name, tilePos.x, tilePos.y), function()
                                local status = WorldBO.getMoveHomeStatus()
                                if status == 1 then
                                    Toast.show(CommonText[10002][1])  -- 部队正在执行任务，无法迁徙
                                    return
                                end

                                Loading.getInstance():show()
                                WorldBO.asynMoveHome(doneMoveHome, tilePos.x, tilePos.y, 3)  -- 定点搬家
                            end):push()
                    else  -- 使用金币迁城
                        local resData = UserMO.getResourceData(ITEM_KIND_COIN)
                        local ConfirmDialog = require("app.dialog.ConfirmDialog")
                        ConfirmDialog.new(string.format(CommonText[311][1], HOME_MOVE_TAKE_COIN .. "", resData.name, tilePos.x, tilePos.y), function()
                                local status = WorldBO.getMoveHomeStatus()
                                if status == 1 then
                                    Toast.show(CommonText[10002][1])  -- 部队正在执行任务，无法迁徙
                                    return
                                end

                                local count = UserMO.getResource(ITEM_KIND_COIN)
                                if count < HOME_MOVE_TAKE_COIN then  -- 金币不足
                                    Toast.show(resData.name .. CommonText[223])
                                    return
                                end

                                Loading.getInstance():show()
                                WorldBO.asynMoveHome(doneMoveHome, tilePos.x, tilePos.y, 1)  -- 金币搬家
                            end):push()
                    end
                end
            end
        end
    end

    local function showClickEffectAndClick(btmView, colorView)
        btmView:stopAllActions()
        if colorView then
            colorView:setColor(cc.c3b(255, 255, 255))
        end

        -- if btmView.choseView_ then
        --     if not tolua.isnull(btmView.choseView_) then
        --         btmView.choseView_:removeSelf()
        --         btmView.choseView_ = nil
        --     end
        -- end
        btmView:removeChildByTag(999, true)

        cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")

        local view = nil
        if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
            view = display.newSprite("#tile_3.png"):addTo(btmView, -1, 999)
        else
            view = display.newSprite("image/world/tile_3.png"):addTo(btmView, -1, 999)
        end
        view:setAnchorPoint(cc.p(0.5, 0))
        view:setPosition(0, 0)
        btmView.choseView_ = view
        btmView:runAction(transition.sequence({cc.CallFuncN:create(function(sender) if colorView then colorView:setColor(cc.c3b(125, 125, 125)) end end),
            cc.DelayTime:create(0.2),
            cc.CallFuncN:create(function(sender)
                    if colorView then colorView:setColor(cc.c3b(255, 255, 255)) end
                    if sender.choseView_ then sender.choseView_:removeSelf(); sender.choseView_ = nil end
                end),
            cc.DelayTime:create(0.2),
            cc.CallFuncN:create(function(sender) click() end)}))
    end

    if FortressBO.isInScope(tilePos) then  -- 在要塞的范围内
        local container = self.layerContainer_:getViewContainer(tilePos)
        local fortressContainer = self.layerContainer_:getViewContainer(FortressMO.pos_)

        if fortressContainer then
            local fortressView = fortressContainer.view_
            showClickEffectAndClick(container, fortressView)
        else
            return
            -- error("TileMap tileTouched FortressBO.isInScope container is NULL!!! Error!!!")
        end
    else
        local airsship = AirshipMO.isInScope(tilePos)
        if airsship then  -- 在飞艇范围内
            local pos = WorldMO.decodePosition(airsship)
            local container = self.layerContainer_:getViewContainer(pos)
            local viewContainer = self.layerContainer_:getViewContainer(pos)

            if viewContainer then
                local view = viewContainer.view_
                showClickEffectAndClick(container, view)
            else
                return
                -- error("TileMap tileTouched FortressBO.isInScope container is NULL!!! Error!!!")
            end
            return
        end
        local container = self.layerContainer_:getViewContainer(tilePos)
        if container then
            showClickEffectAndClick(container, container.view_)
            -- container:stopAllActions()

            -- if container.choseView_ then
            --     container.choseView_:removeSelf()
            --     container.choseView_ = nil
            -- end

            -- cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")

            -- local view = display.newSprite("#tile_3.png"):addTo(container, -1)
            -- view:setAnchorPoint(cc.p(0.5, 0))
            -- view:setPosition(0, 0)
            -- container.choseView_ = view
            -- container:runAction(transition.sequence({cc.CallFuncN:create(function(sender) if sender.view_ then sender.view_:setColor(cc.c3b(125, 125, 125)) end end),
            --     cc.DelayTime:create(0.2),
            --     cc.CallFuncN:create(function(sender)
            --             if sender.view_ then sender.view_:setColor(cc.c3b(255, 255, 255)) end
            --             if sender.choseView_ then sender.choseView_:removeSelf(); sender.choseView_ = nil end
            --         end),
            --     cc.DelayTime:create(0.2),
            --     cc.CallFuncN:create(function(sender) click() end)}))
        else
            click()
        end
    end
end

function TileMap:showCenter()
    if not self.centerView_ then
        self.centerView_ = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(self, 1000)
        self.centerView_:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)

        local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = self.centerView_:getContentSize().width / 2, y = self.centerView_:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(self.centerView_)
        self.centerView_.label_ = label
        self.centerView_.show = false
        self.centerView_:setVisible(false)
    end

    local pos = cc.p(math.abs(self.layerContainer_:getPositionX() - self:getContentSize().width / 2), math.abs(self.layerContainer_:getPositionY() - self:getContentSize().height / 2))
    local tilePos = self.layerContainer_:getTilePositionAt(pos)
    self.centerView_.label_:setString("(" .. tilePos.x .. "," .. tilePos.y .. ")")
end

function TileMap:showIndicate()
    if not self.m_indicateBtn then
        -- 指示距离按钮
        local normal = display.newSprite(IMAGE_COMMON .. "btn_17_normal.png")
        normal:setScale(0.9)
        local selected = display.newSprite(IMAGE_COMMON .. "btn_17_selected.png")
        selected:setScale(0.)
        local btn = MenuButton.new(normal, selected, nil, handler(self, self.onHomeCallback)):addTo(self, 1001)
        btn:setAnchorPoint(cc.p(0, 0.5))
        self.m_indicateBtn = btn

        local timeLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = 50, y = btn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_indicateBtn)
        timeLabel:setAnchorPoint(cc.p(0, 0.5))
        self.m_indicateBtn.timeLabel_ = timeLabel
    end

    local pos = cc.p(math.abs(self.layerContainer_:getPositionX() - self:getContentSize().width / 2), math.abs(self.layerContainer_:getPositionY() - self:getContentSize().height / 2))
    local tilePos = self.layerContainer_:getTilePositionAt(pos)

    if tilePos.x == self.m_homePos.x and tilePos.y == self.m_homePos.y then
        self.m_indicateBtn:setVisible(false)
        return
    end

    self.m_indicateBtn:setVisible(true)
    self.m_indicateBtn:setPosition(100, 200)

    local homePos = self.layerContainer_:getPositionAt(self.m_homePos)
    local deltaX = pos.x - homePos.x
    local deltaY = pos.y - homePos.y
    local degree = clampAngle(math.deg(math.atan2(deltaX, deltaY)) - 90)
    -- gprint("degree:", degree)
    self.m_indicateBtn:setRotation(degree)

    local leftY = self.layerContainer_:getPositionY() + (-self.layerContainer_:getPositionX() - homePos.x) * deltaY / deltaX + homePos.y
    local rightY = self.layerContainer_:getPositionY() + (-self.layerContainer_:getPositionX() + self:getContentSize().width - homePos.x) * deltaY / deltaX + homePos.y
    -- print("leftY:", leftY, "rightY:", rightY)


    local bottomX = self.layerContainer_:getPositionX() + (-self.layerContainer_:getPositionY() - homePos.y) * deltaX / deltaY + homePos.x
    local topX = self.layerContainer_:getPositionX() + (-self.layerContainer_:getPositionY() + self:getContentSize().height - homePos.y) * deltaX / deltaY + homePos.x
    -- print("topX:", topX, "bottomX:", bottomX)

    if (leftY > 0 and leftY < self:getContentSize().height) or (rightY > 0 and rightY < self:getContentSize().height) then
        if homePos.x < pos.x then  -- 左边
            if leftY > self:getContentSize().height - 40 then leftY = self:getContentSize().height - 110 end
            if leftY <= 90 then
                leftY = leftY + 90
            end
            self.m_indicateBtn:setPosition(70, leftY)
        else
            if rightY > self:getContentSize().height - 40 then rightY = self:getContentSize().height - 110 end
            if rightY <= 90 then
                rightY = rightY + 90
            end
            self.m_indicateBtn:setPosition(self:getContentSize().width - 70, rightY)
        end
    elseif (bottomX > 0 and bottomX < self:getContentSize().width) or (topX > 0 and topX < self:getContentSize().width) then
        if homePos.y < pos.y then 
            if bottomX > self:getContentSize().width - 70 then
                bottomX = bottomX - 70
            end

            if bottomX < 70 then
                bottomX = bottomX + 70
            end
            self.m_indicateBtn:setPosition(bottomX, 90)
        else
            if topX > self:getContentSize().width - 70 then
                topX = topX - 70
            end

            if topX < 70 then
                topX = topX + 70
            end
            self.m_indicateBtn:setPosition(topX, self:getContentSize().height - 110)
        end
    end

    local time = WorldBO.getMarchTime(tilePos, self.m_homePos)
    -- print("time:", time)
    self.m_indicateBtn.timeLabel_:setString(UiUtil.strBuildTime(time))
    if degree > 90 and degree < 270 then
        self.m_indicateBtn:setScaleY(-1)
        self.m_indicateBtn.timeLabel_:setScaleX(-1)
        self.m_indicateBtn.timeLabel_:setPositionX(85)
    else
        self.m_indicateBtn:setScaleY(1)
        self.m_indicateBtn.timeLabel_:setScaleX(1)
        self.m_indicateBtn.timeLabel_:setPositionX(30)
    end
end

function TileMap:onHomeCallback(tag, sender)
    ManagerSound.playNormalButtonSound()
    self:locate(self.m_homePos.x, self.m_homePos.y)
end

return TileMap


