
------------------------------------------------------------------------------
-- 神秘商店TableView
------------------------------------------------------------------------------
local ShopTableView = class("ShopTableView", TableView)

function ShopTableView:ctor(size)
	ShopTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

function ShopTableView:numberOfCells()
	return #self.m_propIds
end

function ShopTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ShopTableView:createCellAtIndex(cell, index)
	ShopTableView.super.createCellAtIndex(self, cell, index)
	self:updateCell(cell, index)
	return cell
end

function ShopTableView:updateCell(cell, index)
	cell:removeAllChildren()
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 80, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local data = self.m_propIds[index]
	local prop = json.decode(data.reward)
	local left = data.personNumber - (self.data[data.goodId] and self.data[data.goodId] or 0)
	-- local t = UiUtil.label(CommonText[883][2]):addTo(cell)
	-- 	:align(display.LEFT_CENTER,320,114)
	UiUtil.label("("..left .."/".. data.personNumber..")",nil,COLOR[2]):addTo(cell):align(display.LEFT_CENTER,350,114)

	local propType = prop[1]
	local propId = prop[2]
	local propCount = prop[3]

	local bagView = UiUtil.createItemView(propType, propId, {count = propCount}):addTo(cell)
	bagView:setPosition(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(bagView, cell, true)

	-- 名称
	local name = ui.newTTFLabel({text = data.goodName, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, }):addTo(cell)
	local desc = ui.newTTFLabel({text = data.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	local view = UiUtil.createItemSprite(ITEM_KIND_HUNTER_COIN):addTo(cell)
	view:setPosition(self.m_cellSize.width - 140, 114)

	local price = ui.newBMFontLabel({text = data.cost, font = "fnt/num_2.fnt", x = view:getPositionX() + view:getContentSize().width / 2, y = view:getPositionY()}):addTo(cell)
	price:setAnchorPoint(cc.p(0, 0.5))

	-- 兑换
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBtnCallback))

	btn.data = data
	btn.cell = cell
	btn.index = index

	btn:setLabel(CommonText[294])
	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)

	local count = UserMO.getResource(ITEM_KIND_HUNTER_COIN)
	if count < data.cost or left == 0 then
		btn:setEnabled(false)
	end
end

function ShopTableView:onBtnCallback(tag, sender)
	local data = sender.data
	-- CombatBO.BuyTreasureShop(data.treasureId,function()
	-- 		if not self.data[data.treasureId] then
	-- 			self.data[data.treasureId] = 1
	-- 		else
	-- 			self.data[data.treasureId] = self.data[data.treasureId] + 1
	-- 		end
	-- 		-- 是荒宝兑换，需要扣除荒宝
	-- 		UserMO.reduceResource(ITEM_KIND_HUANGBAO, data.cost)
	-- 		local prop = json.decode(data.reward)
	-- 		local award = {{kind=prop[1],id=prop[2],count=prop[3]}}
	-- 		UserMO.addResource(prop[1],prop[3],prop[2])
	-- 		UiUtil.showAwards({awards = award})
	-- 		-- Notify.notify(LOCAL_COMBAT_BOX_EVENT)  -- 领取了宝箱
	-- 		self:updateCell(sender.cell,sender.index)
	-- 		self:reloadData()
	-- 		self:getParent().m_countLabel:setString(UserMO.getResource(ITEM_KIND_HUANGBAO))
	-- 	end)

	print("teamInstanceExchange goodId==", data.goodId)
	HunterBO.teamInstanceExchange(data.goodId, function (coinCount, awards, buyInfo)
		-- body
		self.data[buyInfo.gid] = self.data[buyInfo.gid] + buyInfo.buyCount
		UserMO.hunterCoin_ = coinCount
		local awardsShow = {awards={}}
		for i, v in ipairs(awards) do
			local award = {kind=v.type,id=v.id,count=v.count}
			UserMO.addResource(v.type, v.count, v.id)
			table.insert(awardsShow.awards, award)
		end
		UiUtil.showAwards(awardsShow)
		self:updateCell(sender.cell, sender.index)
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
		self:getParent().m_countLabel:setString(UserMO.hunterCoin_)
	end)
end

------------------------------------------------------------------------------
-- 神秘商店
------------------------------------------------------------------------------

local ShopHunterView = class("ShopHunterView", UiNode)

function ShopHunterView:ctor(uiEnter)
	ShopHunterView.super.ctor(self, "image/common/bg_ui.jpg")
end

function ShopHunterView:onEnter()
	ShopHunterView.super.onEnter(self)

	self:setTitle(CommonText[415][1])

	local resData = UserMO.getResourceData(ITEM_KIND_HUNTER_COIN)
	local count = UserMO.getResource(ITEM_KIND_HUNTER_COIN)

	local label = ui.newTTFLabel({text = resData.name .. CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self:getBg():getContentSize().height - 140, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local t = UiUtil.label(CommonText[20094]):rightTo(label,180)
	self.left = UiUtil.label("00d:00h:00m:00s"):rightTo(t)

	local label = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))
	self:getBg().m_countLabel = label

	local view = ShopTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height - 187 - 45)):addTo(self:getBg())
	view:setPosition(0, 45)
	self.m_tableView = view
	local function tick()
		local t = ManagerTimer.getTime()
		local h = tonumber(os.date("%H", t))
		local m = tonumber(os.date("%M", t))
		local s = tonumber(os.date("%S", t))
		local temp = UserMO.openServerDay%7
		local day =  7 - (temp == 0 and 7 or temp)
		self.left:setString(string.format("%02dd:%02dh:%02dm:%02ds",day,23-h,59-m,59-s))
		if day == 0 and 23 - h == 0 and 59 - m ==0 and 59 - s == 0 then
			UserMO.openServerDay = UserMO.openServerDay + 1
			self:updateView()
		end
	end
	self.left:performWithDelay(tick, 1, 1)
	tick()
	self:updateView()
end

function ShopHunterView:updateView()
	HunterBO.getBountyShopBuy(function(week,list)
			self.m_tableView.m_propIds = HunterMO.queryShopByWeek(week)
			self.m_tableView.data = {}

			for k,v in ipairs(list) do
				self.m_tableView.data[v.gid] = v.buyCount
			end

			self:getBg().m_countLabel:setString(UserMO.hunterCoin_)
			self.m_tableView:reloadData()
		end)
end

return ShopHunterView 
