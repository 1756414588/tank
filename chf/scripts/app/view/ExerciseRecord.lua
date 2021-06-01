--
-- Author: Xiaohang
-- Date: 2016-08-30 16:45:42
--
----------------军团战记录----------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 76)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	local tankDB = TankMO.queryTankById(data.v1)
	local t = UiUtil.createItemSprite(ITEM_KIND_TANK, tankDB.tankId)
			:addTo(cell):pos(52,self.m_cellSize.height/2)
	local name = UiUtil.label(tankDB.name, nil, COLOR[tankDB.grade])
		:addTo(cell):alignTo(t,150)
	t = UiUtil.label(data.v2,nil,COLOR[14]):addTo(cell):alignTo(t,365)
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
	self.m_activityList = data or {}
	self:reloadData()
end

-----------------------------------总览界面-----------
local ExerciseRecord = class("ExerciseRecord",UiNode)

function ExerciseRecord:ctor(viewFor)
	uiEnter = uiEnter or UI_ENTER_NONE
	ExerciseRecord.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function ExerciseRecord:onEnter()
	ExerciseRecord.super.onEnter(self)
	self:setTitle(CommonText[20024])
	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, self:getBg():width()-40, display.height - 190)
	bg:addTo(self:getBg(),3):pos(self:getBg():width()/2,bg:height()/2+80)
	local t = UiUtil.label(CommonText[20034],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
	t = UiUtil.label(CommonText[40],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 365)

	local view = ContentTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)
	t = UiUtil.label(CommonText[20111]):addTo(self):align(display.LEFT_CENTER,70,48)
	self.num = UiUtil.label(0,nil,COLOR[2]):rightTo(t, 10)
	ExerciseBO.getRank(4,function(data)
			self.num:setString(ExerciseBO.ranks.getExploit)
			view:updateUI(ExerciseBO.record)
		end)
end

return ExerciseRecord