
-- 军事矿区

local MineLayer = require("app.mine.MineLayer")

local MineMap = class("MineMap",function(size)
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

function MineMap:ctor(size)
    self:setContentSize(size)
    self.m_tileUsed = {}
    self.m_homePos = cc.p(5, 5)
end

-- function MineMap:setHomePosition(pos)
--     self.m_homePos = pos
-- end

function MineMap:onEnter()
    self:buildWithMapInfo()

    nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, cc.TOUCH_MODE_ALL_AT_ONCE, nil, false)

    self.m_plunderHandler = Notify.register(LOCAL_PLUNDER_UPDATE_EVENT, handler(self, self.onPlunderUpdate))
    self.m_militaryAreaHandler = Notify.register(LOCAL_MILITARY_AREA_UPDATE_EVENT, handler(self, self.onMilitaryAreaUpdate))
    self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.onMilitaryAreaUpdate))

    local function refresh()
        if UiDirector.getTopUiName() == "HomeView1" then
            self:onMilitaryAreaUpdate()
        end
    end

    if not StaffMO.refreshHandler_ then
        StaffMO.refreshHandler_ = scheduler.scheduleGlobal(refresh, 30)
    end

    self:onMilitaryAreaUpdate()
end

function MineMap:onExit()
    Notify.unregister(self.m_plunderHandler)
    self.m_plunderHandler = nil

    Notify.unregister(self.m_militaryAreaHandler)
    self.m_militaryAreaHandler = nil

    Notify.unregister(self.m_armyHandler)
    self.m_armyHandler = nil

    if StaffMO.refreshHandler_ then
        scheduler.unscheduleGlobal(StaffMO.refreshHandler_)
        StaffMO.refreshHandler_ = nil
    end
end

function MineMap:onMilitaryAreaUpdate(event)
    local function doneCallback()
        Loading.getInstance():unshow()
        self:loadMap()
    end

    Loading.getInstance():show()
    StaffBO.asynGetSeniorMap(doneCallback)
end

function MineMap:buildWithMapInfo(mapInfo)
    self.layerContainer_ = nil
	-- self.mapSize_ = mapInfo:getMapSize()
	-- self.tileSize_ = mapInfo:getTileSize()
    self.mapSize_ = cc.size(20, 20)
    self.tileSize_ = cc.size(WORLD_TILE_WIDTH, WORLD_TILE_HEIGHT)

    local child = MineLayer.new(self):addTo(self, 1, 1)
    self.layerContainer_ = child

    -- gprint("Map content size:", self:getContentSize().width, self:getContentSize().height)

    self.m_xValue = 5
    self.m_yValue = 5


    local function onBuyCallback(tag, sender)
        local resData = UserMO.getResourceData(ITEM_KIND_COIN)
        local take = StaffBO.getBuyPlunderTake()

        local function doneCallback()
            Loading.getInstance():unshow()
            Toast.show(CommonText[10064][2])
        end

        local function gotoBuy()
            local count = UserMO.getResource(ITEM_KIND_COIN)
            if count < take then  -- 金币不足
                require("app.dialog.CoinTipDialog").new():push()
                return
            end

            Loading.getInstance():show()
            StaffBO.asynBuySenior(doneCallback)
        end

        if UserMO.consumeConfirm then
            local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
            CoinConfirmDialog.new(string.format(CommonText[10064][1], take), function() gotoBuy() end):push()
        else
            gotoBuy()
        end
    end

    if not StaffBO.isMilitaryAreaOpen() then  -- 活动时间未到
        local bg = display.newSprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(self, 2)
        bg:setAnchorPoint(cc.p(0, 0.5))
        bg:setPosition(0, self:getContentSize().height - 170)

        -- 非活动期间
        local label = ui.newTTFLabel({text = CommonText[10047][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[6]}):addTo(bg)
        label:setAnchorPoint(cc.p(0, 0.5))
    else
        local bg = display.newSprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(self, 2)
        bg:setAnchorPoint(cc.p(0, 0.5))
        bg:setPosition(40, self:getContentSize().height - 190)

        -- 掠夺
        local label = ui.newTTFLabel({text = CommonText[10047][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
        label:setAnchorPoint(cc.p(0, 0.5))

        local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
        label:setAnchorPoint(cc.p(0, 0.5))
        self.m_plunderLabel = label

        local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
        label:setAnchorPoint(cc.p(0, 0.5))
        self.m_plunderLimitLabel = label

        self:onPlunderUpdate()

        local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
        local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
        local btn = MenuButton.new(normal, selected, nil, onBuyCallback):addTo(self, 2)
        btn:setPosition(44, bg:getPositionY())


        local function queryWorldMine()
            -- body
            WorldBO.getWorldStaffing(function (data)
                -- body
                require_ex("app.dialog.WorldMineFieldDialog").new():push()
            end)
        end

        local normal1 = display.newSprite(IMAGE_COMMON .. "btn_world_mine.png")
        local selected1 = display.newSprite(IMAGE_COMMON .. "btn_world_mine.png")
        local hsBtn1 = MenuButton.new(normal1, selected1, nil, queryWorldMine):addTo(self, 2)
        hsBtn1:setPosition(btn:getContentSize().width/2, bg:getPositionY() - btn:height())
        hsBtn1:setScale(0.8)
    end

    -- 坐标
    local bg = display.newSprite(IMAGE_COMMON .. "info_bg_70.png"):addTo(self, 2)
    bg:setPosition(self:getContentSize().width / 2 + 10, 80)

    local function onXCallback(tag, sender)
        ManagerSound.playNormalButtonSound()
        local function showXValue(numValue)
            self.m_xValue = numValue
            self.m_xLabel:setString(self.m_xValue)
        end

        local KeyBoardDialog = require("app.dialog.KeyBoardDialog")
        local dialog = KeyBoardDialog.new(showXValue):push()
        dialog:getBg():setPosition(280, 210 + dialog:getBg():getContentSize().height / 2)
    end

    local normal = display.newSprite(IMAGE_COMMON .. "btn_tip_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_tip_selected.png")
    local btn = MenuButton.new(normal, selected, nil, onXCallback):addTo(bg)
    btn:setPosition(15, bg:getContentSize().height / 2)

    local label = ui.newTTFLabel({text = CommonText[305], font = G_FONT, size = FONT_SIZE_SMALL, x = 80, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
    label:setAnchorPoint(cc.p(0, 0.5))

    -- X:
    local label = ui.newTTFLabel({text = "X:", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
    label:setAnchorPoint(cc.p(0, 0.5))

    local normal = display.newSprite(IMAGE_COMMON .. "btn_16_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_16_selected.png")
    local xBtn = MenuButton.new(normal, selected, nil, onXCallback):addTo(bg)
    xBtn:setPosition(label:getPositionX() + 85, bg:getContentSize().height / 2)

    local label = ui.newTTFLabel({text = self.m_xValue, font = G_FONT, size = FONT_SIZE_SMALL, x = xBtn:getContentSize().width / 2, y = xBtn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(xBtn)
    self.m_xLabel = label

    -- Y:
    local label = ui.newTTFLabel({text = "Y:", font = G_FONT, size = FONT_SIZE_SMALL, x = xBtn:getPositionX() + 110, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
    label:setAnchorPoint(cc.p(0, 0.5))

    local function onYCallback(tag, sender)
        ManagerSound.playNormalButtonSound()
        local function showValue(numValue)
            self.m_yValue = numValue
            self.m_yLabel:setString(self.m_yValue)
        end

        local KeyBoardDialog = require("app.dialog.KeyBoardDialog")
        local dialog = KeyBoardDialog.new(showValue):push()
        dialog:getBg():setPosition(440, 210 + dialog:getBg():getContentSize().height / 2)
    end

    local normal = display.newSprite(IMAGE_COMMON .. "btn_16_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_16_selected.png")
    local yBtn = MenuButton.new(normal, selected, nil, onYCallback):addTo(bg)
    yBtn:setPosition(label:getPositionX() + 85, bg:getContentSize().height / 2)

    local label = ui.newTTFLabel({text = self.m_yValue, font = G_FONT, size = FONT_SIZE_SMALL, x = yBtn:getContentSize().width / 2, y = yBtn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(yBtn)
    self.m_yLabel = label

    local function onLocationCallback(tag, sender)
        ManagerSound.playNormalButtonSound()
        local x = math.max(0, math.min(self.mapSize_.width - 1, self.m_xValue))
        local y = math.max(0, math.min(self.mapSize_.height - 1, self.m_yValue))
        self:locate(x, y)
    end

    local normal = display.newSprite(IMAGE_COMMON .. "btn_go_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_go_selected.png")
    local locationBtn = MenuButton.new(normal, selected, nil, onLocationCallback):addTo(bg, 10)
    locationBtn:setPosition(bg:getContentSize().width - 30, bg:getContentSize().height / 2)

    local function gotoCrossServerMineMap()
        --跨服军事矿区70才可进入
        if UserMO.level_ < UserMO.querySystemId(81) then
            Toast.show(string.format(CommonText[8032], UserMO.querySystemId(81)))
            return
        end
        local HomeView = require("app.view.HomeView")
        local view = HomeView.new(MAIN_SHOW_CROSSSERVER_MINE_AREA):push()
    end

    --跨服军事矿区
    local normal = display.newSprite(IMAGE_COMMON .. "btn_cross_mine.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_cross_mine.png")
    local socialBtn = MenuButton.new(normal, selected, nil, gotoCrossServerMineMap):addTo(self, 2)
    socialBtn:setScale(0.8)
    socialBtn:setPosition(display.width - 50, 400)
    socialBtn:setVisible(StaffMO.CrossServerMineOpen == 2)

    local function gotoDetail(tag, sender)
        ManagerSound.playNormalButtonSound()
        local DetailTextDialog = require("app.dialog.DetailTextDialog")
        DetailTextDialog.new(DetailText.militaryArea):push()
    end

    -- 详情
    local normal = display.newSprite(IMAGE_COMMON .. "btn_51_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_51_selected.png")
    local socialBtn = MenuButton.new(normal, selected, nil, gotoDetail):addTo(self, 2)
    socialBtn:setPosition(display.width - 50, 280)

    local function gotoRank(tag, sender)
        ManagerSound.playNormalButtonSound()
        require("app.view.StaffRankView").new():push()
    end

    -- 排行
    local normal = display.newSprite(IMAGE_COMMON .. "btn_50_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_50_selected.png")
    local socialBtn = MenuButton.new(normal, selected, nil, gotoRank):addTo(self, 2)
    socialBtn:setPosition(display.width -50, 160)

end

function MineMap:onPlunderUpdate(event)
    if self.m_plunderLabel then
        self.m_plunderLabel:setString(StaffMO.plunderCount_)
        if StaffMO.plunderCount_ <= 0 then
            self.m_plunderLabel:setColor(COLOR[5])
        else
            self.m_plunderLabel:setColor(COLOR[2])
        end
        self.m_plunderLimitLabel:setString("/" .. StaffMO.plunderLimit_)
        self.m_plunderLimitLabel:setPosition(self.m_plunderLabel:getPositionX() + self.m_plunderLabel:getContentSize().width, self.m_plunderLabel:getPositionY())
    end
end

-- 定位到某个坐标位子，是坐标位于可视范围内的中心
-- -- feedback: 定位到指定位置后，tile是否有动画反馈
function MineMap:locate(x, y, feedback)
    if x < 0 then x = 0 end
    if x > self.mapSize_.width - 1 then x = self.mapSize_.width - 1 end
    if y < 0 then y = 0 end
    if y > self.mapSize_.height - 1 then y = self.mapSize_.height - 1 end

    local pos = self.layerContainer_:getPositionAt(cc.p(x, y))
    local offset = cc.p(-pos.x + self:getContentSize().width / 2, -pos.y + self:getContentSize().height / 2 - self.tileSize_.height / 2)

    self:setContentOffset(offset)

    if feedback then
        local container = self.layerContainer_:getViewContainer(cc.p(x, y))
        -- local container = self.layerContainer_:getViewContainer(WorldMO.currentPos_)
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

function MineMap:getViewRect()
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

function MineMap:loadMap()
    if not self.m_tileUsed then return end

    for x, datas in pairs(self.m_tileUsed) do
        for y, tilePos in pairs(datas) do
            if x >= 0 and x < MILITARY_AREA_SIZE_WIDTH and y >= 0 and y < MILITARY_AREA_SIZE_HEIGHT then -- 地图范围内的
                local pos = cc.p(x, y)
                if not self.layerContainer_:hasLoadAt(pos) then
                    self.layerContainer_:loadTileAt(pos)
                else
                    self.layerContainer_:reloadTileAt(pos)
                end
            end
        end
    end
end

function MineMap:setContentOffset(offset)
    local newPos = offset
    local newCenterPos = cc.p(-newPos.x + self:getContentSize().width / 2, -newPos.y + self:getContentSize().height / 2)
    local newCenterTilePos = self.layerContainer_:getTilePositionAt(newCenterPos)

    -- print("pos:" .. newCenterTilePos.x, newCenterTilePos.y, "offset:" .. offset.x, offset.y)

    if newCenterTilePos.x < 0 or newCenterTilePos.x > (MILITARY_AREA_SIZE_WIDTH - 1)
        or newCenterTilePos.y < 0 or newCenterTilePos.y > (MILITARY_AREA_SIZE_HEIGHT - 1) then
        Toast.clear()
        Toast.show(CommonText[10046])  -- 矿区尽头
        return
    end

    self.layerContainer_:setPosition(offset)

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

        if use[tilePos.x] then use[tilePos.x][tilePos.y] = nil end

        if not self.m_tileUsed[tilePos.x] then self.m_tileUsed[tilePos.x] = {} end
        self.m_tileUsed[tilePos.x][tilePos.y] = tilePos
    end

    for x, datas in pairs(use) do  -- 将没有使用的tile清除
        for y, tilePos in pairs(datas) do
            self.layerContainer_:removeTileAt(cc.p(x, y))
        end
    end

    use = nil

    for x, datas in pairs(self.m_tileUsed) do
        for y, tilePos in pairs(datas) do
            if not self.layerContainer_:hasLoadAt(cc.p(x, y)) then
                self.layerContainer_:loadTileAt(cc.p(x, y))
            end
        end
    end

    self:showCenter()
end

function MineMap:onTouch(event)
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
function MineMap:addTouchPoint(point)
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

function MineMap:deleteTouchPoint(point)
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

function MineMap:onTouchBegan(event)
    if not self:isVisible() then return false end

    -- if self.m_zoomHanlder then
    --     scheduler.unscheduleGlobal(self.m_zoomHanlder)
    --     self.m_zoomHanlder = nil
    -- end

    self.m_touchedTilePos = nil

    self.m_touches = {}

    -- gdump(self.m_touches, "[MineMap] onTouchBegan before")

    for id, point in pairs(event.points) do
        self:addTouchPoint(point)
    end

    local touches = self.m_touches

    -- gdump(self.m_touches, "[MineMap] onTouchBegan after")

    local rect = self:getViewRect()

    -- 滑动到可视范围外的不支持
    if not cc.rectContainsPoint(rect, cc.p(touches[1].x, touches[1].y)) then
        gprint("[MineMap] onTouch began not container point!!!")
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

    --     gprint("[MineMap] onTouchBegan 2点触控 ", touches[1].x, touches[1].y, touches[2].x, touches[2].y)
    end
    return true
end

function MineMap:onTouchAdded(event)
    if not self:isVisible() then return end
    -- gdump(event, "[MineMap] onTouchAdded event")

    -- if self.m_zoomHanlder then
    --     scheduler.unscheduleGlobal(self.m_zoomHanlder)
    --     self.m_zoomHanlder = nil
    -- end

    gprint("self.m_multiTouchEnabled:", self.m_multiTouchEnabled)
    if not self.m_multiTouchEnabled then return end  -- 不支持多点

    for id, point in pairs(event.points) do
        self:addTouchPoint(point)
    end

    -- gdump(self.m_touches, "[MineMap] onTouchAdded touches")

    -- 是多点触控
    self.m_touchedCell = nil
    self.m_touchedCellIndex = 0

    local touches = self.m_touches

    if #touches == 2 then
        self.m_touchLength = cc.PointDistance(cc.p(touches[1].x, touches[1].y), cc.p(touches[2].x, touches[2].y))
        self.m_dragging = false

        -- gprint("[MineMap] onTouchAdded 2点触控 ", touches[1].x, touches[1].y, touches[2].x, touches[2].y, "len:", self.m_touchLength)
    elseif #touches > 2 or self.m_touchMoved or not cc.rectContainsPoint(rect, cc.p(touches[1].x, touches[1].y)) then
        -- 多于两指不支持
        -- 滑动到可视范围外的不支持
        gprint("[MineMap] onTouch began not container point!!!")
        return false
    end
end

function MineMap:onTouchMoved(event)
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
        -- -- gdump(event, "[MineMap] onTouchMoved 2点滑动")
        -- local point1 = event.points[self.m_touches[1].id]
        -- local point2 = event.points[self.m_touches[2].id]
        -- local len = cc.PointDistance(cc.p(point1.x, point1.y), cc.p(point2.x, point2.y))
        -- self:setZoomScale(self:getZoomScale() * len / self.m_touchLength)
        -- self.m_touchLength = len -- 更新长度
    end
end

function MineMap:onTouchRemoved(event)
    if not self:isVisible() then return end

    if not self.m_multiTouchEnabled then return end  -- 不支持多点

    -- gdump(event, "[MineMap] onTouchRemoved")

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

function MineMap:onTouchEnded(event)
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

        --     -- -- dump(rect, "MineMap:onTouchEnded")
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

function MineMap:onTouchCancelled(event)
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

function MineMap:tileHighlight(tilePos)
    -- local x = tilePos.x % MINE_SIZE_WIDTH
    -- local y = tilePos.y % MINE_SIZE_HEIGHT
    -- local offset = math.floor(tilePos.x / MINE_SIZE_WIDTH) + math.floor(tilePos.y / MINE_SIZE_HEIGHT) * (WORLD_SIZE_WIDTH / MINE_SIZE_WIDTH)
    -- local minPos = (x + y * MINE_SIZE_WIDTH + MINE_OFFSET_SEED * offset) % 1600

    -- gprint("tx:", tilePos.x, "ty:", tilePos.y, "index", tileIndex, "mine:", minPos)
end

function MineMap:tileUnhighlight(tilePos)
    -- self.m_touchedTilePos
end

function MineMap:tileTouched(tilePos)
    ManagerSound.playNormalButtonSound()

    -- gprint("MineMap touch:", tilePos.x, tilePos.y)
    if tilePos.x < 0 or tilePos.x > self.mapSize_.width - 1
        or tilePos.y < 0 or tilePos.y > self.mapSize_.height - 1 then
        return
    end

    local function click()
        local MilitaryMineDialog = require("app.dialog.MilitaryMineDialog")
        MilitaryMineDialog.new(tilePos.x, tilePos.y):push()
    end

    local function showClickEffectAndClick(btmView, colorView)
        btmView:stopAllActions()
        if colorView then
            colorView:setColor(cc.c3b(255, 255, 255))
        end

        if btmView.choseView_ then
            btmView.choseView_:removeSelf()
            btmView.choseView_ = nil
        end

        cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")

        local view = nil
        if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
            view = display.newSprite("#tile_3.png"):addTo(btmView, -1)
        else
            view = display.newSprite("image/world/tile_3.png"):addTo(btmView, -1)
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

    local container = self.layerContainer_:getViewContainer(tilePos)
    if container then
        showClickEffectAndClick(container, container.view_)
    else
        click()
    end
end

function MineMap:showCenter()
    if not self.centerView_ then
        self.centerView_ = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(self, 1000)
        self.centerView_:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)

        local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = self.centerView_:getContentSize().width / 2, y = self.centerView_:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(self.centerView_)
        self.centerView_.label_ = label
    end

    local pos = cc.p(math.abs(self.layerContainer_:getPositionX() - self:getContentSize().width / 2), math.abs(self.layerContainer_:getPositionY() - self:getContentSize().height / 2))
    local tilePos = self.layerContainer_:getTilePositionAt(pos)
    self.centerView_.label_:setString("(" .. tilePos.x .. "," .. tilePos.y .. ")")
end

return MineMap
