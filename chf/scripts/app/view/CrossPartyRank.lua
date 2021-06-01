--
-- Author: xiaoxing
-- Date: 2016-11-24 10:30:44
--
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 76)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	if index == #self.m_activityList + 1 then -- 最后一个按钮
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_normal.png")
		normal:setPreferredSize(cc.size(500, 76))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_selected.png")
		selected:setPreferredSize(cc.size(500, 76))
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onNextCallback))
		btn:setLabel(CommonText[577])
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		return cell
	end
	local data = self.m_activityList[index]
	local t = nil
	if index <= 3 then
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(54,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(54,self.m_cellSize.height/2)
	end
	if self.kind == 1 then
		local n = UiUtil.label("",nil,COLOR[2]):addTo(cell):alignTo(t, 138)
		UiUtil.label(data.name,nil,COLOR[2]):addTo(cell):alignTo(n,-18,1)
		UiUtil.label(data.serverName):addTo(cell):alignTo(n,18,1)
		n = UiUtil.label(data.fightCount):addTo(cell):alignTo(n,170)
		n = UiUtil.label(data.jifen):addTo(cell):alignTo(n,122)
	elseif self.kind == 2 then
		local n = UiUtil.label("",nil,COLOR[2]):addTo(cell):alignTo(t, 138)
		UiUtil.label(data.name,nil,COLOR[2]):addTo(cell):alignTo(n,-18,1)
		UiUtil.label(data.serverName):addTo(cell):alignTo(n,18,1)
		n = UiUtil.label(data.winCount):addTo(cell):alignTo(n,170)
		ui.newBMFontLabel({text = UiUtil.strNumSimplify(data.fight), font = "fnt/num_2.fnt"}):addTo(cell):alignTo(n,122)
	elseif self.kind == 3 then
		local n = UiUtil.label("",nil,COLOR[2]):addTo(cell):alignTo(t, 138)
		UiUtil.label(data.serverName):addTo(cell):alignTo(n,-18,1)
		UiUtil.label(data.partyName,nil,COLOR[5]):addTo(cell):alignTo(n,18,1)
		n = ui.newBMFontLabel({text = UiUtil.strNumSimplify(data.fight), font = "fnt/num_2.fnt"}):addTo(cell):alignTo(n,170)
		n = UiUtil.label(data.jifen):addTo(cell):alignTo(n,122)
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width-10, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
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

function ContentTableView:onNextCallback(tag, sender)
	local page = math.ceil(#self.m_activityList / RANK_PAGE_NUM)
	CrossPartyBO.rankInfo(self.kind,page,function()

			local data = CrossPartyBO.rankInfo_[self.kind]
			local list = {}
			if data then list = data.list end

			-- self.myRank = data and data.myRank
			-- self.view:updateUI(list,tag)

			for k,v in ipairs(list) do
				table.insert(self.m_activityList, v)
			end
			local oldHeight = self:getContainer():getContentSize().height
			self:updateUI(self.m_activityList,self.kind)
			local delta = self:getContainer():getContentSize().height - oldHeight
			self:setContentOffset(cc.p(0, -delta))
		end)
end

function ContentTableView:onBack(tag,sender)
	FortressBO.fightReport(sender.key)
end

function ContentTableView:updateUI(data,kind)
	self.m_activityList = data or {}
	self.kind = kind
	self:reloadData()
end

--------------------------------------------------------------------
local CrossPartyRank = class("CrossPartyRank",function ()
	return display.newNode()
end)
function CrossPartyRank:ctor(width,height)
	self:size(width,height)
	self.type = type
	local t = display.newSprite(IMAGE_COMMON.."monument.jpg")
		:addTo(self):align(display.CENTER_TOP, width/2, height-5)
	self.numLabel = UiUtil.label(""):addTo(t):align(display.LEFT_CENTER, 270, 45)
	self.num = UiUtil.label("",nil,COLOR[2]):rightTo(self.numLabel)
	self.rankLabel = UiUtil.label(""):addTo(t):align(display.LEFT_CENTER, 270, 23)
	self.rank = UiUtil.label(""):rightTo(self.rankLabel)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(self):pos(width/2,height-235)

	local frame = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-40, height - 340)
	frame:addTo(self,3):pos(width/2,frame:height()/2+70)
	self.labs = {
		{CommonText[396][1],CommonText[396][2],CommonText[20031],CommonText[770][3]},
		CommonText[804],
		{CommonText[396][1],CommonText[805][2],CommonText[805][4],CommonText[20030][1]}
	}
	self.titleLal = {}
	t = UiUtil.label(CommonText[396][1],nil,cc.c3b(150,150,150)):addTo(frame):pos(85,frame:height()-24)
	self.titleLal[1] = t
	t = UiUtil.label(CommonText[105],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 138)
	self.titleLal[2] = t
	t = UiUtil.label(CommonText[20031],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 170)
	self.titleLal[3] = t
	t = UiUtil.label(CommonText[20030][1],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 122)
	self.titleLal[4] = t
	self.view = ContentTableView.new(cc.size(560, frame:height()-55))
		:addTo(frame):pos(30,10)
	--tab按钮
    self.btn1 = UiUtil.button("btn_53_normal.png", "btn_53_selected.png", nil, handler(self,self.showIndex),CommonText[30062])
   		:addTo(bg,0,1):pos(135,bg:height()/2+2)
  	self.btn2 = UiUtil.button("btn_54_normal.png", "btn_54_selected.png", nil, handler(self,self.showIndex),CommonText[802][1])
  	 	:addTo(bg,0,2):alignTo(self.btn1, 184)
 	self.btn3 = UiUtil.button("btn_53_normal.png", "btn_53_selected.png", nil, handler(self,self.showIndex),CommonText[802][2])
 		:addTo(bg,0,3):alignTo(self.btn2, 184)
  	self.btn3:setScaleX(-1)
  	self.btn3.m_label:setScaleX(-1)

  	self:showIndex(1)

  	t = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self,self.personRank), CommonText[10062][1]):addTo(self):pos(80,26)
  	t = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self,self.winRank), CommonText[803][1]):rightTo(t)
  	t = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self,self.partyRank), CommonText[10062][2]):rightTo(t)
  	t = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self,self.allRank), CommonText[10062][3]):rightTo(t)
end

function CrossPartyRank:showIndex(tag,sender)
	for i=1,3 do
		if i == tag then
			self.tag = tag
			self["btn"..i]:selected()
			local lab = self.labs[tag]
			for k,v in ipairs(lab) do
				self.titleLal[k]:setString(v)
			end
			CrossPartyBO.rankInfo(tag,0,function(score)
				local data = CrossPartyBO.rankInfo_[tag]
				local list = {}
				if data then list = data.list end
				self.myRank = data and data.myRank
				self:showRank(tag,score)
				self.view:updateUI(list,tag)
			end)
		else
			self["btn"..i]:unselected()
		end
	end
end

function CrossPartyRank:showRank(kind,score)
	local value = 0
	self.numLabel:hide()
	self.num:hide()
	if kind == 1 then
		self.numLabel:setString(CommonText[764][1])
		self.rankLabel:setString(CommonText[764][2])
		self.num:setString(score or 0)
		self.num:x(self.numLabel:x() + self.numLabel:width())
		self.numLabel:show()
		self.num:show()
	elseif kind == 2 then
		self.rankLabel:setString(CommonText[764][2])
	elseif kind == 3 then
		self.rankLabel:setString(CommonText[30068][2])
	end
	local l,c = CommonText[768],COLOR[6]
	if self.myRank and self.myRank.rank > 0 then
		l,c = self.myRank.rank,COLOR[2]
	end
	self.rank:x(self.rankLabel:x() + self.rankLabel:width())
	self.rank:setString(l)
	self.rank:setColor(c)
end

function CrossPartyRank:refreshUI(add)
	if self.tag == 1 and add > 0 then
		self.num:setString(tonumber(self.num:getString()) + add)
	end
end

function CrossPartyRank:personRank(tag,sender)
	ManagerSound.playNormalButtonSound()
	CrossPartyBO.rankInfo(1,0,function()
		local data = CrossPartyBO.rankInfo_[1]
		self.myRank = data and data.myRank
		require("app.dialog.RankAwardDialog").new(CommonText[10062][1],"serverPartyPersonAward",self.myRank,handler(self, self.refreshUI)):push()
	end)
end

function CrossPartyRank:winRank(tag,sender)
	ManagerSound.playNormalButtonSound()
	CrossPartyBO.rankInfo(2,0,function()
		local data = CrossPartyBO.rankInfo_[2]
		self.myRank = data and data.myRank
		require("app.dialog.RankAwardDialog").new(CommonText[803][1],"serverPartyWinAward",self.myRank,handler(self, self.refreshUI)):push()
	end)
end

function CrossPartyRank:partyRank(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.RebelAwardDialog").new("serverPartyRankAward"):push()
end

function CrossPartyRank:allRank(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.RebelAwardDialog").new("serverPartyAllAward"):push()
end

return CrossPartyRank