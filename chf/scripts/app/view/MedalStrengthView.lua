--
-- Author: xiaoxing
-- Date: 2016-12-22 16:46:33
--

-- 配件强化

local MedalStrengthView = class("MedalStrengthView", UiNode)

COMPONENT_VIEW_FOR_UP = 1	   --温养
COMPONENT_VIEW_FOR_REFIT = 2   --打磨


-- keyId: 需要进行强化的配件的keyId
function MedalStrengthView:ctor(viewFor, keyId)
	MedalStrengthView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	self.m_viewFor = viewFor or 1
	self.m_keyId = keyId
end

function MedalStrengthView:onEnter()
	MedalStrengthView.super.onEnter(self)
	armature_add("animation/effect/ui_multiply_num.pvr.ccz", "animation/effect/ui_multiply_num.plist", "animation/effect/ui_multiply_num_2.xml")
	armature_add("animation/effect/lvup.pvr.ccz", "animation/effect/lvup.plist", "animation/effect/lvup.xml")
	self:setTitle(CommonText[20165][self.m_viewFor])  -- 强化

	local medal = MedalBO.medals[self.m_keyId]
	local md = MedalMO.queryById(medal.medalId)
	local function createDelegate(container, index)
		self.chooseIndex = index
		if index == 1 then  -- 强化
			self:showStrength(container)
		elseif index == 2 then -- 改造
			self:showRemake(container)
		elseif index == 3 then -- 精炼
			self:showRefine(container)
		end
	end

	local function clickBaginDelegate(index)
		if index == 2 then
			if md.refit == 0 then
				Toast.show(CommonText[20166][4])
				return false
			end
		elseif index == 3 then
			if md.transform == -1 then
				Toast.show(CommonText[1753])
				return false
			end
		end
		return true
	end

	local pages
	--勋章精炼
	if UserMO.queryFuncOpen(UFP_MEDAL_REFINE) then
		pages = CommonText[20165]
	else
		pages = CommonText[1759]
	end

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function MedalStrengthView:onExit()
	armature_remove("animation/effect/ui_multiply_num.pvr.ccz", "animation/effect/ui_multiply_num.plist", "animation/effect/ui_multiply_num_2.xml")
	armature_remove("animation/effect/lvup.pvr.ccz", "animation/effect/lvup.plist", "animation/effect/lvup.xml")
end

function MedalStrengthView:updateUI()
	self.m_pageView:setPageIndex(self.chooseIndex)
end

function MedalStrengthView:showTips(data,node)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			if not data then
				local des = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_6.png")
				local label = UiUtil.label(CommonText[1738],nil,nil,cc.size(200,0),ui.TEXT_ALIGN_LEFT)
				des:setPreferredSize(cc.size(220,label:height() + 10))
				label:addTo(des):align(display.LEFT_TOP, 10, des:height() - 5)
				des:alignTo(node, node:height()*node:getScaleY() + 25, 1)
				if des:x() + des:width()/2 > des:getParent():width() then
					des:x(des:getParent():width() - des:width()/2 - 5)
				elseif des:x() - des:width()/2 < 0 then
					des:x(des:width()/2)
				end
				node.tipNode_ = des
			else
				local des = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_6.png")
				local label1 = UiUtil.label(self.medalHero and data.skillName or data.skillName.."("..CommonText[100012][1]..")",nil,COLOR[12],cc.size(240,0),ui.TEXT_ALIGN_LEFT):addTo(des)
				label1:setPosition(10,des:getContentSize().height-30)
				label1:setAnchorPoint(0,0)
				local label2 = UiUtil.label(data.skillDesc,nil,nil,cc.size(240,0),ui.TEXT_ALIGN_LEFT):addTo(des)
				label2:setPosition(10,des:getContentSize().height - 60)
				label2:setAnchorPoint(0,0)
				des:setPreferredSize(cc.size(260,label1:height() + label2:height() + 15))
				des:alignTo(node, node:height()*node:getScaleY() + 25, 1)
				if des:x() + des:width()/2 > des:getParent():width() then
					des:x(des:getParent():width() - des:width()/2 - 5)
				elseif des:x() - des:width()/2 < 0 then
					des:x(des:width()/2)
				end
				node.tipNode_ = des
			end
			return true
		elseif event.name == "ended" then
			node.tipNode_:removeSelf()
		end
	end)
end

-- 
function MedalStrengthView:showStrength(container)
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 620))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 16 - infoBg:getContentSize().height / 2)
	--详情按钮
	local detail_normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local detail_selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(detail_normal, detail_selected, nil, function()
			require("app.dialog.DetailTextDialog").new(DetailText.medal):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 50,infoBg:getContentSize().height - 20 - detailBtn:getContentSize().height / 2)
	self.infoBg = infoBg
	--升级buff。

	self.medalHero = HeroMO.isStaffHeroPutById(HERO_ID_MEDAL_SOLDIER)
	local buffItem = display.newNode()
	if self.medalHero then
		buffItem = display.newSprite("image/item/skillid_"..self.medalHero.skillId..".jpg"):addTo(infoBg)
	else
		buffItem = display.newSprite("image/item/skill_off_5.jpg"):addTo(infoBg)
	end

	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(buffItem):center()
	buffItem:setPosition(infoBg:getContentSize().width - 150,infoBg:getContentSize().height - 120)
	buffItem:setScale(0.7)
	local heroDB = HeroMO.queryHero(109)
	self.hero = HeroMO.getHeroById(HERO_ID_MEDAL_SOLDIER)
	self:showTips(self.hero,buffItem)

	local medal = MedalBO.medals[self.m_keyId]
	local md = MedalMO.queryById(medal.medalId)
	local maxLevel = MedalMO.queryUpMaxLevel(md.quality)

	local attrs = MedalBO.getPartAttrData(self.m_keyId)

	local nxtAttrData = nil
	if medal.upLv < maxLevel then
		local t = clone(medal)
		t.upLv = t.upLv + 1
		nxtAttrData = MedalBO.getPartAttrData(nil,nil,t)
	end

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_medal_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 20 - strengthLabel:getContentSize().height / 2)

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrs.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	local view = UiUtil.createItemView(ITEM_KIND_MEDAL_ICON, medal.medalId, {data = medal}):addTo(infoBg)
	UiUtil.createItemDetailButton(view)
	view:setPosition(70, infoBg:getContentSize().height - 105)

	local t = ui.newTTFLabel({text = md.medalName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 68, color = COLOR[md.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	t:setAnchorPoint(cc.p(0, 0.5))
	--最大等级后就显示
	if MedalBO.medals[self.m_keyId].refitLv == 10 then
		local list={}
		table.insert(list,{{content="打磨等级已达10级，激活特效：此勋章升级属性升级提升15%"}})
		local upProp=AttributeBO.getAttributeData(md.attr1,md.a1*(medal.upLv+1)*0.15)
		local l="当前"..attrs[md.attr1].name.."属性额外提升："..upProp.strValue
		table.insert(list,{{content=l}})
		if md.attr2 > 0 then
			upProp=AttributeBO.getAttributeData(md.attr2,md.a2*(medal.upLv+1)*0.15)
			--upProp=(md.a2*(medal.upLv+1)+md.b2*10)*0.15
			l="当前"..attrs[md.attr2].name.."属性额外提升："..upProp.strValue
			table.insert(list,{{content=l}}) 
		end
	
		local normal = display.newSprite(IMAGE_COMMON .. "btn_act_science.png")
		ScaleButton.new(normal, function()
			require("app.dialog.DetailTextDialog").new(list):push()
		end):rightTo(t, 5)
	end

	local att = attrs[md.attr1]
	t = UiUtil.label(att.name .."："):alignTo(t, -25, 1)
	local l = UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
	if nxtAttrData then
		l = display.newSprite(IMAGE_COMMON.."icon_arrow_up.png"):rightTo(l)
		UiUtil.label(nxtAttrData[md.attr1].strValue,nil,COLOR[2]):rightTo(l)
	end
	if md.attr2 > 0 then
		att = attrs[md.attr2]
		t = UiUtil.label(att.name.."："):alignTo(t, -25, 1)
		l = UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
		if nxtAttrData then
			l = display.newSprite(IMAGE_COMMON.."icon_arrow_up.png"):rightTo(l)
			UiUtil.label(nxtAttrData[md.attr2].strValue,nil,COLOR[2]):rightTo(l)
		end
	end
	t = UiUtil.label(CommonText[20164][2]):alignTo(t, -25, 1)
	l = UiUtil.label(medal.upLv,nil,COLOR[2]):rightTo(t)
	if nxtAttrData then
		l = display.newSprite(IMAGE_COMMON.."icon_arrow_up.png"):rightTo(l)
		UiUtil.label(medal.upLv + 1,nil,COLOR[2]):rightTo(l)
	end
	local strengthBtn = nil
	local maxTime = UserMO.querySystemId(11)
	t = UiUtil.label(CommonText[20166][1]):addTo(infoBg):align(display.LEFT_CENTER, 20, infoBg:getContentSize().height - 210)
	-- local bar = ProgressBar.new(IMAGE_COMMON .. "pro_hp.png", BAR_DIRECTION_HORIZONTAL, cc.size(562,28), {bgName = IMAGE_COMMON .. "pro_hpbg.png", bgScale9Size = cc.size(562,28)}):addTo(infoBg)
	-- 			:pos(infoBg:width()/2,t:y() - 35)
	display.newSprite(IMAGE_COMMON.."pro_hpbg.png"):addTo(infoBg):pos(infoBg:width()/2,t:y() - 35)

	local bar = CCProgressTimer:create(display.newSprite(IMAGE_COMMON.."pro_hp.png"))
	bar:setType(kCCProgressTimerTypeBar)
	bar:setMidpoint(ccp(0,0))
	bar:setBarChangeRate(ccp(1,0))
	bar:addTo(infoBg):pos(infoBg:width()/2,t:y() - 35)

	local pro = UiUtil.label("0/"..maxTime):addTo(infoBg):pos(bar:x(),bar:y())
	local leftLabel = UiUtil.label("00:00:00"):alignTo(t, 380)
	local isActivtyMedalOfInfluence = ActivityCenterBO.getActivityById(ACTIVITY_ID_MEDAL)
	if isActivtyMedalOfInfluence then
		leftLabel:setVisible(false)
		local function peopleCallback(tar, sender)
			local ActMedalUpDialog = require("app.dialog.ActMedalUpDialog")
			ActMedalUpDialog.new():push()
		end
		local people_normal = display.newSprite(IMAGE_COMMON .. "people_1.png")
		local people_selected = display.newSprite(IMAGE_COMMON .. "people_1.png")
		local peopleBtn = MenuButton.new(people_normal, people_selected, nil,peopleCallback):addTo(infoBg,10)
		peopleBtn:setAnchorPoint(cc.p(1,1))
		peopleBtn:setPosition(infoBg:width(),detailBtn:y() - detailBtn:height() * 0.4)
		local act_bg = display.newSprite(IMAGE_COMMON.."info_bg_101.png"):addTo(infoBg, 9)
		act_bg:setAnchorPoint(cc.p(1,1))
		act_bg:setPosition(peopleBtn:x() - peopleBtn:width() * 0.5, peopleBtn:y() - peopleBtn:height() * 0.45)
		local lbtimes = UiUtil.label(CommonText[1092]):addTo(act_bg)
		lbtimes:setPosition(act_bg:width() * 0.45, act_bg:height() * 0.5)
		lbtimes:setRotation(-5)
	end
	local clearBtn = nil
	--需要消耗的材料
	--因为表里面已经配到90级，但是现在最高等级是80级，所以加一个判断
	local medalUp=nil
	if medal.upLv<80 then
		medalUp = MedalMO.queryUp(md.quality, medal.upLv+1)
	end

	--用来判断资源是否够，按钮是否可按
	local material={} --所需的三种材料的数量
	local have={} --拥有的材料的数量
	if medalUp then
		for k,v in ipairs(json.decode(medalUp.cost)) do
			material[k]=v[3]
			local own = UserMO.getResource(v[1],v[2])
			have[k]=own
		end
	end

	local function tick()
		local num = math.floor(MedalBO.cd - ManagerTimer.getTime())
		if num < 0 then 
			num = 0 
			infoBg:stopAllActions()
		end
		pro:setString(num .."/"..maxTime)
		bar:setPercentage((num/maxTime)*100)
		local data = ManagerTimer.time(num)
		leftLabel:setString(string.format("%02d:%02d:%02d", data.hour,data.minute,data.second))
		leftLabel:setColor(num > maxTime and COLOR[6] or cc.c3b(255,255,255))
		clearBtn:setVisible(not isActivtyMedalOfInfluence and num > maxTime)
		if strengthBtn then
			strengthBtn:setEnabled(num <= maxTime and medalUp ~= nil and have[1] >= material[1] and have[2] >= material[2] and have[3] >= material[3])
			akeystrengthBtn:setEnabled(num <= maxTime and medalUp ~= nil and have[1] >= material[1] and have[2] >= material[2] and have[3] >= material[3])
		end
	end
	clearBtn = UiUtil.button("btn_accel_normal.png", "btn_accel_selected.png", nil, function()
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[20168], function()
			if UserMO.consumeConfirm then
				local temp = MedalBO.cd - ManagerTimer.getTime()
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText[10022],math.ceil(temp/60),CommonText.item[1][1]), function()
						MedalBO.buyCd(function()
								MedalBO.cd = ManagerTimer.getTime() - 1
								tick()
							end)
					end):push()
			else
				MedalBO.buyCd(function()
						MedalBO.cd = ManagerTimer.getTime() - 1
						tick()
					end)
			end
		end):push()
	end):scale(0.6):rightTo(leftLabel, 10)
	tick()
	infoBg:performWithDelay(tick, 1, 1)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(infoBg:width()-10, line:getContentSize().height))
	line:setPosition(infoBg:width()/2, pro:y() - 40)

	t = UiUtil.label(CommonText[20166][2]):alignTo(t, -115, 1)

	-- 强化
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	strengthBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onStrengthCallback)):addTo(container)
	strengthBtn:setPosition(container:getContentSize().width / 2-160 , container:getContentSize().height - 700)
	strengthBtn:setLabel(CommonText[20165][1])
	strengthBtn:setEnabled(math.floor(MedalBO.cd - ManagerTimer.getTime()) < maxTime and medalUp ~= nil and have[1] >= material[1] and have[2] >= material[2] and have[3] >= material[3])
	--一键强化按钮
	local akey_normal = display.newSprite(IMAGE_COMMON.."btn_1_normal.png")
	local akey_selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png") 
	local akey_disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	akeystrengthBtn = MenuButton.new(akey_normal,akey_selected,akey_disabled,handler(self,self.onAkeyStrengthCallback)):addTo(container)
	akeystrengthBtn:setPosition(container:getContentSize().width/2 + 160, container:getContentSize().height - 700)
	akeystrengthBtn:setLabel(CommonText[1145])
	akeystrengthBtn:setEnabled(math.floor(MedalBO.cd - ManagerTimer.getTime()) < maxTime and medalUp ~= nil and have[1] >= material[1] and have[2] >= material[2] and have[3] >= material[3])
	if not medalUp then
		UiUtil.label(CommonText[20166][6],nil,COLOR[6]):addTo(infoBg):pos(infoBg:width()/2,240)
		return
	end

	local x,y,ex = 70,222,190
	for k,v in ipairs(json.decode(medalUp.cost)) do
		local tx,ty = x + (k-1)*ex,y
		local view = UiUtil.createItemView(v[1], v[2], {count = v[3]}):addTo(infoBg):pos(tx,ty):scale(0.9)
		UiUtil.createItemDetailButton(view)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local t = UiUtil.label(propDB.name,nil,COLOR[propDB.quality or 1]):addTo(infoBg):align(display.LEFT_CENTER,tx+50,ty+32)
		t = UiUtil.label(UiUtil.strNumSimplify(v[3])):alignTo(t, -32, 1)
		local own = UserMO.getResource(v[1],v[2])
		UiUtil.label("/"..UiUtil.strNumSimplify(own),nil,COLOR[own<v[3] and 6 or 2]):rightTo(t)
	end

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(infoBg:width()-50, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(infoBg:width()-46, 26)}):addTo(infoBg)
				:pos(infoBg:width()/2,130)
	bar:setPercent(medal.upExp / medalUp.exp)
	local pro = UiUtil.label(medal.upExp .."/"..medalUp.exp):addTo(infoBg):pos(bar:x(),bar:y())
	UiUtil.label(CommonText[20167]):alignTo(pro, -40, 1)
    UiUtil.label(CommonText[20227]):alignTo(pro, -80, 1)
end

function MedalStrengthView:showRemake(container)
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 620))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 16 - infoBg:getContentSize().height / 2)
	--详情按钮
	local detail_normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local detail_selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(detail_normal, detail_selected, nil, function()
			require("app.dialog.DetailTextDialog").new(DetailText.medal):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 50,infoBg:getContentSize().height - 20 - detailBtn:getContentSize().height / 2)
	local medal = MedalBO.medals[self.m_keyId]
	local md = MedalMO.queryById(medal.medalId)
	local maxLevel = MedalMO.queryRefitMaxLevel(md.quality)

	local attrs = MedalBO.getPartAttrData(self.m_keyId)

	local nxtAttrData = nil
	if medal.refitLv < maxLevel then
		local t = clone(medal)
		t.refitLv = t.refitLv + 1
		nxtAttrData = MedalBO.getPartAttrData(nil,nil,t)
	end

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_medal_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 20 - strengthLabel:getContentSize().height / 2)

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrs.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	local view = UiUtil.createItemView(ITEM_KIND_MEDAL_ICON, medal.medalId, {data = medal}):addTo(infoBg)
	UiUtil.createItemDetailButton(view)
	view:setPosition(70, infoBg:getContentSize().height - 105)

	local t = ui.newTTFLabel({text = md.medalName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 135, y = infoBg:getContentSize().height - 68, color = COLOR[md.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	t:setAnchorPoint(cc.p(0, 0.5))

	local att = attrs[md.attr1]
	t = UiUtil.label(att.name .."："):alignTo(t, -25, 1)
	local l = UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
	if nxtAttrData then
		l = display.newSprite(IMAGE_COMMON.."icon_arrow_up.png"):rightTo(l)
		UiUtil.label(nxtAttrData[md.attr1].strValue,nil,COLOR[2]):rightTo(l)
	end
	if md.attr2 > 0 then
		att = attrs[md.attr2]
		t = UiUtil.label(att.name.."："):alignTo(t, -25, 1)
		l = UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
		if nxtAttrData then
			l = display.newSprite(IMAGE_COMMON.."icon_arrow_up.png"):rightTo(l)
			UiUtil.label(nxtAttrData[md.attr2].strValue,nil,COLOR[2]):rightTo(l)
		end
	end

	if md.refit == 0 then
		UiUtil.label(CommonText[20166][4],nil,COLOR[6]):alignTo(t, -25, 1)
		return
	end
	t = UiUtil.label(CommonText[20164][3]):alignTo(t, -25, 1)
	l = UiUtil.label(medal.refitLv,nil,COLOR[2]):rightTo(t)
	if nxtAttrData then
		l = display.newSprite(IMAGE_COMMON.."icon_arrow_up.png"):rightTo(l)
		UiUtil.label(medal.refitLv + 1,nil,COLOR[2]):rightTo(l)
	end

	t = UiUtil.label(CommonText[20166][3]):alignTo(strengthLabel, -180, 1)

	-- 强化
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local strengthBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onRefitCallback)):addTo(container)
	strengthBtn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 700)
	strengthBtn:setLabel(CommonText[20165][2])

	local medalUp = MedalMO.queryRefit(md.quality, medal.refitLv + 1)
	strengthBtn:setEnabled(medalUp ~= nil)
	if not medalUp then
		UiUtil.label(CommonText[20166][5],nil,COLOR[6]):addTo(infoBg):pos(infoBg:width()/2,240)
		return
	end
	--需要消耗的材料
	local x,y,ex,ey = 70,332, 275, 112
	for k,v in ipairs(json.decode(medalUp.cost)) do
		local tx,ty = x + (k-1)%2*ex,y - math.floor((k-1)/2)*ey
		local view = UiUtil.createItemView(v[1], v[2], {count = v[3]}):addTo(infoBg):pos(tx,ty):scale(0.9)
		UiUtil.createItemDetailButton(view)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local t = UiUtil.label(propDB.name,nil,COLOR[propDB.quality or 1]):addTo(infoBg):align(display.LEFT_CENTER,tx+50,ty+32)
		t = UiUtil.label(UiUtil.strNumSimplify(v[3])):alignTo(t, -32, 1)
		local own = UserMO.getResource(v[1],v[2])
		UiUtil.label("/"..UiUtil.strNumSimplify(own),nil,COLOR[own<v[3] and 6 or 2]):rightTo(t)
	end
end

--精炼
function MedalStrengthView:showRefine(container)
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 620))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 16 - infoBg:getContentSize().height / 2)

	--详情按钮
	local detail_normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local detail_selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(detail_normal, detail_selected, nil, function()
			require("app.dialog.DetailTextDialog").new(DetailText.medalRefine):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 50,infoBg:getContentSize().height - 20 - detailBtn:getContentSize().height / 2)

	local medal = MedalBO.medals[self.m_keyId]
	local md = MedalMO.queryById(medal.medalId)
	local maxLevel = MedalMO.queryRefitMaxLevel(md.quality)

	local attrs = MedalBO.getPartAttrData(self.m_keyId)

	local nxtAttrData = nil
	if medal.refitLv < maxLevel then
		local t = clone(medal)
		t.refitLv = t.refitLv + 1
		nxtAttrData = MedalBO.getPartAttrData(nil,nil,t)
	end

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_medal_strength.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(20, infoBg:getContentSize().height - 20 - strengthLabel:getContentSize().height / 2)

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrs.strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	local beganView = UiUtil.createItemView(ITEM_KIND_MEDAL_ICON, medal.medalId, {data = medal}):addTo(infoBg)
	UiUtil.createItemDetailButton(beganView)
	beganView:setPosition(100, infoBg:getContentSize().height - 115)

	--显示箭头
	local arrow = display.newSprite(IMAGE_COMMON .. "advance_arrow.png"):addTo(infoBg)
	arrow:setAnchorPoint(cc.p(0,0.5))
	arrow:setPosition(beganView:getPositionX() + 120,beganView:getPositionY())

	if md and md.transform ~= -1 then
		local endMd = MedalMO.queryById(md.transform)
		local endMedal = clone(medal)
		endMedal.medalId = md.transform
		local endView = UiUtil.createItemView(ITEM_KIND_MEDAL_ICON,md.transform ,{data = endMedal}):addTo(infoBg) -- transform
		endView:setPosition(400,infoBg:getContentSize().height - 115)
		UiUtil.createItemDetailButton(endView)

		--名字
		local beganName = ui.newTTFLabel({text = md.medalName,font = G_FONT,size = FONT_SIZE_MEDIUM,x = beganView:getPositionX(), y = beganView:getPositionY() - beganView:getContentSize().height/2,color = COLOR[md.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		beganName:setAnchorPoint(cc.p(0.5,1))
		beganName:setScale(0.8)

		local endName = ui.newTTFLabel({text = endMd.medalName,font = G_FONT,size = FONT_SIZE_MEDIUM,x = endView:getPositionX(), y = endView:getPositionY() - endView:getContentSize().height/2,color = COLOR[md.quality + 2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		endName:setAnchorPoint(cc.p(0.5,1))
		endName:setScale(0.8)
	else
		if md.quality == 5 then
			local desc = ui.newTTFLabel({text = CommonText[1741], font = G_FONT, size = FONT_SIZE_MEDIUM, x = 400, y = infoBg:getContentSize().height - 115, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		else
			UiUtil.label(CommonText[1740],nil,COLOR[12]):addTo(infoBg):pos(400,infoBg:getContentSize().height - 105)
		end
	end

	--分节线
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 203)

	-- 消耗
	local label = ui.newTTFLabel({text = CommonText[1742][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 24, y = infoBg:getContentSize().height - 227, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	-- note
	local label = ui.newTTFLabel({text = CommonText[1742][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	--需要消耗的材料
	if md.transformCost then
		local x,y,ex,ey = 70,infoBg:height() - 295, 275, 112
		for k,v in ipairs(json.decode(md.transformCost)) do
			local tx,ty = x + (k-1)%2*ex,y - math.floor((k-1)/2)*ey
			local view = UiUtil.createItemView(v[1], v[2]):addTo(infoBg):pos(tx,ty):scale(0.82)
			UiUtil.createItemDetailButton(view)
			local costDB = UserMO.getResourceData(v[1], v[2])
			local t = UiUtil.label(costDB.name,nil,COLOR[costDB.quality or 1]):addTo(infoBg):align(display.LEFT_CENTER,tx+65,ty+32)
			t = UiUtil.label(UiUtil.strNumSimplify(v[3])):alignTo(t, -32, 1)
			local own = UserMO.getResource(v[1],v[2])
			UiUtil.label("/"..UiUtil.strNumSimplify(own),nil,COLOR[own<v[3] and 6 or 2]):rightTo(t)
		end
	end

	--点击进阶按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
    local advanceBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onRefineCallback)):addTo(container)
    advanceBtn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 700)
    advanceBtn:setLabel(CommonText[1739])
    advanceBtn.md = md
    advanceBtn:setEnabled(md.quality ~= 5)
    
end

--精炼
function MedalStrengthView:onRefineCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	local function getResult(md)
		if md then
			Toast.show(CommonText[1750])
			self.m_keyId = md.keyId
			self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
		end
	end
	MedalBO.advanceMedal(getResult,self.m_keyId,MedalBO.medals[self.m_keyId].pos)
end

function MedalStrengthView:onStrengthCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- PartBO.asynUpPart(doneUpPart, self.m_keyId, self.m_settingNum)
	MedalBO.upMedal(self.m_keyId,MedalBO.medals[self.m_keyId].pos,function(state)
		self:updateUI()
		if state > 0 then
	    	local critEffect = CCArmature:create(state == 2 and "ui_multiply_num_2" or "lvup")
		    critEffect:getAnimation():playWithIndex(0)
		    critEffect:runAction(transition.sequence({cc.DelayTime:create(1.2),cc.FadeOut:create(0.5),cc.CallFuncN:create(function()
		            	critEffect:removeSelf()
		            end)}))
		    critEffect:setPosition(self.infoBg:width() / 2 + 160, 128)
		    self.infoBg:addChild(critEffect)
		end
	end)
end

function MedalStrengthView:onAkeyStrengthCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	--self:updateUI()
	MedalBO.aKeyUpMedal(self.m_keyId,MedalBO.medals[self.m_keyId].pos,function(state)
		self:updateUI()
		gprint("MedalBO.luckyHitCount==",MedalBO.luckyHitCount)
		if MedalBO.luckyHitCount then
			for i=1,MedalBO.luckyHitCount do
				local critEffect = CCArmature:create("ui_multiply_num_2")
				critEffect:setScale(0.8)
				critEffect:getAnimation():playWithIndex(0)
		    	critEffect:runAction(transition.sequence({cc.FadeOut:create(1),cc.CallFuncN:create(function()
		            	critEffect:removeSelf()
					end)}))
				--critEffect:runAction()
		    	critEffect:setPosition(self.infoBg:width() / 2 + 120, 128 + (i-1) * 30)
		    	self.infoBg:addChild(critEffect)
			end
		end
		if state then
			if state == 1 then
				Toast.show(CommonText[1144][1])
			elseif state == 2 then
				Toast.show(CommonText[1144][2])
			else
				Toast.show(CommonText[1144][3])
				local critEffect = CCArmature:create("lvup")
				critEffect:setScale(0.7)
		    	critEffect:getAnimation():playWithIndex(0)
		    	critEffect:runAction(transition.sequence({cc.DelayTime:create(MedalBO.luckyHitCount*0.5),cc.FadeOut:create(0.5),cc.CallFuncN:create(function()
		            	critEffect:removeSelf()
		            end)}))
		    	critEffect:setPosition(self.infoBg:width() / 2 + 200, 128)
				self.infoBg:addChild(critEffect)
			end
		end
	end)
end

function MedalStrengthView:onRefitCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	MedalBO.refitMedal(self.m_keyId,MedalBO.medals[self.m_keyId].pos,function(state)
		self:updateUI()
	end)
end

return MedalStrengthView
