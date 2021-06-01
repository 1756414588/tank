
------------------------------------------------------------------------------
-- 私聊的所有人TableView
------------------------------------------------------------------------------

local ChatPrivacyTableView = class("ChatPrivacyTableView", TableView)

function ChatPrivacyTableView:ctor(size, viewFor)
	ChatPrivacyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	local chats = ChatMO.getByType(CHAT_TYPE_PRIVACY)

	self.m_privacyNames = {}
	for name, cs in pairs(chats) do
		if #cs > 0 then
			self.m_privacyNames[#self.m_privacyNames + 1] = name
		end
	end
end

function ChatPrivacyTableView:reloadData()
	local chats = ChatMO.getByType(CHAT_TYPE_PRIVACY)

	self.m_privacyNames = {}
	for name, cs in pairs(chats) do
		if #cs > 0 then
			self.m_privacyNames[#self.m_privacyNames + 1] = name
		end
	end

	ChatPrivacyTableView.super.reloadData(self)
end

function ChatPrivacyTableView:numberOfCells()
	return #self.m_privacyNames
end

function ChatPrivacyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ChatPrivacyTableView:createCellAtIndex(cell, index)
	ChatPrivacyTableView.super.createCellAtIndex(self, cell, index)

	local name = self.m_privacyNames[index]

	local typeChats = ChatMO.getByType(CHAT_TYPE_PRIVACY)
	local chats = typeChats[name]

	local chat = chats[#chats]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local node = display.newClippingRegionNode(cc.rect(0, 0, 420, 40)):addTo(cell)
	node:setPosition(170, 30)

	-- 注：私聊中目前没有获得对方头像的信息，所以目前只能暂时以最后一条chat为依据
	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, chat.portrait):addTo(cell)
	itemView:setScale(0.55)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local nameView = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
	cell.name = name
	cell.chatPersonIndex = index  -- 是私聊

	-- 显示最后一条聊天记录
	local stringDatas = {}
	stringDatas[1] = {["content"] = chat.msg}
	local msg = RichLabel.new(stringDatas):addTo(node)
	msg:setPosition(0, 40)


	local quitHandler = function()
		gprint("quit chat")
		ChatMO.delPrivaChat(name)
		self:reloadData()
	end
	--退出按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local quitBtn = CellMenuButton.new(normal, selected, nil, quitHandler)
	quitBtn:setLabel(CommonText[144])
	cell:addButton(quitBtn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 20)


	local num = ChatBO.getTypeUnreadChatNum(CHAT_TYPE_PRIVACY, name)
	if num > 0 then UiUtil.showTip(cell, num, self.m_cellSize.width - 30, self.m_cellSize.height - 30, 5)
	else UiUtil.unshowTip(cell) end
	return cell
end

function ChatPrivacyTableView:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()

	-- if cell.configIndex and cell.configIndex > 0 then
	-- 	local chatType = 0
	-- 	if cell.configIndex == 1 then chatType = CHAT_TYPE_WORLD
	-- 	elseif cell.configIndex == 2 then chatType = CHAT_TYPE_PARTY
	-- 	elseif cell.configIndex == 2 then chatType = CHAT_TYPE_CALLCENTER end

	-- 	local ChatView = require("app.view.ChatView")
	-- 	ChatView.new(chatType):push()
	-- else

	local name = cell.name

	if cell.chatPersonIndex and cell.chatPersonIndex > 0 then
		-- local function doneCallback(man)
		-- 	Loading.getInstance():unshow()
		-- 	if man then -- 搜索到了
		-- 		ChatMO.curPrivacyLordId_ = man.lordId
		-- 		self:dispatchEvent({name = "CHAT_WITH_SOMEONE"})
		-- 	else
		-- 		local num = ChatBO.getTypeUnreadChatNum(CHAT_TYPE_PRIVACY, name)
		-- 		if num > 0 then -- 有没有读取的信息
		-- 			local id = ChatMO.getChatManIdByName(name)
		-- 			if id == 0 then
		-- 				Toast.show(CommonText[355][3])  -- 角色不存在或不在线
		-- 			else
		-- 				ChatMO.curPrivacyLordId_ = id
		-- 				self:dispatchEvent({name = "CHAT_WITH_SOMEONE"})
		-- 			end
		-- 		else
		-- 			Toast.show(CommonText[355][3])  -- 角色不存在或不在线
		-- 		end
		-- 	end
		-- end

		-- Loading.getInstance():show()
		-- ChatBO.asynSearchOl(doneCallback, cell.name)

		local id = ChatMO.getChatManIdByName(name)
		if id == 0 then
			local function doneCallback(man)
				if man then -- 搜索到了
					ChatMO.curPrivacyLordId_ = man.lordId
					self:dispatchEvent({name = "CHAT_WITH_SOMEONE"})
				else
					Toast.show(CommonText[355][3])  -- 角色不存在或不在线
				end
			end

			Loading.getInstance():show()
			ChatBO.asynSearchOl(doneCallback, cell.name)
		else
			ChatMO.curPrivacyLordId_ = id
			self:dispatchEvent({name = "CHAT_WITH_SOMEONE"})
		end
	end

	-- ChatMO.showChat_ = true
end


------------------------------------------------------------------------------
-- 聊天内容TableView
------------------------------------------------------------------------------

local ChatTableView = class("ChatTableView", TableView)

function ChatTableView:ctor(size, viewFor)
	ChatTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 140)

	self.m_viewFor = viewFor
end

function ChatTableView:onEnter()
	ChatTableView.super.onEnter(self)

	self.IsSpecial = 0 
	if ActivityCenterBO.isValid(ACTIVITY_ID_REDPACKET) then
		self.IsSpecial = 1
	end
end

function ChatTableView:numberOfCells()
	local chats = ChatMO.getByType(self.m_viewFor)
	if self.m_viewFor == CHAT_TYPE_PRIVACY then
		if not chats[ChatMO.getChatManName(ChatMO.curPrivacyLordId_)] then return 0
		else return #table.values(chats[ChatMO.getChatManName(ChatMO.curPrivacyLordId_)]) end
	else
		if self.IsSpecial > 0 then
			if self.m_viewFor == CHAT_TYPE_WORLD then
				return #ActivityCenterMO.ActivityRedPacketWorldChat + #chats
			elseif self.m_viewFor == CHAT_TYPE_PARTY then
				return #ActivityCenterMO.ActivityRedPacketPartyChat + #chats
			end
		end
		return #chats
	end
end

function ChatTableView:cellSizeForIndex(index)
	local chats = ChatMO.getByType(self.m_viewFor)
	-- gdump(chats,"chats=====")
	local chat = nil
	if self.m_viewFor == CHAT_TYPE_PRIVACY then
		chat = chats[ChatMO.getChatManName(ChatMO.curPrivacyLordId_)][index]
	else
		chat = self:CellIndexForRedPacket(index, chats)
	end

	if chat.uid then -- 红包
		return cc.size(self.m_cellSize.width, 160)
	end

	local stringDatas = ChatBO.formatChat(chat)
	
	local contentStr = ""
	for i,v in ipairs(stringDatas) do
		if v then
			contentStr = contentStr .. v.content 
		end
	end

	local length = string.utf8len(contentStr)
	if length > 48 then
		return cc.size(self.m_cellSize.width, 160)
	end

	return self.m_cellSize
end

function ChatTableView:CellIndexForRedPacket(index, chats)
	if self.IsSpecial > 0 then
		if self.m_viewFor == CHAT_TYPE_WORLD or self.m_viewFor == CHAT_TYPE_PARTY then
			local out = {}
			if self.m_viewFor == CHAT_TYPE_WORLD then
				for index = 1, #ActivityCenterMO.ActivityRedPacketWorldChat do
					out[#out + 1] = ActivityCenterMO.ActivityRedPacketWorldChat[index]
				end
			end
			if self.m_viewFor == CHAT_TYPE_PARTY then
				for index = 1, #ActivityCenterMO.ActivityRedPacketPartyChat do
					out[#out + 1] = ActivityCenterMO.ActivityRedPacketPartyChat[index]
				end
			end
			for index = 1, #chats do
				out[#out + 1] = chats[index]
			end
			local function redSort(a,b)
				return a.time < b.time
			end
			table.sort(out,redSort)
			return out[index]
		end
	end
	return chats[index]
end

function ChatTableView:createCellAtIndex(cell, index)
	ChatTableView.super.createCellAtIndex(self, cell, index)

	local chats = ChatMO.getByType(self.m_viewFor)
	-- gdump(chats,"chats=====")
	local chat = nil
	if self.m_viewFor == CHAT_TYPE_PRIVACY then
		chat = chats[ChatMO.getChatManName(ChatMO.curPrivacyLordId_)][index]
	else
		chat = self:CellIndexForRedPacket(index, chats)
	end
	-- print("index::::::::::::::", index)

	-- ChatBO.formatChat(chat)
	-- gdump(chat, "ChatTableView====")

	-- cc.size(400, self.m_cellSize.height - 40) 40{(di.png).height * 0.7 - 5(浮动)}
	local stringDatas = ChatBO.formatChat(chat)
	-- dump(stringDatas,"-----------")
	local msg = RichLabel.new(stringDatas, cc.size(400, self.m_cellSize.height - 40)):addTo(cell, 100)

	local size = self:cellSizeForIndex(index)
	if table.isexist(chat,"uid") and chat.uid > 0 then -- 红包UID
		self:showRedPacketContent(cell, index, size, chat)
		msg:removeSelf()
	-- elseif chat.name == UserMO.nickName_ then -- 我自己发的
	elseif chat.roleId == UserMO.lordId_ then 
		local itemView = nil
		if UserMO.gm_ ~= 0 and chat.style and chat.style > 0 then -- 我是管理员，并发送了喇叭
			itemView = display.newSprite(IMAGE_COMMON .. "btn_notice_normal.png"):addTo(cell)
			itemView:setPosition(size.width - 80, size.height - 40)
		else
			local portrait, pendant = UserBO.parsePortrait(chat.portrait)
			itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, chat.portrait, {vip = chat.vip, pendant = pendant}):addTo(cell)
			itemView:setScale(0.5)
			itemView:setPosition(size.width - 80, size.height - itemView:getBoundingBox().size.height / 2 - 10)
			UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onSetPortraitCallback))
		end

		local nameStartX = size.width - 160
		-- 4管理员 3要塞战称号 2玩家名 1军衔 0军团

		if self.m_viewFor == CHAT_TYPE_PARTY then -- 军团
			local job = PartyBO.getPartyJobByMemberNick(chat.name)
			local jobLabel = ui.newTTFLabel({text = job, font = G_FONT, size= FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[3]}):addTo(cell)
			jobLabel:setAnchorPoint(cc.p(1, 0.5))
			jobLabel:setPosition(size.width - 150, size.height - 10)

			nameStartX = jobLabel:getPositionX() - jobLabel:getContentSize().width - 10
		end
		-- elseif self.m_viewFor == CHAT_TYPE_WORLD then -- 世界聊天显示编制
		-- 	if chat.staffing and chat.staffing ~= 0 then
		-- 		local staff = StaffMO.queryStaffById(chat.staffing)
		-- 		local staffName = ui.newTTFLabel({text = staff.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[5]}):addTo(cell)
		-- 		staffName:setAnchorPoint(cc.p(1, 0.5))
		-- 		staffName:setPosition(size.width - 150, size.height - 10)

		-- 		nameStartX = staffName:getPositionX() - staffName:getContentSize().width - 10
		-- 	end
		-- end

		-- 1军衔
		if table.isexist(chat,"militaryRank") then
			local mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(cell)
			mrbg:setAnchorPoint(cc.p(1,0.5))
			mrbg:setPosition(nameStartX,size.height - 5)
			mrbg:setScale(0.7)

			local mricon = display.newSprite(IMAGE_COMMON .. "military/" .. chat.militaryRank .. ".png"):addTo(mrbg)
			mricon:setPosition(mrbg:getContentSize().width * 0.5, mrbg:getContentSize().height * 0.5)

			nameStartX = mrbg:getPositionX() - mrbg:getContentSize().width * 0.7 - 10
		end 

		--2 玩家名
		local name = ui.newTTFLabel({text = chat.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
		name:setAnchorPoint(cc.p(1, 0.5))
		name:setPosition(nameStartX, size.height - 10)

		nameStartX = name:x() - name:width() - 10

		--3要塞战称号
		if chat.jobId and chat.jobId ~= 0 then
			local job = FortressMO.queryJobById(chat.jobId)
			name = UiUtil.label(job.name,nil,COLOR[12])
				:addTo(cell):align(display.RIGHT_CENTER,nameStartX,size.height - 10)
			name = display.newSprite("image/item/job_"..job.id..".png")
					:addTo(cell):leftTo(name)
			nameStartX = name:x() - name:width() - 10
		end
		
		if UserMO.gm_ ~= 0 then  -- 是管理员
			local label = display.newSprite(IMAGE_COMMON .. "label_gm.png"):addTo(cell)
			label:setAnchorPoint(cc.p(1, 0.5))
			label:setPosition(name:getPositionX() - name:getContentSize().width - 20, name:getPositionY())
		elseif UserMO.guider_ ~= 0 then  -- 我是新手指导员
			local label = display.newSprite(IMAGE_COMMON .. "label_newer_guider.png"):addTo(cell)
			label:setAnchorPoint(cc.p(1, 0.5))
			label:setPosition(name:getPositionX() - name:getContentSize().width - 20, name:getPositionY())
		else
			local vip = ui.newTTFLabel({text = "VIP" .. UserMO.vip_, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[12]}):addTo(cell)
			vip:setAnchorPoint(cc.p(1, 0.5))
			vip:setPosition(name:getPositionX() - name:getContentSize().width - 20, name:getPositionY())
		end
		
		local chatType = 3001
		local bg = nil
		if UserMO.gm_ ~= 0 then bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_56.png"):addTo(cell) -- 是管理员
		elseif chat.style and chat.style > 0 then bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_52.png"):addTo(cell)  -- 是公告
		elseif chat.isGuider then bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_56.png"):addTo(cell)  -- 新手指导员
		else 
			local path_ = IMAGE_COMMON
			local path_name = "info_bg_44.png"
			if chat.bubble and chat.bubble > 0 then
				chatType = chat.bubble
				local info = PropMO.checkPropForSkin(chat.bubble)
				path_ = "image/skin/chat/"
				path_name = "r_chatBg_" .. info.show .. ".png"
			end
			bg = display.newScale9Sprite(path_ .. path_name):addTo(cell) 
		end
		local typeInfo = ChatMO.bubbleType[chatType].right
		bg:setPreferredSize(cc.size(math.max(typeInfo.width, msg:getWidth() + typeInfo.widthDex), math.max(typeInfo.height, msg:getHeight() + typeInfo.heightDex)))
		bg:setCapInsets(typeInfo.rect) -- 默认
		bg:setAnchorPoint(cc.p(1, 1))
		bg:setPosition(size.width - 126, size.height - 25)

		msg:setPosition(bg:getPositionX() - bg:getContentSize().width + typeInfo.lbdex.x, bg:getPositionY() + typeInfo.lbdex.y )
		-- msg:setTouchEnabled(false)
	elseif chat.sysId and chat.sysId > 0 then  -- 是系统消息
		if chat.sysId >= 101 and chat.sysId <= 104 then -- 军团招募
			local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, chat.portrait, {vip = chat.vip}):addTo(cell)
			itemView:setScale(0.5)
			itemView:setPosition(80, size.height - itemView:getBoundingBox().size.height / 2 - 10)
			itemView.chat = chat
			UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onHeadCallback))

			local name = ui.newTTFLabel({text = chat.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
			name:setAnchorPoint(cc.p(0, 0.5))
			name:setPosition(160, size.height - 10)

			local vip = ui.newTTFLabel({text = "VIP" .. chat.vip, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[12]}):addTo(cell)
			vip:setAnchorPoint(cc.p(0, 0.5))
			vip:setPosition(name:getPositionX() + name:getContentSize().width + 20, name:getPositionY())
		else -- 系统公告
			local view = display.newSprite(IMAGE_COMMON .. "btn_notice_normal.png"):addTo(cell)
			view:setPosition(80, size.height - 40)

			local name = ui.newTTFLabel({text = CommonText[548][4], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
			name:setAnchorPoint(cc.p(0, 0.5))
			name:setPosition(160, size.height - 10)
		end 

		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_57.png"):addTo(cell)
		bg:setPreferredSize(cc.size(math.max(76, msg:getWidth() + 20 + 20), math.max(66, msg:getHeight() + 30)))
		bg:setCapInsets(cc.rect(42, 38, 1, 1))
		bg:setAnchorPoint(cc.p(0, 1))
		bg:setPosition(126, size.height - 25)

		msg:setPosition(bg:getPositionX() + 20, bg:getPositionY() - 15)
	else
		if chat.isGm and chat.style and chat.style > 0 then -- 管理员，并发送了喇叭
			local itemView = display.newSprite(IMAGE_COMMON .. "btn_notice_normal.png"):addTo(cell)
			itemView:setPosition(80, size.height - itemView:getBoundingBox().size.height / 2 - 20)

			-- 系统
			local name = ui.newTTFLabel({text = CommonText[548][4], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
			name:setAnchorPoint(cc.p(0, 0.5))
			name:setPosition(160, size.height - 10)
		else
			local portrait, pendant = UserBO.parsePortrait(chat.portrait)
			local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, chat.portrait, {vip = chat.vip, pendant = pendant}):addTo(cell)
			itemView:setScale(0.5)
			itemView:setPosition(80, size.height - itemView:getBoundingBox().size.height / 2 - 10)
			itemView.chat = chat
			UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onHeadCallback))

			local nameStartX = 160
			-- 0军团 1军衔 2玩家名(跨服聊天会加区服名) 3要塞称号 4管理员

			if self.m_viewFor == CHAT_TYPE_PARTY then -- 军团
				local job = PartyBO.getPartyJobByMemberNick(chat.name)
				local jobLabel = ui.newTTFLabel({text = job, font = G_FONT, size= FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[3]}):addTo(cell)
				jobLabel:setAnchorPoint(cc.p(0, 0.5))
				jobLabel:setPosition(160, size.height - 10)

				nameStartX = jobLabel:getPositionX() + jobLabel:getContentSize().width + 10
			end
			-- elseif self.m_viewFor == CHAT_TYPE_WORLD then -- 世界聊天 显示 军衔
			-- 	if chat.militaryRank then
			-- 		local mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(cell)
			-- 		mrbg:setAnchorPoint(cc.p(0,0.5))
			-- 		mrbg:setPosition(160,size.height - 10)
			-- 		mrbg:setScale(0.75)

			-- 		local mricon = display.newSprite(IMAGE_COMMON .. "military/" .. chat.militaryRank .. ".png"):addTo(mrbg)
			-- 		mricon:setPosition(mrbg:getContentSize().width * 0.5, mrbg:getContentSize().height * 0.5)

			-- 		nameStartX = mrbg:getPositionX() + mrbg:getContentSize().width * 0.75 + 10
			-- 	end 
			-- end

			-- 1军衔
			if table.isexist(chat,"militaryRank") then
				local mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(cell)
				mrbg:setAnchorPoint(cc.p(0,0.5))
				mrbg:setPosition(nameStartX,size.height - 5)
				mrbg:setScale(0.7)

				local mricon = display.newSprite(IMAGE_COMMON .. "military/" .. chat.militaryRank .. ".png"):addTo(mrbg)
				mricon:setPosition(mrbg:getContentSize().width * 0.5, mrbg:getContentSize().height * 0.5)

				nameStartX = mrbg:getPositionX() + mrbg:getContentSize().width * 0.7 + 10
			end 

			--2 玩家名
			local name = ui.newTTFLabel({text = chat.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
			name:setAnchorPoint(cc.p(0, 0.5))
			name:setPosition(nameStartX, size.height - 10)

			nameStartX = name:x() + name:width() + 10

			--跨服聊天玩家名称后加区服名称
			if self.m_viewFor == CHAT_TYPE_CROSS then
				local crossPlayInfo = chat.crossPlayInfo
				-- gdump(crossPlayInfo)
				local channel = ui.newTTFLabel({text = "("..crossPlayInfo.serverName..")", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
				channel:setAnchorPoint(cc.p(0, 0.5))
				channel:setPosition(nameStartX, size.height - 10)

				nameStartX = channel:x() + channel:width() + 10
			end

			--3要塞战称号
			if chat.jobId and chat.jobId ~= 0 then
				local job = FortressMO.queryJobById(chat.jobId)
				name = UiUtil.label(job.name,nil,COLOR[12])
					:addTo(cell):align(display.LEFT_CENTER,nameStartX,size.height - 10)
				name = display.newSprite("image/item/job_"..job.id..".png")
						:addTo(cell):rightTo(name)
				nameStartX = name:x() + name:width() + 10
			end
			
			if chat.isGm then -- 是管理员
				local label = display.newSprite(IMAGE_COMMON .. "label_gm.png"):addTo(cell)
				label:setAnchorPoint(cc.p(0, 0.5))
				-- label:setPosition(name:getPositionX() + name:getContentSize().width + 20, name:getPositionY())
				label:setPosition(nameStartX, name:getPositionY())
			elseif chat.isGuider then  -- 对方是新手指导员
				local label = display.newSprite(IMAGE_COMMON .. "label_newer_guider.png"):addTo(cell)
				label:setAnchorPoint(cc.p(0, 0.5))
				-- label:setPosition(name:getPositionX() + name:getContentSize().width + 20, name:getPositionY())
				label:setPosition(nameStartX, name:getPositionY())
			else
				local vip = ui.newTTFLabel({text = "VIP" .. chat.vip, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[12]}):addTo(cell)
				vip:setAnchorPoint(cc.p(0, 0.5))
				-- vip:setPosition(name:getPositionX() + name:getContentSize().width + 20, name:getPositionY())
				vip:setPosition(nameStartX, name:getPositionY())
			end
		end

		local chatType = 3001
		local bg = nil
		if chat.isGm then bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_47.png"):addTo(cell)  -- 是管理员
		elseif chat.style and chat.style > 0 then bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_51.png"):addTo(cell) -- 是公告
		elseif chat.isGuider then bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_57.png"):addTo(cell)
		else
			local path_ = IMAGE_COMMON
			local path_name = "info_bg_43.png"
			if chat.bubble and chat.bubble > 0 then
				chatType = chat.bubble
				local info = PropMO.checkPropForSkin(chat.bubble)
				path_ = "image/skin/chat/"
				path_name = "l_chatBg_" .. info.show .. ".png"
			end 
			bg = display.newScale9Sprite(path_ .. path_name):addTo(cell) 
		end
		local typeInfo = ChatMO.bubbleType[chatType].left
		bg:setPreferredSize(cc.size(math.max(typeInfo.width, msg:getWidth() + typeInfo.widthDex), math.max(typeInfo.height, msg:getHeight() + typeInfo.heightDex)))
		bg:setCapInsets(typeInfo.rect) -- 默认
		bg:setAnchorPoint(cc.p(0, 1))
		bg:setPosition(126, size.height - 25)

		-- msg:setAnchorPoint(cc.p(0, 1))
		msg:setPosition(bg:getPositionX() + typeInfo.lbdex.x , bg:getPositionY() + typeInfo.lbdex.y )
	end
	return cell
end



function ChatTableView:showRedPacketContent(cell, index, size, chat)
	-- if chat.name == UserMO.nickName_ then
	if chat.roleId == UserMO.lordId_ then 

		local portrait, pendant = UserBO.parsePortrait(chat.portrait)
		local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, chat.portrait, {vip = chat.vip, pendant = pendant}):addTo(cell)
		itemView:setScale(0.5)
		itemView:setPosition(size.width - 80, size.height - itemView:getBoundingBox().size.height / 2 - 10)
		UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onSetPortraitCallback))


		local nameStartX = size.width - 160
		-- 4管理员 3要塞战称号 2玩家名 1军衔 0军团

		if self.m_viewFor == CHAT_TYPE_PARTY then -- 军团
			local job = PartyBO.getPartyJobByMemberNick(chat.name)
			local jobLabel = ui.newTTFLabel({text = job, font = G_FONT, size= FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[3]}):addTo(cell)
			jobLabel:setAnchorPoint(cc.p(1, 0.5))
			jobLabel:setPosition(size.width - 150, size.height - 10)

			nameStartX = jobLabel:getPositionX() - jobLabel:getContentSize().width - 10
		end

		-- 1军衔
		if table.isexist(chat,"militaryRank") then
			local mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(cell)
			mrbg:setAnchorPoint(cc.p(1,0.5))
			mrbg:setPosition(nameStartX,size.height - 5)
			mrbg:setScale(0.7)

			local mricon = display.newSprite(IMAGE_COMMON .. "military/" .. chat.militaryRank .. ".png"):addTo(mrbg)
			mricon:setPosition(mrbg:getContentSize().width * 0.5, mrbg:getContentSize().height * 0.5)

			nameStartX = mrbg:getPositionX() - mrbg:getContentSize().width * 0.7 - 10
		end 

		--2 玩家名
		local name = ui.newTTFLabel({text = chat.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
		name:setAnchorPoint(cc.p(1, 0.5))
		name:setPosition(nameStartX, size.height - 10)

		nameStartX = name:x() - name:width() - 10

		--3要塞战称号
		-- if chat.jobId and chat.jobId ~= 0 then
		-- 	local job = FortressMO.queryJobById(chat.jobId)
		-- 	name = UiUtil.label(job.name,nil,COLOR[12])
		-- 		:addTo(cell):align(display.RIGHT_CENTER,nameStartX,size.height - 10)
		-- 	name = display.newSprite("image/item/job_"..job.id..".png")
		-- 			:addTo(cell):leftTo(name)
		-- 	nameStartX = name:x() - name:width() - 10
		-- end
		
		local vip = ui.newTTFLabel({text = "VIP" .. UserMO.vip_, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[12]}):addTo(cell)
		vip:setAnchorPoint(cc.p(1, 0.5))
		vip:setPosition(name:getPositionX() - name:getContentSize().width - 20, name:getPositionY())

		local icon = "redpacketbg_1"
		if chat.remainGrab <= 0 then icon = "redpacketbg_0" end
		local msgl = display.newSprite(IMAGE_COMMON .. icon .. ".png")--:addTo(cell, 100)
		local msg = TouchButton.new(msgl,nil,nil,nil,handler(self, self.onRedPacketCallback)):addTo(cell, 100)
		msg.uid = chat.uid
		msg.uidState = table.isexist(chat,"remainGrab")

		local chatType = 3001
		local bg = nil

		local path_ = IMAGE_COMMON
		local path_name = "info_bg_44.png"
		if table.isexist(chat, "bubble") and chat.bubble > 0 then
			chatType = chat.bubble
			local info = PropMO.checkPropForSkin(chat.bubble)
			path_ = "image/skin/chat/"
			path_name = "r_chatBg_" .. info.show .. ".png"
		end
		bg = display.newScale9Sprite(path_ .. path_name):addTo(cell) 
		
		local typeInfo = ChatMO.bubbleType[chatType].right
		bg:setPreferredSize(cc.size(math.max(typeInfo.width, msg:width() + typeInfo.widthDex), math.max(typeInfo.height, msg:height() + typeInfo.heightDex)))
		bg:setCapInsets(typeInfo.rect) -- 默认
		bg:setAnchorPoint(cc.p(1, 1))
		bg:setPosition(size.width - 126, size.height - 25)

		msg:setAnchorPoint(cc.p(0, 1))
		msg:setPosition(bg:getPositionX() - bg:getContentSize().width + typeInfo.lbdex.x, bg:getPositionY() + typeInfo.lbdex.y )
	else
		local uidState = table.isexist(chat,"remainGrab")
		
		if uidState then
			local portrait, pendant = UserBO.parsePortrait(chat.portrait)
			local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, chat.portrait, {vip = chat.vip, pendant = pendant}):addTo(cell)
			itemView:setScale(0.5)
			itemView:setPosition(80, size.height - itemView:getBoundingBox().size.height / 2 - 10)
			itemView.chat = chat
			itemView.chat.sysId = 0
			itemView.chat.msg = ""
			UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onHeadCallback))
		else
			local itemView = display.newSprite(IMAGE_COMMON .. "btn_notice_normal.png"):addTo(cell)
			itemView:setPosition(80, size.height - 40)
		end
		

		local nameStartX = 160
		-- 0军团 1军衔 2玩家名 3要塞称号 4管理员

		if self.m_viewFor == CHAT_TYPE_PARTY then -- 军团
			local job = PartyBO.getPartyJobByMemberNick(chat.name)
			local jobLabel = ui.newTTFLabel({text = job, font = G_FONT, size= FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[3]}):addTo(cell)
			jobLabel:setAnchorPoint(cc.p(0, 0.5))
			jobLabel:setPosition(160, size.height - 10)

			nameStartX = jobLabel:getPositionX() + jobLabel:getContentSize().width + 10
		end
		-- elseif self.m_viewFor == CHAT_TYPE_WORLD then -- 世界聊天 显示 军衔
		-- 	if chat.militaryRank then
		-- 		local mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(cell)
		-- 		mrbg:setAnchorPoint(cc.p(0,0.5))
		-- 		mrbg:setPosition(160,size.height - 10)
		-- 		mrbg:setScale(0.75)

		-- 		local mricon = display.newSprite(IMAGE_COMMON .. "military/" .. chat.militaryRank .. ".png"):addTo(mrbg)
		-- 		mricon:setPosition(mrbg:getContentSize().width * 0.5, mrbg:getContentSize().height * 0.5)

		-- 		nameStartX = mrbg:getPositionX() + mrbg:getContentSize().width * 0.75 + 10
		-- 	end 
		-- end

		-- 1军衔
		if table.isexist(chat,"militaryRank") then
			local mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(cell)
			mrbg:setAnchorPoint(cc.p(0,0.5))
			mrbg:setPosition(nameStartX,size.height - 5)
			mrbg:setScale(0.7)

			local mricon = display.newSprite(IMAGE_COMMON .. "military/" .. chat.militaryRank .. ".png"):addTo(mrbg)
			mricon:setPosition(mrbg:getContentSize().width * 0.5, mrbg:getContentSize().height * 0.5)

			nameStartX = mrbg:getPositionX() + mrbg:getContentSize().width * 0.7 + 10
		end 

		local nameStr = chat.name
		if not uidState then nameStr = CommonText[548][4] end
		--2 玩家名
		local name = ui.newTTFLabel({text = nameStr, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
		name:setAnchorPoint(cc.p(0, 0.5))
		name:setPosition(nameStartX, size.height - 10)

		nameStartX = name:x() + name:width() + 10

		--3要塞战称号
		-- if chat.jobId and chat.jobId ~= 0 then
		-- 	local job = FortressMO.queryJobById(chat.jobId)
		-- 	name = UiUtil.label(job.name,nil,COLOR[12])
		-- 		:addTo(cell):align(display.LEFT_CENTER,nameStartX,size.height - 10)
		-- 	name = display.newSprite("image/item/job_"..job.id..".png")
		-- 			:addTo(cell):rightTo(name)
		-- 	nameStartX = name:x() + name:width() + 10
		-- end
		
		if uidState then
			local vip = ui.newTTFLabel({text = "VIP" .. chat.vip, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT, color = COLOR[12]}):addTo(cell)
			vip:setAnchorPoint(cc.p(0, 0.5))
			vip:setPosition(nameStartX, name:getPositionY())
		end

		local icon = "redpacketbg_1"
		if uidState and chat.remainGrab <= 0 then icon = "redpacketbg_0" end
		local msgl = display.newSprite(IMAGE_COMMON .. icon .. ".png")--:addTo(cell, 100)
		local msg = TouchButton.new(msgl,nil,nil,nil,handler(self, self.onRedPacketCallback)):addTo(cell, 100)
		msg.uid = chat.uid
		msg.uidState = uidState

		local chatType = 3001
		local bg = nil

		local path_ = IMAGE_COMMON
		local path_name = "info_bg_43.png"
		if table.isexist(chat, "bubble")  and chat.bubble > 0 then
			chatType = chat.bubble
			local info = PropMO.checkPropForSkin(chat.bubble)
			path_ = "image/skin/chat/"
			path_name = "l_chatBg_" .. info.show .. ".png"
		end 
		bg = display.newScale9Sprite(path_ .. path_name):addTo(cell) 

		local typeInfo = ChatMO.bubbleType[chatType].left
		bg:setPreferredSize(cc.size(math.max(typeInfo.width, msg:width() + typeInfo.widthDex), math.max(typeInfo.height, msg:height() + typeInfo.heightDex)))
		bg:setCapInsets(typeInfo.rect) -- 默认
		bg:setAnchorPoint(cc.p(0, 1))
		bg:setPosition(126, size.height - 25)

		msg:setAnchorPoint(cc.p(0, 1))
		msg:setPosition(bg:getPositionX() + typeInfo.lbdex.x , bg:getPositionY() + typeInfo.lbdex.y )
	end 
end

function ChatTableView:onRedPacketCallback(tar, sender)
	-- body
	local _uid = sender.uid
	local uidState = sender.uidState -- true : 红包活动  false ：叛军活动
	dump(uidState)
	local function parseResultCallback(data, state)
		-- body
		if not state then return end
		local RedPacketInfoDialog = require("app.dialog.RedPacketInfoDialog")
		RedPacketInfoDialog.new(data):push()
	end
	if uidState then
		ActivityCenterBO.GrabRedBag(parseResultCallback, _uid)
	else
		RebelBO.GrabRebelRedBag(parseResultCallback, _uid)
	end
end

function ChatTableView:onHeadCallback(sender)
	ManagerSound.playNormalButtonSound()
	if self.m_viewFor == CHAT_TYPE_CROSS then 
		local CrossPlayerInfoDialog = require("app.dialog.CrossPlayerInfoDialog")
		local dialog = CrossPlayerInfoDialog.new(sender.chat):push()
		return 
	end
	local function gotoDialog(man)
		if man then
	        local player = {icon = man.icon, nick = man.nick, level = man.level, lordId = man.lordId, rank = man.ranks,
	            fight = man.fight, sex = man.sex, party = man.partyName, pros = man.pros, prosMax = man.prosMax}
	        require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_CHAT, player,nil,sender.chat):push()
	    end
	end

	local function doneCallback(man)
		Loading.getInstance():unshow()
		gotoDialog(man)
	end

	local chat = sender.chat

	Loading.getInstance():show()
	SocialityBO.asynSearchPlayer(doneCallback, chat.name)

	-- local chat = sender.chat
	-- local lordId = ChatMO.getChatManIdByName(chat.name)
	-- if lordId == 0 then
	-- 	local function doneCallback(man)
	-- 		Loading.getInstance():unshow()
	-- 		if man then
	-- 			gotoDialog(man)
	-- 		else
	-- 			-- 角色不存在或不在线
	-- 			Toast.show(CommonText[355][3])
	-- 		end
	-- 	end

	-- 	Loading.getInstance():show()
	-- 	ChatBO.asynSearchOl(doneCallback, chat.name)
	-- else
	-- 	local man = ChatMO.getManById(lordId)
	-- 	gotoDialog(man)
	-- end
end

function ChatTableView:onSetPortraitCallback(itemView)
	ManagerSound.playNormalButtonSound()
	require("app.view.PlayerView").new(UI_ENTER_NONE, PLAYER_VIEW_PORTRAIT):push()
end

function ChatTableView:reloadData()
	local name = ChatMO.getChatManName(ChatMO.curPrivacyLordId_)
	-- 标记聊天已读
	ChatBO.readChat(self.m_viewFor, {nick = name})
	ChatTableView.super.reloadData(self)
end

------------------------------------------------------------------------------
-- 聊天view
------------------------------------------------------------------------------

local ChatView = class("ChatView", UiNode)

function ChatView:ctor(viewFor, uiEnter)
	uiEnter = uiEnter or UI_ENTER_NONE
	ChatView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)

	viewFor = viewFor or CHAT_TYPE_WORLD
	self.m_viewFor = viewFor
end

function ChatView:onEnter()
	ChatView.super.onEnter(self)

	self:setTitle(CommonText[356])
	
	local myParty = PartyBO.getMyParty()
	self.m_myParty = myParty

	local function createDelegate(container, index)
		container.show_state = 1
		if index == 1 then -- 世界
			ChatMO.curPrivacyLordId_ = 0

			container.chat_type = CHAT_TYPE_WORLD
			self:showWorld(container)
		elseif index == 2 then -- 执行任务
			if myParty then  -- 军团
				ChatMO.curPrivacyLordId_ = 0

				container.chat_type = CHAT_TYPE_PARTY
				self:showParty(container)
			else -- 私聊
				container.chat_type = CHAT_TYPE_PRIVACY
				if ChatMO.curPrivacyLordId_ == 0 then
					container.privacy_state = 1
				else
					container.privacy_state = 2 -- 显示列表
				end
				self:showPrivacy(container)
			end
		elseif index == 3 then -- 私聊
			if not myParty then  -- 军团
				ChatMO.curPrivacyLordId_ = 0
				container.chat_type = CHAT_TYPE_CROSS
				self:showCross(container)
			else
				container.chat_type = CHAT_TYPE_PRIVACY
				if ChatMO.curPrivacyLordId_ == 0 then
					container.privacy_state = 1
				else
					container.privacy_state = 2 -- 显示列表
				end
				self:showPrivacy(container)
			end
		elseif index == 4 then -- 跨服
			ChatMO.curPrivacyLordId_ = 0
			container.chat_type = CHAT_TYPE_CROSS
			self:showCross(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = nil
	if myParty then
		if HunterMO.teamFightCrossData_.state == 2 then
			pages = {CommonText[354][1], CommonText[354][2], CommonText[354][4], CommonText[354][5]}
		else
			pages = {CommonText[354][1], CommonText[354][2], CommonText[354][4]}
		end
	else
		if HunterMO.teamFightCrossData_.state == 2 then
			pages = {CommonText[354][1], CommonText[354][4], CommonText[354][5]}
		else
			pages = {CommonText[354][1], CommonText[354][4]}
		end
	end

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView
	if ChatMO.curPrivacyLordId_ > 0 then
		pageView:setPageIndex(3)
	else
		pageView:setPageIndex(1)
	end
	pageView:setPageIndex(self.m_viewFor)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_chatHandler = Notify.register(LOCAL_SERVER_CHAT_EVENT, handler(self, self.onChatUpdate))

	local function shieldCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		local ChatShieldDialog = require("app.dialog.ChatShieldDialog")
		ChatShieldDialog.new():push()
	end

	-- 屏蔽
	local normal = display.newSprite(IMAGE_COMMON .. "btn_shield_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_shield_selected.png")
	local btn = MenuButton.new(normal, selected, nil, shieldCallback):addTo(self:getBg(), 10)
	btn:setPosition(self:getBg():getContentSize().width - 50, self:getBg():getContentSize().height - 50)
end

function ChatView:onExit()
	ChatView.super.onExit(self)
	
	if self.m_chatUpdateScheduler then
		scheduler.unscheduleGlobal(self.m_chatUpdateScheduler)
		self.m_chatUpdateScheduler = nil
	end

	if self.m_chatHandler then
		Notify.unregister(self.m_chatHandler)
		self.m_chatHandler = nil
	end
end

function ChatView:showWorld(container)
	local view = ChatTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 70 - 4), container.chat_type):addTo(container)
	view:setPosition(0, 70)
	container.tableView = view

	self:showBottom(container)

	view:reloadData()
	self:onViewOffset(view)

	self:showUpdateTip()
end

function ChatView:showParty(container)
	local view = ChatTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 70 - 4), container.chat_type):addTo(container)
	view:setPosition(0, 70)
	container.tableView = view

	self:showBottom(container)

	view:reloadData()
	self:onViewOffset(view)

	self:showUpdateTip()
end

--跨服聊天
function ChatView:showCross(container)
	local view = ChatTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 70 - 4), container.chat_type):addTo(container)
	view:setPosition(0, 70)
	container.tableView = view

	self:showBottom(container)

	view:reloadData()
	self:onViewOffset(view)

	self:showUpdateTip()
end

function ChatView:showPrivacy(container)
	container:removeAllChildren()
	container.btmNode = nil

    local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container, 2)
    line:setPreferredSize(cc.size(container:getContentSize().width - 6, line:getContentSize().height))
    line:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 93)
    line:setScaleY(-1)

	if container.privacy_state == 1 then -- 显示列表
        local function onEdit(event, editbox)
	    	if event == "began" then
		        -- if editbox:getText() == CommonText[358] then editbox:setText("") end
	        	ChatMO.searchContent_ = editbox:getText()
	        elseif event == "changed" then
	        	ChatMO.searchContent_ = editbox:getText()
		    end
	    end

	    local width = 390
	    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

		local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
		inputBg:setPreferredSize(cc.size(width + 20, height + 10))
		inputBg:setPosition(220, container:getContentSize().height - 44)

	    local inputMsg = ui.newEditBox({x = 220, y = container:getContentSize().height - 44, size = cc.size(width, height), listener = onEdit}):addTo(container)
	    inputMsg:setFontColor(COLOR[11])
	    inputMsg:setPlaceholderFontColor(COLOR[11])
	    inputMsg:setPlaceHolder(CommonText[353])

	    if ChatMO.searchContent_ and ChatMO.searchContent_ ~= "" then
			inputMsg:setText(ChatMO.searchContent_)
	    end

	    -- 查找
	    local normal = display.newSprite(IMAGE_COMMON .. "btn_search_normal.png")
	    local selected = display.newSprite(IMAGE_COMMON .. "btn_search_selected.png")
	    local btn = MenuButton.new(normal, selected, nil, handler(self, self.onSearchCallback)):addTo(container)
	    btn:setPosition(container:getContentSize().width - 150, container:getContentSize().height - 44)
	    btn.searchEditbox = inputMsg
	    btn.container_ = container

		local function contactCallback(contacts)
			gdump(contacts, "contactCallback")
			if contacts and #contacts > 0 then
				btn.searchEditbox:setText(contacts[1].name)
			end
		end

    	local function gotoContact(tag, sender)
			ManagerSound.playNormalButtonSound()
			local ContactDialog = require("app.dialog.ContactDialog")
			ContactDialog.new(CONTACT_MODE_SINGLE, contactCallback):push()
		end


	    -- 联系人
	    local normal = display.newSprite(IMAGE_COMMON .. "btn_44_normal.png")
	    local selected = display.newSprite(IMAGE_COMMON .. "btn_44_selected.png")
	    local btn = MenuButton.new(normal, selected, nil, gotoContact):addTo(container)
	    btn:setPosition(container:getContentSize().width - 55, container:getContentSize().height - 44)

	    local function chatPrivacy()
			container.privacy_state = 2
			self:showPrivacy(container)
	    end

		local view = ChatPrivacyTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 90)):addTo(container)
		view:addEventListener("CHAT_WITH_SOMEONE", chatPrivacy)
		view:setPosition(0, 0)
		container.tableView = view

		view:reloadData()
		self:onViewOffset(view)
	elseif container.privacy_state == 2 then -- 显示私聊内容列表
		local name = ChatMO.getChatManName(ChatMO.curPrivacyLordId_)
		name = name or ""
		local desc = ui.newTTFLabel({text = "TO: " .. name, font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = container:getContentSize().height - 44, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(container)
		desc:setAnchorPoint(cc.p(0, 0.5))

		local function onReturnCallback(tag, sender)
			ChatMO.curPrivacyLordId_ = 0
			container.privacy_state = 1 -- 显示好友列表
			self:showPrivacy(container)
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_del_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_del_selected.png")
		local btn = MenuButton.new(normal, selected, nil, onReturnCallback):addTo(container)
		btn:setPosition(container:getContentSize().width - 55, container:getContentSize().height - 44)

		local view = ChatTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 70 - 90 - 4), container.chat_type):addTo(container)
		view:setPosition(0, 70)
		container.tableView = view
		self:showBottom(container)

		view:reloadData()
		self:onViewOffset(view)
	end
	self:showUpdateTip()
end

function ChatView:showBottom(container)
	if container.btmNode then
		container.btmNode:removeAllChildren()
		container.btmNode = nil
	end

	local btmNode = display.newNode():addTo(container)
	container.btmNode = btmNode

	local chatType = container.chat_type

	local function onExchange(tag, sender)
		ManagerSound.playNormalButtonSound()
		-- 当前是聊天，切换到公告
		if container.show_state == 1 then container.show_state = 2
		else container.show_state = 1 end
		self:showBottom(container)
	end

	if chatType == CHAT_TYPE_WORLD then  -- 世界
		-- 聊天、公告切换
		local normal = display.newSprite(IMAGE_COMMON .. "btn_back_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_back_selected.png")
		local exchangeBtn = MenuButton.new(normal, selected, nil, onExchange):addTo(btmNode)
		exchangeBtn:setPosition(50, 30)
		container.exchangeBtn = exchangeBtn
	end

	if container.show_state == 1 then  -- 当前是聊天
		if container.exchangeBtn then
			container.exchangeBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_43_normal.png"))
			container.exchangeBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_43_selected.png"))
		end

	    local function onEdit(event, editbox)
   		    if event == "began" then
		        -- if editbox:getText() == CommonText[353] then
		        --     editbox:setText("")
		        -- end
	        	container.send_show_content = editbox:getText()
	        elseif event == "changed" then
	        	container.send_show_content = editbox:getText()
	        end
	    end

	    local width = 0
	    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

		local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(btmNode)

		if chatType == CHAT_TYPE_WORLD then
			width = 320
			inputBg:setPreferredSize(cc.size(width + 20, height + 10))
			inputBg:setPosition(GAME_SIZE_WIDTH / 2 - 50, 30)
		else
			width = 410
			inputBg:setPreferredSize(cc.size(width + 20, height + 10))
			inputBg:setPosition(GAME_SIZE_WIDTH / 2 - 95, 30)
		end

	    local inputMsg = ui.newEditBox({x = inputBg:getPositionX(), y = 30, size = cc.size(width, height), listener = onEdit}):addTo(btmNode)
	    inputMsg:setFontColor(COLOR[11])
	    -- inputMsg:setText(CommonText[353])
	    inputMsg:setPlaceholderFontColor(COLOR[11])
	    inputMsg:setPlaceHolder(CommonText[353])
	    inputMsg:setMaxLength(CHAT_MAX_LENGTH)
	    container.input_edit_box = inputMsg

    	-- 表情
		local normal = display.newSprite(IMAGE_COMMON .. "btn_express_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_express_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onExpressCallback)):addTo(btmNode)
		btn:setPosition(container:getContentSize().width - 140, 30)

	    -- 发送
		local normal = display.newSprite(IMAGE_COMMON .. "btn_send_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_send_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onSendCallback)):addTo(btmNode)
		btn:setPosition(container:getContentSize().width - 50, 30)
		btn.container_ = container
	elseif container.show_state == 2 then -- 当前是公告
	    local function onEdit(event, editbox)
	    	if event == "began" then
		        -- if editbox:getText() == CommonText[454] then
		        --     editbox:setText("")
		        -- end
		        container.send_show_content = editbox:getText()
		    elseif event == "changed" then
	        	container.send_show_content = editbox:getText()
	        end
	    end

	    local width = 320
	    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

		local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_1.png"):addTo(btmNode)
		inputBg:setPreferredSize(cc.size(width + 20, height + 10))
		inputBg:setPosition(GAME_SIZE_WIDTH / 2 - 50, 30)

	    local inputMsg = ui.newEditBox({x = GAME_SIZE_WIDTH / 2 - 50, y = 30, size = cc.size(width, height), listener = onEdit}):addTo(btmNode)
	    inputMsg:setFontColor(COLOR[11])
	    -- inputMsg:setText(CommonText[454])
	    inputMsg:setPlaceholderFontColor(COLOR[11])
	    inputMsg:setPlaceHolder(CommonText[454])
	    inputMsg:setMaxLength(CHAT_MAX_LENGTH)
	    container.input_edit_box = inputMsg
	    
    	-- 表情
		local normal = display.newSprite(IMAGE_COMMON .. "btn_express_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_express_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onExpressCallback)):addTo(btmNode)
		btn:setPosition(container:getContentSize().width - 140, 30)

	    -- 发送
		local normal = display.newSprite(IMAGE_COMMON .. "btn_send_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_send_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onSendCallback)):addTo(btmNode)
		btn:setPosition(container:getContentSize().width - 50, 30)
		btn.container_ = container

		local bg = display.newSprite(IMAGE_COMMON .. "info_bg_65.png"):addTo(btmNode)
		bg:setPosition(bg:getContentSize().width / 2, 90)

		-- 道具
		local itemView = UiUtil.createItemView(ITEM_KIND_PROP, PROP_ID_HORN_NORMAL):addTo(bg)
		itemView:setScale(0.5)
		itemView:setPosition(itemView:getBoundingBox().size.width / 2, bg:getContentSize().height / 2)

		-- 公告
		local name = ui.newTTFLabel({text = CommonText[455], font = G_FONT, size = FONT_SIZE_SMALL, x = 55, y = bg:getContentSize().height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		name:setAnchorPoint(cc.p(0, 0.5))
	end

    container.send_show_content = ""
end

function ChatView:onClickExpress(id)
	local express = UserMO.express[id]
	local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())
	container.send_show_content = container.send_show_content .. express.desc
	container.input_edit_box:setText(container.send_show_content)
end

function ChatView:onExpressCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	local ExpressDialog = require("app.dialog.ExpressDialog")
	local dialog = ExpressDialog.new(handler(self, self.onClickExpress)):push()
	if dialog then
		dialog:getBg():setPosition(display.cx, 100 + dialog:getBg():getContentSize().height / 2)
	end
end

function ChatView:onSendCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

    local container = sender.container_

    local content = string.trim(container.input_edit_box:getText())

 --    if container.show_state == 1 then  -- 当前是聊天
	--     if content == CommonText[353] then
	--         container.input_edit_box:setText("")
	--         container.send_show_content = ""
	--         return
	--     end
	-- elseif container.show_state == 2 then -- 当前是公告
	-- 	if content == CommonText[454] then
	--         container.input_edit_box:setText("")
	--         container.send_show_content = ""
	--         return
	-- 	end
	-- end

    if content == "" then
        Toast.show(CommonText[355][1])
        return
    end

    local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())

    if container.show_state == 1 then  -- 当前是聊天
	    local length = string.utf8len(content)
	    if length > CHAT_MAX_LENGTH or length < 0 then
	        Toast.show(CommonText[355][2])
	        return
	    end

	    --聊天开启条件 (vip玩家/等级>=16/活跃度>=60)
	    if container.chat_type == CHAT_TYPE_WORLD then
	    	local openLv = ChatMO.getChatOpenLv()
	    	if not (UserMO.level_ >= openLv or UserMO.vip_ > 0 or UserMO.gm_ ~= 0 or UserMO.guider_ ~= 0) then
		    	Toast.show(string.format(CommonText[10039], openLv))
		    	return
		    end
	    end

		if not ChatBO.isMsgOk(content) then
			if UserMO.gm_ ~= 0 and container.chat_type == CHAT_TYPE_PRIVACY and ChatMO.curPrivacyLordId_ == UserMO.lordId_ and ChatBO.isGMOK(content) then
				require("app.dialog.GMInfoDialog").new():push()
				return
			end
		    if container.chat_type == CHAT_TYPE_PRIVACY and ChatMO.curPrivacyLordId_ == UserMO.lordId_ then -- 只能自己和自己聊的时候不判断
				SocketWrapper.wrapSend(function() Toast.show("请重新进入游戏，使配置生效") end, NetRequest.new("DoSome", {str = content}))
		    	return
			else
		    	Toast.show(CommonText[355][4])
				return
		    end
		end

		local content = WordMO.filterSensitiveWords(content)
		-- gprint("content",content)

	    local function doneCallback()
	    	Loading.getInstance():unshow()

	    	if container.chat_type == CHAT_TYPE_PRIVACY or container.chat_type == CHAT_TYPE_CALLCENTER then  -- 私聊、
		    	self:showChatUpdate(container.chat_type, UserMO.nickName_)
		    end
	    	container.input_edit_box:setText("")
	    	container.send_show_content = ""
	   end

	    Loading.getInstance():show()

		if container.chat_type == CHAT_TYPE_WORLD then  -- 世界
			ChatBO.asynDoChat(doneCallback, CHAT_TYPE_WORLD, nil, nil, content)
		elseif container.chat_type == CHAT_TYPE_PARTY then
			ChatBO.asynDoChat(doneCallback, CHAT_TYPE_PARTY, nil, nil, content)
		elseif container.chat_type == CHAT_TYPE_CALLCENTER then
			ChatBO.asynDoChat(doneCallback, CHAT_TYPE_CALLCENTER, nil, nil, content)
		elseif container.chat_type == CHAT_TYPE_PRIVACY then  -- 私聊
			ChatBO.asynDoChat(doneCallback, CHAT_TYPE_PRIVACY, ChatMO.curPrivacyLordId_, nil, content)
		elseif container.chat_type == CHAT_TYPE_CROSS then
			if UserMO.level_ < 70 then
				Loading.getInstance():unshow()
				Toast.show(string.format(CommonText[8028],70))
				return
			end
			ChatBO.asynDoChat(doneCallback, CHAT_TYPE_CROSS, nil, nil, content)
		end
	elseif container.show_state == 2 then -- 当前是公告
		if UserMO.gm_ == 0 and UserMO.guider_ == 0 then
			if UserMO.level_ < CHAT_HORN_OPEN_LEVEL then
				Toast.show(string.format(CommonText[290], CHAT_HORN_OPEN_LEVEL, CommonText[455]))
				return
			end
		end

		local content = WordMO.filterSensitiveWords(content)
		-- gprint("content",content)

		local function doneCallback()
			Loading.getInstance():unshow()
			
	    	container.input_edit_box:setText("")
	    	container.send_show_content = ""
		end

		local function gotoHorn(content)
			Loading.getInstance():show()
			PropBO.asynUseProp(doneCallback, PROP_ID_HORN_NORMAL, 1, content)
		end


		local propResData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_HORN_NORMAL)

		local count = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_HORN_NORMAL)
		if count <= 0 then  -- 使用金币购买
			local propDB = PropMO.queryPropById(PROP_ID_HORN_NORMAL)
			local coinResData = UserMO.getResourceData(ITEM_KIND_COIN)

			local function gotoBuyHorn()
				if UserMO.getResource(ITEM_KIND_COIN) < propDB.price then
					require("app.dialog.CoinTipDialog").new():push()
					return
				end
				Loading.getInstance():show()
				PropBO.asynBuyProp(function() gotoHorn(content) end, PROP_ID_HORN_NORMAL, 1)
			end

			if UserMO.consumeConfirm then
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText[312][1], propDB.price, coinResData.name, propResData.name), function() gotoBuyHorn() end):push()
			else
				gotoBuyHorn()
			end
		else
			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(string.format(CommonText[312][2], propResData.name), function()
					gotoHorn(content)
				end):push()
		end
	end
end

function ChatView:onSearchCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local editbox = sender.searchEditbox
    local content = string.gsub(editbox:getText(), " ", "")

    -- if content == CommonText[358] then editbox:setText("") return end
    if content == "" then Toast.show(CommonText[355][1]) return end

	local function doneSearch(man)
		Loading.getInstance():unshow()
		if man then -- 搜索到了
			ChatMO.curPrivacyLordId_ = man.lordId
			local container = sender.container_
			container.privacy_state = 2 -- 显示和搜索到的玩家聊天

			self:showPrivacy(container)
		else
			Toast.show(CommonText[355][3])  -- 角色不存在或不在线
		end
	end

	Loading.getInstance():show()
	ChatBO.asynSearchOl(doneSearch, content)
end

function ChatView:showChatUpdate(channel, nick)
	local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())

	gprint("ChatView:showChatUpdate channel:", channel, "nick:", nick)

	if channel then
		if channel == container.chat_type then
			if nick and nick == UserMO.nickName_ then -- 玩家自己发送的消息
				container.tableView:reloadData()
				self:onViewOffset(container.tableView)
			else
				local offset = container.tableView:getContentOffset()
				container.tableView:reloadData()
				self:onViewOffset(container.tableView, offset)
			end
		end
	end

	self:showUpdateTip()
end

function ChatView:onChatUpdate(event)
	local channel = event.obj.type
	local nick = event.obj.nick

	if self.m_chatUpdateScheduler then
		scheduler.unscheduleGlobal(self.m_chatUpdateScheduler)
		self.m_chatUpdateScheduler = nil
	end

	self.m_chatUpdateScheduler = scheduler.performWithDelayGlobal(function()
			self.m_chatUpdateScheduler = nil
			self:showChatUpdate(channel, nick)
		end, 0.3)
end

function ChatView:showUpdateTip()
	if not self.m_pageView then return end

	local num = ChatBO.getTypeUnreadChatNum(CHAT_TYPE_WORLD)  -- 世界
	if num > 0 then UiUtil.showTip(self.m_pageView, num, 140, self.m_pageView:getContentSize().height + 35, 40, "tip1__")
	else UiUtil.unshowTip(self.m_pageView, "tip1__") end

	if self.m_myParty then -- 有军团
		local num = ChatBO.getTypeUnreadChatNum(CHAT_TYPE_PARTY)  -- 军团
		gprint("ChatView:showUpdateTip unread num:", num)
		if num > 0 then UiUtil.showTip(self.m_pageView, num, 300, self.m_pageView:getContentSize().height + 35, 40, "tip2__")
		else UiUtil.unshowTip(self.m_pageView, "tip2__") end
	end

	local num = ChatBO.getTypeUnreadChatNum(CHAT_TYPE_PRIVACY)  -- 私聊
	if num > 0 then
		if self.m_myParty then
			UiUtil.showTip(self.m_pageView, num, 460, self.m_pageView:getContentSize().height + 35, 40, "tip3__")
		else
			UiUtil.showTip(self.m_pageView, num, 300, self.m_pageView:getContentSize().height + 35, 40, "tip3__")
		end
	else
		UiUtil.unshowTip(self.m_pageView, "tip3__")
	end

	if HunterMO.teamFightCrossData_.state ~= 1 then
		local num = ChatBO.getTypeUnreadChatNum(CHAT_TYPE_CROSS)  -- 跨服
		if num > 0 then
			if self.m_myParty then
				UiUtil.showTip(self.m_pageView, num, 460 + 160, self.m_pageView:getContentSize().height + 35, 40, "tip4__")
			else
				UiUtil.showTip(self.m_pageView, num, 300 + 160, self.m_pageView:getContentSize().height + 35, 40, "tip4__")
			end
		else
			UiUtil.unshowTip(self.m_pageView, "tip4__")
		end


		-- if num > 0 then UiUtil.showTip(self.m_pageView, num, 300, self.m_pageView:getContentSize().height + 35, 40, "tip4__")
		-- else UiUtil.unshowTip(self.m_pageView, "tip4__") end
	end
end

function ChatView:onViewOffset(tableView, offset)
	local maxOffset = tableView:maxContainerOffset()
	local minOffset = tableView:minContainerOffset()
	if minOffset.y > maxOffset.y or not offset then
	    local y = math.max(maxOffset.y, minOffset.y)
	    tableView:setContentOffset(cc.p(0, y))
    elseif offset then
	    tableView:setContentOffset(offset)
    end
end

return ChatView
