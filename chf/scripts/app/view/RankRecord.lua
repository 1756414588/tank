--
-- Author: Xiaohang
-- Date: 2016-05-07 15:31:39
--
----------------军团排行----------
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
			:addTo(cell):pos(54,self.m_cellSize.height/2)
	local name = UiUtil.label(tankDB.name, nil, COLOR[tankDB.grade])
		:addTo(cell):alignTo(t,150)
	t = UiUtil.label(data.v2)
		:addTo(cell):alignTo(t,365)
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
local RankRecord = class("RankRecord",function ()
	return display.newNode()
end)

function RankRecord:ctor(width,height)
	self:size(width,height)
	local t = display.newSprite(IMAGE_COMMON.."monument.jpg")
		:addTo(self):align(display.CENTER_TOP, width/2, height-5)
	--tab按钮
    self.winBtn = UiUtil.button("btn_12_normal.png", "btn_12_selected.png", nil, handler(self,self.showIndex),CommonText[806][3])
   		:addTo(t,0,1):pos(318,40)
  	self.winBtn:selected()
  	
  	self.partyBtn = UiUtil.button("btn_12_normal.png", "btn_12_selected.png", nil, handler(self,self.showIndex),CommonText[806][2])
  	 	:addTo(t,0,2):pos(466,40)
  	self.partyBtn:setScaleX(-1)
  	self.partyBtn.m_label:setScaleX(-1)
  	self.partyBtn:unselected()

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-t:height()-68)
	bg:addTo(self):pos(width/2,bg:height()/2+58)
	t = UiUtil.label(CommonText[20034],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
	t = UiUtil.label(CommonText[40],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 365)
	self.view = ContentTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)
	
	local t = UiUtil.label(CommonText[20031]..":"):addTo(self)
		:align(display.LEFT_CENTER, 42, 30)
	self.fightNum = UiUtil.label(0,nil,COLOR[2]):addTo(self):rightTo(t)
	t = UiUtil.label(CommonText[20035]..":"):addTo(self)
		:align(display.LEFT_CENTER, 270, 30)
	self.winNum = UiUtil.label(0,nil,COLOR[2]):addTo(self):rightTo(t)
	self:showIndex(1)
end

function RankRecord:showIndex(tag,sender)
	if tag == 1 then
		self.winBtn:selected()
		self.partyBtn:unselected()
	else
		self.winBtn:unselected()
		self.partyBtn:selected()
	end
	self:getInfo(tag)
end

function RankRecord:getInfo(index)
	FortressBO.combatStatics(index,function()
		local data = FortressBO.combatRankData_
		self.view:updateUI(data.list)
		self.fightNum:setString(data.fightNum or 0)
		self.winNum:setString(data.winNum or 0)
	end)
end

return RankRecord