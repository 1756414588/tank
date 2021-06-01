
-- 联网出错弹出框

local NetErrorDialog = class("NetErrorDialog", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

local instance_ = nil

function NetErrorDialog.getInstance()
	if not instance_ then
		instance_ = NetErrorDialog.new()
	end
	return instance_
end

function NetErrorDialog:ctor()
	local bg = display.newScale9Sprite("image/common/bg_dlg_2.png"):addTo(self)
	bg:setPreferredSize(cc.size(550, 360))
	bg:setPosition(display.cx, display.cy)
	self.m_bg = bg

	self.touchLayer = display.newColorLayer(ccc4(0, 0, 0, 180)):addTo(self, -1)
	self.touchLayer:setContentSize(cc.size(display.width, display.height))
	self.touchLayer:setPosition(0, 0)
	nodeTouchEventProtocol(self.touchLayer, function(event) return true end, nil, nil, true)
end

function NetErrorDialog:show(msgData, callback, cancelCallback)
	local function onCloseCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if self.m_okBtn then
			self.m_okBtn:setEnabled(false)
		end
		if callback then
			callback()
		end
		self:removeSelf()
	end

	gdump(msgData, "NetErrorDialog")

	local parent = self:getParent()

	if parent then
		gprint("[NetErrorDialog] dialog added to parent already!!!")
	else
		local code = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, x = self.m_bg:getContentSize().width / 2, y = 280}):addTo(self.m_bg, 2)
		if msgData.code then
			code:setString("ERROR：" .. msgData.code)
		end
		
		local msg = ui.newTTFLabel({text = "", font = FONTS, size = FONT_SIZE_MEDIUM, x = self.m_bg:getContentSize().width / 2, y = 240, color = cc.c3b(255, 255, 255)}):addTo(self.m_bg, 2)
		if msgData.code and NetText["text" .. tostring(msgData.code)] then
			msg:setString(NetText["text" .. tostring(msgData.code)])
		elseif msgData.msg then
			msg:setString(msgData.msg)
		end

		local function onCancelCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			if cancelCallback then
				cancelCallback()
				self:removeSelf()
			else
				os.exit()
			end
		end
		-- 取消按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
		self.m_cancelBtn = MenuButton.new(normal, selected, disabled, onCancelCallback)  -- 取消
		self.m_cancelBtn:setLabel(ErrorText.textCancel)
		self.m_cancelBtn:setPosition(self.m_bg:getContentSize().width / 2 - 130, 100)
		self.m_bg:addChild(self.m_cancelBtn)

		-- 确定按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		self.m_okBtn = MenuButton.new(normal, selected, disabled, onCloseCallback)  -- 确定
		self.m_okBtn:setLabel(ErrorText.textOK)
		self.m_okBtn:setPosition(self.m_bg:getContentSize().width / 2 + 130, 100)
		self.m_bg:addChild(self.m_okBtn)

		local scene = display.getRunningScene()
		scene:addChild(self, 100)
	end
end

function NetErrorDialog:onExit()
	instance_ = nil
end

return NetErrorDialog
