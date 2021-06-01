--
-- Author:
-- Date:
--

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local ProgressBar = class("ProgressBar", function ()
   local node = display.newNode()
   node:setNodeEventEnabled(true)
   nodeExportComponentMethod(node)
   return node
end)

BAR_DIRECTION_VERTICAL   = 1
BAR_DIRECTION_HORIZONTAL = 2
BAR_DIRECTION_CIRCLE = 3

-- barName: 进度条图片名称
-- direction:
-- scale9Size: 如果不为空，则进度条为scale9sprite的方式加载，并拉伸
-- param: 进度条的一些参数，其中:
-- label: 进度条标签 显示内容自定义
-- bgName: 进度条背景图
-- bgScale9Size
function ProgressBar:ctor(barName, direction, scale9Size, param)
    direction = direction or BAR_DIRECTION_HORIZONTAL
    param = param or {}

    self.m_direction = direction
    self.m_animationDeltaScale = 1

    if scale9Size then
        self.m_isScale9Sprite = true
        self.m_bar = display.newScale9Sprite(barName):addTo(self, 1)
        self.m_bar:setPreferredSize(scale9Size)
    else
        self.m_bar = display.newSprite(barName):addTo(self, 1)
    end

    self:setCascadeColorEnabled(true)
    self:setContentSize(self.m_bar:getContentSize())
    self:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_bar:setAnchorPoint(cc.p(0, 0.5))
    self.m_bar:setPosition(0, self:getContentSize().height / 2)

    -- local size = self:getContentSize()
    -- if size.width ~= 0 and size.height ~= 0 then
    --     local line = display.newLine({{0, 0}, {size.width, size.height}})
    --     self:addChild(line)
    -- end

    if param.bgName then
        if param.bgScale9Size then
            self.m_bg = display.newScale9Sprite(param.bgName)
            self.m_bg:setPreferredSize(param.bgScale9Size)
        else
            self.m_bg = display.newSprite(param.bgName)
        end

        param.bgX = param.bgX or self:getContentSize().width / 2
        param.bgY = param.bgY or self:getContentSize().height / 2
        -- if self.m_direction == BAR_DIRECTION_HORIZONTAL then
        --     self.m_bg:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        -- else
            self.m_bg:setPosition(param.bgX, param.bgY)
        -- end
        self:addChild(self.m_bg)
    end
end

function ProgressBar:onExit()
    if self.m_animateHanlder then
        scheduler.unscheduleGlobal(self.m_animateHanlder)
        self.m_animateHanlder = nil
    end
end

function ProgressBar:setPercent(percent)
    percent = percent or 0
    if percent < 0 then percent = 0 end
    if percent > 1 then percent = 1 end

    self.m_percent = percent
    self:updateBar()
end

function ProgressBar:getPercent()
    return self.m_percent
end

function ProgressBar:updateBar()
    local percent = self.m_percent

    if self.m_isScale9Sprite then
        self.m_bar:setScaleX(percent)
        return
    end

    local texture = self.m_bar:getTexture()

    local rect = nil
    if self.m_direction == BAR_DIRECTION_HORIZONTAL then
        rect = cc.rect(0, 0, texture:getPixelsWide() * percent, texture:getPixelsHigh())
    elseif self.m_direction == BAR_DIRECTION_CIRCLE then
         rect = cc.rect(0,texture:getPixelsHigh() * (1 - percent),texture:getPixelsWide(), texture:getPixelsHigh() * percent)
        self.m_bar:setPositionY(texture:getPixelsHigh() * percent / 2)
    else
        rect = cc.rect(0, texture:getPixelsHigh() * (1 - percent), texture:getPixelsWide(), texture:getPixelsHigh())
        -- TextureRect是以左上为(0, 0)的
        self.m_bar:setPositionY(self:getContentSize().height / 2 - texture:getPixelsHigh() * (1 - percent))
    end

    self.m_bar:setTextureRect(rect)
end

function ProgressBar:animatePercent(oldPercent, newPercent, level, doneCallback)
    level = level or 0
    level = math.max(0, level)
    oldPercent = math.max(math.min(oldPercent, 1), 0)
    newPercent = math.max(math.min(newPercent, 1), 0)
    
    if level == 0 and oldPercent == newPercent then
        if doneCallback then doneCallback() end
        return
    end

    if level == 0 and oldPercent > newPercent then  -- 动画是在下降的
        self.m_animateDescend = true
        self.m_animateDelta = -0.005 * self.m_animationDeltaScale
    else
        self.m_animateDelta = 0.005 * self.m_animationDeltaScale
    end

    self.m_oldPercent = oldPercent
    self.m_newPercent = newPercent
    self.m_level = level
    self.m_curLevelIndex = 0
    self.m_animateCallback = doneCallback
    self:setPercent(oldPercent)

    if self.m_animateHanlder then
        scheduler.unscheduleGlobal(self.m_animateHanlder)
        self.m_animateHanlder = nil
    end
    self.m_animateHanlder = scheduler.scheduleUpdateGlobal(handler(self, self.animate))
end

function ProgressBar:setAnimationScale(scale)
    self.m_animationDeltaScale = scale
end

-- 私有方法，不要调用
function ProgressBar:animate(dt)
    if self.m_level == 0 then  -- 只有一条的运动动画
        local isOver = false
        if self.m_animateDelta < 0 then  -- 动画增量是下降减少的
            if self.m_newPercent >= self.m_oldPercent then isOver = true
            else isOver = false end
        else
            if self.m_newPercent <= self.m_oldPercent then isOver = true
            else isOver = false end
        end

        if isOver then  -- 运动结束
            if self.m_animateHanlder ~= nil then
                scheduler.unscheduleGlobal(self.m_animateHanlder)
                self.m_animateHanlder = nil
            end
            self:setPercent(self.m_newPercent)  -- 最后再调整下进度
            if self.m_animateCallback then
                self.m_animateCallback()
            end
        else
            self.m_oldPercent = self.m_oldPercent + self.m_animateDelta
            self:setPercent(self.m_oldPercent)
        end
    else  -- 有多条的运动动画
       if self.m_curLevelIndex < self.m_level then  -- 还没有运动到最后一条
            self.m_oldPercent = self.m_oldPercent + self.m_animateDelta
            self:setPercent(self.m_oldPercent)

            if self.m_oldPercent >= 1 then  -- 进入到下一条
                self.m_curLevelIndex = self.m_curLevelIndex + 1
                self.m_oldPercent = 0
            end
        elseif self.m_curLevelIndex == self.m_level then  -- 运动到最后一条
            local isOver = false

            if self.m_animateDelta > 0 then
                if self.m_newPercent <= self.m_oldPercent then isOver = true
                else isOver = false end
            else
                isOver = true -- 不支持多条
            end

            if isOver then  -- 运动结束
                if self.m_animateHanlder ~= nil then
                    scheduler.unscheduleGlobal(self.m_animateHanlder)
                    self.m_animateHanlder = nil
                end
                self:setPercent(self.m_newPercent)  -- 最后再调整下进度
                if self.m_animateCallback then
                    self.m_animateCallback()
                end
            else
                self.m_oldPercent = self.m_oldPercent + self.m_animateDelta
                self:setPercent(self.m_oldPercent)
            end
        end
    end
end


function ProgressBar:setLabel(strText, param)
    param = param or {}
    param.color = param.color or nil
    param.size = param.size or FONT_SIZE_TINY
    param.x = param.x or self:getContentSize().width / 2
    param.y = param.y or self:getContentSize().height / 2

    if self.m_label then
        self.m_label:setString(strText)

        self.m_label:setPosition(param.x, param.y)
        self.m_label:setFontSize(param.size)

        if param.color then self.m_label:setColor(param.color) end
    else
        self.m_label = ui.newTTFLabel({text = strText, font = G_FONT, size = param.size, x = param.x, y = param.y, color = param.color, align = ui.TEXT_ALIGN_CENTER}):addTo(self, 4)
    end
end

function ProgressBar:getLabel()
    return self.m_label
end


return ProgressBar
