--
-- Author: gf
-- Date: 2015-09-18 18:26:18
-- 团本小关卡view


local PartyCombatLevelView = class("PartyCombatLevelView", UiNode)

function PartyCombatLevelView:ctor(sectionInfo)
	PartyCombatLevelView.super.ctor(self)

	self.sectionInfo = sectionInfo
end

function PartyCombatLevelView:onEnter()
	PartyCombatLevelView.super.onEnter(self)
	self.m_updateHandler = Notify.register(LOCAL_PARTY_COMBAT_UPDATE_EVENT, handler(self, self.onCombatUpdate))


	local PartyCombatLevelTableView = require("app.scroll.PartyCombatLevelTableView")
	local view = PartyCombatLevelTableView.new(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT), self.sectionInfo.sectionId):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2,
		(self:getBg():getContentSize().height - view:getContentSize().height) / 2)
	view:reloadData()
	self.m_tableView = view
	
	self.m_tableView:setContentOffset(self.m_tableView:maxContainerOffset())

	local top = display.newSprite(IMAGE_COMMON .. "info_bg_7.png"):addTo(self:getBg())
	top:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - top:getContentSize().height / 2)
	local name = ui.newTTFLabel({text = self.sectionInfo.combatName, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 190, y = top:getContentSize().height - 40, align = ui.TEXT_ALIGN_CENTER}):addTo(top)

	self:showStarInfo()
end

function PartyCombatLevelView:showStarInfo()
	if self.m_starNode then
		self.m_starNode:removeSelf()
	end

	local node = display.newNode():addTo(self:getBg())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getBg():getContentSize().width / 2, 0)
	self.m_starNode = node

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_6.png"):addTo(node)
	bg:setPreferredSize(cc.size(self:getBg():getContentSize().width, bg:getContentSize().height))
	bg:setPosition(0, bg:getContentSize().height / 2)

	-- 次数
	local leftLabel = ui.newTTFLabel({text = CommonText[282] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = 110, y = 38, align = ui.TEXT_ALIGN_CENTER}):addTo(node, 4)
	leftLabel:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = PartyCombatMO.combatCount_, font = G_FONT, size = FONT_SIZE_MEDIUM, x = leftLabel:getPositionX() + leftLabel:getContentSize().width, y = leftLabel:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(node, 4)
	count:setAnchorPoint(cc.p(0, 0.5))
	self.count = count

	local label = ui.newTTFLabel({text = "/" .. PARTY_COMBAT_COUNT_MAX, font = G_FONT, size = FONT_SIZE_MEDIUM, x = count:getPositionX() + count:getContentSize().width, y = count:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(node, 4)
	label:setAnchorPoint(cc.p(0, 0.5))
	
	local btm = display.newSprite(IMAGE_COMMON .. "bg_ui_btm.png"):addTo(node)
	btm:setPosition(0, btm:getContentSize().height / 2)
end

function PartyCombatLevelView:onExit()
	PartyCombatLevelView.super.onExit(self)
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end



function PartyCombatLevelView:onCombatUpdate()
	local offset = self.m_tableView:getContentOffset()
	self.m_tableView:reloadData()
	self.m_tableView:setContentOffset(offset)
	self.count:setString(PartyCombatMO.combatCount_)
	-- 显示奖励
	if CombatMO.curBattleAward_ then
		UiUtil.showAwards(CombatMO.curBattleAward_)
		CombatMO.curBattleAward_ = nil
	end
end




return PartyCombatLevelView
