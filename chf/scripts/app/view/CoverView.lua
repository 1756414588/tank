--
-- Author: Gss
-- Date: 2018-05-19 06:05:45
--

local CoverView = class("CoverView",function()
    local node = display.newNode()
    nodeExportComponentMethod(node)
    node:setNodeEventEnabled(true)
    return node
end)

function CoverView:ctor(rect, size, dis, direction)
	-- assert(direction == SCROLL_DIRECTION_VERTICAL or direction == SCROLL_DIRECTION_HORIZONTAL)

	self.m_rect = rect
	self.m_viewSize = rect.size
	self.m_dis = dis
	self.m_direction = SCROLL_DIRECTION_VERTICAL or SCROLL_DIRECTION_HORIZONTAL
	self.m_delaY = 0
	self.m_cellNum = 0
end

function CoverView:onEnter()
	self.m_touchMoved = false

	self:initData()
end

function CoverView:initData()
	local size = cc.size(display.width, display.height)

	self.m_cellList = {}
	-- local offSetPositon = cc.p(size.width / 2, size.height / 2)

	local scrollView = CCScrollView:create():addTo(self) --  ScrollView.new(size, SCROLL_DIRECTION_VERTICAL):addTo(self)
	scrollView:setPosition(0,0)
	scrollView:setDirection(SCROLL_DIRECTION_VERTICAL)
	-- scrollView:setViewSize(cc.size(self.m_viewSize.width, self.m_viewSize.height))
	scrollView:setViewSize(cc.size(260, 143 * 3))
	scrollView:setContentOffset(cc.p(0, 0))
	scrollView:setTouchEnabled(false)
	self.m_scrollView = scrollView

	local scrollLayer = display.newColorLayer(ccc4(222, 22, 222, 180)):addTo(scrollView)
	scrollLayer:setPosition(cc.p(0, 0))
	self.m_scrollLayer = scrollLayer
	nodeTouchEventProtocol(scrollLayer, function(event)
        	return self:onTouch(event)
        end)
end

function CoverView:onTouch(event)
    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    end
end

function CoverView:onTouchBegan(event)
	self.m_touchMoved = false

	self.m_touchPoint = cc.p(event.x, event.y)


	local rect = self:getViewRect()
	-- 滑动到可视范围外的不支持
	if not cc.rectContainsPoint(rect, cc.p(self.m_touchPoint.x, self.m_touchPoint.y)) then
	    self.m_touches = {}
	    self.m_scrollDistance = cc.p(0, 0)
	    return false
	end

	return true
end

function CoverView:onTouchMoved(event)
	--根据移动距离判断是否移动了
	-- local function convertDistanceFromPointToInch(pointDis)
	--     local factor = ( CCEGLView:sharedOpenGLView():getScaleX() + CCEGLView:sharedOpenGLView():getScaleY() ) / 2
	--     return pointDis * factor / CCDevice:getDPI()
	-- end

	-- local newPoint = cc.p(event.x, event.y)

	-- local moveDistance = cc.PointSub(newPoint, self.m_touchPoint)

	-- if not self.m_touchMoved and math.abs(convertDistanceFromPointToInch(moveDistance.y)) < 0.04375 then
	--     return
	-- end

	-- if not self.m_touchMoved then
	--     moveDistance = cc.p(0, 0)
	-- end

	-- self.m_touchPoint = newPoint
	-- self.m_touchMoved = true

	-- local rect = self:getViewRect()

	-- if cc.rectContainsPoint(rect, self.m_touchPoint) then
	-- 	if self.m_direction == SCROLL_DIRECTION_VERTICAL then
	-- 	    moveDistance = cc.p(0, moveDistance.y)
	-- 	elseif self.m_direction == SCROLL_DIRECTION_HORIZONTAL then
	-- 	    moveDistance = cc.p(moveDistance.x, 0)
	-- 	end

 --        local newPos = cc.p(0, self.m_scrollView:getPositionY() + moveDistance.y)
 --        self.m_scrollDistance = moveDistance

 --        self.m_scrollView:setContentOffset(newPos)
	-- end
end

function CoverView:onTouchEnded(event)
	self.m_delaY = self.m_touchPoint.y - event.y

	self:adjusetEndScrollView()
end

--滚动
function CoverView:adjustScrollView(disP)
	-- body
end

--cell 处理
function CoverView:adjustCellScale(dosP)
	local disX, disY = dosP.x, dosP.y
end

--滚动结束
function CoverView:adjusetEndScrollView()

	local minY = 141
	local midX = display.height / 2 

	--获取距离中间最小值的card 
	for index=1,#self.m_cellList do
		local cell = self.m_cellList[index]
		local offset = self.m_scrollView:getContentOffset().y

		--转化父类坐标 
		local posY = cell:getPositionY() + offset
		local dis = midX - posY

		if math.abs(dis) < math.abs(minY) then
			minY = dis
		end
	end

	for idx=1,#self.m_cellList do
		local item = self.m_cellList[idx]
		--转化父类坐标
		local  offset = self.m_scrollView:getContentOffset().y
		local  posY = item:getPositionX() + offset 

		--距离中间长度 
		local disMid = math.abs(midX - posY - minY) 
	end

	if self.m_delaY == 0 then
		minY = 0
	elseif self.m_delaY < 0 then
		minY = 142
	elseif self.m_delaY > 0 then
		minY = -142
	end

	self.m_scrollLayer:runAction(cc.MoveBy:create(0.2, cc.p(0, minY)))
end

function CoverView:getViewRect()
	local screenPos = self:convertToWorldSpace(cc.p(0, 0))

	local scaleX = self:getScaleX()
	local scaleY = self:getScaleY()

	local p = self:getParent()
	while p ~= nil do
	    scaleX = scaleX * p:getScaleX()
	    scaleY = scaleY * p:getScaleY()

	    p = p:getParent()
	end

	if scaleX < 0 then
	    screenPos.x = screenPos.x + self.m_viewSize.width * scaleX
	    scaleX = -scaleX
	end

	if scaleY < 0 then
	    screenPos.y = screenPos.y + self.m_viewSize.height * scaleY
	    scaleY = -scaleY
	end

	return cc.rect(screenPos.x, screenPos.y, self.m_viewSize.width * scaleX, self.m_viewSize.height * scaleY)
end

function CoverView:createCell(cell,index)
	local cell = cell
	cell:addTo(self.m_scrollLayer)

	-- local positionX = display.width + self.m_dis * self.m_cellNum
	-- local positionY = self.m_dis / 2 + self.m_cellNum * self.m_dis
	local positionX = display.width + self.m_dis * index
	local positionY = self.m_dis / 2 + (index - 1) * self.m_dis

	local aaa = self.m_viewSize.height - positionY + 2


	cell:setPosition(cc.p(self.m_scrollLayer:getContentSize().width / 2, aaa))

	self.m_cellList[#self.m_cellList + 1] = cell
	-- self.m_cellNum = self.m_cellNum + 1
end

function CoverView:onExit()
	-- body
end

return CoverView