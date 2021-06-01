
-- 跨服军事矿区

local CrossServerMineLayer = class("CrossServerMineLayer", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function CrossServerMineLayer:ctor(tileMap)
	self.layerName_ = "MineLayer1"

	self.layerSize_ = tileMap.mapSize_
	self.tileSize_  = tileMap.tileSize_

    local size = cc.size(self.layerSize_.width * self.tileSize_.width, self.layerSize_.height * self.tileSize_.height)
    self:setContentSize(size)

    cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")

    self.m_tickHandler = ManagerTimer.addTickListener(handler(self, self.onTick))

    self.batchNode1_ = display.newBatchNode("image/world/tile_2.png", 50):addTo(self, -GAME_INVALID_VALUE)
    self.batchNode2_ = display.newBatchNode("image/world/tile_1.png", 50):addTo(self, -GAME_INVALID_VALUE)
    self.batchContainer_ = {}

    self.viewNode_ = display.newNode():addTo(self)
    self.viewContainer_ = {}
end

function CrossServerMineLayer:onExit()
    ManagerTimer.removeTickListener(self.m_tickHandler)

    armature_remove(IMAGE_ANIMATION .. "effect/ui_world_protect.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_world_protect.plist", IMAGE_ANIMATION .. "effect/ui_world_protect.xml")
end

function CrossServerMineLayer:onTick(dt)
    local curTime = ManagerTimer.getTime()

    for pos, mapData in pairs(StaffMO.CrossmapData_) do
        if mapData.freeTime < curTime then -- 保护时间到了
            local tilePos = StaffMO.decodeCrossPosition(pos)
            if self:hasTileAt(tilePos) then
                local node = self:getViewContainer(tilePos)
                if node.freeArmature then
                    node.freeArmature:removeSelf()
                    node.freeArmature = nil
                end
                if node.freeLabel then
                    node.freeLabel:removeSelf()
                    node.freeLabel = nil
                end
            end
        else  -- 还在保护时间内
            if mapData.my then  -- 是自己占领的矿
                local tilePos = StaffMO.decodeCrossPosition(pos)
                if self:hasTileAt(tilePos) then
                    local node = self:getViewContainer(tilePos)
                    if node.freeLabel then
                        node.freeLabel:setString(UiUtil.strBuildTime(mapData.freeTime - curTime))
                    end
                end
            end
        end
    end
end

function CrossServerMineLayer:getPositionAt(tilePos)
    return cc.p(self.tileSize_.width / 2 * (self.layerSize_.width + tilePos.x - tilePos.y),
            self.tileSize_.height / 2 * (tilePos.x + tilePos.y))
end

function CrossServerMineLayer:getTilePositionAt(pos)
    local x = pos.x - self:getContentSize().width / 2
    local y = pos.y

    local wx = x / self.tileSize_.width
    local wy = y / self.tileSize_.height

    return cc.p(math.floor(wx + wy), math.floor(-wx + wy))
end

function CrossServerMineLayer:getVertexZAt(tilePos)
	local maxZ = self.layerSize_.width + self.layerSize_.height
	return (maxZ - (tilePos.x + tilePos.y))
end

-- function MineLayer:getTileIndexByPos(tilePos)
-- 	return tilePos.x + tilePos.y * self.layerSize_.width
-- end

-- function MineLayer:getPosByTileIndex(tileIndex)
--     local pos = tileIndex
--     local x = pos % self.layerSize_.width
--     local y = math.floor(pos / self.layerSize_.width)
--     return cc.p(x, y)
-- end

function CrossServerMineLayer:getViewContainer(tilePos)
    if not self.viewContainer_[tilePos.x] then return nil end
    return self.viewContainer_[tilePos.x][tilePos.y]
end

function CrossServerMineLayer:createTileAt(tilePos)
    local position = self:getPositionAt(tilePos)

    if tilePos.x < 0 or tilePos.y < 0 or tilePos.x > (self.layerSize_.width - 1) or tilePos.y > (self.layerSize_.height - 1) then
        local land = display.newSprite("#tile_0.png"):addTo(self)
        land:setAnchorPoint(0.5, 0)
        land:setPosition(position.x, position.y)
        local order = self:getVertexZAt(tilePos)

        if tilePos.x >= 0 and tilePos.y >= 0 then land:setZOrder(order - 360000)
        else land:setZOrder(order) end
        return
    end

    local land = nil
    if (tilePos.x + tilePos.y) % 2 == 0 then
        land = display.newSprite(self.batchNode1_:getTexture(), position.x, position.y):addTo(self.batchNode1_)
    else
        land = display.newSprite(self.batchNode2_:getTexture(), position.x, position.y):addTo(self.batchNode2_)
    end
    land:setAnchorPoint(0.5, 0)

    local order = self:getVertexZAt(tilePos)
    land:setZOrder(order)

    if not self.batchContainer_[tilePos.x] then self.batchContainer_[tilePos.x] = {} end
    self.batchContainer_[tilePos.x][tilePos.y] = land

    local node = display.newNode():addTo(self.viewNode_, order)
    node:setPosition(position.x, position.y)
    node.load = false  -- 刚创建还没有加载

    if not self.viewContainer_[tilePos.x] then self.viewContainer_[tilePos.x] = {} end
    self.viewContainer_[tilePos.x][tilePos.y] = node
end

function CrossServerMineLayer:hasTileAt(tilePos)
    if not self.batchContainer_[tilePos.x] then return false end

    if self.batchContainer_[tilePos.x][tilePos.y] then return true
    else return false end
end

function CrossServerMineLayer:removeTileAt(tilePos)
    if not self.batchContainer_[tilePos.x] then return end

    local tile = self.batchContainer_[tilePos.x][tilePos.y]
    if tile then
        tile:removeSelf()
        self.batchContainer_[tilePos.x][tilePos.y] = nil
    end

    if self.viewContainer_[tilePos.x] then
        local node = self.viewContainer_[tilePos.x][tilePos.y]
        if node then
            node:stopAllActions()
            node:removeSelf()
            self.viewContainer_[tilePos.x][tilePos.y] = nil
        end
    end
end

function CrossServerMineLayer:hasLoadAt(tilePos)
    if tilePos.x < 0 or tilePos.y < 0 or tilePos.x > (self.layerSize_.width - 1) or tilePos.y > (self.layerSize_.height - 1) then
        return true
    end

    if not self.viewContainer_[tilePos.x] then
        error("CrossServerMineLayer hasLoadAt " .. tilePos.x)
    end
    local node = self.viewContainer_[tilePos.x][tilePos.y]
    if not node then return false end

    return node.load
end

function CrossServerMineLayer:reloadTileAt(tilePos)
   if tilePos.x < 0 or tilePos.x > self.layerSize_.width - 1
        or tilePos.y < 0 or tilePos.y > self.layerSize_.height - 1 then
        return
    end
    
    if not self.viewContainer_[tilePos.x] then error("CrossServerMineLayer reloadTileAt AA") end

    local node = self.viewContainer_[tilePos.x][tilePos.y]

    if not node then error("CrossServerMineLayer reloadTileAt BB") end

    node:stopAllActions()
    node:removeAllChildren()
    node.choseView_ = nil
    node.view_ = nil
    node.load = false

    self:loadTileAt(tilePos)
end

local function showFree(node, mapData, pos)
    local freeArmature = nil
    local freeLabel = nil

    local curTime = ManagerTimer.getTime()
    if curTime <= mapData.freeTime then  -- 处于保护中
        armature_add(IMAGE_ANIMATION .. "effect/ui_world_protect.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_world_protect.plist", IMAGE_ANIMATION .. "effect/ui_world_protect.xml")
        local armature = armature_create("ui_world_protect"):addTo(node, 2)
        armature:setAnchorPoint(cc.p(0.5, 0.5))
        armature:setPosition(pos.x, pos.y)
        armature:getAnimation():playWithIndex(0)
        armature:setScale(0.7)

        freeArmature = armature -- 保护免疫动画

        if mapData.my then  -- 只能看见自己的保护罩的倒计时
            local label = ui.newTTFLabel({text = UiUtil.strBuildTime(mapData.freeTime - curTime), font = G_FONT, size = FONT_SIZE_TINY, x = pos.x, y = pos.y - 60, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(node)
            freeLabel = label
        end
    end
    return freeArmature, freeLabel
end

local function createBuildLvView(buildLv)
    local lvBg = display.newSprite(IMAGE_COMMON .. "info_bg_55.png")

    -- 显示等级
    local lv = ui.newTTFLabel({text = buildLv, font = G_FONT, size = FONT_SIZE_LIMIT, x = lvBg:getContentSize().width / 2, y = lvBg:getContentSize().height / 2, color = cc.c3b(246, 217, 40), align = ui.TEXT_ALIGN_CENTER}):addTo(lvBg)
    lvBg.level_ = lv
    return lvBg
end

local function createBuildNameView(buildName, width)
    local titleBg = display.newNode()
    titleBg:setCascadeOpacityEnabledRecursively(true)

    local normal = nil
    local selected = nil
    -- if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
        normal = display.newScale9Sprite("image/screen/a_bg_5.png"):addTo(titleBg)
        selected = display.newScale9Sprite("image/screen/a_bg_6.png"):addTo(titleBg)
    -- else
    --     normal = display.newScale9Sprite("image/screen/b_bg_5.png"):addTo(titleBg)
    --     selected = display.newScale9Sprite("image/screen/b_bg_6.png"):addTo(titleBg)
    -- end
    titleBg.normal_ = normal
    selected:setVisible(false)
    titleBg.selected_ = selected

    local name = ui.newTTFLabel({text = buildName, font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
    titleBg.name_ = name

    local length = 0
    if width then length = width
    else length = math.max(name:getContentSize().width + 20, 54) end

    normal:setPreferredSize(cc.size(length, normal:getContentSize().height))
    selected:setPreferredSize(cc.size(length, selected:getContentSize().height))

    return titleBg
end

function CrossServerMineLayer:loadTileAt(tilePos)
    -- gdump(tilePos, "tilepos=====")
    if tilePos.x < 0 or tilePos.x > self.layerSize_.width - 1 or tilePos.y < 0 or tilePos.y > self.layerSize_.height - 1 then return end
    
    if not self.viewContainer_[tilePos.x] then error("CrossServerMineLayer loadTileAt 11") end

    local node = self.viewContainer_[tilePos.x][tilePos.y]

    if not node then error("CrossServerMineLayer loadTileAt 22") end

    node.load = true -- 加载了

    local mine = StaffBO.getCrossMineAt(tilePos)

    local sprite = UiUtil.createItemSprite(ITEM_KIND_MILITARY_MINE, mine.type):addTo(node)
    sprite:runAction(cc.FadeIn:create(0.2))
    node.view_ = sprite
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    sprite:setPosition(0, self.tileSize_.height / 2 + 10)
    local buildBtn = sprite

    local mapData = StaffMO.getCrossMapDataAt(tilePos.x, tilePos.y)

    if mapData then  -- 矿被占领了
        local nameView = createBuildNameView(mapData.name):addTo(buildBtn, 20)
        buildBtn.buildNameView = nameView

        nameView:setPosition(buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height + 15)
        if mapData.my then
            nameView.name_:setColor(COLOR[2])
        else
            nameView.name_:setColor(COLOR[12])
        end

        local lvView = createBuildLvView(mine.lv):addTo(buildBtn, 20)
        lvView:setPosition(nameView:getPositionX() - lvView:getContentSize().width / 2 - nameView.normal_:getContentSize().width / 2 + 8, nameView:getPositionY())
        buildBtn.buildLvView = lvView

        if mapData.party then -- 如果我自己有军团
            local tag = display.newSprite(IMAGE_COMMON .. "icon_party.png"):addTo(lvView)
            tag:setPosition(-tag:getContentSize().width / 2, lvView:getContentSize().height / 2)
        end

        local pos = ui.newTTFLabelWithShadow({text = "(" .. tilePos.x .. "," .. tilePos.y .. ")", font = G_FONT, size = FONT_SIZE_LIMIT, color = cc.c3b(255, 216, 0), align = ui.TEXT_ALIGN_CENTER}):addTo(node, 100)
        pos:setPosition(0, 55)

        local freeArmature, freeLabel = showFree(buildBtn, mapData, cc.p(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2 + 10))
        node.freeArmature = freeArmature
        node.freeLabel = freeLabel
    else
        local lvView = createBuildLvView(mine.lv):addTo(buildBtn)
        lvView:setPosition(buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height + 15)
        lvView.level_:setColor(cc.c3b(246, 217, 40))
        buildBtn.buildLvView = lvView
    end
end

return CrossServerMineLayer
