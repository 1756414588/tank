
-- 展示我的所有部队，并在部队中选择部队上阵

local COL_NUM = 3

local AllMyArmyTableView = class("AllMyArmyTableView", TableView)

-- tanks: 包含tank的id，和可出阵的数量
function AllMyArmyTableView:ctor(size, tanks, formation)
	AllMyArmyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	-- self.m_tanks = TankMO.getFightTanks()
	self.m_tanks = tanks
	self.m_formation = formation
	gdump(self.m_tanks, "AllMyArmyTableView ctor")

	self.m_cellSize = cc.size(size.width, 195)
	self.m_curChoseIndex = 0
	self.m_curTankFightNum = 0 -- 当前选中的坦克上阵的数量
end

function AllMyArmyTableView:numberOfCells()
	return math.ceil(#self.m_tanks / COL_NUM)
end

function AllMyArmyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function AllMyArmyTableView:createCellAtIndex(cell, index)
	AllMyArmyTableView.super.createCellAtIndex(self, cell, index)

	local buttons = {}
	cell.buttons = buttons

	for numIndex = 1, COL_NUM do
		local posIndex = (index - 1) * COL_NUM + numIndex

		if posIndex <= #self.m_tanks then
			local tank = self.m_tanks[posIndex]
			local tankDB = TankMO.queryTankById(tank.tankId)

			local sprite = display.newScale9Sprite(IMAGE_COMMON .. "btn_position_normal.png")
			sprite:setPreferredSize(cc.size(sprite:getContentSize().width, 192))
			local btn = CellTouchButton.new(sprite, handler(self, self.onBeganCallback), handler(self, self.onMovedCallback), nil, handler(self, self.onChosenCallback))
			btn.posIndex = posIndex
			btn.cellIndex = index
			btn.tank = tank
			buttons[numIndex] = btn
			cell:addButton(btn, 10 + (numIndex - 0.5) * 168, self.m_cellSize.height / 2)

			-- 名称
			local name = ui.newTTFLabel({text = tankDB.name, font = G_FONT, size = FONT_SIZE_SMALL,
				x = btn:getContentSize().width / 2, y = btn:getContentSize().height - 36,
				align = ui.TEXT_ALIGN_CENTER, color = COLOR[tankDB.grade]}):addTo(btn, 2)

			local tankTag = UiUtil.createItemSprite(ITEM_KIND_TANK, tank.tankId):addTo(btn)
			tankTag:setAnchorPoint(cc.p(0.5, 0))
			tankTag:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2 - 50)

			if posIndex == self.m_curChoseIndex then
				self:showChosenEffect(btn)
			end

			if self.m_curChoseIndex == 0 and index == 1 then
				self:onChosenCallback(btn:getTag(), btn)
			end

			self:showTankNum(btn)
		end
	end

	return cell
end

function AllMyArmyTableView:cellWillRecycle(cell, index)
	if self.m_curChoseButton and self.m_curChoseButton.cellIndex == index then
		self.m_curChoseButton = nil
	end
end

function AllMyArmyTableView:onBeganCallback(tag, sender)
end

function AllMyArmyTableView:onMovedCallback(tag, sender)
end

function AllMyArmyTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.posIndex ~= self.m_curChoseIndex then
		local tank = sender.tank
		local takeCount = 1
		if self.m_formation then
			local awakeHeroKeyId = nil
			if table.isexist(self.m_formation,"awakenHero") then awakeHeroKeyId = self.m_formation.awakenHero.keyId end
			takeCount = UserBO.getTakeTank(self.m_formation.commander, awakeHeroKeyId)
		end
		self.m_curChoseIndex = sender.posIndex
		self.m_curTankFightNum = math.min(tank.count, takeCount) -- 选中的坦克默认是按照最大数量上阵
		self.m_curChoseButton = sender

		self:showChosenEffect(sender)

		self:onUpdateNum()

		self:dispatchEvent({name = "CHOSEN_TANK_EVENT", tankId = tank.tankId, tank = tank})
	end
end

function AllMyArmyTableView:showChosenEffect(button)
	if not self.m_choseSprite then
		self.m_choseSprite = display.newScale9Sprite(IMAGE_COMMON .. "chose_1.png"):addTo(self)
		self.m_choseSprite:setPreferredSize(cc.size(self.m_choseSprite:getContentSize().width, 190))
		self.m_choseSprite:retain()
	end

	self.m_choseSprite:retain()
	self.m_choseSprite:removeSelf()
	self.m_choseSprite:addTo(button)
	self.m_choseSprite:setPosition(button:getContentSize().width / 2, button:getContentSize().height / 2 + 2)
	self.m_choseSprite:release()
end

function AllMyArmyTableView:onUpdateNum()
	for index = 1, self:numberOfCells() do
		local cell = self:cellAtIndex(index)
		if cell then
			for btnIndex = 1, #cell.buttons do
				self:showTankNum(cell.buttons[btnIndex])
			end
		end
	end
end

function AllMyArmyTableView:showTankNum(button)
	if not button then return end

	if not button.numNode_ then
		button.numNode_ = display.newNode():addTo(button, 10)
		button.numNode_:setPosition(button:getContentSize().width / 2, 30)
		-- button.numNode_.state = 0
	end

	button.numNode_:removeAllChildren()

	local tank = button.tank

	if button.posIndex == self.m_curChoseIndex then

		local curNum = ui.newTTFLabel({text = self.m_curTankFightNum, font = G_FONT, size = FONT_SIZE_SMALL, x = -5, y = 0, align = ui.TEXT_ALIGN_RIGHT, color = COLOR[2]}):addTo(button.numNode_)
		local totalNum = ui.newTTFLabel({text = "/" .. tank.count, font = G_FONT, size = FONT_SIZE_SMALL, x = -5, y = 0, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT}):addTo(button.numNode_)
	else
		local num = ui.newTTFLabel({text = tank.count, font = G_FONT, size = FONT_SIZE_SMALL, x = 0, y = 0, color = COLOR[11], align = ui.TEXT_VALIGN_CENTER}):addTo(button.numNode_)
	end
end

-- 更新设置当前选中的tank的上阵数量
function AllMyArmyTableView:setCurTankFightNum(num)
	self.m_curTankFightNum = num
	self:showTankNum(self.m_curChoseButton)
end

function AllMyArmyTableView:onExit()
	AllMyArmyTableView.super.onExit(self)
	
	if self.m_choseSprite then
		self.m_choseSprite:release()
	end
end

return AllMyArmyTableView

