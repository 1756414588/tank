--
-- Author: Xiaohang
-- Date: 2016-05-17 15:12:58
--
local ContentTableView = class("ContentTableView", TableView)
local rhand = rhand
function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 70)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local t = display.newSprite(IMAGE_COMMON .."login/btn_server_normal.png")
		:addTo(cell):align(display.LEFT_CENTER, 0, self.m_cellSize.height/2)
	local data = self.m_activityList[index]
	UiUtil.label(data[1].serverName):addTo(t):center()
	if data[2] then
		local t = display.newSprite(IMAGE_COMMON .."login/btn_server_normal.png")
			:addTo(cell):align(display.RIGHT_CENTER, self.m_cellSize.width, self.m_cellSize.height/2)
		UiUtil.label(data[2].serverName):addTo(t):center()
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
	local list = {}
	for k,v in ipairs(data) do
		local key = math.floor((k-1)/2)
		if not list[key+1] then list[key+1] = {} end
		table.insert(list[key+1], v)
	end
	self.m_activityList = list
	self:reloadData()
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
VIEW_FOR_TEAM_FIGHT = 1   --组队副本
VIEW_FOR_CROSS_SERVER_MINE = 2   --跨服军事矿区

local Dialog = require("app.dialog.Dialog")
local ServerList = class("ServerList", Dialog)

function ServerList:ctor(data,viewFor)
	ServerList.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(552, 734)})
	self:size(552,734)
	self.data = data or CrossBO.serverList_
	self.m_viewFor = viewFor
	if viewFor == VIEW_FOR_TEAM_FIGHT then
		self.data = HunterMO.teamFightCrossData_.serverData
	elseif viewFor == VIEW_FOR_CROSS_SERVER_MINE then
		self.data = StaffMO.ServerListData_
	end
end

function ServerList:onEnter()
	ServerList.super.onEnter(self)
	self:setTitle(CommonText[30000])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(522, 704))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = ContentTableView.new(cc.size(500, self:getBg():height()-102))
		:addTo(self:getBg()):pos(26,34)
	if self.m_viewFor == VIEW_FOR_TEAM_FIGHT then
		view:updateUI(self.data)
	elseif self.m_viewFor == VIEW_FOR_CROSS_SERVER_MINE then
		view:updateUI(self.data)
	else
		CrossBO.getServerList(function()
				view:updateUI(self.data)
			end)
	end
end

function ServerList:onExit()
	ServerList.super.onExit(self)
end

function ServerList:showUI()
	
end

return ServerList
