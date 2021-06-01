--
-- Author: Gss
-- Date: 2019-04-08 10:04:10
--
-- 能源核心 EnergyCoreView

local EnergyCoreView = class("EnergyCoreView", UiNode)

function EnergyCoreView:ctor(buildId,enterStyle)
	enterStyle = enterStyle or UI_ENTER_NONE
	EnergyCoreView.super.ctor(self, "image/common/bg_ui.jpg", enterStyle)
end

function EnergyCoreView:onEnter()
	EnergyCoreView.super.onEnter(self)
	self:setTitle(CommonText[8000])
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_dianliu.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_dianliu.plist", IMAGE_ANIMATION .. "effect/nyhx_dianliu.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_bg_guangxiao.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_bg_guangxiao.plist", IMAGE_ANIMATION .. "effect/nyhx_bg_guangxiao.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_shandianqiu.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_shandianqiu.plist", IMAGE_ANIMATION .. "effect/nyhx_shandianqiu.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_jindutiao.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_jindutiao.plist", IMAGE_ANIMATION .. "effect/nyhx_jindutiao.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_suolian_suolian.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_suolian_suolian.plist", IMAGE_ANIMATION .. "effect/nyhx_suolian_suolian.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_ronglian_6xiaokuang.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_ronglian_6xiaokuang.plist", IMAGE_ANIMATION .. "effect/nyhx_ronglian_6xiaokuang.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_zhongjiankuang.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_zhongjiankuang.plist", IMAGE_ANIMATION .. "effect/nyhx_zhongjiankuang.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_jindutiao_fenge.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_jindutiao_fenge.plist", IMAGE_ANIMATION .. "effect/nyhx_jindutiao_fenge.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_nlzr.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_nlzr.plist", IMAGE_ANIMATION .. "effect/nyhx_nlzr.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_shuzi_gundong.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_shuzi_gundong.plist", IMAGE_ANIMATION .. "effect/nyhx_shuzi_gundong.xml")
	armature_add(IMAGE_ANIMATION .. "effect/dengjimingcheng_genghuan.pvr.ccz", IMAGE_ANIMATION .. "effect/dengjimingcheng_genghuan.plist", IMAGE_ANIMATION .. "effect/dengjimingcheng_genghuan.xml")
	armature_add(IMAGE_ANIMATION .. "effect/nyhx_jiahao_lizi.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_jiahao_lizi.plist", IMAGE_ANIMATION .. "effect/nyhx_jiahao_lizi.xml")

	self.m_attrState = true --属性框默认是收进去的
	self.m_isPlay = false  --判断熔炼成功动画是否正在播放
	self.m_isMove = false
	self.m_costData = {}

	self.m_closeBtn = self:getCloseButton()
	self:showUI()
end

function EnergyCoreView:showUI()
	--背景图 
	local bg = display.newSprite(IMAGE_COMMON .. "energy_bg.png"):addTo(self:getBg())
	bg:setAnchorPoint(cc.p(0.5, 1))
	bg:setPosition(self:getBg():width() / 2, self:getBg():height())
	self.m_bg = bg

	local lightBg = CCArmature:create("nyhx_bg_guangxiao"):addTo(bg,999)
	lightBg:setPosition(bg:width() / 2, bg:height() / 2 + 35)
    lightBg:getAnimation():playWithIndex(0)

    self:showTop()
	self:showEnergy()
	self.m_choseNum = 1 --默认选择查看第一位置的
	self:showAttr()
end

function EnergyCoreView:showTop()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	local lvInfo = EnergyCoreMO.queryLvInfoByLv(EnergyCoreMO.energyCoreData_.lv)
	local sectionInfo = EnergyCoreMO.queryExpByLvAndSection(EnergyCoreMO.energyCoreData_.lv, EnergyCoreMO.energyCoreData_.section)
	local sectionExp = EnergyCoreMO.energyCoreData_.exp
	if sectionInfo then
		sectionExp = sectionInfo.exp
	end
	local lvlab1, lvlab2 = EnergyCoreMO.formatEnergyCoreLv()

	--顶部bg
	local topBg = display.newSprite(IMAGE_COMMON .. "energy_top_bg.png"):addTo(container)
	topBg:setPosition(container:width() / 2, container:height() - 92 - topBg:height() / 2)
	--等级和名字
	local headBg = display.newSprite(IMAGE_COMMON .. "energy_head_bg.png"):addTo(topBg,9)
	headBg:setPosition(headBg:width() / 2, topBg:height() / 2 - 20)
	--数字滚动动画
	local roll = armature_create("nyhx_shuzi_gundong"):addTo(headBg,99)
    roll:setPosition(headBg:width() / 2, headBg:height() / 2)
    roll:setVisible(false)
    headBg.roll = roll
    --名字改变变化
	local change = armature_create("dengjimingcheng_genghuan"):addTo(headBg,99)
    change:setPosition(headBg:width() / 2, 25)
    change:setVisible(false)
    headBg.change = change

	local lvBg1 = display.newSprite(IMAGE_COMMON .. "energy_lv_bg.png"):addTo(headBg,-1)
	lvBg1:setPosition(headBg:width() / 2 - 25, headBg:height() / 2 + 8)
	local lv1 = UiUtil.label(lvlab1,nil,cc.c3b(0, 0, 0)):addTo(lvBg1):center()
	headBg.lv1 = lv1

	local lvBg2 = display.newSprite(IMAGE_COMMON .. "energy_lv_bg.png"):addTo(headBg,-1)
	lvBg2:setPosition(headBg:width() / 2 + 25, lvBg1:y())
	local lv2 = UiUtil.label(lvlab2,nil,cc.c3b(0, 0, 0)):addTo(lvBg2):center()
	headBg.lv2 = lv2

	--名称
	local lvName = UiUtil.label(lvInfo.desc2,nil,cc.c3b(0,0,0)):addTo(headBg)
	lvName:setPosition(headBg:width() / 2, 25)
	headBg.lvName = lvName

	self.m_headBg = headBg
	--四个状态球
	for index=1,4 do
		local exp = EnergyCoreMO.queryExpByLvAndSection(EnergyCoreMO.energyCoreData_.lv, index).exp
		local tipBg = display.newSprite(IMAGE_COMMON.."energy_bar_bg.png"):addTo(topBg)
		tipBg:setPosition(headBg:x() + 120 + (index - 1)*125,headBg:height() / 2)

		local needBg = display.newSprite(IMAGE_COMMON.."energy_numExp_bg.png"):addTo(tipBg,9):center()
		local needLab = UiUtil.label(""):addTo(needBg):center()
		needLab:setString(exp)

		--进度
		local clipping = cc.ClippingNode:create()
		local oilBar = ProgressBar.new(IMAGE_COMMON .. "energy_ball_bar.png", BAR_DIRECTION_CIRCLE)
		local mask = display.newSprite(IMAGE_COMMON.."bar_bg_13.png")
		clipping:setInverted(false)
		clipping:setAlphaThreshold(0.0)
		clipping:setStencil(mask)
		clipping:addChild(oilBar)
		clipping:addTo(tipBg):center()
		oilBar:setPercent(EnergyCoreMO.energyCoreData_.exp / sectionExp)

		if EnergyCoreMO.energyCoreData_.section > index then
			oilBar:setPercent(1)
			needLab:setString("Max")

			local lightningBall = CCArmature:create("nyhx_shandianqiu"):addTo(tipBg):center()
		    lightningBall:getAnimation():playWithIndex(0)
		elseif EnergyCoreMO.energyCoreData_.section < index then
			oilBar:setPercent(0)
		elseif EnergyCoreMO.energyCoreData_.section == index then
			local lightning = CCArmature:create("nyhx_dianliu"):addTo(clipping)
			local yOff = (oilBar:getPercent() - 0.5) * 91
			lightning:setPosition(oilBar:getPositionX(),yOff)
		    lightning:getAnimation():playWithIndex(0)
		end
	end

	--当前阶段进度条
	local percent = EnergyCoreMO.energyCoreData_.exp / sectionExp
	if percent > 1 then
		percent = 1
	end
	local expbarBg = display.newSprite(IMAGE_COMMON.."energy_exp_bar_bg.png"):addTo(topBg)
	expbarBg:setPosition(topBg:width() / 2 + 25,0)
	local expBar = ProgressBar.new(IMAGE_COMMON .. "energy_exp_bar.png", BAR_DIRECTION_HORIZONTAL):addTo(topBg)
	expBar:setPosition(topBg:width() / 2 + 25,4)
	expBar:setPercent(percent)
	local barani = CCArmature:create("nyhx_jindutiao"):addTo(expBar,99)
    barani:getAnimation():playWithIndex(0)
    barani:setAnchorPoint(cc.p(0,0.5))
    barani:setScaleX(percent)
    barani:setPosition(0,expBar:height() / 2)

	--经验数字展示
	local expLab = UiUtil.label(EnergyCoreMO.energyCoreData_.exp):addTo(expBar,99)
	expLab:setPosition(expBar:width() / 2 - 40, expBar:height() / 2)
	local needExp = UiUtil.label("/"..sectionExp):addTo(expBar,99)
	needExp:setPosition(expLab:x() + expLab:width() / 2 + needExp:width() / 2, expLab:y())

	--满级满阶段
	if EnergyCoreMO.energyCoreData_.state == 1 then
		expLab:setString("Max")
		expLab:setPosition(expBar:width() / 2, expBar:height() / 2)
		needExp:setVisible(false)
	end
end

function EnergyCoreView:showEnergy()
	if self.m_enerrgyNode then
		self.m_enerrgyNode:removeSelf()
		self.m_enerrgyNode = nil
	end

	local container = display.newNode():addTo(self.m_bg,98)
	container:setContentSize(self.m_bg:getContentSize())
	self.m_enerrgyNode = container

	local bg = container
	--锁链
	local chains = armature_create("nyhx_suolian_suolian"):addTo(bg):center()
    chains:getAnimation():playWithIndex(0)
    chains:setPosition(bg:width() / 2, bg:height() / 2 + 55)
    chains:setVisible(EnergyCoreMO.energyCoreData_.section < 5 and EnergyCoreMO.energyCoreData_.state ~= 1)
	self.m_chains = chains

	--tips
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local tipsBtn = MenuButton.new(normal, selected, nil, function()
			ManagerSound.playNormalButtonSound()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.energyCore):push()
		end):addTo(bg):scale(0.7)
	tipsBtn:setPosition(50,bg:height() - 280)

	--详情查看
	local normal = display.newSprite(IMAGE_COMMON .. "btn_look_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_look_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			ManagerSound.playNormalButtonSound()
			local EnergyCoreShowView = require("app.view.EnergyCoreShowView")
			EnergyCoreShowView.new():push()
		end):addTo(bg,999):scale(0.7):rightTo(tipsBtn, -20)
	-- detailBtn:setPosition(bg:width() - 50,tipsBtn:y())

	--剩余经验
	local overflowExp = display.newSprite(IMAGE_COMMON.."energyCore_overflow_exp.png"):addTo(bg)
	overflowExp:setPosition(bg:width() - 50,tipsBtn:y())
	overflowExp:setVisible(EnergyCoreMO.energyCoreData_.redExp > 0)
	self.m_overflowExp = overflowExp
	self:showTips(overflowExp)

	--箭头
	local normal = display.newSprite(IMAGE_COMMON .. "energy_core_arror.png")
	local nxtBtn = TouchButton.new(normal, nil, nil, handler(self, self.onNextCallback)):addTo(bg)
	nxtBtn:setPosition(bg:width() - 20, detailBtn:y() - 50)
	self.m_arrowBtn = nxtBtn
	-- nxtBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(20, 0)), cc.MoveBy:create(2, cc.p(-20, 0))})))
	

	--中间的
	local choseBg = display.newSprite(IMAGE_COMMON .. "energy_choose.png"):addTo(bg)
	choseBg:setPosition(chains:x(), chains:y() - 40)
	choseBg:setVisible(EnergyCoreMO.energyCoreData_.section < 5 and EnergyCoreMO.energyCoreData_.state ~= 1)
	self.m_choseBg = choseBg

	local normal = display.newSprite(IMAGE_COMMON .. "energy_add.png")
	local choseItem = TouchButton.new(normal, nil, nil, nil, handler(self, self.clickCenterCall)):addTo(choseBg):center()
	local add = armature_create("nyhx_jiahao_lizi"):addTo(choseItem):center()
    add:getAnimation():playWithIndex(0)

	local nameBg = display.newSprite(IMAGE_COMMON .. "energy_nameBg.png"):addTo(choseBg)
	nameBg:setPosition(choseBg:width() / 2, -nameBg:height() / 2)
	local costName = UiUtil.label(CommonText[8008]):addTo(nameBg):center()
	nameBg:setVisible(EnergyCoreMO.energyCoreData_.section < 5)

	local tips = UiUtil.label(CommonText[8009]):addTo(bg)
	tips:setPosition(bg:width() / 2 , choseBg:y() - 230)
	if EnergyCoreMO.energyCoreData_.section < 5 then
		tips:setString(CommonText[8020])
	end
	self.m_tips = tips
	if EnergyCoreMO.energyCoreData_.state == 1 then
		self.m_tips:setString(CommonText[4015])
	end
	-- self.m_tips:setVisible(EnergyCoreMO.energyCoreData_.state ~= 1)

	local attnode = display.newScale9Sprite(IMAGE_COMMON .. "core_arrtbg.png"):addTo(bg)
	attnode:setPreferredSize(cc.size(attnode:width(), attnode:height() - 20))
	attnode:setPosition(bg:width() / 2, choseBg:y() + 270)
	
	local condition = EnergyCoreMO.queryLvInfoByLv(EnergyCoreMO.energyCoreData_.lv)
	local finishTips = UiUtil.label(CommonText[8004]):addTo(attnode)
	finishTips:setPosition(attnode:width() / 2, attnode:height() - 10)
	local finishAttr = json.decode(condition.finishAward)
	for index=1,#finishAttr do
	    local attr = finishAttr[index]
	    local attributeData = AttributeBO.getAttributeData(attr[1],attr[2])
	    local name = UiUtil.label(attributeData.name):addTo(attnode)
	    name:setAnchorPoint(cc.p(0,0.5))
	    name:setPosition(30 + (index - 1)* 130, finishTips:y() - 30)

	    local value = UiUtil.label("+"..attributeData.strValue,nil,COLOR[2]):rightTo(name)
	end
	self.m_attrnode = attnode
	self.m_attrnode:setVisible(EnergyCoreMO.energyCoreData_.section >= 5 and EnergyCoreMO.energyCoreData_.state ~= 1)

	local costData = EnergyCoreMO.queryMeltingCostByLv(EnergyCoreMO.energyCoreData_.lv)
	self.m_choseFrame = {}
	--周围的6个
	for index=1, 6 do
		local choseBg = display.newSprite(IMAGE_COMMON .. "energy_choose.png"):addTo(bg)
		choseBg:setPosition(100, detailBtn:y() - 105 - math.floor((index - 1) / 2)* 170)
		if index % 2 == 0 then
			choseBg:setPositionX(bg:width() - 100)
		end
		self.m_choseFrame[index] = choseBg
		--加号
		local lock = display.newSprite(IMAGE_COMMON .. "energy_lock.png"):addTo(choseBg):center()
		lock:setVisible(EnergyCoreMO.energyCoreData_.section < 5 or index > #costData or EnergyCoreMO.energyCoreData_.state == 1)
		self.m_choseFrame[index].lock = lock

		local normal = display.newSprite(IMAGE_COMMON .. "energy_add.png")
		local item = TouchButton.new(normal, nil, nil, nil, handler(self, self.clickCall)):addTo(choseBg)
		item:setPosition(choseBg:width() / 2, choseBg:height() / 2 + 5)
		local add = armature_create("nyhx_jiahao_lizi"):addTo(item):center()
	    add:getAnimation():playWithIndex(0)
		item:setScale(0.93)
		item.index = index
		item:setVisible(EnergyCoreMO.energyCoreData_.section >= 5 and index <= #costData and EnergyCoreMO.energyCoreData_.state ~= 1)
		self.m_choseFrame[index].item = item

		--名字
		local nameBg = display.newScale9Sprite(IMAGE_COMMON .. "energy_nameBg.png"):alignTo(choseBg, -80, 1)
		nameBg:setPreferredSize(cc.size(nameBg:width() + 10, nameBg:height()))
		nameBg:setVisible(EnergyCoreMO.energyCoreData_.section >= 5 and index <= #costData and EnergyCoreMO.energyCoreData_.state ~= 1)

		local info = EnergyCoreMO.getMeltingInfoByLoc(index)
		local costName = UiUtil.label(info.name,18,COLOR[6]):addTo(nameBg):center()
		self.m_choseFrame[index].nameBg = nameBg
		self.m_choseFrame[index].costName = costName
	end

	--熔炼
	local normal = display.newSprite(IMAGE_COMMON .. "energy_btn_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "energy_btn_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "energy_btn_disabled.png")
	local meltingBtn = MenuButton.new(normal, selected, disabled, handler(self, self.meltingCall)):addTo(bg)
	meltingBtn:setLabel(CommonText[8010][1])
	meltingBtn:setPosition(bg:getContentSize().width / 2 - 160, 230)
	meltingBtn:setEnabled(EnergyCoreMO.energyCoreData_.section >= 5 and EnergyCoreMO.energyCoreData_.state ~= 1)
	self.m_meltingBtn = meltingBtn

	--填充
	local normal = display.newSprite(IMAGE_COMMON .. "energy_btn_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "energy_btn_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "energy_btn_disabled.png")
	local fillBtn = MenuButton.new(normal, selected, disabled, handler(self, self.fillCall)):addTo(bg)
	fillBtn:setLabel(CommonText[8010][2])
	fillBtn:setPosition(bg:getContentSize().width / 2 + 160, 230)
	fillBtn:setEnabled(EnergyCoreMO.energyCoreData_.section >= 5 and EnergyCoreMO.energyCoreData_.state ~= 1)
	self.m_fillBtn = fillBtn
end

function EnergyCoreView:clickCenterCall(tag, sender)
	--判断是否满足解锁条件
	local condition = EnergyCoreMO.queryLvInfoByLv(EnergyCoreMO.energyCoreData_.lv) --下一级的信息
	local lv = EnergyCoreMO.queryOpenInfoBykind(condition.type)
	if lv < condition.cond then
		Toast.show(string.format(condition.desc,condition.cond)..CommonText[8019])
		return
	end

	local equips = EquipMO.getFreeEquipsAtPos()
	if #equips <= 0 then
		Toast.show(CommonText[8011])
		return
	end

	local function callBack()
		--刷新属性
		self.m_overflowExp:setVisible(EnergyCoreMO.energyCoreData_.redExp > 0)
		self.m_attrState = true
		self.m_choseNum = 1
		if self.m_arrowBtn then
			self.m_arrowBtn:setScaleX(1)
		end
		self:showAttr()
		--刷新展示
		local section = EnergyCoreMO.energyCoreData_.section
		if section <= 4 then
			self:showTop()
			UserBO.triggerFightCheck()
		else
			self:showTop()
			self:showUnlock()
		end
	end
	require("app.dialog.EnergyCoreAdvanceDialog").new(callBack):push()
end

--处理解锁升级等
function EnergyCoreView:showUnlock()
	self.m_closeBtn:setTouchEnabled(false)
	--6个方框
	local function playFrame()
		if #self.m_choseFrame > 0 then
			local costData = EnergyCoreMO.queryMeltingCostByLv(EnergyCoreMO.energyCoreData_.lv)
			for index=1,#self.m_choseFrame do
				if index <= #costData then
					local light = armature_create("nyhx_ronglian_6xiaokuang", nil, nil, function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
							self:updateFrameInfo()
						end
					end):addTo(self.m_choseFrame[index]):center()
				    light:getAnimation():playWithIndex(0)
				end
			end
		end
	end

	--播放解锁动画
	local function playUnlockAni()
		if self.m_chains then
	    	local light = armature_create("nyhx_zhongjiankuang",nil,nil,function (movementType, movementID, armature)
	    		if movementType == MovementEventType.COMPLETE then
		    		armature:removeSelf()
		    		self.m_choseBg:setVisible(false)

		    		self.m_chains:connectMovementEventSignal(function(movementType, movementID)
		    			if movementType == MovementEventType.COMPLETE then
		    				playFrame()
		    			end
		    		end)
		    		self.m_chains:getAnimation():playWithIndex(1)
	    		end
	    	end):addTo(self.m_choseBg)
	    	light:setPosition(self.m_choseBg:width() / 2, self.m_choseBg:height() / 2)
	        light:getAnimation():playWithIndex(0)
		end
	end
	playUnlockAni()
end

--处理6个框的刷新显示
function EnergyCoreView:updateFrameInfo()
	--显示按钮可点击
	self.m_meltingBtn:setEnabled(EnergyCoreMO.energyCoreData_.section >= 5)
	self.m_fillBtn:setEnabled(EnergyCoreMO.energyCoreData_.section >= 5)
	if EnergyCoreMO.energyCoreData_.section >= 5 then
		self.m_tips:setString(CommonText[8009])
		-- self.m_tips:setVisible(EnergyCoreMO.energyCoreData_.state ~= 1)
		if EnergyCoreMO.energyCoreData_.state == 1 then
			self.m_tips:setString(CommonText[4015])
		end
		self.m_attrnode:setVisible(EnergyCoreMO.energyCoreData_.section >= 5 and EnergyCoreMO.energyCoreData_.state ~= 1)
	end

	local costData = EnergyCoreMO.queryMeltingCostByLv(EnergyCoreMO.energyCoreData_.lv)
	for index=1,#self.m_choseFrame do
		local record = self.m_choseFrame[index]
		if index <= #costData then
			record.lock:setVisible(false)
			record.item:setVisible(true)
			record.nameBg:setVisible(true)
		end
	end

	UserBO.triggerFightCheck()

	self.m_closeBtn:setTouchEnabled(true)
end

--选择填充
function EnergyCoreView:clickCall(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.EnergyCoreChoseDialog").new(function (data)
		for num=1,#self.m_choseFrame do
			local record = self.m_choseFrame[num]
			if num == sender.index then
				local sp = UiUtil.createItemView(data[1],data[2])
				local resData = UserMO.getResourceData(data[1],data[2])
				record.item:setTouchSprite(sp)
				-- record.costName:setString(resData.name)
				record.costName:setColor(COLOR[1])
				self.m_costData[sender.index] = {v1 = data[1],v2 = data[2],v3 = data[3]}
			end
		end
	end,sender.index):push()
end

--熔炼
function EnergyCoreView:meltingCall(tag, sender)
	ManagerSound.playNormalButtonSound()
	local costData = EnergyCoreMO.queryMeltingCostByLv(EnergyCoreMO.energyCoreData_.lv)

	if table.nums(self.m_costData) == #costData then
		EnergyCoreBO.meltingEngergyCore(function ()
			self.m_costData = {}
			self:showUpgrade()
		end,self.m_costData)
	else
		Toast.show(CommonText[8012])
	end
end

function EnergyCoreView:showUpgrade()
	self.m_closeBtn:setTouchEnabled(false)
	local touchLayer = display.newColorLayer(ccc4(0, 0, 0, 0)):addTo(self:getBg(),999)
	touchLayer:setContentSize(cc.size(display.width, display.height))
	touchLayer:setPosition(0, 0)
	touchLayer:setTouchSwallowEnabled(true)

	touchLayer:setTouchEnabled(true)
	touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		return true
	end)

	local function showHeadChange()
		self.m_headBg.lv1:setVisible(false)
		self.m_headBg.lv2:setVisible(false)
		self.m_headBg.roll:setVisible(true)
		self.m_headBg.roll:getAnimation():playWithIndex(0)
		self.m_headBg.roll:connectMovementEventSignal(function(movementType, movementID) 
				if movementType == MovementEventType.COMPLETE then
					self.m_headBg.roll:removeSelf()
					self.m_headBg.lv1:setVisible(true)
					self.m_headBg.lv2:setVisible(true)

					self.m_headBg.change:setVisible(true)
					self.m_headBg.change:getAnimation():playWithIndex(0)
					self.m_headBg.change:connectMovementEventSignal(function(movementType, movementID) 
							if movementType == MovementEventType.COMPLETE then
								self.m_headBg.change:removeSelf()

								local lvInfo = EnergyCoreMO.queryLvInfoByLv(EnergyCoreMO.energyCoreData_.lv)
								self.m_headBg.lvName:setString(lvInfo.desc2)

								--判断是否满级满阶段了
							    self:showTop()
								self:showEnergy()
								self.m_attrState = true
								self.m_choseNum = 1
								self:showAttr()
								self.m_isPlay = false
								UserBO.triggerFightCheck()
								touchLayer:removeSelf()
								self.m_closeBtn:setTouchEnabled(true)
							end
						end)
				end
			end)
	end

	for index=1,#self.m_choseFrame do
		local item = self.m_choseFrame[index]
		--按钮位置
		local wPos = item:convertToWorldSpace(cc.p(item:getContentSize().width / 2,item:getContentSize().height / 2))
		local lPos = touchLayer:convertToNodeSpace(wPos)

		--等级名字位置
		local toWPos = self.m_headBg:convertToWorldSpace(cc.p(self.m_headBg:getContentSize().width / 2,self.m_headBg:getContentSize().height / 2 - 50))
		local ltPos = touchLayer:convertToNodeSpace(toWPos)

		local path = "animation/effect/nyhx_lizi.plist"
		local particleSys = cc.ParticleSystemQuad:create(path)
		particleSys:setPosition(lPos)
		particleSys:addTo(touchLayer)
	    particleSys:runAction(transition.sequence({cc.MoveTo:create(1, cc.p(ltPos.x, ltPos.y)), cc.CallFunc:create(function (sender)
	    	particleSys:removeSelf()
	    	self.m_isPlay = true
	    	if index == #self.m_choseFrame then
	    		showHeadChange()
	    	end

	    end)}))
	end
end

--属性面板展示
function EnergyCoreView:showAttr()
	if self.m_container then
		self.m_container:removeSelf()
		self.m_container = nil
	end

	local container = display.newNode():addTo(self:getBg(),99)
	container:setContentSize(self:getBg():getContentSize())
	self.m_container = container

	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "energycore_attrBg.png"):addTo(container,99)
	attrBg:setAnchorPoint(cc.p(0.5,1))
	attrBg:setPosition(container:width() + attrBg:width() / 2, container:height() / 2 + 220)
	self.m_attrBg = attrBg

	--按钮
	local btnBg = display.newSprite(IMAGE_COMMON .. "energy_core_btnBg.png"):rightTo(attrBg,40)
	btnBg:setAnchorPoint(cc.p(0.5,1))
	self.m_btns = {}
	for idx=1,FIGHT_FORMATION_POS_NUM do
		local normal = display.newSprite(IMAGE_COMMON .. "energy_core_btn_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "energy_core_btn_selected.png")
		local choseBtn = MenuButton.new(normal, selected, nil, handler(self, self.onChoseCallback)):addTo(btnBg)
		choseBtn.idx = idx
		choseBtn:setPosition(btnBg:width() / 2, btnBg:height() - 45 - (idx - 1) * 65)
		self.m_btns[idx] = choseBtn

		if self.m_choseNum == idx then
			local sprite = display.newSprite(IMAGE_COMMON .. "energy_core_btn_selected.png")
			choseBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "energy_core_btn_selected.png"))
		end

		local num = UiUtil.label(idx):addTo(choseBtn,99):center()
	end

	self:freshAttr()
end

function EnergyCoreView:onNextCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not self.m_container then return end
	if self.m_isMove then return end
	if self.m_attrState then
		self.m_isMove = true
		local eas = CCEaseBackInOut:create(cc.MoveBy:create(0.6,cc.p(-self.m_attrBg:width() - 85,0)))
		local callFun = cc.CallFunc:create(function()
			self.m_attrState = false
			sender:setScaleX(-1)
			self.m_isMove = false
		 end)
		self.m_container:runAction(transition.sequence({eas,callFun}))
		
	else
		self.m_isMove = true
		local eas = CCEaseBackInOut:create(cc.MoveBy:create(0.6,cc.p(self.m_attrBg:width() + 85,0)))
		local callFun = cc.CallFunc:create(function()
			self.m_attrState = true
			sender:setScaleX(1)
			self.m_isMove = false
		 end)
		self.m_container:runAction(transition.sequence({eas,callFun}))
	end
end

--刷新属性显示
function EnergyCoreView:freshAttr()
	local energyCoreAttr = EnergyCoreMO.getEnergyCoreAttrByPos(self.m_choseNum)
	--排序
	function sortFun(a,b)
		return a.id < b.id
	end

	table.sort(energyCoreAttr,sortFun)

	if self.m_attrBg then
		if self.m_attNode then
			self.m_attrBg:removeChildByTag(9, true)
		end
		local container = display.newNode():addTo(self.m_attrBg,1,9)
		container:setContentSize(self.m_attrBg:getContentSize())
		self.m_attNode = container
	end

	local attrBg = self.m_attNode

	local titleBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(attrBg)
	local title = UiUtil.label(string.format(CommonText[8025],CommonText[8024][self.m_choseNum])):addTo(titleBg)
	title:setAnchorPoint(cc.p(0,0.5))
	title:setPosition(40, titleBg:height() / 2)

	if #energyCoreAttr <= 0 then
		self.m_attrBg:setPreferredSize(cc.size(attrBg:width(), 140))
		titleBg:setPosition(titleBg:width() / 2, self.m_attrBg:height() - titleBg:height() / 2 - 18)

		local desc = UiUtil.label(CommonText[8022],nil,nil,cc.size(attrBg:width() - 20,0),ui.TEXT_ALIGN_LEFT):addTo(attrBg)
		desc:setAnchorPoint(cc.p(0,0.5))
		desc:setPosition(10,titleBg:y() - 50)
		return
	end
	
	self.m_attrBg:setPreferredSize(cc.size(attrBg:width(), 90 + #energyCoreAttr * 30))
	titleBg:setPosition(titleBg:width() / 2, self.m_attrBg:height() - titleBg:height() / 2 - 18)

	for index = 1,#energyCoreAttr do
		local addition = energyCoreAttr[index]
		local attributeData = addition

		local addLab = UiUtil.label(attributeData.name .. ":"):addTo(attrBg)
		addLab:setAnchorPoint(cc.p(0,0.5))
		addLab:setPosition(20, titleBg:y() - (index - 1)* 30 - 40)
		local value = UiUtil.label(attributeData.strValue,nil,COLOR[2]):rightTo(addLab,18)
	end
end

--属性界面选择查看
function EnergyCoreView:onChoseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	for idx=1,#self.m_btns do
		if sender.idx == idx then
			self.m_btns[idx]:setNormalSprite(display.newSprite(IMAGE_COMMON .. "energy_core_btn_selected.png"))
		else
			self.m_btns[idx]:setNormalSprite(display.newSprite(IMAGE_COMMON .. "energy_core_btn_normal.png"))
		end
	end
	self.m_choseNum = sender.idx

	self:freshAttr()
end

--一键填充
function EnergyCoreView:fillCall(tag, sender)
	ManagerSound.playNormalButtonSound()

	local lv = EnergyCoreMO.energyCoreData_.lv
	local costData = EnergyCoreMO.queryMeltingCostByLv(lv)
	local data =  EnergyCoreMO.queryOneFillByLv(lv)
	if table.nums(self.m_costData) > 0 then --不管单独选的，重置
		self.m_costData = {}
	end
	if table.nums(data) <= 0 then
		Toast.show(CommonText[8021])
		return
	end
	self.m_costData = data

	for index=1,#self.m_choseFrame do
		local record = self.m_choseFrame[index]
		if data[index] then
			local sp = UiUtil.createItemView(data[index].v1,data[index].v2)
			local resData = UserMO.getResourceData(data[index].v1,data[index].v2)
			record.item:setTouchSprite(sp)
			-- record.costName:setString(resData.name)
			record.costName:setColor(COLOR[1])
		end
	end
end

function EnergyCoreView:showTips(node)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			local des = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_6.png")
			local label = UiUtil.label(CommonText[8030],nil,nil,nil,ui.TEXT_ALIGN_LEFT)
			local exp = UiUtil.label(EnergyCoreMO.energyCoreData_.redExp,nil,COLOR[2],nil,ui.TEXT_ALIGN_LEFT)
			des:setPreferredSize(cc.size(label:width() + 20 + exp:width(),label:height() + 10))
			label:addTo(des):align(display.LEFT_TOP, 10, des:height() - 5)
			exp:addTo(des):align(display.LEFT_TOP, label:width() + 10, des:height() - 5)
			des:alignTo(node, node:height()*node:getScaleY() + 5, 1)
			if des:x() + des:width()/2 > des:getParent():width() then
				des:x(des:getParent():width() - des:width()/2 - 5)
			elseif des:x() - des:width()/2 < 0 then
				des:x(des:width()/2)
			end

			node.tipNode_ = des

			return true
		elseif event.name == "ended" then
			node.tipNode_:removeSelf()
		end
	end)
end

function EnergyCoreView:onExit()
	EnergyCoreView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_dianliu.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_dianliu.plist", IMAGE_ANIMATION .. "effect/nyhx_dianliu.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_bg_guangxiao.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_bg_guangxiao.plist", IMAGE_ANIMATION .. "effect/nyhx_bg_guangxiao.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_shandianqiu.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_shandianqiu.plist", IMAGE_ANIMATION .. "effect/nyhx_shandianqiu.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_jindutiao.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_jindutiao.plist", IMAGE_ANIMATION .. "effect/nyhx_jindutiao.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_suolian_suolian.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_suolian_suolian.plist", IMAGE_ANIMATION .. "effect/nyhx_suolian_suolian.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_ronglian_6xiaokuang.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_ronglian_6xiaokuang.plist", IMAGE_ANIMATION .. "effect/nyhx_ronglian_6xiaokuang.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_zhongjiankuang.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_zhongjiankuang.plist", IMAGE_ANIMATION .. "effect/nyhx_zhongjiankuang.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_jindutiao_fenge.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_jindutiao_fenge.plist", IMAGE_ANIMATION .. "effect/nyhx_jindutiao_fenge.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_nlzr.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_nlzr.plist", IMAGE_ANIMATION .. "effect/nyhx_nlzr.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_shuzi_gundong.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_shuzi_gundong.plist", IMAGE_ANIMATION .. "effect/nyhx_shuzi_gundong.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/dengjimingcheng_genghuan.pvr.ccz", IMAGE_ANIMATION .. "effect/dengjimingcheng_genghuan.plist", IMAGE_ANIMATION .. "effect/dengjimingcheng_genghuan.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/nyhx_jiahao_lizi.pvr.ccz", IMAGE_ANIMATION .. "effect/nyhx_jiahao_lizi.plist", IMAGE_ANIMATION .. "effect/nyhx_jiahao_lizi.xml")

end

return EnergyCoreView