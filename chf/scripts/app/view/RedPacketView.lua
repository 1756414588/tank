--
--
-- 红包 抢红包 抢
-- MYS
--

local RedPacketView = class("RedPacketView", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

RedPacketView.instance_ = nil

function RedPacketView:ctor()
end

function RedPacketView:onEnter()
	armature_add(IMAGE_ANIMATION .. "effect/qianghongbao.pvr.ccz", IMAGE_ANIMATION .. "effect/qianghongbao.plist", IMAGE_ANIMATION .. "effect/qianghongbao.xml")

	local effect = armature_create("qianghongbao"):addTo(self )
	effect:getAnimation():playWithIndex(0)
	effect:setPosition(display.width - 35,display.height - 220)

	local normal = display.newNode():addTo(effect)
	normal:setContentSize(cc.size(50,50))
	normal:setPosition(-25, -25)
	normal:setTouchEnabled(true)
	normal:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			return true
	    elseif event.name == "ended" then
	    	self:doGetAndClose()
		end
	end)
	
	self.m_redInfo = nil
end

function RedPacketView:doGetAndClose()
	-- body
	
	RedPacketView.close()

	local _uid = self.m_redInfo.uid

	local function parseResultCallback(data, state)
		if not state then return end
		local RedPacketInfoDialog = require("app.dialog.RedPacketInfoDialog")
		RedPacketInfoDialog.new(data):push()
	end

	ActivityCenterBO.GrabRedBag(parseResultCallback, _uid)
end

function RedPacketView:setInfo(info)
	-- body
	self.m_redInfo = info
end

function RedPacketView.show(info)
	if not RedPacketView.instance_ then
		local scene = display.getRunningScene()
		if scene then
			RedPacketView.instance_ = RedPacketView.new():addTo(scene, 10001)
		end
	end

	if RedPacketView.instance_ then
		RedPacketView.instance_:setInfo(info)
	end
end

function RedPacketView:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/qianghongbao.pvr.ccz", IMAGE_ANIMATION .. "effect/qianghongbao.plist", IMAGE_ANIMATION .. "effect/qianghongbao.xml")
	RedPacketView.instance_ = nil
end



--
--
-- 静态
function RedPacketView.close(callback)
	if RedPacketView.instance_ then
		RedPacketView.instance_:removeSelf()
	end
	RedPacketView.instance_ = nil
end

return RedPacketView