
local InsetPageView = class("InsetPageView", PageView)

local function formatUnInlayConfirm(stoneName, lv, color)
	local str = CommonText[947][1]
	str = json.decode(str)

	dump(str, "formatUnInlayConfirm")

	local stringDatas = {}

	for i=1,#str do
		stringDatas[i] = {}
		stringDatas[i].size = FONT_SIZE_MEDIUM - 2
	end

	stringDatas[1].content = str[1][1]

	stringDatas[2].content = string.format(str[2][1], stoneName, lv)
	stringDatas[2].color = color

	return stringDatas
end


local RED = 1
local BLUE = 2
local YELLOW = 3
local DEFAULT = 0
local Ext = "type"
local InsetQulityRes = {
	[Ext .. RED] = "chose_5.png",
	[Ext .. BLUE] = "chose_6.png",
	[Ext .. YELLOW] = "chose_7.png",
	[Ext .. DEFAULT] = "chose_5.png",
}

local InsetQulityResEx = {
	[Ext .. RED] = "1b.png",
	[Ext .. BLUE] = "2b.png",
	[Ext .. YELLOW] = "3b.png",
	[Ext .. DEFAULT] = "icon_lock_1.png",
}

local levelLimit = {
	[4] = 60,
	[5] = 65,
	[6] = 70
}

function InsetPageView:ctor(size, pageCounts)
	InsetPageView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_pageCounts = pageCounts
	self.m_cellSize = size
	self.m_insetHoleStates = {RED,BLUE,YELLOW,DEFAULT,DEFAULT,DEFAULT}
	self.m_insetHoles = {}
	self.selected_ = {}
end

function InsetPageView:numberOfCells()
	return self.m_pageCounts
end

function InsetPageView:cellSizeForIndex(index)
	return self.m_cellSize
end

function InsetPageView:createCellAtIndex(cell, index)
	InsetPageView.super.createCellAtIndex(self, cell, index)

	local componentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell)
	componentBg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height-20))
	componentBg:setPosition(self.m_cellSize.width / 2, componentBg:getContentSize().height/2)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(componentBg)
	titleBg:setPosition(componentBg:getContentSize().width / 2, componentBg:getContentSize().height - 10)

	local name = ui.newTTFLabel({text = string.format(CommonText[943][1], index), 
		font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2,
		align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	local function onClickCallback( tag, sender )
		if not sender.item then
			if levelLimit[sender.holeIndex] and UserMO.level_ < levelLimit[sender.holeIndex] then
				Toast.show(string.format(CommonText[20150],levelLimit[sender.holeIndex]))
				return
			end
			---镶嵌			
			local EnergyInsetDialog = require("app.dialog.EnergyInsetDialog")
			EnergyInsetDialog.new(sender.holePos, sender.holeIndex, sender.state, sender.subType):push()			
		else
			---拆除
			local stoneId = EnergySparMO.getEnergySparByPos(sender.holePos, sender.holeIndex)
			if stoneId > 0 then
				local sparDB = EnergySparMO.queryEnergySparById(stoneId)
				local ConfirmDialog = require("app.dialog.ConfirmDialog")
				-- local desc = string.format(CommonText[947][1], sparDB.stoneName, sparDB.level)
				local desc = formatUnInlayConfirm(sparDB.stoneName, sparDB.level, COLOR[sparDB.quite])
				ConfirmDialog.new(desc, function()
					local function doneCallback( ... )
						Loading.getInstance():unshow()
						Toast.show(CommonText[950][2])
					end
					Loading.getInstance():show()
					EnergySparBO.doEnergyStoneInlay(doneCallback, sender.holePos, sender.holeIndex, -1)				
				end):push()	
			end		
		end
	end

	local state = 0
	local startX = componentBg:getContentSize().width / 2
	local scale = 0.7

	if not self.m_insetHoles[index] then
		self.m_insetHoles[index] = {}
	end

	for i=1,6 do
		local normal = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png")
		local itemBg = CellMenuButton.new(normal, selected)
		itemBg.holeIndex = i
		itemBg.holePos = index

		itemBg:setScale(scale)
		-- itemBg:setVisible(true)
		local x = componentBg:getContentSize().width / 2 + ((i % 3 + ((i % 3 == 0) and 3 or 0)) - 2) * ((itemBg:getContentSize().width * scale) + 5)
		local y =  componentBg:getContentSize().height - itemBg:getContentSize().height * scale / 2 - 60 - (math.floor((i-1)/3)*(itemBg:getContentSize().height *scale + 20))
		-- itemBg:setPosition(x, y)
		cell:addButton(itemBg, x, y)
		state = self.m_insetHoleStates[i]

		if state == DEFAULT then
			local bg = display.newGraySprite(IMAGE_COMMON .. InsetQulityRes[Ext .. state])
			if levelLimit[i] and UserMO.level_ >= levelLimit[i] then
				state = self.m_insetHoleStates[i-3]
				bg = display.newSprite(IMAGE_COMMON .. InsetQulityRes[Ext .. state])
			else
				UiUtil.label("LV."..levelLimit[i],30):addTo(bg):pos(bg:width()/2,30)
			end
			bg:addTo(itemBg):center()
			local item = display.newSprite(IMAGE_COMMON .. InsetQulityResEx[Ext .. state]):addTo(itemBg):center()
			item:setScale(1/scale)
		else
			display.newSprite(IMAGE_COMMON .. InsetQulityRes[Ext .. state]):addTo(itemBg):center()
			local item = display.newSprite(IMAGE_COMMON .. InsetQulityResEx[Ext .. state]):addTo(itemBg):center()
			item:setScale(1/scale)

		end
		itemBg:setTagCallback(onClickCallback)
		
		itemBg.state = state
		self.m_insetHoles[index][i] = itemBg 
	end

	self:refresh(index)

	return cell
end

function InsetPageView:refresh(curPage)
	curPage = curPage or self:getCurrentIndex()
	local insetHoles = self.m_insetHoles[curPage]
	if insetHoles then
		for i,v in ipairs(insetHoles) do
			if v.item then
				v.item:removeSelf()
				v.item = nil
			end
			--对应种类额subType
			local pos = v.holeIndex
			if pos <= 3 then
				pos = pos + 3
			else
				pos = pos - 3
			end
			insetHoles[pos].subType = nil
			if v.state ~= DEFAULT then
				local stoneId = EnergySparMO.getEnergySparByPos(v.holePos, i)
				if stoneId > 0 then 
					local itemView = UiUtil.createItemView(ITEM_KIND_ENERGY_SPAR, stoneId):addTo(v)
					itemView:center()
					itemView:setScale(1/v:getScale())
					v.item = itemView
					insetHoles[pos].subType = EnergySparMO.queryEnergySparById(stoneId).type
				end
			end
		end
	end
end

function InsetPageView:getEmptyData()
	local insetHoles = self.m_insetHoles[self:getCurrentIndex()]
	local item = clone(EnergySparMO.energySpar_)
	local unpos = {}
	--先卸下装备
	for i,v in ipairs(insetHoles) do
		if v.item then
			local stoneId = EnergySparMO.getEnergySparByPos(v.holePos, i)
			unpos[i] = stoneId
			if item[stoneId] then 
				item[stoneId].count = item[stoneId].count + 1
			else 
				item[stoneId] = {stoneId = stoneId, count = 1} 
			end
		end
	end
	local list = {}
	for stoneId, spar in pairs(item) do
		if spar.count > 0 then
			table.insert(list,spar)
		end
	end
	table.sort(list, function(spar1, spar2)
			local spar1DB = EnergySparMO.queryEnergySparById(spar1.stoneId)
			local spar2DB = EnergySparMO.queryEnergySparById(spar2.stoneId)
			return spar1DB.level > spar2DB.level
		end)	

	local has = {}
	for k,v in ipairs(list) do
		local eb = EnergySparMO.queryEnergySparById(v.stoneId)
		if not has[eb.holeType] then
			has[eb.holeType] = {}
		end
		table.insert(has[eb.holeType],v)
	end
	local function posType(v,id)
		local stoneId = id or EnergySparMO.getEnergySparByPos(v.holePos, i)
		--对应种类额subType
		local pos = v.holeIndex
		if pos <= 3 then
			pos = pos + 3
		else
			pos = pos - 3
		end
		return pos,EnergySparMO.queryEnergySparById(stoneId).type
	end
	local inPos = {}
	local needPos = {}
	--装备空巢
	for i,v in ipairs(insetHoles) do
		if v.state ~= DEFAULT then
			local data = has[v.state]
			if data then
				for k=1,#data,1 do
					if not inPos[i] then
						table.insert(needPos,{v1 = i, v2 = data[k].stoneId})
						local p,t = posType(v,data[k].stoneId)
						inPos[p] = t
						table.remove(data,k)
						break
					else
						local eb = EnergySparMO.queryEnergySparById(data[k].stoneId)
						if eb.type ~= inPos[i] then
							table.insert(needPos,{v1 = i, v2 = data[k].stoneId})
							local p,t = posType(v,data[k].stoneId)
							inPos[p] = t
							table.remove(data,k)
							break
						end
					end
				end
			end
		end
	end

	gdump(unpos,"unpos=============")
	gdump(needPos,"need=============")
	if #needPos == 0 then
		Toast.show(CommonText[20152])
		return
	end
	EnergySparBO.allInlay(self:getCurrentIndex(),unpos,needPos,function()
		Toast.show(CommonText[950][1])
	end)
end

function InsetPageView:onEnter()
	local function onLastCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		local curPage = self:getCurrentIndex()
		self:setCurrentIndex(curPage - 1, true)
	end

	local function onNextCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		local curPage = self:getCurrentIndex()
		self:setCurrentIndex(curPage + 1, true)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	selected:setScale(-1)
	local lastBtn = MenuButton.new(normal, selected, nil, onLastCallback):addTo(self)
	lastBtn:setPosition(50, self:getContentSize().height / 2)
	lastBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(-20, 0)), cc.MoveBy:create(2, cc.p(20, 0))})))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, onNextCallback):addTo(self)
	nxtBtn:setPosition(self:getContentSize().width - 50, self:getContentSize().height / 2)
	nxtBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(20, 0)), cc.MoveBy:create(2, cc.p(-20, 0))})))

	local function scrollPage(event)
		local curPage = self:getCurrentIndex()
		if curPage <= 1 then
			lastBtn:setVisible(false)
		else
			lastBtn:setVisible(true)
		end

		if curPage >= self:numberOfCells() then
			nxtBtn:setVisible(false)
		else
			nxtBtn:setVisible(true)
		end

        for index,v in ipairs(self.selected_) do
	        if index ~= curPage then
	            v:setVisible(false)
	        else
	        	v:setVisible(true)
	        	v:setOpacity(255)
	        end
        end
	end

	self:addEventListener("PAGE_SCROLL_TO", scrollPage)

	local startX = self:getViewSize().width / 2 - (self:numberOfCells() - 1) * 30 / 2

    for index = 1, self:numberOfCells() do
        local bg = display.newSprite("image/common/scroll_bg_2.png"):addTo(self)
        bg:setPosition(startX + (index - 1) * 30, 25)

        local selected = display.newSprite("image/common/scroll_head_2.png"):addTo(self, 2)
        selected:setPosition(bg:getPositionX(), bg:getPositionY())
        selected:setVisible(false)

        self.selected_[index] = selected
    end	

	local function onDetailCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.energyspar):push()
	end

	-- 详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, onDetailCallback):addTo(self, 1000)
	detailBtn:setPosition(self.m_cellSize.width - detailBtn:getContentSize().width/2, self.m_cellSize.height - detailBtn:getContentSize().height/2 - 20)
end

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

local EquipConfig = {
{wire = {p = cc.p(-124, 112), a = cc.p(0, 1)}, pos = EQUIP_POS_ATK, index = ATTRIBUTE_INDEX_ATTACK}, -- 攻击
{wire = {p = cc.p(-124, -10), a = cc.p(0, 0)}, pos = EQUIP_POS_HIT, index = ATTRIBUTE_INDEX_HIT}, -- 命中
{wire = {p = cc.p(-124, -112), a = cc.p(0, 0)}, pos = EQUIP_POS_CRIT, index = ATTRIBUTE_INDEX_CRIT}, -- 暴击
{wire = {p = cc.p(124, 112), a = cc.p(1, 1)}, pos = EQUIP_POS_HP, index = ATTRIBUTE_INDEX_HP}, -- 生命
{wire = {p = cc.p(124, 10), a = cc.p(1, 1)}, pos = EQUIP_POS_DODGE, index = ATTRIBUTE_INDEX_DODGE}, -- 闪避
{wire = {p = cc.p(124, -112), a = cc.p(1, 0)}, pos = EQUIP_POS_CRIT_DEF, index = ATTRIBUTE_INDEX_CRIT_DEF}, -- 抗暴
}

-- 能晶系统view

local EnergySparView = class("EnergySparView", UiNode)

ENERGYSPAR_VIEW_HOME = 1  ---仓库
ENERGYSPAR_VIEW_INSET = 2  ---镶嵌
local COLOR_GRAY = cc.c3b(115,115,115)

function EnergySparView:ctor(viewFor, chosenPosition)
	EnergySparView.super.ctor(self, IMAGE_COMMON .."bg_ui.jpg", UI_ENTER_NONE)
	self.m_viewFor = viewFor or ENERGYSPAR_VIEW_INSET
	-- self.m_viewFor = ENERGYSPAR_VIEW_INSET --- test
	self.m_chosenPosition = chosenPosition or 1
end

function EnergySparView:onEnter()
	EnergySparView.super.onEnter(self)
	self:setTitle(CommonText[941][1])
	self:showUI()

	self.viewforHandler_ = Notify.register(LOCAL_ENERGYSPAR_VIEW_FOR_EVENT, handler(self, self.onUpdateViewFor))
	self.energysparHandler_ = Notify.register(LOCAL_ENERGYSPAR_EVENT, handler(self, self.onUpdateInfo))
end

function EnergySparView:onExit()
	EnergySparView.super.onExit(self)
	
	Notify.unregister(self.viewforHandler_)
	self.viewforHandler_ = nil	

	Notify.unregister(self.energysparHandler_)
	self.energysparHandler_ = nil
end

function EnergySparView:onUpdateViewFor( event )
	dump(event,"onUpdateViewFor")
	self.m_viewFor = event.obj.viewFor
	self.m_pageView:setPageIndex(self.m_viewFor)
end

function EnergySparView:onUpdateInfo()
	if self.m_energyhouseView then
		self.m_energyhouseView:refrushTableView(self.m_holeType)
	end

	if self.m_energyInlayView then
		self.m_energyInlayView:refresh()
		self:freshAttributes()
	end
end

function EnergySparView:showUI()
	local function createDelegate(container, index)
		self.m_energyhouseView = nil
		self.m_energyInlayView = nil
		if index == ENERGYSPAR_VIEW_HOME then  -- 仓库
			self:showWarehouse(container)
		elseif index == ENERGYSPAR_VIEW_INSET then -- 镶嵌
			self:showInsetView(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = {CommonText[169], CommonText[942]}
	local size = cc.size(GAME_SIZE_WIDTH - 20, GAME_SIZE_HEIGHT - 140)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView
end

function EnergySparView:showWarehouse(container)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 160))
	bg:setPosition(container:getContentSize().width/2, bg:getContentSize().height/2 + 160)

	local EngrysparWarehouseTableView = require("app.scroll.EngrysparWarehouseTableView")
	local view = EngrysparWarehouseTableView.new(cc.size(bg:getContentSize().width - 20, bg:getContentSize().height - 20)):addTo(bg)
	view:setPosition(10, 10)
	-- view:reloadData()
	self.m_energyhouseView = view
	view:refrushTableView()

	self.m_checkBoxs = {}

	local function onCheckedChanged( sender, isChecked )
		for k,v in pairs(self.m_checkBoxs) do
			if v == sender and isChecked then
				v.label:setColor(COLOR[v.color])
			else
				v.label:setColor(COLOR[1])
				if v:isChecked() then
					v:setChecked(false)
				end
			end
		end
		local holeType = nil
		for k,v in pairs(self.m_checkBoxs) do
			if v:isChecked() then
				holeType = v.index
				break
			end
		end
		self.m_holeType = holeType
		view:refrushTableView(self.m_holeType)
	end

	local title = ui.newTTFLabel({text = CommonText[943][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = 120}):addTo(container)
	local checks = {6,3,12}
	for i,v in ipairs(checks) do
		local checkBox = CheckBox.new(nil, nil, onCheckedChanged):addTo(container)

		checkBox:setPosition(74 + (i - 1) * 200, 70)
		checkBox.index = i
		checkBox.color = v
		
		local label = ui.newTTFLabel({text = CommonText[946][i], font = G_FONT, size = FONT_SIZE_SMALL,
			x = checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 25, y = checkBox:getPositionY(),
			color = COLOR[v], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		checkBox.label = label
		checkBox.label:setColor(COLOR[1])
		self.m_checkBoxs[i] = checkBox
	end	
end

function EnergySparView:showInsetView(container)
	local pageCounts = 6--{"1", "2", "3", "4", "5", "6"}
	local pageView = InsetPageView.new(cc.size(600, 430), pageCounts):addTo(container)
	pageView:setPosition(10, container:getContentSize().height - pageView:getContentSize().height)
	pageView:reloadData()

	self.m_energyInlayView = pageView

	-- 达成要求
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(pageView:getPositionX(), pageView:getPositionY() - bg:getContentSize().height/2 - 10)
	local title = ui.newTTFLabel({text = CommonText[944][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local attrValue = {[ATTRIBUTE_INDEX_HP] = {}, [ATTRIBUTE_INDEX_ATTACK] = {}, [ATTRIBUTE_INDEX_HIT] = {}, [ATTRIBUTE_INDEX_DODGE] = {}, [ATTRIBUTE_INDEX_CRIT] = {}, [ATTRIBUTE_INDEX_CRIT_DEF] = {}}

	for k,v in pairs(attrValue) do
		local attrData =  AttributeBO.getAttributeData(k, 0)
		attrValue[attrData.index] = attrData
	end

	local startY = bg:getPositionY() - bg:getContentSize().height

	local attributes = {}
	-- 装备的各个属性
	for index = 1, 6 do
		local seq = {1, 2, 3, 4, 5, 6}
		local config = EquipConfig[seq[index]]
		local attrData = attrValue[config.index]

		local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = attrData.attrName}):addTo(container)
		itemView:setScale(0.36)

		itemView:setPosition(30 + ((index-1) % 3) * 200, startY - math.floor((index-1)/3) * 45)

		local name = ui.newTTFLabel({text = attrData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX() + 30,
			y = itemView:getPositionY(), color= COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)

		name:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL,
			x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), color=COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		value:setAnchorPoint(cc.p(0, 0.5))

		attributes[attrData.index] = {id = attrData.id, name = name, value = value}
	end	

	self.m_attributes = attributes

	startY = startY - 40 * 2
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(pageView:getPositionX(), startY - 20)
	local title = ui.newTTFLabel({text = CommonText[944][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	startY = bg:getPositionY() - bg:getContentSize().height/2 - 5

	local hideAttrs = EnergySparMO.getHideAttributes()

	self.m_hideAttrs = {}

	for i,v in ipairs(hideAttrs) do
		local item = ui.newTTFLabel({text = v.describe, color=COLOR[11], font = G_FONT, size = FONT_SIZE_SMALL}):addTo(container)		
		item:setAnchorPoint(cc.p(0, 0.5))
		item:setPosition(bg:getPositionX() + 35, startY - item:getContentSize().height/2 - (i - 1) * 25)
		item.attr = v

        local bg = display.newSprite("image/common/scroll_bg_2.png"):addTo(item)
        bg:setPosition(-bg:getContentSize().width/2 - 10, bg:getContentSize().height/2 + 5)

        local selected = display.newSprite("image/common/scroll_head_3.png"):addTo(item, 2)
        selected:setPosition(bg:getPositionX(), bg:getPositionY())
        selected:setVisible(false)

        item.selected = selected

		self.m_hideAttrs[i] = item
	end

	local function scrollPage( event )
		self:freshAttributes()
	end

	pageView:addEventListener("PAGE_SCROLL_TO", scrollPage)

	pageView:setCurrentIndex(self.m_chosenPosition)

	UiUtil.button("btn_19_normal.png", "btn_19_selected.png", nil, handler(self, self.oneEquip), CommonText[20151])
		:addTo(container):pos(540,container:height() - 400)
end

function EnergySparView:oneEquip()
	ManagerSound.playNormalButtonSound()
	self.m_energyInlayView:getEmptyData()
end

function EnergySparView:freshAttributes()
	if self.m_energyInlayView then
		local curPage = self.m_energyInlayView:getCurrentIndex()
		local values, levelCounts = EnergySparMO.getAttributeDataByPos(curPage)
		local attributes = self.m_attributes
		for k,v in pairs(attributes) do
			local value = values[k]
			if not value then
				value = AttributeBO.getAttributeData(v.id, 0)
			end
			v.value:setString(string.format("+%s", value.strValue))
			if value.value ~= 0 then
				v.value:setColor(cc.c3b(235, 218, 134))
				v.name:setColor(cc.c3b(235, 218, 134))
			else
				v.value:setColor(COLOR_GRAY)
				v.name:setColor(COLOR_GRAY)				
			end
		end

		for i,v in ipairs(self.m_hideAttrs) do
			local rule = json.decode(v.attr.rule)
			local count = 0
			for lv,cn in pairs(levelCounts) do
				if lv >= rule[2] then
					count = count + cn
				end
			end

			if count >= rule[1] then
				v:setColor(COLOR[2])
				v.selected:setVisible(true)
			else
				v:setColor(COLOR_GRAY)
				v.selected:setVisible(false)
			end
		end
	end
end

return EnergySparView