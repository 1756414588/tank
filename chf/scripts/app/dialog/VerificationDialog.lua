--
--
-- 
--
--

local Dialog = require("app.dialog.Dialog")
local VerificationDialog = class("VerificationDialog", Dialog)

-- local FontSize = FONT_SIZE_HUGE + 20

function VerificationDialog:ctor(data)
	VerificationDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(580, 630)})
	self.m_inDtat = data --or "9527"
end

function VerificationDialog:onEnter()
	VerificationDialog.super.onEnter(self)
	self:setTitle(CommonText[1803][1])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self, -1)
	btm:setPreferredSize(cc.size(542, 600))
	btm:setPosition(display.cx, display.cy)

	local questionStrs = self.m_inDtat
	self.quesNum = {}

	for index = 1, string.len(questionStrs) do
		local c = string.byte(questionStrs, index)
		local oc = string.char(c)
		self.quesNum[#self.quesNum + 1] = tonumber(oc)
	end	
	self:showContent()
end

function VerificationDialog:showContent()
	
	local queBg = display.newScale9Sprite(IMAGE_COMMON .. "bg_0.png"):addTo(self:getBg(),8)
	queBg:setPreferredSize(cc.size(180, 90))
	queBg:setPosition(self:getBg():width() - queBg:width() * 0.5 - 30, self:getBg():height() - queBg:height() * 0.5 - 80)

	math.randomseed(os.time())
	local node = display.newClippingRegionNode(cc.rect(0,0,180,90)):addTo(queBg, 1)
	node:setPosition(0 , 0)
	-- node:drawBoundingBox()
	
	for index = 1, 4 do
		local randomFnt = math.random(1, 9)
		local str = self.quesNum[index]
		local lableStr = ui.newBMFontLabel({text = "", font = "fnt/num_" .. randomFnt .. ".fnt", x = 0, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		-- x
		local _x = node:width() * 0.125 + (index - 1) * node:width() * 0.25
		local dexWidth = node:width() * 0.1
		local _xDex = math.random(-dexWidth, dexWidth)
		local p_x = _x + _xDex
		if (p_x - lableStr:width() * 0.5) < 0 then
			p_x = lableStr:width() * 0.5
		end
		if (p_x + lableStr:width() * 0.5) > node:width() then
			p_x = node:width() - lableStr:width() * 0.5
		end
		-- y
		local _y = node:height() * 0.5
		local dexHeight = node:height() * 0.2
		local _yDex = math.random(-dexHeight, dexHeight)
		local p_y = _y + _yDex
		lableStr:setPosition(p_x, p_y )

		-- rat
		local _rat = math.random(-30, 30)
		lableStr:setRotation(_rat)

		-- scale 
		local _scale = math.random(1, 1.3)
		lableStr:setScale(_scale)

		lableStr:setString(tostring(str))
	end

	self.numberList = {}
	for index = 1 , 4 do
		local bg = display.newSprite(IMAGE_COMMON .. "btn_position_3_normal.png"):addTo(self:getBg(), 2)
		bg:setScale(0.7)
		bg:setPosition(30 + bg:width() * (index - 0.5) * 1.2 * bg:getScale(), self:getBg():height() - bg:height() * 0.5 - 75)
		
		local numlb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_HUGE + 20, x = bg:x(), y = bg:y(), color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg(), 2)
		numlb.num = -1
		self.numberList[#self.numberList + 1] = numlb
	end
	self.numberPoint = 0

	local _x = 150
	local _y = 40
	-- keyborad
	for row = 1, 3 do
		for col = 1, 3 do
			local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.onNumCallback)):addTo(self:getBg())
			btn:setPosition(_x + (col - 0.5) * btn:width(), 102 + (row - 0.5) * btn:height() + _y)

			local num = (row - 1) * 3 + col
			btn.num = num
			btn:setLabel(num, {size = FONT_SIZE_HUGE + 20})
		end
	end

	-- C
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onClearCallback)):addTo(self:getBg())
	btn:setPosition(_x + 0.5 * btn:width(), 53 + _y)
	btn:setLabel("C", {size = FONT_SIZE_HUGE + 20})

	-- 0
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onNumCallback)):addTo(self:getBg())
	btn:setPosition(_x + 1.5 * btn:width(), 53 + _y)
	btn.num = 0
	btn:setLabel(0, {size = FONT_SIZE_HUGE + 20})

	-- enter
	local normal = display.newSprite(IMAGE_COMMON .. "btn_15_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_15_selected.png")
	local btn = MenuButton.new(normal, selected, nil, nil):addTo(self:getBg())
	btn:setPosition(_x + 2.5 * btn:width(), 53 + _y)
	btn:setEnabled(false)

	-- local tag = display.newSprite(IMAGE_COMMON .. "icon_enter.png"):addTo(btn)
	-- tag:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
end

function VerificationDialog:onNumCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local number = sender.num

	local size = #self.numberList
	self.numberPoint = self.numberPoint + 1
	self.numberPoint = self.numberPoint <= size and self.numberPoint or size
	local lb = self.numberList[self.numberPoint]
	if lb then
		lb:setString(tostring(number))
		lb.num = number
	end

	if size ~= self.numberPoint then return end

	local outStr = ""
	for index = 1 ,#self.numberList do
		local lb = self.numberList[index]
		local ans = self.quesNum[index]
		if lb.num == -1 or lb.num ~= ans then
			Toast.show(CommonText[1803][2])
			return
		end
		outStr = outStr .. tostring(lb.num)
	end
	local function resultCallback()
		self:pop(function ()
			if UserMO.SynPlugInScoutMineView then
				UserMO.SynPlugInScoutMineView:doSocket()
			end
		end)
		Toast.show(CommonText[1803][3])
	end
	UserBO.PlugInScoutMineValidCode(resultCallback, outStr)
end

function VerificationDialog:onClearCallback(tar, sender)
	ManagerSound.playNormalButtonSound()
	local lb = self.numberList[self.numberPoint]
	if lb then
		lb:setString("")
		lb.num = -1
		self.numberPoint = self.numberPoint - 1
		self.numberPoint = self.numberPoint > 0 and self.numberPoint or 0
	end
end

-- function VerificationDialog:onEnterCallback(tar, sender)
-- 	ManagerSound.playNormalButtonSound()
-- 	local outStr = ""
-- 	for index = 1 ,#self.numberList do
-- 		local lb = self.numberList[index]
-- 		local ans = self.quesNum[index]
-- 		print(index .. "  " .. lb.num .. " " .. ans)
-- 		if lb.num == -1 or lb.num ~= ans then
-- 			Toast.show("验证码错误，请重新输入！")
-- 			return
-- 		end
-- 		outStr = outStr .. tostring(lb.num)
-- 	end
-- 	print("out : " .. outStr)
-- 	local function resultCallback()
-- 		self:pop(function ()
-- 			print("UserMO.SynPlugInScoutMineView   " .. tostring(UserMO.SynPlugInScoutMineView ~= nil))
-- 			if UserMO.SynPlugInScoutMineView then
-- 				UserMO.SynPlugInScoutMineView:doSocket()
-- 			end
-- 		end)
-- 		Toast.show("验证完成！")
-- 	end
-- 	UserBO.PlugInScoutMineValidCode(resultCallback, outStr)
-- end

function VerificationDialog:onExit()
	VerificationDialog.super.onExit(self)
end

return VerificationDialog