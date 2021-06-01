
--------------------------------------------------------------------
-- 增益tableview
--------------------------------------------------------------------
local EffectTableView = class("EffectTableView", TableView)

function EffectTableView:ctor(size)
	EffectTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	self.m_effects = EffectBO.getShowEffects()
end

function EffectTableView:numberOfCells()
	return #self.m_effects
end

function EffectTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EffectTableView:createCellAtIndex(cell, index)
	EffectTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_EFFECT, self.m_effects[index].effectId):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local effectDB = self.m_effects[index]
	local valid, leftTime = EffectBO.getEffectValid(effectDB.effectId)

	local title = ui.newTTFLabel({text = effectDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

	-- local desc = ui.newTTFLabel({text = effectDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(cell)
	-- desc:setAnchorPoint(cc.p(0.5, 0.5))

	if valid then -- 有增益
		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
		bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 74)
		bar:setPercent(0)
		bar:setLabel(UiUtil.strBuildTime(leftTime, "dhm"))
	end

	local list = PropBO.getCanUsePopIds(ITEM_KIND_EFFECT, effectDB.effectId)
	if list and #list > 0 then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
		local useBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onUseCallback))
		useBtn.effectId = effectDB.effectId
		cell:addButton(useBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
	end
	return cell
end

function EffectTableView:onUseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ItemUseDialog").new(ITEM_KIND_EFFECT, sender.effectId):push()

end

--------------------------------------------------------------------
-- 增益view
--------------------------------------------------------------------

local EffectView = class("EffectView", UiNode)

function EffectView:ctor()
	EffectView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function EffectView:onEnter()
	EffectView.super.onEnter(self)

	-- 增益信息
	self:setTitle(CommonText[262])

	self.m_updateHandler = Notify.register(LOCAL_EFFECT_EVENT, handler(self, self.onEffectUpdate))

	self:showUI()

	SocketWrapper.wrapSend(function(name, data)
			EffectBO.update(data)
		end, NetRequest.new("GetEffect"))
end

function EffectView:onExit()
	EffectView.super.onExit(self)
	
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end

function EffectView:onEffectUpdate()
	self:showUI()
end

function EffectView:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 +  container:getContentSize().height / 2)
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container.status = 1 -- 显示装备
		self.m_container = container
	end

	local container = self.m_container

	container:removeAllChildren()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, 160)

	local function onVIPCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local VipView = require("app.view.VipView")
		VipView.new():push()
	end

	-- VIP特权
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local expandBtn = MenuButton.new(normal, selected, nil, onVIPCallback):addTo(self.m_container)
	expandBtn:setPosition(118, 50)
	expandBtn:setLabel(CommonText[264])


	local function onUseCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ReserverView = require("app.view.ReserverView")
		ReserverView.new():push()
	end

	-- 资源增益
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local useBtn = MenuButton.new(normal, selected, nil, onUseCallback):addTo(self.m_container)
	useBtn:setPosition(self.m_container:getContentSize().width - 118, 50)
	useBtn:setLabel(CommonText[263])


	-- local function onCheckEquip(event)  -- 有装备被选中
	-- 	if self.m_container.status ~= 2 then return end

	-- 	self:onShowChecked()
	-- end

	local view = EffectTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 160)):addTo(container)
	-- view:addEventListener("CHECK_EQUIP_EVENT", onCheckEquip)
	view:setPosition(0, 160)
	view:reloadData()
	-- container.equipTableView_ = view
end

return EffectView