


local Dialog = require("app.dialog.Dialog")
local TeammateArmyInfoDialog = class("TeammateArmyInfoDialog", Dialog)

function TeammateArmyInfoDialog:ctor()
	TeammateArmyInfoDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_37.png", UI_ENTER_NONE, {scale9Size = cc.size(GAME_SIZE_WIDTH, 320), alpha = 0})
end

function TeammateArmyInfoDialog:onEnter()
	TeammateArmyInfoDialog.super.onEnter(self)
	self:setOutOfBgClose(true)
	self:setUI()
end

function TeammateArmyInfoDialog:setUI()
	-- 对话框上的其他UI处理
end

return TeammateArmyInfoDialog
