--
-- Author: Xiaohang
-- Date: 2016-08-09 11:33:24
--
local Dialog = require("app.dialog.Dialog")
local ExchangeTankDialog = class("ExchangeTankDialog", Dialog)

function ExchangeTankDialog:ctor()
	ExchangeTankDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_LEFT_TO_RIGHT, {scale9Size = cc.size(588, 860)})
end

function ExchangeTankDialog:onEnter()
	ExchangeTankDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[20076]) -- 选择部队

	local labelColor = COLOR[11]
	local greenLabelColor = COLOR[2]

	local frame = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(btm)
	frame:setPreferredSize(cc.size(btm:getContentSize().width - 16, 548))
	frame:setCapInsets(cc.rect(130, 40, 1, 1))
	frame:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 12 - frame:getContentSize().height / 2)

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(btm)
    reduceBtn:setPosition(50, 175 - 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(btm)
    addBtn:setPosition(btm:getContentSize().width - 50, reduceBtn:getPositionY())

	-- 取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local okBtn = MenuButton.new(normal, selected, nil, function()
			ManagerSound.playNormalButtonSound()
			self:pop()
		end):addTo(self:getBg())
	okBtn:setPosition(120, 100)
	okBtn:setLabel(CommonText[2])

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local okBtn = MenuButton.new(normal, selected, nil, handler(self, self.onOkCallback)):addTo(self:getBg())
	okBtn:setPosition(self:getBg():width()-120, 100)
	okBtn:setLabel(CommonText[1])

	local t = UiUtil.label(CommonText[20079]):addTo(self:getBg()):align(display.LEFT_CENTER,220,115)
	self.exchangeNum = UiUtil.label("0",nil,COLOR[2]):addTo(self:getBg()):rightTo(t)
	t = UiUtil.label(CommonText[20080]):addTo(self:getBg()):alignTo(t, -30, 1)
	self.getNum = UiUtil.label("0",nil,COLOR[2]):addTo(self:getBg()):rightTo(t)

	local AllMyArmyTableView = require("app.scroll.AllMyArmyTableView")
	local view = AllMyArmyTableView.new(cc.size(frame:getContentSize().width - 8, frame:getContentSize().height - 40), table.values(TankMO.tanks_)):addTo(frame)
	view:addEventListener("CHOSEN_TANK_EVENT", handler(self, self.onChosenTank))  -- 如果有坦克，reloadData时会发送一次此事件!!!!
	view:setPosition(4, 30)
	self.m_armyTableView = view
	self:updateTanks()
	self.m_armyTableView:reloadData()
end

function ExchangeTankDialog:onChosenTank(event)
	self.m_sender = event.sender

	local tankId = event.tankId
	self.tankId = tankId
	if tankId == 0 then  -- 没有tank可以上阵
		self.m_choseTankId = 0
		self.m_maxNum = 0
	else
		local tank = event.tank
		self.m_choseTankId = tankId
		self.m_maxNum = math.min(20,tank.count)
	end

	gprint("[ChoseArmyDialog] maxNum:", self.m_maxNum)

	self:showSlider()
end

function ExchangeTankDialog:showSlider()
	local barHeight = 40
	local barWidth = 286
	if self.m_numSlider then
		self.m_numSlider:removeSelf()
		self.m_numSlider = nil
	end

	self.m_minNum = 1
	if self.m_maxNum == 0 then self.m_minNum = 0 end
	-- 当前坦克的数量
	self.m_settingNum = 1
	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 175)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(364, 64), {x = barWidth / 2, y = barHeight / 2 - 4})
end

function ExchangeTankDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function ExchangeTankDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function ExchangeTankDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	gprint("ChoseArmyDialog value:", value)
	self.m_settingNum = value
	self.exchangeNum:setString(value)
	self.getNum:setString(value*500)
	self.m_armyTableView:setCurTankFightNum(self.m_settingNum)
end

function ExchangeTankDialog:updateTanks()
	local function sortTank(tankA, tankB)
		if tankA.tankId > tankB.tankId then return true
		else return false end
	end
	local tanks = table.values(TankMO.tanks_)
	local list = {}
	for k,v in pairs(tanks) do
		if v.count > 0 then
			table.insert(list,v)
		end
	end
	table.sort(list, sortTank)
	self.m_armyTableView.m_tanks = list
end

function ExchangeTankDialog:onOkCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local id,count = self.tankId,self.m_settingNum
	if not id or not count then
		self:pop()
		return
	end
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(CommonText[20110], function()
			ExerciseBO.exchange(id,count,function()
				UserMO.reduceResource(ITEM_KIND_TANK,count,id)
				Notify.notify(LOCAL_EXCHANGE_TANK,{tanks = {tankId=id,count=count*500}})

				UserBO.triggerFightCheck()

				self:pop()
				require("app.dialog.ExchangeTankDialog").new():push()
				Toast.show(CommonText[590])
			end)
		end):push()

end

return ExchangeTankDialog