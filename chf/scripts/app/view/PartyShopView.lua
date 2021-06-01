--
-- Author: gf
-- Date: 2015-09-14 11:59:44
-- 军团商店

local PartyShopView = class("PartyShopView", UiNode)

function PartyShopView:ctor(buildingId)
	PartyShopView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function PartyShopView:onEnter()
	PartyShopView.super.onEnter(self)

	self.m_updateHandler = Notify.register(LOCAL_PARTY_MYDONATE_UPDATE_EVENT, handler(self, self.updateMyDonate))
	self:setTitle(CommonText[591])

	local function createDelegate(container, index)
		local PartyShopTableView = require("app.scroll.PartyShopTableView")
		local view = nil

		view = PartyShopTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 90), index):addTo(container)

		if view then
			view:setPosition(0, 0)
			view:reloadData()
		end

		--按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
		local ruleBtn = MenuButton.new(normal, selected, nil, handler(self,self.ruleHandler)):addTo(container)
		ruleBtn:setPosition(container:getContentSize().width - 70,container:getContentSize().height - 50)

		local donateLab = ui.newTTFLabel({text = CommonText[587], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, 
		y = container:getContentSize().height - 50, 
		color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		donateLab:setAnchorPoint(cc.p(0, 0.5))

		local donateValue = ui.newTTFLabel({text = PartyMO.myDonate_, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = donateLab:getPositionX() + donateLab:getContentSize().width + 10, 
		y = donateLab:getPositionY(), 
		color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		donateValue:setAnchorPoint(cc.p(0, 0.5))
		self.m_donateValueLabel = donateValue


	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[586][1],CommonText[586][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_index_ = 1
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function PartyShopView:ruleHandler()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyShopRuleDialog").new():push()
end

function PartyShopView:updateMyDonate()
	self.m_donateValueLabel:setString(PartyMO.myDonate_)
end


function PartyShopView:onExit()
	-- gprint("PartyShopView onExit() ........................")
	PartyShopView.super.onExit(self)
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end




return PartyShopView