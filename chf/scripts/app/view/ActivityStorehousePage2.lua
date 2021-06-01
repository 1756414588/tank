--
-- Author: xiaoxing
-- Date: 2016-12-06 09:41:03
--
--
-- Author: Xiaohang
-- Date: 2016-08-10 16:07:16
--
---------------------------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,data)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 145)
	self.m_data = data
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	self:updateCell(cell, index)
	return cell
end

function ContentTableView:updateCell(cell,index)
	cell:removeAllChildren()
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	local data = self.m_props[index]
	prop = json.decode(data.award)[1]
	local propDB = UserMO.getResourceData(prop[1], prop[2])
	local bagView = UiUtil.createItemView(prop[1], prop[2], {count = prop[3]}):addTo(cell)
	bagView:setPosition(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(bagView, cell, true)

	local left = self.leftInfo[data.id] or data.itemNum
	-- 名称
	local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[propDB.quality]}):addTo(cell)
	if data.itemNum ~= -1 then
		UiUtil.label("("..left .."/"..data.itemNum ..")",nil,COLOR[left == 0 and 6 or 2]):rightTo(name)
	end
	local desc = ui.newTTFLabel({text = data.itemDec, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.buy))
	btn:setLabel(CommonText[589])
	btn.cell = cell
	btn.index = index
	btn.data = data
	btn.prop = prop
	btn.left = left
	btn.bagView = bagView

	local need = json.decode(data.more)[1]
	btn.cost = need[3]
	local t = display.newSprite("image/item/chat_small"..need[2] ..".png"):addTo(cell):pos(self.m_cellSize.width - 135,self.m_cellSize.height / 2 - 45):scale(0.7)
	local own = tonumber(self:getParent().num:getString())
	local enough = own >= need[3]
	cell.cost = UiUtil.label(need[3],nil,COLOR[enough and 2 or 6]):rightTo(t)
	btn:setEnabled(enough and left ~=0)
	cell.btn = btn
	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2)
end

function ContentTableView:numberOfCells()
	return #self.m_props
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:buy(tag, sender)
	local itemView = sender.bagView
	local worldPoint = itemView:getParent():convertToWorldSpace(cc.p(itemView:getPositionX(), itemView:getPositionY()))
	local data = clone(sender.data)
	local activityId = self.m_data.activityId
	data.resolveId = data.id
	data.isMedal = true
	if data.itemNum ~= -1 then
		data.max = sender.left
	end

	local function gotoExc(param)
		local  item
		if table.isexist(param, "actProp") then
			item = PbProtocol.decodeRecord(param.actProp)
			ActivityCenterBO.prop_[item.id] = item
		end

		self:getParent().num:setString(item.count)
		if self.leftInfo[data.id] then
			self.leftInfo[data.id] = self.leftInfo[data.id] - param.reduce
		end
		self:updateCell(sender.cell, sender.index)
		for index = 1, #self.m_props do
			local cell = self:cellAtIndex(index)
			if cell then
				local enough = item.count >= cell.btn.cost
				cell.btn:setEnabled(cell.btn.left ~= 0 and enough)
				cell.cost:setColor(COLOR[enough and 2 or 6])
			end
		end
	end

	local ActPropExcDialog = require("app.dialog.ActPropExcDialog")--批量购买
	ActPropExcDialog.new(data, function (param)
		gotoExc(param)
	end, worldPoint, activityId):push()


	-- ActivityCenterBO.doPirateChange(data.id,function(info)
	-- 		self:getParent().num:setString(info.count)
	-- 		if self.leftInfo[data.id] then
	-- 			self.leftInfo[data.id] = self.leftInfo[data.id] - 1
	-- 		end
	-- 		self:updateCell(sender.cell, sender.index)
	-- 		for index = 1, #self.m_props do
	-- 			local cell = self:cellAtIndex(index)
	-- 			if cell then
	-- 				local enough = info.count >= cell.btn.cost
	-- 				cell.btn:setEnabled(cell.btn.left ~= 0 and enough)
	-- 				cell.cost:setColor(COLOR[enough and 2 or 6])
	-- 			end
	-- 		end
	-- 	end)
end

function ContentTableView:updateUI(data,leftInfo)
	self.m_props = data or {}
	self.leftInfo = leftInfo
	self:reloadData()
end

-----------------------------------总览界面-----------
local ActivityStorehoursePage2 = class("ActivityStorehoursePage1",function ()
	return display.newNode()
end)

function ActivityStorehoursePage2:ctor(width,height,activity)
	self.activity = activity
	self:size(width,height)
	local pb = PropMO.queryActPropById(7)
	local t = UiUtil.label(CommonText[20177]..pb.name ..":"):addTo(self):align(display.LEFT_CENTER,50,display.height-212)
	t = display.newSprite("image/item/chat_small7.png"):rightTo(t)
	self.num = UiUtil.label(0,nil,COLOR[2]):rightTo(t)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self)
	line:setPreferredSize(cc.size(display.width-12, line:getContentSize().height))
	line:setPosition(display.cx, display.height-235)

	local view = ContentTableView.new(cc.size(display.width-12, display.height - 245),self.activity)
		:addTo(self):pos(7,0)
	self.view = view

	ActivityCenterBO.getPirateChange(function(info,data,awardId)
			local list = ActivityCenterMO.getStorehouseShop(awardId)
			self.num:setString(info and info.count or 0)
			self.view:updateUI(list,data)
		end)
end

return ActivityStorehoursePage2