
-- 选择阵型弹出框

------------------------------------------------------------------------------
-- 选择阵型TableView
------------------------------------------------------------------------------
local AllFormationTableView = class("AllFormationTableView", TableView)

-- 当前的阵型
function AllFormationTableView:ctor(size, formation, viewFor, commanderLocked, lockedHero)
	AllFormationTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 176)
	self.m_formation = formation
	self.m_viewFor = viewFor
	self.m_commanderLocked = commanderLocked or false
	self.m_lockedHero = lockedHero
end

function AllFormationTableView:onEnter()
	AllFormationTableView.super.onEnter(self)
	self.ListModel = {FORMATION_FOR_TEMPLATE, FORMATION_FOR_TEMPLATE_2, FORMATION_FOR_TEMPLATE_3, FORMATION_FOR_TEMPLATE_4}
end

function AllFormationTableView:numberOfCells()
	return 4
end

function AllFormationTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function AllFormationTableView:createCellAtIndex(cell, index)
	AllFormationTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_19.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_21.jpg"):addTo(bg)
	titleBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 26)

	local formname = CommonText[52] .. index
	local info = TankMO.formation_[self.ListModel[index]]
	if table.isexist(info,"formName") then
		formname = info.formName
	end
	-- 阵型x
	local title = ui.newTTFLabel({text = formname, font = G_FONT, size = FONT_SIZE_TINY, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title.word = formname

	local function onEdit1(event, editbox)

	   if event == "return" then
	   		local outstr = editbox:getText()
	   		if string.utf8len(outstr) > 8 then
	   			Toast.show(string.format(CommonText[1081], 8))
	   			editbox:setText("")
	   			title:setString(title.word)
	   			return
	   		end
	   		if outstr ~= "" then
	   			title:setString(editbox:getText())
	   			title.word = title:getString()
	   		else
	   			title:setString(title.word)
	   		end
			editbox:setText("")
	   elseif event == "began" then
			editbox:setText(title:getString())
			title.word = title:getString()
			title:setString("")
	   end
    end

	local inputContent = ui.newEditBox({image = nil, listener = onEdit1, size = cc.size(180, 30)}):addTo(titleBg)
	inputContent:setAnchorPoint(cc.p(0.5,0.5))
	inputContent:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
	inputContent:setFontColor(cc.c3b(225, 255, 255))
	inputContent:setFontSize(FONT_SIZE_TINY)


	local needVip = FORAMTION_VIP_OPEN[index]
	if needVip <= UserMO.vip_ then -- 开启
		-- 覆盖
		local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
		local writerBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onWriterCallback))
		writerBtn:setLabel(CommonText[67])
		writerBtn.index = index
		writerBtn.title = title
		cell:addButton(writerBtn, 126, 70)

		-- 读取
		local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
		local readerBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onReaderCallback))
		readerBtn:setLabel(CommonText[68])
		readerBtn.index = index
		cell:addButton(readerBtn, self.m_cellSize.width - 126, 70)
	else
		-- 需要VIP开启
		local desc = ui.newTTFLabel({text = "VIP" .. needVip .. CommonText[50], font = G_FONT, size = FONT_SIZE_MEDIUM, color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		desc:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 20)
	end

	return cell
end

-- 用当前的阵型设置模块阵型
function AllFormationTableView:onWriterCallback(tag, sender)
	local index = sender.index
	local formname = sender.title:getString()

	local formationIndex = 0
	if self.ListModel[index] then
		formationIndex = self.ListModel[index]
	end

	if formationIndex > 0 then
		if not TankBO.hasFightFormation(self.m_formation) then
			-- 阵型为空，请设置阵型
			Toast.show(CommonText[193])
			return
		end

		Loading.getInstance():show()

		TankBO.asynSetForm(function()
				Loading.getInstance():unshow()
				Toast.show(CommonText[59])
			end,
			formationIndex, self.m_formation, nil, formname)
	end
end

-- 用模板阵型设置当前的阵型
function AllFormationTableView:onReaderCallback(tag, sender)
	local index = sender.index

	local formationIndex = 0
	if self.ListModel[index] then
		formationIndex = self.ListModel[index]
	end

	if formationIndex > 0 then
		local formation = TankMO.getFormationByType(formationIndex)
		-- dump(formation)

		if not TankBO.hasFightFormation(formation) then
			-- 阵型为空，请设置阵型
			Toast.show(CommonText[193])
			return
		end

		if self.m_viewFor ~= ARMY_SETTING_FOR_WORLD then
			if formation.commander >= 401 and formation.commander <= 410 then
				Toast.show(CommonText[2201])
				return
			end
		end

		if self.m_commanderLocked then
			if formation.commander ~= self.m_lockedHero.heroId then
				Toast.show(CommonText[2203])
				return
			end
		end

		if formation.commander and formation.commander > 0 then
			local hero = HeroMO.getHeroById(formation.commander)
			if hero and table.isexist(hero, "endTime") then
				local curTime = ManagerTimer.getTime()
				if hero.endTime > 0 and curTime >= hero.endTime then
					Toast.show(CommonText[2204])
					return
				end
			end
		end

		-- local formatOk, checkFormat = TankBO.checkFormation(formation)
		-- if not formatOk then
		-- 	-- 没有足够的坦克填充阵型
		-- 	Toast.show(CommonText[194])
		-- 	return
		-- end

		-- gdump(formation, "AllFormationTableView 读取的阵型是")
		
		self:dispatchEvent({name = "READER_FORMATION_EVENT", formation = formation})
	end
end

------------------------------------------------------------------------------
-- 选择阵型弹出框
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ChoseFormationDialog = class("ChoseFormationDialog", Dialog)

-- choseFormationCallback: 选择某个阵型读取，以设置当前阵型
function ChoseFormationDialog:ctor(formation, choseFormationCallback, viewFor, commanderLocked, lockedHero)
	ChoseFormationDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})

	gdump(formation, "[ChoseFormationDialog] ctor")
	self.m_formation = formation
	self.m_choseFormationCallback = choseFormationCallback
	self.m_viewFor = viewFor
	self.m_commanderLocked = commanderLocked or false
	self.m_lockedHero = lockedHero
end

function ChoseFormationDialog:onEnter()
	ChoseFormationDialog.super.onEnter(self)

	self:setTitle(CommonText[16])  -- 已保存阵型

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = AllFormationTableView.new(cc.size(526, 748), self.m_formation, self.m_viewFor, self.m_commanderLocked, self.m_lockedHero):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 44)
	view:addEventListener("READER_FORMATION_EVENT", function(event)
			local formation = clone(event.formation)
			if not HeroBO.canFormationFight(formation) then
				formation.commander = 0
			end

			local formatOk, checkFormat = TankBO.checkFormation(formation)
			local heroOk = HeroBO.canFormationFight(formation)
			if not formatOk then
				formation = checkFormat

				Toast.show(CommonText[194])  -- 没有足够的坦克填充阵型
			elseif not heroOk then
				Toast.show(CommonText[969])
			else
				Toast.show(CommonText[195])  -- 成功读取阵型
			end

			--检测战术
			if formation.tacticsKeyId and #formation.tacticsKeyId > 0 then
				formation.tacticsKeyId = TacticsMO.isTacticCanUse(formation)
			end
			Notify.notify(LOCAL_TACTICS_FORARMY, {formation = formation})
			if self.m_choseFormationCallback then
				self.m_choseFormationCallback(formation)
			end
			self:pop()
		end)
	view:reloadData()
end

return ChoseFormationDialog
