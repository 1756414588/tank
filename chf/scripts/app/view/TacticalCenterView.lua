--
-- Author: Gss
-- Date: 2018-12-05 10:30:08
--
-- 战术中心  TacticalCenterView

local TacticalCenterView = class("TacticalCenterView", UiNode)

function TacticalCenterView:ctor(formation, enterStyle,viewFor, choseForm)
	enterStyle = enterStyle or UI_ENTER_NONE
	TacticalCenterView.super.ctor(self, "image/common/bg_ui.jpg", enterStyle)
	self.m_formation = formation
	self.m_viewFor = viewFor

	--用于战术选择记忆
	self.m_choseKind = 1
	self.m_choseTank = 1
	--战术阵型默认值
	self.m_choseForm = choseForm or 0
end

function TacticalCenterView:onEnter()
	TacticalCenterView.super.onEnter(self)
	self:setTitle(CommonText[4024])

	self.m_choseTacticHandler = Notify.register(LOCAL_TACTICS_WEAR, handler(self, self.onChoseTactic))
	self.m_upgradeTacticHandler = Notify.register(LOCAL_TACTICS_UPDATE, handler(self, self.onUpgradeTactic))
	--仓库
	local warehouse = display.newSprite("image/tactics/warehouse.png")
	local warehouseBtn = ScaleButton.new(warehouse, function ()
		UiDirector.push(require("app.view.TacticsWareHouseView").new(VIEW_FOR_SEE))
	end):addTo(self:getBg(),99)
	warehouseBtn:setPosition(self:getBg():width() - 70, self:getBg():height() - 150)
	warehouseBtn:setScale(0.8)

	--克制展示
	local restraint = display.newSprite("image/tactics/restraint.png")
	local restraintBtn = ScaleButton.new(restraint, function ()
		require("app.dialog.TacticsRestraintDialog").new():push()
	end):addTo(self:getBg(),99)
	restraintBtn:setPosition(self:getBg():width() - 70, warehouseBtn:y() - 80)
	restraintBtn:setScale(0.8)

	self:showFormation()
	if self.m_choseForm > 0 then
		self.m_formation.tacticsKeyId = TacticsMO.TacticForms_[self.m_choseForm].keyId
	end
	self:showUI()
end

function TacticalCenterView:showFormation()
	self.m_btns = {}
	--左边
	for index=1,TACTIC_FORMATION_MAX_NUM / 2 do
		local tx = self:getBg():width() - 70
		local ty = self:getBg():height() - 370 - (index-1)*70
		local normal = display.newSprite("image/tactics/tactic_form.png")
		local selected = display.newSprite("image/tactics/tactic_form_selected.png")
		local formBtn = MenuButton.new(normal, selected, nil, handler(self, self.onFormCallback)):addTo(self:getBg(),99)
		formBtn.index = index
		formBtn:setPosition(tx, ty)
		self.m_btns[index] = formBtn

		if self.m_choseForm == index then
			local sprite = display.newSprite("image/tactics/tactic_form_selected.png")
			formBtn:setNormalSprite(display.newSprite("image/tactics/tactic_form_selected.png"))
		end

		local num = UiUtil.label(index):addTo(formBtn,999):center()
	end

	-- --右边
	-- for idx=5,TACTIC_FORMATION_MAX_NUM do
	-- 	local tx = self:getBg():width() - 70
	-- 	local ty = self:getBg():height() - 370 - (idx-5)*70
	-- 	local normal = display.newSprite("image/tactics/tactic_form.png")
	-- 	local selected = display.newSprite("image/tactics/tactic_form_selected.png")
	-- 	local formBtn = MenuButton.new(normal, selected, nil, handler(self, self.onFormCallback)):addTo(self:getBg(),99)
	-- 	formBtn.index = idx
	-- 	formBtn:setPosition(tx, ty)
	-- 	self.m_btns[idx] = formBtn

	-- 	if self.m_choseForm == idx then
	-- 		local sprite = display.newSprite("image/tactics/tactic_form_selected.png")
	-- 		formBtn:setNormalSprite(display.newSprite("image/tactics/tactic_form_selected.png"))
	-- 	end
	-- 	local num = UiUtil.label(idx):addTo(formBtn,999):center()
	-- end
end

function TacticalCenterView:onFormCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	for idx=1,#self.m_btns do
		if sender.index == idx then
			self.m_btns[idx]:setNormalSprite(display.newSprite("image/tactics/tactic_form_selected.png"))
		else
			self.m_btns[idx]:setNormalSprite(display.newSprite("image/tactics/tactic_form.png"))
		end
	end
	self.m_choseForm = sender.index

	self.m_formation.tacticsKeyId = TacticsMO.TacticForms_[self.m_choseForm].keyId

	Notify.notify(LOCAL_TACTICS_FORARMY, {formation = self.m_formation, formationIndex = self.m_choseForm})
	Notify.notify(LOCAL_TACTICS_UPDATA_ITEM, {formation = self.m_formation})
	self:showUI()
end

function TacticalCenterView:showUI()
	if not self.container then
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 + container:getContentSize().height / 2)
		self.container = container
	end

	local container = self.container
	self.container:removeAllChildren()

	local bg = display.newSprite("image/tactics/tactics_main_bg.png"):addTo(container)
	bg:setPosition(container:width() / 2, container:height() - bg:height() / 2)

	--指线
	local line = display.newSprite("image/tactics/tactic_line.png"):addTo(bg,99)
	line:setPosition(bg:width() / 2, bg:height() / 2)
	line:setVisible(false)

	local ofY = 10
	local tactisList = {
		{x = bg:width() / 2, y = bg:height() - 100 - ofY},
		{x = bg:width() / 2 - 150, y = bg:height() - 180 - ofY},
		{x = bg:width() / 2 - 150, y = bg:height() - 360 - ofY},
		{x = bg:width() / 2, y = bg:height() - 470 - ofY},
		{x = bg:width() / 2 + 150, y = bg:height() - 360 - ofY},
		{x = bg:width() / 2 + 150, y = bg:height() - 180 - ofY},
	}
	self.container.tactisList = tactisList

	--判断是否已经派出去用了。或者已经被消耗掉了(特殊处理些镜像部队)
	if self.m_viewFor == ARMY_SETTING_FOR_ARENA or self.m_viewFor == ARMY_SETTING_FOR_EXERCISE1 or self.m_viewFor == ARMY_SETTING_FOR_EXERCISE3 
		or self.m_viewFor == ARMY_SETTING_FOR_CROSS or self.m_viewFor == ARMY_SETTING_FOR_CROSS1 or self.m_viewFor == ARMY_SETTING_FOR_CROSS2 then
		if self.m_formation.tacticsKeyId and #self.m_formation.tacticsKeyId > 0 then
			self.m_formation.tacticsKeyId = TacticsMO.isTacticCanUse(self.m_formation,true)
		end
	else
		if self.m_formation.tacticsKeyId and #self.m_formation.tacticsKeyId > 0 then
			self.m_formation.tacticsKeyId = TacticsMO.isTacticCanUse(self.m_formation)
		end
	end
	for index=1,#tactisList do
		local normal = display.newSprite("image/tactics/tactics_bg.png")
		local item = TouchButton.new(normal, nil, nil, nil, handler(self, self.clickCall)):addTo(bg)
		item:setPosition(tactisList[index].x, tactisList[index].y)
		item.index = index

		if self.m_formation.tacticsKeyId and #self.m_formation.tacticsKeyId > 0 then
			local tacticDB = TacticsMO.getTacticByKeyId(self.m_formation.tacticsKeyId[index])
			if tacticDB then
				local itemView = UiUtil.createItemView(ITEM_KIND_TACTIC, tacticDB.tacticsId,{tacticLv = tacticDB.lv}):addTo(item)
				itemView:setScale(0.85)
				itemView:setPosition(item:width() / 2, item:height() / 2 + 13)
				item.itemView = itemView
				item.tactic = tacticDB

				local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
				lockIcon:setPosition(itemView:width() - 10, itemView:height() - 10)
				lockIcon:setScale(0.5)
				lockIcon:setVisible(tacticDB.bind == 1)

				local tactic = TacticsMO.queryTacticById(tacticDB.tacticsId)
				local name = UiUtil.label(tactic.tacticsName,nil,COLOR[tactic.quality + 1]):addTo(item)
				name:setPosition(item:width() / 2, 14)
			end
		end
	end

	--增加属性
	local add = display.newSprite("image/tactics/addTitle_bg.png"):addTo(container)
	add:setAnchorPoint(cc.p(0, 0.5))
	add:setPosition(20,container:height() - bg:height() - 30)

	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(container)
	attrBg:setPreferredSize(cc.size(container:width() - 40, 230))
	attrBg:setCapInsets(cc.rect(130, 40, 1, 1))
	attrBg:setPosition(container:width() / 2, add:y() - attrBg:height() / 2 - 20)

	--加成
	local attrList = {
		ATTRIBUTE_INDEX_ATTACK + 1, ATTRIBUTE_INDEX_HURT + 1, ATTRIBUTE_ADD_HURT, ATTRIBUTE_INDEX_HP + 1,
		ATTRIBUTE_INDEX_IMPALE, ATTRIBUTE_INDEX_CRIT_DEF, ATTRIBUTE_INDEX_CRIT, ATTRIBUTE_INDEX_DEFEND,
		ATTRIBUTE_INDEX_FRIGHTEN, ATTRIBUTE_INDEX_TENACITY + 1, ATTRIBUTE_INDEX_BURST + 1, ATTRIBUTE_INDEX_FORTITUDE,
	}

	-- 各个属性值
	local attrs = TacticsMO.getTacticAttr(self.m_formation)
	local x,y,ex,ey = 50,195,190,50
	for k,v in ipairs(attrList) do
		local attr = attrs[v] or AttributeBO.getAttributeData(v, 0)
		local tx, ty = x + math.floor((k-1)/4)*ex,y - (k-1)%4*ey
		local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = attr.attrName}):addTo(attrBg):pos(tx,ty)
		local name = ui.newTTFLabel({text = attr.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
		name:setAnchorPoint(cc.p(0, 0.5))
		name:setColor(COLOR[11])
		name:setPosition(itemView:getPositionX() + 30, itemView:getPositionY())
		local value = ui.newTTFLabel({text = "+" .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	if self.m_formation.tacticsKeyId and #self.m_formation.tacticsKeyId > 0 then
		local isTacticSuit = TacticsMO.isTacticSuit(self.m_formation, true) -- 战术类型
		local quality, tankType = TacticsMO.isArmsSuit(self.m_formation, true)  --兵种类型

		if isTacticSuit then
			--加成
			local data = TacticsMO.getTacticsRestricts(isTacticSuit)
			local attr = json.decode(data.attrSuit)[1]
			local attrData = AttributeBO.getAttributeData(attr[1], attr[2])
			local text = {}
			table.insert(text, {{content = CommonText[4031][1]},{content = attrData.name.."+"..attrData.strValue,color = COLOR[2]}})

			local tacticEff = display.newSprite("image/tactics/tactic_effect_bg.png"):addTo(bg):center()
			local effItem = display.newSprite("image/tactics/tactics_"..isTacticSuit..".png")
			local effBtn = ScaleButton.new(effItem, function ()
				local DetailTextDialog = require("app.dialog.DetailTextDialog")
				DetailTextDialog.new(text):push()
			end):addTo(tacticEff,99):center()
			line:setVisible(true)
		end

		if isTacticSuit and tankType then
			--加成
			local attrs = TacticsMO.getAttrByQuality(isTacticSuit, quality, tankType)
			local text = {}
			for index=1,#attrs do
				local attr = attrs[index]
				local attrData = AttributeBO.getAttributeData(attr[1], attr[2])
				table.insert(text, {{content = string.format(CommonText[4031][2],CommonText[4000][tankType])},{content = attrData.name.."+"..attrData.strValue,color = COLOR[2]}})
			end
			local tankItem = display.newSprite("image/tactics/tank_type_"..tankType..".png")
			local tankBtn = ScaleButton.new(tankItem, function ()
				local DetailTextDialog = require("app.dialog.DetailTextDialog")
				DetailTextDialog.new(text):push()
			end):addTo(bg,99)
			tankBtn:setPosition(bg:width() / 2, bg:height() / 2 - 65)
		end
	end
	--战术效果
	-- local effect = UiUtil.label("战术效果："):addTo(attrBg)
	-- effect:setAnchorPoint(cc.p(0,0.5))
	-- effect:setPosition(30,75)
	-- local effName = UiUtil.label("XX技能"):rightTo(effect)

	-- local tankEffect = UiUtil.label("兵种加成："):alignTo(effect, -30, 1)
	-- local effectValue = UiUtil.label("坦克闪避增加25%"):rightTo(tankEffect)
end

function TacticalCenterView:clickCall(tag, sender)
	local kind = sender.index
	self.m_curUiName = UiDirector.getTopUiName()
	if sender.itemView then
		require("app.dialog.DetailTacticDialog").new(sender.tactic, VIEW_FOR_EXC, kind, self.m_formation,nil,nil,self.m_viewFor):push()
		return
	end

	UiDirector.push(require("app.view.TacticsWareHouseView").new(VIEW_FOR_WEAR,kind,self.m_formation,nil,{tacticType = self.m_choseKind, tankType = self.m_choseTank},self.m_viewFor))
end

function TacticalCenterView:onChoseTactic(event)
	if self.m_curUiName and self.m_curUiName ~= "" then
		UiDirector.popMakeUiTop(self.m_curUiName)
		if event.obj.param then
			self.m_choseKind = event.obj.param.tacticstype
			self.m_choseTank = event.obj.param.tankType
		end

		if not self.m_formation.tacticsKeyId then
			self.m_formation.tacticsKeyId = {}
			for index=1,#self.container.tactisList do
				if index == event.obj.index then
					self.m_formation.tacticsKeyId[index] = event.obj.keyId
				else
					self.m_formation.tacticsKeyId[index] = 0
				end
			end
		else
			for index=1,#self.m_formation.tacticsKeyId do
				if index == event.obj.index then
					self.m_formation.tacticsKeyId[index] = event.obj.keyId
				end
			end
		end

		if self.m_choseForm > 0 then  --前提是先选择了某个战术阵型(默认是没选择任何战术阵型的)
			TacticsBO.setTacticForm(function ()
				self.m_formation.tacticsKeyId = TacticsMO.TacticForms_[self.m_choseForm].keyId
			end, self.m_formation.tacticsKeyId,self.m_choseForm)
		end

		Notify.notify(LOCAL_TACTICS_FORARMY, {formation = self.m_formation, formationIndex = self.m_choseForm})
		Notify.notify(LOCAL_TACTICS_UPDATA_ITEM, {formation = self.m_formation})
		self:showUI()
	end
end

function TacticalCenterView:onUpgradeTactic(event)
	-- if self.m_curUiName and self.m_curUiName ~= "" then
	self:showUI()
	Notify.notify(LOCAL_TACTICS_UPDATA_ITEM, {formation = self.m_formation})
	-- end
end

function TacticalCenterView:onExit()
	TacticalCenterView.super.onExit(self)
	if self.m_choseTacticHandler then
		Notify.unregister(self.m_choseTacticHandler)
		self.m_choseTacticHandler = nil
	end

	if self.m_upgradeTacticHandler then
		Notify.unregister(self.m_upgradeTacticHandler)
		self.m_upgradeTacticHandler = nil
	end
end

return TacticalCenterView