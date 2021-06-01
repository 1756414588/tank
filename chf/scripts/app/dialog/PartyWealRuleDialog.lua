--
-- Author: gf
-- Date: 2015-10-13 11:36:31
-- 福利院活跃说明
local PartyWealRuleTableView = class("PartyWealRuleTableView", TableView)

function PartyWealRuleTableView:ctor(size)
	PartyWealRuleTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 1200)
end

function PartyWealRuleTableView:numberOfCells()
	return 1
end

function PartyWealRuleTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyWealRuleTableView:createCellAtIndex(cell, index)
	PartyWealRuleTableView.super.createCellAtIndex(self, cell, index)
	local title = ui.newTTFLabel({text = CommonText[700][1], font = G_FONT, size = FONT_SIZE_BIG, 
		x = self.m_cellSize.width / 2, y = self.m_cellSize.height - 20, color = COLOR[12], 
		align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- title:setAnchorPoint(cc.p(0, 0.5))

	local title1 = ui.newTTFLabel({text = CommonText[700][2], font = G_FONT, size = FONT_SIZE_BIG, 
		x = 40, y = title:getPositionY() - 50, color = COLOR[12], 
		align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	title1:setAnchorPoint(cc.p(0, 0.5))

	local labs = {}
	for index=3,11 do
		local lab = ui.newTTFLabel({text = CommonText[700][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			 color = COLOR[1], 
			 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
			 dimensions = cc.size(470, 60)
			 }):addTo(cell)
		lab:setAnchorPoint(cc.p(0, 0.5))
		if index == 3 then
			lab:setPosition(40, title1:getPositionY() - 60)
		else
			lab:setPosition(40, labs[index - 3]:getPositionY() - labs[index - 3]:getContentSize().height)
		end
		labs[#labs + 1] = lab
	end

	local title3 = ui.newTTFLabel({text = CommonText[700][12], font = G_FONT, size = FONT_SIZE_BIG, 
		x = 40, y = labs[#labs]:getPositionY() - 50, color = COLOR[12], 
		align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	title3:setAnchorPoint(cc.p(0, 0.5))

	local labs = {}
	for index=13,17 do
		local lab = ui.newTTFLabel({text = CommonText[700][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			 color = COLOR[1], 
			 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
			 dimensions = cc.size(470, 60)
			 }):addTo(cell)
		lab:setAnchorPoint(cc.p(0, 0.5))
		if index == 13 then
			lab:setPosition(40, title3:getPositionY() - 60)
		else
			lab:setPosition(40, labs[index - 13]:getPositionY() - labs[index - 13]:getContentSize().height)
		end
		labs[#labs + 1] = lab
	end

	
	return cell
end


function PartyWealRuleTableView:onExit()
	PartyWealRuleTableView.super.onExit(self)
end



local Dialog = require("app.dialog.Dialog")
local PartyWealRuleDialog = class("PartyWealRuleDialog", Dialog)

function PartyWealRuleDialog:ctor()
	PartyWealRuleDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE,{scale9Size = cc.size(550, 700)})
end

function PartyWealRuleDialog:onEnter()
	PartyWealRuleDialog.super.onEnter(self)

	self:setOutOfBgClose(true)

	local view = PartyWealRuleTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height - 50 - 4)):addTo(self:getBg())
	view:setPosition(0, 30)
	view:reloadData()	
end



function PartyWealRuleDialog:onExit()
	PartyWealRuleDialog.super.onExit(self)
end


return PartyWealRuleDialog