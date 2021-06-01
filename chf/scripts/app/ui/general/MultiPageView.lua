
local TabButtonPageView = class("TabButtonPageView", PageView)

function TabButtonPageView:ctor(size, tabCount, createCellCall)
	TabButtonPageView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_cellSize = size
	self.m_tabCount = tabCount
	self.m_createCellCall = createCellCall

	-- local componentBg = display.newScale9Sprite(IMAGE_COMMON .. "lottery_equip_blue.png"):addTo(self)
	-- componentBg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height))
	-- componentBg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	-- componentBg:setOpacity(0)	
end

function TabButtonPageView:numberOfCells()
	return self.m_tabCount
end

function TabButtonPageView:cellSizeForIndex(index)
	return self:getViewSize()
end

function TabButtonPageView:createCellAtIndex(cell, index)
	TabButtonPageView.super.createCellAtIndex(self, cell, index)

	if self.m_createCellCall then
		self.m_createCellCall(cell, index, self.m_cellSize)
	end
	-- local componentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell)
	-- componentBg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height))
	-- componentBg:setPosition(self:getViewSize().width / 2, self:getViewSize().height / 2)
	-- componentBg:setOpacity(0)

	-- local labelColor = cc.c3b(0, 0, 0)

	-- local title = ui.newTTFLabel({text = "VIP" .. index .. CommonText[408], font = G_FONT, size = FONT_SIZE_HUGE, x = self.m_cellSize.width / 2, y = self.m_cellSize.height - 40, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)

	-- local posY = self.m_cellSize.height - 60

	-- local data = DetailText.vip[index]

	-- if data then
	-- 	for index = 1, #data do
	-- 		local d = data[index]
	-- 		local label = RichLabel.new(d, cc.size(self.m_cellSize.width, 0)):addTo(cell)
	-- 		label:setPosition(0, posY)
	-- 		label:setTouchEnabled(false)
	-- 		posY = posY - label:getHeight()
	-- 	end
	-- end

	return cell
end

function TabButtonPageView:onDetailCallback(tag, sender)
	-- local DetailPartDialog =  require("app.dialog.DetailPartDialog")
	-- DetailPartDialog.new():push()
end

------------------------------------------------------------------------
--
-- Author: GongYY
-- Date:
-- 多标签页控件

local MultiPageView = class("MultiPageView", function()
	local node = display.newNode()
	node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
	return node
end)

MULTIPAGE_STYLE_NORMAL   = 1  -- 多标签的正常(水平)模式
MULTIPAGE_STYLE_DIY      = 4  -- 多标签的自定义模式

local SELECTED_FONT_SIZE = FONT_SIZE_MEDIUM
local SELECTED_COLOR = cc.c3b(255, 255, 255)

local UNSELECTED_FONT_SIZE = FONT_SIZE_MEDIUM
local UNSELECTED_COLOR = cc.c3b(129, 129, 129)

-- style: 模式
-- size: 多标签页的内容的大小(不包含标签按钮)
-- pages: 标签按钮的名称，必须是字符串
-- param: 多标签页的参数，参数有下面几个
-- ｘ、y: 位置
-- hideDelete: 标签页在单击其他标签，当前标签隐藏时，内容是否删除。默认是不删除
-- createDelegate: 创建每个标签下的内容的回调
-- clickBaginDelegate: 点击某个标签前的回调 (return 是否触发响应 defalut true)
-- clickDelegate: 点击某个标签后的回调
-- styleDelegates: 如果MultiPageView.VIEW_STYLE_DIY的style的，则参数为table，{createYesBtnCallback, createNoBtnCallback, createTabCount}
function MultiPageView:ctor(style, size, pages, param)
	style = style or MULTIPAGE_STYLE_NORMAL

	param = param or {}
	param.x = param.x or 0
	param.y = param.y or 0
	if param.hideDelete == nil then param.hideDelete = false end

	param.styleDelegates = param.styleDelegates or {}

	self.containerLayerLevel = param.containerLayerLevel or 1

	self:setPosition(param.x, param.y)
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5, 0.5))

	self.m_style = style
	self.m_pages = pages
	self.m_hideDelete = param.hideDelete
	self.m_createDelegate = param.createDelegate
	self.m_clickDelegate = param.clickDelegate
	self.m_clickBaginDelegate = param.clickBaginDelegate

	self.m_pageNum = 0
	self.m_pageContainer = {}

	self.m_yesButtons = {}
	self.m_noButtons = {}

	self.m_styleDelegates = param.styleDelegates
	if self.m_style ~= MULTIPAGE_STYLE_NORMAL then
		if not self.m_styleDelegates.createYesBtnCallback or not self.m_styleDelegates.createNoBtnCallback then
			self.m_style = MULTIPAGE_STYLE_NORMAL -- 默认模式
		end
	end

	if self.m_style == MULTIPAGE_STYLE_NORMAL then
		self:createNormallButtons(self.m_pages)
	-- elseif self.m_style == MultiPageView.VIEW_STYLE_VERTICAL then
	-- 	self:createVerticalButtons(self.m_pages)
	elseif self.m_style == MULTIPAGE_STYLE_DIY then
		self:createDIYButtons(self.m_pages)
	end

	self.m_curPageButtonIndex = 0
	-- self:setPageIndex(self.m_curPageButtonIndex)
	self:showPageButton()
	self:showPageContianer()

	-----------------------------------------------------
	-- local bg = display.newScale9Sprite(IMAGE_COMMON .. "a.png"):addTo(self)
	-- bg:setPreferredSize(cc.size(size.width, size.height))
	-- bg:setPosition(size.width / 2, size.height / 2)

 --    -- if self.m_line then
 --    --     self.m_line:removeSelf()
 --    -- end

 --    -- local line = display.newLine({{0, size.height}, {size.width, 0}})
 --    -- -- line:setAnchorPoint(cc.p(0.5, 0.5))
 --    -- -- line:setPosition(size.width / 2, size.height / 2)
 --    -- self:addChild(line)
 --    -- self.m_line = line

 --    -- local line = display.newLine({{0, 0}, {size.width, size.height}})
 --    -- -- line:setAnchorPoint(cc.p(0.5, 0.5))
 --    -- -- line:setPosition(size.width / 2, size.height / 2)
 --    -- self:addChild(line)

 --    -- local line = display.newLine({{0, size.height}, {size.width, size.height}})
 --    -- -- line:setAnchorPoint(cc.p(0.5, 0.5))
 --    -- -- line:setPosition(size.width / 2, size.height / 2)
 --    -- self:addChild(line)
    -----------------------------------------------------
end

-- function MultiPageView:createVerticalButtons(pages)
-- 	if pages ~= nil then
-- 		self.m_pageNum = #pages

-- 		local sprite = display.newSprite(IMAGE_COMMON .. "btn_page_selected.png")

-- 		local posX = -sprite:getContentSize().width / 2
-- 		local startPosY = self:getContentSize().height - sprite:getContentSize().height / 2
-- 		local posYDelta = 99

-- 		local count = self.m_pageNum
-- 		for index = 1, count do
-- 			local posY = startPosY - (index - 1) * posYDelta

-- 			-- 选中标签页的按钮
-- 			local yesNormal = display.newSprite(IMAGE_COMMON .. "btn_page_selected.png")
-- 			local yesSelected = display.newSprite(IMAGE_COMMON .. "btn_page_selected.png")
-- 			self.m_yesButtons[index] = MenuButton.new(yesNormal, yesSelected, nil, handler(self, self.pageYesButtonCallback))
-- 			self.m_yesButtons[index]:setPosition(posX, posY)
-- 			self:addChild(self.m_yesButtons[index], 1, index)

-- 			-- 未选中标签页的按钮
-- 			local noNormal = display.newSprite(IMAGE_COMMON .. "btn_page_normal.png")
-- 			local noSelected = display.newSprite(IMAGE_COMMON .. "btn_page_normal.png")
-- 			self.m_noButtons[index] = MenuButton.new(noNormal, noSelected, nil, handler(self, self.pageNoButtonCallback))
-- 			self.m_noButtons[index]:setPosition(posX, posY)
-- 			self:addChild(self.m_noButtons[index], 0, index)

-- 			if not self.m_asynchronous then
-- 				self:createContainer(index)
-- 			end
-- 		end
-- 		gprint("MultiPageView:createVerticalButtons --> 22")

-- 	end
-- end

function MultiPageView:createNormallButtons(pages)
	if pages ~= nil then
		self.m_pageNum = #pages

		local startPosX = 0
		local posXDelta = 0
		if self.m_style == MULTIPAGE_STYLE_NORMAL then
			local sprite = display.newSprite(IMAGE_COMMON .. "btn_4_normal.png")
			startPosX = sprite:getContentSize().width / 2
			posXDelta = 158
		end

		local posY = self:getContentSize().height + 22

		--gprint(".. " .. posYDelta)
		local count = self.m_pageNum
		for index = 1, count do
			local posX = startPosX + (index - 1) * posXDelta

			local normalName = nil
			local selectedName = nil
			if self.m_style == MULTIPAGE_STYLE_NORMAL then
				normalName = IMAGE_COMMON .. "btn_4_selected.png"
				selectedName = IMAGE_COMMON .. "btn_4_selected.png"
			end
			-- 选中标签页的按钮
			local yesNormal = display.newSprite(normalName)
			local yesSelected = display.newSprite(selectedName)
			self.m_yesButtons[index] = MenuButton.new(yesNormal, yesSelected, nil, handler(self, self.pageYesButtonCallback))
			self.m_yesButtons[index]:setPosition(posX, posY - 4)
			self:addChild(self.m_yesButtons[index], count + index, index)

			if pages[index] ~= nil then
				local label = ui.newTTFLabel({text = pages[index], font = G_FONT, size = SELECTED_FONT_SIZE, x = self.m_yesButtons[index]:getContentSize().width / 2,
					y = self.m_yesButtons[index]:getContentSize().height / 2 + 4, color = SELECTED_COLOR, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_yesButtons[index])
			end

			if self.m_style == MULTIPAGE_STYLE_NORMAL then
				normalName = IMAGE_COMMON .. "btn_4_normal.png"
				selectedName = IMAGE_COMMON .. "btn_4_normal.png"
			end
			-- 未选中标签页的按钮
			local noNormal = display.newSprite(normalName)
			local noSelected = display.newSprite(selectedName)
			self.m_noButtons[index] = MenuButton.new(noNormal, noSelected, nil, handler(self, self.pageNoButtonCallback))
			self.m_noButtons[index]:setPosition(posX, posY)
			self:addChild(self.m_noButtons[index], count + index - 1, index)

			if pages[index] ~= nil then
				local label = ui.newTTFLabel({text = pages[index], font = G_FONT, size = UNSELECTED_FONT_SIZE, x = self.m_noButtons[index]:getContentSize().width / 2,
					y = self.m_noButtons[index]:getContentSize().height / 2, color = UNSELECTED_COLOR, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_noButtons[index])
			end
		end
	end
end

function MultiPageView:createDIYButtons(pages)
	if pages ~= nil then
		self.m_pageNum = #pages

		local count = self.m_pageNum

		if self.m_styleDelegates.createTabCount and self.m_styleDelegates.createTabCount > 0 then
			self:createDIYTabButtons(count, self.m_styleDelegates.createTabCount)
			return
		end

		for index = 1, count do
			self.m_yesButtons[index] = self.m_styleDelegates.createYesBtnCallback(index)
			self.m_yesButtons[index]:setTagCallback(handler(self, self.pageYesButtonCallback))
			self:addChild(self.m_yesButtons[index], count + count - index, index)

			self.m_noButtons[index] = self.m_styleDelegates.createNoBtnCallback(index)
			self.m_noButtons[index]:setTagCallback(handler(self, self.pageNoButtonCallback))
			self:addChild(self.m_noButtons[index], count - index + 1, index)

			-- if not self.m_asynchronous then
			-- 	self:createContainer(index)
			-- end
		end
	end
end

function MultiPageView:createDIYTabButtons( count, tabCount )
	local function createCellCall( cell, cellIndex, cellSize )
		local pos = {80,245,410}
		for i=1,tabCount do
			local index = (cellIndex-1) * tabCount + i
			if index <= count then
				self.m_yesButtons[index] = self.m_styleDelegates.createYesBtnCallback(index)
				self.m_yesButtons[index]:setTagCallback(handler(self, self.pageYesButtonCallback))
				-- cell:addChild(self.m_yesButtons[index], count + count - index, i)
				-- self.m_yesButtons[index]:setPosition(pos[i], cellSize.height/2)
				
				cell:addButton(self.m_yesButtons[index], pos[i], cellSize.height/2)
				self.m_yesButtons[index]:setTag(index)

				self.m_noButtons[index] = self.m_styleDelegates.createNoBtnCallback(index)
				self.m_noButtons[index]:setTagCallback(handler(self, self.pageNoButtonCallback))
				-- cell:addChild(self.m_noButtons[index], count - index + 1, i)				
				-- self.m_noButtons[index]:setPosition(pos[i], cellSize.height/2)
				cell:addButton(self.m_noButtons[index], pos[i], cellSize.height/2)
				self.m_noButtons[index]:setTag(index)

				if self.m_curPageButtonIndex ~= index then
					self.m_yesButtons[index]:setVisible(false)
					self.m_noButtons[index]:setVisible(true)
				else
					self.m_yesButtons[index]:setVisible(true)
					self.m_noButtons[index]:setVisible(false)
				end				
			end
		end
	end

	local tabPageCount = math.ceil(count/tabCount)

	local view = TabButtonPageView.new(cc.size(490, 60), tabPageCount, createCellCall):addTo(self,1000)
	view:setPosition(15, self:getContentSize().height )

	view:reloadData()

	self.m_tabPageView = view	
end

function MultiPageView:pageYesButtonCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- ManagerSound.playSound("ui_click_button")
	--if self.m_curPageButtonIndex ~= tag then
	--end
end

function MultiPageView:pageNoButtonCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- ManagerSound.playSound("ui_click_button")

	if self.m_curPageButtonIndex ~= tag then -- 需要显示新的标签页
		-- 点击 响应前操作
		if self.m_clickBaginDelegate and not self.m_clickBaginDelegate(tag) then
			return
		end

		-- 标签操作
		self:setPageIndex(tag)

		-- 进行回调
		if self.m_clickDelegate ~= nil then
			self.m_clickDelegate(self.m_pageContainer[index], tag)
		end
	end
end

function MultiPageView:setPageIndex(pageIndex)
	if self.m_hideDelete then  -- 删除当前container的内容
		if self.m_pageContainer[self.m_curPageButtonIndex] then
			-- gprint("[MultiPageView] 需要删除内容")
			self.m_pageContainer[self.m_curPageButtonIndex]:removeSelf()
			self.m_pageContainer[self.m_curPageButtonIndex] = nil
		end
	end

	self.m_curPageButtonIndex = pageIndex

	-- 判断container是否已经创建了
	self:createContainer(pageIndex)

	self:showPageButton()
	self:showPageContianer()
end

function MultiPageView:showPageButton()
	if self.m_styleDelegates.createTabCount and self.m_styleDelegates.createTabCount > 0 then
		local tabCount = self.m_styleDelegates.createTabCount
		local count = self.m_pageNum
		local tabIndex = math.ceil(self.m_curPageButtonIndex/tabCount)
		if tabIndex == 0 then tabIndex = 1 end
		self.m_tabPageView:setCurrentIndex(tabIndex)

		for i=1,tabCount do
			local index = (tabIndex-1) * tabCount + i
			if index <= count then
				if self.m_curPageButtonIndex ~= index then
					self.m_yesButtons[index]:setVisible(false)
					self.m_noButtons[index]:setVisible(true)
				else
					self.m_yesButtons[index]:setVisible(true)
					self.m_noButtons[index]:setVisible(false)
				end				
			end
		end
		return
	end

	for index = 1, self.m_pageNum do
		if self.m_curPageButtonIndex ~= index then
			self.m_yesButtons[index]:setVisible(false)
			self.m_noButtons[index]:setVisible(true)
		else
			self.m_yesButtons[index]:setVisible(true)
			self.m_noButtons[index]:setVisible(false)
		end
	end
end

function MultiPageView:showPageContianer()
	for index = 1, self.m_pageNum do
		if self.m_pageContainer[index] then
			if self.m_curPageButtonIndex ~= index then
				self.m_pageContainer[index]:setVisible(false)
			else
				self.m_pageContainer[index]:setVisible(true)
			end
		end
	end
end

function MultiPageView:createContainer(index)
	if self.m_pageContainer[index] then return end

	local node = display.newNode()
	node:setContentSize(self:getContentSize())
	self:addChild(node, self.containerLayerLevel)
	self.m_pageContainer[index] = node

	if self.m_createDelegate ~= nil then
		self.m_createDelegate(node, index)
	end
end

function MultiPageView:setStyle(style)
	if not style then return end

	self.m_style = style
end

function MultiPageView:getPageIndex()
	return self.m_curPageButtonIndex
end

function MultiPageView:getContainerByIndex(pageIndex)
	return self.m_pageContainer[pageIndex]
end

function MultiPageView:reloadContainer(pageIndex)
	if self.m_pageContainer[pageIndex] then
		self.m_pageContainer[pageIndex]:removeSelf()
		self.m_pageContainer[pageIndex] = nil
	end

	self:createContainer(pageIndex)
end

return MultiPageView