------------------------------------------------------------------------------
-- 荣耀勋章 view
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ActMedalUpDialog = class("ActMedalUpDialog", Dialog)

-- tankId: 需要改装的tank
function ActMedalUpDialog:ctor(begintime)
	ActMedalUpDialog.super.ctor(self, nil, UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
end

function ActMedalUpDialog:onEnter()
	ActMedalUpDialog.super.onEnter(self)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_102.png"):addTo(self:getBg())
	bg:center()

	local people = display.newSprite(IMAGE_COMMON .. "people_2.png"):addTo(bg)
	people:setAnchorPoint(cc.p(0.2,0))
	people:setPosition(0,0)

	local close_normal = display.newSprite(IMAGE_COMMON .. "btn_del_normal.png")
	local close_selected = display.newSprite(IMAGE_COMMON .. "btn_del_selected.png")
	local closeBtn = MenuButton.new(close_normal, close_selected, nil,handler(self,self.closeCallback)):addTo(bg,10)
	closeBtn:setPosition(bg:width() - closeBtn:width() - 30, bg:height() - closeBtn:height() + 20)

	local lb_value = ui.newTTFLabel({text = CommonText[1091][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		align = ui.TEXT_ALIGN_LEFT, color = cc.c3b(80, 51, 9), dimensions = cc.size(220,200)}):addTo(bg)
	lb_value:setAnchorPoint(cc.p(0.5,0.5))
	lb_value:setPosition(bg:width() * 0.5 + 80, bg:height() * 0.5 + 30)

	local go_normal = display.newSprite(IMAGE_COMMON .. "btn_63_normal.png")
	local go_selected = display.newSprite(IMAGE_COMMON .. "btn_63_selected.png")
	local goBtn = MenuButton.new(go_normal, go_selected, nil,handler(self,self.goCallback)):addTo(bg,10)
	goBtn:setPosition(bg:width() * 0.5 + 80, bg:height() * 0.5 - 70)
	goBtn:setLabel(CommonText[1091][2])

end

function ActMedalUpDialog:closeCallback(tag,sender)
	self:pop()
end

function ActMedalUpDialog:goCallback(tag,sender)
	local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_MEDAL)
	if activity then
		self:pop()
		-- UiDirector.popMakeUiTop("HomeView")
		require("app.view.ActivityMedalView").new(activity):push()
	else
		-- Toast.show("活动已经结束")
	end
end

function ActMedalUpDialog:onExit()
	ActMedalUpDialog.super.onExit(self)
end

return ActMedalUpDialog