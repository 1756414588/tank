--
-- Author: xiaoxing
-- Date: 2017-02-05 14:11:50
--
--------------------------------------------
local PRAY_CARD_1 = 10
local PRAY_CARD_2 = 11
local PRAY_CARD_3 = 12
local PRAY_CARD_4 = 13
local ActivityFestivalPage2 = class("ActivityFestivalPage2",function ()
	return display.newNode()
end)

function ActivityFestivalPage2:ctor(width,height,activity)
	self.activity = activity
	self:size(width,height)

	UiUtil.label(CommonText[1067],nil,nil,cc.size(480,0),ui.TEXT_ALIGN_LEFT)
		:addTo(self):align(display.LEFT_TOP, 20, height - 30)
	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityCelebrate3):push()
		end):addTo(self)
	detailBtn:setPosition(width - 50,height - 50)

	local bg = display.newSprite(IMAGE_COMMON..'info_bg_12.png'):addTo(self):align(display.LEFT_CENTER, 20, height - 105)
	local title = ui.newTTFLabel({text = CommonText[1068], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	--背景图
	-- local btm = display.newSprite(IMAGE_COMMON .. 'info_bg_rebate1.png'):addTo(self)  --祈福活动
	local btm = display.newSprite(IMAGE_COMMON .. 'info_bg_labour1.jpg'):addTo(self)   --五一劳动活动
		:align(display.CENTER_TOP, width/2, height - 280)
	self.btm = btm
	ActivityCenterBO.getActHilarityPrayAction(function()
		self:updateInfo()
	end)

end
function ActivityFestivalPage2:updateInfo()
	self.btm:removeAllChildren()
	self.data = ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL].info
	local list = {
		PRAY_CARD_1,
		PRAY_CARD_2,
		PRAY_CARD_3,
		PRAY_CARD_4
	}
	for k,v in ipairs(list) do
		local tx,ty = 120 + (k-1)*130,self.btm:height() + 90
		local count = ActivityCenterBO.prop_[v] and ActivityCenterBO.prop_[v].count or 0
		local t = UiUtil.createItemView(ITEM_KIND_CHAR, v, {count = count}):addTo(self.btm):pos(tx,ty)
		UiUtil.createItemDetailButton(t)
		local propDB = UserMO.getResourceData(ITEM_KIND_CHAR, v)
		UiUtil.label(propDB.name, nil, COLOR[propDB.quality or 1]):addTo(self.btm):pos(t:x(),t:y()-68)
	end
	self:showInfo()
end

--下面的蜡烛什么的
function ActivityFestivalPage2:showInfo()
	-- self.btm:removeAllChildren()
	local x,y,ex,ey = 110,290,200,240
	local posing = {}
	if table.isexist(self.data,"index") then
		for k,v in ipairs(self.data.index) do
			posing[v] = self.data.time[k] + PropMO.queryActPropById(self.data.propId[k]).value * 60 
		end
	end
	self.posing = posing
	for i=1,6 do
		local tx,ty = x + (i-1)%3*ex,y - math.floor((i-1)/3)*ey
		-- local pic = "pray_icon_nomal.png"  --祈福活动
		local pic = "labour_icon_nomal.png"    --五一劳动活动

		local state = 0
		local time = posing[i]
		if time and time > ManagerTimer.getTime() then 
			-- pic = "pray_icon_ing.png"    --祈福活动
			pic = "labour_icon_ing.png"    --五一劳动活动
			local t = UiUtil.label(CommonText[1069][2],nil,COLOR[1]):addTo(self.btm, 2):pos(tx,ty + 12)
			local date = ManagerTimer.time(time - ManagerTimer.getTime())
			local t = UiUtil.label(string.format("%02dh:%02dm:%02ds", date.hour,date.minute,date.second),nil,COLOR[2]):addTo(self.btm, 2):alignTo(t, 30, 1)
			t:performWithDelay(function()
						if time - ManagerTimer.getTime() <= 0 then
							self:updateInfo()
							return
						end
						local date = ManagerTimer.time(time - ManagerTimer.getTime())
						t:setString(string.format("%02dh:%02dm:%02ds", date.hour,date.minute,date.second))
					end, 1, 1)
			state = 1
		elseif not time then
			state = -1
			local t = UiUtil.label(CommonText[1069][1]):addTo(self.btm,2):pos(tx,ty + 12)
		else
			-- pic = "icon_rebate_1.png"  --祈福活动
			pic = "labour_rebate_1.png"  --五一劳动活动
			local t = UiUtil.label(CommonText[1069][3],nil,COLOR[1]):addTo(self.btm,2):pos(tx,ty + 12)
		end
		local btn = ScaleButton.new(display.newSprite(IMAGE_COMMON.. pic), handler(self, self.doHandler))
			:addTo(self.btm,0,i):align(display.CENTER_BOTTOM, tx,ty)
		btn.state = state
	end
end

function ActivityFestivalPage2:doHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.state == -1 then
		if ManagerTimer.getTime() + 4*3600 >= self.activity.endTime then
			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(CommonText[906][3], function()
				require("app.dialog.ActivityPrayCardDialog").new(tag):push()
			end):push()
		else
			require("app.dialog.ActivityPrayCardDialog").new(tag):push()
		end
	elseif sender.state == 1 then
		local function gotoSpeed()
			ActivityCenterBO.speedActHilarityPrayAction(tag,function()
					local data = ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL].info
					for k,v in ipairs(data.index) do
						if v == tag then
							data.time[k] = ManagerTimer.getTime() - 24*60*60
							UiDirector.getTopUi():refreshUI()
							return
						end
					end
				end)
		end
		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			local coin = math.ceil((self.posing[tag] - ManagerTimer.getTime())/60)
			CoinConfirmDialog.new(string.format(CommonText[916], coin), gotoSpeed):push()
		else
			gotoSpeed()
		end
	else --领奖
		ActivityCenterBO.receiveActHilarityPrayAction(tag,function()
				for i = #self.data.index, 1, -1 do
					if self.data.index[i] == tag then
						table.remove(self.data.index, i)
						table.remove(self.data.propId, i)
						table.remove(self.data.time, i)
						self:updateInfo()
						return
					end
				end
			end)
	end
end

return ActivityFestivalPage2