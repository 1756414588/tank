--
-- Author: Gss
-- Date: 2018-06-20 15:49:50
-- 经验加成dialog

local Dialog = require("app.dialog.Dialog")
local ExpAdditionDialog = class("ExpAdditionDialog", Dialog)

function ExpAdditionDialog:ctor()
	ExpAdditionDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 380)})
end

function ExpAdditionDialog:onEnter()
	ExpAdditionDialog.super.onEnter(self)

	self:setTitle(CommonText[1813])

	local num
	local data = json.decode(UserMO.querySystemId(62))--此处写死ID为62

	for index=1,#data do
		if UserMO.level_ >= data[index][1] and UserMO.level_ <= data[index][2] then
			num = data[index][3]
			break
		end
	end

	local value = tostring(num * 100)

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 350))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local icon = display.newSprite(IMAGE_COMMON .. "exp_addition.png"):addTo(self:getBg())
	icon:setPosition(self:getBg():width() / 2, self:getBg():height() - 120)
	icon:setScale(1.3)

	--描述
	local desc = UiUtil.label(CommonText[1814],nil,nil,cc.size(self:getBg():width() - 70,0),ui.TEXT_ALIGN_LEFT)
	desc:addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0, 0.5))
	desc:setPosition(40, icon:y() - 80)


	--当前提速
	local speed = UiUtil.label(string.format(CommonText[1815], value.."%"), nil, COLOR[2]):addTo(self:getBg())
	speed:setPosition(self:getBg():width() / 2, icon:y() - 140)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, function ()
		self:pop()
		require("app.view.CombatSectionView").new():push()
	end):addTo(self:getBg())
	rechargeBtn:setPosition(self:getBg():getContentSize().width / 2,25)
	rechargeBtn:setLabel(CommonText[1084][8])
end

function ExpAdditionDialog:onExit()
	ExpAdditionDialog.super.onExit(self)
end

return ExpAdditionDialog
