--
-- Author: gf
-- Date: 2016-04-29 13:45:58
-- 玩家升级

local UserLevelUpView = class("UserLevelUpView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)



function UserLevelUpView:ctor()
	-- self._full_screen_ = false

end

function UserLevelUpView:onEnter()
	armature_add(IMAGE_ANIMATION .. "effect/ui_award_level_up.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_level_up.plist", IMAGE_ANIMATION .. "effect/ui_award_level_up.xml")


	local rect = CCRectMake(0, 0, display.width, display.height)
	local bgMask = CCSprite:create("image/common/bg_ui.jpg", rect)
	bgMask:setCascadeBoundingBox(rect)
	bgMask:setColor(ccc3(0, 0, 0))
	bgMask:setOpacity(150)
	bgMask:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addChild(bgMask)
	self.bgMask = bgMask

	self.m_status = false

	nodeTouchEventProtocol(bgMask, function(event)  
				if self.m_status == true then
					self:removeSelf()
				end
                end, nil, true, true)


    
	ManagerSound.playSound("level_up")
    local armature = armature_create("ui_award_level_up", bgMask:getContentSize().width / 2, bgMask:getContentSize().height / 2 + 200, function (movementType, movementID, armature)
            if movementType == MovementEventType.COMPLETE then
            	local msgList = NewerBO.getLevelUpToast(UserMO.level_)
            	local msgLabList = {}
            	for index=1,#msgList do
            		local labBg = display.newSprite(IMAGE_COMMON .. "info_bg_62.png"):addTo(bgMask)
            		labBg:setAnchorPoint(cc.p(0,0.5))
            		labBg:setPosition(bgMask:getContentSize().width, bgMask:getContentSize().height / 2 - (index - 1) * 60)

            		local lab = ui.newTTFLabel({text = msgList[index].content, font = G_FONT, size = FONT_SIZE_SMALL, 
						 color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(labBg)
					lab:setAnchorPoint(cc.p(0, 0.5))
					lab:setPosition(50,labBg:getContentSize().height / 2)

					local iconBg = display.newSprite(IMAGE_COMMON .. "item_fame_1.png", 0, labBg:getContentSize().height / 2):addTo(labBg)
					iconBg:setScale(0.5)

					local icon = display.newSprite(msgList[index].iconSrc, iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2):addTo(iconBg)

					labBg:runAction(transition.sequence({cc.DelayTime:create(0.2 * (index - 1)),cc.MoveTo:create(0.3, cc.p(bgMask:getContentSize().width / 2 - 130, bgMask:getContentSize().height / 2 - (index - 1) * 60)),
						cc.CallFunc:create(function() 
							if index == #msgList then
								self.m_status = true
								local closeBg = display.newSprite(IMAGE_COMMON .. "info_bg_38.png", bgMask:getContentSize().width / 2, bgMask:getContentSize().height / 2 - 300):addTo(self.bgMask)
								local closeLab = ui.newTTFLabel({text = CommonText[905], font = G_FONT, size = FONT_SIZE_SMALL, 
									 color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(closeBg)
								closeLab:setAnchorPoint(cc.p(0.5, 0.5))
								closeLab:setPosition(closeBg:getContentSize().width / 2,closeBg:getContentSize().height / 2)
							end
					end)}))
            	end                
            end
        end):addTo(bgMask)
    armature:getAnimation():playWithIndex(0)

    if EquipMO.reCheck ~= 0 then
		EquipMO.reCheck = 0
		Loading.getInstance():show()
		EquipBO.asynGetEquip(function() Loading.getInstance():unshow() end)
    end
end




function UserLevelUpView:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/ui_award_level_up.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_award_level_up.plist", IMAGE_ANIMATION .. "effect/ui_award_level_up.xml")
	 --升级触发引导
    TriggerGuideBO.showLevelUpGuide()
end

return UserLevelUpView