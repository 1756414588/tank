--
-- Author: gf
-- Date: 2015-09-14 16:07:39
-- 军团科技


--------------------------------------------------------------------
-- 军团科技研究tableview
--------------------------------------------------------------------

local PartyScienceTableView = class("PartyScienceTableView", TableView)

function PartyScienceTableView:ctor(size)
	PartyScienceTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

function PartyScienceTableView:onEnter()
	PartyScienceTableView.super.onEnter(self)
	self.m_UpgradeHandler = Notify.register(LOCAL_PARTY_SCIENCE_DONE_EVENT, handler(self, self.onUpgradeUpdate))
	self.m_upBuildHandler = Notify.register(LOCAL_PARTY_BUILD_EVENT, handler(self, self.onUpgradeUpdate))
	self.m_upBuildScienceHandler = Notify.register(LOCAL_PARTY_BUILD_SCIENCE_EVENT, handler(self, self.onScienceUpdate))
end

function PartyScienceTableView:numberOfCells()
	return #PartyMO.scienceData_.scienceData
end

function PartyScienceTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyScienceTableView:createCellAtIndex(cell, index)
	PartyScienceTableView.super.createCellAtIndex(self, cell, index)

	local science = PartyMO.scienceData_.scienceData[index]
	local scienceLvData,lvmax
	lvmax = false
	local maxLv = PartyMO.queryScienceMaxLevel(science.scienceId)
	if science.scienceLv == maxLv then --等级已达最大
		lvmax = true
		scienceLvData =  PartyMO.queryScienceLevel(science.scienceId, science.scienceLv)
	else
		scienceLvData =  PartyMO.queryScienceLevel(science.scienceId, science.scienceLv + 1)
	end
	-- gprint("science.scienceId",science.scienceId,"science.scienceLv",science.scienceLv)
	-- gdump(scienceLvData,"scienceLvData===")

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_SCIENCE,science.scienceId):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = ScienceMO.queryScience(science.scienceId).refineName .. ":LV." .. science.scienceLv, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))
	--已满级
	if lvmax == true then
		name:setString(ScienceMO.queryScience(science.scienceId).refineName .. "：LV." .. science.scienceLv)
		name:setColor(COLOR[1])
		name:setString(ScienceMO.queryScience(science.scienceId).refineName .. "：LV." .. science.scienceLv)
		name:setColor(COLOR[1])
		--升级进度
		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
		bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 85)
		bar.label = ui.newTTFLabel({text = science.schedule .. "/" .. scienceLvData.schedule, font = G_FONT, size = FONT_SIZE_SMALL, x = bar:getContentSize().width/2, y = bar:getContentSize().height/2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		bar:setPercent(science.schedule / scienceLvData.schedule)
	else
		if PartyMO.partyData_.scienceLv >= scienceLvData.lockLv then
			name:setString(ScienceMO.queryScience(science.scienceId).refineName .. "：LV." .. science.scienceLv)
			name:setColor(COLOR[1])
			--升级进度
			local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
			bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 85)
			bar:setLabel(science.schedule .. "/" .. scienceLvData.schedule)
			bar:setPercent(science.schedule / scienceLvData.schedule)
		else
			name:setString(ScienceMO.queryScience(science.scienceId).refineName .. "：LV." .. science.scienceLv .. CommonText[596][1])
			name:setColor(COLOR[6])
			local cueLab = ui.newTTFLabel({text = string.format(CommonText[596][2],scienceLvData.lockLv), font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 170, y = 54, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			cueLab:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	-- 详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.openDetail))
	detailBtn.science = science
	cell:addButton(detailBtn, self.m_cellSize.width - 150, self.m_cellSize.height / 2 - 22)

	-- 升级按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
	local upBtn = CellMenuButton.new(normal, selected, disabled, handler(self,self.doUpgrade))
	upBtn.science = science
	upBtn:setEnabled(lvmax == false and PartyMO.partyData_.scienceLv >= scienceLvData.lockLv)

	cell:addButton(upBtn, self.m_cellSize.width - 62, self.m_cellSize.height / 2 - 22)

	return cell
end

function PartyScienceTableView:doUpgrade(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyScienceUpDialog").new(sender.science):push()
end

function PartyScienceTableView:openDetail(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyScienceDetailDialog").new(sender.science):push()
end


function PartyScienceTableView:onUpgradeUpdate()
	self:reloadData()
end

function PartyScienceTableView:onScienceUpdate()
	PartyBO.asynGetPartyScience(function()
			end)
	self:reloadData()
end

function PartyScienceTableView:onExit()
	PartyScienceTableView.super.onExit(self)
	
	if self.m_UpgradeHandler then
		Notify.unregister(self.m_UpgradeHandler)
		self.m_UpgradeHandler = nil
	end
	if self.m_upBuildHandler then
		Notify.unregister(self.m_upBuildHandler)
		self.m_upBuildHandler = nil
	end

	if self.m_upBuildScienceHandler then
		Notify.unregister(self.m_upBuildScienceHandler)
		self.m_upBuildScienceHandler = nil
	end
end

--------------------------------------------------------------------
-- 军团科技view
--------------------------------------------------------------------

local PartyScienceView = class("PartyScienceView", UiNode)

function PartyScienceView:ctor()
	PartyScienceView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function PartyScienceView:onEnter()
	PartyScienceView.super.onEnter(self)

	self:setTitle(CommonText[595][1])
	self.m_updateHandler = Notify.register(LOCAL_PARTY_MYDONATE_UPDATE_EVENT, handler(self, self.updateMyDonate))

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, 165))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 110 - infoBg:getContentSize().height / 2)
	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_SCIENCE,PartyMO.partyData_.scienceLv)
	for index=1,#CommonText[594] do
		local labTit = ui.newTTFLabel({text = CommonText[594][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 20, y = infoBg:getContentSize().height - 25 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		labTit:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then --科技大厅等级
			value:setString(PartyMO.partyData_.scienceLv)
			self.buildLvLab_ = value
		elseif index == 2 then --升级需求
			if PartyMO.partyData_.scienceLv == PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_SCIENCE) then --等级已达上限
				value:setString(CommonText[575][1])
				value:setColor(COLOR[2])
			else
				value:setString(partyBuildLv.needExp)
				if PartyMO.partyData_.build >= partyBuildLv.needExp then --建设度大于升级需求
					value:setColor(COLOR[2])
				else
					value:setColor(COLOR[6])
				end
			end
			self.buildUpNeedLab_ = value
		elseif index == 3 then --总建设度
			value:setString(PartyMO.partyData_.build)
			self.buildValueLab_ = value
		elseif index == 4 then --个人贡献
			value:setString(PartyMO.myDonate_)
			self.myDonateLab_ = value
		end
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local levelUpBtn = MenuButton.new(normal, selected, disabled, handler(self,self.levelUpHandler)):addTo(infoBg)
	levelUpBtn:setPosition(infoBg:getContentSize().width - levelUpBtn:getContentSize().width / 2 - 10,infoBg:getContentSize().height - levelUpBtn:getContentSize().height / 2 - 10)
	levelUpBtn:setLabel(CommonText[582][1])
	levelUpBtn:setEnabled(PartyMO.partyData_.scienceLv < PartyMO.partyData_.partyLv and PartyMO.partyData_.scienceLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_SCIENCE) and PartyMO.partyData_.build >= partyBuildLv.needExp)
	if PartyMO.partyData_.scienceLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_SCIENCE) then
		levelUpBtn.needExp = partyBuildLv.needExp
	end
	levelUpBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)
	self.levelUpBtn = levelUpBtn
	
	--科技列表
	local infoBg1 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	infoBg1:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, self:getBg():getContentSize().height - 320))
	infoBg1:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 290 - infoBg1:getContentSize().height / 2)


	local view = PartyScienceTableView.new(cc.size(infoBg1:getContentSize().width, infoBg1:getContentSize().height - 4)):addTo(infoBg1)
	view:setPosition(0, 0)
	view:reloadData()
end

function PartyScienceView:updateMyDonate()
	self.myDonateLab_:setString(PartyMO.myDonate_)
end


function PartyScienceView:levelUpHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.levelUpStatus == true then return end
	self.levelUpStatus = true
	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_SCIENCE,PartyMO.partyData_.scienceLv)
	Loading.getInstance():show()
	PartyBO.asynUpPartyBuilding(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[585])
		self:updateScienceInfo()
		self.levelUpStatus = false
		end,PARTY_BUILD_ID_SCIENCE,partyBuildLv.needExp)
end

function PartyScienceView:updateScienceInfo()
	local partyBuildLv = PartyMO.queryPartyBuildLv(PARTY_BUILD_ID_SCIENCE,PartyMO.partyData_.scienceLv)
	--等级
	self.buildLvLab_:setString(PartyMO.partyData_.scienceLv)
	--升级需求
	if PartyMO.partyData_.scienceLv == PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_SCIENCE) then --等级已达上限
		self.buildUpNeedLab_:setString(CommonText[575][1])
		self.buildUpNeedLab_:setColor(COLOR[2])
	else
		self.buildUpNeedLab_:setString(partyBuildLv.needExp)
		if PartyMO.partyData_.build >= partyBuildLv.needExp then --建设度大于升级需求
			self.buildUpNeedLab_:setColor(COLOR[2])
		else
			self.buildUpNeedLab_:setColor(COLOR[6])
		end
	end
	--建设度
	self.buildValueLab_:setString(PartyMO.partyData_.build)
	self.levelUpBtn:setEnabled(PartyMO.partyData_.scienceLv < PartyMO.queryPartyBuildMaxLevel(PARTY_BUILD_ID_SCIENCE) and PartyMO.partyData_.build >= partyBuildLv.needExp)
end

function PartyScienceView:onExit()
	PartyScienceView.super.onExit(self)
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end

return PartyScienceView