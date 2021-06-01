--
-- Author: gf
-- Date: 2015-09-03 17:22:44
--

local MyFriendTableView = class("MyFriendTableView", TableView)

function MyFriendTableView:ctor(size)
	MyFriendTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

end

function MyFriendTableView:onEnter()
	MyFriendTableView.super.onEnter(self)
	self.m_UpgradeHandler = Notify.register(LOCAL_FRIEND_UPDATE_EVENT, handler(self, self.onUpgradeUpdate))
end

function MyFriendTableView:numberOfCells()
	return #SocialityMO.myFriends_
end

function MyFriendTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MyFriendTableView:createCellAtIndex(cell, index)
	MyFriendTableView.super.createCellAtIndex(self, cell, index)

	local friend = SocialityMO.myFriends_[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, friend.man.icon):addTo(bg)
	itemView:setScale(0.65)
	itemView:setPosition(90,bg:getContentSize().height / 2)

	local name = ui.newTTFLabel({text = friend.man.nick, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local level = ui.newTTFLabel({text = "LV.".. friend.man.level, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + 10, y = 80, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	level:setAnchorPoint(cc.p(0, 0.5))

	--友好度
	--可以赠送道具的友好度
	local canGiveValue = UserMO.querySystemId(71) -- 可以赠送道具的友好度
	local canGiveTimes = UserMO.querySystemId(73) -- 好友之间每月赠送次数
	local canGiveLevel = UserMO.querySystemId(76) -- 赠送功能所需的等级限制
	local friendLiness = UiUtil.label(CommonText[1845]):addTo(cell):pos(self.m_cellSize.width / 2 - 110, self.m_cellSize.height / 2 - 30)
	friendLiness:setVisible(friend.state == 1)
	local linessValue = UiUtil.label(friend.friendliness,nil,COLOR[11]):rightTo(friendLiness)
	-- linessValue:setPosition(self.m_cellSize.width / 2 - 10, self.m_cellSize.height / 2 - 40)
	linessValue:setVisible(friend.state == 1)

	--赠送道具按钮
	local selected= display.newSprite(IMAGE_COMMON .. "frendgive_normal.png")
	local normal = display.newSprite(IMAGE_COMMON .. "frendgive_selected.png")
	local giveBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.giveFriend))
	giveBtn.friend = friend
	giveBtn.giveTimes = canGiveTimes
	giveBtn.canGiveLevel = canGiveLevel
	giveBtn.canGiveValue = canGiveValue
	giveBtn.ownValue = friend.friendliness
	giveBtn:setVisible(friend.state == 1)
	cell:addButton(giveBtn, self.m_cellSize.width - 300, self.m_cellSize.height / 2 - 10)

	local giveTimes = UiUtil.label(friend.giveCount.."/"..canGiveTimes, nil, COLOR[2]):alignTo(giveBtn, -40, 1)
	giveTimes:setVisible(friend.state == 1)

	--赠送红包按钮
	local selected = display.newSprite(IMAGE_COMMON .. "btn_redpacket_normal.png")
	local normal = display.newSprite(IMAGE_COMMON .. "btn_redpacket_selected.png")
	local redBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.redHandler))
	redBtn:setLabel(CommonText[1788][1])
	redBtn.friend = friend
	redBtn.index = index
	cell:addButton(redBtn, self.m_cellSize.width - 210, self.m_cellSize.height / 2 - 10)

	--祝福
	local selected= display.newSprite(IMAGE_COMMON .. "btn_bless_normal.png")
	local normal = display.newSprite(IMAGE_COMMON .. "btn_bless_selected.png")
	local blessBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.blessFriend))
	blessBtn:setLabel(CommonText[538][1])
	blessBtn.lordId = friend.man.lordId
	blessBtn.lv = friend.man.level
	blessBtn:setVisible(friend.bless == 0)
	cell:addButton(blessBtn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 10)

	local blessLab = ui.newTTFLabel({text = CommonText[538][4], font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 100, y = self.m_cellSize.height / 2 - 10, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))
	blessLab:setVisible(friend.bless == 1)

	return cell
end


function MyFriendTableView:openDetail(man)
	gdump(man,"MyFriendTableView:openDetail..man")
	local player = {icon = man.icon, nick = man.nick, level = man.level, lordId = man.lordId, rank = man.ranks,
        fight = man.fight, sex = man.sex, party = man.partyName, pros = man.pros, prosMax = man.prosMax}
    require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_FRIEND, player):push()
end

function MyFriendTableView:blessFriend(tag, sender)
	local value = PropMO.getAddValueByRedId(1)
	Loading.getInstance():show()
	SocialityBO.asynGiveBless(function()
		Loading.getInstance():unshow()
		local isfull = SocialityMO.isFriendLessMax(sender.lordId)
		local isFriend = SocialityBO.isOtherFriend(sender.lordId)
		if isfull or (not isFriend) then
			Toast.show(CommonText[10028])
		else
			Toast.show(string.format(CommonText[1849][1], value))
		end
	end,sender.lordId)
	SocialityBO.getFriend()
end

function MyFriendTableView:giveFriend(tag, sender)
	ManagerSound.playNormalButtonSound()
	local times = sender.giveTimes

	--友好度不足
	if sender.canGiveValue > sender.ownValue then
		Toast.show(string.format(CommonText[1874], sender.canGiveValue))
		return
	end
	
	--等级不足
	if sender.canGiveLevel > UserMO.level_ then
		Toast.show(string.format(CommonText[1873], sender.canGiveLevel))
		return
	end

	--好友等级不足
	if sender.canGiveLevel > sender.friend.man.level then
		Toast.show(string.format(CommonText[1879], sender.canGiveLevel))
		return
	end

	--本月的赠送次数已满
	if SocialityMO.myfriendGiveMax >= UserMO.querySystemId(74) then
		Toast.show(CommonText[1877])
		return
	end

	--次数已满
	if sender.friend.giveCount >= times then
		Toast.show(CommonText[1847])
		return
	end

	require("app.dialog.FriendGiveDialog").new(function ()
		SocialityBO.getFriend()
	end, sender.friend):push()
end

function MyFriendTableView:cellTouched(cell, index)
    gprint(index,"MyFriendTableView:cellTouched..index")
	local friend = SocialityMO.myFriends_[index].man
	self:openDetail(friend)
end

function MyFriendTableView:onUpgradeUpdate()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function MyFriendTableView:redHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local data = UserMO.getAllRedPes()
	if #data <= 0 then
		Toast.show(CommonText[1820])
		return
	end
	local worldPoint = sender:getParent():convertToWorldSpace(cc.p(sender:getPositionX(), sender:getPositionY()))
	require("app.dialog.RedPesDialog").new(worldPoint,sender.friend.man, sender.index):push()
end

function MyFriendTableView:onExit()
	MyFriendTableView.super.onExit(self)
	
	if self.m_UpgradeHandler then
		Notify.unregister(self.m_UpgradeHandler)
		self.m_UpgradeHandler = nil
	end
end



return MyFriendTableView