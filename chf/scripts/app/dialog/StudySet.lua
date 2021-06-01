--
-- Author: Xiaohang
-- Date: 2016-05-05 16:21:00
--
-- 科技列表

local ContentTableView = class("ContentTableView", TableView)
local rhand = rhand
function ContentTableView:ctor(size,tankId,data)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.tankId = tankId
	self.data = data
	self.m_cellSize = cc.size(size.width, 150)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	local img = OrdnanceMO.getImgById(data.militaryScienceId,self.tankId)
		:addTo(cell):pos(103, 73)
	local n = OrdnanceMO.getNameById(data.militaryScienceId)
	-- 名称
	local name = UiUtil.label(n .."Lv."..data.level):addTo(cell):align(display.LEFT_CENTER, 166, 120)
	local so = OrdnanceMO.queryScienceById(data.militaryScienceId,data.level == 0 and 1 or data.level)
	for k,v in ipairs(OrdnanceMO.getAttr(data.militaryScienceId,data.level)) do
		UiUtil.label(v,18):addTo(cell):align(display.LEFT_CENTER, 166, self.m_cellSize.height / 2 + 10 -(k-1)*20)
	end
	UiUtil.sprite9("info_bg_26.png", 220, 80, 1, 1, 500, 138)
		:addTo(cell, -1):pos(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	-- optional int32 level = 2;
 --    optional int32 fitTankId = 3;
 --    optional int32 fitPos = 4;
	if data.level == 0 then
		UiUtil.label(CommonText[20002],nil,COLOR[6]):addTo(cell):pos(self.m_cellSize.width - 92, self.m_cellSize.height / 2)
	elseif data.fitTankId == 0 then --未装配
		local accelBtn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.onSet), CommonText[175], 1)
		accelBtn.data = data
		cell:addButton(accelBtn, self.m_cellSize.width - 92, self.m_cellSize.height / 2)
	elseif data.militaryScienceId == self.data.id then
		UiUtil.label(CommonText[930],nil,COLOR[2]):addTo(cell):rightTo(name)
		local accelBtn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.onOff), CommonText[172], 1)
		accelBtn.data = data
		cell:addButton(accelBtn, self.m_cellSize.width - 92, self.m_cellSize.height / 2)
	elseif data.fitTankId ~= self.tankId then
		UiUtil.label(CommonText[930],nil,COLOR[6]):addTo(cell):pos(self.m_cellSize.width - 92, self.m_cellSize.height / 2)
	elseif self.has[so.attrId] then
		UiUtil.label(CommonText[931],nil,COLOR[6]):addTo(cell):pos(self.m_cellSize.width - 92, self.m_cellSize.height / 2)
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:onSet(tag,sender)
	local data = sender.data
	Loading.getInstance():show()
	OrdnanceBO.AdaptScience(function()
			Loading.getInstance():unshow()
			UserBO.triggerFightCheck()
			rhand = self.parent.rhand
			self.parent:pop()
			rhand()
			Notify.notify(LOCAL_MILITARY_OPEN,nil)
		end,data.militaryScienceId,self.tankId,self.data.pos)
end

function ContentTableView:onOff(tag,sender)
	local data = sender.data
	Loading.getInstance():show()
	OrdnanceBO.AdaptScience(function()
			Loading.getInstance():unshow()
			UserBO.triggerFightCheck()
			rhand = self.parent.rhand
			self.parent:pop()
			rhand()
			Notify.notify(LOCAL_MILITARY_OPEN,nil)
		end,data.militaryScienceId,0,0)
end

function ContentTableView:updateUI(data,parent)
	table.bubble(data, function(a,b)
		if self.data.id == a.militaryScienceId then
			return true
		elseif self.data.id == b.militaryScienceId then
			return false
		else
			local so1 = OrdnanceMO.queryScienceById(a.militaryScienceId)
			local so2 = OrdnanceMO.queryScienceById(b.militaryScienceId)
			if a.fitTankId == 0 then
				if b.fitTankId == 0 then
					return so1.attrId < so2.attrId
				else
					return true
				end
			elseif b.fitTankId == 0 then
				return false
			else
				return so1.attrId < so2.attrId
			end
		end
	end)
	self.m_activityList = data
	self.parent = parent
	local ids = OrdnanceBO.getScienceOnTank(self.tankId)
	self.has = {}
	for k,v in pairs(ids) do
		local to = OrdnanceMO.queryScienceById(v.militaryScienceId)
		self.has[to.attrId] = true
	end
	self:reloadData()
end

------------------------------------------------------------------------------
-- 坦克改装view
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local StudySet = class("StudySet", Dialog)

-- tankId: 需要改装的tank
function StudySet:ctor(tankId,data,rhand)
	StudySet.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self.tankId = tankId
	self.data = data
	self.rhand = rhand
	self:size(582,834)
end

function StudySet:onEnter()
	StudySet.super.onEnter(self)
	self:setTitle(CommonText[175])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = ContentTableView.new(cc.size(500, self:getBg():height()-102),self.tankId,self.data)
		:addTo(self:getBg()):pos(42,34)
	--找出所有符合条件的科技类型 
	view:updateUI(OrdnanceBO.getAdaptTypeScience(self.tankId),self)
end

function StudySet:onExit()
	StudySet.super.onExit(self)
end

function StudySet:showUI()
	
end

return StudySet
