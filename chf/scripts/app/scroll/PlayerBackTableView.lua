--
-- Author: Your Name
-- Date: 2017-06-15 16:58:24
--
local PlayerBackTableView = class("PlayerBackTableView", TableView)

function PlayerBackTableView:ctor(size,type)
	PlayerBackTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

function PlayerBackTableView:onEnter()
	PlayerBackTableView.super.onEnter(self)

end

function PlayerBackTableView:numberOfCells()
	return 1
end

function PlayerBackTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PlayerBackTableView:createCellAtIndex(cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell,-1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png",70, 65):addTo(bg)
	local icon = display.newSprite("image/item/activity_playerback.jpg"):addTo(fame)
	icon:setScale(0.9)
	icon:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)

	local title = ui.newTTFLabel({text = CommonText[100009], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 114, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	title:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.openDetailhandler)):addTo(cell)
	detailBtn:setPosition(self.m_cellSize.width - 70, self.m_cellSize.height / 2 - 20)

	return cell
end

function PlayerBackTableView:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()
	self:openDetailhandler()
end

function PlayerBackTableView:openDetailhandler(tag, sender)
	if PlayerBackMO.isBack_ ==  false then
		Toast.show(CommonText[100021])
	return
	end
	require("app.view.ActivityPlayerReturnView").new():push()
end

function PlayerBackTableView:onExit()
	PlayerBackTableView.super.onExit(self)
end

return PlayerBackTableView

