--
-- Author: Xiaohang
-- Date: 2016-05-06 13:52:59
--

require("app.text.DetailText")

----------------职位列表----------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 76)
	local data = FortressMO.getJobs()
	--要塞战预热到结束，不显示任命信息
	-- if FortressMO.inWar() and not FortressBO.hasOver_ then
	-- 	data = {}
	-- end
	self.m_activityList = {}
	for k,v in pairs(data) do
		table.insert(self.m_activityList,v)
	end
	table.sort(self.m_activityList,function(a,b)
			return a.id < b.id
		end)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local dJob = self.m_activityList[index]
	local data = FortressBO.jobList_[dJob.id]
	local t = UiUtil.label(dJob.name, nil, cc.c3b(200,200,200))
		-- :addTo(cell):pos(52,self.m_cellSize.height/2)
	t = CellTouchButton.new(t, nil, nil, nil, handler(self, self.detailInfo))
	t:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0.5, 1.2),
				 cc.ScaleTo:create(0.5, 1)})))
	t.data = dJob
	cell:addButton(t,52,self.m_cellSize.height/2)
	local left = dJob.appointNum - (data and #data or 0)
	t = UiUtil.label(left, nil, left == 0 and COLOR[6] or COLOR[12])
			:addTo(cell):alignTo(t, 210)
	local btn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self,self.appoint), CommonText[20050], 1)
	cell:addButton(btn,t:x()+205,t:y())
	btn.data = dJob
	--判断是否有军团并且自己是军团长
	if not PartyBO.getMyParty() or (PartyMO.myJob < PARTY_JOB_OFFICAIL)
		or left == 0 then
		btn:setEnabled(false)
	end
	return cell
end

function ContentTableView:detailInfo(tag,sender)
	require("app.dialog.AppointDetail").new(sender.data.id,function()
		end):push()
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:appoint(tag,sender)
	require("app.dialog.IndicatorUseDialog").new(-sender.data.id,function()
		UiDirector.pop()
		self:reloadData()
	end):push()
end
--------------------------------------飞艇任命----------
local AirShipContentTableView = class("AirShipContentTableView", TableView)
function AirShipContentTableView:ctor(size)
	AirShipContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 76)
	self.airshipList = {}
end

function AirShipContentTableView:reload(data)
	for index=1, #data do
		local out = {}
		local kvlong = data[index]
		out.shipid = kvlong.key
		out.commanderid = kvlong.value
		self.airshipList[#self.airshipList + 1] = out
	end
	self:reloadData()
end

function AirShipContentTableView:createCellAtIndex(cell, index)
	AirShipContentTableView.super.createCellAtIndex(self, cell, index)

	local data = self.airshipList[index]

	-- 飞艇
	local ship = AirshipMO.queryShipById(data.shipid)
	local t = UiUtil.label(ship.name, nil, cc.c3b(200,200,200))
		:addTo(cell):pos(52,self.m_cellSize.height/2)

	---坐标
	local lPos = WorldMO.decodePosition(ship.pos)
	local t = UiUtil.label(string.format("[%d,%d]", lPos.x, lPos.y), nil, cc.c3b(200,200,200))
	:addTo(cell):pos(182,self.m_cellSize.height/2)

	--指挥官
	local commander = ""
	for k,v in pairs(PartyMO.partyData_.partyMember) do
		if v.lordId == data.commanderid then
			commander = v.nick
			break
		end
	end
	t = UiUtil.label(commander, nil,COLOR[1] ):addTo(cell):pos(self.m_cellSize.width / 2+55, self.m_cellSize.height/2)

	-- 任命
	local btn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self,self.appoint), CommonText[20050], 1)
	cell:addButton(btn,t:x()+150,t:y())
	btn:setEnabled(false)
	btn.index = index

	-- 是否是自己的飞艇 or 军团长 or 副军团长
	if UserMO.lordId_ == data.commanderid or PartyMO.myJob == PARTY_JOB_MASTER or PartyMO.myJob == PARTY_JOB_OFFICAIL then
		btn:setEnabled(true)
	end

	return cell
end

function AirShipContentTableView:numberOfCells()
	return #self.airshipList
end

function AirShipContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function AirShipContentTableView:appoint(tag,sender)
	require("app.dialog.AirshipAppointDialog").new(sender.index,self.airshipList,function(shipid,newlordId)
		for index = 1, #self.airshipList do
			local data = self.airshipList[index]
			if data.shipid == shipid then
				data.commanderid = newlordId
			end
		end
		UiDirector.pop()
		self:reloadData()
	end):push()
end

-----------------------------------总览界面-----------
local PartyAppoint = class("PartyAppoint",function ()
	return display.newNode()
end)

function PartyAppoint:ctor(width,height)
	self:size(width,height)
	local t = display.newSprite(IMAGE_COMMON.."bar_general.jpg")
		:addTo(self,2):align(display.CENTER_TOP, width/2, height-5)
	UiUtil.label(CommonText[20036])
		:addTo(t):align(display.LEFT_CENTER, 32, 34)
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil,handler(self,self.showDetail))
		:addTo(t):pos(t:width()-62,37)

	if not UserMO.queryFuncOpen(UFP_AIRSHIP) then
		local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-t:height()-15)
		bg:addTo(self):pos(width/2,bg:height()/2)
		t = UiUtil.label(CommonText[20037][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
		t = UiUtil.label(CommonText[275],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 208)
		UiUtil.label(CommonText[20038],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 208)
		local view = ContentTableView.new(cc.size(540, bg:height()-55))
			:addTo(bg):pos(30,10)
		FortressBO.getJob(function()
				Loading.getInstance():show()
				local function getResult(name,data)
					Loading.getInstance():unshow()
					--有胜利军团才显示任命界面
					if not data.partyName or data.partyName == "" then
						view.m_activityList = {}
					end
					view:reloadData()
				end
				SocketWrapper.wrapSend(getResult, NetRequest.new("GetFortressWinParty"))
			end)
		return
	end

	local bg0 = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(self):align(display.CENTER_TOP,width/2,height - t:height() - 15)
	
	-- 要塞官职
	local btn1 = UiUtil.button("btn_55_normal.png", "btn_55_selected.png", "btn_55_selected.png",handler(self,self.showAction)):addTo(bg0):align(display.RIGHT_CENTER,bg0:width()/2 - 3 ,bg0:height()/2 + 1)
	btn1:setLabel(CommonText[1010][1])
	btn1.index = 0
	self.btn1 = btn1
	
	-- 飞艇指挥官
	local normal = display.newSprite(IMAGE_COMMON.."btn_55_normal.png") normal:setFlipX(true)
	local selected = display.newSprite(IMAGE_COMMON.."btn_55_selected.png") selected:setFlipX(true)
	local disabled = display.newSprite(IMAGE_COMMON.."btn_55_selected.png")	disabled:setFlipX(true)
	local btn2 = MenuButton.new(normal,selected,disabled,handler(self,self.showAction)):addTo(bg0):align(display.LEFT_CENTER,bg0:width()/2 + 3 ,bg0:height()/2 + 1)
	btn2:setLabel(CommonText[1010][2])
	btn2.index = 1
	self.btn2 = btn2

	self.bgtop = t
	self.bgcenter = bg0

	self:showAction(nil,{index = 0})
end

function PartyAppoint:showAction(tag, sender)
	local index = sender.index
	local ischeck = (index + 1) % 2 
	self.btn1:setEnabled(ischeck == 0)
	self.btn2:setEnabled(ischeck == 1)
	self:AppointContent(ischeck)
end

function PartyAppoint:AppointContent(index)
	if self.content then
		self.content:removeSelf()
		self.content = nil
	end

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, self:width()-20, self:height()-self.bgtop:height()-self.bgcenter:height()-14)
	bg:addTo(self):pos(self:width()/2,bg:height()/2)
	self.content = bg

	if index == 1 then
		--要塞
		local t = UiUtil.label(CommonText[20037][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
		t = UiUtil.label(CommonText[275],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 208)
		UiUtil.label(CommonText[20038],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 208)

		local view = ContentTableView.new(cc.size(540, bg:height()-55))
			:addTo(bg):pos(30,10)
		FortressBO.getJob(function()
				Loading.getInstance():show()
				local function getResult(name,data)
					Loading.getInstance():unshow()
					--有胜利军团才显示任命界面
					if not data.partyName or data.partyName == "" then
						view.m_activityList = {}
					end
					view:reloadData()
				end
				SocketWrapper.wrapSend(getResult, NetRequest.new("GetFortressWinParty"))
			end)
	else
		-- 飞艇
		-- AirShipContentTableView
		local t = UiUtil.label(CommonText[20037][2],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
		t = UiUtil.label(CommonText[305],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 120)
		t = UiUtil.label(CommonText[51],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 148)	
		UiUtil.label(CommonText[20038],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 148)

		local view = AirShipContentTableView.new(cc.size(540, bg:height()-55))
			:addTo(bg):pos(30,10)
		-- 获取飞艇消息
		Loading.getInstance():show()
		AirshipBO.GetPartyAirshipCommander(function(data)
			if not table.isexist(PartyMO.partyData_,"partyMember") then
				PartyBO.asynGetPartyMember(function()
					Loading.getInstance():unshow()
					view:reload(data)
				end,1)
			else
				Loading.getInstance():unshow()
				view:reload(data)
			end
		end)
	end
end

function PartyAppoint:showDetail()
	local txt = clone(DetailText.fortressJob)
	if UserMO.queryFuncOpen(UFP_AIRSHIP) then
		for i,v in ipairs(DetailText.fortressJobAdd) do
			table.insert(txt, v)
		end
	end
	require("app.dialog.DetailTextDialog").new(txt):push()
end

return PartyAppoint