--
-- Author: Xiaohang
-- Date: 2016-10-11 09:45:29
--
--报名dialog
local Dialog = require("app.dialog.Dialog")
local ApplyDialog = class("ApplyDialog", Dialog)

-- tankId: 需要改装的tank
function ApplyDialog:ctor(rhand)
	ApplyDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(552, 164)})
	self.rhand = rhand
	self:size(552,164)
end

function ApplyDialog:onEnter()
	ApplyDialog.super.onEnter(self)
	self:setTitle(CommonText[30033])

	local t = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self, self.choose),CommonText[30012][1]):addTo(self:getBg(),0,1):pos(140,68)
	t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.choose),CommonText[30012][2]):addTo(self:getBg(),0,2):pos(self:getBg():width()-140,68)
end

function ApplyDialog:choose(tag,sender)
	self:pop()
	UiDirector.pop()
	require("app.view.CrossView").new(nil,2,tag):push()
end

-----------------------------------------------------------------

local ContentTableView = class("ContentTableView", TableView)
local rhand = rhand
function ContentTableView:ctor(size,tankId,data)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.tankId = tankId
	self.data = data
	self.m_cellSize = cc.size(size.width, 726)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	self:updateCell(cell, index)
	return cell
end

function ContentTableView:updateCell(cell,index)
	cell:removeAllChildren()
	local infoBg = UiUtil.sprite9("info_bg_15.png", 30, 30, 1, 1,self.m_cellSize.width - 20,self.m_cellSize.height-5)
		:addTo(cell):pos(self.m_cellSize.width/2,self.m_cellSize.height/2)
	local data = self.list[index]
	--时间
	local t = UiUtil.label(os.date("%m-%d %H:%M",data.betTime),nil,COLOR[2]):addTo(cell):pos(self.m_cellSize.width/2,self.m_cellSize.height-24)
	UiUtil.label(CommonText[30022][data.stage == 1 and 2 or 3]):alignTo(t, -26, 1)
	local p1 = PbProtocol.decodeRecord(data.c1)
	local p2 = PbProtocol.decodeRecord(data.c2)
	local r1 = UiUtil.createItemView(ITEM_KIND_PORTRAIT, p1.portrait):addTo(cell):pos(100,660):scale(0.6)
	t = UiUtil.label(p1.serverName,nil,COLOR[5]):addTo(cell):pos(r1:x(),585)
	UiUtil.label(p1.nick):alignTo(t, -26, 1)
	local r2 = UiUtil.createItemView(ITEM_KIND_PORTRAIT, p2.portrait):addTo(cell):pos(self.m_cellSize.width-r1:x(),660):scale(0.6)
	t = UiUtil.label(p2.serverName,nil,COLOR[5]):addTo(cell):pos(r2:x(),585)
	UiUtil.label(p2.nick):alignTo(t, -26, 1)
	local state = nil
	if data.win == 0 then
		state = 2
	elseif data.win == 1 then
		state = 1
	end
	if state then
		display.newSprite(IMAGE_COMMON.."win.png"):addTo(cell):pos(state == 1 and 100 or self.m_cellSize.width-100,620):scale(0.8)
	end
	--回合信息
	local x,y,ey = self.m_cellSize.width / 2,self.m_cellSize.height-260,145
	local rounds = PbProtocol.decodeArray(data.compteRound)
	for i=0,2 do
		local t = UiUtil.sprite9("info_bg_11.png",130,40,1,1,440,142):addTo(cell):pos(x,y-ey*i)
		local l = display.newSprite(IMAGE_COMMON .. "info_bg_28.png")
			:addTo(t):pos(t:width()/2,t:height()-10)
		local data = rounds[i+1]
		UiUtil.label(string.format(CommonText[30042],i+1)):addTo(l):center()
		if not data then
			UiUtil.label(state and CommonText[20026][3] or CommonText[30041],nil,COLOR[6]):addTo(t):center()
		else
			local s = nil
			if data.win == -1 then
				s = UiUtil.label(CommonText[30027][data.detail],20,COLOR[6]):addTo(t):center()
			else
				s = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.back),nil,1)
				cell:addButton(s,t:x(),t:y())
				s.key = data.reportKey
				s.detail = data.detail
			end
			local list = {"win.png","fail.png"}
			if data.win == 0 then
				list = {"fail.png","win.png"}
			elseif data.win == -1 then
				list = {"fail.png","fail.png"}
			end
			display.newSprite(IMAGE_COMMON.. list[1]):addTo(t):pos(t:width()/2 - 162,t:height()/2)
			display.newSprite(IMAGE_COMMON..list[2]):addTo(t):pos(t:width()/2 + 162,t:height()/2)
		end
	end
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width-50, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 100)
	--下注信息
	t = UiUtil.label(CommonText[30039]):addTo(cell):align(display.LEFT_CENTER,50,80)
	UiUtil.label(p1.myBetNum > 0 and p1.nick or p2.nick,nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[30035]):alignTo(t, -26, 1)
	local myBetPos = p1.myBetNum > 0 and 1 or 2
	UiUtil.label(self:getTotal(p1.myBetNum > 0 and p1 or p2),nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[30040]):alignTo(t, -26, 1)
	local num = self:getTotal(p1.myBetNum > 0 and p1 or p2,(state and state == myBetPos))
	if not state then num = 0 end
	UiUtil.label(num,nil,COLOR[2]):rightTo(t)
	--状态
	local btn = UiUtil.button("btn_11_normal.png","btn_11_selected.png",nil,handler(self, self.getScore),nil,1)
	btn.data = data
	btn.num = num
	btn.index = index
	cell:addButton(btn,397,51)
	self:checkState(btn)
end

function ContentTableView:checkState(btn)
	local data = btn.data
	if data.betState == 1 then
		btn:setLabel(CommonText[672][2])
	elseif data.betState == 2 then
		btn:setLabel(CommonText[672][1])
	elseif data.betState == 3 then
		btn:setLabel(CommonText[30041])
	end
end

function ContentTableView:getTotal(data,isWin)
	local ds = CrossMO.getBetById(data.myBetNum)
	if not ds then return 0 end
	local key = "betamount"
	if isWin ~= nil then
		key = isWin and "win" or "lose"
	end
	return ds[key]
end

function ContentTableView:numberOfCells()
	return #self.list
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:getScore(tag,sender)
	if sender.data.betState ~= 2 then
		return
	end
	local temp = self.list[sender.index]
	CrossBO.battleGet(temp,function(data)
			Toast.show(string.format(CommonText[30048],sender.num))
			sender.data.betState = 1
			self:checkState(sender)
		end)
end

function ContentTableView:back(tag,sender)
	CrossBO.fightReport(sender.key,sender.detail)
end

function ContentTableView:updateUI(data)
	self.list = data
	self:reloadData()
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local CrossBetInfo = class("CrossBetInfo", Dialog)

function CrossBetInfo:ctor(data)
	CrossBetInfo.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self.data = data
	self:size(582,834)
end

function CrossBetInfo:onEnter()
	CrossBetInfo.super.onEnter(self)
	self:setTitle(CommonText[30008])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = ContentTableView.new(cc.size(500, self:getBg():height()-190),self.tankId,self.data)
		:addTo(self:getBg()):pos(42,128)
	view:updateUI(self.data)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(btm:width(), line:getContentSize().height))
	line:setPosition(self:getBg():width() / 2, 140)

	UiUtil.button("btn_1_normal.png", "btn_1_selected.png", nil, handler(self, self.goto), "去下注")
		:addTo(btm):pos(btm:width()/2, 75)

	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.DetailTextDialog").new(DetailText.crossBet):push() 
		end):addTo(btm):pos(480,75)
end

function CrossBetInfo:onExit()
	CrossBetInfo.super.onExit(self)
end

function CrossBetInfo:goto()
	ApplyDialog.new(handler(self,self.pop)):push()
end

return CrossBetInfo
