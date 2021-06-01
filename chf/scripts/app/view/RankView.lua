
------------------------------------------------------------------------------
-- 排行榜左边菜单的TableView
------------------------------------------------------------------------------

local RankConfig = {}

local RankMenuTableView = class("RankMenuTableView", TableView)

function RankMenuTableView:ctor(size, chosenId)
	RankMenuTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 80)

	if StaffMO.isStaffOpen_ then  -- 如果骗纸开放了，则显示编制排行榜
		RankConfig = {1, 9, 2, 3, 4, 5, 6, 7, 12, 13, 10, 11}
	else
		RankConfig = {1, 2, 3, 4, 5, 6, 7, 12, 13, 10, 11}
	end

	-- 军衔
	-- if UserMO.queryFuncOpen(UFP_MILITARY) then
	-- 	table.insert(RankConfig, 1, 14)
	-- 	chosenId = chosenId or 14
	-- else
		chosenId = chosenId or 1
	-- end

	-- 总实力
	-- chosenId = chosenId or 14

	for index = 1, #RankConfig do
		if RankConfig[index] == chosenId then
			self.m_chosenIndex = index
		end
	end
	gprint("RankMenuTableView:ctor:", self.m_chosenIndex)
end

function RankMenuTableView:numberOfCells()
	return #RankConfig
end

function RankMenuTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RankMenuTableView:createCellAtIndex(cell, index)
	RankMenuTableView.super.createCellAtIndex(self, cell, index)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_20_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_20_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenCallback))
	local idx = RankConfig[index]
	btn:setLabel(CommonText[329][idx], {size = FONT_SIZE_SMALL})
	btn.index = index
	cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	cell.btn = btn

	if self.m_chosenIndex == index then
		btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_selected.png"))
	end

	return cell
end

function RankMenuTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.index == self.m_chosenIndex then
	else
		self:dispatchEvent({name = "CHOSEN_MENU_EVENT", index = sender.index})
	end
end

function RankMenuTableView:chosenIndex(menuIndex)
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

function RankMenuTableView:getChosenIndex()
	return RankConfig[self.m_chosenIndex]
end

------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------

local RankView = class("RankView", UiNode)

function RankView:ctor(rankId)
	RankView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_rankId = rankId
	gprint("RankView:ctor:", rankIndex)
end

function RankView:onEnter()
	RankView.super.onEnter(self)

	self:setTitle(CommonText[276])

	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)

	local node = display.newNode():addTo(container)
	node:setContentSize(cc.size(474, container:getContentSize().height - 155))
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(container:getContentSize().width - node:getContentSize().width / 2 - 10, node:getContentSize().height / 2 - 55)
	self.m_rankNode = node

	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(container)
	tag:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tag:getContentSize().height / 2 - 190)

	local size = cc.size(container:getContentSize().width, container:getContentSize().height)

	-- local pages = {CommonText[498][1], CommonText[498][2]}
	local pages = {CommonText[1801][1], CommonText[1801][2]}

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 200 + 60, size.height - tag:getContentSize().height / 2 - 190)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 75+60, size.height - tag:getContentSize().height / 2 - 190)
		end
		button:setLabel(pages[index])
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 200+60, size.height - tag:getContentSize().height / 2 - 190)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 75+60, size.height - tag:getContentSize().height / 2 - 190)
		end
		button:setLabel(pages[index], {color = COLOR[11]})

		return button
	end

	local function createDelegate(container, index)
		if index == 1 then  -- 总榜
			self:showExUI(container)
		elseif index == 2 then -- 其他榜
			self:showUI(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = container:getContentSize().width / 2, y = size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}, hideDelete = true}):addTo(container, 2)
	
	if self.m_rankId then
		pageView:setPageIndex(2)
	else
		pageView:setPageIndex(1)
	end
end

-- 额外的总实力榜
function RankView:showExUI( container )
	self.m_rankNode:removeAllChildren()
	self.m_menuTablView = nil

	self:showRank(15)
end

function RankView:showUI(container)
	if GameConfig.enableCode then
		-- 菜单
		local view = RankMenuTableView.new(cc.size(130, container:getContentSize().height - 210), self.m_rankId):addTo(container)
		view:addEventListener("CHOSEN_MENU_EVENT", handler(self, self.onChosenMenu))
		view:setPosition(10, -40)
		view:reloadData()
		self.m_menuTablView = view

		local index = self.m_menuTablView:getChosenIndex()
		self.m_menuTablView:setVisible(false)
		self:showRank(index)
	end
end

function RankView:onChosenMenu(event)
	local index = event.index
	self.m_menuTablView:chosenIndex(index)

	local choseIndex = self.m_menuTablView:getChosenIndex()
	self:showRank(choseIndex)
end

function RankView:showRank( index )
	local outindex = index

	if not UserMO.queryFuncOpen(UFP_NEW_PLAYER_POWER) then
		outindex = index == 15 and 14 or index
	end	

	local function show()
		Loading.getInstance():unshow()
		self.m_rankNode:removeAllChildren()
		if self.m_menuTablView then
			self.m_menuTablView:setVisible(true)
		end

		local title = display.newSprite(IMAGE_COMMON .. "bar_rank_" .. index .. ".jpg"):addTo(self.m_rankNode)
		title:setPosition(self.m_rankNode:getContentSize().width - title:getContentSize().width / 2, self.m_rankNode:getContentSize().height + title:getContentSize().height / 2)

		-- 我的排名
		local rankname = (index == 14 and CommonText[1017][3]) or 
						(index == 15 and CommonText[1800]) or 
						CommonText[391]
		local label = ui.newTTFLabel({text = rankname .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = -100, y = self.m_rankNode:getContentSize().height + 130, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
		label:setAnchorPoint(cc.p(0, 0.5))

		local myRank = RankMO.getMyRankByType(outindex)
		if myRank == nil or myRank == 0 then  -- 未上榜
			local rankvalue = (index == 14 and CommonText[509]) or CommonText[392]
			if index == 15 then
				if UserMO.queryFuncOpen(UFP_NEW_PLAYER_POWER) then
					local rankvalue = RankMO.getMyRankFightByType(index)
					local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(rankvalue,nil,nil,true), font = "fnt/num_2.fnt"}):addTo(self.m_rankNode)
					value:setPosition(label:getPositionX() + label:getContentSize().width + 5, label:getPositionY())
					value:setAnchorPoint(cc.p(0, 0.5))
				else
					local value = ui.newTTFLabel({text = "-", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
					value:setAnchorPoint(cc.p(0, 0.5))					
				end					
			else
				local value = ui.newTTFLabel({text = rankvalue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
				value:setAnchorPoint(cc.p(0, 0.5))
			end

			-- 军衔 要求显示排行
			if index == 14 or index == 15 then
				local label = ui.newTTFLabel({text = CommonText[391]  .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
				label:setAnchorPoint(cc.p(0, 0.5))

				local value = ui.newTTFLabel({text = CommonText[392],color = COLOR[5], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
				value:setAnchorPoint(cc.p(0, 0.5))
			end
		else
			-- local rankvalue = (index == 14 and MilitaryRankMO.getMilitrayRankName(UserMO.militaryRank_)) or 
			-- 				  (index == 15 and RankMO.getMyRankFightByType(index)) or 
			-- 				  -- (index == 15 and "-" )or 
			-- 				  myRank

			if index == 15 then
				if UserMO.queryFuncOpen(UFP_NEW_PLAYER_POWER) then
					local rankvalue = RankMO.getMyRankFightByType(index)
					local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(rankvalue,nil,nil,true), font = "fnt/num_2.fnt"}):addTo(self.m_rankNode)
					value:setPosition(label:getPositionX() + label:getContentSize().width + 5, label:getPositionY())
					value:setAnchorPoint(cc.p(0, 0.5))
				else
					local value = ui.newTTFLabel({text = "-", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
					value:setAnchorPoint(cc.p(0, 0.5))					
				end				
			else
				local rankvalue = (index == 14 and MilitaryRankMO.getMilitrayRankName(UserMO.militaryRank_)) or myRank				
				local value = ui.newTTFLabel({text = rankvalue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
				value:setAnchorPoint(cc.p(0, 0.5))
			end

			-- 等级
			local ranklv = (index == 14 and CommonText[391]) or (index == 15 and CommonText[391]) or CommonText[113]
			local label = ui.newTTFLabel({text = ranklv .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
			label:setAnchorPoint(cc.p(0, 0.5))

			local ranklvvalue = (index == 14 and myRank) or (index == 15 and myRank) or UserMO.level_
			local value = ui.newTTFLabel({text = ranklvvalue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
			value:setAnchorPoint(cc.p(0, 0.5))

			local isFightShow = index ~= 14 and index ~= 15
			-- 战斗力
			local label = ui.newTTFLabel({text = CommonText[281] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
			label:setAnchorPoint(cc.p(0, 0.5))
			label:setVisible(isFightShow)

			local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(UserMO.fightValue_), font = "fnt/num_2.fnt"}):addTo(self.m_rankNode)
			value:setPosition(label:getPositionX() + label:getContentSize().width + 5, label:getPositionY())
			value:setAnchorPoint(cc.p(0, 0.5))
			value:setVisible(isFightShow)
		end

		-- local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(self.m_rankNode)
		-- titleBg:setPosition(self.m_rankNode:getContentSize().width / 2, self.m_rankNode:getContentSize().height - 8)

		-- local title = ui.newTTFLabel({text = CommonText[330][index], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		-- title:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2 + 2)

		local bgWidth = self.m_rankNode:getContentSize().width
		if index == 15 then
			-- 总实力排行榜 加一个描述
			local label = ui.newTTFLabel({text = CommonText[1802],color = COLOR[12], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_rankNode)
			label:setAnchorPoint(cc.p(0, 0.5)) 

			bgWidth = GAME_SIZE_WIDTH - 17
		end

		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(self.m_rankNode)
		bg:setPreferredSize(cc.size(bgWidth, self.m_rankNode:getContentSize().height - 40))
		bg:setCapInsets(cc.rect(80, 60, 1, 1))
		bg:setPosition(self.m_rankNode:getContentSize().width - bgWidth/2+7, bg:getContentSize().height / 2)

		local ranks = RankMO.getRanksByType(outindex)
		if not ranks or #ranks <= 0 then
			local img = display.newSprite(IMAGE_COMMON .. "smile.png"):addTo(bg)
			img:setPosition(bg:getContentSize().width/2 , bg:getContentSize().height/2 )
		end

		-- 排名
		local label
		if index == 15 then
			label = ui.newTTFLabel({text = CommonText[396][1], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 100, y = bg:getContentSize().height - 25}):addTo(bg)
		else
			label = ui.newTTFLabel({text = CommonText[396][1], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 65, y = bg:getContentSize().height - 25}):addTo(bg)
		end
		-- 角色名
		if index == 14 then
			local label1 = ui.newTTFLabel({text = CommonText[396][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 230, y = label:getPositionY()}):addTo(bg)
		elseif index == 15 then
			local label1 = ui.newTTFLabel({text = CommonText[396][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 200, y = label:getPositionY()}):addTo(bg)
		else
			local label1 = ui.newTTFLabel({text = CommonText[396][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 158, y = label:getPositionY()}):addTo(bg)
		end
		-- 等级
		if index == 9 then  -- 编制称号
			local label = ui.newTTFLabel({text = CommonText[396][9], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 312, y = label:getPositionY()}):addTo(bg)
		elseif index == 14 then
		elseif index == 15 then
			local label = ui.newTTFLabel({text = CommonText[396][14], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 405, y = label:getPositionY()}):addTo(bg)
		else  -- 等级
			local label = ui.newTTFLabel({text = CommonText[396][3], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 312, y = label:getPositionY()}):addTo(bg)
		end

		if index == 1 then -- 战斗力
			local label = ui.newTTFLabel({text = CommonText[281], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 2 then  -- 星数
			local label = ui.newTTFLabel({text = CommonText[396][4], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 3 then -- 荣誉
			local label = ui.newTTFLabel({text = CommonText[106], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 4 then -- 攻击加成
			local label = ui.newTTFLabel({text = CommonText[396][5], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 5 then
			local label = ui.newTTFLabel({text = CommonText[396][6], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 6 then 
			local label = ui.newTTFLabel({text = CommonText[396][7], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 7 then
			local label = ui.newTTFLabel({text = CommonText[396][8], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 9 then -- 编制等级
			local label = ui.newTTFLabel({text = CommonText[396][10], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 10 then -- 震慑强度
			local label = ui.newTTFLabel({text = CommonText[329][10], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 11 then -- 刚毅强度
			local label = ui.newTTFLabel({text = CommonText[329][11], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 12 then -- 勋章价值
			local label = ui.newTTFLabel({text = CommonText[396][11], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 13 then -- 勋章展示
			local label = ui.newTTFLabel({text = CommonText[396][12], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 14 then -- 军衔
			local label = ui.newTTFLabel({text = CommonText[396][13], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)
		elseif index == 15 then -- 总实力
			local label = ui.newTTFLabel({text = CommonText[396][13], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 522, y = label:getPositionY()}):addTo(bg)
		end

		local RankTableView = require("app.scroll.RankTableView")
		local view = RankTableView.new(cc.size(bg:getContentSize().width, self.m_rankNode:getContentSize().height - 30 - 16 - 50), index):addTo(self.m_rankNode)
		view:setPosition(self.m_rankNode:getContentSize().width - bgWidth, 13)
		view:reloadData()
	end

	local ranks = RankMO.getRanksByType(outindex)
	if ranks and index ~=15 then 			-- 总实力榜每次都刷新
		show()
	else
		Loading.getInstance():show()
		RankBO.asynGetRank(show, outindex, 1) -- 显示第一页
	end
end

return RankView
