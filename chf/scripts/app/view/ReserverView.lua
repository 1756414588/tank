
-- 仓库储备

--------------------------------------------------------------------
-- 仓库储备tableview
--------------------------------------------------------------------

local ReserverTableView = class("ReserverTableView", TableView)

local itemKind = {RESOURCE_ID_STONE, RESOURCE_ID_IRON, RESOURCE_ID_OIL, RESOURCE_ID_COPPER, RESOURCE_ID_SILICON}

function ReserverTableView:ctor(size, protectCapacity)
	ReserverTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_protectCapacity = protectCapacity
end

function ReserverTableView:onEnter()
	ReserverTableView.super.onEnter(self)
	
	self.m_capacity = BuildBO.getResourceCapacity()  -- 各种资源的容量
	self.m_output = BuildBO.getResourceOutput() -- 各种资源的产出
end

function ReserverTableView:numberOfCells()
	return 5
end

function ReserverTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ReserverTableView:createCellAtIndex(cell, index)
	ReserverTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local kind = itemKind[index]
	local count = UserMO.getResource(ITEM_KIND_RESOURCE, kind)
	local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, kind)

	local itemView = UiUtil.createItemView(ITEM_KIND_RESOURCE, kind):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local posX = name:getPositionX() + name:getContentSize().width

	local desc = {}
	local valid, leftTime = EffectBO.getResEffectValid(ITEM_KIND_RESOURCE, kind)
	if valid then  -- 资源增益
		table.insert(desc,{{content=CommonText[20058][1]}, {content ="+"..EFFECT_RESOURCE_ADDITION*100 .."% "..UiUtil.strBuildTime(leftTime, "dhm"),color=COLOR[2]}})
	end

	local valid, leftTime = EffectBO.getEffectValid(EFFECT_ID_RESOURCE_ALL)
	if valid then  -- 全面开采中
		table.insert(desc,{{content=CommonText[20058][2]}, {content ="+"..EFFECT_RESOURCE_ADDITION*100 .."% "..UiUtil.strBuildTime(leftTime, "dhm"),color=COLOR[2]}})
	end

	local valid, leftTime = EffectBO.getEffectValid(EFFECT_ID_BASE_RESOURCE)
	if valid then  -- 资源丰收基地中
		table.insert(desc,{{content=CommonText[20058][3]}, {content ="+"..EFFECT_BASE_RES_ADDITION*100 .."% "..UiUtil.strBuildTime(leftTime, "dhm"),color=COLOR[2]}})
	end

	local valid, leftTime = EffectBO.getEffectValid(EFFECT_ID_SKIN_EXTREME)
	if valid then  -- 至尊基地资源丰收中
		table.insert(desc,{{content=CommonText[20058][3]}, {content ="+"..EFFECT_SKIN_EXTREME_ADDITION*100 .."% "..UiUtil.strBuildTime(leftTime, "dhm"),color=COLOR[2]}})
	end

	local valid, leftTime = EffectBO.getEffectValid(EFFECT_ID_SKIN_MECHANICS)
	if valid then  -- 机械迷城基地资源丰收中
		table.insert(desc,{{content=CommonText[20058][3]}, {content ="+"..EFFECT_SKIN_MECHAIN_ADDITION*100 .."% "..UiUtil.strBuildTime(leftTime, "dhm"),color=COLOR[2]}})
	end

	local valid, leftTime = EffectBO.getEffectValid(EFFECT_ID_PB_RESOURCE)
	if valid then  -- 军团战资源增产
		table.insert(desc,{{content=CommonText[20058][4]}, {content ="+"..EFFECT_PB_RES_ADDITION*100 .."% "..UiUtil.strBuildTime(leftTime, "dhm"),color=COLOR[2]}})
	end

	local valid, leftTime, value = FortressMO.getEffectValid()
	if valid then  -- 要塞战官职
		table.insert(desc,{{content=CommonText[20058][5]}, {content =valid..value .."% "..UiUtil.strBuildTime(leftTime, "dhm"),color=COLOR[valid=="+" and 2 or 6]}})
	end

	local valid, leftTime = EffectBO.getEffectValid(EFFECT_ID_PLAYER_BACK)
	if valid then  -- 老玩家回归
		table.insert(desc,{{content=CommonText[20058][7]}, {content ="+"..EFFECT_RESOURCE_ADDITION*100 .."% "..UiUtil.strBuildTime(leftTime, "dhm"),color=COLOR[2]}})
	end

	--活动增益
	local valid,left = EffectMO.resourceAdd()
	if valid > 0 then
		table.insert(desc,{{content=CommonText[20058][6]}, {content = "+"..valid.."% "..UiUtil.strBuildTime(left, "dhm"),color=COLOR[2]}})
	end
	if #desc>0 then  -- 增益中
		local t = UiUtil.button("btn_39_normal.png","btn_39_selected.png",nil,function()
				require("app.dialog.DetailTextDialog").new(desc):push()
			end,nil,1):scale(0.7)
		cell:addButton(t,name:x()+80,name:y())
	end

	-- 产量
	local label = ui.newTTFLabel({text = CommonText[158] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 产量/小时
	local speed = ui.newTTFLabel({text = UiUtil.strNumSimplify(self.m_output[kind]) .. "/" .. CommonText[159][3], font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	speed:setAnchorPoint(cc.p(0, 0.5))

	local status = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + 180, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	status:setAnchorPoint(cc.p(0, 0.5))
	if count < self.m_protectCapacity then
		status:setString("[" .. CommonText[157][2] .. "]")  -- 完全保护
		status:setColor(COLOR[2])
	elseif count <= self.m_capacity[kind] then
		status:setString("[" .. CommonText[157][1] .. "]")  -- 可被掠夺
		status:setColor(COLOR[11])
	else  -- 爆仓
		status:setString("[" .. CommonText[157][3] .. "]")  -- 可被掠夺
		status:setColor(COLOR[5])
	end

	-- 容量
	local label = ui.newTTFLabel({text = CommonText[139] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
	bar:setPosition(label:getPositionX() + label:getContentSize().width + bar:getContentSize().width / 2 + 5, label:getPositionY())
	bar:setPercent(count / self.m_capacity[kind])

	bar:setLabel(UiUtil.strNumSimplify(count) .. "/" .. UiUtil.strNumSimplify(self.m_capacity[kind]))

	local function onUseCallback(tag, sender)  -- 物品使用弹出框
		ManagerSound.playNormalButtonSound()
		require("app.dialog.ItemUseDialog").new(ITEM_KIND_RESOURCE, kind):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
	local addBtn = CellMenuButton.new(normal, selected, nil, onUseCallback)
	cell:addButton(addBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)

	return cell
end


--------------------------------------------------------------------
-- 仓库储备view
--------------------------------------------------------------------
local ReserverView = class("ReserverView", UiNode)

function ReserverView:ctor(viewFor)
	ReserverView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function ReserverView:onEnter()
	ReserverView.super.onEnter(self)

	-- 仓库储备
	self:setTitle(CommonText[155])

	self.m_resHandler = Notify.register(LOCAL_RES_EVENT, handler(self, self.showUI))
	self.m_updateHandler = Notify.register(LOCAL_EFFECT_EVENT, handler(self, self.showUI))

	self:showUI()
end

function ReserverView:onExit()
	ReserverView.super.onExit(self)

	if self.m_resHandler then
		Notify.unregister(self.m_resHandler)
		self.m_resHandler = nil
	end

	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end

function ReserverView:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 +  container:getContentSize().height / 2)
		container:setAnchorPoint(cc.p(0.5, 0.5))
		self.m_container = container
	end

	self.m_container:removeAllChildren()
	local container = self.m_container

	-- 仓库样式
	local build = UiUtil.createItemSprite(ITEM_KIND_BUILD, BUILD_ID_WAREHOUSE_A):addTo(container)
	build:setAnchorPoint(cc.p(0.5, 0))
	build:setPosition(120, container:getContentSize().height - 120)
	build:setScale(math.min(1, math.min(220 / build:getContentSize().width, 120 / build:getContentSize().height)))

	local build = BuildMO.queryBuildById(BUILD_ID_WAREHOUSE_A)

	local title = ui.newTTFLabel({text = build.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 240, y = container:getContentSize().height - 55, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(container)
	title:setAnchorPoint(cc.p(0, 0.5))

	-- 当前可保护每种资源
	local desc = ui.newTTFLabel({text = CommonText[156][1], font = G_FONT, size = FONT_SIZE_SMALL, x = title:getPositionX(), y = title:getPositionY() - 35, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(container)
	desc:setAnchorPoint(cc.p(0, 0.5))
	local t = UiUtil.label(CommonText[53] ..":", 18, COLOR[2]):alignTo(desc, -25, 1)
	UiUtil.label(CommonText[968], 18, COLOR[1]):rightTo(t)
	local res = BuildBO.getResourceCapacity(true)
	-- dump(res)

	local count = ui.newTTFLabel({text = UiUtil.strNumSimplify(res[RESOURCE_ID_STONE]), font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(container)
	count:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = CommonText[156][2], font = G_FONT, size = FONT_SIZE_SMALL, x = count:getPositionX() + count:getContentSize().width, y = count:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(container)
	desc:setAnchorPoint(cc.p(0, 0.5))

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 140)

	local view = ReserverTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 140), res[RESOURCE_ID_STONE]):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

return ReserverView
