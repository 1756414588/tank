--
-- Author: gf
-- Date: 2015-09-14 19:18:00
-- 军团科技详情


local Dialog = require("app.dialog.Dialog")
local PartyScienceDetailDialog = class("PartyScienceDetailDialog", Dialog)

function PartyScienceDetailDialog:ctor(science)
	PartyScienceDetailDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE,{scale9Size = cc.size(380, 300)})
	self.science = science
end

function PartyScienceDetailDialog:onEnter()
	PartyScienceDetailDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	local science = self.science

	local scienceLvData =  PartyMO.queryScienceLevel(science.scienceId, science.scienceLv + 1)
	local scienceInfo = ScienceMO.queryScience(science.scienceId)

	local name = ui.newTTFLabel({text = scienceInfo.refineName .. ":LV." .. science.scienceLv, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = self:getBg():getContentSize().height - 40, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = scienceInfo.desc, font = G_FONT, size = FONT_SIZE_SMALL, 
		color = COLOR[1], align = ui.TEXT_ALIGN_LEFT,
		dimensions = cc.size(330, 0)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 1))
	desc:setPosition(30, name:getPositionY() - name:getContentSize().height - 20)

	local needTit = ui.newTTFLabel({text = CommonText[594][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = desc:getPositionY() - desc:getContentSize().height - 20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	needTit:setAnchorPoint(cc.p(0, 0.5))

	if science.scienceLv == PartyMO.queryScienceMaxLevel(science.scienceId) then
		--已满级
		local needLv = ui.newTTFLabel({text = CommonText[600], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 30, y = needTit:getPositionY() - needTit:getContentSize().height - 20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		needLv:setAnchorPoint(cc.p(0, 0.5))
	else
		local needLv = ui.newTTFLabel({text = string.format(CommonText[599][1],scienceLvData.lockLv), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 30, y = needTit:getPositionY() - needTit:getContentSize().height - 20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		needLv:setAnchorPoint(cc.p(0, 0.5))
		if PartyMO.partyData_.scienceLv >= scienceLvData.lockLv then
			needLv:setColor(COLOR[1])
		else
			needLv:setColor(COLOR[5])
		end

		local needExp = ui.newTTFLabel({text = string.format(CommonText[599][2],scienceLvData.schedule), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 30, y = needLv:getPositionY() - needLv:getContentSize().height - 20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		needExp:setAnchorPoint(cc.p(0, 0.5))
	end
	
end



function PartyScienceDetailDialog:onExit()
	PartyScienceDetailDialog.super.onExit(self)
end


return PartyScienceDetailDialog