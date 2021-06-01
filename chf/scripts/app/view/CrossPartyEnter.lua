--
-- Author: xiaoxing
-- Date: 2016-11-23 15:20:23
--
-------------------------------------------------------------------
local CrossPartyEnter = class("CrossPartyEnter", UiNode)

function CrossPartyEnter:ctor(uiEnter)
	uiEnter = uiEnter or UI_ENTER_NONE
	CrossPartyEnter.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
	local t = display.newSprite(IMAGE_COMMON.."cross_party_top.jpg")
		:addTo(self,2):align(display.CENTER_TOP, display.width/2, display.height-95)
	local l = UiUtil.label(CommonText[30063], 26):addTo(t):align(display.LEFT_CENTER, 20, 48)
	UiUtil.label(CommonText[30003][2], 26):addTo(t):alignTo(l, -28, 1)
	--详情
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.crossParty):push()
		end):addTo(t):pos(562,29)
	self.topBg = t
	local t = display.newSprite(IMAGE_COMMON .."info_bg_29.jpg")
		:addTo(self,2):align(display.CENTER_TOP, display.width/2, display.height-400)
	display.newSprite(IMAGE_COMMON .."cross_party.jpg"):addTo(t):center()
	UiUtil.button("btn_10_normal.png", "btn_10_selected.png", nil, handler(self, self.goArena),CommonText[30064]):addTo(t):pos(t:width()/2,130)
	self.centerBg = t

	CrossPartyBO.getState(function()
			CrossPartyBO.getRegInfo(handler(self, self.show))
		end)
end

function CrossPartyEnter:show()
	local l = UiUtil.label(CommonText[30004], FONT_SIZE_SMALL):addTo(self.topBg):align(display.LEFT_CENTER, 20, -50)
	UiUtil.label(CrossPartyMO.getTime(), FONT_SIZE_SMALL, COLOR[3]):addTo(self.topBg):rightTo(l)
	l = UiUtil.label(CommonText[30005][2], FONT_SIZE_SMALL):addTo(self.topBg):alignTo(l, -28, 1)
	UiUtil.label(CommonText[30057], FONT_SIZE_SMALL, COLOR[6]):addTo(self.topBg):rightTo(l)

	local t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, function()
			CrossPartyBO.getServerList(function()
					require("app.dialog.ServerList").new(CrossPartyBO.serverList_):push()
				end)
		end,CommonText[30000]):addTo(self.topBg):pos(540,-25):scale(0.8)
	UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self,self.score),CommonText[30009]):alignTo(t, -43, 1):scale(0.8)


	l = UiUtil.label(CommonText[30005][3]):addTo(self,10):align(display.LEFT_CENTER, 30, 110)
	self.sectionLabel = UiUtil.label("11"):addTo(self,10):rightTo(l)
	l = UiUtil.label(CommonText[30005][4]):addTo(self,10):align(display.LEFT_CENTER, 30, 90)
	self.timeLabel = UiUtil.label("00h:00m:00s"):addTo(self,10):rightTo(l)
	--底部功能
	local t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png",
		handler(self, self.apply),CommonText[20073][CrossPartyBO.myGroup_ and 2 or 1]):addTo(self,2):pos(98,40)
	self.applyBtn = t
	t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil,
		handler(self, self.setBattle),CommonText[12]):addTo(self,2):alignTo(t, 148)
	t = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png",
		handler(self, self.myParty),CommonText[489][4][5]):addTo(self,2):alignTo(t, 148)
	UiUtil.button("btn_11_normal.png", "btn_11_selected.png", nil,
		handler(self, self.allParty),CommonText[30058]):addTo(self,2):alignTo(t, 148)
	self:checkSection()
end

function CrossPartyEnter:checkSection()
	local str,endTime = CrossPartyMO.getState(CrossPartyBO.state_)
	self.applyBtn:setEnabled(CrossPartyMO.inApplyTime() and not CrossPartyBO.myGroup_)
	self.sectionLabel:setString(str)
	self.timeLabel:stopAllActions()
	self.timeLabel:setString("00h:00m:00s")
	if endTime then
		local function tick()
			local left = endTime - ManagerTimer.getTime()
			local str = string.format("%02dh:%02dm:%02ds",math.floor(left/3600),math.floor(left / 60) % 60,left%60)
			if left <= 0 then
				self.timeLabel:stopAllActions()
				self.timeLabel:setString("00h:00m:00s")
				CrossPartyBO.getState(handler(self, self.checkSection))
			else
				self.timeLabel:setString(str)
			end
		end
		tick()
		self.timeLabel:performWithDelay(tick, 1, 1)
	end
end

function CrossPartyEnter:apply(tag,sender)
	ManagerSound.playNormalButtonSound()
	CrossPartyBO.applyFight(function()
		self.applyBtn:setLabel(CommonText[20073][2])
		self.applyBtn:setEnabled(false)
	end)
end

function CrossPartyEnter:setBattle(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.CrossSettingView").new(2):push()
end

function CrossPartyEnter:score(tag,sender)
	ManagerSound.playNormalButtonSound()
	-- if not CrossPartyMO.canShop() then
	-- 	Toast.show(ErrorText.text816)
	-- 	return
	-- end
	require("app.view.CrossShop").new(ACTIVITY_CROSS_PARTY):push()
end

function CrossPartyEnter:myParty(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.CrossJoinParty").new(1):push()
end

function CrossPartyEnter:allParty(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.CrossJoinParty").new(2):push()
end

function CrossPartyEnter:goArena(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.CrossPartyView").new():push()
end

function CrossPartyEnter:onEnter()
	CrossPartyEnter.super.onEnter(self)
	self:setTitle(CommonText[20148][2])
end

return CrossPartyEnter