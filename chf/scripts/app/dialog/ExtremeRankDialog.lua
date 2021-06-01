
------------------------------------------------------------------------------
-- 极限副本排行榜
------------------------------------------------------------------------------

-- local AccelItemTableView = class("AccelItemTableView", TableView)

-- local AccelItemTableView = class("AccelItemTableView", TableView)

-- function AccelItemTableView:ctor(size)
-- 	AccelItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

-- 	self.m_cellSize = cc.size(size.width, 145)
-- 	self.m_curChoseIndex = 0
-- 	-- self.m_curTankFightNum = 0 -- 当前选中的坦克上阵的数量
-- end

-- function AccelItemTableView:numberOfCells()
-- 	return 4
-- end

-- function AccelItemTableView:cellSizeForIndex(index)
-- 	return self.m_cellSize
-- end

-- function AccelItemTableView:createCellAtIndex(cell, index)
-- 	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell)
-- 	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
-- 	bg:setCapInsets(cc.rect(220, 60, 1, 1))
-- 	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

-- 	return cell
-- end

------------------------------------------------------------------------------
-- 极限副本排行榜
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ExtremeRankDialog = class("ExtremeRankDialog", Dialog)

function ExtremeRankDialog:ctor()
	ExtremeRankDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
end

function ExtremeRankDialog:onEnter()
	ExtremeRankDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[276])

	self.m_rankType = 8

	RankMO.myRank_[self.m_rankType] = 0
	RankMO.ranks[self.m_rankType] = nil

	-- local ranks = RankMO.getRanksByType(self.m_rankType)
	-- if ranks then
	-- 	self:showUI()
	-- else
		Loading.getInstance():show()
		RankBO.asynGetRank(handler(self, self.showUI), self.m_rankType, 1) -- 显示第一页
	-- end
end

function ExtremeRankDialog:showUI()
	Loading.getInstance():unshow()

	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	self.m_upgradeTimeLabel = nil
	self.m_upgradeBar = nil

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	-- -- 排名
	-- local rank = ArenaBO.createRank(1):addTo(container)
	-- rank:setPosition(100, container:getContentSize().height - 110)

	-- 头像
	local portrait = UiUtil.createItemView(ITEM_KIND_PORTRAIT, UserMO.portrait_):addTo(container)
	portrait:setScale(0.4)
	portrait:setPosition(90, container:getContentSize().height - 110)

	-- 玩家自己
	local label = ui.newTTFLabel({text = CommonText[247], font = G_FONT, size = FONT_SIZE_SMALL, x = 140, y = container:getContentSize().height - 80, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 我的进度
	local label = ui.newTTFLabel({text = CommonText[303] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local numLabel = ui.newBMFontLabel({text = CombatMO.getExtremeProgressIndex(CombatMO.exploreExtremeHighest_), font = "fnt/num_2.fnt", x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(container)
	numLabel:setAnchorPoint(cc.p(0, 0.5))

	local myRank = RankMO.getMyRankByType(self.m_rankType)

	-- 我的排名
	local label = ui.newTTFLabel({text = CommonText[391] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	if myRank == nil or myRank == 0 then  -- 未上榜
		local value = ui.newTTFLabel({text = CommonText[392], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		value:setAnchorPoint(cc.p(0, 0.5))
	else
		local value = ui.newTTFLabel({text = myRank, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		value:setAnchorPoint(cc.p(0, 0.5))
	end

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	bg:setPreferredSize(cc.size(520, 660))
	bg:setCapInsets(cc.rect(80, 60, 1, 1))
	bg:setPosition(container:getContentSize().width / 2, 40 + bg:getContentSize().height / 2)

	-- 排名
	local label = ui.newTTFLabel({text = CommonText[396][1], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 65, y = bg:getContentSize().height - 25}):addTo(bg)
	-- 角色名
	local label = ui.newTTFLabel({text = CommonText[396][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 158, y = label:getPositionY()}):addTo(bg)
	-- 进度
	local label = ui.newTTFLabel({text = CommonText[10015], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 312, y = label:getPositionY()}):addTo(bg)
	-- 战斗力
	local label = ui.newTTFLabel({text = CommonText[281], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 412, y = label:getPositionY()}):addTo(bg)

	local RankTableView = require("app.scroll.RankTableView")
	local view = RankTableView.new(cc.size(bg:getContentSize().width, bg:getContentSize().height - 50 - 16), self.m_rankType):addTo(bg)
	view:setPosition(0, 16)
	view:reloadData()
end

return ExtremeRankDialog