
local StaffPageView = class("StaffPageView", PageView)

function StaffPageView:ctor(size)
	StaffPageView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)

	self.m_cellSize = size
end

function StaffPageView:numberOfCells()
	return StaffMO.queryStaffMax()
end

function StaffPageView:cellSizeForIndex(index)
	return self:getViewSize()
end

function StaffPageView:createCellAtIndex(cell, index)
	StaffPageView.super.createCellAtIndex(self, cell, index)

	local componentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell)
	componentBg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height))
	componentBg:setPosition(self:getViewSize().width / 2, self:getViewSize().height / 2)
	componentBg:setOpacity(0)

	local staff = StaffMO.queryStaffById(index)

	-- 达成要求
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(50, self.m_cellSize.height - 30)

	local title = ui.newTTFLabel({text = CommonText[10042][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	-- 军衔要求
	local label = ui.newTTFLabel({text = CommonText[10043][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 80, y = self.m_cellSize.height - 80, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	if staff.rank == 0 then   -- 无
		value:setString(CommonText[108])
		value:setColor(COLOR[2])
	else
		local rankDB = UserMO.queryRankById(staff.rank)
		value:setString(rankDB.name)

		local myRank = UserMO.getResource(ITEM_KIND_RANK)
		if myRank >= staff.rank then -- 军衔足够了
			value:setColor(COLOR[2])
		else
			value:setColor(COLOR[6])
		end
	end

	-- 编制要求
	local label = ui.newTTFLabel({text = CommonText[10043][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 80, y = self.m_cellSize.height - 110, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = staff.staffingLv, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.staffingLv_ >= staff.staffingLv then  -- 编制等级足够了
		value:setColor(COLOR[2])
	else
		value:setColor(COLOR[6])
	end

	-- 人数限制
	local label = ui.newTTFLabel({text = CommonText[10043][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 80, y = self.m_cellSize.height - 140, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	if staff.countLimit == 0 then -- 无限制
		value:setString(CommonText[10043][4])
	else
		value:setString(staff.countLimit .. "(" .. CommonText[10043][5] .. ")")
	end

	-- 属性奖励
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(50, self.m_cellSize.height - 190)

	local title = ui.newTTFLabel({text = CommonText[10042][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local attrDatas = json.decode(staff.attr)
	if attrDatas then
		for index = 1, #attrDatas do
			local attrData = attrDatas[index]
			-- dump(attrData, "111111111")
			local attribute = AttributeBO.getAttributeData(attrData[1], attrData[2])
			-- dump(attribute, "2222222222")

			local label = ui.newTTFLabel({text = attribute.name .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, x = 80, y = self.m_cellSize.height - 240 - 30 * (index - 1), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))

			local value = ui.newTTFLabel({text = attribute.strValue, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			value:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	-- local labelColor = cc.c3b(0, 0, 0)

	-- local title = ui.newTTFLabel({text = "VIP" .. index .. CommonText[408], font = G_FONT, size = FONT_SIZE_HUGE, x = self.m_cellSize.width / 2, y = self.m_cellSize.height - 40, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)

	-- local posY = self.m_cellSize.height - 60

	-- local data = DetailText.vip[index]

	-- if data then
	-- 	for index = 1, #data do
	-- 		local d = data[index]
	-- 		local label = RichLabel.new(d, cc.size(self.m_cellSize.width, 0)):addTo(cell)
	-- 		label:setPosition(0, posY)
	-- 		label:setTouchEnabled(false)
	-- 		posY = posY - label:getHeight()
	-- 	end
	-- end

	return cell
end


-----------------------------------------------------------------
-- 编制View
-----------------------------------------------------------------

local StaffView = class("StaffView", UiNode)

function StaffView:ctor(uiEnter)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	StaffView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function StaffView:onEnter()
	StaffView.super.onEnter(self)

	self:setTitle(CommonText[10045])  -- 编制

	local pagesCall = {}
	local pages = {}
	-- "个人信息", "编制玩法"
	if StaffMO.isStaffOpen_ then
		table.insert(pages,CommonText[10040][1]) -- 个人信息
		table.insert(pagesCall,handler(self,self.showInfo))

		table.insert(pages,CommonText[10040][2]) -- 编制玩法
		table.insert(pagesCall,handler(self,self.showDetail))
	end
	-- 军衔
	if UserMO.queryFuncOpen(UFP_MILITARY) then
		table.insert(pages,CommonText[10040][3]) -- 军衔信息
		table.insert(pagesCall,handler(self,self.requireMilitaryData))
	end
	--参谋配置
	if UserMO.queryFuncOpen(UFP_STAFF_CONFIG) then
		table.insert(pages,CommonText[10040][4]) -- 参谋配置
		table.insert(pagesCall,handler(self,self.staffConfig))
	end

	local function createDelegate(container, index)
		local callback = pagesCall[index]
		if callback then callback(container) end
	end

	local function clickDelegate(container, index)
	end

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_staffHandler = Notify.register(LOCAL_STAFF_UPDATE_EVENT, handler(self, self.onStaffUpdate))
end

function StaffView:onExit()
	StaffView.super.onExit(self)

	if self.m_staffHandler then
		Notify.unregister(self.m_staffHandler)
		self.m_staffHandler = nil
	end
end

function StaffView:onStaffUpdate(event)
	if self.m_pageView:getPageIndex() == 1 then
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end
end

function StaffView:showInfo(container)
	-- 编制等级
	local label = ui.newTTFLabel({text = CommonText[10041][1] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 40, y = container:getContentSize().height - 30}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = UserMO.staffingLv_, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 全服排名
	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))
	if StaffMO.ranking_ ~= 0 then
		value:setString("(" .. CommonText[10041][3] .. ":" .. StaffMO.ranking_ .. ")")
	else
		value:setString("(" .. CommonText[10041][3] .. ":" .. CommonText[768] .. ")")  -- 未上榜
	end

	-- 编制经验
	local label = ui.newTTFLabel({text = CommonText[10041][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 40, y = container:getContentSize().height - 60}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(340, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(340 + 4, 26)}):addTo(container)
	bar:setPosition(label:getPositionX() + label:getContentSize().width + 10 + bar:getContentSize().width / 2, container:getContentSize().height - 60)
	-- bar:setPercent(0.2)
	-- bar:setLabel("1/1499")
	if UserMO.staffingLv_ >= StaffMO.queryStaffLvMaxLv() then -- 编制等级已经是最高的
		local staffLvDB = StaffMO.queryStaffLvByLv(StaffMO.queryStaffLvMaxLv())
		bar:setPercent(UserMO.staffingExp_ / staffLvDB.exp)
		bar:setLabel(UserMO.staffingExp_ .. "/" .. staffLvDB.exp)
	else
		local staffLvDB = StaffMO.queryStaffLvByLv(UserMO.staffingLv_ + 1)
		bar:setPercent(UserMO.staffingExp_ / staffLvDB.exp)
		bar:setLabel(UserMO.staffingExp_ .. "/" .. staffLvDB.exp)
	end

	-- 编制职位
	local label = ui.newTTFLabel({text = CommonText[10041][4] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 40, y = container:getContentSize().height - 90}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))

	if UserMO.staffing_ == 0 then  -- 无职位
		value:setString(CommonText[108]) -- 无
		value:setColor(COLOR[6])
	else
		local staffDB = StaffMO.queryStaffById(UserMO.staffing_)
		value:setString(staffDB.name)
		value:setColor(COLOR[2])
	end

	local function onDetailCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.staff):push()
	end

	-- 详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, onDetailCallback):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 60, container:getContentSize().height - 50)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:getContentSize().width - 20, 500))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - bg:getContentSize().height / 2 - 130)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	titleBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 5)

	local pageTitle = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2 + 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	local pageView = StaffPageView.new(cc.size(bg:getContentSize().width - 2 * 10, bg:getContentSize().height - 10 - 30)):addTo(bg)
	pageView:setPosition(10, 10)
	pageView:reloadData()

	local function onLastCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		local curPage = pageView:getCurrentIndex()
		pageView:setCurrentIndex(curPage - 1, true)

		-- if curPage <= 1 then
		-- 	sender:setVisible(false)
		-- else
		-- 	sender:setVisible(true)
		-- end

		-- sender.nxt:setVisible(true)
	end

	local function onNextCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		local curPage = pageView:getCurrentIndex()
		pageView:setCurrentIndex(curPage + 1, true)

		-- if curPage >= pageView:numberOfCells() then
		-- 	sender:setVisible(false)
		-- else
		-- 	sender:setVisible(true)
		-- end

		-- sender.last:setVisible(true)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	selected:setScale(-1)
	local lastBtn = MenuButton.new(normal, selected, nil, onLastCallback):addTo(bg)
	lastBtn:setPosition(50, bg:getContentSize().height / 2)
	lastBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(-20, 0)), cc.MoveBy:create(2, cc.p(20, 0))})))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, onNextCallback):addTo(bg)
	nxtBtn:setPosition(bg:getContentSize().width - 50, bg:getContentSize().height / 2)
	nxtBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(20, 0)), cc.MoveBy:create(2, cc.p(-20, 0))})))

	local function scrollPage(event)
		local curPage = pageView:getCurrentIndex()
		if curPage <= 1 then
			lastBtn:setVisible(false)
		else
			lastBtn:setVisible(true)
		end

		if curPage >= pageView:numberOfCells() then
			nxtBtn:setVisible(false)
		else
			nxtBtn:setVisible(true)
		end

		local staff = StaffMO.queryStaffById(curPage)

		pageTitle:setString(staff.name)
	end

	pageView:addEventListener("PAGE_SCROLL_TO", scrollPage)
	if UserMO.staffing_ == 0 then
		pageView:setCurrentIndex(1)
	else
		pageView:setCurrentIndex(UserMO.staffing_)
	end

	local worldDB = StaffMO.queryWorldByLv(StaffMO.worldLv_)

	-- 世界等级
	local label = ui.newTTFLabel({text = CommonText[10044][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 126, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = StaffMO.worldLv_, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))


	local addNum = StaffMO.queryWorldByLv(StaffMO.worldLv_).limit
	-- 最高为10级
	local value = ui.newTTFLabel({text = "(" .. CommonText[10052][1] .. ")", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 效果影响
	local label = ui.newTTFLabel({text = CommonText[10044][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 96, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 世界地图损兵比例降低为
	local value = ui.newTTFLabel({text = string.format(CommonText[10052][2], worldDB.haust .. "%"), font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))

	local refitAdd = UiUtil.label(CommonText[1166]..addNum,FONT_SIZE_SMALL,COLOR[2]):alignTo(value, -28, 1)

	if StaffMO.worldLv_ < StaffMO.queryWorldMaxLv() then  -- 还有下一级
		local nxtWorldDB = StaffMO.queryWorldByLv(StaffMO.worldLv_ + 1)

		-- 下级影响
		local label = ui.newTTFLabel({text = CommonText[10044][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 46, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))

		-- 世界地图损兵比例降低为
		local value = ui.newTTFLabel({text = string.format(CommonText[10052][2], nxtWorldDB.haust .. "%"), font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		value:setAnchorPoint(cc.p(0, 0.5))

		local nextNum = StaffMO.queryWorldByLv(StaffMO.worldLv_ + 1).limit
		local nextAdd = UiUtil.label(CommonText[1166]..nextNum,FONT_SIZE_SMALL):alignTo(value, -30, 1)
	end
end

function StaffView:showDetail(container)
	local StaffTableView = require("app.scroll.StaffTableView")
	local view = StaffTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4)):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function StaffView:requireMilitaryData(container)
	if not UserMO.queryFuncOpen(UFP_MILITARY) then return end

	Loading.getInstance():show()
	MilitaryRankBO.getMilitaryData(function(data)
		self:showMilitaryRank(container,data)
	end)
end

function StaffView:showMilitaryRank(container, data)
	container:removeAllChildren()

	local militaryRank = data.militaryRank --军衔
	local sortRank = (data.sortRank ~= 0 and tostring(data.sortRank)) or CommonText[392]--军衔排名
	local militaryExploit = data.militaryExploit --军功
	local mpltGotToday = data.mpltGotToday -- 今日获得军功 暂未使用

	local mrdata = MilitaryRankMO.queryById(militaryRank)

	local showdata = mrdata
	if militaryRank == 0 then
		showdata = MilitaryRankMO.queryById(1)
	end

	-- 我的排名
	local label = ui.newTTFLabel({text = CommonText[391] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 40, y = container:getContentSize().height - 30}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = sortRank, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 我的军功
	label = ui.newTTFLabel({text = CommonText[1017][2] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = 40, y = container:getContentSize().height - 60, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(200, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(200 + 4, 26)}):addTo(container)
	bar:setAnchorPoint(cc.p(0,0.5))
	bar:setPosition(label:getPositionX() + label:getContentSize().width, label:getPositionY())
	bar:setPercent(militaryExploit / showdata.mpltLimit)
	bar:setLabel(UiUtil.strNumSimplify(militaryExploit) .. "/" .. UiUtil.strNumSimplify(showdata.mpltLimit))


	-- 今日获得军功
	label = ui.newTTFLabel({text = CommonText[53] .. ": ", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = 40, y = container:getContentSize().height - 90, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	value = ui.newTTFLabel({text = string.format(CommonText[1017][5], UiUtil.strNumSimplify(UserMO.querySystemId(41))), font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))

	local function onDetailCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.militaryRankInfo):push()
	end

	-- 详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, onDetailCallback):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 60, container:getContentSize().height - 50)


	-- 军衔等级 图标 bg
	local mrbg = display.newSprite(IMAGE_COMMON .. "military/di.png"):addTo(container)
	mrbg:setPosition(detailBtn:getPositionX() - detailBtn:getContentSize().width * 0.5 - mrbg:getContentSize().width * 0.5 - 10, detailBtn:getPositionY())

	local mr = display.newSprite(IMAGE_COMMON .. "military/" .. militaryRank .. ".png"):addTo(mrbg)
	mr:setPosition(mrbg:getContentSize().width * 0.5 , mrbg:getContentSize().height * 0.5)


	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:getContentSize().width - 20, 550))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - bg:getContentSize().height / 2 - 120)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	titleBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 5)

	local name = mrdata and mrdata.name or CommonText[509]
	local pageTitle = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2 + 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	local MilitaryInfoTableView = require("app.scroll.MilitaryInfoTableView")
	local view = MilitaryInfoTableView.new(cc.size(bg:getContentSize().width - 10 , bg:getContentSize().height - 40), mrdata, militaryRank):addTo(bg)
	view:setPosition(20,10)


	-- 详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local upBtn = MenuButton.new(normal, selected, nil, handler(self, self.UpBtnCallback)):addTo(container)
	upBtn:setPosition(container:getContentSize().width * 0.5, upBtn:getContentSize().height * 0.45)
	upBtn:setLabel(CommonText[1015])
	upBtn.nextlv = militaryRank + 1
	upBtn.sortRank = sortRank

	self.container3 = container
end

--参谋配置
function StaffView:staffConfig(container)
	if not StaffMO.staffHerosData_ then return  end
	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.staffHeros):push()
		end):addTo(container,999):scale(0.8)
	detailBtn:setPosition(container:getContentSize().width - 60, container:getContentSize().height - 50)

	local StaffConfigTableView = require("app.scroll.StaffConfigTableView")
	local view = StaffConfigTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 50)):addTo(container,998)
	view:setPosition(0,0)
	view:reloadData()

end

function StaffView:UpBtnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local nextlv = sender.nextlv
	local ranks = sender.sortRank

	if MilitaryRankMO.couldLevelUp(nextlv) then return end

	Loading.getInstance():show()
	MilitaryRankBO.upleveMilitary(function (data)
		
		MilitaryRankMO.useResource(nextlv)

		local indata = {}
		indata.militaryExploit = data.militaryExploit
		indata.militaryRank = data.militaryRank
		indata.sortRank = data.curRank

		self:showMilitaryRank(self.container3 , indata)

		Toast.show(CommonText[585])

		if ranks ~= data.curRank then
			RankBO.asynGetRank(nil, 14, 1) -- 排行不一样时 重新拉去排行榜
		end
	end)
end

return StaffView
