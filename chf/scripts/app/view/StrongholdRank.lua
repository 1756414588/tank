--
-- Author: Xiaohang
-- Date: 2016-08-10 10:24:30
--
----------------据点排行----------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 76)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	local t = nil
	if index <= 3 then
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(36,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(36,self.m_cellSize.height/2)
	end
	t = UiUtil.label(data.name,nil,COLOR[data.camp and 6 or 3]):addTo(cell):alignTo(t, 135)
	t = display.newSprite(IMAGE_COMMON..(data.camp and "icon_capture_person.png" or "icon_capture_party.png")):addTo(cell):alignTo(t, 135)
	UiUtil.label(data.successNum .."/" ..data.failNum,nil,COLOR[2]):addTo(cell):alignTo(t, 135)
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
local StrongholdRank = class("StrongholdRank",function ()
	return display.newNode()
end)

function StrongholdRank:ctor(width,height,kind)
	self:size(width,height)
	self.kind = kind

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-40, height - 50)
	bg:addTo(self):align(display.CENTER_TOP,width/2,height-10)
	local t = UiUtil.label(CommonText[804][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(68,bg:height()-24)
	t = UiUtil.label(CommonText[804][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 135)
	t = UiUtil.label(CommonText[20083],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 135)
	t = UiUtil.label(CommonText[20084],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 135)

	local view = ContentTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)
	ExerciseBO.getRank(kind,function(data)
			view:updateUI(data.ranks)
			local t = UiUtil.label(CommonText[391]..":".. data.myRank):addTo(self):align(display.LEFT_CENTER,50,15)
			UiUtil.label(CommonText[20084]..":".. data.successNum .."/" ..data.failNum):addTo(self):align(display.LEFT_CENTER,400,15)
		end)	
end

return StrongholdRank