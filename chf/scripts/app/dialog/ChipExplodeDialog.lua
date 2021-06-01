
-- 配件碎片分解预览弹出框

local Dialog = require("app.dialog.Dialog")
local ChipExplodeDialog = class("ChipExplodeDialog", Dialog)

ChipExplodeDialog.EXPLODE_TYPE_SINGLE = 1  --单个分解
ChipExplodeDialog.EXPLODE_TYPE_MULTI = 2  --多个分解
-- chips:配件碎片的chips
-- qualities: 如果chips的数量是多个，则必须有qualities字段，表示的是分解这些品质下的所有碎片
function ChipExplodeDialog:ctor(chips, qualities, explodeType, key)
	self.m_explodeType = explodeType or ChipExplodeDialog.EXPLODE_TYPE_SINGLE
	local size = cc.size(588, 382)
	if self.m_explodeType == ChipExplodeDialog.EXPLODE_TYPE_SINGLE then
		size = cc.size(588, 425)
	end

	ChipExplodeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = size})
	self.m_chips = chips
	self.m_qualities = qualities
	self.key = key

	gdump(self.m_chips, "ChipExplodeDialog:ctor chips")
	gdump(self.m_qualities, "ChipExplodeDialog:ctor qualities")
end

function ChipExplodeDialog:onEnter()
	ChipExplodeDialog.super.onEnter(self)
	
	self:setTitle(CommonText[215]) -- 分解预览

	local fittingCount = 0
	--配件芯片(分解兑换活动开启时才有)
	local actChipCount = nil
	if ActivityCenterBO.isValid(ACTIVITY_ID_PART_RESOLVE) and not self.key then
		actChipCount = 0
	end

	-- 勋章芯片
	local actMedalCount = nil
	if ActivityCenterBO.isValid(ACTIVITY_ID_MEDAL_RESOLVE) and self.key == "medal" then
		actMedalCount = 0
	end

	local kind,id = ITEM_KIND_MATERIAL, MATERIAL_ID_FITTING
	for index = 1, #self.m_chips do
		local chip = self.m_chips[index]
		local resData = nil
		if self.key == "medal" then
			resData = UserMO.getResourceData(ITEM_KIND_MEDAL_CHIP, chip.chipId)
			local temp = MedalMO.getResolveChip(chip.chipId)
			kind,id = temp.type,temp.id
			fittingCount = fittingCount + temp.count * chip.count

			if actMedalCount ~= nil then
				local count = ActivityCenterMO.getMedalResolveChipCount(29, resData.quality) * chip.count
				actMedalCount = actMedalCount + count
			end
		else
			resData = UserMO.getResourceData(ITEM_KIND_CHIP, chip.chipId)
			fittingCount = fittingCount + ChipQualityExplodeFitting[resData.quality] * chip.count
		end
		if actChipCount then
			actChipCount = actChipCount + ActivityCenterMO.getActPartResolveChip(2,resData.quality) * chip.count
		end
	end

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 200))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local desc = ui.newTTFLabel({text = CommonText[216], font = G_FONT, size = FONT_SIZE_MEDIUM, x = 20, y = infoBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	desc:setAnchorPoint(cc.p(0, 0.5))

	local fitData = UserMO.getResourceData(kind,id)

	-- 只能分解为零件
	local itemView = UiUtil.createItemView(kind,id, nil):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height - 55 - itemView:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView)

	local name = ui.newTTFLabel({text = fitData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 68, color = COLOR[fitData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 零件数量
	local label1 = ui.newTTFLabel({text = "+" .. fittingCount, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	self.m_fittingLabel = label1


    self.m_actLabel = nil
	--配件芯片(分解兑换活动开启时才有)
	if actChipCount and actChipCount > 0 then
		local itemBg = display.newSprite(IMAGE_COMMON .. "item_fame_4.png"):addTo(infoBg)
		itemBg:setPosition(320, infoBg:getContentSize().height - 55 - 53)
		local itemView = display.newSprite("image/item/activity_115_chip.jpg"):addTo(itemBg)
		itemView:setPosition(itemBg:getContentSize().width / 2 , itemBg:getContentSize().height / 2)

		local name = ui.newTTFLabel({text = CommonText[881], font = G_FONT, size = FONT_SIZE_MEDIUM, x = 385, y = infoBg:getContentSize().height - 68, color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		name:setAnchorPoint(cc.p(0, 0.5))

		-- 零件数量
		local label1 = ui.newTTFLabel({text = "+" ..UiUtil.strNumSimplify(actChipCount) , font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label1:setAnchorPoint(cc.p(0, 0.5))

		self.m_actLabel = label1
	end

	if actMedalCount and actMedalCount > 0 then
		local itemBg = display.newSprite(IMAGE_COMMON .. "item_fame_4.png"):addTo(infoBg)
		itemBg:setPosition(320, infoBg:getContentSize().height - 55 - 53)
		local itemView = display.newSprite("image/item/activity_115_chip.jpg"):addTo(itemBg)
		itemView:setPosition(itemBg:getContentSize().width / 2 , itemBg:getContentSize().height / 2)

		local name = ui.newTTFLabel({text = "勋章芯片", font = G_FONT, size = FONT_SIZE_MEDIUM, x = 385, y = infoBg:getContentSize().height - 68, color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		name:setAnchorPoint(cc.p(0, 0.5))

		-- 零件数量
		local label1 = ui.newTTFLabel({text = "+" ..UiUtil.strNumSimplify(actMedalCount) , font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label1:setAnchorPoint(cc.p(0, 0.5))

		self.m_actLabel = label1
	end

	if self.m_explodeType == ChipExplodeDialog.EXPLODE_TYPE_SINGLE then
		local chipId = self.m_chips[1].chipId
		-- local partDB = PartMO.queryPartById(chipId)
	    self.m_maxNum = 1
	    if self.key == "medal" then
    	    self.m_maxNum = UserMO.getResource(ITEM_KIND_MEDAL_CHIP, chipId)
	    else
    	    self.m_maxNum = UserMO.getResource(ITEM_KIND_CHIP, chipId)
	    end
	    self.m_minNum = 1
	    if self.m_maxNum == 0 then self.m_minNum = 0 end
	    self.m_settingNum = self.m_maxNum

	    -- 减少按钮
	    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
	    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
	    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
	    reduceBtn:setPosition(75, 90)

	    -- 增加按钮
	    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
	    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
	    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
	    addBtn:setPosition(self:getBg():getContentSize().width - 75, reduceBtn:getPositionY())

		-- 数量
		local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, 
			x = self:getBg():getContentSize().width / 2 - 100, y = 130, 
			color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		
		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))
		self.m_numLabel = label
		
		local label = ui.newTTFLabel({text = "/" .. self.m_maxNum, font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))
		self.m_maxLabel = label

		local barHeight = 40
		local barWidth = 266
		self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
		self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, reduceBtn:getPositionY() - 15)
	    self.m_numSlider:setSliderSize(barWidth, barHeight)
	    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
	    self.m_numSlider:setSliderValue(self.m_settingNum)
	    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(266 + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})
    end

	-- 取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local cancelBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCancelCallback)):addTo(self:getBg())
	cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 26)
	cancelBtn:setLabel(CommonText[2])

	-- 分解
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onExplodeCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 26)
	exchangeBtn:setLabel(CommonText[171])

end

function ChipExplodeDialog:onCancelCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self:pop()
end

function ChipExplodeDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function ChipExplodeDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function ChipExplodeDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)

	self:onUpdateValue()
end

function ChipExplodeDialog:onUpdateValue()
	local chip = self.m_chips[1]
	local resData = nil
	local fittingCount = nil
	if self.key == "medal" then
		resData = UserMO.getResourceData(ITEM_KIND_MEDAL_CHIP, chip.chipId)
		fittingCount = MedalMO.getResolveChip(chip.chipId).count * self.m_settingNum
	else
		resData = UserMO.getResourceData(ITEM_KIND_CHIP, chip.chipId)
		fittingCount = ChipQualityExplodeFitting[resData.quality] * self.m_settingNum
	end
	self.m_fittingLabel:setString("+" .. fittingCount)

	self.m_maxLabel:setPositionX(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width + 3)

	if ActivityCenterBO.isValid(ACTIVITY_ID_PART_RESOLVE) and self.m_actLabel and self.key == nil then
		local actChipCount = ActivityCenterMO.getActPartResolveChip(2, resData.quality) * self.m_settingNum
		self.m_actLabel:setString("+" .. UiUtil.strNumSimplify(actChipCount))
	elseif ActivityCenterBO.isValid(ACTIVITY_ID_MEDAL_RESOLVE) and self.m_actLabel and self.key == "medal" then
		local actMedalCount = ActivityCenterMO.getMedalResolveChipCount(29, resData.quality) * self.m_settingNum
		self.m_actLabel:setString("+" .. UiUtil.strNumSimplify(actMedalCount))
	end
end

function ChipExplodeDialog:onExplodeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	local function doneExplode(stastAwards)
		Loading.getInstance():unshow()

		Toast.show(CommonText[517]) -- 分解成功

		UiUtil.showAwards(stastAwards)

		self:pop()
	end

	Loading.getInstance():show()
	local func = self.key == "medal" and MedalBO.explodeChip or PartBO.asynExplodeChip
	if self.m_explodeType == ChipExplodeDialog.EXPLODE_TYPE_MULTI then   -- 按品质批量分解
		func(doneExplode, nil, nil, self.m_qualities)
	else
		func(doneExplode, self.m_chips[1].chipId, self.m_settingNum)
	end
end

return ChipExplodeDialog