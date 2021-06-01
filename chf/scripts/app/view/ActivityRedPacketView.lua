--
--
-- 红包 活动 界面
--
--

--------------------------------------------------------------
--							发送红包						--
--------------------------------------------------------------


local Dialog = require("app.dialog.Dialog")
local SendDialog = class("SendDialog", Dialog)

function SendDialog:ctor(data)
	SendDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_138.jpg", UI_ENTER_NONE, {closeBtn = false})
	self.m_data = data
end

function SendDialog:onEnter()
	SendDialog.super.onEnter(self)

	local limit = self.m_data.limit

	self.m_isWorld = true

	local nomal = display.newSprite(IMAGE_COMMON .. "back_button.png")
	local closeBtn = ScaleButton.new(nomal, handler(self, self.onReturnCallback)):addTo(self:getBg())
	closeBtn:setPosition(30, self:getBg():height() - 35)

	-- title
	local titlelb = ui.newTTFLabel({text = CommonText[1788][1], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self:getBg())
    titlelb:setPosition(130 , closeBtn:y() + 3)

    -- number bg
    local touchContentbg = display.newSprite(IMAGE_COMMON .. "info_bg_139.png"):addTo(self:getBg())
    touchContentbg:setPosition(self:getBg():width() * 0.5, math.floor(self:getBg():height() * 0.75 - 30))

    -- limitlb
    local limitlb = ui.newTTFLabel({text = CommonText[1789][1] .. ":" .. limit .. CommonText[1789][2], font = G_FONT, size = 18, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(touchContentbg)
    limitlb:setPosition(65 , math.floor(touchContentbg:height() + 20))

    local namelb = ui.newTTFLabel({text = CommonText[1789][3], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(touchContentbg)
    namelb:setPosition(35 , touchContentbg:height() * 0.5)

    local unitlb = ui.newTTFLabel({text = CommonText[1789][2], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(touchContentbg)
    unitlb:setPosition(touchContentbg:width() - 20 , touchContentbg:height() * 0.5)

    local inputlb = ui.newTTFLabel({text = "", font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(touchContentbg)
    inputlb:setAnchorPoint(cc.p(1, 0.5))
    inputlb:setPosition(unitlb:x() - unitlb:width() - 10 , touchContentbg:height() * 0.5)
    self.m_number = 0

    local selectlb = ui.newTTFLabel({text = CommonText[1789][4], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(148, 148, 148)}):addTo(touchContentbg)
    selectlb:setPosition( touchContentbg:width() - 100 , touchContentbg:height() * 0.5)

    -- area
    local sendArealb = ui.newTTFLabel({text = CommonText[1790], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self:getBg())
    sendArealb:setAnchorPoint(cc.p(0,0.5))
    sendArealb:setPosition( 25 , touchContentbg:y() -  touchContentbg:height() + 10)

    local checklist = {}
    local function onCheckedChanged(sender, isChecked)
    	local key = sender.key
    	-- for k , v in pairs(checklist) do
    	-- 	if k == key then
    	-- 		v:setChecked(isChecked)
    	-- 	else
    	-- 		v:setChecked(not isChecked)
    	-- 	end
    	-- 	if k == 1 then
    	-- 		self.m_isWorld = isChecked
    	-- 	end
    	-- end
    	if key == 1 then
    		checklist[1]:setChecked(true)
    		checklist[2]:setChecked(false)
    		self.m_isWorld = true
    	elseif key == 2 then
    		if PartyBO.getMyParty() then
    			checklist[1]:setChecked(false)
				checklist[2]:setChecked(true)
				self.m_isWorld = false
    		else
    			checklist[1]:setChecked(true)
				checklist[2]:setChecked(false)
				self.m_isWorld = true
				Toast.show(CommonText[1791])
    		end
    	end
    end

    -- world 
    local worldlb = ui.newTTFLabel({text = CommonText[354][1], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self:getBg())
    worldlb:setAnchorPoint(cc.p(0,0.5))
    worldlb:setPosition( 20 + sendArealb:x() + sendArealb:width() , sendArealb:y() )

   	local uncheckedSprite = display.newSprite(IMAGE_COMMON .. "check0.jpg")
   	uncheckedSprite:setOpacity(128)
	local checkedSprite = display.newSprite(IMAGE_COMMON .. "check1.png")
    local checkBox = CheckBox.new(uncheckedSprite, checkedSprite, onCheckedChanged):addTo(self:getBg())
	checkBox:setPosition(worldlb:x() + worldlb:width() + checkBox:width() * 0.5, worldlb:y() )
	checkBox:setChecked(self.m_isWorld)
	checkBox.key = 1
	checklist[checkBox.key] = checkBox

	-- party
	local partylb = ui.newTTFLabel({text = CommonText[354][2], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(self:getBg())
    partylb:setAnchorPoint(cc.p(0,0.5))
    partylb:setPosition( 20 + checkBox:x() + checkBox:width() , sendArealb:y() )

    local uncheckedSprite = display.newSprite(IMAGE_COMMON .. "check0.jpg")
   	uncheckedSprite:setOpacity(128)
	local checkedSprite = display.newSprite(IMAGE_COMMON .. "check1.png")
    local checkBox2 = CheckBox.new(uncheckedSprite, checkedSprite, onCheckedChanged):addTo(self:getBg())
	checkBox2:setPosition(partylb:x() + partylb:width() + checkBox2:width() * 0.5, partylb:y() )
	checkBox2.key = 2
	checklist[checkBox2.key] = checkBox2	

    local function checkin()
    	if self.m_number > 0 then
    		selectlb:setVisible(false)
    	else
    		selectlb:setVisible(true)
    	end
    end

    checkin()

    local function inputFunc(number, touchNumber)
    	-- body
    	self.m_number = number
    	if self.m_number > 0 then
    		inputlb:setString(tostring(self.m_number))
    	else
    		self.m_number = 0
    		inputlb:setString("")
    	end
    	checkin()
    end

    local point = self:getBg():convertToWorldSpace(cc.p(touchContentbg:x(),touchContentbg:y() ))

   	touchContentbg:setTouchEnabled(true)
	touchContentbg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			local out = {anchor = cc.p(0.5, 1),
						ccp = cc.p(point.x, 	point.y - touchContentbg:height() * 0.5),
						select = self.m_number,
						limit = limit,
						inputfunc = inputFunc}
			require("app.dialog.InputNumberDialog").new(out):push()
		end
	end)


	-- send
    local nomal = display.newSprite(IMAGE_COMMON .. "btn_66_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_66_selected.png")
	local useButton = MenuButton.new(nomal,selected,nil,handler(self, self.sendCallback)):addTo(self:getBg())
	useButton:setPosition(self:getBg():width() * 0.5 , self:getBg():height() * 0.5 - 230)
	useButton:setLabel(CommonText[1792],{y = useButton:height() * 0.5 + 5, size = 30})
	useButton.propId = self.m_data.id

	-- coin
	local coinsp = display.newSprite(IMAGE_COMMON .. "icon_coin_2.png"):addTo(self:getBg())
	coinsp:setAnchorPoint(cc.p(1, 0.5))
	coinsp:setPosition(self:getBg():width() * 0.5 , useButton:y() + useButton:height() * 0.5 + 20)

	local getCoinLabel = ui.newBMFontLabel({text = self.m_data.price .. "", font = "fnt/num_1.fnt", x = self:getBg():width() * 0.5, y = coinsp:y() , align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	getCoinLabel:setAnchorPoint(cc.p(0, 0.5))
	getCoinLabel:setScale(1)

end

function SendDialog:sendCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local number = self.m_number

	if number <= 0 then
		Toast.show(string.format(CommonText[1793],0))
		return
	end
	
	local isparty = not self.m_isWorld
	
	local propId = sender.propId
 
	local function parseResultCallback(data)
		-- body
		Notify.notify("LOACAL_REDPACKET_UPDATE_COUNT")
		self:pop()
		Toast.show(CommonText[551][1])
	end

	ActivityCenterBO.SendActRedBag(parseResultCallback, propId, number, isparty)
end

function SendDialog:onExit()
	SendDialog.super.onExit(self)
end






















--------------------------------------------------------------
--						要发送的红包列表					--
--------------------------------------------------------------
local SendRedPacketTableView = class("SendRedPacketTableView", TableView)

function SendRedPacketTableView:ctor(size, activityid)
	SendRedPacketTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 120)
	self.activityAwardid = activityid
end

function SendRedPacketTableView:onEnter()
	SendRedPacketTableView.super.onEnter(self)
	self.redpacketHanlder = Notify.register("LOACAL_REDPACKET_UPDATE_COUNT", handler(self, self.updateForInfo))
	self:updateForInfo()
end

function SendRedPacketTableView:onExit()
	SendRedPacketTableView.super.onExit(self)
	if self.redpacketHanlder then
		Notify.unregister(self.redpacketHanlder)
	end
end

-- activityID = awardid
function SendRedPacketTableView:updateForInfo()
	-- body

	local list = PropMO.queryActProp(self.activityAwardid)

	self.m_act_prop_list = {}

	for index = 1 , #list do
		local _d = list[index]
		local out = clone(_d)
		out.count = ActivityCenterMO.ActivityRedPacketList[out.id] and ActivityCenterMO.ActivityRedPacketList[out.id].count or 0
		self.m_act_prop_list[#self.m_act_prop_list + 1] = out
	end

	self:reloadData()
end

function SendRedPacketTableView:numberOfCells()
	return #self.m_act_prop_list
end

function SendRedPacketTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SendRedPacketTableView:createCellAtIndex(cell, index)
	SendRedPacketTableView.super.createCellAtIndex(self, cell, index)
	local propInfo = self.m_act_prop_list[index]
	local quality = propInfo.quality

	-- item
	local item = display.newSprite("image/item/" .. propInfo.icon .. ".jpg"):addTo(cell)
	item:setPosition(60 , self.m_cellSize.height * 0.5)

	local itembg = display.newSprite(IMAGE_COMMON .. "item_fame_" .. quality .. ".png"):addTo(item)
	itembg:setPosition(item:width() * 0.5, item:height() * 0.5)

	-- name
	local nameLb = ui.newTTFLabel({text = propInfo.name, font = G_FONT, size = 20, align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80), color = COLOR[quality]}):addTo(cell)
	nameLb:setAnchorPoint(cc.p(0,0.5))
    nameLb:setPosition(120 , self.m_cellSize.height - 25)

	-- desc 
	local descLb = ui.newTTFLabel({text = propInfo.desc, font = G_FONT, size = 20, align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80), color = cc.c3b(255, 255, 255)}):addTo(cell)
	descLb:setAnchorPoint(cc.p(0,0.5))
    descLb:setPosition(120 , self.m_cellSize.height * 0.5 - 12)

    -- number
    local numberLb = ui.newTTFLabel({text = tostring(propInfo.count) .. CommonText[120], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, dimensions = cc.size(220, 80), color = cc.c3b(255, 255, 255)}):addTo(cell)
    numberLb:setPosition(self.m_cellSize.width - 55 , self.m_cellSize.height * 0.5 + 20)

    -- btn
    local nomal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local useButton = MenuButton.new(nomal,selected,disabled,handler(self, self.usePropCallback)):addTo(cell,3)
	useButton:setScale(0.75)
	useButton:setAnchorPoint(cc.p(0.5,0.5))
	useButton:setPosition(self.m_cellSize.width - useButton:width() * 0.5 * 0.75 + 5, self.m_cellSize.height * 0.5 - 20)
	useButton:setLabel(CommonText[553][2])
	if propInfo.count <= 0 then
		useButton:setEnabled(false)
	end

	useButton.propid = propInfo.id
	useButton.price = propInfo.price
	useButton.value = propInfo.value

	 -- line
    local line = display.newSprite(IMAGE_COMMON .. "line2.png"):addTo(cell)
    line:setPosition(self.m_cellSize.width * 0.5, 0)
    line:setScale(self.m_cellSize.width / line:width())

	return cell
end

function SendRedPacketTableView:usePropCallback(tar, sender)
	-- body
	local propid = sender.propid
	local price = sender.price
	local value = sender.value
	local out = {id = propid, price = price, limit = value}
	SendDialog.new(out):push()
end


local Dialog = require("app.dialog.Dialog")
local SendRedPacketDialog = class("SendRedPacketDialog", Dialog)

function SendRedPacketDialog:ctor(activityID)
	SendRedPacketDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 580)})
	self.activityAwardid = activityID
end

function SendRedPacketDialog:onEnter()
	SendRedPacketDialog.super.onEnter(self)
	self:setTitle(CommonText[1788][2])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 550))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)


	local size = cc.size(self:getBg():width() - 60, self:getBg():height() - 90)
	local view = SendRedPacketTableView.new(size, self.activityAwardid):addTo(self:getBg())
	view:setPosition(30,35)
	-- view:drawBoundingBox()
	self.m_view = view
end


function SendRedPacketDialog:onExit()
	SendRedPacketDialog.super.onExit(self)
end

















--------------------------------------------------------------
--						收到的红包列表						--
--------------------------------------------------------------
local RedPacketTableView = class("RedPacketTableView", TableView)

function RedPacketTableView:ctor(size)
	RedPacketTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
end

function RedPacketTableView:updateInfo()

	self.m_Infolist = {}

	for k, v in pairs(ActivityCenterMO.ActivityRedPacketInfo) do
		self.m_Infolist[#self.m_Infolist + 1] = v
	end

	local function mysort(a , b)
		if a.remainGrab > 0 and b.remainGrab == 0 then return true end
		if a.remainGrab == 0 and b.remainGrab > 0 then return false end
		if a.remainGrab > 0 and b.remainGrab > 0 then
			return a.uid > b.uid
		end
	end
	table.sort(self.m_Infolist, mysort)

	self:showTableContent()
end

function RedPacketTableView:showTableContent()
 	if self.m_node then
 		-- self.m_node:removeAllChildren()
 		self.m_node:removeSelf()
 		self.m_node = nil
 	else
 		
 	end

 	local node = display.newNode()
		self.m_node = node

 	local nodeY = -10
	local thisY = nodeY

	local lineCountMax = 3

	local size = #self.m_Infolist
	for index = 1, size do
		local packetInfo = self.m_Infolist[index]

  		local times = packetInfo.remainGrab				-- 红包剩余可抢次数
  		local icon = "redpacket_0"
  		if times > 0 then icon = "redpacket_1" end
		local item = display.newSprite(IMAGE_COMMON .. icon .. ".png"):addTo(self.m_node)
		self:setTouchEvent(item, handler(self, self.takeRedPacketCallback))

		local _index = index - 1
		local _x = _index % lineCountMax
		local x_ = self.m_viewSize.width * 0.5 + CalculateX(lineCountMax , (_x + 1) , item:width(), 1.125)
		local y_ = thisY - item:height() * 0.5 - 5 

		item:setPosition(x_, y_)
		item.uid = packetInfo.uid 						-- 红包唯一ID

		-- 红包所属玩家角色名
		local nameLb = ui.newTTFLabel({text = tostring(packetInfo.lordName), font = G_FONT, size = 16, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(item)
        nameLb:setPosition(item:width() * 0.5 , item:height() * 0.5)

		if index == size then
			nodeY = thisY - item:height() - 10
			break
		end

		if index % 3 == 0 then
			local line = display.newSprite(IMAGE_COMMON .. "line5.png"):addTo(self.m_node)
			line:setPosition(self.m_viewSize.width * 0.5, y_ - item:height() * 0.5 - line:height() - 5)

			thisY = line:y() - 10
		end
	end

	self.m_cellSize = cc.size(self.m_viewSize.width, -nodeY)
	self:reloadData()
end 

function RedPacketTableView:setTouchEvent(node,callback)
	node:setTouchEnabled(true)
	node:setTouchSwallowEnabled(false)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			node.istouch = true
			node:setScale(0.98)
			return true
		elseif event.name == "moved" then
			node.istouch = false
		elseif event.name == "ended" then
			if node.istouch then
				if callback then callback(node) end
			end
			node:setScale(1)
		end
	end)
end

function RedPacketTableView:takeRedPacketCallback(sender)
	-- body
	local _uid = sender.uid
	local function parseResultCallback(data, state)
		-- body
		local RedPacketInfoDialog = require("app.dialog.RedPacketInfoDialog")
		RedPacketInfoDialog.new(data):push()

	end
	ActivityCenterBO.GrabRedBag(parseResultCallback, _uid)
end

function RedPacketTableView:numberOfCells()
	return 1
end

function RedPacketTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RedPacketTableView:createCellAtIndex(cell, index)
	RedPacketTableView.super.createCellAtIndex(self, cell, index)
	self.m_node:addTo(cell)
	self.m_node:setPosition(0,self.m_cellSize.height)
	return cell
end

function RedPacketTableView:onExit()
	RedPacketTableView.super.onExit(self)
end


local Dialog = require("app.dialog.Dialog")
local RedPacketDialog = class("RedPacketDialog", Dialog)

function RedPacketDialog:ctor()
	RedPacketDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_135.png", UI_ENTER_NONE, {closeBtn = false})
end

function RedPacketDialog:onEnter()
	RedPacketDialog.super.onEnter(self)

	local nomal = display.newSprite(IMAGE_COMMON .. "btn_close.png")
	local colsebtn = ScaleButton.new(nomal, handler(self, self.onReturnCallback)):addTo(self:getBg(), 10)
	colsebtn:setPosition(self:getBg():width() - 5, self:getBg():height() - 5)

	local size = cc.size(self:getBg():width() - 10, self:getBg():height() - 10)
	local view = RedPacketTableView.new(size):addTo(self:getBg(), 3)
	view:setPosition(5, 5)
	-- view:drawBoundingBox(ccc4f(1, 1, 0, 1))
	self.m_view = view

	local bottomsp = display.newSprite(IMAGE_COMMON .. "info_bg_135_bottom.png"):addTo(self:getBg(),10)
	bottomsp:setPosition(self:getBg():width() * 0.5 , bottomsp:height() * 0.5 - 14)

	self.m_RedPacketListHandler = Notify.register("LOCAL_REDPACKET_UPDATE_HANDLER", handler(self, self.doLoad))

	self:doLoad()
end

function RedPacketDialog:doLoad()
	ActivityCenterBO.GetActRedBagList(function ()
		if self.m_view then
			self.m_view:updateInfo()
		end
	end)
end

function RedPacketDialog:onExit()
	RedPacketDialog.super.onExit(self)
	if self.m_RedPacketListHandler then
		Notify.unregister(self.m_RedPacketListHandler)
		self.m_RedPacketListHandler = nil
	end
end






















--------------------------------------------------------------
--						红包活动							--
--------------------------------------------------------------
local ActivityRedPacketView = class("ActivityRedPacketView", UiNode)

function ActivityRedPacketView:ctor(activity)
	ActivityRedPacketView.super.ctor(self, "image/common/bg_ui.jpg")
	self.m_activity = activity
end

function ActivityRedPacketView:onEnter()
	ActivityRedPacketView.super.onEnter(self)
	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)
	self.m_activityIdForAward = nil

	local topbg = display.newSprite(IMAGE_COMMON .. "activity/bar_redpacket.png"):addTo(self:getBg(), 1)
	topbg:setPosition(self:getBg():width() * 0.5 , self:getBg():height() - topbg:height() * 0.5 - 86)

	--timeTitle cc.c3b(18, 255, 3)
	local lb_time_title = ui.newTTFLabel({text = CommonText[853], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topbg)
	lb_time_title:setAnchorPoint(cc.p(0,0.5))
	lb_time_title:setPosition(320 , 90)

	--time
	local lb_time = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topbg)
	lb_time:setAnchorPoint(cc.p(0,0.5))
	lb_time:setPosition(math.floor(lb_time_title:x() + lb_time_title:getContentSize().width ), math.floor(lb_time_title:y()) )
	self.lb_time = lb_time


	local centerview = display.newSprite(IMAGE_COMMON .. "info_bg_137.jpg"):addTo(self:getBg(), 2)
	centerview:setAnchorPoint(cc.p(0.5,1))
	centerview:setPosition(self:getBg():width() * 0.5, topbg:y() - topbg:height() * 0.5 + 20)
	self.m_centerview = centerview

	local function tipsCallback(tar, sender)
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.RedPacketHelper):push()
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_39_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_39_selected.png")
	local tipsBtn = MenuButton.new(normal, selected, nil, tipsCallback):addTo(self:getBg(), 3)
	tipsBtn:setPosition(self:getBg():width() - tipsBtn:width() * 0.5 - 40,topbg:y() - topbg:height() * 0.5 + 95)

	local function goRechargeCallback(tar,sender)

		SendRedPacketDialog.new(self.m_activityIdForAward):push()
	end

	local topNomal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local topSelected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local sendButton = MenuButton.new(topNomal,topSelected,nil,goRechargeCallback):addTo(self:getBg(),3)
	sendButton:setAnchorPoint(cc.p(0.5,0))
	sendButton:setPosition(self:getBg():width() * 0.30, 20)
	sendButton:setLabel(CommonText[1788][3])
	sendButton:setEnabled(false)
	self.m_sendbtn = sendButton

	local function showlistCallback(tar,sender)
		-- body
		RedPacketDialog.new():push()

	end
	local topNomal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local topSelected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local haveButton = MenuButton.new(topNomal,topSelected,nil,showlistCallback):addTo(self:getBg(),3)
	haveButton:setAnchorPoint(cc.p(0.5,0))
	haveButton:setPosition(self:getBg():width() * 0.7, 20)
	haveButton:setLabel(CommonText[1788][4])
	haveButton:setEnabled(false)
	self.m_havebtn = haveButton

	self.m_showContent = handler(self,self.showContent)

	self.timeEndTag = -1

	-- 刷新时间
	if not self.timeScheduler then
		self.timeScheduler = scheduler.scheduleGlobal(handler(self,self.update), 1)
	end

	self:updateForRecharge()
end

function ActivityRedPacketView:update(ft)
	if self.lb_time then
		local time = self.m_activity.endTime - ManagerTimer.getTime()
		if time >= 0 then 
			self.lb_time:setString(UiUtil.strBuildTime(time))
		else
			self.lb_time:setString(UiUtil.strBuildTime(0))
			self.timeEndTag = self.timeEndTag + 1
			if self.timeEndTag == 0 then
				-- self:updateForRecharge()
			end
		end
	end
end

function ActivityRedPacketView:updateForRecharge()
	ActivityCenterBO.GetActRedBagInfo(handler(self, self.LoadInfo))
end

-- 拉去信息
function ActivityRedPacketView:LoadInfo(data)
	-- body
	self.m_activityIdForAward = data.activityId
	self.m_money = data.money
	local tokeAward = table.isexist(data,"stage") and data.stage or {}
	self.m_tokeAward = {}
	for index = 1 , #tokeAward do
		local stage = tokeAward[index]
		self.m_tokeAward[stage] = true
	end
	
	self.m_showContent()

	self.m_sendbtn:setEnabled(true)
	self.m_havebtn:setEnabled(true)
end

function ActivityRedPacketView:showContent()
	local activityInfos = ActivityCenterMO.getRedPacketData(self.m_activityIdForAward)
	local size = #activityInfos

	if self.m_centerview then
		self.m_centerview:removeAllChildren()
	end

	local redtitle = display.newSprite(IMAGE_COMMON .. "red_title.png"):addTo(self.m_centerview, 100)
	redtitle:setPosition(85, self.m_centerview:height() - 40)

	local kl = {0,20,40,60,80}

	local bar = display.newSprite(IMAGE_COMMON .. "bar_18.png")
	bar:setAnchorPoint(cc.p(0,0))
	local barSizeWidth = bar:width()
	local barSizeHeight = bar:height()

	local draw = cc.DrawNode:create()
	self.m_centerview:addChild(draw, 10)

	-- 清理画线

	local _scale = 0.7
	local moneyList = {}
	local bottomY = 15
	local drawX = 85
	local drawwidth = 50

	for infoIndex = 1 ,#activityInfos do
		local info = activityInfos[infoIndex]
		local stage = info.stage
		local money = info.money
		moneyList[#moneyList + 1] = info.money
		local _y = 0
		local _height = 0

		local _by = kl[infoIndex] * 0.01 * barSizeHeight + bottomY
		
		local awards = json.decode(info.awards)
		for aIndex = 1 , #awards do
			local award = awards[aIndex]
			local kind = award[1]
			local id = award[2]
			local count = award[3]

			local view = UiUtil.createItemView(kind, id, {count = count}):addTo(self.m_centerview, 3)
			view:setScale(_scale)
			view:setPosition(160 + (aIndex - 1) * view:width() * _scale * 1.2 + view:width() * _scale * 0.5, _by + view:width() * 0.5 * _scale)
			UiUtil.createItemDetailButton(view)
			_y = view:y()
			_height = view:height() * _scale
		end

		-- 画线
		local _drawY = _by + 2
		draw:drawSegment(cc.p(drawX,_drawY), cc.p(drawX + drawwidth,_drawY), 2 , ccc4f(162 / 255, 9 / 255, 9 / 255, 1))
		draw:drawDot(cc.p(drawX + drawwidth,_drawY), 4, ccc4f(162 / 255, 9 / 255, 9 / 255, 1))

		-- 返利
		local recoinnum = info.ratio * 0.01 
		local recoinsp = ui.newTTFLabel({text = "返利" .. recoinnum .. "%", font = G_FONT, size = 16, x = math.floor(drawX + 28), y = math.floor(_drawY + 15), color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_centerview)

		if self.m_money >= money then -- 满足
			local nomal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
			local takeButton = MenuButton.new(nomal,selected,disabled,handler(self, self.takeAwardCallback)):addTo(self.m_centerview,3)
			takeButton:setScale(_scale)
			takeButton:setPosition(self.m_centerview:width() - 60, _y)
			takeButton:setLabel(CommonText[672][1])
			if self.m_tokeAward[stage] then
				takeButton:setEnabled(false)
				takeButton:setLabel(CommonText[672][2])
			end

			takeButton.stage = stage
		else
			local desc = ui.newTTFLabel({text = CommonText[1794], font = G_FONT, size = 18, x = math.floor(self.m_centerview:width() - 60), y = math.floor(_y + _height * 0.25), color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_centerview)
			local desc2 = ui.newTTFLabel({text = info.money .. CommonText[672][1], font = G_FONT, size = 18, x = math.floor(desc:x()), y = math.floor(_y - _height * 0.25), color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_centerview)
		end

	end
	

	local rect = cc.rect(0, 0, barSizeWidth, barSizeHeight)
	local barNode = display.newClippingRegionNode(rect):addTo(self.m_centerview,3)
	barNode:setAnchorPoint(cc.p(0,0))
	barNode:setPosition(25, 15)
	barNode:addChild(bar)
	
	local per = 0
	local lastindex = 0
	for index = 1 , #moneyList do
		local moneyValue = moneyList[index]
		if self.m_money >= moneyValue then
			per = kl[index]
			lastindex = index
		else
			local _per = 0
			local _mvalue = 0
			if lastindex > 0 then
				_mvalue = moneyList[lastindex]
				_per = kl[lastindex]
			end
			local per_ = kl[index]
			local mvalue_ = moneyList[index]
			local outper = (self.m_money - _mvalue) / (mvalue_ - _mvalue) * (per_ - _per)
			per = per + outper
			break
		end
		if index == #moneyList then
			per = 100
		end
	end
	
	barNode:setClippingRegion(cc.rect(0, 0, barSizeWidth, per * 0.01 * barSizeHeight))

	local cur = ui.newTTFLabel({text = UiUtil.strNumSimplify(self.m_money), font = G_FONT, size = 12, x = 25 + barSizeWidth * 0.5, y = math.floor(15 + per * 0.01 * barSizeHeight * 0.75), color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_centerview, 15)

end


function ActivityRedPacketView:takeAwardCallback(tar, sender)
	-- body
	local stage = sender.stage
	local function parseResultCallback(data)
		self.m_tokeAward[stage] = true
		self.m_showContent()
	end
	ActivityCenterBO.DrawActRedBagStageAward(parseResultCallback, stage)
end

function ActivityRedPacketView:onExit()
	ActivityRedPacketView.super.onExit(self)

	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
	end
end

return ActivityRedPacketView