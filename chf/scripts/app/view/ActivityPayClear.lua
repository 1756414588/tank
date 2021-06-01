--
-- Author: xiaoxing
-- Date: 2017-03-02 13:51:40
-- 清盘计划

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local ActivityPayClear = class("ActivityPayClear", UiNode)

function ActivityPayClear:ctor(activity)
	ActivityPayClear.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityPayClear:onEnter()
	ActivityPayClear.super.onEnter(self)

	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
	self.content = display.newNode():addTo(self:getBg()):size(self:getBg():width(),self:getBg():height())
	ActivityCenterBO.getOverRebateAct(function(data)
			self:showUI(data)
		end)

end

function ActivityPayClear:refreshUI(name)
	if name == "RechargeView" then
		self.content:removeAllChildren()
		self.m_timeLab = nil
		ActivityCenterBO.getOverRebateAct(function(data)
				self:showUI(data)
		end)
	end
end

function ActivityPayClear:showUI(data)
	local id = data.gambleId
	local payNum = data.payNum
	local hasIndex = rawget(data,"hasIndex") or {}
	local gb = ActivityCenterMO.getGambleById(id)
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "bar_gamble.jpg"):addTo(self.content)
	infoBg:setPosition(self.content:getContentSize().width / 2,self.content:getContentSize().height - infoBg:getContentSize().height)
	-- 活动时间
	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = cc.c3b(35,255,0)}):addTo(infoBg)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(20, 75)
	self.m_timeLab = timeLab

	--活动说明
	local infoTit = ui.newTTFLabel({text = CommonText[886][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(infoBg)
	infoTit:setAnchorPoint(cc.p(0, 0.5))
	infoTit:setPosition(20, 45)

	local infoLab = ui.newTTFLabel({text = string.format(CommonText[972],gb.topup), font = G_FONT, size = FONT_SIZE_SMALL, dimensions = cc.size(270, 60),
   	color = COLOR[1], align = ui.TEXT_ALIGN_LEFT}):addTo(infoBg)
	infoLab:setAnchorPoint(cc.p(0, 1))
	infoLab:setPosition(infoTit:getPositionX() + infoTit:getContentSize().width, 65)


	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			local text = clone(DetailText.payClear)
			text[1][1].content = string.format(text[1][1].content, gb.topup)
			table.insert(text, {{content = gb.unClean,color = COLOR[6]}})
			DetailTextDialog.new(text):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 70, 30)

	--内容背景
	local contentBg = display.newSprite(IMAGE_COMMON .. "info_bg_gamble.jpg"):addTo(self.content)
	contentBg:setPosition(self.content:getContentSize().width / 2, self.content:getContentSize().height - 620)
	self.m_contentBg = contentBg
	--我的充值
	local rechargeTit = ui.newTTFLabel({text = CommonText[883][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(contentBg)
	rechargeTit:setAnchorPoint(cc.p(0, 0.5))
	rechargeTit:setPosition(20, 580)

	local rechargeValue = ui.newTTFLabel({text = payNum, font = G_FONT, size = FONT_SIZE_SMALL,
   	color = COLOR[2], align = ui.TEXT_ALIGN_LEFT}):addTo(contentBg)
	rechargeValue:setAnchorPoint(cc.p(0, 0.5))
	rechargeValue:setPosition(rechargeTit:getPositionX() + rechargeTit:getContentSize().width, rechargeTit:getPositionY())
	
	--剩余次数
	local countTit = ui.newTTFLabel({text = CommonText[883][2], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(contentBg)
	countTit:setAnchorPoint(cc.p(0, 0.5))
	countTit:setPosition(250, 580)
	local count = math.floor(payNum / gb.topup)
	count = count > 10 and 10 or count
	local countValue = ui.newTTFLabel({text = count - #hasIndex, font = G_FONT, size = FONT_SIZE_SMALL,
   	color = COLOR[2], align = ui.TEXT_ALIGN_LEFT}):addTo(contentBg)
	countValue:setAnchorPoint(cc.p(0, 0.5))
	countValue:setPosition(countTit:getPositionX() + countTit:getContentSize().width, countTit:getPositionY())
	self.m_countValue = countValue
	self.m_countValue.count = count - #hasIndex

	local l = UiUtil.label(CommonText[10070]):alignTo(countTit, 210)
	self.hasCount = UiUtil.label(#hasIndex .."/10", nil, COLOR[2]):rightTo(l)
	self.hasCount.count = #hasIndex

	--前往充值按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, handler(self,self.rechargeHandler)):addTo(self.content)
	rechargeBtn:setPosition(self.content:getContentSize().width / 2, 40)
	rechargeBtn:setLabel(CommonText[757][2])

	--结果效果
	local resultPic = display.newSprite(IMAGE_COMMON .. "gamble_go_result.png"):addTo(contentBg,100)
	resultPic:setPosition(306,305)
	resultPic:setAnchorPoint(cc.p(0.5,0))
	resultPic:setVisible(false)
	self.m_resultPic = resultPic

	--箭头
	local arrowPic = display.newSprite(IMAGE_COMMON .. "arrow_gamble_go.png"):addTo(contentBg,101)
	arrowPic:setPosition(self.m_contentBg:getContentSize().width / 2, self.m_contentBg:getContentSize().height / 2)
	arrowPic:setAnchorPoint(cc.p(0.5,0.5))
	self.m_arrowPic = arrowPic

	--抽奖按钮
	local sprite = display.newSprite(IMAGE_COMMON .. "btn_gamble_go.png")
	local goBtn = ScaleButton.new(sprite, handler(self, self.lotteryhandler)):addTo(contentBg,102)
	goBtn:setPosition(self.m_contentBg:getContentSize().width / 2, self.m_contentBg:getContentSize().height / 2)
	goBtn:setAnchorPoint(cc.p(0.5,0.5))

	self:updateUI(gb,hasIndex)
end

function ActivityPayClear:rechargeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- require("app.view.RechargeView").new():push()
	RechargeBO.openRechargeView()
end

function ActivityPayClear:updateUI(gb,hasIndex)

	local has = {}
	for k,v in ipairs(hasIndex) do
		has[v] = 1
	end
	local awards = json.decode(gb.awardList)
	gdump(awards,"ActivityPayClear .. awards===")
	if self.m_awardUI then self.m_contentBg:removeChild(self.m_awardUI, true) end
	self.m_awardUI = nil
	local awardUI = display.newNode():addTo(self.m_contentBg)
	self.m_awardUI = awardUI

	self.awards = {}
	local r = 190
	local _r = r - 50
	for index= #awards , 1 , -1 do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award[1], award[2])
		UiUtil.createItemDetailButton(itemView)

		if has[index] then
			display.newSprite(IMAGE_COMMON.."icon_gou.png"):addTo(itemView):center():scale(1.3)
		end
		
		-- local strLabel = ui.newTTFLabelWithOutline({text = "x" .. award.count, outlineWidth = 1, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[99], algin = ui.TEXT_ALIGN_CENTER})
		local strLabel = ui.newBMFontLabel({text = "x" .. award[3], font = "fnt/num_8.fnt", align = ui.TEXT_ALIGN_CENTER})--:addTo(self)
		strLabel:setAnchorPoint(cc.p(0.5, 0.5))

		local rads = 36 * (index - 1) + 36

		local rad = (index - 1) * (-36) + 18 + 36
		local x =	math.cos(math.rad(rad)) * r + self.m_contentBg:width() * 0.5
		local y =	math.sin(math.rad(rad)) * r +  self.m_contentBg:height() * 0.5

		itemView:addChild(strLabel)
		strLabel:setPosition(itemView:width() * 0.5 , -28)

		itemView:setRotation(rads)
		itemView:setScale(0.65)
		itemView:setPosition(x,y)
		self.m_awardUI:addChild(itemView)
		self.awards[index] = itemView
	end

end

function ActivityPayClear:lotteryhandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	--判断次数
	if self.hasCount.count >= #self.awards then
		Toast.show(CommonText[10071])
		return
	end
	if self.m_countValue.count <= 0 then
		Toast.show(CommonText[884])
		return
	end

	function doLottery()
		ActivityCenterBO.doOverRebateAct(function(index,awards)
				self.m_countValue:setString(self.m_countValue.count - 1)
				self.m_countValue.count = self.m_countValue.count - 1
				self.hasCount:setString((self.hasCount.count + 1) .."/10")
				self.hasCount.count = self.hasCount.count + 1
				self:showResultEffect(index,awards)
			end,cost)		
	end 

	doLottery()
end

function ActivityPayClear:showResultEffect(resultIdx,awards)
	if resultIdx and resultIdx > 0 then
		--黑色遮罩
		local rect = CCRectMake(0, 0, GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT)
		local bgMask = CCSprite:create("image/common/bg_ui.jpg", rect)
		bgMask:setCascadeBoundingBox(rect)
		bgMask:setColor(ccc3(0, 0, 0))
		bgMask:setOpacity(0)
		bgMask:setPosition(GAME_SIZE_WIDTH / 2, GAME_SIZE_HEIGHT / 2)
		self:addChild(bgMask,199)
		self.bgMask = bgMask

		nodeTouchEventProtocol(bgMask, function(event)  
                end, nil, true, true)
		self.m_resultPic:setVisible(false)
		self.m_arrowPic:setRotation(0);
		self.m_arrowPic:runAction(transition.sequence({
			cc.RotateBy:create(1,360 * 4),
			cc.RotateBy:create(0.1,120),
			cc.RotateBy:create(0.2,120),
			cc.RotateBy:create(0.3,120),
			cc.RotateBy:create(0.2 * resultIdx,360 * resultIdx / #self.awards),
			cc.CallFunc:create(function()	
				if self.bgMask then self:removeChild(self.bgMask, true) end
				self.m_resultPic:setRotation(360 * resultIdx / #self.awards)
				self.m_resultPic:setVisible(true)
				display.newSprite(IMAGE_COMMON.."icon_gou.png"):addTo(self.awards[resultIdx]):center():scale(1.3)
				-- --获得奖励
				if awards then
					 --加入背包
					local ret = CombatBO.addAwards(awards)
					UiUtil.showAwards(ret)
				end
			end)}))
	end
end

function ActivityPayClear:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[871])
	end
end

function ActivityPayClear:onExit()
	ActivityPayClear.super.onExit(self)
end

return ActivityPayClear


