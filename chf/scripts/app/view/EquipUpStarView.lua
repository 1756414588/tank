--
-- Author: Gss
-- Date: 2018-05-25 18:55:19
--
--装备升星

local EquipUpStarView = class("EquipUpStarView", UiNode)

function EquipUpStarView:ctor(keyId)
	EquipUpStarView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)

	self.m_keyId = keyId -- 装备的keyId
	gprint("[EquipUpStarView] keyId :", self.m_keyId)
end

function EquipUpStarView:onEnter()
	EquipUpStarView.super.onEnter(self)

	self.container = display.newNode():size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180):addTo(self)
	self:showUI()
	-- 装备升星
	self:setTitle(CommonText[5060])
end

function EquipUpStarView:showUI()
	self.hasEnough = nil
	self.hasTips = false --是否需要提示紫装的消耗
	local container = self.container
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, container:height() -  80))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - infoBg:getContentSize().height / 2 + 75)
	--获取当前点击的部件
	local equip = EquipMO.getEquipByKeyId(self.m_keyId)

	local equipDB = EquipMO.queryEquipById(equip.equipId)
	local starDB = EquipMO.queryEquipStarsById(equip.starLv + 1)

	--装备来源
	local fromBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(infoBg)
	fromBg:setPosition(infoBg:width() / 2, infoBg:height() - 13)
	local from = ""
	if equip.formatPos > 0 then
		from = string.format(CommonText[5057], equip.formatPos)
	else
		from = CommonText[210]
	end
	local fromPos = UiUtil.label(from):addTo(fromBg):center()

	if equip.starLv >= 5 then
		local beganView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(infoBg)
		beganView:setPosition(infoBg:width() / 2,infoBg:getContentSize().height - 105)
		UiUtil.createItemDetailButton(beganView)
	else
		--显示的装备
		local beganView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(infoBg)
		beganView:setPosition(130,infoBg:getContentSize().height - 105)
		UiUtil.createItemDetailButton(beganView)

		--显示箭头
		local arrow = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png"):addTo(infoBg)
		arrow:setAnchorPoint(cc.p(0,0.5))
		arrow:setPosition(beganView:getPositionX() + 120,beganView:getPositionY())

		--品质大于等于5(橙色)才能升星
		local endView = UiUtil.createItemView(ITEM_KIND_EQUIP, equipDB.equipId, {equipLv = equip.level, star = equip.starLv + 1}):addTo(infoBg)
		endView:setPosition(130 + 300,infoBg:getContentSize().height - 105)
		UiUtil.createItemDetailButton(endView)
	end

	--升星属性
	local line1 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line1:setPreferredSize(cc.size(infoBg:width() - 40, line1:getContentSize().height))
	line1:setPosition(infoBg:getContentSize().width / 2, fromBg:y() - 160)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(infoBg)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20,line1:y() - 40)

	local attr = UiUtil.label(CommonText[5061][1],24):addTo(titleBg)
	attr:setPosition(titleBg:width() / 2 - 20, titleBg:height() / 2)
	--属性加成
	local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level, equip.starLv)
	local attName = UiUtil.label(attrData.name .. CommonText[5063], nil, COLOR[3]):addTo(infoBg)
	attName:setAnchorPoint(cc.p(0, 0.5))
	attName:setPosition(35, titleBg:y() - 40)
	local value = UiUtil.label(attrData.strValue):rightTo(attName, 20)
	--上箭头
	local arrow = display.newScale9Sprite(IMAGE_COMMON .. "icon_arrow_up.png"):rightTo(value, 10)
	arrow:setVisible(equip.starLv < 5)
	local nextAttr = EquipBO.getEquipAttrData(equip.equipId, equip.level, equip.starLv + 1)
	local nextValue = UiUtil.label(nextAttr.strValue, nil, COLOR[2]):rightTo(arrow, 20)
	nextValue:setVisible(equip.starLv < 5)

	--装备星级
	local starLv =UiUtil.label(CommonText[5062], nil, COLOR[3]):addTo(infoBg)
	starLv:setAnchorPoint(cc.p(0, 0.5))
	starLv:setPosition(35, attName:y() - 30)
	local stars = UiUtil.label(equip.starLv):rightTo(starLv, 20)
	--上箭头
	local arrow = display.newScale9Sprite(IMAGE_COMMON .. "icon_arrow_up.png"):rightTo(stars, 10)
	arrow:setVisible(equip.starLv < 5)
	local nextValue = UiUtil.label(equip.starLv + 1, nil, COLOR[2]):rightTo(arrow, 20)
	nextValue:setVisible(equip.starLv < 5)

	--升星消耗
	local line2 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line2:setPreferredSize(cc.size(infoBg:width() - 40, line2:getContentSize().height))
	line2:setPosition(infoBg:getContentSize().width / 2, starLv:y() - 30)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(infoBg)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20, line2:y() - 40)
	local cost = UiUtil.label(CommonText[5061][2], 24):addTo(titleBg)
	cost:setPosition(titleBg:width() / 2 - 20, titleBg:height() / 2)

	--消耗材料列表
	if equip.starLv >= 5 then
		--星级已满
		local full = UiUtil.label(CommonText[5064]):addTo(infoBg)
		full:setPosition(infoBg:width() / 2, infoBg:height() - 450)
	else
		--消耗的装备，单独写
		local itemOne = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId - 1):addTo(infoBg)
		itemOne:setPosition(80, infoBg:height() - 440)
		itemOne:setScale(0.9)
		UiUtil.createItemDetailButton(itemOne)

		local ownCount = #EquipMO.getEquipById(equip.equipId - 1)
		local itemData = UserMO.getResourceData(ITEM_KIND_EQUIP, equip.equipId - 1)
		local itemname = ui.newTTFLabel({text = itemData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = itemOne:getPositionX() + 50, y = itemOne:getPositionY() + 28, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		itemname:setAnchorPoint(cc.p(0, 0.5))
		-- 强化需要的数量
		local need = ui.newTTFLabel({text = UiUtil.strNumSimplify(starDB.needEquip) .. "/", font = G_FONT, size = FONT_SIZE_SMALL-2, x = itemname:getPositionX(), y = itemname:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		need:setAnchorPoint(cc.p(0, 0.5))

		local count = ui.newTTFLabel({text = UiUtil.strNumSimplify(ownCount), font = G_FONT, size = FONT_SIZE_SMALL-2, x = need:getPositionX() + need:getContentSize().width, y = need:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		count:setAnchorPoint(cc.p(0, 0.5))
		if starDB.needEquip > ownCount then
			if not self.hasEnough then
				self.hasEnough = itemData.name
			end
			count:setColor(COLOR[6])
		end

		local needEquips = clone(EquipMO.getEquipById(equip.equipId - 1))
		--等级从小到大排序
		function sortFun(a,b)
			return a.level < b.level
		end

		table.sort(needEquips,sortFun)
		if starDB.needEquip <= ownCount then
			if #needEquips > 0 and needEquips[starDB.needEquip].level >= 2 then
				self.hasTips = true
			end
		end

		local costList = {}
		local costDB = json.decode(EquipMO.queryEquipStarsById(equip.starLv + 1).need)

		for k,v in ipairs (costDB) do
			table.insert(costList, {kind = v[1],id = v[2],count = v[3]})
		end

		local col = math.max(math.ceil(#costList / 2), 2)
		
		for index,v in ipairs(costList) do
			local itemView = UiUtil.createItemView(v.kind, v.id):addTo(infoBg)
			local x, y
			if index <= 1 then
				x = (infoBg:width() / col) * ((index-1)%col) + 80 + infoBg:width() / 2
			    y = infoBg:getContentSize().height - 440
			 else
			 	x = (infoBg:width() / col) * ((index-2)%col) + 80
			    y = infoBg:getContentSize().height - 550
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
	end

	--描述
	local atip = UiUtil.label(CommonText[5065][1]):addTo(infoBg)
	atip:setAnchorPoint(cc.p(0, 0.5))
	atip:setPosition(30, 30)

	local low = UiUtil.label(CommonText[5065][2], nil, COLOR[2]):rightTo(atip)
	local right = UiUtil.label(CommonText[5065][3]):rightTo(low)

	-- 升星
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local upBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onUpStarsCallback)):addTo(container)
	upBtn:setPosition(container:getContentSize().width / 2, upBtn:height() / 2 + 30)
	upBtn:setLabel(CommonText[5066])
	upBtn.equip = equip
	upBtn:setEnabled(equip.starLv < 5)
end

function EquipUpStarView:onUpStarsCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	-- 消耗不足
	if self.hasEnough then
		Toast.show(string.format(CommonText[5059], self.hasEnough))
		return
	end

	local function gotoUp()
		local function getResult(part)
			self.container:removeAllChildren()
			self:showUI()
		end
		EquipBO.equipUpStar(sender.equip,getResult)
	end

	--消耗的紫装有等级则2次确认
	if self.hasTips then
		local InfoDialog = require("app.dialog.ConfirmDialog")
		InfoDialog.new(CommonText[5068], function() gotoUp() end):push()
	else
		gotoUp()
	end
end


return EquipUpStarView