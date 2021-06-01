--
-- Author: gf
-- Date: 2016-04-20 10:51:03
--


-- 军团铭牌道具修改昵称弹出框

require("app.text.CommonText")

local Dialog = require("app.dialog.Dialog")
local PartyNameChangeDialog = class("PartyNameChangeDialog", Dialog)

function PartyNameChangeDialog:ctor(propId, useCallback)
	PartyNameChangeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_propId = propId
	self.m_useCallback = useCallback
end

function PartyNameChangeDialog:onEnter()
	PartyNameChangeDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.m_propId)

	self:setTitle(resData.name)

	-- local label = ui.newTTFLabel({text = CommonText[400][2], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 100, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	local function onEdit(event, editbox)
		-- if editbox:getText() == CommonText[569][2] then
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
	-- inputName:setText(CommonText[569][2])
	inputName:setPlaceholderFontColor(COLOR[1])
    inputName:setPlaceHolder(CommonText[569][2])
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

		--判断名称
		local partyName = string.gsub(self.m_inputMsg:getText()," ","")
		if partyName == "" then
	        Toast.show(CommonText[572][3])
	        return
	    end
	    
	    if WordMO.isSensitiveWords(partyName) == true then
	    	Toast.show(CommonText[572][4])
	    	return
	    end

	    local length = string.utf8len(partyName)

	    if length < 2 or length > 6 then
	        Toast.show(CommonText[569][2])
	    	return
	    end

	    local function doneUseProp()
		    Loading.getInstance():unshow()
	    	if self.m_useCallback then self.m_useCallback() end
	    	self:pop()
	    end

	    Loading.getInstance():show()
	    PropBO.asynUseProp(doneUseProp, self.m_propId, 1, partyName)
	end

	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2 + 130, 90)
end

return PartyNameChangeDialog
