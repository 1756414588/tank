--
-- Author: xiaoxing
-- Date: 2017-01-04 16:41:00
--
local Dialog = require("app.dialog.Dialog")
local MedalShowDialog = class("MedalShowDialog", Dialog)

function MedalShowDialog:ctor(medalId,data)
	MedalShowDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 560)})
	self.medalId = medalId
	self.data = data
end

function MedalShowDialog:onEnter()
	MedalShowDialog.super.onEnter(self)
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)
	self:setTitle(CommonText[20163][2]) -- 查看勋章

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	bg:setPreferredSize(cc.size(490, 370))
	bg:setPosition(self:getBg():width()/2, self:getBg():height() - 80 - bg:height()/2)

	local md = MedalMO.queryById(self.medalId)
	local item = display.newSprite("image/item/m_"..md.medalId..".png"):addTo(bg):pos(bg:width()/2,bg:height()-60)
	local t = display.newSprite(IMAGE_COMMON.."medal_bottom.png"):addTo(bg):pos(bg:width()/2,bg:height()-125)
	UiUtil.label(md.medalName, nil, COLOR[12]):addTo(bg):pos(t:x(),t:y())
	UiUtil.label(md.dec, 18, nil, cc.size(450,0)):addTo(bg):align(display.CENTER_TOP, bg:width()/2, bg:height()-150)

	--属性
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(bg)
	line:setPreferredSize(cc.size(480, line:getContentSize().height))
	line:setPosition(bg:getContentSize().width / 2,bg:height()-240)

	--属性
	local titleBg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(bg)
		:align(display.LEFT_CENTER, 15, bg:height()-270)
	-- 增加属性
	local title = ui.newTTFLabel({text = CommonText[20179][2], font = G_FONT, size = FONT_SIZE_TINY, x = 80, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)
	local x,y,ex,ey = 60,54,190
	local attrs = json.decode(md.attrShowed)
	for k,v in ipairs(attrs) do
		local attr = AttributeBO.getAttributeData(v[1], v[2])
		local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = attr.attrName}):addTo(bg):pos(x+(k-1)*ex,y)
		local name = ui.newTTFLabel({text = attr.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		name:setAnchorPoint(cc.p(0, 0.5))
		name:setColor(COLOR[11])
		name:setPosition(itemView:getPositionX() + 30, itemView:getPositionY())
		local value = ui.newTTFLabel({text = "+" .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end
	if self.data then
		UiUtil.label(CommonText[20182],18,COLOR[6]):addTo(bg):align(display.LEFT_CENTER, 15, 20)
	end
	local t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self, self.show), CommonText[20181][self.data and 3 or 4])
		:addTo(self:getBg()):pos(self:getBg():width()/2,70)
	if not self.data or (self.data and #self.data == 0) then
		t:setEnabled(false)
	end
end

function MedalShowDialog:show(tag,sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function()
			require("app.dialog.MedalShowList").new(self.data):push()
		end)
end

return MedalShowDialog