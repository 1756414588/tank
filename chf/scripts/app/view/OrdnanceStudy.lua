--
-- Author: Xiaohang
-- Date: 2016-04-29 10:38:14
--

---------------------------------------------左侧菜单------------------
local MenuTableView = class("MenuTableView", TableView)

function MenuTableView:ctor(size,rhand)
	MenuTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 108)
end

function MenuTableView:createCellAtIndex(cell, index)
	MenuTableView.super.createCellAtIndex(self, cell, index)
	local activity = self.m_activityList[index]
	cell.activity = activity

	local btn = UiUtil.button("btn_study_0.png","btn_study_1.png",nil,handler(self,self.onChosenCallback),nil,1)
	cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	btn.index = index
	cell.btn = btn
	UiUtil.createItemSprite(ITEM_KIND_TANK, activity):addTo(cell,10)
			:pos(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	if not self.m_chosenIndex then
		self.m_chosenIndex = index
		btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_study_1.png"))
		self.rhand(index)
	elseif self.m_chosenIndex == index then
		btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_study_1.png"))
	end

	return cell
end

function MenuTableView:numberOfCells()
	return #self.m_activityList
end

function MenuTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MenuTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.index == self.m_chosenIndex then
	else
		self:chosenIndex(sender.index)
		self.rhand(sender.index)
	end
end

function MenuTableView:chosenIndex(menuIndex)
	self.m_chosenIndex = menuIndex
	for index = 1, #self.m_activityList do
		local cell = self:cellAtIndex(index)
		if cell then
			if index == self.m_chosenIndex then
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_study_1.png"))
			else
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_study_0.png"))
			end
		end
	end
end

function MenuTableView:updateUI(data)
	self.m_activityList = data
	self:reloadData()
end

---------------------------------------------右侧内容------------------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 150)
end

function ContentTableView:updateView(event)
	self.m_activityList = event.obj or self.m_activityList
	self:reloadData()
	self:getParent():setTotal()
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	local tankDB = TankMO.queryTankById(data.tankId)
	-- 名称
	UiUtil.label(tankDB.name,nil,COLOR[tankDB.grade]):addTo(cell):align(display.LEFT_CENTER, 170,118)
	--
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tankDB.tankId):addTo(cell)
		:align(display.LEFT_CENTER,40,self.m_cellSize.height / 2)

	UiUtil.sprite9("info_bg_26.png", 220, 80, 1, 1, 448, 140)
		:addTo(cell, -1):pos(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	local mo = OrdnanceMO.queryTankById(data.tankId)
	local condition = OrdnanceBO.queryScienceById(mo.pukCondition)
	if not condition or condition.level >0 then  -- 可以生产
		local t = UiUtil.button("btn_up_normal.png", "btn_up_selected.png", nil, handler(self,self.onChosenTank),nil,1)
		t.tankId = data.tankId
		cell:addButton(t,390,58)

		local count = OrdnanceBO.getProgress(data.tankId) .."/" ..mo.developPoint
		-- 研发点数
		t = UiUtil.label(CommonText[921] ..count,nil,cc.c3b(140, 140, 140)):addTo(cell):align(display.LEFT_CENTER, 170, 72)
		count = OrdnanceBO.getEquipNum(data.tankId) .."/" ..mo.assembleNum
		t = UiUtil.label(CommonText[922] ..count,nil,cc.c3b(140, 140, 140)):addTo(cell):align(display.LEFT_CENTER, 170, 40)
	else  -- 未达到条件
		t = UiUtil.label(CommonText[923] ..OrdnanceMO.getNameById(mo.pukCondition),nil,COLOR[6],cc.size(160,0),ui.TEXT_ALIGN_LEFT):addTo(cell):align(display.LEFT_TOP, 170, 78)
		t = UiUtil.button("btn_up_normal.png", "btn_up_selected.png", "btn_up_disabled.png",handler(self,self.onChosenTank),nil,1)
		t:setEnabled(false)
		cell:addButton(t,390,58)
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:onChosenTank(tag,sender)
	require("app.view.OrdnanceScience").new(nil,nil,sender.tankId):push()
end

function ContentTableView:onEnter()
	ContentTableView.super.onEnter(self)
	self.m_activityHandler = Notify.register(LOCAL_MILITARY_OPEN, handler(self, self.updateView))
end

function ContentTableView:onExit()
	ContentTableView.super.onExit(self)
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

-----------------------------------总览界面-----------
local OrdnanceStudy = class("OrdnanceStudy",function ()
	return display.newNode()
end)

function OrdnanceStudy:ctor(width,height)
	self:size(width,height)
	local t = UiUtil.sprite9("info_bg_11.png",130,40,1,1,474,height-100)
		:addTo(self):align(display.CENTER_BOTTOM, width - 474 / 2 - 10, 80)
	t = display.newSprite(IMAGE_COMMON .. "info_bg_28.png")
		:addTo(t):pos(t:width()/2,t:height()-10)
	self.title = UiUtil.label(CommonText[920] .."0/0"):addTo(t):center()
	
	self.data = OrdnanceMO.getList()
	--内容
	self.content = ContentTableView.new(cc.size(474, height-174))
		:addTo(self):pos(144,123)
	-- 菜单
	local view = MenuTableView.new(cc.size(130, height - 68),handler(self, self.onChosenMenu))
		:addTo(self):pos(10,20)
	local list = {}
	for k,v in ipairs(self.data) do
		table.insert(list,v.id)
	end
	view:updateUI(list)
	self.m_menuView = view

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local resetBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onClickResetBtn)):addTo(self)
		:align(display.CENTER_BOTTOM, width - 474 / 2 - 10, 20)
	resetBtn:setLabel("重置点数")

	self.resetListener = nil
end


function OrdnanceStudy:onEnter()
	-- body
	-- print("resetListener!!! registered")
	if self.resetListener == nil then
		self.resetListener = Notify.register(LOCAL_MILITARY_SCIENCE_UPDATE, handler(self, self.onResetOrdnance))
	end
end


function OrdnanceStudy:onResetOrdnance(event)
	-- body
	local index = event.obj.type
	self.data = OrdnanceMO.getList()
	local data = self.data[index]
	table.sort(data.list,function(a,b)
			return a.tankId < b.tankId
		end)
	if self.content then
		self.content:updateView({obj = data.list})
	end
end

function OrdnanceStudy:onChosenMenu(index)
	local data = self.data[index]
	table.sort(data.list,function(a,b)
			return a.tankId < b.tankId
		end)
	self:setTotal(index)
	if self.content then
		self.content:updateView({obj = data.list})
	end
end

function OrdnanceStudy:onClickResetBtn()
	-- body
	local allZero = true
	local typeForm = self.index
	local allData = OrdnanceMO.getList()
	local data = allData[self.index]
	table.sort(data.list,function(a,b)
			return a.tankId < b.tankId
		end)

	for i = 1, #data.list do
		local d = data.list[i]
		local list = OrdnanceMO.getTankScience(d.tankId)
		for j = 1, #list do
			local techId = list[j].id
			if OrdnanceBO.science_[techId] and OrdnanceBO.science_[techId].level > 0 then
				allZero = false
				break
			end
		end
	end

	if allZero == true then
		Toast.show("该类研发点数无需重置")
	else
		local goldCost = OrdnanceBO.getResetMilitaryScienceCost(typeForm)
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		local confirmStr = {
			{content="是否花费"},
			{content=string.format("%d", goldCost), color=COLOR[6]},
			{content="金币重置本类研发点数，重置后返还全部材料和坦克"},
		}

		ConfirmDialog.new(confirmStr, function()
			OrdnanceBO.ResetMilitaryScience(function ()
				Toast.show("本类研发重置完毕")
			end, typeForm)
		end):push()

	end
end

function OrdnanceStudy:setTotal(index)
	index = index or self.index
	self.index = index
	local count = 0
	local de = 0
	local list = OrdnanceMO.getList()
	for k,v in pairs(list[self.index].list) do
		count = count + v.developPoint
		de = de + OrdnanceBO.getProgress(v.tankId)
	end

	self.title:setString(CommonText[920] ..de .."/"..count)
end


function OrdnanceStudy:onExit()
	if self.resetListener then
		Notify.unregister(self.resetListener)
		self.resetListener = nil
	end
end

return OrdnanceStudy