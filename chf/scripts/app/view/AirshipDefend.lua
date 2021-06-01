--
-- Author: xiaoxing
-- Date: 2017-04-21 17:28:44
--
local ItemTableView = class("ItemTableView", TableView)

function ItemTableView:ctor(size,id)
	ItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.id = id
end

function ItemTableView:onEnter()
	ItemTableView.super.onEnter(self)
end

function ItemTableView:numberOfCells()
	return #self.m_list
end

function ItemTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ItemTableView:createCellAtIndex(cell, index)
	ItemTableView.super.createCellAtIndex(self, cell, index)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	local data = self.m_list[index]
	local head = UiUtil.createItemView(ITEM_KIND_PORTRAIT, data.portrait):addTo(cell):pos(150,self.m_cellSize.height / 2):scale(0.55)
	head.data = data

	UiUtil.createItemDetailButton(head, cell, true, handler(self, self.onArmyDetail))

	if index <= 3 then
		display.newSprite(IMAGE_COMMON.."sort_"..index..".png"):addTo(cell):pos(66,self.m_cellSize.height / 2)
	else
		UiUtil.label(index,36):addTo(cell):pos(66,self.m_cellSize.height / 2)
	end
	local t = UiUtil.label(CommonText[51]..":"..data.lordName, 22, cc.c3b(163, 194, 201)):addTo(cell):align(display.LEFT_CENTER, 220, 120)
	t = UiUtil.label(CommonText[995][3],nil,cc.c3b(154,154,154)):alignTo(t, -40, 1)
	UiUtil.label(data.tankCount):rightTo(t, 5)
	local t2 = UiUtil.label(CommonText[801][1]..":",nil,cc.c3b(154,154,154)):alignTo(t, 165)
	UiUtil.label(data.level):rightTo(t2, 5)
	local name,c = CommonText[985]
	if data.commander > 0 then
		local hb = HeroMO.queryHero(data.commander)
		name = hb.heroName
		c = COLOR[hb.star]
	end
	t = UiUtil.label(CommonText[1003][3]..":",nil,cc.c3b(154,154,154)):alignTo(t, -28, 1)
	UiUtil.label(name,nil,c):rightTo(t, 5)
	t2 = UiUtil.label(CommonText[281]..":",nil,cc.c3b(154,154,154)):alignTo(t, -28, 1)
	UiUtil.label(UiUtil.strNumSimplify(data.fight)):rightTo(t2, 5)

	if self.isOwner then
		local btnUp = UiUtil.button("btn_up.png", "btn_up.png", nil, handler(self, self.up), nil, 1)
		btnUp.index = index
		btnUp.data = data
		if index ~= 1 then
			cell:addButton(btnUp, 570, 90)
		end
		local btnDown = UiUtil.button("btn_down.png", "btn_down.png", nil, handler(self, self.down), nil, 1)
		btnDown.index = index
		btnDown.data = data
		if index ~= #self.m_list then
			cell:addButton(btnDown, 570, 40)
		end
	end
	return cell
end

function ItemTableView:up(tag,sender)
	ManagerSound.playNormalButtonSound()
	AirshipBO.setPlayerAttackSeq(sender.data.lordId, sender.data.armyKeyId, -1, true, self.id, function()
		tag = sender.index
		self.m_list[tag-1],self.m_list[tag] = self.m_list[tag],self.m_list[tag-1]
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
	end)
end

function ItemTableView:down(tag,sender)
	ManagerSound.playNormalButtonSound()
	AirshipBO.setPlayerAttackSeq(sender.data.lordId, sender.data.armyKeyId, 1, true, self.id, function()
			tag = sender.index
			self.m_list[tag+1],self.m_list[tag] = self.m_list[tag],self.m_list[tag+1]
			local offset = self:getContentOffset()
			self:reloadData()
			self:setContentOffset(offset)
		end)
end

function ItemTableView:onArmyDetail( sender )
	ManagerSound.playNormalButtonSound()

	local teamData = sender.data

	if self.id == nil or self.id <= 0 then
		return
	end

	local airshipId = self.id
	local lordId = teamData.lordId
	local armyKeyId = teamData.armyKeyId

	AirshipBO.asynGetAirshipGuardArmy(function ( army )
		local ReportArmyDetailView = require("app.view.ReportArmyDetailView")
		ReportArmyDetailView.new(army):push()
	end, airshipId, lordId, armyKeyId)
end

function ItemTableView:onExit()
	ItemTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

function ItemTableView:updateUI(data, isOwner)
	self.m_list = data
	self.isOwner = isOwner
	self:reloadData()
end
-----------------------------------------------------------------------
-----------------------------------------------------------------------
local AirshipDefend = class("AirshipDefend", UiNode)
function AirshipDefend:ctor(id)
	AirshipDefend.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	self.id = id
end

function AirshipDefend:onEnter()
	AirshipDefend.super.onEnter(self)
	-- 部队
	local ab = AirshipMO.queryShipById(self.id)
	self:setTitle(ab.name)
		
	self.data_ = nil
	AirshipBO.getAirshipGuard(self.id,function(data)
			self.data_ = data
			self:showUI(data)
		end)

	self.r_armyGuardHandler_ = Notify.register(LOCAL_AIRSHIP_TEAM_GUARD_EVENT,function ()
		self:showUI(self.data_)
	end)
end

function AirshipDefend:onExit()
	AirshipDefend.super.onExit(self)

	if self.r_armyGuardHandler_ then
		Notify.unregister(self.r_armyGuardHandler_)
		self.r_armyGuardHandler_ = nil
	end
end

function AirshipDefend:showUI(data)
	-- local bg = self:getBg()
	local airshipData = AirshipBO.ships_ and AirshipBO.ships_[self.id]

	if not self.container_ then
		local node = display.newNode():addTo(self:getBg())
		node:setContentSize(self:getBg():getContentSize())
		self.container_ = node
	end
	
	self.container_:removeAllChildren()

	local isOwner = false
	if airshipData.occupy and airshipData.occupy.lordId == UserMO.lordId_ then
		isOwner = true
	end

	local bg = self.container_

	local t = UiUtil.label(CommonText[1001][1]):addTo(bg):align(display.LEFT_CENTER, 45, bg:height() - 142)
	UiUtil.label(CommonText[1001][2]):alignTo(t, -30, 1)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(bg)
	line:setPreferredSize(cc.size(bg:width(), line:getContentSize().height))
	line:setPosition(bg:width() / 2, 150)
	local view = ItemTableView.new(cc.size(bg:width(),bg:height() - 190 - line:y()),self.id):addTo(bg):pos(0,line:y())
	view:updateUI(data, isOwner)
	local defenceBtn = UiUtil.button("btn_2_normal.png", "btn_2_selected.png", "btn_1_disabled.png", handler(self, self.defend), CommonText[1000][1]):addTo(bg):pos(bg:width()/2, 60)

	defenceBtn:setEnabled(ArmyMO.checkAirshpState(self.id))
end

-- 驻防
function AirshipDefend:defend(tag, sender)
	ManagerSound.playNormalButtonSound()
	AirshipBO.defendId = self.id
	require("app.view.FortressSettingView").new(ARMY_SETTING_AIRSHIP_DEFEND):push()
end

return AirshipDefend