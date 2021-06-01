--
-- Author: gf
-- Date: 2015-10-09 15:38:55
-- 军团活跃榜

local PartyLiveRankTableView = class("PartyLiveRankTableView", TableView)

function PartyLiveRankTableView:ctor(size,list)
	PartyLiveRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 110)
	self.list = list

	gdump(list,"PartyLiveRankTableView:ctor..list")
end

function PartyLiveRankTableView:numberOfCells()
	return #self.list
end

function PartyLiveRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyLiveRankTableView:createCellAtIndex(cell, index)
	PartyLiveRankTableView.super.createCellAtIndex(self, cell, index)
	local member = self.list[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(500, 105))

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

	-- 等级 
	local levelLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(bg)
	levelLab:setAnchorPoint(cc.p(0, 0.5))
	local levelValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
	levelValue:setAnchorPoint(cc.p(0, 0.5))

	levelLab:setString(CommonText[544][1])
	levelValue:setString(member.level)
	levelValue:setPosition(levelLab:getPositionX() + levelLab:getContentSize().width,levelLab:getPositionY())


	-- 活跃
	local liveLab = ui.newTTFLabel({text = CommonText[685], font = G_FONT, size = FONT_SIZE_SMALL, x = levelLab:getPositionX(), y = levelLab:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(bg)
	liveLab:setAnchorPoint(cc.p(0, 0.5))
	local liveValue = ui.newTTFLabel({text = member.live, font = G_FONT, size = FONT_SIZE_SMALL, 
		align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
	liveValue:setAnchorPoint(cc.p(0, 0.5))

	liveValue:setPosition(liveLab:getPositionX() + liveLab:getContentSize().width,liveLab:getPositionY())


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


function PartyLiveRankTableView:onUpgradeUpdate()
	self:reloadData()
end

function PartyLiveRankTableView:onExit()
	PartyLiveRankTableView.super.onExit(self)
end


local Dialog = require("app.dialog.Dialog")
local PartyLiveRankDialog = class("PartyLiveRankDialog", Dialog)

function PartyLiveRankDialog:ctor(list)
	PartyLiveRankDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.list = list
end

function PartyLiveRankDialog:onEnter()
	PartyLiveRankDialog.super.onEnter(self)

	self:setTitle(CommonText[696])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	local name = ui.newTTFLabel({text = CommonText[697], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = btm:getContentSize().height - 50, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	name:setAnchorPoint(cc.p(0, 0.5))

	local view = PartyLiveRankTableView.new(cc.size(btm:getContentSize().width, btm:getContentSize().height - 90), self.list):addTo(btm)
	view:setPosition(0, 10)
	view:reloadData()
end

return PartyLiveRankDialog
