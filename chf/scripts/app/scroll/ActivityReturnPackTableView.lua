--
-- Author: Your Name
-- Date: 2017-06-14 20:22:41
--
--老玩家回归大礼包

local ActivityReturnPackTableView = class("ActivityTableView", TableView)

function ActivityReturnPackTableView:ctor(size)
	ActivityReturnPackTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 190)
	self.m_backTime = PlayerBackMO.backTime_
	self.m_packInfo = PlayerBackMO.getBackPackByBackTime(self.m_backTime)
end

function ActivityReturnPackTableView:onEnter()
	ActivityReturnPackTableView.super.onEnter(self)
end

function ActivityReturnPackTableView:numberOfCells()
	if self.m_packInfo then return #self.m_packInfo
	else return 1 end
end

function ActivityReturnPackTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityReturnPackTableView:createCellAtIndex(cell, index)
	ActivityReturnPackTableView.super.createCellAtIndex(self, cell, index)
	local packInfo = PlayerBackMO.backPackage_
	local packAward = packInfo.status
	local signAward = self.m_packInfo[index]
	local awardDB = json.decode(signAward.awardlist)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)
	local title = ui.newTTFLabel({text = string.format(CommonText[671],tostring(index)), font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setAnchorPoint(cc.p(0, 0.5))

	-- 当前登录天数
	local loginDay = ui.newTTFLabel({text = CommonText[962], font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	loginDay:setAnchorPoint(cc.p(0, 0.5))
	local today = ui.newTTFLabel({text = packInfo.today, font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(cell):rightTo(loginDay)
	today:setAnchorPoint(cc.p(0, 0.5))

	for index=1,#awardDB do
		local itemView = UiUtil.createItemView(awardDB[index][1], awardDB[index][2], {count = awardDB[index][3]})
		itemView:setPosition(10 + (index - 0.5) * 105, 70)
		itemView:setScale(0.9)
		cell:addChild(itemView)

		UiUtil.createItemDetailButton(itemView, cell, true)

		local propDB = UserMO.getResourceData(awardDB[index][1], awardDB[index][2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 2, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end

	--签到领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png") 
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local getAwardBtn = CellMenuButton.new(normal, selected, disabled, handler(self,self.getAwardHandler))
	getAwardBtn:setLabel(CommonText[672][1])
	getAwardBtn.index = index
	getAwardBtn.status = packAward[index]
	getAwardBtn:setEnabled(packAward[index] == 0)
	cell:addButton(getAwardBtn, self.m_cellSize.width - 110, self.m_cellSize.height / 2 - 20)

	if packAward[index] == 1 then
		getAwardBtn:setEnabled(false)
		getAwardBtn:setLabel(CommonText[747])
	elseif packAward[index] == 2 then
		getAwardBtn:setEnabled(true)
		getAwardBtn:setLabel(CommonText[100025])
	end

	return cell
end

function ActivityReturnPackTableView:getAwardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = sender.index

	local function goAward()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < 10 then  -- 金币不足
			require("app.dialog.CoinTipDialog").new():push()
			return
		end
		PlayerBackBO.getBackAwards(function (data)
			Notify.notify(LOCAL_PLAYER_BACK_FILL_CHECK_EVENT)
		end, index)
	end

	if UserMO.consumeConfirm and sender.status == 2 then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[100016], 10, "金币"), function ()
			goAward()
		end):push()
	else
		goAward()
	end
end

function ActivityReturnPackTableView:onSignUpdate()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function ActivityReturnPackTableView:onExit()
	ActivityReturnPackTableView.super.onExit(self)

	if self.r_updateHandler then
		Notify.unregister(self.r_updateHandler)
		self.r_updateHandler = nil
	end
end

return ActivityReturnPackTableView