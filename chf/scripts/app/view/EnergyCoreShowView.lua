--
-- Author: Gss
-- Date: 2019-04-16 15:28:31
--
-- 能源核心展示界面  EnergyCoreShowView

local movieTime = 0.3
local movieTimeInterval = 0.01

local EnergyCoreShowView = class("EnergyCoreShowView", UiNode)

function EnergyCoreShowView:ctor()
	EnergyCoreShowView.super.ctor(self, "image/common/bg_ui.jpg")
end

function EnergyCoreShowView:onEnter()
	EnergyCoreShowView.super.onEnter(self)
	self:setTitle(CommonText[8000])

	self:setUI()
end

function EnergyCoreShowView:setUI()
	local topBg = display.newSprite(IMAGE_COMMON .. "energy_core_show_bg.png"):addTo(self:getBg())
	topBg:setPosition(self:getBg():width() / 2, self:getBg():height() - topBg:width() / 2)
    self.m_topBg = topBg

    local tips = UiUtil.label(CommonText[8001],16):addTo(topBg,999)
    tips:setAnchorPoint(cc.p(0,0.5))
    tips:setPosition(topBg:width() - 190, topBg:height() - 60)

	local total = EnergyCoreMO.queryLvInfoByLv()
	self.m_totalData = total

    self.choseNum = EnergyCoreMO.energyCoreData_.lv  --停在当前等级段
	self.m_view_num = self.m_totalData[self.choseNum]


	local listUI = display.newNode():addTo(topBg)
	listUI:setPosition(topBg:getContentSize().width / 2,topBg:getContentSize().height / 2)

	local function movedCallback(tag,sender,x,y)
		if x < self.touchPosX then
			self:turnHandler(nil,{type = "next"})
		elseif x > self.touchPosX then
			self:turnHandler(nil,{type = "pre"})
		end
	end

	local function beganCallback(tag,sender,x,y)
		self.touchPosX = x
	end

	for index=1,#total do
        local condition = EnergyCoreMO.queryLvInfoByLv(index)

		local normal = display.newSprite(IMAGE_COMMON .. "energy_show_btnBg.png")
		normal:setScale(0.9)

		local energyCoreView = TouchButton.new(normal, beganCallback, movedCallback, nil, nil)
        if index < self.choseNum then
            energyCoreView:setPosition(-(self.choseNum - index)*230,45)
        else
            energyCoreView:setPosition((index - self.choseNum)*230, 45)
        end
        --添加滑动块内的显示内容
        --灰色背景
        local btm = display.newSprite(IMAGE_COMMON .. "energyCore_show_btm.png"):addTo(energyCoreView, -1):center()
        btm:setScale(0.9)
        if EnergyCoreMO.energyCoreData_.lv < index then
            btm:setZOrder(90)
        end
        --锁
        local lock = display.newSprite(IMAGE_COMMON .. "energycore_lock.png"):addTo(energyCoreView,99):center()
        lock:setVisible(EnergyCoreMO.energyCoreData_.lv < index)
        --等级
        local numBg = display.newSprite(IMAGE_COMMON .. "energycore_showNum_bg.png"):addTo(energyCoreView)
        numBg:setPosition(energyCoreView:width() / 2, -20)
        local num = UiUtil.label(index):addTo(numBg):center()
        --图标
        local item = display.newSprite(IMAGE_COMMON .. condition.asset ..".png"):addTo(energyCoreView)
        item:setPosition(energyCoreView:width() / 2, energyCoreView:height() / 2 + 20)
        --名称
        local nameBg = display.newScale9Sprite(IMAGE_COMMON .. "energy_nameBg.png"):addTo(energyCoreView)
        nameBg:setPreferredSize(cc.size(nameBg:width() + 40, nameBg:height() + 10))
        nameBg:setPosition(energyCoreView:width() / 2, 60)
        local name = UiUtil.label(condition.desc2):addTo(nameBg):center()

		self["energyCoreView"..index] = energyCoreView
		listUI:addChild(self["energyCoreView"..index])
	end

	self:selectViewHandle()
end

--刷新界面
function EnergyCoreShowView:selectViewHandle()
	self.m_view_num = self.m_totalData[self.choseNum]
    for i = 1, #self.m_totalData do
        if self.m_totalData[i] == self.m_view_num then
            self["energyCoreView"..i]:setScale(1)
            self["energyCoreView"..i]:setZOrder(10)
        	self["energyCoreView"..i]:setOpacity(255)
        	
        else
            self["energyCoreView"..i]:setScale(0.7)
            self["energyCoreView"..i]:setZOrder(9)
            self["energyCoreView"..i]:setOpacity(150)
        end

        if i < self.choseNum then
        	self["energyCoreView"..i]:setPosition(-(self.choseNum - i)*230,45)
        else
        	self["energyCoreView"..i]:setPosition((i - self.choseNum)*230, 45)
        end
    end
    self:updateView()
end

--滑动操作
function EnergyCoreShowView:turnHandler(tag, sender)
	if self.playState == true then return end 
	local type = sender.type
    if type == "next" then
        self.choseNum = self.choseNum + 1 
        if self.choseNum > #self.m_totalData then
            self.choseNum = #self.m_totalData
            return
        end
    else
        self.choseNum = self.choseNum - 1
        if self.choseNum <= 0 then
            self.choseNum = 1
             return
        end
    end
    self.nextHero = self.choseNum + 1
    if self.nextHero >= #self.m_totalData + 1 then
        self.nextHero = #self.m_totalData
    end
    self.preHero = self.choseNum - 1
    if self.preHero <= 0 then
        self.preHero = 1
    end
    
    ManagerSound.playNormalButtonSound()
    self:playMovie(type)
end

--移动
function EnergyCoreShowView:playMovie(type)
    self.showTime = movieTime
    self.playState = true
    local step = movieTime / movieTimeInterval
    local selectHeroX = - self["energyCoreView"..self.choseNum]:getPositionX()
    local selectHeroY = 45

    local nextHeroX = 230 - self["energyCoreView"..self.nextHero]:getPositionX()
    local nextHeroY = 45
    local preHeroX = -230 - self["energyCoreView"..self.preHero]:getPositionX()
    local preHeroY = 45

    local nextHeroScal
    local preHeroScal
    local allPosY = 45

    if type == "next" then
        nextHeroScal = nil
        preHeroScal = 0.8 - self["energyCoreView"..self.preHero]:getScale()
        self["energyCoreView"..self.choseNum]:setZOrder(10)
        self["energyCoreView"..self.nextHero]:setZOrder(9)
        self["energyCoreView"..self.preHero]:setZOrder(9)
    else
        nextHeroScal = 0.8 - self["energyCoreView"..self.nextHero]:getScale()
        preHeroScal = nil
        self["energyCoreView"..self.choseNum]:setZOrder(10)
        self["energyCoreView"..self.nextHero]:setZOrder(9)
        self["energyCoreView"..self.preHero]:setZOrder(9)
    end
    local function timeSet()
        if self.showTime > 0 then
            self.showTime = self.showTime - movieTimeInterval
            self["energyCoreView"..self.choseNum]:setScale(0.2 / step + self["energyCoreView"..self.choseNum]:getScale())
            self["energyCoreView"..self.choseNum]:setPosition(
                selectHeroX / step + self["energyCoreView"..self.choseNum]:getPositionX(),
                allPosY
                )
            self["energyCoreView"..self.nextHero]:setPosition(
                nextHeroX / step + self["energyCoreView"..self.nextHero]:getPositionX(),
                allPosY
                )
            self["energyCoreView"..self.preHero]:setPosition(
                preHeroX / step + self["energyCoreView"..self.preHero]:getPositionX(),
                allPosY
                )
            if type == "next" and self["energyCoreView"..(self.preHero - 1)] then
                self["energyCoreView"..(self.preHero - 1)]:setPosition(
                    preHeroX / step + self["energyCoreView"..(self.preHero-1)]:getPositionX(),
                    allPosY
                    )
            else
                if self["energyCoreView"..self.nextHero + 1] then
                    self["energyCoreView"..self.nextHero + 1]:setPosition(
                        nextHeroX / step + self["energyCoreView"..self.nextHero + 1]:getPositionX(),
                        allPosY
                        )
                end
            end

            if nextHeroScal then
                self["energyCoreView"..self.nextHero]:setScale(nextHeroScal / step + self["energyCoreView"..self.nextHero]:getScale())
            end
            if preHeroScal then 
                self["energyCoreView"..self.preHero]:setScale(preHeroScal / step + self["energyCoreView"..self.preHero]:getScale())
            end
        else 
            self["energyCoreView"..self.choseNum]:setScale(1)
            self["energyCoreView"..self.choseNum]:setPosition(
                0,
                allPosY
                )
            self["energyCoreView"..self.nextHero]:setPosition(
                230,
                allPosY
                )
            self["energyCoreView"..self.preHero]:setPosition(
                -230,
                allPosY
                )
            if type == "next" then 
                self["energyCoreView"..self.preHero]:setScale(0.8)
            else
                self["energyCoreView"..self.nextHero]:setScale(0.8)
            end
            self.playState = false
            self.showTime = 0
            self:stopAllActions()
            self:selectViewHandle()
        end
    end
    local oneSec = transition.sequence({
                                        CCCallFunc:create(timeSet),
                                        CCDelayTime:create(movieTimeInterval)
                                       })
    self:runAction(CCRepeatForever:create(oneSec))
end

--刷新界面，能量球的显示和属性奖励
function EnergyCoreShowView:updateView()
    if self.m_contentNode then
        self.m_contentNode:removeSelf()
        self.m_contentNode = nil
    end

    local container = display.newNode():addTo(self:getBg())
    container:setContentSize(self:getBg():getContentSize())
    self.m_contentNode = container

    --能量球
    -- local sectionInfo = EnergyCoreMO.queryExpByLvAndSection(EnergyCoreMO.energyCoreData_.lv, EnergyCoreMO.energyCoreData_.section)
    -- local sectionExp = EnergyCoreMO.energyCoreData_.exp
    -- if sectionInfo then
    --     sectionExp = sectionInfo.exp
    -- end

    -- for index=1,4 do
    --     local exp = EnergyCoreMO.queryExpByLvAndSection(self.choseNum, index).exp
    --     local tipBg = display.newSprite(IMAGE_COMMON.."energy_bar_bg.png"):addTo(container)
    --     tipBg:setPosition(90 + (index - 1)*155,self.m_topBg:y() - 180)

    --     local needBg = display.newSprite(IMAGE_COMMON.."energy_numExp_bg.png"):addTo(tipBg,9):center()
    --     local needLab = UiUtil.label(""):addTo(needBg):center()
    --     needLab:setString(exp)

    --     --进度
    --     local clipping = cc.ClippingNode:create()
    --     local oilBar = ProgressBar.new(IMAGE_COMMON .. "energy_ball_bar.png", BAR_DIRECTION_CIRCLE)
    --     local mask = display.newSprite(IMAGE_COMMON.."bar_bg_13.png")
    --     clipping:setInverted(false)
    --     clipping:setAlphaThreshold(0.0)
    --     clipping:setStencil(mask)
    --     clipping:addChild(oilBar)
    --     clipping:addTo(tipBg):center()
    --     oilBar:setPercent(EnergyCoreMO.energyCoreData_.exp / sectionExp)
    --     if EnergyCoreMO.energyCoreData_.lv > self.choseNum then
    --         oilBar:setPercent(1)
    --         needLab:setString("Max")
    --         local lightningBall = CCArmature:create("nyhx_shandianqiu"):addTo(tipBg):center()
    --         lightningBall:getAnimation():playWithIndex(0)
    --     elseif EnergyCoreMO.energyCoreData_.lv < self.choseNum then
    --         oilBar:setPercent(0)
    --     else
    --         if EnergyCoreMO.energyCoreData_.section > index then
    --             oilBar:setPercent(1)
    --             needLab:setString("Max")
    --             local lightningBall = CCArmature:create("nyhx_shandianqiu"):addTo(tipBg):center()
    --             lightningBall:getAnimation():playWithIndex(0)
    --         elseif EnergyCoreMO.energyCoreData_.section < index then
    --             oilBar:setPercent(0)
    --         elseif EnergyCoreMO.energyCoreData_.section == index then
    --             local lightning = CCArmature:create("nyhx_dianliu"):addTo(clipping)
    --             local yOff = (oilBar:getPercent() - 0.5) * 91
    --             lightning:setPosition(oilBar:getPositionX(),yOff + 5)
    --             lightning:getAnimation():playWithIndex(0)
    --         end
    --     end
    -- end

    --解锁相关
    local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container,-1)
    infoBg:setPreferredSize(cc.size(container:width() - 20, 340))
    infoBg:setPosition(container:width() / 2, self.m_topBg:y() - self.m_topBg:height() / 2 - infoBg:height() / 2)

    local condition = EnergyCoreMO.queryLvInfoByLv(self.choseNum)
    --解锁条件
    local lockBg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(infoBg)
    lockBg:setPosition(lockBg:width() / 2 + 20, infoBg:height() - 30)
    local lockTitle = UiUtil.label(CommonText[8002]):addTo(lockBg)
    lockTitle:setAnchorPoint(cc.p(0,0.5))
    lockTitle:setPosition(40, lockBg:height() / 2)
    local condLab = UiUtil.label(string.format(condition.desc,condition.cond).."("):addTo(infoBg)
    condLab:setAnchorPoint(cc.p(0, 0.5))
    condLab:setPosition(40, lockBg:y() - 40)

    local lv = EnergyCoreMO.queryOpenInfoBykind(condition.type)
    local mycond = UiUtil.label(lv,nil,COLOR[2]):rightTo(condLab)
    local need = UiUtil.label("/"..condition.cond..")"):rightTo(mycond)
    mycond:setColor(lv >= condition.cond and COLOR[2] or COLOR[5])

    local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(infoBg)
    line:setPreferredSize(cc.size(infoBg:width() - 50, line:height()))
    line:setPosition(infoBg:width() / 2, lockBg:y() - 65)
    
    --点亮奖励
    local lightBg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):alignTo(lockBg, -100, 1)
    local lightTitle = UiUtil.label(CommonText[8003]):addTo(lightBg)
    lightTitle:setAnchorPoint(cc.p(0,0.5))
    lightTitle:setPosition(40, lightBg:height() / 2)
    --位置
    local pos = UiUtil.label(string.format(CommonText[8026],condition.index)):addTo(infoBg)
    pos:setAnchorPoint(cc.p(0,0.5))
    pos:setPosition(40, lightBg:y() - 30)

    local lightAttr = json.decode(condition.lightAward)
    for index=1,#lightAttr do
        local attr = lightAttr[index]
        local attributeData = AttributeBO.getAttributeData(attr[1],attr[2])
        local name = UiUtil.label(attributeData.name):addTo(infoBg)
        name:setAnchorPoint(cc.p(0,0.5))
        name:setPosition(40 + (index - 1)* 150, lightBg:y() - 60)

        local value = UiUtil.label("+"..attributeData.strValue,nil,COLOR[2]):rightTo(name)
    end

    local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(infoBg)
    line:setPreferredSize(cc.size(infoBg:width() - 50, line:height()))
    line:setPosition(infoBg:width() / 2, lightBg:y() - 85)

    --完成奖励
    local finishBg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):alignTo(lightBg, -120, 1)
    local finishTitle = UiUtil.label(CommonText[8004]):addTo(finishBg)
    finishTitle:setAnchorPoint(cc.p(0,0.5))
    finishTitle:setPosition(40, finishBg:height() / 2)
    --全部
    local pos = UiUtil.label(CommonText[8027]):addTo(infoBg)
    pos:setAnchorPoint(cc.p(0,0.5))
    pos:setPosition(40, finishBg:y() - 30)

    local finishAttr = json.decode(condition.finishAward)
    for index=1,#finishAttr do
        local attr = finishAttr[index]
        local attributeData = AttributeBO.getAttributeData(attr[1],attr[2])
        local name = UiUtil.label(attributeData.name):addTo(infoBg)
        name:setAnchorPoint(cc.p(0,0.5))
        name:setPosition(40 + (index - 1)* 150, finishBg:y() - 60)

        local value = UiUtil.label("+"..attributeData.strValue,nil,COLOR[2]):rightTo(name)
    end

    local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(infoBg)
    line:setPreferredSize(cc.size(infoBg:width() - 50, line:height()))
    line:setPosition(infoBg:width() / 2, finishBg:y() - 85)

end

function EnergyCoreShowView:onExit()
	EnergyCoreShowView.super.onExit(self)
end

return EnergyCoreShowView
