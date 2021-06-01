--
-- Author: xiaoxing
-- Date: 2016-11-24 09:46:05
--
----------------军团战记录----------
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
	local t = UiUtil.label(os.date("%H:%M", data.time),nil,cc.c3b(150,150,150)):addTo(cell):pos(51,self.m_cellSize.height/2)
	if data.rank and data.rank > 0 then
		t = ArenaBO.createRank(data.rank):alignTo(t, 450)
		local text = nil
		if data.rank == 1 then
			text = {{content=data.serverName1..CommonText[105]},{content=data.partyName1,color=COLOR[5]},
				{content=CommonText[810][2]}}
		else
			text = {{content=data.serverName1..CommonText[105]},{content=data.partyName1,color=COLOR[5]},
				{content=CommonText[811][1]..data.serverName2},{content=data.name2,color=COLOR[2]},{content="("..data.partyName2..")",color=COLOR[5]},
				{content=string.format(CommonText[811][2],data.rank)}}
		end
		local t = RichLabel.new(text, cc.size(335, 0)):addTo(cell)
		t:pos(90, self.m_cellSize.height/2 + t:getHeight()/2)
	else
		local n = UiUtil.label(data.name1,nil,COLOR[2]):addTo(cell):alignTo(t, 120)
		n:y(n:y()-20)
		n = UiUtil.label(data.partyName1):addTo(cell):alignTo(t, 120)
		n:y(n:y()+20)
		local vs = UiUtil.label("VS",32,COLOR[12]):addTo(cell):alignTo(t, 215)
		n = UiUtil.label(data.name2,nil,COLOR[2]):addTo(cell):alignTo(t, 310)
		n:y(n:y()-20)
		n = UiUtil.label(data.partyName2):addTo(cell):alignTo(t, 310)
		n:y(n:y()+20)
		local l,c = CommonText[809][1],COLOR[6]
		if data.result > 0 then
			l,c = string.format(CommonText[809][2], data.result),COLOR[12]
		end
		t = UiUtil.label(l,nil,c):addTo(cell):alignTo(t, 450)
	end
	if self.index == 3 and not (data.rank and data.rank > 0) then
		t:setAnchorPoint(cc.p(1,0.5))
		local btn = UiUtil.button("btn_replay_normal.png", "btn_replay_selected.png", nil, handler(self, self.onBack), nil, 1)
		btn.reportKey = data.reportKey
		btn:scale(0.8)
		cell:addButton(btn,t:x()+30,t:y())
	end
	if self.index == 1 then
		local server = string.gsub(LoginMO.getServerById(GameConfig.areaId).name," ","")
		local maskPic = nil
		if data.isMy == true then
			maskPic = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_partyB2.png")
		elseif data.group == 5 then
			maskPic = display.newScale9Sprite(IMAGE_COMMON .. "group_2.png")
		else
			maskPic = display.newScale9Sprite(IMAGE_COMMON .. "group_1.png")
		end
		cell:addChild(maskPic,0)
		maskPic:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height))
		maskPic:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	else
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
		line:setPreferredSize(cc.size(self.m_cellSize.width-10, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, 0)
	end
	return cell
end

function ContentTableView:numberOfCells()
	if #self.m_activityList < RANK_PAGE_NUM or #self.m_activityList >= 5000 then
		return #self.m_activityList
	else
		return #self.m_activityList + 1
	end
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:onBack(tag,sender)
	CrossPartyBO.fightReport(sender.reportKey)
end

function ContentTableView:onNextCallback(tag, sender)
	local page = math.ceil(#self.m_activityList / RANK_PAGE_NUM)
	CrossPartyBO.getMyCrossInfo(self.index,page,function(list)
			for k,v in ipairs(list) do
				if v.rank and v.rank > 0 and self.index == 3 then
				else
					table.insert(self.m_activityList, v)
				end
			end
			local oldHeight = self:getContainer():getContentSize().height
			self:updateUI(self.m_activityList,self.index)
			local delta = self:getContainer():getContentSize().height - oldHeight
			self:setContentOffset(cc.p(0, -delta))
		end)
end

function ContentTableView:updateUI(data,index)
	self.m_activityList = data or {}
	self.index = index
	self:reloadData()
end

--------------------------------------------------------------------
local CrossPartyMy = class("CrossPartyMy",function ()
	return display.newNode()
end)
function CrossPartyMy:ctor(width,height)
	self:size(width,height)
	self.type = type
	local t = display.newSprite(IMAGE_COMMON.."cross_party1.jpg")
		:addTo(self):align(display.CENTER_TOP, width/2, height-5)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(self):pos(width/2,height-235)

	local frame = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-40, height - 270)
	frame:addTo(self,3):pos(width/2,frame:height()/2)
	local t = UiUtil.label(CommonText[807][1],nil,cc.c3b(150,150,150)):addTo(frame):pos(68,frame:height()-24)
	t = UiUtil.label(CommonText[807][2],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 120)
	t = UiUtil.label(CommonText[807][3],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 190)
	t = UiUtil.label(CommonText[807][4],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 140)

	self.view = ContentTableView.new(cc.size(560, frame:height()-55))
		:addTo(frame):pos(15,10)

	--tab按钮
    self.btn1 = UiUtil.button("btn_53_normal.png", "btn_53_selected.png", nil, handler(self,self.showIndex),CommonText[30061][2])
   		:addTo(bg,0,1):pos(135,bg:height()/2+2)
  	self.btn2 = UiUtil.button("btn_54_normal.png", "btn_54_selected.png", nil, handler(self,self.showIndex),CommonText[806][2])
  	 	:addTo(bg,0,2):alignTo(self.btn1, 184)
 	self.btn3 = UiUtil.button("btn_53_normal.png", "btn_53_selected.png", nil, handler(self,self.showIndex),CommonText[806][3])
 		:addTo(bg,0,3):alignTo(self.btn2, 184)
  	self.btn3:setScaleX(-1)
  	self.btn3.m_label:setScaleX(-1)

  	self:showIndex(1)
end

function CrossPartyMy:showIndex(tag,sender)
	for i=1,3 do
		if i == tag then
			self["btn"..i]:selected()
			CrossPartyBO.getMyCrossInfo(tag,0,function(data)
				self.view:updateUI(data,tag)
			end)
		else
			self["btn"..i]:unselected()
		end
	end
end

return CrossPartyMy