
AttributeBO = {}

function AttributeBO.getAttributeData(attributeId, attributeValue, posMore)
	local ret = {}
	ret.id = attributeId

	if attributeId == 1 or attributeId == 3 or attributeId == 17 or attributeId == 31 then  -- 数值
		local attribute = AttributeMO.queryAttributeById(attributeId)
		ret.name = attribute.desc
		ret.index = attributeId
		ret.value = attributeValue + 0
		ret.attrName = attribute.attrName
		ret.strValue = AttributeBO.formatAttrValue(attributeId, attributeValue, posMore)
	elseif attributeId == 5 or attributeId == 7 or attributeId == 9 or attributeId == 11 then  -- 数值千分比，显示百分比
		local attribute = AttributeMO.queryAttributeById(attributeId)
		ret.name = attribute.desc
		ret.index = attributeId
		ret.value = attributeValue / 1000
		ret.attrName = attribute.attrName
		ret.strValue = AttributeBO.formatAttrValue(attributeId, ret.value, posMore)
	elseif attributeId == 13 or attributeId == 15 or attributeId == 37 or attributeId == 39 then -- 数值千分比，显示百分比
		local attribute = AttributeMO.queryAttributeById(attributeId)
		ret.name = attribute.desc
		ret.index = attributeId
		ret.value = attributeValue / 1000
		ret.attrName = attribute.attrName
		ret.strValue = AttributeBO.formatAttrValue(attributeId, ret.value, posMore)
	elseif attributeId > 1000 then
		local attribute = AttributeMO.queryAttributeById(attributeId)
		local _rate = attribute.rate == 0 and 0 or (attribute.rate + 1) 
		local format = attribute.format
		ret.name = attribute.desc
		ret.index = attributeId
		ret.value = attributeValue * math.pow(0.1, _rate)
		ret.attrName = attribute.attrName
		ret.strValue = AttributeBO.formatAttrValue(attributeId, ret.value, posMore)
	elseif attributeId == 34 then
		local attribute = AttributeMO.queryAttributeById(attributeId)
		if attribute then
			ret.name = attribute.desc
			ret.index = attributeId - 1
			ret.value = attributeValue / 10000
			ret.attrName = attribute.attrName
			ret.strValue = AttributeBO.formatAttrValue(attributeId, ret.value, posMore)
		else
			return nil
		end
	else -- 数值万分比，显示百分比
		local attribute = AttributeMO.queryAttributeById(attributeId - 1)
		if attribute then
			ret.name = attribute.desc
			ret.index = attributeId - 1
			ret.value = attributeValue / 10000
			ret.attrName = attribute.attrName
			ret.strValue = AttributeBO.formatAttrValue(attributeId, ret.value, posMore)
		else
			return nil
		end
	end
	return ret
end

-- function AttributeBO.getAttributeData(attributeId, attributeValue)
-- 	local attribute = AttributeMO.queryAttributeById(attributeId)
-- 	if not attribute then return nil end

-- 	local ret = {}
-- 	ret.id = attributeId
-- 	if attributeId % 2 == 0 then -- 百分比的形式
-- 		ret.type = 2

-- 		local va = AttributeMO.queryAttributeById(attributeId - 1)
-- 		ret.name = va.desc
-- 		ret.index = attributeId - 1
-- 	else
-- 		ret.type = 1
-- 		ret.name = attribute.desc
-- 		ret.index = attributeId
-- 	end

-- 	ret.attrName = attribute.attrName

-- 	ret.value = attributeValue
-- 	ret.strValue = AttributeBO.formatAttrValue(attributeId, attributeValue)
-- 	return ret
-- end

function AttributeBO.formatAttrValue(attributeId, attributeValue, posMore)
	if attributeId == 1 or attributeId == 3 or attributeId == 17 then -- 显示数值
		return string.format("%.2f",attributeValue) .. ""
	elseif attributeId == 5 or attributeId == 7 or attributeId == 9 or attributeId == 11 then
		return string.format("%.1f", attributeValue * 100) .. "%"
	elseif attributeId == 13 or attributeId == 15 or attributeId == 37 or attributeId == 39 then
		return string.format("%.2f",attributeValue) .. ""
	elseif attributeId == 31 then
		return string.format("%d",attributeValue) .. ""
	elseif attributeId > 1000 then
		local attribute = AttributeMO.queryAttributeById(attributeId)
		if attribute.format and attribute.format == 1 then
			return string.format("%.1f", attributeValue * 100) .. "%"
		else -- attribute.format == 0
			return string.format("%.2f",attributeValue) .. ""
		end
	else  -- 百分比
		local key = "%."..(posMore or 1) .."f"
		return string.format(key, attributeValue * 100) .. "%"
	end
end

-- function AttributeBO.formatAttrValue(attributeId, attributeValue)
	-- if attributeId % 2 == 0 then -- 百分比的形式
	-- 	if attributeValue == 0 then return "0%"
	-- 	else return string.format("%.1f", attributeValue * 100) .. "%" end
	-- else
	-- 	return attributeValue
	-- end
-- end
