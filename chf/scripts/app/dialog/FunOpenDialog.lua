--
-- Author: gf
-- Date: 2016-01-18 11:21:25
--


local Dialog = require("app.dialog.Dialog")
local FunOpenDialog = class("FunOpenDialog", Dialog)

function FunOpenDialog:ctor(buildId)
	FunOpenDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 380)})

	self.m_buildId = buildId
	
	if UserMO.level_ == 75  then
		self.m_buildId = 74
	end

end

function FunOpenDialog:onEnter()
	FunOpenDialog.super.onEnter(self)
	self:setTitle(CommonText[855])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 290))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	
	display.newSprite(IMAGE_COMMON .. "fun_open_" .. self.m_buildId .. ".jpg", btm:getContentSize().width / 2, btm:getContentSize().height / 2 - 10):addTo(btm)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local goBtn = MenuButton.new(normal, selected, nil, handler(self,self.goHandler)):addTo(self:getBg())
	goBtn:setPosition(self:getBg():getContentSize().width / 2,0)
	goBtn:setLabel(CommonText[856])

end

function FunOpenDialog:goHandler()
	ManagerSound.playNormalButtonSound()
	--触发引导
	if self.m_buildId == BUILD_ID_ARENA then
		TriggerGuideMO.currentStateId = 20
	elseif self.m_buildId == BUILD_ID_COMPONENT then
		TriggerGuideMO.currentStateId = 30
	elseif self.m_buildId == BUILD_ID_SCHOOL then
		TriggerGuideMO.currentStateId = 40
	elseif self.m_buildId == BUILD_ID_EQUIP then
		TriggerGuideMO.currentStateId = 50
	elseif self.m_buildId == 74 then
		TriggerGuideMO.currentStateId = 60
	elseif self.m_buildId == BUILD_ID_LABORATORY then
		TriggerGuideMO.currentStateId = 90
	elseif self.m_buildId == BUILD_ID_TACTICCENTER then --战术中心
		TriggerGuideMO.currentStateId = 100
	elseif self.m_buildId == BUILD_ID_ENERGYCORE then --能源核心
		TriggerGuideMO.currentStateId = 110
	end
	
	Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)

end


function FunOpenDialog:onExit()
	FunOpenDialog.super.onExit(self)
end

return FunOpenDialog