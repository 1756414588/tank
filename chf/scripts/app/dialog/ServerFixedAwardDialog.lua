--
--
-- ServerFixedAwardDialog
--
-- 开服定时奖励
--
local Dialog = require("app.dialog.Dialog")
local ServerFixedAwardDialog = class("ServerFixedAwardDialog",Dialog)


function ServerFixedAwardDialog:ctor()
	ServerFixedAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(580, 720)})
end

function ServerFixedAwardDialog:onEnter()
	ServerFixedAwardDialog.super.onEnter(self)

	self:setTitle(CommonText[1778])

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -2)
	bg:setPosition(self:getBg():width() * 0.5 , self:getBg():height() * 0.5)
	bg:setScaleY(self:getBg():height() / bg:height() * 0.95)

	local top = display.newSprite(IMAGE_COMMON .. "stroke_bg.jpg"):addTo(self:getBg() , -1)
	top:setPosition(self:getBg():width() * 0.5, self:getBg():height() - top:height() * 0.5 - 60)

	local activityTimeLb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = 0, y = 0, color = cc.c3b(163, 19, 19), align = ui.TEXT_ALIGN_RIGHT}):addTo(top)
	activityTimeLb:setAnchorPoint(cc.p(1,0.5))
	activityTimeLb:setPosition(top:width() - 10, top:height() - 30)
	self.m_activityTimeLb = activityTimeLb

	local desclbbg = display.newSprite(IMAGE_COMMON .. "info_bg_134.png"):addTo(self:getBg() , 1)
	desclbbg:setPosition(self:getBg():width() * 0.5, top:y() - top:height() * 0.5 - desclbbg:height() * 0.5 - 3)

	local desclb = ui.newTTFLabel({text = CommonText[1779], font = G_FONT, size = FONT_SIZE_TINY, 
		x = desclbbg:width() * 0.5, y = desclbbg:height() * 0.5, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(desclbbg)

	local awardNode = display.newSprite(IMAGE_COMMON .. "info_bg_133.png"):addTo(self:getBg() , -1)
	awardNode:setPosition(self:getBg():width() * 0.5 , desclbbg:y() - desclbbg:height() * 0.5 - awardNode:height() * 0.5 - 3)
	self.m_awardNode = awardNode

	local liveTimeLb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 0, y = 0, color = cc.c3b(33, 196, 52), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg() , 1)
	liveTimeLb:setPosition(self:getBg():width() * 0.5 ,awardNode:y() - awardNode:height() * 0.5 - 25)
	self.m_liveTimeLb = liveTimeLb


	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local awardBtn = MenuButton.new(normal, selected, disabled, handler(self, self.awardCallback)):addTo(self:getBg())
	awardBtn:setPosition(self:getBg():width() * 0.5, awardBtn:height() * 0.5 + 40)
	awardBtn:setLabel(CommonText[1780]) 
	self.m_awardBtn = awardBtn

	self:showContentAward()

	self.timerHandler_ = scheduler.scheduleGlobal(handler(self, self.update),1)

	self:update()
end

function ServerFixedAwardDialog:update()
	if self.m_liveTimeLb then
		local time = ActivityBO.ServerFixedUpdate()
		if time then
			if time == -1 then
				self.m_awardBtn:setEnabled(false)
				self.m_liveTimeLb:setString("")
			elseif time == -2 then
				self.m_awardBtn:setEnabled(true)
				self.m_liveTimeLb:setString("")
			elseif time == -3 then
				self.m_awardBtn:setEnabled(false)
				self.m_liveTimeLb:setString(CommonText[1783])
			else
				self.m_awardBtn:setEnabled(false)
				self.m_liveTimeLb:setString(CommonText[1782] .. ":" .. UiUtil.strBuildTime(time))
			end
		end
	end

	if self.m_activityTimeLb then
		local time = ActivityMO.actStroke.endTime - ActivityMO.actStroke.serverTime
		if time >= 0 then
			self.m_activityTimeLb:setString( CommonText[438] .. CommonText[393] ..":".. UiUtil.strBuildTime(time))
		else
			self.m_activityTimeLb:setString(CommonText[1781])
			self.m_awardBtn:setEnabled(false)
			if self.m_liveTimeLb then
				self.m_liveTimeLb:setString(CommonText[1781])
			end
		end
	end
end

function ServerFixedAwardDialog:showContentAward()
	-- dump(ActivityMO.actStroke,"==")
	local info = ActivityMO.getActStroke(ActivityMO.actStroke.actId , ActivityMO.actStroke.id + 1)
	
	if info then
		-- self.m_awardBtn:setEnabled(true)
		self.m_awardBtn.id = ActivityMO.actStroke.id + 1
	else
		-- self.m_awardBtn:setEnabled(false)
		info = ActivityMO.getActStroke(ActivityMO.actStroke.actId , ActivityMO.actStroke.id)
	end
	
	-- body
	if self.m_awardNode then
		self.m_awardNode:removeAllChildren()
	end

	local awards = json.decode(info.award)
	local size = #awards
	for index = 1, size do
		local award = awards[index]
		local kind = award[1]
		local id = award[2]
		local count = award[3]

		local view = UiUtil.createItemView(kind, id, {count = count}):addTo(self.m_awardNode)
		view:setPosition(self.m_awardNode:width() * 0.5 + CalculateX(size, index , view:width(), 1.2), self.m_awardNode:height() * 0.5 + 15 )
		UiUtil.createItemDetailButton(view)

		local nameinfo = UserMO.getResourceData(kind,id)
		local namelb = ui.newTTFLabel({text = nameinfo.name, font = G_FONT, size = FONT_SIZE_SMALL, x = view:width() * 0.5, y = -15, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(view )
	end

end



function ServerFixedAwardDialog:awardCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local id = sender.id
	local function parseResult(data)
		self:showContentAward()
		self:update()
	end

	ActivityBO.DrawActStrokeAward(parseResult, id)
end

function ServerFixedAwardDialog:onExit()
	ServerFixedAwardDialog.super.onExit(self)
	if self.timerHandler_ then
		scheduler.unscheduleGlobal(self.timerHandler_)
		self.timerHandler_ = nil
	end
end

return ServerFixedAwardDialog