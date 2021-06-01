
local TileMapInfo = class("TileMapInfo")

function TileMapInfo:ctor()
	self.mapSize_ = cc.size(0, 0)    -- 整个地图的x和y轴格子数量
	self.tileSize_ = cc.size(0, 0)   -- 地图中每个瓦片的大小，是像素大小
end

-- width和height是指地图中有在x和y轴有多少格子
function TileMapInfo:setMapSize(width, height)
	-- if width % 2 == 1 then
	-- 	error("TileMapInfo error width")
	-- end
	-- if height % 2 == 1 then
	-- 	error("TileMapInfo error height")
	-- end
	self.mapSize_ = cc.size(width, height)
end

function TileMapInfo:getMapSize()
	return self.mapSize_
end

function TileMapInfo:setTileSize(width, height)
	self.tileSize_ = cc.size(width, height)
end

function TileMapInfo:getTileSize()
	return self.tileSize_
end

return TileMapInfo