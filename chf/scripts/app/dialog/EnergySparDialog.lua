
-- 能晶信息弹出框

local Dialog = require("app.dialog.Dialog")
local EnergySparDialog = class("EnergySparDialog", Dialog)

-- chipId:配件碎片的keyId
function EnergySparDialog:ctor(stoneId)
	EnergySparDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 350)})
	self.m_stoneId = stoneId
end

function EnergySparDialog:onEnter()
	EnergySparDialog.super.onEnter(self)

	self:setTitle(CommonText[941][2]) -- 能晶信息

	local sparDB = EnergySparMO.queryEnergySparById(self.m_stoneId)
	local count = UserMO.getResource(ITEM_KIND_ENERGY_SPAR, self.m_stoneId)

	self.m_sparHoleType = sparDB.holeType

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 190))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_ENERGY_SPAR, self.m_stoneId):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height - 20 - itemView:getContentSize().height / 2)

	local name = ui.newTTFLabel({text = string.format("%sLv.%d", sparDB.stoneName, sparDB.level), font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 135, y = infoBg:getContentSize().height - 40, color = COLOR[sparDB.quite], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 当前数量
	local label1 = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local attr = AttributeBO.getAttributeData(sparDB.attrId, sparDB.attrValue)
-- attrName
-- strValue
	local label1 = ui.newTTFLabel({text = attr.name ..CommonText[176], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 70, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = (attr.value > 0 and "+" or "-") .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 镶嵌
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onInlayCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 26)
	exchangeBtn:setLabel(CommonText[942])


	-- 合成
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local combineBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCombineCallback)):addTo(self:getBg())
	combineBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 26)
	combineBtn:setLabel(CommonText[214])
end

function EnergySparDialog:onInlayCallback( tag, sender )
	self:pop()
	Notify.notify(LOCAL_ENERGYSPAR_VIEW_FOR_EVENT, {viewFor = ENERGYSPAR_VIEW_INSET})	
end

function EnergySparDialog:onCombineCallback( tag, sender )
	local stoneId = self.m_stoneId
	local sparDB = EnergySparMO.queryEnergySparById(stoneId)
	if sparDB.synthesizing > 0 then
		self:pop()

		local EnergySparCombineDialog = require("app.dialog.EnergySparCombineDialog")
		EnergySparCombineDialog.new(self.m_stoneId):push()	
	else
		Toast.show(CommonText[949][1])
	end
end

return EnergySparDialog