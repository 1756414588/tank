--
-- Author: xiaoxing
-- Date: 2016-11-24 10:23:26
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
	if index == #self.m_activityList + 1 and not self.index then -- 最后一个按钮
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
		local t = RichLabel.new(text, cc.size(370, 0)):addTo(cell)
		t:pos(90, self.m_cellSize.height/2 + t:getHeight()/2)
	else
		local n = UiUtil.label(data.partyName1,nil,COLOR[5]):addTo(cell):alignTo(t, 120)
		UiUtil.label(data.name1.."("..data.hp1.."%)",nil,COLOR[2]):addTo(cell):alignTo(n,-23,1)
		UiUtil.label(data.serverName1):addTo(cell):alignTo(n,23,1)
		local vs = UiUtil.label("VS",32,COLOR[12]):addTo(cell):alignTo(t, 215)
		n = UiUtil.label(data.partyName2,nil,COLOR[5]):addTo(cell):alignTo(t, 310)
		UiUtil.label(data.name2.."("..data.hp2.."%)",nil,COLOR[2]):addTo(cell):alignTo(n,-23,1)
		UiUtil.label(data.serverName2):addTo(cell):alignTo(n,23,1)
		local l,c = CommonText[809][1],COLOR[6]
		if data.result > 0 then
			l,c = string.format(CommonText[809][2], data.result),COLOR[12]
		end
		t = UiUtil.label(l,nil,c):addTo(cell):alignTo(t, 450)
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width-10, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
	return cell
end

function ContentTableView:numberOfCells()
	if #self.m_activityList < RANK_PAGE_NUM or #self.m_activityList >= 5000 then
		return #self.m_activityList
	elseif not self.index then
		return #self.m_activityList + 1
	else
		return #self.m_activityList
	end
end

function ContentTableView:onNextCallback(tag, sender)
	local page = math.ceil(#self.m_activityList / RANK_PAGE_NUM)
	CrossPartyBO.getCrossInfo(5,page,function(list)
			for k,v in ipairs(list) do
				table.insert(self.m_activityList, v)
			end
			local oldHeight = self:getContainer():getContentSize().height
			self:updateUI(self.m_activityList)
			local delta = self:getContainer():getContentSize().height - oldHeight
			self:setContentOffset(cc.p(0, -delta))
		end)
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:onBack(tag,sender)
	FortressBO.fightReport(sender.key)
end

function ContentTableView:updateUI(data,index)
	self.m_activityList = data or {}
	self.index = index
	self:reloadData()
end

--------------------------------------------------------------------
local CrossPartyFinal = class("CrossPartyFinal",function ()
	return display.newNode()
end)
function CrossPartyFinal:ctor(width,height)
	self:setNodeEventEnabled(true)
	self:size(width,height)
	self.type = type
	local t = display.newSprite(IMAGE_COMMON.."cross_party2.jpg")
		:addTo(self):align(display.CENTER_TOP, width/2, height-5)

	local frame = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-40, height - 270)
	frame:addTo(self,3):pos(width/2,frame:height()/2+50)
	local t = UiUtil.label(CommonText[807][1],nil,cc.c3b(150,150,150)):addTo(frame):pos(68,frame:height()-24)
	t = UiUtil.label(CommonText[807][2],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 120)
	t = UiUtil.label(CommonText[807][3],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 190)
	t = UiUtil.label(CommonText[807][4],nil,cc.c3b(150,150,150)):addTo(frame):alignTo(t, 140)

	UiUtil.button("btn_19_normal.png", "btn_19_selected.png", nil, handler(self, self.showList), CommonText[30067])
		:addTo(self):pos(width/2,22)
	self.view = ContentTableView.new(cc.size(560, frame:height()-55))
		:addTo(frame):pos(30,10)

	self.situation = Notify.register(LOCAL_CROSSPARTY_SITUATION, handler(self, self.updateUI))
	self.data = {}
	CrossPartyBO.getCrossInfo(5,0,function(data)
		self.data = data or {}
		self.view:updateUI(self.data)
	end)
end

function CrossPartyFinal:updateUI(event)
	local group = event.obj.group
	local info = event.obj.info
	if 5 == group then
		table.insert(self.data, 1, info)
		self.view:updateUI(self.data,1)
	end
end

function CrossPartyFinal:showList(tag,sender)
	ManagerSound.playNormalButtonSound()
	CrossPartyBO.getPartyInfo(5,function(data)
		require("app.dialog.ListDialog").new(CommonText[30067],CommonText[801],data):push()
	end)
	-- local list = {
	-- 	{partyLv=1,partyName="军团名",memberNum=3,totalFight=50000,serverName="服务器"},
	-- 	{partyLv=1,partyName="军团名",memberNum=3,totalFight=50000,serverName="服务器"},
	-- 	{partyLv=1,partyName="军团名",memberNum=3,totalFight=50000,serverName="服务器"},
	-- 	{partyLv=1,partyName="军团名",memberNum=3,totalFight=50000,serverName="服务器"},
	-- }
	-- require("app.dialog.ListDialog").new(CommonText[30067],CommonText[801],list):push()
end

function CrossPartyFinal:onExit()
	if self.situation then
		Notify.unregister(self.situation)
		self.situation = nil
	end
end

return CrossPartyFinal