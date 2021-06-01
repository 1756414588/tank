--
-- Author: gf
-- Date: 2016-05-04 11:47:45
-- 节日欢庆 我的福卡

local PRAY_CARD_1 = 10
local PRAY_CARD_2 = 11
local PRAY_CARD_3 = 12
local PRAY_CARD_4 = 13
local ActivityPrayCardTableView = class("ActivityPrayCardTableView", TableView)

function ActivityPrayCardTableView:ctor(size,prayId)
	ActivityPrayCardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 175)
	self.list = {
		PRAY_CARD_1,
		PRAY_CARD_2,
		PRAY_CARD_3,
		PRAY_CARD_4
	}
	self.prayId = prayId
end

function ActivityPrayCardTableView:numberOfCells()
	return #self.list
end

function ActivityPrayCardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityPrayCardTableView:createCellAtIndex(cell, index)
	ActivityPrayCardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]

	-- local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	-- bg:setAnchorPoint(cc.p(0, 0.5))
	-- bg:setPosition(40, self.m_cellSize.height - 30)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(510, 170))
	bg:setCapInsets(cc.rect(80, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)


	-- gdump(dayWeal,"当前等级每日福利")
	local itemView = UiUtil.createItemView(ITEM_KIND_CHAR, data)
		itemView:setPosition(25 + itemView:getContentSize().width / 2,bg:getPositionY() - 15)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)

	local propDB = UserMO.getResourceData(ITEM_KIND_CHAR, data)
	local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 136, y = 143, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	name:setAnchorPoint(cc.p(0,0.5))

	local desc = propDB.desc or ""
	local desc = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 140, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(200, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	local count = ActivityCenterBO.prop_[data] and ActivityCenterBO.prop_[data].count or 0
	local countLab = ui.newTTFLabel({text = CommonText[914][2] .. count, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = self.m_cellSize.width - 80, y = self.m_cellSize.height / 2 + 10, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	countLab:setAnchorPoint(cc.p(0.5, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disable = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disable, handler(self, self.onPrayCallback))
	btn:setLabel(CommonText[914][1])
	btn.prayCardId = data
	btn:setEnabled(count > 0)
	cell:addButton(btn, self.m_cellSize.width - 80, self.m_cellSize.height / 2 - 35)

	return cell
end

function ActivityPrayCardTableView:onPrayCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	ActivityCenterBO.doActHilarityPrayAction(self.prayId,sender.prayCardId,function()
			Toast.show(CommonText[915])
			UiDirector.pop()
		end)
end

function ActivityPrayCardTableView:onExit()
	ActivityPrayCardTableView.super.onExit(self)
end



return ActivityPrayCardTableView