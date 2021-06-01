--
-- Author: Xiaohang
-- Date: 2016-05-03 15:59:40
--
local OrdnanceAdapt = class("OrdnanceAdapt", TableView)

function OrdnanceAdapt:ctor(size)
	OrdnanceAdapt.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 145)
	self:updateUI()
end

function OrdnanceAdapt:createCellAtIndex(cell, index)
	OrdnanceAdapt.super.createCellAtIndex(self, cell, index)
	local data = self.m_tanks[index]
	local refitTankDB = TankMO.queryTankById(data.tankId)  -- 改装到的坦克

	-- 被改装后名称
	local name = ui.newTTFLabel({text = refitTankDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[refitTankDB.grade]}):addTo(cell)

	-- 被改装后样式
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, refitTankDB.tankId):addTo(cell)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	sprite:setPosition(93, 30)

	-- 可改装数量
	local label = ui.newTTFLabel({text = CommonText[207] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 77, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = data.count, font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 80, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	-- 生产按钮
	local accelBtn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self, self.adapt), CommonText[206], 1)
	accelBtn.data = data
	cell:addButton(accelBtn, self.m_cellSize.width - 104, self.m_cellSize.height - 90)
	
	local mo = OrdnanceMO.queryTankById(data.tankId)
	local condition = OrdnanceBO.queryScienceById(mo.pukCondition)
	if not condition then
		accelBtn:setEnabled(false)
	elseif condition.level == 0 then
		UiUtil.label(CommonText[923] ..OrdnanceMO.getNameById(mo.pukCondition),nil,COLOR[6],cc.size(160,0),ui.TEXT_ALIGN_LEFT):addTo(cell):align(display.LEFT_TOP, 170, self.m_cellSize.height - 90)
		accelBtn:setEnabled(false)
	end
	return cell
end

function OrdnanceAdapt:numberOfCells()
	return #self.m_tanks
end

function OrdnanceAdapt:cellSizeForIndex(index)
	return self.m_cellSize
end

function OrdnanceAdapt:updateUI()
	local offset = self:getContentOffset()
	local ids = OrdnanceMO.getProduceList()
	local list = table.values(TankMO.tanks_)
	table.sort(list,function(a,b)
		return a.tankId < b.tankId
	end )
	self.m_tanks = {}
	for k,v in ipairs(list) do
		if ids[v.tankId] and v.count > 0 then
			table.insert(self.m_tanks,{tankId = ids[v.tankId],count = v.count})
		end
	end
	self:reloadData()
	self:setContentOffset(offset)
end

function OrdnanceAdapt:adapt(tag,sender)
	require("app.dialog.AdaptProduct").new(sender.data,handler(self, self.updateUI)):push()
end

return OrdnanceAdapt