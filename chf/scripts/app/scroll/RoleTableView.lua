

local RoleTableView = class("RoleTableView", TableView)

function RoleTableView:ctor(size)
	RoleTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(86, self:getViewSize().height)
end

function RoleTableView:numberOfCells()
	return 6
end

function RoleTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RoleTableView:createCellAtIndex(cell, index)
	return cell
end

return