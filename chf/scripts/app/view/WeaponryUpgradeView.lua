--
-- 军备洗练
-- MYS
--

local WeaponryUpTableView = class("WeaponryUpTableView", TableView)

function WeaponryUpTableView:ctor(size,data,index,callback)
	WeaponryUpTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_cellSize = cc.size(120,self:getViewSize().height)
	-- body
	self.equipList = data
	self.cellCurIndex = index
	self.callback = callback
end

function WeaponryUpTableView:onEnter()
	WeaponryUpTableView.super.onEnter(self)
	armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
	self:reloadData()
	
	-- 定位	
	self:DealPoint()

	if self.callback then self.callback(self) end
end

function WeaponryUpTableView:onExit()
	WeaponryUpTableView.super.onExit(self)
	armature_remove("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
end

function WeaponryUpTableView:numberOfCells()
	return #self.equipList
end

function WeaponryUpTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function WeaponryUpTableView:createCellAtIndex(cell, index)
	WeaponryUpTableView.super.createCellAtIndex(self, cell, index)
	local data = self.equipList[index]

	local skills = PbProtocol.decodeArray(data.skillLv)
	if data.lordEquipSaveType and data.lordEquipSaveType == 1 then
		skills = PbProtocol.decodeArray(data.skillLvSecond)
	end
	-- 普通格子数量
	local normalBox = data.normalBox
	-- 技能最大等级
	local skilllvMax = data.maxSkillLevel
	
	local skilllist = {}
	local skillnum = 0
	for index =1 , normalBox do
		local skill = skills[index]
		local out = {id = 0,lv = 0}
		if skill then
			out.id = skill.v1
			out.lv = skill.v2
		end
		skillnum = skillnum + out.lv
		skilllist[#skilllist + 1] = out
	end
	-- -- 是否有神秘洗练
	if data.superBox == 1 then
		-- 是否满足神秘洗练要求
		if skillnum >= normalBox * skilllvMax then
			local superskill = skills[normalBox + 1]
			if superskill then
				table.insert(skilllist,{id = superskill.v1 , lv = superskill.v2})
			end
		end
	end
	
	-- 将整理好的技能列表放回数据中
	data.myskill = skilllist
	
	-- 元素
	local item = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,data.equip_id):addTo(cell)
	item:setAnchorPoint(cc.p(0.5,0.5))
	item:setPosition(self.m_cellSize.width * 0.5 , self.m_cellSize.height * 0.5)

	local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(item)
	lockIcon:setScale(0.5)
	lockIcon:setPosition(item:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, item:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)

	lockIcon:setVisible(data.isLock)

	--背景遮罩
	--star_1 star_bg_1 info_bg_32
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(item)
	bg:setScaleX(0.8)
	bg:setAnchorPoint(cc.p(0,0))
	bg:setPosition(0,5)

	local posX = 10
	for index = 1, #skilllist do
		local starStr = "estar_bg.png"
		if skilllist[index].lv >= skilllvMax then
			starStr = "estar.png"
		end
		--星星
		local star = display.newSprite(IMAGE_COMMON .. starStr):addTo(item)
		-- star:setScale(0.4)
		star:setAnchorPoint(cc.p(0,0.5))
		star:setPosition(posX,bg:getContentSize().height * 0.5 + 6)
		posX = star:getPositionX() + star:getContentSize().width
	end
	
	if self.cellCurIndex == index then
		if not cell.oneArmature then
			local armature = armature_create("ui_item_light_orange", self.m_cellSize.width * 0.5 + 2, self.m_cellSize.height * 0.5 - 2):addTo(cell, 10)
			armature:setScale(0.8)
			armature:getAnimation():playWithIndex(0)
			cell.oneArmature = armature
		end
	end
	
	return cell
end

-- 销毁
function WeaponryUpTableView:cellWillRecycle(cell, index)
	if cell and cell.oneArmature then
		cell.oneArmature:removeSelf()
		cell.oneArmature = nil
	end
end

-- 点击
function WeaponryUpTableView:cellTouched(cell, index)
	if self.cellCurIndex == index then return end
	--关闭前动画
	local lastcell = self:cellAtIndex(self.cellCurIndex)
	if lastcell and lastcell.oneArmature then
		lastcell.oneArmature:removeSelf()
		lastcell.oneArmature = nil
	end
	
	self.cellCurIndex = index

	-- 播放现动画
	if not cell.oneArmature then
		local armature = armature_create("ui_item_light_orange", self.m_cellSize.width * 0.5 + 2, self.m_cellSize.height * 0.5 - 2):addTo(cell, 10)
		armature:setScale(0.8)
		armature:getAnimation():playWithIndex(0)
		cell.oneArmature = armature
	end

	-- 回调
	if self.callback then self.callback(self) end
end

--获取当前数据
function WeaponryUpTableView:takeCurrentItemData()
	return self.equipList[self.cellCurIndex] , self.cellCurIndex
end

-- 定位偏移
function WeaponryUpTableView:DealPoint()
	local twidth = self.m_viewSize.width 
	local offset = math.floor(self.m_viewSize.width / 120) * 120
	local min = offset * 0.75
	local max = #self.equipList * 120 -  offset * 0.75
	local dex = (self.cellCurIndex ) * 120 
	if dex < min then
		self:setContentOffset(cc.p( 0 ,0))
	elseif dex > max then
		self:setContentOffset(cc.p( -max + 120 ,0))
	else
		self:setContentOffset(cc.p( -dex + 120 + offset * 0.5,0))
	end
end

-- 更新当前数据
function WeaponryUpTableView:flushData( data )
	self.equipList[self.cellCurIndex].skillLv = data.skillLv
	if table.isexist(data, "skillLvSecond") then
		self.equipList[self.cellCurIndex].skillLvSecond = data.skillLvSecond
		self.equipList[self.cellCurIndex].lordEquipSaveType = data.lordEquipSaveType
	end
	self:reloadData()

	-- 定位	
	self:DealPoint()


	local cell = self:cellAtIndex(self.cellCurIndex)
	if cell and not cell.oneArmature then
		local armature = armature_create("ui_item_light_orange", self.m_cellSize.width * 0.5 + 2, self.m_cellSize.height * 0.5 - 2):addTo(cell, 10)
		armature:setScale(0.8)
		armature:getAnimation():playWithIndex(0)
		cell.oneArmature = armature
	end

	if self.callback then self.callback(self,true) end
end

----------------------------------------------------------------------
--							军备洗练								--
----------------------------------------------------------------------
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local WeaponryUpgradeView = class("WeaponryUpgradeView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function WeaponryUpgradeView:ctor(size,data,frompoint)
	self:setContentSize(size)
	self.ViewSize = size
	self.nomalnum = data.num
	self.recodeTime = data.remainingTime
	armature_add(IMAGE_ANIMATION .. "effect/clds_gaoji_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.plist", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.xml")
	self.recordUpgradeSkillItem = {} -- 记录升级的装备技能
	self.frompoint = frompoint
	self:ShowView()
end

function WeaponryUpgradeView:ShowView()

	-- 背景
	local tipbg = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(self)
	tipbg:setAnchorPoint(cc.p(0.5,1))
	tipbg:setPosition(self.ViewSize.width * 0.5, self.ViewSize.height - 2)


	local size = cc.size(self.ViewSize.width - 10 , self.ViewSize.height - tipbg:getContentSize().height)

	local pages = {CommonText[1053][1],CommonText[1053][2]}

	self.selectIndex = {{index = 1},{index = 1}}

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height * 0.5 )
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5 )
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
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height + tipbg:getContentSize().height *0.5)
		end
		button:setLabel(pages[index], {color = COLOR[11]})

		return button
	end

	local startPoint = 1
	local keyId = nil

	--定点显示
	if self.frompoint then
		startPoint = self.frompoint.equiped
		keyId = self.frompoint.keyId
		self.frompoint = nil
	end 

	-- 背景
	local function createDelegate(container, index)
		local indata = nil
		if index == 1 then
			-- 已装备
			indata = WeaponryMO.getShowMedals()
		elseif index == 2 then
			-- 未装备
			indata = WeaponryMO.getFreeMedals()
		end
		self:LoadForEquiped(container,index,indata,keyId)
		keyId = nil
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate( index )
		return true
	end

	
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = self.ViewSize.width / 2, y = 0, createDelegate = createDelegate, clickDelegate = clickDelegate, 
		clickBaginDelegate = clickBaginDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback},hideDelete = true}):addTo(self, 2)
	pageView:setAnchorPoint(cc.p(0.5,0))
	pageView:setPageIndex(startPoint)


	-- 普通洗练
	local btndata = WeaponryMO.queryChangeById(1)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local nomalBtn = MenuButton.new(normal,selected,disabled,handler(self,self.normalBtnCallback)):addTo(self,3)
	nomalBtn:setAnchorPoint(cc.p(0.5,0.5))
	nomalBtn:setPosition(self.ViewSize.width * 0.2, nomalBtn:getContentSize().height * 0.5)
	nomalBtn:setLabel(btndata.name)
	nomalBtn:setEnabled(self.nomalnum > 0)
	nomalBtn.btntype = 1
	nomalBtn.cost = btndata.cost
	nomalBtn.name = btndata.name
	self.nomalBtn = nomalBtn
	self.nomalBtn.enable = true
	
	-- 免费次数
	local lable = UiUtil.label(CommonText[557][2],FONT_SIZE_LIMIT):addTo(self,4)
	lable:setAnchorPoint(cc.p(0,0.5))
	lable:setPosition(nomalBtn:getPositionX() - nomalBtn:getContentSize().width * 0.5, nomalBtn:getPositionY() + nomalBtn:getContentSize().height*0.5 )
	-- 次数
	local lbtimes = UiUtil.label(self.nomalnum .. "/" .. btndata.keepNumber,FONT_SIZE_LIMIT):addTo(self,4):rightTo(lable,10)
	self.lbtimes = lbtimes
	self.lbtimes.keepNumber = btndata.keepNumber
	-- 时间 剩余恢复时间(秒)
	self.lblifetime = UiUtil.label("00:00",FONT_SIZE_LIMIT):addTo(self,4):rightTo(lbtimes,10)


	-- 至尊洗练
	btndata = WeaponryMO.queryChangeById(2)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local specialBtn = MenuButton.new(normal,selected,disabled,handler(self,self.normalBtnCallback)):addTo(self,3)
	specialBtn:setAnchorPoint(cc.p(0.5,0.5))
	specialBtn:setPosition(self.ViewSize.width * 0.5, specialBtn:getContentSize().height * 0.5)
	specialBtn:setLabel(btndata.name)
	specialBtn.btntype = 2
	specialBtn.cost = btndata.cost
	specialBtn.name = btndata.name
	self.specialBtn = specialBtn


	--神秘洗练
	btndata = WeaponryMO.queryChangeById(3)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local perfectBtn = MenuButton.new(normal,selected,disabled,handler(self,self.normalBtnCallback)):addTo(self,3)
	perfectBtn:setAnchorPoint(cc.p(0.5,0.5))
	perfectBtn:setPosition(self.ViewSize.width * 0.8, perfectBtn:getContentSize().height * 0.5)
	perfectBtn:setLabel(btndata.name)
	perfectBtn.btntype = 3
	perfectBtn.cost = btndata.cost
	perfectBtn.name = btndata.name
	self.perfectBtn = perfectBtn
	

	-- 打开计时器
	if not self.m_tickTimer then
		self.m_tickTimer = scheduler.scheduleGlobal(handler(self,self.onTick), 1)
	end
end

-- 清理数据 关闭计时器
function WeaponryUpgradeView:Clean()
	-- 关闭计时器
	armature_remove(IMAGE_ANIMATION .. "effect/clds_gaoji_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.plist", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.xml")
	if self.m_tickTimer then
		scheduler.unscheduleGlobal(self.m_tickTimer)
		self.m_tickTimer = nil
	end
end

-- 计时器
function WeaponryUpgradeView:onTick( ft )
	-- 未到达最大次数 （没有回满次数）
	if self.nomalnum < self.lbtimes.keepNumber then
		if self.recodeTime > 0 then
			self.recodeTime = self.recodeTime - 1
			if self.recodeTime <= 0 then
				self.nomalnum = self.nomalnum + 1
				self.lbtimes:setString(self.nomalnum .. "/" .. self.lbtimes.keepNumber)
				self.nomalBtn:setEnabled(self.nomalnum > 0 and self.nomalBtn.enable)
			end
			self.lblifetime:setString(UiUtil.strBuildTime(self.recodeTime))
		end
	end
end

-- 更新数据和UI
function WeaponryUpgradeView:LoadForEquiped( container, index, datas, pointKeyId)
	self.isEquiped = index -- 是否是穿在身上的装备 1.身上 2.背包
	local inputData = {}
	for k,v in pairs(datas) do
		local data = WeaponryMO.queryById(v.equip_id)

		local out = {}
		out.equip_id = v.equip_id				        --装备ID
		out.keyId = v.keyId 					        --绝对ID
		out.pos = v.pos 						        --位置
		out.skillLv = v.skillLv 			 	        --技能列表
		out.name = data.name 					        --装备名称
		out.quality = data.quality 				        --装备品质
		out.atts = data.atts 					        --装备属性
		out.tankCount = data.tankCount 			        --带兵量
		out.level = data.level 					        --装备可穿戴等级
		out.normalBox = data.normalBox 			        --普通格子技能格子
		out.superBox = data.superBox			        --是否可以神秘洗练 1可以2不能
		out.maxSkillLevel = data.maxSkillLevel	        --洗练技能等级上限
		out.isLock = v.isLock                           --是否锁定
		out.lordEquipSaveType = v.lordEquipSaveType     --当前设置的是第几条属性
		out.skillLvSecond = v.skillLvSecond             --第二套技能列表

		inputData[#inputData + 1] = out
	end
	local function outsort( a,b )
		if a.pos == b.pos then
			return a.quality > b.quality
		else
			return a.pos < b.pos
		end
	end
	table.sort(inputData, outsort)

	--定点显示
	if pointKeyId then
		local point = 1
		for k , v in pairs(inputData) do
			if v.keyId == pointKeyId then
				point = k
				break
			end
		end
		self.selectIndex[index].index = point
	end

	-- 背景
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width, 130))
	infoBg:setAnchorPoint(cc.p(0.5,1))
	infoBg:setPosition(container:getContentSize().width * 0.5, container:getContentSize().height)
	
	
	--洗练背景
	local changebg = display.newSprite(IMAGE_COMMON .. "info_bg_86.jpg"):addTo(container,2)
	changebg:setAnchorPoint(cc.p(0.5,1))
	changebg:setPosition(container:getContentSize().width * 0.5,container:getContentSize().height - 130 -5)
	self.changebg = changebg


	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.WeaponryTips):push()
	end

	-- TIPS详情
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal2.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
	local detailBtn = MenuButton.new(normal, selected, nil, gotoDetail):addTo(container, 5)
	detailBtn:setAnchorPoint(cc.p(1,1))
	detailBtn:setPosition(container:getContentSize().width - 80, container:getContentSize().height - 130 - 25 - detailBtn:getContentSize().height * 0.5)

	

	-- 装备滚动区
	local view = WeaponryUpTableView.new(cc.size(infoBg:getContentSize().width - 100, infoBg:getContentSize().height - 10),
		inputData,self.selectIndex[index].index,handler(self,self.showCurrentItem)):addTo(infoBg)
	view:setAnchorPoint(cc.p(0.5,0.5))
	view:setPosition(infoBg:getContentSize().width * 0.5, infoBg:getContentSize().height * 0.5)
	self.itemView = view
	-- self:showCurrentItem(view)

	--left
	local left = display.newSprite(IMAGE_COMMON .. "btn_go_selected.png"):addTo(infoBg,2)
	left:setAnchorPoint(cc.p(0.5,0.5))
	left:setPosition(infoBg:getContentSize().width * 0.5 - view:getContentSize().width * 0.5 - left:getContentSize().width * 0.3,infoBg:getContentSize().height * 0.5)
	left:setRotation(-180)

	--right
	local right = display.newSprite(IMAGE_COMMON .. "btn_go_selected.png"):addTo(infoBg,2)
	right:setAnchorPoint(cc.p(0.5,0.5))
	right:setPosition(infoBg:getContentSize().width * 0.5 + view:getContentSize().width * 0.5 + right:getContentSize().width * 0.3,infoBg:getContentSize().height * 0.5)
end

-- 刷新UI
function WeaponryUpgradeView:showCurrentItem(view,reload)
	reload = reload or false -- 是否来自淬炼升级
	local data , indexPoint = view:takeCurrentItemData()
	self.selectIndex[self.isEquiped].index = indexPoint
	self.changebg:removeAllChildren()
	
	-- dump(data," showCurrentItem  " .. indexPoint)

	-- 下地图
	local bottombg = display.newSprite(IMAGE_COMMON .. "info_bg_raffle.jpg"):addTo(self.changebg,-1)
	bottombg:setAnchorPoint(cc.p(0.5,1))
	bottombg:setPosition(self.changebg:getContentSize().width * 0.5 ,35)

	-- 定位坐标
	local function posPoint( allwidth , all , width , index  )
		local ceil = math.ceil(all) - 1
		local a = (allwidth - all * width) / ceil
		return width * 0.5 + (index - 1) * (a + width)
	end

	-- 添加 空数据限制
	if not data then
		-- 普通洗练
		self.nomalBtn:setEnabled(false)
		self.nomalBtn.enable = false
		-- 至尊洗练
		self.specialBtn:setPosition(self.ViewSize.width * 0.8, self.specialBtn:getContentSize().height * 0.5)
		self.specialBtn:setEnabled(false)
		--神秘洗练
		self.perfectBtn:setVisible(false)
		return
	end

	self.changebg.item = nil					--洗练装备UI
	self.changebg.maxlevel = data.maxSkillLevel	--技能最大等级限制
	self.changebg.keyId = data.keyId 		--装备Keyid

	-- 元素
	local item = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,data.equip_id):addTo(self.changebg, 1)
	item:setAnchorPoint(cc.p(0.5,0.5))
	item:setPosition(self.changebg:getContentSize().width * 0.5 , self.changebg:getContentSize().height * 0.55)
	self.changebg.item = item

	-- 名字
	local ename = UiUtil.label(data.name,FONT_SIZE_SMALL,COLOR[data.quality]):addTo(self.changebg,1)
	ename:setAnchorPoint(cc.p(0.5,0.5))
	ename:setPosition(self.changebg:getContentSize().width * 0.5,item:getPositionY() - item:getContentSize().height * 0.65)

	-- 附加属性
	local temps = json.decode(data.atts)
	local attsNmber = #temps
	if attsNmber > 0 then
		for index = 1 , attsNmber do
			local temp = temps[index]
			local att = AttributeBO.getAttributeData(temp[1], temp[2])
			local esoldier = UiUtil.label(att.name .."：" .. att.strValue,nil,cc.c3b(255, 255, 64)):addTo(self.changebg)
			esoldier:setAnchorPoint(cc.p(0.5,0.5))
			esoldier:setPosition(self.changebg:getContentSize().width * 0.5,item:getPositionY() - item:getContentSize().height * 0.9)
		end
	else
		-- 带兵量
		local esoldier = UiUtil.label(CommonText[1040] .. "+" .. data.tankCount,FONT_SIZE_SMALL,cc.c3b(255, 255, 64)):addTo(self.changebg)
		esoldier:setAnchorPoint(cc.p(0.5,0.5))
		esoldier:setPosition(self.changebg:getContentSize().width * 0.5,item:getPositionY() - item:getContentSize().height * 0.9)
	end

	
	-- 初始化技能存储记录
	if not reload then
		self.recordUpgradeSkillItem = {}
		self.recordUpgradeSkillItem[data.keyId] = {}
	end

	
	--星星背景遮罩
	local disbg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(item)
	disbg:setScaleX(0.8)
	disbg:setAnchorPoint(cc.p(0,0))
	disbg:setPosition(0,5)


	local itemAllwidth = bottombg:getContentSize().width * 0.8 		--技能所占位置的总宽度
	local itemnum = data.superBox == 1 and 5 or 3 					--技能数 5强制定义的
	local skill = nil 												--技能实例
	local posX = 10 												--星星的起始偏移
	local skillX = 0 												--临时变量
	local offset = 0 												--偏移
	local skillScale = 0.8 											--技能缩放
	local isEnabledperfectBtn = false								-- 是否显示神秘洗练按钮
	local myskill = clone(data.myskill)
	local skillSize = #myskill
	local curSkillSum = 0

	-- 补全缺位星星 星星数<= 3
	for index = skillSize , 2 do
		table.insert(myskill,{id = 0 , lv = 0})
	end
	skillSize = #myskill

	-- 添加神秘洗练
	if data.superBox == 1 and (4 - skillSize) > 0 then
		table.insert(myskill,{id = 0 , lv = 0})
		skillSize = #myskill
	end
	

	for index = 1, skillSize do
		local skilldata = myskill[index]

		curSkillSum = curSkillSum + skilldata.lv
		local offsetDex = 0
		local anchor = 0

		local starStr = "estar_bg.png"
		if skilldata.lv >= data.maxSkillLevel then
			starStr = "estar.png"
		end
		
		--星星
		if (index ~= 4 and index <= data.normalBox) or (index == 4 and skilldata.lv >= data.maxSkillLevel) then
			local star = display.newSprite(IMAGE_COMMON .. starStr):addTo(item)
			-- star:setScale(0.4)
			star:setAnchorPoint(cc.p(0,0.5))
			star:setPosition(posX,disbg:getContentSize().height * 0.5 + 6)
			posX = star:getPositionX() + star:getContentSize().width
		end
		
		------------ 技能实例 --------------
		

		if data.superBox == 1 and index <= 3 then
			offset = (index - 1) * 10
		elseif index == 4 and data.superBox == 1 then
			-- + 加号
			local addtype = display.newSprite(IMAGE_COMMON .. "link.png"):addTo(self.changebg,1) 
			addtype:setAnchorPoint(cc.p(0.5,0.5))
			addtype:setPosition(skillX + skill:getContentSize().width - 5 , -skill:getContentSize().height * 0.6)

			offsetDex = 1 
			anchor = 1
			offset = 0
			-- 是否显示神秘洗练按钮
			isEnabledperfectBtn = (curSkillSum >= data.maxSkillLevel * (index - 1) )
		end

		-- 技能itme
		skill = UiUtil.createItemView(ITEM_KIND_WEAPONRY_SKILL,skilldata.id,{super = index}):addTo(self.changebg,1)
		skill:setScale(skillScale)
		skill:setAnchorPoint(cc.p(0.5,0.5))
		local point = posPoint(itemAllwidth, itemnum , skill:getContentSize().width , index + offsetDex)
		skill:setPosition(bottombg:getPositionX() - itemAllwidth * 0.5 + point + offset, -skill:getContentSize().height * 0.6 )
		skillX = skill:getPositionX()

		if skilldata.id ~= 0 then
			local bg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(skill)
			bg:setScaleX(0.8)
			bg:setPosition(skill:getContentSize().width * 0.5 , bg:getContentSize().height * 0.5)

			--技能信息 名字 等级
			local db = WeaponryMO.queryChangeSkillById(skilldata.id)
			local lv = db.level >= data.maxSkillLevel and "Max" or db.level
			local lb = UiUtil.label(" Lv." .. lv,FONT_SIZE_SMALL,COLOR[1]):addTo(skill)
			lb:setPosition(skill:getContentSize().width * 0.5 , bg:getContentSize().height * 0.5)
		end

		-- 技能状态显示
		if index > data.normalBox and data.superBox == 0 then
			-- 加锁
			local normal = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png")
			local selected = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png")
			local btn = MenuButton.new(normal,selected,nil,handler(self,self.tipLock)):addTo(skill)
			btn:setPosition(skill:getContentSize().width * 0.5 , skill:getContentSize().height * 0.5)
			btn.tipstr = CommonText[1045][index]
		end

		-- 技能提示
		if skilldata.id ~= 0 then
			self:showTips(skill,skilldata,data.maxSkillLevel,anchor)
		end

		--是否是升级
		if not reload then
			--保存技能状态
			self.recordUpgradeSkillItem[data.keyId][index] = {oldid = skilldata.id ,oldlv = skilldata.lv}
		else
			--技能状态检查
			local oldskill = self.recordUpgradeSkillItem[data.keyId][index]
			if oldskill.oldid ~= skilldata.id or oldskill.oldlv ~= skilldata.lv then
				local light = armature_create("clds_gaoji_tx", skill:x(),skill:y(),function (movementType, movementID, armature )
					if movementType == MovementEventType.LOOP_COMPLETE then
						armature:removeSelf()
					end
				end):addTo(self.changebg ,0)
				-- light:setScale(1.2)
				light:getAnimation():playWithIndex(0)
			end
		end
	end

	if data.isLock then
		self.nomalBtn:setEnabled(false)
		self.specialBtn:setEnabled(false)
		self.perfectBtn:setEnabled(false)
		return
	end

	-- 神秘洗练
	if data.superBox == 1 then
		-- 普通洗练
		self.nomalBtn:setEnabled(self.nomalnum > 0)
		self.nomalBtn.enable = true
		-- 至尊洗练
		self.specialBtn:setPosition(self.ViewSize.width * 0.5, self.specialBtn:getContentSize().height * 0.5)
		self.specialBtn:setEnabled(true)
		--神秘洗练
		self.perfectBtn:setVisible(true)
		self.perfectBtn:setPosition(self.ViewSize.width * 0.8, self.perfectBtn:getContentSize().height * 0.5)
		self.perfectBtn:setEnabled(isEnabledperfectBtn)
	else
		-- 普通洗练
		self.nomalBtn:setEnabled(self.nomalnum > 0)
		self.nomalBtn.enable = true
		-- 至尊洗练
		self.specialBtn:setPosition(self.ViewSize.width * 0.8, self.specialBtn:getContentSize().height * 0.5)
		self.specialBtn:setEnabled(true)
		--神秘洗练
		self.perfectBtn:setVisible(false)
	end
end

-- 洗练
function WeaponryUpgradeView:normalBtnCallback( tag,sender )
	local btntype = sender.btntype -- 按钮类型
	local cost = sender.cost -- 消费金币
	local name = sender.name -- 洗练名称
	local keyId = self.changebg.keyId --洗练装备的keyid

	-- if true then
	-- 	self.itemView:flushData(data.equip)
	-- 	return
	-- end

	local function doEquip()
		local function dorhand( data )
			Loading.getInstance():unshow()
			-- 普通洗练 消耗免费次数
			self.nomalnum = data.num
			self.lbtimes:setString(self.nomalnum .. "/" .. self.lbtimes.keepNumber)
			if btntype == 1 then
				-- self.nomalnum = self.nomalnum - 1
				self.nomalBtn:setEnabled(self.nomalnum > 0 and self.nomalBtn.enable)
				if self.recodeTime <= 0 then
					self.recodeTime = WeaponryMO.queryChangeById(1).cd
				end
			end

			-- 修改界面
			self.itemView:flushData(data.equip)

			Toast.show(CommonText[1041])
		end
		local isEquiped = self.isEquiped == 1 and 1 or 0 --1穿戴2未穿戴
		Loading.getInstance():show()
		WeaponryBO.loadEquipChage(dorhand,keyId, btntype, isEquiped)
	end


	if UserMO.consumeConfirm and btntype ~= 1 then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1043], cost, name), function() doEquip() end):push()
	else
		doEquip()
	end
end

-- 锁定提示
function WeaponryUpgradeView:tipLock( tag,sender )
	Toast.show(sender.tipstr)
end

-- 点击触发提示
function WeaponryUpgradeView:showTips(node,data,max,anchor)
	anchor = anchor or 0
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			local db = WeaponryMO.queryChangeSkillById(data.id)
			-- 背景框
			local bg = display.newSprite(IMAGE_COMMON .. "tipbg.png"):addTo(node) 
			bg:setAnchorPoint(cc.p(anchor,0))
			bg:setPosition(0 + node:getContentSize().width * anchor,node:getContentSize().height * 1.1)
			-- 名字
			local name = UiUtil.label(db.name,FONT_SIZE_MEDIUM,COLOR[1]):addTo(bg)
			name:setAnchorPoint(0,0)
			name:setPosition(30,bg:getContentSize().height * 0.5 + 5)
			-- lv
			local lv = UiUtil.label("Lv." .. db.level,FONT_SIZE_MEDIUM,COLOR[1]):addTo(bg)
			lv:setAnchorPoint(0,0)
			lv:setPosition(name:getPositionX() + name:getContentSize().width + 10,bg:getContentSize().height * 0.5 + 5)
			-- star
			local starStr = db.level >= max and "estar.png" or "estar_bg.png"
			local star = display.newSprite(IMAGE_COMMON .. starStr):addTo(bg)
			star:setAnchorPoint(0,0.5)
			star:setPosition(lv:getPositionX() + lv:getContentSize().width + 20,bg:getContentSize().height * 0.5 + name:getContentSize().height * 0.5 + 5)
			--desc
			local desc = UiUtil.label(db.desc,FONT_SIZE_MEDIUM,COLOR[1]):addTo(bg)
			desc:setAnchorPoint(0,1)
			desc:setPosition(30,bg:getContentSize().height * 0.5 - 5)

			node.tipNode_ = bg
			return true
		elseif event.name == "ended" then
			node.tipNode_:removeSelf()
		end
	end)
end

function WeaponryUpgradeView:updateItemUI(data)
	-- body
end


return WeaponryUpgradeView