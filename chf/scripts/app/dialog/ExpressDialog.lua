
-- 表情弹出框
local ComponentPageView = class("ComponentPageView", function(size)
    if not size then size = cc.size(0, 0) end
    local rect = cc.rect(0, 0, size.width, size.height)

    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function ComponentPageView:ctor(size,rhand)
	self.m_viewSize = size
	self.rhand = rhand
	self.m_viewNode = {}
	self.m_curPageIndex = 0
	self.data = {}
	for index = 1, #UserMO.express do
		local page = math.floor((index -1)/28) + 1
		if not self.data[page] then
			self.data[page] = {}
		end
		local row = math.floor((index - 1) / 7)
		row = row % 4 + 1
		if not self.data[page][row] then
			self.data[page][row] = {}
		end
		table.insert(self.data[page][row], UserMO.express[index])
	end
	self.selected_ = {}
end

function ComponentPageView:onEnter()
	local container = display.newNode():addTo(self)
	container:setContentSize(self.m_viewSize)
	nodeTouchEventProtocol(container, function(event)
        	return self:onTouch(event)
        end)
	self.m_container = container

	local startX = self:getViewSize().width / 2 - (self:numberOfCells() - 1) * 30 / 2

    for index = 1, self:numberOfCells() do
        local bg = display.newSprite("image/common/dot_0.png"):addTo(self)
        bg:setPosition(startX + (index - 1) * 30, 10)

        local selected = display.newSprite("image/common/dot_1.png"):addTo(self, 2)
        selected:setPosition(bg:getPositionX(), bg:getPositionY())
        selected:setVisible(false)

        self.selected_[index] = selected
    end
end

function ComponentPageView:numberOfCells()
	return #self.data
end

function ComponentPageView:cellSizeForIndex(index)
	return self:getViewSize()
end

function ComponentPageView:setCurrentIndex(pageIndex, animated)
	if self.m_moveAnimation then return end
	if self.m_curPageIndex == pageIndex then return end
	if pageIndex > self:numberOfCells() then pageIndex = pageIndex % self:numberOfCells() end
	if pageIndex == 0 then pageIndex = self:numberOfCells() end

	-- gprint("ComponentPageView:setCurrentIndex: pageIndex:", pageIndex)

	if not self.m_viewNode[pageIndex] then
		local node = display.newNode():addTo(self.m_container)
		local cell = self:createCellAtIndex(node, pageIndex)
		self.m_viewNode[pageIndex] = cell
	end

	local function setPage()
		for index = 1, self:numberOfCells() do
			if index ~= pageIndex then
				if self.m_viewNode[index] then  -- 删除掉没有使用的page
					self.m_viewNode[index]:removeSelf()
					self.m_viewNode[index] = nil
				end
			end
			
	        self.selected_[index]:stopAllActions()
            if index ~= pageIndex then
	            self.selected_[index]:setVisible(false)
	        else
	        	self.selected_[index]:setVisible(true)
	        	self.selected_[index]:setOpacity(255)
	        end
	    end

		self.m_curPageIndex = pageIndex
	end

	if animated then
		self.m_moveAnimation = true
		local moveX = 0
		if (pageIndex < self.m_curPageIndex and not (self.m_curPageIndex == self:numberOfCells() and pageIndex == 1)) or (self.m_curPageIndex == 1 and pageIndex == self:numberOfCells()) then
			self.m_viewNode[pageIndex]:setPosition(-self:getViewSize().width, 0)
			moveX = self:getViewSize().width
		else
			self.m_viewNode[pageIndex]:setPosition(self:getViewSize().width, 0)
			moveX = -self:getViewSize().width
		end

		-- gprint("pageIndex:", pageIndex, "curPage:", self.m_curPageIndex)

		self.m_container:runAction(transition.sequence({cc.MoveTo:create(0.6, cc.p(moveX, 0)), cc.CallFunc:create(function()
				self.m_container:setPosition(0, 0)
				self.m_viewNode[pageIndex]:setPosition(0, 0)

				self.m_moveAnimation = false
				setPage()
			end)}))
	else
		setPage()
	end
end

function ComponentPageView:getCurrentIndex()
	return self.m_curPageIndex
end

function ComponentPageView:getNodeAtIndex(index)
	return self.m_viewNode[index]
end

function ComponentPageView:createCellAtIndex(cell, index)
	local data = self.data[index]
	cell.view = {}
	local x,y,ex,ey = 50,self:height() - 55,90,70
	for k,v in ipairs(data) do
		for m,n in ipairs(v) do
			local view = display.newSprite("image/express/" .. n.icon .. ".png"):addTo(cell)
			view:setPosition(x +  (m-1)* ex, y - (k-1) * ey)
			view:setScale(0.87)
			view.id = n.id
			table.insert(cell.view,view)
		end
	end
	return cell
end

function ComponentPageView:getViewSize()
	return self.m_viewSize
end

function ComponentPageView:onTouch(event)
    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    else
        self:onTouchCancelled(event)
    end
end

function ComponentPageView:onTouchBegan(event)
    if not self:isVisible() then return false end
    self.m_touchPoint = cc.p(event.x, event.y)
    return true
end

function ComponentPageView:onTouchEnded(event)
    if not self:isVisible() then return end
	-- gprint("ComponentPageView:onTouch, event:", event.name)
	if not self.m_touchPoint then return end

	local deltaX = event.x - self.m_touchPoint.x
	-- gprint("deltaX:", deltaX)

	if math.abs(deltaX) <= 18 then
		for k,v in ipairs (self.m_viewNode[self.m_curPageIndex].view) do
			if v:getCascadeBoundingBox():containsPoint(ccp(event.x,event.y)) then
				if self.rhand then self.rhand(v.id) end
				break
			end
		end
		return 
	end

	if deltaX < 0 then
		self:setCurrentIndex(self:getCurrentIndex() + 1, true)
	else
		self:setCurrentIndex(self:getCurrentIndex() - 1, true)
	end

end

function ComponentPageView:onTouchCancelled(event)
	self.m_touchPoint = nil
end

--------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ExpressDialog = class("ExpressDialog", Dialog)

function ExpressDialog:ctor(expressCallback)
	ExpressDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_37.png", UI_ENTER_NONE, {scale9Size = cc.size(GAME_SIZE_WIDTH, 320), alpha = 0})

	local t = display.newSprite(IMAGE_COMMON.."group_1.png")
		:addTo(self):center()
	t:scaleTX(self:width())
	t:scaleTY(self:height())

	self.m_expressCallback = expressCallback
end

function ExpressDialog:onEnter()
	ExpressDialog.super.onEnter(self)
	self:setOutOfBgClose(true)
	self:setUI()
end

function ExpressDialog:setUI()
	-- for index = 1, #ExpressMap do
	-- 	local row = math.floor((index - 1) / 7)
	-- 	local col = (index - 1) % 7

	-- 	-- gprint("index:", index, "row:", row, "col:", col)

	-- 	local express = ExpressMap[index]
	-- 	local name = express.key
	-- 	local view = display.newSprite("image/express/" .. name .. ".png")
	-- 	local btn = TouchButton.new(view, nil, nil, nil, handler(self, self.onExpressCallback)):addTo(self:getBg())
	-- 	btn:setPosition(50 + col * 90, self:getBg():getContentSize().height - 55 - row * 70)
	-- 	btn:setScale(0.87)
	-- 	btn.index = index
	-- end
	local view = ComponentPageView.new(cc.size(GAME_SIZE_WIDTH, 320),self.m_expressCallback):addTo(self:getBg())
	view:setCurrentIndex(1)
	self.m_pageView = view
end

return ExpressDialog