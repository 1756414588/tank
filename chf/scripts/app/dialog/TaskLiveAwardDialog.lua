--
-- Author: gf
-- Date: 2015-09-25 10:13:18
--

local Dialog = require("app.dialog.Dialog")
local TaskLiveAwardDialog = class("TaskLiveAwardDialog", Dialog)

function TaskLiveAwardDialog:ctor()
	TaskLiveAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function TaskLiveAwardDialog:onEnter()
	TaskLiveAwardDialog.super.onEnter(self)

	self:setTitle(CommonText[269])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 810))

	local TaskLiveAwardTableView = require("app.scroll.TaskLiveAwardTableView")
	local view = TaskLiveAwardTableView.new(cc.size(btm:getContentSize().width, btm:getContentSize().height - 60)):addTo(btm)
	view:setPosition(0, 20)
	view:reloadData()
end

return TaskLiveAwardDialog