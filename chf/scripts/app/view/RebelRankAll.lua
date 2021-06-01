--
-- Author: Xiaohang
-- Date: 2016-09-06 16:42:36
--
-----------------------------------内容条界面---------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,kind)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 86)
	self.kind = kind
	self.list = {}
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.list[index]
	local t = nil
	if index <= 3 then
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(57,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(57,self.m_cellSize.height/2)
	end
	t = UiUtil.label(data.name,nil,COLOR[2]):addTo(cell):alignTo(t, 138)
	t = UiUtil.label("/"..data.killGuard.."/",nil,COLOR[3]):alignTo(t, 170)
	UiUtil.label(data.killUnit,nil,COLOR[2]):leftTo(t)
	UiUtil.label(data.killLeader,nil,COLOR[4]):rightTo(t)

	t = UiUtil.label(data.score,nil,COLOR[2]):addTo(cell):alignTo(t, 122)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(560, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
	return cell
end

function ContentTableView:numberOfCells()
	return #self.list
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(list)
	self.list = list
	self:reloadData()
end

function ContentTableView:onBack(tag,sender)
	ExerciseBO.fightReport(sender.key)
end

-----------------------------------总览界面-----------
local RebelRankAll = class("RebelRankAll",function ()
	return display.newNode()
end)

function RebelRankAll:ctor(width,height)
	self:size(width,height)
	RebelBO.getRank(2,0,handler(self, self.showInfo))
end

function RebelRankAll:showInfo()
	local t = UiUtil.label(CommonText[20123],nil,cc.c3b(125,125,125)):addTo(self):align(display.LEFT_CENTER,40,self:height()-25)
	self:showLeft(t)
	t = UiUtil.label(CommonText[764][1],nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	self.myScore = UiUtil.label(RebelBO.rankData.score,nil,COLOR[3]):rightTo(t)
	t = UiUtil.label(CommonText[20028] .."：",nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	self.rankNum = UiUtil.label(RebelBO.rankData.rank == 0 and CommonText[768] or RebelBO.rankData.rank):rightTo(t)

  	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, self:width()-20, self:height()-140)
  	bg:addTo(self):pos(self:width()/2,bg:height()/2+45)
  	self.bg = bg
  	local t = UiUtil.label(CommonText[396][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
  	t = UiUtil.label(CommonText[396][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 138)
  	t = UiUtil.label(CommonText[20124],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 170)
  	t = UiUtil.label(CommonText[770][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 122)
	--内容
	local view = ContentTableView.new(cc.size(560, bg:height()-55),kind)
		:addTo(bg):pos(30,10)
	self.view = view
	self.view:updateUI(RebelBO.rankData.rebelRanks)
	UiUtil.label(CommonText[10061][1]):addTo(self):align(display.LEFT_CENTER,40,20)
end

function RebelRankAll:showLeft(label)
	label:removeAllChildren()
	local t = UiUtil.label(CommonText[20120][1],nil,COLOR[2]):addTo(label):align(display.LEFT_CENTER,label:width()+5,label:height()/2)
	t = UiUtil.label(":" ..RebelBO.rankData.killUnit,nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(" " ..CommonText[20120][2],nil,COLOR[3]):rightTo(t,10)
	t = UiUtil.label(":" ..RebelBO.rankData.killGuard,nil,COLOR[3]):rightTo(t)
	t = UiUtil.label(" " ..CommonText[20120][3],nil,COLOR[4]):rightTo(t,10)
	t = UiUtil.label(":" ..RebelBO.rankData.killLeader,nil,COLOR[4]):rightTo(t)
end

return RebelRankAll