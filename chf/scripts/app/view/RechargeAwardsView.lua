--
-- Author: gf
-- Date: 2015-11-10 15:35:40
--


local RechargeAwardsView = class("RechargeAwardsView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

local instance_ = nil

-- levelUp: 是否是升级
-- bar: 显示奖励条
function RechargeAwardsView:ctor(awards)
   
    self.m_awards = {}
    self.m_awardTopup = nil -- VIP点奖励


    for index = 1, #awards do
        if awards[index].kind == ITEM_KIND_TOPUP then  -- VIP点奖励
            if not self.m_awardTopup then self.m_awardTopup = awards[index]
            else self.m_awardTopup.count = self.m_awardTopup.count + awards[index].count end
        else
            self.m_awards[#self.m_awards + 1] = awards[index]
        end
    end
    
end

function RechargeAwardsView:onEnter()
    self:setContentSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
    self:setAnchorPoint(cc.p(0.5, 0.5))

    gdump(self.m_awards, "RechargeAwardsView:onEnter")

    self:runAction(transition.sequence({cc.CallFuncN:create(function()
	        self:showFload()
	    end), cc.DelayTime:create(8), cc.CallFuncN:create(function()
	        self:removeSelf()
	    end)
	    }))
end

function RechargeAwardsView:onExit()
    -- gprint("RechargeAwardsView.onExit()")
    instance_ = nil
end

local FLOAT_NUM = 3 -- 每组最多显示数量

-- 显示空中漂浮的奖励
function RechargeAwardsView:showFload()
    local function show()
        if self.m_floatNode then
            self.m_floatNode:removeSelf()
            self.m_floatNode = nil
        end

        if self.m_floatIndex > math.ceil(#self.m_awards / FLOAT_NUM) then -- 已经显示完了
            return
        end

        ManagerSound.playSound("task_receive")

        local node = display.newNode():addTo(self)
        self.m_floatNode = node

        local num = #self.m_awards - (self.m_floatIndex - 1) * FLOAT_NUM
        if num > FLOAT_NUM then num = FLOAT_NUM end

        local x = display.cx
        local y = display.cy - 120

        armature_add(IMAGE_ANIMATION .. "effect/ui_award_light.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_light.plist", IMAGE_ANIMATION .. "effect/ui_award_light.xml")
        local armature = armature_create("ui_award_light", x, y, function (movementType, movementID, armature)
                if movementType == MovementEventType.COMPLETE then
                    armature:removeSelf()
                end
            end):addTo(node)
        armature:getAnimation():playWithIndex(0)

        local startX = x - (num * 80 + (num - 1) * 60) / 2

        for index = 1, num do
            local award = self.m_awards[(self.m_floatIndex - 1) * FLOAT_NUM + index]
            local itemView = UiUtil.createItemView(award.kind, award.id):addTo(node)
            itemView:setScale(1)
            itemView:setPosition(startX + (index - 0.5) * 80 + (index - 1) * 48, y - 80)
            itemView:runAction(transition.sequence({cc.MoveBy:create(1, cc.p(0, 160)), cc.DelayTime:create(0.8), cc.FadeOut:create(0.1)}))
            itemView:setCascadeOpacityEnabledRecursively(true)

            local resData = UserMO.getResourceData(award.kind, award.id)

            local label = ui.newTTFLabel({text = " +" .. award.count, font = G_FONT, size = FONT_SIZE_BIG, align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
            label:setScale(1 / itemView:getScale())
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(itemView:getContentSize().width, itemView:getContentSize().height / 2)
        end

        node:runAction(transition.sequence({cc.DelayTime:create(1.8), cc.CallFuncN:create(function(sender)
                self.m_floatIndex = self.m_floatIndex + 1
                show()
            end)}))
    end

    self.m_floatIndex = 1
    show()

    local function showTopup()  -- 专门用于显示声望的
        local x = display.cx + 50
        local y = display.cy - 60

        local node = display.newNode():addTo(self)

        armature_add(IMAGE_ANIMATION .. "effect/ui_award_light.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_light.plist", IMAGE_ANIMATION .. "effect/ui_award_light.xml")
        local armature = armature_create("ui_award_light", x, y, function (movementType, movementID, armature)
            if movementType == MovementEventType.COMPLETE then
                armature:removeSelf()
            end
        end):addTo(node)
        armature:getAnimation():playWithIndex(0)

        local view = display.newSprite(IMAGE_COMMON .. "info_bg_48.png"):addTo(node)
        view:setPosition(x - 50, y)
        view:runAction(transition.sequence({cc.MoveBy:create(1, cc.p(0, 160)),cc.DelayTime:create(0.8), cc.CallFuncN:create(function(sender)
                sender:removeSelf()
            end)}))

        local label = ui.newBMFontLabel({text = UserMO.topup_, font = "fnt/num_3.fnt"}):addTo(view)
        label:setAnchorPoint(cc.p(1, 0.5))
        label:setPosition(view:getContentSize().width / 2, 25)

        local label1 = ui.newBMFontLabel({text = "+" .. self.m_awardTopup.count, font = "fnt/num_4.fnt"}):addTo(view)
        label1:setAnchorPoint(cc.p(0, 0.5))
        label1:setPosition(view:getContentSize().width / 2 + 20, 25)
   end

    if self.m_awardTopup then  -- 有声望有显示
        showTopup()
    end
    
end







function RechargeAwardsView.show(awards)
    if instance_ then
        instance_:removeSelf()
        instance_ = nil
    end

    local scene = display.getRunningScene()
    if scene then
        local view = RechargeAwardsView.new(awards):addTo(scene, 10)
        view:setPosition(display.width / 2, display.height / 2)
        instance_ = view
    end
end

return RechargeAwardsView
