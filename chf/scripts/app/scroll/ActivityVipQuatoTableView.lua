
-- 

local ActivityVipQuatoTableView = class("ActivityVipQuatoTableView", TableView)

--
function ActivityVipQuatoTableView:ctor(size, activityId)
	ActivityVipQuatoTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_activityId = activityId
	self.m_activityContent = ActivityMO.getActivityContentById(self.m_activityId)

	gprint("ActivityVipQuatoTableView ctor activity id:", activityId)
	gdump(self.m_activityContent, "ActivityVipQuatoTableView ctor")

	local function sortQuota(contentA, contentB)
		if contentA.quotaId < contentB.quotaId then return true
		else return false end
	end
	table.sort(self.m_activityContent.items, sortQuota)

	self.m_cellSize = cc.size(size.width, 190)
end

function ActivityVipQuatoTableView:numberOfCells()
	return #self.m_activityContent.items
end

function ActivityVipQuatoTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityVipQuatoTableView:createCellAtIndex(cell, index)
	ActivityVipQuatoTableView.super.createCellAtIndex(self, cell, index)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

	local item = self.m_activityContent.items[index]
	-- dump(item, "item")

	local awards = PbProtocol.decodeArray(item.award)
	if not awards then return cell end
	local award = awards[1]
	if not award then return cell end
	award.kind = award.type

	local resData = UserMO.getResourceData(award.type, award.id)

	local title = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setAnchorPoint(cc.p(0, 0.5))

	-- 可购买
	local label = ui.newTTFLabel({text = CommonText[460][4], font = G_FONT, size = FONT_SIZE_SMALL, x = 310, y = titleBg:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 已购买次数
	local label = ui.newTTFLabel({text = item.buy, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[5]}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 可购买次数
	local label = ui.newTTFLabel({text = "/" .. item.count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 次数
	local label = ui.newTTFLabel({text = CommonText[282], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
	itemView:setScale(0.9)
	itemView:setPosition(10 + (1 - 0.5) * 105, 90)
	UiUtil.createItemDetailButton(itemView, cell, true)

	local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)

	-- 原价
	local label = ui.newTTFLabel({text = CommonText[460][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = 130, y = 100, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_73.png"):addTo(cell, 5)
	tag:setPosition(label:getPositionX() + label:getContentSize().width + 10, label:getPositionY())

	local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(cell)
	view:setScale(0.9)
	view:setPosition(label:getPositionX() + label:getContentSize().width + view:getBoundingBox().size.width / 2, label:getPositionY() - 2)

	local value = ui.newTTFLabel({text = item.display, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = view:getPositionX() + view:getBoundingBox().size.width / 2, y = view:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 惊爆价
	local label = ui.newTTFLabel({text = CommonText[460][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = 130, y = 60, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(cell)
	view:setScale(0.9)
	view:setPosition(label:getPositionX() + label:getContentSize().width + view:getBoundingBox().size.width / 2, label:getPositionY() - 2)

	local value = ui.newTTFLabel({text = item.price, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = view:getPositionX() + view:getBoundingBox().size.width / 2, y = view:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 立即购买
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBuyCallback))
	btn:setLabel(CommonText[460][3])
	cell:addButton(btn, self.m_cellSize.width - 70, 70)
	btn.item = item

	local label = ui.newTTFLabel({text = "VIP" .. item.vip .. CommonText[460][4], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setPosition(btn:getPositionX(), 110)

	local activity = ActivityMO.getActivityById(self.m_activityId)
	if not activity.open then
		btn:setEnabled(false)
	else
		if item.buy >= item.count then
			btn:setEnabled(false)
			btn:setLabel(CommonText[1836])
		elseif item.vip > UserMO.vip_ then  -- VIP等级不足
			btn:setEnabled(false)
		end
	end
	return cell
end

function ActivityVipQuatoTableView:onBuyCallback(tag, sender)
	if self.m_isBuy then return end

	local function doneCallback(stastAwards)
		Loading.getInstance():unshow()

		UiUtil.showAwards(stastAwards)

		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)

		self.m_isBuy = false
	end

	local item = sender.item

	local coinResData = UserMO.getResourceData(ITEM_KIND_COIN)

	local function gotoBuy()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < item.price then
			Toast.show(coinResData.name .. CommonText[223])
			return
		end

		self.m_isBuy = true 

		Loading.getInstance():show()
		ActivityBO.asynDoVipGift(doneCallback, sender.item)
	end

	if UserMO.consumeConfirm then
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[315], item.price, coinResData.name), function() gotoBuy() end):push()
	else
		gotoBuy()
	end

end

return ActivityVipQuatoTableView
