--
-- Author: gf
-- Date: 2015-10-30 11:15:59
-- 机甲洪流 活动

local ConfirmDialog = require("app.dialog.ConfirmDialog")
local ActivityMechaView = class("ActivityMechaView", UiNode)

function ActivityMechaView:ctor(activity)
	ActivityMechaView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_activity = activity

	local activityContent = ActivityCenterMO.getActivityContentById(activity.activityId)
	self.activityContent = activityContent
	-- gdump(self.m_mail, "ActivityMechaView:ctor")
end

function ActivityMechaView:onEnter()
	ActivityMechaView.super.onEnter(self)
	self:hasCoinButton(true)
	armature_add("animation/effect/ui_mecha_btn_flash.pvr.ccz", "animation/effect/ui_mecha_btn_flash.plist", "animation/effect/ui_mecha_btn_flash.xml")
	armature_add("animation/effect/ui_mecha_btn_ligth.pvr.ccz", "animation/effect/ui_mecha_btn_ligth.plist", "animation/effect/ui_mecha_btn_ligth.xml")
	armature_add("animation/effect/ui_mecha_get.pvr.ccz", "animation/effect/ui_mecha_get.plist", "animation/effect/ui_mecha_get.xml")
	armature_add("animation/effect/ui_multiply_num.pvr.ccz", "animation/effect/ui_multiply_num.plist", "animation/effect/ui_multiply_num_2.xml")
	armature_add("animation/effect/ui_multiply_num.pvr.ccz", "animation/effect/ui_multiply_num.plist", "animation/effect/ui_multiply_num_3.xml")

	self:setTitle(self.m_activity.name)

	self:setUI()

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function ActivityMechaView:setUI()
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self:getBg():getContentSize().height - 130)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	--概率公示
	local chance = ActivityCenterMO.getProbabilityTextById(self.m_activity.activityId, self.m_activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(self:getBg())
		chanceBtn:setPosition(self:getBg():width() - 90, self:getBg():height() - 130)
		chanceBtn:setVisible(chance.open == 1)
	end

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(self:getBg())
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 20)
	self.m_timeLab = timeLab

	-- 活动说明
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, timeLab:getPositionY() - timeLab:getContentSize().height - 40)

	local title = ui.newTTFLabel({text = CommonText[727][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local desc1 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(510, 60)}):addTo(self:getBg())
	desc1:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 5)
	desc1:setAnchorPoint(cc.p(0, 1))
	desc1:setString(CommonText[722][1])

	local desc2 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 }):addTo(self:getBg())
	desc2:setPosition(40, desc1:getPositionY() - desc1:getContentSize().height - 5)
	desc2:setAnchorPoint(cc.p(0, 0.5))
	desc2:setString(CommonText[722][2])

	local desc3 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 }):addTo(self:getBg())
	desc3:setPosition(40, desc2:getPositionY() - desc2:getContentSize().height - 5)
	desc3:setAnchorPoint(cc.p(0, 0.5))
	desc3:setString(CommonText[722][3])


	--背景图
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_mecha.jpg'):addTo(self:getBg())
	bg:setPosition(self:getBg():getContentSize().width / 2, desc3:getPositionY() - bg:getContentSize().height / 2 - 20)

	self.m_bg = bg

	--左边机甲
	local leftBg = display.newNode():addTo(bg)
	leftBg:setContentSize(cc.size(310, 442))
	leftBg:setAnchorPoint(cc.p(0.5,0.5))
	-- leftBg:setPreferredSize(cc.size(280, 440))
	-- leftBg:setCapInsets(cc.rect(100, 200, 1, 1))
	leftBg:setPosition(bg:getContentSize().width / 2 - leftBg:getContentSize().width / 2, bg:getContentSize().height / 2)

	local leftTank = TankMO.queryTankById(self.activityContent.mechaSingle.tankId)
	--名称
	local tankName = ui.newTTFLabel({text = leftTank.name, font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = COLOR[12], 
		x = leftBg:getContentSize().width / 2, y = leftBg:getContentSize().height - 86}):addTo(leftBg)

	--载重
	local payloadTxt = ui.newTTFLabel({text = CommonText.attr[3] .. ":" .. leftTank.payload, font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[12], 
		x = leftBg:getContentSize().width / 2, y = leftBg:getContentSize().height - 130, align = ui.TEXT_ALIGN_CENTER}):addTo(leftBg)

	--坦克图片
	local normal = UiUtil.createItemSprite(ITEM_KIND_TANK, self.activityContent.mechaSingle.tankId)
	normal:setScale(1)
	local selected = UiUtil.createItemSprite(ITEM_KIND_TANK, self.activityContent.mechaSingle.tankId)
	selected:setScale(1)
	local tankPic = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); require("app.dialog.DetailTankDialog").new(self.activityContent.mechaSingle.tankId):push() end)
	tankPic:setPosition(leftBg:getContentSize().width / 2, leftBg:getContentSize().height / 2 + 20)
	leftBg:addChild(tankPic)


	--碎片图
	local chipPic = UiUtil.createItemView(ITEM_KIND_TANK, self.activityContent.mechaSingle.tankId)
	chipPic:setScale(0.4)
	chipPic:setPosition(100, 140)
	leftBg:addChild(chipPic)

	--碎片数量
	local leftChipCount = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[3], 
		x = 130, y = 140}):addTo(leftBg)
	leftChipCount:setAnchorPoint(cc.p(0,0.5))
	leftChipCount:setString(self.activityContent.mechaSingle.part .. "/")
	self.leftChipCount = leftChipCount

	--合成需要数量
	local leftChipMerge = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[2], 
		x = leftChipCount:getPositionX() + leftChipCount:getContentSize().width, y = 140}):addTo(leftBg)
	leftChipMerge:setAnchorPoint(cc.p(0,0.5))
	leftChipMerge:setString(ACTIVITY_MECHA_MERGE_COUNT)
	self.leftChipMerge = leftChipMerge


	--组装按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local leftMergeBtn = MenuButton.new(normal, selected, disabled, handler(self,self.mergeHandler)):addTo(bg)
	leftMergeBtn:setPosition(leftBg:getPositionX(), leftBg:getPositionY() - 145)
	leftMergeBtn:setLabel(CommonText[728])
	leftMergeBtn:setEnabled(self.activityContent.mechaSingle.part >= ACTIVITY_MECHA_MERGE_COUNT)
	leftMergeBtn.mecha = self.activityContent.mechaSingle
	self.leftMergeBtn = leftMergeBtn

	--组装按钮可组装动画
	local leftMergeBtnEffect = CCArmature:create("ui_mecha_btn_ligth")
    leftMergeBtnEffect:getAnimation():playWithIndex(0)
    leftMergeBtnEffect:connectMovementEventSignal(function(movementType, movementID) end)
    leftMergeBtnEffect:setPosition(leftBg:getPositionX(), leftBg:getPositionY() - 145)
    leftMergeBtnEffect:setVisible(self.activityContent.mechaSingle.part >= ACTIVITY_MECHA_MERGE_COUNT)
    bg:addChild(leftMergeBtnEffect)
    self.leftMergeBtnEffect = leftMergeBtnEffect



    local aura = {}
	if leftTank.aura then aura = json.decode(leftTank.aura) end
	-- 光环
	local haloTxt = ui.newTTFLabel({text = CommonText.attr[11] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 25, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(leftBg)
	haloTxt:setAnchorPoint(cc.p(0, 0.5))

	for index = 1, #aura do
		local buff = BuffMO.queryBuffById(aura[index])
		local desc = ui.newTTFLabel({text = buff.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = haloTxt:getPositionX() + haloTxt:getContentSize().width, y = haloTxt:getPositionY() - (index - 1) * 30, align = ui.TEXT_ALIGN_CENTER}):addTo(leftBg)
		desc:setAnchorPoint(cc.p(0, 0.5))
	end

	local rightBg = display.newNode():addTo(bg)
	rightBg:setContentSize(cc.size(310, 442))
	rightBg:setAnchorPoint(cc.p(0.5,0.5))
	-- rightBg:setPreferredSize(cc.size(280, 440))
	-- rightBg:setCapInsets(cc.rect(100, 200, 1, 1))
	rightBg:setPosition(bg:getContentSize().width / 2 + rightBg:getContentSize().width / 2, bg:getContentSize().height / 2)

	local rightTank = TankMO.queryTankById(self.activityContent.mechaTen.tankId)
	--名称
	local tankName = ui.newTTFLabel({text = rightTank.name, font = G_FONT, size = FONT_SIZE_SMALL,align = ui.TEXT_ALIGN_CENTER,color = COLOR[12], 
		x = rightBg:getContentSize().width / 2, y = rightBg:getContentSize().height - 86}):addTo(rightBg)

	--载重
	local payloadTxt = ui.newTTFLabel({text = CommonText.attr[3] .. ":" .. rightTank.payload, font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[12], 
		x = rightBg:getContentSize().width / 2, y = rightBg:getContentSize().height - 130, align = ui.TEXT_ALIGN_CENTER}):addTo(rightBg)
	
	--坦克图片
	local normal = UiUtil.createItemSprite(ITEM_KIND_TANK, self.activityContent.mechaTen.tankId)
	normal:setScale(1)
	local selected = UiUtil.createItemSprite(ITEM_KIND_TANK, self.activityContent.mechaTen.tankId)
	selected:setScale(1)
	local tankPic = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); require("app.dialog.DetailTankDialog").new(self.activityContent.mechaTen.tankId):push() end)
	tankPic:setPosition(rightBg:getContentSize().width / 2, rightBg:getContentSize().height / 2 + 20)
	rightBg:addChild(tankPic)


	--碎片图
	local chipPic = UiUtil.createItemView(ITEM_KIND_TANK, self.activityContent.mechaTen.tankId)
	chipPic:setScale(0.4)
	chipPic:setPosition(100, 140)
	rightBg:addChild(chipPic)

	--碎片数量
	local rightChipCount = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[3], 
		x = 130, y = 140}):addTo(rightBg)
	rightChipCount:setAnchorPoint(cc.p(0,0.5))
	rightChipCount:setString(self.activityContent.mechaTen.part .. "/")
	self.rightChipCount = rightChipCount

	--合成需要数量
	local rightChipMerge = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[2], 
		x = rightChipCount:getPositionX() + rightChipCount:getContentSize().width, y = 140}):addTo(rightBg)
	rightChipMerge:setAnchorPoint(cc.p(0,0.5))
	rightChipMerge:setString(ACTIVITY_MECHA_MERGE_COUNT)
	self.rightChipMerge = rightChipMerge


	--组装按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local rightMergeBtn = MenuButton.new(normal, selected, disabled, handler(self,self.mergeHandler)):addTo(bg)
	rightMergeBtn:setPosition(rightBg:getPositionX(), rightBg:getPositionY() - 145)
	rightMergeBtn:setLabel(CommonText[728])
	rightMergeBtn:setEnabled(self.activityContent.mechaTen.part >= ACTIVITY_MECHA_MERGE_COUNT)
	rightMergeBtn.mecha = self.activityContent.mechaTen
	self.rightMergeBtn = rightMergeBtn



	--组装按钮可组装动画
	local rightMergeBtnEffect = CCArmature:create("ui_mecha_btn_ligth")
    rightMergeBtnEffect:getAnimation():playWithIndex(0)
    rightMergeBtnEffect:connectMovementEventSignal(function(movementType, movementID) end)
    rightMergeBtnEffect:setPosition(rightBg:getPositionX(), rightBg:getPositionY() - 145)
    rightMergeBtnEffect:setVisible(self.activityContent.mechaTen.part >= ACTIVITY_MECHA_MERGE_COUNT)
    bg:addChild(rightMergeBtnEffect)
    self.rightMergeBtnEffect = rightMergeBtnEffect

    local aura = {}
	if rightTank.aura then aura = json.decode(rightTank.aura) end
	-- 光环
	local haloTxt = ui.newTTFLabel({text = CommonText.attr[11] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 25, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(rightBg)
	haloTxt:setAnchorPoint(cc.p(0, 0.5))

	for index = 1, #aura do
		local buff = BuffMO.queryBuffById(aura[index])
		local desc = ui.newTTFLabel({text = buff.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = haloTxt:getPositionX() + haloTxt:getContentSize().width, y = haloTxt:getPositionY() - (index - 1) * 30, align = ui.TEXT_ALIGN_CENTER}):addTo(rightBg)
		desc:setAnchorPoint(cc.p(0, 0.5))
	end


	--单抽按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local lotteryBtn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(bg)
	lotteryBtn:setPosition(leftBg:getPositionX(), -50)
	lotteryBtn:setLabel(string.format(CommonText[723],self.activityContent.mechaSingle.count),{size = FONT_SIZE_SMALL, y = lotteryBtn:getContentSize().height / 2 + 13})
	lotteryBtn.mecha = self.activityContent.mechaSingle
	lotteryBtn:setTag(1)
	self.lotteryBtn = lotteryBtn

	--判断免费次数
	local icon1,need1
	if self.activityContent.mechaSingle.free and self.activityContent.mechaSingle.free > 0 then
		need1 = ui.newTTFLabel({text = CommonText[729], font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[1],align = ui.TEXT_ALIGN_CENTER, 
		x = lotteryBtn:getContentSize().width / 2, y = lotteryBtn:getContentSize().height / 2 - 15}):addTo(lotteryBtn)
		self.need1 = need1
	else
		icon1 = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lotteryBtn:getContentSize().width / 2 - 30,lotteryBtn:getContentSize().height / 2 - 15):addTo(lotteryBtn)
		need1 = ui.newBMFontLabel({text = self.activityContent.mechaSingle.cost, font = "fnt/num_1.fnt"}):addTo(lotteryBtn)
		need1:setAnchorPoint(cc.p(0, 0.5))
		need1:setPosition(icon1:getPositionX() + icon1:getContentSize().width / 2 + 5,icon1:getPositionY() + 2)
		self.need1 = need1
		self.icon1 = icon1
	end

	--十连抽按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local lottery10Btn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(bg)
	lottery10Btn:setPosition(rightBg:getPositionX(), -50)
	lottery10Btn:setLabel(string.format(CommonText[723],self.activityContent.mechaTen.count),{size = FONT_SIZE_SMALL, y = lottery10Btn:getContentSize().height / 2 + 13})
	lottery10Btn.mecha = self.activityContent.mechaTen
	lottery10Btn:setTag(10)
	self.lottery10Btn = lottery10Btn

	local icon10 = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lottery10Btn:getContentSize().width / 2 - 30,lottery10Btn:getContentSize().height / 2 - 15):addTo(lottery10Btn)
	local need10 = ui.newBMFontLabel({text = self.activityContent.mechaTen.cost, font = "fnt/num_1.fnt"}):addTo(lottery10Btn)
	need10:setAnchorPoint(cc.p(0, 0.5))
	need10:setPosition(icon10:getPositionX() + icon10:getContentSize().width / 2 + 5,icon10:getPositionY() + 2)


	self:updateView()

end

function ActivityMechaView:mergeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local mecha = sender.mecha
	Loading.getInstance():show()
		ActivityCenterBO.asynAssembleMecha(function()
			Loading.getInstance():unshow()
			self:updateView()
			end, mecha)
end

function ActivityMechaView:lotteryHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.playeffectStatus == true then return end
	gdump(sender.mecha,"lotteryHandler .. ,MECHA")
	local mecha = sender.mecha
	local cost = 0

	if tag == 1 and self.activityContent.mechaSingle.free and self.activityContent.mechaSingle.free > 0 then
		cost = 0
	else
		cost = mecha.cost
	end

	--判断金币
	if cost > UserMO.getResource(ITEM_KIND_COIN) then
		require("app.dialog.CoinTipDialog").new():push()
		return 
	end

	function doLottery()
		self.playeffectStatus = true
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActMecha(function()
			Loading.getInstance():unshow()
			self.activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_MECHA)
			self:playLotteryEffect(tag, sender)
			end, mecha)
	end
	--二次消耗判断
	if cost > 0 then
		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[730],cost), function()
				doLottery()
				end):push()
		else
			doLottery()
		end
	else
		doLottery()
	end
end

function ActivityMechaView:playLotteryEffect(tag, sender)
	

	local posStart,posEndLeft,posEndRight
	posStart = {x = sender:getPositionX(), y = sender:getPositionY()}

	local leftX = self.leftMergeBtn:getPositionX()
	local leftY = self.leftMergeBtn:getPositionY()

	local rightX = self.rightMergeBtn:getPositionX()
	local rightY = self.rightMergeBtn:getPositionY()


	posEndLeft = {
		{x = leftX, y = leftY},
		{x = leftX - 30, y = leftY},
		{x = leftX + 30, y = leftY},
		{x = leftX + 10, y = leftY},
		{x = leftX - 20, y = leftY}
	}

	posEndRight = {
		{x = rightX, y = rightY},
		{x = rightX - 30, y = rightY},
		{x = rightX + 30, y = rightY},
		{x = rightX + 10, y = rightY},
		{x = rightX - 20, y = rightY}
	}

	for index=1,5 do
		local lotteryEffect = CCArmature:create("ui_mecha_get")
	    lotteryEffect:getAnimation():playWithIndex(0)
	    lotteryEffect:connectMovementEventSignal(function(movementType, movementID) end)
	    lotteryEffect:setPosition(posStart.x, posStart.y)
	    self.m_bg:addChild(lotteryEffect)

	    local spwArray = cc.Array:create()
		spwArray:addObject(cc.CallFuncN:create(function(sender)
					lotteryEffect:setVisible(true)
				end))
		spwArray:addObject(cc.MoveTo:create(0.5, cc.p(posEndLeft[index].x,posEndLeft[index].y)))

		lotteryEffect:setVisible(false)

		lotteryEffect:runAction(
			transition.sequence({cc.DelayTime:create(0.1 * (index - 1)),cc.Spawn:create(spwArray),cc.CallFuncN:create(function(sender)
					lotteryEffect:removeSelf()
				end)}))

	end

	for index=1,5 do
		local lotteryEffect = CCArmature:create("ui_mecha_get")
	    lotteryEffect:getAnimation():playWithIndex(0)
	    lotteryEffect:connectMovementEventSignal(function(movementType, movementID) end)
	    lotteryEffect:setPosition(posStart.x, posStart.y)
	    self.m_bg:addChild(lotteryEffect)

	    local spwArray = cc.Array:create()
		spwArray:addObject(cc.CallFuncN:create(function(sender)
					lotteryEffect:setVisible(true)
				end))
		spwArray:addObject(cc.MoveTo:create(0.5, cc.p(posEndRight[index].x,posEndRight[index].y)))

		lotteryEffect:setVisible(false)

		lotteryEffect:runAction(
			transition.sequence({cc.DelayTime:create(0.1 * (index - 1)),cc.Spawn:create(spwArray),cc.CallFuncN:create(function(sender)
					lotteryEffect:removeSelf()
					if index == 5 then
						self:updateView()
					end
				end)}))
	end
end

function ActivityMechaView:updateView()
	if self.need1 then
		self.lotteryBtn:removeChild(self.need1)
	end
	if self.icon1 then
		self.lotteryBtn:removeChild(self.icon1)
	end
	local icon1,need1
	if self.activityContent.mechaSingle.free and self.activityContent.mechaSingle.free > 0 then
		need1 = ui.newTTFLabel({text = CommonText[729], font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[1],align = ui.TEXT_ALIGN_CENTER, 
		x = self.lotteryBtn:getContentSize().width / 2, y = self.lotteryBtn:getContentSize().height / 2 - 15}):addTo(self.lotteryBtn)
		self.need1 = need1
	else
		icon1 = display.newSprite(IMAGE_COMMON .. "icon_coin.png", self.lotteryBtn:getContentSize().width / 2 - 30,self.lotteryBtn:getContentSize().height / 2 - 15):addTo(self.lotteryBtn)
		need1 = ui.newBMFontLabel({text = self.activityContent.mechaSingle.cost, font = "fnt/num_1.fnt"}):addTo(self.lotteryBtn)
		need1:setAnchorPoint(cc.p(0, 0.5))
		need1:setPosition(icon1:getPositionX() + icon1:getContentSize().width / 2 + 5,icon1:getPositionY() + 2)
		self.need1 = need1
		self.icon1 = icon1
	end

	self.leftChipCount:setString(self.activityContent.mechaSingle.part .. "/")
	self.rightChipCount:setString(self.activityContent.mechaTen.part .. "/")

	self.leftChipMerge:setPosition(self.leftChipCount:getPositionX() + self.leftChipCount:getContentSize().width,140)
	self.rightChipMerge:setPosition(self.rightChipCount:getPositionX() + self.rightChipCount:getContentSize().width,140)
	

	self.leftMergeBtn:setEnabled(self.activityContent.mechaSingle.part >= ACTIVITY_MECHA_MERGE_COUNT)
	self.rightMergeBtn:setEnabled(self.activityContent.mechaTen.part >= ACTIVITY_MECHA_MERGE_COUNT)

	self.leftMergeBtnEffect:setVisible(self.activityContent.mechaSingle.part >= ACTIVITY_MECHA_MERGE_COUNT)
    self.rightMergeBtnEffect:setVisible(self.activityContent.mechaTen.part >= ACTIVITY_MECHA_MERGE_COUNT)

    if self.activityContent.mechaSingle.part >= ACTIVITY_MECHA_MERGE_COUNT then
    	local flashEffect = CCArmature:create("ui_mecha_btn_flash")
	    flashEffect:getAnimation():playWithIndex(0)
	    flashEffect:connectMovementEventSignal(function(movementType, movementID) 
	    		if movementType == MovementEventType.COMPLETE then
	    			flashEffect:removeSelf()
	    		end
	    	end)
	    flashEffect:setPosition(self.leftMergeBtn:getPositionX(), self.leftMergeBtn:getPositionY())
	    self.m_bg:addChild(flashEffect)
    end
    
    if self.activityContent.mechaTen.part >= ACTIVITY_MECHA_MERGE_COUNT then
    	local flashEffect = CCArmature:create("ui_mecha_btn_flash")
	    flashEffect:getAnimation():playWithIndex(0)
	    flashEffect:connectMovementEventSignal(function(movementType, movementID) 
    			if movementType == MovementEventType.COMPLETE then
	    			flashEffect:removeSelf()
	    		end
	    	end)
	    flashEffect:setPosition(self.rightMergeBtn:getPositionX(), self.rightMergeBtn:getPositionY())
	    self.m_bg:addChild(flashEffect)
    end

    --暴击特效
    if self.critEffect then 
    	self.critEffect:removeSelf() 
    	self.critEffect = nil
    end
    
    if self.activityContent.mechaSingle.crit  > 1 then
    	local critEffect = CCArmature:create("ui_multiply_num_" .. self.activityContent.mechaSingle.crit)
	    critEffect:getAnimation():playWithIndex(0)
	    critEffect:connectMovementEventSignal(function(movementType, movementID) 
	    		-- if movementType == MovementEventType.COMPLETE then
	    		-- 	critEffect:removeSelf()
	    		-- end
	    	end)
	    critEffect:setPosition(self.m_bg:getContentSize().width / 2, 440)
	    self.m_bg:addChild(critEffect)
	    self.critEffect = critEffect
    end
    self.playeffectStatus = false
end


function ActivityMechaView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

function ActivityMechaView:onExit()
	ActivityMechaView.super.onExit(self)
	self.critEffect = nil
	armature_remove("animation/effect/ui_mecha_btn_flash.pvr.ccz", "animation/effect/ui_mecha_btn_flash.plist", "animation/effect/ui_mecha_btn_flash.xml")
	armature_remove("animation/effect/ui_mecha_btn_ligth.pvr.ccz", "animation/effect/ui_mecha_btn_ligth.plist", "animation/effect/ui_mecha_btn_ligth.xml")
	armature_remove("animation/effect/ui_mecha_get.pvr.ccz", "animation/effect/ui_mecha_get.plist", "animation/effect/ui_mecha_get.xml")
	armature_remove("animation/effect/ui_multiply_num.pvr.ccz", "animation/effect/ui_multiply_num.plist", "animation/effect/ui_multiply_num_2.xml")
	armature_remove("animation/effect/ui_multiply_num.pvr.ccz", "animation/effect/ui_multiply_num.plist", "animation/effect/ui_multiply_num_3.xml")
end




return ActivityMechaView
