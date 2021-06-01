--
-- Author: xiaoxing
-- Date: 2017-03-22 10:18:20
--
-- 七天连续活动
---------------------------------------------左侧菜单------------------
local MenuTableView = class("MenuTableView", TableView)
function MenuTableView:ctor(size,rhand)
	MenuTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_chosenIndex = 1
	self.m_cellSize = cc.size(size.width, 80)
end

function MenuTableView:createCellAtIndex(cell, index)
	MenuTableView.super.createCellAtIndex(self, cell, index)
	local activity = self.m_activityList[index]
	local normal = display.newSprite(IMAGE_COMMON .. "btn_20_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_20_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenCallback))
	btn:setLabel(activity, {size = FONT_SIZE_SMALL})
	btn.index = index
	cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	cell.btn = btn
	if self.m_chosenIndex == index then
		btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_selected.png"))
		self.rhand(index)
	end
	local count =  ActivityWeekBO.getWeekCurrDayPoint(index,self.day)
	btn.count = count
	if count >= 1 then
		UiUtil.showTip(btn, count)
	else
		UiUtil.unshowTip(btn)
	end
	return cell
end

function MenuTableView:numberOfCells()
	return #self.m_activityList
end

function MenuTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MenuTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.index == self.m_chosenIndex then
	else
		self:chosenIndex(sender.index)
		self.rhand(sender.index)
		if sender.index == 4 and sender.count > 0 then
			UiUtil.unshowTip(sender)
		end
	end
end

function MenuTableView:chosenIndex(menuIndex)
	self.m_chosenIndex = menuIndex
	for index = 1, self:numberOfCells() do
		local cell = self:cellAtIndex(index)
		if cell then
			if index == self.m_chosenIndex then
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_selected.png"))
			else
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_normal.png"))
			end
		end
	end
end

function MenuTableView:updateUI(day,data)
	self.day = day
	self.m_activityList = data
	self:reloadData()
end

---------------------------------------------右侧内容------------------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,rhand)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 180)
	self.rhand = rhand
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	local info = self.data[data.keyId]
	local w,h = self.m_cellSize.width,self.m_cellSize.height
	if self.index == 4 then
		local v = json.decode(data.awardList)[1]
		local t = display.newSprite(IMAGE_COMMON.."banjia.png"):addTo(cell):pos(w/2, h-50)
		t = UiUtil.createItemView(v[1], v[2],{count = v[3]}):addTo(cell):pos(w/2,h - 140)
		UiUtil.createItemDetailButton(t, cell, true)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 2, 
			x = t:getPositionX(), y = t:getPositionY() - 70, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		t = UiUtil.label(CommonText[460][1]):addTo(cell):pos(90,name:y() - 50)
		t = display.newSprite(IMAGE_COMMON.."icon_coin.png"):addTo(cell):rightTo(t)
		local param = json.decode(data.param)
		t = UiUtil.label(param[1]):rightTo(t)
		display.newSprite(IMAGE_COMMON.."info_bg_73.png"):addTo(cell):pos(130,t:y())

		t = UiUtil.label(CommonText[460][2],nil,COLOR[2]):addTo(cell):pos(290,t:y())
		t = display.newSprite(IMAGE_COMMON.."icon_coin.png"):addTo(cell):rightTo(t)
		t = UiUtil.label(param[2],nil,COLOR[2]):rightTo(t)

		local btn = UiUtil.button("btn_2_normal.png", "btn_2_selected.png", "btn_1_disabled.png", handler(self, self.getBtn), CommonText.WeekActivity[1][2], 1)
		cell:addButton(btn, w/2, t:y() - 70)
		btn.recved = info.recved
		btn.data = data
		if info.recved == 3 then
			btn:setLabel(CommonText[672][2])
			btn:setEnabled(false)
		elseif info.recved == 2 then
			btn:setLabel(CommonText[672][3])
			btn:setEnabled(false)
		end
	else
		local t = display.newSprite(IMAGE_COMMON.."info_bg_12.png"):addTo(cell):align(display.LEFT_CENTER, 12, h-24)
		t = UiUtil.label(data.desc):alignTo(t, 38)
		local c = info.status >= data.cond and 2 or 6
		if data.gotoUi == 35 then 
			c = info.status > data.cond and 6 or 2
		end
		if data.cond > 0 then
			UiUtil.label("("..info.status.."/"..data.cond..")",nil,COLOR[c]):rightTo(t)
		end
		local x,y,ex = 55,h -90,105
		for k,v in ipairs(json.decode(data.awardList)) do
			local itemView = UiUtil.createItemView(v[1], v[2],{count = v[3]})
			itemView:setPosition(x + (k - 1) * ex, y)
			itemView:setScale(0.8)
			cell:addChild(itemView)
			UiUtil.createItemDetailButton(itemView, cell, true)
			local propDB = UserMO.getResourceData(v[1], v[2])
			local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 2, 
				x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[propDB.quality or 1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		end
		local btn = nil
		if info.recved == 0 then
			btn = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self, self.getBtn), CommonText[672][1], 1)
		elseif info.recved == 1 then
			btn = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self, self.getBtn), CommonText[676][2], 1)
		elseif info.recved == 2 then
			btn = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", "btn_9_disabled.png", handler(self, self.getBtn), CommonText[672][3], 1)
			btn:setEnabled(false)
		elseif info.recved == 3 then
			btn = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", "btn_9_disabled.png", handler(self, self.getBtn), CommonText[672][2], 1)
			btn:setEnabled(false)
		end
		btn.recved = info.recved
		btn.data = data
		cell:addButton(btn,w - 80,y)
	end

	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:getBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	local data = sender.data
	if sender.recved == 0 then
		local param = json.decode(data.param)
		if data.gotoUi == 65 then
			local function gotoBuy()
				local count = UserMO.getResource(ITEM_KIND_COIN)
				if count < param[2] then  -- 金币不足
					require("app.dialog.CoinTipDialog").new():push()
					return
				end
				ActivityWeekBO.asynRecvDay7ActAward(function()
						self.rhand(self.currDay)
					end,data.keyId,self.currDay,1)
			end

			if UserMO.consumeConfirm then
				local resData = UserMO.getResourceData(ITEM_KIND_COIN)
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText.WeekActivityCom, param[2], resData.name), function() gotoBuy() end):push()
			else
				gotoBuy()
			end
			return
		end
		ActivityWeekBO.asynRecvDay7ActAward(function()
				self.rhand(self.currDay)
			end,data.keyId,self.currDay)
	elseif sender.recved == 1 then
		UiDirector.pop()
		local kind = data.gotoUi
		if not kind then return end
		if kind == 6 then --升级指挥中心
			require("app.view.CommandInfoView").new():push()
		elseif kind == 53 then  --副本星数
			require("app.view.CombatSectionView").new():push()
		elseif  kind == 7 then  --船坞等级
			local buildLvA = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_A)
			local buildLvB = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_B)
			local buildId
			if buildLvA > buildLvB then
				buildId = BUILD_ID_CHARIOT_A
			else
				buildId = BUILD_ID_CHARIOT_B
			end
			require("app.view.ChariotInfoView").new(buildId):push()	
		elseif kind == 54 or kind == 55 then --装备数量(抽装备)
			require("app.view.LotteryEquipView").new(UI_ENTER_NONE):push()
		elseif kind == 9 then  --科研中心升级
			require("app.view.ScienceView").new(BUILD_ID_SCIENCE):push()
		elseif kind == 12 then --生产舰队
			local buildLvA = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_A)
			local buildLvB = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_B)
			local buildId
			if buildLvA < buildLvB then
				buildId = BUILD_ID_CHARIOT_B
			else
				buildId = BUILD_ID_CHARIOT_A
			end
			require("app.view.ChariotInfoView").new(buildId,CHARIOT_FOR_PRODUCT):push()
		elseif kind == 56 then --任意资源建筑等级达到8
			local homeView = UiDirector.getUiByName("HomeView")
			homeView:showChosenIndex(MAIN_SHOW_WILD)
		elseif kind == 35 then --竞技场
			require("app.view.ArenaView").new():push()
		elseif kind == 34 then  --科技总等级
			--ScienceMO.getTotalLevel()
			require("app.view.ScienceView").new(BUILD_ID_SCIENCE,SCIENCE_FOR_STUDY):push()
		elseif kind == 57 then   --从服务器获取当前采集量
	        local homeView = UiDirector.getUiByName("HomeView")
	        homeView:showChosenIndex(MAIN_SHOW_WORLD)
		elseif kind == 58 or kind == 59  then  -- 繁荣度和统率
			require("app.view.PlayerView").new():push()
		elseif kind == 60 then 					--战斗力
			require("app.view.FightValueView").new():push() 
		elseif kind == 61 then 					--技能总等级(getSkillTotalLevel)
			require("app.view.PlayerView").new(UI_ENTER_NONE, PLAYER_VIEW_SKILL):push()
		elseif kind == 62 then   			--免费
		elseif kind == 63 then 				--猪脚等级
			require("app.view.CombatSectionView").new():push()
		elseif kind == 64 then 				--累计充值
			-- require("app.view.RechargeView").new():push()
			RechargeBO.openRechargeView()
		elseif kind == 65 then              --半价限购
		end
	end
end

function ContentTableView:updateUI(day,index,data)
	self.currDay = day
	self.data = {}
	for k,v in pairs(ActivityWeekMO.WeekList_[day]) do
		self.data[v.keyId] = v
	end
	self.index = index
	if index == 4 then
		self.m_cellSize.height = 400
	else
		self.m_cellSize.height = 180
	end
	self.m_activityList = data
	self:reloadData()
end
------------------------------------------------------------------------

local ActivityWeekView = class("ActivityWeekView", UiNode)

function ActivityWeekView:ctor()
	ActivityWeekView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function ActivityWeekView:onEnter()
	ActivityWeekView.super.onEnter(self)
	self:setTitle(CommonText.WeekActivity[1][3])
	local bg = self:getBg()
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "activity_bar7.jpg"):addTo(self:getBg())
	infoBg:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - infoBg:getContentSize().height)
	local t = UiUtil.label(CommonText[20223]):addTo(infoBg):align(display.LEFT_CENTER, 50, 105)
	self.m_timeLab2 = UiUtil.label(""):rightTo(t)
	t = UiUtil.label(CommonText.WeekActivityAward):alignTo(t, -30, 1)
	self.m_timeLab1 = UiUtil.label(""):rightTo(t)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	--活动说明
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	-- local detailBtn = MenuButton.new(normal, selected, nil, function()

	-- 	end):addTo(infoBg)
	-- detailBtn:setPosition(infoBg:getContentSize().width - 90, 95)

	--天数按钮
	local panel = display.newSprite(IMAGE_COMMON.."banel_bottom.png")
	panel:addTo(bg):pos(bg:width()/2,infoBg:y() - infoBg:height()/2 - panel:height()/2)
	--根据时间判断当前天数
	self.currDay = UserBO.getWeekCurrDay()

	self.m_checkBoxs = {}
	local x,y,ex = 48,panel:height()/2,85
	for i=1,7 do
		local tx = x + (i-1)*ex
		local t = nil
		if i == self.currDay then
			t = CheckBox.new(display.newSprite(IMAGE_COMMON.."btn_2.png"), display.newSprite(IMAGE_COMMON.."btn_2.png"),handler(self, self.onCheckedChanged))
		else
			t = CheckBox.new(display.newSprite(IMAGE_COMMON.."btn_3.png"), display.newSprite(IMAGE_COMMON.."btn_1.png"),handler(self, self.onCheckedChanged))
		end
		UiUtil.label(CommonText.WeekActivity[2][i]):addTo(panel,10):pos(tx,y)
		self.m_checkBoxs[i] = t:addTo(panel,0,i):pos(tx,y)
	end

	--菜单+内容
	local cont = UiUtil.sprite9("info_bg_11.png",130,40,1,1,474,panel:y() - panel:height()/2 - 40)
		:addTo(bg):align(display.CENTER_BOTTOM, bg:width() - 474 / 2 - 10, 25)
	local t = display.newSprite(IMAGE_COMMON .. "info_bg_28.png")
		:addTo(cont):pos(cont:width()/2,cont:height()-10)
	self.title = UiUtil.label(""):addTo(t):center()
	--内容
	self.content = ContentTableView.new(cc.size(474, cont:height() - 55),handler(self, self.setUI))
		:addTo(cont):pos(0,21)
	-- 菜单
	local view = MenuTableView.new(cc.size(130, cont:height()),handler(self, self.onChosenMenu))
		:addTo(bg):pos(20,20)
	self.menu = view

	ActivityWeekBO.asynGetDay7Act(function(success)
			self:setUI(self.currDay)
			for i=1,7 do
				local v = ActivityWeekBO.getWeekCurrDayTotalPoint(i)
				if v >= 1 then
					UiUtil.showTip(self.m_checkBoxs[i],v,70,65)
				else
					UiUtil.unshowTip(self.m_checkBoxs[i])
				end
			end
		end,self.currDay)
end

function ActivityWeekView:onCheckedChanged(sender)
	if sender:getTag() == self.currDay then
		self.m_checkBoxs[self.currDay]:setChecked(true)
		return
	end
	ManagerSound.playNormalButtonSound()
	for index = 1,7 do
		if index == sender:getTag() then
			self.m_checkBoxs[index]:setChecked(true)
			self.currDay = index
			ActivityWeekBO.asynGetDay7Act(function()
					self:setUI(index)
			end,self.currDay)
		else
			self.m_checkBoxs[index]:setChecked(false)
		end
	end
end

function ActivityWeekView:changeTips()
	local v = ActivityWeekBO.getWeekCurrDayTotalPoint(self.currDay)
	if v >= 1 then
		UiUtil.showTip(self.m_checkBoxs[self.currDay],v,70,65)
	else
		UiUtil.unshowTip(self.m_checkBoxs[self.currDay])
	end
	local half = {}
	for k,v in pairs(ActivityWeekBO.halfPrice) do
		half[math.floor(k/10)] = true
	end
	ActivityWeekMO.RedPoint = 0
	for k,v in pairs(ActivityWeekMO.tips) do
		if half[k] then
			v = v - 1
		end
		ActivityWeekMO.RedPoint  = ActivityWeekMO.RedPoint + v
	end
end

function ActivityWeekView:onChosenMenu(index)
	self.title:setString(self.titleName[index])
   	local needData = nil
	if index == 1 then
		needData = ActivityWeekMO.getFirstTabData(self.currDay)
	elseif index == 2 then
		needData = ActivityWeekMO.getTwoTabData(self.currDay)
	elseif index == 3 then
		needData = ActivityWeekMO.getThreeTabData(self.currDay)
	else
		if ActivityWeekBO.getWeekCurrDayPoint(index,self.currDay) > 0 then
			ActivityWeekBO.halfPrice[self.currDay*10 + index] = true
		end
		needData = ActivityWeekMO.getFourTabData(self.currDay)
	end
	needData = ActivityWeekMO.sortWeekData(needData,ActivityWeekMO.WeekList_[self.currDay])
	self.content:updateUI(self.currDay,index,needData)
	self:changeTips()
end

--当前天数
function ActivityWeekView:setUI(_index)
	local v = ActivityWeekBO.getWeekCurrDayTotalPoint(_index)
	if v >= 1 then
		UiUtil.showTip(self.m_checkBoxs[_index],v,70,65)
	else
		UiUtil.unshowTip(self.m_checkBoxs[_index])
	end
	local pages = {CommonText.WeekActivity[1][1],CommonText.WeekActivity[3][_index*2-1],CommonText.WeekActivity[3][_index*2],CommonText.WeekActivity[1][2]}
	self.titleName = pages
	self.menu:updateUI(self.currDay,pages)
end

function ActivityWeekView:update(dt)
	if not self.m_timeLab2 then return end
	local leftTime = UserBO.getWeekActEndTime() - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab2:setString(UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab2:setString(CommonText[852])
	end
	if not self.m_timeLab1 then return end
	local leftTime = UserBO.getWeekAwardEndTime() - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab1:setString(UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab1:setString(CommonText[852])
	end
end

function ActivityWeekView:onExit()
	ActivityWeekView.super.onExit(self)
	if  ActivityWeekBO.firstOpen == true then
		ActivityWeekBO.firstOpen = false
	end
end

return ActivityWeekView

