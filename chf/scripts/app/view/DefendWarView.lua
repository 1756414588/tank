--
-- Author: Xiaohang
-- Date: 2016-05-06 16:40:46
--
local DefendWarView = class("DefendWarView", function()
	local node = display.newNode():size(display.width, display.height)
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function DefendWarView:ctor()
	armature_add(IMAGE_ANIMATION .. "battle/bt_die.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_die.plist", IMAGE_ANIMATION .. "battle/bt_die.xml")
	armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
	local t = display.newNode():size(display.width, 120)
	TouchButton.new(t, nil, nil, nil, function()end):addTo(self):pos(display.width/2,display.height-60)
	t = display.newSprite("image/item/t_jjc.jpg")
	t = TouchButton.new(t, nil, nil, nil, function()
			local effectDB = FortressMO.queryAttrById(6,1)
			require("app.dialog.DetailTextDialog").new({{{content="  "..effectDB.name.."："..effectDB._desc}}}):push()
		end):addTo(self,100):pos(display.width-80,display.height-145)
	t = armature_create("ui_item_light_orange", t:width() / 2 + 6, t:height() / 2):addTo(t, 10)
	t:getAnimation():playWithIndex(0)
	t:setScale(0.76)
	self:showMap()
end

function DefendWarView:showMap()
	self:performWithDelay(handler(self, self.tick), 1, true)
	local t = display.newSprite("image/bg/bg_combat_3.jpg"):addTo(self):align(display.LEFT_BOTTOM,0,0)
	t = display.newSprite("image/world/tile_ys.png")
	self.build = t
	TouchButton.new(t, nil, nil, nil, handler(self, self.showDetail))
		:addTo(self):pos(display.width/2,display.height/2+50)
	
	self.top = display.newSprite(IMAGE_COMMON.."fortress_top1.png"):addTo(self):align(display.CENTER_TOP, self:width()/2, self:height())
	local t = display.newSprite(IMAGE_COMMON.."info_bg_39.png")
		:addTo(self):align(display.LEFT_CENTER, 0, self:height()-90)
	t.label = UiUtil.label("",nil,COLOR[6])
		:addTo(t):align(display.LEFT_CENTER,5,t:height()/2)
	self.joinLabel = t
	t = display.newSprite(IMAGE_COMMON.."info_bg_39.png")
		:addTo(self):alignTo(t,-38,1)
	t.labelTitle = UiUtil.label("",nil,COLOR[12])
		:addTo(t):align(display.LEFT_CENTER,5,t:height()/2)
	t.label = UiUtil.label("",nil,COLOR[6])
		:addTo(t):rightTo(t.labelTitle)
	self.timeLabel = t
	t = UiUtil.button("btn_38_normal.png", "btn_38_selected.png", nil, handler(self, self.person))
		:addTo(self):pos(580,200)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_shop_normal.png")
	ScaleButton.new(normal, handler(self, self.goShop))
		:addTo(self):alignTo(t, -90)
	self.rankBtn = UiUtil.button("btn_50_normal.png", "btn_50_selected.png", nil, handler(self, self.onRank))
		:addTo(self,10):alignTo(t, 90, 1)
	self:tick()
end 

function DefendWarView:showInfo(data)
	if self.top then
		self.top:removeSelf()
		self.top = nil
		self.defendPro = nil
	end
	if self.winNode then
		self.winNode:removeSelf()
		self.winNode = nil
	end
	if data.title then
		self.top = display.newSprite(IMAGE_COMMON.."fortress_top1.png")
		if data.win then
			local t = UiUtil.label(CommonText[20010],nil,COLOR[12])
				:addTo(self.top):align(display.LEFT_CENTER,155,46)
			if data.win == "" then
				UiUtil.label(CommonText[20052],nil,COLOR[6]):addTo(self.top):rightTo(t)
			else
				UiUtil.label(data.win,nil,COLOR[2]):addTo(self.top):rightTo(t)
				self:showWin(data.win)
			end
			UiUtil.label(CommonText[20011],nil,COLOR[2])
				:addTo(self.top):alignTo(t, -22, true)
		else
			UiUtil.label(CommonText[432],nil,COLOR[2]):addTo(self.top):center()
		end
		UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil,handler(self,self.showDesc))
			:addTo(self.top):pos(self.top:width()-50,self.top:height()/2)
	else
		self.top = display.newSprite(IMAGE_COMMON.."fortress_top.png")
		local t = UiUtil.label(CommonText[20016], 30, COLOR[6]):addTo(self.top):pos(32,47)
		self.attackPro = ProgressBar.new(IMAGE_COMMON .. "bar_10.jpg", BAR_DIRECTION_HORIZONTAL, cc.size(152, 22), {bgName = IMAGE_COMMON .. "bar_bg_6.png", bgScale9Size = cc.size(152+ 4, 24)}):addTo(self.top)
			:rightTo(t)
		if self.hpBar_ then
			self.attackPro:setPercent(1-self.hpBar_:getPercent())
		else
			self.attackPro:setPercent(0)
		end
		t = UiUtil.label(CommonText[20017], 30, COLOR[3]):addTo(self.top):pos(self.top:width()-28,47)
		local p = 0
		if self.defendPro then p = self.defendPro:getPercent() end
		self.defendPro = ProgressBar.new(IMAGE_COMMON .. "bar_9.png", BAR_DIRECTION_HORIZONTAL, cc.size(152, 40), {bgName = IMAGE_COMMON .. "bar_bg_6.png", bgScale9Size = cc.size(152+ 4, 24)}):addTo(self.top)
			:leftTo(t)
		self.defendPro:setPercent(p)
	end
	self.top:addTo(self):align(display.CENTER_TOP, self:width()/2, self:height())
end

function DefendWarView:tick()
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	local s = tonumber(os.date("%S", t))
	self.joinLabel:hide()
	self.timeLabel:hide()
	--和平时期 周日20:15 - 周六19:00 
	if (week > FortressMO.war_week and week < FortressMO.peace_week)
		or (week == FortressMO.peace_week and h<FortressMO.peace_endh)
		or (week == FortressMO.war_week and 
			((h==FortressMO.war_starh and m>=FortressMO.war_starm+FortressMO.war_last) or h>FortressMO.war_starh)) then
		FortressBO.getWinParty(function(name)
				Notify.notify(LOCAL_FORTRESS_END)
				self:showInfo({title=true,win=name})
			end)
		self.state = FortressMO.TIME_PICE
		FortressBO.hasOver_ = true
		self.rankBtn:pos(54,self:height()-35)
		self.rankBtn:scale(0.85)
		return
	end
	--预热时期 周日19:30 -20:00
	if week == FortressMO.war_week and h == FortressMO.preheat_starh and
		m >=FortressMO.preheat_starhm and m<FortressMO.preheat_starhm+FortressMO.preheat_last then
		if self.state ~= FortressMO.TIME_PREHEAT then
			Notify.notify(LOCAL_FORTRESS_BUFF)
		end
		self.state = FortressMO.TIME_PREHEAT
		FortressBO.hasOver_ = nil
		FortressBO.getJoinParty(handler(self, self.setState))
		self:showInfo({})
		self.joinLabel:show()
		self.timeLabel:show()
		self.joinLabel.label:setString(self.camp == FortressBO.NOJOIN and CommonText[20012] or CommonText[20023])
		self.timeLabel.labelTitle:setString(CommonText[20013])
		self.timeLabel.label:setString(string.format("%02d:%02d",59-m,60-s))
		self.timeLabel.label:rightTo(self.timeLabel.labelTitle)
		self.rankBtn:pos(580,290)
		self.rankBtn:scale(1)
		return
	end
	--战争时期 周日20:00 - 20:15
	if week == FortressMO.war_week and h == FortressMO.war_starh and
		m >=FortressMO.war_starm and m<FortressMO.war_starm+FortressMO.war_last then
		self.state = FortressMO.TIME_WAR
		FortressBO.getJoinParty(function(data)
				self:setState(data)
				if not self.hasFirstInfo then
					self.hasFirstInfo = true
					FortressBO.GetDefend()
				end
			end)
		self:showInfo({})
		if not FortressBO.hasOver_ then
			self.joinLabel:show()
			self.timeLabel:show()
			self.joinLabel.label:setString(self.camp == FortressBO.NOJOIN and CommonText[20012] or CommonText[20015])
			self.timeLabel.labelTitle:setString(CommonText[20014])
			self.timeLabel.label:setString(string.format("%02d:%02d",14-m,60-s))
			self.timeLabel.label:rightTo(self.timeLabel.labelTitle)
			self:checkDefend(m)
		end
		self.rankBtn:pos(580,290)
		self.rankBtn:scale(1)
		return
	end
	self.rankBtn:pos(54,self:height()-35)
	self.rankBtn:scale(0.85)
	self:showInfo({title=true})
end

--检查防守进度
function DefendWarView:checkDefend(m)
	self.defendPro:setPercent(m/FortressMO.war_last)
end

function DefendWarView:showDesc()
	require("app.dialog.DetailTextDialog").new(DetailText.fortress):push()
end

function DefendWarView:showHp(event)
	local info = {nowNum=1,totalNum=1}
	local attack = nil
	if event then
		info = event.obj.info
		attack = event.obj.attack
	end
	if self.hpBar_ then
		self.hpBar_:removeSelf()
		self.hpBar_ = nil
		self.barBg:removeSelf()
		self.barBg = nil
	end
	local percent = info.nowNum/info.totalNum
	local bar = PointProgress.new(32,totalNum)
	if percent == 0 then
		FortressBO.winParty_ = nil
		FortressBO.hasOver_ = true
		Notify.notify(LOCAL_FORTRESS_END)
	end
	self.hpBar_ = bar
	self.barBg = display.newSprite(IMAGE_COMMON.."bar_bg_1.png")
		:addTo(self):pos(display.width/2,display.height/2+260)
	self.barBg:scaleTX(self.hpBar_:width()+8):scaleTY(self.hpBar_:height()+8)
	bar:addTo(self):pos(display.width/2,display.height/2+260)
	bar:setPercent(percent)
	--着火效果
	local fire = 0
	if percent <= 0.4 then
		fire = 4
	elseif percent <= 0.6 then
		fire = 6
	elseif percent <= 0.8 then
		fire = 8
	end
	if fire > 0 then
		if self.build.effect then self.build.effect:removeSelf() self.build.effect = nil end
		local name = "effect/yaosai_fire"..fire
		armature_add(IMAGE_ANIMATION .. name..".pvr.ccz", IMAGE_ANIMATION .. name..".plist", IMAGE_ANIMATION .. name..".xml")
		local effect = CCArmature:create("yaosai_fire"..fire)
	    effect:getAnimation():playWithIndex(0)
	    effect:addTo(self.build,10):center()
	    self.build.effect = effect
	end
	--攻击效果
	if not attack then return end
	local die = armature_create("bt_die", math.random(display.cx-160,display.cx+160),math.random(display.height/2-50,display.height/2+150),
		function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end)
    die:getAnimation():playWithIndex(0)
	die:addTo(self,10)
end

function DefendWarView:showWin(name)
	if self.hpBar_ then
		self.hpBar_:removeSelf()
		self.hpBar_ = nil
		self.barBg:removeSelf()
		self.barBg = nil
	end
	if self.build.effect then self.build.effect:removeSelf() self.build.effect = nil end
	local node = display.newNode()
	local l = UiUtil.label(name)
	node:size(l:width()+25,23)
	l:addTo(node):align(display.RIGHT_CENTER, node:width(), node:height()/2)
	local t = display.newSprite(IMAGE_COMMON .. "name_bg.png")
	    :addTo(node,-1):center()
	t:setScaleX(node:width()/t:width())
	display.newSprite(IMAGE_COMMON .. "icon_capture_person.png")
	    :addTo(node):pos(5,node:height()/2)
	node:addTo(self):align(display.CENTER,display.width/2,display.height/2+265)
	self.winNode = node
end

function DefendWarView:setState(data)
	if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then	
		local party = data[PartyMO.partyData_.partyId]
		if not party then
			self.camp = FortressBO.NOJOIN
			return
		end
		self.camp = party.rank == 1 and FortressBO.DEFEND or FortressBO.ATTACK
	else
		self.camp = FortressBO.NOJOIN
	end
end

function DefendWarView:showDetail()
	if not FortressMO.isOpen_ then 
		Toast.show(CommonText[20062])
		return
	end
	if self.state == FortressMO.TIME_PICE or FortressBO.hasOver_ then
		require("app.view.DefendReport").new():push()
	elseif self.state == FortressMO.TIME_PREHEAT or self.state == FortressMO.TIME_WAR then
		if self.camp == FortressBO.NOJOIN then
			Toast.show(CommonText[20056])
			return
		end
		if FortressBO.hasOver_ then
			Toast.show(CommonText[20051])
			return
		end
		require("app.dialog.FortressSet").new(self.state,self.camp):push()
	else
		Toast.show(CommonText[432])
	end
end

function DefendWarView:onRank()
	require("app.view.MonumentView").new():push()
end

function DefendWarView:person()
	require("app.view.FortressBuff").new(self.state,self.camp):push()
end

function DefendWarView:goShop()
	require("app.view.BagView").new(BAG_VIEW_FOR_SHOP):push()
end

function DefendWarView:onEnter()
	self.m_activityHandler = Notify.register(LOCAL_FORTRESS_INFO, handler(self, self.showHp))
end

function DefendWarView:onExit()
	armature_remove(IMAGE_ANIMATION .. "battle/bt_die.pvr.ccz", IMAGE_ANIMATION .. "battle/bt_die.plist", IMAGE_ANIMATION .. "battle/bt_die.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/yaosai_fire4.pvr.ccz", IMAGE_ANIMATION .. "effect/yaosai_fire4.plist", IMAGE_ANIMATION .. "effect/yaosai_fire4.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/yaosai_fire6.pvr.ccz", IMAGE_ANIMATION .. "effect/yaosai_fire6.plist", IMAGE_ANIMATION .. "effect/yaosai_fire6.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/yaosai_fire8.pvr.ccz", IMAGE_ANIMATION .. "effect/yaosai_fire8.plist", IMAGE_ANIMATION .. "effect/yaosai_fire8.xml")
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end


return DefendWarView
