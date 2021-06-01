--
-- Author: Xiaohang
-- Date: 2016-06-26 22:31:58
--
local Dialog = require("app.dialog.Dialog")
local AppointDetail = class("AppointDetail", Dialog)

-- tankId: 需要改装的tank
function AppointDetail:ctor(id,rhand)
	AppointDetail.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 334)})
	self.id = id
	self.rhand = rhand
	self:size(582,334)
end

function AppointDetail:onEnter()
	AppointDetail.super.onEnter(self)
	local dJob = FortressMO.queryJobById(self.id)
	self:setTitle(dJob.name)
	display.newSprite("image/item/job_"..self.id ..".png"):addTo(self:getBg()):leftTo(self.m_titleLabel)
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 304))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local node = self:getBg()
	UiUtil.label(dJob._desc):addTo(node):pos(node:width()/2,node:height()-75)
	local data = FortressBO.jobList_[self.id]
	local x,y,ey = 100,node:height()-100,30
	local times = {}
	for i=0,dJob.appointNum-1 do
		local t = UiUtil.label(CommonText[20040])
			:addTo(node):align(display.LEFT_CENTER,x,y-ey*i)
		if data and data[i+1] then
			t = UiUtil.label(data[i+1].nick,nil,COLOR[2])
				:addTo(node):rightTo(t)
			t = UiUtil.label("00:00:00")
				:addTo(node):align(display.RIGHT_CENTER,node:width()-100,t:y())
			t.endTime = data[i+1].endTime
			table.insert(times,t)
		else
			t = UiUtil.label(CommonText[509],nil,COLOR[2])
				:addTo(node):rightTo(t)
		end
	end
	local function tick()
		for k,v in ipairs(times) do
			local left = v.endTime - ManagerTimer.getTime()
			if left < 0 then left = 0 end
			local str = string.format("%02d:%02d:%02d",math.floor(left / 3600) % 24,math.floor(left / 60) % 60,left % 60)
			if left == 0 then
				str = CommonText[20063]
			end
			v:setString(str)
		end
	end
	tick()
	self:performWithDelay(tick, 1, 1)

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local returnBtn = MenuButton.new(normal, selected, nil, handler(self, self.onOk)):addTo(self:getBg())
	returnBtn:setPosition(self:getBg():width()/2, 25)
	returnBtn:setLabel(CommonText[1])
end

function AppointDetail:onExit()
	AppointDetail.super.onExit(self)
end

function AppointDetail:onOk()
	self.rhand()
	self:pop()
end

return AppointDetail