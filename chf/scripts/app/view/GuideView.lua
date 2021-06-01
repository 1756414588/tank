--
-- Author: gf
-- Date: 2015-10-17 11:08:07
-- 任务指引

local GuideView = class("GuideView", UiNode)

NEWER_POS_TYPE_CENTER = 1 --从屏幕中间开始算
NEWER_POS_TYPE_BORDER = 2 --从屏幕边缘开始算
NEWER_POS_TYPE_BASE_MAP = 3 --基地地图上坐标
NEWER_POS_TYPE_COMBAT_MAP = 4 --副本地图上坐标
NEWER_POS_TYPE_WILD_MAP = 5 --野外地图上坐标
NEWER_POS_TYPE_PARTY_MAP = 6 --军团地图上坐标

function GuideView:ctor()
	GuideView.super.ctor(self, "",nil,{closeBtn = false})

	self._full_screen_ = false
end

function GuideView:onEnter()
	GuideView.super.onEnter(self)
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

function GuideView:init()
	
end

function GuideView:setData(process)
	-- gdump(process,"process============")
	if self.container then
		self:getBg():removeChild(self.container)
	end
	self.m_process = process

	local container = display.newNode():addTo(self:getBg())

	self.container = container

	local viewWidth = self:getBg():getContentSize().width
	local viewHeight = self:getBg():getContentSize().height
	local centerX = viewWidth / 2
	local centerY = viewHeight / 2

	
	--对话框
	local info = process.info
	if info then
		self.bgMask:setOpacity(100)
		local infoBgX
		local infoBg = display.newSprite(IMAGE_COMMON .. "guide/info_bg_1.png"):addTo(container)
		if info.posType == NEWER_POS_TYPE_CENTER then
			infoBgX = centerX + info.x
			infoBg:setPositionX(-infoBg:getContentSize().width / 2)
			infoBg:setPositionY(centerY + info.y)
		elseif info.posType == NEWER_POS_TYPE_BORDER then
			if info.x >= 0 then
				-- infoBg:setPositionX(info.x + infoBg:getContentSize().width / 2)
				infoBgX = info.x + infoBg:getContentSize().width / 2
			else
				-- infoBg:setPositionX(viewWidth + info.x - infoBg:getContentSize().width / 2)
				infoBgX = viewWidth + info.x - infoBg:getContentSize().width / 2
			end
			if info.y >= 0 then
				infoBg:setPositionY(info.y + infoBg:getContentSize().height / 2)
			else
				infoBg:setPositionY(viewHeight + info.y - infoBg:getContentSize().height / 2)
			end
		end
		local rolePic
		if info.picType then
			rolePic = display.newSprite(IMAGE_COMMON .. "guide/role_2.png"):addTo(infoBg)
		else
			rolePic = display.newSprite(IMAGE_COMMON .. "guide/role_1.png"):addTo(infoBg)
		end
		
		rolePic:setPosition(rolePic:getContentSize().width / 2 + 20,145)

		local msgLab = ui.newTTFLabel({text = info.text, font = G_FONT, size = FONT_SIZE_SMALL, 
	   		x = 10, y = infoBg:getContentSize().height - 30, color = COLOR[1], 
	   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
	   		dimensions = cc.size(260, 95)}):addTo(infoBg)
		msgLab:setPosition(240, 135)
		msgLab:setAnchorPoint(cc.p(0, 1))

		local pic1 = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png"):addTo(infoBg)
		pic1:setPosition(520, 60)
		pic1:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveTo:create(0.5, cc.p(540, 60)), cc.MoveTo:create(0.5, cc.p(520, 60))})))

		--动画
		infoBg:runAction(transition.sequence({cc.MoveTo:create(0.5, cc.p(infoBgX, infoBg:getPositionY())),
			cc.CallFunc:create(function() end)}))

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
        arrowPic:setPosition(TaskGuideMO.guideArrowX, TaskGuideMO.guideArrowY)
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
		elseif arrow.posType == NEWER_POS_TYPE_PARTY_MAP then
			local bgLeft = display.newSprite("image/bg/bg_party_1_1.jpg")

			local offsetY = (display.height - bgLeft:getContentSize().height) / 2

			local offset = UiDirector.getUiByName("HomeView"):getTableOffSet()
			if arrow.buildId then
				for buildIndex = 1, #HomePartyMapConfig do
					local config = HomePartyMapConfig[buildIndex]
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
					local x = config.offset[1] or 0
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

		local distance = math.floor(math.sqrt((arrowX-TaskGuideMO.guideArrowX)*(arrowX-TaskGuideMO.guideArrowX)+(arrowY-TaskGuideMO.guideArrowY)*(arrowY-TaskGuideMO.guideArrowY)))
		-- gdump(distance,"distancedistance:")
		local effectTime = distance / 2000
		--动画
		arrowPic:runAction(transition.sequence({cc.MoveTo:create(effectTime, cc.p(arrowX, arrowY)),
			cc.CallFunc:create(function() 
				self.canClick = true 
				clickRect:setPosition(arrowPic:getPositionX(), arrowPic:getPositionY()) 
			end)}))


		self.m_arrowPic = arrowPic
	end
end

-- 在每个ui的最下层添加一个node来接受所有的touch事件，避免点击了下层ui
function GuideView:addTouchReceiveNode()
	local touchNode = display.newNode():addTo(self, -1000)
	touchNode:setContentSize(cc.size(display.width, display.height))
	nodeTouchEventProtocol(touchNode, function(event)
		if self.m_process.arrow then
			-- gdump(event)
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
			self:onClickHandler()
		end
	 end, nil, true, true)
	self.m_touchNode = touchNode
end

function GuideView:onTouchBegan(event)
	if self.canClick == false then return end
	local x = event.x
	local y = event.y

	local point = self:getParent():convertToNodeSpace(cc.p(x, y))

	local rect = self.m_arrowPic.clickRect:getBoundingBox()

	if cc.rectContainsPoint(rect, point) then
		-- gprint("包含")
		if not self.m_process.commond then
			self.m_touchNode:setTouchSwallowEnabled(false)
		end
		return true
	else
		-- gprint("不包含")
		self.m_touchNode:setTouchSwallowEnabled(true)
		return true
	end
end

function GuideView:onTouchMoved(event)
	self.m_touchNode:setTouchSwallowEnabled(false)
end

function GuideView:onTouchEnded(event)
	if self.canClick == false then return end
	if self.m_process.moveCancel and self.touchMoved then return end
	-- gdump(event,"GuideView:onTouchEnded(event)")
	local x = event.x
	local y = event.y

	local point = self:getParent():convertToNodeSpace(cc.p(x, y))
	
	local rect = self.m_arrowPic.clickRect:getBoundingBox()

	-- if cc.rectContainsPoint(rect, point) then
	-- 	-- gprint("包含")
	-- 	self:onClickHandler()
	-- else
	-- 	-- gprint("不包含")
	-- end
	self:onClickHandler()

end

function GuideView:onTouchCancelled(event, x, y)
end

function GuideView:onClickHandler()
	if self.m_process then
		self:onNext(self.m_process)
	end
end




function GuideView:onNext(process)
	--空闲状态引导
	if self.m_process.kind == 600 then
		TaskGuideMO.showFreeGuideStatus = false
	end
	self.container:setVisible(false)
	UiDirector.pop()
	if process and process.callBack then
		TaskGuideMO.doCallBack(process.callBack)
	end
	
	-- NewerBO.doState(process)
end


function GuideView:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
end

return GuideView