
-- 获得从n到m之间的随机数
function random(n, m)
	n = n or 1
	m = m or 100
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	return math.random(n, m)
end

-- 将一个角度angle转换为[0,360)范围内
function clampAngle(angle)
	while angle < 0 do angle = angle + 360 end
	return angle % 360
end

-- 判断值A和B是否相等
function isEqual(valueA, valueB)
	if valueA == valueB then return true
	elseif math.abs(valueA - valueB) < 0.0001 then return true
	else return  false end
end
