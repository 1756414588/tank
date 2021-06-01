
-- 章节副本奖励

local Dialog = require("app.dialog.Dialog")
local SectionAwardDialog = class("SectionAwardDialog", Dialog)

function SectionAwardDialog:ctor(combatType, sectionId, boxIndex, receiveCallback)
	SectionAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_combatType = combatType
	self.m_sectionId = sectionId
	self.m_boxIndex = boxIndex
	self.m_receiveCallback = receiveCallback
end

function SectionAwardDialog:onEnter()
	SectionAwardDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[398][1]) -- 副本奖励

	local sectionBoxData = CombatBO.getSectionBoxData(self.m_combatType, self.m_sectionId)

	-- 累计获得x个
	local title = ui.newTTFLabel({text = CommonText[398][2], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2 - 170, y = self:getBg():getContentSize().height - 85, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(self:getBg())
	title:setAnchorPoint(cc.p(0, 0.5))

	local title = ui.newTTFLabel({text = sectionBoxData.starOwnNum, font = G_FONT, size = FONT_SIZE_MEDIUM, x = title:getPositionX() + title:getContentSize().width, y = title:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	title:setAnchorPoint(cc.p(0, 0.5))
	if sectionBoxData.starOwnNum >= sectionBoxData.boxNeedStar[self.m_boxIndex] then
		title:setColor(COLOR[2])
	else
		title:setColor(COLOR[5])
	end

	local title = ui.newTTFLabel({text = "/" .. sectionBoxData.boxNeedStar[self.m_boxIndex] .. CommonText[120], font = G_FONT, size = FONT_SIZE_MEDIUM, x = title:getPositionX() + title:getContentSize().width, y = title:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(self:getBg())
	title:setAnchorPoint(cc.p(0, 0.5))

	local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(self:getBg())
	star:setPosition(title:getPositionX() + title:getContentSize().width + star:getContentSize().width / 2 - 5, title:getPositionY())
	star:setScale(0.7)

	-- 可领取
	local title = ui.newTTFLabel({text = CommonText[398][3], font = G_FONT, size = FONT_SIZE_MEDIUM, x = star:getPositionX() + star:getContentSize().width / 2 - 5, y = star:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(self:getBg())
	title:setAnchorPoint(cc.p(0, 0.5))

	local awards = CombatBO.parseSectionBox(self.m_sectionId, self.m_boxIndex)
	-- dump(awards)
	if awards then
		local startX = self:getBg():getContentSize().width / 2 - (#awards * 108 + (#awards - 1) * 10) / 2

		for index = 1, #awards do
			local award = awards[index]

			local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(self:getBg())
			itemView:setPosition(startX  + (index - 0.5) * 108 + (index - 1) * 10, self:getBg():getContentSize().height - 160)
			UiUtil.createItemDetailButton(itemView)

			local resData = UserMO.getResourceData(award.kind, award.id)
			local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX(), y = 150, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		end
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width - 60, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, 130)

	-- 损兵...
	local label = ui.newTTFLabel({text = CommonText[398][4], font = G_FONT, size = FONT_SIZE_SMALL, x = self:getBg():getContentSize().width / 2, y = 90, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 25)
	btn:setLabel(CommonText[255])

	if sectionBoxData.starOwnNum < sectionBoxData.boxNeedStar[self.m_boxIndex] then -- 还不能领取
		btn:setEnabled(false)
	else
		if CombatBO.hasSectionBoxOpen(self.m_sectionId, self.m_boxIndex) then  -- 已领取
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][2])
		end
	end
end

function SectionAwardDialog:onReceiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	if CombatBO.canOpenSectionBox(self.m_combatType, self.m_sectionId, self.m_boxIndex) then
		local function doneCombatBox(awards)
			Loading.getInstance():unshow()

			UiUtil.showAwards(awards)

			if self.m_receiveCallback then self.m_receiveCallback() end

			self:pop()
		end

		Loading.getInstance():show()
		CombatBO.asynCombatBox(doneCombatBox, self.m_combatType, self.m_sectionId, self.m_boxIndex)
	-- else
		-- Toast.show("星星数量不足，无法开启宝箱")
	end
end

return SectionAwardDialog
