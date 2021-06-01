--
-- Author: Gss
-- Date: 2018-07-27 11:50:04
--  活跃宝箱奖励展示

local ActiveBoxAwardsDialog = class("ActiveBoxAwardsDialog", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function ActiveBoxAwardsDialog:ctor(data, ret, endCallback, param)
	self.m_data = data
	self.m_endCallback = endCallback
	self.m_param = param
	self.ret = ret
end

function ActiveBoxAwardsDialog:onEnter()
	self:setContentSize(cc.size(display.width, display.height))
	self.touchLayer = display.newColorLayer(ccc4(0, 0, 0, 180)):addTo(self, -1)
	self.touchLayer:setContentSize(cc.size(display.width, display.height))
	self.touchLayer:setPosition(0, 0)

	nodeTouchEventProtocol(self, function(event) return self:onTouch(event) end, nil, nil, true)
	self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)

    armature_add(IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.plist", IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.xml")

    self.m_node = display.newNode():addTo(self, 1)
    self.m_node:setPosition(0,self:height() / 2)

    self.isShow = false
    self.myindex = 0
    self.effectShow_ = nil
    self.hasTouch = false
    self:show()
end

function ActiveBoxAwardsDialog:show()
	self.myindex = self.myindex +1
	local itemView = UiUtil.createItemView(self.m_data[self.myindex].type,self.m_data[self.myindex].id,{count = self.m_data[self.myindex].count}):addTo(self.m_node,2)
	local resData = UserMO.getResourceData(self.m_data[self.myindex].type,self.m_data[self.myindex].id)
	local name = ui.newTTFLabel({text = resData.name.."*"..self.m_data[self.myindex].count, font = G_FONT, size = 14, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_node,2)
	name:setVisible(false)
	self.curName = name
	if #self.m_data == 1 then
		itemView:setPosition(display.cx,self.m_node:height() / 2)
		name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
	else
		local x = 80
		if #self.m_data == 2 then
			x = display.cx - itemView:width() / 2
		elseif #self.m_data == 3 then
			x = display.cx - itemView:width() / 2 - itemView:width() + 30
		elseif #self.m_data == 4 then
			x = display.cx - itemView:width() * 2 + 40
		end
		if self.myindex <= 5 then
			itemView:setPosition((self.myindex - 1) * 110 + x,self.m_node:height() - itemView:height() / 2 + 60)
			name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
		else
			itemView:setPosition((self.myindex - 6) * 110 + x,self.m_node:height() - itemView:height() / 2 - 60)
			name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
		end
	end
	itemView:setScale(0)

	local l1 = cc.CallFuncN:create(function(sender) 
		if not self.effectShow_ then
			local armature = armature_create("cuilian_huode_guangxiao", itemView:x(), itemView:y(), function(movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:setVisible(false)
						self.curName:setVisible(true)
						if self.myindex < #self.m_data then
							if self.hasTouch then
								self.isShow = false
								self.m_node:removeAllChildren()
								self:showAwards() 
								return
							end
							self:show()
							self.isShow = true
						else
							self:performWithDelay(function ()
								self.isShow = false
								UiUtil.showAwards(self.ret)
							end, 0.1)
						end
					end
				end):addTo(self.m_node,999)
			self.effectShow_ = armature
		end
		local armature = self.effectShow_
		armature:setPosition(itemView:x(), itemView:y())
		armature:setVisible(true)
		armature:setScale(0.6)
		armature:getAnimation():playWithIndex(0)
		end)
	local l2 = cc.ScaleTo:create(0.3,0.8)
	local spwArray = cc.Array:create()
	spwArray:addObject(l1)
	spwArray:addObject(l2)
	local l3 = cc.Spawn:create(spwArray)
	itemView:runAction(l3)
end

function ActiveBoxAwardsDialog:showAwards()
	UiUtil.showAwards(self.ret)
	for index =1,#self.m_data do
		local itemView = UiUtil.createItemView(self.m_data[index].type,self.m_data[index].id,{count = self.m_data[index].count}):addTo(self.m_node,2)
		local resData = UserMO.getResourceData(self.m_data[index].type,self.m_data[index].id)
		local name = ui.newTTFLabel({text = resData.name.."*"..self.m_data[index].count, font = G_FONT, size = 14, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_node,2)
		itemView:setScale(0.8)

		if #self.m_data == 1 then
			itemView:setPosition(self.m_node:width() / 2,self.m_node:height() / 2)
			name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
		else
			local x = 80
			if #self.m_data == 2 then
				x = display.cx - itemView:width() / 2
			elseif #self.m_data == 3 then
				x = display.cx - itemView:width() / 2 - itemView:width() + 30
			elseif #self.m_data == 4 then
				x = display.cx - itemView:width() * 2 + 40
			end
			if index <= 5 then
				itemView:setPosition((index - 1) * 110 + x,self.m_node:height() - itemView:height() / 2 + 60)
				name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
			else
				itemView:setPosition((index - 6) * 110 + x,self.m_node:height() - itemView:height() / 2 - 60)
				name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
			end
		end
	end
end

function ActiveBoxAwardsDialog:onTouch(event)
	if event.name == "ended" then
		if self.isShow then
			self.hasTouch = true
			
		else
			self:close()
		end
	end
	return true
end

function ActiveBoxAwardsDialog:close()
	UiDirector.pop()
	if self.m_endCallback then self.m_endCallback() end
end

function ActiveBoxAwardsDialog:push()
	UiDirector.push(self)
	return self
end

function ActiveBoxAwardsDialog:getUiName()
	return self.__cname
end

function ActiveBoxAwardsDialog:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.plist", IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.xml")
end

return ActiveBoxAwardsDialog
