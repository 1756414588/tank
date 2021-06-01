
UiDirector = {}

local uiNodes_ = {}

local uiIdx_ = 1

-- -- 初始默认是最高等级UI
-- UiDirector.m_curUILevelIndex = UiDirector.UI_LEVEL_TOP

-- ui: 将view或者dialog添加到场景中
function UiDirector.push(ui, uiName)
	if not ui then return false end

	uiName = uiName or ui.__cname
	uiName = uiName or tostring(uiIdx_)

	ui.__cname = uiName
	if UiDirector.getTopUiName() == ui.__cname then  -- 避免重复添加一个ui
		gprint("[UiDirector] Error! push repeat ui, name:", ui.__cname)
		return false
	end

	if UiDirector.uiLimitNode and UiDirector.uiLimitNode then
		if UiDirector.hasUiByName(UiDirector.uiLimitNode.name) then
			ui:removeSelf()
			gprint("[UiDirector] WARNING! Limit Top Ui, name:", UiDirector.uiLimitNode.name)
			return false
		end
	end

	uiNodes_[#uiNodes_ + 1] = ui

	-- if #uiNodes_ >= 2 then
	-- 	if uiNodes_[#uiNodes_]._full_screen_ then
	-- 		-- uiNodes_[#uiNodes_ - 1]:setVisible(false)
	-- 	end
	-- end

	gprint("[UiDirector] push name:", uiName)
	-- gdump(uiName, "UiDirector.push name")

	display.getRunningScene():addChild(ui)

	uiIdx_ = uiIdx_ + 1
	return true
end

-- 出栈最新的UI
function UiDirector.pop(popCallback)
	if UiDirector.getUiCount() <= 1 then
		gprint("[UiDirector] at least has one ui! Error!")
		return false
	end

	local ui = UiDirector.getTopUi()
	local preName = ui:getUiName()
	gprint("UiDirector.pop name:", ui:getUiName())
	ui:removeSelf()

	table.remove(uiNodes_)

	-- ui = UiDirector.getTopUi()
	-- if ui and ui.class and ui.class.onUiFront and type(ui.class.onUiFront) == "function" then
	-- 	ui.class.onUiFront()
	-- end

	local ui = UiDirector.getTopUi()
	ui:setVisible(true)
	if ui.refreshUI then
		ui:refreshUI(preName)
	end
	if popCallback then
		popCallback()
	end

	return true
	-- if UiDirector.m_curUILevelIndex <= UiDirector.UI_LEVEL_TOP then
	-- 	gprint("UiDirector.pop ==> cannot pop level top ui")
	-- 	return false
	-- end

	-- if UiDirector.m_curUILevelIndex <= UiDirector.UI_LEVEL_TOP then
	-- 	gprint("UiDirector.pop ==> cur ui index is top")
	-- 	return false
	-- end

	-- if not cascade then cascade = false end

	-- local uis = UiDirector.m_uiLevel[UiDirector.m_curUILevelIndex]
	-- if #uis < 1 then -- 当前层级下没有UI
	-- 	if cascade then
	-- 		UiDirector.m_curUILevelIndex = UiDirector.m_curUILevelIndex - 1
	-- 		if UiDirector.m_curUILevelIndex == UiDirector.UI_LEVEL_TOP then
	-- 			return false
	-- 		else
	-- 			UiDirector.pop(true)
	-- 		end
	-- 	end
	-- else
	-- 	local count = #uis
	-- 	CCDirector:sharedDirector():getRunningScene():removeChild(uis[count])
	-- 	-- 删除最后一个
	-- 	table.remove(uis)
	-- end

	-- local lastestUI = UiDirector.getLastestUI()
	-- if lastestUI then
	-- 	lastestUI:setVisible(true)
	-- 	-- 更新UI层级
	-- 	UiDirector.m_curUILevelIndex = lastestUI.UI_DIRECTOR_LEVEL

	-- 	if lastestUI.class.onUIFront and type(lastestUI.class.onUIFront) == "function" then
	-- 		lastestUI.class.onUIFront(lastestUI)
	-- 	end
	-- end
end

--
-- popCallback pop 后回调参数
-- popName 出栈的类名
function UiDirector.popName(popCallback, popName)
	if UiDirector.getUiCount() <= 1 then
		gprint("[UiDirector] at least has one ui! Error!")
		return false
	end

	local popIndex = 0
	local count = UiDirector.getUiCount()
	local topName = UiDirector.getTopUi():getUiName()

	for index = count , 1 , -1 do
		local ui = uiNodes_[index]
		if ui:getUiName() == popName then
			popIndex = index
			print("UiDirector.popName name: " ..  ui:getUiName() .. " " .. index .. " of " .. count)
			ui:removeSelf()
			table.remove(uiNodes_, popIndex)
			break
		end
	end

	if popIndex == count then
		local ui = UiDirector.getTopUi()
		ui:setVisible(true)
		if ui.refreshUI then
			ui:refreshUI(topName)
		end
	end

	if popCallback then
		popCallback()
	end

	return true
end

-- popCallback pop 后回调参数
-- popToUI pop后 同时 添加UI
-- （ui:refreshUI 只在最终栈顶的的UI 刷新）
function UiDirector.popToUI(popCallback,popToUI)
	if UiDirector.getUiCount() <= 1 then
		gprint("[UiDirector] at least has one ui! Error!")
		return false
	end

	local ui = UiDirector.getTopUi()
	local preName = ui:getUiName()
	gprint("UiDirector.pop name:", ui:getUiName())
	ui:removeSelf()

	table.remove(uiNodes_)

	local ui = UiDirector.getTopUi()
	ui:setVisible(true)
	if not popToUI and ui.refreshUI then
		ui:refreshUI(preName)
	end
	if popCallback then
		popCallback()
	end

	if popToUI then
		UiDirector.push(popToUI)
	end

	return true
end

-- 从上向下一直pop当前的Ui，保证top的UI的名称是uiName
function UiDirector.popMakeUiTop(uiName)
	if not UiDirector.hasUiByName(uiName) then
		error("[UiDirector] popMakeUiTop Error!!!")
		return false
	end

	for index = #uiNodes_, 1, -1 do
		if UiDirector.getTopUiName() ~= uiName then
			UiDirector.pop()
		else
			break
		end
	end
	return true
end

-- 清楚所有的ui
-- force如果为true，则最小一层的ui也会被清楚
function UiDirector.clear(force)
	for index = #uiNodes_, 1, -1 do
		if index == 1 then
			if force then -- 清除最底层ui
				local ui = UiDirector.getTopUi()
				gprint("UiDirector.clear pop top name:", ui:getUiName())
				ui:removeSelf()
				table.remove(uiNodes_)
			end
		else
			UiDirector.pop()
		end
	end
end

function UiDirector.reset()
	uiNodes_ = {}
	uiIdx_ = 1
end

function UiDirector.getUiByName(uiName)
	if not uiName then return nil end

	for index, ui in pairs(uiNodes_) do
		if ui.__cname == uiName then
			return ui
		end
	end
	return nil
end

function UiDirector.hasUiByName(uiName)
	local ui = UiDirector.getUiByName(uiName)
	if ui then return true
	else return false end
end

function UiDirector.getTopUi()
	return uiNodes_[#uiNodes_]
end

function UiDirector.getTopUiName()
	local ui = uiNodes_[#uiNodes_]
	if not ui then return nil
	else return ui.__cname end
end

function UiDirector.getUiCount()
	return #uiNodes_
end

function UiDirector.unvisualBottomUi()
	if #uiNodes_ > 1 then
		if uiNodes_[#uiNodes_]._full_screen_ then
			uiNodes_[#uiNodes_ - 1]:setVisible(false)
		end
	end
end

function UiDirector.dumpUi()
	for index = 1, #uiNodes_ do
		gprint("[UiDirector] ", index, uiNodes_[index]:getUiName())
	end
end

function UiDirector.setLimitTopPoshNode(state, limitName)
	state = state or false
	if state then
		UiDirector.uiLimitNode = {name = limitName}
	else
		UiDirector.uiLimitNode = nil
	end
end

-- function UiDirector.getTopestUi()
-- 	return uiNodes_[#uiNodes_ + 1]
-- end

-- function UiDirector.getLastestUI()
-- 	local curLevel = UiDirector.m_curUILevelIndex

-- 	while curLevel >= UiDirector.UI_LEVEL_TOP do
-- 		local uis = UiDirector.m_uiLevel[curLevel]

-- 		if #uis < 1 then  -- 当前层级没有,则查看层级更高的一级
-- 			curLevel = curLevel - 1
-- 		else
-- 			--gprint("UiDirector.getLastestUI level:" .. curLevel)
-- 			return uis[#uis]
-- 		end
-- 	end
-- 	return nil
-- end
