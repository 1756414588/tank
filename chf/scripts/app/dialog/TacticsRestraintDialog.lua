--
-- Author: Gss
-- Date: 2018-12-08 15:26:13
--
-- 战术大师显示克制关系   TacticsRestraintDialog


local Dialog = require("app.dialog.Dialog")
local TacticsRestraintDialog = class("TacticsRestraintDialog", Dialog)

function TacticsRestraintDialog:ctor(kind)
	TacticsRestraintDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(580, 910)})
	self.kind = kind
end

function TacticsRestraintDialog:onEnter()
	TacticsRestraintDialog.super.onEnter(self)
	self:setTitle(CommonText[4018])

	self:showUI()
end

function TacticsRestraintDialog:showUI()
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(550, 880))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	bg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 60, self:getBg():getContentSize().height - 200))
	bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():height() / 2 + 30)

	local titleBg = display.newSprite("image/tactics/title_restraint.png"):addTo(bg)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20, bg:getContentSize().height - 30)

	local desc = UiUtil.label(CommonText[4019]):addTo(bg)
	desc:setAnchorPoint(cc.p(0,0.5))
	desc:setPosition(60,titleBg:y() - 40)

	local effect = UiUtil.label(CommonText[4020],18,COLOR[2]):rightTo(desc)

	local posList = {
		{x = bg:width() / 2, y = effect:y() - 50},
		{x = bg:width() / 4, y = effect:y() - 150},
		{x = bg:width() / 2, y = effect:y() - 250},
		{x = bg:width() / 4 * 3, y = effect:y() - 150},
	}


	local arrowPosList = {
		{x = bg:width() / 2 - 60, y = effect:y() - 90, rotation = 0},
		{x = bg:width() / 3 + 20, y = effect:y() - 200, rotation = 260},
		{x = bg:width() / 2 + 60, y = effect:y() - 200, rotation = 170},
		{x = bg:width() / 3 * 2 - 20, y = effect:y() - 110, rotation = 70},
	}

	for index=1,#posList do
		local attr = display.newSprite("image/tactics/tactics_"..index..".png"):addTo(bg)
		attr:setPosition(posList[index].x,posList[index].y)

		local arrow = display.newSprite("image/tactics/tactics_arrow.png"):addTo(bg)
		arrow:setPosition(arrowPosList[index].x, arrowPosList[index].y)
		arrow:setRotation(arrowPosList[index].rotation)
	end

	--战术加成展示
	local titleBg2 = display.newSprite("image/tactics/suit.png"):alignTo(titleBg, -350, 1)
	local tacticChose = UiUtil.label(CommonText[4021][1]):addTo(bg)
	tacticChose:setPosition(bg:width() / 2 - 40, titleBg2:y() - 30)
	local tactic = UiUtil.label(CommonText[4021][2]):leftTo(tacticChose, 100)
	local tacticAdd = UiUtil.label(CommonText[4021][3]):rightTo(tacticChose, 130)

	local data = TacticsMO.getTacticsRestricts()

	for idx=1,#data do
		local record = data[idx]
		local addAttr = display.newSprite("image/tactics/tactics_"..idx..".png"):addTo(bg)
		addAttr:setPosition(tactic:x() - 20, tactic:y() - (idx - 1) * 70 - 50)
		addAttr:setScale(0.9)

		for num=1,6 do
			local item = display.newSprite("image/tactics/tactics_attr_"..idx..".png"):addTo(bg)
			item:setScale(0.5)
			item:setPosition(addAttr:x() + (num - 1)*40 + 70, addAttr:y())
		end

		--加成
		local attr = json.decode(record.attrSuit)[1]
		local attrData = AttributeBO.getAttributeData(attr[1], attr[2])

		local add = UiUtil.label(attrData.name,18):rightTo(addAttr, 280)
		local value = UiUtil.label("+"..attrData.strValue,18,COLOR[2]):rightTo(add)
	end

	--兵种描述
	local width = self:getBg():width() - 60
	for index=1,5 do
		local tankIcon = display.newSprite("image/tactics/tank_icon_"..index..".png")
		local tankBtn = ScaleButton.new(tankIcon, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.TacticRestrain[index]):push()
		end):addTo(self:getBg())
		tankBtn:setPosition(width / 5.3 * index, tankIcon:height() + 20)
	end
end

return TacticsRestraintDialog