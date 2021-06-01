--
-- Author: Gss
-- Date: 2018-12-17 09:45:39
--
-- 战术升级界面  TacticUpgradeView

local COL_NUM = 5  --一行显示5个

local TacticConsumeTableView = class("TacticConsumeTableView", TableView)

function TacticConsumeTableView:ctor(size, viewFor,item, addCallback, reduceCallback, param)
	TacticConsumeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 140)
	self.m_viewFor = viewFor
	self.m_item = item
	self.m_addCallback = addCallback
	self.m_reduceCallback = reduceCallback
	self.m_param = param
	self.m_tactics = {}
end

function TacticConsumeTableView:onEnter()
	TacticConsumeTableView.super.onEnter(self)
end

function TacticConsumeTableView:onExit()
	TacticConsumeTableView.super.onExit(self)
end

local SHOW_GRID_LIMIT = 5

function TacticConsumeTableView:numberOfCells()
	if #self.m_tactics > SHOW_GRID_LIMIT then
		return math.ceil(#self.m_tactics / COL_NUM)
	else
		return math.ceil(5 / COL_NUM)
	end
end

function TacticConsumeTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function TacticConsumeTableView:createCellAtIndex(cell, index)
	TacticConsumeTableView.super.createCellAtIndex(self, cell, index)
	if #self.m_tactics > 0 then
		for numIndex = 1, COL_NUM do
			local posIndex = (index - 1) * COL_NUM + numIndex
			local tactic = self.m_tactics[posIndex]
			if tactic then
				local itemView = UiUtil.createItemView(self.m_viewFor, tactic.tacticsId,{tacticLv = tactic.lv}):addTo(cell)
				itemView:setPosition(14 + (numIndex - 0.5) * 115, self.m_cellSize.height / 2)
				itemView.count = tactic.count

				local resData = UserMO.getResourceData(self.m_viewFor, tactic.tacticsId)
				local name = UiUtil.label(resData.name,nil,COLOR[resData.quality + 1]):alignTo(itemView, -65, 1)

				if self.m_viewFor == ITEM_KIND_TACTIC and #self.m_param.tacticList > 0 then
					for k,v in pairs(self.m_param.tacticList) do
						if v == tactic.keyId then
							itemView.count = tactic.count - 1
						end
					end
				elseif self.m_viewFor == ITEM_KIND_TACTIC_PIECE and #self.m_param.peceList > 0 then
					for k,v in pairs(self.m_param.peceList) do
						if v.v1 == tactic.tacticsId then
							itemView.count = tactic.count - v.v2
						end
					end
				end

				local count = UiUtil.label(itemView.count,18,COLOR[1]):addTo(itemView)
				count:setPosition(itemView:width() / 2, 10)
				count:setVisible(tactic.count >= 1 and self.m_viewFor == ITEM_KIND_TACTIC_PIECE)

				local reduceBtn = display.newSprite("image/tactics/reduce_btn.png"):addTo(itemView)
				reduceBtn:setTouchEnabled(true)
				reduceBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
					if event.name == "began" then
						itemView.count = itemView.count + 1
						count:setString(itemView.count)
							if self.m_reduceCallback then
								if self.m_viewFor == ITEM_KIND_TACTIC then
									self.m_reduceCallback(self.m_viewFor, tactic.keyId)
								elseif self.m_viewFor == ITEM_KIND_TACTIC_PIECE then
									self.m_reduceCallback(self.m_viewFor, tactic.tacticsId)
								end
							end

							if itemView.count >=  tactic.count then
								reduceBtn:setVisible(false)
							end
						return true
					elseif event.name == "ended" then
					end
				end)


				reduceBtn:setVisible(itemView.count < tactic.count)
				reduceBtn:setPosition(itemView:width() / 2 + 30, itemView:height() / 2 + 30)

				UiUtil.createItemDetailButton(itemView, cell, true,function ()
					local tacticDB = TacticsMO.queryTacticById(self.m_tactic.tacticsId)
					local lvInfo = TacticsMO.getLvInfoByLv(tacticDB.quality, self.m_tactic.lv)
					if lvInfo.breakOn == 1 and self.m_tactic.state == 0 then
						Toast.show(CommonText[4027])
						return
					end

					local maxLvInfo = TacticsMO.getMaxLvByQuality(tacticDB.quality)
					local maxLv = maxLvInfo[#maxLvInfo].lv
					if self.m_tactic.lv >= maxLv then
						Toast.show(CommonText[4015])
						return
					end
					local function playAnimation()
						if itemView.count <= 0 then
							Toast.show(CommonText[4016])
							return false
						end
						--背景层
						local touchLayer = display.newColorLayer(ccc4(0, 0, 0, 0)):addTo(self.m_item:getParent(),999)
						touchLayer:setContentSize(cc.size(display.width, display.height))
						touchLayer:setPosition(0, 0)
						touchLayer:setTouchEnabled(true)
						touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
							return true
						end)

						local wPos = itemView:convertToWorldSpace(cc.p(itemView:getContentSize().width / 2,itemView:getContentSize().height / 2))
						local lPos = touchLayer:convertToNodeSpace(wPos)
						local path = "animation/effect/miyaojuexing_tx1.plist"
						local particleSys = cc.ParticleSystemQuad:create(path):addTo(touchLayer)
						particleSys:setPosition(lPos)

						local itemPos = self.m_item:convertToWorldSpace(cc.p(self.m_item:getContentSize().width / 2,self.m_item:getContentSize().height / 2))
						local toPos = touchLayer:convertToNodeSpace(itemPos)

						particleSys:runAction(transition.sequence({cc.DelayTime:create(0.1), cc.MoveTo:create(0.3, cc.p(toPos.x,toPos.y)),
							cc.CallFunc:create(function()
									particleSys:removeSelf()
									touchLayer:removeSelf()

									if self.m_addCallback then
										if self.m_viewFor == ITEM_KIND_TACTIC then
											self.m_addCallback(self.m_viewFor, tactic.keyId)
										elseif self.m_viewFor == ITEM_KIND_TACTIC_PIECE then
											self.m_addCallback(self.m_viewFor, tactic.tacticsId)
										end
									end

									itemView.count = itemView.count - 1
									count:setString(itemView.count)

									if tactic.count > itemView.count then
										reduceBtn:setVisible(true)
									else
										reduceBtn:setVisible(false)
									end
								end)}))
					end
					playAnimation()
				end)
			end
		end
	end

	return cell
end

function TacticConsumeTableView:updateUI(list,tactic)
	self.m_tactics = list
	self.m_tactic = tactic
	function sortFun(a,b)
		if a.quality == b.quality then
			return a.tacticsId > b.tacticsId
		else
			return a.quality < b.quality
		end
	end
	table.sort(self.m_tactics,sortFun)

	self:reloadData()
end


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

local TacticUpgradeView = class("TacticUpgradeView", UiNode)

function TacticUpgradeView:ctor(keyId, formation)
	TacticUpgradeView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_keyId = keyId
	self.m_tactic = TacticsMO.getTacticByKeyId(keyId)
	self.m_formation = formation or {}

	self.m_costList = {} --消耗的战术列表
	self.m_piece_cost = {} --消耗的战术碎片列表
	self.m_isMax = false --默认战术不是最大等级
end

function TacticUpgradeView:onEnter()
	TacticUpgradeView.super.onEnter(self)
	self:setTitle(CommonText[4008])
	self.m_freshHandler = Notify.register(LOCAL_TACTICS_UPDATE, handler(self, self.freshHandler))
	self:showUI(1)
end

function TacticUpgradeView:showUI(pageIndex)

	if not self.container then
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 + container:getContentSize().height / 2)
		self.container = container
	end

	local container = self.container
	self.container:removeAllChildren()


	local tacticBg = display.newSprite("image/tactics/tactic_upgrade_bg.png"):addTo(container)
	tacticBg:setPosition(self:getBg():width() / 2, self:getBg():height() - tacticBg:height() / 2 - 100)

	local tacticDB = TacticsMO.queryTacticById(self.m_tactic.tacticsId)
	local lvInfo = TacticsMO.getLvInfoByLv(tacticDB.quality, self.m_tactic.lv)
	--图标
	local itemView = UiUtil.createItemView(ITEM_KIND_TACTIC, self.m_tactic.tacticsId,{tacticLv = self.m_tactic.lv}):addTo(tacticBg)
	itemView:setScale(0.9)
	itemView:setPosition(tacticBg:width() / 2, tacticBg:height() / 2 + 34)

	local arrow = display.newSprite("image/tactics/tactic_lv_arrow.png"):addTo(tacticBg)
	arrow:setPosition(tacticBg:width() / 2, itemView:y() - 145)

	--等级
	local lv = UiUtil.label("Lv."..self.m_tactic.lv,nil,COLOR[3]):leftTo(arrow, 30)
	local nextlv = UiUtil.label("Lv."..self.m_tactic.lv + 1,nil,COLOR[3]):rightTo(arrow, 30)

	--加成
	local tacticAttr = TacticsMO.getTacticAttrByKeyId(self.m_keyId)
	local attributeData = AttributeBO.getAttributeData(tacticAttr[1][1], tacticAttr[1][2])
	local addAtrr = UiUtil.label(attributeData.name):addTo(tacticBg)
	addAtrr:setAnchorPoint(cc.p(0, 0.5))
	addAtrr:setPosition(tacticBg:width() / 2 - 150, lv:y() - 30)
	local value = UiUtil.label(" + "..attributeData.strValue,nil,COLOR[2]):rightTo(addAtrr)

	--下一级
	local nextArrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(tacticBg)
	nextArrow:setPosition(tacticBg:width() / 2, value:y())
	nextArrow:setRotation(90)
	local nexAttr = TacticsMO.getTacticAttrByKeyId(self.m_keyId, true)
	local nextAttributeData = AttributeBO.getAttributeData(nexAttr[1][1], nexAttr[1][2])
	local nextValue = UiUtil.label(" + "..nextAttributeData.strValue,nil,COLOR[2]):rightTo(nextArrow, 30)

	--升级 or 突破
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local upBtn = MenuButton.new(normal, selected, disabled, handler(self, self.upgradeHandle)):addTo(tacticBg)
	upBtn:setPosition(tacticBg:width() - 100, nextArrow:y() + 13)
	upBtn:setLabel(CommonText[4009][1])
	upBtn.type = 1 --1升级;2突破
	upBtn.exp = self.m_tactic.exp
	upBtn.nextExp = lvInfo.expNeed

	-- 需要突破
	local breakLabe = UiUtil.label(CommonText[4025],nil,COLOR[2]):addTo(tacticBg)
	breakLabe:setPosition(tacticBg:width() / 2 - 50, nextArrow:y() + 13)
	breakLabe:setVisible(false)
	
	if lvInfo.breakOn == 1 and self.m_tactic.state == 0 then
		upBtn.type = 2
		upBtn:setLabel(CommonText[4009][2])
		upBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_19_normal.png"))
		upBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_19_normal.png"))

		--不显示属性
		arrow:setVisible(false)
		lv:setVisible(false)
		nextlv:setVisible(false)
		addAtrr:setVisible(false)
		value:setVisible(false)
		nextArrow:setVisible(false)
		nextValue:setVisible(false)
		breakLabe:setVisible(true)
	end

	--经验条
	local expBar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(tacticBg:width() - 100, 35), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(tacticBg:width() - 100 + 4, 20)}):addTo(container)
	expBar:setPercent(self.m_tactic.exp / lvInfo.expNeed)
	expBar:setLabel(self.m_tactic.exp.."/"..lvInfo.expNeed)
	expBar:setPosition(tacticBg:x(), tacticBg:y() - tacticBg:height() / 2 + 25)
	self.m_expBar = expBar

	local maxLvInfo = TacticsMO.getMaxLvByQuality(tacticDB.quality)
	local maxLv = maxLvInfo[#maxLvInfo].lv
	if self.m_tactic.lv >= maxLv then
		expBar:setLabel("Max")
		expBar:setPercent(1)
		upBtn:setEnabled(false)
		self.m_isMax = true
	end

	local titlebg = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(container)
	titlebg:setPosition(self:getBg():width() / 2, tacticBg:y() - tacticBg:height() / 2 - titlebg:height() / 2)
	local size = cc.size(self:getBg():width() - 10 , self:getBg():height() - titlebg:height() - tacticBg:height() - 160)
	local pages = CommonText[4004]

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height + titlebg:getContentSize().height * 0.5 )
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height + titlebg:getContentSize().height *0.5 )
		end
		button:setLabel(pages[index])
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height + titlebg:getContentSize().height *0.5)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height + titlebg:getContentSize().height *0.5)
		end
		button:setLabel(pages[index], {color = COLOR[11]})

		return button
	end


	--批量选择
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	self.choseBtn = MenuButton.new(normal, selected, nil, handler(self, self.choseHandler)):addTo(container)
	self.choseBtn:setPosition(self:getBg():getContentSize().width / 2 + 210,20)
	self.choseBtn:setLabel(CommonText[4007])


	-- 背景
	local function createDelegate(container, index)
		self:showConsume(container, index)
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate( index )
		return true
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {createDelegate = createDelegate, clickDelegate = clickDelegate, 
		clickBaginDelegate = clickBaginDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback},hideDelete = true}):addTo(container, 2)
	pageView:setAnchorPoint(cc.p(0.5,0))
	pageView:setPosition(self:getBg():width() / 2, 60)
	pageView:setPageIndex(pageIndex)
	self.m_pageView = pageView

	-- local tips = UiUtil.label("长按材料可以快速选择消耗"):addTo(container)
	-- tips:setAnchorPoint(cc.p(0,0.5))
	-- tips:setPosition(40,60)
end

function TacticUpgradeView:choseHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	if self.m_isMax then
		Toast.show(CommonText[4015])
		return
	end

	local dialogFow = self.m_pageView:getPageIndex()
	require("app.dialog.BatchChoseTacticsDialog").new(dialogFow, self.m_keyId, function (list1, list2)
		self:freshHandlerByType(dialogFow)
		if #list1 > 0 then --战术
			for index=1,#list1 do
				local data = list1[index]
				local flag = false
				for k,v in pairs(self.m_costList) do
					if data.keyId == v then
						flag = true
						break
					end
				end
				if not flag then
					self.m_costList[#self.m_costList + 1] = data.keyId
				end
			end
		end

		if #list2 > 0 then --碎片
			for index=1,#list2 do
				local tactic = list2[index]
				local info= {v1 = tactic.tacticsId, v2 = tactic.count}
				local hasExist = false

				if #self.m_piece_cost > 0 then
					for k,v in pairs(self.m_piece_cost or {}) do
						if v.v1 == info.v1 then
							hasExist = true
							v.v2 = info.v2
							break
						end
					end
				end

				if not hasExist then
					self.m_piece_cost[#self.m_piece_cost + 1] = info
				end
			end
		end

		self:showExpBar()
		self.m_pageView:setPageIndex(dialogFow)
	end,self.m_formation):push()
end

function TacticUpgradeView:upgradeHandle(tag,sender)
	ManagerSound.playNormalButtonSound()
	if sender.type == 1 then --升级
		local costTacticList = nil
		local costPieceList = nil
		if #self.m_costList > 0 then
			costTacticList = self.m_costList
		end

		if #self.m_piece_cost > 0 then
			costPieceList = self.m_piece_cost
		end

		if not costTacticList and not costPieceList and sender.exp < sender.nextExp then
			Toast.show(CommonText[4006])
			return
		end
		TacticsBO.onTacticUpgrade(function (data)
			Toast.show(CommonText[585])
		end, costTacticList, costPieceList, self.m_keyId)
	elseif sender.type == 2 then --突破
		require("app.dialog.TacticBreakDialog").new(self.m_keyId):push()
	end
end

function TacticUpgradeView:showConsume(container,index)
	local containerBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	containerBg:setPreferredSize(cc.size(container:width() - 10, container:height() - 10))
	containerBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)

	local viewFor
	if index == 2 then
		viewFor = ITEM_KIND_TACTIC
	elseif index == 1 then
		viewFor = ITEM_KIND_TACTIC_PIECE
	end

	--消耗展示
	local view = TacticConsumeTableView.new(cc.size(containerBg:width() - 10, containerBg:height() - 20), viewFor, self.m_expBar, handler(self, self.onUpCallback), handler(self, self.onReduceCallback),{tacticList = self.m_costList, peceList = self.m_piece_cost}):addTo(containerBg)
	view:setPosition(0,10)
	self.m_tableView = view

	local data = {}
	if index == 1 then --战术碎片
		data = TacticsMO.getConsumeTacticPieces()
	elseif index == 2 then --战术
		data = TacticsMO.getConsumeTactics(self.m_keyId, self.m_formation)
	end
	if #data == 0 then
		self.choseBtn:setVisible(false)
	else
		self.choseBtn:setVisible(true)
	end
	UiUtil.checkScrollNone(self.m_tableView,data)
	self.m_tableView:updateUI(data, self.m_tactic)
end

function TacticUpgradeView:onUpCallback(kind, tacticsId)
	if self.m_isMax then
		Toast.show(CommonText[4015])
		return
	end
	local info = {}
	if kind == ITEM_KIND_TACTIC then
		table.insert(self.m_costList, tacticsId)
	elseif kind == ITEM_KIND_TACTIC_PIECE then
		info = {v1 = tacticsId, v2 = 1}
		local hasExist = false
		if #self.m_piece_cost > 0 then
			for k,v in pairs(self.m_piece_cost or {}) do
				if v.v1 == info.v1 then
					hasExist = true
					v.v2 = v.v2 + info.v2
					break
				end
			end
		end

		if not hasExist then
			self.m_piece_cost[#self.m_piece_cost + 1] = info
		end
	end

	self:showExpBar()
end

function TacticUpgradeView:onReduceCallback(kind,tacticsId)
	if self.m_isMax then return end

	if kind == ITEM_KIND_TACTIC then
		for index=1,#self.m_costList do
			if self.m_costList[index] and self.m_costList[index] == tacticsId then
				table.remove(self.m_costList,index)
			end
		end
	elseif kind == ITEM_KIND_TACTIC_PIECE then
		info = {v1 = tacticsId, v2 = 1}
		for k,v in pairs(self.m_piece_cost) do
			if v.v1 == tacticsId then
				v.v2 = v.v2 - info.v2
				break
			end
		end

		local info = {}
		for index=1,#self.m_piece_cost do
			if self.m_piece_cost[index].v2 and self.m_piece_cost[index].v2 ~= 0 then
				info[#info + 1] = self.m_piece_cost[index]
			end
		end

		self.m_piece_cost = info
	end
	self:showExpBar()
end

function TacticUpgradeView:showExpBar()
	--战术加的总经验
	local tacticsExp = 0
	if #self.m_costList > 0 then
		for index=1,#self.m_costList do
			local exp = TacticsMO.getOfferExpByKeyId(self.m_costList[index])
			tacticsExp = tacticsExp + exp
		end
	end

	--战术碎片加的总经验
	local piecesExp = 0
	if #self.m_piece_cost > 0 then
		for idx=1,#self.m_piece_cost do
			local tacticDB = TacticsMO.queryTacticById(self.m_piece_cost[idx].v1)
			local expIndex = tacticDB.chipExpOffer * self.m_piece_cost[idx].v2
			piecesExp = piecesExp + expIndex
		end
	end

	local totalExp = tacticsExp + piecesExp + self.m_tactic.exp
	local tacticDB = TacticsMO.queryTacticById(self.m_tactic.tacticsId)
	local lvInfo = TacticsMO.getLvInfoByLv(tacticDB.quality, self.m_tactic.lv)

	self.m_expBar:setPercent(totalExp / lvInfo.expNeed)
	self.m_expBar:setLabel(totalExp.."/"..lvInfo.expNeed)
end

function TacticUpgradeView:freshHandler()
	self.m_tactic = TacticsMO.getTacticByKeyId(self.m_keyId)
	self.m_costList = {} --消耗的战术列表
	self.m_piece_cost = {} --消耗的战术碎片列表
	local pageIndex = self.m_pageView:getPageIndex()
	self:showUI(pageIndex)
end


function TacticUpgradeView:freshHandlerByType(mtype)
	self.m_tactic = TacticsMO.getTacticByKeyId(self.m_keyId)
	if mtype == 1 then
		self.m_piece_cost = {} --消耗的战术碎片列表
	else
		self.m_costList = {} --消耗的战术列表
	end
	local pageIndex = self.m_pageView:getPageIndex()
	self:showUI(pageIndex)
end


function TacticUpgradeView:onExit()
	TacticUpgradeView.super.onExit(self)
	if self.m_freshHandler then
		Notify.unregister(self.m_freshHandler)
		self.m_freshHandler = nil
	end
end

return TacticUpgradeView