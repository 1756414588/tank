--
-- Author: wangzhen
-- Date: 2017-04-20 14:32:06
--

local WeaponryMenuTableView = class("WeaponryMenuTableView", TableView)
local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")

function WeaponryMenuTableView:ctor(size, chosenId,_node)
	WeaponryMenuTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 90)

	--读取所有装备类型
	self.RankConfig =  WeaponryMO.queryWeaponry()
	
	chosenId = chosenId or 1

	for index = 1, table.getn(self.RankConfig) do
		if index == chosenId then
			self.m_chosenIndex = index
		end
	end
	gprint("WeaponryMenuTableView:ctor:", self.m_chosenIndex)

	self.parent = _node
end

function WeaponryMenuTableView:numberOfCells()
	return #self.RankConfig
end

function WeaponryMenuTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function WeaponryMenuTableView:createCellAtIndex(cell, index)
	WeaponryMenuTableView.super.createCellAtIndex(self, cell, index)
	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_62_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_62_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenCallback))
	local idx = self.RankConfig[index]	
	btn.index = index
	cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	cell.btn = btn

	if self.m_chosenIndex == index then
		local sprite = display.newSprite(IMAGE_COMMON .. "btn_62_selected.png")
		btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_62_selected.png"))
	end

	local labelBg = display.newSprite(IMAGE_COMMON .."title_infoBg.png"):addTo(cell,2)
	labelBg:setPosition(self.m_cellSize.width / 2+ 38 ,65)

	local t = UiUtil.label(idx.name,nil,COLOR[idx.quality or 1]):addTo(labelBg):align(display.LEFT_CENTER,10,15)
	local labelBg = display.newSprite(IMAGE_COMMON .."title_infoBg.png"):addTo(cell,2)
	labelBg:setPosition(self.m_cellSize.width / 2+ 38 ,30)
	local t = UiUtil.label( "拥有*"..WeaponryMO.getWeaponryCount(idx.id),nil,COLOR[idx.quality or 1]):addTo(labelBg):align(display.LEFT_CENTER,10,15)

	local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,idx.id,{data = nil}):addTo(cell,2)
	itemView:setPosition( 50 ,45)
	itemView:setScale(0.7)

	local md = WeaponryMO.queryById(idx.id)
	local upt = WeaponryMO.queryUp(md.formula)
	if index == #self.RankConfig and upt.level > UserMO.level_ then
		--加锁
		local suo = display.newSprite(IMAGE_COMMON .."icon_lock_1.png"):addTo(cell,3)
		suo:setPosition(50, self.m_cellSize.height / 2)

		btn.isCanBuild = false
	else
		btn.isCanBuild = true
	end

	return cell
end

function WeaponryMenuTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if sender.isCanBuild == false then
		local md = WeaponryMO.queryById(self.RankConfig[sender.index].id)
		local upt = WeaponryMO.queryUp(md.formula)
		Toast.show( string.format("指挥官等级达到%s级解锁",upt.level) )
		return
	end

	if sender.index == self.m_chosenIndex then
	else
		self:dispatchEvent({name = "CHOSEN_MENU_EVENT", index = sender.index})
	end
end

function WeaponryMenuTableView:chosenIndex(menuIndex)
	self.m_chosenIndex = menuIndex

	for index = 1, self:numberOfCells() do
		local cell = self:cellAtIndex(index)
		if cell then
			if index == self.m_chosenIndex then
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_62_selected.png"))
			else
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_62_normal.png"))
			end
		end
	end
end

function WeaponryMenuTableView:getChosenIndex()
	return self.RankConfig[self.m_chosenIndex]
end

------------------------------------------------------------------------------
-- 军备工厂
------------------------------------------------------------------------------

local WeaponryView = class("WeaponryView", UiNode)

function WeaponryView:ctor(uiEnter, viewFor, param)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	viewFor = viewFor or 1
	self.m_viewFor = viewFor
	self.param = nil 
	if param then self.param = clone(param) end
	self.m_rankId = self.m_rankId or 1
	WeaponryView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function WeaponryView:onEnter()
	WeaponryView.super.onEnter(self)
	-- 部队
	self:setTitle(CommonText[1602])
	self:hasCoinButton(true)

	local function createDelegate(container, index)
		if index == 1 then  --打造
			self.effect1 = nil
			self:showInfo(container) 
		elseif index == 2 then --洗练
			self.cdTime = nil	
			self:loadPrescour(container)
		elseif index == 3 then --洗练
			self:showSecondWeaponry(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate(index)
		if index == 1 then
			-- 关闭洗练信息
			if self.wuview then
				self.wuview:Clean()
				self.wuview = nil
			end

		elseif index == 2 then
			-- 军备洗练功能锁定
			if not UserMO.queryFuncOpen(UFP_WEAP_CHANGE) then
				Toast.show(CommonText[1726])
				return false
			end

			-- 没有军备
			if table.nums(WeaponryMO.WeaponryList) <= 0 then
				Toast.show(CommonText[1054])
				return false
			end

			-- 关闭打造信息
			if self.m_tickTimer then
				ManagerTimer.removeTickListener(self.m_tickTimer)
				self.m_tickTimer = nil
			end
		elseif index == 3 then
			-- 关闭洗练信息
			if self.wuview then
				self.wuview:Clean()
				self.wuview = nil
			end
		end
		return true
	end

	local pages = {CommonText[1603][1],CommonText[1603][2],CommonText[1603][3]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	pageView:setPageIndex(self.m_viewFor)


	self.m_updateEmployHandler = Notify.register(LOCAL_WEAPONRY_EMPLOY, handler(self, self.updateEmploy))
end

-- 洗练
function WeaponryView:loadPrescour(container)

	WeaponryBO.loadEquipChageInfo(function(data)
		local WeaponryUpgradeView = require("app.view.WeaponryUpgradeView")
		local view = WeaponryUpgradeView.new(cc.size(container:getContentSize().width,container:getContentSize().height),data,self.param):addTo(container)
		view:setPosition(0,0)
		self.wuview = view

		self.param = nil
	end)
end

function WeaponryView:showSecondWeaponry(container)
	local WeaponrySecondAttributeView = require("app.view.WeaponrySecondAttributeView")
	local view = WeaponrySecondAttributeView.new(cc.size(container:getContentSize().width,container:getContentSize().height)):addTo(container)
	view:setPosition(0,0)

end

function WeaponryView:showInfo(container)
	local title = display.newSprite(IMAGE_COMMON .. "activity/bar_junbei.jpg"):addTo(container)
	title:setPosition(container:getContentSize().width - title:getContentSize().width / 2 + 16, container:getContentSize().height - title:getContentSize().height / 2)
	self:showBarContent(title)
	--判断当前状态，如果正在打造，则跳转 加速界面。
	--WeaponryBO.buildEquip 正在打造的数据
	if WeaponryBO.buildEquip then
		self.isDoing = true
	else
		self.isDoing = false
	end

	-- isDoing 是否正在打造
	if self.isDoing then
		self:showMakeWeapon(container)
	else
		self:showWeaponryContent(container)
	end
end
-- 通用界面 技工提示信息 +号
function WeaponryView:showBarContent(bar)
	-- 技工：未雇佣
	local desc = ui.newTTFLabel({text = CommonText[1729], font = G_FONT, size = FONT_SIZE_SMALL, x =50, y = 30, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
	desc:setAnchorPoint(cc.p(0, 0.5))
	self.desc = desc 
	
	-- 时间
	local label = ui.newTTFLabel({text ="", font = G_FONT, size = FONT_SIZE_SMALL, x = 500 , y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bar,11)
	label:setAnchorPoint(cc.p(1, 0.5))
	self.cdTime = label

	--打造减少时间
	local liveLab = ui.newTTFLabel({text = CommonText[1730] , font = G_FONT, size = FONT_SIZE_SMALL, x = 150 , y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bar,11)
	liveLab:setAnchorPoint(cc.p(0, 0.5))
	self.strBuildTime = liveLab

	-- 减少时间
	local liveValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = liveLab:getPositionX() + liveLab:getContentSize().width, y = 30, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar,11)
	liveValue:setAnchorPoint(cc.p(0, 0.5))
	self.liveValue = liveValue

	--j加号（先判断是否有技工上阵，有则显示，否则显示加号）
	local normal = display.newSprite(IMAGE_COMMON .. "btn_add1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add1_selected.png")
    local btn = MenuButton.new(normal, selected, nil, handler(self, self.onAddMechanicCallback)):addTo(bar,2)
    btn:setPosition(bar:getContentSize().width - 80 + 10, 92)
    self.mechanic = btn
    --self.mechanic:setNormalSprite()
	if WeaponryBO.currEmployId ~= 0 then
		local data = WeaponryMO.getEmployById(WeaponryBO.currEmployId)
		local icon = data.icon
		btn:setNormalSprite(display.newSprite("image/item/" .. icon .. ".jpg"))
		local xx = display.newSprite("image/item/" .. icon .. ".jpg")
		xx:setScale(0.9)
		btn:setSelectedSprite(xx)
		self.desc:setString(data.name)
		if not self.m_tickTimer then
			self.m_tickTimer = ManagerTimer.addTickListener(handler(self, self.onTick))
		end
		self.liveValue:setString((data.timeDown/3600) .. CommonText[159][3])
		--self.cdTime:setString("剩余时间：")
	else
		btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_add1_normal.png"))
		btn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_add1_normal.png"))
		--加号动画
		armature_add(IMAGE_ANIMATION .. "effect/jbgc_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/jbgc_tx.plist", IMAGE_ANIMATION .. "effect/jbgc_tx.xml")
		if self.effect1 then
			self.effect1:removeAllChildren()
			self.effect1 = nil
		end
		self.effect1 = armature_create("jbgc_tx",bar:getContentSize().width  - 70 , 90):addTo(bar,10)
		self.effect1:getAnimation():playWithIndex(0)

		self.cdTime:setString(CommonText[1731])
		self.strBuildTime:setString("")
		self.liveValue:setString("")
		-- if self.effect1 then
		-- 	self.effect1:setVisible(true)
		-- end
	end


	--遮罩
	local normal = display.newSprite(IMAGE_COMMON .. "info_bg_87.png"):addTo(bar,4)
	normal:setPosition(bar:getContentSize().width - 80 + 3, 92 + 20)
	

    --是否有时间，有时间则开启定时器
	--self:onTick(0)
end

function WeaponryView:onTick(dt)

	if not self.m_tickTimer then
		return
	end	
	if WeaponryBO.buildEquip then
		self.isDoing = true
	else
		self.isDoing = false
	end
	if self.isDoing and self.m_hpBar then   --倒计时
		local left =  WeaponryBO.buildEquip.endTime - ManagerTimer.getTime()
		if left <= 0 then
			left = 0
			if self.quickBtn then
				self.quickBtn:setLabel(CommonText[694][2])
			end
		end
		self.m_hpBar:setPercent( (WeaponryBO.buildEquip.period - left)/ WeaponryBO.buildEquip.period)
		-- local timeLable = string.format("%02d:%02d:%02d",math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
		-- if math.floor(left / (3600*24)) >= 1 then
		-- 	timeLable = string.format("%02dd:%02dh:%02dm:%02ds",math.floor(left / (3600*24)) ,math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
		-- end
	    self.m_hpBar:setLabel(UiUtil.strBuildTime(left))
	end

	if self.cdTime then   --倒计时
		local left =  WeaponryBO.employEndtime - ManagerTimer.getTime()
		if left <= 0 then
			left = 0
			WeaponryBO.currEmployId = 0
			self.cdTime:setColor(COLOR[1])
			self.cdTime:setString(CommonText[1731])
			self.mechanic:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_add1_normal.png"))
			self.mechanic:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_add1_normal.png"))
			return
		end
		-- local timeLable = string.format("%02d:%02d:%02d",math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
		-- if math.floor(left / (3600*24)) >= 1 then
		-- 	timeLable = string.format("%02dd:%02dh:%02dm:%02ds",math.floor(left / (3600*24)) ,math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
		-- end
		self.cdTime:setColor(COLOR[2])
	    self.cdTime:setString(UiUtil.strBuildTime(left))
	end
end

function WeaponryView:onAddMechanicCallback(tag, sender)
	--self:pop()
	--技工雇佣界面
	ManagerSound.playNormalButtonSound()
	--雇佣完成，之后更改加号图标。回调
	require("app.view.employArtificerView").new():push()
end

-- 正在打造的界面
function WeaponryView:showMakeWeapon(container)
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_76.jpg"):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - bg:getContentSize().height + 25)
	--进度条
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(510, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(510 + 4, 26)}):addTo(bg)
	bar:setPosition(bg:getContentSize().width / 2, 26)
	bar:setPercent(0)
	self.m_hpBar = bar

	local left =  WeaponryBO.buildEquip.endTime - ManagerTimer.getTime()
	if left <= 0 then
		left = 0
	end
	self.m_hpBar:setPercent((WeaponryBO.buildEquip.period - left)/ WeaponryBO.buildEquip.period)
	self.m_hpBar:setLabel(UiUtil.strBuildTime(left))

	if left > 0 then
		armature_add(IMAGE_ANIMATION .. "effect/dazhaozhuangbei.pvr.ccz", IMAGE_ANIMATION .. "effect/dazhaozhuangbei.plist", IMAGE_ANIMATION .. "effect/dazhaozhuangbei.xml")
		if not self.effect then
			self.effect = armature_create("dazhaozhuangbei",container:getContentSize().width / 2 ,container:getContentSize().height/2 - 60):addTo(container,10)
			self.effect:getAnimation():playWithIndex(1)
		end
	end

	--技工加速
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.gotoQuickCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 730)
	btn:setLabel(CommonText[1604])
	local md = WeaponryMO.queryById(WeaponryBO.buildEquip.equip_id) 
	btn.cdPrice = WeaponryMO.queryUp(md.formula).cdPrice
	if WeaponryBO.buildEquip.endTime <= ManagerTimer.getTime() then
		btn:setLabel(CommonText[694][2])
	else
		--判断是否能用技工加速
		if WeaponryBO.currEmployId == 0 then
			btn:setLabel(CommonText[1732])
		elseif (WeaponryBO.buildEquip and WeaponryBO.buildEquip.tech_id  ~= 0 and WeaponryBO.currEmployId == WeaponryBO.buildEquip.tech_id ) then
			btn:setLabel(CommonText[1732])
		else
			btn:setLabel(CommonText[1733])
		end
	end
	self.quickBtn = btn

-- 	message LordEquipBuilding{
-- 	optional int32 equip_id = 1;       	//生产中的军备ID
-- 	optional int32 period = 2;			//生产时间
-- 	optional int32 endTime = 3;			//生产结束时间
-- 	optional int32 tech_id = 4;			//使用过的铁匠 0-没有使用过铁匠加速
-- }

	--进度条时间
	if not self.m_tickTimer then
		self.m_tickTimer = ManagerTimer.addTickListener(handler(self, self.onTick))
	end
	--self:onTick(0)
	local data = WeaponryMO.queryById(WeaponryBO.buildEquip.equip_id)
	itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,data.id):addTo(container)
	itemView:setPosition(container:getContentSize().width / 2,container:getContentSize().height/2 )


	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(container)
	bg:setPosition(container:getContentSize().width / 2,container:getContentSize().height/2 - 70 + 3)

	local t = UiUtil.label(md.name,nil,COLOR[md.quality])
		:addTo(container):align(display.CENTER_TOP, container:getContentSize().width / 2,container:getContentSize().height/2 - 55 )

end

-- 使用技工加速
function WeaponryView:gotoQuickCallback(tag, sender)
	--加速之后关闭当前界面
	local function doneReset()
		Loading.getInstance():unshow()
		--self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end
	--
	--先判断是否打造完成，完成则领取
	if WeaponryBO.buildEquip and WeaponryBO.buildEquip.endTime <= ManagerTimer.getTime() then
		Loading.getInstance():show()
		WeaponryBO.CollectLordEquip(doneReset)
	else
		--判断是否有技工，有则技工加速，否则金币加速。
		if WeaponryBO.currEmployId == 0  or (WeaponryBO.buildEquip and WeaponryBO.buildEquip.tech_id  ~= 0 and WeaponryBO.currEmployId == WeaponryBO.buildEquip.tech_id ) then
			local cost = sender.cdPrice * math.ceil((WeaponryBO.buildEquip.endTime - ManagerTimer.getTime())/60)
			if UserMO.consumeConfirm  then
				CoinConfirmDialog.new(string.format(CommonText[1610],cost), function()
					if UserMO.coin_ < cost then
						require("app.dialog.CoinTipDialog").new():push()
						return
					end
					Loading.getInstance():show()
					WeaponryBO.LordEquipSpeedByGold(doneReset)
					end):push()
			else
				if UserMO.coin_ < cost then
					require("app.dialog.CoinTipDialog").new():push()
					return
				end
				WeaponryBO.LordEquipSpeedByGold(doneReset)
			end
		else
			Loading.getInstance():show()
			WeaponryBO.UseTechnical(doneReset)
		end
	end
end

-- 未打造
-- 装备打造列表
function  WeaponryView:showWeaponryContent(container)
	local shang1 = display.newSprite(IMAGE_COMMON .. "btn_go_normal.png")
	local shang2 = display.newSprite(IMAGE_COMMON .. "btn_go_normal.png")
	shang1:setRotation(-90)
	shang2:setRotation(-90)

    local xia1 = display.newSprite(IMAGE_COMMON .. "btn_go_normal.png")
    local xia2 = display.newSprite(IMAGE_COMMON .. "btn_go_normal.png")
    xia1:setRotation(90)
    xia2:setRotation(90)

    local shang = MenuButton.new(shang1, shang2, nil, handler(self, self.onSolderCallback)):addTo(container,11)
    shang:setPosition(135 , container:getContentSize().height -210 )
    shang.tag_ = 1
    self.shang = shang

    local xia = MenuButton.new(xia1, xia2, nil, handler(self, self.onSolderCallback)):addTo(container,11)
    xia:setPosition(135, 10 )
    xia.tag_ = 2
    self.xia = xia

	-- 菜单
	local view = WeaponryMenuTableView.new(cc.size(230, container:getContentSize().height - 250), self.m_rankId,self):addTo(container)
	view:addEventListener("CHOSEN_MENU_EVENT", handler(self, self.onChosenMenu))
	view:setPosition(10, 20)	
	view:reloadData()
	if self.offset then
		view:setContentOffset(self.offset)
	end
	self.m_menuTablView = view

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(container)
	bg:setCapInsets(cc.rect(130, 40, 1, 1))
	bg:setPreferredSize(cc.size(374, container:getContentSize().height - 210))
	bg:setPosition(container:getContentSize().width - bg:getContentSize().width / 2 - 10, bg:getContentSize().height / 2 )

	local node = display.newNode():addTo(bg)
	node:setContentSize(bg:getContentSize())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
	self.container = node

	self:showMenuInfo()
end

function WeaponryView:onSolderCallback(tag,sender)
	--ManagerSound.playNormalButtonSound()
	-- local offset = self.m_menuTablView:getContentOffset()
	-- if offset.y <= -3610  then
	-- 	self.xia:setVisible(false)
	-- elseif offset.y > 0 then
	-- 	self.shang:setVisible(false)
	-- else
	-- 	self.shang:setVisible(true)
	-- 	self.xia:setVisible(true)
	-- end 
	-- dump(self.m_menuTablView:getContentOffset().y)
	
	-- if sender.tag_ == 1 then
	-- 	local offset = self.m_menuTablView:getContentOffset()
	-- 	if offset then
	-- 		local tmp = offset.y
	-- 		if tmp > 710 then
	-- 			tmp = offset.y
	-- 		else
	-- 			tmp = offset.y + 90*6
	-- 		end
	-- 		self.m_menuTablView:setContentOffset(cc.p(0 ,tmp))
	-- 	end
	-- else
	-- 	local offset = self.m_menuTablView:getContentOffset()
	-- 	if offset then
	-- 		local tmp = offset.y
	-- 		if tmp < -2530 then
	-- 			tmp = -3070+540
	-- 		else
	-- 			tmp = offset.y- 90*6
	-- 		end
	-- 		self.m_menuTablView:setContentOffset(cc.p(0 ,tmp))
	-- 	end
	-- end
end

function WeaponryView:onChosenMenu(event)
	local index = event.index
	self.m_menuTablView:chosenIndex(index)

	self:showMenuInfo()

	self.m_rankId = index or 1
end

function WeaponryView:showMenuInfo()
	
	local index = self.m_menuTablView:getChosenIndex()
	--记录当前移动位置
	self.offset = self.m_menuTablView:getContentOffset()

	self.container:removeAllChildren()
	--获取详细信息（军备打造）
	local  data  = index
	itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,data.id):addTo(self.container)
	itemView:setPosition(self.container:getContentSize().width / 2,self.container:getContentSize().height - 80)

	local t = UiUtil.label(data.name,nil,COLOR[data.quality])
		:addTo(self.container):align(display.LEFT_CENTER, self.container:getContentSize().width / 2 - 40, self.container:getContentSize().height - 150)


	-- 附加属性
	local temps = json.decode(data.atts)
	local attsNmber = #temps
		if attsNmber > 0 then
			for index = 1 , attsNmber do
			local temp = temps[index]
			local att = AttributeBO.getAttributeData(temp[1], temp[2])
			t = UiUtil.label(att.name .."："):alignTo(t, -25, 1)
			UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
		end
	else
		t = UiUtil.label(CommonText[1040] .."："):alignTo(t, -25, 1)
			UiUtil.label(data.tankCount,nil,COLOR[2]):rightTo(t)
	end
	

	
	local standardLabel = ui.newTTFLabel({text = CommonText[1734] , font = G_FONT, size = FONT_SIZE_SMALL - 2, x = 10, y = self.container:getContentSize().height - 220, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self.container,2)
	standardLabel:setAnchorPoint(cc.p(0, 0.5))

	--materials  
	local isCanBuild = true 
	local material =  WeaponryMO.needMaterials(data.formula)
	for k,v in ipairs(json.decode(material)) do
		local itemView = UiUtil.createItemView(v[1], v[2],{nil})
		local posx = 65 + (k - 1) * 120
		local posy = self.container:getContentSize().height - 280
		if k > 3 then
			posx = 65 + (k - 4) * 120
			posy = self.container:getContentSize().height - 380
		end
		itemView:setPosition(posx,posy)
		itemView:setScale(0.8)
		self.container:addChild(itemView)
		itemView.param = {}
		itemView.param.count = tonumber(UiUtil.strNumSimplify(v[3]))
		UiUtil.createItemDetailButton(itemView)

		local propDB = UserMO.getResourceData(v[1], v[2])
		--local t = UiUtil.label(propDB.name,nil,COLOR[propDB.quality or 1]):addTo(itemView):align(display.LEFT_CENTER,-10,-10)
		
		local own = UserMO.getResource(v[1],v[2])
		local t = UiUtil.label("/"..UiUtil.strNumSimplify(own),nil,COLOR[own<v[3] and 6 or 2]):addTo(itemView):align(display.LEFT_CENTER,50,-10)
		if  own<v[3] then
			isCanBuild = false
		end
		UiUtil.label(UiUtil.strNumSimplify(v[3])):leftTo(t)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local strengthBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onBuildCallback)):addTo(self.container)
	strengthBtn:setPosition(self.container:getContentSize().width / 2, self.container:getContentSize().height - 500)
	strengthBtn:setLabel(CommonText[1735][1])
	strengthBtn.equipId = data.id
	if  not isCanBuild then
		strengthBtn:setEnabled(false)
	else
		strengthBtn:setEnabled(true)
	end

	--打造时间
	local t = UiUtil.label(CommonText[1735][2],nil,COLOR[data.quality])
		:addTo(self.container):align(display.LEFT_CENTER, self.container:getContentSize().width / 2 - 100, self.container:getContentSize().height - 450)

	local upt = WeaponryMO.queryUp(data.formula)
	local left = upt.period
	-- local timeLable = string.format("%02d:%02d:%02d",math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
	-- if math.floor(left / (3600*24)) >= 1 then
	-- 	timeLable = string.format("%02dd:%02dh:%02dm:%02ds",math.floor(left / (3600*24)) ,math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
	-- end
	UiUtil.label(UiUtil.strBuildTime(left),nil,COLOR[2]):rightTo(t)

end

-- 打造装备
function WeaponryView:onBuildCallback(tag,sender)
	ManagerSound.playNormalButtonSound()

	if UserMO.level_ < WeaponryMO.level_ then
		return
	end

	local function doneReset()
		Loading.getInstance():unshow()
		-- if self.m_pageView then
		-- 	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
		-- end
	end
	WeaponryBO.ProductEquip(doneReset,sender.equipId)
end

function WeaponryView:updateEmploy()
	if self.m_pageView then
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
		--self.effect1 = nil 
		self.effect = nil 
	end
end

function WeaponryView:refreshUI()
	-- if self.m_pageView then
	-- 	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	-- end
end

function WeaponryView:onExit()
	WeaponryView.super.onExit(self)
	if self.m_tickTimer then
		ManagerTimer.removeTickListener(self.m_tickTimer)
		self.m_tickTimer = nil
	end	
	if self.m_updateEmployHandler then
		Notify.unregister(self.m_updateEmployHandler)
		self.m_updateEmployHandler = nil
	end

	if self.wuview then
		self.wuview:Clean()
		self.wuview = nil
	end
end

return WeaponryView