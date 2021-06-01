-- 主场景中的显示聊天内容的view

local ChatButtonView = class("ChatButtonView", function()
	local node = display.newNode()
	node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
	return node
end)

function ChatButtonView:ctor()
end

function ChatButtonView:onEnter()
	local function chatCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if ChatMO.showChat_ then
			require("app.view.ChatView").new():push()
		else
			require("app.view.ChatSearchView").new():push()
		end
	end

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_37.png")
	bg:setPreferredSize(cc.size(585, 50))
	bg:setOpacity(0)

	local btn = TouchButton.new(bg, nil, nil, nil, chatCallback):addTo(self)
	btn:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)

	self:setContentSize(btn:getContentSize())
	self:setAnchorPoint(cc.p(0.5, 0.5))

	self.m_chatHandler = Notify.register(LOCAL_SERVER_CHAT_EVENT, function(event)
			self:stopAllActions()
			self:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.CallFuncN:create(function() self:onChatUpdate(event) end)}))
		end)
end

function ChatButtonView:onExit()
	if self.m_chatHandler then
		Notify.unregister(self.m_chatHandler)
		self.m_chatHandler = nil
	end
end

function ChatButtonView:onChatUpdate(event)
	local chat = event.obj.chat
	-- gdump(chat, "ChatButtonView:onChatUpdate")

	if self.m_contentNode then
		self.m_contentNode:stopAllActions()
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	-- local node = display.newNode():addTo(self)
	local node = display.newClippingRegionNode(cc.rect(0, 0, 560, 35)):addTo(self)
	node:setPosition(10, 10)
	self.m_contentNode = node
	
	if not chat then return end
	local strTitle = ""
	if chat.channel == CHAT_TYPE_PRIVACY then -- 私聊
		strTitle = "[" .. chat.name .. "]: "
	else
		if (chat.isGm and chat.style and chat.style > 0) or (chat.sysId and chat.sysId > 0) then  -- 系统
			strTitle = "[" .. CommonText[548][4] .. "] " .. ": "
		else
			strTitle = "[" .. CommonText[354][chat.channel] .. "] " .. chat.name .. ": "
		end
	end
	local title = ui.newTTFLabel({text = strTitle, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
	title:setAnchorPoint(cc.p(0, 0.5))
	title:setPosition(0, 12)

	local stringDatas = ChatBO.formatChat(chat)
	for index = 1, #stringDatas do  -- 不可点击
		local data = stringDatas[index]
		if data.click then
			data.click = nil
			data.underline = true
		end
	end
	local msg = RichLabel.new(stringDatas):addTo(node)
	msg:setPosition(title:getPositionX() + title:getContentSize().width, msg:getHeight())
	msg:setTouchEnabled(false)

	-- self.m_contentNode:runAction(transition.sequence({cc.DelayTime:create(20), cc.CallFuncN:create(function(sender)
	-- 		self.m_contentNode:removeSelf()
	-- 		self.m_contentNode = nil
	-- 	end)}))
end

return ChatButtonView
