
local AwardsDialog = class("AwardsDialog", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function AwardsDialog:ctor(datas, endCallback, param)
	self.m_awards = datas
	self.m_endCallback = endCallback
	self.m_param = param
end

function AwardsDialog:onEnter()

	armature_add(IMAGE_ANIMATION .. "effect/sdbz_hdgx.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_hdgx.plist", IMAGE_ANIMATION .. "effect/sdbz_hdgx.xml") -- 1
	armature_add(IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.plist", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.xml") -- 1

	self:setContentSize(cc.size(display.width, display.height))

	self.touchLayer = display.newColorLayer(ccc4(0, 0, 0, 180)):addTo(self, -1)
	self.touchLayer:setContentSize(cc.size(display.width, display.height))
	self.touchLayer:setPosition(0, 0)

	nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, nil, nil, true)
	self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)

    self.m_node = display.newNode():addTo(self, 1)
    self.m_node:setPosition(0,0)

    self.curAwardIndex = 0
    self.isTouch = false

    self:showAward()
end

function AwardsDialog:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/sdbz_hdgx.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_hdgx.plist", IMAGE_ANIMATION .. "effect/sdbz_hdgx.xml") -- 1
	armature_remove(IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.pvr.ccz", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.plist", IMAGE_ANIMATION .. "effect/sdbz_jiangli_bgguang.xml") -- 1
end

function AwardsDialog:showAward()
	self.curAwardIndex = self.curAwardIndex + 1

	if self.m_node then
		self.m_node:stopAllActions()
		self.m_node:removeAllChildren()
	end

	if not self.m_awards then
		self:close()
		return
	end

	local heightAdd = 0
	if self.m_param then
		if table.isexist(self.m_param,"hadd") then
			heightAdd = self.m_param.hadd
		end
	end

	local award = self.m_awards[self.curAwardIndex]
	if award then
		local kind = table.isexist(award, "type") and award.type or award.kind
		local id = award.id
		local count = award.count
		-- 奖励
		local item = UiUtil.createItemView(kind, id, {count = count}):addTo(self.m_node, 2)
		item:setPosition(display.cx, display.cy + heightAdd)
		item:setScale(0.1)
		UiUtil.createItemDetailButton(item)

		local info = UserMO.getResourceData(kind, id)
		local name = ui.newTTFLabel({text = info.name , font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER,
			 color = COLOR[info.quality]}):addTo(item)
		name:setPosition(item:width() * 0.5, -20)

		local effect2 = armature_create("sdbz_jiangli_bgguang", display.cx,display.cy + heightAdd):addTo(self.m_node,1)

		-- 
		local effect = armature_create("sdbz_hdgx", display.cx,display.cy + heightAdd, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				effect2:getAnimation():playWithIndex(0)
				armature:removeSelf()
			end
		end):addTo(self.m_node,3)
		effect:getAnimation():playWithIndex(0)

		-- 播放一个动画
		item:runAction(transition.sequence({cc.ScaleTo:create(0.2, 1),cc.CallFuncN:create(function ()
			self.isTouch = true
		end)}))
	else
		self:close()
	end
end

function AwardsDialog:onTouch(event)
	if event.name == "ended" then
		if self.m_node then
			if self.isTouch then
				self.isTouch = false
				self:showAward()
			end
			return true
		end
		self:close()
	end
	return true
end

function AwardsDialog:close()
	UiDirector.pop()
	if self.m_endCallback then self.m_endCallback() end
end

function AwardsDialog:push()
	UiDirector.push(self)
	return self
end

function AwardsDialog:getUiName()
	return self.__cname
end

return AwardsDialog