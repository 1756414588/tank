
-- 战报

local BattleReportView = class("BattleReportView", UiNode)

function BattleReportView:ctor(viewFor)
	BattleReportView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function BattleReportView:onEnter()
	BattleReportView.super.onEnter(self)

	self.m_updateHandler = Notify.register(LOCAL_JJC_REPORT_UPDATE_EVENT, handler(self, self.updateMailsState))
	self:setTitle(CommonText[296])  -- 竞技场战报

	local function createDelegate(container, index)
		if index == 1 then  -- 设置部队
			self:showPerson(container)
		elseif index == 2 then -- 执行任务
			self:showServer(container)
		end
	end

	local function clickDelegate(container, index)
	end

	--  "个人", "全服"
	local pages = {CommonText[297][1], CommonText[297][2]}
	-- local pages = {CommonText[12], CommonText[13], CommonText[14], CommonText[15]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self:updateTip()
end

-- 个人
function BattleReportView:showPerson(container)
	local JJCReportTableView = require("app.scroll.JJCReportTableView")
	local view = nil

	view = JJCReportTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 90 - 4), MAIL_TYPE_PERSON_JJC):addTo(container)

	if view then
		view:setPosition(0, 90)
		view:reloadData()
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_del_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_del_selected.png")
	local delBtn = MenuButton.new(normal, selected, nil, handler(self,self.delHandler)):addTo(container)
	delBtn.type = MAIL_TYPE_PERSON_JJC
	delBtn:setPosition(container:getContentSize().width / 2 - 240,30)

	local allLab = ui.newTTFLabel({text = CommonText[552][1], font = G_FONT, size = FONT_SIZE_SMALL, 
	x = delBtn:getPositionX() + delBtn:getContentSize().width / 2 + 10, 
	y = delBtn:getPositionY() + 20, 
	color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	allLab:setAnchorPoint(cc.p(0, 0.5))

	local allValue = ui.newTTFLabel({text = #MailMO.myJJCPersonReprot_, font = G_FONT, size = FONT_SIZE_SMALL, 
	x = allLab:getPositionX() + allLab:getContentSize().width + 10, 
	y = allLab:getPositionY(), 
	color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	allValue:setAnchorPoint(cc.p(0, 0.5))
	self.m_allValueLabel = allValue

	local newLab = ui.newTTFLabel({text = CommonText[552][2], font = G_FONT, size = FONT_SIZE_SMALL, 
	x = delBtn:getPositionX() + delBtn:getContentSize().width / 2 + 10, 
	y = delBtn:getPositionY() - 20, 
	color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	newLab:setAnchorPoint(cc.p(0, 0.5))

	local newValue = ui.newTTFLabel({text = MailBO.getNewReportCount(MAIL_TYPE_PERSON_JJC), font = G_FONT, size = FONT_SIZE_SMALL, 
	x = newLab:getPositionX() + newLab:getContentSize().width + 10, 
	y = newLab:getPositionY(), 
	color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	newValue:setAnchorPoint(cc.p(0, 0.5))
	self.m_newValueLabel = newValue

end

-- 全服
function BattleReportView:showServer(container)
	if #MailMO.myJJCAllReprot_ > 0 then
		self:showServerUI(container)
	else
		MailBO.getMails(function()
			self:showServerUI(container)
			end,MAIL_TYPE_ALL_JJC)
	end
end

function BattleReportView:showServerUI(container)
	local JJCReportTableView = require("app.scroll.JJCReportTableView")
	local view = nil

	view = JJCReportTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 90 - 4), MAIL_TYPE_ALL_JJC):addTo(container)

	if view then
		view:setPosition(0, 90)
		view:reloadData()
	end

	
	local allLab = ui.newTTFLabel({text = CommonText[552][1], font = G_FONT, size = FONT_SIZE_SMALL, 
	x = 50, 
	y = 50, 
	color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	allLab:setAnchorPoint(cc.p(0, 0.5))

	local allValue = ui.newTTFLabel({text = #MailMO.myJJCAllReprot_, font = G_FONT, size = FONT_SIZE_SMALL, 
	x = allLab:getPositionX() + allLab:getContentSize().width + 10, 
	y = allLab:getPositionY(), 
	color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	allValue:setAnchorPoint(cc.p(0, 0.5))
	self.m_allValueLabel = allValue

	local newLab = ui.newTTFLabel({text = CommonText[552][2], font = G_FONT, size = FONT_SIZE_SMALL, 
	x = 50, 
	y = 20, 
	color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	newLab:setAnchorPoint(cc.p(0, 0.5))

	local newValue = ui.newTTFLabel({text = MailBO.getNewReportCount(MAIL_TYPE_ALL_JJC), font = G_FONT, size = FONT_SIZE_SMALL, 
	x = newLab:getPositionX() + newLab:getContentSize().width + 10, 
	y = newLab:getPositionY(), 
	color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	newValue:setAnchorPoint(cc.p(0, 0.5))
	self.m_newValueLabel = newValue
end


function BattleReportView:delHandler(tag,sender)
	--判断是否有邮件
	local count
	if sender.type == MAIL_TYPE_PERSON_JJC then
		count = #MailMO.myJJCPersonReprot_
	end

	if count == 0 then
		Toast.show(CommonText[554][5])
		return
	end
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	-- 是否确定取消
	ConfirmDialog.new(CommonText[554][7], function()
			Loading.getInstance():show()
			MailBO.asynDelJJCReport(function()
				Loading.getInstance():unshow()
				Toast.show(CommonText[551][2])
				end,0,sender.type)

		end):push()

	
end

function BattleReportView:updateMailsState()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	self:updateTip()
end

function BattleReportView:updateTip()
	for index=MAIL_TYPE_PERSON_JJC,MAIL_TYPE_ALL_JJC do
		local newMailsCount = MailBO.getNewReportCount(index)
		if newMailsCount > 0 then
			UiUtil.showTip(self.m_pageView.m_yesButtons[index - 4], newMailsCount, 142, 50)
			UiUtil.showTip(self.m_pageView.m_noButtons[index - 4], newMailsCount, 135, 37)
		else
			UiUtil.unshowTip(self.m_pageView.m_yesButtons[index - 4])
			UiUtil.unshowTip(self.m_pageView.m_noButtons[index - 4])
		end
	end
end

function BattleReportView:onExit()
	BattleReportView.super.onExit(self)
	
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end

return BattleReportView