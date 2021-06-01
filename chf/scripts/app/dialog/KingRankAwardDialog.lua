--
-- Author: Gss
-- Date: 2018-12-07 15:47:17
--
-- 最强王者 分榜奖励预览  KingRankAwardDialog

local KingRankAwardTableView = class("KingRankAwardTableView", TableView)

function KingRankAwardTableView:ctor(size,kind)
	KingRankAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 200)
	self.list = ActivityCenterMO.getKingRankByKind(kind)
end

function KingRankAwardTableView:numberOfCells()
	return #self.list
end

function KingRankAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function KingRankAwardTableView:createCellAtIndex(cell, index)
	KingRankAwardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(10, self.m_cellSize.height - 30)

	local awardList = {}
	for k,v in ipairs(json.decode(data.awardList)) do
		table.insert(awardList, {type = v[1],id = v[2],count = v[3]})
	end

	for index=1,#awardList do
		local award = awardList[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setPosition(20 + itemView:getContentSize().width / 2 + (index - 1) * 120,bg:getPositionY() - 80)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)

		local resData = UserMO.getResourceData(award.type, award.id)
		local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = 18,}):alignTo(itemView, -70, 1)
	end

	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = bg:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	info:setAnchorPoint(cc.p(0,0.5))

	local rankValue
	if data.rankBegin == data.rankEnd then
		rankValue = data.rankBegin
	else
		rankValue = data.rankBegin .. "-" .. data.rankEnd 
	end

	info:setString(string.format(CommonText[772],rankValue))

	return cell
end

function KingRankAwardTableView:onExit()
	KingRankAwardTableView.super.onExit(self)

end



-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local KingRankAwardDialog = class("KingRankAwardDialog", Dialog)

function KingRankAwardDialog:ctor(kind)
	KingRankAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.kind = kind
end

function KingRankAwardDialog:onEnter()
	KingRankAwardDialog.super.onEnter(self)
	
	self:setTitle(CommonText[771])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 60))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 45 - tableBg:getContentSize().height / 2)

	local view = KingRankAwardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),self.kind):addTo(tableBg)
	view:setPosition(0, 10)
	view:reloadData()
end

return KingRankAwardDialog
