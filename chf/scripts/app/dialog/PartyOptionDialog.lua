--
-- Author: gf
-- Date: 2015-09-17 17:20:18
--

local Dialog = require("app.dialog.Dialog")
local PartyOptionDialog = class("PartyOptionDialog", Dialog)

function PartyOptionDialog:ctor()
	PartyOptionDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function PartyOptionDialog:onEnter()
	PartyOptionDialog.super.onEnter(self)

	self:setTitle(CommonText[622][4])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local lab = ui.newTTFLabel({text = CommonText[631][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = btm:getContentSize().height - 70, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	lab:setAnchorPoint(cc.p(0, 0.5))

	self.m_joinCheckBoxs = {}
	for index = 1, 2 do
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onJoinCheckedChanged)):addTo(btm)
		local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(btm)
		info:setAnchorPoint(cc.p(0,0.5))
		if index == 1 then
			checkBox:setPosition(80,lab:getPositionY() - 60)
		else
			checkBox:setPosition(80,lab:getPositionY() - 120)
		end
		checkBox.index = index
		info:setPosition(checkBox:getPositionX() + checkBox:getContentSize().width,checkBox:getPositionY())
		info:setString(CommonText[570][index])
		self.m_joinCheckBoxs[index] = checkBox
	end

	self.m_joinCheckBoxs[PartyMO.partyData_.applyType]:setChecked(true)


	local lab1 = ui.newTTFLabel({text = CommonText[631][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = lab:getPositionY() - 180, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	lab1:setAnchorPoint(cc.p(0, 0.5))

	self.m_conditionCheckBoxs = {}
	for index = 1, 2 do
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onConditionCheckedChanged)):addTo(btm)
		local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(btm)
		info:setAnchorPoint(cc.p(0,0.5))
		if index == 1 then
			checkBox:setPosition(80,lab1:getPositionY() - 60)
		else
			checkBox:setPosition(80,lab1:getPositionY() - 120)
		end
		checkBox.index = index
		info:setPosition(checkBox:getPositionX() + checkBox:getContentSize().width,checkBox:getPositionY())
		info:setString(CommonText[632][index])
		

		local valueBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
		valueBg:setPreferredSize(cc.size(300, 45))
		valueBg:setPosition(info:getPositionX() + 220, checkBox:getPositionY())



		local valueLab = ui.newTTFLabel({text = 0, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(valueBg)
		valueLab:setPosition(valueBg:getContentSize().width / 2,valueBg:getContentSize().height / 2)
		checkBox.valueLab = valueLab

		nodeTouchEventProtocol(valueBg, function(event) 
			local KeyBoardDialog = require("app.dialog.KeyBoardDialog")
			KeyBoardDialog.new(function(numValue)
					valueLab:setString(numValue)
				end,12):push()
		 end, nil, nil, true)
		self.m_conditionCheckBoxs[index] = checkBox
	end
	if PartyMO.partyData_.applyLv > 0 then
		self.m_conditionCheckBoxs[1]:setChecked(true)
		self.m_conditionCheckBoxs[1].valueLab:setString(PartyMO.partyData_.applyLv)
	end
	if PartyMO.partyData_.applyFight > 0 then
		self.m_conditionCheckBoxs[2]:setChecked(true)
		self.m_conditionCheckBoxs[2].valueLab:setString(PartyMO.partyData_.applyFight)
	end
	

	local sloganBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(btm)
	sloganBg:setPreferredSize(cc.size(500, 250))
	sloganBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - sloganBg:getContentSize().height - 300)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		sloganBg:getContentSize().width / 2, sloganBg:getContentSize().height):addTo(sloganBg)

	local sloganLab = ui.newTTFLabel({text = CommonText[571][8], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	local sloganValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[1], 
   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
   		dimensions = cc.size(sloganBg:getContentSize().width - 20, 150)}):addTo(sloganBg)
	sloganValue:setAnchorPoint(cc.p(0, 1))
	self.sloganValue = sloganValue

	sloganValue:setString(PartyMO.partyData_.slogan)
	sloganValue:setPosition(10,sloganBg:getContentSize().height - 30)

	local function onEdit1(event, editbox)
	   if event == "return" then
	   		sloganValue:setString(editbox:getText())
	   		editbox:setText("")
	   		editbox:setVisible(true)
	   elseif event == "began" then
	   		editbox:setVisible(false)
	   		editbox:setText(sloganValue:getString())
	   end
    end

	local inputContent = ui.newEditBox({image = nil, listener = onEdit1, size = cc.size(sloganBg:getContentSize().width, 200)}):addTo(sloganBg)
	inputContent:setFontColor(COLOR[1])
	inputContent:setFontSize(FONT_SIZE_SMALL)
	inputContent:setPosition(sloganBg:getContentSize().width / 2, sloganBg:getContentSize().height / 2)
	
	--保存按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local saveBtn = MenuButton.new(normal, selected, nil, handler(self,self.saveHandler)):addTo(self:getBg())
	saveBtn:setPosition(self:getBg():getContentSize().width / 2,20)
	saveBtn:setLabel(CommonText[622][2])
end

function PartyOptionDialog:onJoinCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	for index = 1,#self.m_joinCheckBoxs do
		if index == sender.index then
			self.m_joinCheckBoxs[index]:setChecked(true)
		else
			self.m_joinCheckBoxs[index]:setChecked(false)
		end
	end

end

function PartyOptionDialog:onConditionCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
end

function PartyOptionDialog:saveHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local applyType,applyLv,fight,slogan
    if self.m_joinCheckBoxs[1]:isChecked() then
    	applyType = PARTY_JOIN_TYPE_1
    else
    	applyType = PARTY_JOIN_TYPE_2
    end

    if self.m_conditionCheckBoxs[1]:isChecked() then
    	applyLv = self.m_conditionCheckBoxs[1].valueLab:getString()
    else
    	applyLv = 0
    end

    if self.m_conditionCheckBoxs[2]:isChecked() then
    	fight = self.m_conditionCheckBoxs[2].valueLab:getString()
    else
    	fight = 0
    end

    slogan = self.sloganValue:getString()
    local length = string.utf8len(slogan)
    if length > 80 then
    	Toast.show(string.format(CommonText[719],80))
    	return
    end
    if WordMO.filterSensitiveWords(slogan) == true then
    	Toast.show(CommonText[718])
    	return
    end

	Loading.getInstance():show()
	PartyBO.asynPartyApplyEdit(function()
		Loading.getInstance():unshow()
		self:pop()
		end,applyType,applyLv,fight,slogan)
end

function PartyOptionDialog:cancelHandler(tag, sender)
	self:pop()
end

return PartyOptionDialog