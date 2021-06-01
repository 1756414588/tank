
require("app.text.DetailText")

local ScrollText = class("ScrollText", TableView)

function ScrollText:ctor(size, contont)
	ScrollText.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_contont = contont

	self.m_cellSize = cc.size(size.width-10, size.height)

	local height = 0
	for i = 1, #self.m_contont do
		local d = self.m_contont[i]
		local label = RichLabel.new(d, cc.size(self.m_cellSize.width, 0))
		height = height + label:getHeight()
	end

	height = height + 10

	self.m_cellSize.height = math.max(size.height, height)
end

-- 获得view中总共有多少个cell
function ScrollText:numberOfCells()
	return 1
end

-- 索引为index的cell的大小，index从1开启
function ScrollText:cellSizeForIndex(index)
	return self.m_cellSize
end

-- cell:默认会创建一个空的node，node包含有_CELL_INDEX_的值。方法的返回的cellNode才是最终的cell
function ScrollText:createCellAtIndex(cell, index)
	local posY = self.m_cellSize.height
	for i = 1, #self.m_contont do
		local d = self.m_contont[i]
		local label = RichLabel.new(d, cc.size(self.m_cellSize.width, 0)):addTo(cell)
		label:setTouchEnabled(false)
		label:setPosition(5, posY)
		posY = posY - label:getHeight()
	end

	return cell
end


----------------设置为可滑动--------------------------------------------
------------------------------------------------------------------------


local Dialog = require("app.dialog.Dialog")
local DetailTextDialog = class("DetailTextDialog", Dialog)

-- text 用于显示文字列表(例 text = "我是%d一个%d例子")
-- change 用于替换的列表(例 change = {1,2})
function DetailTextDialog:ctor(text,change)
	if change then
		local index = 0
		self.m_text , index = self:replace(text,change,index)
	else
		self.m_text = text
	end

	local height = 70
	for index = 1, #self.m_text do
		local label = RichLabel.new(self.m_text[index], cc.size(480, 0), {lineHeight = 28, paddingHeight = 0})
		height = height + label:getHeight()
	end

	if height >= 850 then
		height = 850
	end
	self.m_height = height

	DetailTextDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, height)})
end

function DetailTextDialog:onEnter()
	DetailTextDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function DetailTextDialog:showUI()
	if self.m_height >= 850 then
		local label = ScrollText.new(cc.size(520, self.m_height - 60), self.m_text):addTo(self:getBg())
		label:setPosition(20, 30)
		label:reloadData()
		self:setInOfBgClose(false)
	else
		local posY = self:getBg():getContentSize().height - 35
		local text = self.m_text
		for index = 1, #text do
			local label = RichLabel.new(text[index], cc.size(480, 0), {lineHeight = 28, paddingHeight = 0}):addTo(self:getBg())
			label:setPosition(24, posY)
			posY = posY - label:getHeight()
		end
	end
end

function DetailTextDialog:replace(rep,change,index)
	local out = {}
	local _index = index or 0 
	for k,v in pairs(rep) do
		if type(v) == 'table' then
			local to = {}
			to , _index = self:replace(v,change,_index)
			out[#out + 1] = to
		elseif type(v) == 'string' then
			_index = _index+1
			local content = string.format(v,change[_index])
			out.content = content
		else
			out.k = v
		end
	end
	return out , _index
end

return DetailTextDialog
