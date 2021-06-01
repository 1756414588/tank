--
-- Author: gf
-- Date: 2015-09-07 11:02:11
--
local ConfirmDialog = require("app.dialog.ConfirmDialog")

local MyStoreTableView = class("MyStoreTableView", TableView)

function MyStoreTableView:ctor(size)
	MyStoreTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 180)
	self.myStore_ = clone(SocialityMO.queryMyStore_(1))
	self.showIndex = 1

	-- 表示每个cell中的checkbox是否被选中
	self.m_chosenData = {}
end

function MyStoreTableView:onEnter()
	MyStoreTableView.super.onEnter(self)

	self.m_UpgradeHandler = Notify.register(LOCAL_STORE_UPDATE_EVENT, handler(self, self.onUpgradeUpdate))
end

function MyStoreTableView:numberOfCells()
	return #self.myStore_
end

function MyStoreTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MyStoreTableView:createCellAtIndex(cell, index)
	MyStoreTableView.super.createCellAtIndex(self, cell, index)

	local store = self.myStore_[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 167))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	--编辑按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_edit_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_edit_selected.png")
	local editBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.editHandler))
	editBtn.store = store
	cell:addButton(editBtn, self.m_cellSize.width / 2 - 260, self.m_cellSize.height - 45)

	--坐标
	local posLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = self.m_cellSize.width / 2 + 260, y = self.m_cellSize.height - 32, 
		color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	posLab:setAnchorPoint(cc.p(1, 0.5))
	local pos = WorldMO.decodePosition(store.pos)
	posLab:setString(" (" .. pos.x  .. "," .. pos.y ..  ")")

	local itemView,name

	if store.type == 1 then --玩家
		itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, store.man.icon):addTo(cell)
		itemView:setScale(0.65)
		itemView:setPosition(110,bg:getContentSize().height / 2)
		name = ui.newTTFLabel({text = store.man.nick .. "(LV." .. store.man.level .. ")", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = self.m_cellSize.width / 2 - 140, y = self.m_cellSize.height - 32, 
			color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		name:setAnchorPoint(cc.p(0, 0.5))
	else --矿点
		local mine = WorldBO.getMineAt(pos)

		local mineName = UserMO.getResourceData(ITEM_KIND_WORLD_RES, mine.type).name2
		if not mineName then return end

		itemView = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, mine.type, {level = mine.lv}):addTo(cell)
		itemView:setPosition(110, bg:getContentSize().height / 2)
		itemView:setScale(0.65)
		name = ui.newTTFLabel({text = mineName .. "(LV." .. mine.lv .. ")", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = self.m_cellSize.width / 2 - 140, y = self.m_cellSize.height - 32, 
			color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		name:setAnchorPoint(cc.p(0, 0.5))
	end

	--是否矿
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_mine_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_mine_selected.png")
	local mineBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.isMineHandler))
	if store.isMine == 0 then
		mineBtn:unselected()
	else
		mineBtn:selected()
	end

	mineBtn.store = store
	cell:addButton(mineBtn, self.m_cellSize.width / 2 - 110, self.m_cellSize.height - 90)

	--是否敌人
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_enemy_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_enemy_selected.png")
	local enemyBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.isEnemyHandler))
	if store.enemy == 0 then
		enemyBtn:unselected()
	else
		enemyBtn:selected()
	end
	enemyBtn.store = store
	cell:addButton(enemyBtn, self.m_cellSize.width / 2 - 40, self.m_cellSize.height - 90)

	--是否好友
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_friend_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_friend_selected.png")
	local friendBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.isfriendHandler))
	if store.friend == 0 then
		friendBtn:unselected()
	else
		friendBtn:selected()
	end
	friendBtn.store = store
	cell:addButton(friendBtn, self.m_cellSize.width / 2 + 30, self.m_cellSize.height - 90)

	--定位
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_go_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_go_selected.png")
	local goBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.goHandler))
	goBtn.pos = pos
	cell:addButton(goBtn, self.m_cellSize.width / 2 + 160, self.m_cellSize.height - 90)

	--删除
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_store_del_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_store_del_selected.png")
	-- local delBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.delHandler))
	-- delBtn.store = store
	-- cell:addButton(delBtn, self.m_cellSize.width / 2 + 245, self.m_cellSize.height - 90)

	--复选框
	local checkBox = CellCheckBox.new(nil, nil, handler(self, self.onCheckedChanged))
	checkBox.cellIndex = index
	checkBox:setAnchorPoint(cc.p(0, 0.5))
	cell:addButton(checkBox, self.m_cellSize.width / 2 + 225, self.m_cellSize.height - 90)

	if self.m_chosenData[index] then
		checkBox:setChecked(true)
	end

	cell.checkBox = checkBox



	--备注
	local psLab = ui.newTTFLabel({text = CommonText[546], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = self.m_cellSize.width / 2 - 140, y = self.m_cellSize.height - 140, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	psLab:setAnchorPoint(cc.p(0, 0.5))


	local function onEdit(event, editbox)
	   if event == "return" then
	   		store.mark = editbox:getText()
	   end
    end

    local inputDesc = ui.newEditBox({image = nil, listener = onEdit, size = cc.size(316, 35)}):addTo(cell)
	inputDesc:setFontColor(COLOR[3])
	inputDesc:setFontSize(FONT_SIZE_MEDIUM)
	inputDesc:setPosition(psLab:getPositionX() + psLab:getContentSize().width + 170, psLab:getPositionY())
	inputDesc:setText(store.mark)

	return cell
end

function MyStoreTableView:isMineHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.store.isMine == 0 then
		sender.store.isMine = 1
		sender:selected()
	else
		sender.store.isMine = 0
		sender:unselected()
	end
end

function MyStoreTableView:isEnemyHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.store.enemy == 0 then
		sender.store.enemy = 1
		sender:selected()
	else
		sender.store.enemy = 0
		sender:unselected()
	end
end

function MyStoreTableView:isfriendHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.store.friend == 0 then
		sender.store.friend = 1
		sender:selected()
	else
		sender.store.friend = 0
		sender:unselected()
	end
end

function MyStoreTableView:editHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	SocialityBO.asynMarkStore(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[851])
		end,sender.store)
end

function MyStoreTableView:goHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- gdump(sender.pos,"[MyStoreTableView:goHandler]..sender.pos")
	UiDirector.clear()
	Notify.notify(LOCAL_LOCATION_EVENT, {x = sender.pos.x, y = sender.pos.y})
end

-- function MyStoreTableView:delHandler(tag, sender)
-- 	ManagerSound.playNormalButtonSound()
-- 	ConfirmDialog.new(CommonText[695], function()
-- 		Loading.getInstance():show()
-- 		SocialityBO.asynDelStore(function()
-- 		Loading.getInstance():unshow()
-- 		end,sender.store.pos)
-- 	end):push()


	
-- end

function MyStoreTableView:setShowIndex(index)
	self.showIndex = index
	self.myStore_ = clone(SocialityMO.queryMyStore_(index))
	self.m_chosenData = {}
	self:reloadData()
end


function MyStoreTableView:onUpgradeUpdate()
	self.myStore_ = SocialityMO.queryMyStore_(self.showIndex)
	self.m_chosenData = {}
	self:reloadData()
end

function MyStoreTableView:cellTouched(cell, index)
	self.m_chosenData[index] = not self.m_chosenData[index]
	cell.checkBox:setChecked(self.m_chosenData[index])

	self:dispatchEvent({name = "CHECK_STORE_EVENT", index = index})
end

function MyStoreTableView:onCheckedChanged(sender, isChecked)
	local index = sender.cellIndex

	self.m_chosenData[index] = isChecked
	self:dispatchEvent({name = "CHECK_STORE_EVENT", index = index})
end


function MyStoreTableView:getCheckedStorePos()
	local poses = {}
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		if self.m_chosenData[index] then -- 选中了
			poses[#poses + 1] = self.myStore_[index].pos
		end
	end
	return poses
end


function MyStoreTableView:onExit()
	MyStoreTableView.super.onExit(self)
	
	if self.m_UpgradeHandler then
		Notify.unregister(self.m_UpgradeHandler)
		self.m_UpgradeHandler = nil
	end
end



return MyStoreTableView