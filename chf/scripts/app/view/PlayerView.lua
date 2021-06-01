
-- 玩家信息view

local PlayerView = class("PlayerView", UiNode)

PLAYER_VIEW_DETAIL = 1
PLAYER_VIEW_SKILL = 2
PLAYER_VIEW_WEAPONRY = 3
PLAYER_VIEW_PORTRAIT = 4

function PlayerView:ctor(uiEnter, viewFor)
	uiEnter = uiEnter or UI_ENTER_BOTTOM_TO_UP
	viewFor = viewFor or PLAYER_VIEW_DETAIL
	self.m_viewFor = viewFor
	PlayerView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
	self.m_scheme = WeaponryMO.getEmptyWeaponryScheme() --军备空套装
end

function PlayerView:onEnter()
	PlayerView.super.onEnter(self)

	armature_add(IMAGE_ANIMATION .. "effect/nengliangcao.pvr.ccz", IMAGE_ANIMATION .. "effect/nengliangcao.plist", IMAGE_ANIMATION .. "effect/nengliangcao.xml")

	-- 部队
	self:setTitle(CommonText[101])

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	local function createDelegate(container, index)
		if index == 1 then  -- 详情
			self:showDetail(container)
		elseif index == 2 then -- 技能
			self:showSkill(container)
		elseif index == 3 then -- 军备
			self:showWeaponry(container)
			--self:showPortrait(container,1)
		elseif index == 4 then --挂件
			self:showMyPortrait(container)
			--self:showPortrait(container,2)
		end
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate(index)
		if index == 3 then
			if not UserMO.queryFuncOpen(UFP_WEAPONRY) then
				Toast.show(CommonText[1600][2] .. CommonText[1722])
				return false
			end
			if UserMO.level_ < WeaponryMO.level_ then -- 大于20级
				Toast.show(string.format(CommonText[290],WeaponryMO.level_,CommonText[1600][2]))
				return false
			end
		end
		return true
	end

	--  "详情", "技能", "头像"
	local pages = {CommonText[102], CommonText[103], CommonText[1600][2], CommonText[104]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_firstSkill = true


	self.m_WeaponryUpdateHandler = Notify.register(LOCLA_PART_EVENT, handler(self, self.onWeaponryUpdate))
	self.m_WeaponryLockHandler = Notify.register(LOCAL_WEAPONRY_LOCK, handler(self, self.onWeaponryUpdate))
	--触发引导
	-- NewerBO.showNewerGuide()
end

function PlayerView:onExit()
	package.loaded["app.scroll.PortraitTableView"] = nil
	package.preload["app.scroll.PortraitTableView"] = nil
	armature_remove(IMAGE_ANIMATION .. "effect/nengliangcao.pvr.ccz", IMAGE_ANIMATION .. "effect/nengliangcao.plist", IMAGE_ANIMATION .. "effect/nengliangcao.xml")
	if self.m_WeaponryUpdateHandler then
		Notify.unregister(self.m_WeaponryUpdateHandler)
		self.m_WeaponryUpdateHandler = nil
	end

	if self.m_WeaponryLockHandler then
		Notify.unregister(self.m_WeaponryLockHandler)
		self.m_WeaponryLockHandler = nil
	end
end

function PlayerView:update(dt)
	if self.m_pageView and self.m_pageView:getPageIndex() == 1 then
		local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())
		if container and container.powerBar_ then  -- 更新显示能量
			local count = UserMO.getResource(ITEM_KIND_POWER)
			container.powerBar_:setPercent(count / POWER_MAX_VALUE)

			if count < POWER_MAX_VALUE then -- 有CD时间
				container.powerBar_:setLabel(count .. "/" .. POWER_MAX_VALUE .. "(" .. UiUtil.strBuildTime(UserBO.getCycleTime(ITEM_KIND_POWER)) .. ")")
				if container.powerBar_.armature and container.powerBar_.armature.showAni ~= 0 then
					container.powerBar_.armature:getAnimation():playWithIndex(0)
					container.powerBar_.armature.showAni = 0
				end
			else
				container.powerBar_:setLabel(count .. "/" .. POWER_MAX_VALUE)
				if container.powerBar_.armature and container.powerBar_.armature.showAni ~= 1 then
					container.powerBar_.armature:getAnimation():playWithIndex(1)
					container.powerBar_.armature.showAni = 1
				end
			end
		end
	end
end

function PlayerView:showDetail(container)
	-- container:removeAllChildren()
	local infoColor = COLOR[3]

	-- 头像
	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, UserMO.portrait_, {pendant = UserMO.pendant_}):addTo(container, 2)
	itemView:setScale(0.85)
	itemView:setPosition(122, container:getContentSize().height - 104)

	local vip = UiUtil.createItemSprite(ITEM_KIND_VIP, UserMO.vip_):addTo(itemView)
	vip:setPosition(itemView:getContentSize().width / 2, 0)
	vip:setScale(1 / itemView:getScale())

	-- 属性背景框
	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	attrBg:setPreferredSize(cc.size(366, 180))
	attrBg:setPosition(420, container:getContentSize().height - 15 - attrBg:getContentSize().height / 2)

	-- 名称
	container.nickNameLabel_ = ui.newTTFLabel({text = UserMO.nickName_, font = G_FONT, size = FONTS_SIZE_MEDIUM, x = 16, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	container.nickNameLabel_:setAnchorPoint(cc.p(0, 0.5))
	container.nickNameLabel_:setString(UserMO.nickName_)

	local sex = UiUtil.createItemSprite(ITEM_KIND_SEX, UserMO.sex_):addTo(attrBg)
	sex:setPosition(container.nickNameLabel_:getPositionX() + container.nickNameLabel_:getContentSize().width + 20, container.nickNameLabel_:getPositionY())

	local pos = ui.newTTFLabel({text = "(" .. WorldMO.pos_.x .. "." .. WorldMO.pos_.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = sex:getPositionX() + 20, y = sex:getPositionY(), color = infoColor, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	pos:setAnchorPoint(cc.p(0, 0.5))

	-- 军团
	local label = ui.newTTFLabel({text = CommonText[105] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 16, y = attrBg:getContentSize().height - 55, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 军团名
	local partyName = ""
	if PartyBO.getMyParty() then partyName = PartyBO.getMyPartyName()
	else partyName = CommonText[108] end

	local name = ui.newTTFLabel({text = partyName, font = G_FONT, size = FONT_SIZE_SMALL, x = 75, y = label:getPositionY(), color = infoColor, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 战斗力
	local fight = display.newSprite(IMAGE_COMMON .. "label_fight.png"):addTo(attrBg)
	fight:setAnchorPoint(cc.p(0, 0.5))
	fight:setPosition(210, label:getPositionY())

	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(UserMO.fightValue_), font = "fnt/num_2.fnt"}):addTo(attrBg)
	value:setPosition(fight:getPositionX() + fight:getContentSize().width + 5, fight:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 荣誉
	local label = ui.newTTFLabel({text = CommonText[106] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 16, y = attrBg:getContentSize().height - 90, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	container.honorLabel_ = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 75, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	container.honorLabel_:setAnchorPoint(cc.p(0, 0.5))
	container.honorLabel_:setString(UserMO.getResource(ITEM_KIND_HONOR))

	-- 等级
	container.lvLabel_ = ui.newTTFLabel({text = "LV." .. UserMO.level_, font = G_FONT, size = FONT_SIZE_SMALL, x = 16, y = attrBg:getContentSize().height - 125, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	container.lvLabel_:setAnchorPoint(cc.p(0, 0.5))

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_5.png", BAR_DIRECTION_HORIZONTAL, cc.size(196, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(196 + 4, 26)}):addTo(attrBg)
	bar:setPosition(75 + bar:getContentSize().width / 2, container.lvLabel_:getPositionY())

	if UserBO.isLordFullLevel() then -- 满级了
		bar:setPercent(0)
	else
		local nxtLord = UserMO.queryLordByLevel(UserMO.level_ + 1)

		bar:setPercent(UserMO.getResource(ITEM_KIND_EXP) / nxtLord.needExp)
		bar:setLabel(UiUtil.strNumSimplifySign(UserMO.getResource(ITEM_KIND_EXP)) .. "/" .. UiUtil.strNumSimplifySign(nxtLord.needExp))
	end

	local resData = UserMO.getResourceData(ITEM_KIND_POWER)

	-- 能量
	local label = ui.newTTFLabel({text = resData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 16, y = attrBg:getContentSize().height - 160, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_9.png", BAR_DIRECTION_HORIZONTAL, cc.size(196, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(196 + 4, 26)}):addTo(attrBg)
	bar:setPosition(75 + bar:getContentSize().width / 2, label:getPositionY())
	container.powerBar_ = bar

	local armature = armature_create("nengliangcao", bar:getContentSize().width / 2 , bar:getContentSize().height / 2 + 3):addTo(bar , 5)
	armature:setScaleX(bar:width() / armature:width() * 1.35)
	container.powerBar_.armature = armature

	container.powerBar_.armature.showAni = -1

	-- local function doneBuyPower()
	-- 	Loading.getInstance():unshow()
	-- end

	-- local function gotoBuyPower()
	-- 	local coinCount = UserMO.getResource(ITEM_KIND_COIN)
	-- 	if coinCount < VipBO.getPowerBuyCoin() then
	-- 		require("app.dialog.CoinTipDialog").new():push()
	-- 		return
	-- 	end

	-- 	Loading.getInstance():show()
	-- 	UserBO.asynBuyPower(doneBuyPower)
	-- end

	local function buyCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.dialog.BuyPawerDialog").new():push()
		
		-- if UserMO.powerBuy_ >= VipBO.getPowerBuyCount() then  -- vip等级不足
		-- 	Toast.show(CommonText[366][1])
		-- 	return
		-- end

		-- local resData = UserMO.getResourceData(ITEM_KIND_POWER)

		-- if POWER_BUY_NUM + UserMO.power_ > POWER_MAX_HAVE then
		-- 	Toast.show(CommonText[20007])
		-- 	return
		-- end
		-- if UserMO.consumeConfirm then
		-- 	local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		-- 	CoinConfirmDialog.new(string.format(CommonText[112], VipBO.getPowerBuyCoin(), POWER_BUY_NUM, resData.name), function() gotoBuyPower() end, nil):push()
		-- else
		-- 	gotoBuyPower()
		-- end
	end

	-- 能量购买按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local energyBtn = MenuButton.new(normal, selected, nil, buyCallback):addTo(attrBg)
	energyBtn:setPosition(320, 35)

	local PlayerDetailTableView = require("app.scroll.PlayerDetailTableView")
	local view = PlayerDetailTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 202)):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
	container.tableView_ = view
end

function PlayerView:showSkill(container)
	local function onUseBag()
		local function doneUserProp(awards)
			Loading.getInstance():unshow()
			
			local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK_BAG)
			Toast.show(CommonText[84] .. resData.name)

			UiUtil.showAwards(awards)

			local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())
			local offset = nil
			if container.tableView then
				offset = container.tableView:getContentOffset()
			end
			self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
			local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())
			
			if container.tableView and offset then
				container.tableView:setContentOffset(offset)
			end
		end

		local PropUseDialog = require("app.dialog.PropUseDialog")
		PropUseDialog.new(PROP_ID_SKILL_BOOK_BAG, doneUserProp):push()
	end

	local SkillTableView = require("app.scroll.SkillTableView")
	local view = SkillTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 160), self.m_firstSkill):addTo(container)
	view:addEventListener("CHOSEN_SKILL_EVENT", handler(self, self.onChosenSkill))
	view:addEventListener("USE_SKILL_BAG_EVENT", onUseBag)
	view:setPosition(0, 160)
	view:reloadData()
	container.tableView = view

	-- 重置
	local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local resetBtn = MenuButton.new(normal, selected, nil, handler(self, self.onResetSkillCallback)):addTo(container)
	resetBtn:setPosition(140, 50)
	resetBtn:setLabel(CommonText[118],  {y = resetBtn:getContentSize().height / 2 + 14})

	local tag = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(resetBtn)
	tag:setPosition(resetBtn:getContentSize().width / 2 - 34, resetBtn:getContentSize().height / 2 - 14)

	local cost = ui.newBMFontLabel({text = SKILL_RESET_TAKE_COIN, font = "fnt/num_1.fnt"}):addTo(resetBtn)
	cost:setAnchorPoint(cc.p(0, 0.5))
	cost:setPosition(tag:getPositionX() + tag:getContentSize().width / 2 + 5, tag:getPositionY())

	-- 购买
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local buyBtn = MenuButton.new(normal, selected, nil, handler(self, self.onShopCallback)):addTo(container)
	buyBtn:setPosition(container:getContentSize().width - 140, 50)
	buyBtn:setLabel(CommonText[119])

	local count = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK)
	-- 当前拥有x个技能书
	local desc = ui.newTTFLabel({text = CommonText[63] .. count .. CommonText[120] .. CommonText[121], font = G_FONT, size = FONT_SIZE_SMALL, x = buyBtn:getPositionX(), y = buyBtn:getPositionY() + 65, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)

	self.m_firstSkill = false -- 已经进入过一次skill标签页
end

function PlayerView:showWeaponry(container)
	--换装
	-- 仓库
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_11_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_11_selected.png')
	local warehouseBtn = MenuButton.new(normal, selected, nil, function()
			ManagerSound.playNormalButtonSound()
			Toast.show(CommonText[1723])
		end):addTo(container,2)
	warehouseBtn:setLabel(CommonText[1724])
	warehouseBtn:setPosition(320,container:height()-465)

	--详情
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.DetailTextDialog").new(DetailText.WeaponryInfo):push() 
		end):addTo(container,2):pos(540,container:height()-465)

	local titleBg = display.newSprite(IMAGE_COMMON .. "weaponryBg.jpg"):addTo(container)
	--titleBg:setScale(0.85)
	titleBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - titleBg:getContentSize().height/2)

	local cell = container
	local index = 1
	local componentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell)
	componentBg:setPreferredSize(cc.size( container:getContentSize().width - 20, 115))
	componentBg:setPosition(container:getContentSize().width / 2,  container:getContentSize().height  - 600)

	local tank = display.newSprite(IMAGE_COMMON .. "Weaponry1.png"):addTo(container)
	tank:setAnchorPoint(cc.p(0.5, 0))
	tank:setScale(0.9)
	tank:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 500)

	self.unequips = {}
	self.equips = WeaponryMO.getShowMedals()
	local unequips = WeaponryMO.getFreeMedals()
	for index = 1 , #unequips do
		local equip = unequips[index]
		local posid = WeaponryMO.queryById(equip.equip_id).pos
		if not self.unequips[posid] then
			self.unequips[posid] = {}
		end
		self.unequips[posid][#self.unequips[posid] + 1] = equip
	end


	local function showPositionComponent(posIndex, animated)
		local config = IMAGE_COMMON .."item_weapon_" .. posIndex .. ".jpg"
		local itemView = nil
		local pos =	posIndex
			
		if self.equips[pos] then
			-- 穿上的装备
			local data = self.equips[pos]
			if not self.m_scheme.leq then self.m_scheme.leq = {} end
			self.m_scheme.leq[pos] = {keyId = data.keyId, pos = data.pos}
			itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,data.equip_id,{data = data})
			itemView.data = data

			local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
			lockIcon:setScale(0.5)
			lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
			lockIcon:setVisible(data.isLock)
		else
			self.m_scheme.leq[pos] = {keyId = 0, pos = pos}
			-- 仓库中的装备
			itemView = display.newSprite(config)
			display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(itemView):center()

			if self.unequips[pos] then
				display.newSprite(IMAGE_COMMON.."icon_plus.png"):addTo(itemView):center()
			end
		end
		local hasBigState = WeaponryBO.checkListUpWeaponryAtPos(self.equips[pos], self.unequips[pos])
		if hasBigState then
			local tipstate = display.newSprite(IMAGE_COMMON .. "icon_red_point.png"):addTo(itemView, 10)
			tipstate:setScale(0.75)
			tipstate:setPosition(itemView:width() - tipstate:width() * 0.5 ,itemView:height() - tipstate:height() * 0.5)
		end

		itemView:addTo(container,0,pos)
		local normal = display.newNode():size(itemView:width(),itemView:height())
		normal:setAnchorPoint(cc.p(0.5, 0.5))
		normal = TouchButton.new(normal, nil, nil, nil, handler(self, self.clickCall)):addTo(itemView,0,pos):center()
		normal.data = itemView.data
		normal.index = posIndex

		itemView.index = posIndex
		itemView:setScale(0.78)

		
		if posIndex == 1 then itemView:setPosition(90, container:getContentSize().height - 70)
		elseif posIndex == 2 then itemView:setPosition(container:getContentSize().width -90, container:getContentSize().height - 70)
		elseif posIndex == 3 then itemView:setPosition(90, container:getContentSize().height - 70 - 90)
		elseif posIndex == 4 then itemView:setPosition(container:getContentSize().width - 90, container:getContentSize().height - 70- 90)
		elseif posIndex == 5 then itemView:setPosition(90, container:getContentSize().height - 70 - 90*2)
		elseif posIndex == 6 then itemView:setPosition(container:getContentSize().width - 90, container:getContentSize().height - 70- 90*2)
		elseif posIndex == 7 then itemView:setPosition(90, container:getContentSize().height - 70 - 90*3)
		elseif posIndex == 8 then itemView:setPosition(container:getContentSize().width - 90, container:getContentSize().height - 70 - 90*3)
		end


		if not cell.components then cell.components = {} end
		cell.components[posIndex] = itemView

		return cell
	end

	for posIndex = 1, 8 do
		showPositionComponent(posIndex)
	end

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(container)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(15, container:getContentSize().height - 515)

	-- 配件强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "Label_weaponry.png"):addTo(container)
	strengthLabel:setAnchorPoint(cc.p(0, 0.5))
	strengthLabel:setPosition(400, titleBg:getPositionY())
	-- 增加属性
	local title = ui.newTTFLabel({text = CommonText[160], font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)
	local attrList = {ATTRIBUTE_INDEX_ATTACK+1,ATTRIBUTE_INDEX_HP+1,ATTRIBUTE_INDEX_IMPALE,ATTRIBUTE_INDEX_DEFEND}
	-- 配件的各个属性值
	local x,y,ex,ey = 50,75,260,45
	local attrlist = {} 
	for k ,v in pairs(self.equips) do
		local data = WeaponryMO.queryById(v.equip_id)
		local temps = json.decode(data.atts)
		for index=1, #temps do
			local temp = temps[index]
			local dex = temp[1]
			if dex == attrList[1] or dex == attrList[2] or 
				dex == attrList[3] or dex == attrList[4] then
				if not attrlist[dex] then
					attrlist[dex] = temp[2]
				else
					attrlist[dex] = attrlist[dex] + temp[2]
				end
			end
		end
	end
	for k,v in ipairs(attrList) do
		local attvalue = attrlist[v] or 0
		local attr = AttributeBO.getAttributeData(v, attvalue)
		local tx, ty = x + math.floor((k-1)/2)*ex,y - (k-1)%2*ey
		local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = attr.attrName}):addTo(componentBg):pos(tx,ty)
		local name = ui.newTTFLabel({text = attr.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(componentBg)
		name:setAnchorPoint(cc.p(0, 0.5))
		name:setColor(COLOR[11])
		name:setPosition(itemView:getPositionX() + 30, itemView:getPositionY())
		local value = ui.newTTFLabel({text = "+" .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(componentBg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	local strengthValue = 0
	for k ,v in pairs(self.equips) do
		local attrsex = WeaponryBO.getPartAttrShow(v.keyId)
		strengthValue = strengthValue + attrsex
	end
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(strengthValue), font = "fnt/num_2.fnt"}):addTo(strengthLabel:getParent())
	value:setPosition(strengthLabel:getPositionX() + strengthLabel:getContentSize().width + 5, strengthLabel:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 军备打造
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local warehouseBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCombatCallback)):addTo(container)
	warehouseBtn:setLabel(CommonText[1600][3])
	warehouseBtn:setPosition(110, 40)

	-- 军备套装
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	--[[local suitBtn = MenuButton.new(normal, selected, nil, function ()
		ManagerSound.playNormalButtonSound()
		WeaponryBO.getAallWeaponryScheme(function ()
			require("app.dialog.ChoseWeaponryDialog").new(self.m_scheme, handler(self, self.onWeaponryUpdate)):push()
		end)
	end):addTo(container)
	suitBtn:setLabel(CommonText[1616])]]-- 不做删除，有用
	local suitBtn = MenuButton.new(normal, selected, nil, handler(self, self.onWeaponrySetAttr)):addTo(container)
	suitBtn:setLabel(CommonText[1627])
	suitBtn:setPosition(container:getContentSize().width / 2, 40)
	local show = WeaponryMO.isHasSecondWeaponrys()
	suitBtn:setVisible(show)

	-- 仓库
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local warehouseBtn = MenuButton.new(normal, selected, nil, handler(self, self.onWarehouseCallback)):addTo(container)
	warehouseBtn:setLabel(CommonText[1600][1])
	warehouseBtn:setPosition(container:getContentSize().width - 110, 40)

	self.m_warehouseBtn = warehouseBtn

	self:onUpdateTip()
end

--军备设置第几套洗练属性
function PlayerView:onWeaponrySetAttr(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.WeaponrySetAttrDialog").new(sender):push()
end

function PlayerView:onCombatCallback(tag, sender)
	--军备打造界面
	ManagerSound.playNormalButtonSound()

	if UserMO.level_ < WeaponryMO.level_ then
		Toast.show(string.format(CommonText[1614],WeaponryMO.level_))
		return
	end

	require("app.view.WeaponryView").new(1):push()
end

function PlayerView:clickCall(tag, sender)
	local selcetIndex = sender.index
	local outdata = sender.data
	if outdata then
		--判断是否等级足够
		if not WeaponryMO.canUseByLv(outdata.equip_id) then
			--穿戴等级不足
			Toast.show(CommonText[1725])
			return
		end
	else
		local unequips = WeaponryMO.getFreeMedals()
		local quality = 0
		for index =1 , #unequips do
			local equip = unequips[index]
			local posdata = WeaponryMO.queryById(equip.equip_id)
			if posdata.pos == selcetIndex then
				if posdata.quality > quality then
					quality = posdata.quality
					outdata = equip
				-- elseif posdata.quality == quality then
				-- 	local strengthValue1 = WeaponryBO.getPartAttrShow(outdata.keyId)
				-- 	local strengthValue2 = WeaponryBO.getPartAttrShow(equip.keyId)
				-- 	if strengthValue2 > strengthValue1 then
				-- 		quality = posdata.quality
				-- 		outdata = equip
				-- 	end
				end		
			end
		end
	end

	if outdata then
		require("app.dialog.WeaponryDialog").new(outdata):push()
	end
end

function PlayerView:onWeaponryUpdate()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

function PlayerView:onWarehouseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.WeaponryWarehouseView").new():push()
end


function PlayerView:showMyPortrait(container)
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(container)
	tag:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tag:getContentSize().height / 2)

	local size = cc.size(container:getContentSize().width, container:getContentSize().height - 58)

	local pages = {CommonText[104], CommonText[20144]}

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 200 + 60, size.height + 34)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 75+60, size.height + 34)
		end
		button:setLabel(pages[index])
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 200+60, size.height + 34)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 75+60, size.height + 34)
		end
		button:setLabel(pages[index], {color = COLOR[11]})

		return button
	end

	local function createDelegate(container, index)
		if index == 1 then  -- 挂件
			self:showPortrait(container,1)
		elseif index == 2 then -- 头像
			self:showPortrait(container,2)
		end
	end

	local function clickDelegate(container, index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = container:getContentSize().width / 2, y = size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}, hideDelete = true}):addTo(container, 2)
	pageView:setPageIndex(1)

end

function PlayerView:showPortrait(container,kind)
	-- 头像
	local itemView = nil

	-- 显示获取条件
	local conditionLabel = ui.newTTFLabel({text = "此处显示条件============================", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = container:getContentSize().height - 40, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(360,0)})
		:addTo(container,2):align(display.LEFT_TOP, 230, container:getContentSize().height - 40)

	-- 挂件预览
	local previewLabel = ui.newTTFLabel({text = CommonText[20145][kind], font = G_FONT, size = FONT_SIZE_SMALL, x = 230, y = container:getContentSize().height - 120, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(container,2)
	previewLabel:setAnchorPoint(cc.p(0, 0.5))

	-- 显示时间
	local standardLabel = ui.newTTFLabel({text = "未解锁", font = G_FONT, size = FONT_SIZE_SMALL, x = 450, y = container:getContentSize().height - 120, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container,2)
	standardLabel:setAnchorPoint(cc.p(0, 0.5))

	local function updateHeader( portraitId, pendantId )
		if itemView then
			itemView:removeSelf()
			itemView = nil
		end
		itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, portraitId, {pendant = pendantId}):addTo(container, 2)
		itemView:setScale(0.7)
		itemView:setPosition(122, container:getContentSize().height - 80)

		local standard = false
		local pendant = nil
		conditionLabel:setVisible(true)
		previewLabel:setVisible(true)
		standardLabel:setVisible(true)		
		if (kind == 2 and pendantId == UserMO.pendant_) or (kind == 1 and portraitId == UserMO.portrait_) then
			previewLabel:setVisible(false)
			standard = true
		else
			previewLabel:setVisible(true)
		end
		if kind == 2 then
			pendant = PendantMO.queryPendantById(pendantId)
			if pendant.type == 1 then
				standard = UserMO.level_ >= pendant.value
			elseif pendant.type == 2 then
				standard = UserMO.vip_ >= pendant.value
			elseif pendant.type == 3 then
				standard = PendantBO.pendants_[pendantId]
			end
		elseif kind == 1 then
			pendant = PendantMO.queryPortrait(portraitId)
			if pendant.type == 1 then
				standard = true
			elseif pendant.type == 2 then
				standard = UserMO.vip_ >= pendant.value
			elseif pendant.type == 3 then
				standard = PendantBO.portraits_[portraitId]
			end
		end
		standardLabel:removeAllChildren()
		if standard then
			conditionLabel:setString(pendant.desc)
			standardLabel:setColor(COLOR[2])
			standardLabel:setString(CommonText[20135])
			if pendant.type == 3 then
				local left = standard.endTime - ManagerTimer.getTime()
				if not standard.foreverHold and left <= 0 then
					standardLabel:setString(CommonText[20063])
					standardLabel:setColor(COLOR[6])
				elseif not standard.foreverHold then
					UiUtil.label("("..math.floor(left/(24*3600)).."d)",FONT_SIZE_SMALL,COLOR[12])
						:addTo(standardLabel):align(display.LEFT_CENTER,standardLabel:width(),standardLabel:height()/2)
				end
			end
		else
			conditionLabel:setString(pendant.tip)
			standardLabel:setColor(COLOR[6])
			standardLabel:setString(CommonText[929])
		end
	end

	updateHeader(UserMO.portrait_, UserMO.pendant_)

	local PortraitTableView = require("app.scroll.PortraitTableView")
	local view = PortraitTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 152 - 110),kind):addTo(container)
	view:addEventListener("CHOSEN_PORTRAIT_EVENT", function ( event )
		updateHeader(event.portraitId, event.pendantId)
	end)

	view:setPosition(0, 110)
	view:reloadData()

	local function doneSetPortrait()
		Loading.getInstance():unshow()

		Toast.show(CommonText[382][1])

		updateHeader(UserMO.portrait_, UserMO.pendant_)
		
		Notify.notify(LOCAL_PORTRAIT_EVENT)
	end

	local function onOkCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local portraitId = view:getPortraitId()
		local pendantId = view:getPendantId()
		local pendant = nil
		if kind == 2 then
			pendant = PendantMO.queryPendantById(pendantId)
		elseif kind == 1 then
			pendant = PendantMO.queryPortrait(portraitId)
		end

		if pendant.type == 2 and pendant.value > UserMO.vip_ then
			Toast.show(CommonText[382][2])  -- VIP不足
			return
		end
		if kind == 2 and pendant.type == 1 then
			if UserMO.level_ < pendant.value then
				Toast.show(CommonText[382][3])  -- 指挥官等级不足
				return
			end
		end
		if pendant.type == 3 then -- 专属
			local standard = false
			if kind == 1 then
				standard = PendantBO.portraits_[portraitId]
			elseif kind == 2 then
				standard = PendantBO.pendants_[pendantId]
			end
			if not standard then
				Toast.show(CommonText[929]) -- 未解锁
				return 
			else
				if not standard.foreverHold then
					local left = standard.endTime - ManagerTimer.getTime()
					if left <= 0 then
						Toast.show(CommonText[20063]) -- 已过期
						return 
					end
				end
			end
		end
		Loading.getInstance():show()
		UserBO.asynSetPortrait(doneSetPortrait, portraitId, pendantId)
	end

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local buyBtn = MenuButton.new(normal, selected, nil, onOkCallback):addTo(container)
	buyBtn:setPosition(container:getContentSize().width / 2, 50)
	buyBtn:setLabel(CommonText[1])
end

function PlayerView:onChosenSkill(event)
	if self.m_isSkillUpgrade then return end

	local skillId = event.skillId

	local function doneUpSkill()
		Loading.getInstance():unshow()
		local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())
		local offset = nil
		if container.tableView then
			offset = container.tableView:getContentOffset()
		end
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
		local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())
		
		if container.tableView and offset then
			container.tableView:setContentOffset(offset)
		end

		ManagerSound.playSound("science_skill_create")
		self.m_isSkillUpgrade = false
	end

	self.m_isSkillUpgrade = true

	Loading.getInstance():show()
	SkillBO.asynUpSkill(doneUpSkill, skillId)
end

function PlayerView:onResetSkillCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneReset()
		Loading.getInstance():unshow()
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end

	local coinData = UserMO.getResourceData(ITEM_KIND_COIN)

	local function gotoReset()
		local coinCount = UserMO.getResource(ITEM_KIND_COIN)
		if coinCount < SKILL_RESET_TAKE_COIN then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		Loading.getInstance():show()
		SkillBO.asynResetSkill(doneReset)
	end

	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[246], SKILL_RESET_TAKE_COIN, coinData.name, PropMO.getPropName(PROP_ID_SKILL_BOOK)), function() gotoReset() end):push()
	else
		gotoReset()
	end
end

function PlayerView:onShopCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.BagView").new(BAG_VIEW_FOR_SHOP, {shopPageIndex = 4}):push()
end

function PlayerView:doCommand(command, callback)
	if command == "player_upCommand" then
		if self.m_pageView:getPageIndex() ~= PLAYER_VIEW_DETAIL then
			self.m_pageView:setPageIndex(PLAYER_VIEW_DETAIL)
		end
		local container = self.m_pageView:getContainerByIndex(PLAYER_VIEW_DETAIL)
		if container.tableView_ then
			container.tableView_:onCommandCallback()
		end
	elseif command == "player_skill" then
		self.m_pageView:setPageIndex(PLAYER_VIEW_SKILL)
	elseif command == "player_portrait" then
		self.m_pageView:setPageIndex(PLAYER_VIEW_PORTRAIT)
	end
end

function PlayerView:refreshUI()
	if self.m_pageView and self.m_pageView:getPageIndex() == 3 then
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
		self:onUpdateTip()
	end
end

function PlayerView:onUpdateTip()
	local medals = WeaponryMO.getFreeMedals()
	if #medals > 0 then
		UiUtil.showTip(self.m_warehouseBtn, #medals)
	else
		UiUtil.unshowTip(self.m_warehouseBtn)
	end
end


return PlayerView