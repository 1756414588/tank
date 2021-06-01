--
-- Author: Gss
-- Date: 2019-02-18 10:36:49
--
-- 好友赠送道具界面

local FriendGiveTableView = class("FriendGiveTableView", TableView)

function FriendGiveTableView:ctor(size, friendData)
	FriendGiveTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_data = {}
	self.m_friendData = friendData
end

function FriendGiveTableView:numberOfCells()
	return #self.m_data
end

function FriendGiveTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function FriendGiveTableView:createCellAtIndex(cell, index)
	FriendGiveTableView.super.createCellAtIndex(self, cell, index)
	local item = self.m_data[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 30, 140))
	bg:setPosition(self.m_cellSize.width / 2 + 14, self.m_cellSize.height / 2)

	local record = json.decode(item.prop)
	local view = UiUtil.createItemView(record[1], record[2]):addTo(cell):pos(125, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(view, cell, true)
	local pb = UserMO.getResourceData(record[1], record[2])
	-- 名称
	local name = ui.newTTFLabel({text = pb.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 190, y = 114, color = COLOR[pb.quality]}):addTo(cell)

	--描述(友好度达到XX可赠送)
	local desc = UiUtil.label(CommonText[1881][1]):addTo(cell)
	desc:setPosition(self.m_cellSize.width / 2, 40)
	local value = UiUtil.label(item.friend,nil,COLOR[2]):rightTo(desc)
	local lab = UiUtil.label(CommonText[1881][2]):rightTo(value)


	-- 拥有
	local own = UserMO.getResource(record[1], record[2])
	local has = UiUtil.label(CommonText[507][1]):addTo(cell)
	has:setPosition(self.m_cellSize.width - 130, 114)
	local num = UiUtil.label(own,nil,COLOR[2]):rightTo(has)
	num:setColor(own > 0 and COLOR[2] or COLOR[6])

	local checkBox = CellCheckBox.new(nil, nil, handler(self, self.onCheckedChanged))
	checkBox.cellIndex = index
	checkBox:setAnchorPoint(cc.p(0, 0.5))
	cell:addButton(checkBox, self.m_cellSize.width - 90, self.m_cellSize.height / 2 - 22)
	cell.checkBox = checkBox
	checkBox:setVisible(false)

	if self.m_friendData.friendliness >= item.friend then
		checkBox:setVisible(true)
		desc:setVisible(false)
		value:setVisible(false)
		lab:setVisible(false)
	end

	return cell
end

function FriendGiveTableView:onCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()

	local prop
	if isChecked then  -- 一次只能选中一个
		for idx = 1, self:numberOfCells() do
			if idx ~= sender.cellIndex then
				local cell = self:cellAtIndex(idx)
				if cell then
					cell.checkBox:setChecked(false)
				end
			else
				prop = self.m_data[idx].prop
			end
		end
	end

	self:dispatchEvent({name = "CHECK_FRIENDGIFT_EVENT", prop = prop})
end

function FriendGiveTableView:updateUI(list)
	self.m_data = list
	self:reloadData()
end


--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local FriendGiveDialog = class("FriendGiveDialog", Dialog)

--viewFor 备用字段。以后可能做扩展
function FriendGiveDialog:ctor(callback, friend, viewFor)
	FriendGiveDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(580, 730)})
	self.m_viewFor = viewFor or 1
	self.m_callback = callback
	self.m_param = nil
	self.m_friend = friend
end

function FriendGiveDialog:onEnter()
	FriendGiveDialog.super.onEnter(self)
	self:setTitle(CommonText[458][1])  -- 赠送
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(self:getBg():getContentSize().width - 30, self:getBg():getContentSize().height - 40))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local btnBg = display.newScale9Sprite(IMAGE_COMMON .. "friend_title_bg.png"):addTo(self:getBg())
	btnBg:setPosition(self:getBg():width() / 2, self:getBg():height() - 89)
	
	--tableBtn
	self.btn1 = UiUtil.button("btn_friend_1normal.png", "btn_friend_1selected.png", nil, handler(self, self.showIndex))
   		:addTo(btnBg,0,1):pos(147 / 2,btnBg:getContentSize().height / 2)
  	self.btn1:selected()
  	self.btn1:selectDisabled()
  	local texe1 = UiUtil.label(CommonText[1880][1],18):addTo(self.btn1):center()

  	self.btn2 = UiUtil.button("btn_friend_2normal.png", "btn_friend_2selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,2):rightTo(self.btn1,-25)
  	self.btn2:unselected()
  	self.btn2:selectDisabled()
  	local texe2 = UiUtil.label(CommonText[1880][2],18):addTo(self.btn2):center()

  	self.btn3 = UiUtil.button("btn_friend_2normal.png", "btn_friend_2selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,3):rightTo(self.btn2,150)
  	self.btn3:setScaleX(-1)
  	self.btn3:unselected()
  	self.btn3:selectDisabled()
  	local texe3 = UiUtil.label(CommonText[1880][3],18):addTo(self.btn3):center()
  	texe3:setScaleX(-1)	

  	self.btn4 = UiUtil.button("btn_friend_3normal.png", "btn_friend_3selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,4):rightTo(self.btn3,-175)
  	-- self.btn4:setScaleX(-1)
  	self.btn4:unselected()
  	self.btn4:selectDisabled()
  	local texe4 = UiUtil.label(CommonText[1880][4],18):addTo(self.btn4):center()
  	-- texe4:setScaleX(-1)	


	local function onCheckFriendGift(event)
		self.m_param = json.decode(event.prop)
	end
	local view = FriendGiveTableView.new(cc.size(btm:getContentSize().width, btm:getContentSize().height - 210), self.m_friend):addTo(self:getBg())
	view:addEventListener("CHECK_FRIENDGIFT_EVENT", onCheckFriendGift)
	view:setPosition(0, 130)
	self.m_view = view

	--赠送
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	giveBtn = MenuButton.new(normal, selected, nil, handler(self,self.omGiveCallback)):addTo(self:getBg())
	giveBtn:setPosition(self:getBg():getContentSize().width / 2,75)
	giveBtn:setLabel(CommonText[1])

	self:showIndex(self.m_viewFor)
end

function FriendGiveDialog:showIndex(tag,sender)
	for i=1,4 do
		if i == tag then
			self["btn"..i]:selected()
		else
			self["btn"..i]:unselected()
		end
	end

	if self.m_param then
		self.m_param = nil
	end

	local data = SocialityMO.getGiftByKind(tag)
	self.page_data = data
	self.m_view:updateUI(data)
end

function FriendGiveDialog:omGiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local canGiveTimes = UserMO.querySystemId(73)

	if not self.m_param then
		Toast.show(CommonText[1878])
		return
	end

	local own = UserMO.getResource(self.m_param[1], self.m_param[2])
	if own < self.m_param[3] then
		Toast.show(CommonText[1754])
		return
	end

	if self.m_friend.giveCount >= canGiveTimes then
		Toast.show(CommonText[1847])
		return
	end

	SocialityBO.giveFriendGift(function ()
		Toast.show(CommonText[1819])
		if self.m_callback then self.m_callback() end
		self.m_friend.giveCount = self.m_friend.giveCount + 1
		local offset = self.m_view:getContentOffset()
		self.m_view:reloadData()
		self.m_view:setContentOffset(offset)
		self.m_param = nil
	end,self.m_param, self.m_friend.man.lordId)
end

function FriendGiveDialog:onExit()
	FriendGiveDialog.super.onExit(self)
end

return FriendGiveDialog