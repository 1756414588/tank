--
-- Author: Your Name
-- Date: 2017-06-14 19:58:01
--
--老玩家回归活动
local ActivityPlayerReturnView = class("ActivityPlayerReturnView", UiNode)

function ActivityPlayerReturnView:ctor()
	ActivityPlayerReturnView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function ActivityPlayerReturnView:onEnter()
	ActivityPlayerReturnView.super.onEnter(self)

	self:setTitle(CommonText[100009])

	self:showUI()

	self.r_updateHandler = Notify.register(LOCAL_PLAYER_BACK_UPDATE_EVENT,handler(self, self.refreshUI))
end

function ActivityPlayerReturnView:showUI()
	local function createDelegate(container, index)
		if index == 1 then  -- 回归礼包
			self:showPackage(container)
		elseif index == 2 then -- 回归加成
			self:showPlus(container)
		elseif index == 3 then -- 回归返利
			self:showRebate(container)
		end
	end

	local function clickDelegate(container, index)
	end

	--  "礼包", "加成", "充值返利"
	local pages = {CommonText[100013][1], CommonText[100013][2], CommonText[100013][3]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView
	pageView:setPageIndex(1)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function ActivityPlayerReturnView:showPackage(container)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(container)
	bg:setCapInsets(cc.rect(130, 40, 1, 1))
	bg:setPreferredSize(cc.size(container:getContentSize().width - 40, container:getContentSize().height - 15))
	bg:setPosition(container:getContentSize().width / 2, bg:getContentSize().height / 2)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	titleBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 8)

	local title = ui.newTTFLabel({text = CommonText[100010], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2 + 2)

	local ActivityReturnPackTableView = require("app.scroll.ActivityReturnPackTableView")
	local view = ActivityReturnPackTableView.new(cc.size(bg:getContentSize().width, bg:getContentSize().height - 70)):addTo(bg)
	view:setPosition(0,30)
	view:reloadData()
end

function ActivityPlayerReturnView:showPlus(container)
	SocketWrapper.wrapSend(function(name, data)
			EffectBO.update(data)
		end, NetRequest.new("GetEffect"))
	PlayerBackBO.GetPlayerBackbuffs(function (data)
		local ActivityReturnPlusTableView = require("app.scroll.ActivityReturnPlusTableView")
		local view = ActivityReturnPlusTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height),data):addTo(container)
		view:setPosition(0,0)
		view:reloadData()
	end)
end

function ActivityPlayerReturnView:showRebate(container)
	local rebate = PlayerBackMO.getBackRebateByTime(PlayerBackMO.backTime_)

	local barBg = display.newSprite(IMAGE_COMMON .. "player_back_banner.jpg"):addTo(container)
	barBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - barBg:getContentSize().height / 2)
	local desc = ui.newTTFLabel({text = CommonText[100011][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80, dimensions = cc.size(550, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(barBg)
	local desc2 = ui.newTTFLabel({text = CommonText[100011][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 50, dimensions = cc.size(550, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(barBg)

	local desc = UiUtil.label(rebate.desc or "",FONT_SIZE_SMALL,nil, cc.size(container:width() - 80, 0),ui.TEXT_ALIGN_LEFT):addTo(container):align(display.LEFT_CENTER,20,barBg:getPositionY() - barBg:height() / 2 -20)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_82.png"):addTo(container)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setPosition(container:width() / 2,desc:getPositionY() - bg:height() / 2 - 40)
	local itemView = UiUtil.createItemView(ITEM_KIND_RED_PACKET, 108):addTo(bg)
	itemView:setPosition(itemView:width() / 2 +30 ,bg:height() / 2)
	itemView:setScale(0.8)

	-- 去充值
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local goBtn = MenuButton.new(normal, selected, nil, function ()
		ManagerSound.playNormalButtonSound()
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
	end):addTo(bg)  -- 确定
	goBtn:setLabel(CommonText[10004])
	goBtn:setPosition(bg:width() - goBtn:width() / 2 - 20,bg:height() / 2)

	local over = UiUtil.label(CommonText[100017],FONT_SIZE_SMALL,COLOR[6]):addTo(bg):pos(bg:width() / 2,bg:height() / 2)
	over:setVisible(PlayerBackMO.backPackage_.today >= 4)

end

function ActivityPlayerReturnView:refreshUI()
	if self.m_pageView and self.m_pageView:getPageIndex() ~= 2 then
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end
end

function ActivityPlayerReturnView:onExit()
	ActivityPlayerReturnView.super.onExit(self)

	if self.r_updateHandler then
		Notify.unregister(self.r_updateHandler)
		self.r_updateHandler = nil
	end
end

return ActivityPlayerReturnView