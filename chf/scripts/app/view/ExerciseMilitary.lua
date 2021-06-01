--
-- Author: Xiaohang
-- Date: 2016-08-09 10:21:09
--
--演习军力
-- 项目tableview
--------------------------------------------------------------------
local ItemTableView = class("ItemTableView", TableView)

function ItemTableView:ctor(size)
	ItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

function ItemTableView:numberOfCells()
	return #self.m_tanks
end

function ItemTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ItemTableView:createCellAtIndex(cell, index)
	ItemTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_tanks[index]
	local refitTankDB = TankMO.queryTankById(data.tankId)  -- 坦克
	local name = ui.newTTFLabel({text = refitTankDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[refitTankDB.grade]}):addTo(cell)
	-- 被改装后样式
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, refitTankDB.tankId):addTo(cell)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	sprite:setPosition(93, 30)
	-- 数量
	local label = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 77, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	local count = ui.newTTFLabel({text = data.count, font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 80, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	return cell
end

function ItemTableView:updateUI(data)
	self.m_tanks = {}
	-- if data then
	-- 	if not ExerciseBO.army[data.tankId] then
	-- 		ExerciseBO.army[data.tankId] = data
	-- 	else
	-- 		ExerciseBO.army[data.tankId].count = ExerciseBO.army[data.tankId].count + data.count
	-- 	end
	-- end
	self.m_tanks = table.values(ExerciseBO.army)
	table.sort(self.m_tanks,function(a,b)
			return a.tankId < b.tankId
		end)
	self:reloadData()
end

--------------------------------------------------------------------

local ExerciseMilitary = class("ExerciseMilitary", UiNode)

function ExerciseMilitary:ctor()
	ExerciseMilitary.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function ExerciseMilitary:onEnter()
	ExerciseMilitary.super.onEnter(self)
	self.m_activityHandler = Notify.register(LOCAL_EXCHANGE_TANK, handler(self, self.update))
	-- 增益信息
	self:setTitle(CommonText[20074])
	self:showUI()
end

function ExerciseMilitary:showUI()
	local t = UiUtil.label(CommonText[20077]):addTo(self):align(display.LEFT_CENTER,20,display.height-128)
	UiUtil.label(CommonText[20078],nil,COLOR[6]):addTo(self):rightTo(t)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self)
	line:setPreferredSize(cc.size(display.width-12, line:getContentSize().height))
	line:setPosition(display.cx, display.height-150)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self)
	line:setPreferredSize(cc.size(display.width-12, line:getContentSize().height))
	line:setPosition(display.cx, 110)
	local view = ItemTableView.new(cc.size(display.width-12, display.height - 270)):addTo(self)
	self.view = view
	view:setPosition(6, 110)

	ExerciseBO.getArmy(function()
			self.view:updateUI()
			self:checkEmpty()
		end)
	UiUtil.button("btn_11_normal.png","btn_11_selected.png",nil,handler(self, self.exchange),CommonText[20076])
		:addTo(self):pos(display.cx,60)
end

function ExerciseMilitary:checkEmpty()
	if self.tips then
		self.tips:removeSelf()
		self.tips = nil
	end
	if #self.view.m_tanks == 0 then
		self.tips = display.newSprite(IMAGE_COMMON .."smile.png")
			:addTo(self,10):pos(display.cx,display.cy+50)
		UiUtil.label(CommonText[20052],nil,cc.c3b(69, 104, 7))
			:addTo(self.tips):align(display.CENTER_TOP,self.tips:width()/2,-10)
	end
end

function ExerciseMilitary:update(event)
	local tanks = event.obj.tanks
	self.view:updateUI(tanks)
	self:checkEmpty()
end

function ExerciseMilitary:exchange()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ExchangeTankDialog").new():push()
end

function ExerciseMilitary:onExit()
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

return ExerciseMilitary