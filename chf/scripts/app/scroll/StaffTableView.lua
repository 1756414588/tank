-- 编制玩法TableView

local StaffTableView = class("StaffTableView", TableView)

function StaffTableView:ctor(size)
	StaffTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end


function StaffTableView:onEnter()
	StaffTableView.super.onEnter(self)

	-- self.m_updateHandler = Notify.register(LOCAL_ACTIVITY_REBATE_EVENT, handler(self, self.updateTip))

	-- self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	-- self:scheduleUpdate()
end

function StaffTableView:numberOfCells()
	-- return #self.activityList
	return 1
end

function StaffTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function StaffTableView:createCellAtIndex(cell, index)
	StaffTableView.super.createCellAtIndex(self, cell, index)

	-- local activity = self.activityList[index]
	-- cell.activity = activity

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png",90, 70):addTo(cell)

	local icon = display.newSprite("image/item/activity_staff_exercise.jpg"):addTo(fame)
	icon:setScale(0.9)
	icon:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
	
	local title = ui.newTTFLabel({text = CommonText[10059][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	title:setAnchorPoint(cc.p(0, 0.5))

	-- if activity.activityId == ACTIVITY_ID_BOSS then
		-- local status = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = title:getPositionX() + title:getContentSize().width, y = title:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		-- status:setAnchorPoint(cc.p(0, 0.5))

		-- -- if not ActivityCenterMO.isBossOpen_ then  -- 活动尚未开启
		-- local worldLv = 0
		-- if worldLv < 1 then
		-- 	status:setString("(" .. CommonText[10026] .. ")")  -- 活动暂未开放
		-- 	status:setColor(COLOR[6])
		-- end

		-- 每周一12:00开始演习报名
		local desc = ui.newTTFLabel({text = CommonText[20064], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 54, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		desc:setAnchorPoint(cc.p(0, 0.5))
	-- else
	-- 	local time = ui.newTTFLabel({text = os.date("%Y/%m/%d", activity.beginTime) .. "-" .. os.date("%Y/%m/%d %X", activity.endTime), font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 		x = 500, y = 54, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 	time:setAnchorPoint(cc.p(1, 0.5))

	-- 	cell.m_timeLab = time
	-- end

	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	-- local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDetailCallback))
	-- -- detailBtn.activity = activity
	-- -- self.m_detailBtns[index] = detailBtn
	-- cell:addButton(detailBtn, self.m_cellSize.width - 70, self.m_cellSize.height / 2 - 20)

	return cell
end

function StaffTableView:onDetailCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	DetailTextDialog.new(DetailText.exercise):push()
end

function StaffTableView:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()
	if StaffMO.worldLv_ < 1 then  -- 世界等级达到1级后
		Toast.show(CommonText[10054][2])
		return
	end

	-- if UserMO.staffing_ < STAFFING_PLATOON_LEADER then  -- 编制职位需要排长及以上职位
	-- 	local staffDB = StaffMO.queryStaffById(STAFFING_PLATOON_LEADER)
	-- 	Toast.show(string.format(CommonText[10054][1], staffDB.name))
	-- 	return
	-- end
	require("app.view.ExerciseView").new():push()
end

function StaffTableView:onExit()
	StaffTableView.super.onExit(self)
end

return StaffTableView