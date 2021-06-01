--
-- Author: Xiaohang
-- Date: 2016-08-10 11:45:32
--
----------------军团战记录----------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, UI_ENTER_NONE)
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
	t = UiUtil.label(data.name,nil,COLOR[2]):addTo(cell):alignTo(t, 110)
	t = UiUtil.label(UiUtil.strNumSimplify(data.fightNum),nil,COLOR[12]):addTo(cell):alignTo(t, 110)
	t = display.newSprite(IMAGE_COMMON..(data.camp and "icon_capture_person.png" or "icon_capture_party.png")):addTo(cell):alignTo(t, 110)
	UiUtil.label(data.successNum .."/" ..data.failNum,nil,COLOR[2]):addTo(cell):alignTo(t, 110)
	return cell
end

function ContentTableView:numberOfCells()
	if #self.m_activityList < RANK_PAGE_NUM or #self.m_activityList >= 100 then
		return #self.m_activityList
	else
		return #self.m_activityList + 1
	end
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
	self.m_activityList = data or {}
	self:reloadData()
end

-----------------------------------总览界面-----------
local ExerciseRank = class("ExerciseRank",UiNode)

function ExerciseRank:ctor()
	ExerciseRank.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function ExerciseRank:onEnter()
	ExerciseRank.super.onEnter(self)
	self:setTitle(CommonText[774][2])
	local t = UiUtil.label(CommonText[20085][1]):addTo(self):align(display.LEFT_CENTER,30,display.height-115)
	self.win = UiUtil.label(CommonText[20052]):rightTo(t)
	t = UiUtil.label(CommonText[20070]):addTo(self):alignTo(t,-26,1)
	self.myCamp = UiUtil.label(CommonText[20052]):rightTo(t)
	t = UiUtil.label(CommonText[391]..":"):addTo(self):alignTo(t,-26,1)
	self.myRank = UiUtil.label(0,nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[20085][2]):addTo(self):alignTo(t,-26,1)
	self.myInfo = UiUtil.label(0 ..CommonText[20026][1] .."/".. 0 ..CommonText[20026][2],nil,COLOR[12]):rightTo(t)

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, self:getBg():width()-40, display.height - 300)
	bg:addTo(self:getBg(),3):pos(self:getBg():width()/2,bg:height()/2+95)
	t = UiUtil.label(CommonText[770][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(68,bg:height()-24)
	t = UiUtil.label(CommonText[770][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 110)
	t = UiUtil.label(CommonText[894][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 110)
	t = UiUtil.label(CommonText[20083],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 110)
	t = UiUtil.label(CommonText[20084],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 110)

	local view = ContentTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)
	ExerciseBO.getRank(4,function(data)
			view:updateUI(data.ranks)
			if data.successCamp ~= 0 then
				self.win:setString(ExerciseBO.data.status == 7 and CommonText[20066][data.successCamp==1 and 2 or 1] or CommonText[20052])
				self.win:setColor(ExerciseBO.data.status == 7 and COLOR[data.successCamp==1 and 6 or 3] or display.COLOR_WHITE)
			end
			self.myCamp:setString(ExerciseBO.data.status == 7 and CommonText[20066][data.myCamp and 2 or 1] or CommonText[20052])
			self.myCamp:setColor(ExerciseBO.data.status == 7 and COLOR[data.myCamp and 6 or 3] or display.COLOR_WHITE)
			self.myRank:setString(data.myRank)
			self.myInfo:setString(data.successNum ..CommonText[20026][1] .."/".. data.failNum ..CommonText[20026][2])
		end)

	UiUtil.button("btn_9_normal.png","btn_9_selected.png",nil,handler(self, self.perRank),CommonText[10062][1])
		:addTo(self):pos(150,60)
	UiUtil.button("btn_19_normal.png","btn_19_selected.png",nil,handler(self, self.allRank),CommonText[20089])
		:addTo(self):pos(display.width-150,60)
end

function ExerciseRank:perRank()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ExerciseRewardDialog").new(1):push()
end

function ExerciseRank:allRank()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ExerciseRewardDialog").new(2):push()
end

return ExerciseRank