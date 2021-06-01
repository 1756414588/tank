--
-- Author: gf
-- Date: 2015-09-17 16:09:03
-- 职位编辑

local Dialog = require("app.dialog.Dialog")
local PartyJobEditDialog = class("PartyJobEditDialog", Dialog)

function PartyJobEditDialog:ctor()
	PartyJobEditDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function PartyJobEditDialog:onEnter()
	PartyJobEditDialog.super.onEnter(self)

	self:setTitle(CommonText[622][3])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	
	local titLab = ui.newTTFLabel({text = CommonText[625][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = btm:getContentSize().height - 60, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	titLab:setAnchorPoint(cc.p(0, 0.5))

	self.inputNameList = {}
	for index=1,#CommonText[626] do
		local nameLab = ui.newTTFLabel({text = CommonText[626][index], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = btm:getContentSize().height - 120 - (index - 1) * 80, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		nameLab:setAnchorPoint(cc.p(0, 0.5))

		--输入框
		local function onEdit(event, editbox)
		--    if eventType == "return" then
		--    end
	    end

	    local width = 340
	    local height = UiUtil.getEditBoxHeight(FONT_SIZE_BIG)

	    local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
		inputBg:setPreferredSize(cc.size(width + 20, height + 10))
		inputBg:setPosition(nameLab:getPositionX() + nameLab:getContentSize().width + width / 2, nameLab:getPositionY())

		local inputName = ui.newEditBox({x = nameLab:getPositionX() + nameLab:getContentSize().width + width / 2, y = nameLab:getPositionY(), size = cc.size(width, height), listener = onEdit}):addTo(btm)

		if PartyMO.partyData_.partyLv < PARTY_CUSTOM_JOB_LV[index] then
			inputName:setText(string.format(CommonText[628],PARTY_CUSTOM_JOB_LV[index]))
			inputName:setFontColor(COLOR[11])
		else
			inputName:setText(PartyMO.partyData_["jobName" .. index])
			inputName:setFontColor(COLOR[1])
		end
		inputName:setEnabled(PartyMO.partyData_.partyLv >= PARTY_CUSTOM_JOB_LV[index])
		self.inputNameList[#self.inputNameList + 1] = inputName

		--人数
		local countLab = ui.newTTFLabel({text = PartyMO.partyJobCount["job" .. index] .. "/3", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 470, y = inputName:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		countLab:setAnchorPoint(cc.p(0, 0.5))

	end

	for index=1,#CommonText[627] do
		local nameLab = ui.newTTFLabel({text = CommonText[627][index], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = btm:getContentSize().height - 450 - (index - 1) * 30, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		nameLab:setAnchorPoint(cc.p(0, 0.5))
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local saveBtn = MenuButton.new(normal, selected, nil, handler(self,self.saveHandler)):addTo(self:getBg())
	saveBtn:setPosition(self:getBg():getContentSize().width / 2 + 120,20)
	saveBtn:setLabel(CommonText[1])


	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local cancelBtn = MenuButton.new(normal, selected, nil, handler(self,self.cancelHandler)):addTo(self:getBg())
	cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 120,20)
	cancelBtn:setLabel(CommonText[2])

end

function PartyJobEditDialog:saveHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local jobNames = {}
	local canSave = true
	for index=1,#self.inputNameList do
		local name = ""
		local inputName = self.inputNameList[index]
		if inputName:isEnabled() then
			name = inputName:getText()
		end
		if string.utf8len(name) > 4 then
			canSave = false
			break
		end
		jobNames[#jobNames + 1] = name
	end
	
	--判断字符长度
	if canSave == false then
		Toast.show(CommonText[630])
		return
	end

	Loading.getInstance():show()
	PartyBO.asynSetPartyJob(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[629])
		end,jobNames[1],jobNames[2],jobNames[3],jobNames[4])
end

function PartyJobEditDialog:cancelHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
end

return PartyJobEditDialog