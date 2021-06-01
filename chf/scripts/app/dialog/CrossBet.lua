--
-- Author: Xiaohang
-- Date: 2016-05-20 15:24:24
--
local Dialog = require("app.dialog.Dialog")
local CrossBet = class("CrossBet", Dialog)

-- kind,stage,groupType,groupId,pos
function CrossBet:ctor(data,kind,stage,groupType,groupId)
	CrossBet.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.data = data
	self.kind = kind
	self.stage = stage
	self.groupType = groupType
	self.groupId = groupId
end

function CrossBet:onEnter()
	CrossBet.super.onEnter(self)
	self:setTitle(CommonText[30031])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local state,endTime = CrossMO.getBetState()
	if not state then
		self:pop()
		Toast.show(CommonText[30032])
		return
	end
	self.list = {}
	self.index = 1
	local node = self:getBg()

	local t = UiUtil.label(CommonText[30035]):addTo(node):align(display.LEFT_CENTER,42,236)
	self.total = UiUtil.label("0",nil,COLOR[2]):addTo(node):rightTo(t)
	t = UiUtil.label(CommonText[30038]):addTo(node):alignTo(t, -32,1)
	local timeLabel = UiUtil.label("00:00",nil,COLOR[2]):addTo(node):rightTo(t)
	local function tick()
		local left = endTime - ManagerTimer.getTime()
		local str = string.format("%02dh:%02dm:%02ds",math.floor(left/3600),math.floor(left / 60) % 60,left%60)
		if left <= 0 then
			timeLabel:stopAllActions()
			timeLabel:setString("00h:00m:00s")
		else
			timeLabel:setString(str)
		end
	end
	tick()
	timeLabel:performWithDelay(tick, 1, 1)

	self.betBtn = UiUtil.button("btn_10_normal.png", "btn_10_selected.png", "btn_1_disabled.png", handler(self, self.bet), CommonText[30033])
		:addTo(node):pos(node:width()/2,25)

	t = self:showInfo(1):addTo(node):pos(150,510)
	self.panel1 = t
	self.panel2 = self:showInfo(2):addTo(node):pos(node:width()-t:x(),t:y())
	UiUtil.label(state,nil,COLOR[12]):addTo(node):pos(node:width()/2,t:y()+116)
	display.newSprite(IMAGE_COMMON.."label_vs_1.png"):addTo(node,10):pos(node:width()/2,t:y()+64)

	t = UiUtil.label(CommonText[53]..":",nil,COLOR[2]):addTo(node):align(display.LEFT_CENTER, 42, 140)
	UiUtil.label(CommonText[20197]):alignTo(t,-22,1)
end

function CrossBet:getTotal(data)
	local num = data.myBetNum
	local ds = CrossMO.getBetById(data.myBetNum)
	if ds then
		self.total:setString(ds.betamount)
	else
		self.total:setString(0)
	end
	ds = CrossMO.getBetById(num + 1)
	if ds then
		self:setCost(ds.cost)
	else
		self:setCost()
	end
end

function CrossBet:setCost(cost)
	self.betBtn.m_label:removeAllChildren()
	self.betBtn.m_label:center()
	if not cost then
		self.betBtn:setEnabled(false)
		self.betBtn.m_label:setString(CommonText[30033])
	else
		self.betBtn:setEnabled(true)
		if cost == 0 then
			self.betBtn.m_label:setString(CommonText[729])
		else
			self.betBtn.m_label:setString(CommonText[30033])
			UiUtil.label("*"..cost):addTo(self.betBtn.m_label):align(display.LEFT_CENTER,self.betBtn.m_label:width(),self.betBtn.m_label:height()/2)
			self.betBtn.m_label:x(self.betBtn.m_label:x() - 15)
		end
	end
	self.betBtn.cost = cost
end

function CrossBet:bet()
	local function ask()
		CrossBO.betBattle(function(info)
				self.list[self.index].data.myBetNum = self.list[self.index].data.myBetNum + 1
				self:getTotal(self.list[self.index].data)
				local px,py = self["panel"..self.index]:x(),self["panel"..self.index]:y()
				self.data["c"..self.index] = info["c"..self.index]
				self["panel"..self.index]:removeSelf()
				self["panel"..self.index] = self:showInfo(self.index):addTo(self:getBg()):pos(px,py)
			end,self.kind,self.stage,self.groupType,self.groupId,self.index)
	end
	if self.betBtn.cost then
		if self.betBtn.cost == 0 then
			ask()
			return
		end
		if UserMO.consumeConfirm then
			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(string.format(CommonText[30037], self.betBtn.cost), function()
					ask()
				end):push()
		else
			ask()
		end
	end
end

function CrossBet:showInfo(index)
	local info = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, 224, 455)
	local data = self.data["c"..index]
	if not data then
		UiUtil.label(CommonText[20052]):addTo(info):center()
		return info
	end
	data = PbProtocol.decodeRecord(data)
	local t = UiUtil.label(data.nick,nil,COLOR[2]):addTo(info):pos(info:width()/2,info:height()-25)
	UiUtil.label(data.serverName):addTo(info):alignTo(t, -32, 1)
	UiUtil.createItemView(ITEM_KIND_PORTRAIT, data.portrait):addTo(info):pos(info:width()/2,info:height()-154):scale(0.8)
	local checkBox = CheckBox.new(nil, nil, handler(self, self.choose)):addTo(info,0,index)
		:pos(info:width()/2,162)
	checkBox.data = data
	if index == self.index then
		checkBox:setChecked(true)
		self:getTotal(data)
	end
	self.list[index] = checkBox
	t = UiUtil.label(CommonText[30036]):addTo(info):alignTo(checkBox, -90, 1)
	t = UiUtil.label(data.bet,nil,COLOR[2]):addTo(info):alignTo(t, -28, 1)
	return info
end

function CrossBet:choose(sender,isChecked)
	local tag = sender:getTag()
	if tag == self.index and isChecked == false then
		sender:setChecked(true)
		return
	end
	self.index = tag
	tag = tag%2 + 1
	self.list[tag]:setChecked(false)
	self:getTotal(sender.data)
end

-- function CrossBet:createItem(index)
-- 	local t = UiUtil.sprite9("info_bg_11.png",130,40,1,1,494,142)
-- 	local l = display.newSprite(IMAGE_COMMON .. "info_bg_28.png")
-- 		:addTo(t):pos(t:width()/2,t:height()-10)
-- 	UiUtil.label("第"..index.."场"):addTo(l):center()
-- 	if index == 3 then
-- 		UiUtil.label("03h18m",nil,COLOR[2]):addTo(t):center()
-- 	else
-- 		local s = UiUtil.button("back_normal.png", "back_selected.png", nil, function()end)
-- 			:addTo(t):center()
-- 		display.newSprite(IMAGE_COMMON.."win.png"):addTo(t):alignTo(s,-162)
-- 		display.newSprite(IMAGE_COMMON.."fail.png"):addTo(t):alignTo(s,162)
-- 	end
-- 	return t
-- end

return CrossBet
