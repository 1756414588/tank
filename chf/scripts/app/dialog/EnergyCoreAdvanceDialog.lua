--
-- Author: Gss
-- Date: 2019-04-15 10:39:59
--
-- 能源核心中间部分选择框 

local EnergyCoreEquipTableView = class("EnergyCoreEquipTableView", TableView)

function EnergyCoreEquipTableView:ctor(size)
	EnergyCoreEquipTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	self.m_equips = EquipMO.getFreeEquipsAtPos()
	table.sort(self.m_equips, EquipBO.orderEquipNew)

	-- 表示每个cell中的checkbox是否被选中
	self.m_chosenData = {}
end

function EnergyCoreEquipTableView:numberOfCells()
	return #self.m_equips
end

function EnergyCoreEquipTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EnergyCoreEquipTableView:createCellAtIndex(cell, index)
	EnergyCoreEquipTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local equip = self.m_equips[index]
	local equipDB = EquipMO.queryEquipById(equip.equipId)
	if not equipDB then return cell end
	local equipPos = EquipMO.getPosByEquipId(equip.equipId)
	
	local itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(itemView, cell, true)
	cell.itemView = itemView
	-- 名称
	local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[equipDB.quality]}):addTo(cell)
	
	--checkbox
	local checkBox = CellCheckBox.new(nil, nil, handler(self, self.onCheckedChanged))
	checkBox.cellIndex = index
	checkBox:setAnchorPoint(cc.p(0, 0.5))
	cell:addButton(checkBox, self.m_cellSize.width - 90, self.m_cellSize.height / 2 - 22)

	if self.m_chosenData[index] then
		checkBox:setChecked(true)
	end
	cell.checkBox = checkBox

	--增加XX经验
	local label = ui.newTTFLabel({text = "EXP", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 160, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local expValue = 0
	if equipPos == 0 then
		if ActivityBO.isValid(ACTIVITY_ID_EQUIP_UP_CRIT) then
			expValue = expValue + math.floor(equipDB.a * (1 + ACTIVITY_EQUIP_CRIT_RATE))
		else
			expValue =  expValue + equipDB.a
		end
	else
		local equipLevel = EquipMO.queryEquipLevel(equipDB.quality, equip.level)
		if equipLevel then
			expValue = equipLevel.giveExp + equip.exp
		else
			expValue = equip.exp
		end
	end

	local value = ui.newTTFLabel({text = "+" .. expValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	return cell
end

function EnergyCoreEquipTableView:cellTouched(cell, index)
	self.m_chosenData[index] = not self.m_chosenData[index]
	cell.checkBox:setChecked(self.m_chosenData[index])

	self:dispatchEvent({name = "CHECK_EVENT_FOR_ENERGYCORE", index = index})
end

function EnergyCoreEquipTableView:onCheckedChanged(sender, isChecked)
	local index = sender.cellIndex

	self.m_chosenData[index] = isChecked
	self:dispatchEvent({name = "CHECK_EVENT_FOR_ENERGYCORE", index = index})
end

-- quality:某种品质的装备全部被选中，为nil表示全部装备
function EnergyCoreEquipTableView:checkAll(quality, isChecked)
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local equip = self.m_equips[index]
		local equipDB = EquipMO.queryEquipById(equip.equipId)
		local pos = EquipMO.getPosByEquipId(equip.equipId)

		if equipDB then
			if ((quality == nil or equipDB.quality == quality) and pos == 0) or (equipDB.quality < 3 and (quality == nil or equipDB.quality == quality)) then
				self.m_chosenData[index] = isChecked

				local cell = self:cellAtIndex(index)
				if cell and cell.checkBox then
					cell.checkBox:setChecked(isChecked)
				end
			end
		end
	end
end

function EnergyCoreEquipTableView:getCheckedExp()
	local exp = 0

	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		if self.m_chosenData[index] then -- 选中了
			local equip = self.m_equips[index]
			local equipDB = EquipMO.queryEquipById(equip.equipId)
			local equipPos = EquipMO.getPosByEquipId(equip.equipId)

			if equipPos == 0 then
				if ActivityBO.isValid(ACTIVITY_ID_EQUIP_UP_CRIT) then
					exp = exp + math.floor(equipDB.a * (1 + ACTIVITY_EQUIP_CRIT_RATE))
				else
					exp =  exp + equipDB.a
				end
			else
				exp = exp + EquipMO.queryEquipLevel(equipDB.quality, equip.level).giveExp + equip.exp
			end
		end
	end

	return exp
end

function EnergyCoreEquipTableView:getCheckedEquips()
	local ret = {}
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		if self.m_chosenData[index] then -- 选中了
			local equip = self.m_equips[index]
			ret[#ret + 1] = equip
		end
	end
	return ret
end

function EnergyCoreEquipTableView:checkNeed(needexp,isChecked)
	self:updateChoseData() --重置
	local exp = 0
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local equip = self.m_equips[index]
		local equipDB = EquipMO.queryEquipById(equip.equipId)
		local pos = EquipMO.getPosByEquipId(equip.equipId)
		local cell = self:cellAtIndex(index)
		if cell and cell.checkBox then
			cell.checkBox:setChecked(false)
		end

		if equipDB and (pos == 0 or equipDB.quality < 3) then
			if pos == 0 then
				if ActivityBO.isValid(ACTIVITY_ID_EQUIP_UP_CRIT) then
					exp = exp + math.floor(equipDB.a * (1 + ACTIVITY_EQUIP_CRIT_RATE))
				else
					exp =  exp + equipDB.a
				end
			else
				exp = exp + EquipMO.queryEquipLevel(equipDB.quality, equip.level).giveExp + equip.exp
			end

			if exp <= needexp then
				self.m_chosenData[index] = isChecked
				if cell and cell.checkBox then
					cell.checkBox:setChecked(isChecked)
				end
			end
		end
	end
end

function EnergyCoreEquipTableView:moveCells(callback)
	self.m_equips = EquipMO.getFreeEquipsAtPos()
	table.sort(self.m_equips, EquipBO.orderEquipNew)
	
	--cell移动
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if cell and self.m_chosenData[index] then
			local boom = armature_create("nyhx_nlzr",nil,nil,function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
				end
			end):addTo(cell.itemView):center()
			boom:getAnimation():playWithIndex(0)
		end
	end

	self:performWithDelay(function ()
		self:updateChoseData()
		self:reloadData()
		if callback then callback() end
	end, 1)
end

function EnergyCoreEquipTableView:updateChoseData()
	self.m_chosenData = {}
end





----------------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local EnergyCoreAdvanceDialog = class("EnergyCoreAdvanceDialog", Dialog)

function EnergyCoreAdvanceDialog:ctor(callBack)
	EnergyCoreAdvanceDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 880)})
	self.m_callBack = callBack
end

function EnergyCoreAdvanceDialog:onEnter()
	EnergyCoreAdvanceDialog.super.onEnter(self)
	self:setTitle(CommonText[8014])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setPreferredSize(cc.size(self:getBg():width() - 34,self:getBg():height() - 80))

	self:showUI()
end

function EnergyCoreAdvanceDialog:showUI()
	if EnergyCoreMO.energyCoreData_.section > 4 then
		self:pop()
		return
	end

	local lvInfo = EnergyCoreMO.queryLvInfoByLv(EnergyCoreMO.energyCoreData_.lv)
	local sectionExp = EnergyCoreMO.queryExpByLvAndSection(EnergyCoreMO.energyCoreData_.lv, EnergyCoreMO.energyCoreData_.section).exp
	self.m_needExp = sectionExp
	local lvlab1, lvlab2 = EnergyCoreMO.formatEnergyCoreLv()

	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	--顶部bg
	local topBg = display.newSprite(IMAGE_COMMON .. "energy_top_bg.png"):addTo(container)
	topBg:setPosition(self:getBg():width() / 2, self:getBg():height() - 45 - topBg:height() / 2)
	topBg:setScale(0.85)

	--等级和名字
	local headBg = display.newSprite(IMAGE_COMMON .. "energy_head_bg.png"):addTo(topBg,9)
	headBg:setPosition(headBg:width() / 2, topBg:height() / 2 - 20)
	local lvBg1 = display.newSprite(IMAGE_COMMON .. "energy_lv_bg.png"):addTo(headBg,-1)
	lvBg1:setPosition(headBg:width() / 2 - 25, headBg:height() / 2 + 8)
	local lv1 = UiUtil.label(lvlab1,nil,cc.c3b(0, 0, 0)):addTo(lvBg1):center()

	local lvBg2 = display.newSprite(IMAGE_COMMON .. "energy_lv_bg.png"):addTo(headBg,-1)
	lvBg2:setPosition(headBg:width() / 2 + 25, lvBg1:y())
	local lv2 = UiUtil.label(lvlab2,nil,cc.c3b(0, 0, 0)):addTo(lvBg2):center()

	--名称
	local lvName = UiUtil.label(lvInfo.desc2,20,cc.c3b(0,0,0)):addTo(headBg)
	lvName:setPosition(headBg:width() / 2, 22)


	--四个状态球
	for index=1,4 do
		local exp = EnergyCoreMO.queryExpByLvAndSection(EnergyCoreMO.energyCoreData_.lv, index).exp
		local tipBg = display.newSprite(IMAGE_COMMON.."energy_bar_bg.png"):addTo(topBg)
		tipBg:setPosition(headBg:x() + 120 + (index - 1)*125,headBg:height() / 2)

		local needBg = display.newSprite(IMAGE_COMMON.."energy_numExp_bg.png"):addTo(tipBg,9):center()
		local needLab = UiUtil.label(""):addTo(needBg):center()
		needLab:setString(exp)

		--进度
		local clipping = cc.ClippingNode:create()
		local oilBar = ProgressBar.new(IMAGE_COMMON .. "energy_ball_bar.png", BAR_DIRECTION_CIRCLE)
		local mask = display.newSprite(IMAGE_COMMON.."bar_bg_13.png")
		clipping:setInverted(false)
		clipping:setAlphaThreshold(0.0)
		clipping:setStencil(mask)
		clipping:addChild(oilBar)
		clipping:addTo(tipBg):center()
		oilBar:setPercent(EnergyCoreMO.energyCoreData_.exp / sectionExp)

		if EnergyCoreMO.energyCoreData_.section > index then
			oilBar:setPercent(1)
			needLab:setString("Max")

			local lightningBall = CCArmature:create("nyhx_shandianqiu"):addTo(tipBg):center()
		    lightningBall:getAnimation():playWithIndex(0)
		elseif EnergyCoreMO.energyCoreData_.section < index then
			oilBar:setPercent(0)
		elseif EnergyCoreMO.energyCoreData_.section == index then
			local lightning = CCArmature:create("nyhx_dianliu"):addTo(clipping)
			local yOff = (oilBar:getPercent() - 0.5) * 91
			lightning:setPosition(oilBar:getPositionX(),yOff + 5)
		    lightning:getAnimation():playWithIndex(0)
		end
	end

	--当前阶段进度条
	local percent = EnergyCoreMO.energyCoreData_.exp / sectionExp
	if percent > 1 then
		percent = 1
	end
	local expbarBg = display.newSprite(IMAGE_COMMON.."energy_exp_bar_bg.png"):addTo(topBg)
	expbarBg:setPosition(topBg:width() / 2 + 25,0)
	local expBar = ProgressBar.new(IMAGE_COMMON .. "energy_exp_bar.png", BAR_DIRECTION_HORIZONTAL):addTo(topBg)
	expBar:setPosition(topBg:width() / 2 + 25,5)
	expBar:setPercent(percent)
	local barani = CCArmature:create("nyhx_jindutiao"):addTo(expBar,99)
    barani:getAnimation():playWithIndex(0)
    barani:setAnchorPoint(cc.p(0,0.5))
    barani:setScaleX(percent)
    barani:setPosition(0,expBar:height() / 2)

	local fenge = CCArmature:create("nyhx_jindutiao_fenge"):addTo(expBar,9999)
    fenge:getAnimation():playWithIndex(0)
    fenge:setPosition(expBar:width() * percent,expBar:height() / 2)

	self.m_expBar = expBar
	self.m_fenge = fenge

	-- local barIcon = display.newSprite(IMAGE_COMMON .. "energy_exp_bar.png")
	-- local bar = CCProgressTimer:create(barIcon):addTo(expBar,90):center()
	-- bar:setType(kCCProgressTimerTypeBar)
	-- bar:setBarChangeRate(cc.p(1,0))
	-- bar:setMidpoint(cc.p(0,0))
	-- bar:setPercentage(EnergyCoreMO.energyCoreData_.exp / sectionExp)
	-- self.m_percentBar = bar

	--经验数字展示
	local expLab = UiUtil.label(EnergyCoreMO.energyCoreData_.exp):addTo(expBar,99)
	expLab:setPosition(expBar:width() / 2 - 40, expBar:height() / 2)
	local needExp = UiUtil.label("/"..sectionExp):addTo(expBar,99)
	needExp:setPosition(expLab:x() + expLab:width() / 2 + needExp:width() / 2, expLab:y())
	self.m_needExpLab = needExp
	self.m_expLabel_ = expLab

	--BG
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container,-1)
	infoBg:setPreferredSize(cc.size(container:width() - 55, container:height() - topBg:height() - 250))
	infoBg:setPosition(container:width() / 2, container:height() / 2 - 30)

	--所有可选的，tableview
	local function onCheckEquip(event)  -- 有装备被选中
		self:onShowChecked()
	end

	--奖励属性预知
	local condition = EnergyCoreMO.queryLvInfoByLv(EnergyCoreMO.energyCoreData_.lv)
	local tips = UiUtil.label(CommonText[8003]):addTo(container)
	tips:setPosition(container:width() / 2, self:getBg():height() - 190)
	--位置
	--POSBG
	local posBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(container)
	posBg:setPosition(container:width() / 2,tips:y() - 35)
	local pos = UiUtil.label(string.format(CommonText[8026],condition.index)):addTo(posBg):center()

	--属性
	local lightAttr = json.decode(condition.lightAward)
	for index=1,#lightAttr do
	    local attr = lightAttr[index]
	    local attributeData = AttributeBO.getAttributeData(attr[1],attr[2])
	    local name = UiUtil.label(attributeData.name):addTo(container)
	    name:setAnchorPoint(cc.p(0,0.5))
	    name:setPosition(40 + (index - 1)* 150, posBg:y() - 40)

	    local value = UiUtil.label("+"..attributeData.strValue,nil,COLOR[2]):rightTo(name)
	end

	local view = EnergyCoreEquipTableView.new(cc.size(self:getBg():width() - 84,self:getBg():height() - 460)):addTo(container)
	view:addEventListener("CHECK_EVENT_FOR_ENERGYCORE", onCheckEquip)
	view:setPosition(40, 170)
	view:reloadData()
	self.m_equipTableView_ = view

	self.m_checkBoxs = {}
	--品质选择
	for index =1,6 do
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onAllCheckedChanged)):addTo(container)
		checkBox:setPosition(((index - 1) % 3 + 1 - 0.5) * ((self:getBg():width() - 190) / 3), 130 - math.floor((index - 1) / 3)* 60)
		checkBox.quality = index
		self.m_checkBoxs[index] = checkBox

		local text = UiUtil.label(CommonText.color[index][2],nil,COLOR[index]):rightTo(checkBox)
		if index == 6 then
			text:setString(CommonText[141])
			text:setColor(COLOR[5])
			checkBox.quality = nil
		end
	end

	-- 一键填充
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local upgradeBtn = MenuButton.new(normal, selected, nil, handler(self, self.oneFillCallback)):addTo(container)
	upgradeBtn:setPosition(self:getBg():width() - 100, 130)
	upgradeBtn:setLabel(CommonText[8015])

	--注入
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local fillBtn = MenuButton.new(normal, selected, nil, handler(self, self.onInjectionCallback)):addTo(container)
	fillBtn:setPosition(self:getBg():width() - 100, 70)
	fillBtn:setLabel(CommonText[8016])
	self.m_fillBtn = fillBtn

	if EnergyCoreMO.energyCoreData_.redExp > 0 then
		self:goMelting(nil,function ()
			Toast.show(CommonText[8029])
		end)
	end
end

-- 根据当前选中的状态，更新显示增加经验值
function EnergyCoreAdvanceDialog:onShowChecked()
	local exp = 0
	if self.m_equipTableView_ then exp = self.m_equipTableView_:getCheckedExp() end
	local percent = (EnergyCoreMO.energyCoreData_.exp + exp) / self.m_needExp
	if percent > 1 then
		percent = 1
	end
	self.m_expLabel_:setString(EnergyCoreMO.energyCoreData_.exp + exp)
	self.m_expBar:setPercent(percent)
	self.m_fenge:setPosition(self.m_expBar:width() * percent,self.m_expBar:height() / 2)
	self.m_needExpLab:setPosition(self.m_expLabel_:x() + self.m_expLabel_:width() / 2 + self.m_needExpLab:width() / 2, self.m_expLabel_:y())
end

function EnergyCoreAdvanceDialog:oneFillCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	--填满所需要的经验
	local expAll, ownAll = EnergyCoreMO.getExpByLvAnd(lv)
	needAll = expAll - ownAll

	if self.m_equipTableView_ then
		self.m_equipTableView_:checkNeed(needAll,true)
		self:onShowChecked()
	end
end

function EnergyCoreAdvanceDialog:onInjectionCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local equips = self.m_equipTableView_:getCheckedEquips()
	local param = {}

	for index=1,#equips do
		param[index] = {v1 = ITEM_KIND_EQUIP, v2 = equips[index].keyId, v3 = 1}
	end

	if #param <= 0 then
		Toast.show(CommonText[8017])
		return
	end

	local chosedExp = 0
	if self.m_equipTableView_ then chosedExp = self.m_equipTableView_:getCheckedExp() end
	local expAll, ownAll = EnergyCoreMO.getExpByLvAnd(lv)
	needAll = expAll - ownAll
	
	if chosedExp > needAll then
		require("app.dialog.TipsAnyThingDialog").new(CommonText[8018],function ()
			self:goMelting(param)
		end):push()
	else
		self:goMelting(param)
	end
end

function EnergyCoreAdvanceDialog:goMelting(param,callBack)
	local sender = self.m_fillBtn
	local list = param or {}
	local function onMeltingCallBack()
		--按钮位置
		local wPos = sender:convertToWorldSpace(cc.p(sender:getContentSize().width / 2,sender:getContentSize().height / 2))
		local lPos = self.m_touchLayer:convertToNodeSpace(wPos)
		--进度条位置
		local toWPos = self.m_expBar:convertToWorldSpace(cc.p(self.m_expBar:getContentSize().width / 2,self.m_expBar:getContentSize().height / 2))
		local ltPos = self.m_touchLayer:convertToNodeSpace(toWPos)

		local path = "animation/effect/nyhx_lizi.plist"
		local particleSys = cc.ParticleSystemQuad:create(path)
		particleSys:setPosition(lPos)
		particleSys:addTo(self.m_touchLayer)
	    particleSys:runAction(transition.sequence({cc.MoveTo:create(1, cc.p(ltPos.x, ltPos.y)), cc.CallFunc:create(function (sender)
	    	particleSys:removeSelf()
	    	self.m_touchLayer:removeSelf()
	    	if self.m_callBack then self.m_callBack() end
	    	self:showUI()
	    	if callBack then callBack() end
	    end)}))
	end

	EnergyCoreBO.meltingEngergyCore(function ()
		local touchLayer = display.newColorLayer(ccc4(0, 0, 0, 0)):addTo(self:getBg(),999)
		touchLayer:setContentSize(cc.size(display.width, display.height))
		touchLayer:setPosition(0, 0)
		touchLayer:setTouchSwallowEnabled(true)

		touchLayer:setTouchEnabled(true)
		touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			return true
		end)
		self.m_touchLayer = touchLayer

		if self.m_equipTableView_ then
			self.m_equipTableView_:moveCells(function ()
			onMeltingCallBack()
			end)
		end
	end,list,1)
end

function EnergyCoreAdvanceDialog:onAllCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	if self.m_equipTableView_ then
		local quality = sender.quality
		self.m_equipTableView_:checkAll(quality, isChecked)
		self:onShowChecked()
	end
end

function EnergyCoreAdvanceDialog:onExit()
	EnergyCoreAdvanceDialog.super.onExit(self)
end

return EnergyCoreAdvanceDialog