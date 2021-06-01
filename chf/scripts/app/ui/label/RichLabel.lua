
local LABEL_DEBUG = false

local FONT_MAX_WIDTH = 20  -- 一个字，不管是什么字，他的最大的宽度
local EXPRESS_WIDTH = 34 -- 表情的宽度

local RichLabel = class("RichLabel", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

-- RichLabel的内容的原点坐标在左上角
-- dimensions:目前只考虑width，当宽到达设定的位置后，会自动换行
function RichLabel:ctor(stringData, dimensions, param)
	-- param = param or {}

	-- param.lineHeight = param.lineHeight or 30  -- 字体的高度
	-- param.paddingHeight = param.paddingHeight or 4    -- label的上下的空白间隔
	-- self.m_lineHeight = param.lineHeight
	-- self.m_paddingHeight = param.paddingHeight
	self.m_dimensions = dimensions or cc.size(0, 0)

	self.m_contentSize = cc.size(self.m_dimensions.width, self.m_dimensions.height)

	self.m_touchEnabled = true

	self:setStringData(stringData)
end

-- function string.truncateUTF8String(s, n)
-- 	local dropping = string.byte(s, n + 1)
-- 	if not dropping then return s end
-- 	if dropping >= 128 and dropping < 192 then
-- 		return string.truncateUTF8String(s, n - 1)
-- 	else
-- 		return string.sub(s, 1, n), string.sub(s, n + 1, string.len(s))
-- 	end
-- end

-- str以#打头，内容中有且只能有一个#
local function hasExpress(str)
	for index = 1, #UserMO.express do
		local s, e = string.find(str, UserMO.express[index].desc)
		if s then -- 找到了
			return true, index, e
		end
	end
	return false
end

local function LangThai(string, start)
	-- print("start:", start, "len:", string.len(string))
	
	local first = string.byte(string, start)
	if first ~= 224 then return 1 end
	
	return string.len(string) - start + 1
	
	-- if start + 2 > string.len(string) then return 1 end

	-- local sf = 0
	-- while (start + 2) <= string.len(string) do
	-- 	local ch = string.byte(string, start)
	-- 	if not ch or ch ~= 224 then return sf end
		
	-- 	start = start + 3
	-- 	sf = sf + 3

	-- 	-- ch1 = string.byte(string, start + 1)
	-- 	-- ch2 = string.byte(string, start + 2)

	-- 	-- if ((ch1 == 184 and (ch2 == 177 or (ch2 >= 179 and ch2 <= 186)))
	-- 	-- 	or (ch1 == 185 and (ch2 >= 135 and ch2 <= 142))) then
	-- 	-- 	sf = sf + 3
	-- 	-- 	start = start + 3
	-- 	-- else
	-- 	-- 	return sf
	-- 	-- end
	-- end
	-- return sf
end

-- 阿拉伯语
local function LangAr(string, start)
	local first = string.byte(string, start)
	if first ~= 217 then return 2 end

	return string.len(string) - start + 1
end

-- 将字符串转换为一个一个的char
function stringToChar_(string)
	local list = {}
	local index = 1
	local len = string.len(string)
	-- for i = 1, len do
	-- 	print("value:", string.byte(string, i))
	-- end
	while index <= len do
		local shift = 1
		local ch = string.byte(string, index)

		if ch < 0 then ch = ch + 256 end

		if ch > 0 and ch <= 127 then shift = 1
		elseif ch >= 198 and ch <= 216 then shift = 2
		elseif ch == 217 then
			shift = LangAr(string, index)
		elseif ch > 217 and ch <= 223 then shift = 2
		elseif ch == 224 then -- 泰文
			shift = LangThai(string, index)
		elseif ch > 224 and ch <= 239 then shift = 3
		elseif ch >= 240 and ch <= 247 then shift = 4
		end
		local char = string.sub(string, index, index + shift - 1)
		if LABEL_DEBUG then
			gprint("charrrr:", char)
		end
		index = index + shift
		table.insert(list, char)
	end
	return list, len
end

local function charToString_(chars)
	local string = ""
	for index = 1, #chars do
		string = string .. chars[index]
	end
	return string
end

-- 将内容分为可以显示的多段有效的数据
function partition_(s)
	-- if true then return {{str = s}} end
	local pos = {}

	local i = 0
	while true do  -- 记录所有表情的位置
		i, j = string.find(s, "#", i + 1)
		if i == nil then break end
		pos[#pos + 1] = i
	end

	if #pos > 0 then  -- 有要判断是否是表情的
		local ret = {}
		local tmp = string.sub(s, 1, pos[1] - 1)
		if tmp ~= "" then ret[#ret + 1] = {str = stringToChar_(tmp)} end

		for index = 1, #pos do
			local endTagPos = 0
			if index == #pos then endTagPos = string.len(s)
			else endTagPos = pos[index + 1] - 1 end

			local tmp = string.sub(s, pos[index], endTagPos)
			local has, expressIndex, endPos = hasExpress(tmp)
			if has then -- 有表情
				ret[#ret + 1] = {exp = expressIndex}

				if endPos < (endTagPos - pos[index]) then
					ret[#ret + 1] = {str = stringToChar_(string.sub(tmp, endPos + 1, string.len(tmp)))}
				end
			else
				ret[#ret + 1] = {str = stringToChar_(tmp)}
			end
		end
		return ret
	else
		return {{str = stringToChar_(s)}}  -- 无表情
	end
end

local function replace(str)
	local len = string.len(str)
	if len == 1 then
		local ch1 = string.byte(str, 1)
		if ch1 >= 128 and ch1 <= 197 then

			if LABEL_DEBUG then
				for index = 1, len do
					local ch = string.byte(str, index)
					gprint("replace ch:...", ch)
				end
			end
			return "*"
		end
	elseif len == 2 then
		local ch1 = string.byte(str, 1)
		local ch2 = string.byte(str, 2)
		if (ch1 == 204 and ch2 == 128) or (ch1 == 204 and ch2 == 129)
			or (ch1 == 204 and ch2 == 132) or (ch1 == 204 and ch2 == 133) or (ch1 == 204 and ch2 == 134) or (ch1 == 204 and ch2 == 135)
			or (ch1 == 204 and ch2 == 145) or (ch1 == 204 and ch2 == 154)
			or (ch1 == 204 and ch2 == 161) or (ch1 == 204 and ch2 == 162) or (ch1 == 204 and ch2 == 163) or (ch1 == 204 and ch2 == 164) or (ch1 == 204 and ch2 == 165) or (ch1 == 204 and ch2 == 166) or (ch1 == 204 and ch2 == 167) or (ch1 == 204 and ch2 == 168)
			or (ch1 == 204 and ch2 == 171) or (ch1 == 204 and ch2 == 173) or (ch1 == 204 and ch2 == 174) or (ch1 == 204 and ch2 == 175) or (ch1 == 204 and ch2 == 178)
			or (ch1 == 204 and ch2 == 180) or (ch1 == 204 and ch2 == 181) or (ch1 == 204 and ch2 == 182) or (ch1 == 204 and ch2 == 187) or (ch1 == 204 and ch2 == 191)
			or (ch1 == 205 and ch2 == 136) or (ch1 == 205 and ch2 == 140) or (ch1 == 205 and ch2 == 146) or (ch1 == 205 and ch2 == 147) or (ch1 == 205 and ch2 == 156) or (ch1 == 205 and ch2 == 158) or (ch1 == 205 and ch2 == 159) or (ch1 == 205 and ch2 == 161) or (ch1 == 205 and ch2 == 166)
			or (ch1 == 210 and ch2 == 136) or (ch1 == 210 and ch2 == 137)
			or (ch1 == 219 and ch2 == 150) then

			if LABEL_DEBUG then
				for index = 1, len do
					local ch = string.byte(str, index)
					gprint("replace ch:...", ch)
				end
			end
			return "**"
		end
	elseif len == 3 then
		local ch1 = string.byte(str, 1)
		local ch2 = string.byte(str, 2)
		local ch3 = string.byte(str, 3)
		if (ch1 == 225 and ch2 == 183 and ch3 == 132) or (ch1 == 225 and ch2 == 183 and ch3 == 133)
			or (ch1 == 226 and ch2 == 128 and ch3 == 139) or (ch1 == 226 and ch2 == 128 and ch3 == 142) or (ch1 == 226 and ch2 == 131 and 144)
			or (ch1 == 239 and ch2 == 184 and ch3 == 142) or (ch1 == 239 and ch2 == 184 and ch3 == 143) then

			if LABEL_DEBUG then
				for index = 1, len do
					local ch = string.byte(str, index)
					gprint("replace ch:...", ch)
				end
			end
			return "***"
		end
	end
	
	return str
	
	-- local back = ""
	-- for index = 1, len do
		-- local ch = string.byte(str, index)
		-- print("ch:...", ch)
		-- back = back .. string.sub(str, index, index)
	-- end
	-- return back
end

function RichLabel:setStringData(stringData)
	self:removeAllChildren()

	local showContents = {}

	for index = 1, #stringData do

		local strData = stringData[index]

		local data = partition_(strData.content)

		for ic = 1, #data do
			local showContent = {}

			if data[ic].str then -- 是字符串
				-- 是可以点击，有下划线的, 作为一个整体，不拆分
				if strData.click then showContent.str = {charToString_(data[ic].str)}
				else showContent.str = data[ic].str end
				-- showContent.str = {data[ic].str}

				showContent.click = strData.click  -- 不为空，则表示可以点击，有下划线，点击后的回调。(可以点击的内容，不会被换行)
				showContent.color = strData.color or COLOR[1]  -- 内容的字体颜色
				showContent.underline = strData.underline  -- 下划线
				showContent.size = strData.size or FONT_SIZE_SMALL
				showContent.font = strData.font or G_FONT
			elseif data[ic].exp then -- 是表情
				showContent.exp = data[ic].exp
				showContent.scale = 0.55
			end
			showContents[#showContents + 1] = showContent
		end
	end

	self.m_spriteArray = self:createSprite_(showContents)

	self:adjustPosition_()
end

function RichLabel:setDimensions( dimensions )
	self.m_dimensions = dimensions
	self:adjustPosition_()
end

function RichLabel:createSprite_(contentArray)
	local spriteArray = {}

	for index = 1, #contentArray do
		local content = contentArray[index]
		-- gdump(content, "createSprite_")
		if content.str then -- 是字符串
			for idxS = 1, #content.str do
				local str = content.str[idxS]
				-- gprint("str111:", str)
				local showStr = replace(str)
				if LABEL_DEBUG then
					gprint("str AAAA show", showStr)

					local len = string.len(showStr)
					for index = 1, len do
						local ch = string.byte(showStr, index)
						gprint("str AAAA show " .. index .. ":...", ch)
					end
				end

				local label = ui.newTTFLabel({text = showStr, font = content.font, size = content.size, color = content.color, align = ui.TEXT_ALIGN_CENTER}):addTo(self)
				if LABEL_DEBUG then
					gprint("str BBB:", str)
				end
				spriteArray[#spriteArray + 1] = {view = label, click = content.click}

				if content.click then
					label.click = content.click
					color = content.color or cc.c3b(120, 201, 22)
					local line = display.newRect(cc.rect(label:getContentSize().width / 2, 0, label:getContentSize().width, 2))
					line:setLineColor(cc.c4f(color.r/255, color.g/255, color.b/255, 1))
					line:setFill(true)
					label:addChild(line)

					nodeTouchEventProtocol(label, function(event)  -- 添加点击事件
						-- gprint("name:", event.name)
						if not self.m_touchEnabled then return false end

						if event.name == "ended" then
							local point = label:getParent():convertToNodeSpace(cc.p(event.x, event.y))
							local rect = label:getBoundingBox()
							if cc.rectContainsPoint(rect, point) then
								if label.click then label.click() end -- 回调调用
							end
						end
						return true
					end, nil, true, true)
				elseif content.underline then
					color = content.color or cc.c3b(120, 201, 22)
					local line = display.newRect(cc.rect(label:getContentSize().width / 2, 0, label:getContentSize().width, 2))
					line:setLineColor(cc.c4f(color.r/255, color.g/255, color.b/255, 1))
					line:setFill(true)
					label:addChild(line)
				end
			end
		elseif content.exp then -- 是表情
			local express = UserMO.express[content.exp]
			local view = display.newSprite("image/express/" .. express.icon .. ".png"):addTo(self)
			view:setScale(0.55)
			spriteArray[#spriteArray + 1] = {view = view}
		end
	end
	return spriteArray
end

-- 调整位置（设置文字和尺寸都会触发此方法）
function RichLabel:adjustPosition_()
	local spriteArray = self.m_spriteArray

	if not spriteArray then return end
	
	local widthArr, heightArr = self:getSizeOfSprites_(spriteArray)

	--获得每个精灵的坐标
	local pointArrX, pointArrY, hidLineArrY = self:getPointOfSprite_(widthArr, heightArr, self.m_dimensions)

	for i, data in ipairs(spriteArray) do
		data.view:setPosition(pointArrX[i], pointArrY[i])
		if not hidLineArrY[i] then
			data.view:setVisible(false)
		end
	end
end

-- 获得每个精灵的宽度和高度
function RichLabel:getSizeOfSprites_(spriteArray)
	local widthArr = {} -- 宽度数组
	local heightArr = {} -- 高度数组
	
	for i, data in ipairs(spriteArray) do  -- 精灵的尺寸
		local rect = data.view:getBoundingBox()
		widthArr[i] = rect.size.width
		heightArr[i] = rect.size.height
	end
	return widthArr, heightArr
end

--获得每个精灵的位置
function RichLabel:getPointOfSprite_(widthArr, heightArr, dimensions)
	local totalWidth = dimensions.width
	local totalHight = dimensions.height

	local maxWidth = 0
	local maxHeight = 0

	local spriteNum = #widthArr

	--从左往右，从上往下拓展
	local curX = 0 --当前x坐标偏移
	
	local curIndexX = 1 --当前横轴index
	local curIndexY = 1 --当前纵轴index
	
	local pointArrX = {} --每个精灵的x坐标

	local rowIndexArr = {} --行数组，以行为index储存精灵组
	local indexArrY = {} --每个精灵的行index

	-- 将所有的sprite按照宽度计算位置，并自动换行
	for i, spriteWidth in ipairs(widthArr) do
		local nexX = curX + spriteWidth
		local pointX = 0
		local rowIndex = curIndexY

		local halfWidth = spriteWidth * 0.5
		if nexX > totalWidth and totalWidth ~= 0 then --超出界限了
			pointX = halfWidth
			if curIndexX == 1 then --当前是第一个，
				curX = 0-- 重置x
			else --不是第一个，当前行已经不足容纳
				rowIndex = curIndexY + 1 --换行
				curX = spriteWidth
			end
			curIndexX = 1 --x坐标重置
			curIndexY = curIndexY + 1 --y坐标自增
		else
			pointX = curX + halfWidth --精灵坐标x
			curX = pointX + halfWidth --精灵最右侧坐标
			curIndexX = curIndexX + 1
		end

		pointArrX[i] = pointX --保存每个精灵的x坐标
		indexArrY[i] = rowIndex --保存每个精灵的行

		local tmpIndexArr = rowIndexArr[rowIndex]

		if not tmpIndexArr then --没有就创建
			tmpIndexArr = {}
			rowIndexArr[rowIndex] = tmpIndexArr
		end
		tmpIndexArr[#tmpIndexArr + 1] = i --保存相同行对应的精灵

		if curX > maxWidth then
			maxWidth = curX
		end
	end

	local curY = 0
	local rowHeightArr = {} --每一行的y坐标
	local lastPointY = 0 --记录上一个精灵的y坐标

	local hideArr = {} -- 超框行 索引列表

	-- 计算每一行的高度
	for i, rowInfo in ipairs(rowIndexArr) do
		local rowHeight = 0
		for j, index in ipairs(rowInfo) do --计算最高的精灵
			local height = heightArr[index]
			if height > rowHeight then
				rowHeight = height
			end
		end
		if totalHight ~= 0 and (curY + rowHeight) > totalHight then --限制高度
			rowHeightArr[#rowHeightArr + 1] = - lastPointY
			hideArr[#hideArr + 1] = false
		else
			lastPointY = curY + rowHeight * 0.5 --当前行所有精灵的y坐标（正数，未取反）
			rowHeightArr[#rowHeightArr + 1] = - lastPointY --从左往右，从上到下扩展，所以是负数
			curY = curY + rowHeight --当前行的边缘坐标（正数）
			hideArr[#hideArr + 1] = true
		end
		
		if curY > maxHeight then
			maxHeight = curY
		end
	end

	self.m_maxWidth = maxWidth
	self.m_maxHeight = maxHeight

	self.m_contentSize.width = maxWidth
	self.m_contentSize.height = maxHeight

	local pointArrY = {}
	local outHidLineArrY = {}

	for i = 1, spriteNum do
		local indexY = indexArrY[i] --y坐标是先读取精灵的行，然后再找出该行对应的坐标
		local pointY = rowHeightArr[indexY]
		outHidLineArrY[i] = hideArr[indexY]
		pointArrY[i] = pointY
	end

	return pointArrX, pointArrY, outHidLineArrY
end

function RichLabel:getHeight()
	-- return self.m_maxHeight + self.m_paddingHeight * 2
	return self.m_maxHeight
end

function RichLabel:getWidth()
	return self.m_maxWidth
end

function RichLabel:setTouchEnabled(enabled)
	self.m_touchEnabled = enabled
end

function RichLabel:getContentSize()
	return self.m_contentSize
end

return RichLabel
