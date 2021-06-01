--
-- Author: Xiaohang
-- Date: 2016-05-19 10:01:25
-- 淘汰赛

-----------------赛事信息tableView--------------------
local ContentTableView = class("ContentTableView", TableView)
local LINE_W = 62
function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_cellSize = cc.size(1100, size.height)
	self.m_activityList = {1}
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	--生成赛事信息
	local size = self.m_cellSize
	local node = self:itemNode(size)
	node:addTo(cell):align(display.LEFT_TOP, 0, size.height)
	node = self:itemNode(self.m_cellSize,1)
	node:addTo(cell):align(display.LEFT_TOP, size.width, size.height)
	node:scaleX(-1)
	for k,v in ipairs(node.names) do
		v:scaleX(-1)
	end
	local ty = size.height - (node:height()-node.cy)
	--冠军
	local l = display.newSprite(IMAGE_COMMON.."line.jpg")
		:addTo(cell):align(display.CENTER_BOTTOM, size.width/2,ty):scaleTY(170)
	local t = display.newSprite(IMAGE_COMMON.."an.png")
		:addTo(cell):align(display.CENTER_BOTTOM, size.width/2, l:y()+l:height()*l:getScaleY())
	local data = self.data[15]
	local state = self:checkData(15)
	if state == 1 then
		local t = UiUtil.button("bet_normal.png", "bet_selected.png", nil, handler(self, self.Bet))
			:addTo(cell):pos(l:x(),l:y())
		t.group = 15
	elseif state == 2 then
		local btn = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.PlayBack))
			:addTo(cell,5):pos(l:x(),l:y())
		btn.name = CommonText[30023][4]
		btn.group = 15
		local index = 1
		if data.win == 0 then index = 2 end
		local info = PbProtocol.decodeRecord(data["c"..index])
		UiUtil.label(info.nick,20):addTo(t):pos(t:width()/2,36)
		UiUtil.label(info.serverName,20):addTo(t):pos(t:width()/2,16)
	end
	display.newSprite(IMAGE_COMMON.."dot.png")
		:addTo(cell):align(display.CENTER_BOTTOM, t:x() + t:y())
		:scaleY(-1)
	UiUtil.label(CommonText[30030],nil,COLOR[12]):addTo(cell):alignTo(t,65,1)
	local ls = CrossMO.getOutTime()
	local y,ey = ty-60,66
	for k,v in ipairs(ls) do
		local ty = y-(k-1)*ey
		local t = UiUtil.label(CommonText[30023][k], 22, COLOR[12]):addTo(cell):pos(size.width/2,ty)
		UiUtil.label(v, 22):addTo(cell):alignTo(t, -28, 1)
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:itemNode(size,isRight)
	local node = display.newNode():size(size.width/2,700)
	node.names = {}
	local x,y,ey = 98,node:height()-28,76
	local pos1 = {}
	--8个玩家信息
	for i=0,7 do
		local group = math.floor(i/2)+1
		if isRight then group = group + 4 end
		local index = i%2 + 1
		local ty = y - i*ey
		local t = UiUtil.button("an.png", "an.png", nil, handler(self, self.lookInfo))
			:addTo(node,0,i):pos(x,ty)
		local data = self.data[group]
		local info = nil
		if data then info = data["c"..index] end
		if info then info = PbProtocol.decodeRecord(info) end
		if info then
			t.info = info
			table.insert(node.names,UiUtil.label(info.nick,20):addTo(t):pos(t:width()/2,36))
			table.insert(node.names,UiUtil.label(info.serverName,20):addTo(t):pos(t:width()/2,16))
		end
		local l = display.newSprite(IMAGE_COMMON.."line.jpg")
			:addTo(node):align(display.CENTER_BOTTOM,t:x()+t:width()/2,t:y())
		l:rotation(90)
		l:scaleTY(LINE_W)
		self:checkFalse(index == 1,self.data[group],l)
		l = display.newSprite(IMAGE_COMMON.."dot.png")
			:addTo(node):align(display.CENTER_BOTTOM,t:x()+t:width()/2,t:y())
		l:rotation(90)
		l = display.newSprite(IMAGE_COMMON.."line.jpg"):scaleTY(ey/2)
			:addTo(node):align(display.RIGHT_BOTTOM, t:x()+t:width()/2+LINE_W, t:y())
		if i%2 == 0 then
			l:scaleY(-1*l:getScaleY())
			table.insert(pos1,cc.p(l:x(),l:y()-ey/2))
		end
		self:checkFalse(index == 1,self.data[group],l)
	end
	local pos2 = {}
	ey = 2*ey
	--8进4
	for k,v in ipairs(pos1) do
		local group = math.floor((k-1)/2)+1+8
		if isRight then group = group + 2 end
		local l = display.newSprite(IMAGE_COMMON.."line.jpg")
			:addTo(node):align(display.CENTER_BOTTOM,v.x,v.y):scaleTY(LINE_W)
		l:rotation(90)
		self:checkFalse(k%2 == 1,self.data[group],l)
		l = display.newSprite(IMAGE_COMMON.."line.jpg"):scaleTY(ey/2)
			:addTo(node):align(display.RIGHT_BOTTOM, v.x+LINE_W,v.y)
		if k%2 == 1 then
			l:scaleY(-1*l:getScaleY())
			table.insert(pos2,cc.p(l:x(),l:y()-ey/2))
		end
		local index = isRight and k + 4 or k
		self:checkFalse(k%2 == 1,self.data[group],l)
		local state = self:checkData(index)
		if state == 1 then
			local t = UiUtil.button("bet_normal.png", "bet_selected.png", nil, handler(self, self.Bet))
				:addTo(node):pos(v.x,v.y)
			t.group = index
		elseif state == 2 then
			local t = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.PlayBack))
				:addTo(node):pos(v.x,v.y)
			t.name = CommonText[30023][1]
			t.group = index
		end
	end
	ey = pos2[1].y - pos2[2].y
	node.cy = pos2[2].y + ey/2
	--半决赛，13,14组
	for k,v in ipairs(pos2) do
		local group = 13
		if isRight then group = 14 end
		local l = display.newSprite(IMAGE_COMMON.."line.jpg")
			:addTo(node):align(display.CENTER_BOTTOM,v.x,v.y):scaleTY(LINE_W)
		l:rotation(90)
		self:checkFalse(k%2 == 1,self.data[group],l)
		l = display.newSprite(IMAGE_COMMON.."line.jpg"):scaleTY(ey/2)
			:addTo(node):align(display.RIGHT_BOTTOM, v.x+LINE_W,v.y)
		self:checkFalse(k%2 == 1,self.data[group],l)
		if k%2 == 1 then
			l:scaleY(-1*l:getScaleY())
			l = display.newSprite(IMAGE_COMMON.."line.jpg")
					:addTo(node):align(display.CENTER_BOTTOM,l:x(),l:y()-ey/2)
					:scaleTY(node:width() - l:x())
			l:rotation(90)
			self:checkFalse(not isRight,self.data[15],l)
			if self.data[group] then
				local state = self:checkData(group)
				if state == 1 then
					local t = UiUtil.button("bet_normal.png", "bet_selected.png", nil, handler(self, self.Bet))
						:addTo(node,2):pos(l:x(),l:y())
					t.group = group
				elseif state == 2 then
					local t = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.PlayBack))
						:addTo(node,2):pos(l:x(),l:y())
					t.group = group
					t.name = CommonText[30023][3]
				end
			end
		end
		local state = self:checkData((group-13) + group - 5 + k)
		if state == 1 then
			local t = UiUtil.button("bet_normal.png", "bet_selected.png", nil, handler(self, self.Bet))
				:addTo(node):pos(v.x,v.y)
			t.group = (group-13) + group - 5 + k
		elseif state == 2 then
			local t = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.PlayBack))
				:addTo(node):pos(v.x,v.y)
			t.group = (group-13) + group - 5 + k
			t.name = CommonText[30023][2]
		end
	end
	return node
end

--检查失败线条
function ContentTableView:checkFalse(isUp,data,l)
	if not data then return end
	if data.win ~= -1 then
		if isUp and data.win == 0 then
			l:setOpacity(30)
			return true
		elseif not isUp and data.win == 1 then
			l:setOpacity(30)
			return true
		end
	end
end

--检查数据
function ContentTableView:checkData(group)
	if self.data[group] then
		if table.isexist(self.data[group],"c1") or table.isexist(self.data[group],"c2") then 
			if self.data[group].win == -1 then --未战斗
				return 1
			end 
			return 2
		end
	end
end

function ContentTableView:lookInfo(tag,sender)
	if sender.info then
		require("app.dialog.CrossPlayer").new(sender.info):push()
	end
end

function ContentTableView:PlayBack(tag,sender)
	require("app.dialog.CrossPlayback").new(self.data[sender.group],sender.name):push()
end

function ContentTableView:Bet(tag,sender)
	local data = self.data[sender.group]
	if not table.isexist(data,"c1") or not table.isexist(data,"c2") then
		Toast.show(CommonText[30045])
		return
	end
	require("app.dialog.CrossBet").new(data,self.kind,1,self.index,sender.group):push()
end

function ContentTableView:updateUI(data,kind,index)
	self.data = data
	self.kind = kind
	self.index = index
	self:reloadData()
end

-------------------------------------------------------
local CrossOut = class("CrossOut",function ()
	return display.newNode()
end)
function CrossOut:ctor(width,height,type)
	self:size(width,height)
	self.type = type
	local t = display.newSprite(IMAGE_COMMON .."info_bg_27.png")
		:addTo(self):align(display.CENTER_TOP, width/2, height)
	self.content = ContentTableView.new(cc.size(self:width()-10,self:height()-60))
		:addTo(self):pos(5,0)
	--tab按钮
    self.btn1 = UiUtil.button("btn_13_normal.png", "btn_13_selected.png", nil, handler(self,self.showIndex),"A"..CommonText[30028])
   		:addTo(t,0,1):pos(128,30)
  	self.btn2 = UiUtil.button("btn_12_normal.png", "btn_12_selected.png", nil, handler(self,self.showIndex),"B"..CommonText[30028])
		:addTo(t,0,2):alignTo(self.btn1, 120)
	self.btn3 = UiUtil.button("btn_12_normal.png", "btn_12_selected.png", nil, handler(self,self.showIndex),"C"..CommonText[30028])
		:addTo(t,0,3):alignTo(self.btn2, 145)
	self.btn3:setScaleX(-1)
	self.btn3.m_label:setScaleX(-1)
	self.btn4 = UiUtil.button("btn_13_normal.png", "btn_13_selected.png", nil, handler(self,self.showIndex),"D"..CommonText[30028])
		:addTo(t,0,4):alignTo(self.btn3, 120)
	self.btn4:setScaleX(-1)
	self.btn4.m_label:setScaleX(-1)
	self:showIndex(1)
end

function CrossOut:showIndex(tag,sender)
	if self.index and self.index == tag then return end
	self.index = tag
	for i=1,4 do
		if i == tag then
			self["btn"..i]:selected()
			self:updateUI(i)
		else
			self["btn"..i]:unselected()
		end
	end
end

function CrossOut:updateUI(index)
	CrossBO.getKnockInfo(self.type,index,function(data)
			self.content:updateUI(data,self.type,index)
		end)
end

return CrossOut