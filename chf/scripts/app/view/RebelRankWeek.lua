--
-- Author: Xiaohang
-- Date: 2016-09-06 16:16:28
--
-----------------------------------内容条界面---------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,kind)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 86)
	self.kind = kind
	self.list = {}
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	if index == #self.list + 1 then -- 最后一个按钮
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_normal.png")
		normal:setPreferredSize(cc.size(500, 76))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_selected.png")
		selected:setPreferredSize(cc.size(500, 76))
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onNextCallback))
		btn:setLabel(CommonText[577])
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		return cell
	end
	local data = self.list[index]
	local t = nil
	if index <= 3 then
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(57,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(57,self.m_cellSize.height/2)
	end
	t = UiUtil.label(data.name,nil,COLOR[2]):addTo(cell):alignTo(t, 138)
	t = UiUtil.label("/"..data.killGuard.."/",nil,COLOR[3]):alignTo(t, 170)
	UiUtil.label(data.killUnit,nil,COLOR[2]):leftTo(t)
	UiUtil.label(data.killLeader,nil,COLOR[4]):rightTo(t)

	t = UiUtil.label(data.score,nil,COLOR[2]):addTo(cell):alignTo(t, 122)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(560, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
	return cell
end

function ContentTableView:onNextCallback(tag, sender)
	local page = math.ceil(#self.list / RANK_PAGE_NUM)
	if self.kind == 1 then
		RebelBO.getRank(1,page,function()
			if RebelBO.rankData.rebelRanks and #RebelBO.rankData.rebelRanks > 0 then
				local oldHeight = self:getContainer():getContentSize().height
				for k,v in ipairs(RebelBO.rankData.rebelRanks) do
					table.insert(self.list,v)
				end
				self:updateUI(self.list)
				local delta = self:getContainer():getContentSize().height - oldHeight
				self:setContentOffset(cc.p(0, -delta))
			end
		end)
	else -- self.kind == 2 then
		RebelBO.getRank(3,page,function()
			if RebelBO.rankData.rebelRanks and #RebelBO.rankData.rebelRanks > 0 then
				local oldHeight = self:getContainer():getContentSize().height
				for k,v in ipairs(RebelBO.rankData.rebelRanks) do
					table.insert(self.list,v)
				end
				self:updateUI(self.list)
				local delta = self:getContainer():getContentSize().height - oldHeight
				self:setContentOffset(cc.p(0, -delta))
			end
		end)
	end
end

function ContentTableView:numberOfCells()
	if #self.list < RANK_PAGE_NUM or #self.list >= 100 then
		return #self.list
	else
		return #self.list + 1
	end
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(list)
	self.list = list
	self:reloadData()
end


















-----------------------------------总览界面-----------
local RebelRankWeek = class("RebelRankWeek",function ()
	return display.newNode()
end)

function RebelRankWeek:ctor(width,height)
	self:size(width,height)

	-- local tag = display.newSprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(self)
	-- tag:setPosition(self:getContentSize().width / 2, self:getContentSize().height - tag:getContentSize().height / 2)

	local size = cc.size(self:getContentSize().width, self:getContentSize().height - 58)

	local pages = {CommonText[30062], CommonText[802][2]}

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_53_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_53_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(button:width() * 0.5 + 10, size.height + 34)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_53_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_53_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(button:width() * 1.5 + 10, size.height + 34)
		end
		button:setLabel(pages[index])
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_53_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_53_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(button:width() * 0.5 + 10, size.height + 34)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_53_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_53_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(button:width() * 1.5 + 10, size.height + 34)
		end
		button:setLabel(pages[index], {color = COLOR[11]})

		return button
	end

	local containerDelegateHandler1 = handler(self, self.showInfo)

	local containerDelegateHandler2 = handler(self, self.partRankView)

	local function createDelegate(container, index)
		if index == 1 then  -- 挂件
			local function resoultCallback()
				if containerDelegateHandler1 then
					containerDelegateHandler1(container, index)
				end
			end
			RebelBO.getRank(1,0,resoultCallback)
		elseif index == 2 then -- 头像
			local function resoultCallback()
				if containerDelegateHandler2 then
					containerDelegateHandler2(container, index)
				end
			end
			RebelBO.getRank(3,0,resoultCallback)
		end
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate( index )
		if index == 2 and (not PartyMO.partyData_.partyId or PartyMO.partyData_.partyId <= 0) then
			Toast.show(CommonText[1854])
			return false
		end
		return true
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = self:getContentSize().width / 2, y = size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}, hideDelete = true}):addTo(self, 2)
	pageView:setPageIndex(1)

	-- RebelBO.getRank(1,0,handler(self, self.showInfo))
end

-- 个人排行
function RebelRankWeek:showInfo(container, index)

	local t = UiUtil.label(CommonText[20123],nil,cc.c3b(125,125,125)):addTo(container):align(display.LEFT_CENTER,20,container:height())
	self:showLeft(t, RebelBO.rankData.killUnit, RebelBO.rankData.killGuard, RebelBO.rankData.killLeader)
	t = UiUtil.label(CommonText[764][1],nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	local myScore = UiUtil.label(RebelBO.rankData.score,nil,COLOR[3]):rightTo(t)
	t = UiUtil.label(CommonText[20028] .."：",nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	local rankNum = UiUtil.label(RebelBO.rankData.rank == 0 and CommonText[768] or RebelBO.rankData.rank):rightTo(t)
	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, container:width()-20, container:height()-155)
  	bg:addTo(container):pos(container:width()/2,bg:height()/2+85)
  	local t = UiUtil.label(CommonText[396][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
  	t = UiUtil.label(CommonText[396][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 138)
  	t = UiUtil.label(CommonText[20124],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 170)
  	t = UiUtil.label(CommonText[770][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 122)
  	--内容
	local view = ContentTableView.new(cc.size(560, bg:height()-55),index)
		:addTo(bg):pos(30,10)
	view:updateUI(RebelBO.rankData.rebelRanks)
	UiUtil.label(string.format(CommonText[20125],20)):addTo(container):align(display.LEFT_CENTER,40,70)
	t = UiUtil.label(CommonText[20126]):addTo(container):align(display.LEFT_CENTER,440,70)
	local lastRank = UiUtil.label(RebelBO.rankData.lastRank,nil,COLOR[2]):rightTo(t)
	local function lookAward(tar, sender)
		ManagerSound.playNormalButtonSound()
		require("app.dialog.RebelAwardDialog").new():push()
	end
	UiUtil.button("btn_9_normal.png","btn_9_selected.png",nil,lookAward,CommonText[769][1])
		:addTo(container):pos(110,30)
	local function checkGetState(self_)
		if table.isexist(RebelBO.rankData, "getReward") then
			local str = RebelBO.rankData.getReward == true and CommonText[777][3] or CommonText[777][1]
			self_:setLabel(str)
			self_:setEnabled(not RebelBO.rankData.getReward)
		else
			self_:setEnabled(false)
		end
	end
	local function getAward(tar, sender)
		ManagerSound.playNormalButtonSound()
		RebelBO.getRankAward(handler(sender,sender.checkGetStateFunc), 1)
	end
	local getBtn = UiUtil.button("btn_11_normal.png","btn_11_selected.png","btn_9_disabled.png",getAward,CommonText[769][3])
	:addTo(container):pos(container:width() - 110,30)
	getBtn.checkGetStateFunc = checkGetState
	getBtn:checkGetStateFunc()

end

-- 军团排行
function RebelRankWeek:partRankView(container, index)
	local t = UiUtil.label(CommonText[1853][1] ..":",nil,cc.c3b(125,125,125)):addTo(container):align(display.LEFT_CENTER,20,container:height())
	UiUtil.label(PartyMO.partyData_.partyName,nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[1853][2] .. ":",nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	self:showLeft(t, RebelBO.rankPartyBata.killUnit, RebelBO.rankPartyBata.killGuard, RebelBO.rankPartyBata.killLeader)
	t = UiUtil.label(CommonText[1853][3] .. ":",nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	local myScore = UiUtil.label(RebelBO.rankPartyBata.score,nil,COLOR[3]):rightTo(t)
	t = UiUtil.label(CommonText[20028] .."：",nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	local rank = RebelBO.rankPartyBata.rank
	local rankNum = UiUtil.label(rank == 0 and CommonText[768] or rank):rightTo(t)
	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, container:width()-20, container:height()-180)
  	bg:addTo(container):pos(container:width()/2,bg:height()/2+85)
  	local t = UiUtil.label(CommonText[396][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
  	t = UiUtil.label(CommonText[805][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 138)
  	t = UiUtil.label(CommonText[20124],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 170)
  	t = UiUtil.label(CommonText[770][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 122)
  	--内容
	local view = ContentTableView.new(cc.size(560, bg:height()-55), index)
		:addTo(bg):pos(30,10)
	view:updateUI(RebelBO.rankPartyBata.rebelRanks)
	UiUtil.label(string.format(CommonText[20125],50)):addTo(container):align(display.LEFT_CENTER,40,70)
	t = UiUtil.label(CommonText[20126]):addTo(container):align(display.LEFT_CENTER,440,70)
	local lastRank = UiUtil.label(RebelBO.rankPartyBata.lastRank,nil,COLOR[2]):rightTo(t)
	local function lookAward(tar, sender)
		ManagerSound.playNormalButtonSound()
		require("app.dialog.RebelAwardDialog").new("rebelPartyRankAward"):push()
	end
	UiUtil.button("btn_9_normal.png","btn_9_selected.png",nil,lookAward,CommonText[769][1])
		:addTo(container):pos(110,30)
	local function checkGetState(self_)
		if table.isexist(RebelBO.rankPartyBata, "getReward") then
			local str = RebelBO.rankPartyBata.getReward == true and CommonText[777][3] or CommonText[777][1]
			self_:setLabel(str)
			self_:setEnabled(not RebelBO.rankPartyBata.getReward)
		else
			self_:setEnabled(false)
		end
	end
	local function getAward(tar, sender)
		ManagerSound.playNormalButtonSound()
		RebelBO.getRankAward(handler(sender,sender.checkGetStateFunc), 3)
	end
	local getBtn = UiUtil.button("btn_11_normal.png","btn_11_selected.png","btn_9_disabled.png",getAward,CommonText[769][3])
	:addTo(container):pos(container:width() - 110,30)
	getBtn.checkGetStateFunc = checkGetState
	getBtn:checkGetStateFunc()
end

function RebelRankWeek:showLeft(label, value1, value2, value3)
	label:removeAllChildren()
	local t = UiUtil.label(CommonText[20120][1],nil,COLOR[2]):addTo(label):align(display.LEFT_CENTER,label:width()+5,label:height()/2)
	t = UiUtil.label(":" .. value1,nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(" " ..CommonText[20120][2],nil,COLOR[3]):rightTo(t,10)
	t = UiUtil.label(":" .. value2,nil,COLOR[3]):rightTo(t)
	t = UiUtil.label(" " ..CommonText[20120][3],nil,COLOR[4]):rightTo(t,10)
	t = UiUtil.label(":" .. value3,nil,COLOR[4]):rightTo(t)
end

return RebelRankWeek