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
	local t = nil
	if data.rank <= 3 then
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(54,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(54,self.m_cellSize.height/2)
	end
	t = UiUtil.label(data.partyName, nil, COLOR[12])
		:addTo(cell):alignTo(t,138)
	t = UiUtil.label(data.fightNum)
		:addTo(cell):alignTo(t,170)
	t = UiUtil.label(data.jifen)
		:addTo(cell):alignTo(t,122)
	local l,c = CommonText[20016],COLOR[6]
	if not data.isAttack then
		l = CommonText[20017] 
		c = COLOR[2]
	end
	t = UiUtil.label(l,nil,c)
		:addTo(cell):alignTo(t,55)
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
local RankArmy = class("RankArmy",function ()
	return display.newNode()
end)

function RankArmy:ctor(width,height)
	self:size(width,height)
	local t = display.newSprite(IMAGE_COMMON.."monument.jpg")
		:addTo(self):align(display.CENTER_TOP, width/2, height-5)
	local l = UiUtil.label(CommonText[20030][1]):addTo(t):align(display.LEFT_CENTER, 210, 32)
	l = UiUtil.label(CommonText[20030][2],nil,COLOR[2]):addTo(t):rightTo(l)
	UiUtil.label(CommonText[20030][3]):addTo(t):rightTo(l)

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-t:height()-128)
	bg:addTo(self):pos(width/2,bg:height()/2+118)
	t = UiUtil.label(CommonText[396][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
	t = UiUtil.label(CommonText[105],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 138)
	t = UiUtil.label(CommonText[20031],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 170)
	t = UiUtil.label(CommonText[20030][1],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 122)
	local view = ContentTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)

	UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil,handler(self,self.showDetail),CommonText[269])
		:addTo(self):pos(width/2,30)
	FortressBO.partyRank(function()
		local data = FortressBO.partyRankData_.myRank
		local list = FortressBO.partyRankData_.list
		if list then
			view:updateUI(list)
		end
		if data then
			local center = UiUtil.label(CommonText[20031] ..":"..data.fightNum):addTo(self):pos(width/2,90)
			UiUtil.label(CommonText[20032]..data.rank):addTo(self):alignTo(center, -212)
			UiUtil.label(CommonText[770][3]..":"..data.jifen):addTo(self):alignTo(center, 212)
		end
	end)
end

function RankArmy:showDetail()
	require("app.dialog.MonumentRewardDialog").new():push()
end

return RankArmy