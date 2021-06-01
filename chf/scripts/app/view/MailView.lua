--
-- Author: gf
-- Date: 2015-09-07 15:07:04
-- 邮件


local MailView = class("MailView", UiNode)

function MailView:ctor(pageIndex)
	MailView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	
	self.pageIndex_ = pageIndex
	if not self.pageIndex_ then self.pageIndex_ = 1 end
end

function MailView:onEnter()
	MailView.super.onEnter(self)

	self.m_updateHandler = Notify.register(LOCAL_MAIL_UPDATE_EVENT, handler(self, self.updateMailsState))

	self:setTitle(CommonText[547])

	local function createDelegate(container, index)
		local MailTableView = require("app.scroll.MailTableView")
		local view = nil

		view = MailTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 90 - 4), index):addTo(container)

		if view then
			view:setPosition(0, 90)
			view:reloadData()
		end

		--按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_store_del_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_store_del_selected.png")
		local delBtn = MenuButton.new(normal, selected, nil, handler(self,self.delHandler)):addTo(container)
		delBtn:setPosition(container:getContentSize().width / 2 - 240,50)

		local allLab = ui.newTTFLabel({text = CommonText[552][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = delBtn:getPositionX() + delBtn:getContentSize().width / 2 + 10, 
		y = delBtn:getPositionY() + 20, 
		color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		allLab:setAnchorPoint(cc.p(0, 0.5))

		local allValue = ui.newTTFLabel({text = #MailMO.queryMyMails_(index), font = G_FONT, size = FONT_SIZE_SMALL, 
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

		local newValue = ui.newTTFLabel({text = MailBO.getNewMailCount(index), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = newLab:getPositionX() + newLab:getContentSize().width + 10, 
		y = newLab:getPositionY(), 
		color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		newValue:setAnchorPoint(cc.p(0, 0.5))
		self.m_newValueLabel = newValue

		if UserMO.queryFuncOpen(UFP_MAIL_SYNC) then
			UiUtil.label(CommonText[20132],20,COLOR[6]):addTo(container):align(display.LEFT_CENTER,30,2)
		else
			UiUtil.label(CommonText[100028],20,COLOR[6]):addTo(container):align(display.LEFT_CENTER,30,2)
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local friendBtn = MenuButton.new(normal, selected, nil, handler(self,self.openSocialityView)):addTo(container)
		friendBtn:setPosition(container:getContentSize().width / 2 + 140 ,50)
		friendBtn:setLabel(CommonText[552][3])

		--一键领取
		if UserMO.queryFuncOpen(UFP_MAIL_SYNC) then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
			local rewardBtn = MenuButton.new(normal, selected, nil, handler(self,self.rewardAllMails)):addTo(container)
			rewardBtn:leftTo(friendBtn,-10)
			rewardBtn:setLabel(CommonText[100026])
			rewardBtn:setVisible(index == 4)
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_sendMail_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_sendMail_selected.png")
		local mailBtn = MenuButton.new(normal, selected, nil, handler(self,self.mailHandler)):addTo(container)
		mailBtn:setPosition(container:getContentSize().width / 2 + 260,50)

	end

	local function clickDelegate(container, index)
	end

	local pages = {CommonText[548][1],CommonText[548][2],CommonText[548][3],CommonText[548][4]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.pageIndex_)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	
	if UserMO.queryFuncOpen(UFP_MAIL_SYNC) and #MailMO.queryMyMails_(4) >= 200 then
		require("app.dialog.MailDelDialog").new(CommonText[100030],function ()
			pageView:setPageIndex(4)
		end):push()
	end

	self:updateTip()
end

function MailView:updateMailsState()
	-- self.m_allValueLabel:setString(#MailMO.queryMyMails_(self.m_index_))
	-- self.m_newValueLabel:setString(MailBO.getNewMailCount(self.m_index_))
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	self:updateTip()
end

function MailView:openSocialityView()
	ManagerSound.playNormalButtonSound()
	self:pop()
	require("app.view.SocialityView").new():push()
end

--邮件一键领取
function MailView:rewardAllMails()
	ManagerSound.playNormalButtonSound()
	local mtype = self.m_pageView:getPageIndex()
	MailBO.rewardMailAwards(function ()
		MailBO.getMails(function ()
			Notify.notify(LOCAL_MAIL_UPDATE_EVENT)
		end)
	end,mtype)
end

function MailView:mailHandler()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.MailSendDialog").new(nil,MAIL_SEND_TYPE_NORMAL):push()
end

function MailView:delHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	--判断是否有邮件
	if self.m_allValueLabel:getString() == "0" then
		Toast.show(CommonText[554][5])
		return
	end

	local pageIdx = self.m_pageView:getPageIndex()
	if pageIdx ~= 2 then --如果是发件。保持不变
		local function deleteCallback()
			Toast.show(CommonText[551][2])
		end

		if pageIdx == 4 then
			-- if MailBO.getHasAwardsMail() then --如果有没领的附件
			require("app.dialog.TipsAnyThingDialog").new(CommonText[1635], function ()
				MailBO.deleteMials(deleteCallback, pageIdx, MAIL_DELETE_TYPE_NULL)
			end):push()
			-- else
			-- 	MailBO.deleteMials(deleteCallback, pageIdx, MAIL_DELETE_TYPE_NULL)
			-- end
		else
			require("app.dialog.MailDeleteDialog").new(sender, pageIdx ,deleteCallback):push()
		end
	else
		local function delAllMail()
			Loading.getInstance():show()
			MailBO.asynDelMail(function()
				Loading.getInstance():unshow()
				Toast.show(CommonText[551][2])
				end,nil,self.m_pageView:getPageIndex())
		end

		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		-- 是否确定取消
		ConfirmDialog.new(CommonText[554][6], function()
				--判断是否有未领取附件的邮件
				if self.m_pageView:getPageIndex() == 4 and MailBO.getHasAwardsMail() then
					ConfirmDialog.new(CommonText[841], function()
						delAllMail()
					end):push()
				else
					delAllMail()

				end
			end):push()
	end
end

function MailView:updateTip()
	for index=1,#CommonText[548] do
		local newMailsCount = MailBO.getNewMailCount(index)
		if newMailsCount > 0 then
			UiUtil.showTip(self.m_pageView.m_yesButtons[index], newMailsCount, 142, 50)
			UiUtil.showTip(self.m_pageView.m_noButtons[index], newMailsCount, 135, 37)
		else
			UiUtil.unshowTip(self.m_pageView.m_yesButtons[index])
			UiUtil.unshowTip(self.m_pageView.m_noButtons[index])
		end
	end
end

function MailView:onExit()
	-- gprint("MailView onExit() ........................")
	MailView.super.onExit(self)
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end

	Notify.notify(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT)
end




return MailView