
-- 道具赠送

local Dialog = require("app.dialog.Dialog")
local PropSendDialog = class("PropSendDialog", Dialog)

function PropSendDialog:ctor(propId, useCallback)
	PropSendDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 432)})

	self.m_propId = propId
	self.m_useCallback = useCallback
end

function PropSendDialog:onEnter()
	PropSendDialog.super.onEnter(self)
	self.m_names = 0
	local propCount = UserMO.getResource(ITEM_KIND_PROP, self.m_propId)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	-- local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.m_propId)

	self:setTitle(CommonText[458][1])

	-- local label = ui.newTTFLabel({text = CommonText[400][2], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 100, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	local function onEdit(event, editbox)
		-- if editbox:getText() == CommonText[458][2] then
		-- 	editbox:setText("")
		-- end

		local content = editbox:getText()
		local names = string.split(content, " && ")
		-- local num = #names * self.m_settingNum
		-- self.m_totalLabel:setPosition(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width, self.m_numLabel:getPositionY())
		-- if num > propCount then self.m_numLabel:setColor(COLOR[5]) else self.m_numLabel:setColor(COLOR[3]) end
		self.m_names = #names
		self.m_settingNum = 1
		self.m_numSlider:setSliderValue(self.m_settingNum)
		self.m_numLabel:setString(self.m_settingNum)
		self.m_maxNum = math.floor(self.m_canUseMax / self.m_names)
		self.m_numSlider.max_ = self.m_maxNum
		self.m_numSlider:onShowSlider()
    end

    local width = 340
    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

	local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	inputBg:setPreferredSize(cc.size(width + 20, height + 10))
	inputBg:setPosition(self:getBg():getContentSize().width / 2 - 30, self:getBg():getContentSize().height - 120)

    local inputName = ui.newEditBox({image = nil, listener = onEdit, size = cc.size(width, height)}):addTo(self:getBg())
	inputName:setFontColor(COLOR[1])
	-- inputName:setText(CommonText[458][2])
	inputName:setPlaceholderFontColor(COLOR[1])
    inputName:setPlaceHolder(CommonText[458][2])
	inputName:setPosition(self:getBg():getContentSize().width / 2 - 30, self:getBg():getContentSize().height - 120)
	self.m_inputMsg = inputName

	local function contactCallback(contacts)
		gdump(contacts, "contactCallback")
		self.m_names = #contacts
		-- local num = 0
		if contacts and #contacts > 0 then
			-- num = #contacts
			-- num = #contacts * self.m_settingNum

			local str = ""
			for index = 1, #contacts do
				local contact = contacts[index]

				if index ~= #contacts then
					str = str .. contact.name .. " && "
				else
					str = str .. contact.name
				end
			end
			self.m_inputMsg:setText(str)
			self.m_maxNum = math.floor(self.m_canUseMax / self.m_names)
		else
			self.m_inputMsg:setText("")
		end

		self.m_settingNum = 1
		self.m_numSlider:setSliderValue(self.m_settingNum)
		self.m_numLabel:setString(self.m_settingNum)
		-- self.m_totalLabel:setPosition(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width, self.m_numLabel:getPositionY())
		-- if num > propCount then self.m_numLabel:setColor(COLOR[5]) else self.m_numLabel:setColor(COLOR[3]) end
		self.m_numSlider.max_ = self.m_maxNum 
		self.m_numSlider:onShowSlider()
	end

	local function gotoContact(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ContactDialog = require("app.dialog.ContactDialog")
		ContactDialog.new(CONTACT_MODE_MULTIPLE, contactCallback):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_search_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_search_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoContact):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width - 90, self:getBg():getContentSize().height - 120)

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self:getBg():getContentSize().width / 2, y = 260, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(1, 0.5))

	-- 
	local count = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = count

	local desc = UiUtil.label(CommonText[1821],16):addTo(self:getBg())
	desc:setPosition(label:x() - 10,label:y() - 90)
	desc:setAnchorPoint(cc.p(0.5,0.5))

	-- local total = ui.newTTFLabel({text = "/" .. propCount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	-- total:setAnchorPoint(cc.p(0, 0.5))
	-- self.m_totalLabel = total

	-- self.m_settingNum = 1
	-- self.m_numLabel:setString(1)
	-- self.m_totalLabel:setPosition(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width, self.m_numLabel:getPositionY())

 	local barHeight = 40
	local barWidth = 266

 --    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    -- reduceBtn:setPosition(label:x() - 130,label:y())
    reduceBtn:setPosition(self:getBg():width() / 2 - 200, 218)
    reduceBtn:setScale(0.8)

 --    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(label:x() + 200,218)
    addBtn:setScale(0.8)

    self.m_maxNum = propCount
    self.m_canUseMax = propCount
    self.m_minNum = 1
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM self.m_canUseMax = PROP_BUY_MAX_NUM end
	self.m_settingNum = self.m_minNum

	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 200)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(266 + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})

	local function onCancelCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:pop()
	end

	-- 取消按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	self.m_cancelBtn = MenuButton.new(normal, selected, nil, onCancelCallback):addTo(self:getBg())  -- 取消
	self.m_cancelBtn:setLabel(CommonText[2])
	self.m_cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 130, 90)

	local function onOkCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		if self.m_inputMsg:getText() == CommonText[458][2] then
			self.m_inputMsg:setText("")
			return
		end

	    local content = string.trim(self.m_inputMsg:getText())

		if content == "" then
			Toast.show(CommonText[355][1])
			return
		end

		local names = string.split(content, " && ")
		-- dump(names, "onOkCallback")

		local sendContent = ""

		for index = 1, #names do
			local name = names[index]
			name = string.gsub(name, " ", "")

			if string.find(name, "&") then
				Toast.show(CommonText[355][4])
				return
			elseif name == UserMO.nickName_ then  -- 不能给自己发送红包
				Toast.show(CommonText[458][3])
				return
			elseif name == "" then
				Toast.show(CommonText[458][4])
				return
			end
			if index == #names then
				sendContent = sendContent .. name
			else
				sendContent = sendContent .. name .. "&"
			end
		end

		-- print("sendContent:", sendContent)
	    local cost = self.m_settingNum * #names
		if cost > propCount then
			local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.m_propId)
			Toast.show(resData.name .. CommonText[223])
			return
		end

		if self.m_settingNum == 0 then
			Toast.show(CommonText[1817])
			return
		end

	    local function doneUseProp()
		    Loading.getInstance():unshow()
	    	if self.m_useCallback then self.m_useCallback() end
	    	self:pop()
	    end

	    Loading.getInstance():show()
	    PropBO.asynUseProp(doneUseProp, self.m_propId, cost, sendContent)
	end

	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	self.m_okBtn = MenuButton.new(normal, selected, nil, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2 + 130, 90)
end

function PropSendDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	if self.m_settingNum <= 1 then
		self.m_settingNum = 1
	end
	self.m_numSlider:setSliderValue(self.m_settingNum)
	self.m_numLabel:setString(self.m_settingNum)
end

function PropSendDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	if self.m_settingNum >= self.m_maxNum then
		self.m_settingNum = self.m_maxNum
	end
	self.m_numSlider:setSliderValue(self.m_settingNum)
	self.m_numLabel:setString(self.m_settingNum)
end

function PropSendDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	-- self.m_totalLabel:setPosition(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width, self.m_numLabel:getPositionY())
end

return PropSendDialog
