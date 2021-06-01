-- 按钮

local Button = class("Button", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function Button:ctor()
	self:setAnchorPoint(cc.p(0.5, 0.5))

	self.tagCallback_ = nil
	self.doubleTagCallback_ = nil
	self.enabled_ = true
	self.dispatchTouchEvent_ = false
	self.lastTagTime_ = 0

	nodeTouchEventProtocol(self, handler(self, self.onTouch), nil, nil, true)
end

function Button:setTagCallback(tagCallback)
	self.tagCallback_ = tagCallback
end

function Button:getTagCallback(tagCallback)
	return self.tagCallback_
end

function Button:setDoubleTagCallback(doubleTagCallback)
	self.doubleTagCallback_ = doubleTagCallback
end

function Button:onTouchBegan(event)
	if self.dispatchTouchEvent_ then
		return false
	else
		return true
	end
end

function Button:onTouchMoved(event)
end

function Button:onTouchEnded(event)
	if self:containPosition(event.x, event.y) then
		local curTime = socket.gettime()
		if curTime - self.lastTagTime_ <= 0.3 then -- 判断当前点击是否是双击
			if self.doubleTagCallback_ then
				self.doubleTagCallback_(self:getTag(), self)
			end
		else
			if self.tagCallback_ ~= nil then
				self.tagCallback_(self:getTag(), self)
			end
		end

		self.lastTagTime_ = curTime
	end
	--[[
	local point = self:convertToNodeSpace(ccp(x, y))
	local r = self:rect()
	r.origin = ccp(0, 0)

	if r:containsPoint(point) then
		if self.tagCallback_ ~= nil then
			self.tagCallback_(self:getTag(), self)
		end
	end
	]]
end

function Button:onTouchCancelled(event, x, y)
end

function Button:onTouch(event)
	-- print("Button ontouch:" .. event.name)
	if not self:isVisible() or not self:isEnabled() then return false end

    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    else -- cancelled
        self:onTouchCancelled(event)
    end
end

function Button:dispatchTouchEvent(dispatch)
	self.dispatchTouchEvent_ = dispatch
end

function Button:setEnabled(enabled)
	if self.enabled_ ~= ended then
		self.enabled_ = enabled
	end
end

function Button:isEnabled()
	return self.enabled_
end

-- function Button:containPosition(x, y)
-- 	-- local point = self:convertToNodeSpace(ccp(x, y))
	
-- 	-- local point = self:getParent():convertToNodeSpace(cc.p(x, y))
-- 	local point = cc.p(x, y)
-- 	print("Button: point.x:" .. point.x .. " y:" .. point.y .. " x:" .. x .. " y:" .. y)

-- 	if self:hitTest(point, true) then
-- 		print("true")
-- 		return true
-- 	else
-- 		print("false")
-- 		return false
-- 	end


-- 	-- if self:getBoundingBox():rectContainsPoint(point) then
-- 	-- 	return true
-- 	-- else
-- 	-- 	return false
-- 	-- end
-- end

function Button:containPosition(x, y)
	local point = self:getParent():convertToNodeSpace(cc.p(x, y))
	--local point = self:convertToNodeSpace(ccp(x, y))
	--print("Button: point.x:" .. point.x .. " y:" .. point.y .. " x:" .. x .. " y:" .. y)

	local rect = self:getBoundingBox()

	if cc.rectContainsPoint(rect, point) then
		return true
	else
		return false
	end
end

--上下增加h点击区域
function Button:addTouchHeight(h)
	self:height(self:height()+h*2)
	local arr = self:getChildren()
	for i = 0,arr:count() - 1 do
	    local c = arr:objectAtIndex(i)
	    if c and c.getPositionY then
	        c:setPositionY(c:getPositionY()+h)
	    end
	end
end

-- function Button:containPosition(x, y)
--  	-- local point = self:convertToNodeSpace(ccp(x, y))
-- 	-- local point = self:getParent():convertToNodeSpace(cc.p(x, y))
-- 	local point = cc.p(x, y)
-- 	-- print("Button: point.x:" .. point.x .. " y:" .. point.y .. " x:" .. x .. " y:" .. y)
--     -- local nsp = self:convertToNodeSpace(point)

--     local rect = self:getBoundingBox()
--     -- print("Button:" .. " x:" .. x .. " y:" .. y, "nspx:", nsp.x, "nspy:", nsp.y)
--     dump(rect)

--     if cc.rectContainsPoint(rect, point) then
--         return true
--     end

--     return false
-- end

return Button
