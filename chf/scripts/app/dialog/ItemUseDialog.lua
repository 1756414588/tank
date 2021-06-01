
------------------------------------------------------------------------------
-- 物品使用弹出框
------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local ItemUseDialog = class("ItemUseDialog", Dialog)

function ItemUseDialog:ctor(kind, id)
	ItemUseDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
	self.m_kind = kind
	self.m_id = id
end

function ItemUseDialog:onEnter()
	ItemUseDialog.super.onEnter(self)

	self:setTitle(CommonText[85])  -- 物品使用

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local ItemUseTableView = require("app.scroll.ItemUseTableView")
	local view = ItemUseTableView.new(cc.size(526, 748), self.m_kind, self.m_id):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 44)
	view:reloadData()
end

return ItemUseDialog
