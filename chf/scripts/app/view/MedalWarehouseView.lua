--
-- Author: xiaoxing
-- Date: 2016-12-22 11:21:14
--

local MedalWarehouseView = class("MedalWarehouseView", UiNode)

function MedalWarehouseView:ctor(viewFor)
	MedalWarehouseView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function MedalWarehouseView:onEnter()
	MedalWarehouseView.super.onEnter(self)

	-- 配件仓库
	self:setTitle(CommonText[20163][1] .. CommonText[169])

	self.m_partHandler = Notify.register(LOCLA_MEDAL_EVENT, handler(self, self.onMedalUpdate))

	local function createDelegate(container, index)
		if index == 1 then  -- 配件
			self:showComponent(container)
		elseif index == 2 then -- 碎片
			self:showPiece(container)
		elseif index == 3 then -- 坦克修复
			self:showMaterial(container)
		end
		if index < 3 and self.ey then
			self.view:setContentOffset(cc.p(0, self.ey))
			self.ey = nil
		end
	end

	local function clickDelegate(container, index)
	end

	--  "配件", "碎片", "材料"
	local pages = {CommonText[20163][1], CommonText[164], CommonText[165]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function MedalWarehouseView:onExit()
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end
end

function MedalWarehouseView:onMedalUpdate(event)
	if self.m_pageView:getPageIndex() < 3 then
		self.ey = self.view:getContentOffset().y
	end
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end
-- 
function MedalWarehouseView:showComponent(container)
	local ComponentWarehouseTableView = require("app.scroll.ComponentWarehouseTableView")
	local view = ComponentWarehouseTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 160 - 4), VIEW_FOR_PART, "medal"):addTo(container)
	view:setPosition(0, 160)
	view:reloadData()
	self.view = view
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

	local desc = ui.newTTFLabel({text = CommonText[20169], font = G_FONT, size = FONT_SIZE_SMALL, x = 230, y = btn:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	desc:setAnchorPoint(cc.p(0, 0.5))
end

function MedalWarehouseView:showPiece(container)
	local ComponentWarehouseTableView = require("app.scroll.ComponentWarehouseTableView")
	local view = ComponentWarehouseTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 160 - 4), VIEW_FOR_CHIP,"medal"):addTo(container)
	view:setPosition(0, 160)
	view:reloadData()
	self.view = view
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, 160)

	-- 批量分解
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onBatchCallback)):addTo(container)
	btn:setPosition(110, 50)
	btn.index = 2
	btn:setLabel(CommonText[166])
	
	local desc = ui.newTTFLabel({text = CommonText[20169], font = G_FONT, size = FONT_SIZE_SMALL, x = 230, y = btn:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	desc:setAnchorPoint(cc.p(0, 0.5))
end

function MedalWarehouseView:showMaterial(container)
	local PartMaterialTableView = require("app.scroll.PartMaterialTableView")
	local view = PartMaterialTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4),"medal"):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function MedalWarehouseView:onBatchCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.index == 1 then
		require("app.dialog.BatchDecomposeDialog").new(BATCH_DIALOG_FOR_MEDAL):push()
	else
		require("app.dialog.BatchDecomposeDialog").new(BATCH_DIALOG_FOR_MEDAL_CHIP):push()
	end
end

return MedalWarehouseView
