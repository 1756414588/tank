
-- 定位仪道具使用

local Dialog = require("app.dialog.Dialog")
local IndicatorUseDialog = class("IndicatorUseDialog", Dialog)

function IndicatorUseDialog:ctor(propId, useCallback)
	IndicatorUseDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_propId = propId
	self.m_useCallback = useCallback
end

function IndicatorUseDialog:onEnter()
	IndicatorUseDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	if self.m_propId < 0 then
		self:setTitle(CommonText[601][4])
	else
		local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.m_propId)

		self:setTitle(resData.name)
	end

	-- local label = ui.newTTFLabel({text = CommonText[400][2], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 100, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	local tips = self.m_propId < 0 and CommonText[20039] or CommonText[450][1]
	local function onEdit(event, editbox)
		-- if editbox:getText() == tips then
		-- 	editbox:setText("")
		-- 	return
		-- end
    end

    local width = 340
    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

	local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	inputBg:setPreferredSize(cc.size(width + 20, height + 10))
	inputBg:setPosition(self:getBg():getContentSize().width / 2 - 30, self:getBg():getContentSize().height - 170)

    local inputName = ui.newEditBox({image = nil, listener = onEdit, size = cc.size(width, height)}):addTo(self:getBg())
	inputName:setFontColor(COLOR[1])
	-- inputName:setText(tips)
	inputName:setPlaceholderFontColor(COLOR[1])
    inputName:setPlaceHolder(tips)
	inputName:setPosition(self:getBg():getContentSize().width / 2 - 30, self:getBg():getContentSize().height - 170)
	self.m_inputMsg = inputName

	local function contactCallback(contacts)
		gdump(contacts, "contactCallback")
		if contacts and #contacts > 0 then
			self.m_inputMsg:setText(contacts[1].name)
		end
	end

	local function gotoContact(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ContactDialog = require("app.dialog.ContactDialog")
		ContactDialog.new(CONTACT_MODE_SINGLE, contactCallback, nil, self.m_propId < 0):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_search_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_search_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoContact):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width - 90, self:getBg():getContentSize().height - 170)

	local function onCancelCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:pop()
	end

	-- 取消按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	self.m_cancelBtn = MenuButton.new(normal, selected, disabled, onCancelCallback):addTo(self:getBg())  -- 取消
	self.m_cancelBtn:setLabel(CommonText[2])
	self.m_cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 130, 90)

	local function onOkCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		-- if self.m_inputMsg:getText() == CommonText[450][1] then
		-- 	self.m_inputMsg:setText("")
		-- 	return
		-- end

	    local content = string.trim(self.m_inputMsg:getText())

		if content == "" then
			Toast.show(CommonText[355][1])
			return
		end
		
		if self.m_propId < 0 then
			require("app.dialog.AppointDetail").new(-self.m_propId,function()
				FortressBO.appoint(-self.m_propId,content,self.m_useCallback)
			end):push()
			return
		end

		if content == UserMO.nickName_ then
			self.m_inputMsg:setText("")
			return
		end

	    local function doneUseProp()
		    Loading.getInstance():unshow()
	    	if self.m_useCallback then self.m_useCallback() end
	    	self:pop()
	    end

	    Loading.getInstance():show()
	    PropBO.asynUseProp(doneUseProp, self.m_propId, 1, content)
	end

	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2 + 130, 90)
end

return IndicatorUseDialog
