
--------------------------------------------------------------
--							菜单							--
--------------------------------------------------------------
-- local MenuDownList = class("MenuDownList",)


--------------------------------------------------------------
--						计算器table							--
--------------------------------------------------------------

local GMFightCalculatorTable = class("GMFightCalculatorTable", TableView)
function GMFightCalculatorTable:ctor(size)
	GMFightCalculatorTable.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
end

function GMFightCalculatorTable:onEnter()
	GMFightCalculatorTable.super.onEnter(self)


	self.funState1 = true

	-- 注册消息
	if not self.notifyhandler then
		self.notifyhandler = Notify.register("GM_LOCAL_NOTIFY_UPDATE", handler(self, self.drawView))
	end 

	self:drawView()
end

function GMFightCalculatorTable:drawView()
	local _width = self:getViewSize().width

	self.node = display.newNode()

	
	local nodeY = -5
	local heightDex = 10

	local label = ui.newTTFLabel({text = "---------- ---------- ----------" , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0.5,1))
	label:setPosition(_width*0.5,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	local label = ui.newTTFLabel({text = "是否在规制内设置" , font = G_FONT,size = FONT_SIZE_SMALL}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex
	
	local optionalBg = display.newSprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.node)
	optionalBg:setAnchorPoint(cc.p(0,0.5))
	optionalBg:setPosition(label:x() + label:width(), label:y() - label:height() * 0.5)
	local optionalvalue = display.newSprite(IMAGE_COMMON .. "btn_7_checked.png"):addTo(optionalBg)
	optionalvalue:setPosition(optionalBg:width() * 0.5, optionalBg:height() * 0.5)
	optionalvalue:setVisible(self.funState1)

	local str1 = self.funState1 and "方案1：只能使用拥有的将领和坦克 且带兵量范围内" or "方案2：可以使用任意将领、坦克、数量"
	local label1 = ui.newTTFLabel({text = str1 , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label1:setAnchorPoint(cc.p(0,1))
	label1:setPosition(0,nodeY)
	nodeY = nodeY - label1:getContentSize().height - heightDex

	self:addTouchFunc(optionalBg,function (event)
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			self.funState1 = not self.funState1
			optionalvalue:setVisible(self.funState1)
			local str1 = self.funState1 and "方案1：只能使用拥有的将领和坦克 且带兵量范围内" or "方案2：可以使用任意将领、坦克、数量"
			label1:setString(str1)
			Notify.notify("GM_LOCAL_NOTIFY_UPDATE")
		end
	end)




	-- nodeY = nodeY - optionalBg:getContentSize().height - heightDex

	
	-- label = ui.newTTFLabel({text = lordidstr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	-- label:setAnchorPoint(cc.p(0,1))
	-- label:setPosition(0,nodeY)
	-- nodeY = nodeY - label:getContentSize().height - heightDex

	self.m_cellSize = cc.size(_width, -nodeY )
	self:reloadData()
end

function GMFightCalculatorTable:numberOfCells()
	return 1
end

function GMFightCalculatorTable:cellSizeForIndex(index)
	return self.m_cellSize
end

function GMFightCalculatorTable:createCellAtIndex(cell, index)
	GMFightCalculatorTable.super.createCellAtIndex(self, cell, index)
	self.node:addTo(cell)
	self.node:setPosition(0,self.m_cellSize.height)
	return cell
end

function GMFightCalculatorTable:addTouchFunc(node,callback)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, callback)
end

function GMFightCalculatorTable:onExit()
	GMFightCalculatorTable.super.onExit(self)
	if self.notifyhandler then
		Notify.unregister(self.notifyhandler)
		self.notifyhandler = nil
	end
end

























--------------------------------------------------------------
--						游戏信息table						--
--------------------------------------------------------------

local GMInfoTable = class("GMInfoTable", TableView)

function GMInfoTable:ctor(size)
	GMInfoTable.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
end

function GMInfoTable:onEnter()
	GMInfoTable.super.onEnter(self)
	-- UserMO.lordId_
	-- UserMO.oldLordId_
	-- UserMO.topup_ --
	-- UserMO.newerGift_
	-- UserMO.onlineAccumTime_
	-- UserMO.createRoleTime_
	-- UserMO.openServerDay

	local lordidstr			= "角色ID [lordId] | " .. UserMO.lordId_
	local oldlordidstr		= "角色曾用ID [oldLordId] | " .. UserMO.oldLordId_
	local topupstr			= "已充值金额 [topup] | " .. UserMO.topup_
	local newerGiftstr		= "是否领取过新手礼包 [newerGift] | " .. UserMO.newerGift_ .. " " .. (UserMO.newerGift_ == 1 and "已领取" or "未领取")
	local olTimestr			= "当日在线时间 [olTime] | " .. UserMO.onlineAccumTime_ .. " 截至本次登录前 " .. UiUtil.strBuildTime(UserMO.onlineAccumTime_)
	local createRoleTimestr	= "玩家注册时间 [createRoleTime] | " .. UserMO.createRoleTime_ .. " " .. os.date("%Y/%m/%d-%H/%M/%S", UserMO.createRoleTime_/1000)
	local openServerDaystr	= "开服时间 [openServerDay] | " .. UserMO.openServerDay
	local areaIdstr 		= "服务器ID | " .. GameConfig.areaId

	local _width = self:getViewSize().width
	self.node = display.newNode()
	local nodeY = -5
	local heightDex = 10



	local label = ui.newTTFLabel({text = "---------- 角色基本信息 ----------" , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0.5,1))
	label:setPosition(_width*0.5,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = lordidstr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = oldlordidstr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = topupstr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = newerGiftstr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = olTimestr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = createRoleTimestr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = openServerDaystr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = areaIdstr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0,1))
	label:setPosition(0,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex




	label = ui.newTTFLabel({text = "---------- 资源详细信息 ----------" , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0.5,1))
	label:setPosition(_width*0.5,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	local itemKind = {RESOURCE_ID_STONE, RESOURCE_ID_IRON, RESOURCE_ID_OIL, RESOURCE_ID_COPPER, RESOURCE_ID_SILICON}
	local resourceMax = BuildBO.getResourceCapacity()
	local resourceProtected = BuildBO.getResourceCapacity(true)
	for index = 1 , 5 do
		local kind = itemKind[index]
		local count = UserMO.getResource(ITEM_KIND_RESOURCE, kind)
		local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, kind)
		local state = "爆仓"
		if count < resourceProtected[kind] then
			state = "保护"
		elseif count <= resourceMax[kind] then
			state = "可掠"
		end
		label = ui.newTTFLabel({text = resData.name .. " 当前/上限/保护/状态 | " .. count .. " / " .. resourceMax[kind] .. " / " .. resourceProtected[kind] .. " / " .. state, font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
		label:setAnchorPoint(cc.p(0.5,1))
		label:setPosition(_width*0.5,nodeY)
		nodeY = nodeY - label:getContentSize().height - heightDex
	end



	label = ui.newTTFLabel({text = "---------- 最大战力详情 ----------" , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0.5,1))
	label:setPosition(_width*0.5,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	local fightHero = HeroBO.getMaxFightHero(false,1)
	local formation = nil
	local temp = HeroBO.getHeroCompare(fightHero,1)
	if table.nums(temp) > 0 then
		local list = {}
		for k,v in pairs(temp) do
			local formation,total = TankBO.getMaxFightFormation(nil, v)
			table.insert(list,{total = total,formation = formation, hero = v})
		end
		table.sort(list, function(a,b)
			return a.total > b.total
		end)
		formation = TankBO.sortFormation(list[1].formation,list[1].hero)
	else
		formation = TankBO.getMaxFightFormation(nil, false, 1)
	end
	local fightValueData = TankBO.analyseFormation(formation)

	local herestr = "无将领"
	if table.isexist(formation, "awakenHero") then
		local _d = formation.awakenHero
		local _hero = UserMO.getResourceData(ITEM_KIND_AWAKE_HERO, _d.heroId)
		herestr = "觉醒将领 [heroId:" .._d.heroId .."][keyId:" .. _d.keyId .. "] " .. _hero.name
	elseif table.isexist(formation, "commander") then
		local _hero = UserMO.getResourceData(ITEM_KIND_HERO, formation.commander)
		herestr = "普通将领 [heroId:" ..formation.commander .."] " .. _hero.name
	end
	label = ui.newTTFLabel({text = herestr, font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0.5,1))
	label:setPosition(_width*0.5,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	for index = 1 , 6 do
		local _d = formation[index]
		local _tank = TankMO.queryTankById(_d.tankId)
		label = ui.newTTFLabel({text = "第".. index .. "战位: " .. "[tankId:" .. _d.tankId .. "] " .. _tank.name .. " " .. _d.count .. "辆", font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
		label:setAnchorPoint(cc.p(0.5,1))
		label:setPosition(_width*0.5,nodeY)
		nodeY = nodeY - label:getContentSize().height - heightDex
	end

	local fightType = {{key="base",name="基础战斗力"},
						{key="part",name="配件战力"},
						{key="skill",name="技能战力"},
						{key="science",name="科技战力"},
						{key="hero",name="武将战力"},
						{key="staff",name="编制战力"},
						{key="equip",name="装备战力"},
						{key="military",name="军工科技战力"},
						{key="medal",name="勋章战力"},
						{key="weaponry",name="军备战斗力"},
						{key="militarystaff",name="军衔战斗力"},
						{key="energyspar",name="能晶战力"},
						{key="total",name="最终总战力"},
						{key="payload",name="最终载重"}}
	for index = 1 , #fightType do
		local _d = fightType[index]
		local _value = fightValueData[_d.key]
		label = ui.newTTFLabel({text = _d.name ..": " .. _value, font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
		label:setAnchorPoint(cc.p(0.5,1))
		label:setPosition(_width*0.5,nodeY)
		nodeY = nodeY - label:getContentSize().height - heightDex
	end



	label = ui.newTTFLabel({text = "---------- 客户端功能状态 ----------" , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0.5,1))
	label:setPosition(_width*0.5,nodeY)
	nodeY = nodeY - label:getContentSize().height - 5

	for k,v in pairs(UserMO.FuncList()) do
		local data = v
		local outstr = v.funname .. " [功能ID:" .. v.funId .. "] " .. (UserMO.queryFuncOpen(k) and "开启" or "关闭")
		label = ui.newTTFLabel({text = outstr , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
		label:setAnchorPoint(cc.p(0.5,1))
		label:setPosition(_width*0.5,nodeY)
		nodeY = nodeY - label:getContentSize().height - heightDex
	end




	label = ui.newTTFLabel({text = "---------- 本地信息 ----------" , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	label:setAnchorPoint(cc.p(0.5,1))
	label:setPosition(_width*0.5,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	label = ui.newTTFLabel({text = "" , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
	local filename1 = "myStore" .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
	local path = CCFileUtils:sharedFileUtils():getCachePath() .. filename1
	if io.exists(path) then
		local filevalue = json.decode(io.readfile(path))
		local count = #filevalue
		label:setString("已找到 收藏记录 [" .. filename1 .. "] 共有 " .. count .. " 条记录")
	else
		label:setString("未找到 收藏记录 [" .. filename1 .. "]")
	end
	label:setAnchorPoint(cc.p(0.5,1))
	label:setPosition(_width*0.5,nodeY)
	nodeY = nodeY - label:getContentSize().height - heightDex

	if UserMO.oldLordId_ and UserMO.oldLordId_ ~= 0 then
		label = ui.newTTFLabel({text = "" , font = G_FONT,size = FONT_SIZE_SMALL, dimensions = cc.size(_width ,0)}):addTo(self.node)
		local filename2 = "myStore" .. "_" .. UserMO.oldLordId_ .. "_" .. GameConfig.areaId
		local path = CCFileUtils:sharedFileUtils():getCachePath() .. filename2
		if io.exists(path) then
			local filevalue = json.decode(io.readfile(path))
			local count = #filevalue
			label:setString("已找到 旧收藏记录 [" .. filename2 .. "] 共有 " .. count .. " 条记录")
		else
			label:setString("未找到 旧收藏记录 [" .. filename2 .. "]")
		end
		label:setAnchorPoint(cc.p(0.5,1))
		label:setPosition(_width*0.5,nodeY)
		nodeY = nodeY - label:getContentSize().height - heightDex
	end


	self.m_cellSize = cc.size(_width, -nodeY )
	self:reloadData()
end

function GMInfoTable:numberOfCells()
	return 1
end

function GMInfoTable:cellSizeForIndex(index)
	return self.m_cellSize
end

function GMInfoTable:createCellAtIndex(cell, index)
	GMInfoTable.super.createCellAtIndex(self, cell, index)
	self.node:addTo(cell)
	self.node:setPosition(0,self.m_cellSize.height)
	return cell
end


function GMInfoTable:onExit()
	GMInfoTable.super.onExit(self)
end

--------------------------------------------------------------
--							GM								--
--------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local GMInfoDialog = class("GMInfoDialog", Dialog)

function GMInfoDialog:ctor()
	GMInfoDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(display.width * 0.9, display.height*0.9)})
	
end

function GMInfoDialog:onEnter()
	GMInfoDialog.super.onEnter(self)

	self:setTitle("GM-角色隐性信息")

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(display.width*0.9-50, display.height*0.9-50))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local pages = {"游戏信息","计算器"}

	local function createDelegate(container, index)
		if index == 1 then
			self:Container1(container)
		else
			self:Container2(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate( index )
		if index == 2 then
			Toast.show(CommonText[1722])
			return false
		end
		return true
	end

	local size = cc.size(self:getBg():getContentSize().width*0.9, self:getBg():getContentSize().height*0.9 - 60)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, { createDelegate = createDelegate, clickDelegate = clickDelegate,clickBaginDelegate = clickBaginDelegate}):addTo(self:getBg(), 2)
	pageView:setAnchorPoint(cc.p(0,0))
	pageView:setPosition(self:getBg():getContentSize().width*0.05,40)
	pageView:setPageIndex(1)

end

function GMInfoDialog:Container1( container )
	-- local topbg = display.newSprite(IMAGE_COMMON .. "btn_1.png"):addTo(container)
	-- topbg:setAnchorPoint(cc.p(0,1))
	-- topbg:setPosition(0, container:getContentSize().height)

	-- topbg = display.newSprite(IMAGE_COMMON .. "btn_1.png"):addTo(container)
	-- topbg:setAnchorPoint(cc.p(0,0))
	-- topbg:setPosition(0, 0)

	-- topbg = display.newSprite(IMAGE_COMMON .. "btn_1.png"):addTo(container)
	-- topbg:setAnchorPoint(cc.p(1,0))
	-- topbg:setPosition(container:getContentSize().width, 0)

	-- topbg = display.newSprite(IMAGE_COMMON .. "btn_1.png"):addTo(container)
	-- topbg:setAnchorPoint(cc.p(1,1))
	-- topbg:setPosition(container:getContentSize().width, container:getContentSize().height)

	-- topbg = display.newSprite(IMAGE_COMMON .. "btn_1.png"):addTo(container)
	-- topbg:setAnchorPoint(cc.p(0.5,0.5))
	-- topbg:setPosition(container:getContentSize().width * 0.5, container:getContentSize().height*0.5)

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(container, 1)
	btm:setPreferredSize(cc.size(container:getContentSize().width, container:getContentSize().height))
	btm:setAnchorPoint(cc.p(0,0))
	btm:setPosition(0, 0)

	local view = GMInfoTable.new(cc.size(container:getContentSize().width*0.95 , container:getContentSize().height*0.95 )):addTo(container,2)
	view:setAnchorPoint(cc.p(0,0))
	view:setPosition(container:getContentSize().width*0.025 ,container:getContentSize().height*0.025 )

end

function GMInfoDialog:Container2( container )
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(container, 1)
	btm:setPreferredSize(cc.size(container:getContentSize().width, container:getContentSize().height))
	btm:setAnchorPoint(cc.p(0,0))
	btm:setPosition(0, 0)

	local view = GMFightCalculatorTable.new(cc.size(container:getContentSize().width*0.95 , container:getContentSize().height*0.95 )):addTo(container,2)
	view:setAnchorPoint(cc.p(0,0))
	view:setPosition(container:getContentSize().width*0.025 ,container:getContentSize().height*0.025 )

end

return GMInfoDialog