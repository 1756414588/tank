--
-- Author: gf
-- Date: 2015-10-08 14:30:15
--

local Dialog = require("app.dialog.Dialog")
local NewerGiftDialog = class("NewerGiftDialog", Dialog)

function NewerGiftDialog:ctor()
	NewerGiftDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 380), closeBtn = false})
end

function NewerGiftDialog:onEnter()
	NewerGiftDialog.super.onEnter(self)

	self:setTitle(CommonText[694][1])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 350))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local awards = json.decode(HeroMO.queryAwards(NewerMO.giftAwardId).awardList)

	gdump(awards,"NewerGift award==============")

	for index = 1,#awards do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award[1], award[2]):addTo(self:getBg())
		itemView:setPosition(90 + (index - 1) % 2 * 220 ,250 - 120 * math.floor((index - 1) / 2))
		
		local name = ui.newTTFLabel({text = UserMO.getResourceData(award[1], award[2]).name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getPositionX() + itemView:getContentSize().width / 2 + 10, 
			y = itemView:getPositionY() + 20, 
			align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[1]}):addTo(self:getBg())
			name:setAnchorPoint(cc.p(0, 0.5))
		local count = ui.newTTFLabel({text = "+" .. award[3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = name:getPositionX(), 
			y = name:getPositionY() - 30, 
			align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[1]}):addTo(self:getBg())
		count:setAnchorPoint(cc.p(0, 0.5))
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local getBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardHandler)):addTo(self:getBg())
	getBtn:setPosition(self:getBg():getContentSize().width / 2,25)
	getBtn:setLabel(CommonText[694][2])
end

function NewerGiftDialog:awardHandler()
	Loading.getInstance():show()
	Statistics.postPoint(ST_P_70)
	NewerBO.asynGetGuideGift(function()
		Loading.getInstance():unshow()
		self:pop()
		end)
end

function NewerGiftDialog:onExit()
	NewerGiftDialog.super.onExit(self)
	NewerMO.showNewer = false
end

return NewerGiftDialog