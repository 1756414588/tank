
local PrizeCycleView = class("PrizeCycleView", CycleView)

function PrizeCycleView:ctor(size, grid)
	PrizeCycleView.super.ctor(self, size)

	self.m_grid = grid
	self.m_cellSize = cc.size(size.width, 120)
	self.m_prizes = SignMO.querySignLoginsByGrid(self.m_grid)

	-- gprint("Grid:", self.m_grid)
	-- gdump(self.m_prizes, "PrizeCycleView")
end

-- function PrizeCycleView:onEnter()
-- end

function PrizeCycleView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PrizeCycleView:numberOfCells()
	return #self.m_prizes
end

function PrizeCycleView:createCellAtIndex(cell, index)
	local prize = self.m_prizes[index]

	local itemView = UiUtil.createItemView(prize.type, prize.itemId, {count = prize.count}):addTo(cell)
	itemView:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(itemView)
	return cell
end

------------------------------------------------------------------------------
-- 每日登陆弹出框
------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local DailyLoginDialog = class("DailyLoginDialog", Dialog)

function DailyLoginDialog:ctor()
	DailyLoginDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 610)})
end

function DailyLoginDialog:onEnter()
	DailyLoginDialog.super.onEnter(self)
	self:getCloseButton():setEnabled(false)

	self.m_startMove = {}
	self.m_moveOffset = {}
	self.m_desOffset = {}

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[498][1]) -- 每日登陆奖励

	local normal = nil
	local selected = nil
	local disabled = nil
	if not SignMO.dailyLogin_.accept then  -- 还没有领取
		normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
		selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	else
		normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
		selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
		disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	end
	local btn = MenuButton.new(display.newSprite(IMAGE_COMMON .. "btn_10_normal.png"), display.newSprite(IMAGE_COMMON .. "btn_10_selected.png"), disabled, nil):addTo(self:getBg(), 5)
	btn:setPosition(self:getBg():getContentSize().width / 2, 25)
	self.m_button = btn

	self:showUI()
end

function DailyLoginDialog:showUI()
	if not SignMO.dailyLogin_.accept then  -- 还没有领取
		self.m_button:setLabel(CommonText[498][2])  -- 试试手气
		self.m_button:setTagCallback(handler(self, self.onStartCallback))
	else
		self.m_button:setLabel(CommonText[326][4])  -- 关闭
		self.m_button:setTagCallback(handler(self, self.onCloseCallback))
	end

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_74.jpg"):addTo(self:getBg())
	bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 10)

	local rect = cc.rect(0, 0, 410, 320)
    local node = display.newClippingRegionNode(rect):addTo(bg, 4)
    node:setPosition(44, 90)
    self.m_prizeFrame = node

    self.m_cycleViews = {}

    local pos = {62, 190, 320}

    gdump(SignMO.dailyLogin_.loginIds, "DailyLoginDialog login ids")

    for index = 1, 3 do

	    local view = PrizeCycleView.new(cc.size(110, 320), index):addTo(bg, 4)
	    view:setPosition(pos[index], 90)
	    view:reloadData()
	    view:setContentOffset(cc.p(0, 0))
		self.m_cycleViews[index] = view

		if SignMO.dailyLogin_.accept then  -- 已经领取了
    		local loginIndex = self:getLocationPrizeIndex(index, SignMO.dailyLogin_.loginIds[index])
    		-- if not loginIndex or loginIndex == 0 then
    		-- 	loginIndex = 1
    		-- end
    		local maxOffset = view:getMaxContentOffset()
    		local offsetY = 320 / 2 - (maxOffset.y - (loginIndex - 0.5) * 120)
    		view:setContentOffset(cc.p(0, offsetY))
		end
    end

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	local shade = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_75.png"):addTo(self:getBg(), 3)
	shade:setPreferredSize(cc.size(410, shade:getContentSize().height))
	shade:setPosition(self:getBg():getContentSize().width / 2, 407)

	local shade = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_75.png"):addTo(self:getBg(), 3)
	shade:setScaleY(-1)
	shade:setPreferredSize(cc.size(410, shade:getContentSize().height))
	shade:setPosition(self:getBg():getContentSize().width / 2, 196)
end

function DailyLoginDialog:getLocationPrizeIndex(gridIndex, loginId)
	local prizes = SignMO.querySignLoginsByGrid(gridIndex)
	for index = 1, #prizes do
		local prize = prizes[index]
		if prize.loginId == loginId then
			return index
		end
	end
end

function DailyLoginDialog:onStartCallback(tag, sender)
	if SignMO.dailyLogin_.accept then -- 已领取
		return
	end

	local function doneCallback()
		Loading.getInstance():unshow()

		for index = 1, #self.m_cycleViews do
			local view = self.m_cycleViews[index]
			view:setTouchEnabled(false)

			local maxOffset = view:getMaxContentOffset()

			self.m_moveOffset[index] = cc.p(maxOffset.x, 0)

			local loginIndex = self:getLocationPrizeIndex(index, SignMO.dailyLogin_.loginIds[index])
			local offsetY = 320 / 2 - (maxOffset.y - (loginIndex - 0.5) * 120)
			-- gprint("offsetY:", offsetY, "index:", index)
			if offsetY > 0 then offsetY = offsetY - maxOffset.y end

			self.m_desOffset[index] = cc.p(maxOffset.x, -maxOffset.y + offsetY)

			self.m_startMove[index] = true
		end

		sender:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_2_normal.png"))
		sender:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_2_selected.png"))
		sender:setDisabledSprite(display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png"))
		sender:setLabel(CommonText[326][4])  -- 关闭
		sender:setEnabled(false)
		sender:setTagCallback(handler(self, self.onCloseCallback))
	end

	Loading.getInstance():show()
	SignBO.asynAcceptEveLogin(doneCallback)
end

function DailyLoginDialog:onCloseCallback(tag, sender)
	self:pop()
end

local deltaOffset = {-3, -4.5, -8}

function DailyLoginDialog:update(dt)
	for index = 1, #self.m_cycleViews do
		if self.m_startMove[index] then
			self.m_moveOffset[index].y = self.m_moveOffset[index].y + deltaOffset[index]

			if self.m_moveOffset[index].y < self.m_desOffset[index].y then  -- 运动完了
				self.m_startMove[index] = false

				local loginId = SignMO.dailyLogin_.loginIds[index]
				local signLogin = SignMO.querySignLoginById(loginId)

			    local scene = display.getRunningScene()
			    if scene then
			    	local AwardsView = require("app.view.AwardsView")
			        local view = AwardsView.new({{kind = signLogin.type, id = signLogin.itemId, count = signLogin.count}}):addTo(scene, 10)
			        view:setPosition(display.width / 2 + (index - 2) * 60, display.height / 2)
			    end
			else
				local view = self.m_cycleViews[index]
				view:setContentOffset(self.m_moveOffset[index])
			end
		end
	end

	local open = true
	for index = 1, #self.m_cycleViews do
		if self.m_startMove[index] then
			open = false
			break
		end
	end
	if open and not self.m_button:isEnabled() then
		for index = 1, #self.m_cycleViews do
			local view = self.m_cycleViews[index]
			view:setTouchEnabled(true)
		end
		self.m_button:setEnabled(true)
	end
end

return DailyLoginDialog
