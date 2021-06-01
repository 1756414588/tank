--
-- Author: MYS
-- Date: 2017-05-24 
--
local ReportRewardTableView = class("ReportRewardTableView", TableView)

-- dataList : 数据
-- size 	: 尺寸
-- direction: 方向
-- isClipoing:是否关闭裁剪  默认开启
function ReportRewardTableView:ctor(size, dataList, isdataname, unClipoing)
	ReportRewardTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.size = size
	self.m_data = dataList
	self.m_cellSize = cc.size(120,self:getViewSize().height)
	self.isdataname = isdataname or false
	self.unClipoing = unClipoing or false
	if self.unClipoing then
		self:setClippingEnabled(false)
	end
	self.m_container:setTouchSwallowEnabled(true) -- 关闭穿透 
end

function ReportRewardTableView:onEnter()
	ReportRewardTableView.super.onEnter(self)
	self:reloadData()
end

function ReportRewardTableView:numberOfCells()
	return #self.m_data
end

function ReportRewardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ReportRewardTableView:createCellAtIndex(cell, index)
	ReportRewardTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_data[index]
	local type = 0
	local id = 0
	local count = 0
	if self.isdataname then
		type = data.type
		id = data.id
		count = data.count
	else
		type = data[1]
		id = data[2]
		count = data[3]
	end
	local item = UiUtil.createItemView(type, id, {count = count}):addTo(cell)
	item:setAnchorPoint(cc.p(0.5,0.5))
	item:setPosition(self.m_cellSize.width * 0.5 , self.m_cellSize.height * 0.5)
	if type == ITEM_KIND_HERO then item:setScale(0.5) end
	UiUtil.createItemDetailButton(item,cell,true)	

	return cell
end

return ReportRewardTableView