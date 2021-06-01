--
-- Author: Gss
-- Date: 2018-10-24 16:20:53
--
-- 探险扫荡，ExploreWipeView

local ExploerWipeTableView = class("ExploerWipeTableView", TableView)

function ExploerWipeTableView:ctor(size)
	ExploerWipeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 300)
end

function ExploerWipeTableView:onEnter()
	ExploerWipeTableView.super.onEnter(self)
end

function ExploerWipeTableView:numberOfCells()
	-- return self.m_cellNum
	return 10
end

function ExploerWipeTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ExploerWipeTableView:createCellAtIndex(cell, index)
	ExploerWipeTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_82.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 20, 298))
	bg:setCapInsets(cc.rect(60,50,14,13))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(bg)
	line:setPreferredSize(cc.size(bg:width() - 40, line:getContentSize().height))
	line:setPosition(bg:width() / 2,bg:height() - 60)



	return cell
end

function ExploerWipeTableView:onUpdate(event)
	self:reloadData()
end

function ExploerWipeTableView:onExit()
	ExploerWipeTableView.super.onExit(self)
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

local ExploreWipeView = class("ExploreWipeView", UiNode)

function ExploreWipeView:ctor()
	ExploreWipeView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function ExploreWipeView:onEnter()
	ExploreWipeView.super.onEnter(self)
	self:setTitle("探险扫荡")
	self:hasCoinButton(true)
	self:showUI()
end

function ExploreWipeView:showUI()
	local size = cc.size(self:getBg():width(), self:getBg():height() - 250)
	local view = ExploerWipeTableView.new(size):addTo(self:getBg())
	view:setPosition(0, 150)
	view:reloadData()


	--探险扫荡
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local wipeBtn = MenuButton.new(normal, selected, nil, handler(self,self.onDoCallback)):addTo(self:getBg())
	wipeBtn:setPosition(self:getBg():width() / 2, wipeBtn:height() / 2 + 20)
	wipeBtn:setLabel("执行",{size = 28})
end

function ExploreWipeView:onDoCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
end

function ExploreWipeView:onExit()
	ExploreWipeView.super.onExit(self)
end


return ExploreWipeView