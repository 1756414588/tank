
-- 玩家信息tableview

local PlayerDetailTableView = class("PlayerDetailTableView", TableView)

function PlayerDetailTableView:ctor(size)
	PlayerDetailTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)
	self.m_cellNum = 4

end

function PlayerDetailTableView:onEnter()
	PlayerDetailTableView.super.onEnter(self)

	self.m_prosperousHandler = Notify.register(LOCAL_PROSPEROUS_EVENT, handler(self, self.onUpdate))
	self.m_fameHandler = Notify.register(LOCAL_FAME_EVENT, handler(self, self.onUpdate))
end


function PlayerDetailTableView:onExit()
	PlayerDetailTableView.super.onExit(self)
	if self.m_prosperousHandler then
		Notify.unregister(self.m_prosperousHandler)
		self.m_prosperousHandler = nil
	end

	if self.m_fameHandler then
		Notify.unregister(self.m_fameHandler)
		self.m_fameHandler = nil
	end
end

-- function PlayerDetailTableView:cellTouched(cell, index)
-- 	print("index:", index)
-- end

function PlayerDetailTableView:numberOfCells()
	return self.m_cellNum
end

function PlayerDetailTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PlayerDetailTableView:createCellAtIndex(cell, index)
	PlayerDetailTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	if index == 1 then -- 军衔
		local itemView = UiUtil.createItemView(ITEM_KIND_RANK, UserMO.getResource(ITEM_KIND_RANK)):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)

		local rankDB = UserMO.queryRankById(UserMO.getResource(ITEM_KIND_RANK))
		if rankDB then
			-- 标题
			local title = ui.newTTFLabel({text = rankDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

			local resData = UserMO.getResourceData(ITEM_KIND_FAME)

			-- 每日可领取X声望
			local desc = ui.newTTFLabel({text = CommonText[111] .. rankDB.fame .. resData.name, font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 89, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
		end
	elseif index == 2 then -- 繁荣
		local itemView = UiUtil.createItemView(ITEM_KIND_PROSPEROUS):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)

		local resData = UserMO.getResourceData(ITEM_KIND_PROSPEROUS)
		-- 标题繁荣等级
		local title = ui.newTTFLabel({text = resData.name .. CommonText[113] .. " LV." .. UserMO.prosperousLevel_, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

		-- 带兵数量
		local label = ui.newTTFLabel({text = CommonText[22] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local pros = UserMO.queryProsperousByLevel(UserMO.prosperousLevel_)

		local count = ui.newTTFLabel({text = "+" .. pros.tankCount, font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		count:setAnchorPoint(cc.p(0, 0.5))

		-- 当前繁荣
		local desc = ui.newTTFLabel({text = CommonText[73] .. resData.name .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		desc:setAnchorPoint(cc.p(0, 0.5))

		local node = UiUtil.showProsValue(UserMO.getResource(ITEM_KIND_PROSPEROUS), UserMO.maxProsperous_):addTo(cell)
		node:setPosition(desc:getPositionX() + desc:getContentSize().width, desc:getPositionY() - node:getContentSize().height / 2)


		local bar = UiUtil.showProsBar(UserMO.getResource(ITEM_KIND_PROSPEROUS), UserMO.maxProsperous_):addTo(cell)
		bar:setPosition(node:getPositionX() + node:getContentSize().width / 2, node:getPositionY() - 6)


		-- -- 当前繁荣度
		-- local num = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_PROSPEROUS), font = G_FONT, size = FONT_SIZE_TINY, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		-- num:setAnchorPoint(cc.p(0, 0.5))

		-- -- 最大繁荣度
		-- local num = ui.newTTFLabel({text = "/" .. UserMO.maxProsperous_, font = G_FONT, size = FONT_SIZE_TINY, x = num:getPositionX() + num:getContentSize().width, y = num:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		-- num:setAnchorPoint(cc.p(0, 0.5))

	elseif index == 3 then -- 统率
		local itemView = UiUtil.createItemView(ITEM_KIND_COMMAND):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)

		local command = UserMO.queryCommandByLevel(UserMO.command_)

		-- 标题统率等级
		local title = ui.newTTFLabel({text = CommonText[114] .. " LV." .. UserMO.command_, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

		-- 带兵数量
		local label = ui.newTTFLabel({text = CommonText[22] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 89, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local strCount = "+"
		if command then
			strCount = strCount .. command.tankCount
		else
			strCount = strCount .. "0"
		end
		local count = ui.newTTFLabel({text = strCount, font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		count:setAnchorPoint(cc.p(0, 0.5))
	elseif index == 4 then -- 声望
		local itemView = UiUtil.createItemView(ITEM_KIND_FAME):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)

		local resData = UserMO.getResourceData(ITEM_KIND_FAME)

		-- 标题声望等级
		local title = ui.newTTFLabel({text = resData.name .. " LV." .. UserMO.fameLevel_, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_5.png", BAR_DIRECTION_HORIZONTAL, cc.size(196, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(196 + 4, 26)}):addTo(cell)
		bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 89)
		local need = UserMO.getUpFameByLevel(UserMO.fameLevel_)
		if need then
			bar:setPercent(UserMO.fame_  / UserMO.getUpFameByLevel(UserMO.fameLevel_))
			bar:setLabel(UserMO.fame_ .. "/" .. UserMO.getUpFameByLevel(UserMO.fameLevel_))
		else
			bar:setPercent(1)
			-- bar:setLabel(UserMO.fame_ .. "/" .. UserMO.getUpFameByLevel(UserMO.fameLevel_))
		end
	end

	-- 详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDetailCallback))
	detailBtn.index = index
	cell:addButton(detailBtn, self.m_cellSize.width - 172, self.m_cellSize.height / 2 - 22)

	-- 升级按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local upBtn = CellMenuButton.new(normal, selected, nil, nil)
	cell:addButton(upBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)

	if index == 1 then
		upBtn:setTagCallback(handler(self, self.onRankCallback))
		if UserMO.getResource(ITEM_KIND_RANK) >= UserMO.queryMaxRank() then -- 最高军衔
			upBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png"))
			upBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png"))
		else
			local nxtRank = UserMO.queryRankById(UserMO.getResource(ITEM_KIND_RANK) + 1)
			if nxtRank.lordLv > UserMO.level_ then
				upBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png"))
				upBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png"))
			end
		end
	elseif index == 2 then
		upBtn:setTagCallback(handler(self, self.onProsCallback))
	elseif index == 3 then
		upBtn:setTagCallback(handler(self, self.onCommandCallback))
	elseif index == 4 then -- 声望
		if not UserMO.canBuyFame_ then  -- 不能授勋
			upBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png"))
			upBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png"))
		end
		upBtn:setTagCallback(handler(self, self.onMedalCallback))
	end
	return cell
end

function PlayerDetailTableView:onDetailCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local index = sender.index
	
	if index == 1 then
		local DetailRankDialog = require("app.dialog.DetailRankDialog")
		DetailRankDialog.new():push()
	elseif index == 2 then
		local DetailProsDialog = require("app.dialog.DetailProsDialog")
		DetailProsDialog.new():push()
	elseif index == 3 then
		local DetailCommandDialog = require("app.dialog.DetailCommandDialog")
		DetailCommandDialog.new():push()
	elseif index == 4 then
		local DetailFameDialog = require("app.dialog.DetailFameDialog")
		DetailFameDialog.new():push()
	end
end

function PlayerDetailTableView:onRankCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if UserMO.getResource(ITEM_KIND_RANK) >= UserMO.queryMaxRank() then -- 最高军衔
		-- gprint("PlayerDetailTableView 1")
		Toast.show(CommonText[10032])  -- 提升军衔等级已最高，无法提升
		return
	end

	local nxtRank = UserMO.queryRankById(UserMO.getResource(ITEM_KIND_RANK) + 1)
	if nxtRank.lordLv > UserMO.level_ then
		Toast.show(string.format(CommonText[240], nxtRank.lordLv))
		return
	end

	if nxtRank.stoneCost > UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE) then
		local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
		Toast.show(resData.name .. CommonText[223])
		return
	end

	local function doneUpRank()
		Loading.getInstance():unshow()
		Toast.show(CommonText[346])  -- 军衔提升成功
		self:reloadData()
	end

	Loading.getInstance():show()
	UserBO.asynUpRank(doneUpRank)
end

-- 繁荣度按钮
function PlayerDetailTableView:onProsCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if UserMO.getResource(ITEM_KIND_PROSPEROUS) >= UserMO.maxProsperous_ then  -- 繁荣度已满
		local resData = UserMO.getResourceData(ITEM_KIND_PROSPEROUS)
		Toast.show(string.format(CommonText[197], resData.name2))
		return
	end

	local delta = UserMO.maxProsperous_ - UserMO.getResource(ITEM_KIND_PROSPEROUS)
	--废墟下购买收益减半
	--回复进度
	local replyAll = nil
	local price = 50
	if UserMO.ruins and UserMO.ruins.isRuins then
		price = 25
		if UserMO.maxProsperous_ > 600 then
			replyAll = 600
			delta = 600 - UserMO.getResource(ITEM_KIND_PROSPEROUS)
		end
	end
	local take = math.ceil(delta / price) * (UserMO.querySystemId(25)/10000)
	local resData = UserMO.getResourceData(ITEM_KIND_COIN)

	local function doneBuyPros()
		Loading.getInstance():unshow()
		self:reloadData()
		--脱离废墟
		UserMO.ruins.isRuins = false
		UserBO.updateCycleTime(ITEM_KIND_PROSPEROUS)
		Notify.notify(LOCAL_GET_MAP_EVENT)
	end

	local function gotoBuy()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < take then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		Loading.getInstance():show()
		UserBO.asynBuyPros(doneBuyPros,replyAll)
	end
	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[428][replyAll and 2 or 1], take, resData.name), function() gotoBuy() end):push()
	else
		gotoBuy()
	end
end

-- 统率
function PlayerDetailTableView:onCommandCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if self.m_isUpCommand then return end

	if UserMO.getResource(ITEM_KIND_COMMAND) >= UserMO.queryMaxCommand() then
		Toast.show(CommonText[973])
		return
	end

	local nxtCommand = UserMO.queryCommandByLevel(UserMO.command_ + 1)
	if nxtCommand.commandLv > UserMO.level_ then  -- 等级不足
		Toast.show(CommonText[245])
		return
	end

	local function doneUpCommand(success)
		if success then
			ManagerSound.playSound("command_up")
			Toast.show(CommonText[374][1])  -- 统帅提升成功
		else
			Toast.show(CommonText[374][2]) -- 统帅提升失败
		end
		Loading.getInstance():unshow()
		self:reloadData()
		
		self.m_isUpCommand = false
	end

	-- 统率书
	local commandBook = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_COMMAND_BOOK)
	if commandBook < nxtCommand.book then
		local propCommand = PropMO.queryPropById(PROP_ID_COMMAND_BOOK)
		local coinData = UserMO.getResourceData(ITEM_KIND_COIN)

		local function gotoUpCommand()
			local coinCount = UserMO.getResource(ITEM_KIND_COIN)
			if coinCount < COMMAND_UP_TAKE_COIN then
				require("app.dialog.CoinTipDialog").new():push()
				return
			end

			self.m_isUpCommand = true

			Loading.getInstance():show()
			UserBO.asynUpCommand(doneUpCommand, true)
		end

		if UserMO.consumeConfirm then
			--拇指观看广告送统率书
			if ServiceBO.muzhiAdPlat() and MuzhiADMO.AddCommandADTime < MZAD_ADD_COMMAND_MAX then
				local ADConfirmDialog = require("app.dialog.ADConfirmDialog")
				ADConfirmDialog.new(string.format(CommonText[238], PropMO.getPropName(PROP_ID_COMMAND_BOOK), COMMAND_UP_TAKE_COIN * nxtCommand.book, coinData.name), function () gotoUpCommand() end, nil, 2):push()
			else
				-- 金币升级
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText[238], PropMO.getPropName(PROP_ID_COMMAND_BOOK), COMMAND_UP_TAKE_COIN * nxtCommand.book, coinData.name), function () gotoUpCommand() end):push()
			end
		else
			gotoUpCommand()
		end
	else
		self.m_isUpCommand = false

		Loading.getInstance():show()
		UserBO.asynUpCommand(doneUpCommand, false)
	end
end

-- 授勋
function PlayerDetailTableView:onMedalCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not UserMO.getUpFameByLevel(UserMO.fameLevel_) then
		Toast.show(CommonText[974])
		return
	end
	local MedalView = require("app.view.MedalView")
	local view = MedalView.new():push()
end

function PlayerDetailTableView:onUpdate(event)
	self:reloadData()
end

return PlayerDetailTableView
