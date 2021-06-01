
-- 根据任何，描绘在Map上的路线

local Route = class("Route", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function Route:ctor(startPos, endPos)
	local tag = display.newSprite(IMAGE_COMMON .. "icon_arrow_up.png"):addTo(self)
	tag:setColor(COLOR[2])
end

return Route