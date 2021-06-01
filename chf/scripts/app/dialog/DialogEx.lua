--
--
-- 弹出框 扩展
--
-- MYS

local DialogEx = class("DialogEx", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function DialogEx:ctor(parent)
	self.m_parent = parent
	self.m_scenerySpriteFrameName = nil
	self.m_viewbg = nil
	self.m_outOfBgClose = false
	self.m_inOfBgClose = false
end

function DialogEx:onEnter()
	nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, nil, nil, true)
	self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)

    local opacity = 125

	if self.m_parent then
		opacity = 255 * 0.7

		-- local crt = CCRenderTexture:create(display.width, display.height)
		-- crt:begin()
  --       self.m_parent:visit()
  --       crt:endToLua()
  --       local m_spriteFrame = crt:getSprite():getDisplayFrame()
  --       self.m_scenerySpriteFrameName = "de_ssfn_" .. self.__cname
  --       CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFrame(m_spriteFrame, self.m_scenerySpriteFrameName)
		-- self.sceneryLayer = CCFilteredSpriteWithOne:createWithSpriteFrame(m_spriteFrame):addTo(self, -2)
		-- self.sceneryLayer:setPosition(display.cx, display.cy)
		-- self.sceneryLayer:setScaleY(-1)
		-- self.sceneryLayer:setFilter(CCGaussianHBlurFilter:create(2))

		-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFrame(m_spriteFrame, self.m_scenerySpriteFrameName)
		-- self.sceneryLayer = CCFilteredSpriteWithMulti:createWithSpriteFrame(m_spriteFrame):addTo(self, -2)
		-- self.sceneryLayer:setPosition(display.cx, display.cy)
		-- self.sceneryLayer:setScaleY(-1)
		--  local arr = CCArray:create()
		--  arr:addObject(CCGaussianVBlurFilter:create(2))
		--  arr:addObject(CCGaussianHBlurFilter:create(2))
		-- self.sceneryLayer:setFilters(arr)


        -- crt:removeSelf()

	end


	local sceneryBgLayer = display.newColorLayer(ccc4(0, 0, 0, opacity)):addTo(self, -1)
	sceneryBgLayer:setContentSize(cc.size(display.width, display.height))
	sceneryBgLayer:setPosition(0, 0)

	
end

function DialogEx:onTouch(event)
	if event.name == "ended" then

		local function ptInNode(node)
			local point = node:getParent():convertToNodeSpace(cc.p(event.x, event.y))
			local rect = node:getBoundingBox()
			if cc.rectContainsPoint(rect, point) then
				return true
			else
				return false
			end
		end

		if self.m_viewbg then
			if self.m_outOfBgClose and not ptInNode(self.m_viewbg) then
				self:close()
			elseif self.m_inOfBgClose and ptInNode(self.m_viewbg) then
				self:close()
			end
			return true
		end
		self:close()
	end
	return true
end

function DialogEx:onExit()
	-- if self.m_scenerySpriteFrameName and self.m_parent and self.sceneryLayer then
	-- 	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFrameByName(self.m_scenerySpriteFrameName)
	-- end
end

function DialogEx:close(callback)
	UiDirector.popName(callback, self:getUiName())
end

function DialogEx:push()
	UiDirector.push(self)
	return self
end

function DialogEx:getUiName()
	return self.__cname
end

return DialogEx