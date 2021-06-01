--
-- Author: gf
-- Date: 2015-09-03 18:39:57
--

local MyBlessTableView = class("MyBlessTableView", TableView)

function MyBlessTableView:ctor(size)
	MyBlessTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

function MyBlessTableView:onEnter()
	MyBlessTableView.super.onEnter(self)
	self.m_UpgradeHandler = Notify.register(LOCAL_BLESS_GET_EVENT, handler(self, self.onUpgradeUpdate))
end

function MyBlessTableView:numberOfCells()
	return #SocialityMO.myBless_
end

function MyBlessTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MyBlessTableView:createCellAtIndex(cell, index)
	MyBlessTableView.super.createCellAtIndex(self, cell, index)

	local friend = SocialityMO.myBless_[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, friend.man.icon):addTo(bg)
	itemView:setScale(0.65)
	itemView:setPosition(90,bg:getContentSize().height / 2)

	local name = ui.newTTFLabel({text = friend.man.nick, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local level = ui.newTTFLabel({text = "LV.".. friend.man.level, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = 60, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	level:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local blessBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.getBless))
	blessBtn:setLabel(CommonText[538][2])
	blessBtn.lordId = friend.man.lordId
	blessBtn:setVisible(friend.state == 0)
	cell:addButton(blessBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 10)

	local blessLab = ui.newTTFLabel({text = CommonText[747], font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120, y = self.m_cellSize.height / 2 - 10, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))
	blessLab:setVisible(friend.state == 1)

	return cell
end


-- function MyBlessTableView:cellTouched(cell, index)
--     gprint(index,"MyFriendTableView:cellTouched..index")
-- 	local friend = SocialityMO.myFriends_[index].man
-- 	self:openDetail(friend)
-- end

function MyBlessTableView:getBless(tag, sender)
	local function getBless()
		Loading.getInstance():show()
		SocialityBO.asynAcceptBless(function()
			Loading.getInstance():unshow()
			end,sender.lordId)
	end
	if UserMO.power_ >= POWER_MAX_HAVE then
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		local t = ConfirmDialog.new(string.format(CommonText[20008],POWER_MAX_HAVE,0),function()
					getBless()
				end):push()
		t.m_cancelBtn:setLabel(CommonText[20009])
	else
		getBless()
	end
end

-- function MyBlessTableView:openDetail(man)
-- 	gdump(man,"MyFriendTableView:openDetail..man")
-- 	local player = {icon = man.icon, nick = man.nick, level = man.level, lordId = man.lordId, rank = man.ranks,
--         fight = man.fight, sex = man.sex, party = man.partyName, pros = man.pros, prosMax = man.prosMax}
--     require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_FRIEND, player):push()
-- end


-- function MyBlessTableView:cellTouched(cell, index)
--     gprint(index,"MyFriendTableView:cellTouched..index")
-- 	local friend = SocialityMO.myBless_[index].man
-- 	self:openDetail(friend)
-- end


function MyBlessTableView:onUpgradeUpdate()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function MyBlessTableView:onExit()
	MyBlessTableView.super.onExit(self)
	
	if self.m_UpgradeHandler then
		Notify.unregister(self.m_UpgradeHandler)
		self.m_UpgradeHandler = nil
	end
end

return MyBlessTableView