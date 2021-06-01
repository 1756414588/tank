--
-- Author: gf
-- Date: 2015-09-19 15:28:13
--

local ReportAirShipTableView = class("ReportAirShipTableView", TableView)

function ReportAirShipTableView:ctor(size, mail, readStatus)
	ReportAirShipTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	
	self.m_bounceable = false
	
	self.mail = mail
	self.readStatus = readStatus

	local height = 550
	local report = self.mail.report_db_

	for i,v in ipairs(report.attackers) do
		height = height + 80 + 80
		if v.tank and #v.tank > 0 then
			height = height + 115 * math.ceil(#v.tank / 2)
		else
			height = height + 40
		end
	end

	for i,v in ipairs(report.defencers) do
		height = height + 80 + 80
		if v.tank and #v.tank > 0 then
			height = height + 115 * math.ceil(#v.tank / 2)
		else
			height = height + 40
		end
	end

	if report.award and #report.award > 0 then
		height = height + 280
	end

	self.m_cellSize = cc.size(size.width, height)
end

function ReportAirShipTableView:reloadData()
	ReportAirShipTableView.super.reloadData(self)
end

function ReportAirShipTableView:numberOfCells()
	return 1
end

function ReportAirShipTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ReportAirShipTableView:createCellAtIndex(cell, index)
	ReportAirShipTableView.super.createCellAtIndex(self, cell, index)

	local report = self.mail.report_db_
	-- gdump(report,"报告信息")

	local defencer = report.defencer
	local attacker = report.attacker
	-- local isRebel = defencer.mine and defencer.mine < 0

	-- 战斗信息
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, self.m_cellSize.height - 30)

	--收藏
	local normal = display.newSprite(IMAGE_COMMON .. "btn_uncollect_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_uncollect_selected.png")
	local collectBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCollectCallback)):addTo(cell)
	collectBtn:setPosition(self.m_cellSize.width - 60, self.m_cellSize.height - 60)
	if self.readStatus then
		collectBtn:setVisible(false)
	end
	if self.mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
		collectBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_collect_normal.png"))
		collectBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_collect_selected.png"))
	end
	collectBtn.keyId = self.mail.keyId

	local title = ui.newTTFLabel({text = CommonText[658][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	local posY

	local topTips = {CommonText[659][1],CommonText[659][2],CommonText[659][3],CommonText[659][4]}

	for index=1,#topTips do
		local labTit = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		labTit:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then 
			if report.reportType == DEFENCE_TYPE_ATTACK_MAN or report.reportType == DEFENCE_TYPE_ATTACK_MINE then
				labTit:setString(topTips[index][1])
			else
				labTit:setString(topTips[index][2])
			end
		else
			labTit:setString(topTips[index])
		end

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))
		

		if index == 1 then 
			--进攻目标
			-- pos = WorldMO.decodePosition(attacker.pos)
			local str = attacker.name
			-- if not self.readStatus then
			-- 	str = str .. " (" .. pos.x  .. "," .. pos.y ..  ")"
			-- end
			-- if attacker.party and attacker.party ~= "" then
			-- 	str = str .. " (" .. attacker.party .. ")"
			-- end
			value:setString(str)
		elseif index == 2 then
			--战斗地点
			local pos = WorldMO.decodePosition(defencer.pos)

			local airshipId = report.airshipId
			local ab = AirshipMO.queryShipById(airshipId)
			local str = ab.name

			if not self.readStatus then
				str = str .. " (" .. pos.x  .. "," .. pos.y ..  ")"
			end
			-- if defencer.party and defencer.party ~= "" then
			-- 	str = str .. " (" .. defencer.party .. ")"
			-- end
			value:setString(str)
		elseif index == 3 then
			--战斗时间
			value:setString(os.date("%m-%d %X",self.mail.report_db_.time))
		elseif index == 4 then
			--战斗结果
			if report.reportType == DEFENCE_TYPE_ATTACK_MAN or report.reportType == DEFENCE_TYPE_ATTACK_MINE 
				or report.reportType == DEFENCE_TYPE_ATTACK_AIRSHIP then
				if report.result then
					value:setString(CommonText[660][1])
					value:setColor(COLOR[2])
				else
					value:setString(CommonText[660][2])
					value:setColor(COLOR[6])
				end
			else
				if report.result then
					value:setString(CommonText[660][4])
					value:setColor(COLOR[6])
				else
					value:setString(CommonText[660][3])
					value:setColor(COLOR[2])
				end
			end
		end

		posY = labTit:getPositionY()
	end

	-- 城市繁荣
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, posY - 50)

	local title = ui.newTTFLabel({text = CommonText[1101], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	
	local attackLab = ui.newTTFLabel({text = CommonText[661][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	attackLab:setAnchorPoint(cc.p(0, 0.5))

	local attackValue = ui.newTTFLabel({text = attacker.name, font = G_FONT, size = FONT_SIZE_SMALL, x = attackLab:getPositionX() + attackLab:getContentSize().width, y = attackLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	attackValue:setAnchorPoint(cc.p(0, 0.5))

    -- 建筑
    local attackBuild = nil
	attackBuild = display.newSprite("res/image/tank/tank_29.png"):addTo(cell)
	attackBuild:setPosition(attackValue:getPositionX() - 20,attackValue:getPositionY() - 50)

	local defenceLab = ui.newTTFLabel({text = CommonText[661][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 350, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	defenceLab:setAnchorPoint(cc.p(0, 0.5))

	local defenceValue = ui.newTTFLabel({text = defencer.name, font = G_FONT, size = FONT_SIZE_SMALL, x = defenceLab:getPositionX() + defenceLab:getContentSize().width, y = defenceLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	defenceValue:setAnchorPoint(cc.p(0, 0.5))

	--守方图片
	local defenceBuild = nil
	defenceBuild = display.newSprite(IMAGE_COMMON.."ship/ship.png"):addTo(cell)
	defenceBuild:setPosition(defenceValue:getPositionX() - 20,defenceValue:getPositionY() - 50)
	defenceBuild:setScale(math.min(160 / defenceBuild:getContentSize().width, 130 / defenceBuild:getContentSize().height))

	--耐久度 进度条
	local maxDurb = 100
	local remainDurb = 0
	local lostDurb = 0
	if table.isexist(report, "remainDurb") then
		remainDurb = report.remainDurb / 100
	end

	if table.isexist(report, "lostDurb") then
		lostDurb = report.lostDurb / 100
	end

	local node = UiUtil.showProsValue(remainDurb, maxDurb)
	node:setPosition(defenceBuild:getPositionX(),defenceBuild:getPositionY() - 60)
	cell:addChild(node)
	local bar = UiUtil.showProsBar(remainDurb, maxDurb)
	bar:setPosition(node:getPositionX() + node:getContentSize().width / 2,node:getPositionY() - 6)
	cell:addChild(bar)

	if lostDurb ~= 0 then
		--耐久度变化
		local prosAddValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = bar:getPositionX() - 10, y = bar:getPositionY() -20,align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		prosAddValue:setAnchorPoint(cc.p(0, 0.5))
		prosAddValue:setString("-" .. lostDurb)
		prosAddValue:setColor(COLOR[6])
	end

    local normal = display.newSprite(IMAGE_COMMON .. "btn_store_go_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_store_go_selected.png")
    local locationBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.onLocationCallback))
    locationBtn.pos = defencer.pos
    locationBtn:setVisible(not self.readStatus)
    cell:addButton(locationBtn, defenceBuild:getPositionX() + 160, defenceBuild:getPositionY() - 20)

    posY = locationBtn:getPositionY()

	-- 部队损失

	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, posY - 110)

	local title = ui.newTTFLabel({text = CommonText[658][4], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local recordLord = report.recordLord
	----攻方损失
	local attackers = clone(report.attackers)
	local defencers = clone(report.defencers)

	for i,v in ipairs(attackers) do
		v.order = 999--math.max(#recordLord, #attackers)
	end

	for i,v in ipairs(defencers) do
		v.order = 999--math.max(#recordLord, #defencers)
	end

	local first = report.first
	for i,v in ipairs(recordLord) do
		local isFirst = first[i]
		for _,man in ipairs(attackers) do
			if v.v1 == man.lordId then
				man.order = math.min(i, man.order)
				if man.first == nil then
					man.first = isFirst
				end
				break
			end
		end

		for _,man in ipairs(defencers) do
			if v.v2 == man.lordId then
				man.order = math.min(i, man.order)
				if man.first == nil then
					man.first = isFirst
				end
				break
			end			
		end		
	end

	table.sort(attackers,function ( man1, man2 )
		return man1.order < man2.order
	end)

	table.sort(defencers,function ( man1, man2 )
		return man1.order < man2.order
	end)

	posY = posY - 155
	for i,attacker in ipairs(attackers) do
		--攻方损失
		local attackLab = ui.newTTFLabel({text = CommonText[661][1], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 40, y = posY - 0, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackLab:setAnchorPoint(cc.p(0, 0.5))

		local attackValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = attackLab:getPositionX() + attackLab:getContentSize().width, y = attackLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackValue:setAnchorPoint(cc.p(0, 0.5))

		local str = attacker.name-- .. "  VIP" .. attacker.vip
		if attacker.first then
			str = str .. CommonText[663]
		end 
		attackValue:setString(str)

		--攻方将领
		local attackHeroLab = ui.newTTFLabel({text = CommonText[661][3], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 40, y = attackValue:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackHeroLab:setAnchorPoint(cc.p(0, 0.5))

		local attackHeroValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = attackHeroLab:getPositionX() + attackHeroLab:getContentSize().width, y = attackHeroLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackHeroValue:setAnchorPoint(cc.p(0, 0.5))
		if attacker.commander > 0 then
			local heroInfo = HeroMO.queryHero(attacker.commander)
			attackHeroValue:setString(heroInfo.heroName)
		else
			attackHeroValue:setString(CommonText[108])
		end

		local attacknextLab = attackHeroLab
		if table.isexist(attacker,"mplt") then
			-- 攻方军功
			local attackMplt = ui.newTTFLabel({text = CommonText[1018] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = self.m_cellSize.width * 0.5, y = attacknextLab:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackMplt:setAnchorPoint(cc.p(0,0.5))
			attackMplt:setPosition(40 , attacknextLab:getPositionY() - 40)

			local attackMpltValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = attackMplt:getPositionX() + attackMplt:getContentSize().width + 10, y = attackMplt:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackMpltValue:setAnchorPoint(cc.p(0, 0.5))
			attackMpltValue:setString(attacker.mplt or "0")

			attacknextLab = attackMplt
		end

		if table.isexist(attacker,"firstValue") then
			-- 攻方先手值
			local attackFirst = ui.newTTFLabel({text = CommonText[1073] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = self.m_cellSize.width * 0.5, y = attacknextLab:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackFirst:setAnchorPoint(cc.p(0,0.5))
			attackFirst:setPosition(40 , attacknextLab:getPositionY() - 40)
			
			local attackFirstValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = attackFirst:getPositionX() + attackFirst:getContentSize().width + 10, y = attackFirst:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackFirstValue:setAnchorPoint(cc.p(0, 0.5))
			attackFirstValue:setString(attacker.firstValue or "0")

			attacknextLab = attackFirst
		end
		

		local posLab_ = attacknextLab
		local expLabel = nil
		if report.winStaffingExp then
			--攻方编制经验
			local attackStaffingLab = ui.newTTFLabel({text = CommonText[661][4], font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 40, y = attacknextLab:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				attackStaffingLab:setAnchorPoint(cc.p(0, 0.5))

			local attackStaffingValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			attackStaffingValue:setAnchorPoint(cc.p(0, 0.5))
			attackStaffingValue:setPosition(attackStaffingLab:getPositionX() + attackStaffingLab:getContentSize().width,attackStaffingLab:getPositionY())
			expLabel = attackStaffingValue
			if report.result then
				attackStaffingValue:setString(report.winStaffingExp)
				attackStaffingValue:setColor(COLOR[2])
				if report.staffingExpAdd then
					expLabel = UiUtil.label("(+".. report.staffingExpAdd .."%)",FONT_SIZE_SMALL,COLOR[2]):rightTo(attackStaffingValue, 5)
				end
			else
				attackStaffingValue:setString("-" .. report.winStaffingExp)
				attackStaffingValue:setColor(COLOR[6])
			end
			posLab_ = attackStaffingLab
		end

		local startY = posLab_:getPositionY()
		
		if attacker.tank and #attacker.tank > 0 then
			for index=1,#attacker.tank do
				local tank = attacker.tank[index]
				local tankIcon = UiUtil.createItemSprite(ITEM_KIND_TANK, tank.tankId)
				-- tankIcon:setPosition(tankPos[index][1],tankPos[index][2])
				local x = 0
				local y = 0
				if index % 2 == 1 then
					x = 100
					y = startY - 80 * math.ceil(index/2)
				else
					x = 400
					y = startY - 80 * math.ceil(index/2)
				end

				tankIcon:setPosition(x, y)
				cell:addChild(tankIcon)
				local tankName = ui.newTTFLabel({text = UserMO.getResourceData(ITEM_KIND_TANK, tank.tankId).name .. "\n -" .. tank.count, font = G_FONT, size = FONT_SIZE_SMALL, 
					x = tankIcon:getPositionX() + tankIcon:getContentSize().width / 2, y = tankIcon:getPositionY() - 10, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				tankName:setAnchorPoint(cc.p(0, 0.5))
			end
			posY = startY - 80 * math.ceil(#attacker.tank/2) - 80-- tankPos[#attacker.tank][2] - 80
		else
			local perfectLab = ui.newTTFLabel({text = CommonText[1104], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = expLabel and expLabel:x()+expLabel:width() + 10 or 40, y = attacknextLab:getPositionY() - 40, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			perfectLab:setAnchorPoint(cc.p(0, 0.5))
			posY = perfectLab:getPositionY() - 40
		end		
	end

	for i,defencer in ipairs(defencers) do
		--守方损失
		local defenceLab = ui.newTTFLabel({text = CommonText[661][2], font = G_FONT, size = FONT_SIZE_SMALL, 
				color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defenceLab:setAnchorPoint(cc.p(0, 0.5))
		defenceLab:setPosition(40,posY)

		local defenceValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = defenceLab:getPositionX() + defenceLab:getContentSize().width, y = defenceLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defenceValue:setAnchorPoint(cc.p(0, 0.5))

		local str = defencer.name

		if not defencer.first then
			str = str .. CommonText[663]
		end 	
		defenceValue:setString(str)

		--守方将领
		local defenceHeroLab = ui.newTTFLabel({text = CommonText[661][3], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 40, y = defenceValue:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defenceHeroLab:setAnchorPoint(cc.p(0, 0.5))

		local defenceHeroValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = defenceHeroLab:getPositionX() + defenceHeroLab:getContentSize().width, y = defenceHeroLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defenceHeroValue:setAnchorPoint(cc.p(0, 0.5))
		if defencer.commander > 0 then
			local id = defencer.commander
			local heroInfo = HeroMO.queryHero(id)
			defenceHeroValue:setString(heroInfo.heroName)
		else
			defenceHeroValue:setString(CommonText[108])
		end

		local defencenextLab = defenceHeroLab
		-- 守方军功
		if table.isexist(defencer, "mplt") then
			local defenceMplt = ui.newTTFLabel({text = CommonText[1018] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = self.m_cellSize.width * 0.5, y = defencenextLab:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defenceMplt:setAnchorPoint(cc.p(0,0.5))
			defenceMplt:setPosition(40 , defencenextLab:getPositionY() - 40 )

			local defenceMpltValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = defenceMplt:getPositionX() + defenceMplt:getContentSize().width + 10, y = defenceMplt:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defenceMpltValue:setAnchorPoint(cc.p(0, 0.5))
			defenceMpltValue:setString(defencer.mplt or "0")

			defencenextLab = defenceMplt
		end

		if table.isexist(defencer,"firstValue") then
			-- 守方先手值
			local defencerFirst = ui.newTTFLabel({text = CommonText[1073] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = self.m_cellSize.width * 0.5, y = defencenextLab:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defencerFirst:setAnchorPoint(cc.p(0,0.5))
			defencerFirst:setPosition(40 , defencenextLab:getPositionY() - 40)

			local defencerFirstValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = defencerFirst:getPositionX() + defencerFirst:getContentSize().width + 10, y = defencerFirst:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			defencerFirstValue:setAnchorPoint(cc.p(0, 0.5))
			defencerFirstValue:setString(defencer.firstValue or "0")

			defencenextLab = defencerFirst
		end
	
		

		local posLab_ = defencenextLab
		if report.failStaffingExp then
			--守方编制经验
			local defenceStaffingLab = ui.newTTFLabel({text = CommonText[661][4], font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 40, y = defencenextLab:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				defenceStaffingLab:setAnchorPoint(cc.p(0, 0.5))

			local defenceStaffingValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
				color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				defenceStaffingValue:setAnchorPoint(cc.p(0, 0.5))
			if report.result then
				defenceStaffingValue:setString("-" .. report.failStaffingExp)
				defenceStaffingValue:setColor(COLOR[6])
			else
				defenceStaffingValue:setString(report.failStaffingExp)
				defenceStaffingValue:setColor(COLOR[2])
			end
			defenceStaffingValue:setPosition(defenceStaffingLab:getPositionX() + defenceStaffingLab:getContentSize().width, defenceStaffingLab:getPositionY())
			posLab_ = defenceStaffingLab
		end
		
		local startY = posLab_:getPositionY()
		if defencer.tank then
			-- gdump(defencer.tank,"损失兵种")
			if #defencer.tank > 0 then
				for index=1,#defencer.tank do
					local tank = defencer.tank[index]
					local tankIcon = UiUtil.createItemSprite(ITEM_KIND_TANK, tank.tankId)
					-- tankIcon:setPosition(tankPos[index][1],tankPos[index][2])
					local x = 0
					local y = 0
					if index % 2 == 1 then
						x = 100
						y = startY - 80 * math.ceil(index/2)
					else
						x = 400
						y = startY - 80 * math.ceil(index/2)
					end

					tankIcon:setPosition(x, y)

					cell:addChild(tankIcon)
					local tankName = ui.newTTFLabel({text = UserMO.getResourceData(ITEM_KIND_TANK, tank.tankId).name .. "\n -" .. tank.count, font = G_FONT, size = FONT_SIZE_SMALL, 
						x = tankIcon:getPositionX() + tankIcon:getContentSize().width / 2, y = tankIcon:getPositionY() - 10, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
					tankName:setAnchorPoint(cc.p(0, 0.5))
				end
				posY = startY - 80 * math.ceil(#defencer.tank/2) - 80--tankPos[#defencer.tank][2] - 80
			else
				posY = defencenextLab:getPositionY() - 40

				local noFormationLab = ui.newTTFLabel({text = CommonText[1104], font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 40, y = defencenextLab:getPositionY() - 40, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				noFormationLab:setAnchorPoint(cc.p(0, 0.5))
					posY = posY - 40
			end
		end	

	end

	return cell
end

function ReportAirShipTableView:onCollectCallback(tag, sender)
	local keyId = sender.keyId
	local kind = self.mail.isCollections
	if self.mail.isCollections == MAIL_COLLECT_TYPE_NORMAL then
		kind = MAIL_COLLECT_TYPE_COLLECTED
	elseif self.mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
		kind = MAIL_COLLECT_TYPE_NORMAL
	end

	if kind == MAIL_COLLECT_TYPE_COLLECTED then
		local collectNum = MailMO.queryTotalCollectMails()
		if collectNum >= MailMO.mailCollectMax then
			Toast.show(CommonText[100031])
			return
		end
	end

	MailBO.CollectMial(keyId, kind, function (success)
		if success then
			self.mail = MailMO.queryMailByKeyId(keyId)
			if self.mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
				sender:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_collect_normal.png"))
				sender:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_collect_selected.png"))
			else
				sender:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_uncollect_normal.png"))
				sender:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_uncollect_selected.png"))
			end
			if self.mail.isCollections == MAIL_COLLECT_TYPE_NORMAL then
				Toast.show(CommonText[1634][2])
			elseif self.mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
				Toast.show(CommonText[1634][1])
			end
		end
	end)
end

function ReportAirShipTableView:onLocationCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.mail.moldId == 51 or self.mail.moldId == 53 then  -- 军事矿区
		local pos = StaffMO.decodePosition(sender.pos)

		UiDirector.clear()

		local HomeView = require("app.view.HomeView")
		local view = HomeView.new(MAIN_SHOW_MINE_AREA):push()
		view:getCurContainer():locate(pos.x, pos.y, true)
	else
		UiDirector.clear()

		local pos = WorldMO.decodePosition(sender.pos)
		Notify.notify(LOCAL_LOCATION_EVENT, {x = pos.x, y = pos.y})
	end
end

return ReportAirShipTableView
