
local Config = {
{text = CommonText[354][1], view = "chat_1.jpg"},
{text = CommonText[354][2], view = "chat_2.jpg"},
{text = CommonText[354][3], view = "chat_3.jpg"},
}

------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------

local ChatSearchTableView = class("ChatSearchTableView", TableView)

function ChatSearchTableView:ctor(size, viewFor)
	ChatSearchTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	local chats = ChatMO.getByType(CHAT_TYPE_PRIVACY)

	self.m_privacyNames = {}
	for name, cs in pairs(chats) do
		if #cs > 0 then
			self.m_privacyNames[#self.m_privacyNames + 1] = name
		end
	end

	self.m_worldChat = 1

	if PartyBO.getMyParty() then self.m_partyHolder = 1
	else self.m_partyHolder = 0 end
	-- gdump(self.m_privacyNames, "ChatSearchTableView privacy names")

	self.m_callCenter = 0
end

function ChatSearchTableView:reloadData()
	local chats = ChatMO.getByType(CHAT_TYPE_PRIVACY)

	self.m_privacyNames = {}
	for name, cs in pairs(chats) do
		if #cs > 0 then
			self.m_privacyNames[#self.m_privacyNames + 1] = name
		end
	end

	self.m_worldChat = 1

	if PartyBO.getMyParty() then self.m_partyHolder = 1
	else self.m_partyHolder = 0 end
	-- gdump(self.m_privacyNames, "ChatSearchTableView privacy names")

	self.m_callCenter = 0

	ChatSearchTableView.super.reloadData(self)
end

function ChatSearchTableView:numberOfCells()
	return self.m_worldChat + self.m_partyHolder + self.m_callCenter + #self.m_privacyNames
end

function ChatSearchTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ChatSearchTableView:createCellAtIndex(cell, index)
	ChatSearchTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local node = display.newClippingRegionNode(cc.rect(0, 0, 420, 40)):addTo(cell)
	node:setPosition(170, 30)
	self.m_contentNode = node

	local function showConfig(configIndex)
		local config = Config[configIndex]
		local view = display.newSprite("image/item/" .. config.view):addTo(cell)
		view:setPosition(100, self.m_cellSize.height / 2)

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(view, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)

		-- 名称
		local name = ui.newTTFLabel({text = config.text, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
		cell.configIndex = configIndex

		local chatType = 0
		if configIndex == 1 then chatType = CHAT_TYPE_WORLD
		elseif configIndex == 2 then chatType = CHAT_TYPE_PARTY
		elseif configIndex == 2 then chatType = CHAT_TYPE_CALLCENTER end

		local typeChats = ChatMO.getByType(chatType)
		if typeChats and #typeChats > 0 then
			local chat = typeChats[#typeChats]
			local name = ""
			if (chat.isGm and chat.style and chat.style > 0) or (chat.sysId and chat.sysId > 0) then -- 系统
				name = CommonText[548][4]
			else
				name = chat.name
			end

			local name = ui.newTTFLabel({text = name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 80, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(cell)
			name:setAnchorPoint(cc.p(0, 0.5))

			-- 显示最后一条聊天记录
			local stringDatas = ChatBO.formatChat(chat)
			local msg = RichLabel.new(stringDatas):addTo(self.m_contentNode)
			msg:setPosition(0, 40)
			msg:setTouchEnabled(false)
		end

		local num = ChatBO.getTypeUnreadChatNum(chatType)
		if num > 0 then
			UiUtil.showTip(cell, num, self.m_cellSize.width - 30, self.m_cellSize.height - 30, 5)
		else
			UiUtil.unshowTip(cell)
		end
	end

	local function showChat(chatIndex)
		local name = self.m_privacyNames[chatIndex]

		local typeChats = ChatMO.getByType(CHAT_TYPE_PRIVACY)
		local chats = typeChats[name]

		local chat = chats[#chats]

		-- 注：私聊中目前没有获得对方头像的信息，所以目前只能暂时以最后一条chat为依据
		local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, chat.portrait):addTo(cell)
		itemView:setScale(0.55)
		itemView:setPosition(100, self.m_cellSize.height / 2)

		local nameView = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
		cell.name = name
		cell.chatPersonIndex = chatIndex  -- 是私聊

		-- 显示最后一条聊天记录
		local stringDatas = {}
		stringDatas[1] = {["content"] = chat.msg}
		local msg = RichLabel.new(stringDatas):addTo(self.m_contentNode)
		msg:setPosition(0, 40)

		local num = ChatBO.getTypeUnreadChatNum(CHAT_TYPE_PRIVACY, name)
		if num > 0 then
			UiUtil.showTip(cell, num, self.m_cellSize.width - 30, self.m_cellSize.height - 30, 5)
		else
			UiUtil.unshowTip(cell)
		end
	end

	if index == 1 then  -- 世界
		showConfig(1)
	elseif index == 2 then -- 判断军团
		if self.m_partyHolder > 0 then  -- 有军团
			showConfig(2)
		else
			if self.m_callCenter > 0 then -- 有客服
				showConfig(3)
			else
				showChat(1)
			end
		end
	elseif index == 3 then
		if self.m_partyHolder > 0 then  -- 有军团
			if self.m_callCenter > 0 then -- 有客服
				showConfig(3)
			else
				showChat(1)
			end
		else
			if self.m_callCenter > 0 then -- 有客服
				showChat(1)
			else
				showChat(2)
			end
		end
	else
		local chatIndex = index - (self.m_worldChat + self.m_partyHolder + self.m_callCenter)
		showChat(chatIndex)
	end

	return cell
end

function ChatSearchTableView:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()

	if cell.configIndex and cell.configIndex > 0 then
		local chatType = 0
		if cell.configIndex == 1 then chatType = CHAT_TYPE_WORLD
		elseif cell.configIndex == 2 then chatType = CHAT_TYPE_PARTY
		elseif cell.configIndex == 2 then chatType = CHAT_TYPE_CALLCENTER end

		local ChatView = require("app.view.ChatView")
		ChatView.new(chatType):push()
	elseif cell.chatPersonIndex and cell.chatPersonIndex > 0 then
		local function doneCallback(man)
			Loading.getInstance():unshow()
			if man then -- 搜索到了
				UiDirector.pop(function()
						ChatMO.curPrivacyLordId_ = man.lordId
						local ChatView = require("app.view.ChatView")
						ChatView.new(CHAT_TYPE_PRIVACY):push()
					end)
			else
				-- 角色不存在或不在线
				Toast.show(CommonText[355][3])
			end
		end

		Loading.getInstance():show()
		ChatBO.asynSearchOl(doneCallback, cell.name)
	end

	ChatMO.showChat_ = true
end

------------------------------------------------------------------------------
-- 聊天分类view
------------------------------------------------------------------------------

local ChatSearchView = class("ChatSearchView", UiNode)

-- 如果是野外，则需要传递位置
function ChatSearchView:ctor()
	ChatSearchView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function ChatSearchView:onEnter()
	ChatSearchView.super.onEnter(self)

	self:setTitle(CommonText[356])  -- 聊天

	ChatMO.showChat_ = false

	self.m_readChatHandler = Notify.register(LOCAL_READ_CHAT_EVENT, handler(self, self.onChatUpdate))
	self.m_chatHandler = Notify.register(LOCAL_SERVER_CHAT_EVENT, handler(self, self.onChatUpdate))

	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
	self.m_container = container

	self:showUI()
end

function ChatSearchView:onExit()
	ChatSearchView.super.onExit(self)

	if self.m_readChatHandler then
		Notify.unregister(self.m_readChatHandler)
		self.m_readChatHandler = nil
	end
	
	if self.m_chatHandler then
		Notify.unregister(self.m_chatHandler)
		self.m_chatHandler = nil
	end
end

function ChatSearchView:showUI()
	self.m_container:removeAllChildren()
	local container = self.m_container

    local function onEdit(event, editbox)
    	if event == "began" then
	        if editbox:getText() == CommonText[358] then
	            editbox:setText("")
	        end
        	ChatMO.searchContent_ = editbox:getText()
        elseif event == "changed" then
        	ChatMO.searchContent_ = editbox:getText()
	    end
    end

    local width = 430
    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

	local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	inputBg:setPreferredSize(cc.size(width + 20, height + 10))
	inputBg:setPosition(display.cx - 85, container:getContentSize().height - 50)

    local inputMsg = ui.newEditBox({x = display.cx - 85, y = container:getContentSize().height - 50, size = cc.size(width, height), listener = onEdit}):addTo(container)
    inputMsg:setFontColor(COLOR[11])
    self.m_inputMsg = inputMsg

    -- gprint("ChatMO.searchContent_:", ChatMO.searchContent_)
    if not ChatMO.searchContent_ or ChatMO.searchContent_ == "" then
    	inputMsg:setText(CommonText[358])
	else
		inputMsg:setText(ChatMO.searchContent_)
	end

    -- 搜索
    local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
    local btn = MenuButton.new(normal, selected, nil, handler(self, self.onSearchCallback)):addTo(container)
    btn:setPosition(container:getContentSize().width - 80, container:getContentSize().height - 50)
    btn:setLabel(CommonText[357])

    local view = ChatSearchTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 80)):addTo(container)
    view:reloadData()
    self.m_tableView = view
end

function ChatSearchView:onSearchCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
    local content = string.gsub(self.m_inputMsg:getText(), " ", "")

    if content == CommonText[358] then
    	self.m_inputMsg:setText("")
    	return
    end

    if content == "" then
        Toast.show(CommonText[355][1])
        return
    end

	local function doneSearch(man)
		Loading.getInstance():unshow()
		-- dump(man)
		if man then -- 搜索到了
			self:pop(function()
					ChatMO.curPrivacyLordId_ = man.lordId
					local ChatView = require("app.view.ChatView")
					ChatView.new(CHAT_TYPE_PRIVACY):push()
				end)
		else
			-- 角色不存在或不在线
			Toast.show(CommonText[355][3])
		end
	end

	Loading.getInstance():show()
	ChatBO.asynSearchOl(doneSearch, content)
end

function ChatSearchView:onChatUpdate(event)
	-- local channel = event.obj.type
	-- local nick = event.obj.nick

	local offset = cc.p(0, 0)
	if self.m_tableView then
		offset = self.m_tableView:getContentOffset()
	end

	self.m_tableView:reloadData()

	-- self:showUI()
	
	if self.m_tableView then
		self.m_tableView:setContentOffset(offset)
	end
end


return ChatSearchView