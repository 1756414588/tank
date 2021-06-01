--
-- Author: Gss
-- Date: 2018-08-20 11:38:46
--
-- 军备套装选择界面

local AllWeaponrySuitTableView = class("AllWeaponrySuitTableView", TableView)

function AllWeaponrySuitTableView:ctor(size, formation)
	AllWeaponrySuitTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 176)
	self.m_formation = formation
end

function AllWeaponrySuitTableView:onEnter()
	AllWeaponrySuitTableView.super.onEnter(self)
end

function AllWeaponrySuitTableView:numberOfCells()
	return 2
end

function AllWeaponrySuitTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function AllWeaponrySuitTableView:createCellAtIndex(cell, index)
	AllWeaponrySuitTableView.super.createCellAtIndex(self, cell, index)
	local data = WeaponryMO.schemesAll[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_19.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_21.jpg"):addTo(bg)
	titleBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 26)

	local formname = CommonText[1618][index]
	if data then
		formname = data.name
	end
	-- 阵型x
	local title = ui.newTTFLabel({text = formname, font = G_FONT, size = FONT_SIZE_TINY, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title.word = formname

	local function onEdit1(event, editbox)

	   if event == "return" then
	   		local outstr = editbox:getText()
	   		if string.utf8len(outstr) > 8 then
	   			Toast.show(string.format(CommonText[1081], 8))
	   			editbox:setText("")
	   			title:setString(title.word)
	   			return
	   		end
	   		if outstr ~= "" then
	   			title:setString(editbox:getText())
	   			title.word = title:getString()
	   		else
	   			title:setString(title.word)
	   		end
			editbox:setText("")
	   elseif event == "began" then
			editbox:setText(title:getString())
			title.word = title:getString()
			title:setString("")
	   end
    end

	local inputContent = ui.newEditBox({image = nil, listener = onEdit1, size = cc.size(180, 30)}):addTo(titleBg)
	inputContent:setAnchorPoint(cc.p(0.5,0.5))
	inputContent:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
	inputContent:setFontColor(cc.c3b(225, 255, 255))
	inputContent:setFontSize(FONT_SIZE_TINY)

	-- 覆盖
	local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local writerBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onWriterCallback))
	writerBtn:setLabel(CommonText[67])
	writerBtn.index = index
	writerBtn.title = title
	cell:addButton(writerBtn, 126, 70)

	-- 读取
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local readerBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onReaderCallback))
	readerBtn:setLabel(CommonText[68])
	readerBtn.index = index
	cell:addButton(readerBtn, self.m_cellSize.width - 126, 70)

	return cell
end

-- 设置
function AllWeaponrySuitTableView:onWriterCallback(tag, sender)
	local index = sender.index
	local formname = sender.title:getString()
	local scheme = clone(self.m_formation)
	scheme.type = sender.index
	scheme.name = formname
	scheme = WeaponryMO.encodeWeaponryScheme(scheme)

	local wealEquips =  WeaponryMO.getShowMedals()

	local hasEquip = false
	for posIndex = 1, FIGHT_WEPONRYSCHEME_POS_NUM do
		if wealEquips[posIndex] then
			hasEquip = true
			break
		end
	end

	if hasEquip then
		WeaponryBO.setWeaponryScheme(function ()
			Toast.show(CommonText[1840])
			self:dispatchEvent({name = "READER_WEAPONRYSCHEME_EVENT"})
		end, scheme)
	else
		Toast.show(CommonText[1839])
		return
	end
end

-- 读取
function AllWeaponrySuitTableView:onReaderCallback(tag, sender)
	local index = sender.index

	local scheme = WeaponryMO.schemesAll[index]
	if not scheme then
		Toast.show(CommonText[1838])
		return
	end

	WeaponryBO.wealWeaponryScheme(function (data)
		if data.resolve and #data.resolve > 0 then
			local tipStr = ""
			for index=1,#data.resolve do
				tipStr = tipStr..data.resolve[index].."号"
			end
			Toast.show(string.format(CommonText[1619],tipStr))
		end
		self:dispatchEvent({name = "READER_WEAPONRYSCHEME_EVENT"})
	end, index)

end

------------------------------------------------------------------------------
-- 选择军备套装弹出框
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ChoseWeaponryDialog = class("ChoseWeaponryDialog", Dialog)

function ChoseWeaponryDialog:ctor(formation, choseWeaponryCallback)
	ChoseWeaponryDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 480)})

	gdump(formation, "[ChoseWeaponryDialog] ctor")
	self.m_formation = formation
	self.m_choseWeaponryCallback = choseWeaponryCallback
end

function ChoseWeaponryDialog:onEnter()
	ChoseWeaponryDialog.super.onEnter(self)

	self:setTitle(CommonText[1617])  -- 已保存阵型

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local view = AllWeaponrySuitTableView.new(cc.size(526, 400), self.m_formation):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 10)
	view:addEventListener("READER_WEAPONRYSCHEME_EVENT", function(event)
			self:pop()
		end)
	view:reloadData()
end

return ChoseWeaponryDialog