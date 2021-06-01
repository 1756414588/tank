--
-- Author: gf
-- Date: 2015-09-26 10:39:53
-- 新手引导

local NewerView = class("NewerView", UiNode)

NEWER_POS_TYPE_CENTER = 1 --从屏幕中间开始算
NEWER_POS_TYPE_BORDER = 2 --从屏幕边缘开始算
NEWER_POS_TYPE_BASE_MAP = 3 --基地地图上坐标
NEWER_POS_TYPE_COMBAT_MAP = 4 --副本地图上坐标
NEWER_POS_TYPE_WILD_MAP = 5 --野外地图上坐标

function NewerView:ctor()
	NewerView.super.ctor(self, "",nil,{closeBtn = false})

	self._full_screen_ = false
end

function NewerView:onEnter()
	NewerView.super.onEnter(self)
	local rect = CCRectMake(0, 0, display.width, display.height)
	local bgMask = CCSprite:create("image/common/bg_ui.jpg", rect)
	bgMask:setCascadeBoundingBox(rect)
	bgMask:setColor(ccc3(0, 0, 0))
	bgMask:setOpacity(0)
	bgMask:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2)
	self:getBg():addChild(bgMask)
	self.bgMask = bgMask
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
end

function NewerView:init(newerData)
	self.newerData = newerData
	--TK统计 引导开始
	if NewerMO.tdBeginStateId ~= newerData.id then
		TKGameBO.onBegin(TKText[39] .. newerData.id)
		NewerMO.tdBeginStateId = newerData.id
	end
end

function NewerView:setData(process)
	-- self.m_process = process
	NewerMO.guideLockTouch = true

	if process.delay then
        local time = process.delay / 1000
        scheduler.performWithDelayGlobal(function()
            self:setDataEx(process)
            end, time)
    else
        self:setDataEx(process)
    end
end

function NewerView:setDataEx(process)
	NewerMO.guideLockTouch = false
	-- gdump(process,"引导数据")
	-- if self.container then
	-- 	self:getBg():removeChild(self.container)
	-- end
	self.m_process = process

	local container = display.newNode()
	self:getBg():addChild(container)

	self.container = container

	local viewWidth = self:getBg():getContentSize().width
	local viewHeight = self:getBg():getContentSize().height
	local centerX = viewWidth / 2
	local centerY = viewHeight / 2

	--跳过引导按钮
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_42_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_42_selected.png")
	-- local skipBtn = MenuButton.new(normal, selected, disabled, handler(self,self.skipNewer)):addTo(container)
	-- skipBtn:setPosition(viewWidth - skipBtn:getContentSize().width / 2, skipBtn:getContentSize().height / 2)
	-- skipBtn:setVisible(self.newerData.id > 20 and self.newerData.id < 170)

	--对话框
	local info = process.info
	if info then
		self.bgMask:setOpacity(185)
		-- local picVec = info.picVec or 0 -- 0 左边 1 右边
		local infoBg = display.newSprite(IMAGE_COMMON .. "guide/info_bg_2.png"):addTo(container)
		if info.posType == NEWER_POS_TYPE_CENTER then
			infoBg:setPosition(centerX + info.x, viewHeight * 0.25 + info.y)
		elseif info.posType == NEWER_POS_TYPE_BORDER then
			local infoBgX, infoBgY
			if info.x >= 0 then
				infoBgX = info.x + infoBg:getContentSize().width / 2
			else
				infoBgX = viewWidth + info.x - infoBg:getContentSize().width / 2
			end
			
			if info.y >= 0 then
				infoBgY = info.y + infoBg:getContentSize().height / 2
			else
				infoBgY = viewHeight + info.y - infoBg:getContentSize().height / 2
			end
			infoBg:setPosition(infoBgX, infoBgY)
		end

		local rolePic
		local name = ""
		if info.picType and info.picType == 2 then
			rolePic = display.newSprite(IMAGE_COMMON .. "guide/role_4.png"):addTo(infoBg, -1)
			rolePic.y = 440
			name = CommonText[1797][1]
		elseif info.picType and info.picType == 3 then
			rolePic = display.newSprite(IMAGE_COMMON .. "guide/role_5.png"):addTo(infoBg, -1)
			rolePic.y = 440
			name = CommonText[1797][3]
		else
			rolePic = display.newSprite(IMAGE_COMMON .. "guide/role_3.png"):addTo(infoBg, -1)
			rolePic.y = 440
			name = CommonText[1797][2]
		end

		local nameLab = ui.newTTFLabel({text = name, font = G_FONT, size = 40,
			color = cc.c3b(255, 255, 255) , align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(infoBg)
		nameLab:setPosition(114,230)
		
		local msgLab = ui.newTTFLabel({text = info.text, font = G_FONT, size = 26,
			color = COLOR[1], align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
	   		dimensions = cc.size(520, 180)}):addTo(infoBg)
		-- msgLab:setAnchorPoint(cc.p(0, 1))
		msgLab:setPosition(320, 105)

		local anyLab = ui.newTTFLabel({text = CommonText[1798], font = G_FONT, size = 20,
			color = COLOR[1], align = ui.TEXT_ALIGN_CENTER,valign = ui.TEXT_VALIGN_CENTER}):addTo(infoBg)
		anyLab:setPosition(infoBg:width() - 104, 25)

		if info.picType and (info.picType == 2 or info.picType == 3) then
			rolePic:setPosition(infoBg:getContentSize().width - rolePic:getContentSize().width / 2 ,rolePic.y)

			-- msgLab:setPosition(70, 135)
			-- msgLab:setAnchorPoint(cc.p(0, 1))
		else
			rolePic:setPosition(rolePic:getContentSize().width / 2,rolePic.y)

			-- msgLab:setPosition(240, 135)
			-- msgLab:setAnchorPoint(cc.p(0, 1))
		end
		--
		--动画
		-- infoBg:runAction(transition.sequence({cc.MoveTo:create(0.5, cc.p(infoBgX, infoBg:getPositionY())),
		-- 	cc.CallFunc:create(function() end)}))

		self.infoBg = infoBg
	end

	--箭头
	local arrow = process.arrow
	if arrow then
		self.bgMask:setOpacity(0)
		self.canClick = false
		-- local arrowPic = display.newSprite(IMAGE_COMMON .. "guide/icon_locationi.png"):addTo(container)
		-- --箭头动画
		-- arrowPic:setScale(0.8)

		-- arrowPic:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0.5, 1), cc.ScaleTo:create(0.5, 0.8)})))
		local arrowPic = CCArmature:create("ryxz_dianji")
        arrowPic:getAnimation():playWithIndex(0)
        arrowPic:connectMovementEventSignal(function(movementType, movementID) end)
        arrowPic:setPosition(NewerMO.guideArrowX, NewerMO.guideArrowY)
        container:addChild(arrowPic)

        local arrowX,arrowY

		if arrow.posType == NEWER_POS_TYPE_CENTER then
			-- arrowPic:setPosition(centerX + arrow.x,centerY + arrow.y)
			arrowX = centerX + arrow.x
			arrowY = centerY + arrow.y
		elseif arrow.posType == NEWER_POS_TYPE_BORDER then
			if arrow.x >= 0 then
				-- arrowPic:setPositionX(arrow.x)
				arrowX = arrow.x
			else
				-- arrowPic:setPositionX(viewWidth + arrow.x)
				arrowX = viewWidth + arrow.x
			end
			if arrow.y >= 0 then
				-- arrowPic:setPositionY(arrow.y)
				arrowY = arrow.y
			else
				-- arrowPic:setPositionY(viewHeight + arrow.y)
				arrowY = viewHeight + arrow.y
			end
		elseif arrow.posType == NEWER_POS_TYPE_BASE_MAP then
			local bgLeft = display.newSprite("image/bg/bg_main_1_1.jpg")

			local offsetY = (display.height - bgLeft:getContentSize().height) / 2

			local offset = UiDirector.getUiByName("HomeView"):getTableOffSet()
			if arrow.buildId then
				for buildIndex = 1, #HomeBaseMapConfig do
					local config = HomeBaseMapConfig[buildIndex]
					if config then
						local x = config.x or 0
						local y = config.y or 0
						if config.id == arrow.buildId then
							-- arrowPic:setPosition(x + offset.x , y + offset.y + offsetY + 70)
							arrowX = x + offset.x
							arrowY = y + offset.y + offsetY + 70
						end
					end
				end
			end
		elseif arrow.posType == NEWER_POS_TYPE_COMBAT_MAP then
			local offset = UiDirector.getUiByName("CombatLevelView"):getTableOffSet()
			if arrow.combatId then
				local config = CombatMO.getCombatViewById(COMBAT_TYPE_COMBAT, arrow.combatId)
				if config then
					local x = (config.offset[1] or 0) + (display.cx - 320)
					local y = config.offset[2] or 0
					-- arrowPic:setPosition(x + offset.x, y + offset.y + 60)
					arrowX = x + offset.x
					arrowY = y + offset.y + 60
				end
			end
		elseif arrow.posType == NEWER_POS_TYPE_WILD_MAP then
			local bgLeft = display.newSprite("image/bg/bg_wild_1_1.jpg")
			local offsetY = (display.height - bgLeft:getContentSize().height) / 2


			local offset = UiDirector.getUiByName("HomeView"):getTableOffSet()
			-- arrowPic:setPosition(HomeWildPos[1].x + offset.x , HomeWildPos[1].y + offset.y + offsetY + 50)
			arrowX = HomeWildPos[1].x + offset.x
			arrowY = HomeWildPos[1].y + offset.y + offsetY + 50

		end
		local pic = CCRectMake(0, 0, self.m_process.arrow.width, self.m_process.arrow.height)
		local clickRect = CCSprite:create("image/common/bg_ui.jpg", pic)
		container:addChild(clickRect)
		-- clickRect:setPosition(arrowPic:getPositionX(), arrowPic:getPositionY())
		clickRect:setCascadeBoundingBox(pic)
		clickRect:setColor(ccc3(255, 0, 0))
		clickRect:setOpacity(1)
		arrowPic.clickRect = clickRect

		local distance = math.floor(math.sqrt((arrowX-NewerMO.guideArrowX)*(arrowX-NewerMO.guideArrowX)+(arrowY-NewerMO.guideArrowY)*(arrowY-NewerMO.guideArrowY)))
		-- gdump(distance,"distancedistance:")
		local effectTime = distance / 2000
		--动画
		arrowPic:runAction(transition.sequence({cc.MoveTo:create(effectTime, cc.p(arrowX, arrowY)),
			cc.CallFunc:create(function() 
				self.canClick = true 
				clickRect:setPosition(arrowPic:getPositionX(), arrowPic:getPositionY()) 
				NewerMO.guideArrowX = arrowPic:getPositionX()
				NewerMO.guideArrowY = arrowPic:getPositionY()
			end)}))


		self.m_arrowPic = arrowPic
	end

	-- 动画
	local action = process.action
	if action then
		self.bgMask:setOpacity(0)

		local actionName = action.name

		armature_add(IMAGE_ANIMATION .. "newer/".. actionName .. ".pvr.ccz", IMAGE_ANIMATION .. "newer/".. actionName .. ".plist", IMAGE_ANIMATION .. "newer/".. actionName .. ".xml")

		local actionPic = CCArmature:create(actionName)
        actionPic:getAnimation():playWithIndex(0)
        actionPic:connectMovementEventSignal(function(movementType, movementID) end)
        actionPic:setPosition(NewerMO.guideActionX, NewerMO.guideActionY)
        container:addChild(actionPic)

        local actionX = 0 
        local actionY = 0

        if action.posType == NEWER_POS_TYPE_CENTER then

        	actionX = centerX + (action.x or 0)
        	actionY = centerY + (action.y or 0)

        elseif action.posType == NEWER_POS_TYPE_BORDER then

        	if action.x then
        		if action.x >= 0 then
        			actionX = action.x
        		else
        			actionX = viewWidth + action.x
        		end
        	end

        	if action.y then
        		if action.y >= 0 then
        			actionY = action.y
        		else
        			actionY = viewHeight + action.y
        		end
        	end

        elseif action.posType == NEWER_POS_TYPE_COMBAT_MAP then
        	local offset = UiDirector.getUiByName("CombatLevelView"):getTableOffSet()
        	if action.combatId then
				local config = CombatMO.getCombatViewById(COMBAT_TYPE_COMBAT, action.combatId)
				if config then
					local x = (config.offset[1] or 0) + (display.cx - 320)
					local y = config.offset[2] or 0
					-- arrowPic:setPosition(x + offset.x, y + offset.y + 60)
					actionX = x + offset.x + action.x
					actionY = y + offset.y + action.y --+ 60
				end
			end
        else
        	-- 暂不使用
        end
        actionPic:setPosition(actionX, actionY)
	end
end

-- 在每个ui的最下层添加一个node来接受所有的touch事件，避免点击了下层ui
function NewerView:addTouchReceiveNode()
	local touchNode = display.newNode():addTo(self, -1000)
	touchNode:setContentSize(cc.size(display.width, display.height))
	nodeTouchEventProtocol(touchNode, function(event)
		if NewerMO.guideLockTouch then return false end
		if self.m_process.arrow then
			-- gdump(event)
			if self.m_process.info then
				self.infoBg:setVisible(false)
			end
			if event.name == "began" then
				self.touchMoved = false
		        return self:onTouchBegan(event)
		    elseif event.name == "moved" then
		    	self.touchMoved = true
		        self:onTouchMoved(event)
		    elseif event.name == "ended" then
		        self:onTouchEnded(event)
		    else -- cancelled
		        self:onTouchCancelled(event)
		    end

		else
			if self.m_process.info then
				Statistics.postPoint(self.m_process.statid)
			end
			self:onClickHandler()
		end
	 end, nil, true, true)
	self.m_touchNode = touchNode
end

function NewerView:onTouchBegan(event)
	if NewerMO.guideLockTouch then return end
	if self.canClick == false then return end
	local x = event.x
	local y = event.y

	local point = self:getParent():convertToNodeSpace(cc.p(x, y))

	local rect = self.m_arrowPic.clickRect:getBoundingBox()

	if cc.rectContainsPoint(rect, point) then
		if self.m_process.statid then
			Statistics.postPoint(self.m_process.statid)
		end
		gprint("包含")
		if not self.m_process.commond or self.m_process.swallow then
			self.m_touchNode:setTouchSwallowEnabled(false)
		end
		return true
	else
		gprint("不包含")
		self.m_touchNode:setTouchSwallowEnabled(true)
		return true
	end
end

function NewerView:onTouchMoved(event)
	-- self.m_touchNode:setTouchSwallowEnabled(false)
end

function NewerView:onTouchEnded(event)
	if NewerMO.guideLockTouch then return end
	if self.canClick == false then return end
	if self.m_process.moveCancel and self.touchMoved then return end
	-- gdump(event,"NewerView:onTouchEnded(event)")
	local x = event.x
	local y = event.y

	local point = self:getParent():convertToNodeSpace(cc.p(x, y))
	
	local rect = self.m_arrowPic.clickRect:getBoundingBox()

	if cc.rectContainsPoint(rect, point) then
		gprint("包含")
		self:onClickHandler()
	else
		-- gprint("不包含")
	end

end

function NewerView:onTouchCancelled(event, x, y)
end

function NewerView:onClickHandler()
	if self.m_process then
		if self.m_process.save then
			NewerMO.needSaveState = self.newerData.id
			self:onNext(self.m_process)
			--保存进度
			-- NewerBO.saveGuideState(function()
			-- 	self:onNext(self.m_process)
			-- end,self.newerData.id)
		else
			self:onNext(self.m_process)
		end
	end
end

function NewerView:skipNewer()
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(CommonText[701], function()
			--TK统计 引导跳过
			TKGameBO.onFailed(TKText[39] .. self.newerData.id,TKText[43])
			self.newerData.process = {}
			--保存进度
			NewerBO.saveGuideState(function()
				self:onNext(self.m_process)
			end,160)
		end):push()
end


function NewerView:onNext(process)
	-- self.container:setVisible(false)
	UiDirector.dumpUi()
	UiDirector.pop(function()
		NewerBO.doState(process)
		end)
end


function NewerView:onExit()
	NewerView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
	if self.m_process.action then
		armature_remove(IMAGE_ANIMATION .. "newer/" .. self.m_process.action.name .. ".pvr.ccz", IMAGE_ANIMATION .. "newer/" .. self.m_process.action.name .. ".plist", IMAGE_ANIMATION .. "newer/" .. self.m_process.action.name .. ".xml")
	end
end

return NewerView