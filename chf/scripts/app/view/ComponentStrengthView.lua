
-- 配件强化

local ComponentStrengthView = class("ComponentStrengthView", UiNode)

COMPONENT_VIEW_FOR_UP = 1	   --升级
COMPONENT_VIEW_FOR_REFIT = 2   --改造
COMPONENT_VIEW_FOR_CUILIAN = 3 --淬炼
COMPONENT_VIEW_FOR_ADVANCE = 4 --进阶


-- keyId: 需要进行强化的配件的keyId
function ComponentStrengthView:ctor(viewFor, keyId)
	ComponentStrengthView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)

	self.m_viewFor = viewFor
	self.m_keyId = keyId
end

function ComponentStrengthView:onEnter()
	ComponentStrengthView.super.onEnter(self)
	self:setTitle(CommonText[173])  -- 强化

	armature_add(IMAGE_ANIMATION .. "effect/cuilianx2.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilianx2.plist", IMAGE_ANIMATION .. "effect/cuilianx2.xml")
	armature_add(IMAGE_ANIMATION .. "effect/cuilianx3.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilianx3.plist", IMAGE_ANIMATION .. "effect/cuilianx3.xml")
	armature_add(IMAGE_ANIMATION .. "effect/cuilianx5.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilianx5.plist", IMAGE_ANIMATION .. "effect/cuilianx5.xml")
	armature_add(IMAGE_ANIMATION .. "effect/cuilianx10.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilianx10.plist", IMAGE_ANIMATION .. "effect/cuilianx10.xml")
	local function createDelegate(container, index)
		self.chooseIndex = index
		if index == 1 then  -- 强化
			self:showStrength(container)
		elseif index == 2 then -- 改造
			self:showRemake(container)
		elseif index == 3 then -- 淬炼
			self:showCuilian(container)
		elseif index == 4 then -- 进阶
			self:showAdvance(container)
		end
	end

	local function clickDelegate(container, index)
		if index == 1 then
			self:setTitle(CommonText[173])
		elseif index == 2 then
			self:setTitle(CommonText[174])
		elseif index == 3 then
			self:setTitle(CommonText[5000])
		elseif index == 4 then
			self:setTitle(CommonText[5001])
		end
	end

	local function clickBaginDelegate(index)
		if index == 3 then
			if UserMO.level_ < PART_REFINE_LEVEL then
				Toast.show(string.format(CommonText[20136], PART_REFINE_LEVEL))
				return false
			end
		end
		return true
	end

	--  "强化", "改造"
	local pages = {CommonText[173], CommonText[174],CommonText[5000],CommonText[5001]}
	-- if UserBO.IsNewOpen() == false then
	-- 	pages = {CommonText[173], CommonText[174]}
	-- end
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self:getBg(), 2)

	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	if self.m_viewFor == 1 then
		self:setTitle(CommonText[173])
	elseif self.m_viewFor == 2 then
		self:setTitle(CommonText[174])
	elseif self.m_viewFor == 3 then
		self:setTitle(CommonText[5000])
	elseif self.m_viewFor == 4 then
		self:setTitle(CommonText[5001])
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_activityHandler = Notify.register(LOCAL_COMPONENT_REFRESH, handler(self, self.updateView))
end

function ComponentStrengthView:onExit()
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
	armature_remove(IMAGE_ANIMATION .. "effect/cuilianx2.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilianx2.plist", IMAGE_ANIMATION .. "effect/cuilianx2.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/cuilianx3.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilianx3.plist", IMAGE_ANIMATION .. "effect/cuilianx3.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/cuilianx5.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilianx5.plist", IMAGE_ANIMATION .. "effect/cuilianx5.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/cuilianx10.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilianx10.plist", IMAGE_ANIMATION .. "effect/cuilianx10.xml")
end

function ComponentStrengthView:updateView()
	self.m_pageView:setPageIndex(self.chooseIndex)
end

-- 
function ComponentStrengthView:showStrength(container)
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 620))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 16 - infoBg:getContentSize().height / 2)

	local part = PartMO.getPartByKeyId(self.m_keyId)

	local maxLevel = PartMO.queryPartUpMaxLevel(part.partId)

	local partDB = PartMO.queryPartById(part.partId)
	local partUp = PartMO.queryPartUp(part.partId, part.upLevel + 1)

	local attrData = PartBO.getPartAttrData(part.partId, part.upLevel, part.refitLevel, part.keyId)

	local nxtAttrData = nil
	if part.upLevel < maxLevel then
		nxtAttrData = PartBO.getPartAttrData(part.partId, part.upLevel + 1, part.refitLevel, part.keyId)
	end

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 20 - strengthLabel:getContentSize().height / 2)

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrData.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	local view = UiUtil.createItemView(ITEM_KIND_PART, part.partId, {upLv = part.upLevel, refitLv = part.refitLevel, keyId = part.keyId}):addTo(infoBg)
	UiUtil.createItemDetailButton(view)
	view:setPosition(70, infoBg:getContentSize().height - 105)

	local name = ui.newTTFLabel({text = partDB.partName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 68, color = COLOR[partDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local bottomLineHeight = infoBg:getContentSize().height - 180
	local attrData1 = attrData.attr1

	local startLabel = nil

	-- xx加成
	local label1 = ui.newTTFLabel({text = attrData1.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = attrData1.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if part.upLevel < maxLevel then
		local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(infoBg)
		arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

		local value = ui.newTTFLabel({text = nxtAttrData.attr1.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	local attrData2 = attrData.attr2
	if attrData2 then -- 有第二属性
		-- xx加成
		local labelX = ui.newTTFLabel({text = attrData2.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		labelX:setAnchorPoint(cc.p(0, 0.5))
		startLabel = labelX

		local value = ui.newTTFLabel({text = attrData2.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = labelX:getPositionX() + labelX:getContentSize().width + 5, y = labelX:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		if part.upLevel < maxLevel then
			local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(infoBg)
			arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

			local value = ui.newTTFLabel({text = nxtAttrData.attr2.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end

		bottomLineHeight = bottomLineHeight - 25
	end

	local attrData3 = attrData.attr3
	if attrData3 then -- 有第三属性
		-- xx加成
		local label3 = ui.newTTFLabel({text = attrData3.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label3:setAnchorPoint(cc.p(0, 0.5))
		startLabel = label3

		local value = ui.newTTFLabel({text = attrData3.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		if part.upLevel < maxLevel then
			local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(infoBg)
			arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

			local value = ui.newTTFLabel({text = nxtAttrData.attr3.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end

		bottomLineHeight = bottomLineHeight - 25
	end

	-- 强化等级
	local label2 = ui.newTTFLabel({text = CommonText[179] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = startLabel:getPositionX(), y = startLabel:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label2:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = part.upLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX() + label2:getContentSize().width + 5, y = label2:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if part.upLevel < maxLevel then
		local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(infoBg)
		arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

		local value = ui.newTTFLabel({text = 1, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 改造等级
	local label3 = ui.newTTFLabel({text = CommonText[178] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX() + 220, y = label2:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label3:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = part.refitLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if part.upLevel < maxLevel then
		-- 成功几率
		local label4 = ui.newTTFLabel({text = CommonText[181] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX(), y = label2:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label4:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = (partUp.prob / 10) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label4:getPositionX() + label4:getContentSize().width + 5, y = label4:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		-- VIP加成
		local vipValue = ui.newTTFLabel({text = (VipBO.getPartProb() .. "%") .. "(VIP" .. CommonText[176] .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label4:getPositionX() + 220, y = label4:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		vipValue:setAnchorPoint(cc.p(0, 0.5))
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, bottomLineHeight)

	if part.upLevel >= maxLevel then -- 是最高等级了
		gprint("强化最高等级")
		local desc = ui.newTTFLabel({text = CommonText[224], font = G_FONT, size = FONT_SIZE_MEDIUM, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 240, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		return
	end

	-- 强化消耗
	local label = ui.newTTFLabel({text = CommonText[182], font = G_FONT, size = FONT_SIZE_SMALL, x = 24, y = bottomLineHeight - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 可能失败
	local label = ui.newTTFLabel({text = "(" .. CommonText[183] .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 宝石
	local view = UiUtil.createItemView(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(infoBg)
	view:setScale(0.9)
	view:setPosition(70, bottomLineHeight - 90)
	UiUtil.createItemDetailButton(view)

	local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
	local stoneCount = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)

	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = view:getPositionX() + 64, y = view:getPositionY() + 28, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 强化需要的数量
	local need = ui.newTTFLabel({text = UiUtil.strNumSimplify(partUp.stone) .. "/", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	need:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = UiUtil.strNumSimplify(stoneCount), font = G_FONT, size = FONT_SIZE_SMALL, x = need:getPositionX() + need:getContentSize().width, y = need:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	count:setAnchorPoint(cc.p(0, 0.5))
	if stoneCount < partUp.stone then -- 宝石不足
		count:setColor(COLOR[6])
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, bottomLineHeight - 160)

	local resData = UserMO.getResourceData(ITEM_KIND_MATERIAL, MATERIAL_ID_METAL)
	local count = UserMO.getResource(ITEM_KIND_MATERIAL, MATERIAL_ID_METAL)
	-- 使用。。。增加成功率
	local label = ui.newTTFLabel({text = string.format(CommonText[184], resData.name), font = G_FONT, size = FONT_SIZE_SMALL, x = 24, y = bottomLineHeight - 190, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 当前拥有
	local label = ui.newTTFLabel({text = "(" .. CommonText[63] .. ": " .. count .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 记忆金属
	local view = UiUtil.createItemView(ITEM_KIND_MATERIAL, MATERIAL_ID_METAL):addTo(infoBg)
	view:setScale(0.9)
	view:setPosition(70, bottomLineHeight - 250)
	UiUtil.createItemDetailButton(view)

	-- 数量
	local desc = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2 + 55, y = bottomLineHeight - 230, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, color = labelColor}):addTo(infoBg)
	local num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() +  desc:getContentSize().width / 2, y = desc:getPositionY(), color = greenLabelColor}):addTo(infoBg)
	num:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = num

	local function onReduceCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self.m_settingNum = self.m_settingNum - 1
		self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
		self.m_numSlider:setSliderValue(self.m_settingNum)
	end

	local function onAddCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self.m_settingNum = self.m_settingNum + 1
		self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
		self.m_numSlider:setSliderValue(self.m_settingNum)
	end

	local function onSlideCallback(event)
		local value = event.value - event.value % 1
		self.m_settingNum = value
		self.m_numLabel:setString(self.m_settingNum)
	end

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, onReduceCallback):addTo(infoBg)
    reduceBtn:setPosition(114 + 55, bottomLineHeight - 265)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, onAddCallback):addTo(infoBg)
    addBtn:setPosition(infoBg:getContentSize().width - 114 + 55, reduceBtn:getPositionY())

    self.m_maxNum = count
    if self.m_maxNum > 10 then self.m_maxNum = 10 end
    self.m_minNum = 0
    -- if self.m_maxNum == 0 then self.m_minNum = 0 end
	-- self.m_settingNum = self.m_maxNum
	self.m_settingNum = self.m_minNum

	local barHeight = 40
	local barWidth = 216
	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(infoBg)
	self.m_numSlider:align(display.LEFT_BOTTOM, infoBg:getContentSize().width / 2 - barWidth / 2 + 55, bottomLineHeight - 280)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(onSlideCallback)
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(barWidth + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})

    -- 强化
    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local strengthBtn = MenuButton.new(normal, selected, nil, handler(self, self.onStrengthCallback)):addTo(container)
    strengthBtn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 700)
    strengthBtn:setLabel(CommonText[173])
end

local refitItemId = {MATERIAL_ID_PLAN, MATERIAL_ID_MINERAL, MATERIAL_ID_TOOL, MATERIAL_ID_FITTING}

function ComponentStrengthView:showRemake(container)
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 620))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 16 - infoBg:getContentSize().height / 2)

	local part = PartMO.getPartByKeyId(self.m_keyId)
	local partDB = PartMO.queryPartById(part.partId)

	local maxLevel = PartMO.queryPartRefitMaxLevel(partDB.quality)

	local attrData = PartBO.getPartAttrData(part.partId, part.upLevel, part.refitLevel, part.keyId)
	local nxtAttrData = nil
	if part.refitLevel < maxLevel then
		nxtAttrData = PartBO.getPartAttrData(part.partId, part.upLevel, part.refitLevel + 1,part.keyId)
	end

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 20 - strengthLabel:getContentSize().height / 2)

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrData.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	local view = UiUtil.createItemView(ITEM_KIND_PART, part.partId, {upLv = part.upLevel, refitLv = part.refitLevel, keyId = part.keyId}):addTo(infoBg)
	view:setPosition(70, infoBg:getContentSize().height - 105)
	UiUtil.createItemDetailButton(view)

	local name = ui.newTTFLabel({text = partDB.partName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 68, color = COLOR[partDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local startLabel = nil

	local attrData1 = attrData.attr1

	-- xx加成
	local label1 = ui.newTTFLabel({text = attrData1.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = attrData1.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if part.refitLevel < maxLevel then
		local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(infoBg)
		arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

		local value = ui.newTTFLabel({text = nxtAttrData.attr1.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	local attrData2 = attrData.attr2
	if attrData2 then -- 有第二属性
		-- xx加成
		local labelX = ui.newTTFLabel({text = attrData2.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		labelX:setAnchorPoint(cc.p(0, 0.5))
		startLabel = labelX

		local value = ui.newTTFLabel({text = attrData2.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = labelX:getPositionX() + labelX:getContentSize().width + 5, y = labelX:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		if part.refitLevel < maxLevel then
			local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(infoBg)
			arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

			local value = ui.newTTFLabel({text = nxtAttrData.attr2.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	local attrData3 = attrData.attr3
	if attrData3 then -- 有第三属性
		-- xx加成
		local label3 = ui.newTTFLabel({text = attrData3.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label3:setAnchorPoint(cc.p(0, 0.5))
		startLabel = label3

		local value = ui.newTTFLabel({text = attrData3.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		if part.refitLevel < maxLevel then
			local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(infoBg)
			arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

			local value = ui.newTTFLabel({text = nxtAttrData.attr3.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	-- 改造等级
	local label2 = ui.newTTFLabel({text = CommonText[178] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = startLabel:getPositionX(), y = startLabel:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label2:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = part.refitLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX() + label2:getContentSize().width + 5, y = label2:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if part.refitLevel < maxLevel then
		local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(infoBg)
		arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

		-- 升一级
		local delta = ui.newTTFLabel({text = 1, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 强化等级
	local label3 = ui.newTTFLabel({text = CommonText[179] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX() + 220, y = label2:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label3:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = part.upLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	if part.refitLevel < maxLevel then
		if part.upLevel == 0 then
		else
			if not ActivityBO.isValid(ACTIVITY_ID_PART_EVOLVE) then -- 如果活动有效，则不会降低等级的
				local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_down.png"):addTo(infoBg)
				arrow:setPosition(value:getPositionX() + value:getContentSize().width + arrow:getContentSize().width / 2 + 8, value:getPositionY())

				local downLevel = PART_REFIT_REDUCE_UP_LEVEL
				if part.upLevel < downLevel then downLevel = part.upLevel end
				-- 降强化等级
				local delta = ui.newTTFLabel({text = downLevel, font = G_FONT, size = FONT_SIZE_SMALL, x = arrow:getPositionX() + arrow:getContentSize().width / 2 + 2, y = arrow:getPositionY(), color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
				delta:setAnchorPoint(cc.p(0, 0.5))
			end
		end
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 203)

	if part.refitLevel >= maxLevel then
		gprint("改造已经是满级了")
		local desc = ui.newTTFLabel({text = CommonText[225], font = G_FONT, size = FONT_SIZE_MEDIUM, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 240, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		return
	end

	local partRefit = PartMO.queryPartRefit(partDB.quality, part.refitLevel + 1, part.partId)

	-- 改造消耗
	local label = ui.newTTFLabel({text = CommonText[185], font = G_FONT, size = FONT_SIZE_SMALL, x = 24, y = infoBg:getContentSize().height - 227, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- ..降低强化等级
	local label = ui.newTTFLabel({text = "(" .. string.format(CommonText[186], PART_REFIT_REDUCE_UP_LEVEL) .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	local cost = {}
	for index = 1, #refitItemId do
		local needCount = 0
		if refitItemId[index] == MATERIAL_ID_PLAN then needCount = partRefit.plan
		elseif refitItemId[index] == MATERIAL_ID_MINERAL then needCount = partRefit.mineral
		elseif refitItemId[index] == MATERIAL_ID_TOOL then needCount = partRefit.tool
		elseif refitItemId[index] == MATERIAL_ID_FITTING then needCount = partRefit.fitting
		end
		if needCount > 0 then 
			table.insert(cost, {kind = ITEM_KIND_MATERIAL,id = refitItemId[index], count = needCount})
		end
	end
	if partRefit.cost and partRefit.cost ~= "" then
		for k,v in ipairs(json.decode(partRefit.cost)) do
			table.insert(cost, {kind = v[1],id = v[2],count = v[3]})
		end
	end
	self.hasEnough = nil

	local col = math.max(math.ceil(#cost / 2), 2)

	for index,v in ipairs(cost) do
		local itemView = UiUtil.createItemView(v.kind, v.id):addTo(infoBg)
		local x, y
		-- if index == 1 or index == 3 then x = 70 else x = 340 end
		-- if index == 1 or index == 2 then y = infoBg:getContentSize().height - 295 else y = infoBg:getContentSize().height - 405 end
		if index <= col then
			x = (infoBg:width() / col) * ((index-1)%col) + 50
		    y = infoBg:getContentSize().height - 295
		 else
		 	x = (infoBg:width() / col) * ((index-1)%col) + 50
		    y = infoBg:getContentSize().height - 405
		 end
		itemView:setPosition(x, y)
		itemView:setScale(0.9)
		UiUtil.createItemDetailButton(itemView)

		local hasCount = UserMO.getResource(v.kind, v.id)
		local resData = UserMO.getResourceData(v.kind, v.id)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX() + 50, y = itemView:getPositionY() + 28, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		name:setAnchorPoint(cc.p(0, 0.5))
		-- 强化需要的数量
		local need = ui.newTTFLabel({text = UiUtil.strNumSimplify(v.count) .. "/", font = G_FONT, size = FONT_SIZE_SMALL-2, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		need:setAnchorPoint(cc.p(0, 0.5))

		local count = ui.newTTFLabel({text = UiUtil.strNumSimplify(hasCount), font = G_FONT, size = FONT_SIZE_SMALL-2, x = need:getPositionX() + need:getContentSize().width, y = need:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		count:setAnchorPoint(cc.p(0, 0.5))
		if v.count > hasCount then
			if not self.hasEnough then
				self.hasEnough = resData.name
			end
			count:setColor(COLOR[6])
		end
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 470)

	-- 改造保证
	local label = ui.newTTFLabel({text = CommonText[187], font = G_FONT, size = FONT_SIZE_SMALL, x = 24, y = infoBg:getContentSize().height - 497, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local resData = UserMO.getResourceData(ITEM_KIND_MATERIAL, MATERIAL_ID_DRAW)
	local drawCount = UserMO.getResource(ITEM_KIND_MATERIAL, MATERIAL_ID_DRAW)

	-- 使用..保证不降低强化等级
	local label = ui.newTTFLabel({text = "(" .. string.format(CommonText[188], resData.name) .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 改造图纸
	local itemView = UiUtil.createItemView(ITEM_KIND_MATERIAL, MATERIAL_ID_DRAW):addTo(infoBg)
	UiUtil.createItemDetailButton(itemView)
	itemView:setScale(0.9)
	itemView:setPosition(70, infoBg:getContentSize().height - 565)

	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = itemView:getPositionX() + 64, y = itemView:getPositionY() + 28, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 强化需要的数量
	local need = ui.newTTFLabel({text = UiUtil.strNumSimplify(PART_REFIT_DRAW_NUM) .. "/", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	need:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = UiUtil.strNumSimplify(drawCount), font = G_FONT, size = FONT_SIZE_SMALL, x = need:getPositionX() + need:getContentSize().width, y = need:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	count:setAnchorPoint(cc.p(0, 0.5))
	if PART_REFIT_DRAW_NUM > drawCount then
		count:setColor(COLOR[6])
	end

	local function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		local count = UserMO.getResource(ITEM_KIND_MATERIAL, MATERIAL_ID_DRAW)
		if PART_REFIT_DRAW_NUM > count then
			local resData = UserMO.getResourceData(ITEM_KIND_MATERIAL, MATERIAL_ID_DRAW)
			Toast.show(resData.name .. CommonText[223])
			sender:setChecked(false)
		end
	end

	-- 改造保证的checkbox
	local checkBox = CheckBox.new(nil, nil, onCheckedChanged):addTo(infoBg)
	checkBox:setAnchorPoint(cc.p(0, 0.5))
	checkBox:setPosition(330, count:getPositionY())
	self.m_refitCheckBox = checkBox

	-- 改装
    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local remakeBtn = MenuButton.new(normal, selected, nil, handler(self, self.onRefitCallback)):addTo(container)
    remakeBtn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 700)
    remakeBtn:setLabel(CommonText[174])
end

function ComponentStrengthView:showAdvance(container)
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 670))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 16 - infoBg:getContentSize().height / 2)
	--获取当前点击的部件
	local part = PartMO.getPartByKeyId(self.m_keyId)
	local partDB = PartMO.queryPartById(part.partId)
	local qualityDB = PartMO.queryQualityById(part.partId)
	-- dump(partDB,"partDB")
	local maxLevel = PartMO.queryPartRefitMaxLevel(partDB.quality)
	local attrData = PartBO.getPartAttrData(part.partId,part.upLevel,part.refitLevel,part.keyId)

	--详情按钮
	local detail_normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local detail_selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(detail_normal, detail_selected, nil, handler(self, self.onAdvanceDetail)):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 50,infoBg:getContentSize().height - 20 - detailBtn:getContentSize().height / 2)

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 20 - strengthLabel:getContentSize().height / 2)

	--强度值
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrData.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	--显示的part
	local beganView = UiUtil.createItemView(ITEM_KIND_PART,part.partId,{upLv = part.upLevel, refitLv = part.refitLevel, keyId = part.keyId}):addTo(infoBg)
	beganView:setPosition(70,infoBg:getContentSize().height - 105)
	UiUtil.createItemDetailButton(beganView)

	--显示箭头
	local arrow = display.newSprite(IMAGE_COMMON .. "advance_arrow.png"):addTo(infoBg)
	arrow:setAnchorPoint(cc.p(0,0.5))
	arrow:setPosition(beganView:getPositionX() + 120,beganView:getPositionY())

	if qualityDB then
		local endView = UiUtil.createItemView(ITEM_KIND_PART,qualityDB.transformPart ,{upLv = 0, refitLv = 0, keyId = part.keyId}):addTo(infoBg)
		endView:setPosition(70 + 300,infoBg:getContentSize().height - 105)
		UiUtil.createItemDetailButton(endView)

		local partName = CommonText.PartPos2Name[PartMO.getPosByPartId(part.partId)]
		--part的名字
		local beganName = ui.newTTFLabel({text = partName,font = G_FONT,size = FONT_SIZE_SMALL,x = beganView:getPositionX(), y = beganView:getPositionY() - beganView:getContentSize().height/2,color = COLOR[partDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		beganName:setAnchorPoint(cc.p(0.5,1))
		beganName:setScale(0.8)

		local endName = ui.newTTFLabel({text = partName,font = G_FONT,size = FONT_SIZE_SMALL,x = endView:getPositionX(), y = endView:getPositionY() - endView:getContentSize().height/2,color = COLOR[partDB.quality + 2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		endName:setAnchorPoint(cc.p(0.5,1))
		endName:setScale(0.8)
	else
		UiUtil.label(CommonText[5024],nil,COLOR[6]):addTo(infoBg):pos(370,infoBg:getContentSize().height - 105)
		return
	end
	--分节线
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 203)

	if not qualityDB and partDB.quality == 4 then
		local desc = ui.newTTFLabel({text = CommonText[5007], font = G_FONT, size = FONT_SIZE_MEDIUM, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 240, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		return
	end
	-- 进阶消耗
	local label = ui.newTTFLabel({text = CommonText[5002], font = G_FONT, size = FONT_SIZE_SMALL, x = 24, y = infoBg:getContentSize().height - 227, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	-- 进阶note
	local label = ui.newTTFLabel({text = CommonText[5003], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	--需要消耗的材料
	local x,y,ex,ey = 70,infoBg:height() - 295, 275, 112
	for k,v in ipairs(json.decode(qualityDB.cost)) do
		local tx,ty = x + (k-1)%2*ex,y - math.floor((k-1)/2)*ey
		local view = UiUtil.createItemView(v[1], v[2]):addTo(infoBg):pos(tx,ty):scale(0.82)
		UiUtil.createItemDetailButton(view)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local t = UiUtil.label(propDB.name,nil,COLOR[propDB.quality or 1]):addTo(infoBg):align(display.LEFT_CENTER,tx+65,ty+32)
		t = UiUtil.label(UiUtil.strNumSimplify(v[3])):alignTo(t, -32, 1)
		local own = UserMO.getResource(v[1],v[2])
		UiUtil.label("/"..UiUtil.strNumSimplify(own),nil,COLOR[own<v[3] and 6 or 2]):rightTo(t)
	end

	--分节线2
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 370)
	--材料返还label
	local back = ui.newTTFLabel({text = CommonText[5004], font = G_FONT, size = FONT_SIZE_SMALL, x = 24, y = infoBg:getContentSize().height - 394, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	back:setAnchorPoint(cc.p(0, 0.5))
	--进阶后返还部分水晶和全部材料
	local back_note = ui.newTTFLabel({text = CommonText[5005], font = G_FONT, size = FONT_SIZE_SMALL, x = back:getPositionX() + back:getContentSize().width, y = back:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	back_note:setAnchorPoint(cc.p(0, 0.5))

	if not qualityDB or part.refitLevel < 4 then
		UiUtil.label(CommonText[5006],nil,COLOR[6]):addTo(infoBg):align(display.LEFT_CENTER,70,70)
		return
	end
	--显示返还的材料
	local list = PartMO.getAdvReturn(part)
	for k,v in ipairs(list) do
		local t = UiUtil.createItemView(v[1], v[2], {count = v[3]}):addTo(infoBg):pos(70+(k-1)*130, 200):scale(0.82)
		if k > 4 then
			t:setPosition(70+(k-5)*130, 172 - 95)
		end
		UiUtil.createItemDetailButton(t)
		local propDB = UserMO.getResourceData(v[1], v[2])
		UiUtil.label(propDB.name, nil, COLOR[propDB.quality or 1]):addTo(infoBg):pos(t:x(),t:y()-55)
	end

	--点击进阶按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local advanceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAdvanceCallback)):addTo(container)
    advanceBtn:setPosition(container:getContentSize().width / 2, advanceBtn:height() / 2)
    advanceBtn:setLabel(CommonText[5001])
    advanceBtn.part = part
end

function ComponentStrengthView:showCuilian(container)     --淬炼
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 620))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 16 - infoBg:getContentSize().height / 2)
	--获取当前点击部件的信息
	local part = PartMO.getPartByKeyId(self.m_keyId)
	local partDB = PartMO.queryPartById(part.partId)
	local maxLevel = PartMO.queryPartRefitMaxLevel(partDB.quelity)

	local attrData = PartBO.getPartAttrData(part.partId,part.upLevel,part.refitLevel,part.keyId)
	--详情按钮
	local detail_normal = display.newSprite(IMAGE_COMMON.."btn_detail_normal.png")
	local detail_selected = display.newSprite(IMAGE_COMMON.."btn_detail_selected.png")
	local detailBtn = MenuButton.new(detail_normal,detail_selected,nil,handler(self,self.onCuilianDetail)):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 50,infoBg:getContentSize().height - 20 - detailBtn:getContentSize().height / 2)

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 10 - strengthLabel:getContentSize().height / 2)

	--强度值
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrData.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	--显示部件
	local newView = UiUtil.createItemView(ITEM_KIND_PART,part.partId,{upLv = part.upLevel, refitLv = part.refitLevel,keyId = part.keyId}):addTo(infoBg)
	newView:setPosition(70,infoBg:getContentSize().height - 85)
	UiUtil.createItemDetailButton(newView)
	newView:setScale(0.8)
	--显示部件的名字
	local name = ui.newTTFLabel({
		text = partDB.partName,
		font = G_FONT,
		size = FONT_SIZE_SMALL,
		x = 30,
		y = newView:getPositionY() - newView:getContentSize().height/2 - 15,
		color = COLOR[partDB.quality + 1],
		align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0,0))
	name:setScale(0.8)
	if partDB.quality<2 then
		UiUtil.label(CommonText[5025],nil,COLOR[6]):addTo(infoBg):align(display.LEFT_CENTER,130,infoBg:getContentSize().height - 85)
		return
	end
	--淬炼等级
	local t = UiUtil.label(CommonText[5008] .. (part.smeltLv >= partDB.lvMax and "MAX" or part.smeltLv)):addTo(infoBg):align(display.LEFT_CENTER,130,infoBg:getContentSize().height - 65)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_act_science.png")
	ScaleButton.new(normal, function()
			require("app.dialog.DetailTextDialog").new(PartMO.getRefineMax(part)):push()
		end):rightTo(t, 5)
	if part.crit and part.crit > 1 then
		local flame = armature_create("cuilianx"..part.crit, nil, nil, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					if movementID == "x" then
						armature:runAction(transition.sequence({cc.DelayTime:create(0.5), cc.CallFuncN:create(function()
								armature:removeSelf()
								part.crit = nil
							end)}))
					else
						local path = "animation/effect/cuilian_x"..part.crit..".plist"
						local particleSys = cc.ParticleSystemQuad:create(path)
						particleSys:setPosition(cc.p(t:x() + 310,t:y() + 10))
						particleSys:addTo(infoBg,998)

						armature:getAnimation():playWithIndex(1)
					end
					end
			end)
		flame:getAnimation():playWithIndex(0)
		flame:setScale(0.7)
		flame:setPosition(t:x() + 310,t:y() + 10)
		flame:addTo(infoBg,999)
	end
	--等级bar
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(infoBg)
				:alignTo(t, -32, 1)
	--bar后面经验等级显示
	local expPro = json.decode(partDB.smeltExp)
	if not expPro[part.smeltLv + 1] then
		UiUtil.label("MAX",nil,COLOR[2]):rightTo(bar, 10)
		bar:setPercent(1)
	elseif part.smeltLv < partDB.lvMax then
		UiUtil.label(part.smeltExp .."/"..expPro[part.smeltLv + 1]):rightTo(bar, 10)
		bar:setPercent(part.smeltExp/expPro[part.smeltLv + 1])
	elseif part.smeltLv >= partDB.lvMax then
		bar:setPercent(1)
	end
	-- 淬炼属性
	-- local labelBg = ui.newTTFLabel({text = "淬炼消耗", font = G_FONT, size = FONT_SIZE_SMALL, x = 24, y = infoBg:getContentSize().height - 227, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	-- label:setAnchorPoint(cc.p(0, 0.5))
	local labelBg = display.newSprite(IMAGE_COMMON.."info_bg_12.png"):addTo(infoBg)
	labelBg:setPosition(24,infoBg:getContentSize().height - 180)
	labelBg:setAnchorPoint(cc.p(0, 0.5))
	local label = ui.newTTFLabel({text = CommonText[5009],
	 	font = G_FONT, 
	 	size = FONT_SIZE_SMALL,
	  	x = 50,
	  	y = 25, 
	  	color = COLOR[2], 
	  	align = ui.TEXT_ALIGN_CENTER})
	:addTo(labelBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	local canUse = false
	local list = PartMO.getRefineAttr(part)
	local x,y,ey = 50,infoBg:height()-215,25
	for k,v in ipairs(list) do
		local name = UiUtil.label(v.name):addTo(infoBg):align(display.LEFT_CENTER,x,y-(k-1)*ey)
		local t = UiUtil.label(v.value[1],nil,COLOR[2]):alignTo(name,100)
		if v.max then
			t = UiUtil.label("(MAX)", 20, COLOR[12]):rightTo(t)
		end
		if v.limit then
			UiUtil.label(v.limit,nil,COLOR[6]):alignTo(name,250)
		else
			canUse = true
			if v.value[2] then
				local tag = v.flag >= 0 and "icon_arrow_up.png" or "icon_arrow_down.png"
				tag = display.newSprite(IMAGE_COMMON..tag):alignTo(name,250)
				UiUtil.label(v.value[2],nil,COLOR[v.flag >= 0 and 2 or 6]):rightTo(tag, 10)
				if v.max then
					UiUtil.label(CommonText[20138], nil, COLOR[12]):rightTo(tag,90)
				end
			else
				if v.max then
					UiUtil.label(CommonText[20138], nil, COLOR[12]):alignTo(name,250)
				end
			end
		end
	end
	--激活属性
	local labelBg1 = display.newSprite(IMAGE_COMMON.."info_bg_12.png"):addTo(infoBg)
	labelBg1:setPosition(24,infoBg:getContentSize().height - 327)
	labelBg1:setAnchorPoint(cc.p(0, 0.5))
	local label2 = ui.newTTFLabel({text = CommonText[5010],
	 	font = G_FONT, 
	 	size = FONT_SIZE_SMALL,
	  	x = 50,
	  	y = 25, 
	  	color = COLOR[2], 
	  	align = ui.TEXT_ALIGN_CENTER})
	:addTo(labelBg1)
	label2:setAnchorPoint(cc.p(0, 0.5))

	local list = PartMO.getActiveAttr(part)
	local x,y,ey = 50,infoBg:height()-360,25
	for k,v in ipairs(list) do
		local name = UiUtil.label(v.name):addTo(infoBg):align(display.LEFT_CENTER,x,y-(k-1)*ey)
		UiUtil.label(v.value,nil,COLOR[2]):alignTo(name,100)
		if v.limit then
			UiUtil.label(v.limit,nil,COLOR[6]):alignTo(name,250)
		end
	end

	--淬炼方式
	local labelBg2 = display.newSprite(IMAGE_COMMON.."info_bg_12.png"):addTo(infoBg)
	labelBg2:setPosition(24,infoBg:getContentSize().height - 477)
	labelBg2:setAnchorPoint(cc.p(0, 0.5))
	local label = ui.newTTFLabel({text = CommonText[5013],
	 	font = G_FONT, 
	 	size = FONT_SIZE_SMALL,
	  	x = 50,
	  	y = 25, 
	  	color = COLOR[2], 
	  	align = ui.TEXT_ALIGN_CENTER})
	:addTo(labelBg2)
	label:setAnchorPoint(cc.p(0, 0.5))

	    --保存
    local normal = display.newSprite(IMAGE_COMMON .. "btn_small_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_small_selected.png")
    local disabled = display.newSprite(IMAGE_COMMON .. "btn_small_disabled.png")
    local cuilianBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onCuilianCallback)):addTo(container,0,2)
    cuilianBtn:setPosition(container:getContentSize().width / 2 - 78, container:getContentSize().height - 700)
    cuilianBtn:setLabel(CommonText[309])
    cuilianBtn:setEnabled(not part.saved and canUse)
    cuilianBtn.part = part
	--点击淬炼按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_small_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_small_selected.png")
    local disabled = display.newSprite(IMAGE_COMMON .. "btn_small_disabled.png")
    local accordBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onCuilianCallback)):addTo(container,0,1)
    accordBtn:leftTo(cuilianBtn,-10)
    accordBtn:setLabel(CommonText[5000])
   	accordBtn:setEnabled(canUse)
   	accordBtn.part = part
    --自动淬炼
    local normal = display.newSprite(IMAGE_COMMON .. "btn_small_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_small_selected.png")
    local disabled = display.newSprite(IMAGE_COMMON .. "btn_small_disabled.png")
    local saveBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onCuilianCallback)):addTo(container,0,3)
    saveBtn:rightTo(cuilianBtn,-10)
    saveBtn:setLabel(CommonText[5015][1])
    saveBtn:setEnabled(canUse)
    saveBtn.part = part
    self.m_saveBtn = saveBtn

    --自动淬炼
    local normal = display.newSprite(IMAGE_COMMON .. "btn_small_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_small_selected.png")
    local disabled = display.newSprite(IMAGE_COMMON .. "btn_small_disabled.png")
    local saveBtn1 = MenuButton.new(normal, selected, disabled, handler(self, self.onCuilianCallback)):addTo(container,0,4)
    saveBtn1:rightTo(saveBtn,-10)
    saveBtn1:setLabel(CommonText[5015][2])
    saveBtn1:setEnabled(canUse)
    saveBtn1.part = part
    self.m_saveBtn1 = saveBtn1

	--checkBox选择
	self.checkBox = {}
	local function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		if not isChecked then
			sender:setChecked(true)
			return 
		end

		for k,v in ipairs(self.checkBox) do
			if v:getTag() ~= sender:getTag() then
				v:setChecked(false)
			end

			if v:getTag() == 1 or sender:getTag() == 1 then
				self.m_saveBtn:setLabel(CommonText[5015][2])
				self.m_saveBtn.times = 100
				self.m_saveBtn.tagNum = 2
				self.m_saveBtn1:setLabel(CommonText[5015][3])
				self.m_saveBtn1.times = 1000
				self.m_saveBtn1.tagNum = 3
			else
				self.m_saveBtn:setLabel(CommonText[5015][1])
				self.m_saveBtn.times = 10
				self.m_saveBtn.tagNum = 1
				self.m_saveBtn1:setLabel(CommonText[5015][2])
				self.m_saveBtn1.times = 100
				self.m_saveBtn1.tagNum = 2
			end
		end
		PartMO.oldCheckIndex = sender:getTag()
		infoBg:removeChildByTag(99)
		local sb = PartMO.querySmeltById(sender:getTag())
		local cost = json.decode(sb.cost)
		itemView = UiUtil.createItemView(cost[1],cost[2]):addTo(infoBg,0,99):pos(90,38):scale(0.7)
		UiUtil.createItemDetailButton(itemView)
		local propDB = UserMO.getResourceData(cost[1], cost[2])
		local t = UiUtil.label(propDB.name,nil,COLOR[propDB.quality or 1])
			:addTo(itemView):align(display.LEFT_CENTER,itemView:width()/2 + 70, itemView:height()/2 + 20)
		t:scale(1/itemView:getScale())
		t = UiUtil.label(UiUtil.strNumSimplify(cost[3])):alignTo(t, -40, 1)
		t:scale(1/itemView:getScale())
		local own = UserMO.getResource(cost[1],cost[2])
		UiUtil.label("/"..UiUtil.strNumSimplify(own),nil,COLOR[own<cost[3] and 6 or 2])
			:addTo(itemView):align(display.LEFT_CENTER, t:x() + t:width()*t:getScaleX(),t:y()):scale(1/itemView:getScale())
	end
	--专家
	local checkBox1 = CheckBox.new(nil, nil, onCheckedChanged):addTo(infoBg,0,2)
	checkBox1:setPosition(infoBg:getContentSize().width / 2,labelBg2:getPositionY() - labelBg2:getContentSize().height / 2 - checkBox1:getContentSize().height / 2)
	table.insert(self.checkBox, checkBox1)
	local lab = ui.newTTFLabel({
		text = CommonText[5014][1],
		font = G_FONT,
		size = FONT_SIZE_SMALL,
		color = COLOR[3],
		align = ui.TEXT_ALIGN_CENTER,
		x = checkBox1:getPositionX() + 30,
		y = checkBox1:getPositionY()
		})
	:addTo(infoBg)
	lab:setAnchorPoint(cc.p(0,0.5))
	--普通
	local checkBox2 = CheckBox.new(nil, nil, onCheckedChanged):addTo(infoBg,0,1)
	checkBox2:leftTo(checkBox1,150)
	table.insert(self.checkBox, checkBox2)

	local lab1 = ui.newTTFLabel({
		text = CommonText[559][1],
		font = G_FONT,
		size = FONT_SIZE_SMALL,
		align = ui.TEXT_ALIGN_CENTER,
		})
	:addTo(infoBg)
	lab1:setAnchorPoint(cc.p(0,0.5))
	lab1:leftTo(lab,150)
	--大师
	local checkBox3 = CheckBox.new(nil, nil, onCheckedChanged):addTo(infoBg,0,3)
	checkBox3:rightTo(checkBox1,150)
	table.insert(self.checkBox, checkBox3)

	local lab2 = ui.newTTFLabel({
		text = CommonText[5014][2],
		font = G_FONT,
		size = FONT_SIZE_SMALL,
		color = COLOR[12],
		align = ui.TEXT_ALIGN_CENTER,
		-- x = checkBox1:getPositionX() + 30,
		-- y = checkBox1:getPositionY()
		})
	:addTo(infoBg)
	lab2:setAnchorPoint(cc.p(0,0.5))
	lab2:rightTo(lab,150)

	local index = PartMO.oldCheckIndex or 1
	for k,v in ipairs(self.checkBox) do
		if v:getTag() == index then
			v:setChecked(true)
			onCheckedChanged(v,true)
		end
	end
end

function ComponentStrengthView:onStrengthCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local stoneCount = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)

	local part = PartMO.getPartByKeyId(self.m_keyId)

	if part.upLevel >= UserMO.level_ then  -- 指挥官等级不足
		Toast.show(CommonText[485][1])
		return
	end

	local partUp = PartMO.queryPartUp(part.partId, part.upLevel + 1)

	if stoneCount < partUp.stone then -- 宝石不足
		local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
		Toast.show(resData.name .. CommonText[217])
		return
	end

	local function doneUpPart(success)
		self.m_isStrength = false
		Loading.getInstance():unshow()

		if success then
			Toast.show(CommonText[219])
		else
			Toast.show(CommonText[220])
		end
		self.m_pageView:reloadContainer(1)
	end

	Loading.getInstance():show()
	PartBO.asynUpPart(doneUpPart, self.m_keyId, self.m_settingNum)
end

function ComponentStrengthView:onRefitCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if self.hasEnough then  -- 消耗不足
		Toast.show(self.hasEnough .. CommonText[218])
		return
	end
	local function doneRefitPart()
		Loading.getInstance():unshow()
		self.m_isRefit = false

		Toast.show(CommonText[221])
		self.m_pageView:reloadContainer(2)
	end

	Loading.getInstance():show()
	PartBO.asynRefitPart(doneRefitPart, self.m_keyId, self.m_refitCheckBox:isChecked())
end

function ComponentStrengthView:onAdvanceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function getResult(part)
		self.m_pageView:setPageIndex(COMPONENT_VIEW_FOR_ADVANCE)
	end
	PartBO.qualityUp(getResult,sender.part)
end

function ComponentStrengthView:onCuilianCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if tag == 1 then
		local index = 1
		for k,v in ipairs(self.checkBox) do
			if v:isChecked() then
				index = v:getTag()
				break
			end
		end
		PartBO.refineUp(function()
				self.m_pageView:setPageIndex(COMPONENT_VIEW_FOR_CUILIAN)
			end,sender.part,index)
	elseif tag == 2 then
		PartBO.refineSave(function()
				self.m_pageView:setPageIndex(COMPONENT_VIEW_FOR_CUILIAN)
			end,sender.part)
	else
		require("app.dialog.RefineTenDialog").new(tag,sender.part, sender.times, sender.tagNum):push()
	end
end

function ComponentStrengthView:onAdvanceDetail(tag, sender)
	ManagerSound.playNormalButtonSound()
	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	DetailTextDialog.new(DetailText.advance):push()
end

function ComponentStrengthView:onCuilianDetail(tag, sender)
	ManagerSound.playNormalButtonSound()
	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	DetailTextDialog.new(DetailText.cuilian):push()
end

return ComponentStrengthView
