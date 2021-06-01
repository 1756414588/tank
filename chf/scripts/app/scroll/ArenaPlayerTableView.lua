
-- 竞技场玩家view

local ArenaPlayerTableView = class("ArenaPlayerTableView", TableView)

function ArenaPlayerTableView:ctor(size, players)
	ArenaPlayerTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 110)

	gdump(players, "[ArenaPlayerTableView")
	self.m_players = players
	table.sort(self.m_players, ArenaBO.orderRival)
end

function ArenaPlayerTableView:numberOfCells()
	return #self.m_players
end

function ArenaPlayerTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ArenaPlayerTableView:createCellAtIndex(cell, index)
	ArenaPlayerTableView.super.createCellAtIndex(self, cell, index)

	local player = self.m_players[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 12, self.m_cellSize.height - 6))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	-- 排名
	local rank = ArenaBO.createRank(player.rank):addTo(cell)
	rank:setPosition(60, self.m_cellSize.height / 2)

	-- 头像
	local portrait = UiUtil.createItemView(ITEM_KIND_PORTRAIT, 1):addTo(cell)
	portrait:setScale(0.4)
	portrait:setPosition(145, self.m_cellSize.height / 2 - 5)

	-- 玩家名称
	local label = ui.newTTFLabel({text = player.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = self.m_cellSize.height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 等级
	local label = ui.newTTFLabel({text = CommonText[113] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local lvlabel = ui.newTTFLabel({text = player.lv, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	lvlabel:setAnchorPoint(cc.p(0, 0.5))

	-- 阵型战力
	local label = ui.newTTFLabel({text = CommonText[248] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local numLabel = ui.newBMFontLabel({text = UiUtil.strNumSimplify(player.fight), font = "fnt/num_2.fnt", x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(cell)
	numLabel:setAnchorPoint(cc.p(0, 0.5))

	if player.name ~= UserMO.nickName_ then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_lock_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_lock_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenCallback))
		btn.index = index
		cell:addButton(btn, self.m_cellSize.width - 75, self.m_cellSize.height / 2)
	end
	return cell
end

function ArenaPlayerTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if ArenaMO.arenaLeftCount_ <= 0 then  -- 没有挑战次数
		Toast.show(CommonText[292])
		return
	end

	local name = self.m_players[sender.index].name
	if ArenaMO.getCdTime() > 0 then
		local resData = UserMO.getResourceData(ITEM_KIND_COIN)
		local needCoin = math.ceil(ArenaMO.getCdTime() / 60)  -- 一分钟一个金币

		local function doneBuyArenaCd()
			Loading.getInstance():unshow()
			Toast.show(CommonText[10031]) -- 成功清除cd时间
		end

		local function gotoBuy()
			local count = UserMO.getResource(ITEM_KIND_COIN)
			if count < needCoin then
				require("app.dialog.CoinTipDialog").new():push()
				return
			end

			if ArenaMO.getCdTime() <= 0 then return end

			Loading.getInstance():show()
			ArenaBO.asynBuyArenaCd(doneBuyArenaCd, ArenaMO.getCdTime())
		end

		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[10030], needCoin, resData.name), function() gotoBuy() end):push()
		else
			gotoBuy()
		end
		-- Toast.show(CommonText[399])
		return
	end

	local formation = TankMO.getFormationByType(FORMATION_FOR_ARENA)

	if not TankBO.hasFightFormation(formation) then  -- 判断阵型是否为空
		-- 阵型为空，请设置阵型
		Toast.show(CommonText[193])
		return
	end

	local function gotoBattle()
		Loading.getInstance():unshow()

		CombatMO.curChoseBattleType_ = COMBAT_TYPE_ARENA
		CombatMO.curChoseBtttleId_ = sender.index

		BattleMO.reset()
		BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
		BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
		BattleMO.setFightData(CombatMO.curBattleFightData_)
		local atk = {name = UserMO.nickName_}
		local def = {name = name}
		-- 攻先手值
		if table.isexist(CombatMO.curBattleFightData_,"firstValue1") then
			atk.firstValue = CombatMO.curBattleFightData_.firstValue1
		end
		-- 防先手值
		if table.isexist(CombatMO.curBattleFightData_,"firstValue2") then
			def.firstValue = CombatMO.curBattleFightData_.firstValue2
		end 
		BattleMO.setBothInfo(atk,def)
		require("app.view.BattleView").new("image/bg/bg_battle_2.jpg"):push()
	end
	
	local function doneDoArena()
		if CombatMO.curBattleStar_ > 0 then -- 挑战胜利，重新拉取数据
			ArenaBO.asynGetArena(gotoBattle, true)
		else
			gotoBattle()
		end
	end

	Loading.getInstance():show()
	ArenaBO.asynDoArena(doneDoArena, self.m_players[sender.index].rank, formation)
end

return ArenaPlayerTableView
