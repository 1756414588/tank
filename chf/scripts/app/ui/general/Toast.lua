--
-- Author: GongYY
-- Date: 
-- 

local Toast = class("Toast", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

local toasts_ = {}
local toastIndex_ = 0

-- Toast显示时间
local TOAST_SHOW_TIME = 0.8

function Toast:ctor()
	self.m_textLabel = ui.newTTFLabel({text = text, font = G_FONT, size = FONT_SIZE_MEDIUM, color = cc.c3b(250, 249, 31)})

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg.png")
	-- bg:setPreferredSize(cc.size(580, 60))
	bg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
	self:addChild(bg)

	self.m_textLabel:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 4)
	self:addChild(self.m_textLabel)

	self:setContentSize(cc.size(bg:getContentSize().width, bg:getContentSize().height))
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setCascadeOpacityEnabled(true)
end

function Toast:onEnter()
	toastIndex_ = toastIndex_ + 1
	self.index_ = toastIndex_
	toasts_[toastIndex_] = self
end

function Toast:onExit()
	toasts_[self.index_] = nil
end

function Toast:star(text, showTime)
	if type(text) == "string" then
		self.m_textLabel:setString(text)
	end
	self:setOpacity(0)
	self:stopAllActions()

	self:runAction(transition.sequence({cc.FadeIn:create(0.2),
		cc.MoveBy:create(0.4, cc.p(0, 100)),
		cc.CallFunc:create(function()
				armature_add(IMAGE_ANIMATION .. "effect/ui_toast.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_toast.plist", IMAGE_ANIMATION .. "effect/ui_toast.xml")
				local armature = armature_create("ui_toast", 0, 53):addTo(self)
				armature:getAnimation():playWithIndex(0)
			end),
		cc.DelayTime:create(showTime),  -- 展示一段时间
		cc.FadeOut:create(0.6),
		cc.CallFunc:create(handler(self, self.unshow))}))
end

function Toast:unshow()
	self:removeSelf()
	-- instance_ = nil
end

function Toast.show(text, showTime)
	local toast = Toast.new()

	text = text or ""
	showTime = showTime or TOAST_SHOW_TIME

	toast:setPosition(display.cx, display.cy - 50)
	toast:setLocalZOrder(999999)
	toast:setTag(999888)
	toast:addTo(display.getRunningScene())
	toast:star(text, showTime)
	return toast
end

function Toast.clear()
	for index, toast in pairs(toasts_) do
		if toast then
			toast:removeSelf()
		end
	end
	toasts_ = {}
end

-- function Toast.isShow()
-- 	local scene = CCDirector:sharedDirector():getRunningScene()
-- 	local toast = scene:getChildByTag(999888)
-- 	if toast then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end

return Toast
