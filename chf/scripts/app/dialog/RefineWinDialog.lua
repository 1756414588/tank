--
-- Author: Your Name
-- Date: 2017-05-26 21:26:28
--
local Dialog = require("app.dialog.Dialog")
local RefineWinDialog = class("RefineWinDialog", Dialog)

function RefineWinDialog:ctor(size,height)
	RefineWinDialog.super.ctor(self, nil, UI_ENTER_NONE, {scale9Size = cc.size(588, height)})
	self.height = height
	self.m_size = size

end

function RefineWinDialog:onEnter()
	RefineWinDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:setInOfBgClose(false)

	self.m_bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_90.png"):addTo(self:getBg())
	self.m_bg:setPreferredSize(cc.size(588, self.height))
	self.m_bg:setPosition(self:getBg():getContentSize().width / 2 + 26,self.m_size.height- 496 - self.m_bg:height() / 2)
	self.m_bg:setAnchorPoint(cc.p(0.5,0))

	local WinRefineAwardTableview = require("app.scroll.WinRefineAwardTableview")
	local view = WinRefineAwardTableview.new(cc.size(self:getBg():getContentSize().width - 50,380)):addTo(self.m_bg)
	view:setPosition(20,30)
	view:reloadData()
	self:onViewOffset(view)
	self.view = view
	self.view:setVisible(false)

	self._scheduler =  scheduler.scheduleGlobal(handler(self,self.update), 0.03)
end

function RefineWinDialog:update(dt)
	local height = self.height + 70
	self.m_bg:setPreferredSize(cc.size(588,height))
	self.height = height
	if self.height >= 400 then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
		self.view:setVisible(true)
		local up = display.newSprite(IMAGE_COMMON.."icon_arrow_3.png"):addTo(self.m_bg):pos(self.m_bg:width() - 40,self.m_bg:height() - 35)
		local down = display.newSprite(IMAGE_COMMON.."icon_arrow_3.png"):addTo(self.m_bg):pos(self.m_bg:width() - 40,40)
		down:setScaleY(-1)
	end
end

function RefineWinDialog:onViewOffset(tableView, offset)
	local maxOffset = tableView:maxContainerOffset()
	local minOffset = tableView:minContainerOffset()
	if minOffset.y > maxOffset.y or not offset then
	    local y = math.max(maxOffset.y, minOffset.y)
	    tableView:setContentOffset(cc.p(0, y))
    elseif offset then
	    tableView:setContentOffset(offset)
    end
end

function RefineWinDialog:onExit()
	RefineWinDialog.super.onExit(self)
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

return RefineWinDialog