--
-- Author: gf
-- Date: 2015-09-10 18:31:56
--

local Dialog = require("app.dialog.Dialog")
local LotteryTreasureResultDialog = class("LotteryTreasureResultDialog", Dialog)

function LotteryTreasureResultDialog:ctor(type,awards,closeCb)
	LotteryTreasureResultDialog.super.ctor(self, nil, UI_ENTER_NONE)
	self.type = type
	self.awards = awards
	self.closeCb = closeCb
end

function LotteryTreasureResultDialog:onEnter()
	LotteryTreasureResultDialog.super.onEnter(self)

	self:hasCloseButton(false)

	-- self:setTitle(CommonText[521])

	
	local itemPic = UiUtil.createItemView(self.awards[1].type, self.awards[1].id, {count = self.awards[1].count})
	itemPic:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2)
	self:getBg():addChild(itemPic)

	local itemName = ui.newTTFLabel({text = string.format(CommonText[564],UserMO.getResourceData(self.awards[1].type, self.awards[1].id).name) .. "×" .. self.awards[1].count, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1],
		x = self:getBg():getContentSize().width / 2, 
		y = self:getBg():getContentSize().height / 2 - 80}):addTo(self:getBg())


	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local quitBtn = MenuButton.new(normal, selected, nil, handler(self,self.quit)):addTo(self:getBg())
	quitBtn:setPosition(self:getBg():getContentSize().width / 2,itemPic:getPositionY() - 150)
	quitBtn:setLabel(CommonText[1])

end



function LotteryTreasureResultDialog:quit()
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function LotteryTreasureResultDialog:onExit()
	LotteryTreasureResultDialog.super.onExit(self)
	if self.closeCb then
		self.closeCb()
	end
end


return LotteryTreasureResultDialog