--
-- Author: Your Name
-- Date: 2017-05-26 12:35:37
--
--淬炼大师活动排行界面
--------------------------排行tableview-----------------
local RefineMasterTableView = class("RefineMasterTableView", TableView)

function RefineMasterTableView:ctor(size,kind)
	RefineMasterTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 86)
	self.kind = kind
	self.list = {}
end

function RefineMasterTableView:onEnter()
	RefineMasterTableView.super.onEnter(self)
end

function RefineMasterTableView:createCellAtIndex(cell, index)
	RefineMasterTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(550, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	
	local rankTitle = ArenaBO.createRank(index)
	rankTitle:setPosition(45, 40)
	bg:addChild(rankTitle)

	local name = ui.newTTFLabel({text = data.nick, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 192, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	if index == 1 then
		name:setColor(COLOR[6])
	elseif index == 2 then
		name:setColor(COLOR[12])
	elseif index == 3 then
		name:setColor(COLOR[4])
	else
		name:setColor(COLOR[11])
	end

	local scoreValue = ui.newTTFLabel({text = data.rankValue, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 470, y = 40, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	return cell
end

function RefineMasterTableView:numberOfCells()
	return #self.list
end

function RefineMasterTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RefineMasterTableView:updateUI(list)
	self.list = list
	self:reloadData()
end

-----------------------------------总览界面-----------
local RefineMasterRank = class("RefineMasterRank",function ()
	return display.newNode()
end)

function RefineMasterRank:ctor(activity,data,width,height)
	self:size(width,height)
	self.m_activity = activity
	self.m_data = data
	self:showInfo()
end

function RefineMasterRank:showInfo()
	local rankInfo = self.m_data
	local myRanhInfo = rankInfo.actPlayerRank
	-- --我的积分
	local myPoint = UiUtil.label(CommonText[764][1],nil,cc.c3b(125,125,125)):addTo(self):align(display.LEFT_CENTER,40,self:height()-25)
	local point = UiUtil.label(rankInfo.score,nil,COLOR[2]):rightTo(myPoint)
	local myRank = UiUtil.label(CommonText[764][2],nil,cc.c3b(125,125,125)):addTo(self):align(display.LEFT_CENTER,self:width() / 2,self:height()-25)
	self.rankInfo = ActivityCenterBO.getMyRefineMasterRank(myRanhInfo)
	local rankNum = UiUtil.label(self.rankInfo):rightTo(myRank)
	local desc = UiUtil.label(CommonText[764][3],nil,cc.c3b(125,125,125)):alignTo(myPoint,-26,1)
	local time = UiUtil.label(CommonText[853],nil,cc.c3b(125,125,125)):alignTo(myRank,-26,1)
	self.timeUp =  UiUtil.label(UiUtil.strActivityTime(self.m_activity.endTime - ManagerTimer.getTime()),nil,COLOR[2]):rightTo(time)

	if self.rankInfo == CommonText[768] then
		rankNum:setColor(COLOR[6])
	else
		rankNum:setColor(COLOR[2])
	end

  	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, self:width()-20, self:height()-130)
  	bg:addTo(self):pos(self:width()/2,bg:height()/2+65)
  	self.bg = bg
  	local t = UiUtil.label(CommonText[396][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
  	t = UiUtil.label(CommonText[396][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 138)
  	t = UiUtil.label(CommonText[770][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 290)
	--内容
	local view = RefineMasterTableView.new(cc.size(560, bg:height()-55),kind)
		:addTo(bg):pos(30,10)
	self.view = view
	if myRanhInfo and #myRanhInfo > 0 then
		self.view:updateUI(myRanhInfo)
	end
	UiUtil.button("btn_9_normal.png","btn_9_selected.png",nil,handler(self, self.lookAward),CommonText[769][1])
		:addTo(self):pos(110,30)
	self.getBtn = UiUtil.button("btn_11_normal.png","btn_11_selected.png","btn_9_disabled.png",handler(self, self.getAward),CommonText[769][3])
		:addTo(self):pos(self:width() - 110,30)
	self.getBtn.rankType = rankInfo.status
	self:checkGetState()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function RefineMasterRank:checkGetState()
	if self.rankInfo == CommonText[768] then
		self.getBtn:setEnabled(false)
		return
	end
	if table.isexist(self.m_data, "open") then
		if self.m_data.open == true and self.m_data.status == 0 then
			self.getBtn:setLabel(CommonText[777][1])
		elseif self.m_data.open == false and self.m_data.status == 0 then
			self.getBtn:setLabel(CommonText[777][1])
			self.getBtn:setEnabled(false)
		else
			self.getBtn:setLabel(CommonText[777][3])
			self.getBtn:setEnabled(false)
		end
	else
		self.getBtn:setEnabled(false)
	end
end

function RefineMasterRank:update(dt)
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.timeUp:setString(UiUtil.strActivityTime(leftTime))
	else
		self.timeUp:setString(CommonText[852])
	end
end

function RefineMasterRank:lookAward()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityFortuneAwardDialog").new(self.m_activity.activityId):push()
end

function RefineMasterRank:getAward(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynGetRankAward(function()
			Loading.getInstance():unshow()
			self.getBtn:setLabel(CommonText[777][3])
			self.getBtn:setEnabled(false)
		end,self.m_activity.activityId,sender.rankType)
end

return RefineMasterRank