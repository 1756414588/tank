--
-- Author: Xiaohang
-- Date: 2016-05-19 17:18:48
--
local ContentTableView = class("WarTableView", TableView)
local COLOR_INDEX = {6,12,4}
function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 76)
	self.m_activityList = {1,2,3,4,5,6,7,8,9}
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	local c = cc.c3b(224,214,156)
	if index <= 3 then
		c = COLOR[COLOR_INDEX[index]]
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(33,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(33,self.m_cellSize.height/2)
	end
	t = UiUtil.label(data.name, 18, c)
		:addTo(cell):alignTo(t,230)
	t:y(t:y() + 18)
	UiUtil.label(data.serverName,18,cc.c3b(150, 150, 150))
		:addTo(cell):alignTo(t, -36, 1)
	t = UiUtil.label(UiUtil.strNumSimplify(data.fight),nil,COLOR[12])
		:addTo(cell):alignTo(t,230)
	t:y(t:y()-18)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width-10, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
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

--------------------------------------------------------------------
local CrossRank = class("CrossRank",function ()
	return display.newNode()
end)

function CrossRank:ctor(width,height,type)
	self:size(width,height)
	self.type = type
	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-20-110)
	bg:addTo(self):pos(width/2,bg:height()/2+110)
	t = UiUtil.label(CommonText[396][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(65,bg:height()-24)
	t = UiUtil.label(CommonText[396][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 230)
	t = UiUtil.label(CommonText[33],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 230)
	local view = ContentTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)

	UiUtil.label(CommonText[30044])
		:addTo(self):align(display.LEFT_CENTER,40,85)
	UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.rankReview), CommonText[269])
		:addTo(self):pos(120,35)
	self.getBtn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self, self.getReward), CommonText[777][1])
		:addTo(self):pos(width-120,35)
	self.getBtn:setEnabled(false)
	t = UiUtil.label(CommonText[10067][4]):addTo(self):align(display.LEFT_CENTER,458,85)
	self.myRank = UiUtil.label(CommonText[768],nil,COLOR[2]):rightTo(t)
	CrossBO.rankInfo(self.type,function()
			if not CrossBO.rankInfo_[self.type] then return end
			view:updateUI(CrossBO.rankInfo_[self.type].list)
			if CrossBO.rankInfo_[self.type].myRank > 0 then
				self.myRank:setString(CrossBO.rankInfo_[self.type].myRank)
			end
			self:checkState()
		end)
end

function CrossRank:checkState()
	if CrossBO.rankInfo_[self.type] then
		if CrossBO.rankInfo_[self.type].state == 2 then
			self.getBtn:setLabel(CommonText[777][3])
			self.getBtn:setEnabled(false)
		elseif CrossBO.rankInfo_[self.type].myRank > 0 and CrossBO.rankInfo_[self.type].myRank < 65 then
			self.getBtn:setLabel(CommonText[777][1])
			self.getBtn:setEnabled(true)
		end
	else
		self.getBtn:setLabel(CommonText[777][1])
		self.getBtn:setEnabled(false)
	end
end

function CrossRank:rankReview()
	require("app.dialog.CrossAwardDialog").new(self.type):push()
end

function CrossRank:getReward()
	CrossBO.getRank(self.type,function()
			self:checkState()
		end)
end

return CrossRank