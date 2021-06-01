
-- 能晶仓库TableView

local COL_NUM = 5
local SHOW_GRID_LIMIT = 60

local EngrysparWarehouseTableView = class("EngrysparWarehouseTableView", TableView)

function EngrysparWarehouseTableView:ctor(size)
	EngrysparWarehouseTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 120)

	self.m_parts = PartMO.getFreeParts()
	table.sort(self.m_parts, PartBO.sortPart)
end

function EngrysparWarehouseTableView:refrushTableView(holeType)
	self.m_energyspars = EnergySparMO.getAllEnergySpars(holeType)
	self:reloadData()
end

function EngrysparWarehouseTableView:numberOfCells()
	if #self.m_energyspars > SHOW_GRID_LIMIT then
		return math.ceil(#self.m_energyspars / COL_NUM)
	else
		return math.ceil(SHOW_GRID_LIMIT / COL_NUM)
	end
end

function EngrysparWarehouseTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EngrysparWarehouseTableView:createCellAtIndex(cell, index)
	EngrysparWarehouseTableView.super.createCellAtIndex(self, cell, index)

	for numIndex = 1, COL_NUM do
		local posIndex = (index - 1) * COL_NUM + numIndex

		local normal = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
		local selected = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onComponentCallback))
		cell:addButton(btn, btn:getContentSize().width / 2 + 6 + (numIndex - 1) * (btn:getContentSize().width+15), self.m_cellSize.height / 2)

		local spar = self.m_energyspars[posIndex]
		if spar then
			btn.spar = spar
			local itemView = UiUtil.createItemView(ITEM_KIND_ENERGY_SPAR, spar.stoneId, {count=spar.count}):addTo(btn)
			itemView:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
		end
	end

	return cell
end

function EngrysparWarehouseTableView:onComponentCallback(tag, sender)
	local spar = sender.spar
	if spar then
		require("app.dialog.EnergySparDialog").new(spar.stoneId):push()
	end
end

return EngrysparWarehouseTableView
