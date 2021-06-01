--
-- 新教程 CG
--
--

local NewerCGGuideView = class("NewerCGGuideView", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function NewerCGGuideView:ctor(size)
	self:setContentSize(size)
	-- nodeTouchEventProtocol(self, function() end, nil, nil, true)
	 nodeTouchEventProtocol(self, function(event)
        return self:onTouch(event)
    end, cc.TOUCH_MODE_ALL_AT_ONCE, nil, true)
end

function NewerCGGuideView:onEnter()
	-- 0 没有启动
	-- 1 第一段动画

	-- ManagerSound.playSound("conveyor")

	armature_add("animation/cg/xsyd_baozha.pvr.ccz", "animation/cg/xsyd_baozha.plist", "animation/cg/xsyd_baozha.xml")
	armature_add("animation/cg/xsyd_baozha2.pvr.ccz", "animation/cg/xsyd_baozha2.plist", "animation/cg/xsyd_baozha2.xml")
	-- armature_add("animation/cg/xsyd_feiji.pvr.ccz", "animation/cg/xsyd_feiji.plist", "animation/cg/xsyd_feiji.xml")
	armature_add("animation/cg/xsyd_jidiche.pvr.ccz", "animation/cg/xsyd_jidiche.plist", "animation/cg/xsyd_jidiche.xml")
	armature_add("animation/cg/xsyd_jidiche_shouji.pvr.ccz", "animation/cg/xsyd_jidiche_shouji.plist", "animation/cg/xsyd_jidiche_shouji.xml")
	-- armature_add("animation/cg/xsyd_ren_tiaosan.pvr.ccz", "animation/cg/xsyd_ren_tiaosan.plist", "animation/cg/xsyd_ren_tiaosan.xml")
	-- armature_add("animation/cg/xsyd_ren1.pvr.ccz", "animation/cg/xsyd_ren1.plist", "animation/cg/xsyd_ren1.xml")

	self.m_cgState = 0 

	self.m_touchState = false

	-- 蒙层
	local blackbg = display.newColorLayer(ccc4(0, 0, 0, 255)):addTo(self, -1)
	blackbg:setContentSize(cc.size(display.width, display.height))
	blackbg:setPosition(0, 0)

	local screen = display.newNode():addTo(self)
	screen:setPosition(0,0)
	self.m_screenNode = screen


	local skipNode = display.newNode():addTo(self, 2)
	skipNode:setContentSize(cc.size(160,50))
	skipNode:setPosition(self:width() - 160, 30)
	self.m_skip = skipNode

	local skiplb = ui.newTTFLabel({text = CommonText[1088][1], font = G_FONT, size = 26, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(skipNode)
	skiplb:setPosition(skipNode:width() * 0.5 - 20, skipNode:height() * 0.5)

	local normal = display.newSprite(IMAGE_COMMON .. "cg/skip.png"):addTo(skipNode)
	normal:setPosition(skipNode:width() * 0.5 + 50, skipNode:height() * 0.5)

	skipNode:setTouchEnabled(true)
	skipNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "ended" then
			ManagerSound.playNormalButtonSound()
			Statistics.postPoint(ST_P_1)
			ManagerSound.stopSound()
			self.m_cgState = 9
		end
		return true
	end)


	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()

    self.m_cgState = 1

    NewerBO.saveGuideState(nil,1)
end



function NewerCGGuideView:onEnterFrame(dt)
	if self.m_cgState then
		if self.m_cgState == 1 then
			self:CGState1()
		elseif self.m_cgState == 3 then
			self:CGState3()
		elseif self.m_cgState == 5 then
			self:CGState5()
		elseif self.m_cgState == 7 then
			self:CGState7()
		elseif self.m_cgState == 8 then
			self:CGTime8()
		elseif self.m_cgState == 9 then
			-- self:CGOver()
			self:CGState9()
		elseif self.m_cgState == 11 then
			self:CGState11()
		elseif self.m_cgState == 13 then
			self:CGState13()
		elseif self.m_cgState == 15 then
			self:CGState15()
		elseif self.m_cgState == 17 then
			self:CGOver()
		end 
	end
end

function NewerCGGuideView:CGOver()
	Statistics.postPoint(ST_P_5)
	self.m_cgState = 18
	self:close()	
end

function NewerCGGuideView:CGState15()	
	self.m_cgState = 16
	if self.m_screenNode.black then
		self.m_screenNode.black:stopAllActions()
		self.m_screenNode.black:removeSelf()
		self.m_screenNode.black = nil
	end

	-- 黑色蒙层
	local black = display.newColorLayer(ccc4(0, 0, 0, 80)):addTo(self.m_screenNode, 11)
	black:setContentSize(cc.size(display.width, display.height))
	black:setPosition(0, 0)
	self.m_screenNode.black = black

	local bg = display.newSprite(IMAGE_COMMON .. "guide/info_bg_2.png"):addTo(black, 12)
	bg:setPosition(self:width() * 0.5, self:width() * 0.25)

	local people = display.newSprite(IMAGE_COMMON .. "guide/role_3.png"):addTo(bg)
	people:setPosition(people:getContentSize().width * 0.5, 440)

	local nameLab = ui.newTTFLabel({text = CommonText[1797][2], font = G_FONT, size = 40,
			color = cc.c3b(255, 255, 255) , align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(bg)
		nameLab:setPosition(114,230)

	local msgLab = ui.newTTFLabel({text = CommonText[1799][3], font = G_FONT, size = 26,
			color = cc.c3b(235, 235, 235), align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
	   		dimensions = cc.size(520, 180)}):addTo(bg)
	msgLab:setPosition(320, 105)

	local tipLab = ui.newTTFLabel({text = CommonText[1798], font = G_FONT, size = 20,
			color = cc.c3b(200, 200, 200) , align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(bg)
		tipLab:setPosition(540,20)

	black:runAction(transition.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function()
		self.m_touchState = true
	end)}))
end

function NewerCGGuideView:CGState13()
	self.m_cgState = 14
	self.m_touchState = false
	self.m_screenNode.black:stopAllActions()
	self.m_screenNode.black:removeSelf()
	self.m_screenNode.black = nil


	-- local tank8 = display.newSprite(IMAGE_COMMON .. "cg/cgtank1.png"):addTo(self.m_screenNode.bg4 , 1)
	-- tank8:setScale(0.7)
	-- -- tank7:setScaleX(-1)
	-- tank8:setPosition(2123,778)
	-- self.m_screenNode.tank8 = tank8

	local tank7 = display.newSprite(IMAGE_COMMON .. "cg/cgtank1.png"):addTo(self.m_screenNode.bg4 , 6)
	tank7:setScale(2.8)
	-- tank7:setScaleX(-1)
	tank7:setPosition(2103,378)
	self.m_screenNode.tank7 = tank7

	-- tank7:runAction(cc.MoveTo:create(1.5, cc.p(1683,728)))
	ManagerSound.playSound("cg_yuanjun")
	self.m_screenNode.bg4:runAction(transition.sequence({cc.CallFunc:create(function()
		tank7:runAction(cc.MoveBy:create(1.2,cc.p(-400, 100)))
	end),
	cc.DelayTime:create(0.3),
	-- cc.CallFunc:create(function()
	-- 	tank8:runAction(cc.MoveBy:create(1.5,cc.p(-200, 50)))
	-- end),
	cc.DelayTime:create(1),
	cc.CallFunc:create(function()
		self.m_cgState = 15
	end)
		}))

end

function NewerCGGuideView:CGState11()
	Statistics.postPoint(ST_P_3)
	self.m_cgState = 12

	self.m_screenNode.black:stopAllActions()
	self.m_screenNode.black:removeSelf()
	self.m_screenNode.black = nil

	-- 黑色蒙层
	local black = display.newColorLayer(ccc4(0, 0, 0, 80)):addTo(self.m_screenNode, 11)
	black:setContentSize(cc.size(display.width, display.height))
	black:setPosition(0, 0)
	self.m_screenNode.black = black

	local bg = display.newSprite(IMAGE_COMMON .. "guide/info_bg_2.png"):addTo(black , 12)
	bg:setPosition(self:width() * 0.5, self:width() * 0.25)

	local people2 = display.newSprite(IMAGE_COMMON .. "guide/role_4.png"):addTo(bg)
	people2:setPosition(bg:getContentSize().width - people2:getContentSize().width / 2 ,440)

	local nameLab = ui.newTTFLabel({text = CommonText[1797][1], font = G_FONT, size = 40,
			color = cc.c3b(255, 255, 255) , align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(bg)
		nameLab:setPosition(114,230)

	local msgLab = ui.newTTFLabel({text = CommonText[1799][1], font = G_FONT, size = 26,
			color = cc.c3b(235, 235, 235), align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
	   		dimensions = cc.size(520, 180)}):addTo(bg)
	msgLab:setPosition(320, 105)

	local tipLab = ui.newTTFLabel({text = CommonText[1798], font = G_FONT, size = 20,
			color = cc.c3b(200, 200, 200) , align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(bg)
		tipLab:setPosition(540,20)

	

	black:runAction(transition.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function()
		self.m_touchState = true
	end)}))
end

function NewerCGGuideView:CGState9()
	self.m_cgState = 10
	-- self.m_screenNode.tank4baozha:stopAllActions()
	-- self.m_screenNode.tank4baozha:removeSelf()

	-- self.m_screenNode.tank3baozha:stopAllActions()
	-- self.m_screenNode.tank3baozha:removeSelf()

	self.m_skip:removeAllChildren()
	self.m_skip:removeSelf()
	self.m_skip = nil

	self.m_screenNode:stopAllActions()
	self.m_screenNode:removeAllChildren()

	local bg4 = display.newSprite(IMAGE_COMMON .. "cg/bg3.jpg"):addTo(self.m_screenNode, 10)
	bg4:setAnchorPoint(cc.p(1,0.5))
	bg4:setPosition(self:width(), display.height * 0.5)
	self.m_screenNode.bg4 = bg4

	
	local tank5 = display.newSprite(IMAGE_COMMON .. "cg/cgtank2.png"):addTo(bg4 , 1)
	tank5:setScale(0.75)
	tank5:setPosition(1606,830)
	self.m_screenNode.tank5 = tank5


	local tank6 = display.newSprite(IMAGE_COMMON .. "cg/cgtank2.png"):addTo(bg4 , 5)
	tank6:setScale(2.5)
	tank6:setPosition(1983,578)
	self.m_screenNode.tank6 = tank6

	-- 黑色蒙层
	local black = display.newColorLayer(ccc4(0, 0, 0, 80)):addTo(self.m_screenNode, 11)
	black:setContentSize(cc.size(display.width, display.height))
	black:setPosition(0, 0)
	self.m_screenNode.black = black

	local bg = display.newSprite(IMAGE_COMMON .. "guide/info_bg_2.png"):addTo(black , 12)
	bg:setPosition(self:width() * 0.5, self:width() * 0.25)

	local people2 = display.newSprite(IMAGE_COMMON .. "guide/role_3.png"):addTo(bg)
	people2:setPosition(people2:width() * 0.5, 440)

	local nameLab = ui.newTTFLabel({text = CommonText[1797][2], font = G_FONT, size = 40,
			color = cc.c3b(255, 255, 255) , align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(bg)
		nameLab:setPosition(114,230)

	local msgLab = ui.newTTFLabel({text = CommonText[1799][2], font = G_FONT, size = 26,
			color = cc.c3b(235, 235, 235), align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
	   		dimensions = cc.size(520, 180)}):addTo(bg)
	msgLab:setPosition(320, 105)

	local tipLab = ui.newTTFLabel({text = CommonText[1798], font = G_FONT, size = 20,
			color = cc.c3b(200, 200, 200) , align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(bg)
		tipLab:setPosition(540,20)

	

	black:runAction(transition.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function()
		self.m_touchState = true
	end)}))

	-- black:setTouchEnabled(true)
	-- black:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	--     if event.name == "ended" then
	--         if not self.m_touchState then
	--         	self.m_touchState = true
	--         end
	--     end
	--     return true
	-- end)
end

function NewerCGGuideView:CGTime8()
	self.m_screenNode.cgtime8 = math.floor(self.m_screenNode.cgtime8 + 1)



	if math.floor(self.m_screenNode.cgtime8) == 1 then

		local firezidan = {
			[1] = {from = cc.p(-86,662), to = cc.p(204,640), delay = 0.1, zorder = 4},
			[2] = {from = cc.p(-41,639), to = cc.p(238,537), delay = 0.2, zorder = 4},
			[3] = {from = cc.p(-103,762), to = cc.p(157,439), delay = 0.5, zorder = 2},
			[4] = {from = cc.p(-109,627), to = cc.p(162,632), delay = 0.7, zorder = 0},
			[5] = {from = cc.p(-106,694), to = cc.p(293,534), delay = 0.8, zorder = 4},	
			[6] = {from = cc.p(-108,838), to = cc.p(172,791), delay = 0.9, zorder = 2},
			[7] = {from = cc.p(-100,285), to = cc.p(162,260), delay = 1.1, zorder = 6},
			[8] = {from = cc.p(-90,874), to = cc.p(382,749), delay = 1.2, zorder = 2},		
			[9] = {from = cc.p(-44,111), to = cc.p(204,67), delay = 1.3, zorder = 6},	
			[10] = {from = cc.p(-86,662), to = cc.p(204,640), delay = 1.6, zorder = 4},
			[11] = {from = cc.p(-41,639), to = cc.p(238,537), delay = 1.7, zorder = 4},
			[12] = {from = cc.p(-103,762), to = cc.p(157,439), delay = 2, zorder = 2},
			[13] = {from = cc.p(-109,627), to = cc.p(162,632), delay = 2.2, zorder = 0},
			[14] = {from = cc.p(-106,694), to = cc.p(293,534), delay = 2.3, zorder = 4},	
			[15] = {from = cc.p(-108,838), to = cc.p(172,791), delay = 2.4, zorder = 2},
			[16] = {from = cc.p(-100,285), to = cc.p(162,260), delay = 2.6, zorder = 6},
			[17] = {from = cc.p(-90,874), to = cc.p(382,749), delay = 2.8, zorder = 2},		
			[18] = {from = cc.p(-44,111), to = cc.p(204,67), delay = 3.0, zorder = 6},					
		}

		local firezidanitem = {}

		for index = 1, #firezidan do
			local info = firezidan[index]

			local zidan = display.newSprite(IMAGE_COMMON .. "cg/zidan.png"):addTo(self.m_screenNode, 10 + info.zorder)
			zidan:setAnchorPoint(cc.p(1, 0.5))

			local _fv = cc.p(info.from.x , info.from.y)
			local _tv = cc.p(self:width() + zidan:width() + info.to.x, info.to.y)

			local fromVec = Vec(_fv.x, _fv.y)
			local toVec = Vec(_tv.x, _tv.y)
			local _xwidth = toVec.x - fromVec.x
			local _yheight = toVec.y - fromVec.y
			local va = Vec(1, 0)
			local vb = Vec(_xwidth, _yheight)
			local _ra = (va * vb) / (va.modulus() * vb.modulus())
			local rotation = math.deg(math.acos( _ra ))

			zidan:setRotation(rotation)
			zidan:setPosition(_fv.x, _fv.y)
			zidan:runAction(transition.sequence({cc.DelayTime:create(info.delay), cc.MoveTo:create(0.1, cc.p(_tv.x, _tv.y)), cc.CallFuncN:create(function(sender)
				sender:removeSelf()
			end)}))

			firezidanitem[#firezidanitem + 1] = zidan
		end

		self.m_screenNode.firezidanitem = firezidanitem
	end

	-- -- 人 小爆炸
	-- if math.floor(self.m_screenNode.cgtime8) == 10 then
	-- 	local peplebaozha = armature_create("xsyd_baozha", self.m_screenNode.peple1:x() - 31,self.m_screenNode.peple1:y() - 47,function (movementType, movementID, armature)
	-- 		if movementType == MovementEventType.COMPLETE then
	-- 			armature:removeSelf()
	-- 		end
	-- 	end):addTo(self.m_screenNode.bg3, 4)
	-- 	peplebaozha:getAnimation():playWithIndex(0)
	-- 	ManagerSound.playSound("tankehit")
	-- end

	-- -- 坦克1 爆炸
	-- if math.floor(self.m_screenNode.cgtime8) == 50 then
	-- 	local tank1baozha = armature_create("xsyd_baozha2", self.m_screenNode.tank1:x() - 31,self.m_screenNode.tank1:y() - 47,function (movementType, movementID, armature)
	-- 		if movementType == MovementEventType.COMPLETE then
	-- 			armature:removeSelf()
	-- 		end
	-- 	end):addTo(self.m_screenNode.bg3, 2)
	-- 	tank1baozha:getAnimation():playWithIndex(0)
	-- 	tank1baozha:setScale(0.8)
	-- 	ManagerSound.playSound("tankdieburn1")
	-- end

	-- -- 坦克1  报废
	-- if math.floor(self.m_screenNode.cgtime8) == 70 then
	-- 	self.m_screenNode.tank1:removeSelf()
	-- 	local tank1 = display.newSprite(IMAGE_COMMON .. "cg/cgtank2.png"):addTo(self.m_screenNode.bg3 , 1)
	-- 	tank1:setScale(0.75)
	-- 	tank1:setPosition(440,830)
	-- 	self.m_screenNode.tank1 = tank1

	-- end
	
	-- -- 坦克2 爆炸
	-- if math.floor(self.m_screenNode.cgtime8) == 80 then
	-- 	local tank2baozha = armature_create("xsyd_baozha2", self.m_screenNode.tank2:x() - 31 + 99,self.m_screenNode.tank2:y() - 47 - 155 + 80,function (movementType, movementID, armature)
	-- 		if movementType == MovementEventType.COMPLETE then
	-- 			armature:removeSelf()
	-- 		end
	-- 	end):addTo(self.m_screenNode.bg3, 6)
	-- 	tank2baozha:getAnimation():playWithIndex(0)
	-- 	tank2baozha:setScale(2)
	-- 	ManagerSound.playSound("tankdieburn1")
	-- end

	-- -- 坦克2 报废
	-- if math.floor(self.m_screenNode.cgtime8) == 100 then
	-- 	self.m_screenNode.tank2:removeSelf()
	-- 	local tank2 = display.newSprite(IMAGE_COMMON .. "cg/cgtank2.png"):addTo(self.m_screenNode.bg3 , 5)
	-- 	tank2:setScale(2.5)
	-- 	tank2:setPosition(150,578)
	-- 	self.m_screenNode.tank2 = tank2
	-- end

	-- -- 人 报废
	-- if math.floor(self.m_screenNode.cgtime8) == 90 then
	-- 	self.m_screenNode.peple1:removeSelf()
	-- end



	-- 移屏
	if math.floor(self.m_screenNode.cgtime8) == 120 then
		self.m_screenNode.bg3:runAction(cc.MoveBy:create(0.6, cc.p(self:width() - self.m_screenNode.bg3:width(),0)))
	end



	-- 坦克3 爆炸
	if math.floor(self.m_screenNode.cgtime8) == 130 then
		ManagerSound.playSound("tankdieburn1")
		local tank3baozha = armature_create("xsyd_baozha2", self.m_screenNode.tank3:x() - 31,self.m_screenNode.tank3:y() - 47,function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end):addTo(self.m_screenNode.bg3, 2)
		tank3baozha:getAnimation():playWithIndex(0)
		tank3baozha:setScale(0.8)
		self.m_screenNode.tank3baozha = tank3baozha
	end

	-- 坦克3  报废
	if math.floor(self.m_screenNode.cgtime8) == 150 then
		self.m_screenNode.tank3:removeSelf()
		local tank3 = display.newSprite(IMAGE_COMMON .. "cg/cgtank2.png"):addTo(self.m_screenNode.bg3 , 1)
		tank3:setScale(0.75)
		tank3:setPosition(1606,830)
		self.m_screenNode.tank3 = tank3
	end

	-- 坦克4 爆炸
	if math.floor(self.m_screenNode.cgtime8) == 160 then
		ManagerSound.playSound("tankdieburn2")
		local tank4baozha = armature_create("xsyd_baozha2", self.m_screenNode.tank4:x() - 31,self.m_screenNode.tank4:y() - 113,function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end):addTo(self.m_screenNode.bg3, 6)
		tank4baozha:getAnimation():playWithIndex(0)
		tank4baozha:setScale(2)
		self.m_screenNode.tank4baozha = tank4baozha
	end

	-- 坦克4 报废
	if math.floor(self.m_screenNode.cgtime8) == 180 then
		self.m_screenNode.tank4:removeSelf()
		local tank4 = display.newSprite(IMAGE_COMMON .. "cg/cgtank2.png"):addTo(self.m_screenNode.bg3 , 5)
		tank4:setScale(2.5)
		tank4:setPosition(1983,578)
		self.m_screenNode.tank4 = tank4
	end

	if math.floor(self.m_screenNode.cgtime8) >= 250 then
		self.m_cgState = 9
	end
	
end

function NewerCGGuideView:CGState7()
	self.m_cgState =  8 -- 8
	self.m_screenNode.cgtime8 = 0

	local bg3 = display.newSprite(IMAGE_COMMON .. "cg/bg3.jpg"):addTo(self.m_screenNode, 10)
	bg3:setAnchorPoint(cc.p(0,0.5))
	bg3:setPosition(0, display.height * 0.5)
	self.m_screenNode.bg3 = bg3

	ManagerSound.playSound("tankAttack1")

	-- local tank1 = display.newSprite(IMAGE_COMMON .. "cg/cgtank1.png"):addTo(bg3 , 1)
	-- tank1:setScale(0.75)
	-- tank1:setPosition(440,830)
	-- self.m_screenNode.tank1 = tank1


	-- local tank1 = display.newSprite(IMAGE_COMMON .. "cg/cgtank3.png"):addTo(bg3 , 1)
	-- local peple1 = display.newSprite(IMAGE_COMMON .. "cg/lottery.png"):addTo(bg3 , 3)
	-- peple1:setScale(0.8)
	-- peple1:setPosition(150 + 82 + 34,578 + 191 + 27)
	-- self.m_screenNode.peple1 = peple1


	-- local tank2 = display.newSprite(IMAGE_COMMON .. "cg/cgtank1.png"):addTo(bg3 , 5)
	-- tank2:setScale(2.5)
	-- tank2:setPosition(150,578)
	-- self.m_screenNode.tank2 = tank2

	local tank0 = display.newSprite(IMAGE_COMMON .. "cg/cgtank3.png"):addTo(bg3 , 1)
	tank0:setScale(0.75)
	tank0:setPosition(440,830)
	self.m_screenNode.tank0 = tank0

	local tank1 = display.newSprite(IMAGE_COMMON .. "cg/cgtank3.png"):addTo(bg3 , 1)
	tank1:setScale(0.8)
	tank1:setPosition(150 + 82 + 34,578 + 191 + 27)
	self.m_screenNode.tank1 = tank1

	local tank2 = display.newSprite(IMAGE_COMMON .. "cg/cgtank3.png"):addTo(bg3 , 1)
	tank2:setScale(2.5)
	tank2:setPosition(150,578)
	self.m_screenNode.tank2 = tank2
	
	local tank3 = display.newSprite(IMAGE_COMMON .. "cg/cgtank1.png"):addTo(bg3 , 1)
	tank3:setScale(0.75)
	tank3:setPosition(1606,830)
	self.m_screenNode.tank3 = tank3


	local tank4 = display.newSprite(IMAGE_COMMON .. "cg/cgtank1.png"):addTo(bg3 , 5)
	tank4:setScale(2.5)
	tank4:setPosition(1983,578)
	self.m_screenNode.tank4 = tank4

	
end


function NewerCGGuideView:CGState5()
	self.m_cgState = 6

	local jidiche = self.m_screenNode.bg2.jidiche
	jidiche:getAnimation():playWithIndex(1)
	ManagerSound.playSound("basecarUp")


	local function over()
		self.m_screenNode.bg2.jidiche:stopAllActions()
		-- self.m_screenNode.bg2.tiaosan:stopAllActions()
		self.m_screenNode.bg2.jidiche:removeSelf()
		-- self.m_screenNode.bg2.tiaosan:removeSelf()
		self.m_screenNode.bg2:stopAllActions()
		self.m_screenNode.bg2:removeSelf()

		self.m_screenNode.bg2.jidiche = nil
		-- self.m_screenNode.bg2.tiaosan = nil
		self.m_screenNode.bg2 = nil

		self.m_cgState = 7
	end

	local function fire()
		-- 攻击
		local gongji = armature_create("xsyd_jidiche_shouji", self.m_screenNode.bg2:width() * 0.5 ,self.m_screenNode.bg2:height() * 0.5 ,function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
				over()
			end
		end):addTo(self.m_screenNode.bg2, 5)
		gongji:getAnimation():playWithIndex(0)
		-- ManagerSound.playSound("tankAttack1")
		
	end

	self.m_screenNode:runAction(transition.sequence({cc.DelayTime:create(2), cc.CallFunc:create(function ()
		fire()
	end)}))
	

end

function NewerCGGuideView:CGState3()
	self.m_cgState = 4

	-- 飞机 跳伞
	-- local function deleteFeiji()
	-- 	self.m_screenNode.feiji:stopAllActions()
	-- 	self.m_screenNode.feiji:removeSelf()
	-- 	self.m_screenNode.feiji = nil
	-- end

	-- local feiji = self.m_screenNode.feiji
	-- local spwArray = cc.Array:create()
	-- spwArray:addObject(CCFadeOut:create(0.1))
	-- spwArray:addObject(transition.sequence({CCScaleTo:create(0.08,5), cc.CallFunc:create(function ()
	-- 	self.m_screenNode.feixingyun:setScale(1)
	-- 	ManagerSound.playSound("opentheumbrella")
	-- end)}))
	-- feiji:runAction(transition.sequence({cc.Spawn:create(spwArray), cc.CallFunc:create(function ()
	-- 	deleteFeiji()
	-- end)}))


	
	local function changeScreen()
		-- body
		-- self.m_screenNode.feixingyun:removeSelf()
		-- self.m_screenNode.feixingyun = nil
		self.m_screenNode.actions = nil
		self.m_screenNode.yun1 = nil
		self.m_screenNode.yun2 = nil
		self.m_screenNode.yun3 = nil
		self.m_screenNode.yun4 = nil
		self.m_screenNode.bg:removeSelf()
		self.m_screenNode.bg = nil

		self.m_screenNode:runAction(transition.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function ()
			self.m_cgState = 5
		end)}))

		
	end


	local function over()

		local bg2 = display.newSprite(IMAGE_COMMON .. "cg/bg2.jpg"):addTo(self.m_screenNode, 0)
		-- bg2:setScale(0.88)
		bg2:setAnchorPoint(cc.p(0.5,0))
		bg2:setPosition(self:width() * 0.5, 0)
		

		-- local spwArray3 = cc.Array:create()
		-- spwArray3:addObject(cc.ScaleTo:create(8,1.0))
		-- spwArray3:addObject()
		bg2:runAction(cc.MoveBy:create(8, cc.p(0,-110)))

		-- 基地车
		local jidiche = armature_create("xsyd_jidiche", bg2:width() * 0.5 + 20,bg2:height() * 0.5 + 100):addTo(bg2, 1)
		jidiche:getAnimation():playWithIndex(0)

		-- 跳伞
		-- local tiaosan = armature_create("xsyd_ren_tiaosan", bg2:width() * 0.5 - 130 ,bg2:height() * 0.5 + 106):addTo(bg2, 2)
		-- tiaosan:getAnimation():playWithIndex(0)
		-- tiaosan:setScale(0.2)

		self.m_screenNode.bg2 = bg2
		self.m_screenNode.bg2.jidiche = jidiche
		-- self.m_screenNode.bg2.tiaosan = tiaosan


		-- self.m_screenNode.bg:runAction( transition.sequence({cc.FadeOut:create(2), cc.CallFunc:create(changeScreen)}) )
		-- self.m_screenNode.feixingyun:runAction(cc.FadeOut:create(1))
	end

	local bg = self.m_screenNode.bg
	local spwArray1 = cc.Array:create()
	spwArray1:addObject( cc.MoveBy:create( 4, cc.p(0,-1200) ) )
	spwArray1:addObject( cc.DelayTime:create(3))
	spwArray1:addObject( cc.CallFunc:create(function ()
		ManagerSound.playSound("jidi_standby")
	end))
	spwArray1:addObject( transition.sequence({CCEaseIn:create(cc.ScaleTo:create(4.0,2.0), 0.5), cc.CallFunc:create(function()
		over()
	end)})  )
	bg:runAction(transition.sequence({cc.Spawn:create(spwArray1), cc.FadeOut:create(1), cc.CallFunc:create(function()
		changeScreen()
	end)}) )



	local function deletemengceng(sender)
		sender:removeSelf()
		sender = nil
	end
	-- actions 蒙层
	for k,v in pairs(self.m_screenNode.actions) do
		v:runAction(transition.sequence({CCFadeTo:create(1.5, 0), cc.CallFuncN:create(function(sender)
			deletemengceng(sender)
		end)}))
	end


	local function tomove(sender, movetime, scale, move)
		local spwArray2 = cc.Array:create()
		spwArray2:addObject(cc.MoveBy:create(movetime, cc.p(move, -50)) )
		spwArray2:addObject(cc.ScaleTo:create(movetime, scale))
		sender:runAction( transition.sequence({cc.Spawn:create(spwArray2), cc.CallFuncN:create(function (_sender)
			_sender:removeSelf()
		end)}) )
	end

	local yun1 = self.m_screenNode.yun1
	tomove(yun1, 3, 4, -self:width() * 2)

	local yun2 = self.m_screenNode.yun2
	tomove(yun2, 3, 2, -self:width() * 2)

	local yun4 = self.m_screenNode.yun4
	tomove(yun4, 3, 2, self:width() * 2)

	self.m_screenNode.yun3:removeSelf()
end

function NewerCGGuideView:CGState1()
	self.m_cgState = 2

	local bg = display.newSprite(IMAGE_COMMON .. "cg/bg1.jpg"):addTo(self.m_screenNode, 1)
	bg:setAnchorPoint(cc.p(0.5,0))
	-- bg:setPosition(self:width() * 0.5, 0)
	bg:setPosition(self:width() * 0.5, -625)

	-- 白色蒙层
	local white = display.newColorLayer(ccc4(255, 255, 255, 60)):addTo(self.m_screenNode, 2)
	white:setContentSize(cc.size(display.width, display.height))
	white:setPosition(0, 0)

	-- 蒙层
	local yuncent = display.newSprite(IMAGE_COMMON .. "cg/yun3.png"):addTo(self.m_screenNode , 2)
	yuncent:setPosition(self:width() * 0.5,self:height() * 0.5)

	-- 云1 中
	local yun1 = display.newSprite(IMAGE_COMMON .. "cg/yun1.png"):addTo(self.m_screenNode , 3)
	yun1:setScale(0.75)
	-- yun1:setPosition(self:width() * 0.5, self:height() * 0.75)
	yun1:setPosition(self:width() * 0.5,-300)

	-- 云2 左中
	local yun2 = display.newSprite(IMAGE_COMMON .. "cg/yun1.png"):addTo(self.m_screenNode , 3)
	-- yun2:setPosition(yun2:width() * 0.1, self:height() * 0.4)
	yun1:setPosition(yun2:width() * 0.1,-150)

	-- 云3 左底
	local yun3 = display.newSprite(IMAGE_COMMON .. "cg/yun1.png"):addTo(self.m_screenNode , 3)
	-- yun3:setPosition(yun3:width() * 0.15, yun3:width() * 0.25)
	yun1:setPosition(yun3:width() * 0.15,-300)


	local yun4 = display.newSprite(IMAGE_COMMON .. "cg/yun2.png"):addTo(self.m_screenNode , 3)
	-- yun4:setPosition(self:width() * 0.5 + yun4:width() * 0.3, self:height() * 0.6)
	yun1:setPosition(self:width() * 0.5 + yun4:width() * 0.3,-200)


	-- local feiji = armature_create("xsyd_feiji", self:width() * 0.5,self:height() * 0.5 - 60):addTo(self.m_screenNode, 5)
	-- feiji:getAnimation():playWithIndex(0)
	-- -- ManagerSound.playSound("conveyor")

	-- local feixingyun = armature_create("xsyd_ren1", self:width() * 0.5,self:height() * 0.5 - 60):addTo(self.m_screenNode, 4)
	-- feixingyun:getAnimation():playWithIndex(0)
	-- feixingyun:setScale(0.2)


	-- yun1:runAction(cc.MoveBy:create(8,cc.p(0,-300)))
	-- yun2:runAction(cc.MoveBy:create(6,cc.p(-50,-150)))
	-- yun3:runAction(cc.MoveBy:create(3,cc.p(0,-300)))
	-- yun4:runAction(cc.MoveBy:create(8,cc.p(200,-200)))

	self.m_cgState = 3
	-- bg:runAction(transition.sequence({cc.MoveBy:create(5,cc.p(0,-625)), cc.CallFunc:create(function ()
		-- self.m_cgState = 3
	-- end)}))

	local actions = {white, yuncent}
	self.m_screenNode.actions = actions
	-- self.m_screenNode.feiji = feiji
	-- self.m_screenNode.feixingyun = feixingyun
	self.m_screenNode.yun1 = yun1
	self.m_screenNode.yun2 = yun2
	self.m_screenNode.yun3 = yun3
	self.m_screenNode.yun4 = yun4
	self.m_screenNode.bg = bg
end

function NewerCGGuideView:close()
	self.m_screenNode:stopAllActions()
	self.m_screenNode:removeAllChildren()
	

    NewerBO.saveGuideState(nil,5)
	Notify.notify(LOCAL_SHOW_NEWER_GUIDE_EVENT)

	UiDirector.popName(nil,"NewerCGGuideView")
end

function NewerCGGuideView:onTouch(event)
	if event.name == "began" then
        return false
    elseif event.name == "ended" then
    	if self.m_touchState then
    		self.m_touchState = false
    		self.m_cgState = self.m_cgState + 1
    	end
    end
 end

function NewerCGGuideView:getUiName()
	return self.__cname
end


function NewerCGGuideView:onExit()
	-- body
	armature_remove("animation/cg/xsyd_baozha.pvr.ccz", "animation/cg/xsyd_baozha.plist", "animation/cg/xsyd_baozha.xml")
	armature_remove("animation/cg/xsyd_baozha2.pvr.ccz", "animation/cg/xsyd_baozha2.plist", "animation/cg/xsyd_baozha2.xml")
	-- armature_remove("animation/cg/xsyd_feiji.pvr.ccz", "animation/cg/xsyd_feiji.plist", "animation/cg/xsyd_feiji.xml")
	armature_remove("animation/cg/xsyd_jidiche.pvr.ccz", "animation/cg/xsyd_jidiche.plist", "animation/cg/xsyd_jidiche.xml")
	armature_remove("animation/cg/xsyd_jidiche_shouji.pvr.ccz", "animation/cg/xsyd_jidiche_shouji.plist", "animation/cg/xsyd_jidiche_shouji.xml")
	-- armature_remove("animation/cg/xsyd_ren_tiaosan.pvr.ccz", "animation/cg/xsyd_ren_tiaosan.plist", "animation/cg/xsyd_ren_tiaosan.xml")
	-- armature_remove("animation/cg/xsyd_ren1.pvr.ccz", "animation/cg/xsyd_ren1.plist", "animation/cg/xsyd_ren1.xml")

	cc.SpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
	cc.TextureCache:sharedTextureCache():removeUnusedTextures()
end

return NewerCGGuideView