--
-- Author: Xiaohang
-- Date: 2016-05-17 17:23:16
--
local Info = class("Info",function ()
	return display.newNode()
end)

function Info:ctor(width,height,kind)
	self:size(width,height)
	local t = UiUtil.label(CommonText[30016]):addTo(self):align(display.LEFT_CENTER, 65, height-18)
	UiUtil.label(CrossMO.getScroeTime()):addTo(self):rightTo(t)
	t = display.newSprite(IMAGE_COMMON .."info_bg_29.jpg")
		:addTo(self,2):align(display.CENTER_TOP, width/2, height-35)
	UiUtil.sprite9("btn_head_normal.png", 60, 90, 10, 10, 262, 360)
		:addTo(t):pos(155,290)
	display.newSprite(IMAGE_COMMON.."group1.jpg")
		:addTo(t):pos(155,295)
	UiUtil.label(CommonText[30017] ..(kind == 1 and CrossBO.jyGroupPlayerNum_ or CrossBO.dfGroupPlayerNum_),nil,COLOR[2]):addTo(t):pos(155,178)
	local panel = UiUtil.sprite9("info_bg_15.png", 30, 30, 1, 1, 260, 350)
		:addTo(t):pos(436,296)
	display.newSprite(IMAGE_COMMON.."info_bg_12.png")
		:addTo(t):align(display.LEFT_CENTER, 315, 433)
	UiUtil.label(CommonText[30015][kind]):addTo(t):align(display.LEFT_CENTER, 357, 433)
	if CrossBO.myGroup_ == kind then
		local l = UiUtil.label(CommonText[30018][1],nil,cc.c3b(200,200,200)):addTo(t):align(display.LEFT_CENTER, 332, 385)
		UiUtil.label(UserMO.nickName_,nil,COLOR[12]):addTo(t):rightTo(l)
		l = UiUtil.label(CommonText[567][2],nil,cc.c3b(200,200,200)):addTo(t):alignTo(l, -36, 1)
		UiUtil.label(UserMO.level_,nil,COLOR[12]):addTo(t):rightTo(l)
		l = UiUtil.label(CommonText[642][5],nil,cc.c3b(200,200,200)):addTo(t):alignTo(l, -36, 1)
		UiUtil.label(UiUtil.strNumSimplify(UserMO.fightValue_),nil,COLOR[12]):addTo(t):rightTo(l)
		l = UiUtil.label(CommonText[30018][2],nil,cc.c3b(200,200,200)):addTo(t):alignTo(l, -36, 1)
		UiUtil.label(PartyMO.partyData_ and PartyMO.partyData_.partyName or CommonText[509],nil,COLOR[12]):addTo(t):rightTo(l)
		l = UiUtil.label(CommonText[30018][3],nil,cc.c3b(200,200,200)):addTo(t):alignTo(l, -36, 1)
		UiUtil.label(LoginMO.getServerById(GameConfig.areaId).name,nil,COLOR[12]):addTo(t):rightTo(l)
	else
		UiUtil.label(CommonText[797][2]):addTo(panel):center()
	end
	UiUtil.label(CommonText[30019][kind])
		:addTo(t):pos(t:width()/2,90)
end
-------------------------
local WarTableView = class("WarTableView", TableView)
function WarTableView:ctor(size)
	WarTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 76)
end

function WarTableView:createCellAtIndex(cell, index)
	WarTableView.super.createCellAtIndex(self, cell, index)
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
	local t = UiUtil.label(os.date("%H:%M", data.time),nil,cc.c3b(150,150,150)):addTo(cell):pos(36,self.m_cellSize.height/2)
	local n = UiUtil.label(data.name1,nil,COLOR[2]):addTo(cell):alignTo(t, 120)
	n:y(n:y()-20)
	n = UiUtil.label(data.serverName1):addTo(cell):alignTo(t, 120)
	n:y(n:y()+20)
	local vs = UiUtil.label("VS",32,COLOR[12]):addTo(cell):alignTo(t, 215)
	n = UiUtil.label(data.name2,nil,COLOR[2]):addTo(cell):alignTo(t, 310)
	n:y(n:y()-20)
	n = UiUtil.label(data.serverName2):addTo(cell):alignTo(t, 310)
	n:y(n:y()+20)
	local l,c = CommonText[20026][1],COLOR[12]
	if data.result == 0 then
		l,c = CommonText[20026][2],COLOR[6]
	elseif data.result == -1 then
		l,c = CommonText[20026][3],COLOR[6]
	end
	t = UiUtil.label(l,nil,c):addTo(cell):alignTo(t, 415)
	t = UiUtil.button("btn_replay_normal.png", "btn_replay_selected.png", nil, handler(self, self.onBack), nil, 1)
	cell:addButton(t,510,self.m_cellSize.height/2)
	t.key = data.reportKey
	t.detail = data.detail
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width-10, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
	return cell
end

function WarTableView:numberOfCells()
	if #self.m_activityList < RANK_PAGE_NUM or #self.m_activityList >= 100 then
		return #self.m_activityList
	else
		return #self.m_activityList + 1
	end
end

function WarTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function WarTableView:onNextCallback(tag, sender)
	local page = math.ceil(#self.m_activityList / RANK_PAGE_NUM)

	CrossBO.getCrossPerson(page,function(list)
			for k,v in ipairs(list) do
				table.insert(self.m_activityList, v)
			end
			local oldHeight = self:getContainer():getContentSize().height
			self:updateUI(self.m_activityList)
			local delta = self:getContainer():getContentSize().height - oldHeight
			self:setContentOffset(cc.p(0, -delta))
		end)
end

function WarTableView:onBack(tag,sender)
	ManagerSound.playNormalButtonSound()
	CrossBO.fightReport(sender.key,sender.detail)
end

function WarTableView:updateUI(data,index)
	self.m_activityList = data or {}
	self.index = index
	self:reloadData()
end

-------------------------------------------------

local War = class("War",function ()
	return display.newNode()
end)

function War:ctor(width,height,type)
	self:size(width,height)
	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-20)
	bg:addTo(self):pos(width/2,bg:height()/2)
	t = UiUtil.label(CommonText[807][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(65,bg:height()-24)
	t = UiUtil.label(CommonText[807][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 136)
	t = UiUtil.label(CommonText[807][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 168)
	t = UiUtil.label(CommonText[807][4],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 146)
	self.view = WarTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)
end

-------------------------
local ScoreTableView = class("WarTableView", TableView)
local COLOR_INDEX = {6,12,2}
function ScoreTableView:ctor(size,kind)
	ScoreTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.kind = kind
	self.m_cellSize = cc.size(size.width, 76)
end

function ScoreTableView:createCellAtIndex(cell, index)
	ScoreTableView.super.createCellAtIndex(self, cell, index)
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
	local c = cc.c3b(255,255,255)
	if index <= 3 then
		c = COLOR[COLOR_INDEX[index]]
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(43,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(43,self.m_cellSize.height/2)
	end
	t = UiUtil.label(data.name, 18, c)
		:addTo(cell):alignTo(t,136)
	t:y(t:y() + 18)
	UiUtil.label(data.serverName,18,cc.c3b(150, 150, 150))
		:addTo(cell):alignTo(t, -36, 1)
	t = UiUtil.label(data.winNum .."/" .. data.failNum, nil, cc.c3b(150, 150, 150))
		:addTo(cell):alignTo(t,168)
	t:y(t:y() - 18)
	t = UiUtil.label(data.jifen,nil,COLOR[12])
		:addTo(cell):alignTo(t,146)

	local tt = data.myGroup
	if tt > 0 then
		display.newSprite(IMAGE_COMMON.."group_"..tt ..".png"):addTo(cell,-1):pos(self.m_cellSize.width / 2,self.m_cellSize.height / 2)
	else
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
		line:setPreferredSize(cc.size(self.m_cellSize.width-10, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, 0)
	end
	return cell
end

function ScoreTableView:numberOfCells()
	if #self.m_activityList < RANK_PAGE_NUM or #self.m_activityList >= 100 then
		return #self.m_activityList
	else
		return #self.m_activityList + 1
	end
end

function ScoreTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ScoreTableView:onNextCallback(tag, sender)
	local page = math.ceil(#self.m_activityList / RANK_PAGE_NUM)
	CrossBO.getCrossScore(page,self.kind,function(list)
			for k,v in ipairs(list) do
				table.insert(self.m_activityList, v)
			end
			local oldHeight = self:getContainer():getContentSize().height
			self:updateUI(self.m_activityList,score,rank)
			local delta = self:getContainer():getContentSize().height - oldHeight
			self:setContentOffset(cc.p(0, -delta))
		end)
end

function ScoreTableView:updateUI(data,score,rank)
	self.m_activityList = data or {}
	self:reloadData()
	if rank and rank > 0 then
		self.myRank:setString(rank)
	end
	if score then
		self.myScore:setString(score)
	end
end

----------------------------------

local Score = class("Score",function ()
	return display.newNode()
end)

function Score:ctor(width,height,type)
	self:size(width,height)
	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-40)
	bg:addTo(self):pos(width/2,bg:height()/2+20)
	t = UiUtil.label(CommonText[770][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(65,bg:height()-24)
	t = UiUtil.label(CommonText[770][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 136)
	t = UiUtil.label(CommonText[20084],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 168)
	t = UiUtil.label(CommonText[770][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 146)
	self.view = ScoreTableView.new(cc.size(570, bg:height()-55),type)
		:addTo(bg):pos(25,10)
	
	t = UiUtil.label(CommonText[10067][4]):addTo(bg):align(display.LEFT_CENTER,440,bg:height()+58)
	self.view.myRank = UiUtil.label(CommonText[768],nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[764][1]):alignTo(t, -23, 1)
	self.view.myScore = UiUtil.label("0",nil,COLOR[2]):rightTo(t)
	
	UiUtil.label(CommonText[30056],20):addTo(self):align(display.LEFT_CENTER, 30, 5)
end

--------------------------------------------------------------------
local CrossScore = class("CrossScore",function ()
	return display.newNode()
end)
local PAGE = {Info,War,Score}
function CrossScore:ctor(width,height,type)
	self:size(width,height)
	self.type = type
	local t = display.newSprite(IMAGE_COMMON.."bar_general.jpg")
		:addTo(self):align(display.CENTER_TOP, width/2, height-5)
	--tab按钮
    self.btn1 = UiUtil.button("btn_13_normal.png", "btn_13_selected.png", nil, handler(self,self.showIndex),CommonText[30015][self.type])
   		:addTo(t,0,1):pos(86,30)
  	self.btn1:unselected()
  	self.btn2 = UiUtil.button("btn_41_selected.png", "btn_41_normal.png", nil, handler(self,self.showIndex),CommonText[806][3])
		:addTo(t,0,2):pos(204,30)
	self.btn2:unselected()
	self.btn3 = UiUtil.button("btn_13_normal.png", "btn_13_selected.png", nil, handler(self,self.showIndex),CommonText[20028])
		:addTo(t,0,3):pos(322,30)
	self.btn3:setScaleX(-1)
	self.btn3.m_label:setScaleX(-1)
	self.btn3:unselected() 
	self:showIndex(1)
end

function CrossScore:showIndex(tag,sender)
	for i=1,3 do
		if i == tag then
			self["btn"..i]:selected()
			self:updateUI(i)
		else
			self["btn"..i]:unselected()
		end
	end
end

function CrossScore:updateUI(index)
	if self.content then
		self.content:removeSelf()
		self.content = nil
	end
	if index == 1 then
		CrossBO.getEnterInfo(function()
				self.content = PAGE[index].new(self:width(),self:height()-208,self.type)
					:addTo(self)
			end)
	elseif index == 2 then
		if CrossBO.myGroup_ ~= self.type then
			return
		end
		CrossBO.getCrossPerson(0,function(list)
				self.content = PAGE[index].new(self:width(),self:height()-208,self.type)
					:addTo(self)
				self.content.view:updateUI(list)
			end)
	elseif index == 3 then
		CrossBO.getCrossScore(0,self.type,function(list,score,rank)
				self.content = PAGE[index].new(self:width(),self:height()-208,self.type)
					:addTo(self)
				self.content.view:updateUI(list,score,rank)
			end)
	end
end

function CrossScore:showDetail()

end

return CrossScore