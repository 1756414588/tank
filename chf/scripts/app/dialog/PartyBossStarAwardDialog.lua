--
-- Author: Gss
-- Date: 2018-11-22 17:10:26
--
--军团BOSS星级奖励预览 PartyBossStarAwardDialog

local AwardTableView = class("AwardTableView", TableView)

function AwardTableView:ctor(size,award)
	AwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_award = award
	local height = size.height + 80
	if self.m_award and #self.m_award > 0 then
		height = height + math.ceil(#self.m_awardand / 4) * 150
	end
	
	self.m_cellSize = cc.size(size.width, height)
end

function AwardTableView:numberOfCells()
	return 1
end

function AwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function AwardTableView:createCellAtIndex(cell, index)
	AwardTableView.super.createCellAtIndex(self, cell, index)
	local award = json.decode(self.m_award.award)
	local x,y,ex,ey = 70,self.m_cellSize.height - 60, 130, 130
	for k,v in ipairs(award) do
		local tx,ty = x + (k-1)%4*ex,y - math.floor((k-1)/4)*ey
		local view = UiUtil.createItemView(v[1], v[2],{count = v[3]}):addTo(cell):pos(tx,ty):scale(0.82)
		-- UiUtil.createItemDetailButton(view)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local t = UiUtil.label(propDB.name,nil,COLOR[propDB.quality or 1]):addTo(cell):alignTo(view, -60, 1)
	end

	return cell
end

-------------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local PartyBossStarAwardDialog = class("PartyBossStarAwardDialog", Dialog)

function PartyBossStarAwardDialog:ctor(lv,star)
	PartyBossStarAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 580)})
	self.m_award = PartyMO.queryPartyBossAwards(lv,star)
end

function PartyBossStarAwardDialog:onEnter()
	PartyBossStarAwardDialog.super.onEnter(self)
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(self:getBg():width() - 30, 500))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 8)

	self:setTitle(CommonText[269])

	local desc = UiUtil.label(CommonText[3009]):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0,0.5))
	desc:setPosition(40,self:getBg():height() - 80)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
	bg:setPreferredSize(cc.size(btm:width() - 30, btm:height() - 60))
	bg:setPosition(btm:width() / 2, btm:height() / 2 - 20)

	local AwardTableView = AwardTableView.new(cc.size(bg:width() - 10, bg:height() - 10),self.m_award):addTo(bg)
	AwardTableView:setPosition(0, 5)
	AwardTableView:reloadData()
end

return PartyBossStarAwardDialog
