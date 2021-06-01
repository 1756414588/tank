--
-- Author: Your Name
-- Date: 2017-09-25 15:58:09
--

local TradeTableView = class("TradeTableView", TableView)

function TradeTableView:ctor(size, param)
	TradeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_param = param
	self.m_cellSize = cc.size(size.width, 140)
	self.m_quinn = PbProtocol.decodeArray(self.m_param["quinn"])

end

function TradeTableView:onEnter()
	TradeTableView.super.onEnter(self)
	armature_add("animation/effect/canmoubu_rongyaozhixing.pvr.ccz", "animation/effect/canmoubu_rongyaozhixing.plist", "animation/effect/canmoubu_rongyaozhixing.xml")
	self:backStates(self.m_param)
end

function TradeTableView:numberOfCells()
	return #self.m_quinn
end

function TradeTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function TradeTableView:createCellAtIndex(cell,index)
	TradeTableView.super.createCellAtIndex(self, cell, index)
	local quinn = PbProtocol.decodeArray(self.m_param["quinn"])[index]
	local awards = PbProtocol.decodeArray(self.m_param["award"])
	local cellBg
	if index > 3 then
		cellBg = display.newSprite(IMAGE_COMMON .. "info_bg_100.png"):addTo(cell)
	else
		cellBg = display.newSprite(IMAGE_COMMON .. "info_bg_93.png"):addTo(cell)
	end
	cellBg:setPosition(self.m_cellSize.width + 310,self.m_cellSize.height / 2)
	local mt = cc.MoveTo:create(0.1*index, cc.p(self.m_cellSize.width / 2,self.m_cellSize.height / 2))
	if self.isrun[index] then
		self.isrun[index] = false
		cellBg:runAction(transition.sequence({mt,cc.DelayTime:create(0.1*(4 -index) + 0.2),cc.CallFunc:create(function ()
					if table.isexist(self.m_param,"award") and index == #self.m_quinn then
						require("app.dialog.HyperspaceAwardDialog").new(awards):push()
					end
					local armature = armature_create("canmoubu_rongyaozhixing",cellBg:width() / 2,cellBg:height() / 2 + 8,function (movementType, movementID, armature)
						-- if movementType == MovementEventType.COMPLETE then
						-- end
					end)
					armature:addTo(cellBg,999)
					armature:getAnimation():playWithIndex(0)
					armature:runAction(cc.RepeatForever:create(transition.sequence({cc.DelayTime:create(5),
						cc.CallFuncN:create(function(sender) sender:getAnimation():playWithIndex(0) end)})))
		end)}))
	else
		cellBg:setPosition(self.m_cellSize.width / 2,self.m_cellSize.height / 2)
	end
	
	if quinn.dis ~= 10 then
		local discout = display.newSprite(IMAGE_COMMON .. "discount_"..quinn.dis..".png"):addTo(cellBg)
		discout:setPosition(cellBg:width() + 8,cellBg:height())
		discout:setAnchorPoint(cc.p(1,1))
	end

	local itemView = UiUtil.createItemView(quinn.type, quinn.id,{count = quinn.count}):addTo(cellBg)
	itemView:setPosition(itemView:width() / 2 + 20,cellBg:height() / 2)
	UiUtil.createItemDetailButton(itemView)

	local resData = UserMO.getResourceData(quinn.type, quinn.id)
	local name = UiUtil.label(resData.name,FONT_SIZE_MEDIUM,cc.c3b(30,230,255),nil,ui.TEXT_ALIGN_LEFT):addTo(cellBg)
	name:setPosition(itemView:x() + itemView:width() / 2 + 20,cellBg:height() - 35)
	name:setAnchorPoint(cc.p(0,0.5))

	local desc = UiUtil.label(resData.desc,nil,nil,cc.size(270,0),ui.TEXT_ALIGN_LEFT):addTo(cellBg)
	desc:setPosition(itemView:x() + itemView:width() / 2 + 20,cellBg:height() - 80)
	desc:setAnchorPoint(cc.p(0,0.5))

	-- 购买按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onBuyBack)):addTo(cellBg)
	btn:setPosition(self.m_cellSize.width - 120, self.m_cellSize.height - btn:height() / 2 - 20)
	btn:setLabel(CommonText[119])
	btn:setVisible(quinn.sold == 0)
	btn.index = index
	btn.price = quinn.price

	--售罄
	local chus = display.newSprite(IMAGE_COMMON.."chus.png"):addTo(cellBg)
	chus:setPosition(btn:getPosition())
	chus:setVisible(quinn.sold == 1)
	btn.chus = chus

	local icon = display.newSprite(IMAGE_COMMON.."icon_coin.png"):addTo(cellBg)
	icon:setPosition(btn:x() - 40,btn:y() - btn:height() / 2 - 10)

	local price = UiUtil.label(quinn.price,FONT_SIZE_TINY,COLOR[12],nil,ui.TEXT_ALIGN_LEFT):rightTo(icon)

	cell.cellBg = cellBg
	return cell
end

function TradeTableView:onBuyBack(tag,sender)
	ManagerSound.playNormalButtonSound()
	local count = UserMO.getResource(ITEM_KIND_COIN)
	local need = sender.price
	if need > count or self.m_settingNum == 0 then -- 金币不足
		require("app.dialog.CoinTipDialog").new():push()
		return
	end
	local index = sender.index
	local function gotoBuy()
		ActivityCenterBO.HyperSpaceBuy(function (data)
			sender:setVisible(false)
			sender.chus:setVisible(true)
			if table.isexist(data,"eggs") then
				local awards = PbProtocol.decodeArray(data["eggs"])
				require("app.dialog.HyperspaceAwardDialog").new(awards):push()
			end
		end,index)
	end
	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1757], need), function()
			gotoBuy()
		 end):push()
	else
		gotoBuy()
	end
end

function TradeTableView:backStates(data)
	self.isrun = {}
	self.m_param = data
	for index = 1 ,4 do
		self.isrun[#self.isrun + 1] = true
	end
	self:reloadData()
end

function TradeTableView:backPos()
	for index = 1, self:numberOfCells() do
		local cell = self:cellAtIndex(index)
		if cell then
			cell.cellBg:setPosition(self.m_cellSize.width + 310,self.m_cellSize.height / 2)
		end
	end
end


function TradeTableView:onExit()
	TradeTableView.super.onExit(self)
	armature_remove("animation/effect/canmoubu_rongyaozhixing.pvr.ccz", "animation/effect/canmoubu_rongyaozhixing.plist", "animation/effect/canmoubu_rongyaozhixing.xml")
end

----------------------------------------------------------------------------------------------------------
HYPERSPACE_FRESH_NORMAL = 1
HYPERSPACE_FRESH_EXC    = 2
HYPERSPACE_FRESH_AWARD  = 3

local ActivityHyperSpaceView = class("ActivityHyperSpaceView", UiNode)

function ActivityHyperSpaceView:ctor(activity)
	ActivityHyperSpaceView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity

	self.m_pageIndex = 1
end

function ActivityHyperSpaceView:onEnter()
	ActivityHyperSpaceView.super.onEnter(self)
	self:hasCoinButton(true)
	armature_add("animation/effect/canmoubu_dian.pvr.ccz", "animation/effect/canmoubu_dian.plist", "animation/effect/canmoubu_dian.xml")
	armature_add("animation/effect/canmoubu_shuaxin.pvr.ccz", "animation/effect/canmoubu_shuaxin.plist", "animation/effect/canmoubu_shuaxin.xml")
	armature_add("animation/effect/canmoubu_shuaxingaoji.pvr.ccz", "animation/effect/canmoubu_shuaxingaoji.plist", "animation/effect/canmoubu_shuaxingaoji.xml")

	self:setTitle(CommonText[1743])
	local normal = display.newSprite(IMAGE_COMMON .. "btn_39_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_39_selected.png")
	local btn = MenuButton.new(normal, selected, nil, function ()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		  DetailTextDialog.new(DetailText.hyperSpace):push()
	end):addTo(self:getBg(),999)
	btn:setPosition(self:getBg():width() - 55,self:getBg():height() - 125)

	local chance = ActivityCenterMO.getProbabilityTextById(self.m_activity.activityId, self.m_activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(self:getBg(),999)
		chanceBtn:setPosition(self:getBg():width() - 155,self:getBg():height() - 125)
		chanceBtn:setVisible(chance.open == 1)
	end

	self:showUI()
end

function ActivityHyperSpaceView:showUI()
	local function createDelegate(container, index)
		if index == 1 then  -- 贸易
				self:showTrade(container)
		elseif index == 2 then -- 兑换
			ActivityCenterBO.FreshHyperSpace(function(data)
						self.m_data = data
						self:showExchange(container)
					end,index,0)
		end
	end

	local function clickDelegate(container, index)
	end

	--  贸易。兑换
	local pages = CommonText[1744]
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView
	pageView:setPageIndex(self.m_pageIndex)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)


end

function ActivityHyperSpaceView:showTrade(container)
	self.m_isnexFresh = false
	local index = self.m_pageView:getPageIndex()
	local rect = cc.rect(0, 0, container:width(), container:height() - 5)
	local node = display.newClippingRegionNode(rect):addTo(container,999)
	local up = display.newSprite(IMAGE_COMMON .. "door_up.png"):addTo(node)
	up:setPosition(container:width() / 2,container:height())
	up:setAnchorPoint(cc.p(0.5,1))

	local down = display.newSprite(IMAGE_COMMON .. "door_down.png"):addTo(container,999)
	down:setPosition(container:width() / 2,container:height() - up:height() + 40)
	down:setAnchorPoint(cc.p(0.5,1))

	local function upAction()
		local act1 = cc.MoveTo:create(0.3, cc.p(node:width() / 2,container:height() + 360))
		local act2 = cc.MoveTo:create(0.3, cc.p(container:width() / 2,40))
		up:runAction(act1)
		down:runAction(act2)
	end

	local function runAct()
		local act1 = cc.MoveTo:create(0.3, cc.p(container:width() / 2,container:height()))
		local act2 = cc.MoveTo:create(0.3, cc.p(container:width() / 2,container:height() - up:height() + 40))
		local rever1 = cc.MoveTo:create(0.3, cc.p(container:width() / 2,container:height() + 360))
		local rever2 = cc.MoveTo:create(0.3, cc.p(container:width() / 2,40))
		local mb1 = cc.MoveBy:create(0.05, cc.p(-5,0))
		local mb2 = cc.MoveBy:create(0.05, cc.p(8,0))
		local mb3 = cc.MoveBy:create(0.05, cc.p(-5,0))
		local mb4 = cc.MoveBy:create(0.05, cc.p(2,0))
		up:runAction(transition.sequence({act1,cc.DelayTime:create(0.5),rever1}))
		container:runAction(transition.sequence({cc.DelayTime:create(0.3),mb1,mb2,mb3,mb4}))
		down:runAction(transition.sequence({act2,
			cc.CallFuncN:create(function(sender)
					self.m_tableView:backPos()
					local armature = armature_create("canmoubu_dian", container:getContentSize().width / 2, container:height() - up:height() + 30)
					armature:getAnimation():playWithIndex(0)
					armature:addTo(container,1000)
		end),cc.DelayTime:create(0.5),rever2,cc.CallFuncN:create(function ()
			self.m_tableView:backStates(self.m_data)
		end),cc.DelayTime:create(0.6),cc.CallFuncN:create(function ()
			if self.opacityLayer then self:removeChild(self.opacityLayer, true) end
		end)}))
	end

	local function loadinfo()
		local function frshUI()
			if self.m_contentNode and self.m_isnexFresh then
				self.m_contentNode:removeSelf()
				self.m_contentNode = nil
			end

			local myContainer = display.newNode():addTo(container)
			myContainer:setContentSize(self:getBg():getContentSize())
			self.m_contentNode = myContainer

			if self.m_data.getType ~= 1 then
				self.timeUp:setVisible(true)
				self.reSet:setVisible(true)
			end

			if self.m_data.getType == 1 then
				local time = ui.newTTFLabel({text = CommonText[1746]..":", font = G_FONT, size = FONT_SIZE_TINY, x = container:width() / 2, y = 40, align = ui.TEXT_ALIGN_CENTER}):addTo(myContainer)
				local m_time = UiUtil.label(self.m_data.getNumber):rightTo(time)
			elseif self.m_data.getType == 2 then
				local lab = ui.newTTFLabel({text = CommonText[1752][1], font = G_FONT, size = FONT_SIZE_TINY, x = container:width() / 2, y = 40, align = ui.TEXT_ALIGN_CENTER}):addTo(myContainer)
				local icon = display.newSprite("image/item/p_refresh_small.png"):rightTo(lab)
				local fresh = UiUtil.label(self.m_data.hasRefreshes):rightTo(icon)
			else
				local lab = ui.newTTFLabel({text = CommonText[1752][2], font = G_FONT, size = FONT_SIZE_TINY, x = container:width() / 2 - 30, y = 40, align = ui.TEXT_ALIGN_CENTER}):addTo(myContainer)
				local icon = display.newSprite(IMAGE_COMMON.."icon_coin.png"):rightTo(lab)
				local cost = UiUtil.label(self.m_data.getPrice):rightTo(icon)
			end
		end

		local function refresh()
			local opacityLayer = self:createOpacityLayer()
			self:addChild(opacityLayer,999)
			self.opacityLayer = opacityLayer
			nodeTouchEventProtocol(opacityLayer, function(event)  
	                end, nil, true, true)
			local index = self.m_pageView:getPageIndex()
			ActivityCenterBO.FreshHyperSpace(function (data)
				self.m_data = data
				self.m_isnexFresh = true
				frshUI()
				runAct()
			end,index,1)
		end

		local function freshCallBack()
			if self.m_data.getType == 3 then
				local count = UserMO.getResource(ITEM_KIND_COIN)
				local need = self.m_data.getPrice
				if need > count or self.m_settingNum == 0 then -- 金币不足
					require("app.dialog.CoinTipDialog").new(CommonText[1755]):push()
					return
				else
					if UserMO.consumeConfirm then
						local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
						CoinConfirmDialog.new(string.format(CommonText[1747][3],need), function() 
	
						refresh() end):push()
					else
	
						refresh()
					end
				end
			else
				if ActivityCenterMO.HysperTip_ then
					local FreshConfirmDialog = require("app.dialog.FreshConfirmDialog")
					FreshConfirmDialog.new(HYPERSPACE_FRESH_NORMAL,CommonText[1747][1], function()
	
					refresh() end):push()
				else

					refresh()
				end
			end
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
		local freshButton = MenuButton.new(normal, selected, nil, freshCallBack):addTo(container)
		freshButton:setPosition(container:width() / 2, 110)
		freshButton:setLabel(CommonText[1745])
		self.m_freshButton = freshButton

		--重置免费次数
		self.timeUp =  ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):rightTo(freshButton)
		self.timeUp:setVisible(false)
		self.reSet = ui.newTTFLabel({text = CommonText[1756], font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):rightTo(self.timeUp,80)
		self.reSet:setVisible(false)
		self.m_tickHandler = ManagerTimer.addTickListener(handler(self, self.update))
		self:update()

		frshUI()
		local tableView = TradeTableView.new(cc.size(container:width() - 20,container:height() - 210),self.m_data):addTo(container,99)
		tableView:setPosition(10,container:height() -  60)
		tableView:setAnchorPoint(cc.p(0,1))
		self.m_tableView = tableView

	end

	ActivityCenterBO.FreshHyperSpace(function(data)
				self.m_data = data
				loadinfo()
				upAction()
	end,index,0)
end

function ActivityHyperSpaceView:showExchange(container)
	if self.m_tickHandler then
		ManagerTimer.removeTickListener(self.m_tickHandler)
		self.m_tickHandler = nil
	end
	self.is_handFresh = false
	self.isTouching = false
	local quinn = PbProtocol.decodeArray(self.m_data["quinn"])[1]
	local myStar = UiUtil.label(CommonText[1748],FONT_SIZE_TINY,nil,nil,ui.TEXT_ALIGN_LEFT):addTo(container)
	myStar:setPosition(20,container:height() - 30)
	myStar:setAnchorPoint(cc.p(0,0.5))
	--我的荣耀之星
	self.my_start = self.m_data.hasStars
	if self.my_start <= 0 then
		self.my_start = 0
	end
	local icon = display.newSprite("image/item/p_force_small.png"):rightTo(myStar)
	self.mstar_num = UiUtil.label(self.my_start,nil,COLOR[12]):rightTo(icon)
	--我的刷新券
	local lab = ui.newTTFLabel({text = CommonText[1752][1], font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):rightTo(self.mstar_num,100)
	local fresfIcon = display.newSprite("image/item/p_refresh_small.png"):rightTo(lab)
	self.m_freshNum = UiUtil.label(self.m_data.hasRefreshes):rightTo(fresfIcon)

	local infoBg = display.newSprite(IMAGE_COMMON .. "info_bg_97.jpg"):addTo(container)
	infoBg:setPosition(container:width() / 2,myStar:y() - infoBg:height() / 2 - 60)

	infoBg:setTouchEnabled(true)
	infoBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			if self.isTouching then
				return false
			end
			self.m_benganX = event.x
			return true
		elseif event.name == "moved" then
		elseif event.name == "ended" then
			local dis = math.abs(event.x - self.m_benganX)
			if dis >= 30 then
				self:FreshAwardCallBack()
			end
		end
	end)

	local fame = display.newSprite(IMAGE_COMMON .. "fame_bg_1.png"):addTo(infoBg):center()
	local function freshItem()
		local quinn = PbProtocol.decodeArray(self.m_data["quinn"])[1]
		if self.is_handFresh and self.m_itemView then
			self.m_itemView:removeFromParent()
			self.m_itemView = nil
		end
		local itemView = UiUtil.createItemView(quinn.type, quinn.id,{count = quinn.count}):addTo(fame)
		itemView:setPosition(fame:width() / 2,fame:height() / 2 - 25)
		UiUtil.createItemDetailButton(itemView)
		self.m_itemView = itemView
		if self.is_handFresh then
			itemView:setScale(0)
			itemView:runAction(cc.ScaleTo:create(0.5,1))
		end
	end
	freshItem()
	self.armature1 = armature_create("canmoubu_shuaxingaoji",infoBg:width() / 2,infoBg:height() - 50,function (movementType, movementID, armature)
		if movementType == MovementEventType.START then
			freshItem()
		elseif movementType == MovementEventType.COMPLETE then
			if self.bgMask then self:removeChild(self.bgMask, true) end
			self.isTouching = false
			if self.btn then
				self.btn:setEnabled(true)
			end
			if table.isexist(self.m_data,"award") then
				local awards = PbProtocol.decodeArray(self.m_data["award"])
				require("app.dialog.HyperspaceAwardDialog").new(awards):push()
			end
		end
	end):addTo(infoBg,999)
	self.armature2 = armature_create("canmoubu_shuaxin",infoBg:width() / 2,infoBg:height() - 50,function (movementType, movementID, armature)
		if movementType == MovementEventType.START then
			freshItem()
		elseif movementType == MovementEventType.COMPLETE then
			if self.bgMask then self:removeChild(self.bgMask, true) end
			self.isTouching = false
			if self.btn then
				self.btn:setEnabled(true)
			end
			if table.isexist(self.m_data,"award") then
				local awards = PbProtocol.decodeArray(self.m_data["award"])
				require("app.dialog.HyperspaceAwardDialog").new(awards):push()
			end
		end
	end):addTo(infoBg,999)

	--刷新消耗
	local consume = UiUtil.label(CommonText[1758][1]):addTo(infoBg)
	consume:setPosition(infoBg:width() / 2 - 90,30)
	local fresfIcon = display.newSprite("image/item/p_refresh_small.png"):rightTo(consume)
	local consumeNum = UiUtil.label("1"):rightTo(fresfIcon)
	local consumeCoin = UiUtil.label(CommonText[1758][2]):rightTo(consumeNum)
	local consumeIcon = display.newSprite(IMAGE_COMMON.."icon_coin.png"):rightTo(consumeCoin)
	local costCionNum = UiUtil.label("50"):rightTo(consumeIcon)


	local topBg = display.newSprite(IMAGE_COMMON .. "info_bg_98.png"):addTo(container)
	topBg:setPosition(container:width() / 2,myStar:y() - 60)

	local titleBg = display.newSprite(IMAGE_COMMON .. "title_bg_2.png"):addTo(container)
	titleBg:setPosition(container:width() / 2,infoBg:y() - infoBg:height() / 2 - titleBg:height() / 2 + 10)

	local cost = UiUtil.label(CommonText[1749],nil,COLOR[12],nil,ui.TEXT_ALIGN_LEFT):addTo(titleBg)
	cost:setPosition(titleBg:width() / 2 - 100,titleBg:height() / 2 + 10)
	cost:setAnchorPoint(cc.p(0,0.5))
	local icon2 = display.newSprite("image/item/p_force_small.png"):rightTo(cost)
	self.costNum = UiUtil.label(quinn.price,nil,COLOR[12]):rightTo(icon2)

	--兑换按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	self.btn = MenuButton.new(normal, selected, disabled, handler(self, self.recruitBack)):addTo(container)
	self.btn:setPosition(container:width() / 2, self.btn:height())
	self.btn:setLabel(CommonText[294])
	self.btn:setEnabled(quinn.sold == 0)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png")
	normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png")
	selected:setScale(-1)
	local lastBtn = MenuButton.new(normal, selected, nil, handler(self, self.FreshAwardCallBack)):addTo(container)
	lastBtn:setPosition(80, infoBg:y() - 20)
	lastBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(-20, 0)), cc.MoveBy:create(2, cc.p(20, 0))})))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, handler(self, self.FreshAwardCallBack)):addTo(container)
	nxtBtn:setPosition(container:getContentSize().width - 80, infoBg:y() - 20)
	nxtBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(20, 0)), cc.MoveBy:create(2, cc.p(-20, 0))})))

	if table.isexist(self.m_data,"award") then
		local awards = PbProtocol.decodeArray(self.m_data["award"])
		require("app.dialog.HyperspaceAwardDialog").new(awards):push()
	end
end

function ActivityHyperSpaceView:FreshAwardCallBack(tag,sender)
	ManagerSound.playNormalButtonSound()
	local index = self.m_pageView:getPageIndex()
	local function fresh()
		self.isTouching = true
		-- --透明遮罩
		local bgMask = self:createOpacityLayer()
		self:addChild(bgMask,999)
		self.bgMask = bgMask
		nodeTouchEventProtocol(bgMask, function(event)  
                end, nil, true, true)

		ActivityCenterBO.FreshHyperSpace(function (data)
			self.is_handFresh = true
			self.m_data = data
			local quinn = PbProtocol.decodeArray(self.m_data["quinn"])[1]
			self.m_freshNum:setString(self.m_data.hasRefreshes)
			self.costNum:setString(quinn.price)
			if self.m_itemView then
				self.m_itemView:removeFromParent()
				self.m_itemView = nil
			end
			if quinn.especial == 1 then
				self.armature = self.armature1
			else
				self.armature = self.armature2
			end
			self.armature:getAnimation():playWithIndex(0)
		end,index,1)
	end
	if self.m_data.getType == 3 then
		local count = UserMO.getResource(ITEM_KIND_COIN)
		local need = self.m_data.getPrice
		if need > count or self.m_settingNum == 0 then -- 金币不足
			require("app.dialog.CoinTipDialog").new(CommonText[1755]):push()
			return
		else
			if UserMO.consumeConfirm then
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText[1747][3],need), function() fresh() end):push()
			else
				fresh()
			end
		end
	else
		if ActivityCenterMO.HysperExcTip_ then
			local FreshConfirmDialog = require("app.dialog.FreshConfirmDialog")
			FreshConfirmDialog.new(HYPERSPACE_FRESH_EXC,CommonText[1747][1], function() fresh() end):push()
		else
			fresh()
		end
	end
end

function ActivityHyperSpaceView:createOpacityLayer()
	--透明遮罩
	local rect = CCRectMake(0, 0, GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT)
	local bgMask = CCSprite:create("image/common/bg_ui.jpg", rect)
	bgMask:setCascadeBoundingBox(rect)
	bgMask:setColor(ccc3(0, 0, 0))
	bgMask:setOpacity(0)
	bgMask:setPosition(GAME_SIZE_WIDTH / 2, GAME_SIZE_HEIGHT / 2)
	return bgMask
end

function ActivityHyperSpaceView:recruitBack(tag,sender)
	ManagerSound.playNormalButtonSound()
	local index = 100 --写死。为兑换
	local price = PbProtocol.decodeArray(self.m_data["quinn"])[1].price
	local own =  self.my_start
	if price > own then
		Toast.show(CommonText[1754])
		return
	end
	local function exchange()
		ActivityCenterBO.HyperSpaceBuy(function (data)
				self.my_start = data.hasMoney
				self.mstar_num:setString(data.hasMoney)
				self.btn:setEnabled(false)
		end,index)
	end

	if ActivityCenterMO.HysperExchange_ then
		local FreshConfirmDialog = require("app.dialog.FreshConfirmDialog")
		FreshConfirmDialog.new(HYPERSPACE_FRESH_AWARD,string.format(CommonText[1747][2],price), function() exchange() end):push()
	else
		exchange()
	end
end

function ActivityHyperSpaceView:update(dt)
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = os.date("%H", t)
	local m = os.date("%M", t) / 60
	local s = os.date("%S", t) / 3600
	local now = h + m + s
	local leftTime = (24 - now) * 3600
	if leftTime == 0 and self.m_pageView:getPageIndex() == 1 then
		if self.timeUp then
			self.timeUp:setVisible(false)
			self.reSet:setVisible(false)
			if self.m_tickHandler then
				ManagerTimer.removeTickListener(self.m_tickHandler)
				self.m_tickHandler = nil
			end
		end
	else
		local time = ManagerTimer.time(leftTime)
		if self.timeUp and self.m_pageView:getPageIndex() == 1 then
			self.timeUp:setString(string.format("%02d:%02d:%02d", time.hour,time.minute, time.second))
		end
	end
end

function ActivityHyperSpaceView:onExit()
	ActivityHyperSpaceView.super.onExit(self)
	if self.m_tickHandler then
		ManagerTimer.removeTickListener(self.m_tickHandler)
		self.m_tickHandler = nil
	end
	armature_remove("animation/effect/canmoubu_dian.pvr.ccz", "animation/effect/canmoubu_dian.plist", "animation/effect/canmoubu_dian.xml")
	armature_remove("animation/effect/canmoubu_shuaxin.pvr.ccz", "animation/effect/canmoubu_shuaxin.plist", "animation/effect/canmoubu_shuaxin.xml")
	armature_remove("animation/effect/canmoubu_shuaxingaoji.pvr.ccz", "animation/effect/canmoubu_shuaxingaoji.plist", "animation/effect/canmoubu_shuaxingaoji.xml")
end

return ActivityHyperSpaceView