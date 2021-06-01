

local ActivityInterceptView = class("ActivityInterceptView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function ActivityInterceptView:ctor(size)
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5, 0.5))
end

function ActivityInterceptView:onEnter()
end

return ActivityInterceptView