--
-- Author: Xiaohang
-- Date: 2016-05-05 10:08:50
--
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.size_w = size.width
	self.m_activityList = {1,2,3,4,5,6}
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local h = self.cell_h[index]
	local data = self.m_activityList[index]
	local t = display.newSprite(IMAGE_COMMON .."info_bg_12.png"):addTo(cell):align(display.LEFT_TOP, 20, h-2)
	UiUtil.label(CommonText[927][index]):addTo(t):align(display.LEFT_CENTER, 55, t:height()/2)	

	if index == 1 then
		for k,v in ipairs(data.name) do
			local c = COLOR[2]
			if v.unOpen then c = COLOR[6] end
			UiUtil.label(v.name, nil, c):addTo(cell):align(display.LEFT_CENTER, 40, t:y()-t:height()-18-(k-1)*36)
		end
	elseif index == 2 then
		for k,v in ipairs(data.name1) do
			local n = UiUtil.label(v):addTo(cell):align(display.LEFT_CENTER, 40, t:y()-t:height()-18-(k-1)*36)
			if data.name2 then
				n = display.newSprite(IMAGE_COMMON .."icon_arrow_right.png"):addTo(cell):rightTo(n, 18)
				UiUtil.label(data.name2[k]):addTo(cell):rightTo(n, 18)
			end
		end
	elseif index == 3 then
		for k,v in ipairs(data) do
			local x,ex = 86,105
			local t = UiUtil.createItemView(ITEM_KIND_TANK, v[1]):addTo(cell):pos(x+(k-1)*ex, h-100):scale(0.9)
			UiUtil.createItemDetailButton(t, cell, true)
			local propDB = UserMO.getResourceData(ITEM_KIND_TANK, v[1])
			UiUtil.label(propDB.name, nil,COLOR[1]):addTo(cell):pos(t:x(),t:y()-60)
		end
	elseif index == 4 then
		for k,v in ipairs(data) do
			local x,ex = 86,105
			local t = UiUtil.createItemView(v[1], v[2], {count = v[3],own = UserMO.getResource(v[1],v[2])}):addTo(cell):pos(x+(k-1)*ex, h-100):scale(0.9)
			if t.enough == false then
				self.enough = false
			end
			UiUtil.createItemDetailButton(t, cell, true)
			local propDB = UserMO.getResourceData(v[1], v[2])
			UiUtil.label(propDB.name, nil, COLOR[propDB.quality or 1]):addTo(cell):pos(t:x(),t:y()-60)
		end
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	local h = 50
	local data = self.m_activityList[index]
	if index == 1 then
		h = h + #data.name*36
	elseif index == 2 then
		h = h + #data.name1*36
	else
		h = h + 125
	end
	self.cell_h[index] = h
	return cc.size(self.size_w,h)
end

function ContentTableView:updateUI(data)
	self.m_activityList = data
	self.cell_h = {}
	self.enough = true
	self:reloadData()
end

----------------------------------------------------------------------

-- 军工科技研究框
local Dialog = require("app.dialog.Dialog")
local StudyDialog = class("StudyDialog", Dialog)

local id,tankId = 0,0
local rhand = nil
function StudyDialog:ctor(id, tankId,rhand)
	StudyDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.id = id
	self.tankId = tankId
	self.rhand = rhand
end

function StudyDialog:onEnter()
	StudyDialog.super.onEnter(self)
	self:setTitle(CommonText[148])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	self:showUI()
end

function StudyDialog:showUI()
	if self.container_ then
		self.container_:removeSelf()
		self.container_ = nil
	end

	self.container_ = display.newNode():addTo(self:getBg())
	self.container_:setContentSize(self:getBg():getContentSize())
	local container = self.container_

	local tankDB = TankMO.queryTankById(self.tankId)
	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	attrBg:setPreferredSize(cc.size(container:width() - 80, 132))
	attrBg:setPosition(container:width() / 2, 695)
	local item = OrdnanceMO.getImgById(self.id,self.tankId)
		:addTo(attrBg):pos(75,attrBg:height()/2)
	--名字
	UiUtil.label(OrdnanceMO.getNameById(self.id),nil,COLOR[tankDB.grade])
		:addTo(attrBg):align(display.LEFT_CENTER, 134, 92)
	local data = OrdnanceBO.queryScienceById(self.id)
	local t = UiUtil.label("Lv."..data.level)
		:addTo(attrBg):align(display.LEFT_CENTER, 134, 42)
	local lvLabel = t
	t = display.newSprite(IMAGE_COMMON .."icon_arrow_right.png"):addTo(attrBg):rightTo(t, 18)
	local arrow = t
	local lvNext = UiUtil.label("Lv."..(data.level+1)):addTo(attrBg):rightTo(t, 18)
	--属性信息
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:width() - 80, 545))
	bg:setPosition(container:width() / 2, 350)

	self.content = ContentTableView.new(cc.size(bg:width(), bg:height()-5)):addTo(bg):pos(0,3)
	local list = {}
	local b,n,max = OrdnanceMO.checkUnOpen(self.id)
	list[1] = {unOpen = b , name = n}
	list[2] = {name1 = OrdnanceMO.getAttr(self.id,data.level),name2 = OrdnanceMO.getAttr(self.id,data.level+1)}
	local lv = data.level
	data = OrdnanceMO.queryScienceById(self.id,lv + 1)
	if not data then
		data = OrdnanceMO.queryScienceById(self.id,lv)
		lvLabel:setString("MAX")
		lvLabel:setColor(COLOR[12])
		arrow:removeSelf()
		lvNext:setString("")
		list[2].name2 = nil
	end
	list[3] = json.decode(data.scope)
	if not max then
		list[4] = json.decode(data.materials)
	end
	self.content:updateUI(list)
	-- 确定
	t = UiUtil.button("btn_1_normal.png", "btn_1_selected.png", "btn_9_disabled.png", handler(self,self.up), max and CommonText[1] or CommonText[79])
		:addTo(self:getBg()):pos(self:getBg():width()/2, 25)
	t.max = max
	t:setEnabled(not b)
end

function StudyDialog:onExit()
	StudyDialog.super.onExit(self)
end

function StudyDialog:up(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.max then
		self:pop()
		return
	end
	if self.content.enough == false then
		Toast.show(ErrorText.text677)
		return
	end

	local id = self.id
	local rhand = self.rhand
	
	Loading.getInstance():show()
	OrdnanceBO.UpMilitaryScience(handler(self,function()
		Loading.getInstance():unshow()

		if not tolua.isnull(self) then
			self:showUI()

		end

		if rhand then
			rhand()
		end

		Notify.notify(LOCAL_MILITARY_OPEN,nil)
		Toast.show(CommonText[20004])
		UserBO.triggerFightCheck()

	end), id)
end

return StudyDialog
