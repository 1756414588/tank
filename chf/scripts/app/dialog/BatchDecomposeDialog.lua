
-- 批量分解弹出框

local Dialog = require("app.dialog.Dialog")
local BatchDecomposeDialog = class("BatchDecomposeDialog", Dialog)

BATCH_DIALOG_FOR_COMPONENT = 1
BATCH_DIALOG_FOR_PIECE = 2
BATCH_DIALOG_FOR_HERO = 3
BATCH_DIALOG_FOR_MEDAL = 4
BATCH_DIALOG_FOR_MEDAL_CHIP = 5

BATCH_DIALOG_FOR_WEAPONRY = 6  --军备分解

function BatchDecomposeDialog:ctor(dialogFor,key)
	BatchDecomposeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_dialogFor = dialogFor

	self.m_checkBoxs = {}
end

function BatchDecomposeDialog:onEnter()
	BatchDecomposeDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[166]) -- 批量分解

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 210))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	if self.m_dialogFor == BATCH_DIALOG_FOR_COMPONENT then -- 配件
		local desc = ui.newTTFLabel({text = CommonText[189], font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_PIECE then -- 碎片
		local desc = ui.newTTFLabel({text = CommonText[190], font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_HERO then -- 将领
		local desc = ui.newTTFLabel({text = CommonText[529], font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_MEDAL then 
		local desc = ui.newTTFLabel({text = CommonText[20170], font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_MEDAL_CHIP then 
		local desc = ui.newTTFLabel({text = CommonText[20171], font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_WEAPONRY then 
		local desc = ui.newTTFLabel({text = CommonText[1606], font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	end

	for index = 1, 4 do
		-- 改造保证的checkbox
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onCheckedChanged)):addTo(infoBg)
		local x, y
		if index <= 2 then y = 130
		else y = 50 end

		if index == 1 or index == 3 then x = 50
		else x = 340 end

		checkBox:setPosition(x, y)
		checkBox.index = index

		if self.m_dialogFor == BATCH_DIALOG_FOR_COMPONENT then -- 配件
			local label = ui.newTTFLabel({text = CommonText.color[index + 1][2] .. CommonText[11], font = G_FONT, size = FONT_SIZE_TINY, x = checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10, y = checkBox:getPositionY(), color = COLOR[index + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_dialogFor == BATCH_DIALOG_FOR_PIECE then -- 碎片
			local label = ui.newTTFLabel({text = CommonText.color[index + 1][2] .. CommonText[164], font = G_FONT, size = FONT_SIZE_TINY, x = checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10, y = checkBox:getPositionY(), color = COLOR[index + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_dialogFor == BATCH_DIALOG_FOR_HERO then -- 将领
			local starPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. index .. ".png", checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 30, checkBox:getPositionY()):addTo(infoBg)
		elseif self.m_dialogFor == BATCH_DIALOG_FOR_MEDAL then
			local label = ui.newTTFLabel({text = CommonText.color[index][2] .. CommonText[20163][1], font = G_FONT, size = FONT_SIZE_TINY, x = checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10, y = checkBox:getPositionY(), color = COLOR[index], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_dialogFor == BATCH_DIALOG_FOR_MEDAL_CHIP then
			local label = ui.newTTFLabel({text = CommonText.color[index][2] .. CommonText[20163][1] ..CommonText[164], font = G_FONT, size = FONT_SIZE_TINY, x = checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10, y = checkBox:getPositionY(), color = COLOR[index], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_dialogFor == BATCH_DIALOG_FOR_WEAPONRY then
			local label = ui.newTTFLabel({text = CommonText.color[index][2] .. CommonText[1600][2], font = G_FONT, size = FONT_SIZE_TINY, x = checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10, y = checkBox:getPositionY(), color = COLOR[index], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			label:setAnchorPoint(cc.p(0, 0.5))
		end

		self.m_checkBoxs[index] = checkBox
	end
	--将领默认选中第一个
	if self.m_dialogFor == BATCH_DIALOG_FOR_HERO then
		self.m_checkBoxs[1]:setChecked(true)
	end

	-- 取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local strengthBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCancelCallback)):addTo(self:getBg())
	strengthBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 26)
	strengthBtn:setLabel(CommonText[2])

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local recreateBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onOKCallback)):addTo(self:getBg())
	recreateBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 26)
	recreateBtn:setLabel(CommonText[1])

end

function BatchDecomposeDialog:onCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	--将领为单选
	if self.m_dialogFor == BATCH_DIALOG_FOR_HERO then
		for index = 1,#self.m_checkBoxs do
			if index == sender.index then
				self.m_checkBoxs[index]:setChecked(true)
			else
				self.m_checkBoxs[index]:setChecked(false)
			end
		end
	end
end

function BatchDecomposeDialog:onCancelCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function BatchDecomposeDialog:onOKCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local res = {}

	for index = 1, #self.m_checkBoxs do
		if self.m_checkBoxs[index]:isChecked() then
			res[#res + 1] = index -- 品质为index(绿色为1)
		end
	end

	local canCompose = false
	local function hasQuality(quality)
		for index = 1, #res do
			local limit = res[index] + 1
			if self.m_dialogFor == BATCH_DIALOG_FOR_MEDAL or self.m_dialogFor == BATCH_DIALOG_FOR_MEDAL_CHIP or self.m_dialogFor == BATCH_DIALOG_FOR_WEAPONRY  then
				limit = res[index]
			end

			if limit >= 5 then
				canCompose = true
			end

			if limit == quality then
				return true
			end
		end
		return false
	end

	if self.m_dialogFor == BATCH_DIALOG_FOR_COMPONENT then	-- 配件
		local has = {}
		local parts = PartMO.getFreeParts()
		for index = 1, #parts do
			local part = parts[index]
			local resData = UserMO.getResourceData(ITEM_KIND_PART, part.partId)
			if hasQuality(resData.quality) and not part.locked then
				has[#has + 1] = part.keyId
			end
		end

		if #has <= 0 then
			Toast.show(CommonText[465][1])
			self:pop()
			return
		end


		local function goBatch()
			self:pop(function()
					local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
					PartExplodeDialog.new(has, res):push()
				end)
		end

		if canCompose then
			require("app.dialog.TipsAnyThingDialog").new(CommonText[1810][1],function ()
				goBatch()
			end):push()
		else
			goBatch()
		end
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_PIECE then	-- 碎片
		local has = {}
		local chips = PartMO.getAllChips()
		for index = 1, #chips do
			local chip = chips[index]
			local resData = UserMO.getResourceData(ITEM_KIND_CHIP, chip.chipId)
			if hasQuality(resData.quality) then
				has[#has + 1] = chip
			end
		end

		if #has <= 0 then
			Toast.show(CommonText[465][2])
			self:pop()
			return
		end

		local function goBatch()
			self:pop(function()
					local ChipExplodeDialog = require("app.dialog.ChipExplodeDialog")
					ChipExplodeDialog.new(has, res, ChipExplodeDialog.EXPLODE_TYPE_MULTI):push()
				end)
		end

		if canCompose then
			require("app.dialog.TipsAnyThingDialog").new(CommonText[1810][2],function ()
				goBatch()
			end):push()
		else
			goBatch()
		end
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_HERO then	-- 将领
		--判断是否有可分解的将领
		-- local heros = HeroMO.queryHeroByStar(res[1])
		local heros = HeroBO.getCanDecomposeHeros(res[1])
		if #heros == 0 then
			Toast.show(CommonText[533])
			return
		end
		require("app.dialog.HeroDecomposeDialog").new(DECOMPOSE_TYPE_BATCH,res[1]):push()
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_MEDAL then	-- 勋章
		local has = {}
		local medals = MedalMO.getFreeMedals()
		for index = 1, #medals do
			local medal = medals[index]
			local resData = UserMO.getResourceData(ITEM_KIND_MEDAL_ICON, medal.medalId)
			if hasQuality(resData.quality) and not medal.locked then
				has[#has + 1] = medal.keyId
			end
		end
		if #has <= 0 then
			Toast.show(CommonText[465][3])
			self:pop()
			return
		end

		local function goBatch()
			self:pop(function()
					local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
					PartExplodeDialog.new(has, res,"medal"):push()
				end)
		end

		if canCompose then
			require("app.dialog.TipsAnyThingDialog").new(CommonText[1810][1],function ()
				goBatch()
			end):push()
		else
			goBatch()
		end
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_WEAPONRY then
		local has = {}
		local medals = WeaponryMO.getFreeMedals()
		for index = 1, #medals do
			local medal = medals[index]
			local resData = UserMO.getResourceData(ITEM_KIND_WEAPONRY_ICON, medal.equip_id)
			if hasQuality(resData.quality) and (medals.isLock == false) then
				has[#has + 1] = medal.keyId
			end
		end
		if #has <= 0 then
			Toast.show(CommonText[1611])
			self:pop()
			return
		end
		self:pop(function()
				local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
				PartExplodeDialog.new(has, res, "weaponry"):push()
			end)
	elseif self.m_dialogFor == BATCH_DIALOG_FOR_MEDAL_CHIP then	-- 勋章碎片
		local has = {}
		local chips = MedalMO.getAllChips()
		for index = 1, #chips do
			local chip = chips[index]
			local resData = UserMO.getResourceData(ITEM_KIND_MEDAL_CHIP, chip.chipId)
			if hasQuality(resData.quality) then
				has[#has + 1] = chip
			end
		end
		if #has <= 0 then
			Toast.show(CommonText[465][4])
			self:pop()
			return
		end

		local function goBatch()
			self:pop(function()
					local ChipExplodeDialog = require("app.dialog.ChipExplodeDialog")
					ChipExplodeDialog.new(has, res, ChipExplodeDialog.EXPLODE_TYPE_MULTI,"medal"):push()
				end)
		end

		if canCompose then
			require("app.dialog.TipsAnyThingDialog").new(CommonText[1810][2],function ()
				goBatch()
			end):push()
		else
			goBatch()
		end
	end
end

return BatchDecomposeDialog
