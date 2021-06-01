--
-- Author: gf
-- Date: 2015-09-01 16:32:14
--

local COL_NUM = 3

local HeroPicTableView = class("HeroPicTableView", TableView)

function HeroPicTableView:ctor(size,star)
	HeroPicTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 195)

	local list = nil
	if star == 1 then
		list = HeroMO.heros_pic_
	else
		list = HeroMO.queryHeroPicByStar(star - 1)
	end
	self.heros = {}
	local has = {}
	for k,v in ipairs(list) do
		if not has[v.show] then
			has[v.show] = {}
			table.insert(self.heros,v)
		end
		table.insert(has[v.show], v)
	end
	self.has = has
	-- gdump(self.heros,"HeroPicTableView:ctor..self.heros")
	-- -- gprint(#self.heros,"HeroPicTableView:ctor..")
end

function HeroPicTableView:numberOfCells()

	return math.ceil(#self.heros / COL_NUM)
end

function HeroPicTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HeroPicTableView:createCellAtIndex(cell, index)
	HeroPicTableView.super.createCellAtIndex(self, cell, index)

	local buttons = {}
	cell.buttons = buttons
	for numIndex = 1, COL_NUM do
		local posIndex = (index - 1) * COL_NUM + numIndex
		if posIndex <= #self.heros then
			local hero = self.heros[posIndex]
			local itemView = UiUtil.createItemView(ITEM_KIND_HERO,hero.heroId)
			itemView:setScale(0.8)
			-- if HeroBO.hasHeroInSchool(hero.heroId) then
			-- 	itemView:setOpacity(255)
			-- else
			-- 	itemView:setOpacity(50)
			-- end
			
			local btn = CellTouchButton.new(itemView, nil, nil, nil, handler(self, self.onChosenCallback))
			btn.hero = hero
			buttons[numIndex] = btn
			cell:addButton(btn, 30 + (numIndex - 0.5) * 192, self.m_cellSize.height / 2 - 10)

		end
	end

	return cell
end

function HeroPicTableView:onChosenCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	gdump(sender.hero,"[HeroPicTableView]..onChosenCallback")
	require("app.dialog.HeroListDialog").new(self.has[sender.hero.show]):push()
end

function HeroPicTableView:onExit()
	HeroPicTableView.super.onExit(self)
	
end

return HeroPicTableView