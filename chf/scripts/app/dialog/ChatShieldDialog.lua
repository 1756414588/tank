
local ChatShieldTableView = class("ChatShieldTableView", TableView)

function ChatShieldTableView:ctor(size)
	ChatShieldTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)
	self.m_curChoseIndex = 0
end

function ChatShieldTableView:numberOfCells()
	return #ChatMO.shield_
end

function ChatShieldTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ChatShieldTableView:createCellAtIndex(cell, index)
	ChatShieldTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local shield = ChatMO.shield_[index]

	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, shield[3]):addTo(cell)
	itemView:setScale(0.5)
	itemView:setPosition(80, self.m_cellSize.height / 2)

	-- 名称
	local label = ui.newTTFLabel({text = shield[2], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 等级
	local label = ui.newTTFLabel({text = "LV." .. shield[4], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_del_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_del_selected.png")
	local delBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDeleteCallback))
	delBtn.shield = shield
	cell:addButton(delBtn, self.m_cellSize.width - 80, 50)

	return cell
end

function ChatShieldTableView:onDeleteCallback(tag, sender)
	local shield = sender.shield
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[405][2], shield[2]), function()
			self:dispatchEvent({name = "DELETE_SHIELD_EVENT", shield = sender.shield})
		end):push()
end

-- 聊天屏蔽列表

local Dialog = require("app.dialog.Dialog")
local ChatShieldDialog = class("ChatShieldDialog", Dialog)

function ChatShieldDialog:ctor()
	ChatShieldDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
end

function ChatShieldDialog:onEnter()
	ChatShieldDialog.super.onEnter(self)

	self:setTitle(CommonText[403])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width - 54, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, 130)

	-- 屏蔽人数
	local label = ui.newTTFLabel({text = CommonText[404][1] .. ": " .. #ChatMO.shield_ .. " / " .. CHAT_SHIELD_NUM, font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_label = label

	local view = ChatShieldTableView.new(cc.size(526, 660), self.m_awards):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 134)
	view:addEventListener("DELETE_SHIELD_EVENT", handler(self, self.onDelete))
	view:reloadData()
	self.m_tableView = view
end

function ChatShieldDialog:onDelete(event)
	local shield = event.shield

	ChatBO.deleteShield(shield[1])

	self.m_label:setString(CommonText[404][1] .. ": " .. #ChatMO.shield_ .. " / " .. CHAT_SHIELD_NUM)
	self.m_tableView:reloadData()
end

return ChatShieldDialog

