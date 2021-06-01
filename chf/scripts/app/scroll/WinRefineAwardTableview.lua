--
-- Author: Your Name
-- Date: 2017-05-26 22:09:44
--
local WinRefineAwardTableview = class("WinRefineAwardTableview", TableView)

function WinRefineAwardTableview:ctor(size)
	WinRefineAwardTableview.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 30)
	self:showSlider(true,nil,{bar = "image/common/scroll_head_5.png", bg = "image/common/scroll_bg_5.png",isShow = true})
	self.m_data = ActivityCenterMO.refineMasterChat_
end

function WinRefineAwardTableview:onEnter()
	WinRefineAwardTableview.super.onEnter(self)
	--注册一个监听，每次后端推送数据过来就做一次刷新
	self.m_refineHandler = Notify.register(LOCAL_REFINE_MASTER, handler(self, self.updateUI))
end

function WinRefineAwardTableview:numberOfCells()
	return #self.m_data
end

function WinRefineAwardTableview:cellSizeForIndex(index)
	return self.m_cellSize
end

function WinRefineAwardTableview:createCellAtIndex(cell, index)
	WinRefineAwardTableview.super.createCellAtIndex(self, cell, index)
	local resData = UserMO.getResourceData(tonumber(self.m_data[index].type), tonumber(self.m_data[index].id))
	local desc = UiUtil.label(CommonText[1030][1]):addTo(cell):align(display.CENTER,60,self.m_cellSize.height / 2)
	local nick = UiUtil.label(self.m_data[index].nick,nil,COLOR[5]):addTo(cell):rightTo(desc)
	local get = UiUtil.label(CommonText[1030][2]):addTo(cell):rightTo(nick)
	local propName = UiUtil.label(resData.name,nil,COLOR[resData.quality]):addTo(cell):rightTo(get)

	return cell
end

function WinRefineAwardTableview:updateUI()
	self.m_data = ActivityCenterMO.refineMasterChat_
	self:reloadData()
	self:onViewOffset()
end

function WinRefineAwardTableview:onExit()
	WinRefineAwardTableview.super.onExit(self)
	if self.m_refineHandler then
		Notify.unregister(self.m_refineHandler)
		self.m_refineHandler = nil
	end
end

function WinRefineAwardTableview:onViewOffset(tableView, offset)
	local maxOffset = self:maxContainerOffset()
	local minOffset = self:minContainerOffset()
	if minOffset.y > maxOffset.y or not offset then
	    local y = math.max(maxOffset.y, minOffset.y)
	    self:setContentOffset(cc.p(0, y))
    elseif offset then
	    self:setContentOffset(offset)
    end
end

return WinRefineAwardTableview