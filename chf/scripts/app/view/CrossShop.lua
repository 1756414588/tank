--
-- Author: Xiaohang
-- Date: 2016-10-11 14:13:25
--
---------------------------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,contentSize,isRecord)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = contentSize
	self.isRecord = isRecord
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	if not self.isRecord then
		self:updateCell(cell, index)
	else
		local data = self.m_props[index]
		local t = UiUtil.label(os.date("%m-%d", data.time)):addTo(cell):pos(85,self.m_cellSize.height/2+12)
		t = UiUtil.label(os.date("%H:%M", data.time)):addTo(cell):pos(85,self.m_cellSize.height/2-12)
		t = UiUtil.label(data.content, nil, COLOR[2], cc.size(360,0),ui.TEXT_ALIGN_LEFT)
			:addTo(cell):align(display.LEFT_TOP,180,self.m_cellSize.height/2+20)
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
		line:setPreferredSize(cc.size(self.m_cellSize.width-30, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, 0)
	end
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
	prop = prop[1]
	local propDB = UserMO.getResourceData(prop[1], prop[2])
	local bagView = UiUtil.createItemView(prop[1], prop[2], {count = prop[3]}):addTo(cell)
	bagView:setPosition(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(bagView, cell, true)

	local info = nil
	if self.kind == ACTIVITY_CROSS_WORLD then
		info = CrossBO.shopLeft_[data.goodid]
	elseif self.kind == ACTIVITY_CROSS_PARTY then
		info = CrossPartyBO.shopLeft_[data.goodid]
	end
	local num = data.personnumber - (info and info[1] or 0)
	-- 名称
	local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[propDB.quality]}):addTo(cell)
	local desc = ui.newTTFLabel({text = data.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.buy))
	btn.perNum = UiUtil.label("(".. num .."/".. data.personnumber ..")",nil,COLOR[2]):rightTo(name)
	btn:setLabel(CommonText[589])
	btn.cell = cell
	btn.index = index
	btn.propId = data.goodid
	btn.data = data
	btn.prop = prop
	btn.num = num
	local own = 0
	if self.kind == ACTIVITY_CROSS_WORLD then
		own = CrossBO.score_
	elseif self.kind == ACTIVITY_CROSS_PARTY then
		own = CrossPartyBO.score_
	end
	local enough = own >= data.cost
	cell.btn = btn
	btn:setEnabled(num ~= 0 and enough)
	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2)
	local t = UiUtil.label(CommonText[770][3]..":"):addTo(cell):pos(self.m_cellSize.width-138,26)
	cell.cost = UiUtil.label(data.cost,nil,COLOR[enough and 2 or 6]):rightTo(t)
end

function ContentTableView:numberOfCells()
	return #self.m_props
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateBtn()
	local own = 0
	if self.kind == ACTIVITY_CROSS_WORLD then
		own = CrossBO.score_
	elseif self.kind == ACTIVITY_CROSS_PARTY then
		own = CrossPartyBO.score_
	end
	for index = 1, #self.m_props do
		local cell = self:cellAtIndex(index)
		if cell then
			local enough = own >= cell.btn.data.cost
			cell.btn:setEnabled(cell.btn.num ~= 0 and enough)
			cell.cost:setColor(COLOR[enough and 2 or 6])
		end
	end
end

function ContentTableView:buy(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.kind == ACTIVITY_CROSS_WORLD then 
		CrossBO.exchanCrossShop(sender.propId,function()
				local data = sender.data
				self:getParent().num:setString(CommonText[764][1]..CrossBO.score_)
				local award = {{kind=sender.prop[1],id=sender.prop[2],count=sender.prop[3]}}
				UserMO.addResource(sender.prop[1],sender.prop[3],sender.prop[2])
				UiUtil.showAwards({awards = award})
				self:updateCell(sender.cell, sender.index)
				self:updateBtn()
			end)
	elseif self.kind == ACTIVITY_CROSS_PARTY then
		CrossPartyBO.exchanCrossShop(sender.propId,function()
				local data = sender.data
				self:getParent().num:setString(CommonText[764][1]..CrossPartyBO.score_)
				local award = {{kind=sender.prop[1],id=sender.prop[2],count=sender.prop[3]}}
				UserMO.addResource(sender.prop[1],sender.prop[3],sender.prop[2])
				UiUtil.showAwards({awards = award})
				self:updateCell(sender.cell, sender.index)
				self:updateBtn()
			end)
	end
end

function ContentTableView:updateUI(data,kind)
	self.m_props = data or {}
	self.kind = kind
	self:reloadData()
end

-----------------------------------总览界面-----------
local CrossShop = class("CrossShop",UiNode)

function CrossShop:ctor(kind)
	CrossShop.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	self.kind = kind or ACTIVITY_CROSS_WORLD
end

function CrossShop:onEnter()
	CrossShop.super.onEnter(self)
	self:setTitle(CommonText[30026])
	self.shopTime = nil
	self.num = UiUtil.label(CommonText[764][1].."0"):addTo(self):align(display.LEFT_CENTER,30,display.height-175)
	self.labs = CommonText[30025]
	if self.kind == ACTIVITY_CROSS_WORLD then
		self.shopTime = CrossMO.inShopTime()
	elseif self.kind == ACTIVITY_CROSS_PARTY then
		self.shopTime = CrossPartyMO.inShopTime()
		self.labs = {"",CommonText[30025][3]}
	end
	self.tickNum = UiUtil.label(""):alignTo(self.num,190)
	self.tickNum:performWithDelay(handler(self, self.tick), 1, 1)
	self:tick()
	self.tip = UiUtil.label(""):addTo(self):alignTo(self.num, -26, 1)

	local function createDelegate(container, index)
		container:removeAllChildren()
		self:showPage(index)
	end
	local function clickDelegate(container, index)
	end
	local pages = {CommonText[559][1],CommonText[586][2],CommonText[30029]}
	if ACTIVITY_CROSS_PARTY == self.kind then
		pages = {CommonText[586][1],CommonText[30029]}
	end
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.text.DetailText")
			local text = DetailText.crossShop
			if self.kind == ACTIVITY_CROSS_PARTY then
				text = DetailText.crossPartyShop
			end
			if self.index == #pages then
				text = DetailText.crossScore
				if self.kind == ACTIVITY_CROSS_PARTY then
					text = DetailText.crossPartyScore
				end
			end
			require("app.dialog.DetailTextDialog").new(text):push() 
		end):addTo(self):pos(display.width-50,display.height-185)
	self.pages = pages
	local size = cc.size(display.width - 12, display.height - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = display.cx+20, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self,2)
	line:setPreferredSize(cc.size(display.width-12, line:getContentSize().height))
	line:setPosition(display.cx, display.height-210)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self,2)
	line:setPreferredSize(cc.size(display.width-12, line:getContentSize().height))
	line:setPosition(display.cx, 70)

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, display.width-60, display.height - 300)
	bg:addTo(self):pos(display.cx,bg:height()/2+70)
	local t = UiUtil.label(CommonText[619][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
	t = UiUtil.label(CommonText[619][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 120)
	bg:hide()
	self.bg = bg

	pageView:setPageIndex(1)
end

function CrossShop:tick()
	local t = ManagerTimer.getTime()
	local left = 0
	local label = ""
	if t <= self.shopTime[1] then
		left = self.shopTime[1] - t
		label = CommonText[30050][1]
	else
		left = self.shopTime[2] - t
		label = CommonText[30050][2]
	end
	if left < 0 then left = 0 end
	local data = ManagerTimer.time(left)
	self.tickNum:setString(string.format(label.."%02dd:%02dh:%02dm:%02ds",data.day,data.hour,data.minute,data.second))
end

function CrossShop:showPage(index)
	self.index  = index
	self.tip:setString(self.labs[index] or "")
	self:updateView()
end

function CrossShop:updateView()
	if self.view then self.view:removeSelf() self.view = nil end
	if self.index ~= #self.pages then
		self.bg:hide()
		self.view = ContentTableView.new(cc.size(display.width-12, display.height - 280),cc.size(display.width-12,145),false)
				:addTo(self):pos(7,58)
		if self.kind == ACTIVITY_CROSS_WORLD then
			CrossBO.GetCrossShop(function()
					self.num:setString(CommonText[764][1]..CrossBO.score_)
					self.view:updateUI(CrossMO.getShop(self.kind,self.index),self.kind)
				end)
		elseif self.kind == ACTIVITY_CROSS_PARTY then
			CrossPartyBO.GetCrossShop(function()
					self.num:setString(CommonText[764][1]..CrossPartyBO.score_)
					self.view:updateUI(CrossMO.getShop(self.kind,self.index),self.kind)
				end)
		end
	else
		self.bg:show()
		self.view = ContentTableView.new(cc.size(self.bg:width(), self.bg:height()-55),cc.size(self.bg:width(),70),true)
				:addTo(self.bg):pos(0,10)
		local rhand = CrossBO.scoreInfo
		if self.kind == ACTIVITY_CROSS_PARTY then
			rhand = CrossPartyBO.scoreInfo
		end
		rhand(function(list)
				local temp = {}
				table.sort(list,function(a,b)
						return a.trendTime > b.trendTime
					end)
				for k,v in ipairs(list) do
					local str = CrossMO.getIntegralById(v.trendId).content
					local index = 1
					local b,e = string.find(str,"|%%s|")
					while e do
						str = string.gsub(str, "|%%s|", v.trendParam[index],1)
						index = index + 1
						b,e = string.find(str,"|%%s|")
					end
					table.insert(temp, {time = v.trendTime,content = str})
					self.view:updateUI(temp)
				end
			end)
	end
end

return CrossShop