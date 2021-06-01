--
-- Author: Gss
-- Date: 2018-11-05 15:13:58
--
-- MailDeleteDialog 邮件选择删除界面

local AllWeaponrySuitTableView = class("AllWeaponrySuitTableView", TableView)

function AllWeaponrySuitTableView:ctor(size, viewIndex)
	AllWeaponrySuitTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 70)
	self.m_viewIndex = viewIndex
	self.m_text = {}
	if self.m_viewIndex == 1 then
		self.m_text = CommonText[1631]
	elseif self.m_viewIndex == 3 then
		self.m_text = CommonText[1632]
	elseif self.m_viewIndex == 4 then
		self.m_text = CommonText[1633]
	end
end

function AllWeaponrySuitTableView:onEnter()
	AllWeaponrySuitTableView.super.onEnter(self)
end

function AllWeaponrySuitTableView:numberOfCells()
	return #self.m_text
end

function AllWeaponrySuitTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function AllWeaponrySuitTableView:createCellAtIndex(cell, index)
	AllWeaponrySuitTableView.super.createCellAtIndex(self, cell, index)

	local delType = 0
	if self.m_viewIndex == MAIL_TYPE_PLAYER then --玩家邮件
		if index == 1 then
			delType = MAIL_DELETE_TYPE_ALL
		elseif index == 2 then
			delType = MAIL_DELETE_TYPE_SYSTEM
		elseif index == 3 then
			delType = MAIL_DELETE_TYPE_READED
		end
	elseif self.m_viewIndex == MAIL_TYPE_REPORT then --报告
		if index == 1 then
			delType = MAIL_DELETE_TYPE_ALL
		elseif index == 2 then
			delType = MAIL_DELETE_TYPE_READED
		end
	end

	-- 覆盖
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local writerBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onWriterCallback))
	writerBtn:setLabel(self.m_text[index])
	writerBtn.delType = delType
	cell:addButton(writerBtn, writerBtn:width() / 2, writerBtn:height() / 2)

	return cell
end

-- 设置
function AllWeaponrySuitTableView:onWriterCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local kind = self.m_viewIndex
	local delType = sender.delType

	local function doDele()
		MailBO.deleteMials(function ()
			self:dispatchEvent({name = "DELETE_MAIL_EVENT"})
		end, kind, delType)
	end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[1637] ,CommonText[1636][delType]), function()
		doDele()
	end):push()
end


------------------------------------------------------------------------------
-- 邮件删除界面
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local MailDeleteDialog = class("MailDeleteDialog", Dialog)

function MailDeleteDialog:ctor(sender, viewFor, deleteCallback)
	if viewFor == 1 then
		MailDeleteDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_19.png", UI_ENTER_NONE, {scale9Size = cc.size(190, 270),alpha = 0})
	elseif viewFor == 3 then
		MailDeleteDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_19.png", UI_ENTER_NONE, {scale9Size = cc.size(190, 200),alpha = 0})
	end

	self.m_viewFor = viewFor
	self.m_deleteCallback = deleteCallback
	self.sender = sender
end

function MailDeleteDialog:onEnter()
	MailDeleteDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:getBg():setPosition(self.sender:getPositionX() + 30,self.sender:getPositionY() + self:getBg():height() / 2 + 70)

	local title = ui.newTTFLabel({text = CommonText[549][1]..":", font = G_FONT, size = FONT_SIZE_SMALL,
	 color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	title:setPosition(self:getBg():width() / 2, self:getBg():height() - 25)

	local view = AllWeaponrySuitTableView.new(cc.size(self:getBg():width() - 40, self:getBg():height() - 60), self.m_viewFor):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 20)
	view:addEventListener("DELETE_MAIL_EVENT", function(event)
			self.m_deleteCallback()
			self:pop()
		end)
	view:reloadData()
end

return MailDeleteDialog