--
-- Author: Gss
-- Date: 2018-12-12 11:03:15
--
-- 战术仓库界面  TacticsWareHouseView

local COL_NUM = 5  --一行显示5个

local TacticWarehouseTableView = class("TacticWarehouseTableView", TableView)

function TacticWarehouseTableView:ctor(size, viewFor, viewStyle, choseIndex, formation, lastTactic)
	TacticWarehouseTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 140)
	self.m_viewFor = viewFor
	self.m_viewStyle = viewStyle
	self.m_choseIndex = choseIndex
	self.m_formation = formation
	self.m_lastTactic = lastTactic
	self.m_tactics = {}
	self.m_param = {}
end

function TacticWarehouseTableView:onEnter()
	TacticWarehouseTableView.super.onEnter(self)
end

function TacticWarehouseTableView:onExit()
	TacticWarehouseTableView.super.onExit(self)
end

local SHOW_GRID_LIMIT = 5

function TacticWarehouseTableView:numberOfCells()
	if #self.m_tactics > SHOW_GRID_LIMIT then
		return math.ceil(#self.m_tactics / COL_NUM)
	else
		return math.ceil(5 / COL_NUM)
	end
end

function TacticWarehouseTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function TacticWarehouseTableView:createCellAtIndex(cell, index)
	TacticWarehouseTableView.super.createCellAtIndex(self, cell, index)
	if #self.m_tactics > 0 then
		for numIndex = 1, COL_NUM do
			local posIndex = (index - 1) * COL_NUM + numIndex
			local tactic = self.m_tactics[posIndex]
			if tactic then
				local normal = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
				local selected = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
				local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onComponentCallback))
				cell:addButton(btn, 14 + (numIndex - 0.5) * 115, self.m_cellSize.height / 2 + 10)
				btn:setScale(0.95)
				btn.tactic = tactic

				local itemView
				if self.m_viewFor == ITEM_KIND_TACTIC_PIECE then
					itemView = UiUtil.createItemView(self.m_viewFor, tactic.tacticsId,{tacticLv = tactic.lv, count = tactic.count or 0}):addTo(btn):center()
				else
					itemView = UiUtil.createItemView(self.m_viewFor, tactic.tacticsId,{tacticLv = tactic.lv}):addTo(btn):center()
				end

				local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
				lockIcon:setPosition(itemView:width() - 10, itemView:height() - 10)
				lockIcon:setScale(0.5)
				lockIcon:setVisible(tactic.bind == 1)

				local resData = UserMO.getResourceData(self.m_viewFor,tactic.tacticsId)
				local name = UiUtil.label(resData.name,nil,COLOR[resData.quality + 1]):alignTo(itemView, -65, 1)
			end
		end
	end

	return cell
end

function TacticWarehouseTableView:onComponentCallback(tag, sender)
	if self.m_viewFor == ITEM_KIND_TACTIC_PIECE then
		require("app.dialog.TacticChipDialog").new(sender.tactic.tacticsId):push()
	else
		require("app.dialog.DetailTacticDialog").new(sender.tactic, self.m_viewStyle, self.m_choseIndex, self.m_formation, self.m_lastTactic,self.m_param):push()
	end
end

-- choseIndex .1= 战术。2= 碎片
function TacticWarehouseTableView:updateUI(list,choseIndex, param)
	self.m_tactics = list
	self.m_param = param
	function sortFun(a,b)
		if a.quality == b.quality then
			if choseIndex == 1 then
				return a.lv > b.lv
			else
				return a.tacticsId > b.tacticsId
			end
		else
			return a.quality > b.quality
		end
	end
	table.sort(self.m_tactics,sortFun)

	self:reloadData()
end



-----------------------------------------------------------------------------

local TacticsWareHouseView = class("TacticsWareHouseView", UiNode)

function TacticsWareHouseView:ctor(viewFor,choseIndex, formation, lastTactic,param,armySettingFo)
	TacticsWareHouseView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_viewFor = viewFor
	self.m_choseIndex = choseIndex
	self.m_lastTactic = lastTactic
	self.m_formation = formation
	self.m_param = param
	self.m_armySettingFor = armySettingFor
end

function TacticsWareHouseView:onEnter()
	TacticsWareHouseView.super.onEnter(self)
	self:setTitle(CommonText[4003])

	self.m_chosenIndex = 1 --默认选择第一个(大类型，战术，战术碎片。战术材料)
	self.m_pageIndex = 1  --默认选择第一个(小类型。战术类型，夹攻，进攻，防守...)
	self.m_subIdx = 1  --默认选择第一个(最小类型，塔克，战车.....)
	if self.m_param and self.m_param.tacticType then
		self.m_pageIndex = self.m_param.tacticType
	end
	if self.m_param and self.m_param.tankType then
		self.m_subIdx = self.m_param.tankType
	end
	self.m_freshHandler = Notify.register(LOCAL_TACTICS_UPDATE, handler(self, self.shouTacticInfo))
	self:showUI()
end

function TacticsWareHouseView:showUI()
	self.m_btns = {}
	local nameList = CommonText[4002]
	for index=1,3 do
		local normal = display.newSprite("image/tactics/btn_tactics_normal.png")
		local selected = display.newSprite("image/tactics/btn_tactics_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onChosenCallback)):addTo(self:getBg(),99)
		btn.index = index
		btn:setPosition(22, self:getBg():height() - (index - 1)*130 - 230 )
		self.m_btns[index] = btn

		if self.m_chosenIndex == index then
			local sprite = display.newSprite("image/tactics/btn_tactics_selected.png")
			btn:setNormalSprite(display.newSprite("image/tactics/btn_tactics_selected.png"))
		end

		local name = UiUtil.label(nameList[index],nil,nil,cc.size(25,0)):addTo(btn,99)
		name:setPosition(15,btn:height() / 2)
	end

	self:showContainer(self.m_chosenIndex)
end

function TacticsWareHouseView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	for idx=1,#self.m_btns do
		if sender.index == idx then
			self.m_btns[idx]:setNormalSprite(display.newSprite("image/tactics/btn_tactics_selected.png"))
		else
			self.m_btns[idx]:setNormalSprite(display.newSprite("image/tactics/btn_tactics_normal.png"))
		end
	end
	self.m_chosenIndex = sender.index
	-- self.m_subIdx = 1  --默认选择第一个
	self:showContainer(sender.index)
end

function TacticsWareHouseView:showContainer(choseIndex)
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	if choseIndex == 3 then
		self:showMaterials() --战术和战术碎片
	else
		self:showTactics() --战术材料
	end
end

function TacticsWareHouseView:showMaterials()
	local TacticMaterialsTableView = require("app.scroll.TacticMaterialsTableView")
	local view = TacticMaterialsTableView.new(cc.size(self.m_contentNode:getContentSize().width - 30, self.m_contentNode:getContentSize().height - 135)):addTo(self.m_contentNode)
	view:setPosition(20, 30)
	view:reloadData()
end

function TacticsWareHouseView:showTactics()
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	if self.m_chosenIndex == 2 then --战术碎片
		size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 - 60)
	end
	local pages = CommonText[4001]

	local function createDelegate(container, index)
		-- self.m_subIdx = 1  --默认选择第一个
		self:showIndexTactics(container, index)
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate(index)
		return true
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self.m_contentNode)
	pageView:setPageIndex(self.m_pageIndex)
	self.m_pageView = pageView

	if self.m_chosenIndex == 2 then --战术碎片才显示
		pageView:setPosition(GAME_SIZE_WIDTH / 2, 94 + size.height / 2)
 		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
 		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
 		local strengthBtn = MenuButton.new(normal ,selected, nil, function ()
 			ManagerSound.playNormalButtonSound()

 			if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_TACTIC) then  -- 等级不足
 				local sectionId = CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_TACTIC)
 				local exploreSection = CombatMO.querySectionById(sectionId)
 				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(EXPLORE_TYPE_TACTIC), exploreSection.name))
 				return
 			end

 			local CombatLevelView = require("app.view.CombatLevelView")
 			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_TACTIC)):push()
 		end):addTo(self.m_contentNode)
 		strengthBtn:setPosition(self.m_contentNode:getContentSize().width / 2, 60)
 		strengthBtn:setLabel("战术探险")
	end
end

function TacticsWareHouseView:showIndexTactics(container, index)
	local btnBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(container)
	btnBg:setPreferredSize(cc.size(container:getContentSize().width, btnBg:getContentSize().height))
	btnBg:setPosition(container:getContentSize().width / 2,container:getContentSize().height - 25)
	--tableBtn
	self.btn1 = UiUtil.button("btn_59_normal.png", "btn_59_selected.png", nil, handler(self, self.showIndex))
   		:addTo(btnBg,0,1):pos(105,btnBg:getContentSize().height / 2 + 3)
  	self.btn1:selected()
  	self.btn1:selectDisabled()
  	local texe1 = UiUtil.label(CommonText[4000][1]):addTo(self.btn1):center()

  	self.btn2 = UiUtil.button("btn_60_normal.png", "btn_60_selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,2):alignTo(self.btn1, 90)
  	self.btn2:unselected()
  	self.btn2:selectDisabled()
  	local texe2 = UiUtil.label(CommonText[4000][2]):addTo(self.btn2):center()

  	self.btn3 = UiUtil.button("btn_61_normal.png", "btn_61_selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,3):alignTo(self.btn2, 120)
  	self.btn3:unselected()
  	self.btn3:selectDisabled()
  	local texe3 = UiUtil.label(CommonText[4000][3]):addTo(self.btn3):center()

  	self.btn4 = UiUtil.button("btn_60_normal.png", "btn_60_selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,4):alignTo(self.btn3, 120)
  	self.btn4:setScaleX(-1)
  	self.btn4:unselected()
  	self.btn4:selectDisabled()
  	local texe4 = UiUtil.label(CommonText[4000][4]):addTo(self.btn4):center()
  	texe4:setScaleX(-1)

  	self.btn5 = UiUtil.button("btn_59_normal.png", "btn_59_selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,5):alignTo(self.btn4, 90)
  	self.btn5:setScaleX(-1)
  	self.btn5:unselected()
  	self.btn5:selectDisabled()
  	local texe5 = UiUtil.label(CommonText[4000][5]):addTo(self.btn5):center()
  	texe5:setScaleX(-1)

  	local viewFor
  	if self.m_chosenIndex == 1 then
  		viewFor = ITEM_KIND_TACTIC
  	elseif self.m_chosenIndex == 2 then
  		viewFor = ITEM_KIND_TACTIC_PIECE
  	end
  	local view = TacticWarehouseTableView.new(cc.size(container:width() - 20, container:height() - 60), viewFor, self.m_viewFor, self.m_choseIndex, self.m_formation, self.m_lastTactic):addTo(container)
  	view:setPosition(20,0)
  	self.view = view

  	self.m_chosePageIndex = index
  	self:showIndex(self.m_subIdx)
end

function TacticsWareHouseView:showIndex(tag,sender)
	for i=1,5 do
		if i == tag then
			self["btn"..i]:selected()
		else
			self["btn"..i]:unselected()
		end
	end
	self.m_subIdx = tag

	self:shouTacticInfo()
end

function TacticsWareHouseView:shouTacticInfo()
	local pageIndex = self.m_chosePageIndex
	local subIndex = self.m_subIdx

	local data = {}
	if self.m_chosenIndex == 1 then --战术
		if self.m_armySettingFor == ARMY_SETTING_FOR_CROSS or self.m_armySettingFor == ARMY_SETTING_FOR_CROSS1 or self.m_armySettingFor == ARMY_SETTING_FOR_CROSS2 then --跨服战特殊处理
			data = TacticsMO.getCrossTacticsByKind(subIndex, pageIndex, self.m_formation, self.m_armySettingFor)
		else
			data = TacticsMO.getTacticsByKind(subIndex, pageIndex, self.m_formation)
		end
	elseif self.m_chosenIndex == 2 then --战术碎片
		data = TacticsMO.getTacticsPiecesByKind(subIndex, pageIndex)
	end

	UiUtil.checkScrollNone(self.view,data)
	self.view:updateUI(data,self.m_chosenIndex,{tacticstype = pageIndex, tankType = subIndex})
end

-- function TacticsWareHouseView:freshHandler()
-- 	local pageIndex = self.m_chosePageIndex
-- 	local subIndex = self.m_subIdx
-- 	local data = {}
-- 	if self.m_chosenIndex == 1 then --战术
-- 		data = TacticsMO.getTacticsByKind(subIndex, pageIndex)
-- 	elseif self.m_chosenIndex == 2 then --战术碎片
-- 		data = TacticsMO.getTacticsPiecesByKind(subIndex, pageIndex)
-- 	end

-- 	UiUtil.checkScrollNone(self.view,data)
-- 	self.view:updateUI(data)
-- end

function TacticsWareHouseView:onExit()
	TacticsWareHouseView.super.onExit(self)
	if self.m_freshHandler then
		Notify.unregister(self.m_freshHandler)
		self.m_freshHandler = nil
	end
end

return TacticsWareHouseView