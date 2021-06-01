--
-- 兄弟同心
--
--
local Dialog = require("app.dialog.Dialog")

-- 计算平均位置 以中心点为准
local function CalculateX( all, index, width, dexScaleOfWidth)
	-- body
	local c = all + 1
	local q = c / 2
	local sw = width * dexScaleOfWidth
	local w = q * sw
	return index * sw - w
end


----------------------------------------------------------
--						奖励显示						--
----------------------------------------------------------
-- 奖励显示

local GiftShowDilog = class("GiftShowDilog", Dialog)

function GiftShowDilog:ctor(showdata,text)
	GiftShowDilog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 330)})
	self.Showdata = showdata
	self.text = text or ""
end

function GiftShowDilog:onEnter()
	GiftShowDilog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:hasCloseButton(true)
	self:setTitle(CommonText[1057][2])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(558, 300))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local lb_time_title = ui.newTTFLabel({text = self.text, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(self:getBg())
	lb_time_title:setPosition(self:getBg():getContentSize().width / 2 , self:getBg():getContentSize().height * 0.5 + 70)


	local centerX = self:getBg():getContentSize().width * 0.5
	local size = #self.Showdata

	for index = 1 , size do
		local _db = self.Showdata[index]
		local kind , id ,count = _db[1], _db[2], _db[3]

		-- 元素
		local item = UiUtil.createItemView(kind,id,{count = count}):addTo(self:getBg())
		item:setPosition(centerX + CalculateX(size, index,  item:getContentSize().width , 1.2) ,self:getBg():getContentSize().height * 0.5 - 10)
		UiUtil.createItemDetailButton(item)

		local namedata = UserMO.getResourceData(kind,id)
		local name = UiUtil.label(namedata.name2,FONT_SIZE_SMALL,COLOR[1]):addTo(self:getBg())
		name:setPosition(item:getPositionX() , item:getPositionY() - item:getContentSize().height * 0.5 - name:getContentSize().height * 0.5 - 10)

	end
end

function GiftShowDilog:onExit()
	GiftShowDilog.super.onExit(self)
	-- body
end






------------------------------------------------------
--				 	推送消息						--
------------------------------------------------------
local BrotherNotifyTableView = class("BrotherNotifyTableView", TableView)
function BrotherNotifyTableView:ctor(size)
	BrotherNotifyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 30)
	self:showSlider(true,nil,{bar = "image/common/scroll_head_5.png", bg = "image/common/scroll_bg_5.png",isShow = true})
	self.m_data = ActivityCenterMO.ActivityBrotherList
	self.m_radio_str_list = ActivityCenterMO.getActBrotherRadio()
	self.m_radio_num = #self.m_radio_str_list
end

function BrotherNotifyTableView:onEnter()
	BrotherNotifyTableView.super.onEnter(self)
	--注册一个监听，每次后端推送数据过来就做一次刷新
	self.m_refineHandler = Notify.register("ACTIVITY_NOTIFY_BROTHER_NOTES", handler(self, self.updateUI))
end

function BrotherNotifyTableView:numberOfCells()
	return #self.m_data
end

function BrotherNotifyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function BrotherNotifyTableView:createCellAtIndex(cell, index)
	BrotherNotifyTableView.super.createCellAtIndex(self, cell, index)
	local _data = self.m_data[index]
	
	local _info = ActivityCenterMO.getActBrotherBuff(_data.id)
	-- local _news = ActivityCenterMO.getActBrotherRadio(_data.id)
	local dolbstr = _info.level == 1 and CommonText[1077][3] or CommonText[1077][4]

	local nametable = {{content = _data.nick, underline = true, color = cc.c3b(10,250,10)},{content= dolbstr}}
	local name = RichLabel.new(nametable,cc.size(0, 0)):addTo(cell)
	name:setAnchorPoint(cc.p(0,1))
	name:setPosition(20,self.m_cellSize.height * 0.5 + name:getHeight() * 0.5)

	-- 图标
	local attr = AttributeMO.queryAttributeById(_info.type)
	local sprite = display.newSprite("image/item/attr_" .. attr.attrName ..".jpg" ):addTo(cell, 1)
	sprite:setScale(0.3)
	sprite:setAnchorPoint(cc.p(0,0.5))
	sprite:setPosition(name:x() + name:getWidth() , self.m_cellSize.height * 0.5)

	local buffnamelb = UiUtil.label(_info.name):addTo(cell, 2)
	buffnamelb:setAnchorPoint(cc.p(0,0.5))
	buffnamelb:setPosition(sprite:x() + sprite:width() * 0.3 + 3, self.m_cellSize.height * 0.5)

	local random = (math.random(self.m_radio_num * 10) % self.m_radio_num) + 1
	local _radio = self.m_radio_str_list[random]
	local radiolb = UiUtil.label("," .. _radio.radio):addTo(cell)
	radiolb:setAnchorPoint(cc.p(0,0.5))
	radiolb:setPosition(buffnamelb:x() + buffnamelb:width(), self.m_cellSize.height * 0.5)

	return cell
end

function BrotherNotifyTableView:updateUI()
	self.m_data = ActivityCenterMO.ActivityBrotherList
	self:reloadData()
	self:onViewOffset()
end

function BrotherNotifyTableView:onViewOffset(tableView, offset)
	local maxOffset = self:maxContainerOffset()
	local minOffset = self:minContainerOffset()
	if minOffset.y > maxOffset.y or not offset then
	    local y = math.max(maxOffset.y, minOffset.y)
	    self:setContentOffset(cc.p(0, y))
    elseif offset then
	    self:setContentOffset(offset)
    end
end

function BrotherNotifyTableView:onExit()
	BrotherNotifyTableView.super.onExit(self)
	if self.m_refineHandler then
		Notify.unregister(self.m_refineHandler)
		self.m_refineHandler = nil
	end
end





------------------------------------------------------
--				 	飞艇BUFF						--
------------------------------------------------------
local BrotherBuffTableView = class("BrotherBuffTableView", TableView)
function BrotherBuffTableView:ctor(size)
	BrotherBuffTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 150)
	self.dataLists = {}
end

function BrotherBuffTableView:onEnter()
	BrotherBuffTableView.super.onEnter(self)
end

function BrotherBuffTableView:updateUI(data)
	-- body
	self.dataLists = {}
	for index = 1, #data do
		local _id = data[index]
		local _d = ActivityCenterMO.getActBrotherBuff(_id)
		self.dataLists[#self.dataLists + 1] = _d
	end

	local function mysort(a,b)
		return a.id < b.id
	end
	self:reloadData()
end

function BrotherBuffTableView:numberOfCells()
	return #self.dataLists
end

function BrotherBuffTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function BrotherBuffTableView:createCellAtIndex(cell, index)
	BrotherBuffTableView.super.createCellAtIndex(self, cell, index)
	local buffdata = self.dataLists[index]

	-- 背景
	local spriteBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	spriteBg:setPreferredSize(cc.size(self.m_cellSize.width - 10, self.m_cellSize.height - 10))
	spriteBg:setPosition(self.m_cellSize.width * 0.5, self.m_cellSize.height * 0.5)

	local attr = AttributeMO.queryAttributeById(buffdata.type)
	-- 图标
	local sprite = display.newSprite("image/item/attr_" .. attr.attrName ..".jpg" ):addTo(cell, 1)
	sprite:setPosition(sprite:width() * 0.9, self.m_cellSize.height * 0.5)
	local spriteb = display.newSprite(IMAGE_COMMON .. "item_fame_1.png" ):addTo(sprite)
	spriteb:setPosition(sprite:width() * 0.5, sprite:height() * 0.5)

	-- 名称等级
	local nameAndLv = ui.newTTFLabel({text =  buffdata.name .. "LV." .. buffdata.level, font = G_FONT, size = FONT_SIZE_TINY, x = 0, y = 0, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell, 1)
	nameAndLv:setAnchorPoint(cc.p(0,0.5))
	nameAndLv:setPosition(sprite:width() * (0.9 + 0.5 + 0.2), self.m_cellSize.height * 0.5 + 40)

	-- up
	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
	local upLevelBuffbtn = MenuButton.new(normal, selected, disabled, handler(self, self.doUp)):addTo(cell, 1)
	upLevelBuffbtn:setAnchorPoint(cc.p(1,0.5))
	upLevelBuffbtn:setPosition(self.m_cellSize.width - upLevelBuffbtn:width() * 0.4, self.m_cellSize.height * 0.5 - 15)
	upLevelBuffbtn.type = buffdata.type
	upLevelBuffbtn.price = buffdata.price

	-- coin ITEM_KIND_COIN
	local coin = UiUtil.createItemSprite(ITEM_KIND_COIN,0,{count = buffdata.price}):addTo(cell)
	coin:setAnchorPoint(cc.p(0,0.5))
	coin:setPosition(upLevelBuffbtn:x() - upLevelBuffbtn:width() + 5 , self.m_cellSize.height * 0.5 + 40)

	-- 价格
	local price = ui.newTTFLabel({text = buffdata.price , font = G_FONT, size = FONT_SIZE_SMALL, x = 0, y = 0, color = cc.c3b(10, 250, 250), align = ui.TEXT_ALIGN_CENTER}):addTo(cell, 1)
	price:setAnchorPoint(cc.p(0,0.5))
	price:setPosition(coin:x() + coin:width() + 5, coin:y())

	if buffdata.level >= 10 then
		upLevelBuffbtn:setEnabled(false)
		coin:setVisible(false)
		price:setVisible(false)
	end

	-- desc
	local width_ = upLevelBuffbtn:x() - upLevelBuffbtn:width() - sprite:width() * (0.9 + 0.5 + 0.2)
	local desc = ui.newTTFLabel({text =  buffdata.desc , font = G_FONT, size = FONT_SIZE_TINY, x = 0, y = 0, color = COLOR[1],
		 align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(width_, 0)}):addTo(cell, 1)
	desc:setAnchorPoint(cc.p(0,0.5))
	desc:setPosition(sprite:width() * (0.9 + 0.5 + 0.2), self.m_cellSize.height * 0.5)

	return cell
end

function BrotherBuffTableView:doUp(tag, sender)
	ManagerSound.playNormalButtonSound()
	local price = sender.price
	local _type = sender.type

	local function doUpLevel(data)
		UserMO.reduceResource(ITEM_KIND_COIN, price)
		local buffId = data.buffId
		-- 刷新界面
		-- 推送本地消息
		Notify.notify("ACTIVITY_LOCAL_NOTIFY_AIRSHIP_BUFF", {buff = buffId})
	end

	local function gotoBuy()
		ActivityCenterBO.UpBrotherBuff(doUpLevel,_type)
	end

	if UserMO.consumeConfirm then
		local resData = UserMO.getResourceData(ITEM_KIND_COIN)

		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1077][7], price, resData.name), function() gotoBuy() end):push()
	else
		gotoBuy()
	end
end

function BrotherBuffTableView:onExit()
	BrotherBuffTableView.super.onExit(self)
end

------------------------------------------------------
--				 	飞艇BUFF Dialog					--
------------------------------------------------------

local BrotherBuffDialog = class("BrotherBuffDialog", Dialog)

function BrotherBuffDialog:ctor(data,closeCallback)
	BrotherBuffDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(display.width * 0.9, display.height*0.9)})
	self.data = data
	self.closeCallback = closeCallback
end

function BrotherBuffDialog:onEnter()
	BrotherBuffDialog.super.onEnter(self)

	self:setTitle(CommonText[1077][5])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(display.width*0.9-50, display.height*0.9-50))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local size = cc.size(self:getBg():getContentSize().width*0.9, self:getBg():getContentSize().height*0.9 - 20)
	local view = BrotherBuffTableView.new(size):addTo(self:getBg(), 1)
	view:setPosition(self:getBg():getContentSize().width * 0.05, 40 )
	view:updateUI(self.data)
	self.view = view
end

function BrotherBuffDialog:UpdateUi(data)
	Toast.show(CommonText[1077][9])
	self.view:updateUI(data)
end

function BrotherBuffDialog:CloseAndCallback()
	if self.closeCallback then self.closeCallback() end
end

function BrotherBuffDialog:onExit()
	BrotherBuffDialog.super.onExit(self)
end








------------------------------------------------------
--				兄弟同心 飞艇活动					--
------------------------------------------------------

local ActivityBrotherBuffView = class("ActivityBrotherBuffView", UiNode)

function ActivityBrotherBuffView:ctor(activity)
	ActivityBrotherBuffView.super.ctor(self, "image/common/bg_ui.jpg")
	self.m_activity = activity
end

function ActivityBrotherBuffView:onEnter()
	ActivityBrotherBuffView.super.onEnter(self)
	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)

	-- 顶部背景
	local topbg = display.newSprite(IMAGE_COMMON .. "brother.jpg"):addTo(self:getBg())
	topbg:setAnchorPoint(cc.p(0.5,1))
	topbg:setPosition(self:getBg():getContentSize().width * 0.5, self:getBg():getContentSize().height - 100)
	self.topbg = topbg

	-- tips
	local function tipsCallback()
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.BrotherTips):push()
	end
	local tips = UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil,tipsCallback):addTo(topbg)
	tips:setPosition(self:getBg():getContentSize().width - 85 , 40)

	--timeTitle
	local lb_time_title = ui.newTTFLabel({text = CommonText[853], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(topbg)
	lb_time_title:setAnchorPoint(cc.p(0,0.5))
	lb_time_title:setPosition(15 , lb_time_title:getContentSize().height * 0.5 + 5)

	--time
	local lb_time = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(topbg)
	lb_time:setAnchorPoint(cc.p(0,0.5))
	lb_time:setPosition(15 + lb_time_title:getContentSize().width , lb_time_title:getContentSize().height * 0.5 + 5)
	self.lb_time = lb_time

	-- buff board
	local buffBoardBg = display.newNode():size(topbg:width() - 10, topbg:height() - 10):addTo(topbg,10)
	buffBoardBg:setAnchorPoint(cc.p(0,0))
	buffBoardBg:setPosition(0,0)
	self.buffBoardBg = buffBoardBg

	local conHeightB = 4.5

	self.m_PageIndex = 1

	-- 任务 背景
	local tipbg = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(self:getBg())
	tipbg:setAnchorPoint(cc.p(0.5,0.5))
	tipbg:setPosition(self:getBg():width() * 0.5, topbg:y() - topbg:height() - tipbg:height() * 0.5)

	local size = cc.size(self:getBg():getContentSize().width - 10 , tipbg:getContentSize().height * conHeightB)

	local pages = {CommonText[1074][1],CommonText[1074][2]}

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height * 0.5 )
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5 )
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
			button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5)
		end
		button:setLabel(pages[index], {color = COLOR[11]})

		return button
	end

	-- 背景
	local function createDelegate(container, index)
		if index == 1 then
			self:showTask(container,index)
		else
			self:showTask2(container,index)
		end
		self.m_PageIndex = index
	end

	local function clickDelegate(container, index)
	end

	-- 页签
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {createDelegate = createDelegate, clickDelegate = clickDelegate, 
		styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback},hideDelete = true,containerLayerLevel = 3}):addTo(tipbg, 2)
	pageView:setAnchorPoint(cc.p(0.5,0))
	pageView:setPosition(tipbg:width() *0.5 , -tipbg:height() * conHeightB)
	pageView:setVisible(false)
	self.pageView = pageView


	-- 去打飞艇
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self,self.goFighterAirship)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width * 0.25, 80)
	btn:setLabel(CommonText[1075][1])

	-- 获得buff
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self,self.goTakeBuff)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width * 0.75, 80)
	btn:setLabel(CommonText[1075][2])


	local heig  =  tipbg:y() - tipbg:height() * conHeightB - (btn:y() + btn:height() * 0.5)
	-- 消息
	local winBg = UiUtil.sprite9("info_bg_90.png", 70, 40, 1, 1, self:getBg():width() - 60, heig):addTo(self:getBg())
	winBg:setAnchorPoint(cc.p(0.5,1))
	winBg:setPosition(self:getBg():width() * 0.5, tipbg:y() - tipbg:height() * conHeightB)
	local arrow = display.newSprite(IMAGE_COMMON.."icon_arrow_3.png"):addTo(winBg):pos(winBg:width() - 40,winBg:height() - 35)
	local arrow2 = display.newSprite(IMAGE_COMMON.."icon_arrow_3.png"):addTo(winBg):pos(winBg:width() - 40,35)
	arrow2:setScaleY(-1)
	local brotherNotify = BrotherNotifyTableView.new(cc.size(winBg:width() - 40,winBg:height() - 40)):addTo(self:getBg())
	brotherNotify:setAnchorPoint(cc.p(0,0.5))
	brotherNotify:setPosition(40,winBg:y() - winBg:height() / 2 )
	brotherNotify:reloadData()


	--注册消息 接受来自充值的回调
	self.notifyhandler = Notify.register("ACTIVITY_LOCAL_NOTIFY_AIRSHIP_BUFF", handler(self, self.BuffData))

	--注册一个监听，每次后端推送数据过来就做一次刷新
	self.m_BuffHandler = Notify.register("ACTIVITY_NOTIFY_BROTHER_NOTES", handler(self, self.pushBrotherBuffListener))

	--注册一个监听，每次后端推送数据过来就做一次刷新
	self.m_FightHandler = Notify.register("ACTIVITY_NOTIFY_BROTHER_FIGHT_NOTES", handler(self, self.doLoadInfo))

	self.taskData = {}

	self.timeEndTag = -1

	self.buffDialog = nil

	self.taskTipName = {CommonText[1076][1],CommonText[1076][2]}

	-- 刷新时间
	if not self.timeScheduler then
		self.timeScheduler = scheduler.scheduleGlobal(handler(self,self.update), 1)
	end

	self:doLoadInfo()
end

-- 秒更新 倒计时
function ActivityBrotherBuffView:update( ft )
	if self.lb_time then
		local time = self.m_activity.endTime - ManagerTimer.getTime()
		if time >= 0 then 
			self.lb_time:setString(UiUtil.strBuildTime(time))
		else
			self.lb_time:setString(UiUtil.strBuildTime(0))
			self.timeEndTag = self.timeEndTag + 1
			if self.timeEndTag == 0 then
				self:doLoadInfo()
			end
		end
	end
end

function ActivityBrotherBuffView:doLoadInfo()
	ActivityCenterBO.GetActBrotherTask(handler(self,self.loadInfo))
	if self.buffDialog then 
		UiDirector.pop()
		self.buffDialog = nil
	end
end

function ActivityBrotherBuffView:loadInfo(data)
	-- 数据
	self.taskData = PbProtocol.decodeArray(data["task"])	-- 任务
	local buffId = data.buffId 								-- buff
	-- dump(self.buffId)
	local out = {buff = buffId}
	local buffdata = {}
	buffdata.obj = out

	-- UI
	self.pageView:setVisible(true)
	self.pageView:setPageIndex(self.m_PageIndex)			-- 任务
	self:BuffData(buffdata)									-- buff
end

-- buff 数据处理
function ActivityBrotherBuffView:BuffData(event)
	local data = event.obj.buff
	self.buffId = data
	self:showBuffBar()
	if self.buffDialog then
		self.buffDialog:UpdateUi(self.buffId)
	end
end

-- 刷新 buff 列表bar
function ActivityBrotherBuffView:showBuffBar()
	local buffdata = self.buffId
	local brother_ = ActivityCenterMO.getActBrother()
	local _descs = string.format(CommonText[1077][1],brother_[1].reduceloss)
	local allbuffdata = {{attrName = "fightloss", desc = _descs}}

	for index = 1 , #buffdata do
		local _buffId = buffdata[index]
		local _buff = ActivityCenterMO.getActBrotherBuff(_buffId)
		if _buff.level > 0 then
			local attr = AttributeMO.queryAttributeById(_buff.type)
			local out = {}
			out.attrName = attr.attrName
			out.desc = _buff.desc
			allbuffdata[#allbuffdata + 1] = out
		end
	end

	self.buffBoardBg:removeAllChildren()

	local buffBoard = display.newScale9Sprite(IMAGE_COMMON .. "bar_bg_12.png"):addTo(self.buffBoardBg)
	buffBoard:setPreferredSize(cc.size(450, 50))
	buffBoard:setAnchorPoint(cc.p(0,1))
	buffBoard:setVisible(false)

	local buffLb = ui.newTTFLabel({text = "", font = G_FONT, color = ccc3(255,255,255), size = FONT_SIZE_LIMIT, x = 0, y = 0,
				dimensions = cc.size(buffBoard:width() * 0.9, 0), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(buffBoard)
	buffLb:setAnchorPoint(cc.p(0,1))

	local function showInof(node,text)
		node:setTouchEnabled(true)
		node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				return true
			elseif event.name == "ended" then
				buffBoard:setVisible(true)
				buffLb:setString(text)
				buffLb:setPosition(10,buffBoard:height() - 10)
			end
		end)
	end

	local _scale = 0.5

	local buffsprite = nil
	for index = 1 , #allbuffdata do
		local attr = allbuffdata[index]

		-- 图标
		buffsprite = display.newSprite("image/item/attr_" .. attr.attrName ..".jpg" ):addTo(self.buffBoardBg, 1)
		buffsprite:setScale(_scale)
		buffsprite:setAnchorPoint(cc.p(1,1))
		buffsprite:setPosition((buffsprite:width() + 20) * index * _scale + 10 , self.buffBoardBg:height() )
		local spriteb = display.newSprite(IMAGE_COMMON .. "item_fame_1.png" ):addTo(buffsprite)
		spriteb:setPosition(buffsprite:width() * 0.5, buffsprite:height() * 0.5)
		showInof(buffsprite,attr.desc)
	end

	if buffsprite then
		buffBoard:setPosition(10,buffsprite:y() - buffsprite:height() * _scale - 10)
	end
	
end

-- 任务
function ActivityBrotherBuffView:showTask(container,index)
	-- body
	--任务标题BG
	local taskbg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	taskbg:setAnchorPoint(cc.p(0,1))
	taskbg:setPosition(10, container:height() - 10)

	local valuelb = ui.newTTFLabel({text =  self.taskTipName[index] , font = G_FONT, size = FONT_SIZE_SMALL, x = 0, y = 0, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(taskbg)
	valuelb:setAnchorPoint(cc.p(0,0.5))
	valuelb:setPosition(50, taskbg:height() * 0.5)

	local taskUIWidth = container:width() * 0.8
	local widthRight = container:width() * 0.5 + taskUIWidth * 0.5

	local datalist = {}
	for _index = 1 , #self.taskData do
		local twoint = self.taskData[_index]
		local data = ActivityCenterMO.getActBrotherTask(twoint.v1)
		if data.type == index then
			local out = clone(data)
			out.state = twoint.v2
			datalist[#datalist + 1] = out
		end
	end

	local function mysort(a,b)
		return a.id > b.id
	end
	table.sort(datalist,mysort)

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(taskUIWidth, 50),
	 			{bgName = IMAGE_COMMON .. "bar_bg_1.png", bgScale9Size = cc.size(taskUIWidth + 4, 36)}):addTo(container)

	local barSizeNum = datalist and table.getn(datalist)
	local dexWidth = taskUIWidth / barSizeNum
	local per = 0

	for _index = 1 , barSizeNum do
		local _x = widthRight - (_index - 1) * dexWidth
		local _y = taskbg:y() - taskbg:height() - 10

		local data = datalist[_index]
		local state = data.state
		local itemIcon = data.icon
		if state >= 1 then
			itemIcon = string.gsub(itemIcon,"normal","open")
		end
		--宝箱 new_active_normal4	new_active_open4
		local item = display.newSprite(IMAGE_COMMON .. itemIcon .. ".png"):addTo(container, 5)
		item:setAnchorPoint(cc.p(0.75,0))
		item:setPosition(_x, _y - item:height())
		item.state = state
		item.awards = data.awards
		item.id = data.id
		item.text = self.taskTipName[index] .. " (" .. data.number .. CommonText[1077][6] .. ")"

		if state <= 0 then
			local anchor = 0.5
			if _index == 1 then anchor = 1 end
			self:showTips(item,anchor)
			if state == 0 then
				item:run{
						"rep",
						{
							"seq",
							{"delay",1}, -- math.random(1,2)
							{"rotateTo",0,-5},
							{"rotateTo",0.1,5},
							{"rotateTo",0.1,-5},
							{"rotateTo",0.3,0,"ElasticOut"}
						}
					}
			end
		else
			item:setTouchEnabled(false)
		end

		local biao = display.newSprite(IMAGE_COMMON .. "chose_4.png"):addTo(container,6)
		biao:setScale(0.5)
		biao:setRotation(180)
		biao:setAnchorPoint(cc.p(0.5,0.75))
		biao:setPosition(_x - biao:width() * 0.25 * 0.5,item:y() - bar:height() * 0.5 + biao:height() * 0.5 * 0.5 )


		local timsbg = display.newSprite(IMAGE_COMMON .. "bar_bg_6.png"):addTo(container)
		timsbg:setAnchorPoint(cc.p(0.5,1))
		timsbg:setPosition(_x - biao:width() * 0.25 * 0.5, item:y() - bar:height())

		-- 次数
		local timslb = ui.newTTFLabel({text = data.number .. CommonText[1077][6] , font = G_FONT, size = FONT_SIZE_SMALL, x = 0, y = 0, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(timsbg)
		timslb:setAnchorPoint(cc.p(0.5,0.5))
		timslb:setPosition(timsbg:width() * 0.5, timsbg:height() * 0.5)

		bar:setPosition(container:width() * 0.5 , item:y() - bar:height() * 0.5 )

		if state >= 0 then
			per = per + dexWidth
		end
	end
	local pss = per / taskUIWidth
	bar:setPercent(pss)
end

-- 任务2
function ActivityBrotherBuffView:showTask2(container,index)
	-- body
	--任务标题BG
	local taskbg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	taskbg:setAnchorPoint(cc.p(0,1))
	taskbg:setPosition(10, container:height() - 10)

	local valuelb = ui.newTTFLabel({text =  self.taskTipName[index] , font = G_FONT, size = FONT_SIZE_SMALL, x = 0, y = 0, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(taskbg)
	valuelb:setAnchorPoint(cc.p(0,0.5))
	valuelb:setPosition(50, taskbg:height() * 0.5)

	local _x = container:width() * 0.5
	local _y = taskbg:y() - taskbg:height() - 10

	local datalist = {}
	for _index = 1 , #self.taskData do
		local twoint = self.taskData[_index]
		local data = ActivityCenterMO.getActBrotherTask(twoint.v1)
		if data.type == index then
			local out = clone(data)
			out.state = twoint.v2
			datalist[#datalist + 1] = out
		end
	end

	local data = datalist[1]
	local state = data.state
	local itemIcon = data.icon
	if state >= 1 then
		itemIcon = string.gsub(itemIcon,"normal","open")
	end
	--宝箱 new_active_normal4	new_active_open4
	local item = display.newSprite(IMAGE_COMMON .. itemIcon .. ".png"):addTo(container, 5)
	item:setAnchorPoint(cc.p(0.75,0))
	item:setPosition(_x, _y - item:height())
	item.state = state
	item.awards = data.awards
	item.id = data.id
	item.text = CommonText[1077][8]

	if state <= 0 then
		local anchor = 0.5
		if _index == 1 then anchor = 1 end
		self:showTips(item,anchor)
		if state == 0 then
			item:run{
					"rep",
					{
						"seq",
						{"delay",1}, -- math.random(1,2)
						{"rotateTo",0,-5},
						{"rotateTo",0.1,5},
						{"rotateTo",0.1,-5},
						{"rotateTo",0.3,0,"ElasticOut"}
					}
				}
		end
	else
		item:setTouchEnabled(false)
	end

	local biao = display.newSprite(IMAGE_COMMON .. "chose_4.png"):addTo(container,6)
	biao:setScale(0.5)
	biao:setRotation(180)
	biao:setAnchorPoint(cc.p(0.5,0.5))
	biao:setPosition(_x - biao:width() * 0.25 * 0.5,item:y())

	local timsbg = display.newScale9Sprite(IMAGE_COMMON .. "bar_bg_6.png"):addTo(container)
	local timslb = ui.newTTFLabel({text = CommonText[1077][8] , font = G_FONT, size = FONT_SIZE_SMALL, x = 0, y = 0, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(timsbg)
	
	timsbg:setPreferredSize(cc.size(timslb:width() * 1.1, timsbg:height() * 1.2))
	timsbg:setAnchorPoint(cc.p(0.5,0.5))
	timsbg:setPosition(_x - biao:width() * 0.25 * 0.5, biao:y() - biao:height() * 0.5 * 0.5 - timsbg:height() * 0.2)

	timslb:setAnchorPoint(cc.p(0.5,0.5))
	timslb:setPosition(timsbg:width() * 0.5, timsbg:height() * 0.5)
	
end

-- 宝箱提示
function ActivityBrotherBuffView:showTips(node,anchor)
	anchor = anchor or 0.5
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			if node.state < 0 then
				local awards = json.decode(node.awards)
				GiftShowDilog.new(awards,node.text):push()
			elseif node.state == 0 then
				self:GetAward(node.awards,node.id)
			end
			return true
		elseif event.name == "ended" then
		end
	end)
end

-- 领取奖励
function ActivityBrotherBuffView:GetAward(award,id)
	local function getAward(data)
		self.taskData = PbProtocol.decodeArray(data["task"])	-- 任务
		self.pageView:setPageIndex(self.pageView:getPageIndex())
		local awards = json.decode(award)
		local showAwards = {}
		for index = 1 , #awards do
			local dt = awards[index]
			local out = {type = dt[1], id = dt[2], count = dt[3]}
			showAwards[#showAwards + 1] = out
		end
		local ret = CombatBO.addAwards(showAwards)
		UiUtil.showAwards(ret)
	end
	-- getAward()
	ActivityCenterBO.GetBrotherAward(getAward, id)
end

-- 去打飞艇
function ActivityBrotherBuffView:goFighterAirship(tag,sender)
	ManagerSound.playNormalButtonSound()
	local ab = AirshipMO.queryShipById(1)
	UiDirector.popMakeUiTop("HomeView")
	UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
	local pos = WorldMO.decodePosition(ab.pos)
	UiDirector.getTopUi():getCurContainer():onLocate(pos.x, pos.y)
end

-- 获得增益
function ActivityBrotherBuffView:goTakeBuff(tag,sender)
	ManagerSound.playNormalButtonSound()

	-- 没有军团
	if not PartyBO.getMyParty() then
		-- 请先加入一个军团
		Toast.show(CommonText[1077][2])
		return 
	end

	-- 增益
	self.buffDialog = BrotherBuffDialog.new(self.buffId,handler(self,self.BuffDialogCloseCallback)):push()
end

-- 飞艇BUFF框对象 关闭回调
function ActivityBrotherBuffView:BuffDialogCloseCallback()
	self.buffDialog = nil
end

-- buff 升级全局监听
function ActivityBrotherBuffView:pushBrotherBuffListener()
	local _data = ActivityCenterMO.ActivityBrotherList[#ActivityCenterMO.ActivityBrotherList]
	local newDataID = _data.id
	local _info = ActivityCenterMO.getActBrotherBuff(newDataID)
	local changeType = _info.type

	local outdata = {}
	for index = 1 , #self.buffId do
		local _id = self.buffId[index]
		local _infomation = ActivityCenterMO.getActBrotherBuff(_id)
		if _infomation.type == changeType then
			outdata[#outdata + 1] = newDataID
		else
			outdata[#outdata + 1] = _id
		end
	end
	local out = {buff = outdata}
	local buffdata = {}
	buffdata.obj = out
	self:BuffData(buffdata)
end

function ActivityBrotherBuffView:onExit()
	ActivityBrotherBuffView.super.onExit(self)

	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
	end

	if self.notifyhandler then
		Notify.unregister(self.notifyhandler)
		self.notifyhandler = nil
	end

	if self.m_BuffHandler then
		Notify.unregister(self.m_BuffHandler)
		self.m_BuffHandler = nil
	end

	if self.m_FightHandler then
		Notify.unregister(self.m_FightHandler)
		self.m_FightHandler = nil
	end
end

return ActivityBrotherBuffView