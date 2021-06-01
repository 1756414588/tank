--
--
--
--

local OwnGiftTableView = class("OwnGiftTableView", TableView)

function OwnGiftTableView:ctor(size,docallbakc)
	OwnGiftTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 170 )
	self.docallback = docallbakc
end

function OwnGiftTableView:onEnter()
	OwnGiftTableView.super.onEnter(self)
	self.dataList = {}
	self.state = 0 --1 可领取  0 不可领取
	self.times = 0
end

function OwnGiftTableView:ReloadInfo(data)
	self.dataList = {}
	-- for k,v in pairs(data) do
	-- 	local list = json.decode(v.awardlist)
	-- 	local out = {}
	-- 	out.id = v.id
	-- 	out.giftid = v.giftid
	-- 	out.awardlist = list
	-- 	self.dataList[#self.dataList + 1] = out
	-- end
	self.dataList = data
end

function OwnGiftTableView:UpdateView(data)
	self.state = data.states -- 领取状态
	self.times = data.left
	self:reloadData()
end

function OwnGiftTableView:numberOfCells()
	return #self.dataList
end

function OwnGiftTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function OwnGiftTableView:createCellAtIndex(cell, index)
	OwnGiftTableView.super.createCellAtIndex(self, cell, index)
	local data = self.dataList[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(cell, 1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 10, self.m_cellSize.height - 5))
	bg:setPosition(self.m_cellSize.width * 0.5, self.m_cellSize.height * 0.5)

	local name = ui.newTTFLabel({text = data.giftid, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(bg, 3)
	name:setAnchorPoint(cc.p(0,1))
	name:setPosition(45, bg:getContentSize().height - 15)

	for index = 1 , #data.awardlist do
		local _d = data.awardlist[index]
		local item = UiUtil.createItemView(_d[1], _d[2], {count = _d[3]}):addTo(bg , 7)
		item:setScale(0.9)
		item:setPosition(item:width() * 0.85 + item:width() * 1.2 * (index - 1) , bg:getContentSize().height * 0.5 - 13)
		UiUtil.createItemDetailButton(item)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = MenuButton.new(normal,selected,disabled,handler(self, self.btncallback)):addTo(bg,5)
	btn:setPosition(bg:getContentSize().width - btn:width() * 0.7 , bg:getContentSize().height * 0.5 - 13)
	if self.state == 1 then
		btn:setLabel(CommonText[694][2])
	else
		btn:setLabel(CommonText[10004])
	end
	if self.times == 0 then
		btn:setVisible(false)
	end

	btn.id = data.id

	return cell
end

function OwnGiftTableView:btncallback(tag, sender)
	if self.state == 1 then
		-- 领取奖励
		local id = sender.id

		if self.docallback then self.docallback(id) end

	else
		-- 去充值
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
	end
end

function OwnGiftTableView:onExit()
	OwnGiftTableView.super.onExit(self)
end





------------------------------------------------------------------
--						自选豪礼								--
------------------------------------------------------------------


local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ActivityOwnGiftView = class("ActivityOwnGiftView", UiNode)

function ActivityOwnGiftView:ctor(activity)
	ActivityOwnGiftView.super.ctor(self, "image/common/bg_ui.jpg")
	self.m_activity = activity
end


function ActivityOwnGiftView:onEnter()
	ActivityOwnGiftView.super.onEnter(self)

	-- 活动标识
	self._key = self.m_activity.activityId .. "_" .. self.m_activity.awardId .. "_" .. self.m_activity.beginTime
	self.ischeck = ActivityCenterMO.UseActivityLoaclRecordInfo(self._key)

	self:setTitle(self.m_activity.name)

	-- 顶部背景
	local topbg = display.newSprite(IMAGE_COMMON .. "bar_owngift.jpg"):addTo(self:getBg())
	topbg:setAnchorPoint(cc.p(0.5,1))
	topbg:setPosition(self:getBg():getContentSize().width * 0.5, self:getBg():getContentSize().height - 100)

	local topbg2 = display.newSprite(IMAGE_COMMON .. "bar_bg.png"):addTo(topbg , -1)
	topbg2:setAnchorPoint(cc.p(0.5,0.5))
	topbg2:setPosition(topbg:width() * 0.5, topbg:height() * 0.5)

	--timeTitle
	local lb_time_title = ui.newTTFLabel({text = CommonText[853], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(topbg)
	lb_time_title:setAnchorPoint(cc.p(0,0.5))
	lb_time_title:setPosition(15 , lb_time_title:getContentSize().height * 0.5 + 5)

	--time
	local lb_time = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(topbg)
	lb_time:setAnchorPoint(cc.p(0,0.5))
	lb_time:setPosition(25 + lb_time_title:getContentSize().width , lb_time_title:y())
	self.lb_time = lb_time

	local lb_info = ui.newTTFLabel({text = CommonText[1070][2], font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topbg)
	lb_info:setAnchorPoint(cc.p(0,0.5))
	lb_info:setPosition(15,topbg:height() * 0.5)

	local lb_info1 = ui.newTTFLabel({text = CommonText[1070][3], font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topbg)
	lb_info1:setAnchorPoint(cc.p(0,0.5))
	lb_info1:setPosition(15,lb_info:y() - lb_info:height())

	local lb_info2 = ui.newTTFLabel({text = CommonText[1070][4], font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(topbg)
	lb_info2:setAnchorPoint(cc.p(0,0.5))
	lb_info2:setPosition(15,lb_info1:y() - lb_info1:height())


	-- 充值提示 bg
	local rechargeTipbg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(topbg)
	rechargeTipbg:setAnchorPoint(cc.p(0,1))
	rechargeTipbg:setPosition(-10,-rechargeTipbg:height() * 0.5 - 5)

	-- 充值提示
	local lb_rechargeTip = ui.newTTFLabel({text = string.format(CommonText[1070][1],0), font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(rechargeTipbg)
	lb_rechargeTip:setAnchorPoint(cc.p(0,0.5))
	lb_rechargeTip:setPosition(40 , rechargeTipbg:getContentSize().height * 0.5)
	self.lb_rechargeTip = lb_rechargeTip

	-- 剩余次数 bg
	local leftTimesbg =	display.newScale9Sprite(IMAGE_COMMON .. "bar_bg_12.png"):addTo(topbg)
	leftTimesbg:setPreferredSize(cc.size(rechargeTipbg:width() * 0.75, rechargeTipbg:height() * 0.75))
	leftTimesbg:setAnchorPoint(cc.p(0,1))
	leftTimesbg:setPosition(0,-rechargeTipbg:height() * 1.25 - leftTimesbg:height() * 0.75)

	-- 剩余次数
	local lb_leftTimes = ui.newTTFLabel({text = CommonText[282] .. ": 0/0", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(leftTimesbg)
	lb_leftTimes:setAnchorPoint(cc.p(0.5,0.5))
	lb_leftTimes:setPosition(leftTimesbg:width() * 0.5 , leftTimesbg:height() * 0.5 )
	self.lb_leftTimes = lb_leftTimes

	-- tips
	local function tipsCallback()
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.OwnGiftTips):push()
	end
	local tips = UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil,tipsCallback):addTo(topbg)
	tips:setPosition(topbg:getContentSize().width - 55 , -tips:height())

	-- 奖励列表
	local view = OwnGiftTableView.new(cc.size(self:getBg():getContentSize().width * 0.9 + 20, topbg:y() - topbg:height() - rechargeTipbg:height() * 1.5 - leftTimesbg:height() * 1.5 - 35),handler(self,self.DoChooseGift)):addTo(self:getBg(),2)
	view:setAnchorPoint(cc.p(0,0))
	view:setPosition(self:getBg():getContentSize().width * 0.05 - 10 , 30)
	self.view = view

	self.giftDataList = {} 	-- 数据表
	self.timeEndTag = -1 	-- 刷新标识
	local time = self.m_activity.endTime - ManagerTimer.getTime()
	if time < 0 then self.timeEndTag = 1 end

	-- 刷新时间
	if not self.timeScheduler then
		self.timeScheduler = scheduler.scheduleGlobal(handler(self,self.update), 1)
	end

	-- 注册消息
	if not self.notifyhandler then
		self.notifyhandler = Notify.register("ACTIVITY_NOTIFY_OWNGIFT", handler(self, self.loadInfo))
	end

	self:loadInfo()
end

function ActivityOwnGiftView:loadInfo()
	local function ActHandler(data)
		-- 刷新次数
		self.lb_leftTimes:setString(CommonText[282] .. ": " .. data.left .. "/" .. data.limit)

		-- 获取奖励信息
		self.giftDataList = ActivityCenterMO.getChooseGift(data.awardId)

		local putInfo = {}
		local tipnum = 0
		for k,v in pairs(self.giftDataList) do
			local list = json.decode(v.awardlist)
			tipnum = v.qualification / 10
			local out = {}
			out.id = v.id
			out.giftid = v.giftid
			out.awardlist = list
			putInfo[#putInfo + 1] = out
		end

		local function mysort(a, b)
			return a.id < b.id
		end
		table.sort(putInfo, mysort)

		-- 刷新提示
		self.lb_rechargeTip:setString(string.format(CommonText[1070][1],tipnum))

		self.view:ReloadInfo(putInfo)
		self.view:UpdateView(data)
	end

	ActivityCenterBO.GetActChooseGift(ActHandler)
end

function ActivityOwnGiftView:DoChooseGift(index)

	local function DoGift(data)
		self:DoGetGift(data,index)
	end

	local function choose()
		ActivityCenterBO.DoActChooseGift(DoGift, index)
	end

	if not self.ischeck then
		local ActivityLocalConfirmDialog = require("app.dialog.ActivityLocalConfirmDialog")
  		local dialog = ActivityLocalConfirmDialog.new(CommonText[1072], self._key, self.ischeck,
  		function(state) 
			if state then
				self.ischeck = not self.ischeck
			end 
			choose()
  		end):push()
  		dialog:setOkBtnText(CommonText[1071][1])
  		dialog:setCancelBtnText(CommonText[1071][2])
  	else
  		choose()
	end
end

function ActivityOwnGiftView:DoGetGift( data, index )
	-- 修改领取次数
	self.lb_leftTimes:setString(CommonText[282] .. ": " .. data.left .. "/" .. data.limit)
	-- 刷新领奖界面
	self.view:UpdateView(data)

	-- 领取奖励
	local awards = {}
	local awardData = self.giftDataList[index]
	local list = json.decode(awardData.awardlist)
	for index = 1, #list do
		local _d = list[index]
		-- ITEM_KIND_COIN detailed
		local award = {type = _d[1], id = _d[2], count = _d[3]} 
		awards[#awards + 1] = award
	end
	if #awards <= 0 then return end
	local ret = CombatBO.addAwards(awards)
	UiUtil.showAwards(ret)
end

-- 秒更新 倒计时
function ActivityOwnGiftView:update( ft )
	if self.lb_time then
		local time = self.m_activity.endTime - ManagerTimer.getTime()
		if time >= 0 then 
			self.lb_time:setString(UiUtil.strBuildTime(time))
		else
			self.lb_time:setString(UiUtil.strBuildTime(0))
			self.timeEndTag = self.timeEndTag + 1
			if self.timeEndTag == 0 then
				self:loadInfo()
			end
		end
	end
end

function ActivityOwnGiftView:onExit()
	ActivityOwnGiftView.super.onExit(self)

	if self.notifyhandler then
		Notify.unregister(self.notifyhandler)
		self.notifyhandler = nil
	end

	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
		self.timeScheduler = nil
	end
end

return ActivityOwnGiftView