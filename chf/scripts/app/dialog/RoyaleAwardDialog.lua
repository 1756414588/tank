--
-- Author: heyunlong
-- Date: 2018-07-26 17:00:28
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
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (k - 1) * 100,self.m_cellSize.height - 120)
		itemView:setScale(0.9)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 2, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end
	return cell
end

function ContentTableView:numberOfCells()
	return self.kind == 2 and 2 or #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
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
local RoyaleAwardDialog = class("RoyaleAwardDialog", Dialog)

-- tankId: 需要改装的tank
function RoyaleAwardDialog:ctor(awardKey)
	RoyaleAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.awardKey = awardKey
end

function RoyaleAwardDialog:onEnter()
	RoyaleAwardDialog.super.onEnter(self)
	self:setTitle(CommonText[269])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local frame = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(self:getBg())
	frame:setPreferredSize(cc.size(500, self:getBg():height()-130))
	frame:setCapInsets(cc.rect(130, 40, 1, 1))
	frame:align(display.CENTER_TOP,self:getBg():width()/2,self:getBg():height()-70)

	local view = ContentTableView.new(cc.size(490, self:getBg():height()-162),self.kind)
		:addTo(self:getBg()):pos(45,86)
	view:updateUI(PartyBattleMO.getAll(self.awardKey or "honourLiveRankAward"))
	if not self.awardKey == "honourLiveRankAward" then
		local tips = UiUtil.label(CommonText[2115]):addTo(self:getBg())
		tips:setPosition(self:getBg():width() / 2, 50)
	end
end

function RoyaleAwardDialog:onExit()
	RoyaleAwardDialog.super.onExit(self)
end

return RoyaleAwardDialog
