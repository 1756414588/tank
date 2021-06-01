
-- 键盘view(只能操作数字)

local Dialog = require("app.dialog.Dialog")
local KeyBoardDialog = class("KeyBoardDialog", Dialog)

local FontSize = FONT_SIZE_HUGE + 20

-- lenLimit:数字的长度限制，默认是3位数
function KeyBoardDialog:ctor(numCallback, lenLimit)
	KeyBoardDialog.super.ctor(self, IMAGE_COMMON .. "info_bg_37.png", UI_ENTER_NONE, {scale9Size = cc.size(304, 404), alpha = 0})
	self.m_numCallback = numCallback
	self.m_curNum = 0
	self.m_lenLimit = lenLimit or 3

	self.m_maxNum = math.pow(10, self.m_lenLimit) - 1
end

function KeyBoardDialog:onEnter()
	KeyBoardDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)

	-- self.m_minNum = math.pow(10, self.m_lenLimit - 1)

	-- self.m_enterCallback = enterCallback

	self:setUI()
end

function KeyBoardDialog:setUI()
	for row = 1, 3 do
		for col = 1, 3 do
			local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.onNumCallback)):addTo(self:getBg())
			btn:setPosition(6 + (col - 0.5) * 98, 102 + (row - 0.5) * 98)

			local num = (row - 1) * 3 + col
			btn.num = num
			btn:setLabel(num, {size = FontSize})
		end
	end

	-- C
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onClearCallback)):addTo(self:getBg())
	btn:setPosition(6 + 0.5 * 98, 53)
	btn:setLabel("C", {size = FontSize})

	-- 0
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onNumCallback)):addTo(self:getBg())
	btn:setPosition(6 + 1.5 * 98, 53)
	btn.num = 0
	btn:setLabel(0, {size = FontSize})

	-- enter
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onEnterCallback)):addTo(self:getBg())
	btn:setPosition(6 + 2.5 * 98, 53)

	local tag = display.newSprite(IMAGE_COMMON .. "icon_enter.png"):addTo(btn)
	tag:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
end

function KeyBoardDialog:onNumCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if self.m_curNum * 10 > self.m_maxNum then return end

	if self.m_curNum == 0 then
		self.m_curNum = sender.num
	else
		self.m_curNum = self.m_curNum * 10 + sender.num
	end

	if self.m_numCallback then self.m_numCallback(self.m_curNum) end
end

function KeyBoardDialog:onClearCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self.m_curNum = 0

	if self.m_numCallback then self.m_numCallback(self.m_curNum) end
end

function KeyBoardDialog:onEnterCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
end

return KeyBoardDialog
