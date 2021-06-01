--
--
--
--
--

local LOCAL_ZORDER_MAPCOLOR	= 1
local LOCAL_ZORDER_SANDHIDE	= 2
local LOCAL_ZORDER_BSCENERY	= 3
local LOCAL_ZORDER_SANDSHOW	= 4
local LOCAL_ZORDER_MAPHLINE	= 5

local LOCAL_STATE_NONE = 0
local LOCAL_STATE_NEED = 1
local LOCAL_STATE_TASK = 2
local LOCAL_STATE_TING = 3
local LOCAL_STATE_DONE = 4

local spyColorAction = {[101] = {active = 2, color = cc.c3b(197, 197, 197)},
						[201] = {active = 1, color = cc.c3b(255, 182, 9)},
						[301] = {active = 0, color = cc.c3b(28, 177, 190)}}

local Dialog = require("app.dialog.Dialog")

------------------------------------------------------
--						奖励 						--
------------------------------------------------------
local ReawardDialog = class("ReawardDialog", Dialog)
function ReawardDialog:ctor(data, info)
	ReawardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(580, 510)})
	self.m_data = data
	self.m_info = info
end

function ReawardDialog:onEnter()
	ReawardDialog.super.onEnter(self)
	self:setTitle(self.m_info.name)

	armature_add(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local titleSize = self.m_data.awardLevel == 1 and 3 or 2

	local _scale = 3.0

	local _sizeIndex = 0

	local function armatureShow()
		_sizeIndex = _sizeIndex + 1
		if _sizeIndex >= titleSize then
			local armature = armature_create("ui_flash", self:getBg():width() * 0.5, self:getBg():height() * 0.775, function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
			 end):addTo(self:getBg(), 12)
			armature:getAnimation():playWithIndex(0)
		end
		
	end

	for index = 1 , titleSize do
		local spItem = display.newSprite(IMAGE_COMMON .. "word_" .. (index - 1) .. ".png"):addTo(self:getBg(), 10)
		spItem:setScale(_scale)
		spItem:setVisible(false)
		local _y = self:getBg():height() * 0.775

		local _x = CalculateX(titleSize, index, spItem:width(), 1.2)
		local _x1 = self:getBg():width() * 0.5 - _x
		
		local _x_ = CalculateX(titleSize, index, spItem:width() * _scale, 1.2)
		local _x2_ =self:getBg():width() * 0.5 - _x_ 

		spItem:setPosition( _x2_ , _y)

		local spwArray = cc.Array:create()
		spwArray:addObject(CCScaleTo:create(0.3, 1))
		spwArray:addObject(CCMoveTo:create(0.3, cc.p(_x1, _y)))

		spItem:runAction(transition.sequence({cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
			spItem:setVisible(true)
		end),cc.Spawn:create(spwArray),cc.CallFunc:create(function ()
			armatureShow()
		end)}))
	end

	local viewbg = display.newSprite(IMAGE_COMMON .. "taskbg.png"):addTo(self:getBg())
	viewbg:setPosition(self:getBg():width() * 0.5 , 240)

	local uilb = ui.newTTFLabel({text = CommonText[230] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg(), 1)
	uilb:setPosition(100, 305)

	for index = 1, #self.m_data.awards do
		local award = self.m_data.awards[index]
		local kind = award.kind
		local id = award.id
		local count = award.count
		local item = UiUtil.createItemView(kind, id, {count = count}):addTo(self:getBg() , 2)
		item:setScale(0.75)
		item:setPosition(item:width() * 0.75 * 1.1 * index , 220)
		UiUtil.createItemDetailButton(item)
	end


	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local takeButton = MenuButton.new(normal, selected, nil, handler(self, self.ontakeCallback)):addTo(self.m_bg, 5)
	takeButton:setPosition(self:getBg():width() * 0.5, 88)
	takeButton:setLabel(CommonText[672][1])

end

function ReawardDialog:ontakeCallback(tar, sender)
	self:pop()
	if self.m_data.ret then 
		UiUtil.showAwards(self.m_data.ret, true)
	end
end

function ReawardDialog:onExit()
	ReawardDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")
	Notify.notify("LOCAL_NOTIFY_BASELOAD")
end






------------------------------------------------------
--						间谍列表					--
------------------------------------------------------
local SpyPeopleListTableView = class("SpyPeopleListTableView", TableView)
function SpyPeopleListTableView:ctor(size,areaId,parent)
	SpyPeopleListTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 300)
	self.m_areaId = areaId
	self.m_parent = parent
end

function SpyPeopleListTableView:onEnter()
	SpyPeopleListTableView.super.onEnter(self)
	self.m_spyList = {}

	self.m_spyList = LaboratoryMO.getLaboratoryLurkSpy()

	local function mysort(a,b)
		return a.cost > b.cost
	end
	table.sort( self.m_spyList, mysort )

	self:reloadData()
end

function SpyPeopleListTableView:numberOfCells()
	return #self.m_spyList
end

function SpyPeopleListTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SpyPeopleListTableView:createCellAtIndex(cell, index)
	SpyPeopleListTableView.super.createCellAtIndex(self, cell, index)

	local spyInfo = self.m_spyList[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "taskbg.png"):addTo(cell)
	bg:setPreferredSize(cc.size(bg:width(), 295))
	bg:setPosition(self.m_cellSize.width * 0.5, self.m_cellSize.height * 0.5)

	local icon = display.newSprite(IMAGE_COMMON .. "laboratory/" .. spyInfo.asset .. ".png"):addTo(bg)
	icon:setAnchorPoint(cc.p(0.5,0))
	icon:setPosition(icon:width() * 0.5, 0)

	local spyrunInfo = spyColorAction[spyInfo.spyId]
	local titleName = ui.newTTFLabel({text = spyInfo.name, font = G_FONT, size = FONT_SIZE_MEDIUM, color = spyrunInfo.color, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	titleName:setPosition(bg:width() * 0.5 + 40 , 250)

	local spyAbility = ui.newTTFLabel({text = CommonText[1134][1] .. ":", font = G_FONT, size = FONT_SIZE_TINY, color = cc.c3b(10, 220, 10), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	spyAbility:setPosition(bg:width() * 0.5 + 30 , 200)

	local exploreAbility = ui.newTTFLabel({text = CommonText[1134][2] .. ":", font = G_FONT, size = FONT_SIZE_TINY, color = cc.c3b(10, 220, 10), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	exploreAbility:setPosition(bg:width() * 0.5 + 30 , 170)

	for index = 1 , 5 do
		local abilityStar = "estar_bg"
		local exploreStar = "estar_bg"
		if index <= spyInfo.spyStar then abilityStar = "estar" end
		if index <= spyInfo.exploreStar then exploreStar = "estar" end

		local star = display.newSprite(IMAGE_COMMON .. abilityStar .. ".png"):addTo(bg)
		star:setPosition(bg:width() * 0.5 + 60 + star:width() * index * 1.5, 202)

		local star1 = display.newSprite(IMAGE_COMMON .. exploreStar .. ".png"):addTo(bg)
		star1:setPosition(bg:width() * 0.5 + 60 + star1:width() * index * 1.5, 172)
	end

	local desclb = ui.newTTFLabel({text = spyInfo.description , font = G_FONT, size = FONT_SIZE_TINY, dimensions = cc.size(250, 0), color = cc.c3b(255, 250, 255), align = ui.TEXT_ALIGN_LEFT}):addTo(bg)
	desclb:setAnchorPoint(cc.p(0,0.5))
	desclb:setPosition(bg:width() * 0.5  , 105)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local doBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.doBtnCallback))--:addTo(bg)
	doBtn:setScale(0.8)
	-- doBtn:setPosition(bg:width() - doBtn:width() * 0.5 + 10, doBtn:height() * 0.5 - 5)
	doBtn.spyId = spyInfo.spyId
	doBtn.payCount = spyInfo.cost
	cell:addButton(doBtn, bg:width() - doBtn:width() * 0.5 + 10, doBtn:height() * 0.5 - 5)

	if spyInfo.cost > 0 then
		-- icon_coin_2.png
		local iconsp = display.newSprite(IMAGE_COMMON .. "icon_coin_2.png"):addTo(doBtn)
		iconsp:setPosition(50, doBtn:height() * 0.5)

		local getCoinLabel = ui.newBMFontLabel({text = spyInfo.cost, font = "fnt/num_1.fnt", x = 0, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(doBtn)
		getCoinLabel:setAnchorPoint(cc.p(0.5, 0.5))
		getCoinLabel:setPosition(100, doBtn:height() * 0.5 + 2)
	else
		doBtn:setLabel(CommonText[729])
	end

	

	return cell
end

function SpyPeopleListTableView:doBtnCallback(tar, sender)
	local spyId = sender.spyId
	local payCount = sender.payCount
	local coinCount = UserMO.getResource(ITEM_KIND_COIN)

	-- print("spyId  " , spyId)
	-- print("payCount  " , payCount)
	-- print("coinCount  " , coinCount)
	-- print("self.m_areaId  " , tostring(self.m_areaId))
	-- body
	local function parseResult(data)
		Toast.show(CommonText[1135])
		Notify.notify("LOCAL_NOTIFY_BASELOAD")
		if self.m_parent then
			self.m_parent:pop()
		end
	end
	local function doIt()
		if payCount > 0 and coinCount < payCount then
			Toast.show(CommonText[679])
		else
			LaboratoryBO.ActFightLabSpyTask(parseResult, self.m_areaId, spyId)
		end
	end

	if payCount > 0 then
		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[1142][1], payCount), function() doIt() end, nil):push()
		else
			doIt()
		end
	else
		doIt()
	end
end

function SpyPeopleListTableView:onTouchBegan(event)
	local rect = self:getViewRect()
    local point = cc.p(event.points["0"].x, event.points["0"].y)
    if cc.rectContainsPoint(rect, point) then
		return SpyPeopleListTableView.super.onTouchBegan(self, event)
    end
    return false
end

function SpyPeopleListTableView:onExit()
	SpyPeopleListTableView.super.onExit(self)
end



local SpyPeopleListDialog = class("SpyPeopleListDialog",Dialog)
function SpyPeopleListDialog:ctor(areaId)
	SpyPeopleListDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(580, 850)})
	self.m_areaId = areaId
end

function SpyPeopleListDialog:onEnter()
	SpyPeopleListDialog.super.onEnter(self)
	self:setTitle(CommonText[1136])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local size = cc.size(self:getBg():width() - 40 , self:getBg():height() - 95)
	local view = SpyPeopleListTableView.new(size, self.m_areaId, self):addTo(self:getBg(),0)
	view:setPosition(20,35)
end

function SpyPeopleListDialog:onExit()
	SpyPeopleListDialog.super.onExit(self)
end


















------------------------------------------------------
--						任务展示					--
------------------------------------------------------
local SandTaskInfoDialog = class("SandTaskInfoDialog",Dialog)

function SandTaskInfoDialog:ctor(areaInfo, taskID, taskUpdateCallback)
	SandTaskInfoDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(580, 510)})
	self.m_areaInfo = areaInfo
	self.m_taskId = taskID
	self.m_taskUpdateCallback = taskUpdateCallback
end

function SandTaskInfoDialog:onEnter()
	SandTaskInfoDialog.super.onEnter(self)
	self:setTitle(self.m_areaInfo.name)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	-- 
	local title = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(self:getBg())
	title:setAnchorPoint(cc.p(0,0.5))
	title:setPosition(35, 420)

	local titleStr = ui.newTTFLabel({text = CommonText[1137], font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = title:height() * 0.5, align = ui.TEXT_ALIGN_LEFT}):addTo(title)
	titleStr:setAnchorPoint(cc.p(0,0.5))

	local node = display.newNode():addTo(self:getBg())
	node:setPosition(0,0)
	self.m_unode = node

	self.m_updateTask = handler(self,self.onContainerTask)

	self.m_updateTask()
end

function SandTaskInfoDialog:onContainerTask()

	local taskInfo = LaboratoryMO.getLaboratoryLurkTask(self.m_taskId)

	-- body
	if self.m_unode then
		self.m_unode:removeAllChildren()
	end

	local descStr = ui.newTTFLabel({text = taskInfo.name .. "-" .. taskInfo.description ,font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[taskInfo.quality], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(500, 0)}):addTo(self.m_unode)
	descStr:setAnchorPoint(cc.p(0,0.5))
	descStr:setPosition(40, 370)
	local viewbg = display.newSprite(IMAGE_COMMON .. "taskbg.png"):addTo(self.m_unode)
	viewbg:setPosition(self:getBg():width() * 0.5 , 240)

	local ytime = ui.newTTFLabel({text = CommonText[1138] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(0, 255, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(viewbg)
	ytime:setAnchorPoint(cc.p(0,0.5))
	ytime:setPosition(15, viewbg:height() - 25)

	local timelb = ui.newTTFLabel({text = UiUtil.strBuildTime(taskInfo.finishTime) , font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(0, 255, 0), align = ui.TEXT_ALIGN_LEFT}):addTo(viewbg)
	timelb:setAnchorPoint(cc.p(0,0.5))
	timelb:setPosition(ytime:x() + ytime:width() + 5, ytime:y())
	self.m_timelb = timelb

	local scale = 0.75

	local mustProduce = ui.newTTFLabel({text = CommonText[1139][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_LEFT}):addTo(viewbg)
	mustProduce:setAnchorPoint(cc.p(0,0.5))
	mustProduce:setPosition(15, viewbg:height() - 65)

	local mplist = json.decode(taskInfo.mustProduce)
	for index = 1 , #mplist do
		local mproduce = mplist[index]
		local kind = mproduce[1]
		local id = mproduce[2]
		local count = mproduce[3]

		local view =  UiUtil.createItemView(kind, id, {count = count}):addTo(viewbg)
		view:setScale(scale)
		view:setPosition(view:width() * scale * 1.05 * index - 30 , 60)
		UiUtil.createItemDetailButton(view)
	end

	local couldProduce = ui.newTTFLabel({text = CommonText[1139][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_LEFT}):addTo(viewbg)
	couldProduce:setAnchorPoint(cc.p(0,0.5))
	couldProduce:setPosition(viewbg:width() * 0.5 + 10, viewbg:height() - 65)

	local cplist = json.decode(taskInfo.couldProduce)
	for index = 1 , #cplist do
		local cproduce = cplist[index]
		local kind = cproduce[1]
		local id = cproduce[2]
		local count = cproduce[3]

		local view =  UiUtil.createItemView(kind, id):addTo(viewbg)
		view:setScale(scale)
		view:setPosition(viewbg:width() * 0.5 + view:width() * scale * 1.05 * index - 35 , 60)
		UiUtil.createItemDetailButton(view)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local reflushBtn = MenuButton.new(normal, selected, nil, handler(self, self.reflushBtnCallback)):addTo(self.m_unode)
	reflushBtn:setPosition(self:getBg():width() * 0.275, 90)
	reflushBtn:setLabel(CommonText[876][2])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local sendBtn = MenuButton.new(normal, selected, nil, handler(self, self.sendBtnCallback)):addTo(self.m_unode)
	sendBtn:setPosition(self:getBg():width() * 0.725, 90)
	sendBtn:setLabel(CommonText[1140])

end

function SandTaskInfoDialog:reflushBtnCallback(tar, sender)

	local refreshcost = self.m_areaInfo.refreshCost
	local coinCount = UserMO.getResource(ITEM_KIND_COIN)

	-- body
	local function parseResult(data)
		local taskid = data.taskId
		self.m_taskId = taskid

		if self.m_updateTask then
			self.m_updateTask()
		end

		if self.m_taskUpdateCallback then
			self.m_taskUpdateCallback(taskid)
		end
		Toast.show(CommonText[879])
	end

	local function doFlush()
		if refreshcost > 0 and coinCount < refreshcost then
			Toast.show(CommonText[679])
		else
			LaboratoryBO.RefFightLabSpyTask(parseResult, self.m_areaInfo.areaId)
		end
	end
	
	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1142][2] , refreshcost), function() doFlush() end, nil):push()
	else
		doFlush()
	end
end

function SandTaskInfoDialog:sendBtnCallback(tar, sender)
	local areaId = self.m_areaInfo.areaId
	self:pop(function()
		SpyPeopleListDialog.new(areaId):push()
	end)
end








------------------------------------------------------
--						地区						--
------------------------------------------------------
local SandNode = class("SandNode",function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node 
end)

function SandNode:ctor(param)
	self.m_param = param
end

function SandNode:onEnter()

	self.pos = self.m_param.pos

	self.info = self.m_param.inf

	self.areaId = self.info.areaId

	self.icon = self.pos.icon

	self.m_color = self.pos.tocolor

	self.m_state = 0
	self.m_taskId = nil
	self.m_time = nil
	self.m_spyId = nil

	-- body
	local item = display.newSprite(IMAGE_COMMON .. "laboratory/" .. self.icon .. "_map.png"):addTo(self)
	self.m_item = item

	self:setContentSize(cc.size(item:width(), item:height()))
	self:setPosition(self.pos.ccp.x, self.pos.ccp.y)

	local itemH = display.newSprite(IMAGE_COMMON .. "laboratory/" .. self.icon .. "_map_h.png"):addTo(self)
	itemH:setVisible(false)
	self.m_itemH = itemH

	local nameUI = ui.newTTFLabel({text = self.info.name, font = G_FONT, size = 25, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_item)
	nameUI:setPosition(self.pos.nameccp.x , self.pos.nameccp.y)

	-- state
	self:checkState()
end

function SandNode:setSandData(data)
	-- body
	local areaId = data.areaId
	self.m_state = data.state
	self.m_taskId = table.isexist(data,"taskId") and data.taskId or nil
	self.m_time = table.isexist(data,"time") and data.time or nil
	self.m_spyId = table.isexist(data,"spyId") and data.spyId or nil

	self:checkState()
end

-- task
function SandNode:checkState()
	self:setZOrder(LOCAL_ZORDER_SANDSHOW)

	-- body
	if self.m_StateItem then
		if self.m_StateItem.timebg then
			self.m_StateItem.timebg:removeSelf()
			self.m_StateItem.timebg = nil
		end
		self.m_StateItem:stopAllActions()
		self.m_StateItem:removeSelf()
		self.m_StateItem = nil
	end

	local taskState = self.m_state
	local stateItem = nil

	if taskState == LOCAL_STATE_NONE then -- 0 未解锁
		self:setZOrder(LOCAL_ZORDER_SANDHIDE)

	elseif taskState == LOCAL_STATE_NEED then -- 1 可解锁 
		-- stateItem = display.newSprite(IMAGE_COMMON .. "laboratory/limit.png"):addTo(self.m_item)
		-- stateItem:setPosition(self.pos.limitccp.x, self.pos.limitccp.y)
		-- stateItem:setScale(self.pos.limitScale)
		-- stateItem:setRotation(self.pos.limitRot)

		stateItem = armature_create("fengtiao", self.pos.limitccp.x, self.pos.limitccp.y):addTo(self.m_item)
		stateItem:getAnimation():playWithIndex(0) -- 0 蓝色 1 黄色 2 白色
		stateItem:setScale(self.pos.limitScale)
		stateItem:setRotation(self.pos.limitRot)

	elseif taskState == LOCAL_STATE_TASK then -- 2 等待任务
		stateItem = display.newSprite(IMAGE_COMMON .. "laboratory/" .. self.icon .. "_task.png"):addTo(self.m_item)
		stateItem:setPosition(self.pos.taskccp.x, self.pos.taskccp.y)

	elseif taskState == LOCAL_STATE_TING then -- 3 任务进行中
		local runinfo = spyColorAction[self.m_spyId]
		stateItem = armature_create("lurkspyrun", self.pos.taskccp.x, self.pos.taskccp.y - 30):addTo(self.m_item)
		stateItem:getAnimation():playWithIndex(runinfo.active) -- 0 蓝色 1 黄色 2 白色

		-- 时间 
		local timebg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(self.m_item)
		timebg:setAnchorPoint(cc.p(0.5,1))
		timebg:setPosition(self.pos.taskccp.x, self.pos.taskccp.y - 5 - 30)
		stateItem.timebg = timebg
		local timelb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, color = runinfo.color, align = ui.TEXT_ALIGN_CENTER}):addTo(timebg)
		timelb:setPosition(timebg:width() * 0.5 , timebg:height() * 0.5)
		timebg.timelb = timelb

	elseif taskState == LOCAL_STATE_DONE then -- 4 任务完成
		stateItem = display.newSprite(IMAGE_COMMON .. "laboratory/complete.png"):addTo(self.m_item)
		stateItem:setPosition(self.pos.taskccp.x, self.pos.taskccp.y)
        stateItem:runAction( 
	        	CCRepeatForever:create(
	        		transition.sequence(
	        			{cc.DelayTime:create(1.5), 
						CCJumpBy:create(0.25,cc.p(0, 0), 100 , 1),
						CCJumpBy:create(0.23,cc.p(0, 0), 50 , 1),
						CCJumpBy:create(0.21,cc.p(0, 0), 25 , 1),
						CCJumpBy:create(0.18,cc.p(0, 0), 12.5 , 1),
						CCJumpBy:create(0.16,cc.p(0, 0), 6.25 , 1)}
					)
	        	)
	        )
	end

	self.m_StateItem = stateItem
end

function SandNode:update(fd)
	if self.m_time then
		if self.m_state == LOCAL_STATE_TING and self.m_StateItem then
			self.m_time = self.m_time - 1
			if self.m_StateItem.timebg then
				self.m_StateItem.timebg.timelb:setString(UiUtil.strBuildTime(self.m_time))
			end
			if self.m_time <= 0 then
				self.m_state = LOCAL_STATE_DONE
				self:checkState()
			end
		end
	end
end

-- 解锁地图
function SandNode:OpenLockArea()
	local function openArea(spyinfo)
		self:setSandData(spyinfo)
		Notify.notify("LOCAL_NOTIFY_BASELOAD")
		Toast.show(CommonText[20003])
	end

	local function parseResult(data)
		-- body 
		self.m_state = nil
		local spyinfo = PbProtocol.decodeRecord(data["spyinfo"])

		if self.m_StateItem.connectMovementEventSignal then
			self.m_StateItem:getAnimation():playWithIndex(1)
			self.m_StateItem:connectMovementEventSignal(function(movementType, movementID)
				if movementType == MovementEventType.COMPLETE then
					openArea(spyinfo)
				end
			end)
		else
			openArea(spyinfo)
		end
	end

	local function ActiveSpyArea()
		self.m_state = LOCAL_STATE_NEED
		LaboratoryBO.ActFightLabSpyArea(parseResult, self.areaId)
	end
	
	local paycost = self.info.cost
	local coinCount = UserMO.getResource(ITEM_KIND_COIN)

	if paycost > 0 then
		local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
		TipsAnyThingDialog.new(string.format(CommonText[1142][3], paycost, self.info.name), function ()
			-- ok
			if coinCount < paycost then
				self.m_state = LOCAL_STATE_NEED
				Toast.show(CommonText[679])
				return 
			end
			ActiveSpyArea()
		end, nil, function ()
			-- cancel
			self.m_state = LOCAL_STATE_NEED
		end):push()
	else -- free
		ActiveSpyArea()
	end
end

-- 领取奖励
function SandNode:getStateAward()
	local function parseResult(data)
		-- Notify.notify("LOCAL_NOTIFY_BASELOAD")
		ReawardDialog.new(data,self.info):push()
	end
	LaboratoryBO.GctFightLabSpyTaskReward(parseResult, self.areaId)
end

function SandNode:updateTaskId(taskid)
	self.m_taskId = taskid
end

-- local LOCAL_STATE_NONE = 0
-- local LOCAL_STATE_NEED = 1
-- local LOCAL_STATE_TASK = 2
-- local LOCAL_STATE_TING = 3
-- local LOCAL_STATE_DONE = 4
-- 点击更新
function SandNode:UpdateHState()
	if not self.m_state then
		return
	elseif self.m_state == LOCAL_STATE_TING then
		return
	elseif self.m_state == LOCAL_STATE_NONE then 
		if self.info.ifUnlock > 0 then
			local qeAreaInfo = LaboratoryMO.getLaboratoryLurkArea(self.info.ifUnlock)
			Toast.show(string.format(CommonText[1143],qeAreaInfo.name ))
		end
		return
	end

	local function doSomeThing()
		if self.m_state == LOCAL_STATE_NEED then -- 解锁
			self.m_state = nil
			self:OpenLockArea()

		elseif self.m_state == LOCAL_STATE_TASK then -- 打开任务信息框
			SandTaskInfoDialog.new(self.info, self.m_taskId, handler(self,self.updateTaskId)):push()
			-- ReawardDialog.new(nil,self.info):push()
		-- elseif self.m_state == 3 then -- ...任务进行中

		elseif self.m_state == LOCAL_STATE_DONE then -- 完成任务领取奖励
			self:getStateAward()
		end
	end

	if self.m_itemH then
		self.m_itemH:setVisible(true)
	end
	self.m_itemH:runAction(transition.sequence({cc.DelayTime:create(0.15),cc.CallFuncN:create(function ()
		-- 完成确认
		self:CancelHState()
		doSomeThing()
	end)}))
end

-- 取消
function SandNode:CancelHState()
	if self.m_itemH then
		self.m_itemH:setVisible(false)
	end
end

function SandNode:checkColor(color)
	local isSame = false
	if color.r == self.m_color.r and 
		color.g == self.m_color.g and 
		color.b == self.m_color.b then 
		-- color.a == self.m_color.r 
		isSame = true
	end 
	return isSame
end

function SandNode:onExit()
	-- body
end
























------------------------------------------------------
--						沙盘						--
------------------------------------------------------
local SandTableView = class("SandTableView", TableView)

function SandTableView:ctor(size)
	SandTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width,973)
end

function SandTableView:onEnter()
	SandTableView.super.onEnter(self)

	armature_add(IMAGE_ANIMATION .. "effect/lurkspyrun.pvr.ccz", IMAGE_ANIMATION .. "effect/lurkspyrun.plist", IMAGE_ANIMATION .. "effect/lurkspyrun.xml")
	armature_add(IMAGE_ANIMATION .. "effect/fengtiao.pvr.ccz", IMAGE_ANIMATION .. "effect/fengtiao.plist", IMAGE_ANIMATION .. "effect/fengtiao.xml")

	self.m_touchState = false
	self.m_couldTouch = true
	local posMap = {
			[100] = {icon = 1, ccp = cc.p(123, 526), nameccp = cc.p(75,550), taskccp = cc.p(70,410), limitccp = cc.p(90,380), limitScale = 1, limitRot = -90, tocolor = ccc4(0,255,0,255)},
			[200] = {icon = 2, ccp = cc.p(383, 856), nameccp = cc.p(193,138 - 18), taskccp = cc.p(270 + 11,130 - 36 + 10), limitccp = cc.p(260,170), limitScale = 0.8, limitRot = 0, tocolor = ccc4(255,255,0,255)},
			[300] = {icon = 3, ccp = cc.p(530, 660), nameccp = cc.p(140,110), taskccp = cc.p(140,240), limitccp = cc.p(125,240), limitScale = 0.8, limitRot = -90, tocolor = ccc4(0,0,255,255)},
			[400] = {icon = 4, ccp = cc.p(319, 208), nameccp = cc.p(300,150), taskccp = cc.p(500,160 + 30), limitccp = cc.p(300 + 180,100+50), limitScale = 1, limitRot = 0, tocolor = ccc4(255,0,255,255)},
			[500] = {icon = 5, ccp = cc.p(387, 521), nameccp = cc.p(160,310), taskccp = cc.p(160,430), limitccp = cc.p(160,390), limitScale = 0.75, limitRot = 0, tocolor = ccc4(255,0,0,255)}
		}

	-- body -- Main Node
	local node = display.newNode()
	self.m_node = node

	local mapInfoList = LaboratoryMO.getLaboratoryLurkArea()
	self.m_AreaList = {}

	-- 沙盘节点
	for k, v in pairs(mapInfoList) do
		local info = {pos = posMap[k], inf = v}
		local view = SandNode.new(info):addTo(node)
		self.m_AreaList[v.areaId] = view
	end


	-- 色盘
	local image = CCImage:new()
	image:initWithImageFile(IMAGE_COMMON .. "laboratory/colorsandmap.png")
	local texture = CCTextureCache:sharedTextureCache():addUIImage(image,nil)--,IMAGE_COMMON .. "laboratory/colorsandmap.png")
	texture:retain()
	texture:autorelease()
	local colormap = display.newSprite()
    colormap:setTexture(texture)
    colormap:setPosition(self.m_cellSize.width * 0.5, self.m_cellSize.height * 0.5)
    colormap:addTo(node, LOCAL_ZORDER_MAPCOLOR)
    colormap:setVisible(false)
    self.m_colormap = colormap
    self.m_MapImage = image
    self.m_MapTexture = texture

    -- 遮罩
    local sceneryBgLayer = display.newColorLayer(ccc4(0, 0, 0, 125)):addTo(node,LOCAL_ZORDER_BSCENERY)
	sceneryBgLayer:setContentSize(cc.size(colormap:width() + 4, colormap:height() + 4))
	sceneryBgLayer:setPosition(self.m_cellSize.width * 0.5 - sceneryBgLayer:width() * 0.5, self.m_cellSize.height * 0.5 - sceneryBgLayer:height() * 0.5)

    -- 高亮线
	local hline = display.newSprite(IMAGE_COMMON .. "laboratory/line.png"):addTo(node, LOCAL_ZORDER_MAPHLINE)
	hline:setPosition(self.m_cellSize.width * 0.5 + 2, self.m_cellSize.height * 0.5 + 2)
	hline:setVisible(false)
	self.m_hline = hline


	self.m_widthDex = (self.m_cellSize.width - colormap:width() ) * 0.5
	self.m_colorMapWidth = colormap:width()
	self.m_colorMapHeight = colormap:height()


	-- 预告
	local loadingnode = display.newNode():addTo(self,10)
	loadingnode:setCascadeOpacityEnabled(true)
    self.m_loadingnode = loadingnode
    local ldbg = display.newScale9Sprite(IMAGE_COMMON .. "taskbg.png"):addTo(loadingnode)
    ldbg:setPreferredSize(cc.size(ldbg:width(), 295))
    ldbg:setPosition(self.m_viewSize.width * 0.5, self.m_viewSize.height * 0.5)
    local ldIcon = display.newSprite(IMAGE_COMMON .. "laboratory/spy_2.png"):addTo(ldbg)
    ldIcon:setPosition(ldbg:width() * 0.5 - 130, ldbg:height() * 0.5)
    local tip = ui.newTTFLabel({text = CommonText[1141], font = G_FONT, size = FONT_SIZE_HUGE, x = ldbg:width() * 0.5, y = ldbg:height() * 0.5, align = ui.TEXT_ALIGN_LEFT}):addTo(ldbg)


	self:reloadData()
	if self.m_cellSize.height > self.m_viewSize.height then
		local dex = self.m_cellSize.height - self.m_viewSize.height
		self:setContentOffset(cc.p(0, -dex * 0.5))
	end

	self.m_dataHandler = Notify.register("LOCAL_NOTIFY_BASELOAD", handler(self, self.doLoad))

	self.m_timeHandler = scheduler.scheduleGlobal(handler(self,self.onUpdateForTime), 1)

	self.m_clockListener = ManagerTimer.addClockListener(0, handler(self, self.doLoad))

	self:doLoad() -- 拉取网络信息
end

function SandTableView:onUpdateForTime(ft)
	for k,v in pairs(self.m_AreaList) do
		v:update(ft)
	end
end

function SandTableView:doLoad()
	LaboratoryBO.GetFightLabSpyInfo(handler(self,self.loadInfo))
end

function SandTableView:loadInfo(data)
	local spys = PbProtocol.decodeArray(data["spyinfo"])
	-- dump(spys)
	for k , v in pairs(spys) do
		self.m_AreaList[v.areaId]:setSandData(v)
	end

	local function doit()
		if self.m_loadingnode then
			self.m_loadingnode:removeSelf()
			self.m_loadingnode = nil
		end
		
		self.m_couldTouch = true
	end

	self.m_hline:setVisible(true)
	if self.m_loadingnode then 
		self.m_loadingnode:runAction( transition.sequence({CCFadeOut:create(0.5), cc.CallFunc:create(doit)}) )
	else
		doit()
	end
	
end

function SandTableView:onExit()
	if self.m_colormap then
		self.m_colormap:removeSelf()
	end
	
	if self.m_MapImage then
		self.m_MapImage:delete()
	end

	if self.m_MapTexture then
		self.m_MapTexture:release()
	end

	SandTableView.super.onExit(self)

	if self.m_dataHandler then
		Notify.unregister(self.m_dataHandler)
		self.m_dataHandler = nil
	end

	if self.m_timeHandler then
		scheduler.unscheduleGlobal(self.m_timeHandler)
		self.m_timeHandler = nil
	end

	if self.m_clockListener then
		ManagerTimer.removeClockListener(self.m_clockListener)
		self.m_clockListener = nil
	end
	
	armature_remove(IMAGE_ANIMATION .. "effect/lurkspyrun.pvr.ccz", IMAGE_ANIMATION .. "effect/lurkspyrun.plist", IMAGE_ANIMATION .. "effect/lurkspyrun.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/fengtiao.pvr.ccz", IMAGE_ANIMATION .. "effect/fengtiao.plist", IMAGE_ANIMATION .. "effect/fengtiao.xml")
end

function SandTableView:numberOfCells()
	return 1
end

function SandTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SandTableView:createCellAtIndex(cell, index)
	SandTableView.super.createCellAtIndex(self, cell, index)
	if self.m_node then
		self.m_node:setPosition(0,0)
		self.m_node:addTo(cell)
	end
	return cell
end

function SandTableView:onTouchBegan(event)
	if not self.m_couldTouch then return false end
	local rect = self:getViewRect()
    local point = cc.p(event.points["0"].x, event.points["0"].y)
    self.m_point = point
    if cc.rectContainsPoint(rect, point) then
    	self.m_touchState = true
		return true --SandTableView.super.onTouchBegan(self, event)
    end
    self.m_touchState = false
	return false
end

function SandTableView:onTouchMoved(event)
	if not self.m_couldTouch then return false end
	-- SandTableView.super.onTouchMoved(self, event)
	local point = cc.p(event.points["0"].x, event.points["0"].y)
	local point = cc.p(event.points["0"].x, event.points["0"].y)
	if self.m_point then
		if point.x > self.m_point.x + 2 or 
			point.x < self.m_point.x - 2 or 
			point.y > self.m_point.y + 2 or
			point.y < self.m_point.y - 2 then
			self.m_touchState = false
		end
	end
end

function SandTableView:onTouchEnded(event)
	if not self.m_couldTouch then return false end
	-- SandTableView.super.onTouchEnded(self, event)
	self.m_point = nil
	if not self.m_touchState then return end

	self.m_touchState = false

	local touchevent = event.points["0"]
	local x = touchevent.x 
	local y = touchevent.y - self:getContentOffset().y

	if ((x - self.m_widthDex ) > 0 or (self.m_colorMapWidth + self.m_widthDex) < x) and
		(y > 0 or y < self.m_colorMapHeight) then

		local _x = x - self.m_widthDex
		local _y = self.m_colorMapHeight - y

		if self.m_MapImage then
			local color = self.m_MapImage:getColor4B(_x,_y)

			for k , v in pairs(self.m_AreaList) do
				if v:checkColor(color) then
					v:UpdateHState()
				else
					v:CancelHState()
				end
			end
		end
	end
end


















------------------------------------------------------
--						潜伏间谍					--
------------------------------------------------------


local LaboratoryForLurkView = class("LaboratoryForLurkView", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node 
end)

function LaboratoryForLurkView:ctor(size , parent)
	self:setContentSize(size)
	self.m_parent = parent
end

function LaboratoryForLurkView:onEnter()
	-- body
	local showViewSize = cc.size(self:width(), self:height())

	-- local BgLayer = display.newColorLayer(ccc4(0, 0, 0, 255)):addTo(self,-1)
	-- BgLayer:setContentSize(showViewSize)
	-- BgLayer:setPosition(0, 0)

	local view = SandTableView.new(showViewSize):addTo(self)
	view:setPosition(0,0)

	local btm = display.newSprite(IMAGE_COMMON .. "bg_ui_btm.png"):addTo(self)
	btm:setAnchorPoint(cc.p(0.5,0))
	btm:setPosition(self:width() * 0.5, 0)

	local function DetailTextCallback()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.SpyLuckHelper):push()
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, DetailTextCallback):addTo(self,2)
	detailBtn:setPosition(self:width() - detailBtn:width() * 0.5 - 6 , self:height() - detailBtn:height() * 0.5 - 2)

end

function LaboratoryForLurkView:onExit()
	-- body
end

return LaboratoryForLurkView