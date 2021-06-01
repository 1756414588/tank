--
-- Author: xiaoxing
-- Date: 2016-12-09 10:09:22
--
local ItemTableView = class("ItemTableView", TableView)

function ItemTableView:ctor(size,kind)
	ItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.kind = kind
	self.m_cellSize = cc.size(self:getViewSize().width, 60)
end

function ItemTableView:onEnter()
	ItemTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_JOIN_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function ItemTableView:numberOfCells()
	return #self.m_list
end

function ItemTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ItemTableView:createCellAtIndex(cell, index)
	ItemTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_list[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, 2))
	bg:setPosition(self.m_cellSize.width / 2, 0)
	local lab = "LV." .. data.partyLv
	local l = ui.newTTFLabel({text = lab, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 80, y = self.m_cellSize.height/2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	lab = data.partyName
	l = ui.newTTFLabel({text = lab, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):alignTo(l, 115)
	l:hide()
	UiUtil.label(data.partyName,nil,COLOR[2]):alignTo(l, 14, 1)
	UiUtil.label(data.serverName):alignTo(l, -14, 1)
	lab = data.memberNum
	l = ui.newTTFLabel({text = lab, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):alignTo(l, 115)
	lab = data.totalFight
	if lab == 0 then 
		UiUtil.label(CommonText[20052]):alignTo(l, 115)
	else
		ui.newBMFontLabel({text = UiUtil.strNumSimplify(lab), font = "fnt/num_2.fnt"}):alignTo(l, 115)
	end
	return cell
end

function ItemTableView:getNextHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBattleBO.asynWarParties(function()
		Loading.getInstance():unshow()
		end, sender.page)
end

function ItemTableView:onExit()
	ItemTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

function ItemTableView:updateUI(data)
	self.m_list = data
	self:reloadData()
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local ListDialog = class("ListDialog", Dialog)

function ListDialog:ctor(title,items,data)
	ListDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.title = title
	self.items = items
	self.data = data
end

function ListDialog:onEnter()
	ListDialog.super.onEnter(self)
	
	self:setTitle(self.title)
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	
	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height-50))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:align(display.CENTER_BOTTOM, btm:getContentSize().width / 2, 20)

	local posX = {80,195,310,425}
	for index=1,#self.items do
		local title = ui.newTTFLabel({text = self.items[index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = cc.c3b(115,115,115), align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
	end

	local view = ItemTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.kind):addTo(tableBg)
	view:setPosition(0, 25)
	self.view = view
	view:updateUI(self.data)
end

return ListDialog