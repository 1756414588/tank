-- 弹出框

local scheduler = require("framework.scheduler")

local Loading = class("Loading", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	return node
end)

local instance_ = nil

function Loading.getInstance()
	if not instance_ then
		instance_ = Loading.new()
	end
	return instance_
end

function Loading:ctor()
	-- gprint("Loading:ctor")

	-- self:setLocalZOrder(10000)
	self:setZOrder(999999)
	self:setNodeEventEnabled(true)
	self:setContentSize(cc.size(display.width, display.height))
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(display.cx, display.cy)
    nodeTouchEventProtocol(self, handler(self, self.onTouch), nil, nil, true)

end

-- function Loading:onEnter()
-- end

function Loading:onExit()
	-- print("Loading onExit")
	if self.unshowScheduler_ then
		-- print("Loading onshowScheduler")
		scheduler.unscheduleGlobal(self.unshowScheduler_)
		self.unshowScheduler_ = nil
	end
	instance_ = nil
end

-- isForce: 目前此参数无用。true：表示不手动unshow，则loading一直存在。false：表示在超过一定时间后，自动消除loading
-- time:显示多长时间
-- delay:延迟多长时间显示
function Loading:show(isForce, time, delay)
	local function showContent(dt)
		armature_add(IMAGE_ANIMATION .. "effect/ui_loading.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_loading.plist", IMAGE_ANIMATION .. "effect/ui_loading.xml")

	    local function animationEvent(movementType, movementID, armature)
	    	-- -- gprint("movement type:", movementType, "movement id:", movementID)
	     --    if movementType == MovementEventType.START then
	     --    elseif movementType == MovementEventType.COMPLETE then
	     --    	self:playEnd()
	     --    elseif movementType == MovementEventType.LOOP_COMPLETE then
	    	-- end
	    end

	    local effect = armature_create("loading_mc", display.cx, display.cy, animationEvent)
	    effect:getAnimation():playWithIndex(0)
	    effect:setScale(0.6)
	    self:addChild(effect)

		-- -- 半透明黑色背景
		-- self.m_touchLayer = display.newColorLayer(cc.c4b(0, 0, 0, 0))
		-- self.m_touchLayer:setContentSize(cc.size(display.width, display.height))
		-- -- self.m_touchLayer:setOpacity(180)
		-- self:addChild(self.m_touchLayer, -1)

		-- local btm = display.newSprite("image/common/loading_btm.png"):addTo(self)
		-- btm:setPosition(display.cx, display.cy)

		-- local label = display.newSprite("image/common/loading_label.png"):addTo(self)
		-- label:setPosition(display.cx, display.cy)

		-- -- -- 存放动画的sprite
		-- -- local sp = display.newSprite():addTo(self)
		-- -- sp:setPosition(display.cx, display.cy)

		-- -- local frames = display.newFrames("loading%02d.png", 1, 12)
		-- -- local animation = display.newAnimation(frames, 1 / 30)
		-- -- transition.playAnimationForever(sp, animation)
	end

	local parent = self:getParent()
	if parent ~= nil then  -- 已经被添加了
		-- gprint("已经被添加了")
		self:stopAllActions()

		if self.unshowScheduler_ then
			scheduler.unscheduleGlobal(self.unshowScheduler_)
			self.unshowScheduler_ = nil
		end
	else
	    local scene = display.getRunningScene()
	    scene:addChild(self, 999999)
	end

	delay = delay or 0.6

	self:runAction(transition.sequence({cc.DelayTime:create(delay),
		cc.CallFunc:create(showContent)}))
	-- showContent()

	local function selfUnshow()
		self.unshowScheduler_ = nil
		self:unshow()
	end

	time = time or 10

	-- 最多二十秒后，自动删除
	self.unshowScheduler_ = scheduler.performWithDelayGlobal(selfUnshow, time)
end

function Loading:unshow()
	self:removeSelf()
	instance_ = nil
end

function Loading:onTouch(event)
	-- gprint("Loading:onTouch")
	return true
end

return Loading