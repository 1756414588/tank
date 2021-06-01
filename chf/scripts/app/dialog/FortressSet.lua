--
-- Author: Xiaohang
-- Date: 2016-06-26 19:36:48
-- 设置部队

local ContentTableView = class("ContentTableView", TableView)
local rhand = rhand
function ContentTableView:ctor(size,tankId,data)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.tankId = tankId
	self.data = data
	self.m_cellSize = cc.size(size.width, 72)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	local img = UiUtil.sprite9("login/btn_server_normal.png", 50, 15, 1, 1, 474, 60)
	if not self.lordId then
		self.lordId = data.lordId
		img = UiUtil.sprite9("login/btn_server_selected.png", 50, 15, 1, 1, 474, 60)
	elseif self.lordId == data.lordId then
		img = UiUtil.sprite9("login/btn_server_selected.png", 50, 15, 1, 1, 474, 60)
	end
	local btn = CellTouchButton.new(img, nil, nil, nil, handler(self, self.choose))
	btn.data = data
	btn.index = index
	cell.btn = btn
	cell:addButton(btn,self.m_cellSize.width/2,self.m_cellSize.height/2)
	t = UiUtil.label(data.nick,nil,COLOR[2]):addTo(cell,2):pos(95,self.m_cellSize.height/2)
	t = UiUtil.label("Lv."..data.level,nil,COLOR[12]):addTo(cell,2):pos(self.m_cellSize.width/2,t:y())
	t = UiUtil.label(UiUtil.strNumSimplify(data.fight),nil,COLOR[6]):addTo(cell,2):pos(self.m_cellSize.width - 95,t:y())
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:choose(tag,sender)
	if self.lordId == sender.data.lordId then return end
	self.lordId = sender.data.lordId
	self:chosenIndex(sender.index)
end

function ContentTableView:chosenIndex(menuIndex)
	for index = 1, #self.m_activityList do
		local cell = self:cellAtIndex(index)
		if cell then
			local img = nil
			if index == menuIndex then
				img = UiUtil.sprite9("login/btn_server_selected.png", 50, 15, 1, 1, 474, 60)
			else
				img = UiUtil.sprite9("login/btn_server_normal.png", 50, 15, 1, 1, 474, 60)
			end
			local data = self.m_activityList[index]
			cell.btn:removeSelf()
			local btn = CellTouchButton.new(img, nil, nil, nil, handler(self, self.choose))
			btn.data = data
			btn.index = index
			cell.btn = btn
			cell:addButton(btn,self.m_cellSize.width/2,self.m_cellSize.height/2)
		end
	end
end

function ContentTableView:updateUI(list)
	self.m_activityList = list or {}
	self:reloadData()
end

function ContentTableView:onEnter()
	ContentTableView.super.onEnter(self)
	self.m_activityHandler = Notify.register(LOCAL_DEFEND_LIST, handler(self, self.updateView))
end

function ContentTableView:onExit()
	ContentTableView.super.onExit(self)
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

function ContentTableView:updateView()
	self.m_activityList = FortressBO.defendList_ or {}
	self:reloadData()
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local FortressSet = class("FortressSet", Dialog)

function FortressSet:ctor(state,camp)
	FortressSet.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(540, 800)})
	self.state = state
	self.camp = camp
	self.data = data
	self.rhand = rhand
	self:size(540,800)
end

function FortressSet:onEnter()
	FortressSet.super.onEnter(self)
	self.m_activityHandler = Notify.register(LOCAL_FORTRESS_END, handler(self, self.fortressEnd))
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(510, 770))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	attrBg:setPreferredSize(cc.size(474, 90))
	attrBg:pos(self:getBg():width()/2,self:getBg():height()-120)
	local t = UiUtil.label(CommonText[431],FONT_SIZE_MEDIUM,COLOR[12])
		:addTo(attrBg):align(display.LEFT_CENTER,110,attrBg:height()/2)
	local fInfo = UiUtil.label(string.format(CommonText[20018],400,400),FONT_SIZE_MEDIUM)
			:addTo(attrBg):rightTo(t)
	self.view = ContentTableView.new(cc.size(474, self:getBg():height()-312))
		:addTo(self:getBg()):pos(33,144)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():width()-46, line:height()))
	line:setPosition(self:getBg():width() / 2, 144)

	local time = UiUtil.label(CommonText[10021]..":",24)
			:addTo(self:getBg()):align(display.LEFT_CENTER,160,100)
	local timeLeft = UiUtil.label("00:00",24,COLOR[2])
			:addTo(self:getBg()):rightTo(time)

	local look = UiUtil.button("btn_1_normal.png","btn_1_selected.png",nil,handler(self, self.look),CommonText[20019])
		:addTo(self:getBg()):pos(140,25)
	local ok = UiUtil.button("btn_2_normal.png","btn_2_selected.png","btn_1_disabled.png",handler(self, self.ok),
			self.camp == FortressBO.DEFEND and CommonText[20020] or CommonText.attr[1]):addTo(self:getBg()):pos(self:getBg():width()-140,25)
	if self.state == FortressMO.TIME_PREHEAT and self.camp == FortressBO.ATTACK then
		ok:setEnabled(false)
	end
	self.timeLeft = timeLeft
	local function getInfo(info,list,cd)
		cd = ManagerTimer.getTime() + cd
		local function tick()
			local left = cd -  ManagerTimer.getTime()
			if left <= 0 then
				left = 0
				self.hasCd = nil
				timeLeft:stopAllActions()
				return
			end
			self.hasCd = left
			timeLeft:setString(string.format("%02d:%02d",math.floor(left / 60) % 60,left % 60))
		end
		timeLeft:performWithDelay(tick, 1, 1)
		tick()
		fInfo:setString(string.format(CommonText[20018],info.nowNum,info.totalNum))
		self.view:updateUI(list)
	end
	FortressBO.GetDefend(getInfo)
end

function FortressSet:look()
	self:pop()
	require("app.view.DefendReport").new(1):push()
end

function FortressSet:fortressEnd()
	self:pop()
end

function FortressSet:ok()
	local function donow()
		if self.camp == FortressBO.ATTACK then
			if #self.view.m_activityList > 0 and not self.view.lordId then
				Toast.show(CommonText[20043])
				return
			end
			-- FortressBO.attackFortress(self.view.lordId)
			FortressMO.attackLordId_ = self.view.lordId or 0
			self:pop()
			require("app.view.ArmyView").new(ARMY_VIEW_FORTRESS):push()
		elseif self.camp == FortressBO.DEFEND then
			self:pop()
			require("app.view.FortressSettingView").new():push()
		end
	end
	if self.hasCd and self.hasCd > 0 then
		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[10022],math.ceil(self.hasCd/10)*5,CommonText.item[1][1]), function()
					FortressBO.buyBattleCd(function()
							self.timeLeft:stopAllActions()
							self.timeLeft:setString("00:00")
							donow()
						end)
				end):push()
		else
			FortressBO.buyBattleCd(function()
					self.timeLeft:stopAllActions()
					self.timeLeft:setString("00:00")
					donow()
				end)
		end
	else
		donow()
	end
end

function FortressSet:onExit()
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

return FortressSet
