
require("app.text.DetailText")

local ScrollText = class("ScrollText", TableView)

function ScrollText:ctor(size)
	ScrollText.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, size.height)
end

-- 获得view中总共有多少个cell
function ScrollText:numberOfCells()
	return 1
end

-- 索引为index的cell的大小，index从1开启
function ScrollText:cellSizeForIndex(index)
	return self.m_cellSize
end

-- cell:默认会创建一个空的node，node包含有_CELL_INDEX_的值。方法的返回的cellNode才是最终的cell
function ScrollText:createCellAtIndex(cell, index)
	local content = self.m_content
	local rich = RichLabel.new(content, cc.size(self.m_cellSize.width-10, 0)):addTo(cell)
	rich:setPosition(5, self.m_cellSize.height - 10)
	return cell
end

function ScrollText:setContent( content )
	self.m_content = content

	local count = 0
	for i,v in ipairs(content) do
		count = count + string.utf8len(v.content)
	end

	local height = count * 22 / self.m_cellSize.width * 24
	self.m_cellSize.height = math.max(height, self.m_cellSize.height)

	self:reloadData()
end


local PageMenuTableView = class("PageMenuTableView", TableView)

function PageMenuTableView:ctor(size, menus, menuIndex)
	PageMenuTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 54)
	self.m_chosenIndex = menuIndex
	self.m_menus = menus
end

function PageMenuTableView:numberOfCells()
	return #self.m_menus
end

function PageMenuTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PageMenuTableView:createCellAtIndex(cell, index)
	PageMenuTableView.super.createCellAtIndex(self, cell, index)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_20_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_20_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenCallback))

	local tip = self.m_menus[index]
	btn:setLabel(tip, {size = FONT_SIZE_SMALL})
	btn.index = index
	cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	cell.btn = btn

	if self.m_chosenIndex == index then
		btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_selected.png"))
	end

	return cell
end

function PageMenuTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.index == self.m_chosenIndex then
	else
		self:dispatchEvent({name = "CHOSEN_MENU_EVENT", index = sender.index})
	end
end

function PageMenuTableView:chosenIndex(menuIndex)
	self.m_chosenIndex = menuIndex

	for index = 1, self:numberOfCells() do
		local cell = self:cellAtIndex(index)
		if cell then
			if index == self.m_chosenIndex then
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_selected.png"))
			else
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_normal.png"))
			end
		end
	end
end

local Dialog = require("app.dialog.Dialog")
local DetailTextPageDialog = class("DetailTextPageDialog", Dialog)

-- text 用于显示文字列表
function DetailTextPageDialog:ctor(text)
	self.m_text = text
	DetailTextPageDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 600)})
end

function DetailTextPageDialog:onEnter()
	DetailTextPageDialog.super.onEnter(self)
	self:setTitle(CommonText[1105])
	-- self:setOutOfBgClose(true)
	-- self:setInOfBgClose(true)
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 570))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	btm:setPreferredSize(cc.size(360, 480))
	btm:setPosition(self:getBg():getContentSize().width / 2+65, self:getBg():getContentSize().height / 2 - 6)


	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(self:getBg():getContentSize())
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height/2)
	self:showUI(container)
end

function DetailTextPageDialog:showUI(container)
	-- 菜单
	local index = 1
	local menus = {}

	for i,v in ipairs(self.m_text) do
		menus[i] = v.tip
	end

	local contentView = ScrollText.new(cc.size(container:getContentSize().width-200, 450)):addTo(container)
	contentView:setPosition(170, 60)
	local function updateContent()
		local content = self.m_text[index]
		contentView:setContent(content)
	end

	local menuView = PageMenuTableView.new(cc.size(130, container:getContentSize().height - 120), menus, index):addTo(container)
	menuView:addEventListener("CHOSEN_MENU_EVENT", function (event)
		index = event.index
		menuView:chosenIndex(index)
		
		updateContent()
	end)
	menuView:setPosition(30, 45)
	menuView:reloadData()	

	updateContent()
end

return DetailTextPageDialog
