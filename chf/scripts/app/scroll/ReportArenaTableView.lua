--
-- Author: gf
-- Date: 2015-10-14 16:11:25
--

local ReportArenaTableView = class("ReportArenaTableView", TableView)

function ReportArenaTableView:ctor(size,  mail)
	ReportArenaTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	
	self.mail = mail

	local height = 400
	local report = self.mail.report_db_
	local defencer = report.defencer
	local attacker = report.attacker

	-- attacker.tank = {
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000}
	-- 	}

	-- defencer.tank = {
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000},
	-- 		{tankId = 1,count = 1000}
	-- 	}

	-- self.mail.award = {
	-- 	{type = 5,id = 1,count = 10,keyId = 1},
	-- 	{type = 5,id = 2,count = 10,keyId = 1},
	-- 	{type = 5,id = 2,count = 10,keyId = 1},
	-- 	{type = 5,id = 2,count = 10,keyId = 1},
	-- 	{type = 5,id = 2,count = 10,keyId = 1}
	-- }

	if attacker.tank and #attacker.tank > 0 then
		height = height + 280
	end
	if defencer.tank and #defencer.tank > 0 then
		height = height + 280
	end
	if self.mail.award and #self.mail.award > 0 then
		height = height + 280
	end


	self.m_cellSize = cc.size(size.width, height)
end

function ReportArenaTableView:reloadData()
	ReportArenaTableView.super.reloadData(self)
end

function ReportArenaTableView:numberOfCells()
	return 1
end

function ReportArenaTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ReportArenaTableView:createCellAtIndex(cell, index)
	ReportArenaTableView.super.createCellAtIndex(self, cell, index)

	local report = self.mail.report_db_
	-- gdump(report,"报告信息")

	local defencer = report.defencer
	local attacker = report.attacker

	local winStatus

	-- 战斗信息
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, self.m_cellSize.height - 30)

	local title = ui.newTTFLabel({text = CommonText[658][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	local posY
	for index=1,#CommonText[706] do
		local labTit = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		labTit:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then 
			if report.reportType == JJC_REPORT_TYPE_ATTACK then
				labTit:setString(string.format(CommonText[706][index][1],defencer.name))
			elseif report.reportType == JJC_REPORT_TYPE_DEFENCE then
				labTit:setString(string.format(CommonText[706][index][2],attacker.name))
			else
				labTit:setString(string.format(CommonText[706][index][3],attacker.name,defencer.name))
			end
		else
			labTit:setString(CommonText[706][index])
		end

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))
		

		if index == 1 then 
			--进攻目标
			-- local pos 
			-- if report.reportType == DEFENCE_TYPE_ATTACK_MINE then
			-- 	pos = WorldMO.decodePosition(defencer.pos)
			-- 	value:setString("LV." .. defencer.lv .. " " .. UserMO.getResourceData(ITEM_KIND_WORLD_RES, defencer.mine).name2 .. " (" .. pos.x  .. "," .. pos.y ..  ")")
			-- elseif report.reportType == DEFENCE_TYPE_ATTACK_MAN then
			-- 	pos = WorldMO.decodePosition(defencer.pos)
			-- 	local str = defencer.name .. " (" .. pos.x  .. "," .. pos.y ..  ")"
			-- 	if defencer.party then
			-- 		str = str .. " (" .. defencer.party .. ")"
			-- 	end
			-- 	value:setString(str)
			-- else
			-- 	pos = WorldMO.decodePosition(attacker.pos)
			-- 	local str = attacker.name .. " (" .. pos.x  .. "," .. pos.y ..  ")"
			-- 	if attacker.party then
			-- 		str = str .. " (" .. attacker.party .. ")"
			-- 	end
			-- 	value:setString(str)
			-- end
		elseif index == 2 then
			--战斗时间
			value:setString(os.date("%m-%d %X",self.mail.time))

		elseif index == 3 then
			--战斗结果
			if report.reportType == JJC_REPORT_TYPE_ATTACK or report.reportType == JJC_REPORT_TYPE_GLOBAL then
				if report.result then
					winStatus = true
					value:setString(CommonText[660][1])
					value:setColor(COLOR[2])
				else
					winStatus = false
					value:setString(CommonText[660][2])
					value:setColor(COLOR[6])
				end
			elseif report.reportType == JJC_REPORT_TYPE_DEFENCE then
				if report.result then
					winStatus = false
					value:setString(CommonText[660][4])
					value:setColor(COLOR[6])
				else
					winStatus = true
					value:setString(CommonText[660][3])
					value:setColor(COLOR[2])
				end
			end
			posY = labTit:getPositionY()
		end
	end

	-- 部队损失

	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, posY - 110)

	local title = ui.newTTFLabel({text = CommonText[658][4], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	--攻方损失
	local attackLab = ui.newTTFLabel({text = CommonText[661][1], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = bg:getPositionY() - 45, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		attackLab:setAnchorPoint(cc.p(0, 0.5))

	local attackValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = attackLab:getPositionX() + attackLab:getContentSize().width, y = attackLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		attackValue:setAnchorPoint(cc.p(0, 0.5))
	local str = attacker.name .. "  VIP" .. attacker.vip
	if report.first then
		str = str .. CommonText[663]
	end 
	attackValue:setString(str)

	local attackHeroLab = ui.newTTFLabel({text = CommonText[661][3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = attackValue:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		attackHeroLab:setAnchorPoint(cc.p(0, 0.5))

	local attackHeroValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = attackHeroLab:getPositionX() + attackHeroLab:getContentSize().width, y = attackHeroLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		attackHeroValue:setAnchorPoint(cc.p(0, 0.5))
	if attacker.hero > 0 then
		local heroInfo = HeroMO.queryHero(attacker.hero)
		attackHeroValue:setString(heroInfo.heroName)
	else
		attackHeroValue:setString(CommonText[108])
	end

	local attacknextLab = attackHeroLab
	-- 攻方军功
	if table.isexist(attacker,"mplt") then
		local attackMplt = ui.newTTFLabel({text = CommonText[1018] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = self.m_cellSize.width * 0.5, y = attacknextLab:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		attackMplt:setAnchorPoint(cc.p(0,0.5))
		attackMplt:setPosition(40 , attacknextLab:getPositionY() - 40)

		local attackMpltValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = attackMplt:getPositionX() + attackMplt:getContentSize().width + 10, y = attackMplt:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		attackMpltValue:setAnchorPoint(cc.p(0, 0.5))
		attackMpltValue:setString(attacker.mplt or "0")
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

	local tankPos = {
		{100,posLab_:getPositionY() - 80},
		{400,posLab_:getPositionY() - 80},
		{100,posLab_:getPositionY() - 160},
		{400,posLab_:getPositionY() - 160},
		{100,posLab_:getPositionY() - 240},
		{400,posLab_:getPositionY() - 240}
	}
	
	if attacker.tank and #attacker.tank > 0 then
		
		for index=1,#attacker.tank do
			local tank = attacker.tank[index]
			local tankIcon = UiUtil.createItemSprite(ITEM_KIND_TANK, tank.tankId)
			tankIcon:setPosition(tankPos[index][1],tankPos[index][2])
			cell:addChild(tankIcon)
			local tankName = ui.newTTFLabel({text = UserMO.getResourceData(ITEM_KIND_TANK, tank.tankId).name .. "\n -" .. tank.count, font = G_FONT, size = FONT_SIZE_SMALL, 
				x = tankIcon:getPositionX() + tankIcon:getContentSize().width / 2, y = tankIcon:getPositionY() - 10, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			tankName:setAnchorPoint(cc.p(0, 0.5))
		end
		posY = tankPos[#attacker.tank][2] - 80
	else
		if report.result then
			--攻方胜并且无损兵
			local perfectLab = ui.newTTFLabel({text = CommonText[664], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 40, y = posLab_:getPositionY() - 40, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			perfectLab:setAnchorPoint(cc.p(0, 0.5))
			posY = perfectLab:getPositionY() - 40
		else
			posY = posLab_:getPositionY() - 40
		end
	end

	--守方损失
	local defenceLab = ui.newTTFLabel({text = CommonText[661][2], font = G_FONT, size = FONT_SIZE_SMALL, 
			color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defenceLab:setAnchorPoint(cc.p(0, 0.5))
	defenceLab:setPosition(40,posY)

	local defenceValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = defenceLab:getPositionX() + defenceLab:getContentSize().width, y = defenceLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defenceValue:setAnchorPoint(cc.p(0, 0.5))

	defenceValue:setString(defencer.name)

	local defenceHeroLab = ui.newTTFLabel({text = CommonText[661][3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = defenceValue:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defenceHeroLab:setAnchorPoint(cc.p(0, 0.5))

	local defenceHeroValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = defenceHeroLab:getPositionX() + defenceHeroLab:getContentSize().width, y = defenceHeroLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defenceHeroValue:setAnchorPoint(cc.p(0, 0.5))
	if defencer.hero > 0 then
		local heroInfo = HeroMO.queryHero(defencer.hero)
		defenceHeroValue:setString(heroInfo.heroName)
	else
		defenceHeroValue:setString(CommonText[108])
	end

	local defencenextLab = defenceHeroLab
	-- 守方军功
	if table.isexist(defencer,"mplt") then
		local defenceMplt = ui.newTTFLabel({text = CommonText[1018] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = self.m_cellSize.width * 0.5, y = defencenextLab:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defenceMplt:setAnchorPoint(cc.p(0,0.5))
		defenceMplt:setPosition(40 , defencenextLab:getPositionY() - 40 )

		local defenceMpltValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
				x = defenceMplt:getPositionX() + defenceMplt:getContentSize().width + 10, y = defenceMplt:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defenceMpltValue:setAnchorPoint(cc.p(0, 0.5))
		defenceMpltValue:setString(defencer.mplt or "0")
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
	local tankPos = {
		{100,posLab_:getPositionY() - 80},
		{400,posLab_:getPositionY() - 80},
		{100,posLab_:getPositionY() - 160},
		{400,posLab_:getPositionY() - 160},
		{100,posLab_:getPositionY() - 240},
		{400,posLab_:getPositionY() - 240}
	}

	if defencer.tank then
		-- gdump(defencer.tank,"损失兵种")
		if #defencer.tank > 0 then
			for index=1,#defencer.tank do
				local tank = defencer.tank[index]
				local tankIcon = UiUtil.createItemSprite(ITEM_KIND_TANK, tank.tankId)
				tankIcon:setPosition(tankPos[index][1],tankPos[index][2])
				cell:addChild(tankIcon)
				local tankName = ui.newTTFLabel({text = UserMO.getResourceData(ITEM_KIND_TANK, tank.tankId).name .. "\n -" .. tank.count, font = G_FONT, size = FONT_SIZE_SMALL, 
					x = tankIcon:getPositionX() + tankIcon:getContentSize().width / 2, y = tankIcon:getPositionY() - 10, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				tankName:setAnchorPoint(cc.p(0, 0.5))
			end
			posY = tankPos[#defencer.tank][2] - 80
		else
			posY = posLab_:getPositionY() - 40
		end
	else
		if report.result then
			--攻方胜且防守方无损失
			local noFormationLab = ui.newTTFLabel({text = CommonText[665], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 40, y = posLab_:getPositionY() - 40, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			noFormationLab:setAnchorPoint(cc.p(0, 0.5))
			posY = noFormationLab:getPositionY() - 40
		else
			posY = posLab_:getPositionY() - 40
		end
	end


	--战利品
	if self.mail.award and #self.mail.award > 0 then
		local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
		bg:setAnchorPoint(cc.p(0, 0.5))
		bg:setPosition(20, posY - 40)

		local title = ui.newTTFLabel({text = CommonText[658][5], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

		local ReportRewardTableView = require("app.scroll.ReportRewardTableView")
		local view = ReportRewardTableView.new(cc.size(self.m_cellSize.width - 40, 140), self.mail.award, true, true):addTo(cell)
		view:setAnchorPoint(cc.p(0,0.5))
		view:setPosition(20 , bg:getPositionY() - bg:getContentSize().height * 0.5 - view:getContentSize().height * 0.5)
		-- for index=1,#self.mail.award do
		-- 	local award = self.mail.award[index]
		-- 	local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		-- 	-- itemView:setPosition(60 + itemView:getContentSize().width / 2 + (index - 1) * 200,bg:getPositionY() - 90)
		-- 	itemView:setScale(0.7)
		-- 	if index < 5 then
		-- 		itemView:setPosition(40 + itemView:getContentSize().width * 0.7 / 2 + (index - 1) * 140,bg:getPositionY() - 90)
		-- 	else
		-- 		gdump(math.ceil(index / 5))
		-- 		if index % 4 == 0 then
		-- 			itemView:setPositionX(40 + itemView:getContentSize().width * 0.7 / 2 + 4 * 140)
		-- 		else
		-- 			itemView:setPositionX(40 + itemView:getContentSize().width * 0.7 / 2 + (index % 4 - 1) * 120)
		-- 		end
		-- 		itemView:setPositionY(bg:getPositionY() - 90 - (math.ceil(index / 4) - 1) * 125)
		-- 	end

		-- 	cell:addChild(itemView)
		-- 	local propDB = UserMO.getResourceData(award.type, award.id)
		-- 	local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		-- 		x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		-- end
	end


	return cell
end


function ReportArenaTableView:onLocationCallback(tag, sender)
	UiDirector.clear()

	local pos = WorldMO.decodePosition(sender.pos)
	Notify.notify(LOCAL_LOCATION_EVENT, {x = pos.x, y = pos.y})
end

return ReportArenaTableView
