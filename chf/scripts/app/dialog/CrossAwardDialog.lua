--
-- Author: Xiaohang
-- Date: 2016-09-06 17:00:28
--
-- 奖励预览
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,kind)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.kind = kind
	self.m_cellSize = cc.size(size.width, 200)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)

	-- local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	-- titBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - titBg:getContentSize().height / 2)

	-- local titLab = ui.newTTFLabel({text = string.format(CommonText[257],index), font = G_FONT, size = FONT_SIZE_SMALL, 
	-- x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)
	local name = self.order[index]
	if self.order[index+1] - 1 > self.order[index] then
		name = name .."-" ..self.order[index+1] - 1
	end
	local t = display.newSprite(IMAGE_COMMON .."info_bg_12.png"):addTo(cell):align(display.LEFT_TOP, 20, self.m_cellSize.height - 20)
	UiUtil.label(string.format(CommonText[257],name)):addTo(t):align(display.LEFT_CENTER, 55, t:height()/2)

	local awardDB = self.m_activityList[index]
	for k,v in ipairs(awardDB) do
		local itemView = UiUtil.createItemView(v[1], v[2],{count = v[3]})
		itemView:setPosition(50 + (k - 1) * 130,self.m_cellSize.height - 120)
		if v[1] ~= ITEM_KIND_HERO then
			itemView:setScale(0.9)
		else
			itemView:setScale(0.5)
		end
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 2, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data,ifPerson)
	self.ifPerson = ifPerson
	self.m_activityList = {}
	local has = {}
	self.order = {}
	for k,v in ipairs(data) do
		local key = ""
		for m,n in ipairs(v) do
			key = key ..":"..n[1] .. "." ..n[2].."." ..n[3] ..":"
		end
		if not has[key] then
			has[key] = true
			table.insert(self.m_activityList, v)
			table.insert(self.order, k)
		end
	end
	table.insert(self.order, #data+1)
	self:reloadData()
end
------------------------------------------------------------------------------
-- 坦克改装view
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local CrossAwardDialog = class("CrossAwardDialog", Dialog)

-- tankId: 需要改装的tank
function CrossAwardDialog:ctor(kind)
	CrossAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.kind = kind
end

function CrossAwardDialog:onEnter()
	CrossAwardDialog.super.onEnter(self)
	self:setTitle(CommonText[269].."-"..CommonText[30012][self.kind])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local frame = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(self:getBg())
	frame:setPreferredSize(cc.size(500, self:getBg():height()-150))
	frame:setCapInsets(cc.rect(130, 40, 1, 1))
	frame:align(display.CENTER_TOP,self:getBg():width()/2,self:getBg():height()-115)

	local view = ContentTableView.new(cc.size(490, self:getBg():height()-192),self.kind)
		:addTo(self:getBg(),3):pos(45,66)
	view:updateUI(PartyBattleMO.getAll("rebelRankAward"))

	local function createDelegate(container, index)
		local key = "eliteServerRankAwards"
		if self.kind == 1 then
			key = index == 1 and "eliteServerRankAwards" or "eliteAllAwards"
		else
			key = index == 1 and "topServerRankAwards" or "topAllAwards"
		end
		view:updateUI(PartyBattleMO.getAll(key),index == 1)
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[10062][1],CommonText[10062][3]}
	local size = cc.size(btm:width() - 12, 60)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = btm:width()/2+24, y = btm:height()- 125, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(btm,3)
	pageView:setPageIndex(1)
	self.m_pageView = pageView
end

function CrossAwardDialog:onExit()
	CrossAwardDialog.super.onExit(self)
end

return CrossAwardDialog
