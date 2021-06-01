
CROSS_SERVER_MINE_RANK_TYPE_PERSON = 1 -- 个人排名
CROSS_SERVER_MINE_RANK_TYPE_SERVER = 2 -- 服務器排名

--------------------------------------------------------------------
-- 编制排行榜TableView
--------------------------------------------------------------------

local CrossServerMineRankTableView = class("CrossServerMineRankTableView", TableView)

function CrossServerMineRankTableView:ctor(size, rankType, rankDatas)
	CrossServerMineRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 80)

	self.m_rankType = rankType
	self.m_rankDatas = rankDatas
end

function CrossServerMineRankTableView:numberOfCells()
	return #self.m_rankDatas
end

function CrossServerMineRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function CrossServerMineRankTableView:createCellAtIndex(cell, index)
	CrossServerMineRankTableView.super.createCellAtIndex(self, cell, index)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(560, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 5)

	-- 排行
	local rankView = ArenaBO.createRank(index):addTo(cell)
	rankView:setPosition(65, self.m_cellSize.height / 2)

	local rankData = self.m_rankDatas[index]

	local name = ui.newTTFLabel({text = rankData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 158 + 10, y = 52, color = ArenaBO.getRankColor(index), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))
	cell.name = rankData.name

	-- if self.m_rankType == 8 then  -- 进度
	-- 	local value = ui.newTTFLabel({text = (rankData.lv % 100), font = G_FONT, size = FONT_SIZE_SMALL, x = 312, y = name:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- else
	-- 	-- 等级
	-- 	local value = ui.newTTFLabel({text = rankData.lv, font = G_FONT, size = FONT_SIZE_SMALL, x = 312, y = name:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- end

	if self.m_rankType == CROSS_SERVER_MINE_RANK_TYPE_PERSON then 
		local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(rankData.fight), font = "fnt/num_2.fnt"}):addTo(cell)
		value:setPosition(368, name:getPositionY())
	end

	local score = ui.newTTFLabel({text = rankData.score, font = G_FONT, size = FONT_SIZE_SMALL, x = 500, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- elseif self.m_rankType == 2 or self.m_rankType == 3 then
	-- 	local value = ui.newTTFLabel({text = rankData.value, font = G_FONT, size = FONT_SIZE_SMALL, x = 412, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- elseif self.m_rankType == 8 then -- 极限副本
	-- 	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(rankData.value), font = "fnt/num_2.fnt"}):addTo(cell)
	-- 	value:setPosition(412, name:getPositionY())
	-- elseif self.m_rankType == 9 then -- 编制
	-- else
	-- 	local attrData = EquipBO.getEquipAttrData(rankData.value, rankData.lv)
	-- 	local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = 412, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	-- end

	return cell
end

--------------------------------------------------------------------
-- 编制排行榜View
--------------------------------------------------------------------

local CrossServerMineRankView = class("CrossServerMineRankView", UiNode)

function CrossServerMineRankView:ctor(viewFor, pageIndex)
	viewFor = viewFor or ARMY_VIEW_FOR_UI
	self.m_viewFor = viewFor
	self.m_pageIndex = pageIndex or 1

	if self.m_viewFor == ARMY_VIEW_FOR_UI then
		CrossServerMineRankView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	else
		CrossServerMineRankView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	end
end

function CrossServerMineRankView:onEnter()
	CrossServerMineRankView.super.onEnter(self)

	self:setTitle(CommonText[396][1])  -- 排名

	-- self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.onArmyUpdate))

	local function createDelegate(container, index)
		if index == 1 then  -- 个人排名
			self:showPerson(container)
		elseif index == 2 then -- 军团排名
			self:showServer(container)
		end
	end

	local function clickDelegate(container, index)
	end

	--  "个人排名", "服务器排名"
	local pages = {CommonText[10060], CommonText[8031]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_pageIndex)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	-- self:onUpdateTip()

    -- 跨服列表
    local function showCrossList()
        ManagerSound.playNormalButtonSound()
        if #StaffMO.ServerListData_ <= 0 then
		    StaffBO.asynCrossServerList(function ()
		    	if #StaffMO.ServerListData_ > 0 then
		        	require("app.dialog.ServerList").new(StaffMO.ServerListData_, VIEW_FOR_CROSS_SERVER_MINE):push()
		        else
		        	Toast.show(CommonText[8036])
		        end
		    end)
		else
		    require("app.dialog.ServerList").new(StaffMO.ServerListData_, VIEW_FOR_CROSS_SERVER_MINE):push()
		end         
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, showCrossList):addTo(self:getBg(), 20)
	-- btn:setScale(0.9)
	btn:setPosition(self:getBg():getContentSize().width - btn:getContentSize().width/2 - 20, self:getBg():getContentSize().height - 183)
	btn:setLabel("跨服列表")
end

function CrossServerMineRankView:onExit()
	CrossServerMineRankView.super.onExit(self)
end

function CrossServerMineRankView:showPerson(container)
	-- 我的排名
	local label = ui.newTTFLabel({text = CommonText[391] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = container:getContentSize().height - 40}):addTo(container)
	local rankValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(container)

	-- 积分
	local label = ui.newTTFLabel({text = CommonText[770][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2, y = container:getContentSize().height - 40}):addTo(container)
	local scoreValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(container)
	scoreValue:setAnchorPoint(cc.p(0,0.5))

	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	attrBg:setCapInsets(cc.rect(80, 60, 1, 1))
	attrBg:setPreferredSize(cc.size(604, container:getContentSize().height - 110 - 70))
	attrBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 70 - attrBg:getContentSize().height / 2)

	-- 排名
	local title = ui.newTTFLabel({text = CommonText[396][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 66, y = attrBg:getContentSize().height - 26, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	-- 角色名
	local title = ui.newTTFLabel({text = CommonText[396][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 202, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	-- 战斗力
	local title = ui.newTTFLabel({text = CommonText[281], font = G_FONT, size = FONT_SIZE_SMALL, x = 366, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	-- 积分
	local title = ui.newTTFLabel({text = CommonText[770][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 505, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)

	-- 积分大于100才可上榜
	local label = ui.newTTFLabel({text = string.format(CommonText[20125], UserMO.querySystemId(82)), font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 70}):addTo(container)

	local function gotoAward(tag, sender)
		ManagerSound.playNormalButtonSound()
		local CrossServerMineRankAwardDialog = require("app.dialog.CrossServerMineRankAwardDialog")
		CrossServerMineRankAwardDialog.new(CROSS_SERVER_MINE_RANK_TYPE_PERSON):push()
	end

	-- 个人奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local awardBtn = MenuButton.new(normal, selected, disabled, gotoAward):addTo(container)
	awardBtn:setPosition(container:getContentSize().width - 130, 50)
	awardBtn:setLabel(CommonText[10062][1])

	local function doneCallback(rankDatas)
		Loading.getInstance():unshow()
		local view = CrossServerMineRankTableView.new(cc.size(attrBg:getContentSize().width, attrBg:getContentSize().height - 50 - 10), CROSS_SERVER_MINE_RANK_TYPE_PERSON, rankDatas):addTo(attrBg)
		view:setPosition(0, 10)
		view:reloadData()

		if StaffMO.CrossServerrankPerson_ > 0 then
			rankValue:setString(StaffMO.CrossServerrankPerson_)
			rankValue:setColor(COLOR[2])
		else
			rankValue:setString(CommonText[392])
			rankValue:setColor(COLOR[6])
		end

		scoreValue:setString(StaffMO.CrossServerrankPersonScore_)

		-- if StaffMO.rankPersonReceive_ then
		-- 	awardBtn:setEnabled(true)
		-- else
		-- 	awardBtn:setEnabled(false)
		-- end
	end

	Loading.getInstance():show()
	StaffBO.asynCrossScoreRank(doneCallback)
end

function CrossServerMineRankView:showServer(container)
	-- 服务器排名
	local label = ui.newTTFLabel({text = CommonText[8031] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = container:getContentSize().height - 40}):addTo(container)
	local rankValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(container)

	-- 积分
	local label = ui.newTTFLabel({text = CommonText[770][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2, y = container:getContentSize().height - 40}):addTo(container)
	local scoreValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(container)
	scoreValue:setAnchorPoint(cc.p(0,0.5))

	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	attrBg:setCapInsets(cc.rect(80, 60, 1, 1))
	attrBg:setPreferredSize(cc.size(604, container:getContentSize().height - 110 - 70))
	attrBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 70 - attrBg:getContentSize().height / 2)

	-- 排名
	local title = ui.newTTFLabel({text = CommonText[396][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 66, y = attrBg:getContentSize().height - 26, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	-- 服务器名
	local title = ui.newTTFLabel({text = CommonText[8033], font = G_FONT, size = FONT_SIZE_SMALL, x = 202, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	-- 服务器id
	-- local title = ui.newTTFLabel({text = CommonText[8034], font = G_FONT, size = FONT_SIZE_SMALL, x = 366, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	-- 积分
	local title = ui.newTTFLabel({text = CommonText[770][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 505, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)

	-- 积分大于800才可上榜
	local label = ui.newTTFLabel({text = string.format(CommonText[20125], 800), font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 70}):addTo(container)

	local function gotoAward(tag, sender)
		ManagerSound.playNormalButtonSound()
		local CrossServerMineRankAwardDialog = require("app.dialog.CrossServerMineRankAwardDialog")
		CrossServerMineRankAwardDialog.new(CROSS_SERVER_MINE_RANK_TYPE_SERVER):push()
	end

	-- 服务器奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local awardBtn = MenuButton.new(normal, selected, nil, gotoAward):addTo(container)
	awardBtn:setPosition(container:getContentSize().width - 130, 50)
	awardBtn:setLabel(CommonText[10062][3])

	local function doneCallback(rankDatas)
		Loading.getInstance():unshow()
		local view = CrossServerMineRankTableView.new(cc.size(attrBg:getContentSize().width, attrBg:getContentSize().height - 50 - 10), CROSS_SERVER_MINE_RANK_TYPE_SERVER, rankDatas):addTo(attrBg)
		view:setPosition(0, 10)
		view:reloadData()

		if StaffMO.CrossServerrankServer_ > 0 then
			rankValue:setString(StaffMO.CrossServerrankServer_)
			rankValue:setColor(COLOR[2])
		else
			rankValue:setString(CommonText[392])
			rankValue:setColor(COLOR[6])
		end

		scoreValue:setString(StaffMO.CrossServerrankServerScore_)

		-- for index = 1, #rankDatas do
		-- 	local rankdata = rankDatas[index]
		-- 	if rankdata.fight == GameConfig.areaId then
		-- 		rankValue:setString(index)
		-- 		rankValue:setColor(COLOR[2])
		-- 		scoreValue:setString(rankdata.score)
		-- 	end
		-- end

		-- if StaffMO.rankPersonReceive_ then
		-- 	awardBtn:setEnabled(true)
		-- else
		-- 	awardBtn:setEnabled(false)
		-- end
	end

	Loading.getInstance():show()
	StaffBO.asynCrossScoreServerRank(doneCallback)
end

return CrossServerMineRankView