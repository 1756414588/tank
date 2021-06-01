
-- 章节副本奖励

local Dialog = require("app.dialog.Dialog")
local OnlineAwardDialog = class("OnlineAwardDialog", Dialog)

function OnlineAwardDialog:ctor(receiveCallback)
	OnlineAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_receiveCallback = receiveCallback
end

function OnlineAwardDialog:onEnter()
	OnlineAwardDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[469])

	local activityAward = ActivityMO.queryActivityAwardsById(1000 + UserMO.onlineAwardIndex_ + 1)
	if not activityAward then return end

	local awards = json.decode(activityAward.awardList)
	local startX = self:getBg():getContentSize().width / 2 - (#awards * 108 + (#awards - 1) * 10) / 2

	for index = 1, #awards do
		local itemView = UiUtil.createItemView(awards[index][1], awards[index][2], {count = awards[index][3]}):addTo(self:getBg())
		itemView:setPosition(startX  + (index - 0.5) * 108 + (index - 1) * 10, self:getBg():getContentSize().height - 160)
		UiUtil.createItemDetailButton(itemView)

		local resData = UserMO.getResourceData(awards[index][1], awards[index][2])
		local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX(), y = 150, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 25)
	btn:setLabel(CommonText[255])
end

function OnlineAwardDialog:onReceiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if self.m_isReceive then return end

	local function doneCallback(id, statisticsAward)
		Loading.getInstance():unshow()
		UiUtil.showAwards(statisticsAward)

		if self.m_receiveCallback then self.m_receiveCallback() end
		self:pop()

		self.m_isReceive = false
	end

	self.m_isReceive = true

	Loading.getInstance():show()
	UserBO.asynOnlineAward(doneCallback)

	
	-- if CombatBO.canOpenSectionBox(self.m_combatType, self.m_sectionId, self.m_boxIndex) then
	-- 	local function doneCombatBox(awards)
	-- 		Loading.getInstance():unshow()

	-- 		UiUtil.showAwards(awards)

	-- 		if self.m_receiveCallback then self.m_receiveCallback() end

	-- 		self:pop()
	-- 	end

	-- 	Loading.getInstance():show()
	-- 	CombatBO.asynCombatBox(doneCombatBox, self.m_combatType, self.m_sectionId, self.m_boxIndex)
	-- -- else
	-- 	-- Toast.show("星星数量不足，无法开启宝箱")
	-- end
end

return OnlineAwardDialog
