--
-- Author: gf
-- Date: 2016-04-22 15:05:41
--

local HeroImproveTableView = class("HeroImproveTableView", TableView)

function HeroImproveTableView:ctor(size, heros)
	HeroImproveTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.heros = heros
	
	local height = 470

	gdump(self.heros,"HeroImproveTableView:ctor")
	local ii = 0
	if math.ceil(#self.heros / 3) > 3 then
		ii = math.ceil(#self.heros / 3) - 3
	end
	height = height + ii * 170

	self.m_cellSize = cc.size(size.width, height)
end

function HeroImproveTableView:reloadData()
	HeroImproveTableView.super.reloadData(self)
end

function HeroImproveTableView:numberOfCells()
	return 1
end

function HeroImproveTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HeroImproveTableView:createCellAtIndex(cell, index)
	HeroImproveTableView.super.createCellAtIndex(self, cell, index)

	for index=1,#self.heros do
		local hero = self.heros[index]

		local heroData = HeroMO.queryHero(hero.heroId)
		local normal = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId)
		local selected = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId)
		local itemPic = CellTouchButton.new(normal, nil, nil, nil, handler(self, self.heroDetail))
		itemPic.heroData = heroData
		itemPic:setScale(0.7)

		local posX,posY
		if index < 4 then
			posX = 30 + itemPic:getContentSize().width * 0.7 / 2 + (index - 1) * 150
			posY = self.m_cellSize.height - 80
		else
			if index % 3 == 0 then
				posX = 30 + itemPic:getContentSize().width * 0.7 / 2 + 2 * 150
			else
				posX = 30 + itemPic:getContentSize().width * 0.7 / 2 + (index % 3 - 1) * 150
			end
			posY = self.m_cellSize.height - 80 - (math.ceil(index / 3) - 1) * 160
		end

		cell:addButton(itemPic,posX,posY)

	end
	
	return cell
end

function HeroImproveTableView:heroDetail(tag, sender)
	local heroData = sender.heroData
	require("app.dialog.HeroDetailDialog").new(heroData,2):push()
end

return HeroImproveTableView
