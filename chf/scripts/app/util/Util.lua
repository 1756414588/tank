
-- Util = {}

MovementEventType =
{
	START = 0,
	COMPLETE = 1,
	LOOP_COMPLETE = 2,
}

function gprint_lua_table(lua_table, indent)
	if GAME_PRINT_ENABLE then
		indent = indent or 0
		for k, v in pairs(lua_table) do
			if type(k) == "string" then
				k = string.format("%q", k)
			end
			local szSuffix = ""
			if type(v) == "table" then
				szSuffix = "{"
			end
			local szPrefix = string.rep("    ", indent)
			formatting = szPrefix.."["..k.."]".." = "..szSuffix
			if type(v) == "table" then
				print(formatting)
				print_lua_table(v, indent + 1)
				print(szPrefix.."},")
			else
				local szValue = ""
				if type(v) == "string" then
					szValue = string.format("%q", v)
				else
					szValue = tostring(v)
				end
				print(formatting..szValue..",")
			end
		end
	end
end

function gprint(...)
	if GAME_PRINT_ENABLE then print(...) end
end

function gdump(...)
	if GAME_PRINT_ENABLE then dump(...) end
end

function gprint_dec_string(hint, data)
	if GAME_PRINT_ENABLE then
		local str = hint 
		for i=1,#data do
			str = str .. string.byte(data, i) .. " "
		end
		print(str)
	end
end

function table.isexist(tbl, index)
	if not tbl then return false end
	
	local res = rawget(tbl , index)
	if res == nil then return false
	else return true end
end

-- node添加touch事件
function nodeTouchEventProtocol(node, cb, mode, capture, swallow)
	if not node then return end

	mode = mode or cc.TOUCH_MODE_ONE_BY_ONE -- 单点触摸
	swallow = swallow or false

	if capture == nil then capture = true end
	-- if swallow == nil then swallow = true end

	node:setTouchEnabled(true)
	node:setTouchMode(mode)
	node:setTouchCaptureEnabled(capture)
	node:setTouchSwallowEnabled(swallow)

	-- 添加触摸事件处理函数
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		return cb(event)
	end)
end

function nodeExportComponentMethod(node)
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods()
end

-- 递归设置node以及所有子节点是否touch enable
function nodeCascadeTouchEnable(node, enable)
	if not node then return end

	node:setTouchEnabled(enable)

	local children = node:getChildren()
	if children then
		for index = 1, #children do
			local child = children[index]
			child:setTouchEnabled(true)

			nodeCascadeTouchEnable(child, enable)
		end
		-- local count = node:getChildrenCount()
		-- for index = 0, count - 1 do
		-- 	local child = children:objectAtIndex(index)
		-- 	-- dump(child, "我去")

		-- 	-- if child.setCascadeOpacityEnabled and type(child.setCascadeOpacityEnabled) == "function" then
		-- 	-- 	child:setCascadeOpacityEnabled(true)
		-- 	-- end

		-- 	nodeCascadeTouchEnable(child, enable)
		-- end
	end
end

function armature_add(imagePath, plistPath, configFilePath)
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(imagePath, plistPath, configFilePath)
end

function armature_remove(imagePath, plistPath, configFilePath)
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(configFilePath)
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plistPath)
    CCTextureCache:sharedTextureCache():removeTextureForKey(imagePath)
end

function armature_create(armatureName, x, y, movementHandler)
	x = x or 0
	y = y or 0
	local armature = CCArmature:create(armatureName)
	armature:setPosition(x, y)
	armature:connectMovementEventSignal(function(movementType, movementID)
			if movementHandler then movementHandler(movementType, movementID, armature) end
		end)
	return armature
end

function clearImageCache()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

function writefile(fileName, content, mode)
	fileName = fileName or "superstar_file"
	content = content or ""
	mode = mode or "w+b"

	local path = CCFileUtils:sharedFileUtils():getWritablePath() .. fileName
	-- if io.exists(path) then
		return io.writefile(path, content, mode)
	-- end
end

function readfile(fileName)
	fileName = fileName or "tank_file"

	local path = CCFileUtils:sharedFileUtils():getWritablePath() .. fileName
	if io.exists(path) then
		return io.readfile(path)
	end
end

function removeFile(fileName)
	io.writefile(fileName, "")
	if device.platform == "windows" then
		os.remove(string.gsub(fileName, '/', '\\'))
	else
		os.remove(fileName)
	end
end

function serialize(t, sort_parent, sort_child)  
    local function ser_table(tbl,parent)  
        local tmp={}  
        local sortList = {}
        for k,v in pairs(tbl) do  
            sortList[#sortList + 1] = {key=k, value=v}
        end  
  
        if tostring(parent) == "ret" then  
            if sort_parent then table.sort(sortList, sort_parent); end  
        else  
            if sort_child then table.sort(sortList, sort_child); end  
        end  
  
        for i = 1, #sortList do  
            local info = sortList[i];  
            local k = info.key;  
            local v = info.value;  
            local key= type(k)=="number" and "["..k.."]" or k;  
            if type(v)=="table" then  
                local dotkey= parent..(type(k)=="number" and key or "."..key)  
                table.insert(tmp, "\n"..key.."="..ser_table(v,dotkey))  
            else  
                if type(v) == "string" then  
                    table.insert(tmp, key..'="'..v..'"');  
                else  
                    table.insert(tmp, key.."="..tostring(v));  
                end  
            end  
        end  
  
        return "{"..table.concat(tmp,",").."}";  
    end  
   
    return "local ret=\n\n"..ser_table(t,"ret").."\n\n return ret"  
end  

-- 重写UTF8LEN方法
-- input 输入文字
-- outMax 输出最大限制
function string.utf8len(input, outMax)
    local len  = string.len(input)
    local left = 1
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	local _start = left
	local _end = _start
    while left <= len do
        local tmp = string.byte(input, left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left + i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
        if not outMax or cnt <= outMax then
            _end = left - 1
        end
    end
    return cnt , string.sub(input,_start,_end)
end

-- 重写UTF8截取方法
function string.utf8sub( input, startIndex, num )
    local sIndex = 1
    local originalStart = startIndex
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while startIndex > 1 do
        local tmp = string.byte(input, sIndex)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                sIndex = sIndex + i
                break
            end
            i = i - 1
        end   

        startIndex = startIndex - 1     
    end

    local eIndex = sIndex
    local len = string.len(input)
    while num > 0 and eIndex <= len do 
        local tmp = string.byte(input, eIndex)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                eIndex = eIndex + i
                break
            end
            i = i - 1
        end   

        num = num - 1         
    end

    return string.sub(input, sIndex, eIndex-1)
end

function formatstring( val )
    local h = math.floor(val/100000000)
    local l = val%100000000 
    if h > 0 then
	    return tostring(h) .. string.format("%08d", l)
	else
		return tostring(l)
	end
end

-----------------------------------------------
local MyVector2 = {x = 0, y = 0}
MyVector2.__index = MyVector2
function Vec(x,y)
	local vec = setmetatable({}, MyVector2)
	if (type(x) == "table") then
        for k, v in pairs(x) do
            vec[k] = v
        end
    elseif (type(x) == "number" and type(y) == "number") then
        vec['x'] = x
        vec['y'] = y
    end
    -- 单位
	vec.normalize = function()
		local vout = cc.pNormalize(vec)
		return Vec(vout.x,vout.y)
	end
	-- 模
	vec.modulus = function()
		return math.sqrt(math.pow(vec.x,2) + math.pow(vec.y,2))
	end
	--
	vec.ccp = function()
		return cc.p(vec.x, vec.y)
	end
	--
	vec.fccp = function()
		return cc.p(-vec.x, -vec.y)
	end

	return vec
end
-- 相加
function MyVector2.__add(p1,p2)
	return Vec({x = p1.x + p2.x, y = p1.y + p2.y})
end

-- 相减
function MyVector2.__sub(p1, p2)
    return Vec({x = p1.x - p2.x, y = p1.y - p2.y})
end

-- 相乘
function MyVector2.__mul(p1, p2)
	if type(p2) == "number" then
		return Vec({x = p1.x * p2, y = p1.y * p2})
	elseif type(p1) == "number" then
		return Vec({x = p1 * p2.x, y = p1 * p2.y})
	else
		return p1.x * p2.x + p1.y * p2.y
	end
end

function MyVector2.__tostring(p1)
    return "("..p1.x.." , "..p1.y .. ")"
end

-- 计算平均位置 以中心点为准
-- 使用时 以展示宽度中心为定点算起
-- example : display.cx + CalculateX(4,1,100,1) 屏幕中间开始排放
-- all 
-- index
-- width 单个元素宽度
-- dexScaleOfWidth 元素之间X坐标的距离 是width的倍数
function CalculateX( all, index, width, dexScaleOfWidth)
	-- body
	local c = all + 1
	local q = c / 2
	local sw = width * dexScaleOfWidth
	local w = q * sw
	return index * sw - w
end