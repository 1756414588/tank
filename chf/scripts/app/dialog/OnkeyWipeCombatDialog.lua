------------------------------------------------------------------------------
-- 扫荡结果tableview
------------------------------------------------------------------------------

local WipeTableView = class("WipeTableView", TableView)

-- isWaiing:是否等待新的一次扫荡结果中。如果ture，则表示wipeResult是之前的扫荡结果，还需要显示现在的扫荡中信息
function WipeTableView:ctor(size, wipeResult)
	WipeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 195)
	self.m_wipeResult = {}
	self.explorePass = {EXPLORE_TYPE_PART,EXPLORE_TYPE_EQUIP,EXPLORE_TYPE_MEDAL,EXPLORE_TYPE_WAR,EXPLORE_TYPE_ENERGYSPAR,EXPLORE_TYPE_TACTIC}

	for k,v in pairs(self.explorePass) do
		for m,n in pairs(wipeResult) do
			if n.exploreType == v then
				table.insert(self.m_wipeResult,n)
				break
			end
		end
	end
end

function WipeTableView:numberOfCells()
	return #self.m_wipeResult
end

function WipeTableView:cellSizeForIndex(index)
	local rewardInfo = self.m_wipeResult[index].award
	if rewardInfo and table.nums(rewardInfo) > 0 then
		local line = math.ceil(table.nums(rewardInfo) / 4)
		return cc.size(self:getViewSize().width, 80 + line * 140)
	else
		return cc.size(self:getViewSize().width, 250)
	end
end

function WipeTableView:createCellAtIndex(cell, index)
	local cellSize = self:cellSizeForIndex(index)

	gprint("WipeTableView index:", index)
	WipeTableView.super.createCellAtIndex(self, cell, index)

	-- 第x次扫荡
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, cellSize.height - 40)

	local sectionId = CombatMO.getExploreSectionIdByType(self.m_wipeResult[index].exploreType)
	local exploreSection = CombatMO.querySectionById(sectionId)

	local title = ui.newTTFLabel({text = exploreSection.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	-- 获得物品
	local label = ui.newTTFLabel({text = CommonText[286] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = bg:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local awards = self.m_wipeResult[index].award

	if awards then
		for i = 1, #awards do
			local award = awards[i]
			local itemView = UiUtil.createItemView(award.kind, award.id):addTo(cell)
			itemView:setScale(0.9)
			local rowx,rowy = self:getLowAndRow(i,4)
			itemView:setPosition(30 + (rowx - 0.5) * 120, cellSize.height - rowy*140)

			local resData = UserMO.getResourceData(award.kind, award.id)
			local name = ui.newTTFLabel({text = resData.name .. "*" .. UiUtil.strNumSimplify(award.count), font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			if award.kind == ITEM_KIND_TACTIC or award.kind == ITEM_KIND_TACTIC_PIECE then
				name:setColor(COLOR[resData.quality + 1])
			end
		end
	end

	return cell
end

function WipeTableView:getLowAndRow(j,num)
	if num ==nil then
		num = 4
	end
	local rowy = j%num
	if rowy == 0 then
		rowy = j/num
	else
		rowy = j/num+1
	end
	rowy = math.floor(rowy)

	rowx = j%num
	if rowx == 0 then
		rowx = num 
	end
	return rowx,rowy
end

------------------------------------------------------------------------------
-- 扫荡
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local OnkeyWipeCombatDialog = class("OnkeyWipeCombatDialog", Dialog)

local WIPE_TOTAL_COUNT = 10
local WIPE_TOTAL_MAX = POWER_MAX_VALUE

function OnkeyWipeCombatDialog:ctor()
	OnkeyWipeCombatDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
end

function OnkeyWipeCombatDialog:onEnter()
	OnkeyWipeCombatDialog.super.onEnter(self)

	self:setTitle(CommonText[35])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:showUI()
end

function OnkeyWipeCombatDialog:updatePowerListener()

end

function OnkeyWipeCombatDialog:onExit()
	OnkeyWipeCombatDialog.super.onExit(self)
	-- 主要用于探险副本刷新次数
	Notify.notify(LOCAL_COMBAT_UPDATE_EVENT)
end


function OnkeyWipeCombatDialog:showUI()
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(510, self:getBg():getContentSize().height-100))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - infoBg:getContentSize().height / 2-60)

	local container = display.newNode():addTo(infoBg)
	container:setContentSize(infoBg:getContentSize())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height / 2)
	self.m_container = container
	self:showResult()
end

function OnkeyWipeCombatDialog:showResult()
	self.m_container:removeAllChildren()
	local container = self.m_container
	local view = WipeTableView.new(cc.size(self.m_container:getContentSize().width - 8, self.m_container:getContentSize().height - 8),CombatMO.wipeReward.rewardInfo):addTo(container)
	view:setPosition(4, 4)
	view:reloadData()
end

return OnkeyWipeCombatDialog
