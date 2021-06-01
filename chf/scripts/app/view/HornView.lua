
-- 界面上显示的喇叭

local HornView = class("HornView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

-- local instance_ = nil

function HornView:ctor(chat, endCallback)
	self.m_chat = chat
	-- self.m_endCallback = endCallback
	gdump(self.m_chat, "HornView")
end

function HornView:onEnter()
	local bg = nil
	local propId = 0

	if self.m_chat.style == 1 then  -- 普通喇叭
		bg = display.newSprite(IMAGE_COMMON .. "info_bg_38.png")
		propId = PROP_ID_HORN_NORMAL
	elseif self.m_chat.style == 2 then  -- 求爱
		bg = display.newSprite(IMAGE_COMMON .. "info_bg_38.png")
		-- bg = display.newSprite(IMAGE_COMMON .. "info_bg_57.png")
		propId = PROP_ID_HORN_LOVE
	elseif self.m_chat.style == 3 then  -- 祝福
		propId = PROP_ID_HORN_BLESS
		bg = display.newSprite(IMAGE_COMMON .. "info_bg_38.png")
		-- bg = display.newSprite(IMAGE_COMMON .. "info_bg_58.png")
	elseif self.m_chat.style == 4 then  -- 生日
		propId = PROP_ID_HORN_BIRTH
		bg = display.newSprite(IMAGE_COMMON .. "info_bg_38.png")
		-- bg = display.newSprite(IMAGE_COMMON .. "info_bg_59.png")
	end

	if not bg then
		error("HornView bg is nul")
	end

	bg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
	bg:addTo(self)
	self:setContentSize(bg:getContentSize())
	self:setAnchorPoint(cc.p(0.5, 0.5))

	-- 道具
	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, propId):addTo(self)
	itemView:setScale(0.5)
	itemView:setPosition(itemView:getBoundingBox().size.width / 2 + 15, self:getContentSize().height / 2)

	local name = nil
	if self.m_chat.isGm then  -- 系统管理员
		name = ui.newTTFLabel({text = CommonText[548][4] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 70, y = self:getContentSize().height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self)
	elseif self.m_chat.sysId > 0 then  -- 系统
		name = ui.newTTFLabel({text = CommonText[548][4] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 70, y = self:getContentSize().height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self)
	else -- 名称
		name = ui.newTTFLabel({text = self.m_chat.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 70, y = self:getContentSize().height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self)
	end
	name:setAnchorPoint(cc.p(0, 0.5))

	local rect = cc.rect(0, 0, self:getContentSize().width - name:getPositionX() - name:getContentSize().width - 10, self:getContentSize().height)
	local clipNode = display.newClippingRegionNode(rect):addTo(self)
	clipNode:setPosition(self:getContentSize().width - rect.size.width, 0)

	-- local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(clipNode)
	-- bg:setAnchorPoint(cc.p(0.5, 0.5))
	-- bg:setPreferredSize(cc.size(rect.size.width, rect.size.height))
	-- bg:setPosition(rect.size.width / 2, rect.size.height / 2)

	local stringDatas = {}
	if self.m_chat.sysId > 0 then
		stringDatas = ChatBO.formatChat(self.m_chat)
		for index = 1, #stringDatas do
			stringDatas[index].click = nil
		end
	else
		stringDatas[1] = {["content"] = self.m_chat.msg}
	end

	-- 信息
	-- local msg = ui.newTTFLabel({text = self.m_chat.msg, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(clipNode)
	-- msg:setAnchorPoint(cc.p(0, 0.5))
	-- self.m_msg = msg

	-- local distance = rect.size.width + msg:getContentSize().width
	-- local time = distance / 45  -- 每秒的速度
	-- self.m_msg:setPosition(rect.size.width, rect.size.height / 2)
	-- self.m_msg:runAction(transition.sequence({cc.MoveBy:create(time, cc.p(-distance, 0)), cc.DelayTime:create(0.3),
	-- 	cc.CallFuncN:create(function(sender)
	-- 			if self.m_endCallback then
	-- 				self.m_endCallback(sender)
	-- 			end
	-- 		end)}))

	local msg = RichLabel.new(stringDatas):addTo(clipNode)
	self.m_msg = msg
	
	local distance = rect.size.width + msg:getWidth()
	local time = distance / 45  -- 每秒的速度
	self.m_msg:setPosition(rect.size.width, (rect.size.height + msg:getHeight()) / 2)
	self.m_msg:runAction(transition.sequence({cc.MoveBy:create(time, cc.p(-distance, 0)), cc.DelayTime:create(0.3),
		cc.CallFuncN:create(function(sender)
				self:removeSelf()
				-- if self.m_endCallback then
				-- 	self.m_endCallback(sender)
				-- end
			end)}))

	-- local infoNode = display.newNode():addTo(self)
	-- infoNode:setPosition(100, self:getContentSize().height / 2)

	-- if self.m_chat.style == 1 or self.m_chat.style == 2 or self.m_chat.style == 3 or self.m_chat.style == 4 then
	-- 	-- 名称
	-- 	local name = ui.newTTFLabel({text = "[" .. self.m_chat.name .. "]", font = G_FONT, size = FONT_SIZE_SMALL, x = 0, y = 0, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoNode)
	-- 	name:setAnchorPoint(cc.p(0, 0.5))

	-- 	-- 信息
	-- 	local msg = ui.newTTFLabel({text = self.m_chat.msg, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(infoNode)
	-- 	msg:setAnchorPoint(cc.p(0, 0.5))
	-- end
end

function HornView:onExit()
    -- gprint("AwardsView.onExit()")
    instance_ = nil
end

function HornView.show(chat)
    if instance_ then
        instance_:removeSelf()
        instance_ = nil
    end

    local scene = display.getRunningScene()
    if scene then
        local view = HornView.new(chat):addTo(scene, 10000)
        view:setPosition(display.cx, display.height - 140)
        instance_ = view
    end
end


return HornView
