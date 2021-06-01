
-- 配件卸下、装配、强化、改造等操作弹出框

local Dialog = require("app.dialog.Dialog")
----------------------------------------------------
local ComponentShowDialog = class("ComponentShowDialog", Dialog)

-- keyId:配件的keyId
function ComponentShowDialog:ctor(keyId)
	ComponentShowDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 560)})

	self.m_part = PartMO.getPartByKeyId(keyId)
end

function ComponentShowDialog:onEnter()
	ComponentShowDialog.super.onEnter(self)

	local partDB = PartMO.queryPartById(self.m_part.partId)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[170]) -- 配件查看

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 420))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)
	--分界线
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(506, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 240)

	local list = PartMO.getRefineAttr(self.m_part,1)
	local x,y,ey = 135,infoBg:height()-280,30
	for k,v in ipairs(list) do
		local name = UiUtil.label(v.name,FONT_SIZE_SMALL):addTo(infoBg):align(display.LEFT_CENTER,x,y-(k-1)*ey)
		UiUtil.label(v.value[1],nil,COLOR[2]):alignTo(name,100)
	end

	local attrData = PartBO.getPartAttrData(self.m_part.partId, self.m_part.upLevel, self.m_part.refitLevel, self.m_part.keyId, 1)

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 20 - strengthLabel:getContentSize().height / 2)

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrData.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	local itemView = UiUtil.createItemView(ITEM_KIND_PART, self.m_part.partId, {upLv = self.m_part.upLevel, refitLv = self.m_part.refitLevel, keyId = self.m_part.keyId}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height - 55 - itemView:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView)

	--锁定状态icon
	local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
	lockIcon:setScale(0.5)
	lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
	lockIcon:setVisible(self.m_part.locked)
	self.m_lockIcon = lockIcon

	local name = ui.newTTFLabel({text = partDB.partName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 68, color = COLOR[partDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local startY = name:getPositionY() - 30

	if self.m_part.refitLevel > 0 then
		for index = 1, self.m_part.refitLevel do
			local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(infoBg)
			star:setPosition(name:getPositionX() + (index - 0.5) * 30, startY)
			star:setScale(0.55)
		end

		startY = name:getPositionY() - 60
	end

	local attrData1 = attrData.attr1

	local startLabel = nil

	-- xx加成
	local label1 = ui.newTTFLabel({text = attrData1.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = startY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = attrData1.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local attrData2 = attrData.attr2
	if attrData2 then -- 有第二属性
		-- xx加成
		local labelX = ui.newTTFLabel({text = attrData2.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		labelX:setAnchorPoint(cc.p(0, 0.5))
		startLabel = labelX

		local value = ui.newTTFLabel({text = attrData2.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = labelX:getPositionX() + labelX:getContentSize().width + 5, y = labelX:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 适用兵种
	local label2 = ui.newTTFLabel({text = CommonText[177] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = startLabel:getPositionX(), y = startLabel:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label2:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = CommonText[162][partDB.type], font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX() + label2:getContentSize().width + 5, y = label2:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 改造等级
	local label3 = ui.newTTFLabel({text = CommonText[178] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX(), y = label2:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label3:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = self.m_part.refitLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 强化等级
	local label4 = ui.newTTFLabel({text = CommonText[179] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX(), y = label3:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label4:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = self.m_part.upLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label4:getPositionX() + label4:getContentSize().width + 5, y = label4:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))
end

return ComponentShowDialog 
