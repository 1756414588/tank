
local NearbyTableView = class("NearbyTableView", TableView)

function NearbyTableView:ctor(size, playerList, resourceList)
	NearbyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)
	self.m_playerList = playerList
	self.m_resourceList = resourceList
end

function NearbyTableView:numberOfCells()
	return #self.m_playerList + #self.m_resourceList
end

function NearbyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function NearbyTableView:createCellAtIndex(cell, index)
	NearbyTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell)
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local pos = cc.p(0, 0)

	if index <= #self.m_playerList then  -- 显示玩家
		local player = self.m_playerList[index]

		local portrait = 1
		if table.isexist(player, "portrait") then portrait = player.portrait end

		local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, portrait):addTo(cell)
		itemView:setPosition(80, self.m_cellSize.height / 2)
		itemView:setScale(0.5)

		local label = ui.newTTFLabel({text = player.name .. " (LV." .. player.lv .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 114, color = COLOR[1]}):addTo(cell)

		local bar = UiUtil.showProsBar(player.pros, player.prosMax):addTo(cell)
		bar:setPosition(160 + bar:getContentSize().width / 2, 70)

		pos = WorldMO.decodePosition(player.pos)

		-- 坐标(x, y)
		local label = ui.newTTFLabel({text = "(" .. pos.x .. " , " .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	else -- 显示资源
		local mine = self.m_resourceList[index - #self.m_playerList]

		local sprite = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, mine.type, {level = mine.lv}):addTo(cell)
		sprite:setPosition(80, self.m_cellSize.height / 2)

		local resData = UserMO.getResourceData(ITEM_KIND_WORLD_RES, mine.type)

		-- 
		local label = ui.newTTFLabel({text = mine.lv .. CommonText[237][4] .. resData.name2 .. " (LV." .. mine.lv .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 114, color = COLOR[1]}):addTo(cell)

		pos = WorldMO.decodePosition(mine.pos)

		-- 坐标(x, y)
		local label = ui.newTTFLabel({text = "(" .. pos.x .. " , " .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 160, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	end

	local function goto(tag, sender)
		ManagerSound.playNormalButtonSound()
		
		UiDirector.clear()
		Notify.notify(LOCAL_LOCATION_EVENT, {x = sender.pos.x, y = sender.pos.y})
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_go_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_go_selected.png")
	local locateBtn = CellMenuButton.new(normal, selected, nil, goto)
	locateBtn.pos = pos
	cell:addButton(locateBtn, self.m_cellSize.width - 90, self.m_cellSize.height / 2 - 20)

	return cell
end


-- 世界，查找附近

local Dialog = require("app.dialog.Dialog")
local WorldNearbyDialog = class("WorldNearbyDialog", Dialog)

function WorldNearbyDialog:ctor(x, y)
	WorldNearbyDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
	gprint("WorldNearbyDialog:x:", x, "y:", y)
	self.m_pos = cc.p(x, y)
end

function WorldNearbyDialog:onEnter()
	WorldNearbyDialog.super.onEnter(self)

	self:setTitle(CommonText[306])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local resources, players = WorldBO.findNeerBy(self.m_pos)

	self.m_players = {}
	self.m_resources = {}

	for resId = RESOURCE_ID_IRON, RESOURCE_ID_STONE do
		self.m_resources[resId] = {}

		local reses = resources[resId]
		if reses then
			for level = UserMO.level_ - 2, 1, -1 do
				local rs = reses[level]
				if rs then
					for index = 1, #rs do
						if #self.m_resources[resId] < 10 then  -- 显示某种资源，只从10个里面挑选
							self.m_resources[resId][#self.m_resources[resId] + 1] = rs[index]
						end
					end
				end
			end
		end
	end

	for level = UserMO.level_, 1, -1 do  -- 等级下降
		local ps = players[level]
		if ps then
			for index = 1, #ps do
				if #self.m_players < 30 then  -- 界面上显示的只从最多30个里面挑选
					self.m_players[#self.m_players + 1] = ps[index]
				end
			end
		end
	end

	gdump(self.m_resources, "WorldNearbyDialog:onEnter resource")
	gdump(self.m_players, "WorldNearbyDialog:onEnter player")

	self:showUI()

	local function changeCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		self:showUI()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local btn = MenuButton.new(normal, selected, nil, changeCallback):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 25)
	btn:setLabel(CommonText[402])
end

function WorldNearbyDialog:showUI()
	if self.m_tableView then
		self.m_tableView:removeSelf()
		self.m_tableView = nil
	end

	-- local value = random(1, 1)
	-- print("value:xxxxxxxxx", value)

	local players = clone(self.m_players)

	local showPlayerList = {}
	if #players <= 5 then
		showPlayerList = players
	else
		for index = 1, 5 do
			local value = random(1, #players)  -- 随机选一个
			-- print("value:", value)
			showPlayerList[index] = players[value]
			table.remove(players, value)
		end
	end

	local showResList = {}
	for index = 1, RESOURCE_ID_STONE do
		if #self.m_resources[index] > 0 then
			local value = random(1, #self.m_resources[index])  -- 随机选一个
			showResList[#showResList + 1] = self.m_resources[index][value]
		end
	end

	gdump(showPlayerList, "WorldNearbyDialog:showUI")

	local view = NearbyTableView.new(cc.size(526, 718), showPlayerList, showResList):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 74)
	view:reloadData()
	self.m_tableView = view
end

return WorldNearbyDialog
