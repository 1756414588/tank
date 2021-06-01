------------------------------------------------------------------------------
-- 用于扫荡设置的tableview
------------------------------------------------------------------------------

--关卡信息
local Dialog = require("app.dialog.Dialog")
local PropLevelInfoDialog = class("PropLevelInfoDialog", Dialog)

function PropLevelInfoDialog:ctor(combatId,exploreType)
	PropLevelInfoDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 180)})
	self.combatId = combatId
	self.exploreType = exploreType
end

function PropLevelInfoDialog:onEnter()
	PropLevelInfoDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	-- 有几率获得装备升级材料
	local label =ui.newTTFLabel({text = CommonText[1170], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = 180 - 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local combatDB = CombatMO.queryExploreById(self.combatId)
	local awards = json.decode(combatDB.passDesc)
	if awards then
		for index = 1, #awards do
			local award = awards[index]
			local name = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = label:getPositionY() - index * 22, color = COLOR[award[2]], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			name:setAnchorPoint(cc.p(0, 0.5))
			
			if self.exploreType == EXPLORE_TYPE_EQUIP then
				local resData = UserMO.getResourceData(ITEM_KIND_EQUIP, award[1])
				name:setString(resData.name)
			else
				name:setString(award[1])
			end
		end
	end
end

--选择关卡TableView
local LevelTableView = class("LevelTableView", TableView)

-- tankId: 需要进行生产的tank
function LevelTableView:ctor(size, index,combatId)
	LevelTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.explorePass = {EXPLORE_TYPE_PART,EXPLORE_TYPE_EQUIP,EXPLORE_TYPE_MEDAL,EXPLORE_TYPE_WAR,EXPLORE_TYPE_ENERGYSPAR,EXPLORE_TYPE_TACTIC}
	self.m_cellSize = cc.size(size.width, 70)
	self.m_assistItem = {}
	self.exploreType = self.explorePass[index]
	local sectionId = CombatMO.getExploreSectionIdByType(self.exploreType)
	self.m_assistItem = CombatMO.getCombatIdsBySectionId(sectionId)
	self.m_curProductNum = 0
	local lastCombatId = 0
	if self.m_assistItem~= nil then
		lastCombatId = CombatMO.getLastFullStarCombatId(self.m_assistItem)
	end
	if CombatMO.selectCombatId[self.exploreType]~= nil and CombatMO.selectCombatId[self.exploreType]>0 then
		self.selectCombatIds = CombatMO.selectCombatId[self.exploreType]
	else
		self.selectCombatIds = lastCombatId
	end
end

function LevelTableView:numberOfCells()
	return #self.m_assistItem
end

function LevelTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function LevelTableView:createCellAtIndex(cell, index)
	LevelTableView.super.createCellAtIndex(self, cell, index)

	local combatId = self.m_assistItem[index]
	local combatDB = CombatMO.queryExploreById(combatId)

	local numbg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_partyB1.png"):addTo(cell, -1)
	numbg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height-20))
	numbg:setAnchorPoint(cc.p(0, 0.5))
	numbg:setPosition(0, self.m_cellSize.height/2)
	numbg:setVisible(false)

	local lineB = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(cell)
	lineB:setPreferredSize(cc.size(self.m_cellSize.width - 20, lineB:height()))
	lineB:setPosition(self.m_cellSize.width / 2, 0)

	-- 名字
	local name = ui.newTTFLabel({text = combatDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setColor(COLOR[11])
	name:setAnchorPoint(cc.p(0, 0.5))

	--关卡信息
    local normal = display.newSprite(IMAGE_COMMON .. "btn_levelinfo_nomal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_levelinfo_selected.png")
    local infoBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.levelInfoCallback))
    cell:addButton(infoBtn,self.m_cellSize.width/2-20, self.m_cellSize.height/2)
    infoBtn.combatId = combatId
    infoBtn:setScale(0.8)
    --
    local des = ui.newTTFLabel({text = CommonText[1168][10], font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width/2+20, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	des:setColor(COLOR[5])
	des:setAnchorPoint(cc.p(0, 0.5))
	cell.des = des

    --复选框
    local uncheckedSprite = display.newSprite(IMAGE_COMMON .. "check0.jpg")
	local checkedSprite = display.newSprite(IMAGE_COMMON .. "check1.png")
	local checkBox1 = CheckBox.new(uncheckedSprite, checkedSprite, handler(self,self.onCheckedChanged)):addTo(cell)
	checkBox1:setPosition(self.m_cellSize.width-110,self.m_cellSize.height/2)
	checkBox1.index = index
	checkBox1.combatId = combatId

	cell.checkBox = checkBox1
    --是否三星通关
    local combatInfo = CombatMO.getExploreById(combatId)
    if combatInfo then
    	if combatInfo.star < 3 then
    		des:setVisible(true)
    		checkBox1:setVisible(false)
    	else
    		des:setVisible(false)
    		checkBox1:setVisible(true)
    	end
    else
    	des:setVisible(true)
    	checkBox1:setVisible(false)
    end

	self:updateCell(cell, index)

	return cell
end
--
function LevelTableView:levelInfoCallback(tag, sender)
	PropLevelInfoDialog.new(sender.combatId,self.exploreType):push()
end
--
function LevelTableView:onCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	if isChecked then
		--table.insert(self.selectCombatIds,sender.index,sender.combatId)
		self.selectCombatIds = sender.combatId
	else
		--table.remove(self.selectCombatIds,sender.index)
		self.selectCombatIds = 0
	end
	for i=1,#self.m_assistItem do
		local cell = self:cellAtIndex(i)
		local combatId = self.m_assistItem[i]
		if cell then
			if self.selectCombatIds>0 and self.selectCombatIds == combatId then
				cell.checkBox:setChecked(true)
			else
				cell.checkBox:setChecked(false)
			end
		end
	end
	CombatMO.selectCombatId[self.exploreType] = self.selectCombatIds
end

function LevelTableView:updateCell(cell, cellIndex)
	local combatId = self.m_assistItem[cellIndex]
	local combatInfo = CombatMO.getExploreById(combatId)

	if combatInfo then
    	if combatInfo.star < 3 then
    		cell.des:setVisible(true)
    		cell.checkBox:setVisible(false)
    	else
    		cell.des:setVisible(false)
    		cell.checkBox:setVisible(true)
    	end
    else
    	cell.des:setVisible(true)
    	cell.checkBox:setVisible(false)
    end
	if self.selectCombatIds>0 and self.selectCombatIds == combatId then
		cell.checkBox:setChecked(true)
	else
		cell.checkBox:setChecked(false)
	end
end

function LevelTableView:setCurProductNum(num)
	self.m_curProductNum = num
	for index = 1, #self.m_assistItem do
		local cell = self:cellAtIndex(index)
		if cell then
			self:updateCell(cell, index)
		end
	end
end


-- 弹出框
local Dialog = require("app.dialog.Dialog")
local PropLevelDialog = class("PropLevelDialog", Dialog)

function PropLevelDialog:ctor(index,combatId,sweepView,useCallback)
	PropLevelDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 800)})
	self.index = index
	self.combatId = combatId
	self.sweepView = sweepView
	self.m_useCallback = useCallback
end

function PropLevelDialog:onEnter()
	PropLevelDialog.super.onEnter(self)
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(self:getBg():width() - 40, self:getBg():height() - 40))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local sectionId = CombatMO.getExploreSectionIdByType(self.sweepView.explorePass[self.index])
	local exploreSection = CombatMO.querySectionById(sectionId)

	local name = ui.newTTFLabel({text = exploreSection.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0.5, 0.5))


	if self.m_returnButton~= nil then
		self.m_returnButton:setVisible(false)
	end

	local view = LevelTableView.new(cc.size(430, btm:height() - 70),self.index,self.combatId):addTo(self:getBg())
	view:setPosition(40,40)
	view:reloadData()

	--关卡信息
    local normal = display.newSprite(IMAGE_COMMON .. "btn_close_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_close_selected.png")
    local closeBtn = MenuButton.new(normal, selected, nil, handler(self, self.closeDialog)):addTo(self:getBg())
    closeBtn:setPosition(440, 765)

end

function PropLevelDialog:closeDialog(tag, sender)
	Dialog.super.pop(self, self.m_useCallback)
	if self.sweepView then
		local cell = self.sweepView:cellAtIndex(self.index)
		if cell then
			self.sweepView:updateCell(cell, self.index)
		end
	end
end
-------------------------------
-------------------------------
local SweepSectionTableView = class("SweepSectionTableView", TableView)

function SweepSectionTableView:ctor(size,sweepSectionView)
	SweepSectionTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.sweepSectionView = sweepSectionView
	self.m_cellSize = cc.size(size.width, 250)
	self.totalCoin = 0
	self.m_productMaxNum = {}
	self.m_settingNum = {}
	self.m_totalCoin = {}
	self.m_minNum = 0
	self.sweepPlan = {}
	CombatMO.wipeSetInfo = {}
	--探险关卡
	self.explorePass = {EXPLORE_TYPE_PART,EXPLORE_TYPE_EQUIP,EXPLORE_TYPE_MEDAL,EXPLORE_TYPE_WAR,EXPLORE_TYPE_ENERGYSPAR,EXPLORE_TYPE_TACTIC}
	-- if CombatMO.myWipeInfo_~=nil then
	-- 	local coinNum = 0
	-- 	for k,v in pairs(clone(CombatMO.myWipeInfo_)) do
	-- 		coinNum = coinNum+CombatMO.getNeedCoin(v.exploreType,v.buyCount)
	-- 	end
	-- 	self.sweepSectionView:upCoinNum(coinNum)
	-- end
	self.sweepSectionView:upCoinNum(CombatMO.getUseCoin())

	for k,v in pairs(self.explorePass) do
		self.m_settingNum[v] = 0
		local tempSweep = {}
		local exploreType = v
		local sectionId = CombatMO.getExploreSectionIdByType(exploreType)
		local combatIds = CombatMO.getCombatIdsBySectionId(sectionId)
		self.m_productMaxNum[exploreType] = CombatMO.getNeedNum(exploreType)
		table.sort(combatIds,function(a,b)
			return a>b
		end)

		if CombatMO.myWipeInfo_~=nil then
			for k,v in pairs(clone(CombatMO.myWipeInfo_)) do
				if CombatMO.getNeedNum(v.exploreType)<=0 then
					self.m_settingNum[v.exploreType] = 0
				else
					if v.buyCount >= CombatMO.getNeedNum(v.exploreType) then
						self.m_settingNum[v.exploreType] = CombatMO.getNeedNum(v.exploreType)
					else
						self.m_settingNum[v.exploreType] = v.buyCount
					end
				end
			end
		end

		local lastCombatId = 0
		if combatIds~= nil then
			lastCombatId = CombatMO.getLastFullStarCombatId(combatIds)
		end
		if lastCombatId >0 then
			tempSweep.exploreType = exploreType
			tempSweep.combatId = lastCombatId
			tempSweep.buyCount = self.m_settingNum[exploreType]
			CombatMO.wipeSetInfo[exploreType] = tempSweep
		end

		local coinStr = CombatMO.getNeedCoin(exploreType,self.m_settingNum[exploreType])
		self.m_totalCoin[exploreType] = coinStr
	end
end

function SweepSectionTableView:onExit()
	SweepSectionTableView.super.onExit(self)
end

function SweepSectionTableView:numberOfCells()
	return #self.explorePass
end

function SweepSectionTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SweepSectionTableView:createCellAtIndex(cell, index)
	SweepSectionTableView.super.createCellAtIndex(self, cell, index)
	local tempSweep = {}
	local btn = display.newScale9Sprite(IMAGE_COMMON .. "info_wipe_bg.png"):addTo(cell)
	btn:setPreferredSize(cc.size(594, 250))
	btn:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local exploreType = self.explorePass[index]
	local sectionId = CombatMO.getExploreSectionIdByType(exploreType)

	gprint("[SweepSectionTableView] create cell. sectionId:", sectionId, "index:", index, "size:", self:numberOfCells())


 -- 探险
	local exploreSection = CombatMO.querySectionById(sectionId)
	local combatIds = CombatMO.getCombatIdsBySectionId(sectionId)
	table.sort(combatIds,function(a,b)
		return a>b
	end)
 

	local bg1 = display.newSprite(IMAGE_COMMON .. "info_wipe_bg1.png"):addTo(btn)
	bg1:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height/2-20)
	local bg2 = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(btn)
	bg2:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height - bg2:getContentSize().height/2)

	--
	local name = ui.newTTFLabel({text = exploreSection.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = self.m_cellSize.width / 2, y = btn:getContentSize().height - 17, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0.5, 0.5))

	local exploreType = CombatMO.getExploreTypeBySectionId(sectionId)


	local lastCombatId = 0
	if combatIds~= nil then
		lastCombatId = CombatMO.getLastFullStarCombatId(combatIds)
	end

	if CombatMO.myWipeInfo_~=nil then
		for k,v in pairs(clone(CombatMO.myWipeInfo_)) do
			if v.exploreType == exploreType then
				tempSweep = v
				lastCombatId = v.combatId
				--self.m_settingNum[exploreType] = tempSweep.buyCount
			end
		end
	else
		tempSweep.exploreType = exploreType
		tempSweep.combatId = lastCombatId
		tempSweep.buyCount = self.m_settingNum[exploreType]
	end
	local combatDB = CombatMO.queryExploreById(lastCombatId)
	local levelName= CommonText[1168][11]
	if combatDB~= nil then
		levelName = combatDB.name
	end
	CombatMO.selectCombatId[exploreType] = lastCombatId
	-- 装备和配件
	-- -- 副本可挑战次数
	local leftTime = CombatBO.getExploreChallengeLeftCount(exploreType)
	-- 描述
	local label = ui.newTTFLabel({text = CommonText[1168][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 35, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = leftTime, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX()+label:getContentSize().width, y = 35, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	if leftTime <= 0 then label:setColor(COLOR[5]) end
	--选择关卡
	local label = ui.newTTFLabel({text = CommonText[1168][5], font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width / 2+10, y = btn:getContentSize().height - 65, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(1, 0.5))

	local labelLevelName = ui.newTTFLabel({text = levelName, font = G_FONT, color = COLOR[5], size = FONT_SIZE_SMALL, x = label:getPositionX(), y = btn:getContentSize().height - 65, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	labelLevelName:setAnchorPoint(cc.p(0, 0.5))
	cell.levelName = labelLevelName

	-- 关卡信息
    local normal = display.newSprite(IMAGE_COMMON .. "btn_levelinfo_nomal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_levelinfo_selected.png")
    local infoBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.levelInfoCallback))
    cell:addButton(infoBtn,self.m_cellSize.width-120, self.m_cellSize.height - 65)
    infoBtn.index = index
    infoBtn.combatId = lastCombatId
    infoBtn.exploreType = exploreType
    cell.infoBtn = infoBtn
	-- 选择关卡
    local normal = display.newSprite(IMAGE_COMMON .. "btn_levelset_nomal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_levelset_select.png")
    local selectBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.selectLevelCallback))
    cell:addButton(selectBtn,self.m_cellSize.width-70, self.m_cellSize.height - 65)
    selectBtn.index = index
    selectBtn.combatId = lastCombatId

	--购买次数
	local buyTitle = ui.newTTFLabel({text = CommonText[1168][2], font = G_FONT, size = FONT_SIZE_MEDIUM, x = 50, y = btn:getContentSize().height/2-20, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	buyTitle:setAnchorPoint(cc.p(0, 0.5))

	--可购买次数
	local label = ui.newTTFLabel({text = CommonText[1168][3], font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width / 2-65, y = btn:getContentSize().height - 115, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local totaknum =  CombatMO.getNeedNum(exploreType)--self.m_settingNum[exploreType]
	local label = ui.newTTFLabel({text = totaknum, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX()+label:getContentSize().width, y = btn:getContentSize().height - 115,color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	if totaknum<=0 then
		label:setColor(COLOR[5])
	end
	
	local label = ui.newTTFLabel({text = CommonText[237][3], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX()+label:getContentSize().width, y = btn:getContentSize().height - 115, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	--花费金币
	local labelCoin = ui.newTTFLabel({text = CommonText[1168][4], font = G_FONT, size = FONT_SIZE_SMALL, x = btn:getContentSize().width-200, y = 35, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	labelCoin:setAnchorPoint(cc.p(0, 0.5))

	local coinNum = CombatMO.getNeedCoin(exploreType,self.m_settingNum[exploreType])
	local labelCoinNum = ui.newTTFLabel({text = coinNum, font = G_FONT, size = FONT_SIZE_SMALL, x = labelCoin:getPositionX()+labelCoin:getContentSize().width, y = 35, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	labelCoinNum:setAnchorPoint(cc.p(0, 0.5))
	cell.labelCoinNum = labelCoinNum
	self.m_totalCoin[exploreType] = coinNum

	local labeljb = ui.newTTFLabel({text = CommonText[1168][12], font = G_FONT, size = FONT_SIZE_SMALL, x = labelCoinNum:getPositionX()+labelCoinNum:getContentSize().width, y = 35, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	labeljb:setAnchorPoint(cc.p(0, 0.5))
	cell.labeljb = labeljb

	--选择的次数
	local numbg = display.newSprite(IMAGE_COMMON .. "info_wipe_bg2.png"):addTo(cell)
	numbg:setPosition(self.m_cellSize.width/ 2+15, self.m_cellSize.height/2-35)

	local tempNum = self.m_settingNum[exploreType]
	if CombatMO.getNeedNum(exploreType)<=0 then
		tempNum = 0
	else
		if self.m_settingNum[exploreType] >= CombatMO.getNeedNum(exploreType) then
			tempNum = CombatMO.getNeedNum(exploreType)
		end
	end
	local labelNum = ui.newTTFLabel({text = tempNum, font = G_FONT, size = FONT_SIZE_BIG, x = self.m_cellSize.width / 2+20, y = btn:getContentSize().height/2-35, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	labelNum:setAnchorPoint(cc.p(0.5, 0.5))
	cell.labelNum = labelNum


    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local disable = display.newSprite(IMAGE_COMMON .. "btn_reduce_disabled.png")
    local reduceBtn = CellMenuButton.new(normal, selected, disable, handler(self, self.onReduceCallback))
    cell:addButton(reduceBtn,210, self.m_cellSize.height/2-25)
    reduceBtn.index = index
    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local disable = display.newSprite(IMAGE_COMMON .. "btn_add_disabled.png")
    local addBtn = CellMenuButton.new(normal, selected, disable, handler(self, self.onAddCallback))
    cell:addButton(addBtn,self.m_cellSize.width - 180, reduceBtn:getPositionY())
    addBtn.index = index

    -- 最大按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_max_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_max_selected.png")
    local disable = display.newSprite(IMAGE_COMMON .. "btn_max_disabled.png")
    local maxBtn = CellMenuButton.new(normal, selected, disable, handler(self, self.onMaxCallback))
    cell:addButton(maxBtn,self.m_cellSize.width - 90, reduceBtn:getPositionY())
    maxBtn.index = index

	if not CombatMO.getCombatState(self.explorePass,index) then
		addBtn:setEnabled(false)
		maxBtn:setEnabled(false)
		reduceBtn:setEnabled(false)
		infoBtn:setEnabled(false)
	else
		addBtn:setEnabled(true)
		maxBtn:setEnabled(true)
		reduceBtn:setEnabled(true)
		infoBtn:setEnabled(true)
	end
	self.sweepPlan[exploreType]=tempSweep
    self:updateCell(cell,index)
	return cell
end

function SweepSectionTableView:updateCell(cell, cellIndex)
	local exploreType = self.explorePass[cellIndex]
	local coinStr = CombatMO.getNeedCoin(exploreType,self.m_settingNum[exploreType])
	self.m_totalCoin[exploreType] = coinStr
	cell.labelCoinNum:setString(coinStr)
	if CombatMO.getNeedNum(exploreType)<=0 then
		cell.labelNum:setString("0")
	else
		if self.m_settingNum[exploreType] >= CombatMO.getNeedNum(exploreType) then
			cell.labelNum:setString(CombatMO.getNeedNum(exploreType))
		else
			cell.labelNum:setString(self.m_settingNum[exploreType])
		end
	end
	cell.labeljb:setPositionX(cell.labelCoinNum:getPositionX()+cell.labelCoinNum:getContentSize().width)

	if self.sweepPlan[exploreType]~= nil then
		self.sweepPlan[exploreType].exploreType = exploreType
		self.sweepPlan[exploreType].buyCount = self.m_settingNum[exploreType]
	end
	if CombatMO.selectCombatId[exploreType]~= nil and CombatMO.selectCombatId[exploreType]>0 then
		cell.infoBtn.combatId = CombatMO.selectCombatId[exploreType]
		local combatDB = CombatMO.queryExploreById(CombatMO.selectCombatId[exploreType])
		cell.levelName:setString(combatDB.name)
		if self.sweepPlan[exploreType]~= nil then
			self.sweepPlan[exploreType].combatId = CombatMO.selectCombatId[exploreType]
		end
	end
	if self.sweepPlan[exploreType]~= nil and self.sweepPlan[exploreType].combatId~= nil then
		CombatMO.wipeSetInfo[exploreType] = self.sweepPlan[exploreType]
	else
		CombatMO.wipeSetInfo[exploreType] = nil
	end
end


function SweepSectionTableView:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = self.explorePass[sender.index]
	if self.m_settingNum[index]<=0 then
		return
	end
	self.m_settingNum[index] = self.m_settingNum[index] - 1
	self.m_settingNum[index] = math.max(self.m_settingNum[index], self.m_minNum)
	self:upDateRes(sender.index)
	self:upCoinNum()
end

function SweepSectionTableView:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = self.explorePass[sender.index]
	if self.m_settingNum[index] >= self.m_productMaxNum[index] then
		return
	end
	self.m_settingNum[index] = self.m_settingNum[index] + 1
	self.m_settingNum[index] = math.min(self.m_settingNum[index], self.m_productMaxNum[index])
	self:upDateRes(sender.index)
	self:upCoinNum()
end

function SweepSectionTableView:onMaxCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = self.explorePass[sender.index]
	if self.m_settingNum[index] >= self.m_productMaxNum[index] then
		return
	end
	self.m_settingNum[index] = self.m_productMaxNum[index]
	self:upDateRes(sender.index)
	self:upCoinNum()
end

function SweepSectionTableView:selectLevelCallback(tag, sender)
	PropLevelDialog.new(sender.index,sender.combatId,self,function ( ... )
		self:upDateRes(sender.index)
	end):push()
end

function SweepSectionTableView:levelInfoCallback(tag, sender)
	PropLevelInfoDialog.new(sender.combatId,sender.exploreType):push()
end

function SweepSectionTableView:upCoinNum()
	local totalCoin = 0
	for k,v in pairs(self.m_totalCoin) do
		totalCoin = totalCoin+v
	end
	self.sweepSectionView:upCoinNum(totalCoin)
end

function SweepSectionTableView:upDateRes(index)
	local cell = self:cellAtIndex(index)
	if cell then
		self:updateCell(cell, index)
	end
	-- local offset = self:getContentOffset()
	-- self:reloadData()
	-- self:setContentOffset(offset)
end

return SweepSectionTableView