--
-- Author: gf
-- Date: 2015-09-10 15:21:27
-- 探宝


local TipsAnyThingDialog = require("app.dialog.TipsAnyThingDialog")


local LotteryTreasureFightContentView = class("LotteryTreasureFightContentView", function (size)
	-- local node = display.newNode()
	local rect = cc.rect(0, 0, size.width, size.height)

	local node = display.newClippingRegionNode(rect)
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function LotteryTreasureFightContentView:ctor(size, coinCallback)
	self.m_coinCallback = coinCallback
	self:setContentSize(size)
	nodeTouchEventProtocol(self, function(event)
		return self:onTouch(event)
	end, cc.TOUCH_MODE_ALL_AT_ONCE, nil, false)
end

function LotteryTreasureFightContentView:onEnter()
	self.m_TouchState = false
	self.m_CouldFire = false
	self.m_CouldTouch = false
	self.m_QueueEnemyWaitingForKill = {}
	self.m_EnemyInKilling = nil
	self.m_EnemyKillingState = nil
	self.m_gunState = false
	self.m_CountingIndex = 1

	self.m_CouldContinueFire = false

	self.m_FireBegan = false
	self.m_FireStopTimer = 0

	self.m_viewY = 0

	self.m_cofirmState = false

	self.m_warEnemyList = {}
	self.m_fightPointID = 0

	local centerX = self:width() * 0.5
	local centerP = 300

	self.localInfo = {
		[1] = {ccp = cc.p(centerX - 215,centerP + 30), icon = {[1] = {offset = cc.p(-50,99), scale = 0.5, zp = cc.p(0,0)}, 	[2] = {offset = cc.p(60,50), scale = 0.8, zp = cc.p(0,0)}} },
		[2] = {ccp = cc.p(centerX - 109,centerP - 10), icon = {[1] = {offset = cc.p(-40 ,85), scale = 0.5, zp = cc.p(0,0)}, [2] =  {offset = cc.p(-24, -45), scale = 1, zp = cc.p(0,0)}} },
		[3] = {ccp = cc.p(centerX,centerP + 30),	   icon = {[1] = {offset = cc.p(0,56), scale = 0.48, zp = cc.p(0,0)}, 	[2] = {offset = cc.p(0,46), scale = 0.9, zp = cc.p(0,0)}} },
		[4] = {ccp = cc.p(centerX + 109,centerP - 10), icon = {[1] = {offset = cc.p(10,-16 ), scale = 1.3, zp = cc.p(30,0)}, [2] = {offset = cc.p(30 ,-28), scale = 1, zp = cc.p(0,0)}} },
		[5] = {ccp = cc.p(centerX + 215,centerP + 30), icon = {[1] = {offset = cc.p(-4,105), scale = 0.5, zp = cc.p(0,0)}, [2] = {offset = cc.p(50,45 ), scale = 0.6, zp = cc.p(0,0)}} },
	}

	-- -- 背景移动
	-- local function fireBg(_self, point)
	-- 	local pointX = centerX - point.x
	-- 	local pointY = centerP - point.y
	-- 	_self:runAction(cc.MoveTo:create(0.1, cc.p(pointX, pointY)))
	-- end

	-- -- 背景回归
	-- local function resetBg(_self)
	-- 	_self:runAction(cc.MoveTo:create(0.1, cc.p(0, 0)))
	-- end

	local warNode = display.newNode():addTo(self, 1)
	warNode:setPosition(0,0)
	-- warNode.fireFunc = fireBg
	-- warNode.resetFunc = resetBg
	self.m_warNode = warNode


	-- 背景
	local fightbg = display.newSprite(IMAGE_COMMON .. "lottery/bg_1.jpg"):addTo(warNode, 1)
	local width = fightbg:width()
	local height = fightbg:height()
	fightbg:setTextureRect(cc.rect(0,0,width ,height))
	fightbg:setAnchorPoint(cc.p(0.5,0))
	fightbg:setPosition(centerX , 0)
	self.m_bg = fightbg


	-- 战士节点 
	local fightNode = display.newNode():addTo(warNode, 2)
	fightNode:setPosition(0,0)
	self.m_fightNode = fightNode


	-- 沙包
	-- local shabaoEffect = armature_create("shabao"):addTo(self, 5)
	-- shabaoEffect:setPosition(centerX, 10)
	-- self.m_shabaoEffect = shabaoEffect

	-- 火花
	-- local fireEffect = armature_create("lvguang_shouji", 0, 0, function (movementType, movementID, armature)
	-- end):addTo(self,6)
	-- fireEffect:setPosition(centerX , 500 - 204)
	-- fireEffect:setVisible(false)
	-- fireEffect.count = 0


	-- 开火
	-- local function doPlay(armature, index, ischeck)
	-- 	local _ischeck = ischeck or false
	-- 	local curCounting = armature.counting
	-- 	-- print("ischeck!!", ischeck)
	-- 	-- if curCounting == 1 or _ischeck then
	-- 	if curCounting == 1 or curCounting == 6 or _ischeck then
	-- 		armature.counting = index
	-- 		armature:getAnimation():playWithIndex(armature.counting)
	-- 		return true
	-- 	end
	-- 	return false
	-- end

	-- -- 播放回调
	-- local function doEndAction(armature)
	-- 	if armature.counting == 0 then
	-- 		self.m_gunState = true
	-- 		armature:playFunc(1, true)
	-- 		self.m_CouldTouch = true
	-- 	elseif armature.counting == 1 then
	-- 		self.m_gunState = true
	-- 		self.m_CouldFire = true
	-- 	elseif armature.counting == 2 then
	-- 		self.m_gunState = false
	-- 		armature:playFunc(3, true)
	-- 		-- fireEffect:setVisible(true)
	-- 		-- fireEffect:getAnimation():playWithIndex(0)
	-- 		ManagerSound.playSound("gattling")
	-- 	elseif armature.counting == 3 then
	-- 		self:killEnemy()
	-- 		self.m_gunState = true
	-- 		-- armature:playFunc(4, true)
	-- 		-- 进入到特殊的等待状态
	-- 		armature.counting = 6
	-- 	elseif armature.counting == 4 then
	-- 		armature:playFunc(5, true)
	-- 		self.m_warNode:resetFunc()
	-- 	elseif armature.counting == 5 then
	-- 		armature:playFunc(1, true)
	-- 	end
	-- end

	-- --开枪
	-- local gunEffect = armature_create("cj_qiang", 0, 0, function (movementType, movementID, armature)
	-- 	if movementType == MovementEventType.COMPLETE then
	-- 		armature:endFunc()
	-- 	end
	-- end):addTo(self,7)
	-- gunEffect:setPosition(centerX,280)
	-- gunEffect.playFunc = doPlay
	-- gunEffect.endFunc = doEndAction
	-- -- gunEffect:playFunc(0)
	-- self.m_gunEffect = gunEffect

	-- 创建 大炮动画
	local sp_fighter_base = display.newSprite(IMAGE_COMMON .. "tank_base.png"):addTo(self,8)
	sp_fighter_base:setAnchorPoint(cc.p(0.5,0.5))
	sp_fighter_base:setPosition(centerX, self:height() * 0.1)
	self.sp_fighter_base = sp_fighter_base

	local sp_fighter = display.newSprite(IMAGE_COMMON .. "tank_body.png"):addTo(self,9)
	sp_fighter:setAnchorPoint(cc.p(0.5,0.2))
	sp_fighter:setPosition(centerX, -self:height() * 0.1)
	sp_fighter:setRotation(0)
	
	local effect = armature_create("ryxz_kaipao", sp_fighter:width() * 0.5 + 3,sp_fighter:height() + 2):addTo(sp_fighter)
	-- effect:getAnimation():playWithIndex(0)
	sp_fighter.fightEffect = effect

	self.m_sp_fighter = sp_fighter
	self.m_sFighterPoint = cc.p(sp_fighter:getPositionX(), sp_fighter:getPositionY())


	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
	self:scheduleUpdate()
end

function LotteryTreasureFightContentView:onEnterFrame(dt)
	if self.m_FireBegan then
		self.m_FireStopTimer = self.m_FireStopTimer + dt
		if self.m_FireStopTimer > 2 then
			-- 如果超过2s没有开枪
			-- if self.m_gunEffect and self.m_gunEffect.counting == 6 then
			-- 	self.m_CouldFire = false
			-- 	self.m_FireBegan = false
			-- 	self.m_FireStopTimer = 0
			-- 	-- 清空剩余的队列
			-- 	self.m_QueueEnemyWaitingForKill = {}
			-- 	self.m_EnemyInKilling = nil
			-- 	self.m_EnemyKillingState = nil

			-- 	if self.m_gunEffect then
			-- 		self.m_gunEffect:playFunc(4, true)
			-- 	end

			-- 	if LotteryMO.doLotteryTreasureChangeFightPoint then
			-- 		UserBO.triggerFightCheck()
			-- 		LotteryMO.doLotteryTreasureChangeFightPoint = false
			-- 	end
			-- end

			if self.m_sp_fighter then
				self.m_CouldFire = false
				self.m_FireBegan = false
				self.m_FireStopTimer = 0
				self.m_QueueEnemyWaitingForKill = {}
				self.m_EnemyInKilling = nil
				self.m_EnemyKillingState = nil

				if LotteryMO.doLotteryTreasureChangeFightPoint then
					UserBO.triggerFightCheck()
					LotteryMO.doLotteryTreasureChangeFightPoint = false
				end
			end
		end
	end
	-- gprint("self.m_fightPointID = " .. self.m_fightPointID)
	if self.m_fightPointID == 0 then
		if self.m_EnemyKillingState == nil or self.m_EnemyKillingState == "finished" or self.m_EnemyKillingState == "failed" then
			if self.m_EnemyInKilling == nil then
				if #self.m_QueueEnemyWaitingForKill > 0 then
					local v = self.m_QueueEnemyWaitingForKill[1]
					table.remove(self.m_QueueEnemyWaitingForKill, 1)

					self.m_EnemyInKilling = v
				end
			end

			-- local curCounting = nil
			-- if self.m_gunEffect then
			-- 	curCounting = self.m_gunEffect.counting
			-- end

			-- if self.m_EnemyInKilling ~= nil and (curCounting == 1 or curCounting == 6) then
			-- 	local pointid = self.m_EnemyInKilling.pointid
			-- 	local pointccp = self.m_EnemyInKilling.pointccp
			-- 	self.m_EnemyKillingState = "start"
			-- 	self:checkLottery(pointid, pointccp)
			-- end
			if self.m_EnemyInKilling ~= nil then
				local pointid = self.m_EnemyInKilling.pointid
				local pointccp = self.m_EnemyInKilling.pointccp
				self.m_EnemyKillingState = "start"
				self:checkLottery(pointid, pointccp)
			end
		end
	end
end

-- 切换
function LotteryTreasureFightContentView:chooseFight(index)
	-- body
	self.m_CountingIndex = index

	-- 需要消耗幸运币
	self:updateLuckyCoin()

	self:makeEnemys()

	-- self.m_gunEffect:playFunc(0, true)
	-- self.m_shabaoEffect:getAnimation():playWithIndex(0)

	self.m_TouchState = true
	self.m_CouldTouch = true

end

function LotteryTreasureFightContentView:makeEnemys()
	if self.m_fightNode then
		self.m_fightNode:removeAllChildren()
	end
	self.m_warEnemyList = {}
	local sc = 0.15

	for index = 1 , #self.localInfo do
		local info = self.localInfo[index]
		local iconInfo = info.icon[self.m_CountingIndex]
		-- local fighter = display.newSprite(IMAGE_COMMON .. "lottery/enemy_" .. self.m_CountingIndex .. "_" .. index .. ".png"):addTo(self.m_fightNode)
		local fighter = display.newSprite(IMAGE_COMMON .. "lottery/enemy_" .. index .. ".png"):addTo(self.m_fightNode)
		fighter:setScale(iconInfo.scale)
		fighter:setPosition(info.ccp.x + iconInfo.offset.x, info.ccp.y + iconInfo.offset.y)
		fighter.pointBox = cc.rect(fighter:getPositionX() - fighter:width() * 0.5 * iconInfo.scale + fighter:width() * sc * iconInfo.scale, 
									fighter:getPositionY() - fighter:height() * 0.5 * iconInfo.scale + fighter:height() * sc * iconInfo.scale, 
									fighter:width() * (1 - sc * 2) * iconInfo.scale, 
									fighter:height() * (1 - sc * 2) * iconInfo.scale)

		local zhunxin = armature_create("zhunxin", fighter:width() * 0.5 + iconInfo.zp.x, fighter:height() * 0.75 + iconInfo.zp.y, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
				armature:removeSelf()
			end
		end):addTo(fighter)
		zhunxin:setVisible(false)
		zhunxin:runAction(transition.sequence({cc.DelayTime:create(0.1 * index), cc.CallFuncN:create(function(sender)
			sender:setVisible(true)
			sender:getAnimation():playWithIndex(0)
		end)}))
		
		self.m_warEnemyList[index] = fighter
	end

end

-- 检查是否可点击
function LotteryTreasureFightContentView:CouldTouch()
	return self.m_CouldTouch
end

function LotteryTreasureFightContentView:TouchState()
	return self.m_TouchState
end

-- 更新幸运币
function LotteryTreasureFightContentView:updateLuckyCoin()
	if self.m_coinCallback then self.m_coinCallback(self.m_CountingIndex) end
	-- local haveCoin = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_LUCKY_COIN)
	-- local needCoin = LotteryMO.LOTTERY_TREASURE_NEED[self.m_CountingIndex]
	-- self.m_luckylabel:setString(haveCoin .. "/" .. needCoin)
end

-- 杀死敌人
function LotteryTreasureFightContentView:killEnemy()

	local function remake()
		local isState = true
		for k , v in pairs(self.m_warEnemyList) do
			if v:isVisible() then
				isState = false
				break
			end
		end
		if isState then
			self:makeEnemys()
		end
	end

	-- body
	local function over()
		self.m_fightPointID = 0
		self.m_CouldTouch = true

		self.m_EnemyKillingState = 'finished'
		self.m_EnemyInKilling = nil
	end

	local pointinfo = self.localInfo[self.m_fightPointID]
	local iconInfo = pointinfo.icon[self.m_CountingIndex]
	local item = self.m_warEnemyList[self.m_fightPointID]
	local itemHeight = item:height()
	local itemScale = item:getScale()

	local function result(data,ret)
		Loading.getInstance():unshow()
		UiUtil.showAwards(ret)
		self:updateLuckyCoin()
		-- armature_add("animation/effect/xiangzi.pvr.ccz", "animation/effect/xiangzi.plist", "animation/effect/xiangzi.xml")
		-- local boxEffect = armature_create("xiangzi", pointinfo.ccp.x + iconInfo.offset.x, pointinfo.ccp.y + iconInfo.offset.y - itemHeight * 0.5 * itemScale, function (movementType, movementID, armature)
			-- if movementType == MovementEventType.COMPLETE then
			-- 	armature:removeSelf()
			-- 	-- over()
			-- 	remake()
			-- end
		-- end):addTo(self.m_fightNode,7)

		-- boxEffect:setScale(iconInfo.scale)
		-- boxEffect:getAnimation():playWithIndex(0)
		-- local function removeS(sender)
			-- sender:removeSelf()
			remake()
		-- end
		-- boxEffect:runAction(transition.sequence({cc.DelayTime:create(1),cc.CallFuncN:create(removeS)}))
		over()
	end

	local function doLotteryTreasure(type, needCoin)
		Loading.getInstance():show()
		if self.m_isNewer then
			LotteryBO.GetGuideReward(result, self.m_isNewer)
		else
			LotteryBO.doLotteryTreasure(result, type, needCoin)
		end
		self.m_isNewer = nil
	end

	local function doLottery()
		-- self.m_CountingIndex == 1
		local needCoin = LotteryMO.LOTTERY_TREASURE_NEED[self.m_CountingIndex]
		local type = LotteryMO.LOTTERY_TYPE_TANBAO_1
		if self.m_CountingIndex == 2 then type = LotteryMO.LOTTERY_TYPE_TANBAO_3 end

		if type == LotteryMO.LOTTERY_TYPE_TANBAO_1 and LotteryMO.LotteryTreasureFree_ > 0 then
			needCoin = 0			
		end
		doLotteryTreasure(type,needCoin)
	end

	local item = self.m_warEnemyList[self.m_fightPointID]
	if item then
		item:setVisible(false)

		-- 创建爆炸动画 function (movementType, movementID, armature)
		local effect = armature_create("ryxz_baozha", pointinfo.ccp.x + iconInfo.offset.x, pointinfo.ccp.y + iconInfo.offset.y, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE then
            	armature:removeSelf()
            	-- _actionEnd()
            end
		end):addTo(self.m_fightNode, 8)
		effect:getAnimation():playWithIndex(0)

		doLottery()
	else
		over()
	end
end

-- 检查是否可以点击并进行
function LotteryTreasureFightContentView:checkLottery(key, point)
	self.m_fightPointID = key

	local function dosomething()
		if self.m_fightPointID > 0 then
			-- if self.m_gunEffect then
			-- 	self.m_CouldFire = self.m_gunEffect:playFunc(2)
			-- end

			--坦克开炮
			if self.m_sp_fighter then
				self.m_CouldFire = true
				local pointFrom = cc.p(self.m_sp_fighter:getPositionX(), self.m_sp_fighter:getPositionY())
				local pointTo = cc.p(point.x, point.y)
				local rodTo = math.deg(math.atan( (pointFrom.x - pointTo.x) / (pointFrom.y - pointTo.y)))
				_rotation = rodTo
				self.m_sp_fighter:runAction( transition.sequence({cc.EaseExponentialOut:create(cc.RotateTo:create(0.5, rodTo)), cc.CallFunc:create(function ()
					self.m_sp_fighter.fightEffect:getAnimation():playWithIndex(0)
					ManagerSound.playSound("kaipao_tank")
					self:killEnemy()
					self.m_gunState = true
				end)})  ) 
			end

			if self.m_CouldFire then
				-- self.m_CouldTouch = false

				-- if self.m_warNode then
				-- 	self.m_warNode:fireFunc(point)
				-- end

				-- 标志着正在处理中
				self.m_EnemyKillingState = 'ing'
				self.m_FireBegan = true
				return true
			else
				-- 当前处理失败了
				self.m_EnemyKillingState = 'failed'
				self.m_fightPointID = 0

				return false
			end
		end
	end

	local needCoin = LotteryMO.LOTTERY_TREASURE_NEED[self.m_CountingIndex]
	local type = LotteryMO.LOTTERY_TYPE_TANBAO_1
	if self.m_CountingIndex == 2 then type = LotteryMO.LOTTERY_TYPE_TANBAO_3 end

	-- 免费
	if type == LotteryMO.LOTTERY_TYPE_TANBAO_1 and LotteryMO.LotteryTreasureFree_ > 0 then
		dosomething()
	else
		local needBuyCoin = needCoin - UserMO.getResource(ITEM_KIND_PROP, PROP_ID_LUCKY_COIN)
		if needBuyCoin > 0 then
			--幸运币不够
			local price = PropMO.queryPropById(PROP_ID_LUCKY_COIN).price
			local cost = needBuyCoin * price
			if not self.m_cofirmState then -- UserMO.consumeConfirm then
				TipsAnyThingDialog.new(string.format(CommonText[563],cost,needBuyCoin), function()
						--判断金币

						if cost > UserMO.getResource(ITEM_KIND_COIN) then
							self.m_CouldTouch = true
							self.m_EnemyKillingState = 'failed'
							self.m_fightPointID = 0
							self.m_QueueEnemyWaitingForKill = {}
							self.m_EnemyInKilling = nil
							require("app.dialog.CoinTipDialog").new():push()
							return
						end

						Loading.getInstance():show()
						PropBO.asynBuyProp(function()
							Loading.getInstance():unshow()
							self:updateLuckyCoin()
							dosomething()
							end, PROP_ID_LUCKY_COIN, needBuyCoin)

					end, nil, function ()
						self.m_CouldTouch = true
						self.m_EnemyKillingState = 'failed'
						self.m_fightPointID = 0
						self.m_QueueEnemyWaitingForKill = {}
						self.m_EnemyInKilling = nil
					end):push()
			else
				if cost > UserMO.getResource(ITEM_KIND_COIN) then
					self.m_CouldTouch = true
					self.m_EnemyKillingState = 'failed'
					self.m_fightPointID = 0
					self.m_QueueEnemyWaitingForKill = {}
					self.m_EnemyInKilling = nil
					require("app.dialog.CoinTipDialog").new():push()
					return 
				end

				Loading.getInstance():show()
					PropBO.asynBuyProp(function()
						Loading.getInstance():unshow()
						self:updateLuckyCoin()
						dosomething()
						end, PROP_ID_LUCKY_COIN, needBuyCoin)
			end
		else
			-- 幸运币够
			dosomething()
		end
	end
end


function LotteryTreasureFightContentView:onTouch(event)
	if not self.m_TouchState then return false end
	if not self.m_CouldTouch then return false end
	-- if not self.m_gunState then return false end

	if event.name == "began" then
		return self:onTouchBegan(event)
	elseif event.name == "ended" then
		self:onTouchEnded(event)
		-- self.m_sp_fighter.fightEffect:getAnimation():playWithIndex(0)
	end
end

function LotteryTreasureFightContentView:onTouchBegan(event)
	return true
end

-- 
function LotteryTreasureFightContentView:onTouchEnded(event)

	local point = event.points["0"]

	-- self.m_fightPointID = 0
	local pointid = 0
	local pointccp

	local localPos = self.m_fightNode:convertToNodeSpace(cc.p(point.x, point.y))
	for k , v in pairs(self.m_warEnemyList) do
		local boundingRect = v:getBoundingBox()
		if v:isVisible() and boundingRect:containsPoint(localPos) then
			pointid = k
			pointccp = cc.p(v:x(), v:y())

			local isInQueue = false
			for i1, v1 in ipairs(self.m_QueueEnemyWaitingForKill) do
				if v1.pointid == k then
					isInQueue = true
					break
				end
			end

			if self.m_EnemyInKilling then
				if self.m_EnemyInKilling.pointid == k then
					isInQueue = true
				end
			end

			if isInQueue == false then
				table.insert(self.m_QueueEnemyWaitingForKill, {pointid=pointid, pointccp=pointccp})
			end

			self.m_FireStopTimer = 0

			self.m_CouldTouch = false
			break
		end
	end

end

function LotteryTreasureFightContentView:setPos(x, y)
	self.m_viewY = y
	self:setPosition(x, y)
end

function LotteryTreasureFightContentView:setCofirmState(state)
	self.m_cofirmState = state
end

function LotteryTreasureFightContentView:onNewer(pointid)
	self.m_CouldTouch = false
	self.m_isNewer = pointid - 1
	local item = self.m_warEnemyList[pointid]
	local ccp = cc.p(item:x(), item:y())
	self:checkLottery(pointid, ccp)
end

function LotteryTreasureFightContentView:fightAll(callBack)
	self:setTouchEnabled(false)
	local function doAllAni(result, ret)
		self:updateLuckyCoin()
		-- if self.m_gunEffect then
		-- 	self.m_CouldTouch = false
		-- 	self.m_gunEffect:runAction(transition.sequence({cc.MoveBy:create(0.3, cc.p(20, -280)),
		-- 		cc.DelayTime:create(1.3), cc.MoveBy:create(0.3, cc.p(-20, 280)),cc.DelayTime:create(0.2),
		-- 		cc.CallFunc:create(function()
		-- 			UiUtil.showAwards(ret)
		-- 			for k , v in pairs(self.m_warEnemyList) do
		-- 				v:setVisible(false)
		-- 			end
		-- 		 end), cc.DelayTime:create(0.7), cc.CallFunc:create(function()
		-- 			 	if callBack then callBack() end
		-- 			  	self:makeEnemys()
		-- 			  	self:setTouchEnabled(true)
		-- 			  	self.m_CouldTouch = true 
		-- 		  	end)
		-- 	}))

		-- 	self:performWithDelay(function ()
		-- 		local sld = armature_create("sld"):addTo(self, 10):pos(self:width() / 2 + 150, 0)
		-- 		sld:getAnimation():playWithIndex(0)
		-- 	end, 0.4)

		-- 	self:performWithDelay(function ()
		-- 		ManagerSound.playSound("boom")
		-- 	end, 1)
		-- end

		if self.m_sp_fighter then
			self.m_CouldTouch = false

			--火箭弹1
			local guiji_effect1 = armature_create("huojiandan_guiji", self:width() / 2 - 150, 400, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					local baozha_effect1 = armature_create("huojiandan_baozha", self:width() / 2 - 150, 400, function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
       		     			armature:removeSelf()
        	    		end
					end):addTo(self.m_fightNode, 8)
					baozha_effect1:getAnimation():playWithIndex(0)
       		     	armature:removeSelf()
        	    end
			end):addTo(self.m_fightNode, 8)

			--火箭弹2
			local guiji_effect2 = armature_create("huojiandan_guiji", self:width() / 2 + 150, 300, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					local baozha_effect2 = armature_create("huojiandan_baozha", self:width() / 2 + 150, 300, function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
       		     			armature:removeSelf()
        	    		end
					end):addTo(self.m_fightNode, 8)
					baozha_effect2:getAnimation():playWithIndex(0)
       		     	armature:removeSelf()
        	    end
			end):addTo(self.m_fightNode, 8)
			
			--火箭弹3
			local guiji_effect3 = armature_create("huojiandan_guiji", self:width() / 2 - 100, 350, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					local baozha_effect3 = armature_create("huojiandan_baozha", self:width() / 2 - 100, 350, function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
       		     			armature:removeSelf()
        	    		end
					end):addTo(self.m_fightNode, 8)
					baozha_effect3:getAnimation():playWithIndex(0)
       		     	armature:removeSelf()
        	    end
			end):addTo(self.m_fightNode, 8)

			--火箭弹4
			local guiji_effect4 = armature_create("huojiandan_guiji", self:width() / 2, 350, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					local baozha_effect4 = armature_create("huojiandan_baozha", self:width() / 2, 350, function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
       		     			armature:removeSelf()
        	    		end
					end):addTo(self.m_fightNode, 8)
					baozha_effect4:getAnimation():playWithIndex(0)
       		     	armature:removeSelf()
        	    end
			end):addTo(self.m_fightNode, 8)

			--火箭弹5
			local guiji_effect5 = armature_create("huojiandan_guiji", self:width() / 2 + 180, 400, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					local baozha_effect5 = armature_create("huojiandan_baozha", self:width() / 2 + 180, 400, function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
       		     			armature:removeSelf()
        	    		end
					end):addTo(self.m_fightNode, 8)
					baozha_effect5:getAnimation():playWithIndex(0)
       		     	armature:removeSelf()
        	    end
			end):addTo(self.m_fightNode, 8)

			self.m_sp_fighter:runAction(transition.sequence({
				cc.CallFunc:create(function()
					guiji_effect1:getAnimation():playWithIndex(0)
				 end),
				cc.DelayTime:create(0.1),
				cc.CallFunc:create(function()
					guiji_effect2:getAnimation():playWithIndex(0)
				 end),
				cc.CallFunc:create(function()
					guiji_effect4:getAnimation():playWithIndex(0)
				 end),
				cc.DelayTime:create(0.3),
				cc.CallFunc:create(function()
					guiji_effect3:getAnimation():playWithIndex(0)
				 end),
				cc.CallFunc:create(function()
					guiji_effect5:getAnimation():playWithIndex(0)
				 end),
				cc.DelayTime:create(1.5),
				cc.CallFunc:create(function()
					UiUtil.showAwards(ret)
					ManagerSound.playSound("huojiandan_baozha")
					for k , v in pairs(self.m_warEnemyList) do
						v:setVisible(false)
					end
				 end), cc.DelayTime:create(0.7), cc.CallFunc:create(function()
					 	if callBack then callBack() end
					  	self:makeEnemys()
					  	self:setTouchEnabled(true)
					  	self.m_CouldTouch = true 
				  	end)
			}))
		
		end
	end

	local function doLotteryAll()
		local lotteryCount = 0
		for k , v in pairs(self.m_warEnemyList) do
			if v:isVisible() then
				lotteryCount = lotteryCount + 1
			end
		end

		local type = LotteryMO.LOTTERY_TYPE_TANBAO_1
		if self.m_CountingIndex == 2 then type = LotteryMO.LOTTERY_TYPE_TANBAO_3 end
		local needCoin = LotteryMO.LOTTERY_TREASURE_NEED[self.m_CountingIndex] * lotteryCount

		if type == LotteryMO.LOTTERY_TYPE_TANBAO_1 and LotteryMO.LotteryTreasureFree_ > 0 then
			needCoin = LotteryMO.LOTTERY_TREASURE_NEED[self.m_CountingIndex] * (lotteryCount - 1)
		end
		
		local needBuyCoin = needCoin - UserMO.getResource(ITEM_KIND_PROP, PROP_ID_LUCKY_COIN)
		if needBuyCoin > 0 then
			--幸运币不够
			local price = PropMO.queryPropById(PROP_ID_LUCKY_COIN).price
			local cost = needBuyCoin * price
			if not self.m_cofirmState then -- UserMO.consumeConfirm then
				TipsAnyThingDialog.new(string.format(CommonText[563],cost,needBuyCoin), function()
						--判断金币
						if cost > UserMO.getResource(ITEM_KIND_COIN) then
							require("app.dialog.CoinTipDialog").new():push()
							self:setTouchEnabled(true)
							self.m_CouldTouch = true
							if callBack then callBack() end
							return
						end

						Loading.getInstance():show()
						PropBO.asynBuyProp(function()
							Loading.getInstance():unshow()
							self:updateLuckyCoin()

							LotteryBO.doLotteryTreasure(doAllAni, type, needCoin, lotteryCount)
						end, PROP_ID_LUCKY_COIN, needBuyCoin)
					end, nil, function () self:setTouchEnabled(true) self.m_CouldTouch = true if callBack then callBack() end end):push()
			else
				if cost > UserMO.getResource(ITEM_KIND_COIN) then
					require("app.dialog.CoinTipDialog").new():push()
					self:setTouchEnabled(true)
					self.m_CouldTouch = true
					if callBack then callBack() end
					return 
				end

				Loading.getInstance():show()
					PropBO.asynBuyProp(function()
						Loading.getInstance():unshow()
						self:updateLuckyCoin()

						LotteryBO.doLotteryTreasure(doAllAni, type, needCoin, lotteryCount)
					end, PROP_ID_LUCKY_COIN, needBuyCoin)
			end
		else
			-- 幸运币够
			LotteryBO.doLotteryTreasure(doAllAni, type, needCoin, lotteryCount)
		end
	end

	doLotteryAll()
end

function LotteryTreasureFightContentView:onExit()
	
end


function LotteryTreasureFightContentView:setBg(index)
	if self.m_bg then
		self.m_bg:removeSelf()
	end

	self.m_bg = display.newSprite(IMAGE_COMMON .. "lottery/bg_" .. index .. ".jpg"):addTo(self.m_warNode, 1)
	local width = self.m_bg:width()
	local height = self.m_bg:height()
	self.m_bg:setTextureRect(cc.rect(0,0,width ,height))
	self.m_bg:setAnchorPoint(cc.p(0.5,0))
	self.m_bg:setPosition(self:width() * 0.5 , 0)
end




















local LotteryTreasureView = class("LotteryTreasureView", UiNode)

function LotteryTreasureView:ctor(buildingId, isguild)
	LotteryTreasureView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_isguild = isguild or nil
end

function LotteryTreasureView:onEnter()
	LotteryTreasureView.super.onEnter(self)

	self:setTitle(CommonText[559][4])
	self:hasCoinButton(true)

	self.LotteryButtons = {}
	self.doLotteryStatus = false

	-- armature_add("animation/effect/cj_qiang.pvr.ccz", "animation/effect/cj_qiang.plist", "animation/effect/cj_qiang.xml")
	-- armature_add("animation/effect/shabao.pvr.ccz", "animation/effect/shabao.plist", "animation/effect/shabao.xml")
	-- armature_add("animation/effect/lvguang_shouji.pvr.ccz", "animation/effect/lvguang_shouji.plist", "animation/effect/lvguang_shouji.xml")
	-- armature_add("animation/effect/xiangzi.pvr.ccz", "animation/effect/xiangzi.plist", "animation/effect/xiangzi.xml")
	armature_add("animation/effect/zhunxin.pvr.ccz", "animation/effect/zhunxin.plist", "animation/effect/zhunxin.xml")

	armature_add("animation/effect/ui_lottery_btn.pvr.ccz", "animation/effect/ui_lottery_btn.plist", "animation/effect/ui_lottery_btn.xml")
	armature_add("animation/effect/sld.pvr.ccz", "animation/effect/sld.plist", "animation/effect/sld.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_kaipao.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_kaipao.plist", IMAGE_ANIMATION .. "effect/ryxz_kaipao.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_baozha.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_baozha.plist", IMAGE_ANIMATION .. "effect/ryxz_baozha.xml")
	armature_add(IMAGE_ANIMATION .. "effect/huojiandan_guiji.pvr.ccz", IMAGE_ANIMATION .. "effect/huojiandan_guiji.plist", IMAGE_ANIMATION .. "effect/huojiandan_guiji.xml")
	armature_add(IMAGE_ANIMATION .. "effect/huojiandan_baozha.pvr.ccz", IMAGE_ANIMATION .. "effect/huojiandan_baozha.plist", IMAGE_ANIMATION .. "effect/huojiandan_baozha.xml")

	local function createDelegate(container, index)
		-- self:showNormalUI(container)
		self:chooseFightContent(index)
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate( index )
		if self.m_fightview and not self.m_fightview:CouldTouch() then
			return false
		end
		if index == 2 then
			if UserMO.level_ < LotteryMO.treasure3OpenLv then
				Toast.show(string.format(CommonText[290], LotteryMO.treasure3OpenLv, CommonText[714]))
				return false
			end
		end
		return true
	end

	local pages = {CommonText[559][1],CommonText[559][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self:getBg(), 10)
	
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	local effect = CCArmature:create("ui_lottery_btn")
	effect:getAnimation():playWithIndex(0)
	effect:connectMovementEventSignal(function(movementType, movementID) end)
	effect:setPosition(pageView.m_noButtons[2]:getContentSize().width / 2, pageView.m_noButtons[2]:getContentSize().height / 2)
	pageView.m_noButtons[2]:addChild(effect)

	local effect1 = CCArmature:create("ui_lottery_btn")
	effect1:getAnimation():playWithIndex(0)
	effect1:setScaleY(1.1)
	effect1:connectMovementEventSignal(function(movementType, movementID) end)
	effect1:setPosition(pageView.m_yesButtons[2]:getContentSize().width / 2, pageView.m_yesButtons[2]:getContentSize().height / 2 + 3)
	pageView.m_yesButtons[2]:addChild(effect1)

	-- 奖励
	local awardbg = display.newSprite(IMAGE_COMMON .. "info_bg_131.png"):addTo(self:getBg(), 8)
	awardbg:setPosition(self:getBg():width() * 0.5, display.height - 240)
	self.m_awardbg = awardbg

	local infospbg = display.newSprite(IMAGE_COMMON .. "info_bg_132.png"):addTo(self:getBg(), 9)
	infospbg:setPosition(self:getBg():width() * 0.5, display.height - 175)

	local infoSP = display.newSprite(IMAGE_COMMON .. "awardword.png"):addTo(infospbg)
	infoSP:setPosition(infospbg:width() * 0.5, infospbg:height() * 0.5 )


	-- 幸运币图标
	local luckyCoinIcon = UiUtil.createItemView(ITEM_KIND_PROP,PROP_ID_LUCKY_COIN):addTo(self:getBg(), 10)
	luckyCoinIcon:setScale(0.5)
	luckyCoinIcon:setPosition(50,125)

	-- 幸运币数量
	local luckylabel = ui.newTTFLabel({text = "", font = G_FONT, size = 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(self:getBg(), 10)
	luckylabel:setPosition(luckyCoinIcon:x() + luckyCoinIcon:width() * 0.5 + 10, luckyCoinIcon:y())
	self.m_luckylabel = luckylabel


	-- 战斗画面
	-- local size = cc.size(self:getBg():width(), self:getBg():height() - 157)
	local size = cc.size(self:getBg():width(), 580)
	local fightview = LotteryTreasureFightContentView.new(size, handler(self, self.updateCoin)):addTo(self:getBg(), 5)
	fightview:setAnchorPoint(cc.p(0.5,0))
	fightview:setPos(self:getBg():width() * 0.5 , self:getBg():height() - 315 - 580)
	self.m_fightview = fightview


	


	local function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		if self.m_fightview and not self.m_fightview:CouldTouch() then
			sender:setChecked(sender.state)
			return 
		end
		sender.state = isChecked
		self.m_fightview:setCofirmState(isChecked)
	end

	local checkBox = CheckBox.new(nil, nil, onCheckedChanged):addTo(self:getBg(), 10)
	checkBox:setPosition(50 , 75)
	-- checkBox:setChecked(true)
	checkBox.state = false

	local checkLb = ui.newTTFLabel({text = CommonText[1796], font = G_FONT, size = 26, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(self:getBg(), 10)
	checkLb:setAnchorPoint(cc.p(0,0.5))
	checkLb:setPosition(80, 75)

	--一键刺激
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local quitBtn = MenuButton.new(normal, selected, nil, function (tag, sender)
		if self.m_fightview and self.m_fightview:CouldTouch() and not self.m_isnewers then --如果能点击,不能是新手引导进来 
			sender:setTouchEnabled(false)
			self.m_fightview:fightAll(function ()
				sender:setTouchEnabled(true)
			end)
		end
	end):addTo(self:getBg(), 10)
	quitBtn:setPosition(self:getBg():getContentSize().width- 110,75)
	quitBtn:setLabel("一键秒杀")

	-- 选择
	pageView:setPageIndex(1)
end

function LotteryTreasureView:updateCoin(index)
	local haveCoin = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_LUCKY_COIN)
	local needCoin = LotteryMO.LOTTERY_TREASURE_NEED[index]
	local str = haveCoin .. "/" .. needCoin
	if (not self.m_isnewers and not self.m_isguild) and self.m_pageView:getPageIndex() == 1 and LotteryMO.LotteryTreasureFree_ > 0 then
		str = CommonText[729]
	end
	self.m_luckylabel:setString(str)
	self.m_isnewers = nil
end


function LotteryTreasureView:chooseFightContent(index)
	if self.m_fightview then
		self.m_fightview:setBg(index)
	end

	-- 奖励
	if self.m_awardbg then
		self.m_awardbg:removeAllChildren()
	end
	local awardInfo = LotteryMO.getTreasure(index)
	local awards = json.decode(awardInfo.displayList)
	local size = #awards
	for i = 1 ,size do
		local award = awards[i]
		local kind = award[1]
		local id = award[2]
		local count = award[3]
		local view = UiUtil.createItemView(kind, id):addTo(self.m_awardbg)
		view:setPosition(self.m_awardbg:width() * 0.5 + CalculateX(size, i , view:width(), 1.1), self.m_awardbg:height() * 0.5 - 10)
		UiUtil.createItemDetailButton(view)
	end

	-- 战斗
	if self.m_fightview then
		self.m_fightview:chooseFight(index)
	end
end


function LotteryTreasureView:onExit()
	LotteryTreasureView.super.onExit(self)
	armature_remove("animation/effect/ui_lottery_btn.pvr.ccz", "animation/effect/ui_lottery_btn.plist", "animation/effect/ui_lottery_btn.xml")

	-- armature_remove("animation/effect/cj_qiang.pvr.ccz", "animation/effect/cj_qiang.plist", "animation/effect/cj_qiang.xml")
	-- armature_remove("animation/effect/shabao.pvr.ccz", "animation/effect/shabao.plist", "animation/effect/shabao.xml")
	-- armature_remove("animation/effect/lvguang_shouji.pvr.ccz", "animation/effect/lvguang_shouji.plist", "animation/effect/lvguang_shouji.xml")
	-- armature_remove("animation/effect/xiangzi.pvr.ccz", "animation/effect/xiangzi.plist", "animation/effect/xiangzi.xml")
	armature_remove("animation/effect/zhunxin.pvr.ccz", "animation/effect/zhunxin.plist", "animation/effect/zhunxin.xml")
	armature_remove("animation/effect/sld.pvr.ccz", "animation/effect/sld.plist", "animation/effect/sld.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_kaipao.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_kaipao.plist", IMAGE_ANIMATION .. "effect/ryxz_kaipao.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_baozha.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_baozha.plist", IMAGE_ANIMATION .. "effect/ryxz_baozha.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/huojiandan_guiji.pvr.ccz", IMAGE_ANIMATION .. "effect/huojiandan_guiji.plist", IMAGE_ANIMATION .. "effect/huojiandan_guiji.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/huojiandan_baozha.pvr.ccz", IMAGE_ANIMATION .. "effect/huojiandan_baozha.plist", IMAGE_ANIMATION .. "effect/huojiandan_baozha.xml")

	Notify.notify(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT)
end

function LotteryTreasureView:onNewerInterface(point)
	if self.m_fightview then
		self.m_fightview:onNewer(point)
	end
	self.m_isnewers = true
end


return LotteryTreasureView