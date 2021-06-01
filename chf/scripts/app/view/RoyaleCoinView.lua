--
-- Author: Gss
-- Date: 2018-08-24 15:40:05
--
----------------排行----------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 110)
	self.m_data = RoyaleSurviveMO.getScoreGoldById()
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_data[index]
	--底部线
	local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width - 10, line:height()))
	line:setPosition(self.m_cellSize.width / 2, 0)
	--图片
	local rank = display.newSprite(IMAGE_COMMON.."honor_" .. index .. ".png"):addTo(cell)
	rank:setPosition(rank:width() / 2 + 20, self.m_cellSize.height / 2)
	rank:setScale(0.8)
	--领奖积分限制
	local begainScore = data.score1 == nil and " + " or UiUtil.strNumSimplify(data.score1)
	local endScore = data.score2 == nil and " + " or UiUtil.strNumSimplify(data.score2)
	local str = begainScore.." - "..endScore
	if not data.score2 then
		str = begainScore..endScore
	end
	local score = UiUtil.label(str, 24, COLOR[2]):addTo(cell)
	score:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	--奖励预览
	local award = json.decode(data.goldreward)

	local itemView = UiUtil.createItemView(award[1], award[2],{count = award[3]}):addTo(cell)
	itemView:setPosition(self.m_cellSize.width - itemView:width(), self.m_cellSize.height / 2 + 5)
	itemView:setScale(0.8)

	local resData = UserMO.getResourceData(award[1], award[2])
	local awardName = UiUtil.label(resData.name, 16):alignTo(itemView, -50, 1)

	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_data
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

-----------------------------------总览界面-----------
local RoyaleCoinView = class("RoyaleCoinView",function ()
	return display.newNode()
end)

function RoyaleCoinView:ctor(width,height, data)
	self:size(width,height)
	local paramStr = CommonText[985]
	if data.awardId > 0 then
		paramStr = RoyaleSurviveMO.getScoreGoldById(data.awardId).name
	end
	local myRank = UiUtil.label(CommonText[764][1]):addTo(self):align(display.CENTER_TOP, 20, height - 25)
	myRank:setAnchorPoint(cc.p(0,0.5))
	local score = UiUtil.label(data.score,nil,COLOR[2]):rightTo(myRank)
	local myTitle = UiUtil.label(CommonText[2114]):addTo(self):alignTo(myRank, -30, 1)
	local name = UiUtil.label(paramStr,nil,COLOR[3]):rightTo(myTitle)

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, width-20, height-168)
	bg:addTo(self):pos(width/2,bg:height()/2+78)
	local score = UiUtil.label(CommonText[2113][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(bg:width() / 2, bg:height() - 24)
	local name = UiUtil.label(CommonText[2113][2],nil,cc.c3b(150,150,150)):leftTo(score,120)
	local desc = UiUtil.label(CommonText[2113][3],nil,cc.c3b(150,150,150)):rightTo(score, 120)
	local view = ContentTableView.new(cc.size(bg:width() - 20, bg:height()-55))
		:addTo(bg):pos(10,10)
	view:reloadData()

	local awardBtn = UiUtil.button("btn_11_normal.png", "btn_11_selected.png", "btn_9_disabled.png",handler(self,self.onReward),CommonText[255])
		:addTo(self):pos(width/2,30)
	awardBtn.awardId = data.awardId
	awardBtn:setEnabled(data.status == 1)
	awardBtn:setLabel(data.status == 2 and CommonText[672][2] or CommonText[255])
	self.m_awardBtn = awardBtn
end

function RoyaleCoinView:onReward(tag, sender)
	ManagerSound.playNormalButtonSound()
	RoyaleSurviveBO.getHonourGoldAwards(function (success)
		if success then
			self.m_awardBtn:setEnabled(false)
			self.m_awardBtn:setLabel(CommonText[672][2])
		end
	end, sender.awardId)
end

return RoyaleCoinView