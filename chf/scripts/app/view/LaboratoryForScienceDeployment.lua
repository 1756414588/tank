--
--
-- 坦克深度研究
--
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

-- 计算定点位置
local function CalculateAllX( size, index, allwidth)
	-- body
	local _width = allwidth / size
	return (index + 0.5) * _width
end

local color1 = ccc4f(1, 0, 0, 1)
local color2 = ccc4f(1, 1, 0, 1)

--------------------------------------------------------------
--						技能信息							--
--------------------------------------------------------------
local Dialog = require("app.dialog.DialogEx")
local DeploymentInfoView = class("DeploymentInfoView", Dialog)

function DeploymentInfoView:ctor(param)
	DeploymentInfoView.super.ctor(self)
	self.m_point = param.point
	self.m_type = param.type
	self.m_skillId = param.skillId
	self.m_offset = param.offset
	self.m_callback = param.callback
end

function DeploymentInfoView:onEnter()
	DeploymentInfoView.super.onEnter(self)
	self.m_outOfBgClose = true

	armature_add(IMAGE_ANIMATION .. "effect/zzsys_xz.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_xz.plist", IMAGE_ANIMATION .. "effect/zzsys_xz.xml")

	local point = self.m_point

	local infos = LaboratoryMO.queryLaboratoryForMilitarye(self.m_type, self.m_skillId)
	local data = LaboratoryMO.militarySkillData[self.m_skillId] -- LaboratoryMO.militaryData[self.m_type][self.m_skillId]

	local bgline = display.newSprite(IMAGE_COMMON .. "info_bg_130.png"):addTo(self, 2) -- info_bg_130 item_fame_1
	bgline:setPosition(point.x, point.y)

	local max = #infos
	local numberStr = data.lv == max and "Max" or tostring("Lv." .. data.lv)
	local totalname = ui.newTTFLabel({text = numberStr , font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(bgline)
	totalname:setPosition( 30, bgline:height() - 15 )

	local lv = data.lv > 0 and data.lv or 1
	local info = infos[lv]
	local itemsp = display.newSprite("image/item/" .. info.icon .. ".jpg"):addTo(bgline, -1)
	itemsp:setPosition(bgline:width() * 0.5, bgline:height() * 0.5 - 10)

	local effect = armature_create("zzsys_xz"):addTo(bgline , 3)
	effect:getAnimation():playWithIndex(0)
	effect:setPosition(bgline:width() * 0.5 , bgline:height() * 0.5 - 10)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_129.png"):addTo(self, 2)
	self.m_viewbg = bg

	if point.y - bgline:height() * 0.6 - bg:height() - 10 < 0 then
		bg:setPosition(display.width * 0.5, point.y + bgline:height() * 0.55 + bg:height() * 0.5 )
	else
		bg:setPosition(display.width * 0.5, point.y - bgline:height() * 0.55 - bg:height() * 0.5 )
	end

	self:showItem()

end

function DeploymentInfoView:showItem()

	local skillData = LaboratoryMO.militarySkillData[self.m_skillId] -- LaboratoryMO.militaryData[self.m_type][self.m_skillId]
	local skillInfo = LaboratoryMO.queryLaboratoryForMilitarye(self.m_type, self.m_skillId)
	local curLv = skillData.lv
	local nextLv = curLv + 1
	local maxLv = #skillInfo -- 个数代表可升的等级
	local showLv = curLv > 0 and curLv or 1
	local _showInfo = skillInfo[showLv]

	local item = display.newSprite("image/tank/tank_" .. (self.m_type + 102) .. ".png"):addTo(self.m_viewbg, 2)
	item:setScale(0.9)
	item:setPosition(30 + item:width() * 0.5 * item:getScale(),self.m_viewbg:height() - 20 - item:height() * 0.5 * item:getScale())

	if curLv == maxLv then 				-- 满级
		item:setPosition(item:x(), item:y() - 20)

		local desclb = ui.newTTFLabel({text = _showInfo.desc , font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(146, 208, 80)}):addTo(self.m_viewbg)
		desclb:setAnchorPoint(cc.p(0,0.5))
		desclb:setPosition( self.m_viewbg:width() * 0.5 - 70 , self.m_viewbg:height() - 35 - 30)

		-- 技能名称
		local curSkillName = ui.newTTFLabel({text = _showInfo.name .. "Lv.Max", font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self.m_viewbg)
		curSkillName:setAnchorPoint(cc.p(0,0.5))
		curSkillName:setPosition(  desclb:x() + 20, desclb:y() - 45)

		
		-- 效果
		local curSp = curSkillName
		local skillEffect = json.decode(_showInfo.effect)
		if skillEffect then
			for index = 1 , #skillEffect do
				local _se = skillEffect[index]
				local attrID = _se[1]
				local attrValue = _se[2]
				local _valueInfo = AttributeBO.getAttributeData(attrID, attrValue)
				local attrName = ui.newTTFLabel({text = _valueInfo.name .. ":" .. _valueInfo.strValue, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self.m_viewbg)
				attrName:setAnchorPoint(cc.p(0,0.5))
				attrName:setPosition(curSp:x() , curSp:y() - index * 25 )
				curSp = attrName
			end
		end

	else -- if curLv == showLv then 		-- 可升级 -- 可激活
		local pre = json.decode( _showInfo.perSkill )

		local _nextInfo = nil
		if curLv == showLv then
			_nextInfo = skillInfo[nextLv]
		end

		local desclb = ui.newTTFLabel({text = _showInfo.desc , font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(146, 208, 80)}):addTo(self.m_viewbg)
		desclb:setAnchorPoint(cc.p(0,0.5))
		desclb:setPosition( self.m_viewbg:width() * 0.5 - 90, self.m_viewbg:height() - 35)
		
		-- 技能名称
		local curSkillName = ui.newTTFLabel({text = _showInfo.name .."Lv." .. showLv, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self.m_viewbg)
		curSkillName:setAnchorPoint(cc.p(0,0.5))
		curSkillName:setPosition( desclb:x() , desclb:y() - 35)

		if _nextInfo then
			-- arrow
			local arrow = display.newSprite(IMAGE_COMMON .. "arrow2.png"):addTo(self.m_viewbg, 2)
			arrow:setAnchorPoint(cc.p(0,0.5))
			arrow:setPosition(curSkillName:x() + curSkillName:width(), curSkillName:y())

			local nextSkillName = ui.newTTFLabel({text = _nextInfo.name .."Lv." .. nextLv, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(146, 208, 80)}):addTo(self.m_viewbg)
			nextSkillName:setAnchorPoint(cc.p(0,0.5))
			nextSkillName:setPosition( arrow:x() + arrow:width(), curSkillName:y())
		end
		
		-- 效果
		local curSp = curSkillName
		local skillEffect = json.decode(_showInfo.effect)
		if skillEffect then
			local nextSkillEffect = _nextInfo and json.decode(_nextInfo.effect) or nil
			for index = 1 , #skillEffect do
				local _se = skillEffect[index]
				local attrID = _se[1]
				local attrValue = _se[2]
				local nextAttrValue = nextSkillEffect and nextSkillEffect[index][2] or nil
				local _valueInfo = AttributeBO.getAttributeData(attrID, attrValue)
				local attrName = ui.newTTFLabel({text = _valueInfo.name .. ":" .. _valueInfo.strValue, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self.m_viewbg)
				attrName:setAnchorPoint(cc.p(0,0.5))
				attrName:setPosition(curSp:x() , curSp:y() - index * 25)
				curSp = attrName

				if nextAttrValue then
					-- arrow
					local arrow = display.newSprite(IMAGE_COMMON .. "arrow2.png"):addTo(self.m_viewbg, 2)
					arrow:setAnchorPoint(cc.p(0,0.5))
					arrow:setPosition(attrName:x() + attrName:width(), attrName:y())

					local _nextvalueInfo = AttributeBO.getAttributeData(attrID, nextAttrValue)
					local nextattrlb = ui.newTTFLabel({text = _nextvalueInfo.strValue, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(146, 208, 80)}):addTo(self.m_viewbg)
					nextattrlb:setAnchorPoint(cc.p(0,0.5))
					nextattrlb:setPosition(arrow:x() + arrow:width(), attrName:y() )
				end
			end
		end
		

		-- 消耗材料
		local consume = ui.newTTFLabel({text = CommonText[927][4], font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self.m_viewbg)
		consume:setAnchorPoint(cc.p(0.5,0.5))
		consume:setPosition( 100 , 75)


		local costInfo = _nextInfo and json.decode(_nextInfo.cost) or json.decode(_showInfo.cost)
		for index = 1, #costInfo do
			local cost = costInfo[index]
			local kind = cost[1]
			local id = cost[2]
			local count = cost[3]
			local param = kind == ITEM_KIND_COIN and {count = count} or nil
			-- 消耗物品
			local costitem = UiUtil.createItemView(kind, id, param):addTo(self.m_viewbg)
			costitem:setScale(0.75)
			-- costitem:setPosition(consume:x() + consume:width() * 0.5 + 30 + costitem:width() * (index - 0.5) * costitem:getScale(), consume:y())
			costitem:setPosition(self.m_viewbg:width() * 0.5 + CalculateX(#costInfo ,index, costitem:width() * costitem:getScale(), 1.05), consume:y()) 
			UiUtil.createItemDetailButton(costitem)
			if kind ~= ITEM_KIND_COIN then
				local myCount = UserMO.getResource(kind, id)
				local countlb = ui.newTTFLabel({text = "/" .. UiUtil.strNumSimplify(count), font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(costitem, 10)
				countlb:setAnchorPoint(cc.p(1,0))
				countlb:setPosition(costitem:width() - 5, 5)

				local _color = myCount >= count and cc.c3b(255, 255, 255) or cc.c3b(255, 0, 0)
				local hascountlb = ui.newTTFLabel({text = UiUtil.strNumSimplify(myCount), font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER, color = _color}):addTo(costitem, 10)
				hascountlb:setAnchorPoint(cc.p(1,0))
				hascountlb:setPosition(countlb:x() - countlb:width() , countlb:y())
			end
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local levelupBtn = MenuButton.new(normal, selected, nil, handler(self, self.activeCallback)):addTo(self.m_viewbg, 5)
		levelupBtn:setPosition(self.m_viewbg:width() - levelupBtn:width() * 0.5 - 20 , levelupBtn:height() * 0.5 + 30)
		if _nextInfo then
			levelupBtn:setLabel(CommonText[1759][1])
		else
			levelupBtn:setLabel(CommonText[413][4])
		end 

		levelupBtn.type = _showInfo.type
		levelupBtn.skillId = _showInfo.skillId
		levelupBtn.costs = costInfo
		levelupBtn.pre = pre
	end

end

-- 激活
function DeploymentInfoView:activeCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local type = sender.type
	local skillId = sender.skillId
	local costs = sender.costs
	local pre = sender.pre

	local _curData = LaboratoryMO.militarySkillData[skillId]
	-- 未激活  或 无需前置 可直接激活
	if _curData.lv <= 0 and pre then
		local str = CommonText[96] .. CommonText[413][4] .. CommonText[1769]
		-- local _pre = 0
		for index = 1 , #pre do
			local item = pre[index]
			local preSkillId = item[1]
			local prelv = item[2]
			local _data = LaboratoryMO.militarySkillData[preSkillId]
			if _data.lv < prelv then
				local info = LaboratoryMO.queryLaboratoryForMilitarye(_data.type, _data.skillId)
				-- _pre = _pre + 1
				str = str .. "[" .. info[1].name .. "Lv." .. prelv .. "]"
				Toast.show(str)
				return
			end
		end
		-- 提示
		-- if _pre > 0 then
		-- 	Toast.show(str) -- Toast.show(CommonText[100012][1])
		-- 	return
		-- end
	end


	local function resultCallback(data)
		local out = {}
		out.skill = self.m_skillId
		out.offset = self.m_offset
		Notify.notify("LOCAL_RESET_EVENT_SCIENCE_DEPLOYMENT", out)
		Notify.notify("LOCAL_LABORATORY_SCIENCE_EVENT")
		self:doClose()
	end

	local function doSocket()
		LaboratoryBO.UpFightLabGraduateUp(resultCallback, type, skillId)
	end

	for index = 1 , #costs do
		local cost = costs[index]
		local kind = cost[1]
		local id = cost[2]
		local count = cost[3]
		local myCount = UserMO.getResource(kind, id)
		if count > myCount then
			local info = UserMO.getResourceData(kind, id)
			Toast.show(info.name .. CommonText[223])
			return
		end
	end

	doSocket()
end

function DeploymentInfoView:doClose()
	DeploymentInfoView.super.close(self)
end

function DeploymentInfoView:close()
	if self.m_callback then self.m_callback() end
	DeploymentInfoView.super.close(self)
end

function DeploymentInfoView:onExit()
	DeploymentInfoView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/zzsys_xz.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_xz.plist", IMAGE_ANIMATION .. "effect/zzsys_xz.xml")
end















--------------------------------------------------------------
--						研究技能带							--
--------------------------------------------------------------

local ScienceDeploymentTableView = class("ScienceDeploymentTableView",TableView)

function ScienceDeploymentTableView:ctor(size, data)
	ScienceDeploymentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_data = data
	self.m_cellSize = cc.size(self:getViewSize().width, 0)
end

function ScienceDeploymentTableView:onEnter()
	ScienceDeploymentTableView.super.onEnter(self)

	armature_add(IMAGE_ANIMATION .. "effect/zzsys_dq.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_dq.plist", IMAGE_ANIMATION .. "effect/zzsys_dq.xml")
	armature_add(IMAGE_ANIMATION .. "effect/zzsys_dl.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_dl.plist", IMAGE_ANIMATION .. "effect/zzsys_dl.xml")
	armature_add(IMAGE_ANIMATION .. "effect/zzsys_wdl.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_wdl.plist", IMAGE_ANIMATION .. "effect/zzsys_wdl.xml")

	self.m_showData = {}

	for k, v in pairs(self.m_data) do
		local c = math.floor(k / 100) % 10
		local e = v[1].skillId % 10
		local _out = self.m_showData[c]
		if _out then
			_out[e] = v
		else
			local out = {}
			out[e] = v
			out.index = c
			self.m_showData[c] = out
		end
	end

	local function mysort(a , b)
		return a.index < b.index
	end
	table.sort(self.m_showData, mysort)

	self.m_spList = {}

	self:drawItem()

	self.resetListener = Notify.register("LOCAL_RESET_EVENT_SCIENCE_DEPLOYMENT", handler(self, self.activeForAction))
	
end

function ScienceDeploymentTableView:drawItem(offset)
	local node = display.newNode()
	self.m_node = node

	local lineNode = display.newNode():addTo(node, 2)
	self.m_lineNode = lineNode

	self.m_spList = {}

	local nodeY = 0
	local thisY = 0
	local thisheight = 0
	local function lockSp(node)
		if node then
			if node.itemSp then
				node.itemSp:removeSelf()
				node.itemSp = nil
			end

			local sp = display.newGraySprite("image/item/"  .. node.picture .. ".jpg"):addTo(node,-1)
			sp:setPosition(node:width() * 0.5 , node:height() * 0.5 - 10)
		end
	end

	local function unlockSp(node)
		if node then
			if node.itemSp then
				node.itemSp:removeSelf()
				node.itemSp = nil
			end

			local sp = display.newSprite("image/item/"  .. node.picture .. ".jpg"):addTo(node,-1)
			sp:setPosition(node:width() * 0.5 , node:height() * 0.5 - 10)
		end
	end

	local size = #self.m_showData
	for index = 1 , size do
		local lists = self.m_showData[index]
		local _allsize = #lists
		for n = 1 , _allsize do
			local _list = lists[n]
			local _type = _list[1].type
			local _skillId = _list[1].skillId
			local _data = LaboratoryMO.militarySkillData[_skillId] -- LaboratoryMO.militaryData[_type][_skillId]
			local _lv = _data.lv > 0 and _data.lv or 1
			local _info = _list[_lv]

			-- 绘制元素 info_bg_130 item_fame_1
			local sp = display.newSprite(IMAGE_COMMON .. "info_bg_130.png"):addTo(self.m_node,5)
			thisheight = sp:getContentSize().height
			thisY = nodeY - sp:getContentSize().height * 0.5 - 10
			local _x = CalculateAllX(_allsize, (n-1) % _allsize, self.m_cellSize.width )
			sp:setPosition(_x, thisY )

			sp.picture = _info.icon 						-- 图标icon 
			sp.lockSpFunc = lockSp 							-- 已解锁图标icon
			sp.unlockSpFunc = unlockSp 						-- 未解锁图标icon
			sp.isTouchEnable = true 						-- 是否可点击状态
			sp.skillId = _data.skillId

			if _data.lv == 0 then
				sp:lockSpFunc()

				local effect = armature_create("zzsys_wdl",sp:width() * 0.5,sp:height() * 0.5 - 10):addTo(sp , 10)
				effect:setVisible(false)
				sp.effect = effect
			else
				sp:unlockSpFunc()
			end
			self:setTouchFunc(sp)

			local max = #_list
			local numberStr = _data.lv == max and "Max" or tostring("Lv." .. _data.lv)
			local totalname = ui.newTTFLabel({text = numberStr , font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(sp)
			totalname:setPosition( 30, sp:height() - 15 )

			local out = {}
			out.type = _data.type
			out.skillId = _data.skillId
			out.lv = _data.lv -- 根据数据 处理
			out.item = sp
			out.ccp = cc.p(sp:x() , sp:y() - 10)
			out.all = _allsize
			out.cur = n
			out.pre = _info.perSkill and json.decode(_info.perSkill) or nil
			self.m_spList[out.skillId] = out
		end
		nodeY = thisY - thisheight * 1.5
	end

	self.m_maxHeight = nodeY
	self.m_cellSize = cc.size(self.m_viewSize.width, -nodeY)
	self:reloadData()

	self:drawline()

	if offset then
		self:setContentOffset(offset)
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
function ScienceDeploymentTableView:drawline()
	if self.m_lineNode then
		self.m_lineNode:removeAllChildren()
	end

	local drawlist = {}
	for k, v in pairs(self.m_spList) do
		drawlist[#drawlist + 1] = v
	end

	local function mysort(a, b)
		return a.skillId < b.skillId
	end

	table.sort(drawlist, mysort)

	-- local line = CCDrawNode:create():addTo(self.m_node, 2)
	-- self.m_line = line

	self.m_lineInfo = {}

	-- draw
	for index = 1 , #drawlist do
		local info = drawlist[index]
		if info.pre then
			local openlockEffect = true
			local list = info.pre
			for n = 1 , #list do
				local item = list[n]
				local preSkillId = item[1]
				local _data = LaboratoryMO.militarySkillData[preSkillId]
				if _data.lv <= 0 then openlockEffect = false end

				local preInfo = self.m_spList[preSkillId]
				-- 中心Y
				local centerY = (preInfo.ccp.y + info.ccp.y) / 2

				-- 前置点
				local prePoint = preInfo.ccp
				local prePointEx = cc.p(prePoint.x, centerY)

				-- 后置点 （当前点）
				local cPoint = info.ccp
				local cPointEx = cc.p(cPoint.x, centerY)

				-- key 前置 + 1 ；后置 - 1 ；链接线 后置 * 10 + 前置 -----（废弃）
				-- line1 
				local line1 = {from = prePoint, to = prePointEx, key = preInfo.skillId + 500000}
				if not self.m_lineInfo[line1.key] then
					-- line:drawSegment(line1.from, line1.to, 1, color1)
					local linesp = display.newSprite(IMAGE_COMMON .. "line4.png"):addTo(self.m_lineNode, 2)
					linesp:setPosition((line1.from.x + line1.to.x) * 0.5 , (line1.from.y + line1.to.y) * 0.5 )
					linesp:setScaleX( (line1.from.y - line1.to.y + 2) / linesp:width() )
					linesp:setRotation(-90)
					self.m_lineInfo[line1.key] = line1
				end
        		

        		local line2 = {from = cPointEx, to = cPoint, key = info.skillId + 300000}
        		if not self.m_lineInfo[line2.key] then
        			-- line:drawSegment(line2.from, line2.to, 1, color1)
        			local linesp = display.newSprite(IMAGE_COMMON .. "line4.png"):addTo(self.m_lineNode, 2)
					linesp:setPosition((line2.from.x + line2.to.x) * 0.5 , (line2.from.y + line2.to.y) * 0.5 )
					linesp:setScaleX( (line2.from.y - line2.to.y + 2 ) / linesp:width() )
					linesp:setRotation(-90)

					if (info.all % 2 ) == 1 and (info.cur % 2 ) == 0 then
						linesp:setRotation(90)
					end

        			self.m_lineInfo[line2.key] = line2
        		end
        		

        		if prePointEx.x ~= cPointEx.x then
        			local line3 = {from = prePointEx, to = cPointEx, key = info.skillId + preInfo.skillId + 400000}
        			if not self.m_lineInfo[line3.key] then
        				-- line:drawSegment(line3.from, line3.to, 1, color1)
        				local linesp = display.newSprite(IMAGE_COMMON .. "line4.png"):addTo(self.m_lineNode, 2)
						linesp:setPosition((line3.from.x + line3.to.x) * 0.5 , (line3.from.y + line3.to.y) * 0.5 )
						if line3.from.x < line3.to.x then
							linesp:setScaleX( (line3.from.x - line3.to.x + 2 ) / linesp:width() )
							linesp:setRotation(180)
						else
							linesp:setScaleX( (line3.to.x - line3.from.x + 2) / linesp:width() )
						end
						
        				self.m_lineInfo[line3.key] = line3
        			end
        			
        		end
			end

			-- 动画
    		if info.lv == 0 and info.item.effect and openlockEffect then
    			info.item.effect:setVisible(true)
    			info.item.effect:getAnimation():playWithIndex(0)
    		end
		end
	end
end

function ScienceDeploymentTableView:activeForAction(param)
	local skillId = param.obj.skill
	local offset = param.obj.offset

	local lineActions = {}
	local spInfo = self.m_spList[skillId]
	local list = spInfo and spInfo.pre or {}
	for n = 1 , #list do
		local item = list[n]
		local preSkillId = item[1] -- item[2] 技能LV
		local preInfo = self.m_spList[preSkillId]

		local line = {}
		-- from
		local key1 = preInfo.skillId + 500000
		local point1 = self.m_lineInfo[key1]

		-- to
		local key2 = spInfo.skillId + 300000
		local point2 = self.m_lineInfo[key2]

		-- center
		local key3 = spInfo.skillId + preInfo.skillId + 400000
		local point3 = self.m_lineInfo[key3]

		if point1 then line[#line + 1] = point1 end
		if point3 then line[#line + 1] = point3 end
		if point2 then line[#line + 1] = point2 end

		lineActions[#lineActions + 1] = line
	end

	local max = #lineActions
	local count = 0

	local function show()
		self:drawItem(offset)
	end

	local function playdl(index)
		if index == max then
			local effect = armature_create("zzsys_dl",0,0,function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
					show()
				end
			end):addTo(spInfo.item , 10)
			effect:setPosition(spInfo.item:width() * 0.5, spInfo.item:height() * 0.5)
			effect:getAnimation():playWithIndex(0)
		end
	end

	playdl(count)
	
	for n = 1 , max do

		local effect = armature_create("zzsys_dq"):addTo(self.m_lineNode , 3)
		effect:getAnimation():playWithIndex(0)

		local lineInfo = lineActions[n]
		local size = #lineInfo

		local cap = CCPointArray:create(6)
		for index = 1, size do
			local line = lineInfo[index]
			cap:add( line.from )
			if index == size then
				cap:add( line.to )
			end
		end
		local action = CCCardinalSplineBy:create((size + 1) * 0.3,cap , 1) -- 0.2

		effect:runAction(transition.sequence({action,cc.CallFuncN:create(function (sender) 
			sender:removeSelf()
			count = count + 1
			playdl(count)
		end)}))
	end
end


function ScienceDeploymentTableView:setTouchFunc(node)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			ManagerSound.playNormalButtonSound()
			local rect = self:getViewRect()
			if not cc.rectContainsPoint(rect, cc.p(event.x, event.y)) then
				return false
			end
			return true
		elseif event.name == "ended" then
			if not node.isTouchEnable then return end
			local offset = self:getContentOffset()
			if offset.y > self:maxContainerOffset().y or offset.y < self:minContainerOffset().y then return end

			local showData = self.m_spList[node.skillId]

			-- local _curData = LaboratoryMO.militarySkillData[node.skillId] -- LaboratoryMO.militaryData[showData.type][node.skillId]
			-- -- 未激活  或 无需前置 可直接激活
			-- if _curData.lv <= 0 and showData.pre then
			-- 	local str = CommonText[96] .. CommonText[413][4] .. CommonText[1769]
			-- 	-- local _pre = 0
			-- 	for index = 1 , #showData.pre do
			-- 		local item = showData.pre[index]
			-- 		local preSkillId = item[1]
			-- 		local prelv = item[2]
			-- 		local _data = LaboratoryMO.militarySkillData[preSkillId] -- LaboratoryMO.militaryData[showData.type][preSkillId]
			-- 		if _data.lv < prelv then
			-- 			local info = LaboratoryMO.queryLaboratoryForMilitarye(_data.type, _data.skillId)
			-- 			-- _pre = _pre + 1
			-- 			str = str .. "[" .. info[1].name .. "Lv." .. prelv .. "]"
			-- 			Toast.show(str)
			-- 			return
			-- 		end
			-- 	end
			-- 	-- 提示
			-- 	-- if _pre > 0 then
			-- 	-- 	Toast.show(str) -- Toast.show(CommonText[100012][1])
			-- 	-- 	return
			-- 	-- end
			-- end

			local outPoint = cc.p( self:getPositionX() + node:x(), offset.y + node:y()  - self.m_maxHeight )
			DeploymentInfoView.new({point = outPoint, picture = node.picture, type = showData.type, skillId = showData.skillId, offset = offset, callback = handler(self,self.allItemEnabledTouch)}):push()

			self:allItemUnEnabledTouch()
		end
	end)
end

function ScienceDeploymentTableView:allItemEnabledTouch()
	for k , v in pairs(self.m_spList) do
		v.item.isTouchEnable = true
	end
end

function ScienceDeploymentTableView:allItemUnEnabledTouch()
	for k , v in pairs(self.m_spList) do
		v.item.isTouchEnable = false
	end
end

function ScienceDeploymentTableView:numberOfCells()
	return 1
end

function ScienceDeploymentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ScienceDeploymentTableView:createCellAtIndex(cell, index)
	ScienceDeploymentTableView.super.createCellAtIndex(self, cell, index)
	self.m_node:addTo(cell)
	self.m_node:setPosition(0,self.m_cellSize.height)
	return cell
end

function ScienceDeploymentTableView:onExit()
	ScienceDeploymentTableView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/zzsys_dq.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_dq.plist", IMAGE_ANIMATION .. "effect/zzsys_dq.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/zzsys_dl.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_dl.plist", IMAGE_ANIMATION .. "effect/zzsys_dl.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/zzsys_wdl.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_wdl.plist", IMAGE_ANIMATION .. "effect/zzsys_wdl.xml")

	if self.resetListener then
		Notify.unregister(self.resetListener)
		self.resetListener = nil
	end
end
























--------------------------------------------------------------
--						坦克深度研究						--
--------------------------------------------------------------

local LaboratoryForScienceDeployment = class("LaboratoryForScienceDeployment",UiNode)

function LaboratoryForScienceDeployment:ctor(typeForm)
	LaboratoryForScienceDeployment.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_typeForm = typeForm
	self.m_tableView = nil
end

function LaboratoryForScienceDeployment:onEnter()
	LaboratoryForScienceDeployment.super.onEnter(self)
	self:setTitle(CommonText[162][self.m_typeForm] .. CommonText[1772])
	self:hasCoinButton(true)

	armature_add(IMAGE_ANIMATION .. "effect/zzsys_bg.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_bg.plist", IMAGE_ANIMATION .. "effect/zzsys_bg.xml")

	local m_militartyInfo = LaboratoryMO.queryLaboratoryForMilitarye(self.m_typeForm)

	local bg = display.newSprite(IMAGE_COMMON .. "laboratory/deployment_" .. self.m_typeForm .. ".jpg"):addTo(self:getBg(), 1)
	bg:setAnchorPoint(cc.p(0.5,0))
	bg:setPosition(self:getBg():width() * 0.5 ,0)

	local effect = armature_create("zzsys_bg"):addTo(self:getBg(), 2)
	effect:setPosition(self:getBg():width() * 0.5, self:getBg():height() - effect:getContentSize().height * 0.5 - 80)
    effect:getAnimation():playWithIndex(0)

	local size = cc.size(self:getBg():width() - 20, self:getBg():height() - 100)
	local view = ScienceDeploymentTableView.new(size, m_militartyInfo):addTo(self:getBg(), 5)
	view:setPosition(10,0)

	self.m_tableView = view

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local resetBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onClickResetBtn)):addTo(self:getBg(), 6)
	resetBtn:setPosition(self:getBg():width() - resetBtn:getContentSize().width / 2, self:getBg():height() - resetBtn:getContentSize().height - 60)
	resetBtn:setLabel("全部重置")

	self.m_resetHandler = Notify.register(LOCAL_RESET_ALL_EVENT_SCIENCE_DEPLOYMENT, handler(self, self.onResetAll))
end

function LaboratoryForScienceDeployment:onExit()
	LaboratoryForScienceDeployment.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/zzsys_bg.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_bg.plist", IMAGE_ANIMATION .. "effect/zzsys_bg.xml")

	if self.m_resetHandler then
		Notify.unregister(self.m_resetHandler)
		self.m_resetHandler = nil
	end
end

function LaboratoryForScienceDeployment:onClickResetBtn()
	-- body
	local allZero = true
	for k, v in pairs(LaboratoryMO.militarySkillData) do
		if v.lv > 0 and v.type == self.m_typeForm then
			allZero = false
			break
		end
	end

	if allZero == false then
		local goldCost = LaboratoryBO.getResetFightLabGraduateUpCost(self.m_typeForm)
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		local confirmStr = {
			{content="是否花费"},
			{content=string.format("%d", goldCost), color=COLOR[6]},
			{content="金币重置"},
			{content=CommonText[162][self.m_typeForm], color=COLOR[6]},
			{content="类型研究，重置后"},
			{content=CommonText[162][self.m_typeForm], color=COLOR[6]},
			{content="研究清零并返还所有材料"},
		}
		ConfirmDialog.new(confirmStr, function()
			LaboratoryBO.ResetFightLabGraduateUp(self.m_typeForm, function (data)
			    -- body
				Toast.show("重置完毕")
			end)
		end):push()
	else
		Toast.show("已经处于重置状态")
	end
end

function LaboratoryForScienceDeployment:onResetAll()
	-- body
	if self.m_tableView then
		self.m_tableView:removeSelf()
		self.m_tableView = nil
	end

	local m_militartyInfo = LaboratoryMO.queryLaboratoryForMilitarye(self.m_typeForm)

	local size = cc.size(self:getBg():width() - 20, self:getBg():height() - 100)
	local view = ScienceDeploymentTableView.new(size, m_militartyInfo):addTo(self:getBg(), 5)
	view:setPosition(10,0)

	self.m_tableView = view
end


return LaboratoryForScienceDeployment