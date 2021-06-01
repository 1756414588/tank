--
-- Author: xiaoxing
-- Date: 2017-04-20 11:49:20
--
local ItemTableView = class("ItemTableView", TableView)

function ItemTableView:ctor(size,showOnly)
	ItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.showOnly = showOnly
	self.m_airshipId = nil
end

function ItemTableView:onEnter()
	ItemTableView.super.onEnter(self)
end

function ItemTableView:numberOfCells()
	return #self.m_list
end

function ItemTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ItemTableView:createCellAtIndex(cell, index)
	ItemTableView.super.createCellAtIndex(self, cell, index)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	local data = self.m_list[index]
	local head = UiUtil.createItemView(ITEM_KIND_PORTRAIT, data.portrait):addTo(cell):pos(150,self.m_cellSize.height / 2):scale(0.55)
	head.data = data
	if not self.isMember then

		--gdump(data, "@^^^^^^^^^show data  ", 9)
		if index <= 3 then
			display.newSprite(IMAGE_COMMON.."sort_"..index..".png"):addTo(cell):pos(66,self.m_cellSize.height / 2)
		else
			UiUtil.label(index,36):addTo(cell):pos(66,self.m_cellSize.height / 2)
		end
		local t = UiUtil.label(CommonText[51]..":"..data.lordName, 22, cc.c3b(163, 194, 201)):addTo(cell):align(display.LEFT_CENTER, 220, 120)
		t = UiUtil.label(CommonText[995][3],nil,cc.c3b(154,154,154)):alignTo(t, -40, 1)
		UiUtil.label(data.tankCount):rightTo(t, 5)

		local t2 = UiUtil.label(CommonText[801][1]..":",nil,cc.c3b(154,154,154)):alignTo(t, 165)
		UiUtil.label(data.level):rightTo(t2, 5)

		local t3 = UiUtil.label(CommonText[1110] .. ":",nil,cc.c3b(154,154,154)):alignTo(t, -25, 1)
		local strCmd = CommonText[108]
		if data.commander > 0 then
			local hero = HeroMO.queryHero(data.commander)
			if hero then
				strCmd = hero.heroName
			end
		end
		UiUtil.label(strCmd):rightTo(t3, 5)

		t = UiUtil.label(CommonText[281]..":",nil,cc.c3b(154,154,154)):alignTo(t, -50, 1)
		UiUtil.label(UiUtil.strNumSimplify(data.fight)):rightTo(t, 5)

		if not self.showOnly then
			local btnUp = UiUtil.button("btn_up.png", "btn_up.png", nil, handler(self, self.up), nil, 1)
			btnUp.index = index
			btnUp.data = data
			if index ~= 1 then
				cell:addButton(btnUp, 570, 90)
			end
			local btnDown = UiUtil.button("btn_down.png", "btn_down.png", nil, handler(self, self.down), nil, 1)
			btnDown.index = index
			btnDown.data = data
			if index ~= #self.m_list then
				cell:addButton(btnDown, 570, 40)
			end
		end

		UiUtil.createItemDetailButton(head, cell, true, handler(self, self.onArmyDetail))
	else
		head:x(115)
		UiUtil.createItemDetailButton(head, cell, true, handler(self, self.detail))
		head:run({
				"rep",
				{
				    "seq",
			        {"scaleto",0.6,0.58},
			        {"scaleto",0.6,0.55},
				}
			})
		local ab = AirshipMO.queryShipById(data.airshipId)
		local t = UiUtil.label(CommonText[999][1] ..data.lordName, 22, cc.c3b(163, 194, 201)):addTo(cell):align(display.LEFT_CENTER, 195, 120)
		t = UiUtil.label(CommonText[999][2],nil,cc.c3b(154,154,154)):alignTo(t, -40, 1)
		UiUtil.label(data.armyNum):rightTo(t, 5)
		t = UiUtil.label(CommonText[20]..":",nil,cc.c3b(154,154,154)):alignTo(t, -25, 1)
		UiUtil.label(ab.name):rightTo(t, 5)
		t = UiUtil.label(CommonText[305]..":",nil,cc.c3b(154,154,154)):alignTo(t, -25, 1)
		local p = WorldMO.decodePosition(ab.pos)
		UiUtil.label("("..p.x .."," ..p.y ..")"):rightTo(t, 5)
		local btn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self, self.add), CommonText[999][3], 1)
		btn.lordId = data.lordId
		btn.airshipId = data.airshipId
		cell:addButton(btn, 520, 60)
		-- 战斗力
		t = UiUtil.label(CommonText[632][2]..":" ..UiUtil.strNumSimplify(data.fight), nil, COLOR[6]):addTo(cell)
		t:setAnchorPoint(cc.p(0,0.5))
		t:setPosition(520 - btn:getContentSize().width * 0.45 , 120)-- align(display.RIGHT_CENTER, 562, 120)

		if ArmyMO.checkAirshpState(data.airshipId) then
			local function tick()
				if data.state == ARMY_AIRSHIP_BEGAIN then
					local left = data.endTime - ManagerTimer.getTime()
					if left <= 0 then
						btn:setEnabled(false)
						btn:stopAllActions()
					end
				else
					btn:setEnabled(false)
					btn:stopAllActions()
				end
			end
			btn:schedule(tick, 1)
			tick()
		else
			btn:setLabel(CommonText[1113])
			btn:setEnabled(false)
		end

		gdump(data, "@^^^^^^^^^^^^data    ", 9)
	end
	return cell
end

function ItemTableView:up(tag,sender)
	ManagerSound.playNormalButtonSound()
	AirshipBO.setPlayerAttackSeq(sender.data.lordId, sender.data.armyKeyId, -1, false, nil, function()
		tag = sender.index
		self.m_list[tag-1],self.m_list[tag] = self.m_list[tag],self.m_list[tag-1]
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
	end)
end

function ItemTableView:down(tag,sender)
	ManagerSound.playNormalButtonSound()
	AirshipBO.setPlayerAttackSeq(sender.data.lordId, sender.data.armyKeyId, 1, false, nil, function()
			tag = sender.index
			self.m_list[tag+1],self.m_list[tag] = self.m_list[tag],self.m_list[tag+1]
			local offset = self:getContentOffset()
			self:reloadData()
			self:setContentOffset(offset)
		end)
end

function ItemTableView:add(tag,sender)
	ManagerSound.playNormalButtonSound()
	AirshipBO.teamLord = sender.lordId
	AirshipBO.airshipId = sender.airshipId
	UiDirector.pop()
	require("app.view.ArmyView").new(ARMY_VIEW_AIRSHIP,1):push()
end

function ItemTableView:detail(sender)
	ManagerSound.playNormalButtonSound()
	
	local callback = self.isMember
	-- dump(sender.data, "detail")
	AirshipBO.getAirshipTeamDetail(callback, sender.data.airshipId)
end

function ItemTableView:onArmyDetail( sender )
	ManagerSound.playNormalButtonSound()

	local teamData = sender.data
	dump(teamData, "@^^^^^^onArmyDetail^^^^")

	if self.m_airshipId == nil or self.m_airshipId <= 0 then
		return
	end

	local airshipId = self.m_airshipId
	local lordId = teamData.lordId
	local armyKeyId = teamData.armyKeyId

	AirshipBO.asynGetAirshpTeamArmy(function ( army )
		local ReportArmyDetailView = require("app.view.ReportArmyDetailView")
		ReportArmyDetailView.new(army):push()
	end, airshipId, lordId, armyKeyId)
end

function ItemTableView:onExit()
	ItemTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

function ItemTableView:updateUI(data,isMember)
	self.m_list = data or {}
	self.isMember = isMember
	self:reloadData()
end

function ItemTableView:setAirShipId( airshipId )
	self.m_airshipId = airshipId
end

function ItemTableView:cleanAndReload()
	self.m_list = {}
	self:reloadData()
end

-----------------------------------------------------------------
-----------------------------------------------------------------
local PartyMassView = class("PartyMassView",function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node	
end)

function PartyMassView:ctor(width,height)
	self:size(width,height)
	local t = display.newSprite(IMAGE_COMMON.."info_bg_27.png")
		:addTo(self):align(display.CENTER_TOP, width/2, height)

  	self.btn1 = UiUtil.button("btn_55_normal.png", "btn_55_selected.png", nil, handler(self,self.showIndex),CommonText[994][1])
 		:addTo(t,0,1):pos(180,t:height()/2)
	self.btn2 = UiUtil.button("btn_55_normal.png", "btn_55_selected.png", nil, handler(self,self.showIndex),CommonText[994][2])
	 	:addTo(t,0,2):alignTo(self.btn1, 280)
	self.btn2:setScaleX(-1)
	self.btn2.m_label:setScaleX(-1)
	self.node = display.newNode():size(width,height - t:height()):addTo(self)
	self:showIndex(1)
end

function PartyMassView:showIndex(tag,sender)
	if tag == self.tag then return end
	for i=1,2 do
		if i == tag then
			self["btn"..i]:selected()
		else
			self["btn"..i]:unselected()
		end
	end
	self.tag = tag

	self:updateTeamData()

end

function PartyMassView:updateTeamData()
	local tag = self.tag
	if tag == 1 then
		AirshipBO.getAirshipTeamList(function()
				self:showDetail(tag)
			end, true)
	else
		AirshipBO.getAirshipTeamList(function()
				self:showDetail(tag)
			end)
	end
end

function PartyMassView:showDetail(tag,data,airshipId)
	self.node:removeAllChildren()
	self.cancelBtn = nil
	if tag == 1 then
		--部队上阵
		local cell = display.newNode():size(GAME_SIZE_WIDTH - 12, 145):addTo(self.node):align(display.CENTER, self.node:width()/2, 210)
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(222, 60, 1, 1))
		bg:setPosition(self.node:width()/2, cell:height()/2)
		local itemView = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(cell)
		itemView:setPosition(100, cell:height() / 2)
		local bg = display.newSprite(IMAGE_COMMON .. "item_bg_1.png"):addTo(itemView, -1)
		bg:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2)
		local tag = display.newSprite(IMAGE_COMMON .. "icon_time.png"):addTo(itemView)
		tag:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2)
		-- 待命中
		local title = ui.newTTFLabel({text = CommonText[320][6] .. "...", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
		local desc = ui.newTTFLabel({text = CommonText[481][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = cell:height() - 74, color = COLOR[11]}):addTo(cell)
		local setBtn = UiUtil.button("btn_nxt_normal.png", "btn_nxt_selected.png", "btn_nxt_disabled.png", handler(self, self.set))
			:addTo(cell):pos(cell:width() - 82, cell:height() / 2 - 22)

		if AirshipBO.team_ then
			setBtn.lordId = UserMO.lordId_
			setBtn.airshipId = AirshipBO.team_.airshipId
		end

		if not AirshipBO.team_ or AirshipBO.team_.state ~= ARMY_AIRSHIP_BEGAIN or not ArmyMO.checkAirshpState(AirshipBO.team_.airshipId) then
			setBtn:setEnabled(false)
		end
		--我的战事
		local view = ItemTableView.new(cc.size(self.node:width(),self.node:height() - 280)):addTo(self.node):pos(0,280)
		if AirshipBO.team_ then
			view:setAirShipId(AirshipBO.team_.airshipId)		
		end
		view:updateUI(AirshipBO.myArmy_)
		self.view = view
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self.node)
		line:setPreferredSize(cc.size(self.node:width(), line:getContentSize().height))
		line:setPosition(self.node:width() / 2, 140)
		local t = UiUtil.button("btn_2_normal.png", "btn_2_selected.png", "btn_1_disabled.png", handler(self, self.cancel), CommonText[996][2])
			:addTo(self.node):pos(162,50)

		-- if AirshipBO.team_ and (AirshipBO.team_.state == ARMY_AIRSHIP_BEGAIN or AirshipBO.team_.state == ARMY_AIRSHIP_MARCH) then
		if AirshipBO.team_ and AirshipBO.team_.state == ARMY_AIRSHIP_BEGAIN then
		else
			t:setEnabled(false)
		end

		self.cancelBtn = t

		-- UiUtil.label(CommonText[996][3]):alignTo(t, 50, 1)
		local btn = UiUtil.button("btn_1_normal.png", "btn_1_selected.png", "btn_1_disabled.png", handler(self, self.attack), CommonText[996][4])
			:alignTo(t, self.node:width() - t:x()*2)
		self.stateBtn = btn
		t = UiUtil.label(""):alignTo(btn, 50, 1)
		self.stateLab = t
		self:checkState(t,btn)
	elseif tag == 2 then
		local view = ItemTableView.new(cc.size(self.node:width(),self.node:height())):addTo(self.node)
		view:updateUI(AirshipBO.memberTeams_,handler(self, self.showLordDetail))
		self.view = view
	elseif tag == 3 then
		local view = ItemTableView.new(cc.size(self.node:width(),self.node:height()), 1):addTo(self.node)
		view:setAirShipId(airshipId)	
		view:updateUI(data)
		self.view = view
	end
end

function PartyMassView:showLordDetail(data, airshipId)
	self:showDetail(3,data,airshipId)
end

function PartyMassView:checkState(lab,btn)
	if AirshipBO.team_ then
		-- 定时攻击
		-- local function doTimeAttack()
		-- 	-- self:doAttack()
		-- 	self:updateTeamData()
		-- end

		local function tick()
			if not AirshipBO.team_ then
				lab:stopAllActions()
				lab:setString("")
				return
			end
			local left = AirshipBO.team_.endTime - ManagerTimer.getTime()
			if left <= 0 then
				lab:stopAllActions()
				-- if AirshipBO.team_.state == ARMY_AIRSHIP_BEGAIN then
				-- 	-- doTimeAttack()
				-- 	-- dump(AirshipBO.team_, "@^^^^^^AirshipBO.team_")
				-- end
				if left < -30 then
					----服务器时间超时 特殊处理
					if AirshipBO.team_ and AirshipBO.team_.state == ARMY_AIRSHIP_BEGAIN then
						self.cancelBtn:setEnabled(true)
					end
				else
					self:updateTeamData()
				end
				left = 0
			end
			local time = ManagerTimer.time(left)
			local tl = string.format("%02d:%02d", time.minute, time.second)
			local str = 0
			if AirshipBO.team_.state == ARMY_AIRSHIP_BEGAIN then
				str = 5
			elseif AirshipBO.team_.state == ARMY_AIRSHIP_MARCH then
				str = 6
			end
			if str > 0 then
				lab:setString(string.format(CommonText[996][str], tl))
			else
				lab:setString("")
			end
		end
		btn:setEnabled(AirshipBO.team_.state == ARMY_AIRSHIP_BEGAIN)
		lab:schedule(tick, 1)
		tick()
	else
		lab:stopAllActions()
		lab:setString("")
		btn:setEnabled(false)
	end
end

-- 撤销集结
function PartyMassView:cancel(tag, sender)
	ManagerSound.playNormalButtonSound()
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(CommonText[1006],function()
		AirshipBO.cancelTeam(function()
			sender:setEnabled(false)
			if self.tag == 1 and self.view then -- 我的战事
				self.view:cleanAndReload()
			end
			self:checkState(self.stateLab, self.stateBtn)
		end)
	end):push()
end

-- 即刻发兵(行军)
function PartyMassView:attack()
	ManagerSound.playNormalButtonSound()

	-- 未设置部队不能发兵
	if AirshipBO.myArmy_ and table.getn(AirshipBO.myArmy_) <= 0 then
		Toast.show(CommonText[1011])
		return
	end

	self:doAttack()
end

--
function PartyMassView:doAttack()
	AirshipBO.startAirshipTeamMarch(function()
			ArmyMO.dirtyArmyData_ = false
	end)
	UiDirector.pop()
	require("app.view.ArmyView").new(ARMY_VIEW_AIRSHIP,2):push()
end

function PartyMassView:set(tag, sender)
	ManagerSound.playNormalButtonSound()
	if ArmyMO.getArmyNum() >= VipBO.getArmyCount() then -- 提升VIP，才能执行任务
		Toast.show(CommonText[366][2])
		return
	end

	local armyNum = ArmyMO.getFightArmies()
	if armyNum >= VipMO.queryVip(UserMO.vip_).armyCount then
		Toast.show(CommonText[1629])
		return
	end

	UiDirector.pop()
	-- AirshipBO.teamLord = UserMO.lordId_
	AirshipBO.teamLord = sender.lordId
	AirshipBO.airshipId = sender.airshipId

	require("app.view.ArmyView").new(ARMY_VIEW_AIRSHIP,1):push()
end 


function PartyMassView:onEnter()
	self.r_airShipTeamUpdateHandler_ = Notify.register(LOCAL_AIRSHIP_TEAM_UPDATE_EVENT, function ()
		self:updateTeamData()
	end)
end

function PartyMassView:onExit()
	if self.r_airShipTeamUpdateHandler_ then
		Notify.unregister(self.r_airShipTeamUpdateHandler_)
		self.r_airShipTeamUpdateHandler_ = nil
	end
end

return PartyMassView