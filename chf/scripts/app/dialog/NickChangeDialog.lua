
-- 身份铭牌道具修改昵称弹出框

require("app.text.LoginText")

local Dialog = require("app.dialog.Dialog")
local NickChangeDialog = class("NickChangeDialog", Dialog)

function NickChangeDialog:ctor(propId, useCallback)
	NickChangeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_propId = propId
	self.m_useCallback = useCallback
end

function NickChangeDialog:onEnter()
	NickChangeDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.m_propId)

	self:setTitle(resData.name)

	-- local label = ui.newTTFLabel({text = CommonText[400][2], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 100, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	local function onEdit(event, editbox)
		-- if editbox:getText() == CommonText[450][1] then
		-- 	editbox:setText("")
		-- 	return
		-- end
    end

    local width = 340
    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

	local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	inputBg:setPreferredSize(cc.size(width + 20, height + 10))
	inputBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 170)

    local inputName = ui.newEditBox({image = nil, listener = onEdit, size = cc.size(width, height)}):addTo(self:getBg())
	inputName:setFontColor(COLOR[1])
	-- inputName:setText(CommonText[450][3])
	inputName:setPlaceholderFontColor(COLOR[1])
    inputName:setPlaceHolder(CommonText[450][3])
	inputName:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 170)
	self.m_inputMsg = inputName

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

		local nick = string.gsub(self.m_inputMsg:getText()," ","")

		-- if nick == CommonText[450][3] then
		-- 	self.m_inputMsg:setText("")
		-- 	return
		-- end

	    if nick == "" or nick == LoginText[30] or nick == UserMO.nickName_ then
	        Toast.show(LoginText[30])
	        return
	    end

	    if WordMO.isSensitiveWords(nick) then
	    	Toast.show(LoginText[38])
	    	return
	    end

	    local length = string.utf8len(nick)
	    -- local length = string.utf8len(nick)
	    -- gprint("length:", length)
	    if length > NAME_MAX_LEN or length < NAME_MIN_LEN then
	        Toast.show(string.format(LoginText[37], NAME_MAX_LEN, NAME_MIN_LEN))
	        return
	    end

        local ok = LoginBO.checkNickName(nick)
        if not ok then
            Toast.show(LoginText[40])  -- 角色昵称只能包含中文、英文和数字
            return
        end

	    local function doneUseProp()
		    Loading.getInstance():unshow()
	    	if self.m_useCallback then self.m_useCallback() end
	    	self:pop()
	    end

	    Loading.getInstance():show()
	    PropBO.asynUseProp(doneUseProp, self.m_propId, 1, nick)
	end

	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2 + 130, 90)
end

return NickChangeDialog
