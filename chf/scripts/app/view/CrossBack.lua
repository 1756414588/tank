--
-- Author: xiaoxing
-- Date: 2016-11-18 10:23:37
--
-- 战局回顾
-----------------赛事信息tableView--------------------
local ContentTableView = class("ContentTableView", TableView)
local LINE_W = 180
function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_cellSize = cc.size(1100, size.height)
	self.m_activityList = {1}
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	--生成赛事信息
	local size = self.m_cellSize
	local node = self:itemNode(size)
	node:addTo(cell):align(display.LEFT_TOP, 0, size.height - 50)
	node = self:itemNode(self.m_cellSize,1)
	node:addTo(cell):align(display.LEFT_TOP, size.width, size.height - 50)
	node:scaleX(-1)
	for k,v in ipairs(node.names) do
		v:scaleX(-1)
	end
	local ty = size.height - 50 - (node:height()-node.cy)
	--冠军
	local l = display.newSprite(IMAGE_COMMON.."line.jpg")
		:addTo(cell):align(display.CENTER_BOTTOM, size.width/2,ty):scaleTY(LINE_W)
	if not self.data[15] then
		l:setOpacity(30)
	end
	local t = self:createHead(self.data[15],node):addTo(cell):align(display.CENTER_BOTTOM, size.width/2, l:y()+l:height()*l:getScaleY())
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:itemNode(size,isRight)
	local node = display.newNode():size(size.width/2,750)
	node.names = {}
	local x,y,ey = 98,node:height()-28,180
	local pos1 = {}
	--8个玩家信息
	for i=0,3 do
		local index = i + 1
		local pindex = math.floor(i/2) + 9
		if isRight then 
			index = index + 4
			pindex = pindex + 2
		end
		local ty = y - i*ey
		local data = self.data[index]
		local t = self:createHead(data,node):addTo(node,1):pos(x,ty)
		local l = display.newSprite(IMAGE_COMMON.."line.jpg")
			:addTo(node):align(display.CENTER_BOTTOM,x,t:y())
		l:rotation(90)
		l:scaleTY(LINE_W)
		self:checkFalse(index,pindex,l)

		l = display.newSprite(IMAGE_COMMON.."line.jpg"):scaleTY(ey/2)
			:addTo(node):align(display.RIGHT_BOTTOM, x+LINE_W, t:y())
		if i%2 == 0 then
			l:scaleY(-1*l:getScaleY())
			table.insert(pos1,cc.p(l:x(),l:y()-ey/2))
		end
		self:checkFalse(index,pindex,l)
	end
	local pos2 = {}
	ey = 2*ey
	node.cy = pos1[2].y + ey/2
	--8进4
	for k,v in ipairs(pos1) do
		local index = k + 8
		local pindex = 13
		if isRight then
			index = index + 2
			pindex = 14
		end
		local l = display.newSprite(IMAGE_COMMON.."line.jpg")
			:addTo(node):align(display.CENTER_BOTTOM,v.x,v.y):scaleTY(LINE_W)
		l:rotation(90)
		self:checkFalse(index,pindex,l)
		l = display.newSprite(IMAGE_COMMON.."line.jpg"):scaleTY(ey/2)
			:addTo(node):align(display.RIGHT_BOTTOM, v.x+LINE_W,v.y)
		self:checkFalse(index,pindex,l)
		if k%2 == 1 then
			l:scaleY(-1*l:getScaleY())
			l = display.newSprite(IMAGE_COMMON.."line.jpg")
					:addTo(node):align(display.CENTER_BOTTOM,l:x(),l:y()-ey/2)
					:scaleTY(node:width() - l:x())
			l:rotation(90)
			self:checkFalse(pindex,15,l)
			self:createHead(self.data[pindex],node):addTo(node,2):pos(l:x(),l:y())
		end
		self:createHead(self.data[index],node):addTo(node,2):pos(v.x,v.y)
	end
	return node
end

function ContentTableView:createHead(data,node,isRight)
	if not data then return UiUtil.createItemView(ITEM_KIND_PORTRAIT, 0):scale(0.6) end
	local head = UiUtil.createItemView(ITEM_KIND_PORTRAIT, data.portrait)
	local t = display.newSprite(IMAGE_COMMON.."info_bg_23.png"):addTo(head):pos(head:width()/2,-45)
	table.insert(node.names, t)
	UiUtil.label("Lv."..data.level .." "..data.name,26,COLOR[6]):addTo(t):pos(t:width()/2,t:height()/2+15)
	UiUtil.label(data.serverName,26,COLOR[3]):addTo(t):pos(t:width()/2,t:height()/2+42)
	head:scale(0.6)
	return head
end

--检查失败线条
function ContentTableView:checkFalse(index,pindex,l)
	if not self.data[index] or not self.data[pindex] then l:setOpacity(30) return end
	if self.data[index].name ~= self.data[pindex].name then
		l:setOpacity(30)
	end
end

--检查数据
function ContentTableView:checkData(group)
	if self.data[group] then
		if table.isexist(self.data[group],"c1") or table.isexist(self.data[group],"c2") then 
			if self.data[group].win == -1 then --未战斗
				return 1
			end 
			return 2
		end
	end
end

function ContentTableView:updateUI(data)
	self.data = data
	table.sort(self.data,function(a,b)
		return a.pos < b.pos
	end)
	self:reloadData()
end

-------------------------------------------------------
local CrossBack = class("CrossBack", UiNode)

function CrossBack:ctor(data,viewFor)
	viewFor = viewFor or 1
	self.data = data
	self.m_viewFor = viewFor
	CrossBack.super.ctor(self, "image/common/bg_ui.jpg")
end

function CrossBack:onEnter()
	CrossBack.super.onEnter(self)
	self:setTitle(CommonText[30053])
	local function createDelegate(container, index)
		self.index = index
		local data = self.data.crossFame[index]
		local temp = {}
		if data.fameBattleReview then
			temp = PbProtocol.decodeArray(data.fameBattleReview)
		end
		self:showInfo(container,temp)
	end

	local function clickDelegate(container, index)
	end
	local pages = CommonText[30012]
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	pageView:setPageIndex(self.m_viewFor)
end

function CrossBack:showInfo(container,data)
	container:removeAllChildren()
	local t = display.newSprite(IMAGE_COMMON.."top_"..self.index ..".png")
		:addTo(container):pos(container:width()/2,container:height()-40)
	UiUtil.label(string.format(CommonText[30055],self.data.keyId) .. CommonText[20148][1],28,cc.c3b(199,199,199))
		:addTo(t):center()
	self.content = ContentTableView.new(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
		:addTo(container):pos(5,-60)
	self.content:updateUI(data)
	self.content:setContentOffset(cc.p(-230,0))
end

return CrossBack