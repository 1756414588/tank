BAR_STATUS_DRAW_BACK = 1 -- 收缩
BAR_STATUS_STRETCH   = 2 -- 伸展

local TaskBarView = class("TaskBarView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function TaskBarView:ctor(task,barStatus)
    armature_add("animation/effect/ui_task_bar.pvr.ccz", "animation/effect/ui_task_bar.plist", "animation/effect/ui_task_bar.xml")

    local bg = display.newSprite(IMAGE_COMMON .. "info_bg_65.png"):addTo(self)
    bg:setPosition(50, 0)
    self.m_bg = bg

    local barEffect = CCArmature:create("ui_task_bar")
    barEffect:setPosition(self.m_bg:getContentSize().width / 2, self.m_bg:getContentSize().height / 2)
    
    self.m_bg:addChild(barEffect)
    self.barEffect = barEffect
    self:playEffect()
    
    

    self:setContentSize(bg:getContentSize())
    self:setAnchorPoint(cc.p(0.5, 0.5))

    if not barStatus or barStatus == BAR_STATUS_STRETCH then
        bg:setPosition(self:getContentSize().width / 2 + 50, self:getContentSize().height / 2)
    else
        bg:setPosition(-self:getContentSize().width / 2, self:getContentSize().height / 2)
    end
    

    local taskInfo = TaskMO.queryTask(task.taskId)

    local name = ui.newTTFLabel({text = taskInfo.taskName, font = G_FONT, size = FONT_SIZE_SMALL, 
        x = 20, y = bg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
    name:setAnchorPoint(cc.p(0, 0.5))

    local scheduleLab = ui.newTTFLabel({text = CommonText[676][1], font = G_FONT, size = FONT_SIZE_SMALL, 
        x = name:getPositionX() + name:getContentSize().width + 10, y = name:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
    scheduleLab:setAnchorPoint(cc.p(0, 0.5))

    local gouPic = display.newSprite(IMAGE_COMMON .. "icon_gou.png"):addTo(bg)
    gouPic:setPosition(scheduleLab:getPositionX() + scheduleLab:getContentSize().width + 20, name:getPositionY())
    gouPic:setVisible(task.schedule >= taskInfo.schedule)


    local scheduleValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
        x = scheduleLab:getPositionX() + scheduleLab:getContentSize().width, y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
    scheduleValue:setAnchorPoint(cc.p(0, 0.5)) 
    if task.schedule >= taskInfo.schedule then
        scheduleValue:setString(CommonText[676][7])
        scheduleValue:setPosition(gouPic:getPositionX() + gouPic:getContentSize().width / 2, name:getPositionY())
    else
        scheduleValue:setString(task.schedule .. "/" .. taskInfo.schedule)
        scheduleValue:setPosition(scheduleLab:getPositionX() + scheduleLab:getContentSize().width, name:getPositionY())
    end

    

    local normal,selected,btn
    -- 收回按钮
    if task.status == 0 then
        normal = display.newSprite(IMAGE_COMMON .. "btn_32_normal.png")
        selected = display.newSprite(IMAGE_COMMON .. "btn_32_selected.png")
    else
        normal = display.newSprite(IMAGE_COMMON .. "btn_39_normal.png")
        selected = display.newSprite(IMAGE_COMMON .. "btn_39_selected.png")
    end
    btn = MenuButton.new(normal, selected, nil, handler(self,self.onEffectBar)):addTo(self)
    btn:setPosition(35, self:getContentSize().height / 2)
    self.m_btn = btn

    -- -- 前进定位图片
    -- local locationPic = display.newSprite(IMAGE_COMMON .. "btn_go_normal.png", 
    --     bg:getContentSize().width - 30, bg:getContentSize().height / 2):addTo(bg,10)
   
   nodeTouchEventProtocol(bg, function(event) 
        if task.status == 0 then
            self:onGoTask(taskInfo)
        else
            self:onGetAward(task.taskId)
        end
     end, nil, nil, true)
    
   if not barStatus then
    self.m_barStatus = BAR_STATUS_STRETCH -- 伸展
   end
end

function TaskBarView:getBarStatus()
    return self.m_barStatus
end



function TaskBarView:onGoTask(taskInfo)
    if self.m_isMove then return false end
    TaskBO.goToTaskDo(taskInfo)
end

function TaskBarView:onEffectBar(tag, sender)
    ManagerSound.playNormalButtonSound()
    if self.m_isMove then return false end

    if self.m_barStatus == BAR_STATUS_DRAW_BACK then
        self.m_barStatus = BAR_STATUS_STRETCH
    else
        self.m_barStatus = BAR_STATUS_DRAW_BACK
    end
    self:showBar()
end

function TaskBarView:showBar()
    if self.m_isMove then return false end

    self.m_isMove = true

    if self.m_barStatus == BAR_STATUS_STRETCH then  -- 需要伸展开
            self.m_bg:runAction(transition.sequence({cc.MoveTo:create(0.1 , cc.p(self:getContentSize().width / 2 + 50, self:getContentSize().height / 2)), cc.CallFuncN:create(function()
                    self.m_isMove = false
                end)}))
    elseif self.m_barStatus == BAR_STATUS_DRAW_BACK then -- 需要收缩
            self.m_bg:runAction(transition.sequence({cc.MoveTo:create(0.08 , cc.p(-self:getContentSize().width / 2, self:getContentSize().height / 2)), cc.CallFuncN:create(function()
                    self.m_isMove = false
                end)}))
    end
end

function TaskBarView:onGetAward(taskId)
    if self.taskAcceptStatus == true then return end
    if self.m_isMove then return false end
    self.taskAcceptStatus = true
    Loading.getInstance():show()
    TaskBO.asynTaskAward(function()
        Loading.getInstance():unshow()
        ManagerSound.playSound("task_done")
        self.taskAcceptStatus = false
        end,TASK_TYPE_MAJOR,taskId,TASK_GET_AWARD_TYPE_NOMAL)
end

function TaskBarView:playEffect()
    self.barEffect:getAnimation():playWithIndex(0)
    self.barEffect:connectMovementEventSignal(function(movementType, movementID) 
            if movementType == MovementEventType.COMPLETE then
                 scheduler.performWithDelayGlobal(function()
                    if self.barEffect then
                        self.barEffect:getAnimation():playWithIndex(0)
                    end
                end, 5)
            end
        end)
end

function TaskBarView:onExit()
    armature_remove("animation/effect/ui_task_bar.pvr.ccz", "animation/effect/ui_task_bar.plist", "animation/effect/ui_task_bar.xml")
end

return TaskBarView