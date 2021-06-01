--
-- Author: xiaoxing
-- Date: 2017-04-15 16:16:18
--
local Dialog = require("app.dialog.Dialog")
local Minimap = class("Minimap", Dialog)
local TOUCHIN = 20 --点击范围
local TOUCHIN_TILE = 12
local MINIMAP_SIZE = 12
local BOX_WIDTH = 34
local BOX_HEIGHT = 18
local GAP_W = 5
local GAP_V = 5
local MINIMAP_PIC_W = 502
local MINIMAP_PIC_H = 246
local MARGIN_H = 10

local POISON = 0
local SAFE = 1
local WARNSAFE = 2

function Minimap:ctor()
	Minimap.super.ctor(self, "", UI_ENTER_NONE, {alpha = 180})
	self.poison_pos_ = nil
	self.m_safeAreaCenter = nil
	self.m_nextSafeAreaCenter = nil
end

function Minimap:onEnter()
	Minimap.super.onEnter(self)
	local bg = display.newSprite(IMAGE_COMMON.."minimap.png"):addTo(self):pos(display.width/2, display.height/2)
	self.m_bg = bg
	self:setOutOfBgClose(true)
	bg:setTouchEnabled(true)
	bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			local pos = bg:convertToNodeSpaceAR(cc.p(event.x,event.y))
			if math.abs(pos.x) > bg:width()/2 or math.abs(pos.y) > bg:height()/2 then
				self:pop()
				return
			end
			local touchin = true
			local tan = math.atan2(bg:height(), bg:width())*pos.x
			if pos.x < 0 and pos.y > 0 then
				if pos.y > tan + bg:height()/2 then
					touchin = false
				end
			elseif pos.x < 0 and pos.y < 0 then
				if pos.y < -tan - bg:height()/2 then
					touchin = false
				end
			elseif pos.x > 0 and pos.y > 0 then
				if pos.y > -tan + bg:height()/2 then
					touchin = false
				end
			elseif pos.x > 0 and pos.y < 0 then
				if pos.y < tan - bg:height()/2 then
					touchin = false
				end
			end
			if not touchin then
				self:pop()
			end
			pos.x = pos.x + bg:width()/2
			pos.y = pos.y + bg:height()/2
			for k,v in ipairs(self.pos_) do
				if math.abs(pos.x - v:x()) <= TOUCHIN and math.abs(pos.y - v:y()) <= TOUCHIN then
					local x,y = v.pos_.x,v.pos_.y
					self:pop()
					UiDirector.getTopUi():getCurContainer():onLocate(x,y)
					return
				end
			end
			if self.m_nextSafeAreaCenter then
				local v = self.m_nextSafeAreaCenter
				if math.abs(pos.x - v:x()) <= TOUCHIN_TILE and math.abs(pos.y - v:y()) <= TOUCHIN_TILE then
					local x,y = v.pos_.x,v.pos_.y
					self:pop()
					UiDirector.getTopUi():getCurContainer():onLocate(x,y)
					return
				end
			end
			if self.m_safeAreaCenter then
				local v = self.m_safeAreaCenter
				if math.abs(pos.x - v:x()) <= TOUCHIN_TILE and math.abs(pos.y - v:y()) <= TOUCHIN_TILE then
					local x,y = v.pos_.x,v.pos_.y
					self:pop()
					UiDirector.getTopUi():getCurContainer():onLocate(x,y)
					return
				end
			end
			if self.poison_pos_ then
				for k, v in ipairs(self.poison_pos_) do
					if math.abs(pos.x - v:x()) <= TOUCHIN_TILE and math.abs(pos.y - v:y()) <= TOUCHIN_TILE then
						local x,y = v.pos_.x,v.pos_.y
						self:pop()
						UiDirector.getTopUi():getCurContainer():onLocate(x,y)
						return
					end
				end
			end
		end
	end)
	self:showPos()
	if RoyaleSurviveMO.isActOpen() then
		self.poison_pos_ = nil
		self:showPoisonArea()
		self.m_hndSafeAreaUpdate = Notify.register(LOCAL_UPDATE_SAFE_AREA, handler(self, self.onSafeAreaUpdate))
		self.m_hndNextSafeAreaUpdate = Notify.register(LOCAL_NEXT_SAFE_AREA, handler(self, self.onNextSafeAreaUpdate))
	end
end

function Minimap:onExit()
	-- body
	if self.m_hndSafeAreaUpdate then
		Notify.unregister(self.m_hndSafeAreaUpdate)
		self.m_hndSafeAreaUpdate = nil
	end

	if self.m_hndNextSafeAreaUpdate then
		Notify.unregister(self.m_hndNextSafeAreaUpdate)
		self.m_hndNextSafeAreaUpdate = nil
	end
end

--转换真实坐标到小地图上显示
function Minimap:posToMiniPos(x,y)
	--先转成v字型坐标
	local l = math.sqrt(self.m_bg:height()*self.m_bg:height() + self.m_bg:width()*self.m_bg:width())/2
	local rate = WORLD_SIZE_WIDTH/l
	local r = math.deg(math.atan2(self.m_bg:height(), self.m_bg:width()))
	local tx = math.cos(math.rad(r))*(x/rate - y/rate) + self.m_bg:width()/2
	local ty = math.sin(math.rad(r))*(x/rate + y/rate)
	return tx,ty
end


-- function Minimap:miniPosToPos(tx, ty)
-- 	-- body
-- 	local l = math.sqrt(self.m_bg:height()*self.m_bg:height() + self.m_bg:width()*self.m_bg:width())/2
-- 	local rate = WORLD_SIZE_WIDTH/l
-- 	local r = math.deg(math.atan2(self.m_bg:height(), self.m_bg:width()))
-- 	local temp1 = (tx - self.m_bg:width()/2) / math.cos(math.rad(r)) 
-- 	local temp2 = ty / math.sin(math.rad(r))
-- 	local x = math.floor((temp1 + temp2) * rate / 2)
-- 	local y = math.floor((temp2 - temp1) * rate / 2)
-- 	return x, y
-- end

--显示各个位置
function Minimap:showPos()
	--自己的位置
	self.pos_ = {}
	local p = display.newSprite(IMAGE_COMMON .."icon_people.png")
		:addTo(self.m_bg,2,1):pos(self:posToMiniPos(WorldMO.pos_.x,WorldMO.pos_.y)):scale(0.8)
	p.pos_ = WorldMO.pos_
	-- table.insert(self.pos_, p)
	local ships = AirshipMO.queryShip()
	for k,v in ipairs(ships) do
		local p = WorldMO.decodePosition(v.pos)
		local data = AirshipBO.ships_ and AirshipBO.ships_[v.id]
		local pic = "ship_0.png"
		if data.occupy and data.occupy.partyId > 0 then
			if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 and data.occupy.partyId == PartyMO.partyData_.partyId then
				pic = "ship_1.png"
			else
				pic = "ship_2.png"
			end
		end
		local temp = display.newSprite(IMAGE_COMMON..pic)
			:addTo(self.m_bg,2,k+1):pos(self:posToMiniPos(p.x,p.y))
		temp.pos_ = p
		table.insert(self.pos_, temp)
	end
end

function Minimap:showPoisonArea()
	-- body
	-- local middleH = MINIMAP_SIZE / 2
	if self.poison_pos_ == nil then
		self.poison_pos_ = {}
		local unitAreaSize = WORLD_SIZE_WIDTH / MINIMAP_SIZE
		for i = 1, MINIMAP_SIZE do
			for j = 1, MINIMAP_SIZE do
				local pInfo = RoyaleSurviveMO.poisonPos[i][j]
				-- p:addTo(self.m_bg,0,1):pos(pInfo.miniPos.x, pInfo.miniPos.y)
				local p = {}
				p.pos_ = pInfo.pos_
				p.miniPos = pInfo.miniPos
				p.x = function ()
					-- body
					return p.miniPos.x
				end
				p.y = function ()
					-- body
					return p.miniPos.y
				end
				table.insert(self.poison_pos_, p)
			end
		end
	end

	-- 下一个安全区显示
	self.m_nextSafeAreaCircle = nil
	self.m_safeAreaLines = nil

	self.m_safeAreaCenter = nil
	self.m_nextSafeAreaCenter = nil

	self:updateNextSafeArea()
	self:updateSafeArea()
end

function Minimap:updateNextSafeArea()
	-- body
	if RoyaleSurviveMO.shrinkAllOver == false then
		if RoyaleSurviveMO.nextSafeAreaLeftBottomCorner and RoyaleSurviveMO.nextSafeAreaRightUpCorner then
			local n_xbegin = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.x
			local n_xend = RoyaleSurviveMO.nextSafeAreaRightUpCorner.x

			local n_ybegin = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.y
			local n_yend = RoyaleSurviveMO.nextSafeAreaRightUpCorner.y

			local midx = math.floor((n_xbegin + n_xend) * 0.5)
			local midy = math.floor((n_ybegin + n_yend) * 0.5)
			local areaPosX, areaPosY = self:posToMiniPos(midx, midy)
			local nextSafeAreaCircle = display.newSprite(IMAGE_COMMON.."minimap_next_safe_area.png"):addTo(self.m_bg,0,1):pos(areaPosX, areaPosY)
			nextSafeAreaCircle:setOpacity(150)

			local l = (n_xend - n_xbegin) * 0.5
			local rate = l / 600
			nextSafeAreaCircle:setScale(rate)
			self.m_nextSafeAreaCircle = nextSafeAreaCircle

			local p = {}
			p.pos_ = {x=midx, y=midy}
			p.miniPos = {x=areaPosX, y=areaPosY}
			p.x = function ()
				-- body
				return p.miniPos.x
			end
			p.y = function ()
				-- body
				return p.miniPos.y
			end
			self.m_nextSafeAreaCenter = p
		end
	end
end

function Minimap:updateSafeArea()
-- 当前安全区边界显示
	if RoyaleSurviveMO.safeAreaLeftBottomCorner and RoyaleSurviveMO.safeAreaRightUpCorner then
		self.m_safeAreaLines = {}

		local xbegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.x
		local xend = RoyaleSurviveMO.safeAreaRightUpCorner.x

		local ybegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.y
		local yend = RoyaleSurviveMO.safeAreaRightUpCorner.y

		-- 算出4条边的中点
		local midx = math.floor((xbegin + xend) * 0.5)
		local midy = math.floor((ybegin + yend) * 0.5)
		local ptLB = {x=xbegin, y=midy}
		local ptLT = {x=midx, y=yend}
		local ptRT = {x=xend, y=midy}
		local ptRB = {x=midx, y=ybegin}

		-- 算出四个边的长度
		local lenLB = yend - ybegin
		local lenLT = xend - xbegin
		local lenRT = lenLB
		local lenRB = lenLT

		-- 计算角度
		local l = math.sqrt(self.m_bg:height()*self.m_bg:height() + self.m_bg:width()*self.m_bg:width())/2
		local r = math.deg(math.atan2(self.m_bg:height(), self.m_bg:width()))

		local pts = {ptLB, ptLT, ptRT, ptRB}
		local lens = {lenLB, lenLT, lenRT, lenRB}
		local angles = {r, -r, r, -r}

		local unitPixels = 24
		local unitAreaSize = WORLD_SIZE_WIDTH / MINIMAP_SIZE

		for i, v in ipairs(pts) do
			local pt = v
			local miniPosX, miniPosY = self:posToMiniPos(v.x, v.y)
			local scale = lens[i] / unitAreaSize
			local rot = angles[i]

			local line = display.newScale9Sprite(IMAGE_COMMON.."minimap_safe_area_border.png"):addTo(self.m_bg,0,1):pos(miniPosX, miniPosY)
			line:setCapInsets(cc.rect(6, 0, 1, 5))
			local prefWidth = unitPixels * scale
			if prefWidth <= 18 then
				prefWidth = 18
			end
			line:setPreferredSize(cc.size(prefWidth, 5))
			line:setRotation(rot)
			line:setOpacity(200)
			table.insert(self.m_safeAreaLines, line)
		end

		local areaPosX, areaPosY = self:posToMiniPos(midx, midy)
		local p = {}
		p.pos_ = {x=midx, y=midy}
		p.miniPos = {x=areaPosX, y=areaPosY}
		p.x = function ()
			-- body
			return p.miniPos.x
		end
		p.y = function ()
			-- body
			return p.miniPos.y
		end
		self.m_safeAreaCenter = p
	end
end

function Minimap:onSafeAreaUpdate(event)
	-- body
	if self.m_safeAreaLines then
		for i, v in ipairs(self.m_safeAreaLines) do
			v:removeFromParentAndCleanup(true)
		end
		self.m_safeAreaLines = nil
	end

	self.m_safeAreaCenter = nil

	self:updateSafeArea()
end

function Minimap:onNextSafeAreaUpdate(event)
	-- body
	if self.m_nextSafeAreaCircle then
		self.m_nextSafeAreaCircle:removeFromParentAndCleanup(true)
		self.m_nextSafeAreaCircle = nil
	end

	self.m_nextSafeAreaCenter = nil

	self:updateNextSafeArea()
end

return Minimap