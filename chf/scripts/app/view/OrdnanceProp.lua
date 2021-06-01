--
-- Author: Xiaohang
-- Date: 2016-05-03 15:02:59
--
--
-----------------------------------内容条界面---------
local OrdancePropTableView = class("OrdancePropTableView", TableView)

function OrdancePropTableView:ctor(size)
	OrdancePropTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 145)
	self.m_props = OrdnanceBO.getProp()
end

function OrdancePropTableView:createCellAtIndex(cell, index)
	OrdancePropTableView.super.createCellAtIndex(self, cell, index)

	local prop = self.m_props[index]
	local propDB = OrdnanceMO.queryMaterialById(prop.id)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	local bagView = UiUtil.createItemView(ITEM_KIND_MILITARY, prop.id, {count = prop.count}):addTo(cell)
	bagView:setPosition(100, self.m_cellSize.height / 2)
	-- 名称
	local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[propDB.color]}):addTo(cell)
	local desc = propDB.desc or "暂无描述"
	local desc = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(400, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 25, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	-- 
	local count = ui.newTTFLabel({text = prop.count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))
	return cell
end

function OrdancePropTableView:numberOfCells()
	return #self.m_props
end

function OrdancePropTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

-----------------------------------总览界面-----------
local OrdnanceProp = class("OrdnanceProp",function ()
	return display.newNode()
end)

function OrdnanceProp:ctor(width,height)
	self:size(width,height)
	--内容
	local view = OrdancePropTableView.new(cc.size(width, height-120))
		:addTo(self):pos(0,120)
	self.view = view
	view:reloadData()

	UiUtil.button("btn_1_normal.png","btn_1_selected.png",nil,handler(self,self.friend),CommonText[537][2])
		:addTo(self):pos(214,50)
	UiUtil.button("btn_1_normal.png","btn_1_selected.png",nil,handler(self,self.pass),CommonText[924])
		:addTo(self):pos(506,50)
	UiUtil.button("btn_detail_normal.png","btn_detail_selected.png",nil,handler(self,self.detail))
		:addTo(self):pos(65,50)
end

function OrdnanceProp:friend()
	require("app.view.SocialityView").new(2):push()
end

function OrdnanceProp:pass()
	local CombatLevelView = require("app.view.CombatLevelView")
	CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_WAR)):push()
end

function OrdnanceProp:detail()
	require("app.dialog.DetailTextDialog").new(DetailText.ordnanceProp):push()
end

function OrdnanceProp:refreshUI()
	self.view:reloadData()
end

return OrdnanceProp