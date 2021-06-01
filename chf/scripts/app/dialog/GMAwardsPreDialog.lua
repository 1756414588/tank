--
-- Author: gf
-- Date: 2015-10-16 14:04:56
--


local Dialog = require("app.dialog.Dialog")
local GMAwardsPreDialog = class("GMAwardsPreDialog", Dialog)

function GMAwardsPreDialog:ctor(awards)
	GMAwardsPreDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(GAME_SIZE_WIDTH, 500)})
	
	self.awards = awards
end

function GMAwardsPreDialog:onEnter()
	GMAwardsPreDialog.super.onEnter(self)

	self:setOutOfBgClose(true)


	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(display.width, 500))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	for index=1,#self.awards do
		local award = self.awards[index]
		local resData = UserMO.getResourceData(award.type,award.id)
		local itemView = UiUtil.createItemView(award.type, award.id, {award.count})
		itemView:setScale(0.8)
		UiUtil.createItemDetailButton(itemView)
		if index < 6 then
			itemView:setPosition(90 + (index - 1) * 115, btm:getContentSize().height / 2 + 90)
		else
			itemView:setPosition(90 + (index - 6) * 115, btm:getContentSize().height / 2 - 90)
		end
		
		btm:addChild(itemView)

		local name = ui.newTTFLabel({text = resData.name2 .. "\n" .. award.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 70, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		name:setAnchorPoint(cc.p(0.5, 0.5))

	end

end



return GMAwardsPreDialog