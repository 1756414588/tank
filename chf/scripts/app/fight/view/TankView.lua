
local TankView = class("TankView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function TankView:ctor()
end

return TankView
