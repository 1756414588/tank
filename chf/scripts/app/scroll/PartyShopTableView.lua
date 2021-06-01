--
-- Author: gf
-- Date: 2015-09-14 13:50:39
--


local PartyShopTableView = class("PartyShopTableView", TableView)

function PartyShopTableView:ctor(size,type)
	PartyShopTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 155)
	self.type = type
	if self.type  == PARTY_SHOP_TYPE_NORMAL then
		self.shopData = PartyMO.shopData_nomal_
	else
		self.shopData = PartyMO.shopData_treasure_
	end
end

function PartyShopTableView:onEnter()
	PartyShopTableView.super.onEnter(self)

	self.m_updateHandler = Notify.register(LOCAL_PARTYSHOP_UPDATE_EVENT, handler(self, self.updateHandler))
end

function PartyShopTableView:numberOfCells()
	return #self.shopData
end

function PartyShopTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyShopTableView:createCellAtIndex(cell, index)
	PartyShopTableView.super.createCellAtIndex(self, cell, index)

	local shopData = self.shopData[index]
	local shopProp = PartyMO.queryPartyProp(shopData.keyId)
	local propDB = UserMO.getResourceData(shopProp.itemType, shopProp.itemId)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 150))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(shopProp.itemType, shopProp.itemId, {count = shopProp.itemNum}):addTo(bg)
	itemView:setPosition(90,bg:getContentSize().height / 2)

	local name = ui.newTTFLabel({text = propDB.name .. " * " .. shopProp.itemNum, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 125, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = "(" .. shopData.count .. "/" .. shopProp.count .. ")", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = name:getPositionX() + name:getContentSize().width + 10, y = name:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))
	if shopData.count < shopProp.count then
		count:setColor(COLOR[1])
	else
		count:setColor(COLOR[6])
	end  

	local desc = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 300, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	if PartyMO.partyData_.partyLv >= shopProp.partyLv then
		desc:setString(propDB.desc)
		desc:setColor(COLOR[1])
	else
		desc:setString(string.format(CommonText[592],shopProp.partyLv))
		desc:setColor(COLOR[6])
	end

	local donateTit = ui.newTTFLabel({text = CommonText[588], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 450, y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	donateTit:setAnchorPoint(cc.p(0, 0.5))

	local donateValue = ui.newTTFLabel({text = shopProp.contribute, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = donateTit:getPositionX() + donateTit:getContentSize().width, y = donateTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	donateValue:setAnchorPoint(cc.p(0, 0.5))
	if PartyMO.myDonate_ >= shopProp.contribute then
		donateValue:setColor(COLOR[1])
	else
		donateValue:setColor(COLOR[6])
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local buyBtn = CellMenuButton.new(normal, selected, disabled, handler(self,self.buyProp))
	buyBtn:setLabel(CommonText[589])
	buyBtn:setEnabled(PartyMO.myDonate_ >= shopProp.contribute and shopData.count < shopProp.count)
	buyBtn:setVisible(PartyMO.partyData_.partyLv >= shopProp.partyLv)
	buyBtn.shopData = shopData
	buyBtn.need = shopProp.contribute
	cell:addButton(buyBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 10)


	return cell
end

function PartyShopTableView:buyProp(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynBuyPartyShop(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[590])
		end,sender.shopData,sender.need)

end


function PartyShopTableView:updateHandler()
	if self.type == PARTY_SHOP_TYPE_NORMAL then
		self.shopData = PartyMO.shopData_nomal_
	else
		self.shopData = PartyMO.shopData_treasure_
	end
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end



function PartyShopTableView:onExit()
	PartyShopTableView.super.onExit(self)
	
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end



return PartyShopTableView