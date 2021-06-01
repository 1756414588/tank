
local Dialog = require("app.dialog.Dialog")
local ADConfirmDialog = class("ADConfirmDialog", Dialog)


--adType  广告类型 1 体力 2 统率书
function ADConfirmDialog:ctor(desc, okCallback, cancelCallback)
	ADConfirmDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 350)})

	desc = desc or ""
	self.m_desc = desc
	self.m_okCallback = okCallback
	self.m_cancelCallback = cancelCallback
end

function ADConfirmDialog:onEnter()
	ADConfirmDialog.super.onEnter(self)

	-- 点击了确定或者取消按钮后就立即关闭弹出框
	self.m_isClickClose = true
	self:setOutOfBgClose(true)

	self.m_contentNode = display.newNode():addTo(self:getBg())
	self.m_contentNode:setPosition(self:getBg():getContentSize().width / 2, 290)

	self.m_descLabel = ui.newTTFLabel({text = self.m_desc, font = G_FONT, size = FONT_SIZE_MEDIUM,
		dimensions = cc.size(0, 0), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_contentNode)

	if self.m_descLabel:getContentSize().width > 450 then
		self.m_descLabel:setDimensions(cc.size(450, 200))
	end

	local function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		UserMO.consumeConfirm = not isChecked
		
		writefile(GAME_SETTING_FILE .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId, json.encode({ManagerSound.musicEnable, ManagerSound.soundEnable, UserMO.autoDefend, UserMO.consumeConfirm, UserMO.showBuildName, UserMO.showArmyLine, UserMO.showPintUI}))
	end

	local checkBox = CheckBox.new(nil, nil, onCheckedChanged):addTo(self:getBg())
	checkBox:setPosition(self:getBg():getContentSize().width / 2 - 50, 235)

	-- 不再提示
	local tip = ui.newTTFLabel({text = CommonText[497], font = G_FONT, size = FONT_SIZESMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(self:getBg())
	tip:setPosition(self:getBg():getContentSize().width / 2 + 30, 235)

	local function onCancelCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if self.m_isClickClose then
			self:pop(self.m_cancelCallback)
		else
			if self.m_cancelCallback then self.m_cancelCallback() end
		end
	end

	-- 取消按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	self.m_cancelBtn = MenuButton.new(normal, selected, disabled, onCancelCallback):addTo(self:getBg())  -- 取消
	self.m_cancelBtn:setLabel(CommonText[2])
	self.m_cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 130, 150)

	local function onOkCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if self.m_isClickClose then
			self:pop(self.m_okCallback)
		else
			if self.m_okCallback then self.m_okCallback() end
		end
	end

	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2 + 130, 150)


	-- 播放广告按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	self.m_adBtn = MenuButton.new(normal, selected, disabled, handler(self, self.playAdHandle)):addTo(self:getBg())  -- 确定
	self.m_adBtn:setPosition(self:getBg():getContentSize().width / 2 +  130, 60)
	self.m_adBtn:setLabel(CommonText.MuzhiAD[1][2])
	self.m_adBtn.m_label:setPositionX(self.m_adBtn.m_label:getPositionX() + 20)
	display.newSprite(IMAGE_COMMON.."free.png"):addTo(self.m_adBtn):pos(45,58)
	display.newSprite(IMAGE_COMMON.."playAD.png"):addTo(self.m_adBtn):pos(75,50)


	--提示
	local tipAd = ui.newTTFLabel({text = "", font = G_FONT, size = 18, align = ui.TEXT_ALIGN_RIGHT, color = cc.c3b(68, 182, 9)}):addTo(self:getBg())
	tipAd:setPosition(self:getBg():getContentSize().width -  250, 60)
	tipAd:setAnchorPoint(cc.p(1, 0.5))
	tipAd:setString(string.format(CommonText.MuzhiAD[4][2],MZAD_ADD_COMMAND_MAX))

	
end

function ADConfirmDialog:playAdHandle()
	ServiceBO.playMzAD(MZAD_TYPE_VIDEO,function()
		Loading.getInstance():show()
		MuzhiADBO.PlayAddCommandAD(function()
			Loading.getInstance():unshow()
			self:pop()
		end)
		
	end)
end

function ADConfirmDialog:setCancelBtnText(text)
	if not text then return end
	self.m_cancelBtn:setLabel(text)
end

function ADConfirmDialog:setOkBtnText(text)
	if not text then return end

	self.m_okBtn:setLabel(text)
end

return ADConfirmDialog

