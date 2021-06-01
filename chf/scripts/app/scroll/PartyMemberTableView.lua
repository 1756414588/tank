--
-- Author: gf
-- Date: 2015-09-17 20:14:35
--

local PartyMemberTableView = class("PartyMemberTableView", TableView)

function PartyMemberTableView:ctor(size,type)
	PartyMemberTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 110)
	self.type = type
end

function PartyMemberTableView:onEnter()
	PartyMemberTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_MEMBER_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyMemberTableView:numberOfCells()
	return #PartyMO.partyData_.partyMember
end

function PartyMemberTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyMemberTableView:createCellAtIndex(cell, index)
	PartyMemberTableView.super.createCellAtIndex(self, cell, index)

	local member = PartyMO.partyData_.partyMember[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 105))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	
	local rankTitle = ArenaBO.createRank(member.rank)
	rankTitle:setPosition(45, bg:getContentSize().height / 2)
	bg:addChild(rankTitle)

	-- 头像
	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, member.icon):addTo(bg)
	itemView:setScale(0.45)
	itemView:setPosition(130, bg:getContentSize().height - 55)
	
	local name = ui.newTTFLabel({text = member.nick, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = itemView:getPositionX() + itemView:getContentSize().width * 0.45 / 2 + 10, y = bg:getContentSize().height / 2 + 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	name:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.lordId_ == member.lordId then
		name:setColor(COLOR[3])
	end

	-- 等级 
	local levelLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(bg)
	levelLab:setAnchorPoint(cc.p(0, 0.5))
	local levelValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
	levelValue:setAnchorPoint(cc.p(0, 0.5))

	-- gdump(self.type,"self.typeself.typeself.type")
	if self.type == 1 then
		levelLab:setString(CommonText[544][1])
		levelValue:setString(member.level)
	else
		levelLab:setString(CommonText[640][1])
		levelValue:setString(member.weekDonate)
	end
	levelValue:setPosition(levelLab:getPositionX() + levelLab:getContentSize().width,levelLab:getPositionY())



	-- 战力
	local powerLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = levelLab:getPositionX(), y = levelLab:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(bg)
	powerLab:setAnchorPoint(cc.p(0, 0.5))
	local powerValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
	powerValue:setAnchorPoint(cc.p(0, 0.5))

	if self.type == 1 then
		powerLab:setString(CommonText[544][2])
		powerValue:setString(UiUtil.strNumSimplify(member.fight))
	else
		powerLab:setString(CommonText[640][2])
		powerValue:setString(member.weekAllDonate)
	end
	powerValue:setPosition(powerLab:getPositionX() + powerLab:getContentSize().width,powerLab:getPositionY())


	if self.type == 1 then
		--军衔信息
		local militaryLab = ui.newTTFLabel({text = CommonText[1064] ..":", font = G_FONT, size = FONT_SIZE_SMALL, x = levelLab:getPositionX() + 150, y = levelLab:getPositionY() , align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(bg)
		militaryLab:setAnchorPoint(cc.p(0, 0.5))
		local militaryValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = militaryLab:getPositionX() + militaryLab:getContentSize().width , y = levelLab:getPositionY() , align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(121, 236, 85)}):addTo(bg)
		militaryValue:setAnchorPoint(cc.p(0, 0.5))
		local mrdata = MilitaryRankMO.queryById(member.militaryRank)
		local militaryLv = mrdata and mrdata.name or CommonText[509]
		militaryValue:setString(militaryLv)
	end


	local jobLab = ui.newTTFLabel({text = CommonText[638], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 + 20, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	local jobValue = ui.newTTFLabel({text = PartyBO.getJobNameById(member.job), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 - 20, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	if member.job == PARTY_JOB_OFFICAIL or member.job == PARTY_JOB_MASTER then
		jobValue:setColor(COLOR[12])
	else
		jobValue:setColor(COLOR[2])
	end
		
	return cell
end


function PartyMemberTableView:openDetail(member)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyMemberDetailDialog").new(member):push()
end


function PartyMemberTableView:cellTouched(cell, index)
    gprint(index,"PartyMemberTableView:cellTouched..index")
	local member = PartyMO.partyData_.partyMember[index]
	self:openDetail(member)
end

function PartyMemberTableView:updateListHandler(event)
	-- gdump(event,"eventeventeventevent")
	self:reloadData()
end



function PartyMemberTableView:onExit()
	PartyMemberTableView.super.onExit(self)
	
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end



return PartyMemberTableView