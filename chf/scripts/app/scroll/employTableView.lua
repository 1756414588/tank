
local employTableView = class("employTableView", TableView)
local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")

function employTableView:ctor(size)
	employTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 150)
		--UserMO.prosperousLevel_繁荣度等级

	-- if WeaponryBO.MaxTechId ~=  WeaponryMO.updateMaxTechBypros() then
	-- 	WeaponryBO.isFirstEmploy = true
	-- end
	-- WeaponryBO.MaxTechId =  WeaponryMO.updateMaxTechBypros()
end

function employTableView:onEnter()
	employTableView.super.onEnter(self)
	--self.m_updateListHandler = Notify.register(LOCAL_WEAPONRY_EMPLOY, handler(self, self.updateListHandler))
	-- self.m_updateListHandler1 = Notify.register(LOCAL_TASK_FINISH_EVENT, handler(self, self.updateListHandler))
end

function employTableView:numberOfCells()
	local data = WeaponryMO.getEmploy()
	local count = 0 
	self.needData = {}
	for k,v in pairs(data) do
		if WeaponryBO.MaxTechId <= v.id then
			count = count + 1
			table.insert(self.needData,v)
		end
	end
	function sortfunction(a,b)
		return a.id < b.id
	end
	table.sort( self.needData, sortfunction )
	if count > 2 then
		count = 2
	end
	if WeaponryBO.MaxTechId == 0 then
		count = 1
	end
	return count
end

function employTableView:cellSizeForIndex(index)
	
	return self.m_cellSize
end

function employTableView:createCellAtIndex(cell, index)
	employTableView.super.createCellAtIndex(self, cell, index)
	local taskInfo = self.needData[index]
	-- WeaponryBO.MaxTechId
	local taskBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(cell,-1)
	taskBg:setPreferredSize(cc.size(610, 140))
	taskBg:setCapInsets(cc.rect(80, 60, 1, 1))
	taskBg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local taskIcon = UiUtil.createItemView(ITEM_KIND_WEAPONRY_EMPLOY, taskInfo.id)
	taskBg:addChild(taskIcon)
	taskIcon:setPosition(80,70)

	local taskName = ui.newTTFLabel({text = taskInfo.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 115, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	taskName:setAnchorPoint(cc.p(0, 0.5))

	local timeDown = ui.newTTFLabel({text = CommonText[1737] .. (taskInfo.workTime/3600) .. CommonText[159][3], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 610 - 200, y = 115, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	timeDown:setAnchorPoint(cc.p(0, 0.5))


	local liveLab = ui.newTTFLabel({text = CommonText[1607][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 65, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	liveLab:setAnchorPoint(cc.p(0, 0.5))

	local liveValue = ui.newTTFLabel({text = (taskInfo.timeDown/3600) .. CommonText[159][3] , font = G_FONT, size = FONT_SIZE_SMALL, 
		x = liveLab:getPositionX() + liveLab:getContentSize().width, y = 65, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	liveValue:setAnchorPoint(cc.p(0, 0.5))


	local scheduleLab = ui.newTTFLabel({text = string.format(CommonText[1608],taskInfo.prosLevel), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150, y = 35, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	scheduleLab:setAnchorPoint(cc.p(0, 0.5))


	local scheduleValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 150 + scheduleLab:getContentSize().width, y = 35, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(taskBg)
	scheduleValue:setAnchorPoint(cc.p(0, 0.5)) 
	--当前繁荣度等级
	local prosLv = UserBO.getProsperousLevel(UserMO.maxProsperous_) 

	if tonumber(WeaponryBO.MaxTechId) >=  tonumber(taskInfo.id) then
		scheduleValue:setString("")
		scheduleLab:setColor(COLOR[2])
	else		
		scheduleLab:setColor(COLOR[6])
		scheduleValue:setString( "("..prosLv .. "/" .. taskInfo.prosLevel .. ")")
	end
	--CommonText[1608]
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local goBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onGoTask))
	goBtn:setLabel(CommonText[1607][2])
	goBtn.taskInfo = taskInfo
	cell:addButton(goBtn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 20)
	if WeaponryBO.MaxTechId <= taskInfo.id then
		if WeaponryBO.isFirstEmploy == true then
			goBtn:setLabel(CommonText[1607][2])
		else
			goBtn:setLabel(CommonText[1607][6])		
		end
		if WeaponryBO.currEmployId == taskInfo.id then
			goBtn:setLabel(CommonText[1607][4])
			--goBtn:setEnabled(false)
		end
		if index == 2 then
			goBtn:setVisible(false)
		end
		if WeaponryBO.MaxTechId == 0 then
			goBtn:setLabel(CommonText[1607][5])
			goBtn:setEnabled(false)
		end
	else
		goBtn:setVisible(false)
	end
	return cell
end

function employTableView:onGoTask(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function rhand()
		Loading.getInstance():unshow()
		Toast.show(CommonText[1736])
	end

	if WeaponryBO.isFirstEmploy == true then
		Loading.getInstance():show()
		WeaponryBO.EmployTechnical(rhand,sender.taskInfo.id)
	else
		if UserMO.consumeConfirm  then
			local cost = sender.taskInfo.cost
			CoinConfirmDialog.new(string.format(CommonText[1613],cost), function()
					if UserMO.coin_ < cost then
						require("app.dialog.CoinTipDialog").new():push()
						return
					end
					Loading.getInstance():show()
					WeaponryBO.EmployTechnical(rhand,sender.taskInfo.id)
					end):push()
		else
			local cost = sender.taskInfo.cost
			if UserMO.coin_ < cost then
				require("app.dialog.CoinTipDialog").new():push()
				return
			end
			Loading.getInstance():show()
		    WeaponryBO.EmployTechnical(rhand,sender.taskInfo.id)
		end
	end
end


function employTableView:onDetailTask(tag, sender)
	-- require("app.dialog.TaskDetailDialog").new(sender.task):push()
end


function employTableView:cellTouched(cell, index)

end

function employTableView:updateListHandler(event)
	local offset = self:getContentOffset()
   	self:reloadData()
   	--self:setContentOffset(offset)
end


function employTableView:onExit()
	employTableView.super.onExit(self)
	-- if self.m_updateListHandler then
	-- 	Notify.unregister(self.m_updateListHandler)
	-- 	self.m_updateListHandler = nil
	-- end
end



return employTableView