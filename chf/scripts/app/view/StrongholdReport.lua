--
-- Author: Xiaohang
-- Date: 2016-08-09 16:16:28
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
	if index == #self.list + 1 then -- 最后一个按钮
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_normal.png")
		normal:setPreferredSize(cc.size(500, 76))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_selected.png")
		selected:setPreferredSize(cc.size(500, 76))
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onNextCallback))
		btn:setLabel(CommonText[577])
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		return cell
	end
	local data = self.list[index]
	local t = UiUtil.label(os.date("%H:%M", data.time),nil,cc.c3b(150,150,150)):addTo(cell):pos(52,self.m_cellSize.height/2)
	local n = UiUtil.label(data.attacker,nil,COLOR[data.attackCamp and 6 or 3]):addTo(cell):alignTo(t, 138)
	n:y(n:y()+20)
	display.newSprite(IMAGE_COMMON..(data.attackCamp and "icon_capture_person.png" or "icon_capture_party.png")):leftTo(n):scale(0.8)
	n = UiUtil.label(CommonText[95]..":"..data.attackNum .."%"):addTo(cell):alignTo(t, 120)
	n:y(n:y()-20)
	local vs = UiUtil.label("VS",32,COLOR[12]):addTo(cell):alignTo(t, 223)
	n = UiUtil.label(data.defender,nil,COLOR[data.defendCamp and 6 or 3]):addTo(cell):alignTo(t, 308)
	n:y(n:y()+20)
	display.newSprite(IMAGE_COMMON..(data.defendCamp and "icon_capture_person.png" or "icon_capture_party.png")):leftTo(n):scale(0.8)
	n = UiUtil.label(CommonText[95]..":"..data.defendNum .."%"):addTo(cell):alignTo(t, 308)
	n:y(n:y()-20)
	local l,c = CommonText[20026][1],COLOR[12]
	if not data.result then
		l,c = CommonText[20026][2],COLOR[6]
	end
	t = UiUtil.label(l,nil,c):addTo(cell):alignTo(t, 393)
	t = UiUtil.button("btn_replay_normal.png", "btn_replay_selected.png", nil, handler(self, self.onBack), nil, 1)
	cell:addButton(t,510,self.m_cellSize.height/2)
	t.key = data.reportKey
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(560, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
	return cell
end

function ContentTableView:onNextCallback(tag, sender)
	local page = math.ceil(#self.list / RANK_PAGE_NUM)
	ExerciseBO.report(self:getParent().tag,self.kind,page,function(info,list)
			if info then
				local oldHeight = self:getContainer():getContentSize().height
				table.sort(list,function(a,b)
						return a.time < b.time
					end)
				if #list == 0 then return end
				for k,v in ipairs(list) do
					table.insert(self.list,v)
				end
				self:updateUI(self.list)
				local delta = self:getContainer():getContentSize().height - oldHeight
				self:setContentOffset(cc.p(0, -delta))
			end
		end)
end

function ContentTableView:numberOfCells()
	if self:getParent().tag == 1 then
		return #self.list
	end
	if #self.list < RANK_PAGE_NUM or #self.list >= 1000 then
		return #self.list
	else
		return #self.list + 1
	end
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
local StrongholdReport = class("StrongholdReport",function ()
	return display.newNode()
end)

function StrongholdReport:ctor(width,height,kind)
	self:size(width,height)
	self.kind = kind
	local t = UiUtil.label(CommonText[20082][1]):addTo(self):align(display.LEFT_CENTER,40,height-25)
	self.redNum = UiUtil.label("0/0",nil,COLOR[6]):rightTo(t)
	t = UiUtil.label(CommonText[20082][2]):alignTo(t,-26,1)
	self.blueNum = UiUtil.label("0/0",nil,COLOR[3]):rightTo(t)
	t = UiUtil.label(CommonText[20082][3]):alignTo(t,-26,1)
	self.winNum = UiUtil.label(CommonText[20052],nil,COLOR[2]):rightTo(t)

	--tab按钮
    self.perBtn = UiUtil.button("btn_12_normal.png", "btn_12_selected.png", nil, handler(self,self.showIndex),CommonText[806][3])
   		:addTo(self,0,1):pos(100,height-112)
  	self.perBtn:selected()
  	
  	self.allBtn = UiUtil.button("btn_12_normal.png", "btn_12_selected.png", nil, handler(self,self.showIndex),CommonText[806][1])
  	 	:addTo(self,0,2):alignTo(self.perBtn, 140)
  	self.allBtn:setScaleX(-1)
  	self.allBtn.m_label:setScaleX(-1)
  	self.allBtn:unselected()

  	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-160)
  	bg:addTo(self):pos(width/2,bg:height()/2+28)
  	self.bg = bg
  	local t = UiUtil.label(CommonText[619][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
  	t = UiUtil.label(CommonText[807][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 138)
  	t = UiUtil.label(CommonText[807][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 170)
  	t = UiUtil.label(CommonText[807][4],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 122)
	--内容
	local view = ContentTableView.new(cc.size(560, bg:height()-55),kind)
		:addTo(bg):pos(30,10)
	self.view = view

	self:showIndex(1)
end

function StrongholdReport:showIndex(tag,sender)
	if tag == 1 then
		self.perBtn:selected()
		self.allBtn:unselected()
	else
		self.perBtn:unselected()
		self.allBtn:selected()
	end
	self.bg.tag = tag
	ExerciseBO.report(tag,self.kind,0,function(info,list)
			if info then
				self.redNum:setString(info.redRest .."/" ..info.redTotal)
				self.blueNum:setString(info.blueRest .."/" ..info.blueTotal)
				if table.isexist(info, "redWin") then
					self.winNum:setString(CommonText[20066][info.redWin and 2 or 1])
					self.winNum:setColor(COLOR[info.redWin and 6 or 3])
				end
				table.sort(list,function(a,b)
						return a.time < b.time
					end)
				self.view:updateUI(list)
			end
		end)
end

return StrongholdReport