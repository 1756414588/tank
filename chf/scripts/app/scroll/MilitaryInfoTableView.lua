
local MilitaryInfoTableView = class("MilitaryInfoTableView", TableView)

function MilitaryInfoTableView:ctor(size, data, mine)
	MilitaryInfoTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.data = data
	self.mine = mine
end

function MilitaryInfoTableView:onEnter()
	MilitaryInfoTableView.super.onEnter(self)

	-- 达成要求 data
	local tgdata = {}
	-- 下一等级数据
	local nextdata = nil
		-- 下一等级
	local nextLv = ((self.mine + 1 > MilitaryRankMO.militaryMax) and 0) or self.mine + 1

	if nextLv > 0 then
		nextdata = MilitaryRankMO.queryById(nextLv)
	end
	
	if nextdata then
		local targetdata = json.decode(nextdata.upCost)
		table.insert(targetdata, 1, {ITEM_KIND_LEVEL, 0, nextdata.lordLv}) --强行加入等级
		for index=1 , #targetdata do
			local out = {}
			local data = targetdata[index]
			local kind , id , max =  data[1], data[2], data[3]
			out.kind = kind
			out.id = id
			out.name = UserMO.getResourceData(kind,id).name
			out.cur = UserMO.getResource(kind,id)
			out.max = max
			tgdata[#tgdata + 1] = out
		end
	end
	

	-- 附加属性
	local efdata = {}
	-- 当前等级属性
	if self.data then
		local effectdata = json.decode(self.data.attrs)
		for index=1 , #effectdata do
			local data = effectdata[index]
			local key , value =  data[1], data[2]
			local out = {}
			local attrsdt = AttributeBO.getAttributeData(key,value)
			out.attrName = attrsdt.attrName
			out.index = attrsdt.index
			out.name = attrsdt.name
			out.strValue = attrsdt.strValue
			efdata[key] = out
		end
	end
	-- 下一等级属性
	if nextdata then
		local attrdata = json.decode(nextdata.attrs)
		for index=1 , #attrdata do
			local data = attrdata[index]
			local key , value =  data[1], data[2]
			local attrsdt = AttributeBO.getAttributeData(key,value)
			if efdata[key] then
				efdata[key].nextstrValue = attrsdt.strValue
			else
				local out = {}
				out.attrName = attrsdt.attrName
				out.index = attrsdt.index
				out.name = attrsdt.name
				out.nextstrValue = attrsdt.strValue
				efdata[#efdata + 1] = out
			end
		end
	end

	-- 排序
	-- local function mysort(dataA, dataB)
	-- 	return dataA.index > dataB.index
	-- end
	-- if table.getn(efdata) > 1 then
	-- 	table.sort( efdata, mysort )
	-- end
	-- test
	-- for index = 1 , 3 do
	-- 	local data = effectdata[1]
	-- 	local key , value =  data[1], data[2]
	-- 	local out = AttributeBO.getAttributeData(key,value)
	-- 	efdata[#efdata + 1] = out
	-- end


	local nodeY = 0
	local thisY = 0
	self.node = display.newNode()


	-- 军衔等级 from
	local mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(self.node)
	thisY = nodeY - mrbg:getContentSize().height * 0.75
	nodeY = thisY
	mrbg:setPosition(20 + mrbg:getContentSize().width * 0.5, thisY)

	local mr = display.newSprite(IMAGE_COMMON .. "military/" .. self.mine .. ".png"):addTo(mrbg)
	mr:setPosition(mrbg:getContentSize().width * 0.5 , mrbg:getContentSize().height * 0.5)

	local name = self.data and self.data.name or CommonText[509]
	local lab = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = mrbg:getContentSize().width * 0.5, y =  -mrbg:getContentSize().height * 0.15 , align = ui.TEXT_ALIGN_CENTER}):addTo(mrbg)


	if nextLv > 0 then
		-- 军衔 >> 
		local sprite = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png"):addTo(self.node)
		sprite:setPosition(mrbg:getPositionX() + mrbg:getContentSize().width * 0.5 + sprite:getContentSize().width * 0.5,nodeY)

		-- 军衔等级 to
		mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(self.node)
		mrbg:setPosition(sprite:getPositionX() + sprite:getContentSize().width * 0.5 + mrbg:getContentSize().width * 0.5 , nodeY)

		mr = display.newSprite(IMAGE_COMMON .. "military/" .. nextLv .. ".png"):addTo(mrbg)
		mr:setPosition(mrbg:getContentSize().width * 0.5 , mrbg:getContentSize().height * 0.5)

		local nextname = nextdata and nextdata.name or CommonText[509]
		local lab = ui.newTTFLabel({text = nextname, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = mrbg:getContentSize().width * 0.5, y =  -mrbg:getContentSize().height * 0.15, align = ui.TEXT_ALIGN_CENTER}):addTo(mrbg)
	end

	nodeY = nodeY - mrbg:getContentSize().width * 0.5


	-- 达成要求
	local tipbg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self.node)
	tipbg:setAnchorPoint(cc.p(0, 0))
	thisY = nodeY - 20 - tipbg:getContentSize().height - 10
	nodeY = thisY
	tipbg:setPosition(20, thisY)

	local lab = ui.newTTFLabel({text = CommonText[1014][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = tipbg:getContentSize().width * 0.15, y = tipbg:getContentSize().height * 0.5, align = ui.TEXT_ALIGN_CENTER}):addTo(tipbg)
	lab:setAnchorPoint(cc.p(0,0.5))


	thisY = nodeY - 30
	nodeY = thisY

	for index = 1, #tgdata do
		local data = tgdata[index]

		local scale = 0.5

		local icon = UiUtil.createItemView(data.kind, data.id, {count = data.cur}):addTo(self.node)
		icon:setScale(scale)
		icon:setAnchorPoint(cc.p(0,0.5))
		icon:setPosition(30 , thisY)
		UiUtil.createItemDetailButton(icon)
		
		local namelab = ui.newTTFLabel({text = data.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = icon:getPositionX() + icon:getContentSize().width * scale + 10, y = thisY, align = ui.TEXT_ALIGN_CENTER}):addTo(self.node)
		namelab:setAnchorPoint(cc.p(0,0.5))

		local curcolor = data.cur < data.max and cc.c3b(255, 0, 0) or cc.c3b(18, 255, 3)
		local valuecur = ui.newTTFLabel({text = data.cur, font = G_FONT, color = curcolor, size = FONT_SIZE_SMALL,
			 x = namelab:getPositionX() + namelab:getContentSize().width + 10, y = thisY, align = ui.TEXT_ALIGN_CENTER}):addTo(self.node)
		valuecur:setAnchorPoint(cc.p(0,0.5))

		local vlauelab = ui.newTTFLabel({text = "/" .. data.max, font = G_FONT, color = cc.c3b(18, 255, 3), size = FONT_SIZE_SMALL,
			 x = valuecur:getPositionX() + valuecur:getContentSize().width, y = thisY, align = ui.TEXT_ALIGN_CENTER}):addTo(self.node)
		vlauelab:setAnchorPoint(cc.p(0,0.5))

		thisY = nodeY - 60
		nodeY = thisY
	end


	-- 附加属性
	tipbg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self.node)
	tipbg:setAnchorPoint(cc.p(0, 0))
	thisY = nodeY - tipbg:getContentSize().height 
	nodeY = thisY
	tipbg:setPosition(20, thisY)

	local lab = ui.newTTFLabel({text = CommonText[1014][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = tipbg:getContentSize().width * 0.15, y = tipbg:getContentSize().height * 0.5, align = ui.TEXT_ALIGN_CENTER}):addTo(tipbg)
	lab:setAnchorPoint(cc.p(0,0.5))
	
	thisY = nodeY - 40
	nodeY = thisY

	for k ,v in pairs(efdata) do
		local data = v 

		local scale = 0.5

		-- 属性ICON
		local icon = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE,nil,{name = data.attrName}):addTo(self.node)
		icon:setScale(scale)
		icon:setAnchorPoint(cc.p(0,0.5))
		icon:setPosition(30 , thisY)

		-- 属性名称
		local name = ui.newTTFLabel({text = data.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL,
			 x = icon:getPositionX() + icon:getContentSize().width * scale + 10, y = thisY, align = ui.TEXT_ALIGN_CENTER}):addTo(self.node)
		name:setAnchorPoint(cc.p(0,0.5))

		-- 当前等级属性
		local strvalue = table.isexist(data, "strValue") and data.strValue or "0%"
		local value = ui.newTTFLabel({text = strvalue, font = G_FONT,color = cc.c3b(18, 255, 3), size = FONT_SIZE_SMALL,
			 x = name:getPositionX() + name:getContentSize().width + 20, y = thisY, align = ui.TEXT_ALIGN_CENTER}):addTo(self.node)
		value:setAnchorPoint(cc.p(0,0.5))


		-- 下一等级属性
		if table.isexist(data, "nextstrValue") then

			-- >> 
			local sprite = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png"):addTo(self.node)
			sprite:setAnchorPoint(cc.p(0,0.5))
			sprite:setPosition(name:getPositionX() + name:getContentSize().width + 20 + 100,thisY)

			-- 等级属性
			local value = ui.newTTFLabel({text = data.nextstrValue, font = G_FONT,color = cc.c3b(18, 255, 3), size = FONT_SIZE_SMALL,
				 x = sprite:getPositionX() + sprite:getContentSize().width + 60, y = thisY, align = ui.TEXT_ALIGN_CENTER}):addTo(self.node)
			value:setAnchorPoint(cc.p(0,0.5))
		end

		thisY = nodeY - 60
		nodeY = thisY
	end


	self.m_cellSize = cc.size(self.m_viewSize.width, -nodeY)
	self:reloadData()
end


function MilitaryInfoTableView:onExit()
	MilitaryInfoTableView.super.onExit(self)
end

function MilitaryInfoTableView:numberOfCells()
	return 1
end

function MilitaryInfoTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MilitaryInfoTableView:createCellAtIndex(cell, index)
	MilitaryInfoTableView.super.createCellAtIndex(self, cell, index)
	self.node:addTo(cell)
	self.node:setPosition(0,self.m_cellSize.height)
	return cell
end

return MilitaryInfoTableView