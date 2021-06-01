--
-- Author: gf
-- Date: 2015-10-08 14:30:15
--

local Dialog = require("app.dialog.Dialog")
local EnergyCombineRsDialog = class("EnergyCombineRsDialog", Dialog)

function EnergyCombineRsDialog:ctor(stoneId, successTimes, loseTimes)
	EnergyCombineRsDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 380),closeBtn=false})
	-- self.m_award = award
	self.m_stoneId 	= stoneId
	self.m_successTimes = successTimes
	self.m_loseTimes	 = loseTimes
end

function EnergyCombineRsDialog:onEnter()
	EnergyCombineRsDialog.super.onEnter(self)

	self:setTitle(CommonText[948][4])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 350))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local itemView = UiUtil.createItemView(ITEM_KIND_ENERGY_SPAR, self.m_stoneId):addTo(self:getBg())
	itemView:setPosition(self:getBg():getContentSize().width/2 - 100, self:getBg():getContentSize().height/2 + 30)
	-- itemView:center()

	local sparDB = EnergySparMO.queryEnergySparById(self.m_stoneId)

	local resData = UserMO.getResourceData(ITEM_KIND_ENERGY_SPAR, self.m_stoneId)
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = itemView:getPositionX() + itemView:getContentSize().width / 2 + 10, 
		y = itemView:getPositionY() + 30, 
		align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[resData.quality]}):addTo(self:getBg())

	name:setAnchorPoint(cc.p(0, 0.5))


	local attr = AttributeBO.getAttributeData(sparDB.attrId, sparDB.attrValue)
-- attrName
-- strValue
	local label1 = ui.newTTFLabel({text = attr.name ..CommonText[176], font = G_FONT, size = FONT_SIZE_SMALL,
		 x = name:getPositionX(), y = name:getPositionY() - 60, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label1:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = (attr.value > 0 and "+" or "-") .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, 
		 x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))


	local count = ui.newTTFLabel({text = "+" .. self.m_successTimes, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = name:getPositionX(), 
		y = name:getPositionY() - 30, 
		align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))

	ui.newTTFLabel({text = string.format(CommonText[948][5], self.m_successTimes), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = self:getBg():getContentSize().width/2, 
		y = itemView:getPositionY() - itemView:getContentSize().height / 2 - 40, 
		align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[2]}):addTo(self:getBg())

	ui.newTTFLabel({text = string.format(CommonText[948][6], self.m_loseTimes), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = self:getBg():getContentSize().width/2, 
		y = itemView:getPositionY() - itemView:getContentSize().height / 2 - 70, 
		align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[6]}):addTo(self:getBg())

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local getBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardHandler)):addTo(self:getBg())
	getBtn:setPosition(self:getBg():getContentSize().width / 2,25)
	getBtn:setLabel(CommonText[1])
end

function EnergyCombineRsDialog:awardHandler()
	self:pop()
	if self.m_successTimes > 0 then
		UiUtil.showAwards({awards = {{kind = ITEM_KIND_ENERGY_SPAR, id = self.m_stoneId, count = self.m_successTimes}}})	
	end
end

return EnergyCombineRsDialog