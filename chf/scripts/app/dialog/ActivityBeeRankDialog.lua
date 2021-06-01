--
-- Author: gf
-- Date: 2015-12-08 14:48:13
--


--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local ActivityBeePlayerTableView = class("ActivityBeePlayerTableView", TableView)

function ActivityBeePlayerTableView:ctor(size,data)
	ActivityBeePlayerTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 80)
	self.data_ = data
	self.actPlayerRank_ = data.actPlayerRank

end

function ActivityBeePlayerTableView:onEnter()
	ActivityBeePlayerTableView.super.onEnter(self)
end

function ActivityBeePlayerTableView:numberOfCells()
	return #self.actPlayerRank_
end

function ActivityBeePlayerTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityBeePlayerTableView:createCellAtIndex(cell, index)
	ActivityBeePlayerTableView.super.createCellAtIndex(self, cell, index)

	
	local data = self.actPlayerRank_[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	
	local rankTitle = ArenaBO.createRank(index)
	rankTitle:setPosition(45, 40)
	bg:addChild(rankTitle)

	local name = ui.newTTFLabel({text = data.nick, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 200, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	if index == 1 then
		name:setColor(COLOR[6])
	elseif index == 2 then
		name:setColor(COLOR[12])
	elseif index == 3 then
		name:setColor(COLOR[4])
	else
		name:setColor(COLOR[11])
	end

	local scoreValue = ui.newTTFLabel({text = UiUtil.strNumSimplify(data.rankValue), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 400, y = 40, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	return cell
end

function ActivityBeePlayerTableView:onExit()
	ActivityBeePlayerTableView.super.onExit(self)
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local ActivityBeeRankDialog = class("ActivityBeeRankDialog", Dialog)

function ActivityBeeRankDialog:ctor(data)
	ActivityBeeRankDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.rankData_ = data
	if not self.rankData_.activityId then
		self.rankData_.activityId = ACTIVITY_ID_BEE
	end
end

function ActivityBeeRankDialog:onEnter()
	ActivityBeeRankDialog.super.onEnter(self)
	
	self:setTitle(UserMO.getResourceData(ITEM_KIND_RESOURCE, self.rankData_.resourceId).name2 .. CommonText[779])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	
	local rankLab = ui.newTTFLabel({text = CommonText[391] .. "：", font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[11], x = 40, y = btm:getContentSize().height - 50}):addTo(btm)

	local myRankData = ActivityCenterBO.getMyBeeRank(self.rankData_.actPlayerRank)
	local rankTxt
	if not myRankData then
		rankTxt = CommonText[768]
	else
		rankTxt = myRankData.rank
	end

	local rankValue = ui.newTTFLabel({text = rankTxt, font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[2], x = rankLab:getPositionX() + rankLab:getContentSize().width / 2, y = btm:getContentSize().height - 50}):addTo(btm)

	local stateLab = ui.newTTFLabel({text = CommonText[776], font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[11], x = 40, y = btm:getContentSize().height - 80}):addTo(btm)

	local stateValue = ui.newTTFLabel({text = UiUtil.strNumSimplify(self.rankData_.state), font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[2], x = stateLab:getPositionX() + stateLab:getContentSize().width / 2, y = btm:getContentSize().height - 80}):addTo(btm)

	
	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 200))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - (btm:getContentSize().height - 130) / 2 - 70)

	local posX = {65,200,400}
	for index=1,#CommonText[780] do
		local title = ui.newTTFLabel({text = CommonText[780][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		title:setAnchorPoint(cc.p(0, 0.5))
	end


	local view = ActivityBeePlayerTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.rankData_):addTo(tableBg)
	view:setPosition(0, 25)
	view:reloadData()

	--按钮
	
	--领取奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local awardGetBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardGetHandler)):addTo(btm)
	awardGetBtn:setPosition(btm:getContentSize().width / 2, 50)
	awardGetBtn:setLabel(CommonText[777][1])
	self.awardGetBtn = awardGetBtn

	local actBeeRank = ActivityCenterMO.activityContents_[self.rankData_.activityId].actBeeRank

	if actBeeRank.open == true and myRankData then
		--是否已领取
		if self.rankData_.status == 0 then
			awardGetBtn:setLabel(CommonText[777][1])
			awardGetBtn:setEnabled(true)
			awardGetBtn.rankType = myRankData.rankType
			awardGetBtn.rankData_ = self.rankData_
		else
			awardGetBtn:setLabel(CommonText[777][3])
			awardGetBtn:setEnabled(false)
		end
	else
		awardGetBtn:setLabel(CommonText[769][2])
		awardGetBtn:setEnabled(false)
	end
end

function ActivityBeeRankDialog:awardGetHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynGetRankAward(function()
		Loading.getInstance():unshow()
		self.awardGetBtn:setLabel(CommonText[777][3])
		self.awardGetBtn:setEnabled(false)
		end, self.rankData_.activityId, sender.rankType, sender.rankData_)

end

return ActivityBeeRankDialog