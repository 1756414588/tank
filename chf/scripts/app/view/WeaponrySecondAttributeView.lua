--
-- Author: Gss
-- Date: 2018-10-11 10:49:12
--
-- 军备第二洗练属性界面

local SecondWeaponrysTableView = class("SecondWeaponrysTableView", TableView)

function SecondWeaponrysTableView:ctor(size,data,index,callback)
	SecondWeaponrysTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_cellSize = cc.size(120,self:getViewSize().height)
	self.equipList = data
	self.cellCurIndex = index
	self.callback = callback
end

function SecondWeaponrysTableView:onEnter()
	SecondWeaponrysTableView.super.onEnter(self)
	armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
	self:reloadData()
	if self.callback then self.callback(self) end
end

function SecondWeaponrysTableView:onExit()
	SecondWeaponrysTableView.super.onExit(self)
	armature_remove("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
end

function SecondWeaponrysTableView:numberOfCells()
	return #self.equipList
end

function SecondWeaponrysTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SecondWeaponrysTableView:createCellAtIndex(cell, index)
	SecondWeaponrysTableView.super.createCellAtIndex(self, cell, index)
	local data = self.equipList[index]
	local skills = PbProtocol.decodeArray(data.skillLv)
	local skilllvMax = data.maxSkillLevel
	
	-- 元素
	local item = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,data.equip_id):addTo(cell)
	item:setAnchorPoint(cc.p(0.5,0.5))
	item:setPosition(self.m_cellSize.width * 0.5 , self.m_cellSize.height * 0.5)

	local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(item)
	lockIcon:setScale(0.5)
	lockIcon:setPosition(item:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, item:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)

	lockIcon:setVisible(data.isLock)

	--背景遮罩
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(item)
	bg:setScaleX(0.8)
	bg:setAnchorPoint(cc.p(0,0))
	bg:setPosition(0,5)

	local posX = 10
	for index = 1, #skills do
		local starStr = "estar_bg.png"
		if skills[index].v2 >= skilllvMax then
			starStr = "estar.png"
		end
		--星星
		local star = display.newSprite(IMAGE_COMMON .. starStr):addTo(item)
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
function SecondWeaponrysTableView:cellWillRecycle(cell, index)
	if cell and cell.oneArmature then
		cell.oneArmature:removeSelf()
		cell.oneArmature = nil
	end
end

-- 点击
function SecondWeaponrysTableView:cellTouched(cell, index)
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
function SecondWeaponrysTableView:takeCurrentItemData()
	return self.equipList[self.cellCurIndex] , self.cellCurIndex
end

-- 更新当前数据
function SecondWeaponrysTableView:flushData(data)
	self.equipList[self.cellCurIndex].lordEquipSaveType = data.lordEquipSaveType
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

local WeaponrySecondAttributeView = class("WeaponrySecondAttributeView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function WeaponrySecondAttributeView:ctor(size)
	self:setContentSize(size)
	self.ViewSize = size
	self.selectIndex = 1 --默认选1
	self:showUI()
end

function WeaponrySecondAttributeView:showUI()
	local weaponryList = WeaponryMO.getCanSecondWeaponrys()
	-- 背景
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self)
	infoBg:setPreferredSize(cc.size(self:getContentSize().width - 20, 130))
	infoBg:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height - infoBg:height() * 0.5 - 20)

	-- 滚动区
	local view = SecondWeaponrysTableView.new(cc.size(infoBg:getContentSize().width - 100, infoBg:getContentSize().height - 10),
		weaponryList,self.selectIndex, handler(self,self.showCurrentItem)):addTo(infoBg)
	view:setAnchorPoint(cc.p(0.5,0.5))
	view:setPosition(infoBg:getContentSize().width * 0.5, infoBg:getContentSize().height * 0.5)
	self.itemView = view

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

function WeaponrySecondAttributeView:showCurrentItem(view)
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local data, indexPoint = view:takeCurrentItemData()
	self.curretChose = indexPoint
	local size = cc.size(self:getContentSize().width - 12, self:getContentSize().height - 180)

	local pages = CommonText[1620]
	local contentNode = display.newNode():addTo(self)
	contentNode:setContentSize(self:getContentSize())
	self.m_contentNode = contentNode

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height)
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
			button:setPosition(size.width / 2 - button:getContentSize().width * 0.5, size.height)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_55_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setAnchorPoint(cc.p(0.5,0.5))
			button:setPosition(size.width / 2 + button:getContentSize().width * 0.5, size.height)
		end
		button:setLabel(pages[index], {color = COLOR[11]})

		return button
	end

	local function createDelegate(container, index)
		self:showAttribute(container,index)
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate( index )
		return true
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = self:getContentSize().width / 2, y = size.height / 2,
		clickBaginDelegate = clickBaginDelegate, createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback},hideDelete = true}):addTo(self.m_contentNode)

	local pageIndex = 1
	if data then
		if data.lordEquipSaveType then
			pageIndex = data.lordEquipSaveType + 1
		end
	end
	pageView:setPageIndex(pageIndex)
	self.m_pageView = pageView
end

function WeaponrySecondAttributeView:showAttribute(container, index)
	local weaponryList = WeaponryMO.getCanSecondWeaponrys()
	self.m_data = weaponryList
	-- 背景
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 20, container:height() - 50))
	infoBg:setPosition(container:getContentSize().width * 0.5, container:getContentSize().height - infoBg:height() * 0.5 - 30)
	local container = infoBg

	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal2.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.SecondWeaponrys):push()
		end):addTo(container)
	detailBtn:setPosition(container:width() - 50, container:height() - 50)

	local data = self.m_data[self.curretChose]
	if not data then
		local tips = UiUtil.label(CommonText[1628],nil,COLOR[2]):addTo(infoBg):center()
	 	return 
	end

	local skills = PbProtocol.decodeArray(data.skillLv)
	local secondSkills = PbProtocol.decodeArray(data.skillLvSecond)
	-- 普通格子数量
	local normalBox = data.normalBox
	-- 技能最大等级
	local skilllvMax = data.maxSkillLevel
	
	local skilllist = {}
	local secondSkilllist = {}
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


	for num = 1, normalBox do
		local skill = skills[num]
		local secondSkill = secondSkills[num]
		local out = {id = skill.v1,lv = skill.v2, lock = 0}

		if secondSkill then
			out.id = secondSkill.v1
			out.lv = secondSkill.v2
			out.lock = 1
		end

		secondSkilllist[#secondSkilllist + 1] = out
	end

	-- -- 是否有神秘洗练
	if data.superBox == 1 then
		-- 是否满足神秘洗练要求
		if skillnum >= normalBox * skilllvMax then
			local superskill = skills[normalBox + 1]
			local superskill2 = secondSkills[normalBox + 1]
			if superskill then
				table.insert(skilllist,{id = superskill.v1 , lv = superskill.v2})
			end

			if superskill2 then
				table.insert(secondSkilllist,{id = superskill2.v1 , lv = superskill2.v2, lock = 1})
			else
				table.insert(secondSkilllist,{id = superskill.v1 , lv = superskill.v2, lock = 0})
			end
		end
	end
	
	-- 将整理好的技能列表放回数据中
	data.myskill = skilllist
	data.mySecondSkill = secondSkilllist
	data.puton = 1
	if data.pos == 0 then
		data.puton = 0
	end

	-- 定位坐标
	local function posPoint( allwidth , all , width , index  )
		local ceil = math.ceil(all) - 1
		local a = (allwidth - all * width) / ceil
		return width * 0.5 + (index - 1) * (a + width)
	end

	local itemAllwidth = container:getContentSize().width * 0.8 	--技能所占位置的总宽度
	local itemnum = 5                            					--技能数 5强制定义的
	local posX = 10 												--星星的起始偏移
	local skillX = 0 												--临时变量
	local skillScale = 0.8 											--技能缩放
	local offX = 50
	local myskill
	local skill

	if index == 1 then
		myskill = data.myskill
	else
		myskill = data.mySecondSkill
	end

	for index=1,#myskill do
		local skilldata = myskill[index]
		-- 技能itme
		skill = UiUtil.createItemView(ITEM_KIND_WEAPONRY_SKILL,skilldata.id,{super = index}):addTo(container)
		skill:setScale(skillScale)
		local lock = display.newSprite(IMAGE_COMMON .. "unactive.png"):addTo(skill):center()
		lock:setVisible(skilldata.lock == 0)

		if index == 4 then --特殊些
			index = 5
		end
		local point = posPoint(itemAllwidth, itemnum , skill:getContentSize().width , index)
		skill:setPosition(point + offX, container:getContentSize().height - skill:getContentSize().height - 50)
		skillX = skill:getPositionX()

		-- + 加号
		local addtype = display.newSprite(IMAGE_COMMON .. "link.png"):addTo(container)
		local point = posPoint(itemAllwidth, itemnum , skill:getContentSize().width , 4) --特殊放在第四个
		addtype:setPosition(point + offX, skill:y())

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

		-- 技能提示
		if skilldata.id ~= 0 and skilldata.lock ~= 0 then
			self:showTips(skill,skilldata,data.maxSkillLevel,index)
		end
	end

	if index == 1 or (data.skillLvSecond and #data.skillLvSecond > 0) then --如果解锁了第二套洗练属性
		-- 保存按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
		local saveBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onSaveCallback)):addTo(container)  -- 确定
		saveBtn:setLabel(CommonText[1621])
		saveBtn:setPosition(container:getContentSize().width / 2, selected:height() / 2 + 10)
		saveBtn.data = data
		saveBtn.type = index
	else
		local noteBg = display.newSprite(IMAGE_COMMON.."info_bg_12.png"):addTo(container)
		noteBg:setAnchorPoint(cc.p(0, 0.5))
		noteBg:setPosition(50,skill:y() - 100)

		local desc = UiUtil.label(CommonText[1622]):addTo(noteBg)
		desc:setAnchorPoint(cc.p(0, 0.5))
		desc:setPosition(40,noteBg:height() / 2)

		local costItem = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,data.equip_id - 1):addTo(container)
		costItem:setScale(0.7)
		costItem:setPosition(container:width() / 2 - 100, noteBg:y() - 80)

		local costWeaponryNum = 1 --军备消耗的数量(此处写死)
		local costCoinNum = 500   --金币消耗的数量(此处写死)
		local costData = WeaponryMO.queryById(data.equip_id - 1)
		local name = UiUtil.label(costData.name .. " * " .. costWeaponryNum):alignTo(costItem, -60, 1)

		--背景遮罩
		local bg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(costItem)
		bg:setScaleX(0.8)
		bg:setAnchorPoint(cc.p(0,0))
		bg:setPosition(0,5)

		local posX = 10
		for index = 1, 4 do
			starStr = "estar.png"
			--星星
			local star = display.newSprite(IMAGE_COMMON .. starStr):addTo(costItem)
			star:setAnchorPoint(cc.p(0,0.5))
			star:setPosition(posX,bg:getContentSize().height * 0.5 + 6)
			posX = star:getPositionX() + star:getContentSize().width
		end

		local costCoin = UiUtil.createItemView(ITEM_KIND_COIN,0):addTo(container)
		costCoin:setScale(0.7)
		costCoin:setPosition(container:width() / 2 + 100, costItem:y())
		local coinCost = UiUtil.label(costCoinNum.." "..CommonText.item[1][1]):alignTo(costCoin, -60, 1)

		local consumeKeyId = nil --消耗军备的keyId
		-- 解锁按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local unlockBtn = MenuButton.new(normal, selected, disabled, handler(self, self.unlockSecondAttribute)):addTo(container)  -- 确定
		unlockBtn:setLabel(CommonText[902][2])
		unlockBtn:setPosition(container:getContentSize().width / 2, selected:height() / 2 + 10)
		unlockBtn.keyId = data.keyId
		unlockBtn.puton = data.puton
		unlockBtn.coincost = costCoinNum
		unlockBtn.star = #myskill
		local costWeaponrys = WeaponryMO.getCostWeaponrysById(data.equip_id - 1) --减一
		if costWeaponrys then
			consumeKeyId = costWeaponrys.keyId
		end
		unlockBtn.consumeKeyId = consumeKeyId
	end
end

function WeaponrySecondAttributeView:onSaveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local data = sender.data

	if data.skillLvSecond and #data.skillLvSecond <= 0 then
		Toast.show(CommonText[1623][1])
		return
	elseif data.lordEquipSaveType == (sender.type - 1)  then
		Toast.show(CommonText[1623][2])
		return
	end

	local myParam = {}
	myParam.type = sender.type - 1
	myParam.keyId = data.keyId
	myParam.puton = data.puton
	myParam.operationType = WEAPONRY_SECOND_SETTYPE_INDEX

	WeaponryBO.setWeaponryAttribute(function (data)
		Toast.show(CommonText[382][1])

		self.itemView:flushData(data[1])
		local weaponryList = WeaponryMO.getCanSecondWeaponrys()
		self.m_data = weaponryList
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end, myParam)
end

function WeaponrySecondAttributeView:unlockSecondAttribute(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not sender.consumeKeyId then
		Toast.show(CommonText[1624])
		return
	end

	local param = {}
	param.keyId = sender.keyId
	param.puton = sender.puton
	param.consumeKeyId = sender.consumeKeyId

	local function goUnlock()
		WeaponryBO.unLockSecondAttrbite(function ()
			Toast.show(CommonText[20003])

			local offSet = self.itemView:getContentOffset()
			self.itemView.cellCurIndex = self.curretChose
			self.itemView:reloadData()
			self.itemView:setContentOffset(offSet)

			local weaponryList = WeaponryMO.getCanSecondWeaponrys()
			self.m_data = weaponryList
			self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
		end, param)
	end

	local equip = WeaponryMO.WeaponryList[sender.consumeKeyId]
	local equipDB = WeaponryMO.queryById(equip.equip_id)
	local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")
	TipsAnyThingDialog.new(string.format(CommonText[1625], sender.star, equipDB.name, sender.coincost), goUnlock):push()
end

-- 点击触发提示
function WeaponrySecondAttributeView:showTips(node,data,max,index)
	local anchor = index == 5 and 1 or 0
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

function WeaponrySecondAttributeView:onExit()

end


return WeaponrySecondAttributeView