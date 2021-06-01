
-- 坦克详情弹出框

local Dialog = require("app.dialog.Dialog")
local DetailTankDialog = class("DetailTankDialog", Dialog)

function DetailTankDialog:ctor(tankId, canShare, tankData)
	DetailTankDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 776)})
	if canShare == nil then canShare = false end -- 是否可以分享

	self.m_tankId = tankId
	self.m_canShare = canShare
	self.m_tankData = tankData
end

function DetailTankDialog:onEnter()
	DetailTankDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailTankDialog:showUI()
	if self.m_canShare then
		-- 分享
		local normal = display.newSprite(IMAGE_COMMON .. "btn_share_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_share_selected.png")
		local shareBtn = MenuButton.new(normal, selected, nil, handler(self, self.onShareCallback)):addTo(self:getBg())
		shareBtn:setPosition(self:getBg():getContentSize().width - 70, self:getBg():getContentSize().height - 80)
	end

	local valueColor = COLOR[3]

	local view = UiUtil.createItemSprite(ITEM_KIND_TANK, self.m_tankId):addTo(self:getBg())
	view:setAnchorPoint(cc.p(0.5, 0))
	view:setPosition(112, self:getBg():getContentSize().height - 134)

	local tankDB = TankMO.queryTankById(self.m_tankId)
	-- 名称
	local name = ui.newTTFLabel({text = tankDB.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 190, y = self:getBg():getContentSize().height - 86, color = COLOR[tankDB.grade], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	if self.m_canShare then
		-- 当前数量
		local label = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		local count = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_TANK, self.m_tankId), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		count:setAnchorPoint(cc.p(0, 0.5))
	end

	local labelX = 110
	local labelX2 = 340

	local restric = {}
	if tankDB.restriction then
		local tmp = json.decode(tankDB.restriction)
		if type(tmp[1]) ~= "table" then
			tmp = {tmp}
		end
		-- -- if tankDB.type == TANK_TYPE_TANK then
		-- -- 	tmp = {tmp}
		-- -- end

		-- dump(tankDB)
		-- dump(tmp)

		for index = 1, #tmp do
			if tmp[index][1] <= 4 then  -- 只显示部分tank的克制
				restric[#restric + 1] = tmp[index]
			end
		end
	end
	-- gdump(restric)

	-- 克制
	local label = ui.newTTFLabel({text = CommonText.attr[10] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = self:getBg():getContentSize().height - 170, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local startY = label:getPositionY()

	for index = 1, #restric do
		local r = restric[index]

		local str = CommonText[401][1] .. CommonText[162][r[1]]
		if r[2] > 0 then -- 增加
			str = str .. CommonText[401][2]
		else -- 减少
			str = str .. CommonText[401][3]
		end

		str = str .. math.abs(r[2]) .. "%" .. CommonText[401][4]

		local desc = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = startY, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 0.5))
		startY = startY - 30
	end

	local aura = {}
	if tankDB.aura then aura = json.decode(tankDB.aura) end

	-- 光环
	local label = ui.newTTFLabel({text = CommonText.attr[11] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = startY, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	for index = 1, #aura do
		local buff = BuffMO.queryBuffById(aura[index])

		local desc = ui.newTTFLabel({text = buff.name, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = startY, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 0.5))
		startY = startY - 30
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(440, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 300)

	local attrAddtion = {[ATTRIBUTE_INDEX_HP] = 0, [ATTRIBUTE_INDEX_ATTACK] = 0, [ATTRIBUTE_INDEX_HIT] = 0, [ATTRIBUTE_INDEX_DODGE] = 0,
		[ATTRIBUTE_INDEX_CRIT] = 0, [ATTRIBUTE_INDEX_CRIT_DEF] = 0, [ATTRIBUTE_INDEX_IMPALE] = 0, [ATTRIBUTE_INDEX_DEFEND] = 0,
		[ATTRIBUTE_INDEX_TENACITY] = 0, [ATTRIBUTE_INDEX_BURST] = 0, [ATTRIBUTE_INDEX_FRIGHTEN] = 0,[ATTRIBUTE_INDEX_FORTITUDE] = 0,
		[ATTRIBUTE_INDEX_PAYLOAD] = 0}

	if self.m_tankData then -- 显示分享的属性
		local tankData = self.m_tankData
		attrAddtion[ATTRIBUTE_INDEX_ATTACK] = (tankData.attack or 0) / 10000				-- 攻击
		attrAddtion[ATTRIBUTE_INDEX_HP] = (tankData.hp or 0) / 10000						-- 生命
		attrAddtion[ATTRIBUTE_INDEX_HIT] = (tankData.hit or 0) / 10000						-- 命中
		attrAddtion[ATTRIBUTE_INDEX_DODGE] = (tankData.dodge or 0) / 10000					-- 闪避
		attrAddtion[ATTRIBUTE_INDEX_CRIT] = (tankData.crit or 0) / 10000					-- 暴击
		attrAddtion[ATTRIBUTE_INDEX_CRIT_DEF] = (tankData.critDef or 0) / 10000				-- 抗暴
		attrAddtion[ATTRIBUTE_INDEX_IMPALE] = (tankData.impale or 0) / 10000				-- 穿刺
		attrAddtion[ATTRIBUTE_INDEX_DEFEND] = (tankData.defend or 0) / 10000				-- 防护
		attrAddtion[ATTRIBUTE_INDEX_TENACITY] = (tankData.tenacity or 0) / 10000			-- 坚韧
		attrAddtion[ATTRIBUTE_INDEX_BURST] = (tankData.burst or 0) / 10000					-- 爆裂
		attrAddtion[ATTRIBUTE_INDEX_FRIGHTEN] = (tankData.frighten or 0) / 10000			-- 震慑
		attrAddtion[ATTRIBUTE_INDEX_FORTITUDE] = (tankData.fortitude or 0) / 10000			-- 刚毅
		attrAddtion[ATTRIBUTE_INDEX_PAYLOAD] = (tankData.payload or 0)						-- 载重 新添加
	else
		-- 配件
		local partAttr = PartBO.getTankTypePartAttrData(tankDB.type)
		gdump(partAttr, "parttttttttttt")
		for attrIndex, attr in pairs(partAttr) do
			if attrIndex == ATTRIBUTE_INDEX_HP or attrIndex == ATTRIBUTE_INDEX_ATTACK or attrIndex == ATTRIBUTE_INDEX_HIT or attrIndex == ATTRIBUTE_INDEX_DODGE
				or attrIndex == ATTRIBUTE_INDEX_CRIT or attrIndex == ATTRIBUTE_INDEX_CRIT_DEF or attrIndex == ATTRIBUTE_INDEX_IMPALE or attrIndex == ATTRIBUTE_INDEX_DEFEND then
				attrAddtion[attrIndex] = attrAddtion[attrIndex] + attr.value
			end
		end

		--勋章
		local medalAttr = MedalBO.getEquipAttr()
		for attrIndex, attr in pairs(medalAttr) do
			if type(attr) == "table" then
				if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_FRIGHTEN or
					attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE or
					attr.index == ATTRIBUTE_INDEX_FORTITUDE or attr.index == ATTRIBUTE_INDEX_BURST or attr.index == ATTRIBUTE_INDEX_TENACITY then
					attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
				end
			end
		end

		--军备
		local medalAttr = WeaponryBO.getEquipAttr()
		for attrIndex, attr in pairs(medalAttr) do
			if type(attr) == "table" then
				if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_FRIGHTEN or
					attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE or
					attr.index == ATTRIBUTE_INDEX_FORTITUDE or attr.index == ATTRIBUTE_INDEX_BURST or attr.index == ATTRIBUTE_INDEX_TENACITY or attr.index == ATTRIBUTE_INDEX_IMPALE or attr.index == ATTRIBUTE_INDEX_DEFEND then
					attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
				end
			end
		end

		--军功
		local militaryAttr = MilitaryRankBO.getEquipAttr()
		for attrIndex, attr in pairs(militaryAttr) do
			if type(attr) == "table" then
				if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_FRIGHTEN or
					attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE or
					attr.index == ATTRIBUTE_INDEX_FORTITUDE or attr.index == ATTRIBUTE_INDEX_BURST or attr.index == ATTRIBUTE_INDEX_TENACITY or attr.index == ATTRIBUTE_INDEX_IMPALE or attr.index == ATTRIBUTE_INDEX_DEFEND then
					attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
				end
			end
		end

		-- 技能
		local skillNum = SkillMO.queryMaxSkill()
		for index = 1, skillNum do
			local skillDB = SkillMO.querySkillById(index)
			if skillDB.target == 0 or (tankDB.type == skillDB.target) then
				local attr = SkillBO.getSkillAttrData(index)
				gdump(attr, "Skilllllllllllllllllll")
				if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE
					or attr.index == ATTRIBUTE_INDEX_CRIT or attr.index == ATTRIBUTE_INDEX_CRIT_DEF or attr.index == ATTRIBUTE_INDEX_IMPALE or attr.index == ATTRIBUTE_INDEX_DEFEND then
					attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
				end
			end
		end

		for index = 1, #ScienceMO.sciences_ do
			local scienceDB = ScienceMO.queryScience(ScienceMO.sciences_[index].scienceId)
			if scienceDB and ((scienceDB.type == 5) or (tankDB.type == scienceDB.type)) then
				local attr = ScienceBO.getScienceAttrData(ScienceMO.sciences_[index].scienceId, ScienceMO.sciences_[index].scienceLv)
				gdump(attr, "Scienceeeeeeeeee")
				if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE
					or attr.index == ATTRIBUTE_INDEX_CRIT or attr.index == ATTRIBUTE_INDEX_CRIT_DEF or attr.index == ATTRIBUTE_INDEX_IMPALE or attr.index == ATTRIBUTE_INDEX_DEFEND then
					attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
				end
			end
		end

		if PartyMO.scienceData_ and PartyMO.scienceData_.scienceData then
			for i = 1,#PartyMO.scienceData_.scienceData do
				local science = PartyMO.scienceData_.scienceData[i]
				local scienceDB = ScienceMO.queryScience(science.scienceId)
				if scienceDB and ((scienceDB.type == 5) or (tankDB.type == scienceDB.type)) then
					local attr = ScienceBO.getScienceAttrData(science.scienceId, science.scienceLv)
					gdump(attr, "Scienceeeeeeeeee party")
					if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE
						or attr.index == ATTRIBUTE_INDEX_CRIT or attr.index == ATTRIBUTE_INDEX_CRIT_DEF or attr.index == ATTRIBUTE_INDEX_IMPALE or attr.index == ATTRIBUTE_INDEX_DEFEND 
						or attr.index == ATTRIBUTE_INDEX_FRIGHTEN then
						attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
					end
				end
			end
		end

		if UserMO.staffing_ ~= 0 then  -- 编制属性
			local staff = StaffMO.queryStaffById(UserMO.staffing_)
			local attrDatas = json.decode(staff.attr)

			if attrDatas then
				for index = 1, #attrDatas do
					local attrData = attrDatas[index]
					local attr = AttributeBO.getAttributeData(attrData[1], attrData[2])
					gdump(attr, "Staffingggggggggggggggggg")
					if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE
						or attr.index == ATTRIBUTE_INDEX_CRIT or attr.index == ATTRIBUTE_INDEX_CRIT_DEF or attr.index == ATTRIBUTE_INDEX_IMPALE or attr.index == ATTRIBUTE_INDEX_DEFEND then
						attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
					end
				end
			end
		end

		local effectAttrData = EffectBO.getBattleBaseAttrData()
		for attrIndex, attr in pairs(effectAttrData) do
			if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE
				or attr.index == ATTRIBUTE_INDEX_CRIT or attr.index == ATTRIBUTE_INDEX_CRIT_DEF or attr.index == ATTRIBUTE_INDEX_IMPALE or attr.index == ATTRIBUTE_INDEX_DEFEND then
				attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
			end
		end

		--军工科技属性
		effectAttrData = OrdnanceBO.getAttrOnTank(self.m_tankId)
		for attrIndex, attr in pairs(effectAttrData) do
			local ao = AttributeBO.getAttributeData(attrIndex, 0)
			if attrAddtion[ao.index] then
				attrAddtion[ao.index] = attrAddtion[ao.index] + attr
			end
		end

		--作战实验室
		local labAttrData = LaboratoryBO.getLaboratoryCommonAttr(tankDB.type)
		for index = 1 ,#labAttrData do
			local attr = labAttrData[index]
			if attrAddtion[attr.id] then
				local att = AttributeBO.getAttributeData(attr.id, attr.value)
				attrAddtion[attr.id] = attrAddtion[attr.id] + att.value
			end
		end

		-- [载重] 军团科技加成
		local _payloadAdd = PartyMO.getSciencePayloadAdd()
		local addPayLoad = 0
		if tankDB.grade == 4 then
			addPayLoad = PartyMO.getSciencePayloadAddNew4()
		elseif tankDB.grade >= 5 then
			addPayLoad = PartyMO.getSciencePayloadAddNew5()
		end
		-- 废墟
		-- if UserMO.ruins and UserMO.ruins.isRuins then
		-- 	_addExPayload = _addExPayload + (-math.floor(tankDB.payload*UserMO.querySystemId(24)/10000))
		-- end
		-- 作战实验室
		local labAttrValue = LaboratoryBO.getPayloadTypeAttr(tankDB.type)
		local _addExPayload = tankDB.payload * (1 + labAttrValue * 0.01 + _payloadAdd + addPayLoad)
		attrAddtion[ATTRIBUTE_INDEX_PAYLOAD] = _addExPayload

		-- 能源核心
		local energyCoreAttr = EnergyCoreMO.getEnergyCoreCombatAttr()
		for attrIndex, attr in pairs(energyCoreAttr) do
			if type(attr) == "table" then
				if attr.index == ATTRIBUTE_INDEX_HP or attr.index == ATTRIBUTE_INDEX_ATTACK or attr.index == ATTRIBUTE_INDEX_FRIGHTEN or
					attr.index == ATTRIBUTE_INDEX_HIT or attr.index == ATTRIBUTE_INDEX_DODGE or
					attr.index == ATTRIBUTE_INDEX_FORTITUDE or attr.index == ATTRIBUTE_INDEX_BURST or attr.index == ATTRIBUTE_INDEX_TENACITY or attr.index == ATTRIBUTE_INDEX_IMPALE or attr.index == ATTRIBUTE_INDEX_DEFEND then
					attrAddtion[attr.index] = attrAddtion[attr.index] + attr.value
				end
			end
		end
	end

	gdump(attrAddtion, "lasttttttttt")
	self.m_attrAddtion = attrAddtion

	-- 攻击
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "attack"}):addTo(self:getBg())
	itemView:setPosition(labelX - 30, self:getBg():getContentSize().height - 340)
	UiUtil.createItemDetailButton(itemView)
	local label = ui.newTTFLabel({text = CommonText.attr[1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = tankDB.attack, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 加成
	local delta = math.floor(tankDB.attack * attrAddtion[ATTRIBUTE_INDEX_ATTACK])
	if delta > 0 then
		local delta = ui.newTTFLabel({text = "+" .. delta, font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 生命
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "maxHp"}):addTo(self:getBg())
	itemView:setPosition(labelX - 30, self:getBg():getContentSize().height - 400)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = tankDB.hp, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 加成
	local delta = math.floor(tankDB.hp * attrAddtion[ATTRIBUTE_INDEX_HP])
	if delta > 0 then
		local delta = ui.newTTFLabel({text = "+" .. delta, font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 攻击方式
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, tankDB.attackMode, {name = "atkMode"}):addTo(self:getBg())
	itemView:setPosition(labelX2 - 30, self:getBg():getContentSize().height - 340)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.atkMode[tankDB.attackMode], font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 载重
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "payload"}):addTo(self:getBg())
	itemView:setPosition(labelX2 - 30, self:getBg():getContentSize().height - 400)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = tankDB.payload, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	-- local _addExPayload = 0
	-- -- 废墟
	-- -- if UserMO.ruins and UserMO.ruins.isRuins then
	-- -- 	_addExPayload = _addExPayload + (-math.floor(tankDB.payload*UserMO.querySystemId(24)/10000))
	-- -- end
	-- -- [载重] 军团科技加成
	-- if PartyMO.scienceData_ and PartyMO.scienceData_.scienceData then
	-- 	for index =1 , #PartyMO.scienceData_.scienceData do
	-- 		local scienceData = PartyMO.scienceData_.scienceData[index]
	-- 		if scienceData.scienceId == 201 then
	-- 			_addExPayload = _addExPayload + math.floor(tankDB.payload * scienceData.addtion * scienceData.scienceLv * 0.01)
	-- 		end
	-- 	end
	-- end

	-- -- 作战实验室
	-- local labAttrValue = LaboratoryBO.getPayloadTypeAttr(tankDB.type)
	-- _addExPayload = _addExPayload + math.floor(tankDB.payload * labAttrValue * 0.01)

	if attrAddtion[ATTRIBUTE_INDEX_PAYLOAD] > 0 then
		local addV = attrAddtion[ATTRIBUTE_INDEX_PAYLOAD] - tankDB.payload
		if addV > 0 then
			UiUtil.label("+" .. addV,nil,COLOR[2]):rightTo(value)
		end
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(440, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 440)

	-- 命中
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "hit"}):addTo(self:getBg())
	itemView:setPosition(labelX - 30, self:getBg():getContentSize().height - 480)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[4] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = (tankDB.hit / 10) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_HIT] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. (attrAddtion[ATTRIBUTE_INDEX_HIT] * 100) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 暴击
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "crit"}):addTo(self:getBg())
	itemView:setPosition(labelX - 30, self:getBg():getContentSize().height - 540)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[6] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = (tankDB.crit / 10) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_CRIT] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. (attrAddtion[ATTRIBUTE_INDEX_CRIT] * 100) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 穿刺
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "impale"}):addTo(self:getBg())
	itemView:setPosition(labelX - 30, self:getBg():getContentSize().height - 600)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[8] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = tankDB.impale, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_IMPALE] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. attrAddtion[ATTRIBUTE_INDEX_IMPALE], font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 爆裂
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "burst"}):addTo(self:getBg())
	itemView:setPosition(labelX - 30, self:getBg():getContentSize().height - 660)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[12] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "0%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_BURST] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. (attrAddtion[ATTRIBUTE_INDEX_BURST]*100) .."%", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 震慑
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "frighten"}):addTo(self:getBg())
	itemView:setPosition(labelX - 30, self:getBg():getContentSize().height - 720)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[14] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_FRIGHTEN] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. attrAddtion[ATTRIBUTE_INDEX_FRIGHTEN], font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 闪避
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "dodge"}):addTo(self:getBg())
	itemView:setPosition(labelX2 - 30, self:getBg():getContentSize().height - 480)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[5] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = (tankDB.dodge / 10) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_DODGE] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. (attrAddtion[ATTRIBUTE_INDEX_DODGE] * 100) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 抗暴
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "critDef"}):addTo(self:getBg())
	itemView:setPosition(labelX2 - 30, self:getBg():getContentSize().height - 540)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[7] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = (tankDB.critDef / 10) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_CRIT_DEF] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. (attrAddtion[ATTRIBUTE_INDEX_CRIT_DEF] * 100) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 防护
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "defend"}):addTo(self:getBg())
	itemView:setPosition(labelX2 - 30, self:getBg():getContentSize().height - 600)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[9] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = tankDB.defend, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_DEFEND] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. attrAddtion[ATTRIBUTE_INDEX_DEFEND], font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 坚韧
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "tenacity"}):addTo(self:getBg())
	itemView:setPosition(labelX2 - 30, self:getBg():getContentSize().height - 660)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[13] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "0%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_TENACITY] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. (attrAddtion[ATTRIBUTE_INDEX_TENACITY]*100) .."%", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 刚毅
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "fortitude"}):addTo(self:getBg())
	itemView:setPosition(labelX2 - 30, self:getBg():getContentSize().height - 720)
	UiUtil.createItemDetailButton(itemView)

	local label = ui.newTTFLabel({text = CommonText.attr[15] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + 50, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if attrAddtion[ATTRIBUTE_INDEX_FORTITUDE] > 0 then
		local delta = ui.newTTFLabel({text = "+" .. attrAddtion[ATTRIBUTE_INDEX_FORTITUDE], font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		delta:setAnchorPoint(cc.p(0, 0.5))
	end
end

function DetailTankDialog:onShareCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local attrAddtion = self.m_attrAddtion

	local tankData = {}
	tankData.tankId = self.m_tankId
	tankData.attack = attrAddtion[ATTRIBUTE_INDEX_ATTACK] * 10000
	tankData.hp = attrAddtion[ATTRIBUTE_INDEX_HP] * 10000
	tankData.payload = attrAddtion[ATTRIBUTE_INDEX_PAYLOAD]
	tankData.hit = attrAddtion[ATTRIBUTE_INDEX_HIT] * 10000
	tankData.dodge = attrAddtion[ATTRIBUTE_INDEX_DODGE] * 10000
	tankData.crit = attrAddtion[ATTRIBUTE_INDEX_CRIT] * 10000
	tankData.critDef = attrAddtion[ATTRIBUTE_INDEX_CRIT_DEF] * 10000
	tankData.impale = attrAddtion[ATTRIBUTE_INDEX_IMPALE] * 10000
	tankData.defend = attrAddtion[ATTRIBUTE_INDEX_DEFEND] * 10000
	tankData.tenacity = attrAddtion[ATTRIBUTE_INDEX_TENACITY] * 10000
	tankData.burst = attrAddtion[ATTRIBUTE_INDEX_BURST] * 10000
	tankData.frighten = attrAddtion[ATTRIBUTE_INDEX_FRIGHTEN] * 10000
	tankData.fortitude = attrAddtion[ATTRIBUTE_INDEX_FORTITUDE] * 10000

	local dialog = require("app.dialog.ShareDialog").new(SHARE_TYPE_TANK, tankData, sender):push()
	dialog:getBg():setPosition(display.cx + 150, display.cy + 150)
end

return DetailTankDialog
