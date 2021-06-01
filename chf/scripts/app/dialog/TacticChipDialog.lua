--
-- Author: Gss
-- Date: 2018-12-14 15:01:32
--
-- 战术。战术碎片dialog  TacticChipDialog

local Dialog = require("app.dialog.Dialog")
local TacticChipDialog = class("TacticChipDialog", Dialog)

function TacticChipDialog:ctor(tacticId)
	TacticChipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_tacticId = tacticId
end

function TacticChipDialog:onEnter()
	TacticChipDialog.super.onEnter(self)
	self:setTitle(CommonText[211])

	local tacticDB = TacticsMO.queryTacticById(self.m_tacticId)
	local count = UserMO.getResource(ITEM_KIND_TACTIC_PIECE, tacticDB.tacticsId)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 210))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_TACTIC_PIECE, tacticDB.tacticsId, {count = count}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height - 20 - itemView:getContentSize().height / 2)
	if self.m_tacticId ~= TACTICS_ID_ALL_PIECE then
		UiUtil.createItemDetailButton(itemView)
	end

	local name = ui.newTTFLabel({text = tacticDB.tacticsName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 33, color = COLOR[tacticDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local label1 = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local allPieceCount = UserMO.getResource(ITEM_KIND_TACTIC_PIECE, TACTICS_ID_ALL_PIECE)

	if self.m_tacticId == TACTICS_ID_ALL_PIECE then
		local label2 = ui.newTTFLabel({text = CommonText[461], font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label2:setAnchorPoint(cc.p(0, 0.5))
	else
		if tacticDB.chipCount > 0 then
			local label2 = ui.newTTFLabel({text = string.format(CommonText[4029], tacticDB.chipCount, tacticDB.tacticsName) , font = G_FONT,
				size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(350,0)}):addTo(infoBg)
			label2:setPosition(label1:getPositionX(), label1:getPositionY() - 35)
			label2:setAnchorPoint(cc.p(0, 0.5))
		-- else
		-- 	local label2 = ui.newTTFLabel({text = string.format(CommonText[466], CommonText[162][tacticDB.quality]), font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		-- 	label2:setAnchorPoint(cc.p(0, 0.5))
		end

		if allPieceCount > 0 then
			local allPieceData = UserMO.getResourceData(ITEM_KIND_TACTIC_PIECE, TACTICS_ID_ALL_PIECE)
			local label = ui.newTTFLabel({text = allPieceData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 70, color = COLOR[allPieceData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label:setAnchorPoint(cc.p(0, 0.5))
			local value = ui.newTTFLabel({text = allPieceCount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	if self.m_tacticId ~= TACTICS_ID_ALL_PIECE then
		if (count + allPieceCount) >= tacticDB.chipCount and tacticDB.chipCount > 0 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local combineBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCombineCallback)):addTo(self:getBg())
			combineBtn:setPosition(self:getBg():getContentSize().width / 2, 66)
			combineBtn:setLabel(CommonText[214])
		else
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local getBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCombatCallback)):addTo(self:getBg())
			getBtn:setPosition(self:getBg():getContentSize().width / 2, 66)
			getBtn:setLabel(CommonText[213])
		end
	end
end

function TacticChipDialog:onCombineCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doneCombine(stastAwards)
		UiUtil.showAwards(stastAwards)
		Toast.show(CommonText[467][1])
		self:pop()
	end

	local function gotoCombine()
		TacticsBO.onTacticCompose(doneCombine, self.m_tacticId)
	end

	local tacticDB = TacticsMO.queryTacticById(self.m_tacticId)
	local count = UserMO.getResource(ITEM_KIND_TACTIC_PIECE, self.m_tacticId)

	if count < tacticDB.chipCount then
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[4030], (tacticDB.chipCount - count)), function() gotoCombine() end):push()
	else
		gotoCombine()
	end
end

function TacticChipDialog:onCombatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self:pop(function()
			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_TACTIC)):push()
		end)
end

return TacticChipDialog
