--
-- Author: Gss
-- Date: 2018-03-22 17:17:27
--
--红色方案商店tableview

local RedplanShopTableView = class("RedplanShopTableView", TableView)

function RedplanShopTableView:ctor(size)
	RedplanShopTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	self.m_goods = ActivityCenterMO.getAllRedPlanGoods()
	self.m_data = ActivityCenterMO.redPlanMapInfo_
end

function RedplanShopTableView:onEnter()
	RedplanShopTableView.super.onEnter(self)
	self:reloadData()
end

function RedplanShopTableView:numberOfCells()
	return #self.m_goods
end

function RedplanShopTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RedplanShopTableView:createCellAtIndex(cell, index)
	RedplanShopTableView.super.createCellAtIndex(self, cell, index)
	local good = self.m_goods[index]
	local data = self.m_data

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local item = json.decode(good.reward)

	local view = UiUtil.createItemView(item[1], item[2], {count = item[3]}):addTo(cell):pos(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(view, cell, true)
	local pb = UserMO.getResourceData(item[1], item[2])
	-- 名称
	local name = ui.newTTFLabel({text = pb.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[pb.quality]}):addTo(cell)
	local descStr = pb.desc or ""
	local desc = ui.newTTFLabel({text = descStr, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))
	--兑换限制
	local count = ui.newTTFLabel({text = "(" .. data.shopInfo[index] .. "/" .. good.personNumber .. ")", font = G_FONT, size = FONT_SIZE_SMALL,
	 color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell):rightTo(name)
	count:setAnchorPoint(cc.p(0, 0.5))
	if data.shopInfo[index] < good.personNumber then
		count:setColor(COLOR[1])
	else
		count:setColor(COLOR[6])
	end

	--价格
	local dollar = display.newSprite(IMAGE_COMMON.."redplan/dollar.png"):addTo(bg)
	dollar:setScale(0.6)
	dollar:setPosition(bg:width() - 130, bg:height() - dollar:height() / 2 - 5)

	local costNum = json.decode(good.cost)[3]
	local cost = UiUtil.label(costNum):addTo(bg):rightTo(dollar)

	local own = UserMO.getResource(ITEM_KIND_PROP,640)--物资
	-- 兑换按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBtnCallback))
	btn:setLabel(CommonText[589])
	btn.goodsId = good.goodId
	btn.itemView = view
	local newData = {}
	newData.award = good.reward
	newData.id = good.goodId
	newData.max = good.personNumber - data.shopInfo[index]
	newData.price = costNum
	btn.newData = newData

	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
	btn:setEnabled(data.shopInfo[index] < good.personNumber and own > costNum)

	return cell
end

function RedplanShopTableView:onBtnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local itemView = sender.itemView
	local worldPoint = itemView:getParent():convertToWorldSpace(cc.p(itemView:getPositionX(), itemView:getPositionY()))
	local data = clone(sender.newData)
	data.resolveId = data.id
	data.isMedal = true

	local RedPlanExchangeDialog = require("app.dialog.RedPlanExchangeDialog")--批量购买
	RedPlanExchangeDialog.new(data, function (param)
		self.m_data.shopInfo = param.shopInfo
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)

		local view = UiDirector.getUiByName("RedplanShopView")
		if view then
			view:reSetUI()
		end
	end, worldPoint):push()

	-- local goodsId = sender.goodsId
	-- ActivityCenterBO.exchangeRedPlan(function (data)
	-- 	self.m_data.shopInfo = data.shopInfo
	-- 	local offset = self:getContentOffset()
	-- 	self:reloadData()
	-- 	self:setContentOffset(offset)

	-- 	local view = UiDirector.getUiByName("RedplanShopView")
	-- 	if view then
	-- 		view:reSetUI()
	-- 	end
	-- end,goodsId)
end


-----------------------------------------------------------------------------------------
--红色方案商店
-----------------------------------------------------------------------------------------



local RedplanShopView = class("RedplanShopView", UiNode) 

function RedplanShopView:ctor()
	RedplanShopView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function RedplanShopView:onEnter()
	RedplanShopView.super.onEnter(self)
	self.itemNum = nil
	local data = ActivityCenterMO.redPlanMapInfo_
	self.m_data = data

	self:setTitle(CommonText[5029][2])

	--我的物资
	local myToken = ui.newTTFLabel({text = CommonText[5030], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	myToken:setPosition(myToken:width(), self:getBg():height() - 130)

	if data then
		local itemNum = UiUtil.label(data.itemCount,nil,COLOR[2]):addTo(self:getBg()):rightTo(myToken)
		self.itemNum = itemNum
	end
	
	--一键补充
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local addButton = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
	addButton:setPosition(self:getBg():width() - addButton:width()* 0.6, myToken:y())
	addButton:setLabel(CommonText[1502])

	local view = RedplanShopTableView.new(cc.size(self:getBg():width(), self:getBg():height() - 180)):addTo(self:getBg())
	view:setPosition(0,20)
	self.view = view
	self:reSetUI()
end

function RedplanShopView:reSetUI()
	local num = UserMO.getResource(ITEM_KIND_PROP,640)--物资
	self.itemNum:setString(num)
end

function RedplanShopView:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local propIds = {641,642,643,644} -- 物资箱（小，中，大，巨）
	local index = propIds[1]

	--判断是否有物资箱（小，中，大，巨）
	local canotUse = false
	for num=1,#propIds do
		local pNum = UserMO.getResource(ITEM_KIND_PROP,propIds[num])
		if pNum > 0 then
			canotUse = true
			break
		end
	end

	--没有箱子可以使用
	if not canotUse then Toast.show(CommonText[1503]) return end 

	--使用物资箱（小，中，大，巨）
	local function doUse(awards)
		Loading.getInstance():unshow()
		if awards then
			UiUtil.showAwards(awards)
			self:reSetUI()
			if self.view then
				ActivityCenterBO.getRedPlanInfo(function ()
					local offset = self.view:getContentOffset()
					self.view:reloadData()
					self.view:setContentOffset(offset)
				end)
			end
		end
		local propNum = UserMO.getResource(ITEM_KIND_PROP,index)
		if propNum > 0 and index <= propIds[#propIds] then
			Loading.getInstance():show()
			PropBO.asynUseProp(doUse, index, propNum)
			
			index = index + 1
		else
			index = index + 1
			if index <= propIds[#propIds] then
				doUse()
			end
		end
	end

	doUse()
end

return RedplanShopView