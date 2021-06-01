------------------------------------------------------------------------------
-- 扫荡结果tableview
------------------------------------------------------------------------------

local WipeTableView = class("WipeTableView", TableView)

-- isWaiing:是否等待新的一次扫荡结果中。如果ture，则表示wipeResult是之前的扫荡结果，还需要显示现在的扫荡中信息
function WipeTableView:ctor(size, wipeResult, isWaiting)
	WipeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 195)
	self.m_wipeResult = wipeResult
	self.m_isWaiting = isWaiting
end

function WipeTableView:numberOfCells()
	if self.m_isWaiting then return #self.m_wipeResult + 1
	else return #self.m_wipeResult end
end

function WipeTableView:cellSizeForIndex(index)
	if index > #self.m_wipeResult then return cc.size(self:getViewSize().width, 150)
	else
		local haust = self.m_wipeResult[index].haust
		if haust and table.nums(haust) > 0 then
			local line = math.ceil(table.nums(haust) / 2)
			return cc.size(self:getViewSize().width, 280 + line * 120)
		else
			return cc.size(self:getViewSize().width, 280)
		end
	end
end

function WipeTableView:createCellAtIndex(cell, index)
	local cellSize = self:cellSizeForIndex(index)

	gprint("WipeTableView index:", index)
	WipeTableView.super.createCellAtIndex(self, cell, index)

	-- local b = display.newScale9Sprite(IMAGE_COMMON .. "btn_14_normal.png"):addTo(cell)
	-- b:setPreferredSize(cc.size(cellSize.width, cellSize.height - 8))
	-- b:setPosition(cellSize.width / 2, cellSize.height / 2)

	-- 第x次扫荡
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, cellSize.height - 40)
	local title = ui.newTTFLabel({text = CommonText[237][1] .. index .. CommonText[237][3] .. CommonText[35], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	if index > #self.m_wipeResult then  -- 显示当前正在努力扫荡中
		local label = ui.newTTFLabel({text = CommonText[299][4], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = bg:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	else
		-- 获得物品
		local label = ui.newTTFLabel({text = CommonText[286] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = bg:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local awards = self.m_wipeResult[index].award

		if awards then
			for index = 1, #awards do
				local award = awards[index]
				gdump(award, "[WipeCombatDialog] award")

				local itemView = UiUtil.createItemView(award.kind, award.id):addTo(cell)
				itemView:setScale(0.9)
				itemView:setPosition(30 + (index - 0.5) * 104, cellSize.height - 140)

				local resData = UserMO.getResourceData(award.kind, award.id)
				local name = ui.newTTFLabel({text = resData.name .. "*" .. UiUtil.strNumSimplify(award.count), font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				if award.kind == ITEM_KIND_TACTIC or award.kind == ITEM_KIND_TACTIC_PIECE then
					name:setColor(COLOR[resData.quality + 1])
				end
			end
		end

		local stoneData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)

		-- 修理扣除宝石
		local label = ui.newTTFLabel({text = CommonText[287] .. stoneData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = cellSize.height - 230, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local itemView = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(cell)
		itemView:setPosition(label:getPositionX() + label:getContentSize().width + itemView:getBoundingBox().size.width / 2, label:getPositionY())

		local num = ui.newTTFLabel({text = UiUtil.strNumSimplify(self.m_wipeResult[index].takeStone), font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX() + itemView:getBoundingBox().size.width / 2, y = itemView:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		num:setAnchorPoint(cc.p(0, 0.5))

		local hausts = self.m_wipeResult[index].haust
		gdump(hausts, "WipeTableView:createCellAtIndex")
		if hausts and table.nums(hausts) > 0 then
			-- 损耗扣除坦克
			local label = ui.newTTFLabel({text = CommonText[288] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = cellSize.height - 260, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))

			local tankIndex = 1
			for _, data in pairs(hausts) do
				local itemView = UiUtil.createItemSprite(ITEM_KIND_TANK, data.tankId):addTo(cell)
				itemView:setAnchorPoint(cc.p(0.5, 0))
				itemView:setScale(0.8)

				local x, y
				if tankIndex % 2 == 1 then x = 80 else x = 310 end
				y = cellSize.height - 360 - (math.ceil(tankIndex / 2) - 1) * 120

				itemView:setPosition(x, y)

				local tankDB = TankMO.queryTankById(data.tankId)
				local label = ui.newTTFLabel({text = tankDB.name .. "*" .. data.count, font = G_FONT, size = FONT_SIZE_TINY, x = itemView:getPositionX(), y = itemView:getPositionY() - 15, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)

				tankIndex = tankIndex + 1
			end
		end
	end

	return cell
end

------------------------------------------------------------------------------
-- 扫荡
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local WipeCombatDialog = class("WipeCombatDialog", Dialog)

local WIPE_TOTAL_COUNT = 10
local WIPE_TOTAL_MAX = POWER_MAX_VALUE

function WipeCombatDialog:ctor(combatType, combatId, formation, doneCallback)
	WipeCombatDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})

	if combatType == COMBAT_TYPE_COMBAT then
		WIPE_TOTAL_COUNT = 10
		WIPE_TOTAL_MAX = POWER_MAX_VALUE
	elseif combatType == COMBAT_TYPE_EXPLORE then
		gprint("WipeCombatDialog:explore error!!!")
		local exploreDB = CombatMO.queryExploreById(combatId)
		WIPE_TOTAL_COUNT = CombatBO.getExploreChallengeLeftCount(exploreDB.type)
		WIPE_TOTAL_MAX = 5
	end
	self.m_combatType = combatType
	self.m_combatId = combatId
	self.m_formation = formation
	self.m_doneCallback = doneCallback
	gprint("WipeCombatDialog: type:", self.m_combatType, "combatId:", self.m_combatId, "count:", WIPE_TOTAL_COUNT)

	CombatMO.copyWipeFormation_ = clone(formation) -- 原始阵型
end

function WipeCombatDialog:onEnter()
	WipeCombatDialog.super.onEnter(self)

	self:setTitle(CommonText[35])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self.m_curWipeIndex = 1
	self.m_isWipeStop = false -- 是否停止

	self.m_wipeReport = {}

	-- self.m_award = {}
	-- self.m_haust = {}

	self:showUI()
	self:runAction(transition.sequence({cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			self:onWipe()
		end)}))

	self.m_powerListener = Notify.register("WIPE_COMBAT_POWER_HANDLER", handler(self,self.updatePowerListener))
	self.m_exploreListener = Notify.register("WIPE_COMBAT_EXPLORE_HANDLER", handler(self,self.updatePowerListener))
end

function WipeCombatDialog:updatePowerListener()
	if self.m_combatType == COMBAT_TYPE_COMBAT and self.m_container and self.m_container.powerlabel then
		-- 体力
		local count = UserMO.getResource(ITEM_KIND_POWER)
		self.m_container.powerlabel:setString(count .. "/" .. WIPE_TOTAL_MAX)
	elseif self.m_combatType == COMBAT_TYPE_EXPLORE and self.m_container and self.m_container.powerlabel then
		local exploreDB = CombatMO.queryExploreById(self.m_combatId)
		local count = CombatBO.getExploreChallengeLeftCount(exploreDB.type)
		self.m_container.powerlabel:setString(count .. "/" .. WIPE_TOTAL_MAX)
	end
end

function WipeCombatDialog:onExit()
	WipeCombatDialog.super.onExit(self)
	-- 主要用于探险副本刷新次数
	Notify.notify(LOCAL_COMBAT_UPDATE_EVENT)
	
	if self.m_powerListener then
		Notify.unregister(self.m_powerListener)
		self.m_powerListener = nil
	end

	if self.m_exploreListener then
		Notify.unregister(self.m_exploreListener)
		self.m_exploreListener = nil
	end
end

function WipeCombatDialog:onReturnCallback(tag, sender)
	if self.m_doneCallback then self.m_doneCallback() end

	ManagerSound.playNormalButtonSound()
	self:pop()
end

function WipeCombatDialog:showUI()
	-- if not self.m_container then
		local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
		infoBg:setPreferredSize(cc.size(510, 564))
		infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 72 - infoBg:getContentSize().height / 2)

		local container = display.newNode():addTo(infoBg)
		container:setContentSize(infoBg:getContentSize())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height / 2)
		self.m_container = container

		-- 当前等级
		local LVlabel = ui.newTTFLabel({text = "LV." .. UserMO.level_, font = G_FONT, size = FONT_SIZE_BIG, x = 64, y = 190, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		LVlabel:setAnchorPoint(cc.p(0, 0.5))
		container.LVlabel = LVlabel

		local function updateProgress(self_)
			if UserBO.isLordFullLevel() then -- 满级了
				self_:setPercent(0)
			else
				local nxtLord = UserMO.queryLordByLevel(UserMO.level_ + 1)

				self_:setPercent(UserMO.getResource(ITEM_KIND_EXP) / nxtLord.needExp)
				self_:setLabel(UiUtil.strNumSimplifySign(UserMO.getResource(ITEM_KIND_EXP)) .. "/" .. UiUtil.strNumSimplifySign(nxtLord.needExp), {size = FONT_SIZE_MEDIUM})
			end
		end

		-- 经验
		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_5.png", BAR_DIRECTION_HORIZONTAL, cc.size(356, 47), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(356 + 4, 36)}):addTo(self:getBg())
		bar:setPosition(self:getBg():getContentSize().width * 0.575 , LVlabel:y())
		bar.updateFunc = updateProgress
		bar:updateFunc()
		container.bar = bar


		if self.m_combatType == COMBAT_TYPE_COMBAT then
			-- 体力
			local powerSp = UiUtil.createItemView(ITEM_KIND_POWER):addTo(self:getBg())
			powerSp:setScale(0.75)
			powerSp:setPosition(100, 115)
			UiUtil.createItemDetailButton(powerSp,nil,nil,function ()
				self:onAddCallback()
				require("app.dialog.BuyPawerDialog").new():push()
			end)

			--加号
			local add = display.newSprite(IMAGE_COMMON.."add_combat.png"):addTo(powerSp)
			add:setPosition(powerSp:width() - 15, 16)

			local count = UserMO.getResource(ITEM_KIND_POWER)
			local powerlabel = ui.newTTFLabel({text = count .. "/" .. WIPE_TOTAL_MAX, font = G_FONT, size = FONT_SIZE_MEDIUM, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			powerlabel:setPosition(cc.p(powerSp:x() + 5, powerSp:y() - powerSp:height() * 0.5 * 0.75 - 20))
			container.powerlabel = powerlabel
		else
			-- 次数
			local powerSp = display.newSprite("image/item/times.jpg"):addTo(self:getBg())
			powerSp:setScale(0.75)
			powerSp:setPosition(100, 115)

			--加号
			local add = display.newSprite(IMAGE_COMMON.."add_combat.png"):addTo(powerSp)
			add:setPosition(powerSp:width() - 14, 14)

			local powerSpbg = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(powerSp, 1)
			powerSpbg:setPosition(powerSp:width() * 0.5, powerSp:height() * 0.5)

			powerSp:setTouchEnabled(true)
			powerSp:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					return true
				elseif event.name == "ended" then
					self:onAddCallback()
					local view = UiDirector.getUiByName("CombatLevelView")
					if view then
						view:onBuyCombat()
					end
				end
			end)


			local count = WIPE_TOTAL_COUNT
			local powerlabel = ui.newTTFLabel({text = count .. "/" .. WIPE_TOTAL_MAX, font = G_FONT, size = FONT_SIZE_MEDIUM, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			powerlabel:setPosition(cc.p(powerSp:x() + 5, powerSp:y() - powerSp:height() * 0.5 * 0.75 - 20))
			container.powerlabel = powerlabel
		end	


		-- 水晶
		local itemView = UiUtil.createItemView(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(self:getBg())
		itemView:setScale(0.75)
		itemView:setPosition(200, 115)
		UiUtil.createItemDetailButton(itemView,nil,nil,function ()
			self:onAddCallback()
			require("app.dialog.ItemUseDialog").new(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):push()
		end)
		--加号
		local add = display.newSprite(IMAGE_COMMON.."add_combat.png"):addTo(itemView)
		add:setPosition(itemView:width() - 16, 16)

		local itembg = display.newColorLayer(ccc4(0, 0, 0, 255)):addTo(itemView, -1)
		itembg:setContentSize(cc.size(itemView:width(), itemView:height()))

		local res = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
		
		local num = ui.newTTFLabel({text = UiUtil.strNumSimplify(res), font = G_FONT, size = FONT_SIZE_MEDIUM, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		-- num:setAnchorPoint(cc.p(0, 0.5))
		num:setPosition(itemView:x(), itemView:y() - itemView:height() * 0.5 * 0.75 - 20)
		container.stoneLabel = num

		-- 扫荡
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onStopCallback)):addTo(self:getBg())
		-- btn:setPosition(self:getBg():getContentSize().width / 2, 26)
		btn:setPosition(self:getBg():getContentSize().width * 0.75, 115)
		btn:setLabel(CommonText[285]) -- 初始默认是停止扫荡
		self.m_wipeButton = btn
	-- end
end

function WipeCombatDialog:onWipe(canWipe)
	-- if self.m_curWipeIndex > WIPE_TOTAL_COUNT then
	if self.m_combatType == COMBAT_TYPE_COMBAT then
		-- if self.m_curWipeIndex % 10 == 1 and self.m_curWipeIndex ~= 1 and not canWipe then
		-- 	gprint("扫荡结束关卡")
		-- 	self.m_isWipeStop = true
		-- 	self:showButtonStatus()
		-- 	self:showResult(false)

		-- 	local InfoDialog = require("app.dialog.InfoDialog")
		-- 	InfoDialog.new(CommonText[299][2], function() end):push()
		-- 	return
		-- end
	else
		local exploreDB = CombatMO.queryExploreById(self.m_combatId)
		local count = CombatBO.getExploreChallengeLeftCount(exploreDB.type)
		if count <= 0 then
			gprint("扫荡结束探险")
			self.m_isWipeStop = true
			self:showButtonStatus()
			self:showResult(false)

			local InfoDialog = require("app.dialog.InfoDialog")
			InfoDialog.new(CommonText[299][2], function() end):push()
			return
		end
	end

	self:showResult(true)

	local formatOk
	formatOk, self.m_formation = TankBO.checkFormation(CombatMO.copyWipeFormation_)

	if self.m_combatType == COMBAT_TYPE_COMBAT then  -- 普通副本判断能量释放足够
		local power = UserMO.getResource(ITEM_KIND_POWER)
		if power < COMBAT_TAKE_POWER then -- 能量不足
			local resData = UserMO.getResourceData(ITEM_KIND_POWER)
			local function callback()
				require("app.dialog.BuyPawerDialog").new():push()
				self.m_isWipeStop = true
				self:showButtonStatus()
			end
			local InfoDialog = require("app.dialog.InfoDialog")
			InfoDialog.new(resData.name .. CommonText[223] .. "，" .. CommonText[300], callback):push()  -- 能量不足，停止扫荡
			self.m_isWipeStop = true
			self:showButtonStatus()
			self:showResult(false)
			return
		end
	elseif self.m_combatType == COMBAT_TYPE_EXPLORE then -- 探险副本判断挑战次数是否足够
		local combatDB = CombatMO.queryExploreById(self.m_combatId)
		if CombatBO.getExploreChallengeLeftCount(combatDB.type) <= 0 then
			local InfoDialog = require("app.dialog.InfoDialog")
			InfoDialog.new(CommonText[299][3], function() end):push()  -- 次数不足，停止扫荡
			self.m_isWipeStop = true
			self:showButtonStatus()
			self:showResult(false)

			return
		end
	end

	local result = CombatBO.canWipe(self.m_formation, CombatMO.copyWipeFormation_)

	if result ~= 0 then
	-- 	if result == 2 then  -- 宝石不足
	-- 		local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
	-- 		-- 无法满足坦克修复，停止扫荡
	-- 		local InfoDialog = require("app.dialog.InfoDialog")
	-- 		InfoDialog.new(resData.name .. CommonText[299][5], function() end):push()
	-- 		self.m_isWipeStop = true
	-- 		self:showButtonStatus()
	-- 		return
	-- 	else
		if result == 3 then -- 阵型损失过大
			local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
			-- 阵型损失太大，停止扫荡
			local InfoDialog = require("app.dialog.InfoDialog")
			InfoDialog.new(CommonText[299][6], function() end):push()
			self.m_isWipeStop = true
			self:showButtonStatus()
			self:showResult(false)
			return
		end
	end

	-- local data = {}
	-- local statFormat = TankBO.stasticsFormation(self.m_formation)
	-- for tankId, count in pairs(statFormat.tank) do
	-- 	local num1 = UserMO.getResource(ITEM_KIND_TANK, tankId)
	-- 	local num2 = TankMO.getTankRepairCountById(tankId)
	-- 	data[tankId] = num1 + num2
	-- end
	-- CombatMO.deforeWipeTankNum_ = data

	Loading.getInstance():show()
	CombatBO.asynDoWipe(handler(self, self.onDoneWip), self.m_combatType, self.m_combatId, self.m_formation)
end

function WipeCombatDialog:onDoneWip(award, haust)
	if tolua.isnull(self) then
		gprint("[my 丢弃] 超时UI ")
		return
	end
	self.m_wipeReport[self.m_curWipeIndex] = {}
	self.m_wipeReport[self.m_curWipeIndex].award = award  -- 奖励
	self.m_wipeReport[self.m_curWipeIndex].haust = haust  -- 战损
	self.m_wipeReport[self.m_curWipeIndex].takeStone = 0  -- 修理扣除宝石
	local report = self.m_wipeReport[self.m_curWipeIndex]

	self.m_curWipeIndex = self.m_curWipeIndex + 1

	-- local function doneCallback()
	-- 	Loading.getInstance():unshow()
	-- 	self:showResult(false)

	-- 	-- 显示奖励
	-- 	UiUtil.showAwards(CombatMO.curBattleAward_)
	-- 	CombatMO.curBattleAward_ = nil

	-- 	if CombatMO.curBattleStar_ > 0 then -- 扫荡胜利了
	-- 		self:stopAllActions()
	-- 		if self.m_curWipeIndex > WIPE_TOTAL_COUNT then
	-- 			if not self.m_isWipeStop then self:onWipe() end
	-- 		else
	-- 			self:runAction(transition.sequence({cc.DelayTime:create(2), cc.CallFunc:create(function()
	-- 					if not self.m_isWipeStop then self:onWipe() end
	-- 				end)}))
	-- 		end
	-- 	else
	-- 		local InfoDialog = require("app.dialog.InfoDialog")
	-- 		-- 扫荡失败，停止扫荡
	-- 		InfoDialog.new(CommonText[299][1], function() end):push()
	-- 		self.m_isWipeStop = true
	-- 		self:showButtonStatus()
	-- 	end

	-- end

	local repairStoneTotal = 0   -- 修理扣除宝石
	local tanks = TankMO.getNeedRepairTanks()

	if CombatMO.curBattleStar_ > 0 then  -- 打赢了
		local function doneCallback()
			report.takeStone = repairStoneTotal

			self:stopAllActions()

			Loading.getInstance():unshow()
			self:showResult(false)

			-- 显示奖励
			UiUtil.showAwards(CombatMO.curBattleAward_)
			CombatMO.curBattleAward_ = nil

			-- if self.m_combatType == COMBAT_TYPE_COMBAT then
				self:runAction(transition.sequence({cc.DelayTime:create(0.5), cc.CallFunc:create(function()
						if not self.m_isWipeStop then self:onWipe() end
					end)}))
			-- else
			-- 	if self.m_curWipeIndex > WIPE_TOTAL_COUNT then
			-- 		if not self.m_isWipeStop then self:onWipe() end
			-- 	else
			-- 		self:runAction(transition.sequence({cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			-- 				if not self.m_isWipeStop then self:onWipe() end
			-- 			end)}))
			-- 	end
			-- end
		end

		if #tanks > 0 then  -- 有坦克要修的
			repairStoneTotal = TankMO.calcRepairCost(tanks).gemTotal

			if repairStoneTotal > UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE) then -- 水晶不足
				Loading.getInstance():unshow()

				-- 显示奖励
				UiUtil.showAwards(CombatMO.curBattleAward_)
				CombatMO.curBattleAward_ = nil

				local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
				-- 无法满足坦克修复，停止扫荡
				local InfoDialog = require("app.dialog.InfoDialog")
				InfoDialog.new(resData.name .. CommonText[299][5], function() end):push()
				self.m_isWipeStop = true
				self:showResult(false)
				self:showButtonStatus()
			else  -- 用宝石修复所有坦克
				TankBO.asynRepair(doneCallback, 0, 1)
			end
		else  -- 没有坦克要修复
			doneCallback()
		end
	else  -- 打输了
		Loading.getInstance():unshow()

		-- 显示奖励
		UiUtil.showAwards(CombatMO.curBattleAward_)
		CombatMO.curBattleAward_ = nil

		local InfoDialog = require("app.dialog.InfoDialog")
		InfoDialog.new(CommonText[299][1], function() end):push()  -- 扫荡失败，停止扫荡
		self.m_isWipeStop = true
		self:showResult(false)
		self:showButtonStatus()
	end
end

-- isStart：是否是开启一次扫荡。false表示一次扫荡结束，显示结果
function WipeCombatDialog:showResult(isStart)
	self.m_container:removeAllChildren()
	local container = self.m_container

	local view = WipeTableView.new(cc.size(self.m_container:getContentSize().width - 8, self.m_container:getContentSize().height - 8), self.m_wipeReport, isStart):addTo(container)
	view:setPosition(4, 4)
	view:reloadData()
	self.m_wipeTableView = view

	-- if self.m_curWipeIndex > WIPE_TOTAL_COUNT then
	-- 	view:setContentOffset(view:maxContainerOffset())
	-- 	view:setTouchEnabled(true)
	-- else
		local cellNum = view:numberOfCells()
		local cellSize = view:cellSizeForIndex(cellNum) -- 最后一个cell的大小
		view:setContentOffset(cc.p(0, view:getViewSize().height - cellSize.height))
		if self.m_isWipeStop then
			view:setTouchEnabled(true)
		else
			view:setTouchEnabled(false)
		end
	-- end


	-- -- 第x次扫荡
	-- local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	-- bg:setAnchorPoint(cc.p(0, 0.5))
	-- bg:setPosition(20, 620)
	-- local title = ui.newTTFLabel({text = CommonText[237][1] .. (self.m_curWipeIndex - 1) .. CommonText[237][3] .. CommonText[35], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	-- -- 获得物品
	-- local label = ui.newTTFLabel({text = CommonText[286] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 580, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- for index = 1, #self.m_award do
	-- 	local award = self.m_award[index]
	-- 	gdump(award, "[WipeCombatDialog] award")

	-- 	local itemView = UiUtil.createItemView(award.kind, award.id):addTo(container)
	-- 	itemView:setScale(0.9)
	-- 	itemView:setPosition(30 + (index - 0.5) * 104, 510)

	-- 	local resData = UserMO.getResourceData(award.kind, award.id)
	-- 	local name = ui.newTTFLabel({text = resData.name .. "*" .. UiUtil.strNumSimplify(award.count), font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 450, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	-- end

	-- local stoneData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)

	-- -- 修理扣除宝石
	-- local label = ui.newTTFLabel({text = CommonText[287] .. stoneData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 410, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- local itemView = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(container)
	-- itemView:setPosition(label:getPositionX() + label:getContentSize().width + itemView:getBoundingBox().size.width / 2, label:getPositionY())

	-- local num = ui.newTTFLabel({text = UiUtil.strNumSimplify(self.m_repairTake), font = G_FONT, size = FONT_SIZE_SMALL, x = itemView:getPositionX() + itemView:getBoundingBox().size.width / 2, y = itemView:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	-- num:setAnchorPoint(cc.p(0, 0.5))

	-- -- 损耗扣除坦克
	-- local label = ui.newTTFLabel({text = CommonText[288] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 380, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- local index = 1
	-- for tankId, count in pairs(self.m_haust) do
	-- 	local itemView = UiUtil.createItemSprite(ITEM_KIND_TANK, tankId):addTo(container)
	-- 	itemView:setAnchorPoint(cc.p(0.5, 0))
	-- 	itemView:setScale(0.8)

	-- 	local x, y
	-- 	if index % 2 == 1 then x = 80 else x = 310 end
	-- 	y = 300 - (math.ceil(index / 2) - 1) * 120

	-- 	itemView:setPosition(x, y)

	-- 	local tankDB = TankMO.queryTankById(tankId)
	-- 	local label = ui.newTTFLabel({text = tankDB.name .. "*" .. count, font = G_FONT, size = FONT_SIZE_TINY, x = itemView:getPositionX(), y = itemView:getPositionY() - 20, color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(container)

	-- 	index = index + 1
	-- end

	-- 宝石剩余数量
	local res = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
	container.stoneLabel:setString(UiUtil.strNumSimplify(res))

	-- 等级
	self.m_container.LVlabel:setString("LV." .. UserMO.level_)

	-- 经验
	self.m_container.bar:updateFunc()

	if self.m_combatType == COMBAT_TYPE_COMBAT then
		-- 体力
		local count = UserMO.getResource(ITEM_KIND_POWER)
		self.m_container.powerlabel:setString(count .. "/" .. WIPE_TOTAL_MAX)
	else
		-- 次数
		local exploreDB = CombatMO.queryExploreById(self.m_combatId)
		local count = CombatBO.getExploreChallengeLeftCount(exploreDB.type)

		self.m_container.powerlabel:setString(count .. "/" .. WIPE_TOTAL_MAX)
	end
end

function WipeCombatDialog:onStopCallback(tag, sender)
	if self.m_combatType == COMBAT_TYPE_COMBAT then
		if self.m_curWipeIndex % 10 == 1 and self.m_curWipeIndex ~= 1 then
			local canWipe = 1
			self:onWipe(canWipe)
			self.m_isWipeStop = false
			self:showButtonStatus()
			return
		end
	else
		local exploreDB = CombatMO.queryExploreById(self.m_combatId)
		local count = CombatBO.getExploreChallengeLeftCount(exploreDB.type)
		if count <= 0 then
			local view = UiDirector.getUiByName("CombatLevelView")
			if view then
				view:onBuyCombat()
			end
			return
		end
		if self.m_curWipeIndex % WIPE_TOTAL_COUNT == 1 and self.m_curWipeIndex ~= 1 then
			local canWipe = 1
			self:onWipe(canWipe)
			self.m_isWipeStop = false
			self:showButtonStatus()
			return
		end


		-- if self.m_curWipeIndex > WIPE_TOTAL_COUNT then -- 扫荡结束
		-- 	if self.m_doneCallback then self.m_doneCallback() end
		-- 	self:pop()
		-- 	return
		-- end
	end

	if not self.m_isWipeStop then -- 需要停止扫荡
		self.m_isWipeStop = true
		self:stopAllActions()

		self.m_wipeTableView:setTouchEnabled(true)
	else
		-- 需要开启扫荡
		self.m_isWipeStop = false

		self:onWipe()
	end
	self:showButtonStatus()
end

--点击添加能量或者资源等
function WipeCombatDialog:onAddCallback()
	if not self.m_isWipeStop then
		self.m_isWipeStop = true
		self:stopAllActions()
		self.m_wipeTableView:setTouchEnabled(true)
		self.m_wipeButton:setLabel(CommonText[284])  -- 按钮显示为继续扫荡
	end
end

function WipeCombatDialog:showButtonStatus()
	-- if self.m_combatType == COMBAT_TYPE_COMBAT then
	if self.m_isWipeStop then
		self.m_wipeButton:setLabel(CommonText[284])  -- 按钮显示为继续扫荡
	else
		self.m_wipeButton:setLabel(CommonText[285])  -- 按钮显示为停止扫荡
	end
	-- else
	-- 	if self.m_curWipeIndex > WIPE_TOTAL_COUNT then
	-- 		-- 扫荡结束
	-- 		self.m_wipeButton:setLabel(CommonText[289])
	-- 	else
	-- 		if self.m_isWipeStop then
	-- 			self.m_wipeButton:setLabel(CommonText[284])  -- 按钮显示为继续扫荡
	-- 		else
	-- 			self.m_wipeButton:setLabel(CommonText[285])  -- 按钮显示为停止扫荡
	-- 		end
	-- 	end
	-- end
end

function WipeCombatDialog:refreshUI(name)
	-- if name == "BuyPawerDialog" then
	-- 	self.m_isWipeStop = true
	-- end

	if name == "ItemUseDialog" and self.m_container and self.m_container.stoneLabel then
		self.m_isWipeStop = false
		local res = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
		self.m_container.stoneLabel:setString(UiUtil.strNumSimplify(res))
	end
end

return WipeCombatDialog
