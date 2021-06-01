
-- 配件碎片弹出框

local Dialog = require("app.dialog.Dialog")
local ChipDialog = class("ChipDialog", Dialog)

-- chipId:配件碎片的keyId
function ChipDialog:ctor(chipId)
	ChipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_chipId = chipId
end

function ChipDialog:onEnter()
	ChipDialog.super.onEnter(self)

	self:setTitle(CommonText[211]) -- 碎片查看

	self.quality2NeedCount = {}
	local partSystemData = json.decode(UserMO.querySystemId(75))
	self.quality2NeedCount[partSystemData[1][1]] = partSystemData[1][2]
	self.quality2NeedCount[partSystemData[2][1]] = partSystemData[2][2]

	local partDB = PartMO.queryPartById(self.m_chipId)
	local count = UserMO.getResource(ITEM_KIND_CHIP, partDB.partId)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 210))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_CHIP, partDB.partId, {count = count}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height - 20 - itemView:getContentSize().height / 2)
	if self.m_chipId ~= PART_ID_ALL_PIECE then
		UiUtil.createItemDetailButton(itemView)
	end

	local name = ui.newTTFLabel({text = partDB.partName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 33, color = COLOR[partDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 当前数量
	local label1 = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local allPieceCount = UserMO.getResource(ITEM_KIND_CHIP, PART_ID_ALL_PIECE)
	-- gprint("allPieceCount:", allPieceCount)

	if self.m_chipId == PART_ID_ALL_PIECE then
		local label2 = ui.newTTFLabel({text = CommonText[461], font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label2:setAnchorPoint(cc.p(0, 0.5))
	else
		local partPos = PartMO.getPosByPartId(partDB.partId)
		if partDB.chipCount > 0 then -- x个可合成,适用
			local label2 = ui.newTTFLabel({text = string.format(CommonText[212], partDB.chipCount, CommonText.PartPos2Name[partPos], CommonText[162][partDB.type]) , font = G_FONT,
				size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(350,0)}):addTo(infoBg)
			label2:setPosition(label1:getPositionX(), label1:getPositionY() - 35)
			label2:setAnchorPoint(cc.p(0, 0.5))
		else  -- 适用
			local label2 = ui.newTTFLabel({text = string.format(CommonText[466], CommonText[162][partDB.type]), font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label2:setAnchorPoint(cc.p(0, 0.5))
		end

		local offsetY = label1:getPositionY() - 70
		if allPieceCount > 0 then
			local allPieceData = UserMO.getResourceData(ITEM_KIND_CHIP, PART_ID_ALL_PIECE)
			local label = ui.newTTFLabel({text = allPieceData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 70, color = COLOR[allPieceData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label:setAnchorPoint(cc.p(0, 0.5))
			local value = ui.newTTFLabel({text = allPieceCount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 0.5))
			offsetY = offsetY - 25
		end

		if partPos >= 9 and (partDB.quality == 2 or partDB.quality == 3) then
			local labelDesc = ui.newTTFLabel({text = CommonText[4034], font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = offsetY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			labelDesc:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	-- 分解
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onExplodeCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 26)
	exchangeBtn:setLabel(CommonText[171])
	exchangeBtn.partDB = partDB

	if self.m_chipId ~= PART_ID_ALL_PIECE then
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

function ChipDialog:onExplodeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local partDB = sender.partDB
	local chipId = self.m_chipId

	local function goBatch()
		self:pop(function()
				local ChipExplodeDialog = require("app.dialog.ChipExplodeDialog")
				ChipExplodeDialog.new({{chipId = chipId, count = 1}}, nil , ChipExplodeDialog.EXPLODE_TYPE_SINGLE):push()
			end)
	end

	if partDB.quality >= 4 then
		require("app.dialog.TipsAnyThingDialog").new(CommonText[1810][2],function ()
			goBatch()
		end):push()
	else
		goBatch()
	end

	-- self:pop(function()
	-- 		local ChipExplodeDialog = require("app.dialog.ChipExplodeDialog")
	-- 		ChipExplodeDialog.new({{chipId = self.m_chipId, count = 1}}, nil , ChipExplodeDialog.EXPLODE_TYPE_SINGLE):push()
	-- 	end)
-- 	Loading.getInstance():show()

-- 	local function doneOnPart()
-- 		Loading.getInstance():unshow()

-- 		-- 配件卸下成功
-- 		Toast.show(CommonText[180])

-- 		self:pop()
-- 	end

-- 	PartBO.asynOnPart(doneOnPart, self.m_part.keyId)
end

function ChipDialog:onCombineCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doneCombine(stastAwards)
		Loading.getInstance():unshow()

		UiUtil.showAwards(stastAwards)

		Toast.show(CommonText[467][1])  -- 合成成功

		self:pop()
	end

	local function gotoCombine()
		Loading.getInstance():show()
		PartBO.asynCombinePart(doneCombine, self.m_chipId)
	end

	local partDB = PartMO.queryPartById(self.m_chipId)
	local count = UserMO.getResource(ITEM_KIND_CHIP, self.m_chipId)
	local partPos = PartMO.getPosByPartId(self.m_chipId)
	if partPos == 9 or partPos == 10 then  -- 9-10号配件判断最少本体碎片数量
		local qualityNeedCount = self.quality2NeedCount[partDB.quality]
		if qualityNeedCount then
			if count < qualityNeedCount then
				Toast.show(string.format(CommonText[4033], qualityNeedCount))
				return
			end
		end
	end

	if count < partDB.chipCount then -- 使用了万能碎片
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[10066], (partDB.chipCount - count)), function() gotoCombine() end):push()
	else  -- 不需要消耗万能碎片
		gotoCombine()
	end
end

function ChipDialog:onCombatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self:pop(function()
			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_PART)):push()
		end)
end

return ChipDialog