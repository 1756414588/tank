--
-- Author: mys
-- 体力购买

local BuyPawerTableView = class("BuyPawerTableView", TableView)
function BuyPawerTableView:ctor(size,data)
	BuyPawerTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 140)
	self.m_data = data
	self.cur = {10,5,1}
end

function BuyPawerTableView:numberOfCells()
	return #self.m_data
end

function BuyPawerTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function BuyPawerTableView:createCellAtIndex(cell, index)
	BuyPawerTableView.super.createCellAtIndex(self, cell, index)

	local _dataId = self.m_data[index]
	local _info = PropMO.queryPropById(_dataId)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width , self.m_cellSize.height - 10))
	bg:setPosition(self.m_cellSize.width * 0.5, self.m_cellSize.height * 0.5)

	local icon = UiUtil.createItemView(ITEM_KIND_PROP,_dataId):addTo(cell)
	icon:setScale(0.9)
	icon:setPosition(45 + icon:width() * 0.5 - 10, self.m_cellSize.height * 0.5)
	UiUtil.createItemDetailButton(icon)

	local name = ui.newTTFLabel({text = PropMO.getPropName(_dataId), font = G_FONT, color = COLOR[1], size = FONT_SIZE_LIMIT}):addTo(cell)
	name:setAnchorPoint(cc.p(0,0.5))
	name:setPosition(icon:x() + icon:width() * 0.5 + 15, self.m_cellSize.height - 27 - 5)

	local desc = ui.newTTFLabel({text = _info.desc, font = G_FONT, color = COLOR[1], size = FONT_SIZE_LIMIT}):addTo(cell)
	desc:setAnchorPoint(cc.p(0,0.5))
	desc:setPosition(name:x() , self.m_cellSize.height * 0.5 - 10)

	local numberLb =  ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, color = COLOR[1], size = FONT_SIZE_LIMIT}):addTo(cell)
	numberLb:setAnchorPoint(cc.p(0,0.5))
	numberLb:setPosition(self.m_cellSize.width - 120,name:y())

	local _count = UserMO.getResource(ITEM_KIND_PROP, _dataId)
	local numberLbStr = ui.newTTFLabel({text = _count, font = G_FONT, color = COLOR[3], size = FONT_SIZE_LIMIT}):addTo(cell)
	numberLbStr:setAnchorPoint(cc.p(0,0.5))
	numberLbStr:setPosition(numberLb:x() + numberLb:width(),numberLb:y())

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local useBtn = MenuButton.new(normal, selected, disabled, handler(self,self.useCallback)):addTo(cell)
	useBtn:setAnchorPoint(cc.p(0.5,0.5))
	useBtn:setPosition(self.m_cellSize.width - useBtn:width() * 0.5 * 0.8 - 30 , self.m_cellSize.height * 0.5 - 10)
	useBtn:setLabel(CommonText[86])
	useBtn:setScale(0.8)
	useBtn:setEnabled(_count > 0)
	useBtn.propid = _dataId
	useBtn.index = index

	return cell
end

function BuyPawerTableView:useCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local propid = sender.propid

	if self.cur[sender.index] + UserMO.power_ > POWER_MAX_HAVE then
		Toast.show(CommonText[20007])
		return
	end

	local function callback(data)
		self:reloadData()
		Toast.show(CommonText[1062][3] )

		Notify.notify("WIPE_COMBAT_POWER_HANDLER")
	end
	PropBO.asynUseProp(callback, propid , 1)
end


local Dialog = require("app.dialog.Dialog")
local BuyPawerDialog = class("BuyPawerDialog", Dialog)

function BuyPawerDialog:ctor()
	BuyPawerDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 850)})
	
end

function BuyPawerDialog:onEnter()
	BuyPawerDialog.super.onEnter(self)
	armature_add(IMAGE_ANIMATION .. "effect/nengliangcao.pvr.ccz", IMAGE_ANIMATION .. "effect/nengliangcao.plist", IMAGE_ANIMATION .. "effect/nengliangcao.xml")

	self:setTitle(CommonText[1098])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	
	local powerIcon = UiUtil.createItemView(ITEM_KIND_POWER):addTo(self:getBg())
	powerIcon:setPosition(61 + powerIcon:width() * 0.5, self:getBg():getContentSize().height - powerIcon:height() * 0.5 - 80)

	local powerInfo = UserMO.getResourceData(ITEM_KIND_POWER)
	local name = ui.newTTFLabel({text = powerInfo.name, font = G_FONT, 
		size = FONT_SIZE_MEDIUM, x = powerIcon:x() + powerIcon:width() * 0.5 + 30 - 15, y = powerIcon:y() + powerIcon:height() * 0.5 - 25}):addTo(self:getBg())

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_9.png", BAR_DIRECTION_HORIZONTAL, cc.size(240, 42), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(240 + 4, 31)}):addTo(self:getBg())
	bar:setPosition(powerIcon:x() + powerIcon:width() * 0.5 + bar:getContentSize().width / 2 + 15, powerIcon:y() - 15)
	self.powerBar = bar

	local armature = armature_create("nengliangcao", bar:getContentSize().width / 2 , bar:getContentSize().height / 2 ):addTo(bar , 5)
	armature:setScaleX(bar:width() / armature:width() * 1.35)
	armature:setScaleY(1.2)
	-- armature:setScaleY(armature:height() / bar:height())
	self.powerBar.armature = armature

	self.powerBar.showAni = -1

	local vip = UiUtil.createItemSprite(ITEM_KIND_VIP, UserMO.vip_):addTo(self:getBg())
	vip:setPosition(name:x() + name:width() * 0.5 + vip:width() * 0.5 + 10, name:y())
	vip:setScale(0.9)

	-- 能量购买按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
	local energyBuyBtn = MenuButton.new(normal, selected, disabled, handler(self,self.buyPower)):addTo(self:getBg())
	energyBuyBtn:setAnchorPoint(cc.p(0.5,0))
	energyBuyBtn:setPosition(bar:x() + bar:width() * 0.5 + energyBuyBtn:width() * 0.5 + 10, powerIcon:y() - powerIcon:width() * 0.5 + 10)
	self.energyBuyBtn = energyBuyBtn

	local leftTimesLb = ui.newTTFLabel({text = CommonText[10036] .. CommonText[119] .. CommonText[282].. ":", font = G_FONT, color = COLOR[1], size = FONT_SIZE_LIMIT}):addTo(self:getBg())
	leftTimesLb:setAnchorPoint(cc.p(0,0.5))
	leftTimesLb:setPosition(bar:x() - bar:width() * 0.25,bar:y() - bar:height() * 0.5- 10)

	self.buyPowerMax = VipMO.queryVip(UserMO.vip_).buyPower
	local leftTimes = ui.newTTFLabel({text = UserMO.powerBuy_ .."/" .. self.buyPowerMax, font = G_FONT, color = cc.c3b(18, 127, 3), size = FONT_SIZE_LIMIT}):addTo(self:getBg())
	leftTimes:setAnchorPoint(cc.p(0,0.5))
	leftTimes:setPosition(leftTimesLb:x() + leftTimesLb:width() ,leftTimesLb:y() )
	self.leftTimes = leftTimes

	if UserMO.powerBuy_ >= self.buyPowerMax then
		energyBuyBtn:setEnabled(false)
	end

	local data = {109, 118, 246}
	self.checkBoxList = {}

	local powerLb = ui.newTTFLabel({text = CommonText[1099][1], font = G_FONT, color = COLOR[1], size = FONT_SIZE_MEDIUM}):addTo(self:getBg())
	powerLb:setAnchorPoint(cc.p(0,0.5))
	powerLb:setPosition(50, powerIcon:y() - powerIcon:height() * 0.5 - 55)

	-- 1
	local uncheckedSprite = display.newSprite(IMAGE_COMMON .. "check0.jpg")
	local checkedSprite = display.newSprite(IMAGE_COMMON .. "check1.png")
	local checkBox1 = CheckBox.new(uncheckedSprite, checkedSprite, handler(self,self.onCheckedChanged)):addTo(self:getBg())
	checkBox1:setPosition(powerLb:x() + powerLb:width() + checkBox1:width() * 0.5 + 10, powerLb:y() )
	checkBox1.propid = data[1]
	checkBox1.consume = 10
	checkBox1.index = 1
	self.checkBoxList[1] = checkBox1

	local prop1 = PropMO.queryPropById(data[1])
	local power1 = ui.newTTFLabel({text = prop1.nameSuffix, font = G_FONT, color = COLOR[1], size = FONT_SIZE_SMALL}):addTo(self:getBg())
	power1:setAnchorPoint(cc.p(0,0.5))
	power1:setPosition(checkBox1:x() + checkBox1:width() * 0.5 + 5, checkBox1:y() )

	-- 5
	local uncheckedSprite = display.newSprite(IMAGE_COMMON .. "check0.jpg")
	local checkedSprite = display.newSprite(IMAGE_COMMON .. "check1.png")
	local checkBox2 = CheckBox.new(uncheckedSprite, checkedSprite, handler(self,self.onCheckedChanged)):addTo(self:getBg())
	checkBox2:setPosition(power1:x() + power1:width() + checkBox2:width() * 0.5 + 10, power1:y() )
	checkBox2.propid = data[2]
	checkBox2.consume = 5
	checkBox2.index = 2
	self.checkBoxList[2] = checkBox2

	local prop2 = PropMO.queryPropById(data[2])
	local power2 = ui.newTTFLabel({text = prop2.nameSuffix, font = G_FONT, color = COLOR[1], size = FONT_SIZE_SMALL}):addTo(self:getBg())
	power2:setAnchorPoint(cc.p(0,0.5))
	power2:setPosition(checkBox2:x() + checkBox2:width() * 0.5 + 5, checkBox2:y() )

	-- 10
	local uncheckedSprite = display.newSprite(IMAGE_COMMON .. "check0.jpg")
	local checkedSprite = display.newSprite(IMAGE_COMMON .. "check1.png")
	local checkBox3 = CheckBox.new(uncheckedSprite, checkedSprite, handler(self,self.onCheckedChanged)):addTo(self:getBg())
	checkBox3:setPosition(power2:x() + power2:width() + checkBox3:width() * 0.5 + 10, power2:y() )
	checkBox3.propid = data[3]
	checkBox3.consume = 1
	checkBox3.index = 3
	self.checkBoxList[3] = checkBox3

	local prop3 = PropMO.queryPropById(data[3])
	local power3 = ui.newTTFLabel({text = prop3.nameSuffix, font = G_FONT, color = COLOR[1], size = FONT_SIZE_SMALL}):addTo(self:getBg())
	power3:setAnchorPoint(cc.p(0,0.5))
	power3:setPosition(checkBox3:x() + checkBox3:width() * 0.5 + 5, checkBox3:y() )

	-- 一键
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local autoBtn = MenuButton.new(normal, selected, nil, handler(self, self.AutoUsePowerPorop)):addTo(self:getBg())
	autoBtn:setAnchorPoint(cc.p(0.5,0.5))
	autoBtn:setPosition(power3:x() + power3:width() + autoBtn:width() * 0.5, power3:y())
	autoBtn:setLabel(CommonText[1099][2])
	autoBtn:setScale(0.9)


	local listbg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	listbg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 70, powerLb:y() - 100 ))
	listbg:setAnchorPoint(cc.p(0,0))
	listbg:setPosition(35,45)
	

	local view = BuyPawerTableView.new(cc.size(listbg:width() - 20, listbg:height() - 20), data):addTo(listbg)
	view:setAnchorPoint(cc.p(0,0))
	view:setPosition(10,10)
	view:reloadData()
	self.view = view

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function BuyPawerDialog:update( ft )
	if self.powerBar then
		local count = UserMO.getResource(ITEM_KIND_POWER)
		 self.powerBar:setPercent(count / POWER_MAX_VALUE)

		if count < POWER_MAX_VALUE then -- 有CD时间
			 self.powerBar:setLabel(count .. "/" .. POWER_MAX_VALUE .. "(" .. UiUtil.strBuildTime(UserBO.getCycleTime(ITEM_KIND_POWER)) .. ")")
			if self.powerBar.armature and self.powerBar.showAni ~= 0 then
				self.powerBar.armature:getAnimation():playWithIndex(0)
				self.powerBar.showAni = 0
			end
		else
			 self.powerBar:setLabel(count .. "/" .. POWER_MAX_VALUE)
			 if self.powerBar.armature and self.powerBar.showAni ~= 1 then
				self.powerBar.armature:getAnimation():playWithIndex(1)
				self.powerBar.showAni = 1
			end
		end
	end
end

function BuyPawerDialog:onCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	local index = sender.index
	for k , v  in pairs(self.checkBoxList) do
		if index == v.index then
			v:setChecked(true)
		else
			v:setChecked(false)
		end
	end
end

function BuyPawerDialog:AutoUsePowerPorop(tag, sender)
	ManagerSound.playNormalButtonSound()
	local curProp = 0
	local addPower = 0
	for k , v  in pairs(self.checkBoxList) do
		if v:isChecked() then
			curProp = v.propid
			addPower = v.consume
			break
		end
	end

	-- 没有选择
	if curProp == 0 then 
		Toast.show(CommonText[1100][1])
		return 
	end

	local count = UserMO.getResource(ITEM_KIND_PROP, curProp)
	-- 没有该道具
	if count <= 0 then
		Toast.show( CommonText[1100][2] .. PropMO.getPropName(curProp).. "，" .. CommonText[1100][3] .. "！")
		return
	end

	-- 能量充沛
	if addPower + UserMO.power_ > POWER_MAX_HAVE then
		Toast.show(CommonText[20007])
		return
	end

	local consumeCount = 0
	for index = 1 , count do
		if (addPower * (consumeCount + 1))  + UserMO.power_ > POWER_MAX_HAVE then
			break
		end
		consumeCount = consumeCount + 1
	end
	-- print(UserMO.power_ .. "  " .. addPower .. " " .. consumeCount)

	local function callback( data )
		-- body
		Toast.show(CommonText[1100][4])
		self.view:reloadData()

		Notify.notify("WIPE_COMBAT_POWER_HANDLER")
	end
	PropBO.asynUseProp(callback, curProp ,consumeCount)
end

function BuyPawerDialog:buyPower(tag, sender)
	ManagerSound.playNormalButtonSound()

	if POWER_BUY_NUM + UserMO.power_ > POWER_MAX_HAVE then
		Toast.show(CommonText[20007])
		return
	end

	local coinCount = UserMO.getResource(ITEM_KIND_COIN)
	if coinCount < VipBO.getPowerBuyCoin() then
		require("app.dialog.CoinTipDialog").new():push()
		return
	end

	local function buyPowerCallback(data)
		Loading.getInstance():unshow()
		if UserMO.powerBuy_ >= self.buyPowerMax then
			self.energyBuyBtn:setEnabled(false)
		end
		self.leftTimes:setString(UserMO.powerBuy_ .."/" .. self.buyPowerMax)
		Toast.show(CommonText[119]..CommonText[1062][3])
	end

	local function gotoBuyPower()
		Loading.getInstance():show()
		UserBO.asynBuyPower(buyPowerCallback)
	end

	if UserMO.consumeConfirm then
		local resData = UserMO.getResourceData(ITEM_KIND_POWER)
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[112], VipBO.getPowerBuyCoin(), POWER_BUY_NUM, resData.name), function() gotoBuyPower() end, nil):push()
	else
		gotoBuyPower()
	end
end

function BuyPawerDialog:onExit()
	BuyPawerDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/nengliangcao.pvr.ccz", IMAGE_ANIMATION .. "effect/nengliangcao.plist", IMAGE_ANIMATION .. "effect/nengliangcao.xml")
end

return BuyPawerDialog