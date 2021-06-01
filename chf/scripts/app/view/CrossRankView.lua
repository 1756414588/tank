--
-- Author: xiaoxing
-- Date: 2016-11-16 11:13:48
--
local ContentTableView = class("ContentTableView",TableView)

function ContentTableView:ctor(size,kind,rhand)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.kind = kind
	self.rhand = rhand
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.list = CrossBO.backData_
end

function ContentTableView:onEnter()
	ContentTableView.super.onEnter(self)
end

function ContentTableView:numberOfCells()
	return #self.list
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local data = self.list[index]
	local title = ui.newTTFLabel({text = string.format(CommonText[30055],data.keyId)..CommonText[20148][self.kind], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 114, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	title:setAnchorPoint(cc.p(0, 0.5))

	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png",70, 65):addTo(bg)
	local icon = display.newSprite("image/item/kua_" .. self.kind .. ".jpg")
		:addTo(fame):center():scale(0.9)

	local bt = string.gsub(data.beginTime,"-","/")
	local et = string.gsub(data.endTime,"-","/")
	local desc = ui.newTTFLabel({text = bt .."-"..et, font = G_FONT, size = FONT_SIZE_SMALL, x = 155, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	desc:setAnchorPoint(cc.p(0, 0.5))
	return cell
end

function ContentTableView:cellTouched(cell, index)
	local data = self.list[index]
	self.rhand(data,index)
end

--------------------------------------------------------
local CrossRankView = class("CrossRankView", UiNode)
function CrossRankView:ctor(viewFor)
	viewFor = viewFor or 1
	self.m_viewFor = viewFor
	CrossRankView.super.ctor(self, "image/common/bg_ui.jpg")
end

function CrossRankView:onEnter()
	CrossRankView.super.onEnter(self)
	self:setTitle(CommonText[30051])
	local function createDelegate(container, index)
		container:removeAllChildren()
		self.view = nil
		self.index = index
		self.container = container
		CrossBO.GetCrossRank(function()
			self.tableView = ContentTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), index, handler(self, self.showDetail)):addTo(container)
			self.tableView:setPosition(0, 0)
			self.tableView:reloadData()
		end,index)
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate(index)
		return true
	end

	local pages = CommonText[30052]
	local size = cc.size(display.width - 12, display.height - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = display.cx, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function CrossRankView:showDetail(data,index)
	local page = require("app.view.CrossCelebrity")
	self.view = page.new(self.container:width(), self.container:height(),data,self.index):addTo(self.container)
	self.tableView:hide()
end

function CrossRankView:onReturnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.view then
		self.view:removeSelf()
		self.view = nil
		self.tableView:show()
	else
		self:pop()
	end
end

return CrossRankView