
-- 背包

BAG_VIEW_FOR_MINE = 1
BAG_VIEW_FOR_SHOP = 2

local BagView = class("BagView", UiNode)

function BagView:ctor(viewFor, param)
	BagView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	param = param or {}
	param.shopPageIndex = param.shopPageIndex or 1  -- 只有当viewFor为SHOP时才有效

	viewFor = viewFor or BAG_VIEW_FOR_MINE
	self.m_viewFor = viewFor
	self.m_param = param

	self.m_mailHandler = nil
end

function BagView:onEnter()
	BagView.super.onEnter(self)
	
	-- 物资
	self:setTitle(CommonText[151])

	self:hasCoinButton(true)

	local function createDelegate(container, index)
		if index == 1 then  -- 我的物资
			self:showMyBag(container)
		elseif index == 2 then -- 执行任务
			self:showShop(container)
		else
			PropBO.getShopInfo(function()
					self:showOther(container,index)
				end)
		end
	end

	local function clickDelegate(container, index)
		-- if index == 2 then
		-- 	self:hasCoinButton(true)
		-- else
		-- 	self:hasCoinButton(false)
		-- end
	end

	local function clickBaginDelegate(index)
		if index == 4 then
			if not UserBO.IsNewOpen() then
				Toast.show(CommonText[64])
				return false
			end
		end
		return true
	end

	--  "我的物资", "商城"
	local pages = {CommonText[149], CommonText[150],CommonText[20216][1],CommonText[20216][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_mailHandler = Notify.register(LOCAL_USE_POS_SCOUT, handler(self, self.getPosScoutMail))
end

function BagView:showMyBag(container)
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(container)
	tag:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tag:getContentSize().height / 2)

	local size = cc.size(container:getContentSize().width, container:getContentSize().height - 58)
	--  "所有", "资源", "增益", "其他"
	local pages = {CommonText[152], CommonText[153], CommonText[135], CommonText[154]}

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 200, size.height + 34)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 75, size.height + 34)
		elseif index == 3 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 75, size.height + 34)
		elseif index == 4 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 200, size.height + 34)
		end
		button:setLabel(pages[index])
		if index == 2 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() + 10)
		elseif index == 3 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() - 10)
		end
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 200, size.height + 34)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 75, size.height + 34)
		elseif index == 3 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 75, size.height + 34)
		elseif index == 4 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 200, size.height + 34)
		end
		button:setLabel(pages[index], {color = COLOR[11]})
		if index == 2 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() + 10)
		elseif index == 3 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() - 10)
		end
		return button
	end

	local function createDelegate(container, index)
		local BagTableView = require("app.scroll.BagTableView")
		local view = nil

		if index == 1 then  -- 所有
			view = BagTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), VIEW_FOR_MINE_ALL):addTo(container)
		elseif index == 2 then -- 资源
			view = BagTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), VIEW_FOR_MINE_RESOURCE):addTo(container)
		elseif index == 3 then -- 增益
			view = BagTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), VIEW_FOR_MINE_GAIN):addTo(container)
		elseif index == 4 then -- 其他
			view = BagTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), VIEW_FOR_MINE_OTHER):addTo(container)
		end

		if view then
			view:setPosition(0, 0)
			view:reloadData()
		end
	end

	local function clickDelegate(container, index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = container:getContentSize().width / 2, y = size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}, hideDelete = true}):addTo(container, 2)
	pageView:setPageIndex(self.m_param.shopPageIndex)

end

function BagView:showShop(container)
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(container)
	tag:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tag:getContentSize().height / 2)

	local size = cc.size(container:getContentSize().width, container:getContentSize().height - 58)
	--  "所有", "资源", "增益", "其他"
	local pages = {CommonText[152], CommonText[153], CommonText[135], CommonText[154]}

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 200, size.height + 34)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 75, size.height + 34)
		elseif index == 3 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 75, size.height + 34)
		elseif index == 4 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 200, size.height + 34)
		end
		button:setLabel(pages[index])
		if index == 2 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() + 10)
		elseif index == 3 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() - 10)
		end
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 200, size.height + 34)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 75, size.height + 34)
		elseif index == 3 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 75, size.height + 34)
		elseif index == 4 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 200, size.height + 34)
		end
		button:setLabel(pages[index], {color = COLOR[11]})
		if index == 2 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() + 10)
		elseif index == 3 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() - 10)
		end
		return button
	end

	local function createDelegate(container, index)
		local BagTableView = require("app.scroll.BagTableView")
		local view = nil

		if index == 1 then  -- 所有
			view = BagTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), VIEW_FOR_SHOP_ALL):addTo(container)
		elseif index == 2 then -- 资源
			view = BagTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), VIEW_FOR_SHOP_RESOURCE):addTo(container)
		elseif index == 3 then -- 增益
			view = BagTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), VIEW_FOR_SHOP_GAIN):addTo(container)
		elseif index == 4 then -- 其他
			view = BagTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), VIEW_FOR_SHOP_OTHER):addTo(container)
		end

		if view then
			view:setPosition(0, 0)
			view:reloadData()
		end
	end

	local function clickDelegate(container, index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = container:getContentSize().width / 2, y = size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}}):addTo(container, 2)
	pageView:setPageIndex(self.m_param.shopPageIndex)
end

function BagView:showOther(bg,index)
	local text = CommonText[index == 3 and 20215 or 20218]
	local l = UiUtil.label(text[1]):addTo(bg):align(display.LEFT_CENTER, 26, bg:height() - 30)
	UiUtil.label(index == 3 and UserMO.vip_ or StaffMO.worldLv_,nil,COLOR[2]):rightTo(l)
	l = UiUtil.label(text[2],nil,COLOR[2]):alignTo(l, -28, 1)
	l = UiUtil.label(text[3],nil,nil,cc.size(600,0),ui.TEXT_ALIGN_LEFT):addTo(bg):align(display.LEFT_TOP, l:x(), l:y() - l:height()/2 - 5)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(bg)
	line:setPreferredSize(cc.size(bg:width(), line:getContentSize().height))
	line:setPosition(bg:width() / 2, l:y() - l:height())
	local BagTableView = require("app.scroll.BagTableView")
	local view = BagTableView.new(cc.size(bg:getContentSize().width, line:y() - line:height()/2), index == 3 and VIEW_FOR_SHOP_SALE or VIEW_FOR_SHOP_WORLD):addTo(bg)
	view:reloadData()
end

function BagView:refreshUI(name)
	if name == "RechargeView" and self.m_pageView:getPageIndex() == 3 then
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end
end

function BagView:getPosScoutMail(event)
	-- 拿到坐标位置并跳转
	if UiDirector.popMakeUiTop("HomeView") then
		local posStr = event.obj.pos
		local pos = WorldMO.decodePosition(tonumber(posStr))
		local ui = UiDirector.getTopUi()
		ui:showChosenIndex(3)
		ui:getCurContainer():onLocate(pos.x, pos.y)
	end
end

function BagView:onExit()
	-- body
	if self.m_mailHandler then
		Notify.unregister(self.m_mailHandler)
		self.m_mailHandler = nil
	end
	BagView.super.onExit(self)
end

return BagView
