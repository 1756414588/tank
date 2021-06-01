--
-- Author: Xiaohang
-- Date: 2016-09-18 10:28:30
--
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.size_w = size.width
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local size = self:cellSizeForIndex(index)
	local data = self.m_list[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(size.width - 40, size.height - 10))
	bg:setCapInsets(cc.rect(130, 40, 1, 1))
	bg:setPosition(size.width / 2, size.height / 2 - 20)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(cell)
	titBg:setPosition(size.width / 2,size.height - 30)

	local titLab = ui.newTTFLabel({text = CommonText[789][index], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width/2, y = titBg:getContentSize().height/2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	for i=1,#data do
		local list = data[i]
		local itemView = UiUtil.createItemView(list[1], list[2], {count = list[3]})
		itemView:setScale(0.8)
		itemView:setPosition(bg:getContentSize().width - 40, bg:getContentSize().height - 90 / 2 - 40 - (i - 1) * (90))
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView,cell,true)
		for j=1,4-index do
			local lab = ui.newTTFLabel({text = "=", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = itemView:getPositionX() - 70 - (j - 1) * 125, y = itemView:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			lab:setAnchorPoint(cc.p(0.5, 0.5))
			if j == 1 then
				lab:setString("=")
			else
				lab:setString("+")
			end
			local item = json.decode(ActivityCenterMO.getEquateById(list[4]).showList)
			-- local pic = display.newSprite(IMAGE_COMMON .. "raffle_" .. i .. ".png", 
			-- 	lab:getPositionX() - 60, lab:getPositionY()):addTo(cell)
			local itemView = UiUtil.createItemView(item[1], item[2])
			itemView:setScale(0.8)
			itemView:setPosition(lab:getPositionX() - 60, lab:getPositionY())
			if itemView.bg_ then itemView.bg_:hide() end
			if itemView.armature_ then itemView.armature_:hide() end
			cell:addChild(itemView)
		end
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_list
end

function ContentTableView:cellSizeForIndex(index)
	local h = 80
	local data = self.m_list[index]
	h = h + (#data - 1)*100
	self.cell_h[index] = h
	return cc.size(self.size_w,h)
end

function ContentTableView:updateUI(data)
	self.m_list = data
	self.cell_h = {}
	self:reloadData()
end

------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local TankCarnivalReward = class("TankCarnivalReward", Dialog)

function TankCarnivalReward:ctor()
	TankCarnivalReward.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function TankCarnivalReward:onEnter()
	TankCarnivalReward.super.onEnter(self)
	
	self:setTitle(CommonText[771])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local view = ContentTableView.new(cc.size(btm:getContentSize().width, btm:getContentSize().height - 20)):addTo(btm)
	view:setPosition(0, 10)
	
	local list = ActivityCenterMO.getAllEqudate()
	local has = {}
	local data = {}
	for k,v in ipairs(list) do
		if not has[v.kind] then
			has[v.kind] = true
			local temp = json.decode(v.awardLis)
			for m,n in ipairs(temp) do
				if not data[4 - n[1]] then
					data[4 - n[1]] = {}
				end
				table.insert(data[4 - n[1]],{n[2],n[3],n[4],v.equateId})
			end
		end
	end
	for k,v in ipairs(data) do
		table.sort(v,function(a,b)
				local da = ActivityCenterMO.getEquateById(a[4])
				local db = ActivityCenterMO.getEquateById(b[4])
				return da.kind < db.kind
			end)
	end
	view:updateUI(data)
end

return TankCarnivalReward