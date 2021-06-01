--
-- Author: Xiaohang
-- Date: 2016-09-18 18:30:41
--
--
local ItemTableView = class("ItemTableView", TableView)

function ItemTableView:ctor(size)
	ItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 175)
end

function ItemTableView:numberOfCells()
	return #self.m_tanks
end

function ItemTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ItemTableView:createCellAtIndex(cell, index)
	ItemTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_tanks[index]
	local name = ui.newTTFLabel({text = string.format(CommonText[20130], data.lineNum), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 148}):addTo(cell)
	local sprite = display.newSprite(IMAGE_COMMON.."dot_yellow.png"):addTo(cell):pos(56,75)
	UiUtil.label(data.lineNum,28):addTo(sprite):center()
	local x,ex = 142,110
	for k,v in ipairs(data.awards) do
		local t = UiUtil.createItemView(v.type, v.id, {count = v.count}):addTo(cell):pos(x+(k-1)*ex, 75):scale(0.8)
		UiUtil.createItemDetailButton(t, cell, true)
		local propDB = UserMO.getResourceData(v.type, v.id)
		UiUtil.label(propDB.name, nil, COLOR[propDB.quality or 1]):addTo(cell):pos(t:x(),t:y()-55)
	end
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, 175))
	bg:setCapInsets(cc.rect(220, 80, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	return cell
end

function ItemTableView:updateUI(data)
	self.m_tanks = data
	self:reloadData()
end

------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local TankCarnivalAward = class("TankCarnivalAward", Dialog)

function TankCarnivalAward:ctor(list)
	TankCarnivalAward.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.list = list
end

function TankCarnivalAward:onEnter()
	TankCarnivalAward.super.onEnter(self)
	
	self:setTitle(CommonText[230])
	self:getCloseButton():setEnabled(false)
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local view = ItemTableView.new(cc.size(btm:getContentSize().width-34, btm:getContentSize().height - 70)):addTo(btm)
	view:setPosition(17, 40)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, 85)
	
	self.awards = {}
	for k,v in ipairs(self.list) do
		v.awards = PbProtocol.decodeArray(v.awards)
		for m,n in ipairs(v.awards) do
			table.insert(self.awards,n)
		end
	end
	view:updateUI(self.list)

	-- 确定
	UiUtil.button("btn_1_normal.png", "btn_1_selected.png", nil, handler(self,self.get), CommonText[676][3])
		:addTo(self:getBg()):pos(self:getBg():width()/2, 25)
end

function TankCarnivalAward:get()
	ManagerSound.playNormalButtonSound()
	local statsAward = CombatBO.addAwards(self.awards)
	UiUtil.showAwards(statsAward)
	self:pop()
end

return TankCarnivalAward