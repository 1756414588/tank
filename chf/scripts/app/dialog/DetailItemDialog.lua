
-- 点击图标，显示物品详情的弹出框

local Dialog = require("app.dialog.Dialog")
local DetailItemDialog = class("DetailItemDialog", Dialog)

function DetailItemDialog:ctor(kind, id, param)
	if kind == ITEM_KIND_COIN or kind == ITEM_KIND_PROP or kind == ITEM_KIND_RED_PACKET or kind == ITEM_KIND_EQUIP or kind == ITEM_KIND_FAME then
		DetailItemDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 200)})
	elseif kind == ITEM_KIND_PART then
		if param then
			DetailItemDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 480)})
		else
			DetailItemDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 240)})
		end
		-- DetailItemDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 480)})
	elseif kind == ITEM_KIND_ATTRIBUTE then
		DetailItemDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 100)})
	elseif kind == ITEM_KIND_MEDAL_ICON then
		DetailItemDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 230)})
	else
		DetailItemDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 200)})
	end

	gdump(param, "DetailItemDialog")
	param = param or {}
	if not param.count or param.count <= 0 then
		self.noCount = true
	end
	local param = clone(param)
	param.count = param.count or 1

	self.m_kind = kind
	self.m_id = id
	self.m_param = param
end

function DetailItemDialog:onEnter()
	DetailItemDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailItemDialog:showUI()
	local label = nil
	if self.m_kind == ITEM_KIND_COIN or self.m_kind == ITEM_KIND_EXPLOIT or self.m_kind == ITEM_KIND_FORMATION 
		or self.m_kind == ITEM_KIND_POWER or self.m_kind == ITEM_KIND_CROSSSCORE or self.m_kind == ITEM_KIND_HUNTER_COIN then
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)

		local resData = UserMO.getResourceData(self.m_kind, self.m_id)

		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))

		-- 数量
		label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))
		local str = CommonText[397][1]
		if self.m_kind == ITEM_KIND_EXPLOIT then
			str = CommonText[397][4]
		elseif self.m_kind == ITEM_KIND_FORMATION then
			str = CommonText[397][5]
		elseif self.m_kind == ITEM_KIND_POWER then
			str = CommonText[397][6]
		elseif self.m_kind == ITEM_KIND_CROSSSCORE then
			str = CommonText[397][7]
		elseif self.m_kind == ITEM_KIND_HUNTER_COIN then
			str = CommonText[397][8]
		end
		local desc = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, x = -170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 80)}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 1))
	elseif self.m_kind == ITEM_KIND_FAME then  -- 声望
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)

		local resData = UserMO.getResourceData(self.m_kind, self.m_id)

		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))

		-- 数量
		label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local desc = ui.newTTFLabel({text = CommonText[397][2], font = G_FONT, size = FONT_SIZE_SMALL, x = -170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 80)}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 1))
	elseif self.m_kind == ITEM_KIND_RESOURCE or self.m_kind == ITEM_KIND_MATERIAL then
		local resData = UserMO.getResourceData(self.m_kind, self.m_id)

		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)

		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))

		local desc = ui.newTTFLabel({text = resData.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = -170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 80)}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 1))
	elseif self.m_kind == ITEM_KIND_EQUIP then
		self.m_param.star = self.m_param.star or 0
		self.m_param.equipLv = self.m_param.equipLv or 1

		local itemView = UiUtil.createItemView(self.m_kind, self.m_id, {equipLv = self.m_param.equipLv, star = self.m_param.star}):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)

		local resData = UserMO.getResourceData(self.m_kind, self.m_id)

		local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))

		local equipDB = EquipMO.queryEquipById(self.m_id)

		if EquipMO.getPosByEquipId(self.m_id) == 0 then  -- 装备升级经验
			-- 数量
			label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))

			-- 装备升级材料
			local desc = ui.newTTFLabel({text = string.format(CommonText[208], equipDB.a), font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			desc:setAnchorPoint(cc.p(0, 0.5))
		else
			local attrData = EquipBO.getEquipAttrData(self.m_id, self.m_param.equipLv, self.m_param.star)

			-- label = ui.newTTFLabel({text = "LV." .. self.m_param.equipLv .. "  " .. resData.name .. "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			-- label:setAnchorPoint(cc.p(0, 0.5))

			local add = UiUtil.label(resData.name .. "+" .. attrData.strValue, nil, COLOR[2]):addTo(self:getBg())
			add:setAnchorPoint(cc.p(0, 0.5))
			add:setPosition(name:getPositionX(), name:getPositionY() - 40)

			local attrB = AttributeBO.getAttributeData(attrData.id, equipDB.b)

			-- 每级增加部队
			local desc = ui.newTTFLabel({text = string.format(CommonText[128], attrB.strValue, attrData.name), font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			desc:setAnchorPoint(cc.p(0, 0.5))
		end
	elseif self.m_kind == ITEM_KIND_PART then -- 配件
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id, self.m_param):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 110)
		itemView:setScale(0.9)

		self.m_param.upLv = self.m_param.upLv or 0
		self.m_param.refitLv = self.m_param.refitLv or 0

		local resData = UserMO.getResourceData(ITEM_KIND_PART, self.m_id)
		local partDB = PartMO.queryPartById(self.m_id)
		local attrData = PartBO.getPartAttrData(self.m_id, self.m_param.upLv, self.m_param.refitLv, self.m_param.keyId, 1)

		-- 配件强度
		local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_component_strength.png"):addTo(self:getBg())
		strengthLabel:setAnchorPoint(cc.p(0, 0.5))
		strengthLabel:setPosition(35, self:getBg():getContentSize().height - 30 - strengthLabel:getContentSize().height / 2)

		local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrData.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
		value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
		value:setAnchorPoint(cc.p(0, 0.5))

		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 78, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))

		local startY = name:getPositionY() - 30

		if self.m_param.refitLv > 0 then
			for index = 1, self.m_param.refitLv do
				local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(self:getBg())
				star:setPosition(name:getPositionX() + (index - 0.5) * 30, startY)
				star:setScale(0.55)
			end
			
			startY = name:getPositionY() - 60
		end

		--分界线
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(self:getBg())
		line:setPreferredSize(cc.size(465, line:getContentSize().height))
		line:setPosition(250, 250)

		local bottomBuffInitHeight = self:getBg():height() - 250
		local attrData1 = attrData.attr1

		local startLabel = nil

		-- xx加成
		local label1 = ui.newTTFLabel({text = attrData1.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = startY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label1:setAnchorPoint(cc.p(0, 0.5))
		startLabel = label1

		local value = ui.newTTFLabel({text = attrData1.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

		local attrData2 = attrData.attr2
		if attrData2 then -- 有第二属性
			-- xx加成
			local labelX = ui.newTTFLabel({text = attrData2.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			labelX:setAnchorPoint(cc.p(0, 0.5))
			startLabel = labelX

			local value = ui.newTTFLabel({text = attrData2.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = labelX:getPositionX() + labelX:getContentSize().width + 5, y = labelX:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			value:setAnchorPoint(cc.p(0, 0.5))

			line:setPositionY(line:getPositionY() - 25)
			bottomBuffInitHeight = bottomBuffInitHeight - 25
		end

		local attrData3 = attrData.attr3
		if attrData3 then -- 有第三属性
			-- xx加成
			local label3 = ui.newTTFLabel({text = attrData3.name .. CommonText[176] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX(), y = label1:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label3:setAnchorPoint(cc.p(0, 0.5))
			startLabel = label3

			local value = ui.newTTFLabel({text = attrData3.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			value:setAnchorPoint(cc.p(0, 0.5))

			line:setPositionY(line:getPositionY() - 25)
			bottomBuffInitHeight = bottomBuffInitHeight - 25
		end

		-- 适用兵种
		local label2 = ui.newTTFLabel({text = CommonText[177] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = startLabel:getPositionX(), y = startLabel:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label2:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = CommonText[162][partDB.type], font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX() + label2:getContentSize().width + 5, y = label2:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

		-- 改造等级
		local label3 = ui.newTTFLabel({text = CommonText[178] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label2:getPositionX(), y = label2:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label3:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = self.m_param.refitLv, font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX() + label3:getContentSize().width + 5, y = label3:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

		-- 强化等级
		local label4 = ui.newTTFLabel({text = CommonText[179] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label3:getPositionX(), y = label3:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label4:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = self.m_param.upLv, font = G_FONT, size = FONT_SIZE_SMALL, x = label4:getPositionX() + label4:getContentSize().width + 5, y = label4:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		value:setAnchorPoint(cc.p(0, 0.5))

		--XX加成
		if self.m_param.keyId then
			local m_part = PartMO.getPartByKeyId(self.m_param.keyId)
			local list = PartMO.getRefineAttr(m_part,1)
				
			local x, ey = 135, 30
			for k,v in ipairs(list) do
				local name = UiUtil.label(v.name,FONT_SIZE_SMALL):addTo(self:getBg()):align(display.LEFT_CENTER,x,bottomBuffInitHeight-(k-1)*ey)
				UiUtil.label(v.value[1],nil,COLOR[2]):alignTo(name,100)
				-- 	if v.value[2] then
				-- 		local tag = v.flag >= 0 and "icon_arrow_up.png" or "icon_arrow_down.png"
				-- 		tag = display.newSprite(IMAGE_COMMON..tag):alignTo(name,200)
				-- 		UiUtil.label(v.value[2],nil,COLOR[v.flag >= 0 and 2 or 6]):rightTo(tag, 10)
				-- end
			end
		end
	elseif self.m_kind == ITEM_KIND_PROP or self.m_kind == ITEM_KIND_RED_PACKET or self.m_kind == ITEM_KIND_MILITARY or self.m_kind == ITEM_KIND_CHAR 
			or self.m_kind == ITEM_KIND_MEDAL_MATERIAL or self.m_kind == ITEM_KIND_LABORATORY_RES or self.m_kind == ITEM_KIND_TACTIC
			or self.m_kind == ITEM_KIND_TACTIC_PIECE or self.m_kind == ITEM_KIND_TACTIC_MATERIAL then

		local nodes = display.newNode()

		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(nodes)
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)

		local propDB = UserMO.getResourceData(self.m_kind, self.m_id)

		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 60, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(nodes)
		name:setAnchorPoint(cc.p(0, 0.5))
		if self.m_kind == ITEM_KIND_TACTIC_PIECE then
			name:setColor(COLOR[propDB.quality + 1])
		end

		-- 数量
		label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(nodes)
		label:setAnchorPoint(cc.p(0, 0.5))

		if propDB.desc then
			local desc = ui.newTTFLabel({text = propDB.desc , font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11],
					 align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(400, 0)}):addTo(nodes)
			desc:setAnchorPoint(cc.p(0.5, 1))
			desc:setPosition(self:getBg():getContentSize().width*0.5, 65)
			local allheight = itemView:height() + name:height() + label:height() + desc:height() - self._param_.scale9Size.height + 16

			self:getBg():setPreferredSize(cc.size(self._param_.scale9Size.width, self._param_.scale9Size.height + allheight))
			nodes:setPosition(0,allheight)
			self:getBg():addChild(nodes)
		end
	elseif self.m_kind == ITEM_KIND_SCORE then -- 竞技场积分
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)

		local resData = UserMO.getResourceData(self.m_kind, self.m_id)
		local propDB = PropMO.queryPropById(self.m_id)

		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))

		-- 数量
		label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local desc = ui.newTTFLabel({text = CommonText[397][3], font = G_FONT, size = FONT_SIZE_SMALL, x = -170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 80)}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 1))
	elseif self.m_kind == ITEM_KIND_CHIP then --碎片
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)
		local resData = UserMO.getResourceData(ITEM_KIND_PART, self.m_id)

		local partDB = PartMO.queryPartById(self.m_id)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 58, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))
		local desc = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, x = -170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 80)}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 1))

		if self.m_id == PART_ID_ALL_PIECE then
			desc:setString(CommonText[762])
		else
			desc:setString(string.format(CommonText[212], partDB.chipCount, partDB.partName, CommonText[162][partDB.type]))
		end

		if self.m_id == PART_ID_ALL_PIECE and self.m_param.count and self.m_param.count > 0 then
			-- 数量
			label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))
		end
	elseif self.m_kind == ITEM_KIND_MEDAL_CHIP then
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)
		local resData = UserMO.getResourceData(self.m_kind, self.m_id)

		local partDB = MedalMO.queryById(self.m_id)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 58, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))
		
		if self.m_id ~= MEDAL_ID_ALL_PIECE then
			local t = UiUtil.label(CommonText[20164][1], FONT_SIZE_SMALL, COLOR[12]):alignTo(name, -25, 1)
			UiUtil.label(self.m_chipId == MEDAL_ID_ALL_PIECE and CommonText[20163][3] or partDB.position,nil,COLOR[2]):rightTo(t)
		end
		local desc = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, x = -170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 80)}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 1))

		if self.m_id == MEDAL_ID_ALL_PIECE then
			desc:setString(partDB.dec)
		else
			desc:setString(string.format(CommonText[20172], partDB.chipCount, partDB.medalName))
		end

		if self.m_id == MEDAL_ID_ALL_PIECE and self.m_param.count and self.m_param.count > 0 then
			-- 数量
			label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 50, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))
		end
	elseif self.m_kind == ITEM_KIND_MEDAL_ICON then
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id, {data = self.m_param.data}):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 100)
		itemView:setScale(0.9)
		local resData = UserMO.getResourceData(self.m_kind, self.m_id)

		local md = MedalMO.queryById(self.m_id)
		local attrs = MedalBO.getPartAttrData(nil,self.m_id,self.m_param.data)
		-- 配件强度
		local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_medal_strength.png"):addTo(self:getBg())
		strengthLabel:setAnchorPoint(cc.p(0, 0.5))
		strengthLabel:setPosition(35, self:getBg():getContentSize().height - 25 - strengthLabel:getContentSize().height / 2)
		local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrs.strengthValue), font = "fnt/num_2.fnt"}):rightTo(strengthLabel, 10)

		local t = UiUtil.label(md.medalName,nil,COLOR[md.quality])
			:addTo(self:getBg()):align(display.LEFT_CENTER, 135, self:getBg():getContentSize().height - 65)
		t = UiUtil.label(CommonText[20164][1]):alignTo(t, -25, 1)
		UiUtil.label(md.position,nil,COLOR[2]):rightTo(t)

		t = UiUtil.label(CommonText[20164][2]):alignTo(t, -25, 1)
		UiUtil.label(self.m_param.data and self.m_param.data.upLv or 0,nil,COLOR[2]):rightTo(t)	

		t = UiUtil.label(CommonText[20164][3]):alignTo(t, -25, 1)
		UiUtil.label(self.m_param.data and self.m_param.data.refitLv or 0,nil,COLOR[2]):rightTo(t)

		local att = attrs[md.attr1]
		t = UiUtil.label(att.name .."："):alignTo(t, -25, 1)
		UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
		if md.attr2 > 0 then
			att = attrs[md.attr2]
			t = UiUtil.label(att.name.."："):alignTo(t, -25, 1)
			UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
		end
	elseif self.m_kind == ITEM_KIND_WEAPONRY_ICON then 			--军备
		self:pop()
		local weapDB = {equip_id = self.m_id, pos = 0}
		if table.isexist(self.m_param, "skillInfo") then
			local outdata = {}
			for index = 1, #self.m_param.skillInfo do
				local out = {}
				local datakey = self.m_param.skillInfo[index]
				local db = WeaponryMO.queryChangeSkillById(datakey)
				out.key = datakey
				out.value = db.level
				outdata[#outdata + 1] = out
			end
			local skillLv = PbProtocol.analogyTwoIntList(outdata)
			weapDB.skillLv = skillLv
		end
		require("app.dialog.WeaponryDialog").new(weapDB,true):push()
	elseif self.m_kind == ITEM_KIND_WEAPONRY_PAPER then
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)
		local resData = UserMO.getResourceData(self.m_kind, self.m_id)

		local partDB = WeaponryMO.queryPaperById(self.m_id)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 58, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))
		
		local label = ui.newTTFLabel({text =  partDB.desc, font = G_FONT, size = FONT_SIZE_SMALL-2, align = ui.TEXT_ALIGN_LEFT
			,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(380, 50)}):alignTo(name, -70, 1)
			label:setAnchorPoint(cc.p(0, 0.5))
		-- if self.m_id == MEDAL_ID_ALL_PIECE then
		-- 	desc:setString(partDB.dec)
		-- else
		-- 	desc:setString(string.format(CommonText[20172], partDB.chipCount, partDB.medalName))
		-- end

		if self.m_param.count and self.m_param.count > 0 then
			-- 数量
			label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL-2, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label:setAnchorPoint(cc.p(0, 0.5))
		end
	elseif self.m_kind == ITEM_KIND_MILITARY_EXPLOIT then -- 军功
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)
		--名称
		local resData = UserMO.getResourceData(self.m_kind, self.m_id)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 58, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))
		--描述
		local label = ui.newTTFLabel({text = resData.desc, font = G_FONT, size = FONT_SIZE_SMALL-2, align = ui.TEXT_ALIGN_LEFT
			,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(380, 50)}):alignTo(name, -70, 1)
			label:setAnchorPoint(cc.p(0, 0.5))
		--数量
		label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL-2, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))
	elseif self.m_kind == ITEM_KIND_HUANGBAO then -- 荒宝碎片
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)
		
		local resData = UserMO.getResourceData(ITEM_KIND_HUANGBAO, self.m_id)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 58, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))
	elseif self.m_kind == ITEM_KIND_EFFECT then --增益
		if self.m_id == EFFECT_ID_PB_RESOURCE then -- 军团战，增产
			local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
			itemView:setPosition(80, self:getBg():getContentSize().height - 80)
			itemView:setScale(0.9)
			
			local name = ui.newTTFLabel({text = CommonText[821][1], font = G_FONT, size = FONT_SIZE_MEDIUM, 
				x = 135, y = self:getBg():getContentSize().height - 58, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			name:setAnchorPoint(cc.p(0, 0.5))

			local desc = ui.newTTFLabel({text = CommonText[821][2], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 35, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, valign = ui.TEXT_VALIGN_TOP}):addTo(self:getBg())
			desc:setAnchorPoint(cc.p(0, 1))

			local desc = ui.newTTFLabel({text = CommonText[821][3], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 35, y = 55, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, valign = ui.TEXT_VALIGN_TOP}):addTo(self:getBg())
			desc:setAnchorPoint(cc.p(0, 1))
		else
			local effectDb = EffectMO.queryEffectById(self.m_id)
			local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
			itemView:setPosition(80, self:getBg():getContentSize().height - 80)
			itemView:setScale(0.9)
			
			local name = ui.newTTFLabel({text = effectDb.name or CommonText[135], font = G_FONT, size = FONT_SIZE_MEDIUM, 
				x = 135, y = self:getBg():getContentSize().height - 58, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			name:setAnchorPoint(cc.p(0, 0.5))

			local desc = ui.newTTFLabel({text = effectDb.desc, font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 35, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, valign = ui.TEXT_VALIGN_TOP}):addTo(self:getBg())
			desc:setAnchorPoint(cc.p(0, 1))
		end
	elseif self.m_kind == ITEM_KIND_ENERGY_SPAR then
		local itemView = UiUtil.createItemView(self.m_kind, self.m_id):addTo(self:getBg())
		itemView:setPosition(80, self:getBg():getContentSize().height - 80)
		itemView:setScale(0.9)

		local propDB = UserMO.getResourceData(self.m_kind, self.m_id)

		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = self:getBg():getContentSize().height - 65, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setAnchorPoint(cc.p(0, 0.5))

		-- 数量
		label = ui.newTTFLabel({text = CommonText[40] .. ":" .. self.m_param.count, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 40, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		if propDB.desc then
			local desc = ui.newTTFLabel({text = propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 80)}):addTo(self:getBg())
			desc:setAnchorPoint(cc.p(0, 1))
			desc:setPosition(60, 60)
		end		
	elseif self.m_kind == ITEM_KIND_HERO then
		self:pop()
		local heroDB = HeroMO.queryHero(self.m_id)
		require("app.dialog.HeroDetailDialog").new(heroDB,2):push()
	elseif self.m_kind == ITEM_KIND_AWAKE_HERO then
		self:pop()
		local heroDB = {heroId = self.m_id}
		if table.isexist(self.m_param, "skillInfo") then
			local skillLv = PbProtocol.analogyTwoIntList(self.m_param.skillInfo)
			heroDB.skillLv = skillLv
		end
		require("app.dialog.AwakeOperationDialog").new(heroDB,true):push()
	elseif self.m_kind == ITEM_KIND_ATTRIBUTE then
		local resData = self.m_param.name
		local str = CommonText[966][1]
		if resData == "attack" then
			str = CommonText[966][1]
		elseif resData == "atkMode" then
			str = CommonText[966][2]
		elseif resData == "maxHp" then
			str = CommonText[966][3]
		elseif resData == "payload" then
			str = CommonText[966][4]
		elseif resData == "hit" then
			str = CommonText[966][5]
		elseif resData == "dodge" then
			str = CommonText[966][6]
		elseif resData == "crit" then
			str = CommonText[966][7]
		elseif resData == "critDef" then
			str = CommonText[966][8]
		elseif resData == "impale" then
			str = CommonText[966][9]
		elseif resData == "defend" then
		str = CommonText[966][10]
		elseif resData == "burst" then
			str = CommonText[966][11]
		elseif resData == "tenacity" then
			str = CommonText[966][12]
		elseif resData == "frighten" then
			str = CommonText[966][13]
		elseif resData == "fortitude" then
			str = CommonText[966][14]
		end
		local desc = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, x = -170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 80)}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 1))
	-- elseif self.m_kind == ITEM_KIND_LABORATORY_RES then
	-- 	print("self.m_kind    " , self.m_kind)
	-- 	print("self.m_id    " , self.m_id)


	end
	self.ownLabel = label
	if self.noCount and label then
		label:hide()
	end
	
	if GameConfig.GM then
		local t = UiUtil.button("btn_9_normal.png","btn_9_selected.png",nil,function()
				local mail = {
					keyId = 0,
					type = 4,
					state = 3,
					time = 0,
					moldId = 35,
					award = {{type = self.m_kind,id=self.m_id,count = 10000}},
					contont = "发奖"
				}
				GMBO.asynSendMail(function()
						Toast.show("增加100，邮箱领取")
					end,"mail "..UserMO.nickName_,mail)
			end,"+10k邮件领")
		:addTo(self:getBg(),10):pos(self:getBg():width()-100,self:getBg():height()-60)
		if self.m_id then
			UiUtil.label("type："..self.m_kind ..",id：" ..self.m_id,nil,COLOR[6])
				:alignTo(t,-40,1)
		end
	end
end

return DetailItemDialog