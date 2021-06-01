
local Dialog = require("app.dialog.Dialog")
local BossBalanceDialog = class("BossBalanceDialog", Dialog)

function BossBalanceDialog:ctor(okCallback)
	BossBalanceDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 360)})

	self.m_okCallback = okCallback
end

function BossBalanceDialog:onEnter()
	BossBalanceDialog.super.onEnter(self)

	local starBg = {}

	armature_add(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")

	local function showStar()
		-- for index = 1, CombatMO.curBattleStar_ do
		for index = 1, 3 do -- 攻打世界BOSS只有三星显示
			local bg = starBg[index]
			local star = display.newSprite(IMAGE_COMMON .. "star_2.png"):addTo(bg)
			if index == 1 then star:setPosition(bg:getContentSize().width / 2 - 150, bg:getContentSize().height / 2 + 220)
			elseif index == 2 then star:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 220)
			elseif index == 3 then star:setPosition(bg:getContentSize().width / 2 + 150, bg:getContentSize().height / 2 + 220)
			end
			star:setVisible(false)
			star:runAction(transition.sequence({cc.DelayTime:create(0.22 * index),
				cc.CallFunc:create(function()
						star:setVisible(true)
						local armature = armature_create("ui_flash", bg:getContentSize().width / 2, bg:getContentSize().height / 2, function (movementType, movementID, armature) end)
						armature:getAnimation():playWithIndex(0)
						armature:addTo(bg)
					end),
				cc.MoveTo:create(0.15, cc.p(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 7)),
				cc.CallFunc:create(function() ManagerSound.playSound("balance_star") end)})) 
		end
	end

	for index = 1, 3 do -- 星级的背景
		local bg = display.newSprite(IMAGE_COMMON .. "star_bg_2.png"):addTo(self:getBg())
		bg:setPosition(self:getBg():getContentSize().width / 2 + (index - 2) * 85, self:getBg():getContentSize().height)
		starBg[index] = bg
	end

	showStar()

	-- 战斗结果
	local title = ui.newTTFLabel({text = CommonText[10016][1], font = G_FONT, size = FONT_SIZE_BIG, color = COLOR[12], x = self:getBg():getContentSize().width / 2, y = 285, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

	-- 伤害总值
	local label = ui.newTTFLabel({text = CommonText[10016][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[12], x = 40, y = 250, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = ActivityCenterMO.bossBalance_.hurtDelta, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	value:setAnchorPoint(cc.p(0, 0.5))

	if CombatMO.curBattleAward_ then
		-- 本次奖励
		local label = ui.newTTFLabel({text = CommonText[10016][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[12], x = label:getPositionX(), y = label:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		label:setAnchorPoint(cc.p(0, 0.5))

		dump(CombatMO.curBattleAward_.awards, "BOSS BALANCE ????")

		for index = 1, #CombatMO.curBattleAward_.awards do
			local award = CombatMO.curBattleAward_.awards[index]

			local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(self:getBg())
			itemView:setPosition(40 + 110 * (index - 0.5), 150)

			local resData = UserMO.getResourceData(award.kind, award.id)
			local name = ui.newTTFLabel({text = resData.name .. "*" .. award.count, font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX(), y = 85, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		end
	end

	local function onOkCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:pop(self.m_okCallback)
	end

	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2, 25)
end

function BossBalanceDialog:onExit()
	BossBalanceDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")
end

return BossBalanceDialog

