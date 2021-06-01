--
-- Author: gf
-- Date: 2015-12-17 18:46:20
-- 百团混战 个人战报

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local PartyBPersonalTableView = class("PartyBPersonalTableView", TableView)

function PartyBPersonalTableView:ctor(size)
	PartyBPersonalTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 90)
	self.m_list = PartyBattleBO.getPersonalReport()
end

function PartyBPersonalTableView:onEnter()
	PartyBPersonalTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_PROCESS_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyBPersonalTableView:numberOfCells()
	return #self.m_list
end

function PartyBPersonalTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyBPersonalTableView:createCellAtIndex(cell, index)
	PartyBPersonalTableView.super.createCellAtIndex(self, cell, index)

	local data = self.m_list[index]
		
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, 2))
	bg:setPosition(self.m_cellSize.width / 2, 0)
	
 	local timeLab = ui.newTTFLabel({text = os.date("%H:%M", data.time), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 65, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	timeLab:setAnchorPoint(cc.p(0.5, 0.5))

	--是否有最终名次
	-- if data.rank then
	-- 	if data.rank == 1 then
	-- 		--决出第一名
	-- 		local lab1 = ui.newTTFLabel({text = CommonText[810][1], font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 		x = 110, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 		lab1:setAnchorPoint(cc.p(0, 0.5))

	-- 		local lab2 = ui.newTTFLabel({text = data.partyName1, font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 		x = lab1:getPositionX() + lab1:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 		lab2:setAnchorPoint(cc.p(0, 0.5))

	-- 		local lab3 = ui.newTTFLabel({text = CommonText[810][2], font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 		x = lab2:getPositionX() + lab2:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 		lab3:setAnchorPoint(cc.p(0, 0.5))

	-- 	else
	-- 		--被淘汰
	-- 		local defPartyLab = ui.newTTFLabel({text = data.partyName2, font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 		x = 110, y = self.m_cellSize.height / 2, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 		defPartyLab:setAnchorPoint(cc.p(0, 0.5))

	-- 		local lab2 = ui.newTTFLabel({text = CommonText[811][1], font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 		x = defPartyLab:getPositionX() + defPartyLab:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 		lab2:setAnchorPoint(cc.p(0, 0.5)) 

	-- 		local atkPartyLab = ui.newTTFLabel({text = data.partyName1, font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 		x = lab2:getPositionX() + lab2:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 		atkPartyLab:setAnchorPoint(cc.p(0, 0.5))

	-- 		local lab3 = ui.newTTFLabel({text = string.format(CommonText[811][2],data.rank), font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 		x = atkPartyLab:getPositionX() + atkPartyLab:getContentSize().width, y = self.m_cellSize.height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- 		lab3:setAnchorPoint(cc.p(0, 0.5)) 
	-- 	end
	-- else
		local atkPartyLab = ui.newTTFLabel({text = data.partyName1, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 181, y = self.m_cellSize.height / 2 + 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		atkPartyLab:setAnchorPoint(cc.p(0.5, 0.5))

		local atkManLab = ui.newTTFLabel({text = data.name1 .. "(" .. data.hp1 .. "%)", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 181, y = self.m_cellSize.height / 2 - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		atkManLab:setAnchorPoint(cc.p(0.5, 0.5))

		--VS
		local vsLab = ui.newTTFLabel({text = "VS", font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 250, y = self.m_cellSize.height / 2, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		vsLab:setAnchorPoint(cc.p(0.5, 0.5))

		local defPartyLab = ui.newTTFLabel({text = data.partyName2, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 333, y = self.m_cellSize.height / 2 + 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defPartyLab:setAnchorPoint(cc.p(0.5, 0.5))

		local defManLab = ui.newTTFLabel({text = data.name2 .. "(" .. data.hp2 .. "%)", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 333, y = self.m_cellSize.height / 2 - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		defManLab:setAnchorPoint(cc.p(0.5, 0.5))
	-- end

	--战报按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_replay_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_replay_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_replay_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onPlayCallback))
	btn.index = index

	cell:addButton(btn, self.m_cellSize.width - 60, self.m_cellSize.height / 2)

	return cell
end

function PartyBPersonalTableView:onPlayCallback(tag, sender)
	local function doneCallback(rptAtkWar)
		Loading.getInstance():unshow()
		if not rptAtkWar then
			return
		end
		local atk = rptAtkWar.attacker
		if win then win = PbProtocol.decodeRecord(win) end
		local def = rptAtkWar.defencer
		if def then def = PbProtocol.decodeRecord(def) end
		BattleMO.setBothInfo(atk,def)
		require("app.view.BattleView").new():push()
	end

	Loading.getInstance():show()
	PartyBattleBO.asynGetWarFight(doneCallback,sender.index - 1)

end

function PartyBPersonalTableView:updateListHandler(event)
	-- local offset = self:getContentOffset()
	self.m_list = PartyBattleBO.getPersonalReport()
	self:reloadData()
	-- self:setContentOffset(offset)
end

function PartyBPersonalTableView:onExit()
	PartyBPersonalTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local PartyBPersonalDialog = class("PartyBPersonalDialog", Dialog)

function PartyBPersonalDialog:ctor()
	PartyBPersonalDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function PartyBPersonalDialog:onEnter()
	PartyBPersonalDialog.super.onEnter(self)
	
	self:setTitle(CommonText[806][3])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	
	local countLab = ui.newTTFLabel({text = CommonText[813], font = G_FONT, align = ui.TEXT_ALIGN_CENTER,
		size = FONT_SIZE_SMALL,color = COLOR[11], x = 40, y = btm:getContentSize().height - 50}):addTo(btm)
	countLab:setAnchorPoint(cc.p(0,0.5))

	local m_list = PartyBattleBO.getPersonalReport()

	local countValue = ui.newTTFLabel({text = #m_list, font = G_FONT, align = ui.TEXT_ALIGN_CENTER,
		size = FONT_SIZE_SMALL,color = COLOR[2], x = countLab:getPositionX() + countLab:getContentSize().width, y = btm:getContentSize().height - 50}):addTo(btm)
	countValue:setAnchorPoint(cc.p(0,0.5))
	self.countValue = countValue
	
	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 80))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 420)

	local posX = {50,150,300,390}
	for index=1,#CommonText[812] do
		local title = ui.newTTFLabel({text = CommonText[812][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		title:setAnchorPoint(cc.p(0, 0.5))
	end


	local view = PartyBPersonalTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.rankData_):addTo(tableBg)
	view:setPosition(0, 25)
	view:reloadData()

	self.m_updateViewHandler = Notify.register(LOCAL_PARTY_BATTLE_PROCESS_UPDATE_EVENT, handler(self, self.updateView))
end

function PartyBPersonalDialog:updateView()
	local m_list = PartyBattleBO.getPersonalReport()
	self.countValue:setString(#m_list)
end

function PartyBPersonalDialog:onExit()
	PartyBPersonalDialog.super.onExit(self)

	if self.m_updateViewHandler then
		Notify.unregister(self.m_updateViewHandler)
		self.m_updateViewHandler = nil
	end
end

return PartyBPersonalDialog