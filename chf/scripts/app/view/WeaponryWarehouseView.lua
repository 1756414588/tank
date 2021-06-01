
-- 配件仓库view

local WeaponryWarehouseView = class("WeaponryWarehouseView", UiNode)

function WeaponryWarehouseView:ctor(viewFor)
	WeaponryWarehouseView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function WeaponryWarehouseView:onEnter()
	WeaponryWarehouseView.super.onEnter(self)

	-- 配件仓库
	self:setTitle(CommonText[1600][1])

	self.m_partHandler = Notify.register(LOCLA_PART_EVENT, handler(self, self.onPartUpdate))
	self.m_WeaponryLockHandler = Notify.register(LOCAL_WEAPONRY_LOCK, handler(self, self.onPartUpdate))

	local function createDelegate(container, index)
		if index == 1 then  -- 军备
			self:showComponent(container)
		elseif index == 2 then -- 图纸
			self:showPiece(container)
		elseif index == 3 then -- 材料
			self:showMaterial(container)
		end
	end

	local function clickDelegate(container, index)
	end

	--  "军备", "图纸", "材料"
	local pages = {CommonText[1600][2], CommonText[1600][4], CommonText[165]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function WeaponryWarehouseView:onExit()
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end

	if self.m_WeaponryLockHandler then
		Notify.unregister(self.m_WeaponryLockHandler)
		self.m_WeaponryLockHandler = nil
	end
end

function WeaponryWarehouseView:onPartUpdate(event)
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

-- 
function WeaponryWarehouseView:showComponent(container)
	local ComponentWarehouseTableView = require("app.scroll.ComponentWarehouseTableView")
	local view = ComponentWarehouseTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 160 - 4), VIEW_FOR_PART,"weaponry"):addTo(container)
	view:setPosition(0, 160)
	view:reloadData()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, 160)

	-- 批量分解
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onBatchCallback)):addTo(container)
	btn:setPosition(110, 50)
	btn.index = 1
	btn:setLabel(CommonText[166])

	local desc = ui.newTTFLabel({text = CommonText[1612], font = G_FONT, size = FONT_SIZE_SMALL, x = 230, y = btn:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	desc:setAnchorPoint(cc.p(0, 0.5))
end

function WeaponryWarehouseView:showPiece(container)
	local ComponentWarehouseTableView = require("app.scroll.ComponentWarehouseTableView")
	local view = ComponentWarehouseTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 160 - 4), VIEW_FOR_CHIP,"weaponry"):addTo(container)
	view:setPosition(0, 160)
	view:reloadData()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, 160)

	-- -- 批量分解
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	-- local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	-- local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onBatchCallback)):addTo(container)
	-- btn:setPosition(110, 50)
	-- btn.index = 2
	-- btn:setLabel(CommonText[166])
	
	-- local desc = ui.newTTFLabel({text = CommonText[191], font = G_FONT, size = FONT_SIZE_SMALL, x = 230, y = btn:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	-- desc:setAnchorPoint(cc.p(0, 0.5))
end

function WeaponryWarehouseView:showMaterial(container)
	local PartMaterialTableView = require("app.scroll.PartMaterialTableView")
	local view = PartMaterialTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4),"weaponry"):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function WeaponryWarehouseView:onBatchCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.index == 1 then
		require("app.dialog.BatchDecomposeDialog").new(BATCH_DIALOG_FOR_WEAPONRY):push()
	-- else
	-- 	require("app.dialog.BatchDecomposeDialog").new(BATCH_DIALOG_FOR_PIECE):push()
	end
end

return WeaponryWarehouseView
