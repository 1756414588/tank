--
-- Author: gf
-- Date: 2015-09-21 14:04:31
-- 签到tableview


local SignTableView = class("SignTableView", TableView)



function SignTableView:ctor(size)
	SignTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 200)
end

function SignTableView:onEnter()
	SignTableView.super.onEnter(self)
	self.signStatus = false
	
	
	self.m_updateHandler = Notify.register(LOCAL_SIGN_UPDATE_EVENT, handler(self, self.onSignUpdate))
end

function SignTableView:numberOfCells()
	return #SignMO.getSignData()
end

function SignTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SignTableView:createCellAtIndex(cell, index)
	SignTableView.super.createCellAtIndex(self, cell, index)

	local signAward = SignMO.getSignData()[index]


	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(585, 190))
	bg:setCapInsets(cc.rect(130, 40, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	titBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - titBg:getContentSize().height / 2)

	local titLab = ui.newTTFLabel({text = string.format(CommonText[671],signAward.signId), font = G_FONT, size = FONT_SIZE_SMALL, 
	x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	local awardDB = json.decode(signAward.awardList)
	-- gdump(awardDB,"awardDBawardDBawardDB")
	for index=1,#awardDB do
		local itemView = UiUtil.createItemView(awardDB[index][1], awardDB[index][2], {count = awardDB[index][3]})
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 100,bg:getContentSize().height - 90)
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
	getAwardBtn:setVisible(SignMO.signData_.signs[signAward.signId] == 0)
	getAwardBtn:setEnabled(signAward.signId <= SignMO.signData_.logins)
	getAwardBtn.signAward = signAward
	cell:addButton(getAwardBtn, self.m_cellSize.width - 110, self.m_cellSize.height / 2)
	
	--已领取文字
	local hasGetLab = ui.newTTFLabel({text = CommonText[672][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = getAwardBtn:getPositionX(), y = getAwardBtn:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	hasGetLab:setVisible(SignMO.signData_.signs[signAward.signId] == 1)

	return cell
end

function SignTableView:getAwardHandler(tag, sender)
	if self.signStatus == true then return end
	self.signStatus = true
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	SignBO.asynSign(function()
		Loading.getInstance():unshow()
		end,sender.signAward)
end

function SignTableView:onSignUpdate()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
	self.signStatus = false
end


function SignTableView:onExit()
	SignTableView.super.onExit(self)
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end



return SignTableView