--
-- Author: xiaoxing
-- Date: 2016-12-05 15:34:59
--
local ActivityStorehoursePage1 = class("ActivityStorehoursePage1",function ()
	return display.newNode()
end)

function ActivityStorehoursePage1:ctor(width,height,activity)
	self.activity = activity
	self:size(width,height)
	
	local t = display.newSprite(IMAGE_COMMON.."info_bg_12.png")
		:addTo(self):align(display.LEFT_CENTER, 40, height - 40)
	UiUtil.label(CommonText[940]):alignTo(t, 45)

	--概率公示
	local chance = ActivityCenterMO.getProbabilityTextById(self.activity.activityId, self.activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(self)
		chanceBtn:setPosition(450, height - 40)
		chanceBtn:setVisible(chance.open == 1)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.storehouse):push()
		end):addTo(self)
	detailBtn:setPosition(550, height - 55)

	self.bg = display.newSprite(IMAGE_COMMON .. "info_bg_29.jpg", 
		width / 2, height - 440):addTo(self)
	self.itemNode = display.newNode():size(self.bg:width(),self.bg:height()):addTo(self.bg,10)
	self.hideNode = display.newNode():size(self.bg:width(),self.bg:height()):addTo(self.bg,8)
	local mask = UiUtil.sprite9("info_bg_14.jpg",20,20,1,1,self.bg:width(),self.bg:height())
		:addTo(self.bg,9):center()
	mask:scaleTX(self.bg:width())
	mask:scaleTY(self.bg:height())
	mask:setOpacity(100)
	self.mask = mask
	nodeTouchEventProtocol(mask, function(event)  
            end, nil, true, true)

	local t = UiUtil.label(CommonText[883][2]):addTo(self.bg,10):align(display.LEFT_CENTER, 480, 455)
	self.left = UiUtil.label(0,nil,COLOR[2]):addTo(self.bg,10):rightTo(t)
	self.LotteryButtons = {}
	self:showItems()
	ActivityCenterBO.getPirateInfo(function(data,awardId)
			local list = {1,2,3}
			for k,v in ipairs(list) do
				local tx,ty = 140 + (k-1)*120,height - 120
				local item = json.decode(ActivityCenterMO.getStorehouseList(awardId,v).icon)
				local t = UiUtil.createItemView(item[1], item[2], {count = item[3]}):addTo(self):pos(tx,ty)
				UiUtil.createItemDetailButton(t)
			end
			local list = self:getList(data)
			self:showResult(list)
		end)
	-- self:showItems()
end

function ActivityStorehoursePage1:showItems()
	self.LotteryButtons = {}
	local middleX = self.bg:width() / 2
	local middleY = self.bg:height()/2 + 155
	local pos = {
				{middleX - 190,middleY - 30},
				{middleX,middleY - 30},
				{middleX + 190,middleY - 30},
				{middleX - 190,middleY - 170},
				{middleX,middleY - 170},
				{middleX + 190,middleY - 170},
				{middleX - 190,middleY - 310},
				{middleX,middleY - 310},
				{middleX + 190,middleY - 310}
			}
	for index=1,9 do
		local normal = display.newSprite(IMAGE_COMMON .. "lottery_result_bg2.png")
		local selected = display.newSprite(IMAGE_COMMON .. "lottery_result_bg2.png")
		local lotteryButton = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(self.bg)
		lotteryButton:setPosition(pos[index][1], pos[index][2])
		local buttonPic = display.newSprite(IMAGE_COMMON .. "lottery_treasure_normal_close.png",lotteryButton:getContentSize().width / 2,lotteryButton:getContentSize().height / 2):addTo(lotteryButton)
		lotteryButton.buttonPic = buttonPic
		local rewardView = display.newNode():addTo(lotteryButton)
		lotteryButton.rewardView = rewardView
		lotteryButton.pos = index
		lotteryButton.type = LotteryMO.LOTTERY_TYPE_TANBAO_1
		lotteryButton.need = LotteryMO.LOTTERY_TREASURE_NEED[1]
		self.LotteryButtons[index] = lotteryButton
	end
end

--显示操作
function ActivityStorehoursePage1:showOption()
	self.left:setString(self.data.count)
	local y = self.bg:height()/2 - self.bg:y() + 30
	if self.data.isReset then
		local t = UiUtil.button("btn_1_normal.png", "btn_1_selected.png", nil, handler(self, self.reset), CommonText[677][5])
			:addTo(self.itemNode):pos(self.itemNode:width()/2,y):scale(0.8)
		if self.data.oneLottery > 0 then
			self:priceBtn(1,handler(self, self.open),self.data.oneLottery):addTo(self.itemNode,0,1):leftTo(t):scale(0.8)
		end
		if self.data.allLottery > 0 then
			self:priceBtn(2,handler(self, self.open),self.data.allLottery):addTo(self.itemNode,0,2):rightTo(t):scale(0.8)
		end
	else
		if self.data.oneLottery > 0 then
			self:priceBtn(1,handler(self, self.open),self.data.oneLottery):addTo(self.itemNode,0,1):pos(self.itemNode:width()/2,y):scale(0.8)
		end
	end
end

function ActivityStorehoursePage1:getList(data)
	self.data = data
	local list = PbProtocol.decodeArray(data.grids)
	local grids = {}
	for k,v in ipairs(list) do
		local temp = PbProtocol.decodeRecord(v.gridData)
		grids[temp.grid] = temp
		grids[temp.grid].has = v.has
	end
	return grids
end

function ActivityStorehoursePage1:reset(tag,sender)	
	ManagerSound.playNormalButtonSound()
	if self.data.count > 0 then
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[20178], function()
			ActivityCenterBO.resetPirate(function(data)
					local list = self:getList(data)
					self:showResult(list)
				end)
		end):push()
		return
	end
	ActivityCenterBO.resetPirate(function(data)
			local list = self:getList(data)
			self:showResult(list)
		end)
end

function ActivityStorehoursePage1:open(tag,sender)	
	ManagerSound.playNormalButtonSound()
	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[20162][3],sender.price), function()
				ActivityCenterBO.doPirate(tag,function(data,id)
						local list = self:getList(data)
						self:showResult(list)
					end)
			end):push()
	else
		ActivityCenterBO.doPirate(tag,function(data,id)
				local list = self:getList(data)
				self:showResult(list)
			end)
	end
end

function ActivityStorehoursePage1:priceBtn(kind,rhand,price)
	local btn = UiUtil.button("btn_5_normal.png", "btn_5_selected.png", nil, rhand, CommonText[20162][kind])
	local t = display.newSprite(IMAGE_COMMON.."icon_coin.png"):addTo(btn):pos(80,105)
	UiUtil.label(price,32):rightTo(t, 15)
	btn.price = price
	return btn
end

function ActivityStorehoursePage1:showResult(list)
	self.itemNode:removeAllChildren()
	self.hideNode:removeAllChildren()
	for i=1,9 do
		local temp = list[i]
		local btn = self.LotteryButtons[i]
		btn.buttonPic:removeSelf()
		if temp then
			local t = UiUtil.createItemView(temp.type, temp.id, {count = temp.count}):scale(0.7)
			local item = self.LotteryButtons[i]
			if temp.has then
				btn.buttonPic = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_open.png",btn:getContentSize().width / 2,btn:getContentSize().height / 2):addTo(btn)
				UiUtil.createItemDetailButton(t)
				t:addTo(self.itemNode):pos(item:x(),item:y())
			else
				btn.buttonPic = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_close.png",btn:getContentSize().width / 2,btn:getContentSize().height / 2):addTo(btn)
				t:addTo(self.hideNode):pos(item:x(),item:y())
			end
		else
			btn.buttonPic = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_close.png",btn:getContentSize().width / 2,btn:getContentSize().height / 2):addTo(btn)
		end
	end
	self:showOption()
end

return ActivityStorehoursePage1