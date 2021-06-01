--
--
-- 数字输入框
-- 
--
--
local Dialog = require("app.dialog.DialogEx")
local InputNumberDialog = class("InputNumberDialog", Dialog)

--
-- 数字编辑器
-- inputfunc : 输入反馈 返回 number
-- select    : 预输入值 默认为 0
-- limit     : 最大限制 0 不启用
-------------------------------------
-- 界面
-- ccp       : 背景坐标 默认 屏幕中心 display.cx, display.cy
-- anchor    : 锚点 默认中心 0.5,0.5
-- 【暂时不支持小数】
function InputNumberDialog:ctor(param)
	InputNumberDialog.super.ctor(self)

	self.m_param = param or {}
	self.InputingListeningFunc = self.m_param.inputfunc or nil
	self.selectNum = math.floor(tonumber(self.m_param.select or 0))
	self.limitNum = math.floor(tonumber(self.m_param.limit or 0))

	self.inputNumber = self.selectNum
	-- self.inputStr = tostring(self.inputNumber)
end

function InputNumberDialog:onEnter()
	InputNumberDialog.super.onEnter(self)

	local ccp = self.m_param.ccp or cc.p(display.cx, display.cy)
	local anchor = self.m_param.anchor or cc.p(0.5,0.5)

	local viewbg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_37.png"):addTo(self)
	viewbg:setPreferredSize(cc.size(300 , 400))
	viewbg:setAnchorPoint(anchor)
	viewbg:setPosition(ccp)
	self.m_viewbg = viewbg

	local _x = 5
	local _y = 0
	-- keyborad
	for row = 1, 3 do
		for col = 1, 3 do
			local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.onNumCallback)):addTo(viewbg)
			btn:setPosition(_x + (col - 0.5) * btn:width(), 102 + (row - 0.5) * btn:height() + _y)

			local num = (row - 1) * 3 + col
			btn.num = num
			btn:setLabel(num, {size = FONT_SIZE_HUGE + 20})
		end
	end

	-- C
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onClearCallback)):addTo(viewbg)
	btn:setPosition(_x + 0.5 * btn:width(), 53 + _y)
	btn:setLabel("C", {size = FONT_SIZE_HUGE + 20})

	-- 0
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onNumCallback)):addTo(viewbg)
	btn:setPosition(_x + 1.5 * btn:width(), 53 + _y)
	btn.num = 0
	btn:setLabel(0, {size = FONT_SIZE_HUGE + 20})

	-- enter
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onEnterCallback)):addTo(viewbg)
	btn:setPosition(_x + 2.5 * btn:width(), 53 + _y)
	-- btn:setVisible(false)

	local tag = display.newSprite(IMAGE_COMMON .. "icon_enter.png"):addTo(btn)
	tag:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)

	self.m_outOfBgClose = true
end

function InputNumberDialog:onNumCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local number = sender.num

	local curNumber = self.inputNumber
	local outNumber = curNumber * 10 + number

	if self.limitNum and self.limitNum > 0 and outNumber > self.limitNum then
		outNumber = self.limitNum
	end
	self.inputNumber = outNumber
	if self.InputingListeningFunc then self.InputingListeningFunc(outNumber, number) end
end

function InputNumberDialog:onClearCallback(tar, sender)
	ManagerSound.playNormalButtonSound()

	local curNumber = self.inputNumber
	local outNumber = math.floor(curNumber * 0.1)

	if outNumber <= 0 then
		outNumber = 0
	end
	self.inputNumber = outNumber
	if self.InputingListeningFunc then self.InputingListeningFunc(outNumber, nil) end
end

function InputNumberDialog:onEnterCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	self:close()
end

function InputNumberDialog:close()
	InputNumberDialog.super.close(self)
end

return InputNumberDialog