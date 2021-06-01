--
-- Author: gf
-- Date: 2015-09-03 17:11:33
-- 社交
local ConfirmDialog = require("app.dialog.ConfirmDialog")


local SocialityView = class("SocialityView", UiNode)

SOCIALITY_FOR_FRIEND = 1
SOCIALITY_FOR_BLESS = 2
SOCIALITY_FOR_STORE = 3

function SocialityView:ctor(viewFor)
	SocialityView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	
	self.m_viewFor = viewFor or SOCIALITY_FOR_FRIEND
end

function SocialityView:onEnter()
	SocialityView.super.onEnter(self)

	self.m_friendUpdateHandler = Notify.register(LOCAL_FRIEND_UPDATE_EVENT, handler(self, self.onPageUpdate))
	-- self.m_blessUpdateHandler = Notify.register(LOCAL_BLESS_ACCEPT_EVENT, handler(self, self.onBlessUpdate))
	self.m_blessSysHandler = Notify.register(LOCAL_BLESS_GET_EVENT, handler(self, self.onBlessUpdate))
	
	self:setTitle(CommonText[8])

	local function createDelegate(container, index)
		if index == 1 then  -- 好友
			self.getBlessBtn = nil
			self:showFriend(container)
		elseif index == 2 then -- 祝福
			self:showBless(container)
		elseif index == 3 then --收藏
			-- Loading.getInstance():show()
			-- SocialityBO.asynGetStore(function()
			-- 	Loading.getInstance():unshow()
			-- 	self:showStore(container)
			-- end)
			self.getBlessBtn = nil
			self:showStore(container)
			
		end
	end

	local function clickDelegate(container, index)
		if index == 1 then
			Loading.getInstance():show()
			SocialityBO.getFriend(function()
				Loading.getInstance():unshow()
				end)
		end
	end

	local pages = {CommonText[537][1],CommonText[537][2],CommonText[537][3]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	if self.m_viewFor == 1 then
		Loading.getInstance():show()
		SocialityBO.getFriend(function()
			Loading.getInstance():unshow()
			pageView:setPageIndex(self.m_viewFor)
			end)
	else
		pageView:setPageIndex(self.m_viewFor)
	end
	
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self:updateTip()

	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.DetailTextDialog").new(DetailText.friendGive):push() 
		end):addTo(self:getBg(),99):pos(self:getBg():width() - 80, self:getBg():height() - 130)
end

function SocialityView:showFriend(container)
	local MyFriendTableView = require("app.scroll.MyFriendTableView")
	local view = MyFriendTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 120 - 4)):addTo(container)
	view:setPosition(0, 120)
	view:reloadData()
	self.myFriendTableView = view

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(container)
	line:setPreferredSize(cc.size(view:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, view:getPositionY())

	local friendCountLab = ui.newTTFLabel({text = CommonText[539], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 50, y = 80, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	friendCountLab:setAnchorPoint(cc.p(0, 0.5))

	local friendCountValue = ui.newTTFLabel({text = #SocialityMO.myFriends_ .. "/" .. SocialityMO.friendMax, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = friendCountLab:getPositionX() + friendCountLab:getContentSize().width, y = friendCountLab:getPositionY(), color = COLOR[2], 
		align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	friendCountValue:setAnchorPoint(cc.p(0, 0.5))
	self.friendCountValue = friendCountValue

	--本月赠送次数
	local giveTime = UiUtil.label(CommonText[1876]):addTo(container)
	giveTime:setAnchorPoint(cc.p(0, 0.5))
	giveTime:setPosition(container:width() - 250, 80)
	local times = UiUtil.label(SocialityMO.myfriendGiveMax.."/"..UserMO.querySystemId(74),nil, COLOR[2]):rightTo(giveTime)

	local function onEdit(event, editbox)
	--    if eventType == "return" then
	--    end
    end
	local input_bg = IMAGE_COMMON .. "btn_7_unchecked.png"

    local inputDesc = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(316, 40)}):addTo(container)
	inputDesc:setFontColor(cc.c3b(255, 255, 255))
	inputDesc:setFontSize(FONT_SIZE_MEDIUM)
	inputDesc:setPosition(container:getContentSize().width / 2 - 125, 30)
	self.inputDesc = inputDesc

	local function clearEdit()
		ManagerSound.playNormalButtonSound()
		self.inputDesc:setText("")
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_del_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_del_selected.png")
	local delBtn = MenuButton.new(normal, selected, nil, clearEdit):addTo(inputDesc)
	delBtn:setPosition(inputDesc:getContentSize().width - 30,inputDesc:getContentSize().height / 2)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_search_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_search_selected.png")
	local searchBtn = MenuButton.new(normal, selected, nil, handler(self,self.searchHandler)):addTo(container)
	searchBtn.container = container
	searchBtn:setPosition(inputDesc:getPositionX() + inputDesc:getContentSize().width / 2 + 50,inputDesc:getPositionY())

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local blessBtn = MenuButton.new(normal, selected, nil, handler(self,self.blessAllHandler)):addTo(container)
	blessBtn:setPosition(searchBtn:getPositionX() + 140,searchBtn:getPositionY())
	blessBtn:setLabel(CommonText[538][5])
end

function SocialityView:showBless(container)
	
	local MyBlessTableView = require("app.scroll.MyBlessTableView")
	local view = MyBlessTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 70 - 4)):addTo(container)
	view:setPosition(0, 70)
	view:reloadData()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(container)
	line:setPreferredSize(cc.size(view:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, view:getPositionY())

	local friendCountLab = ui.newTTFLabel({text = CommonText[705], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 50, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	friendCountLab:setAnchorPoint(cc.p(0, 0.5))

	local friendCountValue = ui.newTTFLabel({text = #SocialityMO.myBless_ .. "/" .. SocialityMO.blessNumMax, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = friendCountLab:getPositionX() + friendCountLab:getContentSize().width, y = friendCountLab:getPositionY(), color = COLOR[2], 
		align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	friendCountValue:setAnchorPoint(cc.p(0, 0.5))
	self.blessCountValue = friendCountValue


	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local getBlessBtn = MenuButton.new(normal, selected, disabled, handler(self,self.getAllBlessHandler)):addTo(container)
	getBlessBtn:setPosition(container:getContentSize().width - 100,30)
	getBlessBtn:setLabel(CommonText[538][9])
	getBlessBtn:setEnabled(SocialityBO.getBlessCount() > 0)
	self.getBlessBtn = getBlessBtn

	Loading.getInstance():show()
	SocialityBO.asynGetBless(function()
		Loading.getInstance():unshow()
			self:onBlessUpdate()
		end)
end

function SocialityView:showStore(container)

	local MyStoreTableView = require("app.scroll.MyStoreTableView")
	local view = MyStoreTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 100 - 4)):addTo(container)
	view:addEventListener("CHECK_STORE_EVENT", handler(self, self.onCheckStore))
	view:setPosition(0, 100)
	view:reloadData()
	self.myStoreTableView = view

	self.pageButtons = {}
	local asset = {"world","mine","enemy","friend"}
	local pos = {
		container:getContentSize().width / 2 - 150,
		container:getContentSize().width / 2 - 70,
		container:getContentSize().width / 2 + 10,
		container:getContentSize().width / 2 + 90
	}
	for index=1,4 do
		local normal = display.newSprite(IMAGE_COMMON .. "btn_store_" .. asset[index] .. "_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_store_" .. asset[index] .. "_selected.png")

		local btn = MenuButton.new(normal, selected, nil, handler(self,self.pageHandler)):addTo(container)
		btn.index = index
		btn:setPosition(pos[index],50)
		self.pageButtons[index] = btn
	end

	--删除按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local delBtn = MenuButton.new(normal, selected, disabled, handler(self,self.delHandler)):addTo(container)
	delBtn:setLabel(CommonText[549][1])
	delBtn:setPosition(container:getContentSize().width - 100, 50)
	self.m_storeDelBtn = delBtn
	delBtn:setEnabled(false)
end

function SocialityView:onCheckStore()
	local poses = self.myStoreTableView:getCheckedStorePos()
	self.m_storeDelBtn:setEnabled(#poses > 0)
end

function SocialityView:delHandler()
	local poses = self.myStoreTableView:getCheckedStorePos()
	gdump(poses,"poses====")

	ManagerSound.playNormalButtonSound()
	ConfirmDialog.new(CommonText[695], function()
		Loading.getInstance():show()
		SocialityBO.asynDelStore(function()
			Loading.getInstance():unshow()
			self.m_storeDelBtn:setEnabled(false)
		end,poses)
	end):push()
end

function SocialityView:pageHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.myStoreTableView:setShowIndex(sender.index)
	for index=1,#self.pageButtons do
		if index == sender.index then
			self.pageButtons[index]:selected()
		else
			self.pageButtons[index]:unselected()
		end
	end
end


function SocialityView:showSearchResult(player,container)
	self.myFriendTableView:setVisible(false)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(container)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2 + 300)

	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, player.icon):addTo(bg)
	itemView:setScale(0.65)
	itemView:setPosition(90,bg:getContentSize().height / 2)

	local name = ui.newTTFLabel({text = player.nick, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local level = ui.newTTFLabel({text = "LV.".. player.level, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = 60, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	level:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local addBtn = MenuButton.new(normal, selected, nil, handler(self,self.addHandler)):addTo(bg)
	addBtn:setLabel(CommonText[538][3])
	addBtn:setPosition(bg:getContentSize().width - addBtn:getContentSize().width + 40,bg:getContentSize().height / 2 - 10)
	addBtn.lordId = player.lordId

	nodeTouchEventProtocol(bg, function(event) self:showPlayerDetail(player) end, nil, nil, true)
end

function SocialityView:showPlayerDetail(man)
	local function closeCb()
		self.m_pageView:setPageIndex(1)
	end
	local player = {icon = man.icon, nick = man.nick, level = man.level, lordId = man.lordId, rank = man.ranks,
        fight = man.fight, sex = man.sex, party = man.partyName, pros = man.pros, prosMax = man.prosMax}
    require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_FRIEND, player):push()
end

function SocialityView:addHandler(tag,sender)
	if #SocialityMO.myFriends_ >= SocialityMO.friendMax then
		Toast.show(CommonText[710])
		return
	end
	Loading.getInstance():show()
	SocialityBO.asynAddFriend(function()
			Loading.getInstance():unshow()
			self.m_pageView:setPageIndex(1)
			
		end,sender.lordId)
	SocialityBO.getFriend()
end

function SocialityView:searchHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local nick = string.gsub(self.inputDesc:getText()," ","")
	if nick == "" then
        Toast.show(CommonText[540])
        return
    end
    Loading.getInstance():show()
	SocialityBO.asynSearchPlayer(function(player)
			Loading.getInstance():unshow()
			if player then
				self:showSearchResult(player,sender.container)
			end 
		end,nick)
end

function SocialityView:blessAllHandler()
	ManagerSound.playNormalButtonSound()
	local value = PropMO.getAddValueByRedId(1)
	--判断是否有可祝福的好友
	if SocialityBO.getCanBlessFriends() == false then
		Toast.show(CommonText[542])
		return
	end
	Loading.getInstance():show()
	SocialityBO.asynGiveBless(function()
		Loading.getInstance():unshow()
			Toast.show(string.format(CommonText[1849][2], value))
		end,0)
	SocialityBO.getFriend()
end

function SocialityView:getAllBlessHandler()
	local function getBless()
		Loading.getInstance():show()
		SocialityBO.asynAcceptBless(function()
			Loading.getInstance():unshow()
			end,0)
	end
	ManagerSound.playNormalButtonSound()
	-- if UserMO.power_ >= POWER_MAX_HAVE then
	-- 	Toast.show(CommonText[20007])
	-- 	return
	-- end
	if #SocialityMO.myBless_ + UserMO.power_ > POWER_MAX_HAVE then
		local canGet = POWER_MAX_HAVE-UserMO.power_
		if canGet < 0 then
			canGet = 0
		end

		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		local t = ConfirmDialog.new(string.format(CommonText[20008],POWER_MAX_HAVE, canGet),function()
					getBless()
				end):push()
		t.m_cancelBtn:setLabel(CommonText[20009])
		return
	else
		getBless()
	end

end

function SocialityView:onBlessUpdate()
	if not self.getBlessBtn then return end
	self.getBlessBtn:setEnabled(SocialityBO.getBlessCount() > 0)
	self.blessCountValue:setString(#SocialityMO.myBless_ .. "/" .. SocialityMO.blessNumMax)
	self:updateTip()
end

function SocialityView:updateTip()
	local blessCount = SocialityBO.getBlessCount()
	if blessCount > 0 then
		UiUtil.showTip(self.m_pageView.m_yesButtons[SOCIALITY_FOR_BLESS], blessCount, 142, 50)
		UiUtil.showTip(self.m_pageView.m_noButtons[SOCIALITY_FOR_BLESS], blessCount, 135, 37)
	else
		UiUtil.unshowTip(self.m_pageView.m_yesButtons[SOCIALITY_FOR_BLESS])
		UiUtil.unshowTip(self.m_pageView.m_noButtons[SOCIALITY_FOR_BLESS])
	end
end

function SocialityView:onPageUpdate()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

function SocialityView:onExit()
	SocialityView.super.onExit(self)
	if self.m_friendUpdateHandler then
		Notify.unregister(self.m_friendUpdateHandler)
		self.m_friendUpdateHandler = nil
	end

	if self.m_blessUpdateHandler then
		Notify.unregister(self.m_blessUpdateHandler)
		self.m_blessUpdateHandler = nil
	end

	if self.m_blessSysHandler then
		Notify.unregister(self.m_blessSysHandler)
		self.m_blessSysHandler = nil
	end
end

return SocialityView