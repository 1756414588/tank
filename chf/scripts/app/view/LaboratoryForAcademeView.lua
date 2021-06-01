--
--
-- 研究院
-- MYS

-- 计算平均位置 以中心点为准
local function CalculateX( all, index, width, dexScaleOfWidth)
	-- body
	local c = all + 1
	local q = c / 2
	local sw = width * dexScaleOfWidth
	local w = q * sw
	return index * sw - w
end
local lineColor = ccc4f(2/255, 255/255, 175/255, 1)

local Dialog = require("app.dialog.DialogEx")

--------------------------------------------------------------
--						建设改进							--
--------------------------------------------------------------

local ConstructionImprovementDialog = class("ConstructionImprovementDialog", Dialog)

function ConstructionImprovementDialog:ctor(parent)
	ConstructionImprovementDialog.super.ctor(self, parent)
end

function ConstructionImprovementDialog:onEnter()
	ConstructionImprovementDialog.super.onEnter(self)

	armature_add(IMAGE_ANIMATION .. "effect/zzsys_dq.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_dq.plist", IMAGE_ANIMATION .. "effect/zzsys_dq.xml")
	armature_add(IMAGE_ANIMATION .. "effect/zzsys_dl.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_dl.plist", IMAGE_ANIMATION .. "effect/zzsys_dl.xml")

	-- bg_dlg_1.png
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self)
	btm:setPreferredSize(cc.size(542, 600))
	btm:setPosition(display.cx, display.cy)
	-- self.m_viewbg = btm

	local btmb = display.newScale9Sprite(IMAGE_COMMON .. "bg_dlg_1.png"):addTo(self, 1)
	btmb:setPreferredSize(cc.size(582, 630))
	btmb:setPosition(display.cx, display.cy)

	local showbg = display.newNode():addTo(self, 2)
	showbg:setContentSize(cc.size(542, 600))
	showbg:setPosition(display.cx - 542 /2, display.cy - 600 / 2)
	self.m_viewbg = showbg

	-- local bottombg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(btm)
	-- bottombg:setPreferredSize(cc.size(510, 530))
	-- bottombg:setPosition(btm:width() * 0.5, btm:height() * 0.5 - 10)

	-- local fff = display.newSprite(IMAGE_COMMON .. "info_bg_127.png"):addTo(bottombg):center()

	local bottombg = display.newSprite(IMAGE_COMMON .. "info_bg_127.png"):addTo(btm):center()

	local titlename = ui.newTTFLabel({text = CommonText[1762][3], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btmb)
	titlename:setPosition(btmb:width() * 0.5 , btmb:height() - 31)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_close_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_close_selected.png")
	local closeBtn = MenuButton.new(normal, selected, nil, handler(self, self.closeCallback)):addTo(btmb)
	closeBtn:setPosition(btmb:width() - closeBtn:width() * 0.5 - 32 , btmb:height() - closeBtn:height() * 0.5 - 5)

	self.buildList = {}
	self:drawContetnLayer()
end

function ConstructionImprovementDialog:drawContetnLayer()
	local allResearch = LaboratoryMO.queryLaboratoryForResearchAllType()
	-- 已解锁 图片
	local function unlockSp(node)
		if node then
			if node.itemsp then
				node.itemsp:removeSelf()
				node.itemsp = nil
			end
			local item = display.newSprite(IMAGE_COMMON .. "laboratory/" .. node.picture .. ".jpg"):addTo(node, -1)
			item:setPosition(node:width() * 0.5, node:height() * 0.5)
			node.itemsp = item
		end
	end
	-- 未解锁 图片
	local function lockSp(node)
		if node then
			if node.itemsp then
				node.itemsp:removeSelf()
				node.itemsp = nil
			end
			local item = display.newGraySprite(IMAGE_COMMON .. "laboratory/" .. node.picture .. ".jpg"):addTo(node, -1)
			item:setPosition(node:width() * 0.5, node:height() * 0.5)
			node.itemsp = item
		end
	end

	local line = CCDrawNode:create():addTo(self.m_viewbg, 2)
	self.m_line = line
	self.lineInfo = {}

	for _type = 1, 3 do
		local researchs = allResearch[_type]
		local all = #researchs
		for index = 1, all do
			local _research = researchs[index]
			
			local buildBtn = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(self.m_viewbg , 5)
			-- buildBtn:setPosition(self.m_viewbg:width() * 0.5 + CalculateX(all, index, buildBtn:width(), 1.3) , self.m_viewbg:height() + 80 - buildBtn:height() * _type * 2.1)
			buildBtn:setPosition(self.m_viewbg:width() * 0.5 + CalculateX(all, index, buildBtn:width(), 1.3) , self.m_viewbg:height() + 7 - buildBtn:height() * _type * 1.5)
			buildBtn.type = _type
			buildBtn.id = _research.id
			buildBtn.picture = _research.picture
			buildBtn.isTouchEnable = true
			buildBtn:setTouchSwallowEnabled(false)
			buildBtn.lockSpFunc = lockSp
			buildBtn.unlockSpFunc = unlockSp
			buildBtn.ccp = cc.p(buildBtn:x(), buildBtn:y())
			buildBtn.size = cc.size(buildBtn:width(), buildBtn:height())

			self:setTouchFunc(buildBtn, handler(self, self.buildCallback))

			local state = LaboratoryMO.academeData.archData[_research.id]
			if not state or state ~= 1 then
				buildBtn:lockSpFunc()
			else
				buildBtn:unlockSpFunc()
			end

			local preBuilding = json.decode(_research.preBuilding)
			buildBtn.preBuilding = preBuilding

			self.buildList[buildBtn.id] = buildBtn

			self:drawLines(buildBtn)
		end
	end
end

--
--            | 300000
--            |
-- 350000     |    450000
-- ----------------------        ------------------------------------ 400000
--            |
--            |
--            | 500000
--
function ConstructionImprovementDialog:drawLines(node)
	-- self.m_line:clear()
	local preBuilding = node.preBuilding

	for index = 1 , #preBuilding do
		local preBuildid = preBuilding[index]

		local fromSp = self.buildList[preBuildid]
		local fromSpType = fromSp.type
		local fromSpccp = fromSp.ccp

		local toSp = node
		local toSpType = toSp.type
		local toSpccp = toSp.ccp

		if fromSpType == toSpType then
			-- 横向
			local centerX = cc.p( (fromSpccp.x + toSpccp.x) * 0.5 , (fromSpccp.y + toSpccp.y) * 0.5 )

			-- 前置
			local line1 = {from = cc.p(fromSpccp.x + fromSp.size.width * 0.5, fromSpccp.y), to = centerX, key = fromSp.id + 450000}
			if not self.lineInfo[line1.key] then
				self.m_line:drawSegment(line1.from, line1.to, 1, lineColor)
				self.lineInfo[line1.key] = line1
			end
			
			-- 后置
			local line2 = {from = centerX, to = cc.p(toSpccp.x - toSp.size.width * 0.5, toSpccp.y), key = toSp.id + 350000}
			if not self.lineInfo[line2.key] then
				self.m_line:drawSegment(line2.from, line2.to, 1, lineColor)
				self.lineInfo[line2.key] = line2
			end
		else
			-- 纵向
			local centerY = (fromSpccp.y + toSpccp.y) * 0.5

			-- 前置
			local line1 = {from = cc.p(fromSpccp.x , fromSpccp.y - fromSp.size.height * 0.5), to = cc.p(fromSpccp.x, centerY), key = fromSp.id + 500000}
			if not self.lineInfo[line1.key] then
				self.m_line:drawSegment(line1.from, line1.to, 1, lineColor)
				self.lineInfo[line1.key] = line1
			end

			-- 后置
			local line2 = {from = cc.p(toSpccp.x, centerY), to = cc.p(toSpccp.x, toSpccp.y + toSp.size.height * 0.5), key = toSp.id + 300000}
			if not self.lineInfo[line2.key] then
				self.m_line:drawSegment(line2.from, line2.to, 1, lineColor)
				self.lineInfo[line2.key] = line2
			end

			if line1.to.x ~= line2.from.x then
				local line3 = {from = cc.p(fromSpccp.x, centerY), to = cc.p(toSpccp.x, centerY), key = toSp.id + fromSp.id + 400000}
				if not self.lineInfo[line3.key] then
					self.m_line:drawSegment(line3.from, line3.to, 1, lineColor)
					self.lineInfo[line3.key] = line3
				end
			end
		end

		-- local fromSpPoint = cc.p(0,0)
		-- local toSpPoint = cc.p(0,0)
		-- local widthSize = 0
		-- local rat = 0

		-- if fromSpType == toSpType then
		-- 	fromSpPoint = cc.p(fromSp:x() , fromSp:y())
		-- 	toSpPoint = cc.p(toSp:x() - toSp:width() * 0.5, toSp:y())
		-- 	local vector = Vec(toSpPoint.x - fromSpPoint.x , toSpPoint.y - fromSpPoint.y)
		-- 	widthSize = vector.modulus()
		-- 	rat = math.deg(math.acos( vector.x / widthSize))
		-- else
		-- 	fromSpPoint = cc.p(fromSp:x() , fromSp:y() - fromSp:height() * 0.5)
		-- 	toSpPoint = cc.p(toSp:x() , toSp:y() + toSp:height() * 0.5)
		-- 	local vector = Vec(toSpPoint.x - fromSpPoint.x , toSpPoint.y - fromSpPoint.y)
		-- 	widthSize = vector.modulus()
		-- 	rat = math.deg(math.acos( vector.x / widthSize))
		-- end

		-- local ctp = ccTexParams:new()
  --       ctp.minFilter = 0x2601
  --       ctp.magFilter = 0x2601
  --       ctp.wrapS = 0x2901
  --       ctp.wrapT = 0x2901
		-- local arrow = display.newSprite(IMAGE_COMMON .. "arrow3.png"):addTo(self.m_viewbg ,4)
		-- arrow:getTexture():setTexParameters(ctp)
		-- arrow:setTextureRect(cc.rect(0,0,-widthSize,16))
		-- -- local arrow = display.newScale9Sprite(IMAGE_COMMON .. "arrow3.png"):addTo(self.m_viewbg ,4)
		-- -- arrow:setPreferredSize(cc.size(widthSize, 16))
		-- -- arrow:setCapInsets(cc.rect(5,5,1,1))
		-- arrow:setAnchorPoint(cc.p(0,0.5))
		-- arrow:setPosition(toSpPoint.x, toSpPoint.y)
		-- arrow:setRotation(rat)
	end
end

function ConstructionImprovementDialog:showTopLayer(buildID, preBuilding)
	if self.m_topLayer then
		self.m_topLayer:removeSelf()
		self.m_topLayer = nil
	end

	local buildInfo = LaboratoryMO.queryLaboratoryForResearchById(buildID)

	local topLayer = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_129.png"):addTo(self.m_viewbg, 10)
	topLayer:setPreferredSize(cc.size(599, 420))
	topLayer:setAnchorPoint(cc.p(0.5,0.5))
	topLayer:setPosition(self.m_viewbg:width() * 0.5 , self.m_viewbg:height() * 0.5)
	self.m_topLayer = topLayer

	local item = display.newSprite(IMAGE_COMMON .. "laboratory/" .. buildInfo.picture .. ".jpg"):addTo(topLayer, 1)
	item:setPosition(55 + item:width() * 0.5, topLayer:height() - 50 - item:height() * 0.5)

	local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(item,1)
	sprite:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)

	-- 建筑名称
	local buildname = ui.newTTFLabel({text = buildInfo.name, font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(item)
	buildname:setPosition(item:width() * 0.5 , -20)

	-- 描述
	local buildDesc = ui.newTTFLabel({text = CommonText[1763][1].. "：" .. buildInfo.description, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = cc.c3b(255, 255, 255), dimensions = cc.size(330, 60)}):addTo(topLayer, 2)
	buildDesc:setPosition(topLayer:width() * 0.5 + item:width() * 0.5, item:y() + 5)

	local state = LaboratoryMO.academeData.archData[buildID]
	if not state or state ~= 1 then
		-- 需解锁

		-- 消耗
		local buildDesc = ui.newTTFLabel({text = CommonText[934] .."：", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(211, 218, 21)}):addTo(topLayer, 2)
		buildDesc:setPosition(item:x() - 15, topLayer:height() * 0.5 - 10 )
		local sumes = json.decode(buildInfo.itemConsume)
		local size = #sumes
		for index = 1 , #sumes do
			local sume = sumes[index]
			local kind = sume[1]
			local id = sume[2]
			local count = sume[3]

			local resitem = UiUtil.createItemView(kind, id):addTo(topLayer,4)
			resitem:setScale(0.75)
			resitem:setPosition(topLayer:width() * 0.5 + buildDesc:width() * 0.5 + CalculateX(size, index, resitem:width() * resitem:getScale(), 1.6), buildDesc:y())

			UiUtil.createItemDetailButton(resitem)

			local mycount = UserMO.getResource(kind,id)
			local color = cc.c3b(255, 255, 255)
			if mycount < count then color = cc.c3b(255, 0, 0) end
			local mycountStr = UiUtil.strNumSimplify(mycount)
			local countStr = UiUtil.strNumSimplify(count)
			local strs3 = { {content = mycountStr,color = color , size = FONT_SIZE_LIMIT}, 
						{content = "/" .. countStr,color = cc.c3b(255, 255, 255),  size = FONT_SIZE_LIMIT} } 
			local countlb = RichLabel.new(strs3):addTo(topLayer,5)
			countlb:setPosition(resitem:x() - countlb:width() * 0.5, resitem:y() - resitem:height() * 0.5 * resitem:getScale() - 10)
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local activeBtn = MenuButton.new(normal, selected, nil, handler(self, self.activeCallback)):addTo(topLayer, 5)
		activeBtn:setPosition(topLayer:width() * 0.5 + activeBtn:width() * 0.25 , activeBtn:height() * 0.5 + 30)
		activeBtn:setLabel(CommonText[413][4])
		activeBtn.id = buildInfo.id
		activeBtn.needs = sumes
		activeBtn.preBuilding = preBuilding

	else
		local buildDesc = ui.newTTFLabel({text = CommonText[1763][2], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topLayer, 2)
		buildDesc:setPosition(topLayer:width() * 0.5 , 90)
	end
end

function ConstructionImprovementDialog:setTouchFunc(node,callback)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			if not node.isTouchEnable then return end
			if callback then callback(nil,node) end
		end
	end)
end

function ConstructionImprovementDialog:hideTopLayer()
	if self.m_topLayer then
		self.m_topLayer:removeSelf()
		self.m_topLayer = nil
	end
end

function ConstructionImprovementDialog:hideBuildBtn()
	for k, v in pairs(self.buildList) do
		v.isTouchEnable = false
	end
end

function ConstructionImprovementDialog:showBuildBtn()
	for k, v in pairs(self.buildList) do
		v.isTouchEnable = true
	end
end

function ConstructionImprovementDialog:activeCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	-- body
	local id = sender.id
	local preBuilding = sender.preBuilding

	local preBid = 0
	for index = 1, #preBuilding do
		local bid = preBuilding[index]
		local buildState = LaboratoryMO.academeData.archData[bid]
		if not buildState or buildState ~= 1 then
			preBid = bid
			break
		end
	end
	if preBid > 0 then
		-- 未解锁
		local predata = LaboratoryMO.queryLaboratoryForResearchById(preBid)
		Toast.show(CommonText[1763][3] .. "[" .. predata.name .. "]")
		return
	end


	local needs = sender.needs
	local isCould = true
	for index = 1, #needs do
		local sume = needs[index]
		local _kind = sume[1]
		local _id = sume[2]
		local _count = sume[3]
		local mycount = UserMO.getResource(_kind,_id)
		if mycount < _count then
			isCould = false
			break
		end
	end

	if not isCould then
		Toast.show(CommonText[1764])
		return
	end

	local function resultCallback(data)
		local btn = self.buildList[id]
		-- btn:unlockSpFunc()
		self:hideTopLayer()
		-- self:showBuildBtn()
		-- Toast.show("激活成功")

		Notify.notify("LOCAL_LABORATORY_PRODUCT_NOTIGY")

		self:activeForAction(btn)
	end

	LaboratoryBO.ActFightLabArchAct(resultCallback, id)
end

function ConstructionImprovementDialog:buildCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local id = sender.id
	local preBuilding = sender.preBuilding

	self:hideBuildBtn()
	self:showTopLayer(id, preBuilding)
	-- if true then
	-- 	return
	-- end

	-- local buildState = LaboratoryMO.academeData.archData[id]
	-- -- 已经解锁
	-- if buildState and buildState == 1 then
	-- 	self:hideBuildBtn()
	-- 	self:showTopLayer(id)
	-- else
		
	-- 	local preBid = 0
	-- 	for index = 1, #preBuilding do
	-- 		local bid = preBuilding[index]
	-- 		local buildState = LaboratoryMO.academeData.archData[bid]
	-- 		if not buildState or buildState ~= 1 then
	-- 			preBid = bid
	-- 			break
	-- 		end
	-- 	end
	-- 	if preBid == 0 then
	-- 		-- 可以解锁
	-- 		self:hideBuildBtn()
	-- 		self:showTopLayer(id)
	-- 	else
	-- 		-- 未解锁
	-- 		local predata = LaboratoryMO.queryLaboratoryForResearchById(preBid)
	-- 		Toast.show(CommonText[1763][3] .. "[" .. predata.name .. "]")
	-- 	end
	-- end
end

function ConstructionImprovementDialog:activeForAction(node)
	local function ActionDone()
		self:showBuildBtn()
		node:unlockSpFunc()

		Toast.show(CommonText[413][4].. CommonText[1116][2])

		-- 播放一个动画
	end

	local function ActionDoneEx()
		local effect = armature_create("zzsys_dl",0,0,function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
					ActionDone()
				end
			end):addTo(node , 10)
		effect:getAnimation():playWithIndex(0)
		effect:setPosition(node:width() * 0.5, node:height() * 0.5)
	end

	local outLines = {}
	local preBuilding = node.preBuilding
	for index = 1 , #preBuilding do
		local preBuildid = preBuilding[index]

		local fromSp = self.buildList[preBuildid]
		local fromSpType = fromSp.type

		local toSp = node
		local toSpType = toSp.type
		local line = {}

		if fromSpType == toSpType then
			-- 前置
			local key1 = fromSp.id + 450000
			local lineinfo1 = self.lineInfo[key1]

			-- 后置
			local key2 = toSp.id + 350000
			local lineinfo2 = self.lineInfo[key2]

			if lineinfo1 then line[#line + 1] = lineinfo1 end
			if lineinfo2 then line[#line + 1] = lineinfo2 end
		else
			-- 前置
			local key1 = fromSp.id + 500000
			local lineinfo1 = self.lineInfo[key1]

			-- 后置
			local key2 = toSp.id + 300000
			local lineinfo2 = self.lineInfo[key2]

			local key3 = fromSp.id + toSp.id + 400000
			local lineinfo3 = self.lineInfo[key3]

			if lineinfo1 then line[#line + 1] = lineinfo1 end
			if lineinfo3 then line[#line + 1] = lineinfo3 end
			if lineinfo2 then line[#line + 1] = lineinfo2 end
		end
		outLines[#outLines + 1] = line
	end

	-- 播放动画
	for index = 1, #outLines do
		
		local effect = armature_create("zzsys_dq"):addTo(self.m_viewbg , 3)
		effect:getAnimation():playWithIndex(0)

		local actionLines = outLines[index]
		local size = #actionLines
		local cp = size <= 2 and 0 or 1
		local cap = CCPointArray:create(6)
		for n = 1, size do
			local point = actionLines[n]
			cap:add( point.from )

			if n == size then
				cap:add( point.to )
			end
		end
		local action = CCCardinalSplineBy:create((size + 1) * 0.2,cap , cp)

		effect:runAction(transition.sequence({action,cc.CallFuncN:create(function (sender) 
			sender:removeSelf()
			ActionDoneEx()
		end)}))
	end
end

-- 关闭
function ConstructionImprovementDialog:closeCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	self:close()
end

function ConstructionImprovementDialog:onTouch(event)
	ConstructionImprovementDialog.super.onTouch(self,event)
	if event.name == "ended" then
		if self.m_topLayer then
			local point = self.m_topLayer:getParent():convertToNodeSpace(cc.p(event.x, event.y))
			local rect = self.m_topLayer:getBoundingBox()
			if not cc.rectContainsPoint(rect, point) then
				self:hideTopLayer()
				self:showBuildBtn()
			end
		end
	end
	return true
end

function ConstructionImprovementDialog:onExit()
	ConstructionImprovementDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/zzsys_dq.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_dq.plist", IMAGE_ANIMATION .. "effect/zzsys_dq.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/zzsys_dl.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_dl.plist", IMAGE_ANIMATION .. "effect/zzsys_dl.xml")
end





































--------------------------------------------------------------
--						科技突破							--
--------------------------------------------------------------
local ScientificBreakThroughDialog = class("ScientificBreakThroughDialog", Dialog)

function ScientificBreakThroughDialog:ctor(parent)
	ScientificBreakThroughDialog.super.ctor(self, parent)
end

function ScientificBreakThroughDialog:onEnter()
	ScientificBreakThroughDialog.super.onEnter(self)

	-- bg_dlg_1.png
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self)
	btm:setPreferredSize(cc.size(542, 620))
	btm:setPosition(display.cx, display.cy)
	-- self.m_viewbg = btm

	local btmb = display.newScale9Sprite(IMAGE_COMMON .. "bg_dlg_1.png"):addTo(self, 1)
	btmb:setPreferredSize(cc.size(582, 650))
	btmb:setPosition(display.cx, display.cy)

	local bottombg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(btm)
	bottombg:setPreferredSize(cc.size(510, 480))
	bottombg:setPosition(btm:width() * 0.5, btm:height() * 0.5)

	local showbg = display.newNode():addTo(self, 2)
	showbg:setContentSize(cc.size(542, 620))
	showbg:setPosition(display.cx - 542 /2, display.cy - 620 / 2)
	self.m_viewbg = showbg

	local titlename = ui.newTTFLabel({text = CommonText[1762][2], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btmb)
	titlename:setPosition(btmb:width() * 0.5 , btmb:height() - 31)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_close_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_close_selected.png")
	local closeBtn = MenuButton.new(normal, selected, nil, handler(self, self.closeCallback)):addTo(btmb)
	closeBtn:setPosition(btmb:width() - closeBtn:width() * 0.5 - 32 , btmb:height() - closeBtn:height() * 0.5 - 5)


	self.TECHs = {LABORATORY_TECH1_ID, LABORATORY_TECH2_ID, LABORATORY_TECH3_ID, LABORATORY_TECH4_ID, LABORATORY_TECH5_ID}
	self.itemBtnList = {}
	-- self.isTouchEnabled = false
	self:drawContetnLayer()
end

function ScientificBreakThroughDialog:drawContetnLayer()
	if self.itemBtnList then 
		for k , v in pairs(self.itemBtnList) do
			v:removeSelf()
			v = nil
		end
	end

	self.itemBtnList = {}

	local MAXROW = 3
	for index = 1, #self.TECHs do
		local techID = self.TECHs[index]
		local techData = LaboratoryMO.academeData.techData[techID]
		local techLV = techData and techData.lv or 0
		local techInfo = LaboratoryMO.queryLaboratoryForTechnologyByIdLv(techID, techLV)

		local xindex = math.floor((index - 1) % MAXROW)
		local yindex = math.floor((index - 1) / MAXROW)

		local itemSp = display.newSprite(IMAGE_COMMON .. "laboratory/" .. techInfo.picture .. ".jpg")
		local itemBtn = TouchButton.new(itemSp, nil, nil, handler(self, self.showTechCallback)):addTo(self.m_viewbg , 5)
		itemBtn:setPosition(self.m_viewbg:width() * 0.5 + CalculateX(MAXROW, (xindex + 1), itemBtn:width() , 1.7)  , self.m_viewbg:height() - 100 - itemBtn:height() * 0.5 - itemBtn:height() * 1.8 * (yindex ))
		itemBtn:setTouchSwallowEnabled(false)

		local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(itemBtn,1)
		sprite:setPosition(itemBtn:getContentSize().width / 2, itemBtn:getContentSize().height / 2)


		local name = ui.newTTFLabel({text = techInfo.name , font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(66, 127, 239)}):addTo(itemBtn)
		name:setPosition(itemBtn:width() * 0.5 - 15, -30)

		local level = ui.newTTFLabel({text = "LV" .. techInfo.techLv, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(211, 218, 21)}):addTo(itemBtn)
		level:setAnchorPoint(cc.p(0,0.5))
		level:setPosition(name:x() + name:width() * 0.5, -30)

		itemBtn.level = level
		itemBtn.techInfo = techInfo
		itemBtn.techID = techID
		self.itemBtnList[techInfo.techId] = itemBtn
	end
end

-- 显示信息框
function ScientificBreakThroughDialog:showTopLayer(techID, info)
	if self.m_topLayer then
		self.m_topLayer:removeSelf()
		self.m_topLayer = nil
	end

	local topLayer = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_129.png"):addTo(self.m_viewbg, 10)
	topLayer:setPreferredSize(cc.size(599, 420))
	-- local topLayer = display.newScale9Sprite(IMAGE_COMMON .. "bg_dlg_2.png"):addTo(self.m_viewbg, 10)
	-- topLayer:setPreferredSize(cc.size(540, 420))
	topLayer:setAnchorPoint(cc.p(0.5,0.5))
	topLayer:setPosition(self.m_viewbg:width() * 0.5 , self.m_viewbg:height() * 0.5)
	self.m_topLayer = topLayer

	local item = display.newSprite(IMAGE_COMMON .. "laboratory/" .. info.picture .. ".jpg"):addTo(topLayer, 1)
	item:setPosition(65 + item:width() * 0.5, topLayer:height() - 65 - item:height() * 0.5)

	local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(item,1)
	sprite:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)

	-- local bottom = display.newSprite(IMAGE_COMMON .. "btn_position_4_normal.png"):addTo(item, -1)
	-- bottom:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2 - 3)

	local nextLv = info.techLv + 1
	local nextInfo = LaboratoryMO.queryLaboratoryForTechnologyByIdLv(techID, nextLv)

	if nextInfo then
		local curStr = info.name .. "LV" .. info.techLv
		local nextStr = nextInfo.name 
		local nextStr2 = "LV" .. nextInfo.techLv
		local strs = { {content = curStr, size = FONT_SIZE_TINY}, 
						{content = "#194"}, 
						{content = nextStr, size = FONT_SIZE_TINY},
						{content = nextStr2, color = cc.c3b(76, 151, 95), size = FONT_SIZE_TINY}  } 

		-- 名称 , color = cc.c3b(76, 151, 95)
		local namelb = RichLabel.new(strs):addTo(topLayer,2)
		namelb:setPosition(topLayer:width() * 0.5 + item:width() * 0.5 + 15 - namelb:width() * 0.5, item:y() + 45)


		local strs2 = {}
		-- 效果
		if techID == 4 then
			local cur_ = tostring(info.maxPersonNumber)
			local next_ = tostring(nextInfo.maxPersonNumber)
			-- 总人数
			strs2 = { {content = CommonText[1765][1].. ": " .. cur_, size = FONT_SIZE_TINY}, 
					{content = "#194"}, 
					{content = next_ , size = FONT_SIZE_TINY, color = cc.c3b(76, 151, 95)} }
		elseif techID == 5 then
			local cur_ = tostring(info.personNumberLimit)
			local next_ = tostring(nextInfo.personNumberLimit)
			-- 项目人数上限
			strs2 = { {content = CommonText[1765][2] .. ": " .. cur_, size = FONT_SIZE_TINY}, 
					{content = "#194"}, 
					{content = next_ , size = FONT_SIZE_TINY, color = cc.c3b(76, 151, 95)} }
		else -- techID == 1 or techID == 2 or techID == 3
			local cur_ = tostring(info.composeEfficiency)
			local next_ = tostring(nextInfo.composeEfficiency)
			-- 合成所需碎片数
			strs2 = { {content = CommonText[1765][3] .. ": " .. cur_ , size = FONT_SIZE_TINY}, 
					{content = "#194"}, 
					{content = next_ , size = FONT_SIZE_TINY, color = cc.c3b(76, 151, 95)} }
		end

		-- 名称
		local resChangelb = RichLabel.new(strs2):addTo(topLayer,2)
		resChangelb:setPosition(topLayer:width() * 0.5 + item:width() * 0.5 + 15 - resChangelb:width() * 0.5, item:y() + 20)

		
		-- 材料消耗 lb
		local reslb = ui.newTTFLabel({text = CommonText[165] .. CommonText[1026], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(211, 218, 21)}):addTo(topLayer,3)
		reslb:setPosition(30 + 50, topLayer:height() * 0.5)

		-- 材料消耗
		local sumes = json.decode(nextInfo.itemConsume)
		local size = #sumes
		for index = 1, #sumes do
			local sume = sumes[index]
			local kind = sume[1]
			local id = sume[2]
			local count = sume[3]
			local resitem = UiUtil.createItemView(kind, id):addTo(topLayer,4)
			resitem:setScale(0.75)
			resitem:setPosition(topLayer:width() * 0.5 + reslb:width() * 0.5 + 5 + CalculateX(size, index, resitem:width() * resitem:getScale(), 1.4), reslb:y())

			UiUtil.createItemDetailButton(resitem)

			local mycount = UserMO.getResource(kind,id)
			local color = cc.c3b(255, 255, 255)
			if mycount < count then color = cc.c3b(255, 0, 0) end
			local mycountStr = UiUtil.strNumSimplify(mycount)
			local countStr = UiUtil.strNumSimplify(count)
			local strs3 = { {content = mycountStr,color = color , size = FONT_SIZE_LIMIT}, 
						{content = "/" .. countStr,color = cc.c3b(255, 255, 255),  size = FONT_SIZE_LIMIT} } 
			local countlb = RichLabel.new(strs3):addTo(topLayer,5)
			countlb:setPosition(resitem:x() - countlb:width() * 0.5, resitem:y() - resitem:height() * 0.5 * resitem:getScale() - 10)
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local leveUpBtn = MenuButton.new(normal, selected, nil, handler(self, self.levelUpCallback)):addTo(topLayer, 5)
		leveUpBtn:setPosition(topLayer:width() * 0.5 + leveUpBtn:width() * 0.25 , leveUpBtn:height() * 0.5 + 30)
		leveUpBtn:setLabel(CommonText[79])
		leveUpBtn.techId = info.techId
		leveUpBtn.info = info
		leveUpBtn.needs = sumes

	else
		local namelb = ui.newTTFLabel({text = info.name .. "Lv." .. info.techLv , font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topLayer,2)
		namelb:setPosition(topLayer:width() * 0.5 + item:width() * 0.5, item:y() + 35)

		local str = ""
		-- 效果
		if techID == 4 then
			str = CommonText[1765][1] .. ": " .. info.maxPersonNumber -- 总人数
		elseif techID == 5 then
			str = CommonText[1765][2] .. ": " .. info.personNumberLimit -- 项目人数上限
		else -- techID == 1 or techID == 2 or techID == 3
			str = CommonText[1765][4] .. ": " .. info.composeEfficiency -- 合成效率
		end

		local resChangelb = ui.newTTFLabel({text = str , font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topLayer,2)
		resChangelb:setPosition(topLayer:width() * 0.5 + item:width() * 0.5, item:y() + 10)

		-- max
		local maxlb = ui.newTTFLabel({text = CommonText[1766][1] , font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topLayer,2)
		maxlb:setPosition(topLayer:width() * 0.5 + item:width() * 0.5 - maxlb:width() * 0.25, 90)

	end
end

-- 隐藏信息框
function ScientificBreakThroughDialog:hideTopLayer()
	if self.m_topLayer then
		self.m_topLayer:removeSelf()
		self.m_topLayer = nil
	end
	for k, v in pairs(self.itemBtnList) do
		v:setEnabled(true)
	end
	-- self.isTouchEnabled = false
end

function ScientificBreakThroughDialog:onTouch(event)
	ScientificBreakThroughDialog.super.onTouch(self,event)
	if event.name == "ended" then
		if self.m_topLayer then
			local point = self.m_topLayer:getParent():convertToNodeSpace(cc.p(event.x, event.y))
			local rect = self.m_topLayer:getBoundingBox()
			if not cc.rectContainsPoint(rect, point) then
				self:hideTopLayer()
			end
		end
	end
	return true
end

function ScientificBreakThroughDialog:levelUpCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local techId = sender.techId
	local _techInfo = sender.info
	-- print("techId   " .. tostring(techId))
	local techData = LaboratoryMO.academeData.techData[techId]
	if not techData then
		local research = LaboratoryMO.queryLaboratoryForResearchById(_techInfo.preBuilding)
		Toast.show(CommonText[1767][1] .. CommonText[902][2]  .. research.name)
		if research.id == LABORATORY_RESEARCH2_ID then -- 102 陨石加工所
			TriggerGuideMO.currentStateId = 94
			Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
		elseif research.id == LABORATORY_RESEARCH3_ID then -- 103 晶块工厂
			TriggerGuideMO.currentStateId = 96
			Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
		elseif research.id == LABORATORY_RESEARCH4_ID then -- 104 聚变反应炉
			TriggerGuideMO.currentStateId = 98
			Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
		end
		return
	end

	local needs = sender.needs
	local isCould = true
	for index = 1 , #needs do
		local sume = needs[index]
		local kind = sume[1]
		local id = sume[2]
		local count = sume[3]
		local mycount = UserMO.getResource(kind,id)
		if mycount < count then
			isCould = false
			break
		end
	end

	if not isCould then
		Toast.show(CommonText[1764])
		return
	end

	local function resultCallback(data)

		local outitem = self.itemBtnList[techId]
		Toast.show("[" .. outitem.techInfo.name .."]" .. CommonText[1766][2])

		self:hideTopLayer()

		self:drawContetnLayer()

		Notify.notify("LOCAL_LABORATORY_RES_NOTIGY")
	end
	LaboratoryBO.UpFightLabTechUpLevel(resultCallback, techId)
end

function ScientificBreakThroughDialog:showTechCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local techInfo = sender.techInfo
	local techID = sender.techID

	self:showTopLayer(techID, techInfo)
	for k, v in pairs(self.itemBtnList) do
		v:setEnabled(false)
	end
	-- self.isTouchEnabled = true
end

-- 关闭
function ScientificBreakThroughDialog:closeCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	self:close()
end

function ScientificBreakThroughDialog:onExit()
	ScientificBreakThroughDialog.super.onExit(self)
end








































--------------------------------------------------------------
--						人员分配							--
--------------------------------------------------------------
local PersonnelAllotmentDialog = class("PersonnelAllotmentDialog", Dialog)

function PersonnelAllotmentDialog:ctor(parent)
	PersonnelAllotmentDialog.super.ctor(self, parent)
end

function PersonnelAllotmentDialog:onEnter()
	PersonnelAllotmentDialog.super.onEnter(self)
	-- bg_dlg_1.png
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self)
	btm:setPreferredSize(cc.size(542, 620))
	btm:setPosition(display.cx, display.cy)
	self.m_viewbg = btm

	local btmb = display.newScale9Sprite(IMAGE_COMMON .. "bg_dlg_1.png"):addTo(self, 1)
	btmb:setPreferredSize(cc.size(582, 650))
	btmb:setPosition(display.cx, display.cy)

	local titlename = ui.newTTFLabel({text = CommonText[1762][1], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btmb)
	titlename:setPosition(btmb:width() * 0.5 , btmb:height() - 31)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_close_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_close_selected.png")
	local closeBtn = MenuButton.new(normal, selected, nil, handler(self, self.closeCallback)):addTo(btmb)
	closeBtn:setPosition(btmb:width() - closeBtn:width() * 0.5 - 32 , btmb:height() - closeBtn:height() * 0.5 - 5)

	-- 空闲人数
	local freePeople = ui.newTTFLabel({text = CommonText[1768][1] .. CommonText[1768][2] ..":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btm)
	freePeople:setPosition(btm:width() - 100 - freePeople:width() * 0.5, btm:height() - 70)

	local freepeoplelb = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(btm)
	freepeoplelb:setAnchorPoint(cc.p(0,0.5))
	freepeoplelb:setPosition(freePeople:x() + freePeople:width() * 0.5, freePeople:y())
	freepeoplelb:setString(tostring(LaboratoryMO.academeData.freeCount))
	self.m_peoplelb = freepeoplelb
	self.m_peoplelb.people = LaboratoryMO.academeData.freeCount

	self.m_PersonnelInfo = {free = LaboratoryMO.academeData.freeCount, list = {} ,last = {}, cur = {}}
	self.m_SpriteFrameNameList = {}
	self.NAMES = {LABORATORY_RES1_ID, LABORATORY_RES2_ID, LABORATORY_RES3_ID, LABORATORY_RES4_ID}
	self.isEnabledForSlider = false
	-- 
    self:drawContetnLayer()

    -- self:updateInfo()
end

function PersonnelAllotmentDialog:drawContetnLayer()

	local barHeight = 40
	local barWidth = 266
	local heightDex = -15
	self.isEnabledForSlider = false
	local RESEARCHs = {LABORATORY_RESEARCH1_ID, LABORATORY_RESEARCH2_ID, LABORATORY_RESEARCH3_ID, LABORATORY_RESEARCH4_ID}
	for index = 1 , 4 do
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.m_viewbg, 2)
		bg:setPreferredSize(cc.size(520, 118))
		bg:setPosition(self.m_viewbg:width() * 0.5 , self.m_viewbg:height() - 30 - (bg:height() + 5) * index)

		local itemid = self.NAMES[index]
		local data = LaboratoryMO.academeData.presonData[itemid]		-- 数据信息
		local info = LaboratoryMO.queryLaboratoryForItemById(itemid) 	-- 配置信息
		local minP = info.minP											-- 倍率
		local plimit = info.personLimit 								-- 人口基数限制

		-- 名称
		local name = ui.newTTFLabel({text = info.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bg)
		name:setPosition(15 + name:width() * 0.5 , bg:height() - 25)

		if data then

			-- 科技影响
	    	local techData = LaboratoryMO.academeData.techData[LABORATORY_TECH5_ID]
	    	local techInfo = LaboratoryMO.queryLaboratoryForTechnologyByIdLv(techData.id, techData.lv)
	    	local peoplemax = techInfo.personNumberLimit + plimit		-- 最大人数

			-- 名称
			local name = ui.newTTFLabel({text = info.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bg)
			name:setPosition(15 + name:width() * 0.5 , bg:height() - 25)

			-- 产量
			local turnout = ui.newTTFLabel({text = CommonText[158] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bg)
			turnout:setPosition(120 + turnout:width() * 0.5 , bg:height() - 25)

			-- 产量数
			local turnoutNumber = ui.newTTFLabel({text = "0/h", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bg)
			turnoutNumber:setAnchorPoint(cc.p(0,0.5))
			turnoutNumber:setPosition(turnout:x() + turnout:width() * 0.5 + 5, bg:height() - 25)

			-- 项目人数
			local projectName = ui.newTTFLabel({text = CommonText[1768][3] .. CommonText[1768][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bg)
			projectName:setPosition(bg:width() * 0.5 + projectName:width() * 0.5 + 50, bg:height() - 25)

			-- 项目人数数量
			local projectNameNumber = ui.newTTFLabel({text = "0/0", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bg)
			projectNameNumber:setAnchorPoint(cc.p(0,0.5))
			projectNameNumber:setPosition(projectName:x() + projectName:width() * 0.5 + 5, bg:height() - 25)

			-- 进度条
			local _pmax = math.floor(peoplemax / minP) 
			local m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"},{scale9 = true,min=0,max = _pmax}):addTo(bg)
			m_numSlider:align(display.LEFT_CENTER, bg:width() / 2 - barWidth / 2, bg:height() * 0.5 + heightDex)
		    m_numSlider:setSliderSize(barWidth, barHeight)
		    m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
		    m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(266 + 82, 64), {x = barWidth / 2, y = barHeight / 2 - 24})
		    m_numSlider.itemID = itemid
		    m_numSlider.minP = minP

		    -- 减少按钮
		    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
		    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
		    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(bg)
		    reduceBtn:setPosition(bg:width() * 0.5 - barWidth / 2 - 78, bg:height() * 0.5 - 4 + heightDex)
		    reduceBtn.itemID = itemid
		    reduceBtn.minP = minP

		    -- 增加按钮
		    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
		    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
		    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(bg)
		    addBtn:setPosition(bg:width() * 0.5 + barWidth / 2 + 78, bg:height() * 0.5 - 4 + heightDex)
		    addBtn.itemID = itemid
		    addBtn.minP = minP


		    local productNum = 0
		    local count = 0

	    
	    -- if data then
	    	local _peoplemax = _pmax * minP -- 实际显示最大值

	    	-- 已开启
	    	count = math.min(data.count, _peoplemax)

	    	-- 产量数 = 人数 * 个人每分钟生产量 * 小时
	    	productNum = count * info.amountPmm * 60
	    	turnoutNumber:setString(productNum .. "/h")

	    	-- 人员分配
	    	projectNameNumber:setString(count .. "/" .. peoplemax)

	    	-- 设置最大值
	    	m_numSlider:setSliderLimit(math.floor((count + self.m_peoplelb.people) / minP) )

	    	-- 设置当前值
	    	m_numSlider:setSliderValue(math.floor(count / minP))
	    	-- m_numSlider:setEnabled(true)
	    	reduceBtn:setEnabled(true)
	    	addBtn:setEnabled(true)

	    	local function setSliderValueFunc(tab, num)
	    		local _num = num * tab.info.minP
		    	local products = _num * tab.info.amountPmm * 60
	    		tab.turnout:setString(products .. "/h")
		    	-- 人员分配
	    		tab.project:setString(_num .. "/" .. (tab.techInfo.personNumberLimit + tab.info.personLimit))
		    	tab.slider:setSliderValue( math.floor(_num / tab.info.minP) )
		    end

	    	-- 初始数据
		    local last = {}
		    last.id = itemid
		    last.count = count
		    last.max = peoplemax

		    local cur = {}
		    cur.id = itemid
		    cur.count = count
		    cur.max = peoplemax

		    -- 数据
		    local out = {}
		    out.itemid = itemid
		    out.techInfo = techInfo
		    out.info = info
		    out.turnout = turnoutNumber
		    out.project = projectNameNumber
		    out.slider = m_numSlider
		    out.setSliderFunc = setSliderValueFunc

		    self.m_PersonnelInfo.list[itemid] = out
		    self.m_PersonnelInfo.last[itemid] = last
		    self.m_PersonnelInfo.cur[itemid] = cur
	    else

		    -- 建筑
			local researchid = RESEARCHs[index]
			local researchInfo = LaboratoryMO.queryLaboratoryForResearchById(researchid)
			local preBuildingData = json.decode(researchInfo.preBuilding)
			local preBuildid = preBuildingData[1]
			local preBuildState = LaboratoryMO.academeData.archData[preBuildid]
			if preBuildState and preBuildState >= 1 then
				-- 未解锁可见
				name:setPosition(bg:width() * 0.5 , bg:height() * 0.5)
				name:setString(info.name .. CommonText[1767][2] .. CommonText[413][4] .. ",".. CommonText[929].. researchInfo.name) -- 需激活，未解锁

				bg:setTouchEnabled(true)
		        bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		        	if event.name == "began" then
		        		ManagerSound.playNormalButtonSound()
		        	end
		            if event.name == "ended" then
		               Toast.show(researchInfo.name .. CommonText[929]) -- 生产建筑未解锁 CommonText[1769]
		            end
		            return true
		        end)
			else
				-- 未解锁隐去
				bg:removeSelf()
			end

	   --  	-- 未开启
	   --  	turnoutNumber:setString( productNum .. "/h" )
	   --  	projectNameNumber:setString( count .. "/" .. peoplemax)
	   --  	m_numSlider:setSliderValue(count)
	   --  	-- m_numSlider:setEnabled(false)
	   --  	reduceBtn:setEnabled(false)
	   --  	addBtn:setEnabled(false)

	   --  	local function unlockButton()
	   --  		local cPos = cc.p(bg:x(), bg:y())
	   --  		local cSize = cc.size(bg:width(), bg:height())
	   --  		bg:setPosition(cSize.width * 0.5,cSize.height * 0.5 )
	   --  		local crt = CCRenderTexture:create(cSize.width, cSize.height)
				-- crt:begin()
		  --       bg:visit()
		  --       crt:endToLua()
		  --       bg:setPosition(cPos.x ,cPos.y )
		  --       local m_spriteFrame = crt:getSprite():getDisplayFrame()
		  --       local spriteFrameName = index .. "sp_ssfn_" .. self.__cname
		  --       self.m_SpriteFrameNameList[#self.m_SpriteFrameNameList + 1] = spriteFrameName
		  --       CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFrame(m_spriteFrame, spriteFrameName)
		  --       local graysp = CCFilteredSpriteWithOne:createWithSpriteFrame(m_spriteFrame):addTo(self.m_viewbg,10)
				-- graysp:setScaleY(-1)
				-- graysp:setPosition(cPos.x , cPos.y)
		  --       graysp:setFilter(filter.newFilter("GRAY"))
		  --       graysp:setTouchEnabled(true)
		  --       graysp:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		  --           if event.name == "ended" then
		  --              print("touch")
		  --              Toast.show("未激活")
		  --           end
		  --           return true
		  --       end)

		  --       crt:removeSelf()
		  --       bg:removeSelf()
	   --  	end
	   --  	unlockButton()
	    end
	end
	self.isEnabledForSlider = true
end

function PersonnelAllotmentDialog:updateInfo()
	-- 空闲人数
	self.m_peoplelb:setString(tostring(LaboratoryMO.academeData.freeCount))

end


-- 进度条 数据
function PersonnelAllotmentDialog:onSlideCallback(event)
	if not self.isEnabledForSlider then return end
	local value = event.value - event.value % 1
	local itemID = event.target.itemID
	local minP = event.target.minP
	if itemID then
		self:changeSlidersValue(itemID, minP, value * minP)
	end
end

-- 增加
function PersonnelAllotmentDialog:onAddCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	if not self.isEnabledForSlider then return end
	local itemID = sender.itemID
	local minP = sender.minP
	if itemID and self.m_peoplelb.people >= minP then
		local sliderData = self.m_PersonnelInfo.cur[itemID]
		self:changeSlidersValue(itemID, minP, sliderData.count + minP )
	end
end

-- 减少
function PersonnelAllotmentDialog:onReduceCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	if not self.isEnabledForSlider then return end
	local itemID = sender.itemID
	local minP = sender.minP
	if itemID then
		local sliderData = self.m_PersonnelInfo.cur[itemID]
		self:changeSlidersValue(itemID, minP, sliderData.count - minP)
	end
end

-- 计算滚动值
function PersonnelAllotmentDialog:changeSlidersValue(itemid, minP, value)
	local function finally()
		self.m_peoplelb:setString(tostring(self.m_peoplelb.people))
	end

	local curSliderData = self.m_PersonnelInfo.cur[itemid]
	local curSlider = self.m_PersonnelInfo.list[itemid]

	if value < 0 or value > curSliderData.max then
		finally()
		return
	end

	
	local cur = curSliderData.count
	if value > cur then

		-- 增加
		if self.m_peoplelb.people >= minP then
			local addnum = value - cur
			if addnum <= self.m_peoplelb.people then
				curSliderData.count = value
				curSlider:setSliderFunc(math.floor(value / minP))
				self.m_peoplelb.people = self.m_peoplelb.people - addnum
			else
				local newcur = cur + self.m_peoplelb.people
				curSliderData.count = newcur
				curSlider:setSliderFunc(newcur)
				self.m_peoplelb.people = 0
			end
		else
			finally()
			return
		end

	elseif value < cur then

		-- 减少
		local reduce = cur - value
		curSliderData.count = value
		curSlider:setSliderFunc(math.floor(value / minP))
		self.m_peoplelb.people = self.m_peoplelb.people + reduce

	else 		-- 不变（相同）
		finally()
		return
	end

	for index = 1 ,#self.NAMES do
		local itemID = self.NAMES[index]
		local cS = self.m_PersonnelInfo.list[itemID]
		local cSData = self.m_PersonnelInfo.cur[itemID]
		if cS and cSData then
			local curs = cSData.count
			-- cS.slider:setSliderLimit(curs + self.m_peoplelb.people)
			cS.slider:setSliderLimit(math.floor((curs + self.m_peoplelb.people) / cS.info.minP))
		end
	end

	finally()
end

function PersonnelAllotmentDialog:isCheckSave(doSave, doclose)
	if self.m_peoplelb.people ~= LaboratoryMO.academeData.freeCount then
		doSave()
		return
	end

	for index = 1 ,#self.NAMES do
		local itemID = self.NAMES[index]
		local last = self.m_PersonnelInfo.last[itemID]
		local cur = self.m_PersonnelInfo.cur[itemID]
		if last and cur then
			if cur.count ~= last.count then
				doSave()
				return
			end
		end
	end

	doclose()
end

-- 关闭
function PersonnelAllotmentDialog:closeCallback(tar, sender)
	ManagerSound.playNormalButtonSound()

	local function closeFunc()
		self:close()
	end

	local function parseResult(data)
		closeFunc()
		Notify.notify("LOCAL_LABORATORY_PRODUCT_NOTIGY")
		Toast.show(CommonText[1762][1] .. CommonText[1770][2]) -- 人员分配已修改
	end

	local function doSocket()
		local out = {}
		for k, v in pairs(self.m_PersonnelInfo.cur) do
			local item = {}
			item.v1 = v.id
			item.v2 = v.count
			out[#out + 1] = item
		end

		LaboratoryBO.SetFightLabPersonCount(parseResult,out)
	end
	
	self:isCheckSave(doSocket, closeFunc)
end

function PersonnelAllotmentDialog:onExit()
	PersonnelAllotmentDialog.super.onExit(self)
end



































--------------------------------------------------------------
--							研究所							--
--------------------------------------------------------------
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local LaboratoryForAcademeView = class("LaboratoryForAcademeView",function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node 
end)

function LaboratoryForAcademeView:ctor(size, parent)
	self:setContentSize(size)
	self.m_parent = parent
end

function LaboratoryForAcademeView:onEnter()
	self.particle = {{icon = "laboratory_particle_1", width = 17, height = 19},
					 {icon = "laboratory_particle_2", width = 15, height = 18},
					 {icon = "laboratory_particle_3", width = 15, height = 18},
					 {icon = "laboratory_particle_4", width = 15, height = 18},
					 {icon = "laboratory_particle_5", width = 15, height = 18},
					 {icon = "laboratory_particle_6", width = 15, height = 18}}

	armature_add(IMAGE_ANIMATION .. "effect/zzsys_cwj.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_cwj.plist", IMAGE_ANIMATION .. "effect/zzsys_cwj.xml")

	local function helpCallback(tar, sender)
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.LaboratoryHelper):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal2.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
	local helpBtn = MenuButton.new(normal, selected, nil, helpCallback):addTo(self, 5)
	helpBtn:setPosition(self:width() - helpBtn:width() * 0.5 - 3 , self:height() - helpBtn:height() * 0.5 + 1)

	-- 
	local allResWidth = self:width() - helpBtn:width()
	local items = {LABORATORY_ITEM1_ID, LABORATORY_ITEM2_ID, LABORATORY_ITEM3_ID, LABORATORY_ITEM4_ID}
	self.m_resNumber = {}
	-- res
	for index = 1 , 4 do
		local resSp = display.newScale9Sprite(IMAGE_COMMON .. "bar_bg_12.png"):addTo(self, 4)
		resSp:setPreferredSize(cc.size((allResWidth - 8) / 4 , 45))
		resSp:setAnchorPoint(cc.p(0, 1))
		resSp:setPosition((index - 1) * allResWidth * 0.25, self:height())

		local icon = display.newSprite(IMAGE_COMMON .. "laboratory/laboratory_item_" .. index .. ".png"):addTo(resSp, 1)
		icon:setPosition(10 + icon:width() * 0.5, resSp:height() * 0.5)

		local numberlb = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(resSp, 2)
		numberlb:setPosition(resSp:width() * 0.5 + icon:width() * 0.5 , icon:y())
		self.m_resNumber[items[index]] = numberlb
	end

	local topbg = display.newSprite(IMAGE_COMMON .. "info_bg_125.jpg"):addTo(self,1)
	topbg:setAnchorPoint(cc.p(0.5,1))
	topbg:setPosition(self:width() * 0.5, self:height())

	local effect = armature_create("zzsys_cwj"):addTo(topbg , 3)
	effect:getAnimation():playWithIndex(0)
	effect:setPosition(topbg:width() * 0.5 + 8, topbg:height() * 0.5  - 137)

	local bottom = display.newSprite(IMAGE_COMMON .. "info_bg_126.png"):addTo(self,2)
	bottom:setAnchorPoint(cc.p(0.5,1))
	bottom:setPosition(self:width() * 0.5, topbg:y() - topbg:height())
	self.m_contentView = bottom

	local lines = display.newSprite(IMAGE_COMMON .. "line3.png"):addTo(self,3)
	lines:setPosition(self:width() * 0.5, bottom:y())

	local function func1Callback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:OpenPersonnelAllotment()
		-- PersonnelAllotmentDialog.new(self.m_parent):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local func1Btn = MenuButton.new(normal, selected, nil, func1Callback):addTo(self, 6)
	func1Btn:setPosition(self:width() * 0.5 - func1Btn:width() + 18 , func1Btn:height() * 0.5 + 10)
	func1Btn:setLabel(CommonText[1762][1])

	local function func2Callback(tag, sender)
		ManagerSound.playNormalButtonSound()
		ScientificBreakThroughDialog.new(self.m_parent):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local func2Btn = MenuButton.new(normal, selected, nil, func2Callback):addTo(self, 6)
	func2Btn:setPosition(self:width() * 0.5 , func2Btn:height() * 0.5 + 10)
	func2Btn:setLabel(CommonText[1762][2])

	local function func3Callback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:OpenConstructionImprovement()
		-- ConstructionImprovementDialog.new(self.m_parent):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local func3Btn = MenuButton.new(normal, selected, nil, func3Callback):addTo(self, 6)
	func3Btn:setPosition(self:width() * 0.5 + func3Btn:width() - 18, func3Btn:height() * 0.5 + 10)
	func3Btn:setLabel(CommonText[1762][3])

	-- 玻璃瓶
	self.m_contentBgList = {}
	self.m_contentBgBtnList = {}
	local RESs = {LABORATORY_RES1_ID, LABORATORY_RES2_ID, LABORATORY_RES3_ID, LABORATORY_RES4_ID}
	local TECHS = {0, LABORATORY_TECH1_ID, LABORATORY_TECH2_ID, LABORATORY_TECH3_ID}
	local RESEARCHs = {LABORATORY_RESEARCH1_ID, LABORATORY_RESEARCH2_ID, LABORATORY_RESEARCH3_ID, LABORATORY_RESEARCH4_ID}
	local ITEMs = {LABORATORY_ITEM1_ID, LABORATORY_ITEM2_ID, LABORATORY_ITEM3_ID, LABORATORY_ITEM4_ID}
	local LIBs = {LABORATORY_RESEARCH1_LIB_ID, LABORATORY_RESEARCH2_LIB_ID, LABORATORY_RESEARCH3_LIB_ID, LABORATORY_RESEARCH4_LIB_ID}
	for index = 1 , 4 do
		local nomal = display.newSprite(IMAGE_COMMON .. "info_bg_glass.png")
		local selected = display.newSprite(IMAGE_COMMON .. "info_bg_glass.png")
		local contentBgBtn = MenuButton.new(nomal, selected, nil, handler(self, self.contentCallback)):addTo(self.m_contentView , 3)
		contentBgBtn:setPosition(self.m_contentView:width() * 0.5 + CalculateX(4, index, contentBgBtn:width(), 2.5), self.m_contentView:height() * 0.5 + 15)
		contentBgBtn.ID = RESs[index]
		contentBgBtn.TECH = TECHS[index]
		contentBgBtn.RESEARCH = RESEARCHs[index]
		contentBgBtn.ITEM = ITEMs[index]
		contentBgBtn:setVisible(false)
		self.m_contentBgBtnList[#self.m_contentBgBtnList + 1] = contentBgBtn
		-- contentBgBtn:drawBoundingBox()

		local rect = cc.rect(0, 0, contentBgBtn:width() - 8, contentBgBtn:height() - 49)
		local node = display.newClippingRegionNode(rect):addTo(contentBgBtn, 5)
		node.ID = RESs[index]
		node.LIB = LIBs[index]
		node.LIBEX = LABORATORY_RESEARCH_MAX_LIB_ID
		node.parent = contentBgBtn
		node:setPosition(4,24)
		
		local namebg = display.newSprite(IMAGE_COMMON .. "skin_gold_bg.png"):addTo(self.m_contentView , 1) -- title
		namebg:setPosition(contentBgBtn:x() + 5 , contentBgBtn:y() - contentBgBtn:height() * 0.5 - namebg:height() * 0.5 - 10)

		local info = LaboratoryMO.queryLaboratoryForItemById(RESs[index])
		local name = ui.newTTFLabel({text = info.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = _color}):addTo(namebg)
		name:setPosition(namebg:width() * 0.5, namebg:height() * 0.5 + 1)
		name:setVisible(false)
		contentBgBtn.namelb = name
		node.namelb = name

		self.m_contentBgList[#self.m_contentBgList + 1] = node
	end

	self.m_cTimeMax = 60 * 5
	self.m_cTimes = self.m_cTimeMax
	self.m_eachTime = {}

	-- 刷新时间
	if not self.timeScheduler then
		self.timeScheduler = scheduler.scheduleGlobal(handler(self,self.update), 1)
	end

	if not self.m_resHandler then
		self.m_resHandler = Notify.register("LOCAL_LABORATORY_RES_NOTIGY", handler(self, self.updateRes))
	end

	-- Notify.notify("LOCAL_LABORATORY_RES_NOTIGY")
	if not self.m_productHandler then
		self.m_productHandler = Notify.register("LOCAL_LABORATORY_PRODUCT_NOTIGY", handler(self, self.showContentValue))
	end
	

	LaboratoryBO.GetFightLabItemInfo(handler(self,self.loadData))

end

function LaboratoryForAcademeView:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/zzsys_cwj.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_cwj.plist", IMAGE_ANIMATION .. "effect/zzsys_cwj.xml")

	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
	end

	if self.m_resHandler then
		Notify.unregister(self.m_resHandler)
	end

	if self.m_productHandler then
		Notify.unregister(self.m_productHandler)
	end
end

function LaboratoryForAcademeView:update(ft)
	local times = 0
	-- 刷新
	for k, v in pairs(self.m_eachTime) do
		if v and v.state > 0 then
			times = times + 1
			v.time = v.time + 1
			if v.time >= v.maxtime then
				v.state = 0
				-- self:showContentValue()
				return
			end
		end
	end

	if times > 0 then
		self.m_cTimes = self.m_cTimes - 1 
		if self.m_cTimes <= 0 then
			self.m_cTimes = self.m_cTimeMax
			self:showContentValue()
		end
	end
end

-- 领取生产的资源
function LaboratoryForAcademeView:contentCallback(tar, sender)
	local itemid = sender.ID -- 碎片ID
	local techid = sender.TECH
	local research = sender.RESEARCH
	local item = sender.ITEM

	local researchData = LaboratoryMO.academeData.archData[research]
	if not researchData and researchData ~= 1 then
		local researchinfo = LaboratoryMO.queryLaboratoryForResearchById(research)
		Toast.show(researchinfo.name .. CommonText[929]) -- 生产建筑未解锁 CommonText[1769]
		return
	end

	local compose = 1 -- 合成效率
	local techData = LaboratoryMO.academeData.techData[techid]
	if techData then
		local techInfo = LaboratoryMO.queryLaboratoryForTechnologyByIdLv(techData.id , techData.lv)
		compose = techInfo.composeEfficiency
	end
	
	local resdata = LaboratoryMO.dataList[itemid]
	local curCount = resdata and resdata.count or 0

	local function resultCallback(shows)
		local awards = {}
		for index = 1 , #shows do
			local data = shows[index]
			if data and data.id == item then
				awards[#awards + 1] = data
			end
		end
		if #awards >= 0 then
			local awardshow = {awards = awards}
			UiUtil.showAwards(awardshow)
		end
		self:showContentValue()
	end

	-- 可以收获
	if curCount >= compose then
		LaboratoryBO.GetFightLabResource(resultCallback, itemid)
	else
		-- 不能收获
		-- Toast.show(CommonText[164] .. CommonText[1771] ) -- 碎片数量不足
		Toast.show(CommonText[1776]) -- 碎片数量不足
	end
end

function LaboratoryForAcademeView:updateRes()
	-- 更新物品
	local ITME = {LABORATORY_ITEM1_ID, LABORATORY_ITEM2_ID, LABORATORY_ITEM3_ID, LABORATORY_ITEM4_ID}
	for index = 1 , 4 do
		local id = ITME[index]
		local itemdata = LaboratoryMO.dataList[id]
		local itemLb = self.m_resNumber[itemdata.id]
		itemLb:setString(UiUtil.strNumSimplify(itemdata.count))
		-- itemLb:setString(itemdata.count)
	end
end

function LaboratoryForAcademeView:loadData()
	for k, v in pairs(self.m_contentBgBtnList) do
		v:setVisible(true)
		v.namelb:setVisible(true)
	end
	self:showContentValue()
end

-- 玻璃瓶 内容填充
function LaboratoryForAcademeView:showContentValue()
	self:updateRes()

	self.m_eachTime = {}

	-- 清楚子节点
	for index = 1 , 4 do
		local sp = self.m_contentBgList[index]
		if sp then
			sp:removeAllChildren()
		end
	end

	-- 更新碎片
	for index = 1 , 4 do
		local sp = self.m_contentBgList[index]
		local itemid = sp.ID
		local libID = sp.LIB
		local libmaxID = sp.LIBEX
		local uplibid = LaboratoryMO.academeData.archData[libID]
		local upMaxid = LaboratoryMO.academeData.archData[libmaxID]
		local upMaxValue = 0
		if uplibid and uplibid > 0 then
			local researchinfo = LaboratoryMO.queryLaboratoryForResearchById(libID)
			upMaxValue = upMaxValue + (researchinfo and researchinfo.addProduceTime or 0)
		end
		if upMaxid and upMaxid > 0 then
			local researchinfo = LaboratoryMO.queryLaboratoryForResearchById(libmaxID)
			upMaxValue = upMaxValue + (researchinfo and researchinfo.addProduceTime or 0)
		end
		local resdata = LaboratoryMO.resProduct[itemid]
		
		if index == 1 then
			self:drawType1(sp, resdata, upMaxValue)
		else
			math.randomseed(os.time() + index * 100)
			self:drawType2(sp, resdata, index, upMaxValue)
		end
	end
end

function LaboratoryForAcademeView:drawType1(sprite, data, upMaxValue)
	-- sprite:drawBoundingBox(ccc4f(0, 0, 1, 1))

	local allwidth = sprite:width()
	local allheight = sprite:height()
	
	if not data then 
		sprite.parent:setVisible(false)
		sprite.namelb:setVisible(false)
		-- sprite.parent:setNormalSprite(display.newSprite(IMAGE_COMMON .. "info_bg_glass2.png"))
		-- sprite.parent:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "info_bg_glass2.png"))
		return 
	else
		if not sprite.parent:isVisible() then
			sprite.parent:setVisible(true)
		end
		if not sprite.namelb:isVisible() then
			sprite.namelb:setVisible(true)
		end
	end


	local max = 1
	local id = data.id
	local cur = data.time

	if cur <= 0 then return end

	local itemdata = LaboratoryMO.queryLaboratoryForItemById(id)
	max = itemdata.maxProduceTime + upMaxValue

	local outTime = {}
	outTime.state = data.state
	outTime.time = data.time
	outTime.maxtime = max
	self.m_eachTime[id] = outTime
	
	local percent = cur / max
	percent = math.min(percent , 1)	

	local _sp = display.newScale9Sprite(IMAGE_COMMON .. "laboratory_part_0.png"):addTo(sprite)
	local height = math.max(allheight * percent, _sp:height())
	_sp:setPreferredSize(cc.size(_sp:width() , height))
	_sp:setAnchorPoint(cc.p(0.5, 0))
	_sp:setCapInsets(cc.rect(32,5 , 1, 1))
	_sp:setPosition(allwidth * 0.5, 0)
end

function LaboratoryForAcademeView:drawType2(sprite, data, index, upMaxValue)
	if not data then
		sprite.parent:setVisible(false)
		sprite.namelb:setVisible(false)
		-- sprite.parent:setNormalSprite(display.newSprite(IMAGE_COMMON .. "info_bg_glass2.png"))
		-- sprite.parent:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "info_bg_glass2.png"))
		return
	else
		if not sprite.parent:isVisible() then
			sprite.parent:setVisible(true)
		end
		if not sprite.namelb:isVisible() then
			sprite.namelb:setVisible(true)
		end
	end
	-- sprite.parent:setNormalSprite(display.newSprite(IMAGE_COMMON .. "info_bg_glass.png"))
	-- sprite.parent:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "info_bg_glass.png"))

	local size = cc.p(4,5)
	-- sprite:drawBoundingBox(ccc4f(1, 0, 0, 1))
	local allwidth = sprite:width() - 16
	local allheight = sprite:height() - 10

	local max = 1
	local id = data.id
	local cur = data.time

	local itemdata = LaboratoryMO.queryLaboratoryForItemById(id)
	max = itemdata.maxProduceTime + upMaxValue

	local outTime = {}
	outTime.state = data.state
	outTime.time = data.time
	outTime.maxtime = max
	self.m_eachTime[id] = outTime
	
	local percent = cur / max 
	percent = math.min(percent , 1)

	percent = percent * 100
	-- print(percent .. " " .. cur .. " " .. max .. " ")

	local pw = {}
	for i = 1 , size.x do
		local px = (allwidth / size.x) * (i - 0.5) + 6
		pw[i] = px
	end

	local ph = {}
	for i = 1, size.y do
		local py = (allheight / size.y) * (i - 1)
		ph[i] = py
	end

	local addpy = {1, 0.5, 0, 0.5, 1}

	local yh = math.floor(percent / 100 * size.y)
	local xw = math.min(math.ceil( (percent % size.y) / size.y * size.x ), size.x)

	for h = 1 , size.y do
		local wsize = size.x
		local out = false
		if h > yh then
			out = true
			wsize = xw
		end

		for w = 1 , wsize do
			local dex = math.random(10) % 2 + 1 + (index - 2) * 2
			local particle = self.particle[dex]
			local _sp = display.newSprite(IMAGE_COMMON .. particle.icon .. ".png"):addTo(sprite, (h * 10 + w) )
			if out then
				local yyy = ph[h]
				local xd = math.random(20) % size.x
				local xxx = pw[xd + 1]
				_sp:setPosition(xxx , yyy + addpy[w] + _sp:height() * 0.5 )
			else
				local yyy = ph[h]
				local xxx = pw[w]
				_sp:setPosition(xxx , yyy + addpy[w] + _sp:height() * 0.5 )
			end
			local rat = math.random(-75, 75)
			_sp:setRotation(rat)
			-- print(" . " .. _sp:x() .. " " .. _sp:y() .. "   w " .. w .. "  h " .. h )
		end
		if out then break end
	end

end

function LaboratoryForAcademeView:OpenPersonnelAllotment()
	-- body
	PersonnelAllotmentDialog.new(self.m_parent):push()
end

function LaboratoryForAcademeView:OpenConstructionImprovement()
	ConstructionImprovementDialog.new(self.m_parent):push()
end

return LaboratoryForAcademeView