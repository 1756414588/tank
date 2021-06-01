
local PoisonLayer = class("PoisonLayer", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)


function PoisonLayer:ctor(tileMap)
	armature_add("animation/royale/poison.pvr.ccz", "animation/royale/poison.plist", "animation/royale/poison.xml")
	armature_add("animation/royale/poison_border.pvr.ccz", "animation/royale/poison_border.plist", "animation/royale/poison_border.xml")
	armature_add("animation/royale/poison_border1.pvr.ccz", "animation/royale/poison_border1.plist", "animation/royale/poison_border1.xml")
	self.layerName_ = "PoisonLayer1"

	self.layerSize_ = tileMap.mapSize_
	self.tileSize_  = tileMap.tileSize_

	local size = cc.size(self.layerSize_.width * self.tileSize_.width, self.layerSize_.height * self.tileSize_.height)
	self:setContentSize(size)

	self.batchNode1_ = display.newBatchNode("image/world/tile_poison.png", 50):addTo(self, -GAME_INVALID_VALUE)
	self.batchContainer_ = {}

	-- self.poisonFlags = {}
	self.viewNode_ = display.newNode():addTo(self)
	self.viewContainer_ = {}

	self.m_tickCount = 0
end

function PoisonLayer:onEnter()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
	self:scheduleUpdate_()
	self.m_tickCount = 0
end

function PoisonLayer:onEnterFrame(dt)
	-- 每隔两分钟刷一下状态
	-- self.m_tickCount = self.m_tickCount + dt
	-- if self.m_tickCount > 120 then
	--     self.m_tickCount = 0
	-- end
end

function PoisonLayer:onExit()
	armature_remove("animation/royale/poison_border.pvr.ccz", "animation/royale/poison_border.plist", "animation/royale/poison_border.xml")
	armature_remove("animation/royale/poison_border1.pvr.ccz", "animation/royale/poison_border1.plist", "animation/royale/poison_border1.xml")
	armature_remove("animation/royale/poison.pvr.ccz", "animation/royale/poison.plist", "animation/royale/poison.xml")
end

function PoisonLayer:getPositionAt(tilePos)
	return cc.p(self.tileSize_.width / 2 * (self.layerSize_.width + tilePos.x - tilePos.y),
			self.tileSize_.height / 2 * (tilePos.x + tilePos.y))
end

function PoisonLayer:getTilePositionAt(pos)
	local x = pos.x - self:getContentSize().width / 2
	local y = pos.y

	local wx = x / self.tileSize_.width
	local wy = y / self.tileSize_.height

	return cc.p(math.floor(wx + wy), math.floor(-wx + wy))
end

function PoisonLayer:getVertexZAt(tilePos)
	local maxZ = self.layerSize_.width + self.layerSize_.height
	return (maxZ - (tilePos.x + tilePos.y))
end

function PoisonLayer:getTileIndexByPos(tilePos)
	return tilePos.x + tilePos.y * self.layerSize_.width
end

function PoisonLayer:getPosByTileIndex(tileIndex)
	local pos = tileIndex
	local x = pos % self.layerSize_.width
	local y = math.floor(pos / self.layerSize_.width)
	return cc.p(x, y)
end

function PoisonLayer:createTileAt(tilePos)
	local position = self:getPositionAt(tilePos)
	local order = self:getVertexZAt(tilePos)

	local land = display.newSprite(self.batchNode1_:getTexture(), position.x, position.y):addTo(self.batchNode1_)
	land:setAnchorPoint(0.5, 0)
	land:setZOrder(order)
	land:setOpacity(0)

	if not self.batchContainer_[tilePos.x] then self.batchContainer_[tilePos.x] = {} end
	self.batchContainer_[tilePos.x][tilePos.y] = land

	local node = display.newNode():addTo(self.viewNode_, order)
	node:setPosition(position.x, position.y)
	node.load = false  -- 刚创建还没有加载

	if not self.viewContainer_[tilePos.x] then self.viewContainer_[tilePos.x] = {} end
	self.viewContainer_[tilePos.x][tilePos.y] = node
end

function PoisonLayer:hasTileAt(tilePos)
	if not self.batchContainer_[tilePos.x] then return false end

	if self.batchContainer_[tilePos.x][tilePos.y] then return true
	else return false end
end

function PoisonLayer:removeTileAt(tilePos)
	if not self.batchContainer_[tilePos.x] then return end

	local tile = self.batchContainer_[tilePos.x][tilePos.y]
	if tile then
		tile:removeSelf()
		self.batchContainer_[tilePos.x][tilePos.y] = nil
	end

	if self.viewContainer_[tilePos.x] then
		local node = self.viewContainer_[tilePos.x][tilePos.y]
		if node then
			node:stopAllActions()
			node:removeSelf()
			self.viewContainer_[tilePos.x][tilePos.y] = nil
		end
	end

	-- if self.poisonFlags[tilePos.x] then
	--     self.poisonFlags[tilePos.x][tilePos.y] = nil
	-- end
end


function PoisonLayer:hasLoadAt(tilePos)
	if not self.viewContainer_[tilePos.x] then
		gprint("error TileLayer hasLoadAt")
		return false
	end
	local node = self.viewContainer_[tilePos.x][tilePos.y]
	if not node then return false end

	return node.load
end

function PoisonLayer:loadTileAt(tilePos)
	local safe = RoyaleSurviveMO.IsInSafeArea(tilePos)

	if not self.viewContainer_[tilePos.x] then 
		gprint("error TileLayer loadTileAt 11")
		return
	end

	local node = self.viewContainer_[tilePos.x][tilePos.y]

	if not node then 
		gprint("error TileLayer loadTileAt 22")
		return
	end

	node.data_ = not safe

	if not safe then
		local offsetX = 0
		local offsetY = 100
		local view = armature_create("poison", offsetX, offsetY)
		view:addTo(node)
		view:getAnimation():playWithIndex(0)
		view:setOpacity(128)
		node.view_ = view
		node.load = true
	else
		local areaType = RoyaleSurviveMO.GetAreaType(tilePos)
		if areaType == RoyaleSurviveMO.AREA_SAFE_CORNER_B or areaType == RoyaleSurviveMO.AREA_SAFE_CORNER_R or
			areaType == RoyaleSurviveMO.AREA_SAFE_CORNER_T or areaType == RoyaleSurviveMO.AREA_SAFE_CORNER_L then
			local offsetX = 0
			local offsetY = 0

			local offsetX1 = 0
			local offsetY1 = 0

			if areaType == RoyaleSurviveMO.AREA_SAFE_CORNER_B then
				offsetX = -70
				offsetY = 35
				offsetX1 = 80
				offsetY1 = 50
			elseif areaType == RoyaleSurviveMO.AREA_SAFE_CORNER_T then
				offsetX = 85
				offsetY = 120
				offsetX1 = -80
				offsetY1 = 120
			elseif areaType == RoyaleSurviveMO.AREA_SAFE_CORNER_R then
				offsetX = 85
				offsetY = 120
				offsetX1 = 80
				offsetY1 = 50
			elseif areaType == RoyaleSurviveMO.AREA_SAFE_CORNER_L then
				offsetX = -70
				offsetY = 35
				offsetX1 = -80
				offsetY1 = 120
			end

			local view = armature_create("poison_border", offsetX, offsetY)
			view:addTo(node)
			view:getAnimation():playWithIndex(0)
			node.view_ = view

			local view1 = armature_create("poison_border1", offsetX1, offsetY1)
			view1:addTo(node)
			view1:getAnimation():playWithIndex(0)
			node.view1_ = view1

			node.load = true
		elseif areaType == RoyaleSurviveMO.AREA_SAFE_BORDER_1 or areaType == RoyaleSurviveMO.AREA_SAFE_BORDER_2 then
			local offsetX = 0
			local offsetY = 0
			if areaType == RoyaleSurviveMO.AREA_SAFE_BORDER_1 then
				offsetX = -70
				offsetY = 35
			else
				offsetX = 85
				offsetY = 120
			end
			local view = armature_create("poison_border", offsetX, offsetY)
			view:addTo(node)
			view:getAnimation():playWithIndex(0)
			node.view_ = view
			node.load = true
		elseif areaType == RoyaleSurviveMO.AREA_SAFE_BORDER1_1 or areaType == RoyaleSurviveMO.AREA_SAFE_BORDER1_2 then
			local offsetX = 0
			local offsetY = 0
			if areaType == RoyaleSurviveMO.AREA_SAFE_BORDER1_1 then
				offsetX = 80
				offsetY = 50
			else
				offsetX = -80
				offsetY = 120
			end
			local view = armature_create("poison_border1", offsetX, offsetY)
			view:addTo(node)
			view:getAnimation():playWithIndex(0)
			node.view_ = view
			node.load = true
		elseif areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_B or areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_R or
			areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_T or areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_L then
			local offsetX = 0
			local offsetY = 0

			local offsetX1 = 0
			local offsetY1 = 0

			if areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_B then
				offsetX = -75
				offsetY = 40
				offsetX1 = 80
				offsetY1 = 40
			elseif areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_T then
				offsetX = 75
				offsetY = 125
				offsetX1 = -75
				offsetY1 = 125
			elseif areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_R then
				offsetX = 75
				offsetY = 125
				offsetX1 = 80
				offsetY1 = 40
			elseif areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_L then
				offsetX = -70
				offsetY = 40
				offsetX1 = -75
				offsetY1 = 125
			end

			local view = display.newSprite("image/world/border.png", offsetX, offsetY)
			view:addTo(node)
			node.view_ = view

			local view1 = display.newSprite("image/world/border1.png", offsetX1, offsetY1)
			view1:addTo(node)
			node.view1_ = view1

			node.load = true
		elseif areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER_1 or areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER_2 then
			local offsetX = 0
			local offsetY = 0
			if areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER_1 then
				offsetX = -75
				offsetY = 40
			else
				offsetX = 75
				offsetY = 125
			end
			local view = display.newSprite("image/world/border.png", offsetX, offsetY)
			view:addTo(node)
			node.view_ = view
			node.load = true
		elseif areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER1_1 or areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER1_2 then
			local offsetX = 0
			local offsetY = 0
			if areaType == RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER1_1 then
				offsetX = 80
				offsetY = 40
			else
				offsetX = -75
				offsetY = 125
			end
			local view = display.newSprite("image/world/border1.png", offsetX, offsetY)
			view:addTo(node)
			node.view_ = view
			node.load = true
		end
	end

end

function PoisonLayer:reloadTileAt(tilePos)
	if not self.viewContainer_[tilePos.x] then error("TileLayer reloadTileAt AA") end

	local node = self.viewContainer_[tilePos.x][tilePos.y]

	if not node then error("TileLayer reloadTileAt BB") end

	node:stopAllActions()
	node:removeAllChildren()
	node.view_ = nil
	node.view1_ = nil
	node.load = false

	self:loadTileAt(tilePos)
end

function PoisonLayer:compareView(tilePos)
	local safe = RoyaleSurviveMO.IsInSafeArea(tilePos)
	local poison = not safe

	if tilePos.x == WorldMO.pos_.x and tilePos.y == WorldMO.pos_.y then return true end  -- 玩家自己

	local node = self.viewContainer_[tilePos.x][tilePos.y]

	if not node.view_ then return false end

	return node.data_ == poison
end

return PoisonLayer
