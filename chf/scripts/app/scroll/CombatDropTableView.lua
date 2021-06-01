
-- 关卡掉落TableView

local CombatDropTableView = class("CombatDropTableView", TableView)

function CombatDropTableView:ctor(size, awards)
	CombatDropTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)

	self.m_cellSize = cc.size(80, size.height)
	self.m_awards = awards
	gdump(self.m_awards, "CombatDropTableView")
end

function CombatDropTableView:numberOfCells()
	return #self.m_awards
end

function CombatDropTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function CombatDropTableView:createCellAtIndex(cell, index)
	CombatDropTableView.super.createCellAtIndex(self, cell, index)
	local award = self.m_awards[index]
	local itemView = UiUtil.createItemView(award.kind, award.id):addTo(cell)
	itemView:setScale(0.55)
	itemView:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(itemView, cell, true)

	return cell
end

return CombatDropTableView
