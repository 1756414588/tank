--
-- Author: gf
-- Date: 2015-09-19 15:28:13
--

local ReportAttackTableView = class("ReportAttackTableView", TableView)

function ReportAttackTableView:ctor(size,  mail, readStatus)
	ReportAttackTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	

	self.mail = mail
	self.readStatus = readStatus

	local height = 1100
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
	if report.award and #report.award > 0 then
		height = height + 280
	end


	self.m_cellSize = cc.size(size.width, height)
end

function ReportAttackTableView:reloadData()
	ReportAttackTableView.super.reloadData(self)
end

function ReportAttackTableView:numberOfCells()
	return 1
end

function ReportAttackTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ReportAttackTableView:createCellAtIndex(cell, index)
	ReportAttackTableView.super.createCellAtIndex(self, cell, index)

	local report = self.mail.report_db_
	-- gdump(report,"报告信息")

	local defencer = report.defencer
	local attacker = report.attacker
	local isRebel = defencer.mine and defencer.mine < 0

	local winStatus

	if report.reportType == DEFENCE_TYPE_ATTACK_MAN or report.reportType == DEFENCE_TYPE_ATTACK_MINE then
		if report.result then
			winStatus = true
		else
			winStatus = false
		end
	else
		if report.result then
			winStatus = false
		else
			winStatus = true
		end
	end

	gdump(self.mail, "ReportAttackTableView..mail===")
	gdump(report,"ReportAttackTableView..report===")
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
	for index=1,#CommonText[659] do
		local labTit = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		labTit:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then 
			if report.reportType == DEFENCE_TYPE_ATTACK_MAN or report.reportType == DEFENCE_TYPE_ATTACK_MINE then
				labTit:setString(CommonText[659][index][1])
			else
				labTit:setString(CommonText[659][index][2])
			end
		elseif index == 5 then
			if winStatus then
				labTit:setString(CommonText[659][index][1])
			else
				labTit:setString(CommonText[659][index][2])
			end
		else
			labTit:setString(CommonText[659][index])
		end

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))
		

		if index == 1 then 
			--进攻目标
			if report.reportType == DEFENCE_TYPE_ATTACK_MINE then
				if self.mail.moldId == 53 or self.mail.moldId == 51 or self.mail.moldId == 100 or self.mail.moldId == 101 then  -- 军事矿区
					pos = StaffMO.decodePosition(defencer.pos)
				elseif self.mail.moldId == 166 or self.mail.moldId == 169 then	--	跨服军事矿区
					pos = StaffMO.decodeCrossPosition(defencer.pos)
				else
					pos = WorldMO.decodePosition(defencer.pos)
				end

				local str = ""
				--攻击的矿点有人
				if defencer.name and defencer.name ~= "" then
					if self.mail.moldId == 166 or self.mail.moldId == 169 then --跨服军事矿区中的要加上服务器名称
						if table.isexist(defencer, "serverName") then
							str = str .. "(" .. defencer.serverName .. ") "
						end
						-- gdump(report, "report=================")
					end
					str = str .. defencer.name
					if not self.readStatus then
						str = str .. " (" .. pos.x  .. "," .. pos.y ..  ")"
					end
					if defencer.party and defencer.party ~= "" then
						str = str .. " (" .. defencer.party .. ")"
					end
				else
					if self.mail.moldId == 53 or self.mail.moldId == 166 or self.mail.moldId == 169 then  -- 军事矿区 或 跨服军事矿区
						str = "LV." .. defencer.lv .. " " .. UserMO.getResourceData(ITEM_KIND_MILITARY_MINE, defencer.mine).name2
					elseif isRebel then
						if defencer.mine == -2 then
							str = "LV." .. defencer.lv .. " " ..RebelMO.getTeamById(defencer.hero).name
						else
							local rd = RebelMO.queryHeroById(defencer.hero)
							str = "LV." .. defencer.lv .. " " ..HeroMO.queryHero(rd.associate).heroName
						end
					else
						str = "LV." .. defencer.lv .. " " .. UserMO.getResourceData(ITEM_KIND_WORLD_RES, defencer.mine).name2
					end
					if not self.readStatus then
						str = str .. " (" .. pos.x  .. "," .. pos.y ..  ")"
					end
				end
				value:setString(str)
			elseif report.reportType == DEFENCE_TYPE_ATTACK_MAN then
				pos = WorldMO.decodePosition(defencer.pos)
				local str = defencer.name
				if not self.readStatus then
					str = str .. " (" .. pos.x  .. "," .. pos.y ..  ")"
				end
				if defencer.party and defencer.party ~= "" then
					str = str .. " (" .. defencer.party .. ")"
				end
				value:setString(str)
			elseif report.reportType == DEFENCE_TYPE_DEFENCE_MINE then
				-- gdump(self.mail, "self.mail=========================")
				-- if self.mail.moldId == 51 or self.mail.moldId == 98 or self.mail.moldId == 100 then -- 军事矿区
				-- 	pos = StaffMO.decodePosition(attacker.pos)
				-- if self.mail.moldId == 167 or self.mail.moldId == 168 then	--	跨服军事矿区
					-- pos = StaffMO.decodeCrossPosition(attacker.pos)
				-- else
					pos = WorldMO.decodePosition(attacker.pos)
					local str = ""
					if self.mail.moldId == 167 or self.mail.moldId == 168 then	--跨服军事矿区中的要加上服务器名称
						if table.isexist(attacker, "serverName") then
							str = str .. "(" .. attacker.serverName .. ") "
						end
					end
					str = str .. attacker.name
					if not self.readStatus and self.mail.moldId ~= 167 and self.mail.moldId ~= 168 then
						str = str .. " (" .. pos.x  .. "," .. pos.y ..  ")"
					end
					if attacker.party and attacker.party ~= "" then
						str = str .. " (" .. attacker.party .. ")"
					end
					value:setString(str)
				-- end			
			else
				pos = WorldMO.decodePosition(attacker.pos)
				local str = attacker.name
				if not self.readStatus then
					str = str .. " (" .. pos.x  .. "," .. pos.y ..  ")"
				end
				if attacker.party and attacker.party ~= "" then
					str = str .. " (" .. attacker.party .. ")"
				end
				value:setString(str)
			end
		elseif index == 2 then
			if self.mail.moldId == 53 or self.mail.moldId == 166 or self.mail.moldId == 169 then  -- 军事矿区 或跨服军事矿区
				if report.reportType == DEFENCE_TYPE_ATTACK_MINE or report.reportType == DEFENCE_TYPE_DEFENCE_MINE then
					value:setString("LV." .. defencer.lv .. " " .. UserMO.getResourceData(ITEM_KIND_MILITARY_MINE, defencer.mine).name2)
				end
			else
				if report.reportType == DEFENCE_TYPE_ATTACK_MINE or report.reportType == DEFENCE_TYPE_DEFENCE_MINE then
					local str = ""
					if isRebel then
						if defencer.mine == -2 then
							str = "LV." .. defencer.lv .. " " ..RebelMO.getTeamById(defencer.hero).name
						else
							local rd = RebelMO.queryHeroById(defencer.hero)
							str = "LV." .. defencer.lv .. " " ..HeroMO.queryHero(rd.associate).heroName
						end
					else
						str = "LV." .. defencer.lv .. " " .. UserMO.getResourceData(ITEM_KIND_WORLD_RES, defencer.mine).name2
					end
					value:setString(str)
				else
					--战斗地点
					local pos = WorldMO.decodePosition(defencer.pos)
					local str = defencer.name

					if not self.readStatus then
						str = str .. " (" .. pos.x  .. "," .. pos.y ..  ")"
					end
					if defencer.party and defencer.party ~= "" then
						str = str .. " (" .. defencer.party .. ")"
					end
					value:setString(str)
				end
			end
		elseif index == 3 then
			--战斗时间
			value:setString(os.date("%m-%d %X",self.mail.report_db_.time))
		elseif index == 4 then
			--战斗结果
			if report.reportType == DEFENCE_TYPE_ATTACK_MAN or report.reportType == DEFENCE_TYPE_ATTACK_MINE then
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
		elseif index == 5 then
			--获得荣誉
			if winStatus then
				value:setColor(COLOR[2])
			else
				value:setColor(COLOR[6])
			end
			value:setString(report.honour)
			
		elseif index == 6 then
			--据点驻军
			if report.friend then
				value:setString(report.friend)
			else
				value:setString(CommonText[108])
				value:setColor(COLOR[6])
			end
			posY = labTit:getPositionY()
		end
	end

	-- 城市繁荣
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, posY - 50)

	local title = ui.newTTFLabel({text = CommonText[658][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	
	local attackLab = ui.newTTFLabel({text = CommonText[661][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	attackLab:setAnchorPoint(cc.p(0, 0.5))

	local attackValue = ui.newTTFLabel({text = attacker.name, font = G_FONT, size = FONT_SIZE_SMALL, x = attackLab:getPositionX() + attackLab:getContentSize().width, y = attackLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	attackValue:setAnchorPoint(cc.p(0, 0.5))

	--攻方图片
	-- local attackBuild = display.newSprite("image/build/build_1.png"):addTo(cell)
	-- attackBuild:setScale(0.6)
	-- attackBuild:setPosition(attackValue:getPositionX() - 20,attackValue:getPositionY() - attackBuild:getContentSize().height / 2 * 0.6 - 40)
    -- 建筑
    local level = WorldMO.getBuildLevelByProps(attacker.pros, attacker.prosMax)
    local attackBuild = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, WORLD_ID_BUILD, {level = level}):addTo(cell)
    attackBuild:setScale(math.min(160 / attackBuild:getContentSize().width, 130 / attackBuild:getContentSize().height))
    -- attackBuild:setAnchorPoint(cc.p(0.5, 0))
    attackBuild:setPosition(attackValue:getPositionX() - 20,attackValue:getPositionY() - attackBuild:getContentSize().height / 2 * attackBuild:getScale() - 40)

	--攻方繁荣度

	--进度条
	local node = UiUtil.showProsValue(attacker.pros, attacker.prosMax)
	node:setPosition(150,attackBuild:getPositionY() + 50)
	cell:addChild(node)
	local bar = UiUtil.showProsBar(attacker.pros, attacker.prosMax)
	bar:setPosition(node:getPositionX() + node:getContentSize().width / 2,node:getPositionY() - 6)
	cell:addChild(bar)

	--繁荣度变化
	local prosAddValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = bar:getPositionY() -20,align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	prosAddValue:setAnchorPoint(cc.p(0, 0.5))
	if attacker.prosAdd > 0 then
		prosAddValue:setString(attacker.prosAdd)
		prosAddValue:setColor(COLOR[2])
	elseif attacker.prosAdd < 0 then
		prosAddValue:setString(attacker.prosAdd)
		prosAddValue:setColor(COLOR[6])
	end

	if self.mail.moldId == 51 or self.mail.moldId == 53 or self.mail.moldId == 166 or self.mail.moldId == 167 or self.mail.moldId == 168 or self.mail.moldId == 169 then  -- 军事矿区 和 跨服军事矿区
	else
		local normal = display.newSprite(IMAGE_COMMON .. "btn_store_go_normal.png")
	    local selected = display.newSprite(IMAGE_COMMON .. "btn_store_go_selected.png")
	    local locationBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.onLocationCallback))
	    locationBtn.pos = attacker.pos
	    locationBtn:setVisible(not self.readStatus)
	    cell:addButton(locationBtn, attackBuild:getPositionX() + 160, attackBuild:getPositionY() - 20)
	end

	local defenceLab = ui.newTTFLabel({text = CommonText[661][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 350, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	defenceLab:setAnchorPoint(cc.p(0, 0.5))

	local defenceValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = defenceLab:getPositionX() + defenceLab:getContentSize().width, y = defenceLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	defenceValue:setAnchorPoint(cc.p(0, 0.5))

	--守方图片
	local defenceBuild = nil
	if self.mail.moldId == 53 or self.mail.moldId == 51  or self.mail.moldId == 166 or self.mail.moldId == 167 then  -- 军事矿区 和 跨服军事矿区
		defenceValue:setString("LV." .. defencer.lv .. " " .. UserMO.getResourceData(ITEM_KIND_MILITARY_MINE, defencer.mine).name2)
		
		defenceBuild = UiUtil.createItemSprite(ITEM_KIND_MILITARY_MINE, defencer.mine):addTo(cell)
		defenceBuild:setPosition(defenceValue:getPositionX() - 20,attackBuild:getPositionY())
	else
		if report.reportType == DEFENCE_TYPE_ATTACK_MAN or report.reportType == DEFENCE_TYPE_DEFENCE_MAN then
			defenceValue:setString(defencer.name)

			-- 建筑
			local level = WorldMO.getBuildLevelByProps(defencer.pros, defencer.prosMax)
		    defenceBuild = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, WORLD_ID_BUILD, {level = level}):addTo(cell)
		    defenceBuild:setScale(math.min(160 / defenceBuild:getContentSize().width, 130 / defenceBuild:getContentSize().height))
		    -- defenceBuild:setAnchorPoint(cc.p(0.5, 0))
		    defenceBuild:setPosition(defenceValue:getPositionX() - 20,attackBuild:getPositionY())

			--进度条
			--攻方繁荣度

			--进度条
			local node = UiUtil.showProsValue(defencer.pros, defencer.prosMax)
			node:setPosition(450,defenceBuild:getPositionY() + 50)
			cell:addChild(node)
			local bar = UiUtil.showProsBar(defencer.pros, defencer.prosMax)
			bar:setPosition(node:getPositionX() + node:getContentSize().width / 2,node:getPositionY() - 6)
			cell:addChild(bar)

			--繁荣度变化
			local prosAddValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 450, y = bar:getPositionY() - 20,align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			prosAddValue:setAnchorPoint(cc.p(0, 0.5))

			if defencer.prosAdd > 0 then
				prosAddValue:setString(defencer.prosAdd)
				prosAddValue:setColor(COLOR[2])
			elseif defencer.prosAdd < 0 then
				prosAddValue:setString(defencer.prosAdd)
				prosAddValue:setColor(COLOR[6])
			end
		else
			local str = ""
			if isRebel then
				if defencer.mine == -2 then
					str = "LV." .. defencer.lv .. " " ..RebelMO.getTeamById(defencer.hero).name
					defenceBuild = UiUtil.createItemView(ITEM_KIND_PORTRAIT, 0):scale(0.6)
				else
					local rd = RebelMO.queryHeroById(defencer.hero)
					str = "LV." .. defencer.lv .. " " ..HeroMO.queryHero(rd.associate).heroName
					defenceBuild = UiUtil.createItemSprite(ITEM_KIND_HERO, rd.associate):addTo(cell):scale(0.7)
				end
			else
				str = "LV." .. defencer.lv .. " " .. UserMO.getResourceData(ITEM_KIND_WORLD_RES, defencer.mine).name2
				defenceBuild = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, defencer.mine, {level = defencer.lv}):addTo(cell)
			end
			defenceValue:setString(str)
			defenceBuild:setPosition(defenceValue:getPositionX() - 20,attackBuild:getPositionY())
		end
	end

    local normal = display.newSprite(IMAGE_COMMON .. "btn_store_go_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_store_go_selected.png")
    local locationBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.onLocationCallback))
    locationBtn.pos = defencer.pos
    locationBtn:setVisible(not self.readStatus)
    cell:addButton(locationBtn, defenceBuild:getPositionX() + 160, defenceBuild:getPositionY() - 20)

    posY = locationBtn:getPositionY()

    -- 资源信息
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, posY - 90)

	local title = ui.newTTFLabel({text = CommonText[658][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local resLab = ui.newTTFLabel({text = CommonText[662], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 40, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	resLab:setAnchorPoint(cc.p(0, 0.5))

	local resValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = resLab:getPositionX() + resLab:getContentSize().width, y = resLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	resValue:setAnchorPoint(cc.p(0, 0.5))

	if report.reportType == DEFENCE_TYPE_ATTACK_MINE then
		-- 如果是炸矿
		if table.isexist(report, "grabScore") then
			local grabScore = report.grabScore
			local resTitleLabel = ui.newTTFLabel({text = CommonText[2110][1], font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 230, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			resTitleLabel:setAnchorPoint(cc.p(0, 0.5))

			local resValueLabel = ui.newTTFLabel({text = UiUtil.strNumSimplify(grabScore), font = G_FONT, size = FONT_SIZE_SMALL, 
					x = resTitleLabel:getPositionX() + resTitleLabel:getContentSize().width, y = resTitleLabel:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			resValueLabel:setAnchorPoint(cc.p(0, 0.5))
		end
		local grabGold = 0
		if table.isexist(report, "honourGoldWin") then
			grabGold = grabGold + report.honourGoldWin
		end
		if table.isexist(report, "plunderGold") then
			grabGold = grabGold + report.plunderGold
		end
		if grabGold > 0 then
			local resTitleLabel = ui.newTTFLabel({text = CommonText[2110][2], font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 400, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			resTitleLabel:setAnchorPoint(cc.p(0, 0.5))

			local resValueLabel = ui.newTTFLabel({text = UiUtil.strNumSimplify(grabGold), font = G_FONT, size = FONT_SIZE_SMALL, 
					x = resTitleLabel:getPositionX() + resTitleLabel:getContentSize().width, y = resTitleLabel:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			resValueLabel:setAnchorPoint(cc.p(0, 0.5))
		end
	elseif report.reportType == DEFENCE_TYPE_DEFENCE_MINE then
		if table.isexist(report, "grabScore") then
			local grabScore = report.grabScore
			local resTitleLabel = ui.newTTFLabel({text = CommonText[2110][1], font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 230, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			resTitleLabel:setAnchorPoint(cc.p(0, 0.5))

			local resValueLabel = ui.newTTFLabel({text = "-" .. UiUtil.strNumSimplify(grabScore), font = G_FONT, size = FONT_SIZE_SMALL, 
					x = resTitleLabel:getPositionX() + resTitleLabel:getContentSize().width, y = resTitleLabel:getPositionY(), color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			resValueLabel:setAnchorPoint(cc.p(0, 0.5))
		end

		local grabGold = 0
		if table.isexist(report, "honourGoldFail") then
			grabGold = grabGold + report.honourGoldFail
		end
		if table.isexist(report, "defPlunderGold") then
			grabGold = grabGold + report.defPlunderGold
		end
		if grabGold > 0 then
			local resTitleLabel = ui.newTTFLabel({text = CommonText[2110][2], font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 400, y = bg:getPositionY() - 45 - (index - 1) * 40, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			resTitleLabel:setAnchorPoint(cc.p(0, 0.5))

			local resValueLabel = ui.newTTFLabel({text = "-" .. UiUtil.strNumSimplify(grabGold), font = G_FONT, size = FONT_SIZE_SMALL, 
					x = resTitleLabel:getPositionX() + resTitleLabel:getContentSize().width, y = resTitleLabel:getPositionY(), color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			resValueLabel:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	local text
	local color
	local grabList,grabCount
	grabList,grabCount = MailBO.parseGrab(report.grab)
	if (report.reportType == DEFENCE_TYPE_DEFENCE_MAN or report.reportType == DEFENCE_TYPE_DEFENCE_MINE) and grabCount > 0 then
		text = CommonText[1875]
		color = COLOR[6]
		resValue:setString("-" .. UiUtil.strNumSimplify(grabCount))
		resValue:setColor(COLOR[6])
	else
		text = CommonText[1872]
		color = COLOR[2]
		resValue:setString(UiUtil.strNumSimplify(grabCount))
	end

	--友好度加成
	if report.friendliness and report.friendliness > 0 then
		local calculation = SocialityMO.getPlunderByFriendliness(report.friendliness)
		if calculation > 0 then --如果比0大才显示
			local tips = UiUtil.label(CommonText[1845]):rightTo(resLab, 110)
			local value = UiUtil.label(report.friendliness,nil,color):rightTo(tips)
			local addLab = UiUtil.label(text):rightTo(value)
			local addvalue = UiUtil.label(calculation.."%",nil,color):rightTo(addLab)
		end
	end

	-- gdump(grabList,"grabListgrabListgrabList")
	for index=1,#grabList do
		local icon = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, grabList[index].id)
		icon:setScale(0.4)
		cell:addChild(icon)
		icon:setPosition(40 + icon:getContentSize().width * 0.4 / 2 + (index - 1) * 110,resLab:getPositionY() - 45)
		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = icon:getPositionX() + icon:getContentSize().width * 0.3 / 2 + 5, y = icon:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))
		if (report.reportType == DEFENCE_TYPE_DEFENCE_MAN or report.reportType == DEFENCE_TYPE_DEFENCE_MINE) and grabList[index].count > 0 then
			value:setString("-" .. UiUtil.strNumSimplify(grabList[index].count))
			value:setColor(COLOR[6])
		else
			value:setString(UiUtil.strNumSimplify(grabList[index].count))
		end
	end
	posY = resLab:getPositionY()

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

	--攻方将领
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

	if RoyaleSurviveMO.isActOpen() then
		if report.reportType == DEFENCE_TYPE_ATTACK_MINE then
			if table.isexist(report, "demageScore") then
				local demageScore = report.demageScore
				local attackMplt = ui.newTTFLabel({text = CommonText[2111] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = self.m_cellSize.width, y = attackHeroLab:getPositionY() - 40, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				attackMplt:setAnchorPoint(cc.p(0,0.5))
				attackMplt:setPosition(40 + 200 , attackHeroLab:getPositionY() - 40)

				local attackMpltValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = attackMplt:getPositionX() + attackMplt:getContentSize().width + 10, y = attackMplt:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				attackMpltValue:setAnchorPoint(cc.p(0, 0.5))
				attackMpltValue:setString(string.format("%d", demageScore))
			end
		elseif report.reportType == DEFENCE_TYPE_ATTACK_MAN then
			if table.isexist(report, "demageScore") then
				local demageScore = report.demageScore
				local attackMplt = ui.newTTFLabel({text = CommonText[2111] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = self.m_cellSize.width, y = attackHeroLab:getPositionY() - 40, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				attackMplt:setAnchorPoint(cc.p(0,0.5))
				attackMplt:setPosition(40 + 200 , attackHeroLab:getPositionY() - 40)

				local attackMpltValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
					x = attackMplt:getPositionX() + attackMplt:getContentSize().width + 10, y = attackMplt:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				attackMpltValue:setAnchorPoint(cc.p(0, 0.5))
				attackMpltValue:setString(string.format("%d", demageScore))
			end
		end
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
				x = expLabel and expLabel:x()+expLabel:width() + 10 or 40, y = attacknextLab:getPositionY() - 40, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			perfectLab:setAnchorPoint(cc.p(0, 0.5))
			posY = perfectLab:getPositionY() - 40
		else
			posY = attacknextLab:getPositionY() - 40
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
	local str = ""
	if report.reportType == DEFENCE_TYPE_ATTACK_MAN or report.reportType == DEFENCE_TYPE_DEFENCE_MAN then
		str = defencer.name .. "  VIP" .. defencer.vip
	else
		if defencer.name and defencer.name ~= "" then
			str = defencer.name .. "  VIP" .. defencer.vip
		else
			if isRebel then
				if defencer.mine == -2 then
					str = "LV." .. defencer.lv .. " " ..RebelMO.getTeamById(defencer.hero).name
				else
					local rd = RebelMO.queryHeroById(defencer.hero)
					str = "LV." .. defencer.lv .. " " ..HeroMO.queryHero(rd.associate).heroName
				end
			else
				str = "LV." .. defencer.lv .. " " .. UserMO.getResourceData(ITEM_KIND_WORLD_RES, defencer.mine).name2
			end
		end
	end
	if not report.first then
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
	if defencer.hero > 0 then
		if defencer.mine == -2 then
			defenceHeroValue:setString(CommonText[108])
		else
			local id = defencer.hero
			if isRebel then
				id = RebelMO.queryHeroById(defencer.hero).associate
			end
			local heroInfo = HeroMO.queryHero(id)
			defenceHeroValue:setString(heroInfo.heroName)
		end
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
			posY = defencenextLab:getPositionY() - 40

			if report.result then
				--攻方胜且防守方无损失
				local noFormationLab = ui.newTTFLabel({text = CommonText[665], font = G_FONT, size = FONT_SIZE_SMALL, 
					x = 40, y = defencenextLab:getPositionY() - 40, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				noFormationLab:setAnchorPoint(cc.p(0, 0.5))
					posY = posY - 40
			end
		end
	else
		
	end


	--战利品
	if report.award and #report.award > 0 then
		local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
		bg:setAnchorPoint(cc.p(0, 0.5))
		bg:setPosition(20, posY - 40)

		local title = ui.newTTFLabel({text = CommonText[658][5], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

		--奖励列表
		local ReportRewardTableView = require("app.scroll.ReportRewardTableView")
		local view = ReportRewardTableView.new(cc.size(self.m_cellSize.width - 40, 140), report.award, true,true):addTo(cell,0)
		view:setAnchorPoint(cc.p(0,0.5))
		view:setPosition(20 , bg:getPositionY() - bg:getContentSize().height * 0.5 - view:getContentSize().height * 0.5)
		-- for index=1,#report.award do
		-- 	local award = report.award[index]
		-- 	local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		-- 	itemView:setScale(award.type == ITEM_KIND_HERO and 0.48 or 0.7)
		-- 	if itemView.heroName_ then itemView.heroName_:removeSelf() itemView.heroName_ = nil end
		-- 	UiUtil.createItemDetailButton(itemView,cell,true)
		-- 	if index < 5 then
		-- 		itemView:setPosition(40 + itemView:getContentSize().width * 0.7 / 2 + (index - 1) * 140,bg:getPositionY() - 70)
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
		-- 		x = itemView:getPositionX(), y = itemView:getPositionY() - 50, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		-- end
	end


	return cell
end

function ReportAttackTableView:onCollectCallback(tag, sender)
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

function ReportAttackTableView:onLocationCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.mail.moldId == 51 or self.mail.moldId == 53 or self.mail.moldId == 101 or self.mail.moldId == 100 then  -- 军事矿区
		local pos = StaffMO.decodePosition(sender.pos)

		UiDirector.clear()

		local HomeView = require("app.view.HomeView")
		local view = HomeView.new(MAIN_SHOW_MINE_AREA):push()
		view:getCurContainer():locate(pos.x, pos.y, true)
	elseif self.mail.moldId == 166 or self.mail.moldId == 167 or self.mail.moldId == 168 or self.mail.moldId == 169 then  -- 跨服军事矿区
		local pos = StaffMO.decodeCrossPosition(sender.pos)

		UiDirector.clear()

		local HomeView = require("app.view.HomeView")
		local view = HomeView.new(MAIN_SHOW_CROSSSERVER_MINE_AREA):push()
		view:getCurContainer():locate(pos.x, pos.y, true)
	else
		UiDirector.clear()

		local pos = WorldMO.decodePosition(sender.pos)
		Notify.notify(LOCAL_LOCATION_EVENT, {x = pos.x, y = pos.y})
	end
end

return ReportAttackTableView
