--
-- Author: gf
-- Date: 2015-11-06 12:25:33
-- 充值

local RechargeTableView = class("RechargeTableView", TableView)

RechargeTableView.VIEW_FOR_CASHBACK = 1
RechargeTableView.VIEW_FOR_CASHBACK_NEW = 2

function RechargeTableView:ctor(size, viewFor)
	RechargeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 100)
	self.m_viewFor = viewFor
end

function RechargeTableView:onEnter()
	RechargeTableView.super.onEnter(self)
	-- self.m_updateHandler = Notify.register(LOCAL_SIGN_UPDATE_EVENT, handler(self, self.onSignUpdate))
end

function RechargeTableView:numberOfCells()
	return #RechargeMO.rechargeList
end

function RechargeTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RechargeTableView:createCellAtIndex(cell, index)
	RechargeTableView.super.createCellAtIndex(self, cell, index)

	local recharge = RechargeMO.rechargeList[index]

	--充
	local pic = display.newSprite(IMAGE_COMMON .. "recharge_r.png"):addTo(cell)
	pic:setPosition(40, self.m_cellSize.height / 2)
	--充值金币
	local label = ui.newBMFontLabel({text = "", font = "fnt/num_3.fnt"}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	label:setString(recharge.topup)
	label:setPosition(80, self.m_cellSize.height / 2 + 4)

	local coinPic = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(cell)
	coinPic:setPosition(210, self.m_cellSize.height / 2 - 3)

	--送
	local pic = display.newSprite(IMAGE_COMMON .. "recharge_g.png"):addTo(cell)
	pic:setPosition(260, self.m_cellSize.height / 2)

	--返还金币
	local label = ui.newBMFontLabel({text = "", font = "fnt/num_3.fnt"}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	label:setString(math.floor(recharge.topup * recharge.extraGold / 1000))
	label:setPosition(290, self.m_cellSize.height / 2 + 4)

	local coinPic = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(cell)
	coinPic:setPosition(400, self.m_cellSize.height / 2 - 3)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(cell, 2)
    line:setPreferredSize(cc.size(self.m_cellSize.width - 6, line:getContentSize().height))
    line:setPosition(self.m_cellSize.width / 2, line:getContentSize().height / 2)

    --实惠
    local boonPic = display.newSprite(IMAGE_COMMON .. "recharge_boon.png"):addTo(cell)
	boonPic:setPosition(self.m_cellSize.width - boonPic:getContentSize().width / 2 - 2, self.m_cellSize.height - boonPic:getContentSize().height / 2)
	boonPic:setVisible(recharge.banFlag == 1)

	--热卖
    local hotPic = display.newSprite(IMAGE_COMMON .. "recharge_hot.png"):addTo(cell)
	hotPic:setPosition(self.m_cellSize.width - hotPic:getContentSize().width / 2 - 2, self.m_cellSize.height - hotPic:getContentSize().height / 2)
	hotPic:setVisible(recharge.banFlag == 2)

	--充值按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local rechargeBtn = CellMenuButton.new(normal, selected, disabled, handler(self,self.rechargeHandler))
	rechargeBtn.recharge = recharge
	rechargeBtn:setLabel(recharge.topup / GAME_PAY_RATE .. RechargeBO.getCurrencyType())

	cell:addButton(rechargeBtn, self.m_cellSize.width - 100, self.m_cellSize.height / 2)

	-- 首冲活动状态，先判断首冲是否开启
	-- print("self.m_viewFor!!", self.m_viewFor)
	if ActivityBO.isActCashbackOpen() and self.m_viewFor == RechargeTableView.VIEW_FOR_CASHBACK then
		--送
		local btm = display.newSprite(IMAGE_COMMON .. "recharge_act_bg.png"):addTo(cell)
		btm:setPosition(btm:getContentSize().width / 2 + 5, self.m_cellSize.height - btm:getContentSize().height / 2 - 10)

		local discount = 0
		-- local showStr = nil
		local filename = nil
		if RechargeMO.getRechargeState(recharge.payId) == 1 then
			discount = 80
			-- showStr = string.format("充值该额度返利%d%%", discount)
			filename = "cashback_bottom_2.png"
		else
			discount = 120
			-- showStr = string.format("首次充值该额度返利%d%%", discount)
			filename = "cashback_bottom_1.png"
		end
		-- local labelAct = ui.newTTFLabel({text = showStr, font = G_FONT, align = ui.TEXT_ALIGN_CENTER, size = FONT_SIZE_SMALL}):addTo(btm)
		-- labelAct:setAnchorPoint(cc.p(0, 0.5))
		-- labelAct:setPosition(0, labelAct:getContentSize().height / 2)
		local cashbackBg = display.newSprite(IMAGE_COMMON .. filename):addTo(btm)
		cashbackBg:setAnchorPoint(cc.p(0, 0.5))
		cashbackBg:setPosition(0, cashbackBg:getContentSize().height / 2)

		local cashbackLabel = ui.newBMFontLabel({text = string.format("%d%%", discount), font = "fnt/cashback.fnt", x = 160, y = cashbackBg:y(), align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		cashbackLabel:setAnchorPoint(cc.p(0, 0.5))
		cashbackLabel:setPositionY(cashbackBg:y() - cashbackLabel:height()/2 + 8)
	elseif ActivityBO.isActCashbackNewOpen() and self.m_viewFor == RechargeTableView.VIEW_FOR_CASHBACK_NEW then
		-- print("we get here!!!!!!!!!!!!!!!!!!!!!!!!!")
		local btm = display.newSprite(IMAGE_COMMON .. "recharge_act_bg.png"):addTo(cell)
		btm:setPosition(btm:getContentSize().width / 2 + 5, self.m_cellSize.height - btm:getContentSize().height / 2 - 10)

		local discount = 0
		local filename = nil
		local showStr = nil
		-- local test = true
		local space_x = 0
		if RechargeMO.getRechargeNewState(recharge.payId) == 1 then
		-- if test then
			local discount_min, discount_max = ActivityMO.getActNewPay2RatioMinMax()
			filename = "cashback_bottom_2.png"
			showStr = string.format("%d%%-%d%%", discount_min, discount_max)
			space_x = 125
		else
			local discount = ActivityMO.getActNewPay2Ratio1(recharge.payId)
			filename = "cashback_bottom_1.png"
			showStr = string.format("%d%%", discount)
			space_x = 160
		end
		local cashbackBg = display.newSprite(IMAGE_COMMON .. filename):addTo(btm)
		cashbackBg:setAnchorPoint(cc.p(0, 0.5))
		cashbackBg:setPosition(0, cashbackBg:getContentSize().height / 2)

		local cashbackLabel = ui.newBMFontLabel({text =showStr, font = "fnt/cashback.fnt", x = space_x, y = cashbackBg:y(), align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		cashbackLabel:setAnchorPoint(cc.p(0, 0.5))
		cashbackLabel:setPositionY(cashbackBg:y() - cashbackLabel:height()/2 + 8)
	end
	return cell
end

function RechargeTableView:rechargeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if GameConfig.environment == "ssjj_client" then
		Toast.show(CommonText[64])
		return
	end

	-- 检查新充值活动是否开启 （能量灌注）
	if ActivityCenterMO.isCheckActivityNewenergy() then
		local function callback()
			self:doRecharge(sender)
			-- require("app.view.ChatView").new():push()
		end
		ActivityCenterBO.ActCumulativeRePay(callback,ActivityCenterMO.ActivityEnergyOfdata.day)
		return
	else
		self:doRecharge(sender)
	end
end

function RechargeTableView:doRecharge(sender)


	LoginBO.getRechargeBlack(function()
			if LoginBO.enableRecharge() == false then Toast.show(CommonText[739]) return end 
			local recharge = sender.recharge
			local notifyUrl = getPayCallBackUrl()
			local money = recharge.topup / GAME_PAY_RATE
			local coin = recharge.topup
			local arr = string.split(GameConfig.environment, "_")
			local channel = ""
			for i = 1, #arr-1 do
				channel = channel .. arr[i]
			end
			local paymentType = string.upper(channel)
			local productName = CommonText.item[1][1]
			local goodsCount = coin
			local productId = RechargeMO.getProductId(recharge.payId)
			local extraCoin = math.floor(recharge.topup * recharge.extraGold / 1000)
			-- if recharge.productId then
			-- 	productId = recharge.productId
			-- end

			-- RechargeBO.parseSynGold(nil, {gold = UserMO.coin_,addGold = coin,addTopup = coin,vip = 2})

			--草花IOS 帝国指挥官 支付特殊处理
			if GameConfig.environment == "chdgzhg_appstore" then 
				LoginBO.chPaytype(function(chPaytype)
			        --草花IOS 帝国指挥官 支付方式 1 苹果官方 2 第三方
			        local newNotifyUrl

			        if chPaytype == 1 then
			        	newNotifyUrl = notifyUrl .. "&paytype=1"
			        	ServiceBO.chIosPay(function(payResult)
							RechargeBO.rechargeCallBack(payResult)
							end, recharge.payId, newNotifyUrl, money, coin, GAME_PAY_CURRENCYTYPE, paymentType, productName, goodsCount, productId, extraCoin, chPaytype)
					else
						gprint("弹出支付方式=====")
						local dialog = require_ex("app.dialog.ChIosPayDialog").new(function(thirdPayType)
								if thirdPayType == 3 then
									newNotifyUrl = notifyUrl .. "&paytype=1"
									ServiceBO.chIosPay(function(payResult)
										RechargeBO.rechargeCallBack(payResult)
										end, recharge.payId, newNotifyUrl, money, coin, GAME_PAY_CURRENCYTYPE, paymentType, productName, goodsCount, productId, extraCoin, 1)
								elseif thirdPayType == 1 or thirdPayType == 2 then 
									newNotifyUrl = notifyUrl .. "&paytype=2"
									ServiceBO.chIosPay(function(payResult)
										RechargeBO.rechargeCallBack(payResult)
										end, recharge.payId, newNotifyUrl, money, coin, GAME_PAY_CURRENCYTYPE, paymentType, productName, goodsCount, productId, extraCoin, chPaytype,thirdPayType)
								end
							end):push()
			        end
			    end)
			else
				ServiceBO.pay(function(payResult)
					RechargeBO.rechargeCallBack(payResult)
					end, recharge.payId, notifyUrl, money, coin, GAME_PAY_CURRENCYTYPE, paymentType, productName, goodsCount, productId, extraCoin)
			end
			



		end)
end



function RechargeTableView:onExit()
	RechargeTableView.super.onExit(self)
	-- if self.m_updateHandler then
	-- 	Notify.unregister(self.m_updateHandler)
	-- 	self.m_updateHandler = nil
	-- end
end



return RechargeTableView