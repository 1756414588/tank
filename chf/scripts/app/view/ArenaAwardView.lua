
-- 竞技场排名奖励

------------------------------------------------------------------------------
-- 竞技场奖励TableView
------------------------------------------------------------------------------
local ArenaAwardTableView = class("ArenaAwardTableView", TableView)

function ArenaAwardTableView:ctor(size)
	ArenaAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 190)

	self.m_awards = ArenaMO.queryAllAwards()

	gdump(self.m_awards, "[ArenaAwardView]")
end

function ArenaAwardTableView:numberOfCells()
	return #self.m_awards
end

function ArenaAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ArenaAwardTableView:createCellAtIndex(cell, index)
	ArenaAwardTableView.super.createCellAtIndex(self, cell, index)

	local award = self.m_awards[index]

	-- 关卡评级
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, self.m_cellSize.height - 30)

	local name = ""
	if award.beginRank == award.endRank then
		name = award.beginRank
	else
		name = award.beginRank .. " - " .. award.endRank
	end

	local title = ui.newTTFLabel({text = string.format(CommonText[257], name), font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local awards = {}
	local data = json.decode(award.award)
	for index = 1, #data do
		awards[index] = {}
		awards[index].kind = data[index][1]
		awards[index].id = data[index][2]
		awards[index].count = data[index][3]
	end

	for index = 1, #awards do
		local award = awards[index]
		-- dump(award)

		local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
		itemView:setPosition(30 + (index - 0.5) * 120, 80)
		UiUtil.createItemDetailButton(itemView, cell, true)

		local resData = UserMO.getResourceData(award.kind, award.id)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 20, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end

	return cell
end

------------------------------------------------------------------------------
-- 竞技场奖励
------------------------------------------------------------------------------
local ArenaAwardView = class("ArenaAwardView", UiNode)

function ArenaAwardView:ctor(uiEnter)
	ArenaAwardView.super.ctor(self, "image/common/bg_ui.jpg")
end

function ArenaAwardView:onEnter()
	ArenaAwardView.super.onEnter(self)
	self:setTitle(CommonText[258])

	self:setUI()
end

function ArenaAwardView:onExit()
	ArenaAwardView.super.onExit(self)
	
	-- gprint("ArenaAwardView onExit() ........................")
	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end
end

function ArenaAwardView:setUI()
	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)

	local label = ui.newTTFLabel({text = CommonText[256], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = container:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(588, container:getContentSize().height - 170))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 50 - infoBg:getContentSize().height / 2)

	local view = ArenaAwardTableView.new(cc.size(infoBg:getContentSize().width - 8, infoBg:getContentSize().height - 8)):addTo(infoBg)
	view:setPosition(4, 4)
	view:reloadData()

	-- 昨日排名
	local label = ui.newTTFLabel({text = CommonText[259] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))
	local label = ui.newTTFLabel({text = ArenaMO.lastRank_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onAwardCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width - 110, 50)
	btn:setLabel(CommonText[255])
	if not ArenaMO.canReceiveAward() then
		btn:setEnabled(false)
	end
	self.m_button = btn
end

function ArenaAwardView:onAwardCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneCallback(awards)
		Loading.getInstance():unshow()
		self.m_button:setEnabled(false)
		UiUtil.showAwards(awards)
	end

	Loading.getInstance():show()
	ArenaBO.asynArenaAward(doneCallback)
end

return ArenaAwardView
