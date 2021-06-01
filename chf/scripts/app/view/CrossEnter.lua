--
-- Author: Xiaohang
-- Date: 2016-05-17 14:17:03
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
	self:setTitle(CommonText[30002])

	local t = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil, handler(self, self.choose),CommonText[30012][1]):addTo(self:getBg(),0,1):pos(140,68)
	t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.choose),CommonText[30012][2]):addTo(self:getBg(),0,2):pos(self:getBg():width()-140,68)
end

function ApplyDialog:choose(tag,sender)
	-- if tag == 2 and UserMO.fightValue_ < CrossMO.peakCondition then
	-- 	Toast.show(CommonText[30001])
	-- 	return
	-- end
	CrossBO.applyFight(tag,function()
			self.rhand()
			self:pop()
		end)
end

-------------------------------------------------------------------
local CrossEnter = class("CrossEnter", UiNode)

function CrossEnter:ctor(uiEnter)
	uiEnter = uiEnter or UI_ENTER_NONE
	CrossEnter.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
	local t = display.newSprite(IMAGE_COMMON.."bar_general.jpg")
		:addTo(self,2):align(display.CENTER_TOP, display.width/2, display.height-95)
	local l = UiUtil.label(CommonText[30003][1], 26):addTo(t):align(display.LEFT_CENTER, 20, 48)
	UiUtil.label(CommonText[30003][2], 26):addTo(t):alignTo(l, -28, 1)
	--详情
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.crossInfo):push()
		end):addTo(t):pos(562,29)
	self.topBg = t
	local t = display.newSprite(IMAGE_COMMON .."info_bg_29.jpg")
		:addTo(self,2):align(display.CENTER_TOP, display.width/2, display.height-400)
	UiUtil.sprite9("btn_head_normal.png", 60, 90, 10, 10, 262, 360)
		:addTo(t):pos(155,290)
	display.newSprite(IMAGE_COMMON.."group1.jpg")
		:addTo(t):pos(155,295)
	UiUtil.button("btn_10_normal.png", "btn_10_selected.png", nil, handler(self, self.goArena),CommonText[30010][1]):addTo(t,0,1):pos(155,122)
	UiUtil.sprite9("btn_head_normal.png", 60, 90, 10, 10, 262, 360)
		:addTo(t):pos(460,290)
	display.newSprite(IMAGE_COMMON.."group2.jpg")
		:addTo(t):pos(460,295)
	local condition = UiUtil.label(CommonText[30007],nil,COLOR[2]):addTo(t):pos(435,177)
	UiUtil.label(UiUtil.strNumSimplify(CrossMO.peakCondition),nil,COLOR[6]):rightTo(condition)
	UiUtil.button("btn_1_normal.png", "btn_1_selected.png", nil, handler(self, self.goArena),CommonText[30010][2]):addTo(t,0,2):pos(460,122)
	self.centerBg = t

	CrossBO.getState(function()
			CrossBO.getServerList(function()
					CrossBO.getEnterInfo(handler(self, self.show))
				end)
		end)
end

function CrossEnter:show()
	local l = UiUtil.label(CommonText[30004], FONT_SIZE_SMALL):addTo(self.topBg):align(display.LEFT_CENTER, 20, -50)
	UiUtil.label(CrossMO.getTime(), FONT_SIZE_SMALL, COLOR[3]):addTo(self.topBg):rightTo(l)
	-- l = UiUtil.label(CommonText[30005][1], 24):addTo(self.topBg):alignTo(l, -28, 1)
	-- UiUtil.label(CrossMO.getServerList(), 24, COLOR[3]):addTo(self.topBg):rightTo(l)
	l = UiUtil.label(CommonText[30005][2], FONT_SIZE_SMALL):addTo(self.topBg):alignTo(l, -28, 1)
	UiUtil.label(CommonText[30006], FONT_SIZE_SMALL, COLOR[6]):addTo(self.topBg):rightTo(l)

	UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, function()
			CrossBO.getServerList(function()
					require("app.dialog.ServerList").new():push()
				end)
		end,CommonText[30000]):addTo(self.topBg):pos(540,-33)


	l = UiUtil.label(CommonText[30005][3]):addTo(self.centerBg):align(display.LEFT_CENTER, 12, 60)
	self.sectionLabel = UiUtil.label(""):addTo(self.centerBg):rightTo(l)
	l = UiUtil.label(CommonText[30005][4]):addTo(self.centerBg):align(display.LEFT_CENTER, 12, 40)
	self.timeLabel = UiUtil.label("00h:00m:00s"):addTo(self.centerBg):rightTo(l)

	--底部功能
	local t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png",
		handler(self, self.apply),CrossBO.myGroup_>0 and CommonText[798][3] or CommonText[20073][1]):addTo(self,2):pos(98,40)
	self.applyBtn = t
	t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil,
		handler(self, self.setBattle),CommonText[12]):addTo(self,2):alignTo(t, 148)
	t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png",
		handler(self, self.bet),CommonText[30008]):addTo(self,2):alignTo(t, 148)
	self.betBtn = t
	UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil,
		handler(self, self.score),CommonText[30009]):addTo(self,2):alignTo(t, 148)
	self:checkSection()
end

function CrossEnter:checkSection()
	local str,endTime = CrossMO.getState(CrossBO.state_)
	self.applyBtn:setEnabled(CrossBO.state_ == CrossMO.applyState)
	self.sectionLabel:setString(str)
	self.timeLabel:stopAllActions()
	self.timeLabel:setString("00h:00m:00s")
	self.betBtn:setEnabled(CrossMO.cantState())
	if endTime then
		local function tick()
			local left = endTime - ManagerTimer.getTime()
			local str = string.format("%02dh:%02dm:%02ds",math.floor(left/3600),math.floor(left / 60) % 60,left%60)
			if left <= 0 then
				self.timeLabel:stopAllActions()
				self.timeLabel:setString("00h:00m:00s")
				CrossBO.getState(handler(self, self.checkSection))
			else
				self.timeLabel:setString(str)
			end
		end
		tick()
		self.timeLabel:performWithDelay(tick, 1, 1)
	end
end

function CrossEnter:apply(tag,sender)
	ManagerSound.playNormalButtonSound()
	if CrossBO.myGroup_ > 0 then
		CrossBO.cancelApply(function()
				self.applyBtn:setLabel(CommonText[20073][1])
			end)
	else
		ApplyDialog.new(function()
				self.applyBtn:setLabel(CommonText[798][3])
			end):push()
	end
end

function CrossEnter:setBattle(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.CrossSettingView").new():push()
end

function CrossEnter:bet(tag,sender)
	ManagerSound.playNormalButtonSound()
	CrossBO.battleInfo(function(data)
			require("app.dialog.CrossBetInfo").new(data):push()
		end)
end

function CrossEnter:score(tag,sender)
	ManagerSound.playNormalButtonSound()
	-- if not CrossMO.canShop() then
	-- 	Toast.show(ErrorText.text816)
	-- 	return
	-- end
	require("app.view.CrossShop").new():push()
end

function CrossEnter:goArena(tag,sender)
	require("app.view.CrossView").new(nil,nil,tag):push()
end

function CrossEnter:onEnter()
	CrossEnter.super.onEnter(self)
	self:setTitle(CommonText[30011])
end

return CrossEnter