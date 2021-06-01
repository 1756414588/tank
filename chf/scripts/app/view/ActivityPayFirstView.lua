
-- 首充礼包活动View

local ActivityPayFirstView = class("ActivityPayFirstView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function ActivityPayFirstView:ctor(size)
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5, 0.5))
end

function ActivityPayFirstView:onEnter()
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_2.jpg"):addTo(self)
	bg:setPosition(self:getContentSize().width / 2 + 4, self:getContentSize().height - bg:getContentSize().height / 2 - 15)
	self.m_bg = bg

	local title = display.newSprite(IMAGE_COMMON .. "label_pay_first_1.png"):addTo(self.m_bg)
	title:setPosition(self.m_bg:getContentSize().width / 2, self.m_bg:getContentSize().height - 60)

	local awardDB = json.decode(ActivityMO.queryActivityAwardsById(FIRST_RECHARGE_ACTIVITY_ID).awardList)
	for index=1,#awardDB do
		local itemView = UiUtil.createItemView(awardDB[index][1], awardDB[index][2], {count = awardDB[index][3]}):addTo(self.m_bg)
		itemView:setScale(0.9)
		itemView:setPosition(20 + (index - 0.5) * 105, self.m_bg:getContentSize().height - 140)
		UiUtil.createItemDetailButton(itemView)

		local resData = UserMO.getResourceData(awardDB[index][1], awardDB[index][2])
		local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = self.m_bg:getContentSize().height - 200, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_bg)
	end

	-- 首充双倍金币
	local itemView = UiUtil.createItemView(ITEM_KIND_COIN):addTo(self.m_bg)
	itemView:setScale(0.9)
	itemView:setPosition(20 + 3.5 * 105, self.m_bg:getContentSize().height - 140)
	-- UiUtil.createItemDetailButton(itemView)
	local resData = UserMO.getResourceData(ITEM_KIND_COIN)
	local name = ui.newTTFLabel({text = CommonText[462], font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = self.m_bg:getContentSize().height - 200, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_bg)

	local title = display.newSprite(IMAGE_COMMON .. "label_pay_first_2.png"):addTo(self.m_bg)
	title:setPosition(self.m_bg:getContentSize().width / 2, self.m_bg:getContentSize().height - 260)

	for index = 1, 3 do
		local bg = display.newSprite(IMAGE_COMMON .. "info_bg_50.png"):addTo(self.m_bg)
		bg:setPosition(self.m_bg:getContentSize().width / 2, self.m_bg:getContentSize().height - 336 - (index - 1) * 42)

		local texts = CommonText[464][index]
		local label = ui.newTTFLabel({text = texts[1], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[12], x = 20, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = texts[2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		label:setAnchorPoint(cc.p(0, 0.5))

		if texts[3] then
			local tag = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(bg)
			tag:setPosition(label:getPositionX() + label:getContentSize().width + tag:getContentSize().width / 2, label:getPositionY())

			local label = ui.newTTFLabel({text = texts[3], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = tag:getPositionX() + tag:getContentSize().width / 2, y = tag:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	-- local activity = ActivityMO.getActivityById(ACTIVITY_ID_PAY_FIRST)

	-- 马上参与
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onGoCallback)):addTo(self.m_bg)
	btn:setPosition(self.m_bg:getContentSize().width  /2, 50)
	btn:setLabel(CommonText[463])

	-- if not activity.open then
	-- 	btn:setEnabled(false)
	-- elseif self.m_activityContent.state ~= 0 then -- 已充值
	-- 	btn:setEnabled(false)
	-- end
end

function ActivityPayFirstView:onGoCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- require("app.view.RechargeView").new():push()
	RechargeBO.openRechargeView()
end

return ActivityPayFirstView