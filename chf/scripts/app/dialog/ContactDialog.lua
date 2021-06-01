
CONTACT_MODE_SINGLE = 1 -- 只能选择一个联系人
CONTACT_MODE_MULTIPLE = 2 -- 可以选择多个人

------------------------------------------------------------------------------
-- 联系人TableView
------------------------------------------------------------------------------

local ContactTableView = class("ContactTableView", TableView)

function ContactTableView:ctor(size, page, list, mode)
	ContactTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)
	self.m_page = page
	self.m_curChoseIndex = 0
	self.m_list = list
	self.m_mode = mode
	gdump(self.m_list, "ContactTableView")
end

function ContactTableView:numberOfCells()
	return #self.m_list
end

function ContactTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContactTableView:createCellAtIndex(cell, index)
	ContactTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local contact = self.m_list[index]

	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, contact.portrait):addTo(cell)
	itemView:setScale(0.5)
	itemView:setPosition(80, self.m_cellSize.height / 2)

	-- 名称
	local label = ui.newTTFLabel({text = contact.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		self:dispatchEvent({name = "CHOSEN_MEMBER_EVENT", page = self.m_page, lordId = sender.contact.lordId, isChecked = isChecked})

		if isChecked and self.m_mode == CONTACT_MODE_SINGLE then  -- 一次只能选中一个
			for idx = 1, self:numberOfCells() do
				if idx ~= index then
					local cell = self:cellAtIndex(idx)
					if cell then
						cell.checkBox:setChecked(false)
					end
					self.m_list[idx].checked = false
				end
			end
		end
	end

	local checkBox = CellCheckBox.new(nil, nil, onCheckedChanged)
	checkBox:setChecked(contact.checked)
	checkBox.contact = contact
	cell:addButton(checkBox, self.m_cellSize.width - 60, self.m_cellSize.height / 2 - 20)
	cell.checkBox = checkBox

	return cell
end

------------------------------------------------------------------------------
-- 联系人弹出框
------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local ContactDialog = class("ContactDialog", Dialog)

--indexOnly 军事福利分配功能增加字段，用于只能选择相应index的tab
function ContactDialog:ctor(mode, contaceCallback, indexOnly, ifSelf)
	ContactDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_LEFT_TO_RIGHT, {scale9Size = cc.size(588, 860)})

	mode = mode or CONTACT_MODE_MULTIPLE
	self.m_mode = mode
	self.m_contaceCallback = contaceCallback
	self.indexOnly = indexOnly
	self.ifSelf = ifSelf
end

function ContactDialog:onEnter()
	ContactDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[451]) -- 选择联系人

	self.m_dialogData = {}

	self:showUI()
end

function ContactDialog:showUI()
    local tag = display.newSprite(IMAGE_COMMON .. "info_bg_66.png"):addTo(self:getBg())
    tag:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 92)

    local size = cc.size(tag:getContentSize().width, 660)
    local pages = {CommonText[452][1], CommonText[452][2], CommonText[452][3], CommonText[452][4]}

    local function createYesBtnCallback(index)
        local button = nil
        if index == 1 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
            local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
            button = MenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 - 192, size.height + 30)
        elseif index == 2 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
            local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
            button = MenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 - 73, size.height + 30)
        elseif index == 3 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
            normal:setFlipX(true)
            local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
            selected:setFlipX(true)
            button = MenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 + 73, size.height + 30)
        elseif index == 4 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
            normal:setFlipX(true)
            local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
            selected:setFlipX(true)
            button = MenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 + 192, size.height + 30)
        end
		button:setLabel(pages[index])
		if index == 2 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() + 10)
		elseif index == 3 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() - 10)
		end
		return button
    end

    local function createNoBtnCallback(index)
        local button = nil
        if index == 1 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
            local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
            button = MenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 - 192, size.height + 30)
        elseif index == 2 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
            local selected = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
            button = MenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 - 73, size.height + 30)
        elseif index == 3 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
            normal:setFlipX(true)
            local selected = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
            selected:setFlipX(true)
            button = MenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 + 73, size.height + 30)
        elseif index == 4 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
            normal:setFlipX(true)
            local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
            selected:setFlipX(true)
            button = MenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 + 192, size.height + 30)
        end
		button:setLabel(pages[index], {color = COLOR[11]})
		if index == 2 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() + 10)
		elseif index == 3 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() - 10)
		end
        return button
    end

    local function clickDelegate(container, index)
    	if self.indexOnly and self.indexOnly ~= index then
			self.m_pageView:setPageIndex(self.indexOnly)
			return 
		end
    end

    local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = self:getBg():getContentSize().width / 2, y = size.height / 2 + 80,
        createDelegate = handler(self, self.createDelegate), clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}, hideDelete = true}):addTo(self:getBg(), 2)
    pageView:setPageIndex(1)
    self.m_pageView = pageView

    -- 选择
    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local btn = MenuButton.new(normal, selected, nil, handler(self, self.onChosenCallback)):addTo(self:getBg())
    btn:setPosition(self:getBg():getContentSize().width / 2, 25)
    btn:setLabel(CommonText[453])
end

function ContactDialog:onChosenCallback(tag, sender)
	if self.m_contaceCallback then
		local members = {}

		for pageIndex, data in pairs(self.m_dialogData) do  -- 其他的全部设置为false
			if data.members_ then
				for index = 1, #data.members_ do
					if data.members_[index].checked then
						members[data.members_[index].lordId] = data.members_[index]
					end
				end
			end
		end
		members = table.values(members)
		
		self.m_contaceCallback(members)
	end
	self:pop()
end

function ContactDialog:createDelegate(container, index)
	if not self.m_dialogData[index] then self.m_dialogData[index] = {} end

	if self.indexOnly and self.indexOnly ~= index then
		self.m_pageView:setPageIndex(self.indexOnly)
		return 
	end

    if index == 1 then self:showParty(container, index)
	elseif index == 2 then self:showRecent(container, index)
	elseif index == 3 then self:showStore(container, index)
	elseif index == 4 then self:showFriend(container, index)
    end

    local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container, 2)
    line:setPreferredSize(cc.size(container:getContentSize().width - 6, line:getContentSize().height))
    line:setPosition(container:getContentSize().width / 2, 75)

    if self.m_mode == CONTACT_MODE_MULTIPLE then
    	local label = ui.newTTFLabel({text = CommonText[141], font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width - 110, y = 20, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
    	label:setAnchorPoint(cc.p(1, 0.5))
	    -- 全选
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onCheckedChanged)):addTo(container)
		checkBox:setPosition(container:getContentSize().width - 70, checkBox:getContentSize().height / 2)
		checkBox.container = container
		checkBox.page = index

		if self.m_dialogData and self.m_dialogData[index] and self.m_dialogData[index].allChecked then
			checkBox:setChecked(self.m_dialogData[index].allChecked)
		end
	end
end

function ContactDialog:showParty(container, index)
	local function showList()
		Loading.getInstance():unshow()

		if not self.m_dialogData[index].members_ then
			-- gdump(PartyMO.partyData_.partyMember, "ContactDialog:showParty")

			local list = {}
			for index = 1, #PartyMO.partyData_.partyMember do
				local member = PartyMO.partyData_.partyMember[index]
				if self.indexOnly then
					list[#list + 1] = {lordId = member.lordId, name = member.nick, level = member.level, portrait = member.icon, checked = false}
				else
					if member.lordId ~= UserMO.lordId_ then
						list[#list + 1] = {lordId = member.lordId, name = member.nick, level = member.level, portrait = member.icon, checked = false}
					end
				end
				
			end
			--把自己放在最前面
			if self.ifSelf then
				table.insert(list,1,{lordId = UserMO.lordId_, name = UserMO.nickName_, level = UserMO.level_, portrait = UserMO.portrait_, checked = false})
			end
			self.m_dialogData[index].members_ = list
		end

	    local view = ContactTableView.new(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 70), index, self.m_dialogData[index].members_, self.m_mode):addTo(container)
	    view:addEventListener("CHOSEN_MEMBER_EVENT", handler(self, self.choseMemeber))
	    view:setPosition(10, 70)
	    view:reloadData()
	    container.tableView = view
	end

	if PartyBO.getMyParty() then -- 如果有军团才显示列表
		if table.isexist(PartyMO.partyData_, "partyMember") and PartyMO.partyData_.partyMember then
			showList()
		else  -- 没有拉取过成员列表
			Loading.getInstance():show()
			PartyBO.asynGetPartyMember(showList, 1)
		end
	end
end

function ContactDialog:showRecent(container, index)
	local function showList()
		if not self.m_dialogData[index].members_ then
			local list = {}
			for index = 1, #ChatMO.recent_ do
				local recent = ChatMO.recent_[index]
				if recent and recent[1] ~= UserMO.lordId_ then
					list[#list + 1] = {lordId = recent[1], name = recent[2], level = recent[4], portrait = recent[3], checked = false}
				end
			end
			self.m_dialogData[index].members_ = list
		end

	    local view = ContactTableView.new(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 70), index, self.m_dialogData[index].members_, self.m_mode):addTo(container)
	    view:addEventListener("CHOSEN_MEMBER_EVENT", handler(self, self.choseMemeber))
	    view:setPosition(10, 70)
	    view:reloadData()
	    container.tableView = view
	end

	showList()
end

function ContactDialog:showStore(container, index)
	local function showList()
		Loading.getInstance():unshow()

		if not self.m_dialogData[index].members_ then
			local list = {}
			for index = 1, #SocialityMO.myStore_ do
				local member = SocialityMO.myStore_[index]
				if member.man and member.man.lordId > 0 and member.man.lordId ~= UserMO.lordId_ then
					list[#list + 1] = {lordId = member.man.lordId, name = member.man.nick, level = member.man.level, portrait = member.man.icon, checked = false}
				end
			end
			self.m_dialogData[index].members_ = list
		end

	    local view = ContactTableView.new(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 70), index, self.m_dialogData[index].members_, self.m_mode):addTo(container)
	    view:addEventListener("CHOSEN_MEMBER_EVENT", handler(self, self.choseMemeber))
	    view:setPosition(10, 70)
	    view:reloadData()
	    container.tableView = view
	end

	-- if not self.m_dialogData[index].members_ then
	-- 	Loading.getInstance():show()
	-- 	SocialityBO.asynGetStore(showList)
	-- else
	-- 	showList()
	-- end
	showList()
end

function ContactDialog:showFriend(container, index)
	local function showList()
		Loading.getInstance():unshow()

		if not self.m_dialogData[index].members_ then
			local list = {}
			for index = 1, #SocialityMO.myFriends_ do
				local friend = SocialityMO.myFriends_[index]
				list[#list + 1] = {lordId = friend.man.lordId, name = friend.man.nick, level = friend.man.level, portrait = friend.man.icon, checked = false}
			end
			self.m_dialogData[index].members_ = list
		end

	    local view = ContactTableView.new(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 70), index, self.m_dialogData[index].members_, self.m_mode):addTo(container)
	    view:addEventListener("CHOSEN_MEMBER_EVENT", handler(self, self.choseMemeber))
	    view:setPosition(10, 70)
	    view:reloadData()
	    container.tableView = view
	end

	if not self.m_dialogData[index].members_ then
		Loading.getInstance():show()
		SocialityBO.getFriend(showList)
	else
		showList()
	end
end

function ContactDialog:onCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()

	local page = sender.page
	if isChecked then
		if self.m_dialogData[page] and self.m_dialogData[page].members_ then
			for index = 1, #self.m_dialogData[page].members_ do
				self.m_dialogData[page].members_[index].checked = true
			end
		end

		if sender.container and sender.container.tableView then
			sender.container.tableView:reloadData()
		end
	end

	if self.m_dialogData[page] then
		self.m_dialogData[page].allChecked = isChecked
	end
end

function ContactDialog:choseMemeber(event)
	local page = event.page
	local lordId = event.lordId
	local isChecked = event.isChecked

	-- gprint("page:", page, "lordId:", lordId, "isChecked:", isChecked)

	local function find(list, lordId)
		for index = 1, #list do
			if list[index].lordId == lordId then return list[index] end
		end
	end

	local members = self.m_dialogData[page].members_
	local member = find(members, lordId)
	if member then
		member.checked = isChecked
	end
	-- gdump(member)

	if self.m_mode == CONTACT_MODE_SINGLE then  -- 一次只能选中一个
		for pageIndex, data in pairs(self.m_dialogData) do  -- 其他的全部设置为false
			if data.members_ and pageIndex ~= page then
				for index = 1, #data.members_ do
					data.members_[index].checked = false
				end
			end
		end
	end
end

return ContactDialog

