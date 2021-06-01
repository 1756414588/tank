--
-- 勋章活跃性活动
--
--
--------------------------
local LOCAL_ACTION_RAD = 15 -- 偏离角度
local LOCAL_ACTION_WHOLE_RAD = 180 
--------------------------------------------------------------
--					勋章活动 - 奖励一览界面					--
--------------------------------------------------------------
local MedalAwardTableView = class("MedalAwardTableView", TableView)

function MedalAwardTableView:ctor(size,awardId)
	MedalAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 190)
	self.awardId = awardId
	self.dataList = {}
end

function MedalAwardTableView:onEnter()
	MedalAwardTableView.super.onEnter(self)
	self.dataList = ActivityCenterMO.getRankDataById(self.awardId)
end

function MedalAwardTableView:numberOfCells()
	return #self.dataList
end

function MedalAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MedalAwardTableView:createCellAtIndex(cell, index)
	MedalAwardTableView.super.createCellAtIndex(self, cell, index)

	local _dataInfo = self.dataList[index]
	-- info_bg_12
	local title = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
	title:setAnchorPoint(cc.p(0,1))
	title:setPosition(10 ,self.m_cellSize.height)

	local numberStr = ""
	if _dataInfo.rank == _dataInfo.rankEd then
		numberStr = CommonText[237][1] .. _dataInfo.rank .. CommonText[237][7]
	else
		numberStr = CommonText[237][1] .. _dataInfo.rank .. "-" .. _dataInfo.rankEd .. CommonText[237][7]
	end
	-- 名次
	local lb_number = ui.newTTFLabel({text = numberStr , font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(title)
	lb_number:setAnchorPoint(cc.p(0,0.5))
	lb_number:setPosition(title:width() * 0.2 , title:height() * 0.5)

	local awards = json.decode(_dataInfo.awardList)
	local strList = string.split(_dataInfo.desc,"，")

	for index = 1 , #awards do
		local award = awards[index]
		local item = UiUtil.createItemView(award[1], award[2], { count = award[3]}):addTo(cell)
		item:setPosition(20 + item:width() * 0.5 + (index - 1) * item:width() * 1.2, title:y() - title:height() - item:height() * 0.6)

		UiUtil.createItemDetailButton(item)
		local lb_name = ui.newTTFLabel({text = strList[index] or "" , font = G_FONT, size = 18, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(cell)
		lb_name:setAnchorPoint(cc.p(0.5,0.5))
		lb_name:setPosition(item:x() , item:y() - item:height() * 0.5 - lb_name:height() * 0.5 - 5)
	end

	return cell
end

--------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local MedalAwardDialog = class("MedalAwardDialog", Dialog)

function MedalAwardDialog:ctor(awardId)
	MedalAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.m_awardId = awardId
end

function MedalAwardDialog:onEnter()
	MedalAwardDialog.super.onEnter(self)
	
	self:setTitle(CommonText[771])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 60))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 45 - tableBg:getContentSize().height / 2)

	local view = MedalAwardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),self.m_awardId):addTo(tableBg)
	view:setPosition(0, 10)
	view:reloadData()
end

--------------------------------------------------------------
--					勋章活动 - 排行榜界面					--
--------------------------------------------------------------

local MedalRankTableView = class("MedalRankTableView", TableView)

function MedalRankTableView:ctor(size)
	MedalRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 90)
	self.converDataList = {}
end

function MedalRankTableView:onEnter()
	MedalRankTableView.super.onEnter(self)
	-- local topbg = display.newSprite(IMAGE_COMMON .. "btn_2.png"):addTo(self)
	-- topbg:setAnchorPoint(cc.p(0,0))
	-- topbg:setPosition(0, 0)

	-- local topbg = display.newSprite(IMAGE_COMMON .. "btn_2.png"):addTo(self)
	-- topbg:setAnchorPoint(cc.p(1,1))
	-- topbg:setPosition(self.m_viewSize.width, self.m_viewSize.height)

	-- local topbg = display.newSprite(IMAGE_COMMON .. "btn_2.png"):addTo(self)
	-- topbg:setAnchorPoint(cc.p(0,1))
	-- topbg:setPosition(0, self.m_viewSize.height)
end

function MedalRankTableView:numberOfCells()
	return #self.converDataList
end

function MedalRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MedalRankTableView:createCellAtIndex(cell, index)
	MedalRankTableView.super.createCellAtIndex(self, cell, index)

	local rankdata = self.converDataList[index]

	local _color = cc.c3b(255, 255, 255)
	if index == 1 then
		_color = cc.c3b(170, 52, 53)
	elseif index == 2 then
		_color = cc.c3b(166, 149, 80)
	elseif index == 3 then
		_color = cc.c3b(157, 21, 152)
	end

	-- 排名
	local lb_ranknumber = ui.newTTFLabel({text = index , font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = _color}):addTo(cell)
	lb_ranknumber:setAnchorPoint(cc.p(0.5,0.5))
	lb_ranknumber:setPosition(self.m_cellSize.width * 0.1 , self.m_cellSize.height * 0.5)

	-- 角色名
	local lb_rankname = ui.newTTFLabel({text = rankdata.nick , font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = _color}):addTo(cell)
	lb_rankname:setAnchorPoint(cc.p(0.5,0.5))
	lb_rankname:setPosition(self.m_cellSize.width * 0.45 , self.m_cellSize.height * 0.5)

	-- 吃鸡数
	local lb_rankvalue = ui.newTTFLabel({text = rankdata.rankValue , font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = _color}):addTo(cell)
	lb_rankvalue:setAnchorPoint(cc.p(0.5,0.5))
	lb_rankvalue:setPosition(self.m_cellSize.width * 0.85 , self.m_cellSize.height * 0.5)

	-- line
	local line = display.newSprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setScaleX(25)
	line:setPosition(self.m_cellSize.width * 0.5 ,0)

	return cell
end


function MedalRankTableView:doReloadData(data)
	self.converDataList = data
	self:reloadData()
end















--------------------------------------------------------------
--					勋章活动 - 兑换界面						--
--------------------------------------------------------------
local MedalConvertibilityTableView = class("MedalConvertibilityTableView", TableView)

function MedalConvertibilityTableView:ctor(size,coinCallback)
	MedalConvertibilityTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)
	self.coinCallback = coinCallback
end

function MedalConvertibilityTableView:onEnter()
	MedalConvertibilityTableView.super.onEnter(self)
	self.converDataList = ActivityCenterMO.getActivityMedalRule()
	local function qualitySort(a,b)
		if a.quality == b.quality then
			return a.cost < b.cost
		else
			return a.quality < b.quality
		end
	end
	table.sort(self.converDataList, qualitySort)
	self:reloadData()
end

function MedalConvertibilityTableView:numberOfCells()
	return #self.converDataList
end

function MedalConvertibilityTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MedalConvertibilityTableView:createCellAtIndex(cell, index)
	MedalConvertibilityTableView.super.createCellAtIndex(self, cell, index)

	local _data = self.converDataList[index]

	-- info_bg_26.png
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 10, self.m_cellSize.height - 4))
	bg:setAnchorPoint(cc.p(0.5,0.5))
	bg:setPosition(self.m_cellSize.width * 0.5 , self.m_cellSize.height * 0.5)

	local _itemdata = json.decode(_data.awards)
	local item = UiUtil.createItemView(_itemdata[1],_itemdata[2]):addTo(cell)
	item:setAnchorPoint(cc.p(0.5,0.5))
	item:setPosition( item:width() , self.m_cellSize.height * 0.5)
	UiUtil.createItemDetailButton(item)

	local lbname = ui.newTTFLabel({text = _data.name, font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = COLOR[_data.quality]}):addTo(cell)
	lbname:setAnchorPoint(cc.p(0,0.5))
	lbname:setPosition( item:x() + item:width() * 0.75 , self.m_cellSize.height - 27.5)

	-- 兑换
	local btn = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", "btn_9_disabled.png",handler(self,self.btncallback),CommonText[294]):addTo(cell)
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(self.m_cellSize.width - btn:width() * 0.7 , self.m_cellSize.height * 0.5)
	btn.index = index
	btn.kind = _itemdata[1]
	btn.id = _itemdata[2]

	local _width = btn:x() - btn:width() * 0.5 - (item:x() + item:width() * 0.75)
	--
	local lbdesc = ui.newTTFLabel({text = _data.desc, font = G_FONT, size = 20, align = ui.TEXT_ALIGN_LEFT, color = cc.c3b(255, 255, 255), dimensions = cc.size(_width, 120)}):addTo(cell)
	lbdesc:setAnchorPoint(cc.p(0,0.5))
	lbdesc:setPosition( item:x() + item:width() * 0.75 , self.m_cellSize.height - 85 )

	--
	local sp_medal = display.newSprite(IMAGE_COMMON .. "medal.png"):addTo(cell)
	sp_medal:setAnchorPoint(cc.p(1,0.5))
	sp_medal:setPosition(btn:x(), btn:y() - btn:height() * 0.5 - 7)
	sp_medal:setScale(0.5)
	
	local lbcost = ui.newTTFLabel({text = _data.cost, font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 200, 10)}):addTo(cell)
	lbcost:setAnchorPoint(cc.p(0,0.5))
	lbcost:setPosition( sp_medal:x() + 2, sp_medal:y())

	if ActivityCenterMO.ActivityMedalInfo.price >= _data.cost then
		btn:setEnabled(true)
		lbcost:setColor(cc.c3b(10, 200, 10))
	else
		btn:setEnabled(false)
		lbcost:setColor(cc.c3b(200, 10, 10))
	end

	return cell
end

function MedalConvertibilityTableView:btncallback(tag , sender)
	local iconKind = sender.kind
	local iconId = sender.id
	local buydata = self.converDataList[sender.index]

	local function bugCallback(buyCount , done)
		local function cb(data)
			done()
			if self.coinCallback then self.coinCallback() end
			self:reloadData()
		end
		ActivityCenterBO.BuyActMedalofhonorItem(cb,buydata.id,buyCount)
	end
	
	local param = {}
	param.kind = iconKind
	param.id = iconId
	param.name = buydata.name
	param.desc = buydata.desc
	param.quality = buydata.quality
	param.coinIcon = tostring(IMAGE_COMMON .. "medal.png")
	param.max = 100
	param.myCoinNumber = ActivityCenterMO.ActivityMedalInfo.price
	param.price = tonumber(buydata.cost)
	param.okCallback = bugCallback

	require("app.dialog.BuyAnythingDialog").new(param):push()
end













--------------------------------------------------------------
--					勋章活动 - 歼敌界面						--
--------------------------------------------------------------

local MedalActivityCenterWindows = class("MedalActivityCenterWindows",function ()
	local node = display.newNode()
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function MedalActivityCenterWindows:ctor(size,activityawardId)
	self:setContentSize(size)
	self.winSize = self:getContentSize()
	self.activityawardId = activityawardId -- 活动奖励项ID
end

function MedalActivityCenterWindows:onEnter()
	-- 左上角
	local sp_title = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(self)
	sp_title:setAnchorPoint(cc.p(0,0.5))
	sp_title:setPosition(20, self.winSize.height - 10 - sp_title:height() * 0.5)

	local lb_title = ui.newTTFLabel({text = CommonText[1084][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(sp_title)
	lb_title:setAnchorPoint(cc.p(0,0.5))
	lb_title:setPosition(40 , sp_title:height() * 0.5)

	-- 右上角
	local numbg = display.newScale9Sprite(IMAGE_COMMON .. "mine_probg.png"):addTo(self,5)
   	numbg:setPreferredSize(cc.size(80, 24))
   	numbg:setAnchorPoint(cc.p(1,0.5))
   	numbg:setPosition(self.winSize.width - 15 , sp_title:y())

   	local medalNum = ui.newBMFontLabel({text = "0", font = "fnt/num_3.fnt", align = ui.TEXT_ALIGN_CENTER}):addTo(numbg)
	medalNum:setAnchorPoint(cc.p(0.5, 0.5))
	medalNum:setPosition(numbg:width() * 0.5 , numbg:height() * 0.55 )
	medalNum:setScale(0.55)
	self.lb_medalNum = medalNum
	self.lb_medalNumStr = 0

	local sp_medal = display.newSprite(IMAGE_COMMON .. "medal.png"):addTo(self,5)
	sp_medal:setAnchorPoint(cc.p(1,0.5))
	sp_medal:setPosition(numbg:x() - numbg:width(), numbg:y())
	self.sp_medal_pos = cc.p(sp_medal:x() - sp_medal:width() * 0.5, sp_medal:y()) 
	local effect = armature_create("ryxz_xingguang", sp_medal:width() * 0.5,sp_medal:height() * 0.25, function (movementType, movementID, armature)
	end):addTo(sp_medal)
	-- effect:getAnimation():playWithIndex(0)
	self.arm_xingguang = effect
	-- sp_medal:drawBoundingBox()

	local lb_medalHas = ui.newTTFLabel({text = CommonText[1085], font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self,5)
	lb_medalHas:setAnchorPoint(cc.p(1,0.5))
	lb_medalHas:setPosition(sp_medal:x() - sp_medal:width() , sp_medal:y())

	local t_bg = display.newSprite(IMAGE_COMMON .. "t_bg1.png"):addTo(self, 6)
	t_bg:setAnchorPoint(cc.p(0.5,0))
	t_bg:setPosition(self.winSize.width * 0.5,0)
	self.bgMoveWidth = t_bg:width()

	-- 中心区域
	-- local rect = cc.rect(0,0,self.winSize.width,self.winSize.height - lb_title:y() - lb_title:height() )
	local rect = cc.rect(0,0,self.winSize.width,t_bg:height() - 10 )
	local clipRectNode = display.newClippingRegionNode(rect):addTo(self)
	clipRectNode:setAnchorPoint(cc.p(0,0))
	clipRectNode:setPosition(0,3)
	-- clipRectNode:drawBoundingBox()
	self.m_clipRectNode = clipRectNode

	local ctp = ccTexParams:new()
	ctp.minFilter = 0x2601
	ctp.magFilter = 0x2601
	ctp.wrapS = 0x8370
	ctp.wrapT = 0x8370

	local rectBg = display.newSprite(IMAGE_COMMON .. "emap.jpg"):addTo(clipRectNode)
	rectBg:setAnchorPoint(cc.p(0,0))
	rectBg:setPosition(0,-10)
	
	rectBg:getTexture():setTexParameters(ctp)
	self.rectBg = rectBg

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
    nodeTouchEventProtocol(self, function(event)
        return self:onTouch(event)
    end, cc.TOUCH_MODE_ALL_AT_ONCE, nil, false)

    self.m_ActionState = false -- 动画是否在播放
    self.m_ActionSpriteState = false -- 模版动画
    self.m_TouchSate = false -- 是否可点击

    -- self.m_ThreeGodState = false -- 必出三橙
    -- self.m_TenTimesState = false -- 一键十连
    -- self.m_NoneAction = false -- 跳过动画
    self.m_NoneAction = 0 

    self.m_fighterState = {curState = 2, targetState = 2}

    self.touchRectList = {}

    self.m_sFighterPoint = cc.p(0,0) -- 大炮坐标

    self.m_dataList = {}

    -- self.m_curTouchItemIndex = 0 -- 当前选中的item
    self.m_toSearchBtn = nil

    self.m_isNetingState = 0 -- 默认太

    self.m_actKey = nil
    self.m_actState = true
    self.m_actCheckCallback = nil
end

function MedalActivityCenterWindows:setSearchBtnObject(obj)
	self.m_toSearchBtn = obj
end

function MedalActivityCenterWindows:setLocalActionRecord(actKey, actState, actCheckCallback)
	self.m_actKey = actKey
	self.m_actState = actState
	self.m_actCheckCallback = actCheckCallback
end

-- function MedalActivityCenterWindows:onExit()
-- end

-- function MedalActivityCenterWindows:SetThreeGod( isState )
-- 	self.m_ThreeGodState = isState
-- end

-- function MedalActivityCenterWindows:SetTenTimes( isState )
-- 	self.m_TenTimesState = isState
-- end

function MedalActivityCenterWindows:SetNoneAction( isState )
	self.m_NoneAction = self.m_NoneAction + 1
end

-- 更新数据 绘制大炮
function MedalActivityCenterWindows:UpdateForUI(data, medalCount, isActivity)
	-- self.m_clipRectNode
	self.isActivity = isActivity

	-- 更新 勋章数量
	self.lb_medalNumStr = medalCount
	self.lb_medalNum:setString(self.lb_medalNumStr)
	ActivityCenterMO.ActivityMedalInfo.price = medalCount

	-- 关闭按钮监听
	self:setTouchEnabled(self.isActivity)

	if self.sp_fighter_base then
		self.sp_fighter_base:removeSelf()
		self.sp_fighter_base = nil
	end

	if self.m_sp_fighter then
		self.m_sp_fighter:removeSelf()
		self.m_sp_fighter = nil
	end


	self:updateItem(data)

	-- 创建 大炮动画
	-- self.m_fighterState
	local sp_fighter_base = display.newSprite(IMAGE_COMMON .. "tank_base.png"):addTo(self.m_clipRectNode,3)
	sp_fighter_base:setAnchorPoint(cc.p(0.5,0))
	sp_fighter_base:setPosition(self.m_clipRectNode:width() * 0.5, -sp_fighter_base:height() * 0.7)
	sp_fighter_base:setVisible(not ActivityCenterMO.ActivityMedalInfo.pass)
	self.sp_fighter_base = sp_fighter_base

	local sp_fighter = display.newSprite(IMAGE_COMMON .. "tank_body.png"):addTo(self.m_clipRectNode,4)
	-- sp_fighter:setAnchorPoint(cc.p(0.5,0))
	-- sp_fighter:setPosition(self.m_clipRectNode:width() * 0.5, -sp_fighter:height() * 0.5)
	-- sp_fighter:setAnchorPoint(cc.p(0.5,0.25))
	-- sp_fighter:setPosition(self.m_clipRectNode:width() * 0.5, -sp_fighter:height() * 0.35)
	sp_fighter:setAnchorPoint(cc.p(0.5,0))
	sp_fighter:setPosition(self.m_clipRectNode:width() * 0.5, -sp_fighter:height() * 0.6)
	-- sp_fighter:drawBoundingBox()
	sp_fighter:setRotation(0)
	sp_fighter:setVisible(not ActivityCenterMO.ActivityMedalInfo.pass)
	
	local effect = armature_create("ryxz_kaipao", sp_fighter:width() * 0.5 + 3,sp_fighter:height() + 2):addTo(sp_fighter)
	-- effect:getAnimation():playWithIndex(0)
	sp_fighter.fightEffect = effect

	self.m_sp_fighter = sp_fighter
	self.m_sFighterPoint = cc.p(sp_fighter:getPositionX(), sp_fighter:getPositionY())

	if self.m_toSearchBtn then
		self.m_toSearchBtn:setEnabled(not self:checkInLastItem() and self.isActivity)
	end

	-- 活动结束动画
	if not self.isActivity then
		local maskLayer = display.newColorLayer(ccc4(0, 0, 0, 150)):addTo(self.m_clipRectNode, 9)
		maskLayer:setContentSize(cc.size(self.m_clipRectNode:width(), self.m_clipRectNode:height()))
		maskLayer:setPosition(0, 0)
		local overEffect = armature_create("ryxz_huodongjieshu"):addTo(self.m_clipRectNode,10)
		overEffect:setAnchorPoint(cc.p(0.5,0))
		overEffect:setPosition(self.m_clipRectNode:width() * 0.5,self.m_clipRectNode:height() )
		overEffect:getAnimation():playWithIndex(0)
	end

	if self.helperEffect then
		self.helperEffect:removeSelf()
		self.helperEffect = nil
	end
	-- 引导动画
	if self.m_actKey and not self.m_actState and self.isActivity then
		local helperEffect = armature_create("ryxz_dianji"):addTo(self.m_clipRectNode,8)
		helperEffect:setAnchorPoint(cc.p(0.5,0))
		helperEffect:setPosition(self.m_clipRectNode:width() * 0.5, self.m_clipRectNode:height() * 0.45 - 20)
		helperEffect:getAnimation():playWithIndex(0)
		self.helperEffect = helperEffect
	end
	
end

-- 清楚屏幕上所有坦克
function MedalActivityCenterWindows:clearScreenItem()
	for index = 3 , 1 , -1 do
		if self.touchRectList[index] then
			self.touchRectList[index]:removeSelf()
			self.touchRectList[index] = nil
		end
	end
end

function MedalActivityCenterWindows:updateFighterState()
	-- 大炮
	if self.m_sp_fighter then
		self.m_sp_fighter:setVisible(not ActivityCenterMO.ActivityMedalInfo.pass)
	end
	if self.sp_fighter_base then
		self.sp_fighter_base:setVisible(not ActivityCenterMO.ActivityMedalInfo.pass)
	end
end

-- 移动背景 and 处理大炮显示
function MedalActivityCenterWindows:updateBgAndFighter(callback)
	-- 大炮
	-- if self.m_sp_fighter then
	-- 	self.m_sp_fighter:setVisible(not ActivityCenterMO.ActivityMedalInfo.pass)
	-- end
	-- if self.sp_fighter_base then
	-- 	self.sp_fighter_base:setVisible(not ActivityCenterMO.ActivityMedalInfo.pass)
	-- end
	self:updateFighterState()

	-- 背景移动
	local _x = self.rectBg:x()
	local _y = self.rectBg:y()
	self.rectBg:setTextureRect(cc.rect(0,0,self.rectBg:width() + self.bgMoveWidth,self.rectBg:height()))
	self.rectBg:setPosition(_x, _y)
	self.rectBg:runAction( transition.sequence({cc.MoveBy:create(0.5, cc.p(-self.bgMoveWidth,0)) , cc.CallFunc:create(function()
		if callback then callback() end
	end) }) )

	-- 刷新归位
	if self.m_sp_fighter then
		self.m_sp_fighter:setRotation(0)
	end
end

-- 刷新 3个 item
function MedalActivityCenterWindows:updateItem(data)
	-- 创建 dancer
	for index = 1 , 3 do
		local _data_id = data[index]
		self:drawItem(index, _data_id)
	end
end

-- 绘制 坦克 和 鸡
function MedalActivityCenterWindows:drawItem(index, _data_id)

	-- 清楚
	if self.touchRectList[index] then
		self.touchRectList[index]:removeSelf()
		self.touchRectList[index] = nil
	end

	-- 获取信息
	local _info = ActivityCenterMO.getActivityMedal(self.activityawardId, _data_id)
	if _info then
		local _quality = _info.quality -- 品质 坦克1-6 鸡99
		local _type = _info.type -- 0：单个坦克 1：坦克集群 2:鸡 3：全家桶
		local _icon = _info.icon -- 使用的图片资源
		local iconStr = ""
		local _state = 0 -- 0鸡 1单个坦克 2集群坦克
		local _scale = 1
		if _type == 0 then -- 单个坦克
			_scale = 0.75
			_state = 1
			iconStr = "image/tank/" .. _icon .. ".png"
		elseif _type == 1 then -- 坦克集群
			_scale = 0.75
			_state = 2
			iconStr = "image/tanks/" .. _icon .. ".png"
		else --if _type >= 2 then
			_scale = 0.5
			_state = 0
			iconStr = IMAGE_COMMON .. _icon .. ".png"
		end
	
		local item = display.newSprite(iconStr):addTo(self.m_clipRectNode,2)
		item:setAnchorPoint(cc.p(0.5,0))
		item:setPosition(self.m_clipRectNode:width() * 0.5 + ((index - 2) * self.m_clipRectNode:width() * 0.25),self.m_clipRectNode:height() * 0.45 + ((index == 2) and 1 or 0) * 30 )
		item:setScale(_scale)
		item.index = index
		item.id = _data_id
		item.medalNum = _info.medalawards
		
		if _state == 0 then
			local lb_item_medal_name = ui.newTTFLabelWithOutline({text = CommonText[1086], font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = COLOR[_quality]}):addTo(item)
			lb_item_medal_name:setAnchorPoint(cc.p(0.5,0))
			lb_item_medal_name:setPosition(item:width() * 0.5 , item:height())
			lb_item_medal_name:setScale(1 / _scale)
			-- lb_item_medal_name:enableStroke(cc.c3b(0,0,0),0.75)
			item.child3 = lb_item_medal_name

		else
			-- 勋章图标
			local sp_item_medal = display.newSprite(IMAGE_COMMON .. "medal.png"):addTo(item)
			sp_item_medal:setAnchorPoint(cc.p(1,0))
			sp_item_medal:setPosition(item:width() * 0.5, item:height())
			-- sp_item_medal:setScale(0.5)
			item.child1 = sp_item_medal

			local lb_item_medalNum = ui.newTTFLabelWithOutline({text = "x" .. _info.medalawards, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(item)
			lb_item_medalNum:setScale(1 / _scale)
			lb_item_medalNum:setAnchorPoint(cc.p(0,0.5))
			lb_item_medalNum:setPosition(item:width() * 0.5 , sp_item_medal:y() + sp_item_medal:height() * 0.5)
			-- lb_item_medalNum:enableStroke(cc.c3b(0,0,0),0.75)
			item.child2 = lb_item_medalNum

			local lb_item_medal_name = ui.newTTFLabelWithOutline({text = _info.name, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = COLOR[_quality]}):addTo(item)
			lb_item_medal_name:setScale(1 / _scale)
			lb_item_medal_name:setAnchorPoint(cc.p(0.5,0))
			lb_item_medal_name:setPosition(item:width() * 0.5 , sp_item_medal:y() + sp_item_medal:height())
			item.child3 = lb_item_medal_name
			-- lb_item_medal_name:enableStroke(cc.c3b(0,0,0),0.75)

			if self.isActivity then
				item:setOpacity(0)
				local armStr = _state == 1 and "ryxz_shuaxin" or "ryxz_shuaxin_jinse"
				local effect = armature_create(armStr, item:width() * 0.5, item:height() * 0.5, function (movementType, movementID, armature)
		            if movementType == MovementEventType.COMPLETE then
		            	armature:removeSelf()
		            	item:setOpacity(255)
		            end
		        end):addTo(item)
		        effect:setScale(1 / _scale)
		        effect:getAnimation():playWithIndex(0)
			end
		end

		self.touchRectList[index] = item
		-- item:drawBoundingBox()
		self.m_dataList[index] = _data_id
		return item
	end

	self.m_dataList[index] = 0
	return nil
end

function MedalActivityCenterWindows:onEnterFrame(dt)
	if not self.m_ActionSpriteState and self.m_NoneAction > 0 then
		self.m_NoneAction = 0
		self:updateFighterState()
	end

	-- 等待数据
	if self.m_isNetingState > 0 then
		if self.m_isNetingState >= 2 and not self.m_ActionSpriteState then
			self.m_isNetingState = 0 -- 关闭网络状态（默认）
			self.m_ActionStep = 1 -- 动画步骤
			self.m_ActionState = true -- 开始动画
		end 
	end

	if self.m_ActionState then
		-- 创建奖励
		self:MoveActionStepOfCreateAndDelete()
		-- 奖励动画
		self:MoveActionStepOfMedal()
		-- 奖励动画结束
		self:MoveActionStepOfGet()
		-- 跳出动画
		self:MoveActionStepOfOver()
		
	end
	-- 刷新金币动画
	self:UpdateMedalCoin()
end

-- 播放爆炸的动画 删除原item 
function MedalActivityCenterWindows:MoveActionStepOfCreateAndDelete()
	if self.m_ActionStep == 1 then
		local itemIndex = self.OpenActMedalData.index
		local thisitem = self.touchRectList[itemIndex]
		self.touchRectList[itemIndex] = nil
		self.m_dataList[itemIndex] = 0
		local function _actionEnd()
			if thisitem then
				thisitem:removeSelf()
				thisitem = nil
			end
		end

		-- 隐藏
		thisitem:setOpacity(0)
		if thisitem.child1 then thisitem.child1:setOpacity(0) end
		if thisitem.child2 then thisitem.child2:setOpacity(0) end
		if thisitem.child3 then thisitem.child3:setOpacity(0) end

		local medalNum = thisitem.medalNum

		self.m_ActionStepMedalList = {	list = {} , 
										pos = cc.p(thisitem:x(),thisitem:y() + thisitem:height() * 0.5), 
										medalNum = medalNum ,
										counts = 0,
										medalHonor = self.OpenActMedalData.medalHonor }

		-- 刷新增量
		if self.OpenActMedalData.medalAddHonor > 0 then
			medalNum = self.OpenActMedalData.medalAddHonor
		end
		local size = medalNum < 3 and medalNum or 3
		for index = 1 , size do
			local sp_medalCoin = display.newSprite(IMAGE_COMMON .. "medal.png"):addTo(self,10)
			sp_medalCoin:setAnchorPoint(cc.p(0.5,0.5))
			sp_medalCoin:setPosition(thisitem:x() , thisitem:y() + thisitem:height() * 0.5 )
			-- sp_medalCoin:setScale(0.4)
			sp_medalCoin:setVisible(false)
			self.m_ActionStepMedalList.list[#self.m_ActionStepMedalList.list + 1] = sp_medalCoin
		end

		-- 创建爆炸动画 function (movementType, movementID, armature)
		local effect = armature_create("ryxz_baozha", thisitem:width() * 0.5,0, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
            	armature:removeSelf()
            	_actionEnd()
            end
		end):addTo(thisitem)
		 effect:getAnimation():playWithIndex(0)

		 self.m_ActionStep = 2
		 self.m_ActionDelayTime = 10 -- 等候时间
	end

	if self.m_ActionStep == 2 then
		self.m_ActionDelayTime = self.m_ActionDelayTime - 1
		if self.m_ActionDelayTime < 0 then
			self.m_ActionStep = 3
		end
	end
end

-- 爆出 配件并掉落
function MedalActivityCenterWindows:MoveActionStepOfMedal()
	if self.m_ActionStep == 3 then
		math.randomseed(os.time())
		local size = #self.m_ActionStepMedalList.list
		for index = 1, size do
			local medalItem = self.m_ActionStepMedalList.list[index]
			medalItem:setVisible(true)

			local medalItemPos = self.m_ActionStepMedalList.pos
			local dex_x = math.random(40,65) * ((index % 2 == 1) and 1 or -1 )
			local _x = medalItemPos.x
			local _x = _x + dex_x

			local spwArray1 = cc.Array:create()
	        spwArray1:addObject(CCJumpTo:create(0.25,cc.p(_x, medalItemPos.y - 80), 100 , 1) )
	        -- spwArray1:addObject(cc.RotateTo:create(0.25, 60))
	        local spaw1 = cc.Spawn:create(spwArray1)
	        dex_x = dex_x / 2
	        _x = _x + dex_x

	        local spwArray2 = cc.Array:create()
	        spwArray2:addObject(CCJumpTo:create(0.23,cc.p(_x, medalItemPos.y  - 120), 50 , 1) )
	        -- spwArray2:addObject(cc.RotateTo:create(0.23, 90))
	        local spaw2 = cc.Spawn:create(spwArray2)
	        dex_x = dex_x / 2
	        _x = _x + dex_x

	        local spwArray3 = cc.Array:create()
	        spwArray3:addObject(CCJumpTo:create(0.21,cc.p(_x, medalItemPos.y  - 120), 25 , 1) )
	        -- spwArray3:addObject(cc.RotateTo:create(0.21, 150))
	        local spaw3 = cc.Spawn:create(spwArray3)
	        dex_x = dex_x / 2
	        _x = _x + dex_x

	        local spwArray4 = cc.Array:create()
	        spwArray4:addObject(CCJumpTo:create(0.18,cc.p(_x, medalItemPos.y  - 120), 12.5 , 1) )
	        -- spwArray4:addObject(cc.RotateTo:create(0.28, 180))
	        local spaw4 = cc.Spawn:create(spwArray4)

	        medalItem:runAction(transition.sequence({spaw1, spaw2, spaw3, spaw4, cc.CallFunc:create(function ()
	        	self.m_ActionStep = 5
				self.m_ActionDelayTime = 5 -- 等候时间
	        end)}))
		end

		-- 绘制鸡
		if self.OpenActMedalData.chickenId > 0 then
			local itemchicken = self:drawItem(self.OpenActMedalData.index,self.OpenActMedalData.chickenId)
			itemchicken:setScale(0.2)

			local dex_x = math.random(5,15) * ((math.random(1,15) % 2 == 1) and 1 or -1 )
			local _x = itemchicken:x()

			local spwArray1 = cc.Array:create()
	        spwArray1:addObject(CCJumpTo:create(0.25,cc.p(_x, itemchicken:y() - 10), 25 , 1) )
	        -- spwArray1:addObject(cc.ScaleTo:create(0.25,1) )-- cc.RotateTo:create(0.25, 60))
	        local spaw1 = cc.Spawn:create(spwArray1)
	        dex_x = dex_x / 2
	        _x = _x + dex_x

	        local spwArray2 = cc.Array:create()
	        spwArray2:addObject(CCJumpTo:create(0.23,cc.p(_x, itemchicken:y()  - 15), 12.5 , 1) )
	        -- spwArray2:addObject(cc.ScaleTo:create(0.25,1.1) )-- cc.RotateTo:create(0.25, 60))
	        local spaw2 = cc.Spawn:create(spwArray2)
	        dex_x = dex_x / 2
	        _x = _x + dex_x

	        local spwArray3 = cc.Array:create()
	        spwArray3:addObject(CCJumpTo:create(0.21,cc.p(_x, itemchicken:y()  - 15), 6.25 , 1) )
	        -- spwArray3:addObject(cc.ScaleTo:create(0.25,1.15) )-- cc.RotateTo:create(0.25, 60))
	        local spaw3 = cc.Spawn:create(spwArray3)
	        dex_x = dex_x / 2
	        _x = _x + dex_x

	        local spwArray4 = cc.Array:create()
	        spwArray4:addObject(CCJumpTo:create(0.18,cc.p(_x, itemchicken:y()  - 15), 3.125 , 1) )
	        -- spwArray4:addObject(cc.ScaleTo:create(0.25,1.2) )-- cc.RotateTo:create(0.25, 60))
	        local spaw4 = cc.Spawn:create(spwArray4)

	        itemchicken:runAction(transition.sequence({spaw1, spaw2, spaw3, spaw4 , cc.DelayTime:create(0.5) , CCScaleTo:create(0.5,0.5)}))
		end
		
		self.m_ActionStep = 4

		if size == 0 then
			self.m_ActionStep = 5
			self.m_ActionDelayTime = 5 -- 等候时间
		end
	end

	if self.m_ActionStep == 5 then
		self.m_ActionDelayTime = self.m_ActionDelayTime - 1
		if self.m_ActionDelayTime < 0 then
			self.m_ActionStep = 6
		end
	end
end

function MedalActivityCenterWindows:MoveActionStepOfGet()
	if self.m_ActionStep == 6 then
		local isupdate = false

		-- 动画结束回调
		local function endAndPutNum(sender)
			-- sender:setOpacity(128)
			sender:removeSelf()
			self.m_ActionStepMedalList.counts = self.m_ActionStepMedalList.counts + 1
			if not isupdate then
				isupdate = true
				self:checkUpdateMedalCoin(self.m_ActionStepMedalList.medalNum, self.m_ActionStepMedalList.medalHonor)
			end
			-- if self.m_ActionStepMedalList.counts >= #self.m_ActionStepMedalList.list then
			-- 	self.m_ActionStepMedalList.list = nil
			-- 	self.m_ActionStepMedalList = nil
			-- end
		end

		math.randomseed(os.time())
		for index = 1, #self.m_ActionStepMedalList.list do
			local medalItem = self.m_ActionStepMedalList.list[index]
			local _d = (math.random(40,65) % 2) == 0 and 1 or -1 
			local _a = Vec(self.sp_medal_pos.x - medalItem:getPositionX() , self.sp_medal_pos.y - medalItem:getPositionY() )
			local c = math.deg(math.atan(_a.y / _a.x)) 
			if c < 0 then c = c + LOCAL_ACTION_WHOLE_RAD end
			local _c = c + 20 * _d
			local x = _a.modulus() * math.cos(math.rad(_c)) * 0.5
			local y = _a.modulus() * math.sin(math.rad(_c)) * 0.5
			local to_ = cc.p(medalItem:getPositionX() + x, medalItem:getPositionY() + y)
			local cbc = ccBezierConfig:new()
	        cbc.controlPoint_1 = to_
	        cbc.controlPoint_2 =  cbc.controlPoint_1
	        cbc.endPosition = self.sp_medal_pos

			local spwArray = cc.Array:create()
	        -- spwArray:addObject(CCMoveTo:create(0.25, self.sp_medal_pos))
	        spwArray:addObject(CCEaseExponentialInOut:create(CCBezierTo:create(0.75,cbc)) )
	        -- spwArray:addObject(cc.RotateTo:create(0.75, 720))
	        local spaw = cc.Spawn:create(spwArray)
			medalItem:runAction( transition.sequence({spaw ,cc.CallFuncN:create(endAndPutNum)}))
		end

		self.m_ActionStep = 7
	end
end

function MedalActivityCenterWindows:MoveActionStepOfOver()
	-- 跳出状态机
	if self.m_ActionStep == 7 then
		self.m_ActionState = false

		local allState = false
		for index = 1 , 3 do
			if self.m_dataList and self.m_dataList[index] and self.m_dataList[index] > 0 then
				allState = true
			end
		end
		if not allState then
			Toast.show(CommonText[1093][2])
		end
		if self.m_toSearchBtn then
			self.m_toSearchBtn:setEnabled(not allState)
		end
	end
end

function MedalActivityCenterWindows:checkUpdateMedalCoin(num,all)
	if self.isMedalCoinUpdate then return end
	self.isMedalCoinUpdate = true

	-- num = 50
	local dex = 5
	local alltime = 30
	local prices = 0
	if (alltime / dex) > num then
		alltime = 15
		dex = alltime / num 
	end
	prices = num / math.floor(alltime / dex)

	local _all = all or self.lb_medalNumStr + num

	self.medalCoinUpdateInfo = {}
	self.medalCoinUpdateInfo.time = alltime
	self.medalCoinUpdateInfo.dextime = alltime
	self.medalCoinUpdateInfo.dex = dex
	self.medalCoinUpdateInfo.dexs = dex
	self.medalCoinUpdateInfo.num = num
	self.medalCoinUpdateInfo.prices = prices
	self.medalCoinUpdateInfo.starts = self.lb_medalNumStr
	self.medalCoinUpdateInfo.ends = _all
	self.lb_medalNumStr = _all

	self.arm_xingguang:getAnimation():playWithIndex(0)
end

-- 刷新金币动画
function MedalActivityCenterWindows:UpdateMedalCoin()
	if self.isMedalCoinUpdate then
		if self.medalCoinUpdateInfo then
			self.medalCoinUpdateInfo.dextime = self.medalCoinUpdateInfo.dextime - 1
			self.medalCoinUpdateInfo.dexs = self.medalCoinUpdateInfo.dexs - 1
			if self.medalCoinUpdateInfo.dexs <= 0 then
				self.medalCoinUpdateInfo.dexs = self.medalCoinUpdateInfo.dex
				self.medalCoinUpdateInfo.starts = math.ceil(self.medalCoinUpdateInfo.starts + self.medalCoinUpdateInfo.prices)
				if self.medalCoinUpdateInfo.dextime == 0 then self.medalCoinUpdateInfo.starts = self.medalCoinUpdateInfo.ends end
				self.lb_medalNum:setString(self.medalCoinUpdateInfo.starts)
			end
			if self.medalCoinUpdateInfo.dextime <= 0 then
				self.lb_medalNum:setString(self.medalCoinUpdateInfo.ends)
				self.isMedalCoinUpdate = false
				self.medalCoinUpdateInfo = nil
			end
		end
	end
end

function MedalActivityCenterWindows:checkInLastItem()
	local state = false
	for k,v in pairs(self.m_dataList) do
		if v and v > 0 then
			state = true
		end
	end
	return state
end

-- 动画是否播放中
function MedalActivityCenterWindows:IsActionState()
	return self.m_ActionState or self.m_ActionSpriteState
end

-- 打开活动宝箱 For Touch
function MedalActivityCenterWindows:DoOpenActionForMedal(item)
	-- self.m_curTouchItemIndex = item.index

	-- 消除引导
	if self.m_actKey and not self.m_actState and self.helperEffect then
		self.helperEffect:removeSelf()
		self.helperEffect = nil
		local state = not self.m_actState
		ActivityCenterMO.UseActivityLoaclRecordInfo(self.m_actKey,state)
		if self.m_actCheckCallback then self.m_actCheckCallback(state) end
	end

	local index = item.index
	local _rotation = 0

	-- 修改活动状态
	local function playActionOrActionEnd()
		
		self.m_sp_fighter.fightEffect:getAnimation():playWithIndex(0)
		self.m_sp_fighter:setRotation(_rotation)

		self.m_ActionSpriteState = false


	end
	-- 计算动画活动
	if not ActivityCenterMO.ActivityMedalInfo.pass and self.m_sp_fighter then

		self.m_ActionSpriteState = true
		local pointFrom = cc.p(item:getPositionX(), item:getPositionY())
		local pointTo = cc.p(self.m_sp_fighter:getPositionX(), self.m_sp_fighter:getPositionY())
		local rodTo = math.deg(math.atan( (pointFrom.x - pointTo.x) / (pointFrom.y - pointTo.y)))
		_rotation = rodTo
		self.m_sp_fighter:runAction( transition.sequence({cc.EaseExponentialOut:create(cc.RotateTo:create(0.5, rodTo)), cc.CallFunc:create(function ()
			playActionOrActionEnd()
		end)})  ) -- CCEaseExponentialIn -- CCEaseElasticIn
	else
		playActionOrActionEnd()
	end

	self.m_isNetingState = 1
	--拉取 打开宝箱信息
	local function result( data )
		self.m_isNetingState = 2

		local medalAddHonor = 0
		local medalHonor = table.isexist(data, "medalHonor") and data["medalHonor"] or 0
		local chickenId = table.isexist(data, "chickenId") and data["chickenId"] or 0
		local awards = PbProtocol.decodeArray(data["award"])
		if #awards > 0 then
			for index = #awards , 1 , -1 do
				local award = awards[index]
				if award.type == 100 then -- 荣誉勋章
					medalAddHonor = award.count
					-- if medalHonor == 0 then
					-- 	medalHonor = ActivityCenterMO.ActivityMedalInfo.price + award.count
					-- end
					table.remove(awards,index)
				end
			end
			local statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end
		
		if medalHonor == 0 then
			medalHonor = ActivityCenterMO.ActivityMedalInfo.price + medalAddHonor
		end

		ActivityCenterMO.ActivityMedalInfo.price = medalHonor

		self.OpenActMedalData = {}
		self.OpenActMedalData.medalAddHonor = medalAddHonor 
		self.OpenActMedalData.medalHonor = medalHonor 
		self.OpenActMedalData.chickenId = chickenId
		self.OpenActMedalData.index = index

		if chickenId ~= 0 then
			Toast.show(CommonText[1093][1])
		end
	end
	-- 客户端 服务端 列表下标起始值不同 0 1
	ActivityCenterBO.OpenActMedalofhonor(result, (index - 1) )
end

----------------------------------------------------------
--						TOUCH 							--
----------------------------------------------------------
function MedalActivityCenterWindows:onTouch(event)
	if event.name == "began" then
        return self:onTouchBegan(event)
	elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    end
end

function MedalActivityCenterWindows:onTouchBegan(event)
	self.m_TouchSate = false
	if self:IsActionState() or self.m_isNetingState > 0 then 
		return false
	end

	-- local point = cc.p(event.points["0"].x , event.points["0"].y)
	-- local point = cc.p(point.x - 5 , point.y - (self:getPositionY() - self.winSize.height) - 4)
	-- self.TouchPoint = point
	self.m_TouchSate = true
	return true
end

function MedalActivityCenterWindows:onTouchMoved(event)
	-- self.m_TouchSate = false
end

function MedalActivityCenterWindows:onTouchEnded(event)
	if not self.m_TouchSate then return end
	local point = cc.p(event.points["0"].x , event.points["0"].y)
	point = cc.p(point.x - (display.cx - 320),point.y)
	point = cc.p(point.x - 15 , point.y - (self:getPositionY() - self.winSize.height) - 4)
	self.TouchPoint = point

	for k,v in pairs(self.touchRectList) do
		local itme = v
		if itme:boundingBox():containsPoint(self.TouchPoint) then
			-- 点击坦克、鸡 成功
			self:DoOpenActionForMedal(itme)
			break
		end
	end

	self.m_TouchSate = false
end

















--------------------------------------------------------------
--						勋章活动	主界面					--
--------------------------------------------------------------
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ActivityMedalView = class("ActivityMedalView", UiNode)

function ActivityMedalView:ctor(activity)
	ActivityMedalView.super.ctor(self,"image/common/bg_ui.jpg")
	self.m_activity = activity
	-- dump(activity)
end

function ActivityMedalView:onEnter()
	ActivityMedalView.super.onEnter(self)

	-- 活动标识
	self._key = self.m_activity.activityId --.. "_" .. self.m_activity.awardId .. "_" .. self.m_activity.beginTime
	self.ischeck = ActivityCenterMO.UseActivityLoaclRecordInfo(self._key)

	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)

	armature_add(IMAGE_ANIMATION .. "effect/ryxz_baozha.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_baozha.plist", IMAGE_ANIMATION .. "effect/ryxz_baozha.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_kaipao.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_kaipao.plist", IMAGE_ANIMATION .. "effect/ryxz_kaipao.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_leida.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_leida.plist", IMAGE_ANIMATION .. "effect/ryxz_leida.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_miaozhun.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_miaozhun.plist", IMAGE_ANIMATION .. "effect/ryxz_miaozhun.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_shuaxin.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_shuaxin.plist", IMAGE_ANIMATION .. "effect/ryxz_shuaxin.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_shuaxin_jinse.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_shuaxin_jinse.plist", IMAGE_ANIMATION .. "effect/ryxz_shuaxin_jinse.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_xingguang.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_xingguang.plist", IMAGE_ANIMATION .. "effect/ryxz_xingguang.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_huodongjieshu.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_huodongjieshu.plist", IMAGE_ANIMATION .. "effect/ryxz_huodongjieshu.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")

	local function createDelegate(container, index)
		if index == 1 then -- 歼敌
			self:showTable1(container)
		elseif index == 2 then -- 兑换
			self:showTable2(container)
		elseif index == 3 then -- 排行榜
			self:showTable3(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate(index)
		self.lb_time_num = nil
		self.lb_awardtime_num = nil
		return true
	end

	local pages = CommonText[1087]
	local size = cc.size(self:getBg():getContentSize().width - 10,self:getBg():getContentSize().height - 100 - 50)

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self:getBg(), 1)
	pageView:setAnchorPoint(cc.p(0,0))
	pageView:setPosition(5,4)
	pageView:setPageIndex(1)
	self.m_pageView = pageView	

	self.scheduler_ = scheduler.scheduleGlobal(handler(self,self.onTick), 1)

end

function ActivityMedalView:onExit()
	ActivityMedalView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_baozha.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_baozha.plist", IMAGE_ANIMATION .. "effect/ryxz_baozha.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_kaipao.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_kaipao.plist", IMAGE_ANIMATION .. "effect/ryxz_kaipao.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_leida.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_leida.plist", IMAGE_ANIMATION .. "effect/ryxz_leida.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_miaozhun.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_miaozhun.plist", IMAGE_ANIMATION .. "effect/ryxz_miaozhun.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_shuaxin.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_shuaxin.plist", IMAGE_ANIMATION .. "effect/ryxz_shuaxin.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_shuaxin_jinse.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_shuaxin_jinse.plist", IMAGE_ANIMATION .. "effect/ryxz_shuaxin_jinse.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_xingguang.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_xingguang.plist", IMAGE_ANIMATION .. "effect/ryxz_xingguang.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_huodongjieshu.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_huodongjieshu.plist", IMAGE_ANIMATION .. "effect/ryxz_huodongjieshu.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
	if self.scheduler_ then
		scheduler.unscheduleGlobal(self.scheduler_)
	end
end

function ActivityMedalView:onTick(ft)
	if self.m_pageView then
		if self.m_pageView:getPageIndex() == 1 then
			local activityTime = self.m_activity.endTime - ManagerTimer.getTime()
			if self.lb_time_num_state and self.lb_time_num then
				if activityTime >= 0 then
					self.lb_time_num:setString(UiUtil.strBuildTime(activityTime,nil,true))
				else
					if not self.updateStateOver1 then
						self.lb_time_num:setString(CommonText[10017][4])
						self:sendInfo1()
						self.updateStateOver1 = true
					end
				end
			end
		end
		if self.m_pageView:getPageIndex() == 3 then
			local awardTime = self.m_activity.displayTime - ManagerTimer.getTime()
			if self.lb_awardtime_num_state and self.lb_awardtime_num then
				if awardTime >= 0 then
					self.lb_awardtime_num:setString(UiUtil.strBuildTime(awardTime,nil,true))
				else
					if not self.updateStateOver3 then
						self.lb_awardtime_num:setString(CommonText[10017][4])
						self:sendInfo3()
						self.updateStateOver3 = true
					end
				end
			end
		end
	end
end



-- 歼敌活动UI
function ActivityMedalView:showTable1(container)
	self.m_medalExplore = ActivityCenterMO.getActivityMedalExplore(1)
	-- 活动描述
	local lb_desc = ui.newTTFLabel({text = CommonText[1084][2], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(container)
	lb_desc:setAnchorPoint(cc.p(0,0.5))
	lb_desc:setPosition(25 , container:getContentSize().height - 5 - lb_desc:height())

	-- 活动时间
	local lb_time = ui.newTTFLabel({text = CommonText[1084][6], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 255, 10)}):addTo(container)
	lb_time:setAnchorPoint(cc.p(0,0.5))
	lb_time:setPosition(25 , lb_desc:y() - lb_time:height() - 10)

	-- 活动时间 number
	local lb_time_num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 255, 10)}):addTo(container)
	lb_time_num:setAnchorPoint(cc.p(0,0.5))
	lb_time_num:setPosition(lb_time:x() + lb_time:width() , lb_time:y())
	self.lb_time_num = lb_time_num
	self.lb_time_num_state = false

	-- -- 领奖时间
	-- local lb_awardtime = ui.newTTFLabel({text = CommonText[1084][7], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 255, 10)}):addTo(container)
	-- lb_awardtime:setAnchorPoint(cc.p(0,0.5))
	-- lb_awardtime:setPosition(25 , lb_time:y() - lb_awardtime:height())

	-- -- 领奖时间 number
	-- local lb_awardtime_num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 255, 10)}):addTo(container)
	-- lb_awardtime_num:setAnchorPoint(cc.p(0,0.5))
	-- lb_awardtime_num:setPosition(lb_awardtime:x() + lb_awardtime:width() , lb_awardtime:y())
	-- self.lb_awardtime_num = lb_awardtime_num


	-- 前往勋章界面
	local function toMedalViewFun()
		if UserMO.level_ < MedalMO.level_ then return Toast.show(string.format(CommonText[1097],70,CommonText[20163][1])) end
		if UiDirector.getUiByName("ActivityCenterView") then
			UiDirector.popMakeUiTop("ActivityCenterView")
		else
			UiDirector.popMakeUiTop("HomeView")
		end
		UiDirector.push(require("app.view.MedalBaseView").new())
	end
	local toMedalViewBtn = UiUtil.button("btn_go.png", "btn_go.png", nil,toMedalViewFun):addTo(container)
	toMedalViewBtn:setAnchorPoint(cc.p(1, 0.5))
	toMedalViewBtn:setPosition(lb_desc:x() + lb_desc:width() + 5, lb_desc:y())
	toMedalViewBtn:setScale(0.75)
	toMedalViewBtn:setRotation(180)

	local lb_go = ui.newTTFLabel({text = CommonText[1084][8], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(toMedalViewBtn)
	lb_go:setAnchorPoint(cc.p(0.5,0.5))
	lb_go:setPosition(toMedalViewBtn:width() * 0.55 , toMedalViewBtn:height() * 0.5)
	lb_go:setRotation(180)
	lb_go:setScale(1.25)


	local function tohelpFun()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.MedalHelper):push()
	end
	-- 帮助
	local tohelpBtn = UiUtil.button("btn_39_normal.png", "btn_39_selected.png", nil,tohelpFun):addTo(container)
	tohelpBtn:setAnchorPoint(cc.p(1,0.5))
	tohelpBtn:setPosition(container:width() - 20 , lb_desc:y())

	--概率公示
	local chance = ActivityCenterMO.getProbabilityTextById(self.m_activity.activityId, self.m_activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(container)
		chanceBtn:setPosition(container:width() - 140, container:height() - 30)
		chanceBtn:setVisible(chance.open == 1)
	end

	-- 活动中心界面
	-- local size = cc.size(container:width(), 545) -- MedalActivityCenterWindows
	local size = cc.size(610, 545) 
	local centerWin = MedalActivityCenterWindows.new(size,self.m_activity.awardId):addTo(container)
	centerWin:setAnchorPoint(cc.p(0.5,1))
	centerWin:setPosition(container:width() * 0.5, lb_time:y() - 5 - lb_time:height() * 0.5)
	self.m_centerWin = centerWin

	if not self.ischeck then
		local function checkCallback(state)
			self.ischeck = state
		end
		centerWin:setLocalActionRecord(self._key, self.ischeck, checkCallback)
	end

	
	local searcheffect = armature_create("ryxz_leida"):addTo(container,5)
	searcheffect:setAnchorPoint(cc.p(0.5,0.5))
	searcheffect:setPosition(centerWin:x() , centerWin:y() - size.height * 0.5)
	searcheffect:setVisible(false)
	self.searcheffect = searcheffect
	-- searcheffect:getAnimation():playWithIndex(0)


	-- 必出三橙
	local function onCheckedChanged1(sender, isChecked)
		-- self.m_centerWin:SetThreeGod(isChecked)
		ActivityCenterMO.ActivityMedalInfo.three = isChecked
	end
	-- 必出三橙 选框
	local checkBox1 = CheckBox.new(nil, nil, onCheckedChanged1):addTo(container)
	checkBox1:setPosition(container:width() * 0.5 - 80, checkBox1:height() )
	checkBox1:setChecked(ActivityCenterMO.ActivityMedalInfo.three)
	-- 必出三橙 lb
	local lb_ThreeO = ui.newTTFLabel({text = CommonText[1088][2], font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(container)
	lb_ThreeO:setAnchorPoint(cc.p(0,0.5))
	lb_ThreeO:setPosition(checkBox1:x() + checkBox1:width()*0.5 , checkBox1:y())
	-- 金币
	local coin = UiUtil.createItemSprite(ITEM_KIND_COIN,1):addTo(container)
	coin:setPosition(lb_ThreeO:x() + lb_ThreeO:width() + coin:width() * 0.5 , checkBox1:y())
	-- 金币数值
	local CoinNum = ui.newBMFontLabel({text = "0000", font = "fnt/num_3.fnt", x = 0, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	CoinNum:setAnchorPoint(cc.p(0, 0.5))
	CoinNum:setPosition(coin:x() + coin:width() * 0.5 , checkBox1:y() + CoinNum:height() * 0.25 )
	CoinNum:setScale(0.65)


	-- 一键十倍
	local function onCheckedChanged2(sender, isChecked)
		-- self.m_centerWin:SetTenTimes(isChecked)
		ActivityCenterMO.ActivityMedalInfo.ten = isChecked
		if ActivityCenterMO.ActivityMedalInfo.ten then 
			CoinNum:setString("1000") 
			self:CheckTimes(10)
		else 
			CoinNum:setString("100") 
			self:CheckTimes()
		end
	end
	-- 一键十倍 选框
	local checkBox2 = CheckBox.new(nil, nil, onCheckedChanged2):addTo(container)
	checkBox2:setPosition(CoinNum:x() + CoinNum:width() + 10, checkBox2:height() )
	checkBox2:setChecked(ActivityCenterMO.ActivityMedalInfo.ten)
	checkBox2:setVisible(UserMO.vip_ >= 6)
	if ActivityCenterMO.ActivityMedalInfo.ten then CoinNum:setString("1000") else CoinNum:setString("100") end
	-- 一键十倍 lb
	local lb_Tens = ui.newTTFLabel({text = CommonText[1088][3], font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(container)
	lb_Tens:setAnchorPoint(cc.p(0,0.5))
	lb_Tens:setPosition(checkBox2:x() + checkBox2:width()*0.5 , checkBox2:y())
	lb_Tens:setVisible(UserMO.vip_ >= 6)


	-- 跳过动画 lb
	local lb_PassA = ui.newTTFLabel({text = CommonText[1088][1], font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(container)
	lb_PassA:setAnchorPoint(cc.p(1,0.5))
	lb_PassA:setPosition(checkBox1:x() - checkBox1:width() * 0.5 - 10 , checkBox1:y())
	local function onCheckedChanged3(sender, isChecked)
		self.m_centerWin:SetNoneAction(isChecked)
		ActivityCenterMO.ActivityMedalInfo.pass = isChecked
	end
	-- 跳过动画 选框
	local checkBox3 = CheckBox.new(nil, nil, onCheckedChanged3):addTo(container)
	checkBox3:setPosition(lb_PassA:x() - lb_PassA:width() - checkBox3:width() * 0.5, checkBox3:height() )
	checkBox3:setChecked(ActivityCenterMO.ActivityMedalInfo.pass)
	


	-- 锁敌 Button
	local toChangeBtn = UiUtil.button("btn_5_normal.png", "btn_5_selected.png", "btn_1_disabled.png",handler(self,self.toSearchForMedal)):addTo(container)
	toChangeBtn:setAnchorPoint(cc.p(0.5,0))
	toChangeBtn:setPosition(container:width() * 0.5 , checkBox1:y() + checkBox1:height()*0.5)
	-- toChangeBtn:setEnabled(self.m_centerWin:checkInLastItem())
	centerWin:setSearchBtnObject(toChangeBtn)
	-- 锁敌
	local lb_Change1 = ui.newTTFLabel({text = CommonText[1084][9], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(toChangeBtn)
	lb_Change1:setAnchorPoint(cc.p(0.5,0.5))
	lb_Change1:setPosition(toChangeBtn:width()*0.5 , toChangeBtn:height() * 0.5 + 8)

	-- 剩余免费
	local lb_Change2 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(toChangeBtn)
	lb_Change2:setAnchorPoint(cc.p(1,0.5))
	lb_Change2:setPosition(toChangeBtn:width()*0.5 , toChangeBtn:height() * 0.5 - 15)
	self.m_lbFreeTimes = lb_Change2

	local lb_Change2_num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(toChangeBtn)
	lb_Change2_num:setAnchorPoint(cc.p(0,0.5))
	lb_Change2_num:setPosition(toChangeBtn:width()*0.5 , toChangeBtn:height() * 0.5 - 15)
	self.m_lbFreeTimes2 = lb_Change2_num

	local sp_Changecoin2 = UiUtil.createItemSprite(ITEM_KIND_COIN,1):addTo(toChangeBtn)
	sp_Changecoin2:setAnchorPoint(cc.p(0,0.5))
	sp_Changecoin2:setPosition(0, 0)
	sp_Changecoin2:setVisible(false)
	self.m_lbFreeTimesCoin = sp_Changecoin2

	self.updateStateOver1 = false
	-- 发送消息 拉取歼敌活动信息
	self:sendInfo1()
end

function ActivityMedalView:sendInfo1()
	ActivityCenterBO.GetActMedalofhonorInfo(handler(self,self.updateInfo1))
end

-- 兑换活动UI
function ActivityMedalView:showTable2(container)

	local lb_MyMedal = ui.newTTFLabel({text = CommonText[1084][3], font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(container)
	lb_MyMedal:setAnchorPoint(cc.p(0,0.5))
	lb_MyMedal:setPosition(30  , container:height() - lb_MyMedal:height() - 5)

	local sp_medal = display.newSprite(IMAGE_COMMON .. "medal.png"):addTo(container)
	sp_medal:setAnchorPoint(cc.p(0,0.5))
	sp_medal:setPosition(lb_MyMedal:x() + lb_MyMedal:width(), lb_MyMedal:y())

	local lb_MyMedal_Num = ui.newTTFLabel({text = "0", font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 200, 10)}):addTo(container)
	lb_MyMedal_Num:setAnchorPoint(cc.p(0,0.5))
	lb_MyMedal_Num:setPosition(sp_medal:x() + sp_medal:width() + 5 , lb_MyMedal:y())
	self.lb_MyMedal_Num = lb_MyMedal_Num

	local size = cc.size(container:getContentSize().width - 10, container:getContentSize().height - sp_medal:height()  - 20)
	local view = MedalConvertibilityTableView.new(size,handler(self,self.updateCoinOfTable2)):addTo(container)
	view:setAnchorPoint(cc.p(0,0))
	view:setPosition(5,15)

	self:updateCoinOfTable2()
end

-- 排行榜活动UI
function ActivityMedalView:showTable3(container)
	--吃鸡
	local lb_chicken = ui.newTTFLabel({text = CommonText[1084][4], font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(container)
	lb_chicken:setAnchorPoint(cc.p(0,0.5))
	lb_chicken:setPosition(30  , container:height() - 25)

	local lb_chicken_num = ui.newTTFLabel({text = "0", font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 200, 10)}):addTo(container)
	lb_chicken_num:setAnchorPoint(cc.p(0,0.5))
	lb_chicken_num:setPosition(lb_chicken:x() + lb_chicken:width()  , lb_chicken:y())
	self.lb_chicken_num = lb_chicken_num

	-- 排名
	local lb_rank = ui.newTTFLabel({text = CommonText[1084][5], font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(container)
	lb_rank:setAnchorPoint(cc.p(0,0.5))
	lb_rank:setPosition(container:width() * 0.5  , lb_chicken:y())

	local lb_rank_num = ui.newTTFLabel({text = CommonText[392], font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 0, 0)}):addTo(container)
	lb_rank_num:setAnchorPoint(cc.p(0,0.5))
	lb_rank_num:setPosition(lb_rank:x() + lb_rank:width() + 5, lb_chicken:y())
	self.lb_rank_num = lb_rank_num

	-- 
	local lb_tip = ui.newTTFLabel({text = CommonText[764][3], font = G_FONT, size = 22, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(container)
	lb_tip:setAnchorPoint(cc.p(0,0.5))
	lb_tip:setPosition(30 , lb_chicken:y() - 35) -- lb_chicken:height() - lb_tip:height() * 0.5)

	-- 领奖时间
	local lb_awardtime = ui.newTTFLabel({text = CommonText[1084][7], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 255, 10)}):addTo(container)
	lb_awardtime:setAnchorPoint(cc.p(0,0.5))
	lb_awardtime:setPosition(container:width() * 0.5 , lb_tip:y())
	lb_awardtime:setVisible(false)
	self.lb_awardtime = lb_awardtime

	-- 领奖时间 number
	local lb_awardtime_num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(10, 255, 10)}):addTo(container)
	lb_awardtime_num:setAnchorPoint(cc.p(0,0.5))
	lb_awardtime_num:setPosition(lb_awardtime:x() + lb_awardtime:width() , lb_awardtime:y())
	lb_awardtime_num:setVisible(false)
	self.lb_awardtime_num = lb_awardtime_num
	self.lb_awardtime_num_state = false


	local function findCallback(tag , sender)
		MedalAwardDialog.new(self.m_activity.awardId):push()
	end
	-- 查看奖励
	local findGoldBtn = UiUtil.button("btn_1_normal.png", "btn_1_selected.png", "btn_1_disabled.png",findCallback,CommonText[769][1]):addTo(container)
	findGoldBtn:setAnchorPoint(cc.p(0.5,0.5))
	findGoldBtn:setPosition(container:width() * 0.25, findGoldBtn:height() * 0.65)
	-- self.findGoldBtn = findGoldBtn

	-- 领取奖励
	local getGoldBtn = UiUtil.button("btn_1_normal.png", "btn_1_selected.png", "btn_1_disabled.png",handler(self,self.getGoldCallback),CommonText[769][2]):addTo(container)
	getGoldBtn:setAnchorPoint(cc.p(0.5,0.5))
	getGoldBtn:setPosition(container:width() * 0.75, getGoldBtn:height() * 0.65)
	getGoldBtn:setEnabled(false)
	self.getGoldBtn = getGoldBtn
	
	-- 排行列表
	local ruanSize = cc.size(container:width() - 30, lb_rank:y() - lb_rank:height() * 0.5 - (findGoldBtn:y() + findGoldBtn:height()) )
	local rankbg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	rankbg:setPreferredSize(ruanSize)
	rankbg:setCapInsets(cc.rect(80, 60, 1, 1))
	rankbg:setAnchorPoint(cc.p(0.5,0))
	rankbg:setPosition(container:width() * 0.5, findGoldBtn:y() + findGoldBtn:height() * 0.55)

	-- 排行列表 排名
	local bg_rank = ui.newTTFLabel({text = CommonText[268], font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(rankbg)
	bg_rank:setAnchorPoint(cc.p(0.5,0.5))
	bg_rank:setPosition(rankbg:width() * 0.15  , rankbg:height() - 25 )

	-- 排行列表 角色名
	local bg_name = ui.newTTFLabel({text = CommonText[804][2], font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(rankbg)
	bg_name:setAnchorPoint(cc.p(0.5,0.5))
	bg_name:setPosition(rankbg:width() * 0.45 , rankbg:height() - 25)

	-- 排行列表 吃鸡数
	local bg_chicken = ui.newTTFLabel({text = CommonText[1084][10], font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(rankbg)
	bg_chicken:setAnchorPoint(cc.p(0.5,0.5))
	bg_chicken:setPosition(rankbg:width() * 0.8 , rankbg:height() - 25)

	-- view
	local viewSize = cc.size(rankbg:width() *0.9, rankbg:height() * 0.9)
	local view = MedalRankTableView.new(viewSize):addTo(rankbg)
	view:setAnchorPoint(cc.p(0.5,0))
	view:setPosition(rankbg:width() * 0.5, 20)
	self.rankview = view

	self.updateStateOver3 = false
	-- 拉去排行榜
	self:sendInfo3()
end

function ActivityMedalView:sendInfo3()
 	ActivityCenterBO.GetActMedalofhonorRankInfo(handler(self,self.updateInfo3))
end 

function ActivityMedalView:updateInfo3(data)
	-- optional int32 score = 1;                   //我的积分
	-- repeated ActPlayerRank actPlayerRank = 2;   //排行榜
	-- optional bool open = 3;                     //true可领奖励 1 不可领奖
	-- repeated RankAward rankAward = 4;           //排名奖励信息
	-- optional int32 status = 5;                  //0未领 1已领
	--
	self.lb_chicken_num:setString(data.score)
	-- dump(data,"updateInfo3")
	--
	if data.open then
		self.lb_awardtime:setVisible(true)
		self.lb_awardtime_num:setVisible(true)
	end

	local isInRank = false
	--  
	local actPlayerRank = PbProtocol.decodeArray(data["actPlayerRank"])
	for index = 1 , #actPlayerRank do
		local actPlayer = actPlayerRank[index]
		if actPlayer.lordId == UserMO.lordId_ then
			self.lb_rank_num:setString(index)
			self.lb_rank_num:setColor(cc.c3b(10, 240, 10))
			isInRank = true
		end
	end

	if data.status == 0 then
		if data.open and isInRank then
			self.getGoldBtn:setLabel(CommonText[255])
			self.getGoldBtn:setEnabled(true)
		end
	else
		self.getGoldBtn:setLabel(CommonText[747])
	end

	self.rankview:doReloadData(actPlayerRank)

	self.lb_awardtime_num_state = true
end


function ActivityMedalView:updateInfo1(data)
	local targetIdData = data.targetId -- 奖励数据
	local medalHonor = data.medalHonor -- 勋章数量
	self.usedTimes = data.count -- 次数
	local adds = ActivityCenterMO.ActivityMedalInfo.ten and 10 or 1
	self:CheckTimes(adds)

	local activityTime = self.m_activity.endTime - ManagerTimer.getTime()
	local isActivity = (activityTime >= 0 )
	
	self.m_centerWin:UpdateForUI(targetIdData, medalHonor, isActivity)

	self.lb_time_num_state = true

	if not isActivity then
		if not self.updateStateOver1 then
			self.lb_time_num:setString(CommonText[10017][4])
			self.updateStateOver1 = true
		end
	end
end


function ActivityMedalView:toSearchForMedal(tag , sender)
	-- 有动画播放中
	if self.m_centerWin:IsActionState() then return end

	local forceResult = ActivityCenterMO.ActivityMedalInfo.three and 1 or 0 -- 0: 不指定搜索结果, 1: 指定搜索结果(必定3橙)
	local searchType = ActivityCenterMO.ActivityMedalInfo.ten and 1 or 0 -- 0: 单次搜索, 1: 使用一键十倍

	local function parseResult(data)
		sender:setEnabled(false)

		local adds = ((searchType == 1) and 10 or 1)
		self.usedTimes = self.usedTimes + adds
		self:CheckTimes(adds)

		self.searcheffect:setVisible(true)
		self.searcheffect:getAnimation():playWithIndex(0)

		-- 搜索
		local function updateBgAndFightercallback()
			self.searcheffect:setVisible(false)
			-- self.searcheffect:stopAction()
			self.m_centerWin:updateItem(data.targetId)
		end
		self.m_centerWin:clearScreenItem()
		self.m_centerWin:updateBgAndFighter(updateBgAndFightercallback)
		
	end

	local function doSearch()
		
		ActivityCenterBO.SearchActMedalofhonorTargets(parseResult,forceResult,searchType)
	end

	-- 锁敌
	local function doCheckPrice()
		local thisTimes = (searchType == 1) and 10 or 1
		local freetimes = self.usedTimes - self.m_medalExplore.freeCount 
		local times = freetimes + thisTimes
		local coins = 0
		if times >= 1 then
			coins = self:getPrice(math.max(0,freetimes), math.min(times,thisTimes))
		end
		coins = coins + ((forceResult == 1) and 100 or 0) * thisTimes

		print( ((searchType == 1) and "十倍搜索" or "单次搜索") .. " - " .. ((forceResult == 1) and " 指定结果(必定3橙)" or "不指定结果") .. ( freetimes < 0 and tostring(" " .. -freetimes .. "次免费且") or "")  .. " 花费：" .. coins .. "金币" .. " useTimes " .. self.usedTimes)


		local myCoin = UserMO.getResource(ITEM_KIND_COIN)

		if myCoin >= coins then
			if UserMO.consumeConfirm and coins ~= 0 then
				local resData = UserMO.getResourceData(ITEM_KIND_COIN)
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText[1089], coins, resData.name), function() doSearch() end):push()
			else
				doSearch()
			end
		else
			-- 前往充值
			local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
			TipsAnyThingDialog.new(CommonText[1094][2], function() 
					-- require("app.view.RechargeView").new():push()
					RechargeBO.openRechargeView()
				end,CommonText[1094][1]):push()
		end
	end

	doCheckPrice()
end


function ActivityMedalView:CheckTimes(add)
	local frees = self.m_medalExplore.freeCount
	if frees > self.usedTimes then -- 免费
		local times = frees - self.usedTimes
		self.m_lbFreeTimes:setString(CommonText[1090][1])
		self.m_lbFreeTimes2:setString(times .. CommonText[237][3])
		self.m_lbFreeTimes2:setPosition(self.m_lbFreeTimes:x() ,self.m_lbFreeTimes:y())
		self.m_lbFreeTimesCoin:setVisible(false)
	else -- 收费
		local times = self.usedTimes - frees
		local coins = self:getPrice(times, add)
		print(times .. " " .. self.usedTimes .. " " .. frees .. "   " .. coins  .. "   " .. UserMO.coin_)
		self.m_lbFreeTimes:setString(CommonText[1090][2])
		self.m_lbFreeTimesCoin:setVisible(true)
		self.m_lbFreeTimesCoin:setPosition(self.m_lbFreeTimes:x() , self.m_lbFreeTimes2:y())
		self.m_lbFreeTimes2:setString( tostring(coins) )
		self.m_lbFreeTimes2:setPosition(self.m_lbFreeTimesCoin:x() + self.m_lbFreeTimesCoin:width(),self.m_lbFreeTimes2:y())
	end
end

-- 根据次数获取价格
-- nowtime 当前次数 
-- adds 增加次数
function ActivityMedalView:getPrice(nowtime, adds)
	adds = adds or 1
	local total = 0
	local sec = json.decode(self.m_medalExplore.price)
	for i=nowtime + 1,nowtime + adds do
		local t = sec[1][2]
		for k,v in ipairs(sec) do
			if i > v[1] and i <= sec[k+1][1] then
				t = sec[k+1][2]
				break
			end
		end
		total = total + t
	end
	return total
end



-- 兑换界面 刷新COIN
function ActivityMedalView:updateCoinOfTable2()
	self.lb_MyMedal_Num:setString(ActivityCenterMO.ActivityMedalInfo.price)
end


-- 领取排行奖励
function ActivityMedalView:getGoldCallback(tag, sender)
	local function doCallBack()
		sender:setEnabled(false)
		sender:setLabel(CommonText[672][2])
	end
	ActivityCenterBO.GetActMedalofhonorRankAward(doCallBack)
end

return ActivityMedalView