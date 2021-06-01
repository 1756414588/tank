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
	if index <= 3 then
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(54,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(54,self.m_cellSize.height/2)
	end
	t = UiUtil.label(data.nick, nil, COLOR[12])
		:addTo(cell):alignTo(t,138)
	t = UiUtil.label(data.fightNum)
		:addTo(cell):alignTo(t,170)
	t = UiUtil.label(data.jifen)
		:addTo(cell):alignTo(t,122)
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
local RankScore = class("RankScore",function ()
	return display.newNode()
end)

function RankScore:ctor(width,height)
	self:size(width,height)
	local top = display.newSprite(IMAGE_COMMON.."monument.jpg")
		:addTo(self):align(display.CENTER_TOP, width/2, height-5)
	local l = UiUtil.label(CommonText[20033]):addTo(top):align(display.LEFT_CENTER, 210, 55)

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-top:height()-128)
	bg:addTo(self):pos(width/2,bg:height()/2+118)
	local t = UiUtil.label(CommonText[770][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
	t = UiUtil.label(CommonText[770][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 138)
	t = UiUtil.label(CommonText[20031],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 170)
	t = UiUtil.label(CommonText[770][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 122)
	self.view = ContentTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)
	self.num = UiUtil.label(CommonText[20031]):addTo(self):pos(width/2,90)
	self.rank = UiUtil.label(CommonText[20032]):addTo(self):alignTo(self.num, -212)
	self.score = UiUtil.label(CommonText[770][3]):addTo(self):alignTo(self.num, 212)
	UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil,handler(self,self.showDetail),CommonText[269])
		:addTo(self):pos(width/2,30)
	--tab按钮
    self.winBtn = UiUtil.button("btn_12_normal.png", "btn_12_selected.png", nil, handler(self,self.showIndex),CommonText[751])
   		:addTo(top,0,1):pos(318,25)
  	self.winBtn:selected()
  	
  	self.partyBtn = UiUtil.button("btn_12_normal.png", "btn_12_selected.png", nil, handler(self,self.showIndex),CommonText[10041][3])
  	 	:addTo(top,0,2):pos(466,25)
  	self.partyBtn:setScaleX(-1)
  	self.partyBtn.m_label:setScaleX(-1)
  	self.partyBtn:unselected()

  	self:showIndex(1)
end

function RankScore:showIndex(tag,sender)
	if tag == 1 then
		self.winBtn:selected()
		self.partyBtn:unselected()
	else
		self.winBtn:unselected()
		self.partyBtn:selected()
	end
	self:getInfo(tag)
end

function RankScore:getInfo(index)
	FortressBO.scoreRank(0,index,function()
		local data = FortressBO.scoreRankData_.myRank
		local list = FortressBO.scoreRankData_.list
		self.view:updateUI(list)
		local str = index == 1 and CommonText[20032] or CommonText[391]..":"
		if data then
			self.num:setString(CommonText[20031] ..":"..data.fightNum)
			self.rank:setString(str..data.rank)
			self.score:setString(CommonText[770][3]..":"..data.jifen)
		else
			self.num:setString(CommonText[20031] ..":0")
			self.rank:setString(str..0)
			self.score:setString(CommonText[770][3]..":0")
		end
	end)
end

function RankScore:showDetail()
	require("app.dialog.MonumentRewardDialog").new():push()
end

return RankScore