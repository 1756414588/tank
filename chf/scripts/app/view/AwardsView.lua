
-- 界面下方的奖励条

local AwardsView = class("AwardsView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

local instance_ = nil

-- levelUp: 是否是升级
-- bar: 显示奖励条
function AwardsView:ctor(awards, levelUp, bar)
    self.m_awards = {}
    self.m_awardFame = nil -- 声望奖励
    self.m_awardExp = nil -- 经验奖励
    self.m_awardPower = nil -- 能量奖励

    for index = 1, #awards do
        if awards[index].kind == ITEM_KIND_FAME then  -- 声望
            if not self.m_awardFame then self.m_awardFame = awards[index]
            else self.m_awardFame.count = self.m_awardFame.count + awards[index].count end
        elseif awards[index].kind == ITEM_KIND_EXP then  -- 经验
            

            --拇指广告经验加成
            if ServiceBO.muzhiAdPlat() and MuzhiADMO.ExpAddADTime > 0 then
                awards[index].count = math.floor(awards[index].count * (1 + MuzhiADMO.ExpAddADTime * MZAD_EXPADD_FACTOR / 100))
            end


            if not self.m_awardExp then self.m_awardExp = awards[index]
            else self.m_awardExp.count = self.m_awardExp.count + awards[index].count end
        elseif awards[index].kind == ITEM_KIND_POWER then -- 能量
            if not self.m_awardPower then self.m_awardPower = awards[index]
            else self.m_awardPower.count = self.m_awardPower.count + awards[index].count end
        else
            self.m_awards[#self.m_awards + 1] = awards[index]
        end
    end

    self.m_showLevelUp = levelUp

    -- self.m_showBar = bar
end

function AwardsView:onEnter()
    self:setContentSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
    self:setAnchorPoint(cc.p(0.5, 0.5))

    gdump(self.m_awards, "AwardsView:onEnter")

    -- if self.m_showBar then
    --     self:showAwardBar()
    --     if self.m_showLevelUp then
    --         self:showLevelUp()
    --     end

    --     self:runAction(transition.sequence({cc.DelayTime:create(1), cc.CallFuncN:create(function()
    --             self:showFload()
    --         end), cc.DelayTime:create(8), cc.CallFuncN:create(function()
    --             self:removeSelf()
    --         end)}))
    -- else

    local function closeView()
        self:removeSelf()
    end

        if self.m_showLevelUp then
            self:showLevelUp()
            self:runAction(transition.sequence({cc.DelayTime:create(1),  -- 延迟点时间用来显示升级
                cc.CallFuncN:create(function()
                    self:showFload(closeView)
                end)
                -- , cc.DelayTime:create(10), cc.CallFuncN:create(function()
                    -- self:removeSelf()
                -- end)
            }))
        else
            self:runAction(transition.sequence({cc.CallFuncN:create(function()
                    self:showFload(closeView)
                end)
            -- , cc.DelayTime:create(10), cc.CallFuncN:create(function()
                    -- self:removeSelf()
                -- end)
                }))
        end
    -- end
end

function AwardsView:onExit()
    gprint("AwardsView.onExit()")
    instance_ = nil
end

-- local FLOAT_NUM = 3 -- 每组最多显示数量
local FLOAT_NUM = 4

-- 显示空中漂浮的奖励
function AwardsView:showFload(callback)
    -- local function show()
    --     if self.m_floatNode then
    --         self.m_floatNode:removeSelf()
    --         self.m_floatNode = nil
    --     end

    --     if self.m_floatIndex > math.ceil(#self.m_awards / FLOAT_NUM) then -- 已经显示完了
    --         return
    --     end

    --     ManagerSound.playSound("task_receive")

    --     local node = display.newNode():addTo(self)
    --     self.m_floatNode = node

    --     local num = #self.m_awards - (self.m_floatIndex - 1) * FLOAT_NUM
    --     if num > FLOAT_NUM then num = FLOAT_NUM end

    --     local x = display.cx
    --     local y = display.cy - 120

        -- armature_add(IMAGE_ANIMATION .. "effect/ui_award_light.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_light.plist", IMAGE_ANIMATION .. "effect/ui_award_light.xml")
        -- local armature = armature_create("ui_award_light", x, y, function (movementType, movementID, armature)
        --         if movementType == MovementEventType.COMPLETE then
        --             armature:removeSelf()
        --         end
        --     end):addTo(node)
        -- armature:getAnimation():playWithIndex(0)

    --     local startX = x - (num * 80 + (num - 1) * 60) / 2

    --     for index = 1, num do
    --         local award = self.m_awards[(self.m_floatIndex - 1) * FLOAT_NUM + index]
    --         local itemView = UiUtil.createItemView(award.kind, award.id):addTo(node)
    --         itemView:setScale(0.6)
    --         itemView:setPosition(startX + (index - 0.5) * 80 + (index - 1) * 48, y - 80)
    --         itemView:runAction(transition.sequence({cc.MoveBy:create(0.6, cc.p(0, 160)), cc.DelayTime:create(0.8), cc.FadeOut:create(0.1)}))
    --         itemView:setCascadeOpacityEnabledRecursively(true)

    --         local resData = UserMO.getResourceData(award.kind, award.id)

    --         local label = ui.newTTFLabel({text = "+" .. UiUtil.strNumSimplify(award.count, false), font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
    --         label:setScale(1 / itemView:getScale())
    --         label:setAnchorPoint(cc.p(0, 0.5))
    --         label:setPosition(itemView:getContentSize().width, itemView:getContentSize().height / 2)
    --     end

    --     node:runAction(transition.sequence({cc.DelayTime:create(1.8), cc.CallFuncN:create(function(sender)
    --             self.m_floatIndex = self.m_floatIndex + 1
    --             show()
    --         end)}))
    -- end

    local function show()
        if self.m_floatNode then
            self.m_floatNode:removeSelf()
            self.m_floatNode = nil
        end

        if self.m_floatIndex > math.ceil(#self.m_awards / FLOAT_NUM) then -- 已经显示完了
            -- gprint("显示完了")
            return
        end

        ManagerSound.playSound("task_receive")

        local node = display.newNode():addTo(self)
        self.m_floatNode = node

        local num = #self.m_awards - (self.m_floatIndex - 1) * FLOAT_NUM
        if num > FLOAT_NUM then num = FLOAT_NUM end

        for index = 1, num do
            local award = self.m_awards[(self.m_floatIndex - 1) * FLOAT_NUM + index]

            local bg = display.newSprite(IMAGE_COMMON .. "info_bg_62.png"):addTo(node)
            bg:setPosition(display.width + bg:getContentSize().width / 2, display.cy - (index - 0.5) * 68)
            bg:setCascadeOpacityEnabled(true)

            local itemView = UiUtil.createItemView(award.kind, award.id):addTo(bg)
            if award.kind == ITEM_KIND_HERO then
                itemView:setScale(0.33)
            else
                itemView:setScale(0.6)
            end
            itemView:setPosition(itemView:getBoundingBox().size.width / 2, bg:getContentSize().height / 2)

            local nameX = 70
            if award.kind == ITEM_KIND_AWAKE_HERO then
                nameX = 125
            end
            local resData = UserMO.getResourceData(award.kind, award.id)
            local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = nameX, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[resData.quality]}):addTo(bg)
            -- local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_LIMIT, x = 70, y = 35, align = ui.TEXT_ALIGN_CENTER, color = COLOR[resData.quality]}):addTo(bg)
            name:setAnchorPoint(cc.p(0, 0.5))
            if award.kind == ITEM_KIND_TACTIC or award.kind == ITEM_KIND_TACTIC_PIECE then
                name:setColor(COLOR[resData.quality + 1])
            end
            
            local count = ui.newTTFLabel({text = " X " .. UiUtil.strNumSimplify(award.count, false, table.isexist(award, "detailed")), font = G_FONT, size = FONT_SIZE_LIMIT, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
            -- local count = ui.newTTFLabel({text = "X" .. UiUtil.strNumSimplify(award.count, false), font = G_FONT, size = FONT_SIZE_LIMIT, x = 70, y = 15, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
            count:setAnchorPoint(cc.p(0, 0.5))

            local spwArray = cc.Array:create()
            spwArray:addObject(cc.MoveBy:create(0.4, cc.p(0, 300)))
            spwArray:addObject(cc.FadeOut:create(0.4))

            local actions = {cc.DelayTime:create(0.2 * index), cc.EaseBackOut:create(cc.MoveBy:create(0.4, cc.p(-display.cx - bg:getContentSize().width / 2 - 60, 0))),
                cc.DelayTime:create(0.7), cc.Spawn:create(spwArray)}

            if index == num then  -- 当前轮显示完了，进入下一轮的奖励显示
                actions[#actions + 1] = cc.CallFuncN:create(function(sender)
                        self.m_floatIndex = self.m_floatIndex + 1
                        show()
                        sender:removeSelf()
                    end)
            else
                actions[#actions + 1] = cc.CallFuncN:create(function(sender) sender:removeSelf() end)
            end

            bg:runAction(transition.sequence(actions, cc.CallFuncN:create(function(sender) callback() end)))
        end
    end

    -- self.m_awards = {{kind = ITEM_KIND_POWER, id = 1, count = 100000},
    --     {kind = ITEM_KIND_HERO, id = 101, count = 1},
    --     {kind = ITEM_KIND_PART, id = 101, count = 1},
    --     {kind = ITEM_KIND_CHIP, id = 101, count = 1},
    --     {kind = ITEM_KIND_MATERIAL, id = 1, count = 1}}

    -- self.m_floatIndex = 1
    -- show()
    
    local function showFame()  -- 专门用于显示声望的
        local x = display.cx + 160
        local y = display.cy - 20

        local node = display.newNode():addTo(self)

        armature_add(IMAGE_ANIMATION .. "effect/ui_award_light.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_light.plist", IMAGE_ANIMATION .. "effect/ui_award_light.xml")
        local armature = armature_create("ui_award_light", x, y, function (movementType, movementID, armature)
            if movementType == MovementEventType.COMPLETE then
                armature:removeSelf()
            end
        end):addTo(node)
        armature:getAnimation():playWithIndex(0)

        local view = display.newSprite(IMAGE_COMMON .. "label_fame.png"):addTo(node)
        view:setPosition(x - 50, y)
        view:setLocalZOrder(999999)
        view:runAction(transition.sequence({cc.MoveBy:create(2, cc.p(0, 50)), cc.CallFuncN:create(function(sender)
                sender:removeSelf()
                -- callback()
            end)}))

        local label = ui.newBMFontLabel({text = "+" .. self.m_awardFame.count, font = "fnt/num_4.fnt",  x = view:getContentSize().width, y = view:getContentSize().height / 2}):addTo(view)
        label:setAnchorPoint(cc.p(0, 0.5))
   end

    if self.m_awardFame then  -- 有声望有显示
        showFame()
    end

    local function showExp()  -- 专门用于显示exp的
        local x = display.cx + 140
        local y = display.cy + 200

        local node = display.newNode():addTo(self)

        armature_add(IMAGE_ANIMATION .. "effect/ui_award_light.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_light.plist", IMAGE_ANIMATION .. "effect/ui_award_light.xml")
        local armature = armature_create("ui_award_light", x, y, function (movementType, movementID, armature)
            if movementType == MovementEventType.COMPLETE then
                armature:removeSelf()
            end
        end):addTo(node)
        armature:getAnimation():playWithIndex(0)

        local view = display.newSprite(IMAGE_COMMON .. "label_exp.png"):addTo(node)
        view:setPosition(x - 50, y)
        view:setLocalZOrder(999999)
        view:runAction(transition.sequence({cc.MoveBy:create(2, cc.p(0, 50)), cc.CallFuncN:create(function(sender)
                sender:removeSelf()
                -- callback()
            end)}))

        local label = ui.newBMFontLabel({text = "+" .. self.m_awardExp.count, font = "fnt/num_4.fnt",  x = view:getContentSize().width, y = view:getContentSize().height / 2}):addTo(view)
        label:setAnchorPoint(cc.p(0, 0.5))
    end

    if self.m_awardExp then -- 有exp显示
        showExp()
    end

    local function showPower()
        local x = display.cx - 80
        local y = display.cy - 250

        local node = display.newNode():addTo(self)

        armature_add(IMAGE_ANIMATION .. "effect/ui_award_light.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_light.plist", IMAGE_ANIMATION .. "effect/ui_award_light.xml")
        local armature = armature_create("ui_award_light", x, y, function (movementType, movementID, armature)
            if movementType == MovementEventType.COMPLETE then
                armature:removeSelf()
            end
        end):addTo(node)
        armature:getAnimation():playWithIndex(0)

        local view = display.newSprite(IMAGE_COMMON .. "label_power.png"):addTo(node)
        view:setPosition(x - 50, y)
        view:setLocalZOrder(999999)
        view:runAction(transition.sequence({cc.MoveBy:create(2, cc.p(0, 50)), cc.CallFuncN:create(function(sender)
                sender:removeSelf()
                -- callback()
            end)}))

        local label = ui.newBMFontLabel({text = "+" .. self.m_awardPower.count, font = "fnt/num_4.fnt",  x = view:getContentSize().width, y = view:getContentSize().height / 2}):addTo(view)
        label:setAnchorPoint(cc.p(0, 0.5))
    end

    if self.m_awardPower then  -- 有能量显示
        showPower()
    end

    self.m_floatIndex = 1
    show()
end

-- function AwardsView:showAwardBar()
--     ManagerSound.playSound("task_receive")

--     local bg = display.newSprite(IMAGE_COMMON .. "info_bg_42.png"):addTo(self)
--     bg:setPosition(self:getContentSize().width + bg:getContentSize().width / 2, 270)

--     local itemView = display.newSprite(IMAGE_COMMON .. "item_bg_0.png"):addTo(bg)
--     -- local itemView = UiUtil.createItemView(ITEM_KIND_COIN):addTo(bg)
--     itemView:setPosition(55, bg:getContentSize().height / 2)

--     local sprite = display.newSprite("image/item/p_award.jpg"):addTo(itemView)
--     sprite:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)

--     local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(itemView, 6)
--     fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)

--     -- 奖励
--     local label = ui.newTTFLabel({text = CommonText[360][2], font = G_FONT, size = FONT_SIZE_LIMIT, x = 120, y = bg:getContentSize().height / 2 + 12, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
--     local label = ui.newTTFLabel({text = CommonText[360][3], font = G_FONT, size = FONT_SIZE_LIMIT, x = 120, y = bg:getContentSize().height / 2 - 12, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

--     local startX = 180

--     for index = 1, #self.m_awards do
--     	local award = self.m_awards[index]

-- 		local resData = UserMO.getResourceData(award.kind, award.id)

-- 		local itemView = UiUtil.createItemView(award.kind, award.id):addTo(bg)
-- 		itemView:setPosition(startX, bg:getContentSize().height / 2)
-- 		itemView:setScale(0.7)

-- 		local label = ui.newTTFLabel({text = UiUtil.strNumSimplify(award.count, false), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
-- 		label:setAnchorPoint(cc.p(0, 0.5))
-- 		label:setPosition(itemView:getPositionX() + itemView:getBoundingBox().size.width / 2, itemView:getPositionY())

-- 		startX = label:getPositionX() + label:getContentSize().width + 5 + itemView:getBoundingBox().size.width / 2
--     end

--     bg:setCascadeOpacityEnabledRecursively(true)
--     -- 奖励条入场
--     bg:runAction(transition.sequence({cc.MoveTo:create(0.3, cc.p(self:getContentSize().width / 2, bg:getPositionY())),
--         cc.DelayTime:create(0.8),
--         cc.FadeOut:create(0.4),
--         cc.CallFuncN:create(function(sender)
--                 sender:removeSelf()
--             end)}))
-- end

function AwardsView:showLevelUp()
    if UserMO.level_ <=3 then 
        Notify.notify(LOCAL_SHOW_NEWER_GUIDE_EVENT) 
        return 
    end
    if UserMO.level_ <=8 then return end
    local scene = display.getRunningScene()
    if scene then
        local view = require("app.view.UserLevelUpView").new():addTo(scene, 999)
        view:setPosition(display.width / 2, display.height / 2)
    end
end

function AwardsView.show(awards, levelUp, bar)
    if instance_ then
        instance_:removeSelf()
        instance_ = nil
    end

    local scene = display.getRunningScene()
    if scene then
        local view = AwardsView.new(awards, levelUp, bar):addTo(scene, 10)
        view:setPosition(display.width / 2, display.height / 2)
        instance_ = view
    end
end

return AwardsView
