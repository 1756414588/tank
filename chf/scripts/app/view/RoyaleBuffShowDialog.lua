--
-- Author: heyunlong
-- Date: 2018-07-18 15:49:50
-- 荣耀增益展示

local Dialog = require("app.dialog.Dialog")
local RoyaleBuffShowDialog = class("RoyaleBuffShowDialog", Dialog)

function RoyaleBuffShowDialog:ctor()
	RoyaleBuffShowDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 480)})
end

function RoyaleBuffShowDialog:onEnter()
	RoyaleBuffShowDialog.super.onEnter(self)

	self:setTitle(CommonText[2100])

	-- local num
	-- local data = json.decode(UserMO.querySystemId(62))--此处写死ID为62

	-- for index=1,#data do
	-- 	if UserMO.level_ >= data[index][1] and UserMO.level_ <= data[index][2] then
	-- 		num = data[index][3]
	-- 		break
	-- 	end
	-- end

	-- local value = tostring(num * 100)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal.png"):addTo(self:getBg())
	local normal1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal_debuff.png"):addTo(self:getBg())
	normal:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 120)
	normal1:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 120)

	local myPos = WorldMO.pos_
	local temp = RoyaleSurviveMO.IsInSafeArea(myPos)
	normal:setVisible(temp)
	normal1:setVisible(not temp)
	normal:setScale(1.5)
	normal1:setScale(1.5)

	local descTitleStr = nil
	local descTitleColor = nil
	if temp == true then
		if not RoyaleSurviveMO.shrinkAllOver then
			descTitleStr = CommonText[2106][2]
		else
			descTitleStr = CommonText[2106][4]
		end
		descTitleColor = COLOR[6]
	else
		descTitleStr = CommonText[2106][1]
		descTitleColor = COLOR[22]
	end

	local curPhase = RoyaleSurviveMO.curPhase

	local labelLv = ui.newTTFLabel({text=string.format("Lv.%d", curPhase), size=20, color=descTitleColor}):addTo(self:getBg())
	labelLv:setPosition(self:getBg():getContentSize().width / 2 + normal:width() * 0.75, self:getBg():getContentSize().height - 120 + normal:height() * 0.75)
	labelLv:setAnchorPoint(cc.p(1, 1))

	local labelDescTitle = ui.newTTFLabel({text=descTitleStr,size=20,color=descTitleColor}):addTo(self:getBg())
	labelDescTitle:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 200)

	local labelExtraDescTitle = ui.newTTFLabel({text=string.format("(%s)", CommonText[2106][3]),size=20,color=COLOR[25]}):addTo(self:getBg())
	labelExtraDescTitle:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 200 - labelDescTitle:height())

	local buff = 1
	if temp == false then
		buff = -1
	end

	local attrStr = RoyaleSurviveMO.getBuffAttrShow(buff, curPhase)
	local attrDatas = json.decode(attrStr)
	local oneItemWidth = 150
	local oneItemHeight = 50
	local rowStartX = 50
	local firstColY = self:getBg():getContentSize().height - 270
	local colNum = 3
	local LastY = labelExtraDescTitle:height()
	if attrDatas then
		local signStr = "+"
		if temp == false then
			signStr = "-"
		end
		for index = 1, #attrDatas do
			local attrData = attrDatas[index]
			local attribute = AttributeBO.getAttributeData(attrData[1], attrData[2])
			local row = math.floor((index - 1) / colNum) + 1
			local col = (index - 1) % colNum + 1
			local labelX = rowStartX + (col - 1) * oneItemWidth
			local labelY = firstColY - (row - 1) * oneItemHeight
			local label = ui.newTTFLabel({text = attribute.name .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = labelY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			local value = ui.newTTFLabel({text = signStr .. attribute.strValue, font = G_FONT, size = FONT_SIZE_SMALL, color = descTitleColor, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			value:setAnchorPoint(cc.p(0, 0.5))

			LastY = labelY
		end
	end

	if buff == -1 and curPhase > 0 then
		local tankLoss = RoyaleSurviveMO.getForeverTankLoss(curPhase)
		local label = ui.newTTFLabel({text = "永久损兵增加：", font = G_FONT, size = FONT_SIZE_SMALL, x = rowStartX, y = LastY - oneItemHeight, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = string.format("%d%%", tankLoss), font = G_FONT, size = FONT_SIZE_SMALL, color = descTitleColor, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 450))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, function ()
		self:pop()
	end):addTo(self:getBg())
	rechargeBtn:setPosition(self:getBg():getContentSize().width / 2,25)
	rechargeBtn:setLabel(CommonText[2102])
end

function RoyaleBuffShowDialog:onExit()
	RoyaleBuffShowDialog.super.onExit(self)
end

return RoyaleBuffShowDialog 
