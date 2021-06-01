
-- 要塞弹出框

local Dialog = require("app.dialog.Dialog")
local FortressDialog = class("FortressDialog", Dialog)

function FortressDialog:ctor()
	FortressDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_LEFT_TO_RIGHT, {scale9Size = cc.size(588, 860)})
end

function FortressDialog:onEnter()
	FortressDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[431]) -- 要塞

	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_69.jpg"):addTo(self:getBg())
	tag:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 70 - tag:getContentSize().height / 2)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	bg:setPreferredSize(cc.size(500, 415))
	bg:setPosition(self:getBg():getContentSize().width / 2, 50 + bg:getContentSize().height / 2)

	for index = 1, #CommonText[433] do
		local desc = ui.newTTFLabel({text = CommonText[433][index], font = G_FONT, size = FONT_SIZE_SMALL, x = bg:getContentSize().width / 2, y = bg:getContentSize().height - index * 80, dimensions = cc.size(380, 80), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	end

	-- local function sortTank(tankA, tankB)
	-- 	if tankA.tankId > tankB.tankId then return true
	-- 	else return false end
	-- end

	-- self.m_tanks = TankBO.getFormationCanFightTank(self.m_formation)
	-- table.sort(self.m_tanks, sortTank)

	-- local labelColor = COLOR[11]
	-- local greenLabelColor = COLOR[2]

	-- local frame = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(btm)
	-- frame:setPreferredSize(cc.size(btm:getContentSize().width - 16, 548))
	-- frame:setCapInsets(cc.rect(130, 40, 1, 1))
	-- frame:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 12 - frame:getContentSize().height / 2)

	-- -- 数量
	-- local desc = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = btm:getContentSize().width / 2 - 20, y = 208, align = ui.TEXT_ALIGN_CENTER, color = labelColor}):addTo(btm)
	-- local num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, x = desc:getPositionX() +  desc:getContentSize().width / 2, y = desc:getPositionY(), color = greenLabelColor}):addTo(btm)
	-- num:setAnchorPoint(cc.p(0, 0.5))
	-- self.m_numLabel = num

	-- local AllMyArmyTableView = require("app.scroll.AllMyArmyTableView")
	-- local view = AllMyArmyTableView.new(cc.size(frame:getContentSize().width - 8, frame:getContentSize().height - 40), self.m_tanks):addTo(frame)
	-- view:addEventListener("CHOSEN_TANK_EVENT", handler(self, self.onChosenTank))  -- 如果有坦克，reloadData时会发送一次此事件!!!!
	-- view:setPosition(4, 30)
	-- self.m_armyTableView = view
	-- self.m_armyTableView:reloadData()

	-- if #self.m_tanks == 0 then  -- 没有坦克可以上阵
	-- 	self:onChosenTank({tankId = 0})
	-- end

 --    -- 减少按钮
 --    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
 --    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
 --    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(btm)
 --    reduceBtn:setPosition(50, 150 - 16)

 --    -- 增加按钮
 --    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
 --    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
 --    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(btm)
 --    addBtn:setPosition(btm:getContentSize().width - 50, reduceBtn:getPositionY())

	-- -- 确定
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	-- local okBtn = MenuButton.new(normal, selected, nil, handler(self, self.onOkCallback)):addTo(self:getBg())
	-- okBtn:setPosition(self:getBg():getContentSize().width / 2, 26)
	-- okBtn:setLabel(CommonText[1])
end

-- function ChoseArmyDialog:onChosenTank(event)
-- 	self.m_sender = event.sender

-- 	local tankId = event.tankId

-- 	if tankId == 0 then  -- 没有tank可以上阵
-- 		self.m_choseTankId = 0
-- 		self.m_maxNum = 0
-- 	else
-- 		local tank = event.tank
-- 		self.m_choseTankId = tankId
-- 		local takeCount = UserBO.getTakeTank()
-- 		self.m_maxNum = math.min(takeCount, tank.count)
-- 	end

-- 	gprint("[ChoseArmyDialog] maxNum:", self.m_maxNum)

-- 	self:showSlider()
-- end

-- function ChoseArmyDialog:showSlider()
-- 	local barHeight = 40
-- 	local barWidth = 286
-- 	if self.m_numSlider then
-- 		self.m_numSlider:removeSelf()
-- 		self.m_numSlider = nil
-- 	end

-- 	self.m_minNum = 1
-- 	if self.m_maxNum == 0 then self.m_minNum = 0 end
-- 	-- 当前坦克的数量
-- 	self.m_settingNum = self.m_maxNum

-- 	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
-- 	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 150)
--     self.m_numSlider:setSliderSize(barWidth, barHeight)
--     self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
--     self.m_numSlider:setSliderValue(self.m_settingNum)
--     self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(364, 64), {x = barWidth / 2, y = barHeight / 2 - 4})
-- end

-- function ChoseArmyDialog:onReduceCallback(tag, sender)
-- 	ManagerSound.playNormalButtonSound()
-- 	self.m_settingNum = self.m_settingNum - 1
-- 	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
-- 	self.m_numSlider:setSliderValue(self.m_settingNum)
-- end

-- function ChoseArmyDialog:onAddCallback(tag, sender)
-- 	ManagerSound.playNormalButtonSound()
-- 	self.m_settingNum = self.m_settingNum + 1
-- 	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
-- 	self.m_numSlider:setSliderValue(self.m_settingNum)
-- end

-- function ChoseArmyDialog:onSlideCallback(event)
-- 	local value = event.value - event.value % 1
-- 	gprint("ChoseArmyDialog value:", value)
-- 	self.m_settingNum = value
-- 	self.m_numLabel:setString(self.m_settingNum)
-- 	self.m_armyTableView:setCurTankFightNum(self.m_settingNum)
-- end

-- function ChoseArmyDialog:onOkCallback(tag, sender)
-- 	ManagerSound.playNormalButtonSound()
-- 	if self.m_choseTankCallback and self.m_choseTankId > 0 and self.m_settingNum > 0 then
-- 		self.m_choseTankCallback({tankId = self.m_choseTankId, count = self.m_settingNum})
-- 	end

-- 	self:pop()
-- end

return FortressDialog
