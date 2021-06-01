
-- 技能tableview

local SkillTableView = class("SkillTableView", TableView)

function SkillTableView:ctor(size, needRefresh)
	SkillTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_needRefresh = needRefresh

	self.m_cellSize = cc.size(size.width, 145)
	self.m_cellNum = SkillMO.queryMaxSkill()

	self.m_curProductNum = 0
end

function SkillTableView:onEnter()
	SkillTableView.super.onEnter(self)

	if self.m_needRefresh then
		local function doneGetSkill()
			Loading.getInstance():unshow()
			local offset = self:getContentOffset()
			self:reloadData()
			self:setContentOffset(offset)
		end
		Loading.getInstance():show()
		self.dataScheduler_ = scheduler.performWithDelayGlobal(function() self.dataScheduler_ = nil; SkillBO.asynGetSkill(doneGetSkill) end, 0.2)
	end
end

function SkillTableView:onExit()
	SkillTableView.super.onExit(self)

	if self.dataScheduler_ then
		scheduler.unscheduleGlobal(self.dataScheduler_)
		self.dataScheduler_ = nil
	end
end

function SkillTableView:numberOfCells()
	return self.m_cellNum
end

function SkillTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SkillTableView:createCellAtIndex(cell, index)
	SkillTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local skillLv = SkillMO.getSkillLevelById(index)
	local skillDB = SkillMO.querySkillById(index)

	local itemView = UiUtil.createItemView(ITEM_KIND_SKILL, skillDB.skillId):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local attrData = SkillBO.getSkillAttrData(index)
	-- gdump(attrData)

	-- 标题
	local title = ui.newTTFLabel({text = skillDB.name .. " LV." .. skillLv, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

	local desc = ui.newTTFLabel({text = "+" .. (attrData.value * 100) .. "%" .. skillDB.desc, font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 89, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	desc:setAnchorPoint(cc.p(0, 0.5))

	-- 详情按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDetailCallback))
	detailBtn.index = index
	cell:addButton(detailBtn, self.m_cellSize.width - 172, self.m_cellSize.height / 2 - 22)

	-- 升级按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local upBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onSkillUpCallback))
	upBtn.index = index
	cell:addButton(upBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)

	return cell
end

function SkillTableView:onDetailCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local DetailSkillDialog = require("app.dialog.DetailSkillDialog")
	DetailSkillDialog.new(sender.index):push()
end

function SkillTableView:onSkillUpCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local skillId = sender.index
	local skillLv = SkillMO.getSkillLevelById(skillId)
	if skillLv + 1 > UserMO.level_ then  -- 指挥官等级不足
		Toast.show(CommonText[245])
		return
	end

	if skillLv + 1 > UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK) then
		local bagCount = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK_BAG)
		if bagCount > 0 then -- 有技能书礼包
			self:dispatchEvent({name = "USE_SKILL_BAG_EVENT", skillId = skillId})
		else
			Toast.show(PropMO.getPropName(PROP_ID_SKILL_BOOK) .. CommonText[223])  -- 技能书不足
		end
		return
	end

	self:dispatchEvent({name = "CHOSEN_SKILL_EVENT", skillId = skillId})
end

return SkillTableView
