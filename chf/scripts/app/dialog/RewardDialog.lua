--
-- Author: xiaoxing
-- Date: 2017-04-18 14:29:27
--

local Dialog = require("app.dialog.Dialog")
local RewardDialog = class("RewardDialog", Dialog)

function RewardDialog:ctor(data,rhand,has)
	RewardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})
	self.data =data
	self.rhand = rhand
	self.has = has
end

function RewardDialog:onEnter()
	RewardDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[269]) -- 奖励预览
	local awards = self.data
	local startX = self:getBg():getContentSize().width / 2 - (#awards * 108 + (#awards - 1) * 10) / 2
	for index = 1, #awards do
		local award = awards[index]

		local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(self:getBg())
		itemView:setPosition(startX  + (index - 0.5) * 108 + (index - 1) * 10, self:getBg():getContentSize().height - 160)
		UiUtil.createItemDetailButton(itemView)

		local resData = UserMO.getResourceData(award.kind, award.id)
		local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX(), y = 100, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width - 60, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, 130)


	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 25)
	btn:setLabel(CommonText[self.has == true and 747 or 255])
	if not self.rhand then
		btn:setEnabled(false)
		btn:setVisible(false)
	end
end

function RewardDialog:onReceiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.rhand then
		self.rhand()
	end
end

return RewardDialog
