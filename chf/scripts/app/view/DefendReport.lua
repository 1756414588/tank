--
-- Author: Xiaohang
-- Date: 2016-05-09 13:46:42
--
----------------军团战记录----------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 76)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	if index == #self.m_activityList + 1 then -- 最后一个按钮
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_normal.png")
		normal:setPreferredSize(cc.size(500, 76))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_selected.png")
		selected:setPreferredSize(cc.size(500, 76))
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onNextCallback))
		btn:setLabel(CommonText[577])
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		return cell
	end
	local data = self.m_activityList[index]
	local t = UiUtil.label(os.date("%H:%M", data.time),nil,cc.c3b(150,150,150)):addTo(cell):pos(36,self.m_cellSize.height/2)
	local n = UiUtil.label(data.name1,nil,COLOR[2]):addTo(cell):alignTo(t, 120)
	n:y(n:y()-20)
	n = UiUtil.label(data.partyName1):addTo(cell):alignTo(t, 120)
	n:y(n:y()+20)
	local vs = UiUtil.label("VS",32,COLOR[12]):addTo(cell):alignTo(t, 215)
	n = UiUtil.label(data.name2,nil,COLOR[2]):addTo(cell):alignTo(t, 310)
	n:y(n:y()-20)
	n = UiUtil.label(data.partyName2):addTo(cell):alignTo(t, 310)
	n:y(n:y()+20)
	local l,c = CommonText[20026][1],COLOR[12]
	if data.result == 0 then
		l,c = CommonText[20026][2],COLOR[6]
	end
	t = UiUtil.label(l,nil,c):addTo(cell):alignTo(t, 415)
	t = UiUtil.button("btn_replay_normal.png", "btn_replay_selected.png", nil, handler(self, self.onBack), nil, 1)
	cell:addButton(t,510,self.m_cellSize.height/2)
	t.key = data.reportKey
	return cell
end

function ContentTableView:numberOfCells()
	if #self.m_activityList < RANK_PAGE_NUM or #self.m_activityList >= 5000 then
		return #self.m_activityList
	else
		return #self.m_activityList + 1
	end
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:onBack(tag,sender)
	FortressBO.fightReport(sender.key)
end

function ContentTableView:onNextCallback(tag, sender)
	local function showData()
		Loading.getInstance():unshow()

		local oldHeight = self:getContainer():getContentSize().height

		self.m_activityList = FortressBO.recordList_[self.index]
		if not self.m_activityList then self.m_activityList = {} end
		self:reloadData()
		local delta = self:getContainer():getContentSize().height - oldHeight
		self:setContentOffset(cc.p(0, -delta))
	end

	local page = math.ceil(#self.m_activityList / RANK_PAGE_NUM)

	FortressBO.getBattleRecord(self.index,page + 1,showData)
end

function ContentTableView:updateUI(data,index)
	self.m_activityList = data or {}
	self.index = index
	self:reloadData()
end

-----------------------------------总览界面-----------
local DefendReport = class("DefendReport",UiNode)

--1全服 2个人 viewfor有值，强制请求
function DefendReport:ctor(viewFor)
	uiEnter = uiEnter or UI_ENTER_BOTTOM_TO_UP
	self.viewFor = viewFor
	DefendReport.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function DefendReport:onEnter()
	DefendReport.super.onEnter(self)
	self:setTitle(CommonText[20024])
	self.bgIcon = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, self:getBg():width()-40, display.height - 180)
	self.bgIcon:addTo(self:getBg(),3):pos(self:getBg():width()/2,self.bgIcon:height()/2+35)
	local t = UiUtil.label(CommonText[807][1],nil,cc.c3b(150,150,150)):addTo(self.bgIcon):pos(68,self.bgIcon:height()-24)
	t = UiUtil.label(CommonText[807][2],nil,cc.c3b(150,150,150)):addTo(self.bgIcon):alignTo(t, 120)
	t = UiUtil.label(CommonText[807][3],nil,cc.c3b(150,150,150)):addTo(self.bgIcon):alignTo(t, 190)
	t = UiUtil.label(CommonText[807][4],nil,cc.c3b(150,150,150)):addTo(self.bgIcon):alignTo(t, 140)

	local view = ContentTableView.new(cc.size(560, self.bgIcon:height()-55))
		:addTo(self.bgIcon):pos(30,10)
	local function createDelegate(container, index)
		container:removeAllChildren()
		index = index == 1 and 2 or 1
		if self.viewFor then
			FortressBO.recordList_ = {}
			FortressBO.getBattleRecord(index,1,function()
					view:updateUI(FortressBO.recordList_[index],index)
				end)
		else
			if not FortressBO.recordList_ or not FortressBO.recordList_[index] then
				FortressBO.getBattleRecord(index,1,function()
						view:updateUI(FortressBO.recordList_[index],index)
					end)
			else
				view:updateUI(FortressBO.recordList_[index],index)
			end
		end
	end
	local function clickDelegate(container, index)
	end
	local pages = CommonText[20025]
	local size = cc.size(display.width - 12, display.height - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = display.cx, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView
end

return DefendReport