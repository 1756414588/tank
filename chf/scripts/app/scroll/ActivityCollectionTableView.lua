--
-- Author: Your Name
-- Date: 2016-10-24 10:53:39
--
------------------------------------------------------------------------
	--集字活动TableView
------------------------------------------------------------------------

local ActivityCollectionTableView = class("ActivityCollectionTableView",TableView)

function ActivityCollectionTableView:ctor(size,activityId,rhand)
	ActivityCollectionTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_activityId = activityId
	self.rhand = rhand
	-- self.m_exchangeData = ActivityCenterMO.activityContents_[self.m_activityId]
	-- dump(self.m_exchangeData,"self.m_exchangeData==============================self.m_exchangeData")
end

function ActivityCollectionTableView:onEnter()
	ActivityCollectionTableView.super.onEnter(self)
	-- self.m_nums = "读表数据：获得的可兑换物品的种类数"
	self.m_updateHandler = Notify.register(LOCAL_PARTYSHOP_UPDATE_EVENT, handler(self, self.updateHandler))
	self.m_nums = 5
end

function ActivityCollectionTableView:numberOfCells()
	return self.m_nums
end

function ActivityCollectionTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityCollectionTableView:createCellAtIndex(cell, index)
	ActivityCollectionTableView.super.createCellAtIndex(self, cell, index)
	self:updateCell(cell, index)
	return cell
end

function ActivityCollectionTableView:updateCell(cell, index)
	ActivityCollectionTableView.super.createCellAtIndex(self, cell,index)
	-- local exchangeData = self.m_exchangeData[index]
	-- local prop = PartyMO.queryPartyProp(index)
	local prop = ActivityCenterMO.getExchangeById(index)
	local awardId = json.decode(prop.awardId)[1]
	local propDB = UserMO.getResourceData(awardId[1],awardId[2])

	--背景框
	local viewBg = display.newScale9Sprite(IMAGE_COMMON.."info_bg_25.png"):addTo(cell)
	viewBg:setPreferredSize(cc.size(607, 140))
	viewBg:setCapInsets(cc.rect(220, 60, 1, 1))
	viewBg:setPosition(self.m_cellSize.width / 2,self.m_cellSize.height / 2)
	--prop
	local itemView = UiUtil.createItemView(awardId[1],awardId[2],{count = awardId[3]}):addTo(cell)
	itemView:setPosition(80,viewBg:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView,cell,true)

	--propName and num
	local name = ui.newTTFLabel({text = propDB.name .. " * " .. awardId[3],font = G_FONT,size = FONT_SIZE_SMALL,x = 160,y = 115,
		color = COLOR[propDB.quality or 1],align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0,0.5))
	if prop.itemNum ~= -1 then
		local left = ActivityCenterBO.propLeft_[prop.id] or prop.itemNum
		UiUtil.label("("..left .."/"..prop.itemNum ..")",nil,COLOR[2]):rightTo(name)
	end
	--道具描述
	local desc = ui.newTTFLabel({text = propDB.desc,font = G_FONT,size = FONT_SIZE_SMALL,x = 160,y = self.m_cellSize.height / 2 - 15,
		color = COLOR[1],align = ui.TEXT_ALIGN_LEFT,dimensions = cc.size(260,80)}):addTo(cell)

	local need = json.decode(prop.more)[1]
	--兑换按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local changeBtn = CellMenuButton.new(normal, selected, disabled, handler(self,self.onChangeCallback))
	changeBtn:setLabel(CommonText[589])
	changeBtn.id = prop.id
	changeBtn.cell = cell
	changeBtn.index = index
	cell:addButton(changeBtn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 30)
	--字牌item
	local t = display.newSprite("image/item/chat_small"..need[2] ..".png"):addTo(cell):pos(self.m_cellSize.width - 120,self.m_cellSize.height / 2+10):scale(0.7)
	local own = ActivityCenterBO.prop_[need[2]] and ActivityCenterBO.prop_[need[2]].count or 0
	UiUtil.label(need[3],nil,COLOR[own >= need[3] and 2 or 6]):rightTo(t,5)
end

function ActivityCollectionTableView:onChangeCallback(tag,sender)
	ActivityCenterBO.CollectExchange(sender.id,function()
		self:updateCell(sender.cell, sender.index)
		self.rhand()
	end)
end

function ActivityCollectionTableView:updateHandler()
	self.m_exchangeData = ActivityCenterMO.exchangeData_
	self:reloadData()
end


return ActivityCollectionTableView