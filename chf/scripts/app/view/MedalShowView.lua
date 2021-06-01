--
-- Author: xiaoxing
-- Date: 2017-01-04 14:52:52
--
local quality = {
	[1] = {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0},
	[2] = {[5]=0},
	[3] = {[3]=0,[4]=0},
	[4] = {[1]=0,[2]=0},
}
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 170)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	display.newSprite(IMAGE_COMMON.."medal_panel.png")
		:addTo(cell):align(display.CENTER_BOTTOM, self.m_cellSize.width/2, 5)
	local data = self.medals[index]
	local x,y,ex = 120,102,192
	for k,v in ipairs(data) do
		local node = display.newNode():addTo(cell):align(display.CENTER, x + (k-1)*ex, y)
		node:setCascadeOpacityEnabled(true)
		if not MedalBO.shows[v.medalId] then
			display.newSprite("image/item/m_lock.png"):addTo(node)
			display.newGraySprite(IMAGE_COMMON.."medal_bottom.png"):addTo(node):pos(0,-65)
			UiUtil.label(CommonText[929], nil, COLOR[11]):addTo(node):pos(0,-65)
			node:setOpacity(100)
		else
			local item = display.newSprite("image/item/m_"..v.medalId..".png"):addTo(node)
			display.newSprite(IMAGE_COMMON.."medal_bottom.png"):addTo(node):pos(0,-65)
			UiUtil.label(v.medalName, nil, COLOR[12]):addTo(node):pos(0,-65)
			local medals = nil
			if MedalBO.shows[v.medalId] == 0 then
				node:setOpacity(100)
				medals = {}
				for m,n in pairs(MedalBO.medals) do
					if n.pos == 0 and n.medalId == v.medalId and n.locked == false then
						table.insert(medals,n)
					end
				end
				if #medals > 0 then
					local t = display.newSprite(IMAGE_COMMON.."icon_red_point.png")
						:addTo(cell):pos(node:x()+62,node:y()-50)
					UiUtil.label(#medals,18):addTo(t):center()
				end
			end
			local touch = display.newNode():size(item:width(),item:height())
				:addTo(cell):align(display.CENTER, node:x(), node:y())
			UiUtil.createItemDetailButton(touch,cell,true,function()
					require("app.dialog.MedalShowDialog").new(v.medalId,medals):push()
				end)
		end
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.medals
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(index)
	local list = MedalMO.getShowMedal(quality[index])
	self.medals = {}
	for k,v in ipairs(list) do
		local key = math.floor((k-1)/3)
		if not self.medals[key+1] then self.medals[key+1] = {} end
		table.insert(self.medals[key+1], v)
	end
	self:reloadData()
end

--------------------------------------------------------------
local MedalShowView = class("MedalShowView", UiNode)

function MedalShowView:ctor(viewFor)
	viewFor = viewFor or 1
	self.m_viewFor = viewFor
	MedalShowView.super.ctor(self, "image/common/bg_ui.jpg")
end

function MedalShowView:onEnter()
	MedalShowView.super.onEnter(self)
	self.m_partHandler = Notify.register(LOCLA_MEDAL_EVENT, handler(self, self.onMedalUpdate))
	self:setTitle(CommonText[20179][1])
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg(),2)
	bg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 20, GAME_SIZE_HEIGHT - 150 - 300))
	bg:setPosition(self:getBg():width() / 2, 300 + bg:getContentSize().height / 2 )
	self.view = ContentTableView.new(cc.size(bg:width(),bg:height())):addTo(bg)
	self.infoBg = display.newNode():size(self:getBg():width(),300):addTo(self:getBg())
	local function createDelegate(container, index)
		self.view:updateUI(index)
		if self.ey then
			self.view:setContentOffset(cc.p(0, self.ey))
			self.ey = nil
		end
		self:showAttr()
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[504],CommonText.color[5][2],CommonText[20180][1],CommonText[20180][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView
	pageView:setPageIndex(self.m_viewFor)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function MedalShowView:onMedalUpdate()
	self.ey = self.view:getContentOffset().y
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

function MedalShowView:showAttr()
	self.infoBg:removeAllChildren()
	local bg = self.infoBg
	--属性
	local titleBg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(bg)
		:align(display.LEFT_CENTER, 15, 270)
	-- 增加属性
	local title = ui.newTTFLabel({text = CommonText[20179][2], font = G_FONT, size = FONT_SIZE_TINY, x = 80, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)
	local has = 0
	for k,v in pairs(MedalBO.shows) do
		if v == 1 then
			has = has + 1
		end
	end
	--收集
	local t = UiUtil.label("("..CommonText[20181][1]):alignTo(titleBg, 230)
	t = UiUtil.label(MedalMO.getShowMedal(),nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[20181][2]):rightTo(t)
	t = UiUtil.label(","..CommonText[20181][4]):rightTo(t)
	t = UiUtil.label(has,nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[20181][2] ..")"):rightTo(t)

	local attrList = {ATTRIBUTE_INDEX_ATTACK+1,ATTRIBUTE_INDEX_HP+1,ATTRIBUTE_INDEX_FRIGHTEN,ATTRIBUTE_INDEX_FORTITUDE,ATTRIBUTE_INDEX_BURST+1,ATTRIBUTE_INDEX_TENACITY+1}
	-- 配件的各个属性值
	local attrs = MedalBO.getShowAttr(1)
	local x,y,ex,ey = 60,220,190,45
	for k,v in ipairs(attrList) do
		local attr = attrs[v] or AttributeBO.getAttributeData(v, 0)
		local tx, ty = x + math.floor((k-1)/2)*ex,y - (k-1)%2*ey
		local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = attr.attrName}):addTo(bg):pos(tx,ty)
		local name = ui.newTTFLabel({text = attr.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		name:setAnchorPoint(cc.p(0, 0.5))
		name:setColor(COLOR[11])
		name:setPosition(itemView:getPositionX() + 30, itemView:getPositionY())
		local value = ui.newTTFLabel({text = "+" .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	--属性
	titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(bg)
		:align(display.LEFT_CENTER, 15, 120)
	-- 增加属性
	title = ui.newTTFLabel({text = CommonText[20179][3], font = G_FONT, size = FONT_SIZE_TINY, x = 80, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)
	x,y,ey = 70,88,22
	local list = MedalMO.queryBouns()
	for k,v in ipairs(list) do
		local items = json.decode(v.bonus)
		local attr = AttributeBO.getAttributeData(items[1][1], items[1][2])
		local c = has >= v.number and COLOR[2] or cc.c3b(115,115,115)
		display.newSprite("image/common/"..(has >= v.number and "scroll_head_3" or "scroll_bg_2")..".png"):addTo(bg):align(display.LEFT_CENTER, 40, y-(k-1)*ey)
		local t = UiUtil.label(attr.name,nil,c):addTo(bg)
			:align(display.LEFT_CENTER, x, y-(k-1)*ey)
		t = UiUtil.label("+" .. attr.strValue.." ",nil,c):rightTo(t)
		attr = AttributeBO.getAttributeData(items[2][1], items[2][2])
		t = UiUtil.label(attr.name,nil,c):rightTo(t)
		t = UiUtil.label("+" .. attr.strValue,nil,c):rightTo(t)
		UiUtil.label(string.format(CommonText[20183], v.number),nil,c):addTo(bg):align(display.LEFT_CENTER, 360, t:y())
	end
end

function MedalShowView:onExit()
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end
end

return MedalShowView