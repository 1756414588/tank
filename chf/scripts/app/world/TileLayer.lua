
local TileLayer = class("TileLayer", function()
    local node = display.newNode()
    nodeExportComponentMethod(node)
    node:setNodeEventEnabled(true)
    return node
end)
local UPDATE_NUM = 20 --画线刷新数量
local SPEED = 20 --线条速度
local ANGLE = {"part7","part6","part5","part4","part3","part2","start","part8"}

function TileLayer:ctor(tileMap)
    armature_add("animation/effect/tank_dir.pvr.ccz", "animation/effect/tank_dir.plist", "animation/effect/tank_dir.xml")
    armature_add(IMAGE_ANIMATION .. "ship/sj_feiting_piao.pvr.ccz", IMAGE_ANIMATION .. "ship/sj_feiting_piao.plist", IMAGE_ANIMATION .. "ship/sj_feiting_piao.xml")
    armature_add(IMAGE_ANIMATION .. "ship/sj_feiting_piao2.pvr.ccz", IMAGE_ANIMATION .. "ship/sj_feiting_piao2.plist", IMAGE_ANIMATION .. "ship/sj_feiting_piao2.xml")
    self.lines = {}
    self.layerName_ = "TileLayer1"

    self.layerSize_ = tileMap.mapSize_
    self.tileSize_  = tileMap.tileSize_

    local size = cc.size(self.layerSize_.width * self.tileSize_.width, self.layerSize_.height * self.tileSize_.height)
    self:setContentSize(size)

    cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")

    -- local view = display.newScale9Sprite(IMAGE_COMMON .. "icon_clock.png"):addTo(self)
    -- view:setContentSize(self:getContentSize())
    -- view:setAnchorPoint(cc.p(0, 0))

    -- self.batchNode_ = display.newNode():addTo(self)
    self.batchNode1_ = display.newBatchNode("image/world/tile_2.png", 50):addTo(self, -GAME_INVALID_VALUE)
    self.batchNode2_ = display.newBatchNode("image/world/tile_1.png", 50):addTo(self, -GAME_INVALID_VALUE)
    -- self.batchNodePoison = display.newBatchNode("image/world/tile_poison.png", 100):addTo(self, -GAME_INVALID_VALUE)
    self.batchContainer_ = {}


    self.viewNode_ = display.newNode():addTo(self)
    self.viewContainer_ = {}
    self.airShipContainer = {}
    self.skinActionResList = {}
    -- self.poisonFogContainer = {}

    self.m_tickCount = 0
    self.m_MineFreePos = {}
end

function TileLayer:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
    self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.showArmyLine))
    self.m_lineHandler = Notify.register(LOCAL_TANK_LINE, handler(self, self.showArmyLine))

    self.m_tickCount = 0
    self.m_MineFreePos = {}

    -- print("TileLayer:onEnter---------------------")
    -- print(debug.traceback())
end

function TileLayer:onEnterFrame(dt)
    for k,v in ipairs (self.lines) do
        local t = v.batch
        if #v.nums > 0 then
            for i = #v.nums,#v.nums - UPDATE_NUM,-1 do
                if v.nums[i] then
                    local line = display.newSprite(t:getTexture())
                        :addTo(t):align(display.RIGHT_CENTER,v.nums[i],v:height()/2)
                    local ex = v:width() - v.nums[i] + 16
                    line:runAction(transition.sequence({cc.MoveBy:create(ex/SPEED, cc.p(ex,0)), cc.CallFuncN:create(function()
                            line:removeSelf()
                        end)}))
                    if not v.firstLine then
                        v.ox = v.nums[i]
                        v.firstLine = line
                    end
                end
            end
            for i = #v.nums,#v.nums - UPDATE_NUM,-1 do
                table.remove(v.nums,i)
            end
        end
        if v.firstLine and v.firstLine:x() - v.ox >= 22 then
            local line = display.newSprite(t:getTexture())
                :addTo(t):align(display.RIGHT_CENTER,v.ox,v:height()/2)
            local ex = v:width() - v.ox + 16
            v.firstLine = line
            line:runAction(transition.sequence({cc.MoveBy:create(ex/SPEED, cc.p(ex,0)), cc.CallFuncN:create(function()
                    line:removeSelf()
                end)}))
        end
    end

    -- 每隔两分钟刷一下矿的状态
    self.m_tickCount = self.m_tickCount + dt
    if self.m_tickCount > 120 then
        self.m_tickCount = 0
        local positions = {}
        for x, rowData in pairs(self.m_MineFreePos) do
            for y, v in pairs(rowData) do
                if v == true then
                    table.insert(positions, {x=x, y=y})
                end
            end
        end
        WorldBO.asynGetMp(positions, true)
    end
end

function TileLayer:onExit()
    armature_remove(IMAGE_ANIMATION .. "effect/ui_world_protect.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_world_protect.plist", IMAGE_ANIMATION .. "effect/ui_world_protect.xml")
    armature_remove(IMAGE_ANIMATION .. "effect/ui_world_protect.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_world_protect.plist", IMAGE_ANIMATION .. "effect/ui_world_fortress_protect.xml")
    armature_remove("animation/effect/tank_dir.pvr.ccz", "animation/effect/tank_dir.plist", "animation/effect/tank_dir.xml")
    armature_remove(IMAGE_ANIMATION .. "ship/sj_feiting_piao.pvr.ccz", IMAGE_ANIMATION .. "ship/sj_feiting_piao.plist", IMAGE_ANIMATION .. "ship/sj_feiting_piao.xml")
    for k,v in pairs(self.skinActionResList) do
        armature_remove(v .. ".pvr.ccz", v .. ".plist", v .. ".xml")
    end
    self.airShipContainer = {}
    if self.m_armyHandler then
        Notify.unregister(self.m_armyHandler)
        self.m_armyHandler = nil
    end
    if self.m_lineHandler then
        Notify.unregister(self.m_lineHandler)
        self.m_lineHandler = nil
    end
end

function TileLayer:getPositionAt(tilePos)
    return cc.p(self.tileSize_.width / 2 * (self.layerSize_.width + tilePos.x - tilePos.y),
            self.tileSize_.height / 2 * (tilePos.x + tilePos.y))
end

function TileLayer:getTilePositionAt(pos)
    local x = pos.x - self:getContentSize().width / 2
    local y = pos.y

    local wx = x / self.tileSize_.width
    local wy = y / self.tileSize_.height

    return cc.p(math.floor(wx + wy), math.floor(-wx + wy))
end

function TileLayer:getVertexZAt(tilePos)
    local maxZ = self.layerSize_.width + self.layerSize_.height
    return (maxZ - (tilePos.x + tilePos.y))
end

function TileLayer:getTileIndexByPos(tilePos)
    return tilePos.x + tilePos.y * self.layerSize_.width
end

function TileLayer:getPosByTileIndex(tileIndex)
    local pos = tileIndex
    local x = pos % self.layerSize_.width
    local y = math.floor(pos / self.layerSize_.width)
    return cc.p(x, y)
end

function TileLayer:getViewContainer(tilePos)
    if not self.viewContainer_[tilePos.x] then return nil end
    return self.viewContainer_[tilePos.x][tilePos.y]
end

function TileLayer:createTileAt(tilePos)
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

    local order = 0
    if FortressBO.isInScope(tilePos) then  -- 如果是在要塞的范围的tile，所有的tile的order都是一样的
        order = self:getVertexZAt(cc.p(FortressMO.pos_.x - 1, FortressMO.pos_.y - 1))
        if tilePos.x == FortressMO.pos_.x and tilePos.y == FortressMO.pos_.y then
            order = order + 1
        end
        land:setZOrder(order)
    else
        order = self:getVertexZAt(tilePos)
        land:setZOrder(order)
    end

    if not self.batchContainer_[tilePos.x] then self.batchContainer_[tilePos.x] = {} end
    self.batchContainer_[tilePos.x][tilePos.y] = land

    local node = display.newNode():addTo(self.viewNode_, order)
    node:setPosition(position.x, position.y)
    node.load = false  -- 刚创建还没有加载

    if not self.viewContainer_[tilePos.x] then self.viewContainer_[tilePos.x] = {} end
    self.viewContainer_[tilePos.x][tilePos.y] = node
end

function TileLayer:hasTileAt(tilePos)
    if not self.batchContainer_[tilePos.x] then return false end

    if self.batchContainer_[tilePos.x][tilePos.y] then return true
    else return false end
end

function TileLayer:removeTileAt(tilePos)
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

    -- if self.poisonFogContainer[tilePos.x] then
    --     local node = self.poisonFogContainer[tilePos.x][tilePos.y]
    --     if node then
    --         node:stopAllActions()
    --         node:removeSelf()
    --         self.poisonFogContainer[tilePos.x][tilePos.y] = nil
    --     end
    -- end
end

function TileLayer:hasLoadAt(tilePos)
    if tilePos.x < 0 or tilePos.y < 0 or tilePos.x > (self.layerSize_.width - 1) or tilePos.y > (self.layerSize_.height - 1) then
        return true
    end

    if not self.viewContainer_[tilePos.x] then
        error("TileLayer hasLoadAt")
    end
    local node = self.viewContainer_[tilePos.x][tilePos.y]
    if not node then return false end

    return node.load
end

-- 比较当前位置tilePos的view和数据，如果有不一致则返回false，需要重新加载；否则返回true，不需要重新加载
function TileLayer:compareView(tilePos)
    if tilePos.x < 0 or tilePos.x > self.layerSize_.width - 1 or tilePos.y < 0 or tilePos.y > self.layerSize_.height - 1 then return true end
    if FortressBO.isInScope(tilePos) then return false end
    if tilePos.x == WorldMO.pos_.x and tilePos.y == WorldMO.pos_.y then return true end  -- 玩家自己


    local node = self.viewContainer_[tilePos.x][tilePos.y]

    if not node.view_ then return false end

    local mine = WorldBO.getMineAt(tilePos)
    if mine then  -- 所在位置是资源
        if not node.data_ then return false end

        if node.data_.type == mine.type and node.data_.lv == mine.lv then
            -- local mine = WorldMO.getMineAt(tilePos.x, tilePos.y)
            -- if (not mine and table.isexist(node.data_, "mine")) or (mine and (not table.isexist(node.data_, "mine") or (node.data_.mine.qua ~= mine.qua or node.data_.mine.mineId ~= mine.mineId))) then
            --     return false
            -- end
            -- local status = WorldBO.getPositionStatus(tilePos)
            if table.isexist(node.data_, "status") and status and (node.data_.status[ARMY_STATE_MARCH] == status[ARMY_STATE_MARCH] and node.data_.status[ARMY_STATE_COLLECT] == status[ARMY_STATE_COLLECT]) then
                local partyMine = WorldMO.getPartyMineAt(tilePos.x, tilePos.y)
                if (not node.data_.partyMine and not partyMine) or (node.data_.partyMine and partyMine) then
                    return true
                end
            end
        end
        return false
    end

    if mapData then
        if not node.data_ or node.data_.pros == nil or node.data_.prosMax == nil or node.data_.surface == nil or node.data_.name == nil or node.data_.free == nil or node.data_.lv == nil then return false end

        if node.data_.pros == mapData.pros and node.data_.prosMax == mapData.prosMax and node.data_.surface == mapData.surface and node.data_.name == mapData.name and node.data_.free == mapData.free and node.data_.lv == mapData.lv then
            local status = WorldBO.getPositionStatus(tilePos)
            if table.isexist(node.data_, "status") and status and (node.data_.status[ARMY_STATE_MARCH] == status[ARMY_STATE_MARCH] and node.data_.status[ARMY_STATE_COLLECT] == status[ARMY_STATE_COLLECT]) then
                local myParty = PartyBO.getMyParty()
                if (not node.data_.myParty and not myParty) or (node.data_.myParty and myParty and node.data_.myParty.partyName == myParty.partyName) then
                    return true
                end
            end
        end
        return false
    end
end

function TileLayer:reloadTileAt(tilePos)
   if tilePos.x < 0 or tilePos.x > self.layerSize_.width - 1
        or tilePos.y < 0 or tilePos.y > self.layerSize_.height - 1 then
        return
    end
    
    if not self.viewContainer_[tilePos.x] then error("TileLayer reloadTileAt AA") end

    local node = self.viewContainer_[tilePos.x][tilePos.y]

    if not node then error("TileLayer reloadTileAt BB") end

    node:stopAllActions()
    node:removeAllChildren()
    node.choseView_ = nil
    node.view_ = nil
    node.load = false

    -- if self.poisonFogContainer[tilePos.x] then
    --     local node = self.poisonFogContainer[tilePos.x][tilePos.y]
    --     if node then
    --         node:stopAllActions()
    --         node:removeAllChildren()
    --         self.poisonFogContainer[tilePos.x][tilePos.y] = nil
    --     end
    -- end

    self:loadTileAt(tilePos)
end

function TileLayer:createSurface(surface, level)
    if surface and surface > 0 then
        if surface == 7 then
            return display.newSprite("image/skin/base/w_r_5_2.png")--display.newSprite("#w_r_5_2.png")
        elseif surface > 2000 then
            if not self.skinActionResList[surface .. "_ac"] then
                self.skinActionResList[surface .. "_ac"] = "animation/skin/w_s_" .. surface .. "_action"
            end
            local node = display.newNode()
            node:setContentSize(cc.size(WORLD_TILE_WIDTH, WORLD_TILE_HEIGHT))
            armature_add(IMAGE_ANIMATION .. "skin/w_s_" .. surface .. "_action.pvr.ccz", IMAGE_ANIMATION .. "skin/w_s_" .. surface .. "_action.plist", IMAGE_ANIMATION .. "skin/w_s_" .. surface .. "_action.xml")
            local armature = armature_create("w_s_" .. surface .. "_action"):addTo(node, 2)
            armature:getAnimation():playWithIndex(0)
            armature:setAnchorPoint(cc.p(0.5, 0))
            armature:setPosition(node:width() * 0.5, 3)
            if surface == 2002 then
                armature:setPosition(node:width() * 0.5 + 10, 20)
            elseif surface == 2003 then
                armature:setPosition(node:width() * 0.5 + 25, 25)
            end
            return node
        else
            return display.newSprite("image/skin/base/" .. "w_s_" .. surface .. ".png")--display.newSprite("#w_s_" .. surface .. ".png")
        end
    else
        return UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, WORLD_ID_BUILD, {level = level})
    end
end

function TileLayer:showFree(node, mapData, pos)
    if mapData.free then -- 免战
        if mapData.surface and mapData.surface > 2000 then
            if mapData.surface == 2002 then 
                -- if mapData.surface == 2002 then 动态特殊处理
                local spfree = display.newSprite("image/skin/base/" .. "w_s_" .. mapData.surface .. "_shield.png"):addTo(node, 0)
                spfree:setAnchorPoint(cc.p(0.5, 0))
                spfree:setPosition(pos.x, 0)
            else -- 动态
                if not self.skinActionResList[mapData.surface .. "_sd"] then
                    self.skinActionResList[mapData.surface .. "_sd"] = "animation/skin/w_s_" .. mapData.surface .. "_shield"
                end
                armature_add(IMAGE_ANIMATION .. "skin/w_s_" .. mapData.surface .. "_shield.pvr.ccz", IMAGE_ANIMATION .. "skin/w_s_" .. mapData.surface .. "_shield.plist", IMAGE_ANIMATION .. "skin/w_s_" .. mapData.surface .. "_shield.xml")
                local armature = armature_create("w_s_" .. mapData.surface .. "_shield"):addTo(node, 2)
                armature:setAnchorPoint(cc.p(0.5, 0))
                armature:setPosition(pos.x, 0)
                armature:getAnimation():playWithIndex(0)
            end
        else
            armature_add(IMAGE_ANIMATION .. "effect/ui_world_protect.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_world_protect.plist", IMAGE_ANIMATION .. "effect/ui_world_protect.xml")
            local armature = armature_create("ui_world_protect"):addTo(node, 2)
            armature:setAnchorPoint(cc.p(0.5, 0.5))
            armature:setPosition(pos.x, pos.y + 30)
            armature:getAnimation():playWithIndex(0)
            -- armature:setScale(0.6)
        end
    end
end


function TileLayer:showMineFree(node, mapData, pos, tilePos)
    -- body
    local freeArmature = nil
    local freeLabel = nil

    local curTime = ManagerTimer.getTime()
    print("curTime!!", curTime)
    print("mapData.time!!", mapData.time)
    if curTime <= mapData.time then  -- 处于保护中
        armature_add(IMAGE_ANIMATION .. "effect/ui_world_protect.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_world_protect.plist", IMAGE_ANIMATION .. "effect/ui_world_protect.xml")
        local armature = armature_create("ui_world_protect"):addTo(node, 2)
        armature:setAnchorPoint(cc.p(0.5, 0.5))
        armature:setPosition(pos.x, pos.y + 30)
        armature:getAnimation():playWithIndex(0)

        if mapData.my then  -- 只能看见自己的保护罩的倒计时
            local label = ui.newTTFLabel({text = UiUtil.strBuildTime(mapData.time - curTime), font = G_FONT, size = FONT_SIZE_TINY, x = pos.x, y = pos.y - 60, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(node)
            freeLabel = label

            local function tick()
                local left = mapData.time - ManagerTimer.getTime()
                if left <= 0 then
                    freeLabel:stopAllActions()
                    left = 0
                    -- 抓取地图数据
                    WorldBO.asynGetMp({tilePos, }, true)
                end

                freeLabel:setString(UiUtil.strBuildTime(left))
            end
            freeLabel:schedule(tick, 1)
            tick() 
        end
    end
end

local function createRebelGiftNameView(rebelGift)
    local titleBg = display.newSprite(IMAGE_COMMON .. "gift_namebg.png")
    local name = ui.newTTFLabel({text = CommonText[1850] .. ":" .. rebelGift, font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
    name:setPosition(titleBg:width() * 0.5, titleBg:height() * 0.5)
    return titleBg
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

local function createBuildLvView(buildLv)
    local lvBg = display.newSprite(IMAGE_COMMON .. "info_bg_55.png")

    -- 显示等级
    local lv = ui.newTTFLabel({text = buildLv, font = G_FONT, size = FONT_SIZE_LIMIT, x = lvBg:getContentSize().width / 2, y = lvBg:getContentSize().height / 2, color = cc.c3b(246, 217, 40), align = ui.TEXT_ALIGN_CENTER}):addTo(lvBg)
    lvBg.level_ = lv
    return lvBg
end

function TileLayer:loadTileAt(tilePos)
    if tilePos.x < 0 or tilePos.x > self.layerSize_.width - 1 or tilePos.y < 0 or tilePos.y > self.layerSize_.height - 1 then return end
    
    if not self.viewContainer_[tilePos.x] then error("TileLayer loadTileAt 11") end

    local node = self.viewContainer_[tilePos.x][tilePos.y]

    if not node then error("TileLayer loadTileAt 22") end

    local mine = WorldBO.getMineAt(tilePos)
    if tilePos.x == FortressMO.pos_.x and tilePos.y == FortressMO.pos_.y then  -- 要塞
        local view = display.newSprite("image/world/tile_ys.png"):addTo(node)
        view:runAction(cc.FadeIn:create(0.2))
        view:setPosition(0, self.tileSize_.height / 2 + 50)
        node.view_ = view

        if FortressMO.inPeace() then --和平期
            if FortressBO.winParty_ and FortressBO.winParty_ ~= "" then
                local node = display.newNode()
                local l = UiUtil.label(FortressBO.winParty_)
                node:size(l:width()+25,23)
                l:addTo(node):align(display.RIGHT_CENTER, node:width(), node:height()/2)
                local t = display.newSprite(IMAGE_COMMON .. "name_bg.png")
                    :addTo(node,-1):center()
                t:setScaleX(node:width()/t:width())
                display.newSprite(IMAGE_COMMON .. "icon_capture_person.png")
                    :addTo(node):pos(5,node:height()/2)
                node:addTo(view,10):align(display.CENTER,view:width()/2,view:height())
                armature_add(IMAGE_ANIMATION .. "effect/ui_world_protect.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_world_protect.plist", IMAGE_ANIMATION .. "effect/ui_world_fortress_protect.xml")
                local armature = armature_create("ui_world_fortress_protect", 0, self.tileSize_.height / 2 + 50):addTo(view):pos(view:width()/2,view:height()/2)
                armature:getAnimation():playWithIndex(0)
            end
        elseif FortressMO.inWar() then --战争中
            local titleBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_68.png"):addTo(view)
            titleBg:setPosition(view:getContentSize().width / 2, 50)
            local title = ui.newTTFLabel({text = CommonText[20060], font = G_FONT, size = FONT_SIZE_MEDIUM, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
        else
            local titleBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_68.png"):addTo(view)
            titleBg:setPosition(view:getContentSize().width / 2, 50)
            local title = ui.newTTFLabel({text = CommonText[432], font = G_FONT, size = FONT_SIZE_MEDIUM, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
        end
        node.load = true -- 加载了
    elseif FortressBO.isInScope(tilePos) then  -- 在要塞的范围内，不显示其他的内容
        return
    elseif tilePos.x == WorldMO.pos_.x and tilePos.y == WorldMO.pos_.y then  -- 玩家自己
        local mapData = WorldMO.getMapDataAt(tilePos.x, tilePos.y)
        node.data_ = mapData
        -- gdump(mapData, "TileLayer loadTileAt")

        local level = WorldMO.getBuildLevelByProps(UserMO.getResource(ITEM_KIND_PROSPEROUS), UserMO.maxProsperous_, UserMO.ruins)

        local itemView = nil
        if mapData then itemView = self:createSurface(mapData.surface, level):addTo(node)
        else itemView = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, WORLD_ID_BUILD, {level = level}):addTo(node) end
        self:showRuins(itemView, UserMO.ruins, level, true)
        node.view_ = itemView
        itemView:setAnchorPoint(cc.p(0.5, 0.5))
        itemView:setPosition(0, self.tileSize_.height / 2)
        local buildBtn = itemView

        local nameView = createBuildNameView(UserMO.nickName_):addTo(buildBtn, 20)
        buildBtn.buildNameView = nameView

        nameView:setPosition(buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height + 15)
        nameView.name_:setColor(COLOR[2])

        local lvView = createBuildLvView(UserMO.level_):addTo(buildBtn, 20)
        lvView:setPosition(nameView:getPositionX() - lvView:getContentSize().width / 2 - nameView.normal_:getContentSize().width / 2 + 8, nameView:getPositionY())
        buildBtn.buildLvView = lvView

        -- 繁荣度进度条
        local bar = UiUtil.showProsBar(UserMO.getResource(ITEM_KIND_PROSPEROUS), UserMO.maxProsperous_):addTo(itemView, 20)
        bar:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height - 5)

        if mapData then
            self:showFree(buildBtn, mapData, cc.p(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2))
        end

        local pos = ui.newTTFLabelWithShadow({text = "(" .. tilePos.x .. "," .. tilePos.y .. ")", font = G_FONT, size = FONT_SIZE_LIMIT, color = cc.c3b(255, 216, 0), align = ui.TEXT_ALIGN_CENTER}):addTo(node, 100)
        pos:setPosition(0, 40)

        local endPos = cc.p(tilePos.x - 1, tilePos.y - 1)

        local myParty = PartyBO.getMyParty()
        if myParty then -- 如果我自己有军团
            local tag = display.newSprite(IMAGE_COMMON .. "icon_party.png"):addTo(lvView)
            tag:setPosition(-tag:getContentSize().width / 2, lvView:getContentSize().height / 2)
        end
        
        local Route = require("app.world.Route")
        local view = Route.new(tilePos, endPos):addTo(self.viewNode_, 50)
        view:setPosition(node:getPositionX(), node:getPositionY() + self.tileSize_.height / 2)

        node.load = true -- 加载了
    elseif mine then  -- 所在位置是资源
        node.data_ = clone(mine)
        -- print("loadTileAt tilePos.x!!!", tilePos.x)
        -- print("loadTileAt tilePos.y!!!", tilePos.y)

        local sprite = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, mine.type, {level = mine.lv}):addTo(node)
        sprite:runAction(cc.FadeIn:create(0.2))
        node.view_ = sprite
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setPosition(0, self.tileSize_.height / 2)
        local buildBtn = sprite
        local itemView = sprite

        -- 这里好像是矿等级
        local lvView = createBuildLvView(mine.lv):addTo(buildBtn)
        lvView:setPosition(buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height + 15)
        lvView.level_:setColor(cc.c3b(246, 217, 40))
        buildBtn.buildLvView = lvView

        local partyMine = WorldMO.getPartyMineAt(tilePos.x, tilePos.y)
        node.data_.partyMine = clone(partyMine)
        if partyMine and PartyBO.getMyParty() then  -- 是被军团成功占领
            local view = display.newSprite(IMAGE_COMMON .. "icon_capture_party.png"):addTo(sprite)
            view:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height + 70)
            view:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(0, -10)), cc.MoveBy:create(2, cc.p(0, 10))})))
        end

        local status = WorldBO.getPositionStatus(tilePos)
        node.data_.status = status
        if status[ARMY_STATE_MARCH] then -- 是要被打的
            local view = display.newSprite(IMAGE_COMMON .. "chose_2.png"):addTo(sprite, -1)
            view:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)
            view:setScale(0.6)
            view:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(3, 0.8), cc.ScaleTo:create(3, 0.6)})))
        end

        if status[ARMY_STATE_COLLECT] then -- 正在收集资源
            local view = display.newSprite(IMAGE_COMMON .. "icon_capture_person.png"):addTo(sprite)
            view:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height + 70)
            view:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(0, -10)), cc.MoveBy:create(2, cc.p(0, 10))})))
        end

        local data = WorldMO.getMineAt(tilePos.x, tilePos.y)
        node.data_.mine = data
        if data and data.qua > 1 then
            local flag = display.newSprite(IMAGE_COMMON.."mine_quality" .. WorldMO.queryMineQuality(data.qua).icon ..".png"):addTo(sprite)
                :align(display.LEFT_BOTTOM, sprite:width() - 10, sprite:height()/2 + 10):scale(0.6)
            if data.mineId > 0 then
                flag:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(1, cc.p(0, -10)), cc.MoveBy:create(1, cc.p(0, 10))})))
            end
        end

        node.load = true -- 加载了

        -- 判断一下是否免战
        local freeInfo = WorldMO.getWarFreeInfo(tilePos.x, tilePos.y)
        if freeInfo then
            gdump(freeInfo, "freeInfo==")
            self:showMineFree(buildBtn, freeInfo, cc.p(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2), tilePos)
        end

        if self.m_MineFreePos[tilePos.x] == nil then
            self.m_MineFreePos[tilePos.x] = {}
        end
        self.m_MineFreePos[tilePos.x][tilePos.y] = true
    elseif UserMO.queryFuncOpen(UFP_AIRSHIP) and AirshipMO.queryShip(WorldMO.encodePosition(tilePos.x,tilePos.y)) then
        --信息
        local ab = AirshipMO.queryShip(WorldMO.encodePosition(tilePos.x,tilePos.y))
        local data = AirshipBO.ships_ and AirshipBO.ships_[ab.id]

        local airshipRes = "sj_feiting_piao"
        if ab.id > 4 then
            airshipRes = "sj_feiting_piao2"
        end
        local view = armature_create(airshipRes, 0, self.tileSize_.height * 0.8)
        
        view:addTo(node)
        view:getAnimation():playWithIndex(0)
        view:setScale(0.7)
        node.view_ = view

        local name1,name2 = CommonText[108],CommonText[108]
        local color0 = cc.c3b(255, 255, 0)

        if data then
            local isRuins = data.base.ruins

            ----废墟状态
            if isRuins then
                armature_add(IMAGE_ANIMATION .. "ship/sj_feiting_baozha.pvr.ccz", IMAGE_ANIMATION .. "ship/sj_feiting_baozha.plist", IMAGE_ANIMATION .. "ship/sj_feiting_baozha.xml")
                local armature = armature_create("sj_feiting_baozha", 0, 0):addTo(view,2)--:center()
                armature:getAnimation():playWithIndex(0)   
            end

            ----战斗
            if data.base.attackCount and data.base.attackCount > 0 then
                armature_add(IMAGE_ANIMATION .. "ship/sj_feiting_daodan.pvr.ccz", IMAGE_ANIMATION .. "ship/sj_feiting_daodan.plist", IMAGE_ANIMATION .. "ship/sj_feiting_daodan.xml")
                local armature = armature_create("sj_feiting_daodan", 0, 0):addTo(view,2)--:center()
                armature:getAnimation():playWithIndex(0)   

                armature_add(IMAGE_ANIMATION .. "ship/sj_feiting_zdbs.pvr.ccz", IMAGE_ANIMATION .. "ship/sj_feiting_zdbs.plist", IMAGE_ANIMATION .. "ship/sj_feiting_zdbs.xml")
                local armature = armature_create("sj_feiting_zdbs", 0, 0):addTo(view,2)--:center()
                armature:getAnimation():playWithIndex(0)                                     
            end

            --判断防护罩
            if data.base.safeEndTime < 0 or ManagerTimer.getTime() < data.base.safeEndTime then
                armature_add(IMAGE_ANIMATION .. "effect/ui_world_protect.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_world_protect.plist", IMAGE_ANIMATION .. "effect/ui_world_fortress_protect.xml")
                local armature = armature_create("ui_world_fortress_protect", 0, self.tileSize_.height * 0.5):addTo(view,2)--:center()
                armature:setScale(0.8)
                armature:getAnimation():playWithIndex(0)
            end

            if data.occupy then
                -- 是否有军团信息
                if data.occupy.partyId > 0 then
                    name1 = data.occupy.partyName
                    name2 = data.occupy.lordName
                    -- 是否是己方军团
                    if PartyBO.getMyParty() and PartyMO.partyData_.partyId == data.occupy.partyId then
                        color0 = cc.c3b(0, 255, 0)

                        local detail = data.detail

                        --判断显示 生产
                        if table.isexist(detail, "produceTime") then
                            if isRuins then ---废墟状态,无法生产
                            else
                                --- 根据飞艇状态判断是否显示 ---
                                -- [收获]
                                local function doGain()
                                    ManagerSound.playNormalButtonSound()
                                    -- dump(data, "@====================doGain", 9)
                                    --是否可以领取物品
                                    if table.isexist(detail,"produceNum") and detail.produceNum > 0 then
                                        require_ex("app.dialog.LevyAirShipDialog").new(ab.id):push()
                                    else
                                        Toast.show(CommonText[1035])
                                    end                                    
                                end
                                -- [收获] 进度条
                                local showBar = ProgressBar.new(IMAGE_COMMON .. "ship/durable.png",BAR_DIRECTION_HORIZONTAL,cc.size(100, 9),{bgName = IMAGE_COMMON .. "ship/durablebg2.jpg", bgScale9Size = cc.size(105, 18)}):addTo(node)
                                    showBar:setAnchorPoint(cc.p(0,0.5))
                                    showBar:setPosition(0,self.tileSize_.height * 0.4)
                                local Labbg = display.newSprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(showBar)
                                    Labbg:setAnchorPoint(cc.p(0.3,0.6))
                                    Labbg:setPosition(0,23)
                                -- [收获] 倒计时
                                local showLab = UiUtil.label(""):addTo(showBar,2)
                                    showLab:setPosition(showBar:getContentSize().width*0.5,23)
                                -- [收获] 按钮
                                local gainBtn = ScaleButton.new(display.newSprite(IMAGE_COMMON.."ship/gain.png"),doGain):addTo(showBar,2)
                                    gainBtn:setPosition(-gainBtn:getContentSize().width*0.4,gainBtn:getContentSize().height*0.25)
                                    -- gainBtn:setEnabled(false)
                                --  --是否可以领取物品
                                -- if table.isexist(detail,"produceNum") and detail.produceNum > 0 then
                                --    gainBtn:setEnabled(true)
                                -- end
                                if table.isexist(detail,"produceNum") and detail.produceNum > 0 then
                                   -- gainBtn:setEnabled(true)
                                   local produceIcon = display.newSprite(IMAGE_COMMON .. "ship/airship_produce.jpg"):addTo(showBar, 2)
                                   display.newSprite(IMAGE_COMMON .. "ship/item_fame_5.png"):addTo(produceIcon):center()
                                   produceIcon:setScale(0.6)
                                   produceIcon:setPosition(-produceIcon:getContentSize().width*0.5-gainBtn:getContentSize().width*0.9, produceIcon:getContentSize().height*0.25)
                                end
                                                                
                                local function tick()
                                    local left = detail.produceTime - ManagerTimer.getTime()
                                    if left <= 0 then
                                        showLab:stopAllActions()
                                        left = 0
                                        if detail.produceNum < ab.capacity then
                                            AirshipBO.getAirship(function ()
                                                -- body
                                                Notify.notify(LOCAL_GET_MAP_EVENT)
                                            end, data.base.id)
                                        end
                                    end

                                    showLab:setString(UiUtil.strBuildTime(left))
                                end
                                showLab:schedule(tick, 1)
                                tick() 
                            end
                        end
                    else
                        color0 = cc.c3b(255, 0, 0)
                    end
                end
            end
        end

        local lab1 = UiUtil.label(CommonText[1003][1]..name1,20,color0):addTo(node,12):pos(0, self.tileSize_.height*1.8 + 36) -- 军团
        local lab2 = UiUtil.label(CommonText[51]..":"..name2,20,color0):addTo(node,12):pos(0, self.tileSize_.height*1.8 + 16) -- 指挥官
        local lab3 = UiUtil.label(ab.name.."("..ab.level..")",20,cc.c3b(255,255,255)):addTo(node,12):pos(0, self.tileSize_.height*1.8 + 56) -- 飞艇.名字.等级
        local width1 = lab1:getContentSize().width
        local width2 = lab2:getContentSize().width
        local width3 = lab3:getContentSize().width
        if width1 < width2 then width1 = width2 end
        if width1 < width3 then width1 = width3 end
        
        local info = display.newScale9Sprite(IMAGE_COMMON.."an.png"):addTo(node,10):align(display.CENTER_BOTTOM, 0, self.tileSize_.height*1.8)
        if (width1 + 20) > info:getContentSize().width then
            info:setPreferredSize(cc.size(width1 + 20, info:getContentSize().height * 1.25))
        else
            info:setPreferredSize(cc.size(info:getContentSize().width, info:getContentSize().height * 1.25))
        end

        local pos = ui.newTTFLabelWithShadow({text = "(" .. tilePos.x .. "," .. tilePos.y .. ")", font = G_FONT, size = FONT_SIZE_LIMIT, color = cc.c3b(255, 216, 0), align = ui.TEXT_ALIGN_CENTER}):addTo(node, 100)
        pos:setPosition(0, 40)

        node.load = true -- 加载了
    else
        node:stopAllActions()
        node:removeAllChildren()

        local mapData = WorldMO.getMapDataAt(tilePos.x, tilePos.y)
        if mapData then
            node.data_ = clone(mapData)
            local isRebel = false
            local itemView = nil
            local name = mapData.name
            if table.isexist(mapData, "heroPick") then -- 叛军
                isRebel = true
                if mapData.heroPick == -2 then --剿匪行动
                    local data = RebelMO.getTeamById(mapData.surface)
                    name = data.name
                    itemView = display.newNode():size(320,160):addTo(node, 10)
                    local x,y,ex,ey = 150,itemView:height() - 50,33,25
                    for i=1,6 do
                        local id,count = data["team"..i .."Id"],data["team"..i .."number"]
                        if id > 0 and count > 0 then
                            local tank = display.newSprite("image/tank/tank_"..id ..".png"):addTo(itemView):scale(0.5)
                            local tx,ty = x + (i-1)%3*ex - math.floor((i-1)/3)*50  ,y - math.floor((i-1)/3)*ey - (i-1)%3*15
                            tank:pos(tx,ty)
                        end
                    end
                else
                    local rd = RebelMO.queryHeroById(mapData.heroPick)
                    name = HeroMO.queryHero(rd.associate).heroName
                    -- itemView = UiUtil.createItemSprite(ITEM_KIND_TANK,RebelMO.getShowTank(mapData.surface)):addTo(node)
                    local name = "panjun"..rd.teamType
                    armature_add("animation/effect/"..name..".pvr.ccz", "animation/effect/"..name..".plist", "animation/effect/"..name..".xml")
                    itemView = armature_create(name):addTo(node, 10)
                    itemView:getAnimation():playWithIndex(0)
                end
            elseif table.isexist(mapData, "rebelGift") then -- 叛军礼盒 先不添加0判断
                itemView = display.newSprite(IMAGE_COMMON .. "gift.png"):addTo(node, 10)
            else
                local level = WorldMO.getBuildLevelByProps(mapData.pros, mapData.prosMax, mapData.ruins)
                itemView = self:createSurface(mapData.surface, level):addTo(node)
                self:showRuins(itemView, mapData.ruins, level)
            end
            itemView:runAction(cc.FadeIn:create(0.2))
            node.view_ = itemView
            itemView:setAnchorPoint(cc.p(0.5, 0.5))
            itemView:setPosition(0, self.tileSize_.height / 2)
            itemView:runAction(cc.FadeIn:create(0.2))

            local buildBtn = itemView

            if table.isexist(mapData, "rebelGift") then -- 礼盒
                local nameView = createRebelGiftNameView(mapData.rebelGift):addTo(buildBtn, 20)
                buildBtn.buildNameView = nameView

                nameView:setPosition(buildBtn:width() * 0.5, buildBtn:height() + nameView:height() * 0.5)
            else
                local nameView = createBuildNameView(name):addTo(buildBtn, 20)
                buildBtn.buildNameView = nameView

                nameView:setPosition(buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height + 15)
                nameView.name_:setColor(COLOR[12])
                if table.isexist(mapData, "heroPick") then
                    if mapData.heroPick ~= -2 then
                        nameView:pos(0,70)
                    else
                        nameView:y(buildBtn:getContentSize().height/2 + 50)
                    end
                end

                local lvView = createBuildLvView(mapData.lv):addTo(buildBtn, 20)
                lvView:setPosition(nameView:getPositionX() - lvView:getContentSize().width / 2 - nameView.normal_:getContentSize().width / 2 + 8, nameView:getPositionY())
                buildBtn.buildLvView = lvView

                local myParty = PartyBO.getMyParty()
                node.data_.myParty = clone(myParty)
                if myParty then -- 如果我自己有军团
                    if mapData.party and mapData.party == myParty.partyName then  -- 和自己是同一个军团标记
                        local tag = display.newSprite(IMAGE_COMMON .. "icon_party.png"):addTo(lvView)
                        tag:setPosition(-tag:getContentSize().width / 2, lvView:getContentSize().height / 2)
                    end
                end

                if not isRebel then
                    -- 繁荣度进度条
                    local bar = UiUtil.showProsBar(mapData.pros, mapData.prosMax):addTo(itemView, 20)
                    bar:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height - 5)

                    self:showFree(buildBtn, mapData, cc.p(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2))

                    local status = WorldBO.getPositionStatus(tilePos)
                    node.data_.status = status

                    if status[ARMY_STATE_MARCH] then   -- 是要被打的
                        local view = display.newSprite(IMAGE_COMMON .. "chose_2.png"):addTo(itemView, -1)
                        view:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2)
                        view:setScale(0.6)
                        view:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(3, 0.8), cc.ScaleTo:create(3, 0.6)})))
                    end
                end
            end

            local pos = ui.newTTFLabelWithShadow({text = "(" .. tilePos.x .. "," .. tilePos.y .. ")", font = G_FONT, size = FONT_SIZE_LIMIT, color = cc.c3b(255, 216, 0), align = ui.TEXT_ALIGN_CENTER}):addTo(node, 100)
            pos:setPosition(0, 40)

            node.load = true -- 加载了
        else
            -- 判断是否是地形
            local environment = WorldBO.getEnvironmentAt(tilePos)
            if environment then
                local view = display.newSprite("#w_e_" .. environment[1] .. "_" .. environment[2] .. ".png"):addTo(node)
                view:setPosition(0, self.tileSize_.height / 2)
                node.view_ = view
            end
        end
    end

    -- 查询是否在安全区内
    -- if node.view_ then
    --     if RoyaleSurviveBO.IsInSafeArea(tilePos) == false then
    --         local position = self:getPositionAt(tilePos)
    --         local fog = display.newSprite(self.batchNodePoison:getTexture(), position.x, position.y):addTo(self.batchNodePoison)
    --         fog:setAnchorPoint(0.5, 0)
    --         local order = node:getZOrder()
    --         fog:setZOrder(order + 1)
    --         if self.poisonFogContainer[tilePos.x] == nil then
    --             self.poisonFogContainer[tilePos.x] = {}
    --         end
    --         self.poisonFogContainer[tilePos.x][tilePos.y] = fog
    --     end
    -- end
end

function TileLayer:showRuins(item,ruins,level)
    if level ~= 0 then return end
    --废墟加白棋
    if ruins and ruins.isRuins == true then
        local node = display.newNode()
        local l = UiUtil.label(ruins.attackerName,FONT_SIZE_LIMIT)
        node:size(l:width()+25,23)
        l:addTo(node):align(display.RIGHT_CENTER, node:width(), node:height()/2)
        local t = display.newSprite(IMAGE_COMMON .. "name_bg.png")
            :addTo(node,-1):center()
        t:setScaleX(node:width()/t:width())
        display.newSprite(IMAGE_COMMON .. "white_flag.png")
            :addTo(node):pos(5,node:height()/2)
        node:addTo(item):align(display.CENTER_BOTTOM,item:width()/2,item:height()+35)
    end
end

function TileLayer:showArmyLine()
    if not UserMO.showArmyLine then
        for k,v in ipairs(self.lines) do
            v:removeSelf()
        end
        self.lines = {}
        return
    end


    local armys = clone(ArmyMO.army_)
    local defArmys = {}
    for k,v in pairs(armys) do 
        local army = v
        if not defArmys[army.target] then
            defArmys[army.target] = {}
            defArmys[army.target][1] = {num = 0, army = nil} -- 回
            defArmys[army.target][2] = {num = 0, army = nil} -- 去
        end
        local state = army.state
        if not v.isMilitary and 
            state == ARMY_STATE_RETURN or -- 返回
            state == ARMY_STATE_MARCH or -- 行军
            state == ARMY_STATE_AID_MARCH or -- 援助行军
            state == ARMY_AIRSHIP_MARCH or --飞艇部队 行军中
            state == ARMY_AIRSHIP_GUARD_MARCH then --飞艇部队 驻防行军中
            local _state = 2
            if state == ARMY_STATE_RETURN then _state = 1 end
            defArmys[army.target][_state].num = defArmys[army.target][_state].num + 1
            if not defArmys[army.target][_state].army then
                defArmys[army.target][_state].army = army
            end
        end
    end

    for k = #self.lines,1,-1 do
        local v = self.lines[k]
        local target = v.target
        local state = v.state
        if not defArmys[target] or 
            (state == ARMY_STATE_RETURN and defArmys[target][1].num == 0) or 
            (state ~= ARMY_STATE_RETURN and defArmys[target][2].num == 0) then
            v:removeSelf()
            table.remove(self.lines,k)
        else
            local _state = 2
            if state == ARMY_STATE_RETURN then _state = 1 end
            defArmys[target][_state].army = nil
        end
    end

    local needUpdate = {}
    for k,v in pairs(defArmys) do 
        for k1,v1 in pairs(v) do
            if v1.army then
                table.insert(needUpdate,v1.army)
            end
        end
    end 
    ---------------------------------

    -- local armys = clone(ArmyMO.army_)
    -- dump(armys, "@^^^armys^^^^" .. table.nums(armys))
    -- print("showArmyLine " .. #armys)
    -- for k = #self.lines,1,-1 do
    --     local v = self.lines[k]
    --     if not armys[v.keyId] or armys[v.keyId].state ~= v.state then
    --         v:removeSelf()
    --         table.remove(self.lines,k)
    --     else
    --         armys[v.keyId] = nil
    --     end
    -- end
    local myPos = self:getPositionAt(WorldMO.pos_)
    -- local needUpdate = {}
    -- local ownerPos = WorldMO.encodePosition(WorldMO.pos_.x,WorldMO.pos_.y)
    -- for k,v in pairs(armys) do
    --     if v.target and v.state ~= ARMY_STATE_FORTRESS and not v.isMilitary then
    --         table.insert(needUpdate,v)
    --     end
    -- end
    local index = 1
    local speed = 40
    local function showLine()
        if index > #needUpdate then return end
        local army = needUpdate[index]
        local pos = self:getPositionAt(WorldMO.decodePosition(army.target))
        local len = ccpDistance(myPos,pos)
        local node = display.newNode():size(len,1)
        node.keyId = army.keyId
        node.state = army.state
        node.target = army.target
        table.insert(self.lines,node)
        --更新数量
        local line = {}
        local num = {}
        local width = 0
        while width < len do
            table.insert(num,len - width)
            width = width + 22
        end
        node.nums = num
        node.batch = display.newBatchNode(IMAGE_COMMON.."line.png",#num+8):addTo(node)
        -- for k,v in ipairs (num) do
        --     local line = display.newSprite(t:getTexture())
        --         :addTo(t):align(display.RIGHT_CENTER,v,node:height()/2)
        --     local ex = len - v + line:width()
        --     line:runAction(transition.sequence({cc.MoveBy:create(ex/speed, cc.p(ex,0)), cc.CallFuncN:create(function()
        --             line:removeSelf()
        --         end)}))
        -- end
        -- node:performWithDelay(function()
        --         local line = display.newSprite(t:getTexture())
        --             :addTo(t):align(display.RIGHT_CENTER,0,node:height()/2)
        --         local ex = line:width() + len
        --         line:runAction(transition.sequence({cc.MoveBy:create(ex/speed, cc.p(ex,0)), cc.CallFuncN:create(function()
        --                 line:removeSelf()
        --             end)}))
        --     end, (22)/speed, 1)
        local r = 0
        if army.state == ARMY_STATE_RETURN then
            node:addTo(self.viewNode_,1000000):align(display.LEFT_CENTER,pos.x,pos.y + self.tileSize_.height / 2)
            r = 180 - math.deg(math.atan2(pos.y-myPos.y,pos.x-myPos.x))
        else
            node:addTo(self.viewNode_,1000000):align(display.LEFT_CENTER,myPos.x,myPos.y + self.tileSize_.height / 2)
            r = - math.deg(math.atan2(pos.y-myPos.y,pos.x-myPos.x))
        end
        if army.state == ARMY_STATE_MARCH or army.state == ARMY_STATE_RETURN or army.state == ARMY_STATE_AID_MARCH then --显示行军坦克
            local leftTime = SchedulerSet.getTimeById(army.schedulerId)
            local percent = 0
            if army.period == 0 then
                percent = 1
            else
                percent = (army.period - leftTime) / army.period
                local tank = armature_create("tank_dir",len*percent,node:height()/2):addTo(node)
                local div = math.abs(math.floor(r/45))
                if r < 0 then div = #ANGLE - div end
                if math.abs(r%45) > 45/2 then
                    div = div + 1 
                end
                tank:rotation(-r)
                tank:getAnimation():play(ANGLE[div%#ANGLE + 1])
                tank:runAction(transition.sequence({cc.MoveBy:create(leftTime, cc.p(len*(1-percent),0)), cc.CallFuncN:create(function()
                        tank:removeSelf()
                    end)}))
            end
        end
        node:setRotation(r)
        index = index + 1
        showLine()
    end
    showLine()

end


function TileLayer:clearMineFreePos()
    -- body
    self.m_MineFreePos = {}
end

return TileLayer
