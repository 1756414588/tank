--
-- Author: xiaoxing
-- Date: 2016-12-06 10:23:57
--
-----------------------------------内容条界面---------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,activityId)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 80)
	self.activityId = activityId
end

function ContentTableView:onEnter()
	ContentTableView.super.onEnter(self)
end

function ContentTableView:numberOfCells()
	return #self.rank
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)

	local data = self.rank[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(550, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	
	local rankTitle = ArenaBO.createRank(index)
	rankTitle:setPosition(45, 40)
	bg:addChild(rankTitle)

	local name = ui.newTTFLabel({text = data.nick, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 192, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	if index == 1 then
		name:setColor(COLOR[6])
	elseif index == 2 then
		name:setColor(COLOR[12])
	elseif index == 3 then
		name:setColor(COLOR[4])
	else
		name:setColor(COLOR[11])
	end

	local scoreValue = ui.newTTFLabel({text = data.rankValue, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 470, y = 40, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	return cell
end

function ContentTableView:updateUI(data)
	self.rank = data or {}
	self:reloadData()
end

function ContentTableView:onExit()
	ContentTableView.super.onExit(self)
end

-----------------------------------总览界面-----------
local ActivityStorehoursePage3 = class("ActivityStorehoursePage3",function ()
	return display.newNode()
end)

function ActivityStorehoursePage3:ctor(width,height,activity)
	self.activity = activity
	self:size(width,height)
	ActivityCenterBO.getActPirateRank(handler(self, self.showInfo))
end

function ActivityStorehoursePage3:showInfo(score,status,list,info,open)
	ActivityCenterMO.activityContents_[ACTIVITY_ID_STOREHOUSE] = {}
	ActivityCenterMO.activityContents_[ACTIVITY_ID_STOREHOUSE].rankAward = info
	local myRank = CommonText[768]
	if list and #list > 0 then
		for index=1,#list do
			local player = list[index]
			if player.lordId == UserMO.lordId_ then
				myRank = index
				break
			end
		end
	end
	--我的积分
	local scoreLab = ui.newTTFLabel({text = CommonText[764][1], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = self:getContentSize().height - 30}):addTo(self)
	scoreLab:setAnchorPoint(cc.p(0, 0.5))

	local scoreValue = ui.newTTFLabel({text = " ", font = G_FONT, color = COLOR[2],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = scoreLab:getPositionX() + scoreLab:getContentSize().width, y = scoreLab:getPositionY()}):addTo(self)
	scoreValue:setAnchorPoint(cc.p(0, 0.5))
	scoreValue:setString(score)

	--当前排名
	local rankLab = ui.newTTFLabel({text = CommonText[764][2], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 350, y = self:getContentSize().height - 30}):addTo(self)
	rankLab:setAnchorPoint(cc.p(0, 0.5))

	local rankValue = ui.newTTFLabel({text = " ", font = G_FONT, color = COLOR[6],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = rankLab:getPositionX() + rankLab:getContentSize().width, y = scoreLab:getPositionY()}):addTo(self)
	rankValue:setAnchorPoint(cc.p(0, 0.5))
	rankValue:setString(myRank)
	local rank = 100
	if myRank == CommonText[768] then
		rankValue:setColor(COLOR[6])
	else
		rankValue:setColor(COLOR[2])
		rank = myRank
	end

	--活动结束时结算排名
	local infoLab = ui.newTTFLabel({text = CommonText[764][3], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = self:getContentSize().height - 60}):addTo(self)
	infoLab:setAnchorPoint(cc.p(0, 0.5))

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(self)
	tableBg:setPreferredSize(cc.size(self:getContentSize().width, self:getContentSize().height - 160))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(self:getContentSize().width / 2, self:getContentSize().height - (self:getContentSize().height - 160) / 2 - 80)

	local posX = {65,200,490}
	for index=1,#CommonText[770] do
		local title = ui.newTTFLabel({text = CommonText[770][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		title:setAnchorPoint(cc.p(0, 0.5))
	end


	local view = ContentTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.activity.activityId):addTo(tableBg)
	view:setPosition(0, 25)
	view:updateUI(list)

	--按钮
	--查看奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local awardInfoBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardInfoHandler)):addTo(self)
	awardInfoBtn:setPosition(self:getContentSize().width / 2 - 150, 30)
	awardInfoBtn:setLabel(CommonText[769][1])

	--领取奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local awardGetBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardGetHandler)):addTo(self)
	awardGetBtn:setPosition(self:getContentSize().width / 2 + 150, 30)
	self.awardGetBtn = awardGetBtn

	--我的排名数据
	if open and rank <= 10 then
		if status == 0 then
			awardGetBtn:setLabel(CommonText[777][1])
			awardGetBtn:setEnabled(true)
		else
			awardGetBtn:setLabel(CommonText[777][3])
			awardGetBtn:setEnabled(false)
		end
	else
		awardGetBtn:setLabel(CommonText[777][2])
		awardGetBtn:setEnabled(false)
	end
end

function ActivityStorehoursePage3:awardInfoHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityFortuneAwardDialog").new(self.activity.activityId):push()
end

function ActivityStorehoursePage3:awardGetHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	
	Loading.getInstance():show()
	ActivityCenterBO.asynGetRankAward(function()
			Loading.getInstance():unshow()
			self.awardGetBtn:setLabel(CommonText[777][3])
			self.awardGetBtn:setEnabled(false)
		end,self.activity.activityId,0,sender.actFortuneRank)
end

return ActivityStorehoursePage3