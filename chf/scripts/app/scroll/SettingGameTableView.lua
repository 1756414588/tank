
local SettingGameTableView = class("SettingGameTableView", TableView)

function SettingGameTableView:ctor(size, viewFor)
	SettingGameTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 1010)
end

function SettingGameTableView:numberOfCells()
	return 1
end

function SettingGameTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SettingGameTableView:createCellAtIndex(cell, index)
	SettingGameTableView.super.createCellAtIndex(self, cell, index)

	-- 游戏性
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell)
	infoBg:setPreferredSize(cc.size(self.m_cellSize.width - 16, 450))
	-- infoBg:setCapInsets(cc.rect(130, 40, 1, 1))
	infoBg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height - infoBg:getContentSize().height / 2 - 20)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(infoBg)
	titleBg:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 8)

	local title = ui.newTTFLabel({text = CommonText[323], font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y =titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	for index = 1, 4 do
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
		line:setPreferredSize(cc.size(580, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, infoBg:getContentSize().height - 108 - (index - 1) * 80)
	end

	local initTopHeight = infoBg:getContentSize().height - 70
	local initTopBtnHeight = self.m_cellSize.height - 90
	local topHeightIndex = 0
	-- local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	-- star:setPosition(40, infoBg:getContentSize().height - 70 - 0 * 80)

	-- -- 背景音乐
	-- local label = ui.newTTFLabel({text = CommonText[325][1], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- if ManagerSound.musicEnable then
	-- 	-- 已开启
	-- 	local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- 	label:setAnchorPoint(cc.p(0, 0.5))

	-- 	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	-- 	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	-- 	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
	-- 	btn.index = 1
	-- 	btn:setLabel(CommonText[326][4])
	-- 	cell:addButton(btn, infoBg:getContentSize().width - 80, self.m_cellSize.height - 90)
	-- else
	-- 	-- 已关闭
	-- 	local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- 	label:setAnchorPoint(cc.p(0, 0.5))

	-- 	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	-- 	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	-- 	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
	-- 	btn.index = 1
	-- 	btn:setLabel(CommonText[326][3])
	-- 	cell:addButton(btn, infoBg:getContentSize().width - 80, self.m_cellSize.height - 90)
	-- end

	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initTopHeight - topHeightIndex * 80)

	-- 按键音效
	local label = ui.newTTFLabel({text = CommonText[325][2], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if ManagerSound.soundEnable then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 2
		btn:setLabel(CommonText[326][4])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 2
		btn:setLabel(CommonText[326][3])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	end

	topHeightIndex = topHeightIndex + 1
	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initTopHeight - topHeightIndex * 80)

	-- 消费二次确认
	local label = ui.newTTFLabel({text = CommonText[325][4], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.consumeConfirm then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 4
		btn:setLabel(CommonText[326][4])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 4
		btn:setLabel(CommonText[326][3])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	end

	topHeightIndex = topHeightIndex + 1
	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initTopHeight - topHeightIndex * 80)

	-- 显示建筑名称
	local label = ui.newTTFLabel({text = CommonText[325][5], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.showBuildName then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 5
		btn:setLabel(CommonText[326][4])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 5
		btn:setLabel(CommonText[326][3])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	end

	topHeightIndex = topHeightIndex + 1
	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initTopHeight - topHeightIndex * 80)

	-- 显示行军路线
	local label = ui.newTTFLabel({text = CommonText[20061], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.showArmyLine then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 6
		btn:setLabel(CommonText[326][4])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 6
		btn:setLabel(CommonText[326][3])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	end

	topHeightIndex = topHeightIndex + 1
	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initTopHeight - topHeightIndex * 80)

	-- 显示网络延迟
	local label = ui.newTTFLabel({text = CommonText[1063], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.showPintUI then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 8
		btn:setLabel(CommonText[326][4])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onClickCallback))
		btn.index = 8
		btn:setLabel(CommonText[326][3])
		cell:addButton(btn, infoBg:getContentSize().width - 80, initTopBtnHeight - 80 * topHeightIndex)
	end

	-- 通知
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell)
	infoBg:setPreferredSize(cc.size(self.m_cellSize.width - 16, 445))
	infoBg:setCapInsets(cc.rect(130, 40, 1, 1))
	infoBg:setPosition(self.m_cellSize.width / 2, infoBg:getContentSize().height / 2 + 80)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(infoBg)
	titleBg:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 8)

	local title = ui.newTTFLabel({text = CommonText[324], font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y =titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	for index = 1, 4 do
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
		line:setPreferredSize(cc.size(580, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, infoBg:getContentSize().height - 108 - (index - 1) * 80)
	end

	local initBottomHeight = infoBg:getContentSize().height - 70
	local initBottomBtnHeight = self.m_cellSize.height - 550
	local bottomHeightIndex = 0

	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initBottomHeight - bottomHeightIndex * 80)

	-- 活动开启
	local label = ui.newTTFLabel({text = CommonText[325][6], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if open then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[326][4])
		btn:setEnabled(false)
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[326][3])
		btn:setEnabled(false)
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	end

	bottomHeightIndex = bottomHeightIndex + 1
	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initBottomHeight - bottomHeightIndex * 80)

	-- 建筑升级完成
	local label = ui.newTTFLabel({text = CommonText[325][7], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if open then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[326][4])
		btn:setEnabled(false)
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[326][3])
		btn:setEnabled(false)
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	end

	bottomHeightIndex = bottomHeightIndex + 1
	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initBottomHeight - bottomHeightIndex * 80)

	-- 生产完成
	local label = ui.newTTFLabel({text = CommonText[325][8], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if open then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[326][4])
		btn:setEnabled(false)
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[326][3])
		btn:setEnabled(false)
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	end

	bottomHeightIndex = bottomHeightIndex + 1
	local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
	star:setPosition(40, initBottomHeight - bottomHeightIndex * 80)

	-- 能量满通知
	local label = ui.newTTFLabel({text = CommonText[325][9], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	if open then
		-- 已开启
		local label = ui.newTTFLabel({text = CommonText[326][1], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[326][4])
		btn:setEnabled(false)
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	else
		-- 已关闭
		local label = ui.newTTFLabel({text = CommonText[326][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[326][3])
		btn:setEnabled(false)
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	end

	bottomHeightIndex = bottomHeightIndex + 1
	if UserBO.isEnablePush() then
		local star = display.newSprite(IMAGE_COMMON .. "star_3.png"):addTo(infoBg)
		star:setPosition(40, initBottomHeight - bottomHeightIndex * 80)
		-- 评论按钮
		local label = ui.newTTFLabel({text = CommonText[325][10], font = G_FONT, size = FONT_SIZE_SMALL, x = star:getPositionX() + 30, y = star:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onClickCallback))
		btn:setLabel(CommonText[676][2])
		btn.index = 7
		cell:addButton(btn, infoBg:getContentSize().width - 80, initBottomBtnHeight - 80 * bottomHeightIndex)
	end 
	
	return cell
end

function SettingGameTableView:onClickCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = sender.index
	if index == 1 then
		ManagerSound.musicEnable = not ManagerSound.musicEnable
	elseif index == 2 then
		ManagerSound.soundEnable = not ManagerSound.soundEnable
	elseif index == 3 then
		UserMO.autoDefend = not UserMO.autoDefend
	elseif index == 4 then
		UserMO.consumeConfirm = not UserMO.consumeConfirm
	elseif index == 5 then
		UserMO.showBuildName = not UserMO.showBuildName
	elseif index == 6 then
		UserMO.showArmyLine = not UserMO.showArmyLine
	elseif index == 7 then
		--IOS 应用商店评论
		if UserMO.pushState == IOS_PUSH_STATE_NO then
			Loading.getInstance():show()
			UserBO.asynPushComment(function()
				Loading.getInstance():unshow()
				end,3)
		else
			ServiceBO.gotoAppStorePageRaisal(CommonText[1501][4])
		end
	elseif index == 8 then
		UserMO.showPintUI = not UserMO.showPintUI
		if UserMO.showPintUI then
			Pinging.GetInstance():show()
		else
			Pinging.GetInstance():unshow()
		end
	end

	writefile(GAME_SETTING_FILE .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId, json.encode({ManagerSound.musicEnable, ManagerSound.soundEnable, UserMO.autoDefend, UserMO.consumeConfirm, UserMO.showBuildName, UserMO.showArmyLine, UserMO.showPintUI}))

	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

return SettingGameTableView
