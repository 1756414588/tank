--
-- Author: gf
-- Date: 2015-12-17 10:17:13
-- 百团混战 排行奖励


local PartyBAwardTableView = class("PartyBAwardTableView", TableView)



function PartyBAwardTableView:ctor(size,type)
	PartyBAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 200)

	self.list = PartyBattleMO.getRankAward(type)
	self.type = type
end

function PartyBAwardTableView:numberOfCells()
	return #self.list
end

function PartyBAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyBAwardTableView:createCellAtIndex(cell, index)
	PartyBAwardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]

	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self.m_cellSize.height - 30)

	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = bg:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	info:setAnchorPoint(cc.p(0,0.5))

	info:setString(string.format(CommonText[257],data.rank))


	local awardList = data.awards
	-- gdump(dayWeal,"当前等级每日福利")
	for index=1,#awardList do
		local award = awardList[index]
		--军团奖励第一名增加BUFF图标

		if self.type == 2 and data.rank == 1 then
			local itemView = UiUtil.createItemView(ITEM_KIND_EFFECT, EFFECT_ID_PB_RESOURCE)
			itemView:setPosition(50 + itemView:getContentSize().width / 2,bg:getPositionY() - 80)
			itemView:setScale(0.8)
			cell:addChild(itemView)
			UiUtil.createItemDetailButton(itemView, cell, true)	
			local name = ui.newTTFLabel({text = CommonText[821][1], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
		end

		local itemView = UiUtil.createItemView(award[1], award[2])
		if self.type == 2 and data.rank == 1 then
			itemView:setPosition(160 + itemView:getContentSize().width / 2 + (index - 1) * 110,bg:getPositionY() - 80)
		else
			itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 110,bg:getPositionY() - 80)
		end
		itemView:setScale(0.8)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)		

		local propDB = UserMO.getResourceData(award[1], award[2])
		local name = ui.newTTFLabel({text = propDB.name2 .. " * " .. award[3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end


	return cell
end



function PartyBAwardTableView:onExit()
	PartyBAwardTableView.super.onExit(self)

end



local Dialog = require("app.dialog.Dialog")
local PartyBAwardDialog = class("PartyBAwardDialog", Dialog)

function PartyBAwardDialog:ctor(type)
	PartyBAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.type = type
end

function PartyBAwardDialog:onEnter()
	PartyBAwardDialog.super.onEnter(self)
	
	self:setTitle(CommonText[771])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	if self.type == 1 then
		local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
		tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 160))
		tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 45 - tableBg:getContentSize().height / 2)

		local view = PartyBAwardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),self.type):addTo(tableBg)
		view:setPosition(0, 10)
		view:reloadData()

		--当前排名
		local rankLab = ui.newTTFLabel({text = CommonText[764][2], font = G_FONT, color = COLOR[11],
			align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = 100}):addTo(btm)
		rankLab:setAnchorPoint(cc.p(0, 0.5))

		local rankValue = ui.newTTFLabel({text = CommonText[768], font = G_FONT, color = COLOR[6],
			align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = rankLab:getPositionX() + rankLab:getContentSize().width, y = 100}):addTo(btm)
		rankValue:setAnchorPoint(cc.p(0, 0.5))
		if PartyBattleMO.myRankWin and PartyBattleMO.myRankWin.rank and PartyBattleMO.myRankWin.rank > 0 and PartyBattleMO.myRankWin.rank <= 10 then
			rankValue:setString(PartyBattleMO.myRankWin.rank)
			rankValue:setColor(COLOR[2])
		else
			rankValue:setString(CommonText[768])
			rankValue:setColor(COLOR[6]) 
		end

		--领取奖励按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
		local awardGetBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardGetHandler)):addTo(btm)
		awardGetBtn:setPosition(btm:getContentSize().width / 2, 40)
		awardGetBtn:setLabel(CommonText[777][1])
		awardGetBtn:setEnabled(PartyBattleMO.rankWinGet)
		self.awardGetBtn = awardGetBtn
	else
		local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
		tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 60))
		tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 45 - tableBg:getContentSize().height / 2)

		local view = PartyBAwardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),self.type):addTo(tableBg)
		view:setPosition(0, 10)
		view:reloadData()
	end
end

function PartyBAwardDialog:awardGetHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBattleBO.asynWarWinAward(function()
		Loading.getInstance():unshow()
		self.awardGetBtn:setEnabled(PartyBattleMO.rankWinGet)
		end)
end

return PartyBAwardDialog
