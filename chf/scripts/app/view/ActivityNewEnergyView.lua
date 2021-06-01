--
--
--
local Dialog = require("app.dialog.Dialog")
--------------------------------------------------------


-- 计算平均位置 以中心点为准
local function CalculateX( all, index, width, dexScaleOfWidth)
	-- body
	local c = all + 1
	local q = c / 2
	local sw = width * dexScaleOfWidth
	local w = q * sw
	return index * sw - w
end


----------------------------------------------------------
--						奖励显示						--
----------------------------------------------------------
-- 奖励显示

local GiftShowDilog = class("GiftShowDilog", Dialog)

function GiftShowDilog:ctor(showdata,text)
	GiftShowDilog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 330)})
	self.Showdata = showdata
	self.text = text
end

function GiftShowDilog:onEnter()
	GiftShowDilog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:hasCloseButton(true)
	self:setTitle(CommonText[1057][2])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(558, 300))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local lb_time_title = ui.newTTFLabel({text = self.text, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(self:getBg())
	lb_time_title:setPosition(self:getBg():getContentSize().width / 2 , self:getBg():getContentSize().height * 0.5 + 70)


	local centerX = self:getBg():getContentSize().width * 0.5
	local size = #self.Showdata

	for index = 1 , size do
		local _db = self.Showdata[index]
		local kind , id ,count = _db[1], _db[2], _db[3]

		-- 元素
		local item = UiUtil.createItemView(kind,id,{count = count}):addTo(self:getBg())
		item:setPosition(centerX + CalculateX(size, index,  item:getContentSize().width , 1.2) ,self:getBg():getContentSize().height * 0.5 - 10)
		UiUtil.createItemDetailButton(item)

		local namedata = UserMO.getResourceData(kind,id)
		local name = UiUtil.label(namedata.name2,FONT_SIZE_SMALL,COLOR[1]):addTo(self:getBg())
		name:setPosition(item:getPositionX() , item:getPositionY() - item:getContentSize().height * 0.5 - name:getContentSize().height * 0.5 - 10)

	end
end

function GiftShowDilog:onExit()
	GiftShowDilog.super.onExit(self)
	-- body
end

------------------------------------------------------
--					大奖领取界面					--
------------------------------------------------------
-- 大奖领取界面
local BigGiftDilog = class("BigGiftDilog", Dialog)

function BigGiftDilog:ctor(ret,func1,func2,posY)
	BigGiftDilog.super.ctor(self, nil, UI_ENTER_NONE)
	self.ret = ret
	self.func1 = func1
	self.func2 = func2
	self.posY = posY
	
end

function BigGiftDilog:onEnter()
	BigGiftDilog.super.onEnter(self)

	local item = display.newSprite(IMAGE_COMMON .. "energygift_boss.png"):addTo(self:getBg() , 2)
	item:setPosition(self:getBg():getContentSize().width * 0.5, self.posY)

	-- 点击屏幕
	local function touchEnds()
		if self.func2 then self.func2() end
	end

	-- 动画播放完毕
	local function actionEnds()
		local guanzi = armature_create("xdjx_diandiguang",self:getBg():getContentSize().width * 0.5,self:getBg():getContentSize().height * 0.5 ,nil):addTo(self:getBg())
		guanzi:getAnimation():playWithIndex(0)
		guanzi:setScale(1.5)
		item:setVisible(false)
		local item2 = display.newSprite(IMAGE_COMMON .. "energygift_boss_dis.png"):addTo(self:getBg() , 2)
		item2:setScale(1.5)
		item2:setPosition(self:getBg():getContentSize().width * 0.5, self:getBg():getContentSize().height * 0.5)
		
		UiUtil.showAwards(self.ret)
		if self.func1 then self.func1() end

		self:setInOfBgClose(true,touchEnds)
	end

	-- 大奖动画
	local l1 = cc.EaseSineIn:create(cc.MoveTo:create(0.5 , cc.p(self:getBg():getContentSize().width * 0.5,self:getBg():getContentSize().height * 0.5)))
	local l2 = cc.ScaleTo:create(0.5,1.5)
	local spwArray = cc.Array:create()
	spwArray:addObject(l1)
	spwArray:addObject(l2)
	local l3 = cc.Spawn:create(spwArray)
	item:runAction(transition.sequence({l3, cc.CallFuncN:create(actionEnds)}))

end

function BigGiftDilog:onExit()
	BigGiftDilog.super.onExit(self)
end




----------------------------------------------------------
--						能量柱							--
----------------------------------------------------------
-- 能量柱 
local EnergyBar = class("EnergyBar",function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function EnergyBar:ctor(size,index,path)
	self.index = index
	self.viseSize = size
	self.path = path
	self:setContentSize(size)
	self:initWithUI()
end

function EnergyBar:initWithUI()

	-- 彩色遮罩
	local beforebg = display.newSprite(IMAGE_COMMON .. "energy_bg" .. self.index .. ".png"):addTo(self,10)
	beforebg:setAnchorPoint(cc.p(0.5,0))
	beforebg:setPosition(self.viseSize.width * 0.5 , 0)

	-- 水潭
	local bottom = display.newSprite(IMAGE_COMMON .. "energy_bottom" .. self.index .. ".png"):addTo(self,2)
	bottom:setAnchorPoint(cc.p(0.5,0))
	bottom:setPosition(self.viseSize.width * 0.5 , 0)
	self.bottom = bottom
	self.bottom.y = bottom:getPositionY()
	self.bottom.height = bottom:getContentSize().height

	-- 增长区域
	local centerSize = cc.size(self.viseSize.width , self.viseSize.height - bottom:getContentSize().height * 0.5)
	self.centerSize = centerSize

	-- 区域
	local rectNode = display.newClippingRegionNode(cc.rect(0,0,centerSize.width,centerSize.height)):addTo(self,3)
	rectNode:setAnchorPoint(cc.p(0.5,0))
	rectNode:setPosition(self.viseSize.width * 0.5 , bottom:getContentSize().height)

	-- 能量柱 增长部分
	local energy = display.newSprite(IMAGE_COMMON .. "energy" .. self.index .. ".png"):addTo(rectNode)
	energy:setAnchorPoint(cc.p(0.5,0))
	energy:setPosition(centerSize.width * 0.5 , 0)
	self.energy = energy
	self.energy.height = energy:getContentSize().height

	-- 籽粒气泡
    local particleSys = cc.ParticleSystemQuad:create(self.path):addTo(rectNode)
    particleSys:setAnchorPoint(cc.p(0.5,0))
    particleSys:setPosition(centerSize.width * 0.5,10)
    self.particleSys = particleSys
    self.particleSys.height = particleSys:getContentSize().height

	--动画
	local bolan = armature_create("nlgz_bolang",self.viseSize.width * 0.5,bottom:getContentSize().height - 1 ,nil):addTo(rectNode,1)
	bolan:setAnchorPoint(cc.p(0.5,0))
	bolan:getAnimation():playWithIndex(self.index - 1)
	self.bolanAction = bolan
	self.bolanAction.height = bolan:getContentSize().height

	-- 宝箱
	local box = display.newSprite(IMAGE_COMMON .. "energygift" .. self.index .. "_small.png"):addTo(self,5)
	box:setAnchorPoint(cc.p(0.5,0))
	box:setPosition(self.viseSize.width * 0.5, bottom:getContentSize().height )
	-- box:setScale(0.75)
	self.box = box
	self.box.height = box:getContentSize().height-- * box:getScale()
end

function EnergyBar:setPrecentBar(per)
	if per <= 0.0 then
		self.particleSys:setVisible(false)
		self.bottom:setVisible(false)
		self.energy:setScaleY(0)
		self.bolanAction:setVisible(false)
		self.box:setPosition(self.centerSize.width * 0.5, self.bottom:getContentSize().height)
	elseif per >= 1.0 then
		self.bottom:setVisible(true)
		self.energy:setScaleY(self.centerSize.height / self.energy.height)
		self.bolanAction:setVisible(false)
		self.box:setVisible(false)
		self.particleSys:setVisible(true)
	else
		self.bottom:setVisible(true)

		local _scale = (self.centerSize.height * per) / self.energy.height
		self.energy:setScaleY(_scale)

		self.bolanAction:setPosition(self.centerSize.width * 0.5 , self.bottom.y + self.centerSize.height * per - 1)
		self.bolanAction:setVisible(true)

		local boxY = self.bottom.y + self.centerSize.height * per + self.bolanAction.height
		local _boxY = self.bottom.y + self.centerSize.height - self.box.height
		local toBoxY = boxY > _boxY and _boxY or boxY
		self.box:setPosition(self.centerSize.width * 0.5, toBoxY)

		-- self.particleSys:setVisible(boxY >= self.particleSys.height)
		self.particleSys:setVisible(per > 0.4)
	end
end



------------------------------------------------------
--				能量灌注 新充值活动					--
------------------------------------------------------
-- 能量灌注 新充值活动
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ActivityNewEnergyView = class("ActivityNewEnergyView", UiNode)

function ActivityNewEnergyView:ctor(activity)
	ActivityNewEnergyView.super.ctor(self, "image/common/bg_ui.jpg")
	self.m_activity = activity
end

function ActivityNewEnergyView:onEnter()
	ActivityNewEnergyView.super.onEnter(self)
	self:setTitle(self.m_activity.name)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
	self:hasCoinButton(true,handler(self,self.TouchCoinCallback))

	-- 顶部背景
	local topbg = display.newSprite(IMAGE_COMMON .. "newEnergy.jpg"):addTo(self:getBg())
	topbg:setAnchorPoint(cc.p(0.5,1))
	topbg:setPosition(self:getBg():getContentSize().width * 0.5, self:getBg():getContentSize().height - 100)
	self.topbg = topbg

	--timeTitle
	local lb_time_title = ui.newTTFLabel({text = CommonText[853], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(topbg)
	lb_time_title:setAnchorPoint(cc.p(0,0.5))
	lb_time_title:setPosition(25 , lb_time_title:getContentSize().height * 0.5 + 15)

	--time
	local lb_time = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(topbg)
	lb_time:setAnchorPoint(cc.p(0,0.5))
	lb_time:setPosition(25 + lb_time_title:getContentSize().width , lb_time_title:getContentSize().height * 0.5 + 15)
	self.lb_time = lb_time

	-- activity tip label content
	local content1 = {{content = CommonText[1058][1], color = cc.c3b(255,255,255)}}
	local content2 = {{content = CommonText[1058][2], color = cc.c3b(255,255,255)},{content = CommonText[1058][3], color = COLOR[5]},{content = "!", color = cc.c3b(255,255,255)}}
	local tips_label = RichLabel.new(content1, cc.size(375, 0)):addTo(topbg,2)
	tips_label:setAnchorPoint(cc.p(0,0.5))
	tips_label:setPosition(25, topbg:getContentSize().height * 0.5 - 40 + 20 )
	tips_label = RichLabel.new(content2, cc.size(375, 0)):addTo(topbg,2)
	tips_label:setAnchorPoint(cc.p(0,0.5))
	tips_label:setPosition(25, topbg:getContentSize().height * 0.5 - 40 )

	-- tips
	local function tipsCallback()
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.EnegryTips):push()
	end
	local tips = UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil,tipsCallback):addTo(topbg)
	tips:setPosition(self:getBg():getContentSize().width - 85 , 40)

	-- 活动内容容器
	local energybg = display.newSprite(IMAGE_COMMON .. "energybg.jpg"):addTo(self:getBg() , 2)
	energybg:setAnchorPoint(cc.p(0.5,1))
	energybg:setPosition(self:getBg():getContentSize().width * 0.5 , topbg:getPositionY() - topbg:getContentSize().height)
	-- energybg:setOpacity(10)
	self.container = energybg

	--添加 动画资源
	armature_add("animation/effect/nlgz_bolang.pvr.ccz", "animation/effect/nlgz_bolang.plist", "animation/effect/nlgz_bolang.xml")
	armature_add("animation/effect/nlgz_guanzi.pvr.ccz", "animation/effect/nlgz_guanzi.plist", "animation/effect/nlgz_guanzi.xml")
	armature_add("animation/effect/xdjx_diandiguang.pvr.ccz", "animation/effect/xdjx_diandiguang.plist", "animation/effect/xdjx_diandiguang.xml")
	armature_add("animation/effect/nlgz_shangfu_guang.pvr.ccz", "animation/effect/nlgz_shangfu_guang.plist", "animation/effect/nlgz_shangfu_guang.xml")
	armature_add("animation/effect/nlgz_yuanpanguang.pvr.ccz", "animation/effect/nlgz_yuanpanguang.plist", "animation/effect/nlgz_yuanpanguang.xml")

	-- 默认按钮样式
	self.btntype = {
			{normal = "btn_9_normal", selected = "btn_9_selected", disabled = "btn_9_disabled"},
			{normal = "btn_64_normal", selected = "btn_64_selected", disabled = "btn_9_disabled"},
			{normal = "btn_63_normal", selected = "btn_63_selected", disabled = "btn_9_disabled"}
		}
	-- 动画X轴偏移量
	self.runActionPos = { -8 ,8 , 27}

	-- 泡泡动画
	self.paopaoRs = {"animation/effect/lanpaopao.plist","animation/effect/zipaopao.plist","animation/effect/huangpaopao.plist"}

	--
	self.timeEndTag = -1

	-- 默认支付 对应天数
	ActivityCenterMO.ActivityEnergyOfdata.day = 0

	-- 刷新时间
	if not self.timeScheduler then
		self.timeScheduler = scheduler.scheduleGlobal(handler(self,self.update), 1)
	end

	--注册消息 接受来自充值的回调
	self.notifyhandler = Notify.register("ACTIVITY_NOTIFY_NEWENERGY", handler(self, self.updateForRecharge))

	--发送消息拉取 数据
	self:updateForRecharge()

	
end

-- 秒更新 倒计时
function ActivityNewEnergyView:update( ft )
	if self.lb_time then
		local time = self.m_activity.endTime - ManagerTimer.getTime()
		if time >= 0 then 
			self.lb_time:setString(UiUtil.strBuildTime(time))
		else
			self.lb_time:setString(UiUtil.strBuildTime(0))
			self.timeEndTag = self.timeEndTag + 1
			if self.timeEndTag == 0 then
				self:updateForRecharge()
			end
		end
	end
end

-- resume 重新刷新
function ActivityNewEnergyView:refreshUI( preName )

	-- 是否是充值
	if ActivityCenterMO.ActivityEnergyOfdata.updateui then
		ActivityCenterMO.ActivityEnergyOfdata.updateui = false
		Notify.notify("ACTIVITY_NOTIFY_NEWENERGY")
	end
end

-- 点击 金币按钮后 修改数据
function ActivityNewEnergyView:TouchCoinCallback()
	ActivityCenterMO.ActivityEnergyOfdata.day = 0
end

--发送消息拉取 数据
function ActivityNewEnergyView:updateForRecharge()
	self.isAllFunctionTouch = false
	self.updateActionList = {}
	self.updateTempBoss = {}
	ActivityCenterBO.GetActCumulativePayInfo(handler(self,self.checkData))
end

-- 处理来自服务端的数据
function ActivityNewEnergyView:checkData(data)
	ActivityCenterMO.ActivityEnergyOfdata.updateui = false
	-- body 处理收到的消息 来决定怎么显示UI  或者 播放动画
	self.status = data.status -- 大奖 领取奖励状态 1.可领     -1.已领      0.条件不满足不可领
	self.keyId = json.decode(ActivityMO.queryActivityAwardsById(data.keyId).awardList) -- 大奖 预览id s_activity_award
	self.curDay = data.day -- 当前是第几天

	local awardId = data.awardId -- 活动奖励 标识符
	local _paydata = PbProtocol.decodeArray(data["pay"])
	-- dump(_paydata,"day :" .. data.day .. "  status :" .. data.status )
	self.runAction = {}
	self.paydata = {}
	for index = 1 ,#_paydata do
		local _pay = _paydata[index]
		local _data = ActivityCenterMO.getCumulativepay(awardId,_pay.dayId)

		local out = {}
		out.addPay = _pay.addPay					-- 增加值
		out.dayId = _pay.dayId						-- 天数
		out.status = _pay.status					-- 领取按钮状态 1 可领 0 不能领 -1 已领
		out.curPay = _pay.totalPay 					-- 当前已经充值
		out.allPay = _pay.totalPay + _pay.addPay	-- 总量
		out.targetPay = _data.daypay				-- 目标
		out.pvaward = json.decode(_data.dayawards)	-- 预览奖励
		out.index = index
		self.paydata[#self.paydata + 1] = out
	end
	
	self.isAllFunctionTouch = true
	self.updateTempBoss = {}
	self:ShowActivity()
end

-- 绘制活动UI
function ActivityNewEnergyView:ShowActivity()
	-- body
	self.container:removeAllChildren()

	local _width = self.container:getContentSize().width
	local topY = self.container:getContentSize().height
	local bottomY = topY
	local addUpdateNumber = 0
	local widthScale = 0.90
	local giftProtectedIndex = 0

	for index = 1, #self.paydata do
		-- 数据
		local data = self.paydata[index]
		local mywidth = _width * 0.5 + (_width / 6) * (index * 2 - 1 - 3) * widthScale 
		addUpdateNumber = addUpdateNumber + data.addPay

		-- 主动 领取大奖
		if data.addPay == 0 and data.curPay >= data.targetPay then
			giftProtectedIndex = giftProtectedIndex + 1
		end

		--顶部按钮
		local topButton = nil
		local isCoudaward = false
		local topNomal = display.newSprite(IMAGE_COMMON .. self.btntype[index].normal .. ".png")
		local topSelected = display.newSprite(IMAGE_COMMON .. self.btntype[index].selected .. ".png")
		local topDisabled = display.newSprite(IMAGE_COMMON .. self.btntype[index].disabled .. ".png")
		if data.curPay >= data.targetPay then isCoudaward = true end

		if isCoudaward then
			topNomal = display.newSprite(IMAGE_COMMON .. "energygift" .. index .. ".png")
			topSelected = display.newSprite(IMAGE_COMMON .. "energygift" .. index .. ".png")
			topDisabled = display.newSprite(IMAGE_COMMON .. "energygift" .. index .. "_dis.png")
		end
		local btn_bg = display.newSprite(IMAGE_COMMON .. "energy_btn_bg" .. index .. ".png"):addTo(self.container,2)
		btn_bg:setAnchorPoint(cc.p(0.5,0))
		btn_bg:setPosition(mywidth, topY - 108)

		local shangfuEffect = armature_create("nlgz_shangfu_guang",mywidth,topY - 108 ,nil):addTo(self.container,4)
		shangfuEffect:setAnchorPoint(cc.p(0.5,0))
		shangfuEffect:getAnimation():playWithIndex(index - 1)
		-- shangfuEffect:setScale(0.4)


		topButton = MenuButton.new(topNomal,topSelected,topDisabled,handler(self,self.TopButtonCallback)):addTo(self.container,3)
		topButton:setAnchorPoint(cc.p(0.5,0))
		topButton:setPosition(mywidth, topY - 105)
		if topButton:getPositionY() < bottomY then bottomY = topButton:getPositionY() end
		if isCoudaward then
			btn_bg:setVisible(true)
			shangfuEffect:setVisible(true)
			if data.status > 0 then 			--还未领取 可领
				topButton:setEnabled(true)
				self:Myrun(topButton)
			else 								-- 已经领取 0 不可领取 -1 已领取
				topButton:setEnabled(false)
			end
			topButton:setLabel("")
		else
			btn_bg:setVisible(false)
			shangfuEffect:setVisible(false)
			topButton:setLabel(CommonText[1055][2])
			if data.dayId > self.curDay then 	-- 未开启
				topButton:setVisible(false)
			else
				topButton:setVisible(true)
			end
		end

		--能量体
		local energyBox = EnergyBar.new(cc.size(112,184),index,self.paopaoRs[index]):addTo(self.container , 6)
		energyBox:setAnchorPoint(cc.p(0,0))
		energyBox:setPosition(mywidth - 112 * 0.5, topY - 340)

		if energyBox:getPositionY() < bottomY then bottomY = energyBox:getPositionY() - energyBox:getContentSize().height end

		self:showTips(energyBox,data.pvaward,CommonText[1057][3])


		-- 百分比文字
		local lb_pertitle = ui.newTTFLabel({text = CommonText[1055][1], font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255), 
			x = energyBox:getContentSize().width * 0.5 , y = energyBox:getContentSize().height * 0.5 + 10}):addTo(energyBox,10)
		local lb_percent = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255),
			x = energyBox:getContentSize().width * 0.5 , y = energyBox:getContentSize().height * 0.5 - 10}):addTo(energyBox,10)

		-- 
		local guanzi = armature_create("nlgz_guanzi",mywidth + self.runActionPos[index],topY - 393 ,nil):addTo(self.container,7)
		guanzi:setAnchorPoint(cc.p(0.5,1))
		guanzi:setVisible(false)

		if isCoudaward then -- and data.status < 0 then
			guanzi:setVisible(true)
			guanzi:getAnimation():playWithIndex((index - 1) * 2 + 1)
		end
		self.runAction[data.dayId] = guanzi

		--
		topButton.bg = btn_bg
		topButton.couldaward = isCoudaward		--是否可以领取奖励
		topButton.dayId = data.dayId 			-- 天数
		topButton.index = index
		topButton.lb_pertitle = lb_pertitle
		topButton.lb_percent = lb_percent
		topButton.energyBox = energyBox
		topButton.effect = shangfuEffect
		topButton.func = handler(self, self.updateUI)

		-- 更新 坐标
		self:updateUI(data, lb_pertitle, lb_percent, energyBox)

		if not isCoudaward and data.addPay > 0 then
			-- 动作
			self:takeAction(data, topButton, lb_pertitle, lb_percent, energyBox)
		end

	end

	-- 底部大奖
	self.bottomSprite = nil
	self:updateAndDrawBoss(_width * 0.5 , bottomY + 45)

	local yuanpan = armature_create("nlgz_yuanpanguang",_width * 0.5,bottomY - 15,nil):addTo(self.container,10)
	yuanpan:getAnimation():playWithIndex(0)

	-- 主动领取大奖
	if self.status == 1 and giftProtectedIndex >= #self.paydata then
		self:GetBigGift()
	end
end

-- 更新 坐标
function ActivityNewEnergyView:updateUI(data, lb_pertitle, lb_percent, energyBox)
	-- 能量柱
	energyBox:setPrecentBar(data.curPay / data.targetPay)

	-- 百分比文字
	if data.curPay <= 0 then
		lb_percent:setColor(cc.c3b(255,0,0))
		lb_percent:setString(math.min(math.floor(data.curPay), data.targetPay) .. "/" .. data.targetPay)
	elseif data.curPay >= data.targetPay then
		lb_percent:setColor(cc.c3b(0,200,0))
		if data.status > 1 then
			lb_pertitle:setString(CommonText[1055][3])
			lb_percent:setString(CommonText[1055][4])
		else
			lb_pertitle:setString(CommonText[1055][1])
			lb_percent:setString(math.min(math.floor(data.curPay), data.targetPay) .. "/" .. data.targetPay)
		end
	else
		lb_percent:setColor(cc.c3b(255,255,255))
		lb_percent:setString(math.min(math.floor(data.curPay), data.targetPay) .. "/" .. data.targetPay)
	end 
	
end

-- 创建 能量变动[动画]
function ActivityNewEnergyView:takeAction(data, topButton, lb_pertitle, lb_percent, energyBox)
	-- body
	self.isAllFunctionTouch = false

	local time = 2
	local startdata = data.curPay
	local enddata = data.allPay > data.targetPay and data.targetPay or data.allPay
	local temp = {curPay = data.curPay , targetPay = data.targetPay, status = data.status}

	local function updateHeight(_self,dt)
		-- time
		local restate = false
		_self._detlatime = _self._detlatime + dt
		local pretime = _self._detlatime / _self._alltime
		local pre = (1.0 - pretime)
		local curdata = _self._startdata * pre + _self._enddata * pretime
		_self._temp.curPay = math.floor(curdata)

		if pre <= 0 then
			restate = true
			_self._temp.curPay = _self._enddata
			_self.data.curPay = _self._enddata
			if _self.data.allPay >= _self.data.targetPay then
				_self._temp.status = 1
				_self.data.status = 1
			end
		end
		
		self:updateUI(_self._temp, _self.lb_pertitle, _self.lb_percent, _self.energyBox)

		return restate
	end 

	local outAction = {}
	outAction.data = data
	outAction.topButton = topButton
	outAction.lb_pertitle = lb_pertitle
	outAction.lb_percent = lb_percent
	outAction.energyBox = energyBox

	outAction._alltime = time
	outAction._detlatime = 0
	outAction._startdata = startdata
	outAction._enddata = enddata
	outAction._temp = temp
	outAction.myfunction = updateHeight

	table.insert(self.updateActionList,outAction)
end

-- 实时刷新[动画]
function ActivityNewEnergyView:onEnterFrame(dt)
	if table.getn(self.updateActionList) == 0 then return end

	local tempnode = 0
	for index = 1 , #self.updateActionList do
		local action = self.updateActionList[index]
		if action:myfunction(dt) then
			if action.data.allPay >= action.data.targetPay then
				action.topButton:setNormalSprite(display.newSprite(IMAGE_COMMON .. "energygift" .. action.data.dayId .. ".png"))
				action.topButton:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "energygift" .. action.data.dayId .. ".png"))
				action.topButton:setDisabledSprite(display.newSprite(IMAGE_COMMON .. "energygift" .. action.data.dayId .. "_dis.png"))
				action.topButton:setEnabled(true)
				action.topButton:setLabel("")
				action.topButton.bg:setVisible(true)
				action.topButton.effect:setVisible(true)
				action.topButton.couldaward = true -- isCoudaward is local variable

				local temp = {}
				temp.dayId = action.data.dayId
				temp.topButton = action.topButton
				temp.allPay = action.data.allPay
				temp.targetPay = action.data.targetPay
				self.updateTempBoss[#self.updateTempBoss + 1] = temp
			end
			tempnode = index
			break
		end
	end

	-- 逐个删除
	if tempnode > 0 then
		table.remove(self.updateActionList, tempnode)
	end

	-- 检查是否循环完毕
	if table.getn(self.updateActionList) > 0 then return end

	-- 检查时候需要播放 满足条件的动画
	if table.getn(self.updateTempBoss) > 0 then	self:ActionGz()	return end

	self.isAllFunctionTouch = true

end

-- 领取按钮 / 跳转按钮
-- function 1 领取 日充值奖励 1,2,3第几天奖励 0 大奖
-- function 2 跳转入充值界面
function ActivityNewEnergyView:TopButtonCallback(tag,sender)
	if not self.isAllFunctionTouch then return end
	ManagerSound.playNormalButtonSound()
	local dayid = sender.dayId
	local index = sender.index
	local couldaward = sender.couldaward --是否可以领取奖励


	if not couldaward then
		-- 进入充值页面 补充操作
		ActivityCenterMO.ActivityEnergyOfdata.day = dayid
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
		return
	end

	-- 领取奖励操作
	local function callback(data)
		-- print("Activity - NewEnergy - 领取 日充值奖励 " .. dayid )
		sender:stopAllActions()
		sender:setEnabled(false)
		self.paydata[sender.index].status = -1
		sender.func(self.paydata[sender.index], sender.lb_pertitle, sender.lb_percent, sender.energyBox)
		-- 奖励提示
		Toast.show(CommonText[1057][1]) -- 奖励领取成功
	end
	ActivityCenterBO.GetActCumulativePayAward(callback, dayid)
end

-- 出发领取大奖 并 发送消息
function ActivityNewEnergyView:GetBigGift()
	self.isAllFunctionTouch = false
	ActivityCenterBO.GetActCumulativePayAward(handler(self,self.BossAction), 0)
end

-- 点击触发提示
-- node 出发的节点
-- data 出发相关数据
function ActivityNewEnergyView:showTips(node,data_,text)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			-- if not self.isAllFunctionTouch then return true end
			-- -- 背景框
			-- local bg = display.newScale9Sprite(IMAGE_COMMON .. "tipbg.png"):addTo(node , 999) 
			-- bg:setAnchorPoint(cc.p(anchor,0))
			-- local _scale = 0.8
			-- local _y = 20
			-- local top = 0

			-- for index = #data , 1 , -1 do
			-- 	local _db = data[index]
			-- 	local kind , id ,count = _db[1], _db[2], _db[3]
			-- 	-- 元素
			-- 	local item = UiUtil.createItemView(kind,id):addTo(bg)
			-- 	item:setScale(_scale)
			-- 	item:setAnchorPoint(cc.p(0 , 0))
			-- 	item:setPosition(30 ,_y + item:getContentSize().height * 1.1 * _scale * (#data - index))
			-- 	top = item:getPositionY() + item:getContentSize().height
			-- 	-- 数量
			-- 	local numberLb = UiUtil.label("X " .. count,FONT_SIZE_MEDIUM,COLOR[1]):addTo(bg)
			-- 	numberLb:setAnchorPoint(cc.p(0,0.5))
			-- 	numberLb:setPosition(item:getPositionX() + item:getContentSize().width * 1.3 * _scale , item:getPositionY() + item:getContentSize().height * 0.5 * _scale)
			-- end
			
			-- bg:setPreferredSize(cc.size(bg:getContentSize().width, top ))
			-- bg:setPosition(0 + anchor * node:getContentSize().width,node:getContentSize().height * 1.1)
			-- node.tipNode_ = bg
			return true
		elseif event.name == "ended" then
			-- if node.tipNode_ then node.tipNode_:removeSelf() end
			GiftShowDilog.new(data_,text):push()
		end
	end)
end

-- 刷新 和 绘制 大奖
function ActivityNewEnergyView:updateAndDrawBoss(_x , _y)
	local x_ = nil
	local y_ = nil
	if self.bottomSprite then
		x_ = self.bottomSprite.x_
		y_ = self.bottomSprite.y_
		self.bottomSprite:removeSelf()
		self.bottomSprite = nil
	else
		x_ = _x
		y_ = _y
	end

	local boss_path = "energygift_boss"
	if self.status < 0 then boss_path = "energygift_boss_dis" end 
	local bottomSprite = display.newSprite(IMAGE_COMMON .. boss_path .. ".png"):addTo(self.container,9)
	bottomSprite:setPosition(x_, y_)
	self.bottomSprite = bottomSprite
	self.bottomSprite.x_ = x_
	self.bottomSprite.y_ = y_

	self:showTips(self.bottomSprite,self.keyId,CommonText[1057][4])
end

------------------------------------------------------
--						动画组						--
------------------------------------------------------
-- 带领取奖励按钮提示动画
function ActivityNewEnergyView:Myrun( node )
	node:run{
				"rep",
				{
					"seq",
					{"rotateTo",0,-2},
					{"rotateTo",0.1,2},
					{"rotateTo",0.1,-2},
				}
			}
end

-- 满足条件管道动画
function ActivityNewEnergyView:ActionGz()

	local count = #self.updateTempBoss

	local function actioncall( movementType, movementID )	
		if movementType == MovementEventType.COMPLETE then
			count = count - 1
			if count <= 0 then
				self.updateTempBoss = {}
				self.isAllFunctionTouch = true
				if self.status > 0 then self:GetBigGift() end
			end
		end
	end

	-- 播放管道动画
	local function actionfun(dayId)
		local action = self.runAction[dayId]
		action:setVisible(true)
		action:connectMovementEventSignal(actioncall)
		action:getAnimation():playWithIndex((dayId - 1) * 2)
	end

	for index = 1 , #self.updateTempBoss do
		local _data = self.updateTempBoss[index]
		-- 播放按钮
		self:Myrun(_data.topButton)
		-- 播放管道动画
		actionfun(_data.dayId)
	end
end

-- 领取大奖动画
function ActivityNewEnergyView:BossAction(data)
	-- print("Activity - NewEnergy - 领取大奖")
	--加入背包
	local awards = PbProtocol.decodeArray(data["award"])
	local ret = CombatBO.addAwards(awards)
	-- UiUtil.showAwards(ret)
	local function finash()
		self.isAllFunctionTouch = true
		self.status = -1

		-- Toast.show(CommonText[1057][1]) -- 奖励领取成功
	end	

	self.bottomSprite:setVisible(false)
	BigGiftDilog.new(ret,finash,handler(self,self.updateAndDrawBoss),self.bottomSprite:getPositionY()):push()
end

-- 清空数据和动画资源
function ActivityNewEnergyView:onExit()
	ActivityNewEnergyView.super.onExit(self)

	armature_remove("animation/effect/nlgz_bolang.pvr.ccz", "animation/effect/nlgz_bolang.plist", "animation/effect/nlgz_bolang.xml")
	armature_remove("animation/effect/nlgz_guanzi.pvr.ccz", "animation/effect/nlgz_guanzi.plist", "animation/effect/nlgz_guanzi.xml")
	armature_remove("animation/effect/xdjx_diandiguang.pvr.ccz", "animation/effect/xdjx_diandiguang.plist", "animation/effect/xdjx_diandiguang.xml")
	armature_remove("animation/effect/nlgz_shangfu_guang.pvr.ccz", "animation/effect/nlgz_shangfu_guang.plist", "animation/effect/nlgz_shangfu_guang.xml")
	armature_remove("animation/effect/nlgz_yuanpanguang.pvr.ccz", "animation/effect/nlgz_yuanpanguang.plist", "animation/effect/nlgz_yuanpanguang.xml")

	if self.timeScheduler then
		scheduler.unscheduleGlobal(self.timeScheduler)
	end

	if self.notifyhandler then
		Notify.unregister(self.notifyhandler)
	end

	ActivityCenterMO.ActivityEnergyOfdata.day = 0
end

return ActivityNewEnergyView