

local Dialog = require("app.dialog.Dialog")
local DetailBuffDialog = class("DetailBuffDialog", Dialog)

function DetailBuffDialog:ctor(groups)
	-- gdump(groups, "DetailBuffDialog")

	self.m_groups = groups

	DetailBuffDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, #self.m_groups * 90 + 60)})
end

function DetailBuffDialog:onEnter()
	DetailBuffDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailBuffDialog:showUI()
	for index = 1, #self.m_groups do
		local group = self.m_groups[index]
		local groupId = group.groupId

		if BuffMO.buffMap[groupId] then
			local normal = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(self:getBg())
			normal:setScale(0.7)
			normal.groups = groups
			normal:setPosition(90, self:getBg():getContentSize().height - 30 - 90 * (index - 0.5))
			local sprite = display.newSprite("image/item/" .. BuffMO.buffMap[groupId] ..".jpg" ):addTo(normal, -1)
			sprite:setPosition(normal:getContentSize().width / 2, normal:getContentSize().height / 2)

			local buff = BuffMO.queryBuffById(group.buffId)
			local label = ui.newTTFLabel({text = buff.name, font = G_FONT, size = FONT_SIZE_SMALL, x = normal:getPositionX() + 40, y = normal:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))
		else
			gprint("DetailBuffDialog showUI no buff material!!! Error!!!!", "groupId:", groupId, "index:", index)
		end
	end
end

return DetailBuffDialog
