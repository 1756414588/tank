--
-- Author: gf
-- Date: 2015-12-18 18:06:31
-- 军团战事福利


local PartyBWealTableView = class("PartyBWealTableView", TableView)


function PartyBWealTableView:ctor(size)
	PartyBWealTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)


end

function PartyBWealTableView:onEnter()
	PartyBWealTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_AWARD_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyBWealTableView:numberOfCells()
	return #PartyBattleMO.battleAwards
end

function PartyBWealTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyBWealTableView:createCellAtIndex(cell, index)
	PartyBWealTableView.super.createCellAtIndex(self, cell, index)

	local data = PartyBattleMO.battleAwards[index]
	local resData = UserMO.getResourceData(ITEM_KIND_PROP, data.propId)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self:getViewSize().width - 20, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, data.propId, {count = data.count})
	itemView:setPosition(100,self.m_cellSize.height / 2)
	cell:addChild(itemView)

	--名称
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = self.m_cellSize.height - 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	--描述
	local desc = ui.newTTFLabel({text = resData.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))


	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 25, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = data.count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5)) 

	-- 分配按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onAllotCallback))
	btn.data = data
	btn:setLabel(CommonText[818])
	btn:setEnabled(PartyMO.myJob > PARTY_JOB_OFFICAIL)
	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)

	return cell
end

function PartyBWealTableView:onAllotCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local PartyBAwardAllotDialog = require("app.dialog.PartyBAwardAllotDialog")
	local dialog = PartyBAwardAllotDialog.new(sender.data)
	dialog:push()
	
end

function PartyBWealTableView:updateListHandler(event)
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function PartyBWealTableView:onExit()
	PartyBWealTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

-- function PartyBWealTableView:cellTouched(cell, index)
-- 	print("PartyBWealTableView index:", index)
-- end

return PartyBWealTableView
