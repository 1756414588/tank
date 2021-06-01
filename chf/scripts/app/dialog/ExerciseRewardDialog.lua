--
-- Author: Xiaohang
-- Date: 2016-08-10 15:15:19
--
-- 演习奖励预览
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,kind)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.kind = kind
	self.m_cellSize = cc.size(size.width, 200)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(585, 190))
	bg:setCapInsets(cc.rect(130, 40, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	titBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - titBg:getContentSize().height / 2)

	local str = self.kind == 1 and string.format(CommonText[257],index) or CommonText[20091][index]
	local titLab = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, 
	x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	local awardDB = self.m_activityList[index]
	for k,v in ipairs(awardDB) do
		local itemView = UiUtil.createItemView(v[1], v[2],{count = v[3]})
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (k - 1) * 100,bg:getContentSize().height - 90)
		itemView:setScale(0.9)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 2, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end
	return cell
end

function ContentTableView:numberOfCells()
	return self.kind == 2 and 2 or #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
	self.m_activityList = data
	self:reloadData()
end
------------------------------------------------------------------------------
-- 坦克改装view
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ExerciseRewardDialog = class("ExerciseRewardDialog", Dialog)

-- tankId: 需要改装的tank
function ExerciseRewardDialog:ctor(kind)
	ExerciseRewardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.kind = kind
end

function ExerciseRewardDialog:onEnter()
	ExerciseRewardDialog.super.onEnter(self)
	self:setTitle(self.kind == 1 and CommonText[10062][1] or CommonText[20089])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	UiUtil.sprite9("info_bg_37.png", 30, 30, 1, 1, 500, self:getBg():height()-240)	
		:addTo(self:getBg()):align(display.CENTER_TOP,self:getBg():width()/2,self:getBg():height()-70)

	local view = ContentTableView.new(cc.size(490, self:getBg():height()-244),self.kind)
		:addTo(self:getBg()):pos(45,175)
	view:updateUI(self.kind == 1 and PartyBattleMO.getAll("drillRankAward") or PartyBattleMO.getCampReward())

	local btn = UiUtil.button("btn_2_normal.png","btn_2_selected.png","btn_1_disabled.png",
			handler(self, self.getReward),CommonText[672][1]):addTo(self:getBg()):pos(self:getBg():width()/2,100)
	local state = true
	local str = CommonText[672][1]
	if self.kind == 1 then 
		state = ExerciseBO.ranks.canGetRank
		if not state and ExerciseBO.ranks.myRank > 0 and ExerciseBO.ranks.myRank <= 10 then
			str = CommonText[672][2]
		end
		local t = ManagerTimer.getTime()
		local week = tonumber(os.date("%w",t))
		local h = tonumber(os.date("%H", t))
		local m = tonumber(os.date("%M", t))
		local s = tonumber(os.date("%S", t))
		if state and week == 2 and h == 21 and m < 30 then
			state = false
		end
	end
	btn:setEnabled(state)
	btn:setLabel(str)
	btn:setVisible(self.kind == 1)
	self.btn = btn
end

function ExerciseRewardDialog:onExit()
	ExerciseRewardDialog.super.onExit(self)
end

function ExerciseRewardDialog:getReward(tag,sender)
	ManagerSound.playNormalButtonSound()
	ExerciseBO.getReward(self.kind,function()
			self.btn:setLabel(CommonText[672][2])
			self.btn:setEnabled(false)
		end)
end

return ExerciseRewardDialog
