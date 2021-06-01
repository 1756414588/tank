--
-- Author: Xiaohang
-- Date: 2016-05-09 14:48:18
--
-- 军团战奖励预览

local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 180)
	self.m_activityList = PartyBattleMO.getAll("fortressRankAward")
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local t = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	t:pos(t:width()/2+30,150)
	UiUtil.label(string.format(CommonText[20046],index), nil, COLOR[12])
		:addTo(t):align(display.LEFT_CENTER,54,t:height()/2)
	local test = self.m_activityList[index]
	local x,ex = 100,120
	for k,v in ipairs(test) do
		local t = UiUtil.createItemView(v[1], v[2],{count = v[3]}):addTo(cell):pos(x+(k-1)*ex, 80):scale(0.9)
		UiUtil.createItemDetailButton(t, cell, true)
		local propDB = UserMO.getResourceData(v[1], v[2])
		UiUtil.label(propDB.name, nil,COLOR[propDB.quality or 1]):addTo(cell):pos(t:x(),t:y()-60)
	end
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end
------------------------------------------------------------------------------
-- 坦克改装view
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local MonumentRewardDialog = class("MonumentRewardDialog", Dialog)

-- tankId: 需要改装的tank
function MonumentRewardDialog:ctor()
	MonumentRewardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
end

function MonumentRewardDialog:onEnter()
	MonumentRewardDialog.super.onEnter(self)
	self:setTitle(CommonText[269])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	UiUtil.label(CommonText[20047]):addTo(self:getBg()):align(display.LEFT_CENTER, 55, self:getBg():height()-85)
	UiUtil.createItemView(ITEM_KIND_EFFECT, 18):addTo(self:getBg())
		:pos(120,self:getBg():height()-155)
	local eb = EffectMO.queryEffectById(1)
	local t = UiUtil.label(eb.desc,nil,COLOR[2]):addTo(self:getBg()):align(display.LEFT_CENTER,180, self:getBg():height()-120)
	UiUtil.label(string.format(CommonText[20053],12),nil,COLOR[12]):addTo(self:getBg()):alignTo(t,-30,-1)
	UiUtil.sprite9("info_bg_15.png", 30, 30, 1, 1, 500, self:getBg():height()-290)	
		:addTo(self:getBg()):pos(self:getBg():width()/2,(self:getBg():height()-290)/2+70)
	local view = ContentTableView.new(cc.size(500, self:getBg():height()-300))
		:addTo(self:getBg()):pos(42,73)
	view:reloadData()

	UiUtil.label(CommonText[20048]):addTo(self:getBg()):align(display.LEFT_CENTER, 55, 55)
end

function MonumentRewardDialog:onExit()
	MonumentRewardDialog.super.onExit(self)
end

function MonumentRewardDialog:showUI()
	
end

return MonumentRewardDialog
