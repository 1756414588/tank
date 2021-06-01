--
-- Author: Gss
-- Date: 2018-04-10 10:25:41
--

local RedPlanAwardTableView = class("RedPlanAwardTableView", TableView)


function RedPlanAwardTableView:ctor(size)
	RedPlanAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 200)
	
	self.m_list = ActivityCenterMO.getRedPlanArea()
end

function RedPlanAwardTableView:numberOfCells()
	return #self.m_list
end

function RedPlanAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RedPlanAwardTableView:createCellAtIndex(cell, index)
	RedPlanAwardTableView.super.createCellAtIndex(self, cell, index)

	local live = self.m_list[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(507, 195))
	bg:setCapInsets(cc.rect(80, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = string.format(CommonText[5037], live.name), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 140, y = 170, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local liveAwards = json.decode(live.areaAward)

	for index=1,#liveAwards do
		local itemView = UiUtil.createItemView(liveAwards[index][1], liveAwards[index][2], {count = liveAwards[index][3]})
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 100,bg:getContentSize().height - 100)
		cell:addChild(itemView)
		itemView:setScale(0.8)
		UiUtil.createItemDetailButton(itemView,cell,true)
		local propDB = UserMO.getResourceData(liveAwards[index][1], liveAwards[index][2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_TINY - 2, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end

	return cell
end

function RedPlanAwardTableView:onExit()
	RedPlanAwardTableView.super.onExit(self)
end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--奖励预览dialog

local Dialog = require("app.dialog.Dialog")
local RedPlanAwardDialog = class("RedPlanAwardDialog", Dialog)

function RedPlanAwardDialog:ctor()
	RedPlanAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function RedPlanAwardDialog:onEnter()
	RedPlanAwardDialog.super.onEnter(self)

	self:setTitle(CommonText[269])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 810))

	-- local RedPlanAwardTableView = require("app.scroll.RedPlanAwardTableView")
	local view = RedPlanAwardTableView.new(cc.size(btm:getContentSize().width, btm:getContentSize().height - 60)):addTo(btm)
	view:setPosition(0, 20)
	view:reloadData()
end

return RedPlanAwardDialog