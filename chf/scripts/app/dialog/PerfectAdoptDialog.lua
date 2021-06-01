--
-- Author: Gss
-- Date: 2018-04-14 12:06:36
--

--完美通关展示
local Dialog = require("app.dialog.Dialog")

local PerfectAdoptDialog = class("PerfectAdoptDialog", Dialog)

function PerfectAdoptDialog:ctor()
	PerfectAdoptDialog.super.ctor(self, nil, UI_ENTER_NONE, {alpha = 0})
end

function PerfectAdoptDialog:onEnter()
	PerfectAdoptDialog.super.onEnter(self)
	
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)

	self:showUI()
end

function PerfectAdoptDialog:showUI()
	-- local actNode = display.newNode():addTo(self:getBg())
	-- actNode:setPosition(0,self:getBg():height())

	-- local btm = display.newSprite(IMAGE_COMMON .. "redplan/perfect_bg.png"):addTo(actNode)
	-- btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	-- local perfect = display.newSprite(IMAGE_COMMON .. "redplan/perfect_adopt.png"):addTo(btm)
	-- perfect:setPosition(btm:width() / 2, btm:height() / 2 + perfect:height() + 10)

	-- local unlock = UiUtil.label("功能解锁:",28):addTo(btm)
	-- unlock:setPosition(btm:width() / 2, btm:height() / 2 - unlock:height() / 2)

	-- local sweep = UiUtil.label("扫荡",28,COLOR[2]):addTo(btm)
	-- sweep:setPosition(unlock:x(), unlock:y() - 50)

	-- local close = UiUtil.label("点击任意地方关闭",16,COLOR[11]):addTo(btm)
	-- close:setPosition(sweep:x(), sweep:y() - 50)

	-- actNode:runAction(CCEaseBackInOut:create(cc.MoveTo:create(1,cc.p(0,0))))


	----------------------------------------------------------------------------------------------------------------------
	--方案2
	local btm = display.newSprite(IMAGE_COMMON .. "redplan/perfect_bg.png")
	-- btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local perfect = display.newSprite(IMAGE_COMMON .. "redplan/perfect_adopt.png"):addTo(self:getBg())
	perfect:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2 + perfect:height() + 10)


	local bar = CCProgressTimer:create(btm):addTo(self)
	bar:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	bar:setType(1)
	bar:setBarChangeRate(cc.p(0,1))
	bar:setMidpoint(cc.p(0,1))
	bar:setPercentage(0)

	--解锁
	local unlock = UiUtil.label(CommonText[5042],28):addTo(bar)
	unlock:setPosition(btm:width() / 2, btm:height() / 2 - unlock:height() / 2 + 10)
	unlock:setVisible(false)

	--扫荡
	local sweep = UiUtil.label(CommonText[35],28,COLOR[2]):addTo(bar)
	sweep:setPosition(unlock:x(), unlock:y() - 50)
	sweep:setVisible(false)

	--点击关闭
	local close = UiUtil.label(CommonText[5043],16,cc.c3b(155, 155, 155)):addTo(bar)
	close:setPosition(sweep:x(), sweep:y() - 70)
	close:setVisible(false)


	local function palyAct()
		bar:runAction(transition.sequence({CCProgressTo:create(0.28, 100), cc.CallFunc:create(function() 
			unlock:setVisible(true)
			sweep:setVisible(true)
			close:setVisible(true)
			end)}))
	end

	perfect:setScale(4.5)
	perfect:runAction(transition.sequence({CCEaseExponentialIn:create(cc.ScaleTo:create(0.6,1)), cc.DelayTime:create(0.2), cc.CallFunc:create(function() 
		palyAct()
	end)}))

end

function PerfectAdoptDialog:onExit()
	PerfectAdoptDialog.super.onExit()
end

return PerfectAdoptDialog