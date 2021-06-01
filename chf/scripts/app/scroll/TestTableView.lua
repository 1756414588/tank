
local TestTableView = class("TestTableView", TableView)

local COL_NUM = 2 -- 每行显示两个

-- choseNotifyName:选中某个员工后，通知的名称
function TestTableView:ctor(size)
	TestTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 100)

	-- self.m_bounceable = false

	self.m_curChosenIndex = 1
end

function TestTableView:numberOfCells()
	return 50
end

function TestTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function TestTableView:createCellAtIndex(cell, index)
	TestTableView.super.createCellAtIndex(self, cell, index)

	local firstIndex = (index - 1) * COL_NUM + 1

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenEmployee))
	btn.employeeIndex = firstIndex
	cell:addButton(btn, 92, self.m_cellSize.height / 2)
	cell.firstBtn = btn

	if firstIndex == self.m_curChosenIndex then
		btn:setScale(0.85)
	end

	local secondIndex = (index - 1) * COL_NUM + 2

	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenEmployee))
	btn.employeeIndex = secondIndex
	cell:addButton(btn, self.m_cellSize.width - 92, self.m_cellSize.height / 2)
	cell.secondBtn = btn

	return cell
end

function TestTableView:cellWillRecycle(cell, index)
	-- print("删除cell:", index)
end

-- 选中了某个雇员
function TestTableView:onChosenEmployee(tag, sender)
	gprint("index:", sender.employeeIndex)
end

return TestTableView
