--
-- Author: gf
-- Date: 2015-09-18 14:44:01
-- 军团成员职位变更


local ConfirmDialog = require("app.dialog.ConfirmDialog")
local Dialog = require("app.dialog.Dialog")
local PartyMemberJobSetDialog = class("PartyMemberJobSetDialog", Dialog)

function PartyMemberJobSetDialog:ctor(member)
	PartyMemberJobSetDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.member = member
end

function PartyMemberJobSetDialog:onEnter()
	PartyMemberJobSetDialog.super.onEnter(self)

	self:setTitle(CommonText[652])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	
	local lab = ui.newTTFLabel({text = CommonText[653][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = btm:getContentSize().height - 70, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	lab:setAnchorPoint(cc.p(0, 0.5))

	local lab1 = ui.newTTFLabel({text = CommonText[653][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = btm:getContentSize().height - 240, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	lab1:setAnchorPoint(cc.p(0, 0.5))


	self.m_jobCheckBoxs = {}
	for index = 1, 6 do
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onJobCheckedChanged)):addTo(btm)
		local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(btm)
		info:setAnchorPoint(cc.p(0,0.5))

		if index < 3 then
			checkBox:setPosition(80,lab:getPositionY() - 60 - (index - 1) * 60)
		else
			checkBox:setPosition(80,lab:getPositionY() - 110 - (index - 1) * 60)
		end
		
		checkBox.index = index
		info:setPosition(checkBox:getPositionX() + checkBox:getContentSize().width,checkBox:getPositionY())
		if index == 1 then
			info:setString(CommonText[639][2])
		elseif index == 2 then
			info:setString(CommonText[639][3])
		else
			local name
			if PartyMO.partyData_.partyLv < PARTY_CUSTOM_JOB_LV[index - 2] then
				name = string.format(CommonText[628],PARTY_CUSTOM_JOB_LV[index - 2])
				info:setColor(COLOR[11])
			else
				name = PartyMO.partyData_["jobName" .. (index - 2)]
				info:setColor(COLOR[1])
			end
			checkBox:setEnabled(PartyMO.partyData_.partyLv >= PARTY_CUSTOM_JOB_LV[index - 2])
			info:setString(name)
		end
		
		self.m_jobCheckBoxs[index] = checkBox
	end
	if self.member.job == PARTY_JOB_OFFICAIL then
		self.m_jobCheckBoxs[1]:setChecked(true)
	elseif self.member.job == PARTY_JOB_MEMBER then
		self.m_jobCheckBoxs[2]:setChecked(true)
	elseif self.member.job == PARTY_JOB_CUSTOM_1 then
		self.m_jobCheckBoxs[3]:setChecked(true)
	elseif self.member.job == PARTY_JOB_CUSTOM_2 then
		self.m_jobCheckBoxs[4]:setChecked(true)
	elseif self.member.job == PARTY_JOB_CUSTOM_3 then
		self.m_jobCheckBoxs[5]:setChecked(true)
	elseif self.member.job == PARTY_JOB_CUSTOM_4 then
		self.m_jobCheckBoxs[6]:setChecked(true)
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

function PartyMemberJobSetDialog:onJobCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	for index = 1,#self.m_jobCheckBoxs do
		if index == sender.index then
			self.m_jobCheckBoxs[index]:setChecked(true)
		else
			self.m_jobCheckBoxs[index]:setChecked(false)
		end
	end

end

function PartyMemberJobSetDialog:saveHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local job
	if self.m_jobCheckBoxs[1]:isChecked() then
    	job = PARTY_JOB_OFFICAIL
    elseif self.m_jobCheckBoxs[2]:isChecked() then
    	job = PARTY_JOB_MEMBER
    elseif self.m_jobCheckBoxs[3]:isChecked() then
    	job = PARTY_JOB_CUSTOM_1
    elseif self.m_jobCheckBoxs[4]:isChecked() then
    	job = PARTY_JOB_CUSTOM_2
    elseif self.m_jobCheckBoxs[5]:isChecked() then
    	job = PARTY_JOB_CUSTOM_3
    elseif self.m_jobCheckBoxs[6]:isChecked() then
    	job = PARTY_JOB_CUSTOM_4
    end

	Loading.getInstance():show()
	PartyBO.asynSetMemberJob(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[629])
		end,self.member,job)
end

function PartyMemberJobSetDialog:cancelHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
end

return PartyMemberJobSetDialog