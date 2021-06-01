--
-- Author: gf
-- Date: 2015-09-14 19:18:00
-- 任务详情


local Dialog = require("app.dialog.Dialog")
local TaskDetailDialog = class("TaskDetailDialog", Dialog)

function TaskDetailDialog:ctor(task)
	TaskDetailDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE,{scale9Size = cc.size(450, 400)})
	self.task = task
end

function TaskDetailDialog:onEnter()
	TaskDetailDialog.super.onEnter(self)
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)
	local task = self.task
	local taskInfo = TaskMO.queryTask(task.taskId)

	local taskName = ui.newTTFLabel({text = taskInfo.taskName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = self:getBg():getContentSize().height - 50, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	taskName:setAnchorPoint(cc.p(0, 0.5))

	local scheduleLab = ui.newTTFLabel({text = CommonText[676][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = taskName:getPositionY() - 30, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	scheduleLab:setAnchorPoint(cc.p(0, 0.5))

	local scheduleValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40 + scheduleLab:getContentSize().width, y = scheduleLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	scheduleValue:setAnchorPoint(cc.p(0, 0.5)) 
	if taskInfo.type == 2 and task.accept == 0 then
		scheduleValue:setString(CommonText[684])
	else
		if task.schedule >= taskInfo.schedule then
			scheduleValue:setString(CommonText[676][4])
		else
			scheduleValue:setString(task.schedule .. "/" .. taskInfo.schedule)
		end
	end
	

	local awardLab = ui.newTTFLabel({text = CommonText[360][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = scheduleLab:getPositionY() - 30, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	awardLab:setAnchorPoint(cc.p(0, 0.5))
	
	local awards = json.decode(taskInfo.awardList)

	local taskExp = taskInfo.exp
	if UserMO.level_ >= 30 and taskInfo.type == 2 then
		taskExp = TaskMO.getDailyTaskExpByUserLevel(UserMO.level_, taskInfo.taskStar)
	end

	if taskExp > 0 then
		table.insert(awards,{ITEM_KIND_EXP,0,taskExp})
	end
	if awards and #awards > 0 then
		for index=1,#awards do
			local award = awards[index]
			local itemView = UiUtil.createItemView(award[1], award[2]):addTo(self:getBg())
			itemView:setPosition(90 + (index - 1) % 2 * 190 ,210 - 120 * math.floor((index - 1) / 2))
			UiUtil.createItemDetailButton(itemView)
			local name = ui.newTTFLabel({text = UserMO.getResourceData(award[1], award[2]).name, font = G_FONT, size = FONT_SIZE_SMALL, 
				x = itemView:getPositionX() + itemView:getContentSize().width / 2 + 10, 
				y = itemView:getPositionY() + 20, 
				align = ui.TEXT_ALIGN_CENTER, 
				color = COLOR[1]}):addTo(self:getBg())
				name:setAnchorPoint(cc.p(0, 0.5))
			local count = ui.newTTFLabel({text = "+" .. award[3], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = name:getPositionX(), 
				y = name:getPositionY() - 30, 
				align = ui.TEXT_ALIGN_CENTER, 
				color = COLOR[1]}):addTo(self:getBg())
			count:setAnchorPoint(cc.p(0, 0.5))
		end
	end

end



function TaskDetailDialog:onExit()
	TaskDetailDialog.super.onExit(self)
end


return TaskDetailDialog