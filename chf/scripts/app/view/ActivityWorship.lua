--
-- Author: yansong
-- Date: 2017-03-07
-- 拜神许愿

local ActivityWorship = class("ActivityWorship",UiNode)

function ActivityWorship:ctor(activity,form)
	ActivityWorship.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
	self.form = form or 1
end


function ActivityWorship:onEnter()
	ActivityWorship.super.onEnter(self)
	
	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	--self.updateForday = false --整点刷新

	local function createDelegate(container, index)
		if index == 1 then
			self:enterWorshipGod(container)
		else
			self:enterWorshipTask(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = CommonText[20198]
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, 
		{x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2,
		 createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true
		 }):addTo(self:getBg(), 2)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)


	self.isGod = false
	self.isTask = false
	self.worshipCount = 0
	self.worshiptimes = 0
	self.tasknum = {}
	self.task = {}
	self.awardIcon = {}

	if self.form == 1 then
		pageView:setPageIndex(1)
	else
		pageView:setPageIndex(2)
	end
end


function ActivityWorship:onExit()
	ActivityWorship.super.onExit(self)
end


--[[    =======  UPDATA   ======   ]]
function ActivityWorship:update(dt)
	if not self.timeLabGod and not self.timeLabTask then return end

	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()

	-- 拜神界面 刷新时间
	if self.isGod and self.timeLabGod then
		--[[
		if (math.floor(leftTime) % 86400) == 0 and not self.updateForday then
			self.updateForday = true
			self.m_pageView:setPageIndex(1)
		end]]

		if leftTime > 0 then
			self.timeLabGod:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
		else
			self.timeLabGod:setString(CommonText[871])
		end
	end

	-- 许愿界面 刷新时间
	if self.isTask and self.timeLabTask then
		--[[
		if (math.floor(leftTime) % 86400) == 0 and not self.updateForday then
			self.updateForday = true
			self.m_pageView:setPageIndex(2)
		end]]
		
		if leftTime > 0 then
			self.timeLabTask:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
		else
			self.timeLabTask:setString(CommonText[871])
		end
	end
	
end



function ActivityWorship:enterWorshipGod(container)
	-- 请求拜神界面
	self.isGod = false
	self.isTask = false
	self.timeLabGod = nil
	ActivityCenterBO.getWorshipGodAct(function(data)
		--[[ GetWorshipGodActRs 
				required int32 count = 1;    //  剩余拜神次数
		    	repeated TwoInt record = 2;   //  金币记录  (时间  ：获得的金币)
		]]
		--self.updateForday = false

		local recordlist = PbProtocol.decodeArray(data["record"])
		ActivityCenterMO.worshipRecord = {}
		for index=1 ,#recordlist do
			local record = {}
			record.time = recordlist[index].v1 -- v1
			record.value = recordlist[index].v2 -- v2
			ActivityCenterMO.worshipRecord[#ActivityCenterMO.worshipRecord + 1] = record
		end
		self.worshiptimes = data.count

		gdump(ActivityCenterMO.worshipRecord,"worshipRecord = ")

		-- UI
		self:pagesForGod(container)
		self.isGod = true
	end)
end

function ActivityWorship:enterWorshipTask(container)
	-- 请求许愿界面
	self.isGod = false
	self.isTask = false
	self.timeLabTask = nil
	ActivityCenterBO.getWorshipTaskAct(function(data)
		--[[
			GetWorshipTaskActRs  
				required int32 awardId = 1; // 奖励id
				repeated TwoInt taskNum = 2; // 任务完成数量  (任务下标  ：完成数量) 
				required int32 count = 3; // 可许愿次数
		]]

		local date = ManagerTimer.time(ManagerTimer.getTime() - self.m_activity.beginTime)
		-- 第几天
		self.numDays = 1
		if date.day <= 0 then
			self.numDays = 1
		elseif date.day > 0 and date.day <= 1 then
			self.numDays = 2
		elseif date.day > 1 then--and date.day <= 2 then
			self.numDays = 3
		end

		print("today is No." .. self.numDays .. " day.")

		--self.updateForday = false

		local awardid = data.awardId -- 奖励任务ID 奖励id
		local taskNum = PbProtocol.decodeArray(data["taskNum"]) -- 任务完成数量  (任务下标  ：完成数量) 
		self.tasknum = {}
		for index=1, #taskNum do
			local num = {}
			local dex = taskNum[index].v1
			local times = taskNum[index].v2
			self.tasknum[dex] = times
		end
		self.worshipCount = data.count -- 可许愿次数
		self.task = ActivityCenterMO.getWorshipTaskById(awardid, self.numDays)
		self.awardIcon = json.decode(self.task.icon)

		--gdump(self.task , "self.task =========== ")

		-- UI
		self:pagesForTask(container)
		self.isTask = true
	end)
end



-- [[  =====  女神界面 ui , 数据 ======  ]]
function ActivityWorship:pagesForGod(container)
	
	local times , goddata = self:getTimesWithGodData()
	
	-- 活动时间 提示
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20,container:getContentSize().height - bg:getContentSize().height / 2 - 10)
	local title = ui.newTTFLabel({text = CommonText[964], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	
	--self.m_activity.beginTime - self.m_activity.endTime
	--local showtime = os.date("%Y/%m/%d",self.m_activity.beginTime) .. "-" .. os.date("%Y/%m/%d",self.m_activity.endTime)
	--print("showtime:" .. showtime)
	-- 时间
	local timeLabGod = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLabGod:setAnchorPoint(cc.p(0, 0.5))
	timeLabGod:setPosition(20, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.timeLabGod = timeLabGod

   --活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			local firstdata = ActivityCenterMO.getWorshipGodById(1)
			local DetailTextGod = DetailText.worshipGod
			for index=1, #DetailTextGod do
				local texttable = DetailTextGod[index]
				for k,v in pairs(texttable) do
					local outtext = string.gsub(v.content,"X",firstdata.num)
					if outtext then
						v.content = outtext
					end
				end
			end
			DetailTextDialog.new(DetailTextGod):push()
		end):addTo(container)
	detailBtn:setAnchorPoint(1,0.5)
	detailBtn:setPosition(container:getContentSize().width - 20,container:getContentSize().height - detailBtn:getContentSize().height / 2 - 10)

	--活动说明
	local descLab = ui.newTTFLabel({text = CommonText[20199], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1],align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(530, 70)}):addTo(container)
	descLab:setAnchorPoint(cc.p(0, 0.5))
	descLab:setPosition(20, timeLabGod:getPositionY() - timeLabGod:getContentSize().height / 2 - descLab:getContentSize().height / 2 - 10)

	local pic = display.newSprite(IMAGE_COMMON .. 'worship_god.jpg'):addTo(container)
	pic:setAnchorPoint(0.5,1)
	pic:setPosition(container:getContentSize().width / 2, descLab:getPositionY() + 10)

	
	--花费XXX金币拜女神，获得XXX%-XXX%金币返还
	local pictips = ui.newTTFLabel({text = goddata.desc, font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1],align = ui.TEXT_ALIGN_CENTER,valign = ui.TEXT_VALIGN_CENTER,dimensions = cc.size(530, 70)}):addTo(container)
   	pictips:setAnchorPoint(0.5,0.5)
   	pictips:setPosition(container:getContentSize().width / 2 , pic:getPositionY() - pic:getContentSize().height - 15)
   	self.pictips = pictips

	-- 金币记录
	local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local coinRecordBtn = MenuButton.new(normal, selected, nil,handler(self,self.coinRecordCallback)):addTo(container)
	coinRecordBtn:setAnchorPoint(0.5,0.5)
	coinRecordBtn:setPosition(container:getContentSize().width * 0.25 , 30)
	coinRecordBtn:setLabel(CommonText[20203])

	-- 拜神
	local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local doWorshipgodBtn = MenuButton.new(normal, selected, disabled,handler(self,self.doWorshipGodCallback)):addTo(container)
	doWorshipgodBtn:setAnchorPoint(0.5,0.5)
	doWorshipgodBtn:setPosition(container:getContentSize().width * 0.75 , 30)
	doWorshipgodBtn:setLabel(CommonText[20202][times])
	doWorshipgodBtn:setEnabled(self.worshiptimes > 0)
	self.doWorshipgodBtn = doWorshipgodBtn

	local timesText = CommonText[20201] .. tostring(self.worshiptimes) --act_data.num
	local lastWorshipTimes = ui.newTTFLabel({text = timesText, font = G_FONT, size = FONT_SIZE_TINY, 
   	color = COLOR[1],align = ui.TEXT_ALIGN_CENTER,valign = ui.TEXT_VALIGN_BOTTOM,dimensions = cc.size(530, 70)}):addTo(container)
	lastWorshipTimes:setAnchorPoint(0.5,1)
	lastWorshipTimes:setPosition(doWorshipgodBtn:getPositionX() , doWorshipgodBtn:getContentSize().height + lastWorshipTimes:getContentSize().height / 2 + 10)
	self.lastWorshipTimes = lastWorshipTimes
end


-- [[  ========  许愿任务界面   =========  ]]
function ActivityWorship:pagesForTask(container)

	-- 活动时间 提示
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20,container:getContentSize().height - bg:getContentSize().height / 2 - 10)
	local title = ui.newTTFLabel({text = CommonText[964], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
		
	-- 时间
	local timeLabTask = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLabTask:setAnchorPoint(cc.p(0, 0.5))
	timeLabTask:setPosition(20, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.timeLabTask = timeLabTask

	--活动说明
	local descLab = ui.newTTFLabel({text = CommonText[20205], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1],align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(530, 70)}):addTo(container)
	descLab:setAnchorPoint(cc.p(0, 0.5))
	descLab:setPosition(20, timeLabTask:getPositionY() - timeLabTask:getContentSize().height / 2 - descLab:getContentSize().height / 2 - 10)

	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			local content = DetailText.worshipTask
			DetailTextDialog.new(content):push()
		end):addTo(container)
	detailBtn:setAnchorPoint(1,0.5)
	detailBtn:setPosition(container:getContentSize().width - 20,container:getContentSize().height - detailBtn:getContentSize().height / 2 - 10)


	-- 许愿 按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local taskbtn = MenuButton.new(normal, selected, disabled,handler(self,self.doWorshipTaskCallback)):addTo(container,2)
	taskbtn:setAnchorPoint(0.5,0.5)
	taskbtn:setPosition(container:getContentSize().width / 2, 25)
	taskbtn:setLabel(CommonText[20208])
	taskbtn:setEnabled(self.worshipCount > 0)
	self.taskbtn = taskbtn

	-- 许愿 次数
	local times = CommonText[20206] .. tostring(self.worshipCount)
	local timesLab = ui.newTTFLabel({text = times, font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1],align = ui.TEXT_ALIGN_CENTER,valign = ui.TEXT_VALIGN_CENTER,dimensions = cc.size(530, 70)}):addTo(container)
   	timesLab:setAnchorPoint(0.5,0.5)
   	timesLab:setPosition(container:getContentSize().width * 0.2 , taskbtn:getPositionY())
   	self.timesLab = timesLab

   	local bottomLab = display.newSprite(IMAGE_COMMON .. "info_bg_raffle.jpg"):addTo(container)
	bottomLab:setAnchorPoint(0.5,0)
	bottomLab:setPosition( container:getContentSize().width / 2, 40)
	self:awardShow(bottomLab)

	local bottomLabText = ui.newTTFLabel({text = CommonText[20207], font = G_FONT, size = FONT_SIZE_TINY, 
   	color = COLOR[1],align = ui.TEXT_ALIGN_CENTER,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(530, 70)}):addTo(bottomLab)
	bottomLabText:setAnchorPoint(0.5,1)
	bottomLabText:setPosition(bottomLab:getContentSize().width / 2 , bottomLab:getContentSize().height - 5)

	-- 任务列表
	local WorshipTask = require("app.view.ActivityWorshipTask")
	self.Rankview = WorshipTask.new(container:width() - 10, descLab:getPositionY() - bottomLab:getPositionY() - bottomLab:getContentSize().height, self.task, self.tasknum):addTo(container,2)
	self.Rankview:setAnchorPoint(0.5,1)
	self.Rankview:setPosition(container:getContentSize().width / 2, descLab:getPositionY())

end

--
function ActivityWorship:awardShow(container)
	-- 奖励平台
	--self.awardIcon
	local function mathdex( all, index, width)
		-- body
		local c = all + 1
		local q = c / 2
		local sw = width * 1.2
		local w = q * sw
		return index * sw - w
	end

	local size = #self.awardIcon
	for index=1, size do
		local data = self.awardIcon[index]
		--gdump(data , "======== " .. index)
		local kindtype = data[1]
		local iconid = data[2]
		local count = data[3]
		local awardshow = UiUtil.createItemView(kindtype,iconid,{count = count}):addTo(container)
		awardshow:setAnchorPoint(0.5,0.5)
		awardshow:setPosition( container:getContentSize().width / 2 + mathdex(size,index,awardshow:getContentSize().width), container:getContentSize().height / 2)
		UiUtil.createItemDetailButton(awardshow)
	end
end


-- [[  === 查看金币记录 ===  ]]
function ActivityWorship:coinRecordCallback(tag, sender)
	-- 金币记录
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityCoinRecordDialog").new():push()
end


-- [[  === 拜女神 ===   ]]
function ActivityWorship:doWorshipGodCallback(tag, sender)
	-- 拜神
	ManagerSound.playNormalButtonSound()

	-- VIP5 一下 不能玩
	if UserMO.vip_ < 5 then
		Toast.show(CommonText[20199])
		return
	end

	if UserMO.consumeConfirm then
		local times , act_data = self:getTimesWithGodData()
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[20212], act_data.price), function() self:doGodCallback() end):push()
	else
		self:doGodCallback()
	end

end


-- [[  ===  拜女神  二级界面  ===  ]]
function ActivityWorship:doGodCallback()
	ActivityCenterBO.doWorshipGodAct(function(data)

		local ldata = {}
		ldata.time = data.time
		ldata.value = data.proportion

		local ltimes , lact_data = self:getTimesWithGodData()

		local last_price = lact_data.price

		table.insert(ActivityCenterMO.worshipRecord , ldata)
		--ActivityCenterMO.worshipRecord

		local times , act_data = self:getTimesWithGodData()

		-- 拜女神次数
		self.worshiptimes = self.worshiptimes - 1
		if self.lastWorshipTimes then
			local timesText = CommonText[20201] .. self.worshiptimes
			self.lastWorshipTimes:setString(timesText)
		end

		if self.doWorshipgodBtn then
			self.doWorshipgodBtn:setEnabled(self.worshiptimes > 0)
			self.doWorshipgodBtn:setLabel(CommonText[20202][times])
		end

		if self.pictips then
			self.pictips:setString(act_data.desc)
		end

		local upgold = last_price * data.proportion * 0.01

		local award = {}
		local add = {}
		add.type = ITEM_KIND_COIN
		add.count = upgold
		add.detailed = true
		award[#award+1] = add
		local ret = CombatBO.addAwards(award)
		UiUtil.showAwards(ret)

		local coin = UserMO.getResource(ITEM_KIND_COIN)
		UserMO.updateResource(ITEM_KIND_COIN, coin - last_price)

	end)
end


-- [[  ====  许愿  ====  ]]
function ActivityWorship:doWorshipTaskCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

--[[
	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[20212], sender.data.price), function() self:doGodCallback() end):push()
	else
		self:doGodCallback()
	end
	]]

	-- 许愿
	ActivityCenterBO.doWorshipTaskAct(function (data)
		--[[
		repeated Award award = 1;  //  许愿奖励
		Award:
	    required int32 type = 1;
	    required int32 id = 2;
	    required int32 count = 3;
	    optional int32 keyId = 4;
	    repeated int32 param = 5;        //参数暂时：配件[强化等级,改造等级] 装备[等级]
		]]
		local award = PbProtocol.decodeArray(data["award"])
		gdump(award,"worship task ========== award")
		local ret = CombatBO.addAwards(award)
			UiUtil.showAwards(ret)

		self.worshipCount = self.worshipCount - 1
		if self.timesLab then
			local times = CommonText[20206] .. tostring(self.worshipCount)
			self.timesLab:setString(times)
		end

		if self.taskbtn then
			self.taskbtn:setEnabled(self.worshipCount > 0)
		end
	end)
end


-- 获得 拜女神 次数-数据
function ActivityWorship:getTimesWithGodData()
	local times = #ActivityCenterMO.worshipRecord + 1
	local act_data = ActivityCenterMO.getWorshipGodDataTimes(times)
	if not act_data then
		times = #ActivityCenterMO.worshipRecord
		act_data = ActivityCenterMO.getWorshipGodDataTimes(times)
	end
	return times , act_data
end



return ActivityWorship