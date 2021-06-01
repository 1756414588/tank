--
-- Author: Xiaohang
-- Date: 2016-08-10 16:07:16
--
---------------------------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 145)
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
	prop = json.decode(data.reward)

	local propDB = UserMO.getResourceData(prop[1], prop[2])
	local bagView = UiUtil.createItemView(prop[1], prop[2], {count = prop[3]}):addTo(cell)
	bagView:setPosition(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(bagView, cell, true)

	local info = ExerciseBO.shopData[data.goodID]
	local num = data.personNumber - (info and info.buyNum or 0)
	-- 名称
	local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[propDB.quality]}):addTo(cell)
	local desc = ui.newTTFLabel({text = data.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.buy))
	btn.perNum = UiUtil.label("(".. num .."/".. data.personNumber ..")",nil,COLOR[2]):rightTo(name)
	btn:setLabel(CommonText[589])
	btn.cell = cell
	btn.index = index
	btn.propId = data.goodID
	btn.data = data
	btn.prop = prop
	local enough = ExerciseBO.data.exploit >= data.cost
	btn:setEnabled(num ~= 0 and enough)
	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2)
	local t = UiUtil.label(CommonText[20095]):addTo(cell):pos(self.m_cellSize.width-138,26)
	UiUtil.label(data.cost,nil,COLOR[enough and 2 or 6]):rightTo(t)
	if data.treasure == 1 then
		local t = UiUtil.label(CommonText[20097]):addTo(cell):pos(self.m_cellSize.width-158,114)
		local left = info and info.restNum or data.totalNumber
		btn.allNum = UiUtil.label("(".. left .."/".. data.totalNumber ..")",nil,COLOR[2]):rightTo(t)
		btn:setEnabled(left ~= 0 and num ~= 0 and enough)
	end
end

function ContentTableView:numberOfCells()
	return #self.m_props
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:buy(tag, sender)
	ExerciseBO.buyShop(sender.propId,function(count)
			local data = sender.data
			self:getParent().num:setString(CommonText[20093]..ExerciseBO.data.exploit)
			local award = {{kind=sender.prop[1],id=sender.prop[2],count=sender.prop[3]}}
			UserMO.addResource(sender.prop[1],sender.prop[3],sender.prop[2])
			UiUtil.showAwards({awards = award})
			if not ExerciseBO.shopData[data.goodID] then
				ExerciseBO.shopData[data.goodID] = {buyNum = 1, restNum = data.totalNumber}
			else
				ExerciseBO.shopData[data.goodID].buyNum = ExerciseBO.shopData[data.goodID].buyNum + 1
			end
			if self:getParent().index == 2 then
				ExerciseBO.shopData[data.goodID].restNum = count or ExerciseBO.shopData[data.goodID].restNum - 1
			end
			self:updateCell(sender.cell, sender.index)
		end)
end

function ContentTableView:updateUI(data)
	self.m_props = data or {}
	self:reloadData()
end

-----------------------------------总览界面-----------
local ExerciseShop = class("ExerciseShop",UiNode)

function ExerciseShop:ctor()
	ExerciseShop.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function ExerciseShop:onEnter()
	ExerciseShop.super.onEnter(self)
	self:setTitle(CommonText[20092])
	self.index = 1
	self.num = UiUtil.label(CommonText[20093]..ExerciseBO.data.exploit):addTo(self):align(display.LEFT_CENTER,30,display.height-124)
	self.time = UiUtil.label(CommonText[20094]):addTo(self):alignTo(self.num, -26, 1)
	self.time:performWithDelay(handler(self, self.tick), 1, 1)
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.DetailTextDialog").new(DetailText.exerciseShop):push() 
		end):addTo(self):pos(display.width-100,display.height-137)
	
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self)
	line:setPreferredSize(cc.size(display.width-12, line:getContentSize().height))
	line:setPosition(display.cx, display.height-210)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self)
	line:setPreferredSize(cc.size(display.width-12, line:getContentSize().height))
	line:setPosition(display.cx, 70)
	local view = ContentTableView.new(cc.size(display.width-12, display.height - 295))
		:addTo(self):pos(7,70)
	self.view = view
	local function createDelegate(container, index)
		container:removeAllChildren()
		self:showPage(index)
	end
	local function clickDelegate(container, index)
	end
	local pages = {CommonText[559][1],CommonText[586][2]}
	local size = cc.size(display.width - 12, display.height - 250)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = display.cx+20, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
end

function ExerciseShop:tick()
	local t = ManagerTimer.getTime()
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	local s = tonumber(os.date("%S", t))
	h = h >= 22 and 45 - h or 21 - h
	m = 59 - m
	if h == 0 and m == 0 and 59-s == 0 then
		self:updateView()
	end
	self.time:setString(CommonText[20094] .. string.format("%02dh:%02dm:%02ds",h,m,59-s))
end

function ExerciseShop:showPage(index)
	self.index  = index
	self.time:setVisible(self.index == 2)
	self:tick()
	self:updateView()
end

function ExerciseShop:updateView()
	ExerciseBO.getShopInfo(function()
			local list = ExerciseMO.getShop(self.index-1)
			local temp = {}
			if self.index == 1 then
				temp = list
			else
				for k,v in ipairs(list) do
					if ExerciseBO.shopIds[v.goodID] then
						table.insert(temp,v)
					end
				end
			end
			self.view:updateUI(temp)
		end)
end

return ExerciseShop