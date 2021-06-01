--
-- Author: xiaoxing
-- Date: 2016-12-22 11:58:57
--
-- 配件碎片弹出框

local Dialog = require("app.dialog.Dialog")
local MedalChipDialog = class("MedalChipDialog", Dialog)

-- chipId:配件碎片的keyId
function MedalChipDialog:ctor(chipId)
	MedalChipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_chipId = chipId
end

function MedalChipDialog:onEnter()
	MedalChipDialog.super.onEnter(self)

	self:setTitle(CommonText[211]) -- 碎片查看

	local partDB = MedalMO.queryById(self.m_chipId)
	local count = UserMO.getResource(ITEM_KIND_MEDAL_CHIP, partDB.medalId)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 210))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_MEDAL_CHIP, partDB.medalId, {count = count}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height - 20 - itemView:getContentSize().height / 2)
	if self.m_chipId ~= MEDAL_ID_ALL_PIECE then
		UiUtil.createItemDetailButton(itemView)
	end

	local name = ui.newTTFLabel({text = partDB.medalName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 33, color = COLOR[partDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 当前数量
	local label1 = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local t = UiUtil.label(CommonText[20164][1], FONT_SIZE_SMALL, COLOR[11]):alignTo(label1, -25, 1)
	UiUtil.label(self.m_chipId == MEDAL_ID_ALL_PIECE and CommonText[20163][3] or partDB.position,nil,COLOR[2]):rightTo(t)
	if self.m_chipId == MEDAL_ID_ALL_PIECE then
		local label2 = ui.newTTFLabel({text = CommonText[20173], font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label2:setAnchorPoint(cc.p(0, 0.5))
	else
		local label2 = ui.newTTFLabel({text = string.format(CommonText[20172], partDB.chipCount, partDB.medalName), font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label2:setAnchorPoint(cc.p(0, 0.5))
	end
	local allPieceCount = UserMO.getResource(ITEM_KIND_MEDAL_CHIP, MEDAL_ID_ALL_PIECE)
	-- 分解
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onExplodeCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 26)
	exchangeBtn:setLabel(CommonText[171])
	exchangeBtn.partDB = partDB

	if self.m_chipId ~= MEDAL_ID_ALL_PIECE then
		if (count + allPieceCount) >= partDB.chipCount and partDB.chipCount > 0 then
			-- 合成
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local combineBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCombineCallback)):addTo(self:getBg())
			combineBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 26)
			combineBtn:setLabel(CommonText[214])
		else
			-- 获取
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local getBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCombatCallback)):addTo(self:getBg())
			getBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 26)
			getBtn:setLabel(CommonText[213])
		end
	end
end

function MedalChipDialog:onExplodeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	local id =  self.m_chipId
	local function goBatch()
		self:pop(function()
				local ChipExplodeDialog = require("app.dialog.ChipExplodeDialog")
				ChipExplodeDialog.new({{chipId = id, count = 1}}, nil , ChipExplodeDialog.EXPLODE_TYPE_SINGLE, "medal"):push()
			end)
	end

	if sender.partDB.quality >= 5 then
		require("app.dialog.TipsAnyThingDialog").new(CommonText[1810][2],function ()
			goBatch()
		end):push()
	else
		goBatch()
	end

	-- self:pop(function()
	-- 		local ChipExplodeDialog = require("app.dialog.ChipExplodeDialog")
	-- 		ChipExplodeDialog.new({{chipId = self.m_chipId, count = 1}}, nil , ChipExplodeDialog.EXPLODE_TYPE_SINGLE, "medal"):push()
	-- 	end)
end

function MedalChipDialog:onCombineCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doneCombine(stastAwards)
		UiUtil.showAwards(stastAwards)
		Toast.show(CommonText[467][1])  -- 合成成功
		self:pop()
	end

	local function gotoCombine()
		Loading.getInstance():show()
		MedalBO.combineMedal(self.m_chipId,doneCombine)
	end

	local md = MedalMO.queryById(self.m_chipId)
	local count = UserMO.getResource(ITEM_KIND_MEDAL_CHIP, self.m_chipId)

	if count < md.chipCount then -- 使用了万能碎片
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[20174], (md.chipCount - count)), function() gotoCombine() end):push()
	else  -- 不需要消耗万能碎片
		gotoCombine()
	end
end

function MedalChipDialog:onCombatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self:pop(function()
			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_MEDAL)):push()
		end)
end

return MedalChipDialog