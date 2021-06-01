--
-- Author: gf
-- Date: 2015-12-16 15:10:46
--

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local PartyBJoinTableView = class("PartyBJoinTableView", TableView)

function PartyBJoinTableView:ctor(size)
	PartyBJoinTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 60)
	self.m_list = PartyBattleMO.joinParty
end

function PartyBJoinTableView:onEnter()
	PartyBJoinTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_JOIN_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyBJoinTableView:numberOfCells()
	if #self.m_list > 0 and #self.m_list % 20 == 0 then
		return #self.m_list + 1
	else
		return #self.m_list
	end
end

function PartyBJoinTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyBJoinTableView:createCellAtIndex(cell, index)
	PartyBJoinTableView.super.createCellAtIndex(self, cell, index)

	if #self.m_list > 0 and #self.m_list % 20 and index == #self.m_list + 1 then
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_normal.png")
		normal:setPreferredSize(cc.size(self:getViewSize().width, 90))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_selected.png")
		selected:setPreferredSize(cc.size(self:getViewSize().width, 90))
		local getNextButton = MenuButton.new(normal, selected, nil, handler(self,self.getNextHandler)):addTo(cell)
		getNextButton:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 5)
		getNextButton.page = (index - 1) / 20
		getNextButton:setLabel(CommonText[577])

	else
		local data = self.m_list[index]
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, 2))

		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
		
		local level = ui.newTTFLabel({text = "LV." .. data.lv, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 50, y = 30, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

		local name = ui.newTTFLabel({text = data.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 168, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

		local num = ui.newTTFLabel({text = data.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 298, y = 30, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

		local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(data.fight), font = "fnt/num_2.fnt"}):addTo(bg)
		fightValue:setPosition(395,30)
	end


	return cell
end

function PartyBJoinTableView:getNextHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBattleBO.asynWarParties(function()
		Loading.getInstance():unshow()
		end, sender.page)
end

function PartyBJoinTableView:updateListHandler(event)
	-- gdump(event,"eventeventeventevent")
	-- local offset = self:getContentOffset()
	self:reloadData()
	if event.obj and event.obj.page > 0 then
		self:setContentOffset(cc.p(0,-event.obj.count * 60))
	end
end

function PartyBJoinTableView:onExit()
	PartyBJoinTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local PartyBJoinDialog = class("PartyBJoinDialog", Dialog)

function PartyBJoinDialog:ctor()
	PartyBJoinDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function PartyBJoinDialog:onEnter()
	PartyBJoinDialog.super.onEnter(self)
	
	self:setTitle(CommonText[798][1])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	
	local signLab = ui.newTTFLabel({text = CommonText[800][1], font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[11], x = 40, y = btm:getContentSize().height - 50}):addTo(btm)

	local signValue = ui.newTTFLabel({text = PartyBattleMO.joinPartyTotal, font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[2], x = signLab:getPositionX() + signLab:getContentSize().width / 2, y = btm:getContentSize().height - 50}):addTo(btm)

	local stateLab = ui.newTTFLabel({text = CommonText[800][2], font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[6], x = 40, y = btm:getContentSize().height - 80}):addTo(btm)

	
	
	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 110))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 430)

	local posX = {50,150,300,400}
	for index=1,#CommonText[801] do
		local title = ui.newTTFLabel({text = CommonText[801][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		title:setAnchorPoint(cc.p(0, 0.5))
	end


	local view = PartyBJoinTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.rankData_):addTo(tableBg)
	view:setPosition(0, 25)
	view:reloadData()

	
end


return PartyBJoinDialog